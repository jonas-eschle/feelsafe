/// Coverage tests for [LocationPoint] — targets the `copyWith` `accuracy`
/// branch (line 52) that was previously uncovered.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/models/location_point.dart';

void main() {
  final basePoint = LocationPoint(
    latitude: 48.8566,
    longitude: 2.3522,
    timestamp: DateTime.utc(2025, 1, 1),
    accuracy: 5.0,
  );

  group('LocationPoint.copyWith accuracy branch', () {
    test('copyWith with new accuracy replaces accuracy', () {
      final updated = basePoint.copyWith(accuracy: 10.0);
      check(updated.accuracy).equals(10.0);
      check(updated.latitude).equals(basePoint.latitude);
    });

    test('copyWith with all fields replaced', () {
      final ts = DateTime.utc(2025, 6, 1);
      final updated = basePoint.copyWith(
        latitude: 51.5,
        longitude: -0.12,
        timestamp: ts,
        accuracy: 3.0,
      );
      check(updated.latitude).equals(51.5);
      check(updated.longitude).equals(-0.12);
      check(updated.timestamp).equals(ts);
      check(updated.accuracy).equals(3.0);
    });

    test('copyWith with null accuracy preserves original accuracy', () {
      final updated = basePoint.copyWith(latitude: 10.0);
      check(updated.accuracy).equals(basePoint.accuracy);
    });
  });
}
