/// Unit tests for [LocationResolver].
///
/// Exercises every branch of `resolve()` (logGpsEnabled guard,
/// tracking-buffer priority, live-service fallback, "unavailable")
/// and every path in the private `_formatAge` helper.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/engine/tracking_buffer.dart';
import 'package:guardianangela/domain/models/tracking_point.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/location_resolver.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/services/fakes/fake_audio_service.dart';
import 'package:guardianangela/services/fakes/fake_location_service.dart';
import 'package:guardianangela/services/fakes/fake_messaging_service.dart';
import 'package:guardianangela/services/fakes/fake_notification_service.dart';
import 'package:guardianangela/services/fakes/fake_phone_service.dart';
import 'package:guardianangela/services/fakes/fake_vibration_service.dart';
import 'package:guardianangela/domain/models/location_point.dart';

/// Builds an [EventServices] bundle with optional [location] and
/// optional [buffer].
EventServices _services({
  FakeLocationService? location,
  TrackingBuffer? buffer,
}) => EventServices(
  audio: FakeAudioService(),
  messaging: FakeMessagingService(),
  phone: FakePhoneService(),
  notification: FakeNotificationService(),
  vibration: FakeVibrationService(),
  context: const SessionContext(),
  isCancelled: () => false,
  location: location,
  trackingBuffer: buffer,
);

TrackingPoint _point({
  double lat = 47.0,
  double lon = 8.0,
  double? accuracy,
  Duration age = Duration.zero,
}) {
  final now = DateTime.utc(2024, 1, 1, 12);
  return TrackingPoint(
    timestamp: now.subtract(age),
    latitude: lat,
    longitude: lon,
    accuracy: accuracy,
  );
}

DateTime Function() _clock({Duration offset = Duration.zero}) {
  final base = DateTime.utc(2024, 1, 1, 12);
  return () => base.add(offset);
}

void main() {
  group('LocationResolver.resolve', () {
    test('returns "Location unavailable" when logGpsEnabled is false', () {
      final svc = _services(
        location: FakeLocationService()..injectPoint(
          LocationPoint(
            latitude: 47.0,
            longitude: 8.0,
            timestamp: DateTime.utc(2024),
          ),
        ),
      );
      final result = LocationResolver.resolve(svc, logGpsEnabled: false);
      check(result).equals('Location unavailable');
    });

    test('prefers tracking buffer over live location when buffer has a point',
        () {
      final buf = TrackingBuffer();
      final pt = _point(lat: 47.0, lon: 8.0, accuracy: 15);
      buf.add(pt);
      final loc = FakeLocationService();
      final svc = _services(location: loc, buffer: buf);

      final result = LocationResolver.resolve(
        svc,
        now: _clock(),
      );
      // Should contain the Google Maps URL for the tracking buffer point.
      check(result).contains('maps.google.com');
      check(result).contains('47.0');
      // Live location was NOT consulted.
      check(loc.calls).not((it) => it.contains('getLastLocationUrl'));
    });

    test('falls through to live location when buffer is empty', () {
      final buf = TrackingBuffer(); // empty
      final loc = FakeLocationService();
      loc.injectPoint(
        LocationPoint(
          latitude: 48.0,
          longitude: 9.0,
          timestamp: DateTime.utc(2024),
        ),
      );
      final svc = _services(location: loc, buffer: buf);

      final result = LocationResolver.resolve(svc, now: _clock());
      check(result).contains('48.0');
      check(loc.calls).contains('getLastLocationUrl');
    });

    test('falls through to "Location unavailable" when all sources empty',
        () {
      final svc = _services();
      check(LocationResolver.resolve(svc)).equals('Location unavailable');
    });

    test('falls through to live when buffer is null', () {
      final loc = FakeLocationService();
      loc.injectPoint(
        LocationPoint(
          latitude: 51.5,
          longitude: -0.1,
          timestamp: DateTime.utc(2024),
        ),
      );
      final svc = _services(location: loc); // no buffer
      final result = LocationResolver.resolve(svc, now: _clock());
      check(result).contains('51.5');
    });

    test('falls through to unavailable when location is null', () {
      final svc = _services(); // no location, no buffer
      check(LocationResolver.resolve(svc)).equals('Location unavailable');
    });

    test('falls through to unavailable when live location returns null', () {
      // FakeLocationService with empty history returns null.
      final loc = FakeLocationService(); // no points injected
      final svc = _services(location: loc);
      check(LocationResolver.resolve(svc)).equals('Location unavailable');
    });

    // ---------- age annotation tests ----------------------------------------

    test('annotation includes accuracy and "just now" for zero age', () {
      final buf = TrackingBuffer();
      buf.add(_point(accuracy: 10));
      final svc = _services(buffer: buf);
      // same clock as the point's timestamp → age = 0
      final result = LocationResolver.resolve(svc, now: _clock());
      check(result).contains('±10m');
      check(result).contains('just now');
    });

    test('annotation shows "N sec ago" for seconds age', () {
      final buf = TrackingBuffer();
      buf.add(_point(accuracy: 5, age: const Duration(seconds: 30)));
      final svc = _services(buffer: buf);
      final result = LocationResolver.resolve(svc, now: _clock());
      check(result).contains('30 sec ago');
    });

    test('annotation shows "N min ago" for minutes age', () {
      final buf = TrackingBuffer();
      buf.add(_point(age: const Duration(minutes: 3)));
      final svc = _services(buffer: buf);
      final result = LocationResolver.resolve(svc, now: _clock());
      check(result).contains('3 min ago');
    });

    test('annotation shows "N h ago" for hours age', () {
      final buf = TrackingBuffer();
      buf.add(_point(age: const Duration(hours: 2)));
      final svc = _services(buffer: buf);
      final result = LocationResolver.resolve(svc, now: _clock());
      check(result).contains('2 h ago');
    });

    test('annotation shows "N d ago" for days age', () {
      final buf = TrackingBuffer();
      buf.add(_point(age: const Duration(days: 3)));
      final svc = _services(buffer: buf);
      final result = LocationResolver.resolve(svc, now: _clock());
      check(result).contains('3 d ago');
    });

    test('annotation omits accuracy part when accuracy is null', () {
      final buf = TrackingBuffer();
      buf.add(_point(accuracy: null)); // no accuracy
      final svc = _services(buffer: buf);
      final result = LocationResolver.resolve(svc, now: _clock());
      // Should not contain '±' prefix.
      check(result.contains('±')).isFalse();
      // Should still have age annotation.
      check(result).contains('just now');
    });

    test('annotation clamps negative age to "just now"', () {
      // Point in the future (clock skew) → negative age → just now.
      final buf = TrackingBuffer();
      // Point timestamp is 5 minutes in the future relative to now.
      final futurePoint = TrackingPoint(
        timestamp: DateTime.utc(2024, 1, 1, 12, 5), // 5 min ahead of _clock()
        latitude: 47.0,
        longitude: 8.0,
      );
      buf.add(futurePoint);
      final svc = _services(buffer: buf);
      final result = LocationResolver.resolve(svc, now: _clock());
      check(result).contains('just now');
    });
  });
}
