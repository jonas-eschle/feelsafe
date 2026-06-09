/// Real-controller tests for the Session-Interrupted Prompt (spec 04 Extra 13).
///
/// Drives the REAL [SessionController] against an in-memory database to prove
/// the cold-launch detection path and the two dismiss actions:
///   - An orphan SessionLog marker (a `startedAt` row with no `endedAt`)
///     detected at `build()` seeds the prompt with the mode id/name + start.
///   - A cleanly-ended session (its marker finalised with an `endedAt`) is
///     NOT detected — no prompt.
///   - No logs at all → no prompt.
///   - [SessionController.startInterruptedModeAgain] starts a BRAND-NEW session
///     for the interrupted mode (not a resume) and clears the prompt; a deleted
///     mode returns false and starts nothing; the orphan marker is removed so
///     the prompt never re-fires.
///   - [SessionController.acknowledgeInterruptedPrompt] clears the prompt; the
///     orphan was already deleted at detection so it never re-fires.
library;

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/features/session/session_controller.dart';
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

// ─── Fakes ──────────────────────────────────────────────────────────────────

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository()
    : super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('interrupted_test_'),
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

// ─── Fixtures ─────────────────────────────────────────────────────────────────

SessionMode _holdMode({String id = 'mode-hold', String name = 'Walk Mode'}) =>
    SessionMode(
      id: id,
      name: name,
      chainSteps: <ChainStep>[
        ChainStep(
          id: 'step-$id-0',
          type: ChainStepType.holdButton,
          order: 0,
          waitSeconds: 0,
          durationSeconds: 60,
          gracePeriodSeconds: 5,
          retryCount: 0,
          randomize: false,
        ),
      ],
    );

/// An in-progress marker: a started row with no `endedAt`.
SessionLog _orphan({
  required String id,
  required String modeId,
  required String modeName,
  required DateTime startedAt,
}) => SessionLog(
  id: id,
  modeId: modeId,
  modeName: modeName,
  startedAt: startedAt,
  isSimulation: false,
  events: const [],
);

// ─── Container ────────────────────────────────────────────────────────────────

ProviderContainer _container(GuardianAngelaDatabase db) {
  final container = ProviderContainer(
    overrides: [
      appSettingsRepositoryProvider.overrideWithValue(
        _FakeAppSettingsRepository(),
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
        SimulationBackgroundSessionService(),
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
  late SessionLogRepository logRepo;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
    logRepo = SessionLogRepository(db.sessionLogsDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('detection', () {
    test('orphan marker → priorInterrupted with mode + start time', () async {
      final started = DateTime.utc(2026, 5, 1, 10);
      await logRepo.upsert(
        _orphan(
          id: 'orphan-1',
          modeId: 'mode-hold',
          modeName: 'Walk Mode',
          startedAt: started,
        ),
      );
      final container = _container(db);

      final state = await container.read(sessionControllerProvider.future);

      check(state.priorInterrupted).isTrue();
      check(state.priorModeId).equals('mode-hold');
      check(state.priorModeName).equals('Walk Mode');
      check(state.priorStartedAt).equals(started);
    });

    test('detection deletes the orphan so it never re-fires', () async {
      await logRepo.upsert(
        _orphan(
          id: 'orphan-1',
          modeId: 'mode-hold',
          modeName: 'Walk Mode',
          startedAt: DateTime.utc(2026, 5, 1, 10),
        ),
      );
      final container = _container(db);
      await container.read(sessionControllerProvider.future);

      // The marker row is gone after detection.
      check(await logRepo.getAll()).isEmpty();
    });

    test('newest orphan wins when several are present', () async {
      await logRepo.upsert(
        _orphan(
          id: 'old',
          modeId: 'mode-a',
          modeName: 'Old Mode',
          startedAt: DateTime.utc(2026, 5, 1, 10),
        ),
      );
      await logRepo.upsert(
        _orphan(
          id: 'new',
          modeId: 'mode-b',
          modeName: 'New Mode',
          startedAt: DateTime.utc(2026, 5, 2, 10),
        ),
      );
      final container = _container(db);

      final state = await container.read(sessionControllerProvider.future);

      check(state.priorModeName).equals('New Mode');
      check(state.priorModeId).equals('mode-b');
    });

    test('cleanly-ended session (marker finalised) → no prompt', () async {
      // A finalised log carries an endedAt; it is not an orphan marker.
      await logRepo.upsert(
        SessionLog(
          id: 'finalised',
          modeId: 'mode-hold',
          modeName: 'Walk Mode',
          startedAt: DateTime.utc(2026, 5, 1, 10),
          endedAt: DateTime.utc(2026, 5, 1, 11),
          endReason: EndReason.userQuit,
          isSimulation: false,
          events: const [],
        ),
      );
      final container = _container(db);

      final state = await container.read(sessionControllerProvider.future);

      check(state.priorInterrupted).isFalse();
      check(state.priorModeId).isNull();
    });

    test('no logs at all → no prompt', () async {
      final container = _container(db);

      final state = await container.read(sessionControllerProvider.future);

      check(state.priorInterrupted).isFalse();
    });
  });

  group('acknowledge', () {
    test('clears the prompt flags', () async {
      await logRepo.upsert(
        _orphan(
          id: 'orphan-1',
          modeId: 'mode-hold',
          modeName: 'Walk Mode',
          startedAt: DateTime.utc(2026, 5, 1, 10),
        ),
      );
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);

      notifier.acknowledgeInterruptedPrompt();

      final state = container.read(sessionControllerProvider).value!;
      check(state.priorInterrupted).isFalse();
      check(state.priorModeId).isNull();
      check(state.priorModeName).isNull();
      check(state.priorStartedAt).isNull();
    });
  });

  group('start same mode', () {
    test('existing mode → fresh session started + prompt cleared', () async {
      await db.sessionModesDao.upsert(_holdMode());
      await logRepo.upsert(
        _orphan(
          id: 'orphan-1',
          modeId: 'mode-hold',
          modeName: 'Walk Mode',
          startedAt: DateTime.utc(2026, 5, 1, 10),
        ),
      );
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);

      final started = await notifier.startInterruptedModeAgain();

      check(started).isTrue();
      // A brand-new engine is running, and the prompt is cleared.
      check(notifier.isSessionActive).isTrue();
      final state = container.read(sessionControllerProvider).value!;
      check(state.priorInterrupted).isFalse();
      check(state.phase).not((p) => p.equals(SessionPhase.idle));

      await notifier.endSession();
    });

    test('deleted mode → returns false, no session, prompt cleared', () async {
      // Orphan references a mode that is NOT in the modes table.
      await logRepo.upsert(
        _orphan(
          id: 'orphan-1',
          modeId: 'mode-deleted',
          modeName: 'Ghost Mode',
          startedAt: DateTime.utc(2026, 5, 1, 10),
        ),
      );
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);

      final started = await notifier.startInterruptedModeAgain();

      check(started).isFalse();
      check(notifier.isSessionActive).isFalse();
      final state = container.read(sessionControllerProvider).value!;
      check(state.priorInterrupted).isFalse();
    });

    test('mode with a distressModeId → restart resolves and wires the distress '
        'mode (confirmDistress fires the distress chain)', () async {
      final distress = _holdMode(id: 'mode-dist', name: 'Distress');
      await db.sessionModesDao.upsert(distress);
      await db.sessionModesDao.upsert(
        _holdMode().copyWith(distressModeId: 'mode-dist'),
      );
      await logRepo.upsert(
        _orphan(
          id: 'orphan-1',
          modeId: 'mode-hold',
          modeName: 'Walk Mode',
          startedAt: DateTime.utc(2026, 5, 1, 10),
        ),
      );
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);

      final started = await notifier.startInterruptedModeAgain();
      check(started).isTrue();

      // The restarted session resolved mode.distressModeId — so a distress
      // trigger now swaps in the distress chain instead of failing loud.
      notifier.confirmDistress();
      await Future<void>.delayed(Duration.zero);
      final state = container.read(sessionControllerProvider).value!;
      check(state.lastError).isNull();
      check(state.isDistressChain).isTrue();

      await notifier.endSession();
    });

    test(
      'start same mode writes a NEW marker (not a resume of the old)',
      () async {
        await db.sessionModesDao.upsert(_holdMode());
        await logRepo.upsert(
          _orphan(
            id: 'orphan-old',
            modeId: 'mode-hold',
            modeName: 'Walk Mode',
            startedAt: DateTime.utc(2026, 5, 1, 10),
          ),
        );
        final container = _container(db);
        await container.read(sessionControllerProvider.future);
        final notifier = container.read(sessionControllerProvider.notifier);

        await notifier.startInterruptedModeAgain();

        // Exactly one marker exists — the fresh session's — and it is a
        // different row than the deleted orphan.
        final logs = await logRepo.getAll();
        check(logs.length).equals(1);
        check(logs.single.id).not((s) => s.equals('orphan-old'));
        check(logs.single.endedAt).isNull();

        await notifier.endSession();
      },
    );
  });
}
