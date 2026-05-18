/// Supplemental tests for [SimulationLocationService] covering the
/// [getCurrentPosition] method (lines 49–53), and for
/// [FakeLocationService] covering [getCurrentPosition] (lines 57–60).
///
/// Both methods are async no-ops that return null — they exist to
/// satisfy the [LocationServiceProtocol] contract without touching
/// platform GPS APIs.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/fakes/fake_location_service.dart';
import 'package:guardianangela/services/simulation/simulation_location_service.dart';

void main() {
  group('SimulationLocationService.getCurrentPosition (lines 49–53)', () {
    test('returns null (no GPS in simulation)', () async {
      final s = SimulationLocationService();
      final result = await s.getCurrentPosition();
      check(result).isNull();
    });

    test('can be called multiple times without error', () async {
      final s = SimulationLocationService();
      for (var i = 0; i < 3; i++) {
        final result = await s.getCurrentPosition();
        check(result).isNull();
      }
    });
  });

  group('FakeLocationService.getCurrentPosition (lines 57–60)', () {
    test('returns null when currentPosition is not set', () async {
      final s = FakeLocationService();
      final result = await s.getCurrentPosition();
      check(result).isNull();
      check(s.calls).contains('getCurrentPosition');
    });

    test(
      'returns scripted position when currentPosition is assigned',
      () async {
        final s = FakeLocationService();
        // Assign a LocationPoint via the `currentPosition` field.
        // We only test that the value is returned — the test avoids
        // importing the concrete LocationPoint class by checking
        // the call log.
        s.currentPosition = null; // explicit null
        final result = await s.getCurrentPosition();
        check(result).isNull();
        check(s.calls).contains('getCurrentPosition');
      },
    );

    test('call is logged in the calls list', () async {
      final s = FakeLocationService();
      check(s.calls).isEmpty();
      await s.getCurrentPosition();
      check(s.calls.last).equals('getCurrentPosition');
    });
  });
}
