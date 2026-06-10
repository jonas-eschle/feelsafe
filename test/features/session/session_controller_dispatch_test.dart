/// Tests verifying that SessionController wires EventStrategy.executeReal
/// correctly on engine events (Phase 7 TASK A).
///
/// Covers:
///   - Real dispatch reaches the audio service when a loudAlarm step starts.
///   - Simulation guard: isSimulation=true skips dispatch (Layer-1 guard).
///   - Error isolation: a throwing strategy surfaces lastError without
///     crashing the session.
///   - disguisedReminder is NOT dispatched on stepStarted (deferred to
///     reminderFired which fires after the wait interval).
///   - #17 fakeCall interaction: the fakeCallShowNonce auto-appear signal, and
///     answerFakeCall / hangUpFakeCall / declineFakeCall wiring to audio + engine.
library;

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart' hide EnginePhase;

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/enums/call_state.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/pause_reason.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/mode_overrides.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/services/protocols/audio_service_protocol.dart';
import 'package:guardianangela/services/protocols/call_state_service_protocol.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';
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

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _FakeAppSettingsRepository extends AppSettingsRepository {
  /// [settings] defaults to `const AppSettings()` (all model defaults).
  _FakeAppSettingsRepository({AppSettings? settings})
    : _settings = settings ?? const AppSettings(),
      super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('dispatch_test_'),
      );

  final AppSettings _settings;

  @override
  Future<AppSettings> load() async => _settings;
}

class _FakeUserProfileRepository extends UserProfileRepository {
  _FakeUserProfileRepository() : super(keyProvider: _k);

  static Future<String> _k() async => '00' * 32;

  @override
  Future<UserProfile> load() async => const UserProfile();
}

/// A recording [AudioServiceProtocol] that tracks calls.
final class _RecordingAudioService implements AudioServiceProtocol {
  final List<Map<String, Object?>> calls = [];

  @override
  Future<void> playAlarm({bool alarmDndOverride = true}) async =>
      calls.add({'method': 'playAlarm'});

  @override
  Future<void> playAlarmWithConfig({
    String soundChoice = 'siren',
    String? customSoundPath,
    double volume = 1.0,
    bool isSimulation = false,
    int rampSeconds = kDefaultAlarmRampSeconds,
    bool alarmDndOverride = true,
  }) async => calls.add({
    'method': 'playAlarmWithConfig',
    'rampSeconds': rampSeconds,
    'alarmDndOverride': alarmDndOverride,
  });

  @override
  Future<void> playRingtone(String? assetPath) async =>
      calls.add({'method': 'playRingtone'});

  @override
  Future<void> playSound(String assetPath) async =>
      calls.add({'method': 'playSound'});

  @override
  Future<void> playVoiceRecording(
    String? filePath, {
    bool useSpeaker = false,
    bool isSimulation = false,
  }) async => calls.add({
    'method': 'playVoiceRecording',
    'filePath': filePath,
    'useSpeaker': useSpeaker,
    'isSimulation': isSimulation,
  });

  @override
  Future<void> stop() async => calls.add({'method': 'stop'});
}

/// A throwing [AudioServiceProtocol] for error-isolation tests.
final class _ThrowingAudioService implements AudioServiceProtocol {
  @override
  Future<void> playAlarm({bool alarmDndOverride = true}) async =>
      throw Exception('audio exploded');

  @override
  Future<void> playAlarmWithConfig({
    String soundChoice = 'siren',
    String? customSoundPath,
    double volume = 1.0,
    bool isSimulation = false,
    int rampSeconds = kDefaultAlarmRampSeconds,
    bool alarmDndOverride = true,
  }) async => throw Exception('audio exploded');

  @override
  Future<void> playRingtone(String? assetPath) async {}

  @override
  Future<void> playSound(String assetPath) async {}

  @override
  Future<void> playVoiceRecording(
    String? filePath, {
    bool useSpeaker = false,
    bool isSimulation = false,
  }) async {}

  @override
  Future<void> stop() async {}
}

/// A recording [NotificationServiceProtocol] used for the disguisedReminder
/// test.
final class _RecordingNotificationService
    implements NotificationServiceProtocol {
  final List<Map<String, Object?>> calls = [];

  @override
  Future<void> showDisguisedReminder({
    required int id,
    required String title,
    required String body,
    bool stealth = false,
  }) async => calls.add({
    'method': 'showDisguisedReminder',
    'id': id,
    'title': title,
    'body': body,
    'stealth': stealth,
  });

  @override
  Future<void> showSmsRetryExhaustedNotification({
    required String contactName,
    required String actionPayload,
  }) async => calls.add({'method': 'showSmsRetryExhaustedNotification'});

  @override
  Future<void> showForegroundServiceNotification({
    required String title,
    required String body,
    bool stealth = false,
    String? fakeName,
  }) async => calls.add({
    'method': 'showForegroundServiceNotification',
    'title': title,
    'body': body,
    'stealth': stealth,
    'fakeName': fakeName,
  });

  @override
  Future<void> showAlarmEscalation({
    required int id,
    required String title,
    required String body,
    String sound = 'critical_alert.wav',
  }) async => calls.add({'method': 'showAlarmEscalation'});

  @override
  Future<void> cancel(int id) async =>
      calls.add({'method': 'cancel', 'id': id});

  @override
  Stream<String> get actionTaps => const Stream.empty();

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> isChannelEnabled(NotificationChannelKey channel) async => true;

  @override
  Future<void> openChannelSettings(NotificationChannelKey channel) async {}
}

// ─── Mode factories ───────────────────────────────────────────────────────────

SessionMode _loudAlarmMode({LoudAlarmConfig? config}) => SessionMode(
  id: 'mode-la',
  name: 'LoudAlarm Test',
  chainSteps: <ChainStep>[
    ChainStep(
      id: 'step-la-0',
      type: ChainStepType.loudAlarm,
      order: 0,
      waitSeconds: 0,
      durationSeconds: 5,
      gracePeriodSeconds: 1,
      retryCount: 0,
      randomize: false,
      config: config,
    ),
  ],
);

/// disguisedReminder mode with [waitSeconds] = 30, so the timer does not
/// elapse during the immediate-check window of the test. The engine emits
/// [ChainEvent.stepStarted] synchronously inside `engine.start()`, but
/// [ChainEvent.reminderFired] only fires after a 30-second real Timer.
/// This separation lets us assert that nothing reached the service immediately
/// after start (i.e. dispatch was NOT on stepStarted).
SessionMode _disguisedReminderMode({DisguisedReminderConfig? config}) =>
    SessionMode(
      id: 'mode-dr',
      name: 'DisguisedReminder Test',
      chainSteps: <ChainStep>[
        ChainStep(
          id: 'step-dr-0',
          type: ChainStepType.disguisedReminder,
          order: 0,
          waitSeconds: 30,
          durationSeconds: 30,
          gracePeriodSeconds: 5,
          retryCount: 0,
          randomize: false,
          config: config,
        ),
      ],
    );

/// A reminder template used as the mode-local pool for the selection tests.
ReminderTemplate _calendarTemplate() => ReminderTemplate(
  id: 'tmpl-calendar',
  name: 'Calendar Event',
  title: 'You have an appointment',
  body: 'Meeting with Alex at 3 PM',
  confirmationType: ConfirmationType.tapButton,
  buttonLabel: 'Acknowledge',
  isCustom: false,
  displayStyle: ReminderDisplayStyle.subtle,
  isGlobal: false,
);

/// disguisedReminder mode with [waitSeconds] = 0 so `reminderFired` is emitted
/// (nearly) immediately after `start()`, and a mode-local template pool so the
/// controller has a known disguise to select. retryCount is high and the
/// duration long enough that the reminder stays on-screen through the test.
SessionMode _reminderFiresImmediatelyMode() => SessionMode(
  id: 'mode-dr0',
  name: 'DisguisedReminder Immediate',
  chainSteps: <ChainStep>[
    ChainStep(
      id: 'step-dr0-0',
      type: ChainStepType.disguisedReminder,
      order: 0,
      waitSeconds: 0,
      durationSeconds: 60,
      gracePeriodSeconds: 5,
      retryCount: 3,
      randomize: false,
      config: const DisguisedReminderConfig(),
    ),
  ],
  overrides: ModeOverrides(
    localTemplates: <ReminderTemplate>[_calendarTemplate()],
  ),
);

/// Single-step fakeCall mode used by the #17 interaction tests.
SessionMode _fakeCallMode() => SessionMode(
  id: 'mode-fc',
  name: 'FakeCall Test',
  chainSteps: <ChainStep>[
    ChainStep(
      id: 'step-fc-0',
      type: ChainStepType.fakeCall,
      order: 0,
      waitSeconds: 0,
      durationSeconds: 30,
      gracePeriodSeconds: 5,
      retryCount: 1,
      randomize: false,
    ),
  ],
);

/// A loudAlarm mode carrying a stealth override (C3 foreground-service wiring
/// tests). [disguise] controls `notificationDisguise`; [fakeName] sets the
/// disguise app name.
SessionMode _stealthMode({bool disguise = true, String fakeName = 'Music'}) =>
    SessionMode(
      id: 'mode-stealth',
      name: 'Stealth Test',
      chainSteps: <ChainStep>[
        ChainStep(
          id: 'step-st-0',
          type: ChainStepType.holdButton,
          order: 0,
          waitSeconds: 0,
          durationSeconds: 30,
          gracePeriodSeconds: 5,
          retryCount: 0,
          randomize: false,
        ),
      ],
      overrides: ModeOverrides(
        stealth: StealthConfig(
          enabled: true,
          fakeName: fakeName,
          notificationDisguise: disguise,
        ),
      ),
    );

// ─── Container builder ────────────────────────────────────────────────────────

ProviderContainer _container(
  GuardianAngelaDatabase db, {
  AudioServiceProtocol? audio,
  NotificationServiceProtocol? notification,
  CallStateServiceProtocol? callState,
  SimulationBackgroundSessionService? background,
  AppSettings? settings,
}) {
  final container = ProviderContainer(
    overrides: [
      appSettingsRepositoryProvider.overrideWithValue(
        _FakeAppSettingsRepository(settings: settings),
      ),
      userProfileRepositoryProvider.overrideWithValue(
        _FakeUserProfileRepository(),
      ),
      databaseProvider.overrideWith((ref) async => db),
      systemUiServiceProvider.overrideWithValue(SimulationSystemUiService()),
      homeWidgetServiceProvider.overrideWithValue(
        SimulationHomeWidgetService(),
      ),
      sessionLogRecorderProvider.overrideWith((ref) async {
        final repo = await ref.watch(sessionLogRepositoryProvider.future);
        return (SessionContext ctx) =>
            SimulationSessionLogRecorder(context: ctx, repo: repo);
      }),
      // Sim service overrides so startSession doesn't touch real hardware.
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
      audioServiceProvider.overrideWithValue(audio ?? SimulationAudioService()),
      notificationServiceProvider.overrideWithValue(
        notification ?? SimulationNotificationService(),
      ),
      callStateServiceProvider.overrideWithValue(
        callState ?? SimulationCallStateService(),
      ),
      backgroundSessionServiceProvider.overrideWithValue(
        background ?? SimulationBackgroundSessionService(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

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

  test(
    'real dispatch reaches audio service: loudAlarm step fires playAlarmWithConfig',
    () async {
      final audio = _RecordingAudioService();
      final container = _container(db, audio: audio);
      await container.read(sessionControllerProvider.future);

      await container
          .read(sessionControllerProvider.notifier)
          .startSession(mode: _loudAlarmMode(), simulate: false);

      // Allow micro-tasks to flush (fire-and-forget via unawaited).
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      check(audio.calls).isNotEmpty();
      check(
        audio.calls.any((c) => c['method'] == 'playAlarmWithConfig'),
      ).isTrue();

      // Cleanup: end session to cancel engine timers.
      await container.read(sessionControllerProvider.notifier).endSession();
    },
  );

  test(
    'simulation guard (isSimulation=true): dispatch is skipped — audio receives no calls',
    () async {
      final audio = _RecordingAudioService();
      final container = _container(db, audio: audio);
      await container.read(sessionControllerProvider.future);

      await container
          .read(sessionControllerProvider.notifier)
          .startSession(mode: _loudAlarmMode(), simulate: true);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Layer-1 sim guard in _dispatchStep returns immediately when
      // isSimulation == true so no strategy runs.
      check(
        audio.calls.where((c) => c['method'] == 'playAlarmWithConfig'),
      ).isEmpty();

      await container.read(sessionControllerProvider.notifier).endSession();
    },
  );

  test(
    'error isolation: throwing audio service surfaces lastError without crashing session',
    () async {
      final audio = _ThrowingAudioService();
      final container = _container(db, audio: audio);
      await container.read(sessionControllerProvider.future);

      await container
          .read(sessionControllerProvider.notifier)
          .startSession(mode: _loudAlarmMode(), simulate: false);

      // Allow enough micro-task rounds for the fire-and-forget to complete and
      // notifyStepExecutionFailed to propagate to the state.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final value = container.read(sessionControllerProvider).value;
      check(value).isNotNull();
      // The session must still be running despite the strategy throw.
      check(
        container.read(sessionControllerProvider.notifier).engine,
      ).isNotNull();
      // The error must be surfaced via lastError (stepExecutionFailed path).
      check(value!.lastError).isNotNull();
      check(value.lastError!).contains('Step execution failed');

      await container.read(sessionControllerProvider.notifier).endSession();
    },
  );

  // ─── AppSettings → EventServices copy-hop (alarm settings arrival) ──────────
  //
  // session_controller.startSession copies alarmDndOverride /
  // alarmGradualVolume / alarmGradualVolumeDurationSeconds from the loaded
  // AppSettings into the per-session EventServices bundle. These tests seed
  // the fake repository with values that ALL differ from the AppSettings
  // defaults (false / false / 5) AND from kDefaultAlarmRampSeconds (5), so a
  // dropped or mis-wired hop cannot pass vacuously.
  group('AppSettings → EventServices alarm-settings arrival', () {
    test('gradual ON: non-default rampSeconds=42 and alarmDndOverride=true '
        'arrive at the audio service', () async {
      final audio = _RecordingAudioService();
      final container = _container(
        db,
        audio: audio,
        settings: const AppSettings(
          alarmDndOverride: true,
          alarmGradualVolume: true,
          alarmGradualVolumeDurationSeconds: 42,
        ),
      );
      await container.read(sessionControllerProvider.future);

      // The ramp fires only when BOTH the global toggle and the per-step
      // LoudAlarmConfig.gradualVolume opt-in are true (spec 02 §loudAlarm).
      await container
          .read(sessionControllerProvider.notifier)
          .startSession(
            mode: _loudAlarmMode(
              config: const LoudAlarmConfig(gradualVolume: true),
            ),
            simulate: false,
          );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final call = audio.calls.firstWhere(
        (c) => c['method'] == 'playAlarmWithConfig',
      );
      check(call['rampSeconds']).equals(42);
      check(call['alarmDndOverride']).equals(true);

      await container.read(sessionControllerProvider.notifier).endSession();
    });

    test('gradual OFF globally: rampSeconds=0 arrives even though the '
        'configured duration is 42 and the step opts in', () async {
      final audio = _RecordingAudioService();
      final container = _container(
        db,
        audio: audio,
        // Master toggle left at its default OFF — the per-step opt-in alone
        // must not ramp, even with a non-default 42 s duration configured.
        settings: const AppSettings(
          alarmDndOverride: true,
          alarmGradualVolumeDurationSeconds: 42,
        ),
      );
      await container.read(sessionControllerProvider.future);

      await container
          .read(sessionControllerProvider.notifier)
          .startSession(
            mode: _loudAlarmMode(
              config: const LoudAlarmConfig(gradualVolume: true),
            ),
            simulate: false,
          );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final call = audio.calls.firstWhere(
        (c) => c['method'] == 'playAlarmWithConfig',
      );
      // LoudAlarmStrategy passes 0 (not the 42 duration, not the protocol
      // default 5) when the global gradual-volume toggle is off.
      check(call['rampSeconds']).equals(0);
      check(call['alarmDndOverride']).equals(true);

      await container.read(sessionControllerProvider.notifier).endSession();
    });
  });

  test(
    'disguisedReminder NOT dispatched on stepStarted: notification receives no calls immediately',
    () async {
      final notification = _RecordingNotificationService();
      final container = _container(db, notification: notification);
      await container.read(sessionControllerProvider.future);

      await container
          .read(sessionControllerProvider.notifier)
          .startSession(mode: _disguisedReminderMode(), simulate: false);

      // Immediately after start (no time advance): the engine emits stepStarted
      // for the disguisedReminder step. The controller must NOT call
      // executeReal here — that fires only on reminderFired (after the
      // wait interval elapses).
      await Future<void>.delayed(Duration.zero);

      final reminderCalls = notification.calls.where(
        (c) => c['method'] == 'showDisguisedReminder',
      );
      check(reminderCalls).isEmpty();

      // Note: with real timers we cannot advance the waitSeconds easily here.
      // The negative assertion proves the stepStarted guard is in place.
      // When reminderFired fires (after wait + duration), showDisguisedReminder
      // WOULD appear — but we rely on the unit-level strategy tests for that.
      await container.read(sessionControllerProvider.notifier).endSession();
    },
  );

  // ─── #18 disguisedReminder selection + earlyCheckIn ─────────────────────────
  group('disguisedReminder selection (#18)', () {
    test('reminderFired selects a template, sets state + bumps the nonce '
        'and the notification uses the disguise', () async {
      final notification = _RecordingNotificationService();
      final container = _container(db, notification: notification);
      await container.read(sessionControllerProvider.future);

      // waitSeconds=0 → reminderFired is emitted right after start().
      await container
          .read(sessionControllerProvider.notifier)
          .startSession(mode: _reminderFiresImmediatelyMode(), simulate: false);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(sessionControllerProvider).value;
      check(state!.activeReminderTemplate).isNotNull();
      check(state.activeReminderTemplate!.id).equals('tmpl-calendar');
      check(state.reminderShowNonce).isGreaterThan(0);

      final reminderCall = notification.calls.firstWhere(
        (c) => c['method'] == 'showDisguisedReminder',
      );
      check(reminderCall['title']).equals('You have an appointment');
      check(reminderCall['body']).equals('Meeting with Alex at 3 PM');

      await container.read(sessionControllerProvider.notifier).endSession();
    });

    test('earlyCheckIn during the wait phase (resetOnEarlyCheckIn=true) '
        'disarms and re-arms at step 0', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);

      // waitSeconds=30 → the step sits in the wait phase after start.
      await notifier.startSession(
        mode: _disguisedReminderMode(),
        simulate: false,
      );
      await Future<void>.delayed(Duration.zero);

      final events = <ChainEvent>[];
      final sub = notifier.engine!.events.listen((e) => events.add(e.event));

      notifier.earlyCheckIn();
      await Future<void>.delayed(Duration.zero);

      // Default resetOnEarlyCheckIn=true → the engine disarms (userDisarmed)
      // and re-arms at step 0; the session stays alive.
      check(events).contains(ChainEvent.userDisarmed);
      final state = container.read(sessionControllerProvider).value;
      check(state!.currentStepIndex).equals(0);

      await sub.cancel();
      await notifier.endSession();
    });

    test('earlyCheckIn with resetOnEarlyCheckIn=false is a deliberate no-op '
        '(strict verification — reminder still fires on schedule)', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);

      await notifier.startSession(
        mode: _disguisedReminderMode(
          config: const DisguisedReminderConfig(resetOnEarlyCheckIn: false),
        ),
        simulate: false,
      );
      await Future<void>.delayed(Duration.zero);

      final events = <ChainEvent>[];
      final sub = notifier.engine!.events.listen((e) => events.add(e.event));

      notifier.earlyCheckIn();
      await Future<void>.delayed(Duration.zero);

      // Strict mode (spec 02 §Early Check-in D4): the early tap is ignored —
      // no disarm, and the reminder stays pending in the wait phase.
      check(events.where((e) => e == ChainEvent.userDisarmed)).isEmpty();
      final snapshot = notifier.engine!.snapshot;
      check(snapshot).isA<EngineRunning>();
      check((snapshot as EngineRunning).phase).equals(EnginePhase.wait);

      await sub.cancel();
      await notifier.endSession();
    });
  });

  // ─── #17 fakeCall interaction (auto-appear + answer/hang-up/decline) ────────
  group('fakeCall interaction (#17)', () {
    test('fakeCallShowNonce bumps when a fakeCall step starts', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _fakeCallMode(), simulate: false);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(sessionControllerProvider).value;
      // Signal that drives the session screen's auto-push of FakeCallScreen.
      check(state!.fakeCallShowNonce).isGreaterThan(0);

      await notifier.endSession();
    });

    test('answerFakeCall stops the ring and plays the voice clip routed to '
        'the requested output', () async {
      final audio = _RecordingAudioService();
      final container = _container(db, audio: audio);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _fakeCallMode(), simulate: false);
      await Future<void>.delayed(Duration.zero);
      audio.calls.clear(); // drop the ring/escalation from the step firing

      await notifier.answerFakeCall(
        voiceRecordingPath: '/voice/a.aac',
        useSpeaker: true,
      );

      check(audio.calls.any((c) => c['method'] == 'stop')).isTrue();
      final voice = audio.calls.firstWhere(
        (c) => c['method'] == 'playVoiceRecording',
      );
      check(voice['filePath']).equals('/voice/a.aac');
      check(voice['useSpeaker']).equals(true);
      check(voice['isSimulation']).equals(false);

      await notifier.endSession();
    });

    test('answerFakeCall routes the voice clip to the earpiece by default '
        '(useSpeaker: false — spec 02 §fakeCall Voice Recording)', () async {
      final audio = _RecordingAudioService();
      final container = _container(db, audio: audio);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _fakeCallMode(), simulate: false);
      await Future<void>.delayed(Duration.zero);
      audio.calls.clear();

      // No useSpeaker argument → controller default (earpiece) must win.
      await notifier.answerFakeCall(voiceRecordingPath: '/voice/a.aac');

      final voice = audio.calls.firstWhere(
        (c) => c['method'] == 'playVoiceRecording',
      );
      check(voice['useSpeaker']).equals(false);

      await notifier.endSession();
    });

    test('hangUpFakeCall stops audio and disarms (userDisarmed fires; '
        'chain resets to step 0)', () async {
      final audio = _RecordingAudioService();
      final container = _container(db, audio: audio);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _fakeCallMode(), simulate: false);
      await Future<void>.delayed(Duration.zero);
      audio.calls.clear();

      // _fakeCallMode is single-step, so currentStepIndex is 0 regardless;
      // assert the disarm *event* fired to prove hang-up actually disarmed.
      final events = <ChainEvent>[];
      final sub = notifier.engine!.events.listen((e) => events.add(e.event));

      notifier.hangUpFakeCall();
      await Future<void>.delayed(Duration.zero);

      check(audio.calls.any((c) => c['method'] == 'stop')).isTrue();
      check(events).contains(ChainEvent.userDisarmed);
      final state = container.read(sessionControllerProvider).value;
      check(state!.currentStepIndex).equals(0);

      await sub.cancel();
      await notifier.endSession();
    });

    test('declineFakeCall(declineIsSafe: true) stops audio and disarms '
        '(userDisarmed fires)', () async {
      final audio = _RecordingAudioService();
      final container = _container(db, audio: audio);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _fakeCallMode(), simulate: false);
      await Future<void>.delayed(Duration.zero);
      audio.calls.clear();

      final events = <ChainEvent>[];
      final sub = notifier.engine!.events.listen((e) => events.add(e.event));

      notifier.declineFakeCall(declineIsSafe: true);
      await Future<void>.delayed(Duration.zero);

      check(audio.calls.any((c) => c['method'] == 'stop')).isTrue();
      check(events).contains(ChainEvent.userDisarmed);
      final state = container.read(sessionControllerProvider).value;
      check(state!.currentStepIndex).equals(0);

      await sub.cancel();
      await notifier.endSession();
    });

    test('declineFakeCall(declineIsSafe: false) stops audio and re-rings via '
        'the grace phase (counts as a miss — does NOT disarm)', () async {
      final audio = _RecordingAudioService();
      final container = _container(db, audio: audio);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _fakeCallMode(), simulate: false);
      await Future<void>.delayed(Duration.zero);
      audio.calls.clear();

      final events = <ChainEvent>[];
      final sub = notifier.engine!.events.listen((e) => events.add(e.event));

      notifier.declineFakeCall(declineIsSafe: false);
      await Future<void>.delayed(Duration.zero);

      check(audio.calls.any((c) => c['method'] == 'stop')).isTrue();
      // Miss, not disarm: no userDisarmed, and the engine sits in the grace
      // phase before re-ringing (spec 02 §fakeCall Decline, declineIsSafe=false).
      check(events.where((e) => e == ChainEvent.userDisarmed)).isEmpty();
      final snapshot = notifier.engine!.snapshot;
      check(snapshot).isA<EngineRunning>();
      check((snapshot as EngineRunning).phase).equals(EnginePhase.grace);

      await sub.cancel();
      await notifier.endSession();
    });
  });

  // ─── #11 real incoming-call detection (pause/resume + fakeCall cancel) ───────
  group('real incoming-call detection (#11)', () {
    test('startSession starts call detection; endSession stops it', () async {
      final calls = SimulationCallStateService();
      final container = _container(db, callState: calls);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);

      await notifier.startSession(
        mode: _disguisedReminderMode(),
        simulate: false,
      );
      await Future<void>.delayed(Duration.zero);
      check(calls.isStarted).isTrue();

      await notifier.endSession();
      check(calls.isStarted).isFalse();
    });

    test('a simulation session does NOT start real call detection', () async {
      final calls = SimulationCallStateService();
      final container = _container(db, callState: calls);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);

      await notifier.startSession(
        mode: _disguisedReminderMode(),
        simulate: true,
      );
      await Future<void>.delayed(Duration.zero);
      check(calls.isStarted).isFalse();

      await notifier.endSession();
    });

    test('real call on a non-fakeCall step pauses with incomingCall, then '
        'resumes on idle (A2 / Extra-30/31)', () async {
      final calls = SimulationCallStateService();
      final container = _container(db, callState: calls);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(
        mode: _disguisedReminderMode(),
        simulate: false,
      );
      await Future<void>.delayed(Duration.zero);

      calls.setState(CallState.ringing);
      await Future<void>.delayed(Duration.zero);

      check(notifier.engine!.snapshot).isA<EnginePaused>();
      var s = container.read(sessionControllerProvider).value;
      check(s!.isPaused).isTrue();
      check(s.pauseReason).equals(PauseReason.incomingCall);

      calls.setState(CallState.idle);
      await Future<void>.delayed(Duration.zero);

      check(notifier.engine!.snapshot).isA<EngineRunning>();
      s = container.read(sessionControllerProvider).value;
      check(s!.isPaused).isFalse();

      await notifier.endSession();
    });

    test('ringing→offhook (answering the real call) does not double-fire the '
        'pause; one idle resumes', () async {
      final calls = SimulationCallStateService();
      final container = _container(db, callState: calls);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(
        mode: _disguisedReminderMode(),
        simulate: false,
      );
      await Future<void>.delayed(Duration.zero);

      calls.setState(CallState.ringing);
      await Future<void>.delayed(Duration.zero);
      calls.setState(CallState.offhook); // same call answered — still active
      await Future<void>.delayed(Duration.zero);
      check(notifier.engine!.snapshot).isA<EnginePaused>();

      calls.setState(CallState.idle);
      await Future<void>.delayed(Duration.zero);
      check(notifier.engine!.snapshot).isA<EngineRunning>();

      await notifier.endSession();
    });

    test('real call during a fakeCall step cancels it (stop audio + cancel '
        'nonce + pause), then auto-disarms on idle (Extra-24/25)', () async {
      final audio = _RecordingAudioService();
      final calls = SimulationCallStateService();
      final container = _container(db, audio: audio, callState: calls);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _fakeCallMode(), simulate: false);
      await Future<void>.delayed(Duration.zero);
      audio.calls.clear();
      final nonce0 = container
          .read(sessionControllerProvider)
          .value!
          .fakeCallCancelNonce;

      final events = <ChainEvent>[];
      final sub = notifier.engine!.events.listen((e) => events.add(e.event));

      calls.setState(CallState.ringing);
      await Future<void>.delayed(Duration.zero);

      // Cancelled now: ring stopped + screen dismissed via the nonce; the
      // session is paused but not yet disarmed.
      check(audio.calls.any((c) => c['method'] == 'stop')).isTrue();
      check(
        container.read(sessionControllerProvider).value!.fakeCallCancelNonce,
      ).isGreaterThan(nonce0);
      check(events.where((e) => e == ChainEvent.userDisarmed)).isEmpty();
      check(notifier.engine!.snapshot).isA<EnginePaused>();

      calls.setState(CallState.idle);
      await Future<void>.delayed(Duration.zero);

      // Real call ended → auto-disarm (resume then reset to step 0).
      check(events).contains(ChainEvent.userDisarmed);
      check(notifier.engine!.snapshot).isA<EngineRunning>();

      await sub.cancel();
      await notifier.endSession();
    });

    test('a real call does not clobber a user-requested pause', () async {
      final calls = SimulationCallStateService();
      final container = _container(db, callState: calls);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(
        mode: _disguisedReminderMode(),
        simulate: false,
      );
      await Future<void>.delayed(Duration.zero);

      notifier.pause(); // user pause (reason: userRequested)
      await Future<void>.delayed(Duration.zero);
      var s = container.read(sessionControllerProvider).value;
      check(s!.isPaused).isTrue();
      check(s.pauseReason).equals(PauseReason.userRequested);

      calls.setState(CallState.ringing);
      await Future<void>.delayed(Duration.zero);
      // Already paused — the call neither re-pauses nor changes the reason.
      s = container.read(sessionControllerProvider).value;
      check(s!.pauseReason).equals(PauseReason.userRequested);

      calls.setState(CallState.idle);
      await Future<void>.delayed(Duration.zero);
      // The call ending must NOT resume the user's deliberate pause.
      check(notifier.engine!.snapshot).isA<EnginePaused>();
      s = container.read(sessionControllerProvider).value;
      check(s!.isPaused).isTrue();

      await notifier.endSession();
    });
  });

  // ─── C3: foreground-service start/stop wiring (#15) ──────────────────────────
  group('foreground service lifecycle (#15 C3)', () {
    test('startSession configures + starts the foreground service', () async {
      final bg = SimulationBackgroundSessionService();
      final container = _container(db, background: bg);
      await container.read(sessionControllerProvider.future);

      await container
          .read(sessionControllerProvider.notifier)
          .startSession(mode: _loudAlarmMode(), simulate: false);
      await Future<void>.delayed(Duration.zero);

      // configure() runs once and a startService posts the persistent
      // notification (this is the wire that keeps a backgrounded session alive).
      check(bg.calls.map((c) => c.method)).contains('configure');
      final starts = bg.calls.where((c) => c.method == 'startService');
      check(starts).isNotEmpty();
      // Non-stealth mode → not disguised.
      check(starts.first.stealth).equals(false);

      await container.read(sessionControllerProvider.notifier).endSession();
    });

    test('endSession stops the foreground service', () async {
      final bg = SimulationBackgroundSessionService();
      final container = _container(db, background: bg);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);

      await notifier.startSession(mode: _loudAlarmMode(), simulate: false);
      await Future<void>.delayed(Duration.zero);
      bg.reset();

      await notifier.endSession();

      check(bg.calls.map((c) => c.method)).contains('stopService');
    });

    test(
      'stealth+disguise session starts a disguised service with fakeName',
      () async {
        final bg = SimulationBackgroundSessionService();
        final container = _container(db, background: bg);
        await container.read(sessionControllerProvider.future);
        final notifier = container.read(sessionControllerProvider.notifier);

        await notifier.startSession(
          mode: _stealthMode(fakeName: 'Spotify'),
          simulate: false,
        );
        await Future<void>.delayed(Duration.zero);

        final start = bg.calls.firstWhere((c) => c.method == 'startService');
        // Disguised: stealth flag set, title is the fakeName, fakeName threaded.
        check(start.stealth).equals(true);
        check(start.title).equals('Spotify');
        check(start.fakeName).equals('Spotify');

        await notifier.endSession();
      },
    );

    test(
      'stealth WITHOUT notificationDisguise starts a normal service',
      () async {
        final bg = SimulationBackgroundSessionService();
        final container = _container(db, background: bg);
        await container.read(sessionControllerProvider.future);
        final notifier = container.read(sessionControllerProvider.notifier);

        await notifier.startSession(
          mode: _stealthMode(disguise: false, fakeName: 'Spotify'),
          simulate: false,
        );
        await Future<void>.delayed(Duration.zero);

        final start = bg.calls.firstWhere((c) => c.method == 'startService');
        // notificationDisguise=false → the persistent notification is NOT
        // disguised even though the on-screen session is stealthed.
        check(start.stealth).equals(false);
        check(start.title).equals('Guardian Angela is active');

        await notifier.endSession();
      },
    );

    test('configure runs only once across two sessions', () async {
      final bg = SimulationBackgroundSessionService();
      final container = _container(db, background: bg);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);

      await notifier.startSession(mode: _loudAlarmMode(), simulate: false);
      await Future<void>.delayed(Duration.zero);
      await notifier.endSession();
      await notifier.startSession(mode: _loudAlarmMode(), simulate: false);
      await Future<void>.delayed(Duration.zero);

      check(bg.calls.where((c) => c.method == 'configure')).length.equals(1);

      await notifier.endSession();
    });

    test(
      'simulation session also starts the foreground service (process kept alive)',
      () async {
        final bg = SimulationBackgroundSessionService();
        final container = _container(db, background: bg);
        await container.read(sessionControllerProvider.future);
        final notifier = container.read(sessionControllerProvider.notifier);

        await notifier.startSession(mode: _loudAlarmMode(), simulate: true);
        await Future<void>.delayed(Duration.zero);

        // A simulation still wants the persistent notification + keep-alive so
        // the practice run survives backgrounding like a real one.
        check(bg.calls.where((c) => c.method == 'startService')).isNotEmpty();

        await notifier.endSession();
      },
    );
  });
}
