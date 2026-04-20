/// Unit tests for the sealed `Trigger` hierarchy — dispatch by kind,
/// each subtype round-trip, unknown type errors.
library;

import 'package:checks/checks.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('Trigger.fromJson', () {
    test('missing kind throws', () {
      check(() => Trigger.fromJson(const <String, Object?>{}))
          .throws<ArgumentError>();
    });

    test('unknown kind throws', () {
      check(() => Trigger.fromJson(const {'kind': 'bogus'}))
          .throws<ArgumentError>();
    });

    test('dispatches distress', () {
      final json = const HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeUp,
        trigger: RepeatPressTrigger(),
      ).toJson();
      final t = Trigger.fromJson(json);
      check(t).isA<DistressTrigger>();
    });

    test('dispatches disarm', () {
      final json = const TimerDisarmTrigger(durationSeconds: 60).toJson();
      final t = Trigger.fromJson(json);
      check(t).isA<DisarmTrigger>();
    });
  });

  group('HardwareTrigger', () {
    test('RepeatPressTrigger round-trip', () {
      const t = RepeatPressTrigger(pressCount: 3, pressWindowMs: 300);
      check(HardwareTrigger.fromJson(t.toJson())).equals(t);
    });

    test('LongPressTrigger round-trip', () {
      const t = LongPressTrigger(durationSeconds: 5.0);
      check(HardwareTrigger.fromJson(t.toJson())).equals(t);
    });

    test('unknown HardwareTrigger type throws', () {
      check(() => HardwareTrigger.fromJson(const {'type': 'x'}))
          .throws<ArgumentError>();
    });

    test('missing HardwareTrigger type throws', () {
      check(() => HardwareTrigger.fromJson(const <String, Object?>{}))
          .throws<ArgumentError>();
    });

    test('RepeatPressTrigger copyWith', () {
      const t = RepeatPressTrigger();
      check(t.copyWith(pressCount: 10).pressCount).equals(10);
    });

    test('LongPressTrigger copyWith', () {
      const t = LongPressTrigger();
      check(t.copyWith(durationSeconds: 4.0).durationSeconds).equals(4.0);
    });
  });

  group('DistressTrigger', () {
    test('HardwareButtonDistressTrigger round-trip (repeat)', () {
      const t = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeDown,
        trigger: RepeatPressTrigger(pressCount: 5, pressWindowMs: 500),
      );
      check(DistressTrigger.fromJson(t.toJson())).equals(t);
    });

    test('HardwareButtonDistressTrigger round-trip (long)', () {
      const t = HardwareButtonDistressTrigger(
        buttonType: ButtonType.power,
        trigger: LongPressTrigger(durationSeconds: 2.5),
      );
      check(DistressTrigger.fromJson(t.toJson())).equals(t);
    });

    test('HardwareButtonDistressTrigger copyWith', () {
      const t = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeUp,
        trigger: RepeatPressTrigger(),
      );
      final t2 = t.copyWith(buttonType: ButtonType.power);
      check(t2.buttonType).equals(ButtonType.power);
    });

    test('unknown DistressTrigger type throws', () {
      check(() => DistressTrigger.fromJson(const {'type': 'bogus'}))
          .throws<ArgumentError>();
    });

    test('missing DistressTrigger type throws', () {
      check(() => DistressTrigger.fromJson(const <String, Object?>{}))
          .throws<ArgumentError>();
    });
  });

  group('DisarmTrigger', () {
    test('GpsArrivalDisarmTrigger round-trip', () {
      const t = GpsArrivalDisarmTrigger(
        latitude: 47.1,
        longitude: 8.2,
        radiusMeters: 50,
      );
      check(DisarmTrigger.fromJson(t.toJson())).equals(t);
    });

    test('TimerDisarmTrigger round-trip', () {
      const t = TimerDisarmTrigger(durationSeconds: 600);
      check(DisarmTrigger.fromJson(t.toJson())).equals(t);
    });

    test('WrongPinThresholdDisarmTrigger round-trip', () {
      const t = WrongPinThresholdDisarmTrigger(threshold: 3);
      check(DisarmTrigger.fromJson(t.toJson())).equals(t);
    });

    test('unknown DisarmTrigger type throws', () {
      check(() => DisarmTrigger.fromJson(const {'type': 'bogus'}))
          .throws<ArgumentError>();
    });

    test('GpsArrivalDisarmTrigger defaults radius to 100', () {
      const t = GpsArrivalDisarmTrigger(latitude: 0, longitude: 0);
      check(t.radiusMeters).equals(100);
    });

    test('GpsArrivalDisarmTrigger copyWith', () {
      const t = GpsArrivalDisarmTrigger(latitude: 0, longitude: 0);
      final t2 = t.copyWith(radiusMeters: 200);
      check(t2.radiusMeters).equals(200);
    });

    test('TimerDisarmTrigger copyWith', () {
      const t = TimerDisarmTrigger(durationSeconds: 1);
      check(t.copyWith(durationSeconds: 10).durationSeconds).equals(10);
    });

    test('WrongPinThresholdDisarmTrigger defaults to 5', () {
      const t = WrongPinThresholdDisarmTrigger();
      check(t.threshold).equals(5);
    });

    test('WrongPinThresholdDisarmTrigger copyWith', () {
      const t = WrongPinThresholdDisarmTrigger();
      check(t.copyWith(threshold: 3).threshold).equals(3);
    });
  });
}
