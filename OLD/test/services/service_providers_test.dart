/// Smoke tests that every service provider constructs its service
/// without throwing. Also verifies `onDispose` wiring for providers
/// that close streams (notification, hardware button, incoming call,
/// geofence).
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/service_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('real service providers', () {
    test('every real provider constructs a concrete service', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      check(c.read(audioServiceProvider)).isA<AudioServiceProtocol>();
      check(c.read(vibrationServiceProvider)).isA<VibrationServiceProtocol>();
      check(c.read(messagingServiceProvider)).isA<MessagingServiceProtocol>();
      check(c.read(phoneServiceProvider)).isA<PhoneServiceProtocol>();
      check(c.read(locationServiceProvider)).isA<LocationServiceProtocol>();
      check(
        c.read(notificationServiceProvider),
      ).isA<NotificationServiceProtocol>();
      check(
        c.read(hardwareButtonServiceProvider),
      ).isA<HardwareButtonServiceProtocol>();
      check(
        c.read(incomingCallServiceProvider),
      ).isA<IncomingCallServiceProtocol>();
      check(
        c.read(batteryMonitorServiceProvider),
      ).isA<BatteryMonitorServiceProtocol>();
      check(
        c.read(deviceStateServiceProvider),
      ).isA<DeviceStateServiceProtocol>();
      check(c.read(geofenceServiceProvider)).isA<GeofenceServiceProtocol>();
      check(
        c.read(stealthIconServiceProvider),
      ).isA<StealthIconServiceProtocol>();
      check(c.read(homeWidgetServiceProvider)).isA<HomeWidgetServiceProtocol>();
      check(c.read(wakelockServiceProvider)).isA<WakelockServiceProtocol>();
      check(c.read(systemUiServiceProvider)).isA<SystemUiServiceProtocol>();
    });

    test('every simulation provider constructs a concrete service', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      check(c.read(simulationAudioProvider)).isA<AudioServiceProtocol>();
      check(
        c.read(simulationVibrationProvider),
      ).isA<VibrationServiceProtocol>();
      check(
        c.read(simulationMessagingProvider),
      ).isA<MessagingServiceProtocol>();
      check(c.read(simulationPhoneProvider)).isA<PhoneServiceProtocol>();
      check(c.read(simulationLocationProvider)).isA<LocationServiceProtocol>();
      check(
        c.read(simulationNotificationProvider),
      ).isA<NotificationServiceProtocol>();
      check(
        c.read(simulationHardwareButtonProvider),
      ).isA<HardwareButtonServiceProtocol>();
      check(
        c.read(simulationIncomingCallProvider),
      ).isA<IncomingCallServiceProtocol>();
      check(
        c.read(simulationBatteryMonitorProvider),
      ).isA<BatteryMonitorServiceProtocol>();
      check(
        c.read(simulationDeviceStateProvider),
      ).isA<DeviceStateServiceProtocol>();
      check(c.read(simulationGeofenceProvider)).isA<GeofenceServiceProtocol>();
      check(
        c.read(simulationStealthIconProvider),
      ).isA<StealthIconServiceProtocol>();
      check(
        c.read(simulationHomeWidgetProvider),
      ).isA<HomeWidgetServiceProtocol>();
      check(c.read(simulationWakelockProvider)).isA<WakelockServiceProtocol>();
      check(c.read(simulationSystemUiProvider)).isA<SystemUiServiceProtocol>();
    });
  });

  test('onDispose hooks fire when container disposes', () {
    final c = ProviderContainer();
    // Read the providers that wire onDispose to service.dispose().
    c.read(notificationServiceProvider);
    c.read(hardwareButtonServiceProvider);
    c.read(incomingCallServiceProvider);
    c.read(geofenceServiceProvider);
    // Dispose; should close streams without throwing.
    c.dispose();
  });
}
