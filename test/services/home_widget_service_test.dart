/// Tests for the home-screen widget service triplet (Phase 7 TASK B).
///
/// Covers:
///   - [SimulationHomeWidgetService] records calls and never touches platform.
///   - [RealHomeWidgetService.publishStatus] writes the correct data keys to
///     the 'home_widget' MethodChannel (faked via
///     [TestDefaultBinaryMessengerBinding]).
///   - Status mapping: idle → 'idle' slug, sessionActive → 'sessionActive',
///     etc.
///   - Elapsed formatting: null → '', 65 s → '01:05', 3600 s → '60:00'.
///   - SessionController publishes homeWidgetServiceProvider on transitions
///     (start → sessionActive, end → idle, distress → sessionActive).
library;

import 'dart:io';

import 'package:flutter/services.dart';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/home_widget_status.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/services/home_widget_service.dart';
import 'package:guardianangela/services/protocols/home_widget_service_protocol.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/session_log_recorder.dart';
import 'package:guardianangela/services/sim/audio_service_sim.dart';
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

// ─── MethodChannel mock ──────────────────────────────────────────────────────

/// Records all calls to the `home_widget` MethodChannel.
///
/// Install via [register] in setUp and remove via [unregister] in tearDown.
/// [lastSavedData] collects key→value pairs from `saveWidgetData` calls.
/// [updateWidgetCalled] is incremented for each `updateWidget` call.
/// [setAppGroupIdCalled] is incremented for each `setAppGroupId` call.
class _HomeWidgetChannelMock {
  final Map<String, Object?> lastSavedData = {};
  int updateWidgetCalled = 0;
  int setAppGroupIdCalled = 0;
  final List<MethodCall> rawCalls = [];

  void register() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('home_widget'), _handle);
  }

  void unregister() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('home_widget'), null);
  }

  Future<dynamic> _handle(MethodCall call) async {
    rawCalls.add(call);
    switch (call.method) {
      case 'saveWidgetData':
        final args = call.arguments as Map;
        final id = args['id'] as String;
        final data = args['data'];
        lastSavedData[id] = data;
        return true;
      case 'updateWidget':
        updateWidgetCalled++;
        return true;
      case 'setAppGroupId':
        setAppGroupIdCalled++;
        return true;
      case 'registerBackgroundCallback':
        return true;
      default:
        return null;
    }
  }
}

// ─── Helper repositories ─────────────────────────────────────────────────────

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository()
    : super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('hw_svc_test_'),
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

// ─── Mode factories ───────────────────────────────────────────────────────────

SessionMode _holdMode(String id) => SessionMode(
  id: id,
  name: 'Hold Test',
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

// ─── Container builder for controller tests ───────────────────────────────────

ProviderContainer _container(
  GuardianAngelaDatabase db,
  HomeWidgetServiceProtocol widgetService,
) {
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
      homeWidgetServiceProvider.overrideWithValue(widgetService),
      // Sim service overrides so startSession doesn't touch real hardware.
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
      messagingServiceProvider.overrideWithValue(SimulationMessagingService()),
      contactServiceProvider.overrideWith(
        (_) async => SimulationContactService(),
      ),
      sessionLogRecorderProvider.overrideWith((ref) async {
        final repo = await ref.watch(sessionLogRepositoryProvider.future);
        return (SessionContext ctx) =>
            SimulationSessionLogRecorder(context: ctx, repo: repo);
      }),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // Required so that TestDefaultBinaryMessengerBinding.instance is accessible
  // in the MethodChannel mock setUp / tearDown.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SimulationHomeWidgetService', () {
    late SimulationHomeWidgetService svc;

    setUp(() => svc = SimulationHomeWidgetService());

    test('publishStatus records the call with correct fields', () async {
      await svc.publishStatus(
        status: HomeWidgetStatus.sessionActive,
        elapsed: const Duration(seconds: 65),
        statusText: 'Session active',
        quickExitLabel: 'Quick Exit',
        fakeCallLabel: 'Fake Call',
      );

      check(svc.calls.length).equals(1);
      check(svc.calls.first['status']).equals(HomeWidgetStatus.sessionActive);
      check(svc.calls.first['elapsed']).equals(const Duration(seconds: 65));
      check(svc.calls.first['statusText']).equals('Session active');
    });

    test('registerCallback sets callbackRegistered = true', () async {
      check(svc.callbackRegistered).isFalse();
      await svc.registerCallback();
      check(svc.callbackRegistered).isTrue();
    });

    test('idle status records null elapsed', () async {
      await svc.publishStatus(
        status: HomeWidgetStatus.idle,
        statusText: 'Idle',
        quickExitLabel: 'Quick Exit',
        fakeCallLabel: 'Fake Call',
      );
      check(svc.calls.first['elapsed']).isNull();
    });
  });

  group('RealHomeWidgetService — MethodChannel integration', () {
    late _HomeWidgetChannelMock mock;

    setUp(() {
      mock = _HomeWidgetChannelMock();
      mock.register();
    });

    tearDown(() => mock.unregister());

    test(
      'publishStatus writes all 5 data keys and calls updateWidget',
      () async {
        // RealHomeWidgetService calls setAppGroupId in the constructor, then
        // publishStatus writes 5 keys and calls updateWidget once.
        final svc = RealHomeWidgetService();
        await svc.publishStatus(
          status: HomeWidgetStatus.sessionActive,
          elapsed: const Duration(seconds: 65),
          statusText: 'Session active',
          quickExitLabel: 'Quick Exit',
          fakeCallLabel: 'Fake Call',
        );

        check(mock.lastSavedData[kWidgetKeyStatus]).equals('sessionActive');
        check(
          mock.lastSavedData[kWidgetKeyStatusText],
        ).equals('Session active');
        check(mock.lastSavedData[kWidgetKeyElapsed]).equals('01:05');
        check(mock.lastSavedData[kWidgetKeyQuickExit]).equals('Quick Exit');
        check(mock.lastSavedData[kWidgetKeyFakeCall]).equals('Fake Call');
        check(mock.updateWidgetCalled).equals(1);
      },
    );

    test('idle status writes empty elapsed string', () async {
      final svc = RealHomeWidgetService();
      await svc.publishStatus(
        status: HomeWidgetStatus.idle,
        statusText: 'Idle',
        quickExitLabel: 'Quick Exit',
        fakeCallLabel: 'Fake Call',
      );
      check(mock.lastSavedData[kWidgetKeyStatus]).equals('idle');
      check(mock.lastSavedData[kWidgetKeyElapsed]).equals('');
    });

    test('simulationActive slug is written correctly', () async {
      final svc = RealHomeWidgetService();
      await svc.publishStatus(
        status: HomeWidgetStatus.simulationActive,
        statusText: 'Simulation active',
        quickExitLabel: 'Quick Exit',
        fakeCallLabel: 'Fake Call',
      );
      check(mock.lastSavedData[kWidgetKeyStatus]).equals('simulationActive');
    });

    test('batteryAlert slug is written correctly', () async {
      final svc = RealHomeWidgetService();
      await svc.publishStatus(
        status: HomeWidgetStatus.batteryAlert,
        statusText: 'Battery alert',
        quickExitLabel: 'Quick Exit',
        fakeCallLabel: 'Fake Call',
      );
      check(mock.lastSavedData[kWidgetKeyStatus]).equals('batteryAlert');
    });

    test('elapsed formatting: 0s → 00:00', () async {
      final svc = RealHomeWidgetService();
      await svc.publishStatus(
        status: HomeWidgetStatus.sessionActive,
        elapsed: Duration.zero,
        statusText: 'Session active',
        quickExitLabel: 'Q',
        fakeCallLabel: 'F',
      );
      check(mock.lastSavedData[kWidgetKeyElapsed]).equals('00:00');
    });

    test('elapsed formatting: 3600s → 60:00', () async {
      final svc = RealHomeWidgetService();
      await svc.publishStatus(
        status: HomeWidgetStatus.sessionActive,
        elapsed: const Duration(seconds: 3600),
        statusText: 'Session active',
        quickExitLabel: 'Q',
        fakeCallLabel: 'F',
      );
      check(mock.lastSavedData[kWidgetKeyElapsed]).equals('60:00');
    });

    test(
      'registerCallback invokes registerBackgroundCallback on channel',
      () async {
        final svc = RealHomeWidgetService();
        await svc.registerCallback();
        check(
          mock.rawCalls.any((c) => c.method == 'registerBackgroundCallback'),
        ).isTrue();
      },
    );
  });

  group('SessionController publishes widget status on transitions', () {
    late GuardianAngelaDatabase db;

    setUp(() {
      db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'startSession publishes sessionActive; endSession publishes idle',
      () async {
        final svc = SimulationHomeWidgetService();
        final container = _container(db, svc);
        await container.read(sessionControllerProvider.future);

        await container
            .read(sessionControllerProvider.notifier)
            .startSession(mode: _holdMode('m1'), simulate: false);
        await Future<void>.delayed(Duration.zero);

        check(
          svc.calls.any((c) => c['status'] == HomeWidgetStatus.sessionActive),
        ).isTrue();

        await container.read(sessionControllerProvider.notifier).endSession();
        await Future<void>.delayed(Duration.zero);

        check(
          svc.calls.any((c) => c['status'] == HomeWidgetStatus.idle),
        ).isTrue();
      },
    );

    test('startSession(simulate: true) publishes simulationActive', () async {
      final svc = SimulationHomeWidgetService();
      final container = _container(db, svc);
      await container.read(sessionControllerProvider.future);

      await container
          .read(sessionControllerProvider.notifier)
          .startSession(mode: _holdMode('m2'), simulate: true);
      await Future<void>.delayed(Duration.zero);

      check(
        svc.calls.any((c) => c['status'] == HomeWidgetStatus.simulationActive),
      ).isTrue();

      await container.read(sessionControllerProvider.notifier).endSession();
    });

    test('notifyBatteryAlert publishes batteryAlert', () async {
      final svc = SimulationHomeWidgetService();
      final container = _container(db, svc);
      await container.read(sessionControllerProvider.future);

      await container
          .read(sessionControllerProvider.notifier)
          .startSession(mode: _holdMode('m3'), simulate: false);
      await Future<void>.delayed(Duration.zero);

      final notifier = container.read(sessionControllerProvider.notifier);
      notifier.notifyBatteryAlert();
      await Future<void>.delayed(Duration.zero);

      check(
        svc.calls.any((c) => c['status'] == HomeWidgetStatus.batteryAlert),
      ).isTrue();

      await notifier.endSession();
    });
  });
}
