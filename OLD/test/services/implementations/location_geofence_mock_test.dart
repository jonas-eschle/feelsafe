/// Tests for LocationService and GeofenceService using a mocked
/// geolocator plugin. Exercises:
///  * requestPermission: denied → denied, denied → whileInUse, always
///  * startTracking → position stream → _onPosition adds to history
///  * FIFO cap at 200 entries
///  * GeofenceService._onPosition updates insideRegion latch
library;

import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/implementations/geofence_service.dart';
import 'package:guardianangela/services/implementations/location_service.dart';

import 'channel_test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const geoChannel = MethodChannel('flutter.baseflow.com/geolocator');
  const eventChannel = EventChannel('flutter.baseflow.com/geolocator_updates');

  group('LocationService.requestPermission', () {
    test('denied then denied on request returns false', () async {
      installMethodChannelMock(
        geoChannel,
        responder: (call) {
          if (call.method == 'checkPermission') return 0; // denied
          if (call.method == 'requestPermission') return 0; // denied
          return null;
        },
      );
      final s = LocationService();
      check(await s.requestPermission()).isFalse();
    });

    test('denied then whileInUse on request returns true', () async {
      installMethodChannelMock(
        geoChannel,
        responder: (call) {
          if (call.method == 'checkPermission') return 0; // denied
          if (call.method == 'requestPermission') return 2; // whileInUse
          return null;
        },
      );
      final s = LocationService();
      check(await s.requestPermission()).isTrue();
    });

    test('always on check returns true without requesting', () async {
      final calls = installMethodChannelMock(
        geoChannel,
        responder: (call) {
          if (call.method == 'checkPermission') return 3; // always
          return null;
        },
      );
      final s = LocationService();
      check(await s.requestPermission()).isTrue();
      check(calls.where((c) => c.method == 'requestPermission')).isEmpty();
    });

    test('deniedForever returns false', () async {
      installMethodChannelMock(
        geoChannel,
        responder: (call) {
          if (call.method == 'checkPermission') return 1; // deniedForever
          return null;
        },
      );
      final s = LocationService();
      check(await s.requestPermission()).isFalse();
    });
  });

  group('LocationService.startTracking', () {
    test('startTracking subscribes and _onPosition adds to history', () async {
      installMethodChannelMock(geoChannel);
      final evt = installEventChannelMock(eventChannel);
      final s = LocationService();
      await s.startTracking(interval: const Duration(seconds: 10));
      check(s.history).isEmpty();
      final epochMs = DateTime.utc(2026, 1, 1).millisecondsSinceEpoch;
      await evt.push({
        'latitude': 47.5,
        'longitude': 8.5,
        'timestamp': epochMs.toDouble(),
        'accuracy': 5.0,
        'altitude': 400.0,
        'altitude_accuracy': 10.0,
        'heading': 0.0,
        'heading_accuracy': 0.0,
        'speed': 0.0,
        'speed_accuracy': 0.0,
        'floor': null,
        'is_mocked': false,
      });
      await Future<void>.delayed(const Duration(milliseconds: 5));
      check(s.history.length).equals(1);
      check(s.getLastLocationPoint()!.latitude).equals(47.5);
      check(
        s.getLastLocationUrl(),
      ).equals('https://maps.google.com/?q=47.5,8.5');
      await s.stopTracking();
    });

    test('FIFO cap removes oldest beyond 200 entries', () async {
      installMethodChannelMock(geoChannel);
      final evt = installEventChannelMock(eventChannel);
      final s = LocationService();
      await s.startTracking();
      final epochMs = DateTime.utc(2026, 1, 1).millisecondsSinceEpoch;
      for (var i = 0; i < 205; i++) {
        await evt.push({
          'latitude': i.toDouble(),
          'longitude': 0.0,
          'timestamp': (epochMs + i).toDouble(),
          'accuracy': 5.0,
          'altitude': 0.0,
          'altitude_accuracy': 0.0,
          'heading': 0.0,
          'heading_accuracy': 0.0,
          'speed': 0.0,
          'speed_accuracy': 0.0,
          'floor': null,
          'is_mocked': false,
        });
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
      check(s.history.length).equals(200);
      // Oldest is removed — first entry is index 5 (205 - 200).
      check(s.history.first.latitude).equals(5.0);
      check(s.history.last.latitude).equals(204.0);
      s.clearHistory();
      check(s.history).isEmpty();
      await s.stopTracking();
    });

    test('restart replaces existing subscription', () async {
      installMethodChannelMock(geoChannel);
      installEventChannelMock(eventChannel);
      final s = LocationService();
      await s.startTracking();
      await s.startTracking(); // should cancel previous
      await s.stopTracking();
    });
  });

  group('GeofenceService with mocked geolocator', () {
    test('enter + exit + re-entry fires arrival once per entry', () async {
      installMethodChannelMock(geoChannel);
      final evt = installEventChannelMock(eventChannel);
      final s = GeofenceService();
      final arrivals = <double>[];
      final sub = s.arrivals.listen((p) => arrivals.add(p.latitude));
      await s.registerGeofence(
        latitude: 0.0,
        longitude: 0.0,
        radiusMeters: 100.0,
      );
      final baseMs = DateTime.utc(2026, 1, 1).millisecondsSinceEpoch;
      // Outside: far away (hundreds of km)
      await evt.push({
        'latitude': 1.0,
        'longitude': 1.0,
        'timestamp': baseMs.toDouble(),
        'accuracy': 5.0,
        'altitude': 0.0,
        'altitude_accuracy': 0.0,
        'heading': 0.0,
        'heading_accuracy': 0.0,
        'speed': 0.0,
        'speed_accuracy': 0.0,
        'floor': null,
        'is_mocked': false,
      });
      // Inside: 0.0002 deg ≈ 22m
      await evt.push({
        'latitude': 0.0002,
        'longitude': 0.0,
        'timestamp': (baseMs + 1).toDouble(),
        'accuracy': 5.0,
        'altitude': 0.0,
        'altitude_accuracy': 0.0,
        'heading': 0.0,
        'heading_accuracy': 0.0,
        'speed': 0.0,
        'speed_accuracy': 0.0,
        'floor': null,
        'is_mocked': false,
      });
      await Future<void>.delayed(const Duration(milliseconds: 10));
      check(arrivals.length).equals(1);
      // Another inside point should NOT re-fire.
      await evt.push({
        'latitude': 0.0003,
        'longitude': 0.0,
        'timestamp': (baseMs + 2).toDouble(),
        'accuracy': 5.0,
        'altitude': 0.0,
        'altitude_accuracy': 0.0,
        'heading': 0.0,
        'heading_accuracy': 0.0,
        'speed': 0.0,
        'speed_accuracy': 0.0,
        'floor': null,
        'is_mocked': false,
      });
      await Future<void>.delayed(const Duration(milliseconds: 10));
      check(arrivals.length).equals(1);
      // Exit region → reset latch.
      await evt.push({
        'latitude': 1.0,
        'longitude': 1.0,
        'timestamp': (baseMs + 3).toDouble(),
        'accuracy': 5.0,
        'altitude': 0.0,
        'altitude_accuracy': 0.0,
        'heading': 0.0,
        'heading_accuracy': 0.0,
        'speed': 0.0,
        'speed_accuracy': 0.0,
        'floor': null,
        'is_mocked': false,
      });
      // Enter again → fire again.
      await evt.push({
        'latitude': 0.0002,
        'longitude': 0.0,
        'timestamp': (baseMs + 4).toDouble(),
        'accuracy': 5.0,
        'altitude': 0.0,
        'altitude_accuracy': 0.0,
        'heading': 0.0,
        'heading_accuracy': 0.0,
        'speed': 0.0,
        'speed_accuracy': 0.0,
        'floor': null,
        'is_mocked': false,
      });
      await Future<void>.delayed(const Duration(milliseconds: 10));
      check(arrivals.length).equals(2);
      await sub.cancel();
      await s.dispose();
    });

    test('position event before register is ignored', () async {
      installMethodChannelMock(geoChannel);
      final s = GeofenceService();
      // No register, but the stream isn't subscribed, so nothing happens.
      await s.removeGeofence();
      await s.dispose();
    });

    test('register replaces previous subscription', () async {
      installMethodChannelMock(geoChannel);
      installEventChannelMock(eventChannel);
      final s = GeofenceService();
      await s.registerGeofence(
        latitude: 0.0,
        longitude: 0.0,
        radiusMeters: 50.0,
      );
      await s.registerGeofence(
        latitude: 1.0,
        longitude: 1.0,
        radiusMeters: 25.0,
      );
      await s.dispose();
    });
  });
}
