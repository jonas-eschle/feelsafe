/// Real-controller tests for [SessionController] lifecycle edges (M5 C7a).
///
/// Drives the REAL controller + engine against an in-memory database and
/// covers the surfaces the dispatch / distress / gps suites leave out:
///
///   - double-start guard, GPS destination prompt wiring, lock-task mode,
///   - error isolation for home-widget publish, foreground-service
///     start/stop, lock-task release, and marker cleanup,
///   - quick exit, restartCurrentStep, resume, wrong-PIN counter reset,
///   - simulation controls (silent / speed / leap),
///   - the distress-confirmation countdown (begin / pause / resume /
///     auto-confirm at zero),
///   - crafted-event metadata fallbacks via the test-only seam,
///   - provider teardown while a session is live.
library;

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart' hide EnginePhase;

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/enums/gps_destination_source.dart';
import 'package:guardianangela/domain/enums/home_widget_status.dart';
import 'package:guardianangela/domain/enums/pause_reason.dart';
import 'package:guardianangela/domain/enums/stealth_icon_preset.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/mode_overrides.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/services/protocols/home_widget_service_protocol.dart';
import 'package:guardianangela/services/protocols/system_ui_service_protocol.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/session_log_recorder.dart';
import 'package:guardianangela/services/sim/audio_service_sim.dart';
import 'package:guardianangela/services/sim/background_session_service_sim.dart';
import 'package:guardianangela/services/sim/call_state_service_sim.dart';
import 'package:guardianangela/services/sim/contact_service_sim.dart';
import 'package:guardianangela/services/sim/flash_service_sim.dart';
import 'package:guardianangela/services/sim/home_widget_service_sim.dart';
import 'package:guardianangela/services/sim/location_service_sim.dart';
import 'package:guardianangela/services/sim/messaging_service_sim.dart';
import 'package:guardianangela/services/sim/notification_service_sim.dart';
import 'package:guardianangela/services/sim/phone_service_sim.dart';
import 'package:guardianangela/services/sim/recording_service_sim.dart';
import 'package:guardianangela/services/sim/screen_flash_service_sim.dart';
import 'package:guardianangela/services/sim/system_ui_service_sim.dart';
import 'package:guardianangela/services/sim/vibration_service_sim.dart';

// ─── Fakes ────────────────────────────────────────────────────────────────────

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository()
    : super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('lifecycle_test_'),
      );

  @override
  Future<AppSettings> load() async => const AppSettings();
}

class _FakeUserProfileRepository extends UserProfileRepository {
  _FakeUserProfileRepository() : super(keyProvider: _k);

  static Future<String> _k() async => '00' * 32;

  @override
  Future<UserProfile> load() async => const UserProfile();
}

/// A [HomeWidgetServiceProtocol] whose publish always throws — proves the
/// controller's fire-and-forget `.catchError` keeps the session alive.
final class _ThrowingHomeWidgetService implements HomeWidgetServiceProtocol {
  int publishAttempts = 0;

  @override
  Future<void> publishStatus({
    required HomeWidgetStatus status,
    Duration? elapsed,
    required String statusText,
    required String quickExitLabel,
    required String fakeCallLabel,
  }) async {
    publishAttempts++;
    throw Exception('widget storage exploded');
  }

  @override
  Future<void> registerCallback() async {}
}

/// A background service that can throw on start and/or stop.
final class _ThrowingBackgroundSessionService
    extends SimulationBackgroundSessionService {
  _ThrowingBackgroundSessionService({
    this.throwOnStart = false,
    this.throwOnStop = false,
  });

  final bool throwOnStart;
  final bool throwOnStop;

  @override
  Future<void> startService({
    required String title,
    required String body,
    bool stealth = false,
    String? fakeName,
  }) async {
    if (throwOnStart) throw Exception('fg start exploded');
    return super.startService(
      title: title,
      body: body,
      stealth: stealth,
      fakeName: fakeName,
    );
  }

  @override
  Future<void> stopService() async {
    if (throwOnStop) throw Exception('fg stop exploded');
    return super.stopService();
  }
}

/// A system-UI service whose lock-task toggle always throws.
final class _ThrowingSystemUiService implements SystemUiServiceProtocol {
  @override
  Future<void> setStealthIcon(StealthIconPreset preset) async {}

  @override
  Future<void> toggleLockTaskMode(bool enabled) async =>
      throw Exception('lock-task channel exploded');
}

/// A [SessionLogRepository] that throws on [deleteById] only — exercises
/// the marker-cleanup catch without breaking marker writes / finalise.
final class _DeleteThrowsSessionLogRepository extends SessionLogRepository {
  _DeleteThrowsSessionLogRepository(GuardianAngelaDatabase db)
    : super(db.sessionLogsDao);

  @override
  Future<void> deleteById(String id) async =>
      throw Exception('delete exploded');
}

// ─── Mode factories ───────────────────────────────────────────────────────────

/// holdButton mode parked in a 30 s wait phase so lifecycle calls can be
/// observed without any step action firing mid-test.
SessionMode _holdMode({
  String id = 'mode-hold',
  int? maxPauseMinutes,
  List<DisarmTrigger> disarmTriggers = const <DisarmTrigger>[],
  ModeOverrides? overrides,
}) => SessionMode(
  id: id,
  name: 'Lifecycle Test',
  maxPauseMinutes: maxPauseMinutes,
  disarmTriggers: disarmTriggers,
  overrides: overrides,
  chainSteps: <ChainStep>[
    ChainStep(
      id: 'step-$id-0',
      type: ChainStepType.holdButton,
      order: 0,
      waitSeconds: 30,
      durationSeconds: 30,
      gracePeriodSeconds: 5,
      retryCount: 1,
      randomize: false,
    ),
  ],
);

/// countdownWarning mode parked in a plain 30 s [EnginePhase.wait] (the
/// holdButton type uses the special holdWait phase instead).
SessionMode _countdownMode() => SessionMode(
  id: 'mode-countdown',
  name: 'Countdown Test',
  chainSteps: <ChainStep>[
    ChainStep(
      id: 'step-countdown-0',
      type: ChainStepType.countdownWarning,
      order: 0,
      waitSeconds: 30,
      durationSeconds: 30,
      gracePeriodSeconds: 5,
      retryCount: 1,
      randomize: false,
    ),
  ],
);

SessionMode _distressMode() => SessionMode(
  id: 'mode-distress',
  name: 'Distress',
  isDistressMode: true,
  chainSteps: <ChainStep>[
    ChainStep(
      id: 'step-distress-0',
      type: ChainStepType.holdButton,
      order: 0,
      waitSeconds: 30,
      durationSeconds: 30,
      gracePeriodSeconds: 5,
      retryCount: 0,
      randomize: false,
    ),
  ],
);

// ─── Container builder ────────────────────────────────────────────────────────

ProviderContainer _container(
  GuardianAngelaDatabase db, {
  HomeWidgetServiceProtocol? homeWidget,
  SystemUiServiceProtocol? systemUi,
  SimulationBackgroundSessionService? background,
  SessionLogRepository? logRepo,
  bool autoDispose = true,
}) {
  final container = ProviderContainer(
    overrides: [
      appSettingsRepositoryProvider.overrideWithValue(
        _FakeAppSettingsRepository(),
      ),
      userProfileRepositoryProvider.overrideWithValue(
        _FakeUserProfileRepository(),
      ),
      databaseProvider.overrideWith((ref) async => db),
      systemUiServiceProvider.overrideWithValue(
        systemUi ?? SimulationSystemUiService(),
      ),
      homeWidgetServiceProvider.overrideWithValue(
        homeWidget ?? SimulationHomeWidgetService(),
      ),
      if (logRepo != null)
        sessionLogRepositoryProvider.overrideWith((ref) async => logRepo),
      sessionLogRecorderProvider.overrideWith((ref) async {
        final repo = await ref.watch(sessionLogRepositoryProvider.future);
        return (SessionContext ctx) =>
            SimulationSessionLogRecorder(context: ctx, repo: repo);
      }),
      vibrationServiceProvider.overrideWithValue(SimulationVibrationService()),
      flashServiceProvider.overrideWithValue(SimulationFlashService()),
      screenFlashServiceProvider.overrideWithValue(
        SimulationScreenFlashService(),
      ),
      recordingServiceProvider.overrideWithValue(SimulationRecordingService()),
      locationServiceProvider.overrideWithValue(SimulationLocationService()),
      phoneServiceProvider.overrideWithValue(SimulationPhoneService()),
      messagingServiceProvider.overrideWithValue(SimulationMessagingService()),
      contactServiceProvider.overrideWith(
        (_) async => SimulationContactService(),
      ),
      audioServiceProvider.overrideWithValue(SimulationAudioService()),
      notificationServiceProvider.overrideWithValue(
        SimulationNotificationService(),
      ),
      callStateServiceProvider.overrideWithValue(SimulationCallStateService()),
      backgroundSessionServiceProvider.overrideWithValue(
        background ?? SimulationBackgroundSessionService(),
      ),
    ],
  );
  if (autoDispose) {
    addTearDown(container.dispose);
  }
  return container;
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // startSession registers a WidgetsBindingObserver (G-013 background clamp),
  // which needs an initialised binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  late GuardianAngelaDatabase db;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
  });

  tearDown(() async {
    await db.close();
  });

  group('startSession guards & wiring', () {
    test(
      'starting a second session while one is live throws StateError',
      () async {
        final container = _container(db);
        await container.read(sessionControllerProvider.future);
        final notifier = container.read(sessionControllerProvider.notifier);
        await notifier.startSession(mode: _holdMode(), simulate: false);

        await expectLater(
          notifier.startSession(mode: _holdMode(id: 'mode-2'), simulate: false),
          throwsStateError,
        );

        await notifier.endSession();
      },
    );

    test(
      'a throwing home-widget publish is swallowed — session unaffected',
      () async {
        final widget = _ThrowingHomeWidgetService();
        final container = _container(db, homeWidget: widget);
        await container.read(sessionControllerProvider.future);
        final notifier = container.read(sessionControllerProvider.notifier);

        await notifier.startSession(mode: _holdMode(), simulate: false);
        await _flush();
        await _flush();

        // The publish WAS attempted (so the catchError genuinely ran) …
        check(widget.publishAttempts).isGreaterOrEqual(1);
        // … and the session neither crashed nor surfaced an error.
        check(notifier.engine).isNotNull();
        check(
          container.read(sessionControllerProvider).value!.lastError,
        ).isNull();

        await notifier.endSession();
      },
    );

    test(
      'mode.maxPauseMinutes is threaded into the engine (pause works)',
      () async {
        final container = _container(db);
        await container.read(sessionControllerProvider.future);
        final notifier = container.read(sessionControllerProvider.notifier);

        await notifier.startSession(
          mode: _holdMode(maxPauseMinutes: 1),
          simulate: false,
        );
        notifier.pause();
        await _flush();

        check(notifier.engine!.snapshot).isA<EnginePaused>();
        check(
          container.read(sessionControllerProvider).value!.isPaused,
        ).isTrue();

        await notifier.endSession();
      },
    );

    test(
      'GPS promptAtStart disarm trigger raises the destination prompt',
      () async {
        final container = _container(db);
        await container.read(sessionControllerProvider.future);
        final notifier = container.read(sessionControllerProvider.notifier);

        await notifier.startSession(
          mode: _holdMode(
            disarmTriggers: const <DisarmTrigger>[GpsArrivalDisarmTrigger()],
          ),
          simulate: false,
        );

        check(
          container
              .read(sessionControllerProvider)
              .value!
              .needsGpsDestinationPrompt,
        ).isTrue();

        await notifier.endSession();
      },
    );

    test('a fixed-destination GPS trigger does NOT prompt', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);

      await notifier.startSession(
        mode: _holdMode(
          disarmTriggers: const <DisarmTrigger>[
            GpsArrivalDisarmTrigger(
              destinationSource: GpsDestinationSource.fixed,
              lat: 46.2,
              lng: 6.1,
            ),
          ],
        ),
        simulate: false,
      );

      check(
        container
            .read(sessionControllerProvider)
            .value!
            .needsGpsDestinationPrompt,
      ).isFalse();

      await notifier.endSession();
    });

    test('setGpsDestination clears the prompt flag', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(
        mode: _holdMode(
          disarmTriggers: const <DisarmTrigger>[GpsArrivalDisarmTrigger()],
        ),
        simulate: false,
      );

      notifier.setGpsDestination(lat: 46.2044, lng: 6.1432);

      check(
        container
            .read(sessionControllerProvider)
            .value!
            .needsGpsDestinationPrompt,
      ).isFalse();

      await notifier.endSession();
    });

    test('skipGpsDestination clears the prompt flag', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(
        mode: _holdMode(
          disarmTriggers: const <DisarmTrigger>[GpsArrivalDisarmTrigger()],
        ),
        simulate: false,
      );

      notifier.skipGpsDestination();

      check(
        container
            .read(sessionControllerProvider)
            .value!
            .needsGpsDestinationPrompt,
      ).isFalse();

      await notifier.endSession();
    });

    test(
      'stealth lockTaskMode engages lock-task on start, releases on end',
      () async {
        final systemUi = SimulationSystemUiService();
        final container = _container(db, systemUi: systemUi);
        await container.read(sessionControllerProvider.future);
        final notifier = container.read(sessionControllerProvider.notifier);

        await notifier.startSession(
          mode: _holdMode(
            overrides: const ModeOverrides(
              stealth: StealthConfig(enabled: true, lockTaskMode: true),
            ),
          ),
          simulate: false,
        );

        final engaged = systemUi.calls.whereType<LockTaskCall>().toList();
        check(engaged.map((c) => c.enabled)).deepEquals([true]);

        await notifier.endSession();

        final after = systemUi.calls.whereType<LockTaskCall>().toList();
        check(after.map((c) => c.enabled)).deepEquals([true, false]);
      },
    );

    test('a throwing lock-task release does not break endSession', () async {
      final container = _container(db, systemUi: _ThrowingSystemUiService());
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _holdMode(), simulate: false);

      // endSession always tries to release lock-task; the throw must be
      // contained so teardown completes and the state still flips to ended.
      await notifier.endSession();

      final state = container.read(sessionControllerProvider).value!;
      check(state.phase).equals(SessionPhase.ended);
      check(notifier.engine).isNull();
    });

    test('foreground-service start failure is non-fatal', () async {
      final container = _container(
        db,
        background: _ThrowingBackgroundSessionService(throwOnStart: true),
      );
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);

      await notifier.startSession(mode: _holdMode(), simulate: false);
      await _flush();

      check(notifier.engine).isNotNull();
      check(notifier.engine!.snapshot).isA<EngineRunning>();

      await notifier.endSession();
    });

    test('foreground-service stop failure is non-fatal', () async {
      final container = _container(
        db,
        background: _ThrowingBackgroundSessionService(throwOnStop: true),
      );
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _holdMode(), simulate: false);

      await notifier.endSession();

      final state = container.read(sessionControllerProvider).value!;
      check(state.phase).equals(SessionPhase.ended);
    });

    test(
      'marker cleanup failure is contained; the log still finalises',
      () async {
        final repo = _DeleteThrowsSessionLogRepository(db);
        final container = _container(db, logRepo: repo);
        await container.read(sessionControllerProvider.future);
        final notifier = container.read(sessionControllerProvider.notifier);

        await notifier.startSession(mode: _holdMode(), simulate: false);
        final recorder = notifier.recorder! as SimulationSessionLogRecorder;
        // The in-progress marker was written through the throwing repo.
        check(
          (await repo.getAll()).where((l) => l.endedAt == null),
        ).isNotEmpty();

        await notifier.endSession();
        // Finalisation is event-driven (unawaited) — give it a beat.
        final sw = Stopwatch()..start();
        while (recorder.finalisedLog == null &&
            sw.elapsed < const Duration(seconds: 5)) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }

        // The log still finalised even though deleting the in-progress marker
        // threw — and the orphan marker row survived (delete really failed).
        check(recorder.finalisedLog).isNotNull();
        check(
          (await repo.getAll()).where((l) => l.endedAt == null),
        ).isNotEmpty();
        check(
          container.read(sessionControllerProvider).value!.phase,
        ).equals(SessionPhase.ended);
      },
    );

    test('disposing the container mid-session ends the engine and stops the '
        'foreground service', () async {
      final bg = SimulationBackgroundSessionService();
      final container = _container(db, background: bg, autoDispose: false);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _holdMode(), simulate: false);
      final engine = notifier.engine!;
      check(engine.isEnded).isFalse();
      bg.reset();

      container.dispose();
      await _flush();

      check(engine.isEnded).isTrue();
      check(bg.calls.map((c) => c.method)).contains('stopService');
    });
  });

  group('session controls', () {
    test(
      'restartCurrentStep re-arms the step through its grace phase',
      () async {
        final container = _container(db);
        await container.read(sessionControllerProvider.future);
        final notifier = container.read(sessionControllerProvider.notifier);
        await notifier.startSession(mode: _countdownMode(), simulate: false);
        check(
          (notifier.engine!.snapshot as EngineRunning).phase,
        ).equals(EnginePhase.wait);

        notifier.restartCurrentStep();

        final snapshot = notifier.engine!.snapshot;
        check(snapshot).isA<EngineRunning>();
        check((snapshot as EngineRunning).phase).equals(EnginePhase.grace);

        await notifier.endSession();
      },
    );

    test('resume() after pause() restarts the engine', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _holdMode(), simulate: false);

      notifier.pause();
      await _flush();
      check(notifier.engine!.snapshot).isA<EnginePaused>();

      notifier.resume();
      await _flush();

      check(notifier.engine!.snapshot).isA<EngineRunning>();
      check(
        container.read(sessionControllerProvider).value!.isPaused,
      ).isFalse();

      await notifier.endSession();
    });

    test(
      'triggerQuickExit finalises the log and clears the recorder',
      () async {
        final container = _container(db);
        await container.read(sessionControllerProvider.future);
        final notifier = container.read(sessionControllerProvider.notifier);
        await notifier.startSession(mode: _holdMode(), simulate: false);
        final recorder = notifier.recorder;
        check(recorder).isNotNull();
        // While the session runs the live log id is exposed for deep links.
        check(notifier.currentSessionLogId).equals(recorder!.sessionId);

        await notifier.triggerQuickExit();

        // Log finalised with the quick-exit reason; recorder released.
        check(notifier.recorder).isNull();
        check(notifier.currentSessionLogId).isNull();
        final finalised =
            (recorder as SimulationSessionLogRecorder).finalisedLog;
        check(finalised).isNotNull();
        check(finalised!.endReason).equals(EndReason.userQuit);
        check(finalised.endedAt).isNotNull();

        await notifier.endSession();
      },
    );

    test('resetWrongPinAttempts zeroes the in-memory counter', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _holdMode(), simulate: false);

      check(notifier.notifyWrongPinAttempt()).equals(1);
      check(notifier.notifyWrongPinAttempt()).equals(2);

      notifier.resetWrongPinAttempts();

      check(notifier.wrongPinAttempts).equals(0);
      // The next wrong attempt counts from a clean slate.
      check(notifier.notifyWrongPinAttempt()).equals(1);

      await notifier.endSession();
    });

    test('debugContactCount reflects the contacts table', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);

      check(await notifier.debugContactCount()).equals(0);
      await ContactsRepository(db.contactsDao).upsert(
        EmergencyContact(
          id: 'c-1',
          name: 'Alex',
          phoneNumber: '+41790000000',
          sortOrder: 0,
        ),
      );
      check(await notifier.debugContactCount()).equals(1);
    });

    test('eventServices.isCancelled tracks engine liveness', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _holdMode(), simulate: false);

      final services = notifier.eventServices;
      check(services).isNotNull();
      final isCancelled = services!.isCancelled;
      check(isCancelled).isNotNull();
      // Live session → strategies must keep going.
      check(isCancelled!()).isFalse();

      await notifier.endSession();

      // Torn down → in-flight strategies must stop ASAP.
      check(isCancelled()).isTrue();
    });

    test(
      'the elapsed tick clears remainingSeconds once the engine has ended',
      () async {
        final container = _container(db);
        await container.read(sessionControllerProvider.future);
        final notifier = container.read(sessionControllerProvider.notifier);
        await notifier.startSession(mode: _holdMode(), simulate: false);

        int? remaining() =>
            container.read(sessionControllerProvider).value!.remainingSeconds;

        // First let the real 1 s tick publish a remaining time.
        final arm = Stopwatch()..start();
        while (remaining() == null &&
            arm.elapsed < const Duration(seconds: 8)) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
        check(remaining()).isNotNull();

        // End the engine underneath the controller (chain-exhausted shape):
        // the next periodic tick must stop publishing a remaining time.
        notifier.engine!.endSession();
        final clear = Stopwatch()..start();
        while (remaining() != null &&
            clear.elapsed < const Duration(seconds: 8)) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
        check(remaining()).isNull();

        await notifier.endSession();
      },
    );
  });

  group('crafted engine events (defensive metadata fallbacks)', () {
    test('unknown pause-reason name falls back to userRequested', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _holdMode(), simulate: false);

      notifier.debugHandleEngineEvent(
        const ChainEventData(
          ChainEvent.sessionPaused,
          metadata: {'reason': 'not-a-reason'},
        ),
      );

      final state = container.read(sessionControllerProvider).value!;
      check(state.isPaused).isTrue();
      check(state.pauseReason).equals(PauseReason.userRequested);

      await notifier.endSession();
    });

    test('pauseExpired clears the paused flag and reason', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _holdMode(), simulate: false);

      notifier.debugHandleEngineEvent(
        const ChainEventData(
          ChainEvent.sessionPaused,
          metadata: {'reason': 'userRequested'},
        ),
      );
      check(container.read(sessionControllerProvider).value!.isPaused).isTrue();

      notifier.debugHandleEngineEvent(
        const ChainEventData(ChainEvent.pauseExpired),
      );

      final state = container.read(sessionControllerProvider).value!;
      check(state.isPaused).isFalse();
      check(state.pauseReason).isNull();

      await notifier.endSession();
    });

    test('unknown end-reason name falls back to userQuit in the log', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _holdMode(), simulate: false);
      final recorder = notifier.recorder! as SimulationSessionLogRecorder;

      notifier.debugHandleEngineEvent(
        const ChainEventData(
          ChainEvent.sessionEnded,
          metadata: {'reason': 'not-a-reason'},
        ),
      );
      final sw = Stopwatch()..start();
      while (recorder.finalisedLog == null &&
          sw.elapsed < const Duration(seconds: 5)) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }

      check(
        container.read(sessionControllerProvider).value!.phase,
      ).equals(SessionPhase.ended);
      check(recorder.finalisedLog).isNotNull();
      check(recorder.finalisedLog!.endReason).equals(EndReason.userQuit);

      await notifier.endSession();
    });
  });

  group('simulation controls', () {
    test('setSimulationSilent updates the state flag', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _holdMode(), simulate: true);
      check(
        container.read(sessionControllerProvider).value!.simulationSilent,
      ).isTrue();

      notifier.setSimulationSilent(false);

      check(
        container.read(sessionControllerProvider).value!.simulationSilent,
      ).isFalse();

      await notifier.endSession();
    });

    test('setSimulationSpeed updates engine and state', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _holdMode(), simulate: true);

      notifier.setSimulationSpeed(2);

      check(notifier.engine!.speedMultiplier).equals(2.0);
      check(
        container.read(sessionControllerProvider).value!.simSpeedMultiplier,
      ).equals(2.0);

      await notifier.endSession();
    });

    test('setSimulationSpeed is a no-op on a real session', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _holdMode(), simulate: false);

      notifier.setSimulationSpeed(50);

      // Real engines must never be sped up (safety invariant).
      check(notifier.engine!.speedMultiplier).equals(1.0);

      await notifier.endSession();
    });

    test('leap() collapses the current wait phase (simulation only)', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _countdownMode(), simulate: true);
      check(
        (notifier.engine!.snapshot as EngineRunning).phase,
      ).equals(EnginePhase.wait);

      notifier.leap();
      await _flush();

      // The 30 s wait collapsed immediately: the step fired into duration.
      check(
        (notifier.engine!.snapshot as EngineRunning).phase,
      ).equals(EnginePhase.duration);

      await notifier.endSession();
    });

    test('leap() is a guarded no-op on a real session', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _countdownMode(), simulate: false);

      notifier.leap();
      await _flush();

      check(
        (notifier.engine!.snapshot as EngineRunning).phase,
      ).equals(EnginePhase.wait);

      await notifier.endSession();
    });
  });

  group('distress-confirmation countdown', () {
    test('beginDistressCountdown publishes the remaining seconds', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(
        mode: _holdMode(),
        simulate: false,
        distressMode: _distressMode(),
      );

      fakeAsync((FakeAsync fa) {
        notifier.beginDistressCountdown(seconds: 3);
        check(
          container
              .read(sessionControllerProvider)
              .value!
              .distressConfirmRemaining,
        ).equals(3);
        // Drain the periodic countdown timer before leaving the zone.
        notifier.cancelDistress();
      });

      await notifier.endSession();
    });

    test(
      'the countdown ticks down and auto-confirms distress at zero',
      () async {
        final container = _container(db);
        await container.read(sessionControllerProvider.future);
        final notifier = container.read(sessionControllerProvider.notifier);
        await notifier.startSession(
          mode: _holdMode(),
          simulate: false,
          distressMode: _distressMode(),
        );

        fakeAsync((FakeAsync fa) {
          notifier.beginDistressCountdown(seconds: 2);
          fa.elapse(const Duration(seconds: 1));
          check(
            container
                .read(sessionControllerProvider)
                .value!
                .distressConfirmRemaining,
          ).equals(1);

          fa.elapse(const Duration(seconds: 1));
          // Hit zero: the overlay state is cleared synchronously …
          check(
            container
                .read(sessionControllerProvider)
                .value!
                .distressConfirmRemaining,
          ).isNull();
        });
        // … and the engine has swapped to the distress chain (event delivery
        // happens on the real microtask loop outside the fakeAsync zone).
        await _flush();
        check(
          container.read(sessionControllerProvider).value!.isDistressChain,
        ).isTrue();

        await notifier.endSession();
      },
    );

    test(
      'pauseDistressCountdown freezes the timer; resume re-arms it',
      () async {
        final container = _container(db);
        await container.read(sessionControllerProvider.future);
        final notifier = container.read(sessionControllerProvider.notifier);
        await notifier.startSession(
          mode: _holdMode(),
          simulate: false,
          distressMode: _distressMode(),
        );

        int? remaining() => container
            .read(sessionControllerProvider)
            .value!
            .distressConfirmRemaining;

        fakeAsync((FakeAsync fa) {
          notifier.beginDistressCountdown();
          fa.elapse(const Duration(seconds: 1));
          check(remaining()).equals(4);

          // Freeze (PIN keypad open): time passing must not consume the window.
          notifier.pauseDistressCountdown();
          fa.elapse(const Duration(seconds: 30));
          check(remaining()).equals(4);

          // Resume re-arms at the preserved value.
          notifier.resumeDistressCountdown();
          // A second resume while running must not double-arm the timer.
          notifier.resumeDistressCountdown();
          fa.elapse(const Duration(seconds: 1));
          check(remaining()).equals(3);

          notifier.cancelDistress();
        });

        // The distress chain never fired during the frozen window.
        check(
          container.read(sessionControllerProvider).value!.isDistressChain,
        ).isFalse();

        await notifier.endSession();
      },
    );

    test('cancelDistress dismisses the countdown; resume after cancel is a '
        'no-op', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(
        mode: _holdMode(),
        simulate: false,
        distressMode: _distressMode(),
      );

      fakeAsync((FakeAsync fa) {
        notifier.beginDistressCountdown();
        fa.elapse(const Duration(seconds: 1));

        notifier.cancelDistress();
        check(
          container
              .read(sessionControllerProvider)
              .value!
              .distressConfirmRemaining,
        ).isNull();

        // Resuming a dismissed countdown must not restart anything.
        notifier.resumeDistressCountdown();
        fa.elapse(const Duration(seconds: 30));
        check(
          container
              .read(sessionControllerProvider)
              .value!
              .distressConfirmRemaining,
        ).isNull();
      });
      await _flush();
      check(
        container.read(sessionControllerProvider).value!.isDistressChain,
      ).isFalse();

      await notifier.endSession();
    });

    test(
      'confirmDistress without a configured distress mode fails loud',
      () async {
        final container = _container(db);
        await container.read(sessionControllerProvider.future);
        final notifier = container.read(sessionControllerProvider.notifier);
        // No distressMode argument and no default configured.
        await notifier.startSession(mode: _holdMode(), simulate: false);

        notifier.confirmDistress();

        final state = container.read(sessionControllerProvider).value!;
        check(state.lastError).isNotNull();
        check(state.lastError!).contains('no distress mode');
        check(state.isDistressChain).isFalse();

        await notifier.endSession();
      },
    );

    test('startDistressSession delegates to confirmDistress when a session '
        'is already running', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(
        mode: _holdMode(),
        simulate: false,
        distressMode: _distressMode(),
      );
      final engineBefore = notifier.engine;

      await notifier.startDistressSession(reason: EndReason.hardwarePanic);
      await _flush();

      // Same engine (no second session) — the running chain was replaced.
      check(identical(notifier.engine, engineBefore)).isTrue();
      check(
        container.read(sessionControllerProvider).value!.isDistressChain,
      ).isTrue();

      await notifier.endSession();
    });
  });
}
