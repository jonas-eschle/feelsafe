/// Unit tests for `TrackingPoint` — JSON round-trip, equality,
/// optional fields, and the maps URL helper.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/models/tracking_point.dart';

void main() {
  group('TrackingPoint', () {
    test('required fields & null optionals', () {
      final ts = DateTime.utc(2026, 4, 29, 12, 0, 0);
      final p = TrackingPoint(
        timestamp: ts,
        latitude: 47.0,
        longitude: 8.0,
      );
      check(p.timestamp).equals(ts);
      check(p.latitude).equals(47.0);
      check(p.longitude).equals(8.0);
      check(p.accuracy).isNull();
      check(p.altitude).isNull();
      check(p.speed).isNull();
    });

    test('all fields populated', () {
      final p = TrackingPoint(
        timestamp: DateTime.utc(2026, 1, 1),
        latitude: 47.5,
        longitude: 8.5,
        accuracy: 12.3,
        altitude: 450.0,
        speed: 1.5,
      );
      check(p.accuracy).equals(12.3);
      check(p.altitude).equals(450.0);
      check(p.speed).equals(1.5);
    });

    test('JSON round-trip (minimal)', () {
      final p = TrackingPoint(
        timestamp: DateTime.utc(2026, 4, 29, 8),
        latitude: 0.0,
        longitude: 0.0,
      );
      check(TrackingPoint.fromJson(p.toJson())).equals(p);
    });

    test('JSON round-trip (all optional fields)', () {
      final p = TrackingPoint(
        timestamp: DateTime.utc(2026, 4, 29, 8, 15, 30),
        latitude: -33.86,
        longitude: 151.21,
        accuracy: 7.5,
        altitude: 12.0,
        speed: 0.4,
      );
      check(TrackingPoint.fromJson(p.toJson())).equals(p);
    });

    test('toJson produces ISO 8601 timestamp', () {
      final p = TrackingPoint(
        timestamp: DateTime.utc(2026, 4, 29, 8, 15, 30),
        latitude: 47,
        longitude: 8,
      );
      final json = p.toJson();
      check(json['timestamp']).equals('2026-04-29T08:15:30.000Z');
    });

    test('toMapsUrl produces expected URL', () {
      final p = TrackingPoint(
        timestamp: DateTime.utc(2026, 1, 1),
        latitude: 47.123456,
        longitude: 8.987654,
      );
      check(p.toMapsUrl()).equals('https://maps.google.com/?q=47.123456,8.987654');
    });

    test('copyWith replaces a single field', () {
      final p = TrackingPoint(
        timestamp: DateTime.utc(2026, 1, 1),
        latitude: 47,
        longitude: 8,
      );
      final p2 = p.copyWith(accuracy: 10.0);
      check(p2.accuracy).equals(10.0);
      check(p2.timestamp).equals(p.timestamp);
      check(p2.latitude).equals(47.0);
    });

    test('equality and hashCode', () {
      final ts = DateTime.utc(2026, 1, 1);
      final a = TrackingPoint(timestamp: ts, latitude: 47, longitude: 8);
      final b = TrackingPoint(timestamp: ts, latitude: 47, longitude: 8);
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });

    test('inequality on differing fields', () {
      final ts = DateTime.utc(2026, 1, 1);
      final a = TrackingPoint(timestamp: ts, latitude: 47, longitude: 8);
      final b = a.copyWith(latitude: 48);
      check(a).not((it) => it.equals(b));
    });

    test('toString contains coordinates and timestamp', () {
      final p = TrackingPoint(
        timestamp: DateTime.utc(2026, 4, 29),
        latitude: 47.0,
        longitude: 8.0,
      );
      final s = p.toString();
      check(s).contains('47.0');
      check(s).contains('8.0');
      check(s).contains('2026-04-29');
    });
  });
}
