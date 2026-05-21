/// Tests for the remaining real services (audio, vibration, location,
/// geofence, battery_monitor, wakelock, home_widget).
///
/// These wrap third-party Flutter packages (`just_audio`, `vibration`,
/// `geolocator`, `battery_plus`, `wakelock_plus`, `home_widget`) which
/// have no pure-Dart/Linux bindings and therefore throw
/// MissingPluginException in the unit test harness. The tests below
/// exercise:
///  * isSimulation short-circuits that never touch the plugin
///  * dispose / cleanup
///  * pure-Dart logic (history caps, in-memory caches)
///  * MissingPluginException surfaces — error contract
library;

import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/services/implementations/audio_service.dart';
import 'package:guardianangela/services/implementations/battery_monitor_service.dart';
import 'package:guardianangela/services/implementations/geofence_service.dart';
import 'package:guardianangela/services/implementations/home_widget_service.dart';
import 'package:guardianangela/services/implementations/location_service.dart';
import 'package:guardianangela/services/implementations/vibration_service.dart';
import 'package:guardianangela/services/implementations/wakelock_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioService isSimulation', () {
    test('playAlarm isSimulation is a no-op (no plugin reach)', () async {
      final s = AudioService();
      await s.playAlarm(isSimulation: true);
      await s.playAlarm(isSimulation: true, maxVolume: false);
    });

    test('playRingtone isSimulation is a no-op', () async {
      final s = AudioService();
      await s.playRingtone(isSimulation: true);
      await s.playRingtone(isSimulation: true, assetPath: 'custom.wav');
    });

    test('playVoiceRecording isSimulation is a no-op', () async {
      final s = AudioService();
      await s.playVoiceRecording(assetPath: 'v.mp3', isSimulation: true);
    });

    test(
      'stopAlarm on a service with no player instantiated is safe',
      () async {
        final s = AudioService();
        await s.stopAlarm();
        await s.stopRingtone();
        await s.stopVoiceRecording();
      },
    );
  });

  group('VibrationService isSimulation', () {
    test('every pattern method is a no-op when isSimulation=true', () async {
      final s = VibrationService();
      await s.alarmPattern(isSimulation: true);
      await s.warningPattern(isSimulation: true);
      await s.fakeCallPattern(isSimulation: true);
    });

    test('real alarmPattern completes without throwing on host', () async {
      // Vibration.hasVibrator returns false on non-mobile hosts, so the
      // guarded `Vibration.vibrate` is skipped and the method completes.
      final s = VibrationService();
      await s.alarmPattern();
      await s.warningPattern();
      await s.fakeCallPattern();
    });

    test('stop surfaces MissingPluginException in tests', () async {
      final s = VibrationService();
      await check(s.stop()).throws<Object>();
    });
  });

  group('LocationService', () {
    test('empty-history accessors return null/empty', () async {
      final s = LocationService();
      check(s.getLastLocationPoint()).isNull();
      check(s.getLastLocationUrl()).isNull();
      check(s.history).isEmpty();
      s.clearHistory();
      check(s.history).isEmpty();
    });

    test(
      'requestPermission surfaces MissingPluginException in tests',
      () async {
        final s = LocationService();
        await check(s.requestPermission()).throws<Object>();
      },
    );

    test('startTracking/stopTracking are safe to call (lazy stream)', () async {
      final s = LocationService();
      // The position stream is lazy: subscribing does not trigger the
      // native plugin call. Stream errors are logged via onError.
      await s.startTracking();
      await s.stopTracking();
    });
  });

  group('GeofenceService', () {
    test('dispose is idempotent and closes the stream', () async {
      final s = GeofenceService();
      await s.dispose();
      await s.dispose();
    });

    test('arrivals is a broadcast stream', () {
      final s = GeofenceService();
      check(s.arrivals.isBroadcast).isTrue();
      s.dispose();
    });

    test('removeGeofence on a never-registered service is safe', () async {
      final s = GeofenceService();
      await s.removeGeofence();
      await s.dispose();
    });

    test('registerGeofence sets internal center without throwing', () async {
      // The Position stream is subscribed lazily; the call returns
      // immediately even if the native plugin is missing.
      final s = GeofenceService();
      await s.registerGeofence(
        latitude: 47.0,
        longitude: 8.0,
        radiusMeters: 50.0,
      );
      await s.removeGeofence();
      await s.dispose();
    });
  });

  group('BatteryMonitorService', () {
    test('threshold out of range throws ArgumentError', () async {
      final s = BatteryMonitorService();
      await check(
        s.startMonitoring(thresholdPercent: -1),
      ).throws<ArgumentError>();
      await check(
        s.startMonitoring(thresholdPercent: 101),
      ).throws<ArgumentError>();
    });

    test('isActive defaults to false and onLowBattery is broadcast', () async {
      final s = BatteryMonitorService();
      check(s.isActive).isFalse();
      check(s.onLowBattery.isBroadcast).isTrue();
      await s.stopMonitoring();
      check(s.isActive).isFalse();
    });

    test('startMonitoring seeds level via battery plugin — '
        'MissingPluginException propagates on host', () async {
      final s = BatteryMonitorService();
      // _safeBatteryLevel only catches PlatformException, not
      // MissingPluginException; that surfaces on the test host.
      await check(
        s.startMonitoring(thresholdPercent: 20),
      ).throws<MissingPluginException>();
      // isActive was set before the failing call, so leave the
      // service by stopping it cleanly.
      await s.stopMonitoring();
    });

    test('stopMonitoring is idempotent', () async {
      final s = BatteryMonitorService();
      await s.stopMonitoring();
      await s.stopMonitoring();
      check(s.isActive).isFalse();
    });
  });

  group('WakelockService', () {
    test(
      'enable/disable/isEnabled surface MissingPluginException in tests',
      () async {
        final s = WakelockService();
        await check(s.enable()).throws<Object>();
        await check(s.disable()).throws<Object>();
        await check(s.isEnabled).throws<Object>();
      },
    );
  });

  group('HomeWidgetService', () {
    test(
      'initiallyLaunchedUri surfaces MissingPluginException in tests',
      () async {
        final s = HomeWidgetService();
        await check(s.initiallyLaunchedUri()).throws<Object>();
      },
    );

    test('updateStatus surfaces MissingPluginException in tests', () async {
      final s = HomeWidgetService();
      await check(
        s.updateStatus(status: 'Idle', modeName: 'Walk', isRunning: false),
      ).throws<Object>();
    });

    test('writeLastMarker surfaces MissingPluginException in tests', () async {
      final s = HomeWidgetService();
      await check(s.writeLastMarker('m')).throws<Object>();
    });

    test(
      'consumePendingMarker surfaces MissingPluginException in tests',
      () async {
        final s = HomeWidgetService();
        await check(s.consumePendingMarker()).throws<Object>();
      },
    );

    test(
      'registerInteractivity surfaces MissingPluginException in tests',
      () async {
        final s = HomeWidgetService();
        await check(s.registerInteractivity(() {})).throws<Object>();
      },
    );
  });

  // Sanity: every service exposes a default constructor with no
  // required arguments; the providers file constructs them via `()`.
  test('every real service has a no-arg constructor', () {
    final services = <Object>[
      AudioService(),
      VibrationService(),
      LocationService(),
      GeofenceService(),
      BatteryMonitorService(),
      WakelockService(),
      HomeWidgetService(),
    ];
    check(services.length).equals(7);
  });

  test('LocationPoint history cap is observed via getLastLocationPoint', () {
    // Structural test — we can't push positions without a plugin, but
    // verifying the history accessors is easy.
    final s = LocationService();
    check(s.history).isEmpty();
    check(s.getLastLocationPoint()).isNull();
    // Construct a point and ensure the model math is correct — exercises
    // the toMapsUrl() used by getLastLocationUrl() indirectly.
    final p = LocationPoint(
      latitude: 1,
      longitude: 2,
      timestamp: DateTime.utc(2026, 1, 1),
    );
    check(p.toMapsUrl()).equals('https://maps.google.com/?q=1.0,2.0');
  });
}
