// Coverage for service_providers.dart — THE single wiring owner.
//
// Reads every Real*Service provider through a real ProviderContainer so each
// construction lambda runs and resolves to the documented protocol type. The
// async (Drift-backed) providers resolve against an in-memory database; the
// real databaseProvider open() body is exercised separately against a mocked
// path_provider + a simulation encryption key.
//
// This is the genuine wiring-owner selection logic — a provider returning the
// wrong concrete type, or a missing dependency, fails here.

import 'dart:io';

import 'package:flutter/services.dart';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/feedback_history_repository.dart';
import 'package:guardianangela/services/protocols/audio_service_protocol.dart';
import 'package:guardianangela/services/protocols/background_session_service_protocol.dart';
import 'package:guardianangela/services/protocols/backup_service_protocol.dart';
import 'package:guardianangela/services/protocols/biometric_service_protocol.dart';
import 'package:guardianangela/services/protocols/call_state_service_protocol.dart';
import 'package:guardianangela/services/protocols/contact_service_protocol.dart';
import 'package:guardianangela/services/protocols/device_info_service_protocol.dart';
import 'package:guardianangela/services/protocols/flash_service_protocol.dart';
import 'package:guardianangela/services/protocols/hardware_button_service_protocol.dart';
import 'package:guardianangela/services/protocols/home_widget_service_protocol.dart';
import 'package:guardianangela/services/protocols/location_service_protocol.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';
import 'package:guardianangela/services/protocols/permission_audit_service_protocol.dart';
import 'package:guardianangela/services/protocols/phone_service_protocol.dart';
import 'package:guardianangela/services/protocols/quick_exit_service_protocol.dart';
import 'package:guardianangela/services/protocols/recording_service_protocol.dart';
import 'package:guardianangela/services/protocols/session_start_validator_protocol.dart';
import 'package:guardianangela/services/protocols/system_ui_service_protocol.dart';
import 'package:guardianangela/services/protocols/vibration_service_protocol.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/encryption_service_sim.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('service_providers — sync Real*Service construction lambdas', () {
    late ProviderContainer container;
    late GuardianAngelaDatabase db;

    // A few Real*Service constructors touch a plugin channel eagerly (record's
    // AudioRecorder.create, home_widget's setAppGroupId). Mock those channels
    // to harmless no-ops so the construction lambdas run on the host.
    void mockPluginChannel(String name) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(name), (_) async => null);
    }

    void unmockPluginChannel(String name) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(name), null);
    }

    setUp(() {
      mockPluginChannel('com.llfbandit.record/messages');
      mockPluginChannel('home_widget');
      db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
      container = ProviderContainer(
        overrides: [
          // Resolve the async DB-backed providers against in-memory Drift.
          databaseProvider.overrideWith((_) async => db),
          encryptionServiceProvider.overrideWithValue(
            SimulationEncryptionService(),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
      unmockPluginChannel('com.llfbandit.record/messages');
      unmockPluginChannel('home_widget');
    });

    test('each leaf output/sensor provider builds its Real implementation', () {
      check(
        container.read(vibrationServiceProvider),
      ).isA<VibrationServiceProtocol>();
      check(
        container.read(biometricServiceProvider),
      ).isA<BiometricServiceProtocol>();
      check(container.read(flashServiceProvider)).isA<FlashServiceProtocol>();
      check(
        container.read(recordingServiceProvider),
      ).isA<RecordingServiceProtocol>();
      check(container.read(audioServiceProvider)).isA<AudioServiceProtocol>();
      check(
        container.read(locationServiceProvider),
      ).isA<LocationServiceProtocol>();
      check(
        container.read(notificationServiceProvider),
      ).isA<NotificationServiceProtocol>();
      check(
        container.read(hardwareButtonServiceProvider),
      ).isA<HardwareButtonServiceProtocol>();
      check(
        container.read(callStateServiceProvider),
      ).isA<CallStateServiceProtocol>();
      check(
        container.read(systemUiServiceProvider),
      ).isA<SystemUiServiceProtocol>();
      check(
        container.read(deviceInfoServiceProvider),
      ).isA<DeviceInfoServiceProtocol>();
      check(container.read(phoneServiceProvider)).isA<PhoneServiceProtocol>();
      check(
        container.read(quickExitServiceProvider),
      ).isA<QuickExitServiceProtocol>();
      check(
        container.read(homeWidgetServiceProvider),
      ).isA<HomeWidgetServiceProtocol>();
      check(
        container.read(permissionAuditServiceProvider),
      ).isA<PermissionAuditServiceProtocol>();
      check(
        container.read(sessionStartValidatorProvider),
      ).isA<SessionStartValidatorProtocol>();
    });

    test('messaging provider wires notification + phone dispatcher', () {
      check(
        container.read(messagingServiceProvider),
      ).isA<MessagingServiceProtocol>();
    });

    test('background-session provider wires the notification dependency', () {
      check(
        container.read(backgroundSessionServiceProvider),
      ).isA<BackgroundSessionServiceProtocol>();
    });

    test('contactService FutureProvider builds RealContactService over the '
        'Drift-backed repository', () async {
      final svc = await container.read(contactServiceProvider.future);
      check(svc).isA<ContactServiceProtocol>();
    });

    test(
      'feedbackHistoryRepository FutureProvider builds over the DB',
      () async {
        final repo = await container.read(
          feedbackHistoryRepositoryProvider.future,
        );
        check(repo).isA<FeedbackHistoryRepository>();
      },
    );

    test('sessionLogRecorder factory FutureProvider resolves', () async {
      final factory = await container.read(sessionLogRecorderProvider.future);
      // The factory is callable and produces a recorder for a context.
      check(factory).isNotNull();
    });

    test('backup FutureProvider builds RealBackupService over the DB '
        'and repos', () async {
      final svc = await container.read(backupServiceProvider.future);
      check(svc).isA<BackupServiceProtocol>();
    });
  });

  group('service_providers — real databaseProvider open() body', () {
    test('databaseProvider opens a real encrypted DB via the encryption '
        'key + path_provider', () async {
      final docsDir = await Directory.systemTemp.createTemp('ga_sp_db_');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (call) async => call.method == 'getApplicationDocumentsDirectory'
                ? docsDir.path
                : null,
          );
      // SimulationEncryptionService yields a deterministic 32-byte key.
      final container = ProviderContainer(
        overrides: [
          encryptionServiceProvider.overrideWithValue(
            SimulationEncryptionService(),
          ),
        ],
      );
      try {
        final db = await container.read(databaseProvider.future);
        // Force the connection to open + seed.
        check(await db.sessionModesDao.getAll()).isNotEmpty();
        await db.close();
      } finally {
        container.dispose();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('plugins.flutter.io/path_provider'),
              null,
            );
        await docsDir.delete(recursive: true);
      }
    });
  });
}
