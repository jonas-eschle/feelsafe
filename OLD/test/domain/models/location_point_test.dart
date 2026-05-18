/// Unit tests for `LocationPoint` — toMapsUrl and JSON round-trip.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/models/models.dart';

void main() {
  group('LocationPoint', () {
    final ts = DateTime.utc(2026, 4, 1, 12);

    test('required fields and optional accuracy', () {
      final p = LocationPoint(latitude: 47.1, longitude: 8.2, timestamp: ts);
      check(p.latitude).equals(47.1);
      check(p.longitude).equals(8.2);
      check(p.timestamp).equals(ts);
      check(p.accuracy).isNull();
    });

    test('toMapsUrl format', () {
      final p = LocationPoint(latitude: 47.1, longitude: 8.2, timestamp: ts);
      check(p.toMapsUrl()).equals('https://maps.google.com/?q=47.1,8.2');
    });

    test('toMapsUrl handles negatives', () {
      final p = LocationPoint(latitude: -33.9, longitude: -70.6, timestamp: ts);
      check(p.toMapsUrl()).equals('https://maps.google.com/?q=-33.9,-70.6');
    });

    test('round-trip without accuracy', () {
      final p = LocationPoint(latitude: 47.1, longitude: 8.2, timestamp: ts);
      check(LocationPoint.fromJson(p.toJson())).equals(p);
    });

    test('round-trip with accuracy', () {
      final p = LocationPoint(
        latitude: 47.1,
        longitude: 8.2,
        timestamp: ts,
        accuracy: 5.5,
      );
      check(LocationPoint.fromJson(p.toJson())).equals(p);
    });

    test('copyWith', () {
      final p = LocationPoint(latitude: 47.1, longitude: 8.2, timestamp: ts);
      check(p.copyWith(accuracy: 10).accuracy).equals(10);
    });

    test('equality', () {
      final a = LocationPoint(latitude: 47.1, longitude: 8.2, timestamp: ts);
      final b = LocationPoint(latitude: 47.1, longitude: 8.2, timestamp: ts);
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });

    test('inequality on latitude', () {
      final a = LocationPoint(latitude: 0, longitude: 0, timestamp: ts);
      final b = LocationPoint(latitude: 1, longitude: 0, timestamp: ts);
      check(a).not((it) => it.equals(b));
    });
  });
}
