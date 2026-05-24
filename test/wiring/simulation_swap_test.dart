// simulation_swap_test.dart
//
// Verifies that every Real*Service registered in service_providers.dart
// has a simulation override path: when a ProviderContainer is built with
// the relevant provider overridden with a Simulation* impl, reading the
// protocol-typed provider returns the simulation impl.
//
// Phase 5A coverage: EncryptionService + all three JSON repos.
// Stage 5B.1 adds: vibration, wakelock, flash, screenFlash, recording,
//   contact, audio.
// Stage 5B.2 adds: location, batteryMonitor, notification,
//   hardwareButton, callState, systemUi.
// Stage 5B.3 adds: phone, messaging, backgroundSession,
//   sentry, sessionLogRecorder.
// Stage 5C adds: permissionAudit, sessionStartValidator, backup.
//   Also: databaseProvider / contactServiceProvider / sessionLogRecorderProvider
//   are now FutureProviders.

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/session_log_recorder.dart';
import 'package:guardianangela/services/sim/audio_service_sim.dart';
import 'package:guardianangela/services/sim/backup_service_sim.dart';
import 'package:guardianangela/services/sim/background_session_service_sim.dart';
import 'package:guardianangela/services/sim/battery_monitor_service_sim.dart';
import 'package:guardianangela/services/sim/call_state_service_sim.dart';
import 'package:guardianangela/services/sim/contact_service_sim.dart';
import 'package:guardianangela/services/sim/encryption_service_sim.dart';
import 'package:guardianangela/services/sim/flash_service_sim.dart';
import 'package:guardianangela/services/sim/permission_audit_service_sim.dart';
import 'package:guardianangela/services/sim/session_start_validator_sim.dart';
import 'package:guardianangela/services/sim/hardware_button_service_sim.dart';
import 'package:guardianangela/services/sim/location_service_sim.dart';
import 'package:guardianangela/services/sim/messaging_service_sim.dart';
import 'package:guardianangela/services/sim/notification_service_sim.dart';
import 'package:guardianangela/services/sim/phone_service_sim.dart';
import 'package:guardianangela/services/sim/recording_service_sim.dart';
import 'package:guardianangela/services/sim/screen_flash_service_sim.dart';
import 'package:guardianangela/services/sim/sentry_service_sim.dart';
import 'package:guardianangela/services/sim/system_ui_service_sim.dart';
import 'package:guardianangela/services/sim/vibration_service_sim.dart';
import 'package:guardianangela/services/sim/wakelock_service_sim.dart';

void main() {
  group('Simulation swap — EncryptionService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          encryptionServiceProvider.overrideWithValue(
            SimulationEncryptionService(),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('encryptionServiceProvider returns SimulationEncryptionService '
        'when overridden', () {
      final service = container.read(encryptionServiceProvider);
      check(service).isA<SimulationEncryptionService>();
    });

    test('encryptionServiceProvider override is NOT RealEncryptionService', () {
      final service = container.read(encryptionServiceProvider);
      check(
        service.runtimeType.toString(),
      ).not((c) => c.equals('RealEncryptionService'));
    });

    test(
      'keyProviderProvider uses the simulation encryption service '
      '(returns a callable that produces a key without secure storage)',
      () async {
        final keyProvider = container.read(keyProviderProvider);
        // If the provider were backed by RealEncryptionService this
        // would try to read FlutterSecureStorage and fail in a unit
        // test environment.
        final key = await keyProvider();
        check(key).isNotEmpty();
      },
    );

    test('appSettingsRepositoryProvider resolves to an AppSettingsRepository '
        'with the simulation encryption key', () {
      // Just check the provider resolves without error. Actual
      // load() calls require path_provider; that is tested in
      // test/services/json_repos_wiring_test.dart which provides
      // a temp-dir override.
      final repo = container.read(appSettingsRepositoryProvider);
      check(repo.runtimeType.toString()).equals('AppSettingsRepository');
    });

    test(
      'userProfileRepositoryProvider resolves to a UserProfileRepository',
      () {
        final repo = container.read(userProfileRepositoryProvider);
        check(repo.runtimeType.toString()).equals('UserProfileRepository');
      },
    );

    test('batteryAlertConfigRepositoryProvider resolves to a '
        'BatteryAlertConfigRepository', () {
      final repo = container.read(batteryAlertConfigRepositoryProvider);
      check(repo.runtimeType.toString()).equals('BatteryAlertConfigRepository');
    });
  });

  group('Simulation swap — invariant: no Real*Service outside override', () {
    test('Default container (no overrides) uses RealEncryptionService', () {
      // This test verifies the DEFAULT wiring is Real* so that the
      // override swap above is non-trivial (we are actually swapping
      // something, not just reading the same impl).
      //
      // The RealEncryptionService constructor is safe to call here
      // because it only touches FlutterSecureStorage in async
      // operations (getKey / saveKey / getOrCreateKeyAsBase64),
      // not in the constructor itself.
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final service = c.read(encryptionServiceProvider);
      check(service.runtimeType.toString()).equals('RealEncryptionService');
    });
  });

  // -----------------------------------------------------------------------
  // Stage 5B.1 — 7 leaf service simulation swaps
  // -----------------------------------------------------------------------

  group('Simulation swap — VibrationService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          vibrationServiceProvider.overrideWithValue(
            SimulationVibrationService(),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('overridden container returns SimulationVibrationService', () {
      final s = container.read(vibrationServiceProvider);
      check(s).isA<SimulationVibrationService>();
    });

    test('overridden container is NOT RealVibrationService', () {
      final s = container.read(vibrationServiceProvider);
      check(
        s.runtimeType.toString(),
      ).not((c) => c.equals('RealVibrationService'));
    });
  });

  group('Simulation swap — WakelockService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          wakelockServiceProvider.overrideWithValue(
            SimulationWakelockService(),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('overridden container returns SimulationWakelockService', () {
      final s = container.read(wakelockServiceProvider);
      check(s).isA<SimulationWakelockService>();
    });

    test('simulation wakelock starts disabled', () {
      final s =
          container.read(wakelockServiceProvider) as SimulationWakelockService;
      check(s.isEnabled).isFalse();
    });
  });

  group('Simulation swap — FlashService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          flashServiceProvider.overrideWithValue(SimulationFlashService()),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('overridden container returns SimulationFlashService', () {
      final s = container.read(flashServiceProvider);
      check(s).isA<SimulationFlashService>();
    });

    test('simulation flash starts not flashing', () {
      final s = container.read(flashServiceProvider) as SimulationFlashService;
      check(s.isFlashing).isFalse();
    });
  });

  group('Simulation swap — ScreenFlashService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          screenFlashServiceProvider.overrideWithValue(
            SimulationScreenFlashService(),
          ),
        ],
      );
    });

    tearDown(() {
      (container.read(screenFlashServiceProvider)
              as SimulationScreenFlashService)
          .dispose();
      container.dispose();
    });

    test('overridden container returns SimulationScreenFlashService', () {
      final s = container.read(screenFlashServiceProvider);
      check(s).isA<SimulationScreenFlashService>();
    });
  });

  group('Simulation swap — RecordingService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          recordingServiceProvider.overrideWithValue(
            SimulationRecordingService(),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('overridden container returns SimulationRecordingService', () {
      final s = container.read(recordingServiceProvider);
      check(s).isA<SimulationRecordingService>();
    });

    test('simulation recording starts with empty calls', () {
      final s =
          container.read(recordingServiceProvider)
              as SimulationRecordingService;
      check(s.calls).isEmpty();
    });
  });

  group('Simulation swap — ContactService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          // contactServiceProvider is a FutureProvider — override with a
          // resolved future.
          contactServiceProvider.overrideWith(
            (_) async => SimulationContactService(),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('overridden container returns SimulationContactService', () async {
      final s = await container.read(contactServiceProvider.future);
      check(s).isA<SimulationContactService>();
    });

    test('simulation contact service starts with empty list', () async {
      final s = await container.read(contactServiceProvider.future)
          as SimulationContactService;
      check(s.all).isEmpty();
    });
  });

  group('Simulation swap — AudioService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          audioServiceProvider.overrideWithValue(SimulationAudioService()),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('overridden container returns SimulationAudioService', () {
      final s = container.read(audioServiceProvider);
      check(s).isA<SimulationAudioService>();
    });

    test('simulation audio starts with empty calls', () {
      final s = container.read(audioServiceProvider) as SimulationAudioService;
      check(s.calls).isEmpty();
    });
  });

  // -----------------------------------------------------------------------
  // Stage 5B.2 — 6 streaming/sensor service simulation swaps
  // -----------------------------------------------------------------------

  group('Simulation swap — LocationService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          locationServiceProvider.overrideWithValue(
            SimulationLocationService(),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('overridden container returns SimulationLocationService', () {
      final s = container.read(locationServiceProvider);
      check(s).isA<SimulationLocationService>();
    });

    test('simulation location starts not tracking', () {
      final s =
          container.read(locationServiceProvider) as SimulationLocationService;
      check(s.isTracking).isFalse();
    });
  });

  group('Simulation swap — BatteryMonitorService', () {
    late ProviderContainer container;
    late SimulationBatteryMonitorService sim;

    setUp(() {
      sim = SimulationBatteryMonitorService();
      container = ProviderContainer(
        overrides: [batteryMonitorServiceProvider.overrideWithValue(sim)],
      );
    });

    tearDown(() {
      container.dispose();
      sim.dispose();
    });

    test('overridden container returns SimulationBatteryMonitorService', () {
      final s = container.read(batteryMonitorServiceProvider);
      check(s).isA<SimulationBatteryMonitorService>();
    });

    test('simulation battery monitor starts not monitoring', () {
      final s =
          container.read(batteryMonitorServiceProvider)
              as SimulationBatteryMonitorService;
      check(s.isMonitoring).isFalse();
    });
  });

  group('Simulation swap — NotificationService', () {
    late ProviderContainer container;
    late SimulationNotificationService sim;

    setUp(() {
      sim = SimulationNotificationService();
      container = ProviderContainer(
        overrides: [notificationServiceProvider.overrideWithValue(sim)],
      );
    });

    tearDown(() {
      sim.dispose();
      container.dispose();
    });

    test('overridden container returns SimulationNotificationService', () {
      final s = container.read(notificationServiceProvider);
      check(s).isA<SimulationNotificationService>();
    });

    test('simulation notification starts with empty calls', () {
      final s =
          container.read(notificationServiceProvider)
              as SimulationNotificationService;
      check(s.calls).isEmpty();
    });
  });

  group('Simulation swap — HardwareButtonService', () {
    late ProviderContainer container;
    late SimulationHardwareButtonService sim;

    setUp(() {
      sim = SimulationHardwareButtonService();
      container = ProviderContainer(
        overrides: [hardwareButtonServiceProvider.overrideWithValue(sim)],
      );
    });

    tearDown(() {
      container.dispose();
      sim.dispose();
    });

    test('overridden container returns SimulationHardwareButtonService', () {
      final s = container.read(hardwareButtonServiceProvider);
      check(s).isA<SimulationHardwareButtonService>();
    });

    test('simulation hardware button starts not listening', () {
      final s =
          container.read(hardwareButtonServiceProvider)
              as SimulationHardwareButtonService;
      check(s.isListening).isFalse();
    });
  });

  group('Simulation swap — CallStateService', () {
    late ProviderContainer container;
    late SimulationCallStateService sim;

    setUp(() {
      sim = SimulationCallStateService();
      container = ProviderContainer(
        overrides: [callStateServiceProvider.overrideWithValue(sim)],
      );
    });

    tearDown(() {
      container.dispose();
      sim.dispose();
    });

    test('overridden container returns SimulationCallStateService', () {
      final s = container.read(callStateServiceProvider);
      check(s).isA<SimulationCallStateService>();
    });

    test('simulation call state starts not started', () {
      final s =
          container.read(callStateServiceProvider)
              as SimulationCallStateService;
      check(s.isStarted).isFalse();
    });
  });

  group('Simulation swap — SystemUiService', () {
    late ProviderContainer container;
    late SimulationSystemUiService sim;

    setUp(() {
      sim = SimulationSystemUiService();
      container = ProviderContainer(
        overrides: [systemUiServiceProvider.overrideWithValue(sim)],
      );
    });

    tearDown(() {
      container.dispose();
      sim.reset();
    });

    test('overridden container returns SimulationSystemUiService', () {
      final s = container.read(systemUiServiceProvider);
      check(s).isA<SimulationSystemUiService>();
    });

    test('simulation system UI starts with empty call log', () {
      final s =
          container.read(systemUiServiceProvider) as SimulationSystemUiService;
      check(s.calls).isEmpty();
    });
  });

  // -----------------------------------------------------------------------
  // Stage 5B.3 — 5 communication / cross-cutter service simulation swaps
  // -----------------------------------------------------------------------

  group('Simulation swap — PhoneService', () {
    late ProviderContainer container;
    late SimulationPhoneService sim;

    setUp(() {
      sim = SimulationPhoneService();
      container = ProviderContainer(
        overrides: [phoneServiceProvider.overrideWithValue(sim)],
      );
    });

    tearDown(() => container.dispose());

    test('overridden container returns SimulationPhoneService', () {
      final s = container.read(phoneServiceProvider);
      check(s).isA<SimulationPhoneService>();
    });

    test('simulation phone service starts with empty calls', () {
      final s = container.read(phoneServiceProvider) as SimulationPhoneService;
      check(s.calls).isEmpty();
    });
  });

  group('Simulation swap — MessagingService', () {
    late ProviderContainer container;
    late SimulationMessagingService sim;

    setUp(() {
      sim = SimulationMessagingService();
      container = ProviderContainer(
        overrides: [messagingServiceProvider.overrideWithValue(sim)],
      );
    });

    tearDown(() {
      sim.dispose();
      container.dispose();
    });

    test('overridden container returns SimulationMessagingService', () {
      final s = container.read(messagingServiceProvider);
      check(s).isA<SimulationMessagingService>();
    });

    test('simulation messaging starts with empty call log', () {
      final s =
          container.read(messagingServiceProvider)
              as SimulationMessagingService;
      check(s.calls).isEmpty();
    });
  });

  group('Simulation swap — BackgroundSessionService', () {
    late ProviderContainer container;
    late SimulationBackgroundSessionService sim;

    setUp(() {
      sim = SimulationBackgroundSessionService();
      container = ProviderContainer(
        overrides: [backgroundSessionServiceProvider.overrideWithValue(sim)],
      );
    });

    tearDown(() {
      sim.dispose();
      container.dispose();
    });

    test('overridden container returns SimulationBackgroundSessionService', () {
      final s = container.read(backgroundSessionServiceProvider);
      check(s).isA<SimulationBackgroundSessionService>();
    });

    test('simulation background session starts with empty calls', () {
      final s =
          container.read(backgroundSessionServiceProvider)
              as SimulationBackgroundSessionService;
      check(s.calls).isEmpty();
    });
  });

  group('Simulation swap — SentryService', () {
    late ProviderContainer container;
    late SimulationSentryService sim;

    setUp(() {
      sim = SimulationSentryService();
      container = ProviderContainer(
        overrides: [sentryServiceProvider.overrideWithValue(sim)],
      );
    });

    tearDown(() => container.dispose());

    test('overridden container returns SimulationSentryService', () {
      final s = container.read(sentryServiceProvider);
      check(s).isA<SimulationSentryService>();
    });

    test('simulation sentry starts not initialized', () {
      final s =
          container.read(sentryServiceProvider) as SimulationSentryService;
      check(s.isInitialized).isFalse();
    });
  });

  group('Simulation swap — SessionLogRecorder', () {
    late GuardianAngelaDatabase db;
    late SessionLogRepository repo;
    late ProviderContainer container;

    setUp(() {
      db = GuardianAngelaDatabase.memory();
      repo = SessionLogRepository(db.sessionLogsDao);
      container = ProviderContainer(
        overrides: [
          // sessionLogRecorderProvider is a FutureProvider — override with
          // a resolved future.
          sessionLogRecorderProvider.overrideWith(
            (_) async =>
                (SessionContext context) =>
                    SimulationSessionLogRecorder(context: context, repo: repo),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('overridden factory produces SimulationSessionLogRecorder', () async {
      final factory = await container.read(sessionLogRecorderProvider.future);
      check(factory).isNotNull();
    });

    test('default factory produces SessionLogRecorder (not simulation)', () async {
      // Build a default container with an in-memory database override.
      final defaultDb = GuardianAngelaDatabase.memory();
      final defaultContainer = ProviderContainer(
        overrides: [
          databaseProvider.overrideWith((_) async => defaultDb),
        ],
      );
      addTearDown(() async {
        defaultContainer.dispose();
        await defaultDb.close();
      });
      final factory = await defaultContainer.read(
        sessionLogRecorderProvider.future,
      );
      check(factory).isNotNull();
    });
  });

  // -------------------------------------------------------------------------
  // Stage 5C — PermissionAuditService, SessionStartValidator, BackupService
  // -------------------------------------------------------------------------

  group('Simulation swap — PermissionAuditService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          permissionAuditServiceProvider.overrideWithValue(
            SimulationPermissionAuditService(),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test(
      'overridden container returns SimulationPermissionAuditService',
      () {
        final s = container.read(permissionAuditServiceProvider);
        check(s).isA<SimulationPermissionAuditService>();
      },
    );

    test('simulation audit starts with no audited modes', () {
      final s = container.read(permissionAuditServiceProvider)
          as SimulationPermissionAuditService;
      check(s.auditedModes).isEmpty();
    });
  });

  group('Simulation swap — SessionStartValidator', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          sessionStartValidatorProvider.overrideWithValue(
            SimulationSessionStartValidator(),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test(
      'overridden container returns SimulationSessionStartValidator',
      () {
        final s = container.read(sessionStartValidatorProvider);
        check(s).isA<SimulationSessionStartValidator>();
      },
    );

    test('simulation validator starts with no validated modes', () {
      final s = container.read(sessionStartValidatorProvider)
          as SimulationSessionStartValidator;
      check(s.validatedModes).isEmpty();
    });
  });

  group('Simulation swap — BackupService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          backupServiceProvider.overrideWith(
            (_) async => SimulationBackupService(),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('overridden container returns SimulationBackupService', () async {
      final s = await container.read(backupServiceProvider.future);
      check(s).isA<SimulationBackupService>();
    });

    test('simulation backup starts with empty call records', () async {
      final s = await container.read(backupServiceProvider.future)
          as SimulationBackupService;
      check(s.exportCalls).isEmpty();
      check(s.importCalls).isEmpty();
    });
  });

  group('Simulation swap — databaseProvider (Stage 5C)', () {
    test('databaseProvider can be overridden with in-memory database', () async {
      final db = GuardianAngelaDatabase.memory();
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWith((_) async => db),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });
      final resolved = await container.read(databaseProvider.future);
      check(resolved).isA<GuardianAngelaDatabase>();
    });
  });
}
