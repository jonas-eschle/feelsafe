/// Unit tests for the sealed `Trigger` hierarchy — dispatch by kind,
/// each subtype round-trip, unknown type errors.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/models/models.dart';

void main() {
  group('Trigger.fromJson', () {
    test('missing kind throws', () {
      check(
        () => Trigger.fromJson(const <String, Object?>{}),
      ).throws<ArgumentError>();
    });

    test('unknown kind throws', () {
      check(
        () => Trigger.fromJson(const {'kind': 'bogus'}),
      ).throws<ArgumentError>();
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
      check(
        () => HardwareTrigger.fromJson(const {'type': 'x'}),
      ).throws<ArgumentError>();
    });

    test('missing HardwareTrigger type throws', () {
      check(
        () => HardwareTrigger.fromJson(const <String, Object?>{}),
      ).throws<ArgumentError>();
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
      check(
        () => DistressTrigger.fromJson(const {'type': 'bogus'}),
      ).throws<ArgumentError>();
    });

    test('missing DistressTrigger type throws', () {
      check(
        () => DistressTrigger.fromJson(const <String, Object?>{}),
      ).throws<ArgumentError>();
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

    test('legacy wrongPinThreshold tag is rejected', () {
      // Q9: WrongPinThresholdDisarmTrigger was deleted; the
      // threshold lives on AppSettings.wrongPinThreshold now.
      check(
        () => DisarmTrigger.fromJson(const {
          'type': 'wrongPinThreshold',
          'threshold': 3,
        }),
      ).throws<ArgumentError>();
    });

    test('unknown DisarmTrigger type throws', () {
      check(
        () => DisarmTrigger.fromJson(const {'type': 'bogus'}),
      ).throws<ArgumentError>();
    });

    test('missing DisarmTrigger type throws', () {
      check(
        () => DisarmTrigger.fromJson(const <String, Object?>{}),
      ).throws<ArgumentError>();
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

    test('null copyWith preserves fields across subtypes', () {
      const r = RepeatPressTrigger(pressCount: 7, pressWindowMs: 123);
      check(r.copyWith()).equals(r);
      const l = LongPressTrigger(durationSeconds: 3.5);
      check(l.copyWith()).equals(l);
      const h = HardwareButtonDistressTrigger(
        buttonType: ButtonType.power,
        trigger: LongPressTrigger(durationSeconds: 2.0),
      );
      check(h.copyWith()).equals(h);
      const g = GpsArrivalDisarmTrigger(
        latitude: 1,
        longitude: 2,
        radiusMeters: 30,
      );
      check(g.copyWith()).equals(g);
      const tt = TimerDisarmTrigger(durationSeconds: 42);
      check(tt.copyWith()).equals(tt);
    });
  });

  group('HardwareTrigger equality / hashCode / toString', () {
    test('RepeatPressTrigger identical equals', () {
      const t = RepeatPressTrigger();
      check(t == t).isTrue();
    });

    test('RepeatPressTrigger cross-type unequal', () {
      // ignore: unrelated_type_equality_checks
      check(const RepeatPressTrigger() == 'x').isFalse();
    });

    test('RepeatPressTrigger equal values equal', () {
      check(
        const RepeatPressTrigger(pressCount: 3, pressWindowMs: 400),
      ).equals(const RepeatPressTrigger(pressCount: 3, pressWindowMs: 400));
      check(
        const RepeatPressTrigger(pressCount: 3).hashCode,
      ).equals(const RepeatPressTrigger(pressCount: 3).hashCode);
    });

    test('RepeatPressTrigger differ pressCount unequal', () {
      check(
        const RepeatPressTrigger(pressCount: 3) ==
            const RepeatPressTrigger(pressCount: 4),
      ).isFalse();
    });

    test('RepeatPressTrigger differ pressWindowMs unequal', () {
      check(
        const RepeatPressTrigger(pressWindowMs: 200) ==
            const RepeatPressTrigger(pressWindowMs: 400),
      ).isFalse();
    });

    test('RepeatPressTrigger toString', () {
      final str = const RepeatPressTrigger(
        pressCount: 3,
        pressWindowMs: 400,
      ).toString();
      check(str).contains('3');
      check(str).contains('400');
    });

    test('LongPressTrigger identical equals', () {
      const t = LongPressTrigger();
      check(t == t).isTrue();
    });

    test('LongPressTrigger cross-type unequal', () {
      // ignore: unrelated_type_equality_checks
      check(const LongPressTrigger() == 'x').isFalse();
    });

    test('LongPressTrigger equal values equal', () {
      check(
        const LongPressTrigger(durationSeconds: 3.0),
      ).equals(const LongPressTrigger(durationSeconds: 3.0));
      check(
        const LongPressTrigger(durationSeconds: 3.0).hashCode,
      ).equals(const LongPressTrigger(durationSeconds: 3.0).hashCode);
    });

    test('LongPressTrigger differ duration unequal', () {
      check(
        const LongPressTrigger(durationSeconds: 1.0) ==
            const LongPressTrigger(durationSeconds: 2.0),
      ).isFalse();
    });

    test('LongPressTrigger toString', () {
      final str = const LongPressTrigger(durationSeconds: 4.5).toString();
      check(str).contains('4.5');
    });
  });

  group('HardwareButtonDistressTrigger equality / toString', () {
    test('identical equals', () {
      const t = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeUp,
        trigger: RepeatPressTrigger(),
      );
      check(t == t).isTrue();
    });

    test('cross-type unequal', () {
      const t = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeUp,
        trigger: RepeatPressTrigger(),
      );
      // ignore: unrelated_type_equality_checks
      check(t == 'x').isFalse();
    });

    test('differ buttonType unequal', () {
      const a = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeUp,
        trigger: RepeatPressTrigger(),
      );
      const b = HardwareButtonDistressTrigger(
        buttonType: ButtonType.power,
        trigger: RepeatPressTrigger(),
      );
      check(a == b).isFalse();
    });

    test('differ trigger unequal', () {
      const a = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeUp,
        trigger: RepeatPressTrigger(),
      );
      const b = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeUp,
        trigger: LongPressTrigger(),
      );
      check(a == b).isFalse();
    });

    test('hashCode stable for equal', () {
      const a = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeUp,
        trigger: RepeatPressTrigger(),
      );
      const b = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeUp,
        trigger: RepeatPressTrigger(),
      );
      check(a.hashCode).equals(b.hashCode);
    });

    test('toString includes parts', () {
      const t = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeUp,
        trigger: RepeatPressTrigger(),
      );
      final str = t.toString();
      check(str).contains('volumeUp');
    });
  });

  group('DisarmTrigger equality / toString', () {
    test('GpsArrivalDisarmTrigger identical equals', () {
      const t = GpsArrivalDisarmTrigger(latitude: 0, longitude: 0);
      check(t == t).isTrue();
    });

    test('GpsArrivalDisarmTrigger cross-type unequal', () {
      const t = GpsArrivalDisarmTrigger(latitude: 0, longitude: 0);
      // ignore: unrelated_type_equality_checks
      check(t == 'x').isFalse();
    });

    test('GpsArrivalDisarmTrigger differ lat unequal', () {
      check(
        const GpsArrivalDisarmTrigger(latitude: 1, longitude: 0) ==
            const GpsArrivalDisarmTrigger(latitude: 2, longitude: 0),
      ).isFalse();
    });

    test('GpsArrivalDisarmTrigger differ lon unequal', () {
      check(
        const GpsArrivalDisarmTrigger(latitude: 0, longitude: 1) ==
            const GpsArrivalDisarmTrigger(latitude: 0, longitude: 2),
      ).isFalse();
    });

    test('GpsArrivalDisarmTrigger differ radius unequal', () {
      check(
        const GpsArrivalDisarmTrigger(
              latitude: 0,
              longitude: 0,
              radiusMeters: 50,
            ) ==
            const GpsArrivalDisarmTrigger(
              latitude: 0,
              longitude: 0,
              radiusMeters: 100,
            ),
      ).isFalse();
    });

    test('GpsArrivalDisarmTrigger hashCode stable', () {
      check(
        const GpsArrivalDisarmTrigger(latitude: 47.1, longitude: 8.2).hashCode,
      ).equals(
        const GpsArrivalDisarmTrigger(latitude: 47.1, longitude: 8.2).hashCode,
      );
    });

    test('GpsArrivalDisarmTrigger toString', () {
      final str = const GpsArrivalDisarmTrigger(
        latitude: 47.1,
        longitude: 8.2,
        radiusMeters: 50,
      ).toString();
      check(str).contains('47.1');
      check(str).contains('8.2');
      check(str).contains('50');
    });

    test('TimerDisarmTrigger identical equals', () {
      const t = TimerDisarmTrigger(durationSeconds: 10);
      check(t == t).isTrue();
    });

    test('TimerDisarmTrigger cross-type unequal', () {
      // ignore: unrelated_type_equality_checks
      check(const TimerDisarmTrigger(durationSeconds: 1) == 'x').isFalse();
    });

    test('TimerDisarmTrigger differ unequal', () {
      check(
        const TimerDisarmTrigger(durationSeconds: 10) ==
            const TimerDisarmTrigger(durationSeconds: 20),
      ).isFalse();
    });

    test('TimerDisarmTrigger hashCode stable', () {
      check(
        const TimerDisarmTrigger(durationSeconds: 5).hashCode,
      ).equals(const TimerDisarmTrigger(durationSeconds: 5).hashCode);
    });

    test('TimerDisarmTrigger toString', () {
      check(
        const TimerDisarmTrigger(durationSeconds: 30).toString(),
      ).contains('30');
    });

    // Q9: WrongPinThresholdDisarmTrigger was deleted. Threshold
    // lives on AppSettings.wrongPinThreshold now; the legacy class
    // is no longer present so its tests are removed.
  });

  group('ButtonType JSON dispatch', () {
    test('volumeDown round-trips through HardwareButtonDistressTrigger', () {
      const t = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeDown,
        trigger: RepeatPressTrigger(),
      );
      check(DistressTrigger.fromJson(t.toJson())).equals(t);
    });

    test('power round-trips through HardwareButtonDistressTrigger', () {
      const t = HardwareButtonDistressTrigger(
        buttonType: ButtonType.power,
        trigger: LongPressTrigger(),
      );
      check(DistressTrigger.fromJson(t.toJson())).equals(t);
    });

    test('unknown buttonType throws', () {
      check(
        () => HardwareButtonDistressTrigger.fromJson(const {
          'kind': 'distress',
          'type': 'hardwareButton',
          'buttonType': 'bogus',
          'trigger': {'type': 'repeatPress'},
        }),
      ).throws<ArgumentError>();
    });
  });

  group('Trigger.fromJson cross-dispatch', () {
    test('distress hardware round-trips via Trigger.fromJson', () {
      const t = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeUp,
        trigger: RepeatPressTrigger(),
      );
      check(Trigger.fromJson(t.toJson())).equals(t);
    });

    test('disarm gps round-trips via Trigger.fromJson', () {
      const t = GpsArrivalDisarmTrigger(latitude: 1, longitude: 2);
      check(Trigger.fromJson(t.toJson())).equals(t);
    });

    test('disarm timer round-trips via Trigger.fromJson', () {
      const t = TimerDisarmTrigger(durationSeconds: 42);
      check(Trigger.fromJson(t.toJson())).equals(t);
    });

    test('disarm wrongPin tag is rejected via Trigger.fromJson', () {
      // Q9: WrongPinThresholdDisarmTrigger was deleted. A persisted
      // legacy tag must throw rather than silently round-trip.
      check(
        () => Trigger.fromJson(const {
          'kind': 'disarm',
          'type': 'wrongPinThreshold',
          'threshold': 3,
        }),
      ).throws<ArgumentError>();
    });
  });
}
