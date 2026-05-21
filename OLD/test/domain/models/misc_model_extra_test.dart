/// Supplemental tests covering miscellaneous model gaps:
///
/// - [EmergencyConfirmRequest] equality / hashCode / toString
/// - [ModeOverrides.copyWith] null-fallback path for distressModeId
/// - [WalkSession] JSON round-trip with an untyped-key `args` map
///   (the `args is Map` branch in `_simDescFromJson`)
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/session/emergency_confirm_request.dart';

void main() {
  group('EmergencyConfirmRequest', () {
    test('two instances with same fields are equal', () {
      const a = EmergencyConfirmRequest(number: '112', durationSeconds: 10);
      const b = EmergencyConfirmRequest(number: '112', durationSeconds: 10);
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });

    test('identical instance is equal to itself', () {
      const req = EmergencyConfirmRequest(number: '999', durationSeconds: 5);
      check(req == req).isTrue();
    });

    test('differs by number → not equal', () {
      const a = EmergencyConfirmRequest(number: '112', durationSeconds: 5);
      const b = EmergencyConfirmRequest(number: '999', durationSeconds: 5);
      check(a == b).isFalse();
    });

    test('differs by durationSeconds → not equal', () {
      const a = EmergencyConfirmRequest(number: '112', durationSeconds: 5);
      const b = EmergencyConfirmRequest(number: '112', durationSeconds: 10);
      check(a == b).isFalse();
    });

    test('cross-type equality returns false', () {
      const req = EmergencyConfirmRequest(number: '112', durationSeconds: 5);
      // ignore: unrelated_type_equality_checks
      final result = req == ('x' as Object);
      check(result).isFalse();
    });

    test('toString contains the number and duration', () {
      const req = EmergencyConfirmRequest(number: '112', durationSeconds: 8);
      check(req.toString()).contains('112');
      check(req.toString()).contains('8');
    });
  });

  group('ModeOverrides.copyWith null-fallback path', () {
    test('copyWith without providing distressModeId keeps existing value', () {
      const original = ModeOverrides(distressModeId: 'existing-id');
      final copied = original.copyWith();
      // The `?? this.distressModeId` branch must be exercised.
      check(copied.distressModeId).equals('existing-id');
    });

    test('copyWith without providing gpsLogging keeps existing', () {
      const original = ModeOverrides(
        gpsLogging: GpsLoggingConfig(enabled: false),
      );
      final copied = original.copyWith();
      check(copied.gpsLogging).equals(const GpsLoggingConfig(enabled: false));
    });

    test('copyWith without providing stealth keeps existing', () {
      const original = ModeOverrides(stealth: StealthConfig(enabled: true));
      final copied = original.copyWith();
      check(copied.stealth?.enabled).equals(true);
    });

    test('copyWith without providing eventDefaults keeps existing', () {
      const original = ModeOverrides(eventDefaults: EventDefaults());
      final copied = original.copyWith();
      check(copied.eventDefaults).isNotNull();
    });
  });

  group('WalkSession._simDescFromJson — untyped Map branch', () {
    // `_simDescFromJson` has a `args is Map` fallback branch that casts
    // untyped `Map<dynamic, dynamic>` to `Map<String, Object?>`. This
    // is reached when the `firedStepDescriptions` JSON entry holds an
    // untyped map (e.g. from an older JSON store or a different decoder).
    test('fromJson handles untyped-key args map in firedStepDescriptions', () {
      // Build a Map<dynamic, dynamic> to simulate untyped JSON.
      final untypedArgs = <dynamic, dynamic>{'flash': true, 'volume': 80};

      final sessionJson = {
        'id': 'ws-1',
        'modeId': 'mode-1',
        'isSimulation': true,
        'startedAt': DateTime.utc(2024).toIso8601String(),
        'phase': 'active',
        'firedStepDescriptions': [
          {
            'templateKey': 'simLoudAlarm',
            'args': untypedArgs, // Map<dynamic, dynamic> — the target branch
          },
        ],
      };

      final ws = WalkSession.fromJson(sessionJson);
      // The SimulationDescription must survive the untyped Map round-trip.
      check(ws.firedStepDescriptions).isNotEmpty();
      check(ws.firedStepDescriptions.first.templateKey).equals('simLoudAlarm');
      check(ws.firedStepDescriptions.first.args['flash']).equals(true);
    });

    test('fromJson with null args falls back to empty map', () {
      final sessionJson = {
        'id': 'ws-2',
        'modeId': 'mode-1',
        'isSimulation': false,
        'startedAt': DateTime.utc(2024).toIso8601String(),
        'phase': 'idle',
        'firedStepDescriptions': [
          {'templateKey': 'simTest', 'args': null},
        ],
      };

      final ws = WalkSession.fromJson(sessionJson);
      check(ws.firedStepDescriptions.first.args).isEmpty();
    });
  });
}
