/// Wiring contract test — every service/repository provider must
/// resolve without throwing at construction time, and each real/simulation
/// pair must return the expected concrete type.
///
/// The service providers currently return stub instances whose methods
/// throw `UnimplementedError`. That's fine — this test only exercises
/// provider construction, not method calls. If a later phase accidentally
/// breaks the provider graph (cyclic deps, missing override, type
/// mismatch), this guard fails fast.
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/battery_alert_repository.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/data/repositories/modes_repository.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/data/repositories/session_logs_repository.dart';
import 'package:guardianangela/data/repositories/settings_repository.dart';
import 'package:guardianangela/data/repositories/templates_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/simulation/simulation_audio_service.dart';
import 'package:guardianangela/services/simulation/simulation_battery_monitor_service.dart';
import 'package:guardianangela/services/simulation/simulation_device_state_service.dart';
import 'package:guardianangela/services/simulation/simulation_geofence_service.dart';
import 'package:guardianangela/services/simulation/simulation_hardware_button_service.dart';
import 'package:guardianangela/services/simulation/simulation_home_widget_service.dart';
import 'package:guardianangela/services/simulation/simulation_incoming_call_service.dart';
import 'package:guardianangela/services/simulation/simulation_location_service.dart';
import 'package:guardianangela/services/simulation/simulation_messaging_service.dart';
import 'package:guardianangela/services/simulation/simulation_notification_service.dart';
import 'package:guardianangela/services/simulation/simulation_phone_service.dart';
import 'package:guardianangela/services/simulation/simulation_stealth_icon_service.dart';
import 'package:guardianangela/services/simulation/simulation_system_ui_service.dart';
import 'package:guardianangela/services/simulation/simulation_vibration_service.dart';
import 'package:guardianangela/services/simulation/simulation_wakelock_service.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('service providers resolve', () {
    late ProviderContainer container;

    setUp(() {
      container = makeContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('audioServiceProvider returns AudioService', () {
      check(container.read(audioServiceProvider)).isA<AudioService>();
    });

    test('simulationAudioProvider returns SimulationAudioService', () {
      check(
        container.read(simulationAudioProvider),
      ).isA<SimulationAudioService>();
    });

    test('vibrationServiceProvider returns VibrationService', () {
      check(container.read(vibrationServiceProvider)).isA<VibrationService>();
    });

    test('simulationVibrationProvider returns simulation', () {
      check(
        container.read(simulationVibrationProvider),
      ).isA<SimulationVibrationService>();
    });

    test('messagingServiceProvider returns MessagingService', () {
      check(container.read(messagingServiceProvider)).isA<MessagingService>();
    });

    test('simulationMessagingProvider returns simulation', () {
      check(
        container.read(simulationMessagingProvider),
      ).isA<SimulationMessagingService>();
    });

    test('phoneServiceProvider returns PhoneService', () {
      check(container.read(phoneServiceProvider)).isA<PhoneService>();
    });

    test('simulationPhoneProvider returns simulation', () {
      check(
        container.read(simulationPhoneProvider),
      ).isA<SimulationPhoneService>();
    });

    test('locationServiceProvider returns LocationService', () {
      check(container.read(locationServiceProvider)).isA<LocationService>();
    });

    test('simulationLocationProvider returns simulation', () {
      check(
        container.read(simulationLocationProvider),
      ).isA<SimulationLocationService>();
    });

    test('notificationServiceProvider returns NotificationService', () {
      check(
        container.read(notificationServiceProvider),
      ).isA<NotificationService>();
    });

    test('simulationNotificationProvider returns simulation', () {
      check(
        container.read(simulationNotificationProvider),
      ).isA<SimulationNotificationService>();
    });

    test('hardwareButtonServiceProvider returns HardwareButtonService', () {
      check(
        container.read(hardwareButtonServiceProvider),
      ).isA<HardwareButtonService>();
    });

    test('simulationHardwareButtonProvider returns simulation', () {
      check(
        container.read(simulationHardwareButtonProvider),
      ).isA<SimulationHardwareButtonService>();
    });

    test('incomingCallServiceProvider returns IncomingCallService', () {
      check(
        container.read(incomingCallServiceProvider),
      ).isA<IncomingCallService>();
    });

    test('simulationIncomingCallProvider returns simulation', () {
      check(
        container.read(simulationIncomingCallProvider),
      ).isA<SimulationIncomingCallService>();
    });

    test('batteryMonitorServiceProvider returns BatteryMonitorService', () {
      check(
        container.read(batteryMonitorServiceProvider),
      ).isA<BatteryMonitorService>();
    });

    test('simulationBatteryMonitorProvider returns simulation', () {
      check(
        container.read(simulationBatteryMonitorProvider),
      ).isA<SimulationBatteryMonitorService>();
    });

    test('deviceStateServiceProvider returns DeviceStateService', () {
      check(
        container.read(deviceStateServiceProvider),
      ).isA<DeviceStateService>();
    });

    test('simulationDeviceStateProvider returns simulation', () {
      check(
        container.read(simulationDeviceStateProvider),
      ).isA<SimulationDeviceStateService>();
    });

    test('geofenceServiceProvider returns GeofenceService', () {
      check(container.read(geofenceServiceProvider)).isA<GeofenceService>();
    });

    test('simulationGeofenceProvider returns simulation', () {
      check(
        container.read(simulationGeofenceProvider),
      ).isA<SimulationGeofenceService>();
    });

    test('stealthIconServiceProvider returns StealthIconService', () {
      check(
        container.read(stealthIconServiceProvider),
      ).isA<StealthIconService>();
    });

    test('simulationStealthIconProvider returns simulation', () {
      check(
        container.read(simulationStealthIconProvider),
      ).isA<SimulationStealthIconService>();
    });

    test('homeWidgetServiceProvider returns HomeWidgetService', () {
      check(container.read(homeWidgetServiceProvider)).isA<HomeWidgetService>();
    });

    test('simulationHomeWidgetProvider returns simulation', () {
      check(
        container.read(simulationHomeWidgetProvider),
      ).isA<SimulationHomeWidgetService>();
    });

    test('wakelockServiceProvider returns WakelockService', () {
      check(container.read(wakelockServiceProvider)).isA<WakelockService>();
    });

    test('simulationWakelockProvider returns simulation', () {
      check(
        container.read(simulationWakelockProvider),
      ).isA<SimulationWakelockService>();
    });

    test('systemUiServiceProvider returns SystemUiService', () {
      check(container.read(systemUiServiceProvider)).isA<SystemUiService>();
    });

    test('simulationSystemUiProvider returns simulation', () {
      check(
        container.read(simulationSystemUiProvider),
      ).isA<SimulationSystemUiService>();
    });
  });

  group('real and simulation pairs are distinct concrete types', () {
    late ProviderContainer container;

    setUp(() {
      container = makeContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('audio', () {
      check(container.read(audioServiceProvider).runtimeType).not(
        (it) => it.equals(container.read(simulationAudioProvider).runtimeType),
      );
    });

    test('vibration', () {
      check(container.read(vibrationServiceProvider).runtimeType).not(
        (it) =>
            it.equals(container.read(simulationVibrationProvider).runtimeType),
      );
    });

    test('messaging', () {
      check(container.read(messagingServiceProvider).runtimeType).not(
        (it) =>
            it.equals(container.read(simulationMessagingProvider).runtimeType),
      );
    });

    test('phone', () {
      check(container.read(phoneServiceProvider).runtimeType).not(
        (it) => it.equals(container.read(simulationPhoneProvider).runtimeType),
      );
    });

    test('location', () {
      check(container.read(locationServiceProvider).runtimeType).not(
        (it) =>
            it.equals(container.read(simulationLocationProvider).runtimeType),
      );
    });

    test('notification', () {
      check(container.read(notificationServiceProvider).runtimeType).not(
        (it) => it.equals(
          container.read(simulationNotificationProvider).runtimeType,
        ),
      );
    });

    test('hardwareButton', () {
      check(container.read(hardwareButtonServiceProvider).runtimeType).not(
        (it) => it.equals(
          container.read(simulationHardwareButtonProvider).runtimeType,
        ),
      );
    });

    test('incomingCall', () {
      check(container.read(incomingCallServiceProvider).runtimeType).not(
        (it) => it.equals(
          container.read(simulationIncomingCallProvider).runtimeType,
        ),
      );
    });

    test('batteryMonitor', () {
      check(container.read(batteryMonitorServiceProvider).runtimeType).not(
        (it) => it.equals(
          container.read(simulationBatteryMonitorProvider).runtimeType,
        ),
      );
    });

    test('deviceState', () {
      check(container.read(deviceStateServiceProvider).runtimeType).not(
        (it) => it.equals(
          container.read(simulationDeviceStateProvider).runtimeType,
        ),
      );
    });

    test('geofence', () {
      check(container.read(geofenceServiceProvider).runtimeType).not(
        (it) =>
            it.equals(container.read(simulationGeofenceProvider).runtimeType),
      );
    });

    test('stealthIcon', () {
      check(container.read(stealthIconServiceProvider).runtimeType).not(
        (it) => it.equals(
          container.read(simulationStealthIconProvider).runtimeType,
        ),
      );
    });

    test('homeWidget', () {
      check(container.read(homeWidgetServiceProvider).runtimeType).not(
        (it) =>
            it.equals(container.read(simulationHomeWidgetProvider).runtimeType),
      );
    });

    test('wakelock', () {
      check(container.read(wakelockServiceProvider).runtimeType).not(
        (it) =>
            it.equals(container.read(simulationWakelockProvider).runtimeType),
      );
    });

    test('systemUi', () {
      check(container.read(systemUiServiceProvider).runtimeType).not(
        (it) =>
            it.equals(container.read(simulationSystemUiProvider).runtimeType),
      );
    });
  });

  group('repository providers resolve', () {
    late ProviderContainer container;

    setUp(() {
      container = makeContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('modesRepositoryProvider', () {
      check(container.read(modesRepositoryProvider)).isA<ModesRepository>();
    });

    test('contactsRepositoryProvider', () {
      check(
        container.read(contactsRepositoryProvider),
      ).isA<ContactsRepository>();
    });

    test('templatesRepositoryProvider', () {
      check(
        container.read(templatesRepositoryProvider),
      ).isA<TemplatesRepository>();
    });

    test('settingsRepositoryProvider', () {
      check(
        container.read(settingsRepositoryProvider),
      ).isA<SettingsRepository>();
    });

    test('userProfileRepositoryProvider', () {
      check(
        container.read(userProfileRepositoryProvider),
      ).isA<UserProfileRepository>();
    });

    test('batteryAlertRepositoryProvider', () {
      check(
        container.read(batteryAlertRepositoryProvider),
      ).isA<BatteryAlertRepository>();
    });

    test('sessionLogsRepositoryProvider', () {
      check(
        container.read(sessionLogsRepositoryProvider),
      ).isA<SessionLogsRepository>();
    });
  });
}
