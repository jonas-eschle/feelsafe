/// Tests for [SessionController.startDistressSession] — the cold-start distress
/// entry used by the App-lock launch gate (spec 06 §App PIN / §Duress PIN).
///
/// Covers the new resolution + fail-loud logic (no default distress mode / a
/// missing mode must surface an error, never silently do nothing — global
/// "fail loud" policy) AND the happy path end-to-end against a real in-memory
/// database: the distress chain fires, and — crucially — NO interrupt marker
/// is written, so a force-stopped cold-start distress cannot leak
/// "Mode: Default Distress" on the next launch (the Duress-PIN stealth
/// contract).
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
import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/session_log_recorder.dart';
import 'package:guardianangela/services/sim/audio_service_sim.dart';
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

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository(this._current)
    : super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('session_ctl_test_'),
      );

  final AppSettings _current;

  @override
  Future<AppSettings> load() async => _current;
}

class _FakeUserProfileRepository extends UserProfileRepository {
  _FakeUserProfileRepository() : super(keyProvider: _dummyKey);

  static Future<String> _dummyKey() async => '00' * 32;

  @override
  Future<UserProfile> load() async => const UserProfile();
}

SessionMode _distressMode(String id) => SessionMode(
  id: id,
  name: 'Default Distress',
  isDistressMode: true,
  chainSteps: <ChainStep>[
    ChainStep(
      id: '$id-step-0',
      type: ChainStepType.holdButton,
      order: 0,
      waitSeconds: 0,
      durationSeconds: 10,
      gracePeriodSeconds: 1,
      retryCount: 0,
      randomize: false,
    ),
  ],
);

ProviderContainer _container(AppSettings settings, GuardianAngelaDatabase db) {
  final container = ProviderContainer(
    overrides: [
      appSettingsRepositoryProvider.overrideWithValue(
        _FakeAppSettingsRepository(settings),
      ),
      databaseProvider.overrideWith((ref) async => db),
      // Sim service overrides so startSession doesn't touch real hardware
      // or platform channels (required since Phase 7 wired EventServices).
      systemUiServiceProvider.overrideWithValue(SimulationSystemUiService()),
      homeWidgetServiceProvider.overrideWithValue(
        SimulationHomeWidgetService(),
      ),
      audioServiceProvider.overrideWithValue(SimulationAudioService()),
      vibrationServiceProvider.overrideWithValue(SimulationVibrationService()),
      flashServiceProvider.overrideWithValue(SimulationFlashService()),
      screenFlashServiceProvider.overrideWithValue(
        SimulationScreenFlashService(),
      ),
      recordingServiceProvider.overrideWithValue(SimulationRecordingService()),
      locationServiceProvider.overrideWithValue(SimulationLocationService()),
      notificationServiceProvider.overrideWithValue(
        SimulationNotificationService(),
      ),
      phoneServiceProvider.overrideWithValue(SimulationPhoneService()),
      callStateServiceProvider.overrideWithValue(SimulationCallStateService()),
      messagingServiceProvider.overrideWithValue(SimulationMessagingService()),
      contactServiceProvider.overrideWith(
        (_) async => SimulationContactService(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  // startDistressSession → startSession registers a WidgetsBindingObserver
  // (G-013 background clamp), which needs an initialised binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  late GuardianAngelaDatabase db;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
  });

  tearDown(() async {
    await db.close();
  });

  test('fails loud when no default distress mode is configured', () async {
    final container = _container(const AppSettings(), db);
    await container.read(sessionControllerProvider.future);
    await container
        .read(sessionControllerProvider.notifier)
        .startDistressSession(reason: EndReason.duressPin);
    final state = container.read(sessionControllerProvider).value;
    check(state?.lastError).isNotNull();
  });

  test('fails loud when the default distress mode id is missing', () async {
    final settings = const AppSettings().copyWith(
      defaults: const AppDefaults(defaultDistressModeId: 'does-not-exist'),
    );
    final container = _container(settings, db);
    await container.read(sessionControllerProvider.future);
    await container
        .read(sessionControllerProvider.notifier)
        .startDistressSession(reason: EndReason.duressPin);
    final state = container.read(sessionControllerProvider).value;
    check(state?.lastError).isNotNull();
    check(state!.lastError!).contains('does-not-exist');
  });

  test('does not start an engine on the fail-loud path', () async {
    final container = _container(const AppSettings(), db);
    await container.read(sessionControllerProvider.future);
    final notifier = container.read(sessionControllerProvider.notifier);
    await notifier.startDistressSession(reason: EndReason.duressPin);
    // No engine spun up — the run never reached startSession.
    check(notifier.engine).isNull();
  });

  test(
    'happy path: fires the distress chain AND writes no interrupt marker '
    '(stealth — a killed cold-start distress must not leak on next launch)',
    () async {
      await db.sessionModesDao.upsert(_distressMode('dm-1'));
      final repo = SessionLogRepository(db.sessionLogsDao);
      final settings = const AppSettings().copyWith(
        defaults: const AppDefaults(defaultDistressModeId: 'dm-1'),
      );
      final container = ProviderContainer(
        overrides: [
          appSettingsRepositoryProvider.overrideWithValue(
            _FakeAppSettingsRepository(settings),
          ),
          databaseProvider.overrideWith((ref) async => db),
          userProfileRepositoryProvider.overrideWithValue(
            _FakeUserProfileRepository(),
          ),
          systemUiServiceProvider.overrideWithValue(
            SimulationSystemUiService(),
          ),
          homeWidgetServiceProvider.overrideWithValue(
            SimulationHomeWidgetService(),
          ),
          audioServiceProvider.overrideWithValue(SimulationAudioService()),
          vibrationServiceProvider.overrideWithValue(
            SimulationVibrationService(),
          ),
          flashServiceProvider.overrideWithValue(SimulationFlashService()),
          screenFlashServiceProvider.overrideWithValue(
            SimulationScreenFlashService(),
          ),
          recordingServiceProvider.overrideWithValue(
            SimulationRecordingService(),
          ),
          locationServiceProvider.overrideWithValue(
            SimulationLocationService(),
          ),
          notificationServiceProvider.overrideWithValue(
            SimulationNotificationService(),
          ),
          phoneServiceProvider.overrideWithValue(SimulationPhoneService()),
          callStateServiceProvider.overrideWithValue(
            SimulationCallStateService(),
          ),
          messagingServiceProvider.overrideWithValue(
            SimulationMessagingService(),
          ),
          contactServiceProvider.overrideWith(
            (_) async => SimulationContactService(),
          ),
          sessionLogRecorderProvider.overrideWith(
            (ref) async =>
                (SessionContext context) =>
                    SimulationSessionLogRecorder(context: context, repo: repo),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);

      await notifier.startDistressSession(reason: EndReason.duressPin);
      // Let the distressTriggered engine event propagate to the state.
      await Future<void>.delayed(Duration.zero);

      // The distress chain is running...
      check(notifier.engine).isNotNull();
      check(
        container.read(sessionControllerProvider).value!.isDistressChain,
      ).isTrue();
      // ...but NO in-progress marker was written, so a force-stop before the
      // chain finishes cannot surface "Mode: Default Distress" on next launch.
      final orphans = (await repo.getAll())
          .where((l) => l.endedAt == null)
          .toList();
      check(orphans).isEmpty();

      // Tear down the engine's timers before the test ends.
      await notifier.endSession();
    },
  );
}
