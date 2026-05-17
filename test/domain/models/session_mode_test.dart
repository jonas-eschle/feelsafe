/// Unit tests for `SessionMode` — fields, copyWith, JSON round-trip
/// including triggers and overrides, equality.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/models/models.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('SessionMode', () {
    test('required fields & defaults', () {
      final m = makeMode();
      check(m.id).isNotNull();
      check(m.name).equals('Test');
      check(m.distressModeId).isNull();
      check(m.distressTriggers).isEmpty();
      check(m.disarmTriggers).isEmpty();
      check(m.overrides).isNull();
      // Spec 11 §DE-3 defaults.
      check(m.trackingEnabled).isFalse();
      check(m.trackingIntervalSeconds).equals(300);
      check(m.trackingBufferSize).equals(50);
    });

    test('copyWith replaces one field', () {
      final m = makeMode(name: 'A');
      final m2 = m.copyWith(name: 'B');
      check(m2.name).equals('B');
      check(m2.id).equals(m.id);
    });

    test('copyWith replaces distressModeId', () {
      final m = makeMode();
      final m2 = m.copyWith(distressModeId: 'dc1');
      check(m2.distressModeId).equals('dc1');
    });

    test('JSON round-trip (minimal)', () {
      final m = makeMode();
      check(SessionMode.fromJson(m.toJson())).equals(m);
    });

    test('JSON round-trip with full chain', () {
      final m = makeMode(
        steps: [holdStep(order: 0), smsStep(order: 1), fakeCallStep(order: 2)],
      );
      check(SessionMode.fromJson(m.toJson())).equals(m);
    });

    test('JSON round-trip with distress triggers', () {
      final m = makeMode().copyWith(
        distressTriggers: const [
          HardwareButtonDistressTrigger(
            buttonType: ButtonType.volumeUp,
            trigger: RepeatPressTrigger(pressCount: 5, pressWindowMs: 500),
          ),
        ],
      );
      check(SessionMode.fromJson(m.toJson())).equals(m);
    });

    test('JSON round-trip with disarm triggers', () {
      final m = makeMode().copyWith(
        disarmTriggers: const [
          TimerDisarmTrigger(durationSeconds: 3600),
          GpsArrivalDisarmTrigger(
            latitude: 47.0,
            longitude: 8.0,
            radiusMeters: 50,
          ),
          // Q9: WrongPinThresholdDisarmTrigger was deleted; threshold
          // lives on AppSettings.wrongPinThreshold instead.
        ],
      );
      check(SessionMode.fromJson(m.toJson())).equals(m);
    });

    test('JSON round-trip with ModeOverrides', () {
      final m = makeMode().copyWith(
        overrides: const ModeOverrides(
          distressModeId: 'dc-other',
          gpsLogging: GpsLoggingConfig(enabled: false),
        ),
      );
      check(SessionMode.fromJson(m.toJson())).equals(m);
    });

    test('JSON round-trip with empty fields', () {
      const m = SessionMode(id: 'm1', name: 'X');
      check(SessionMode.fromJson(m.toJson())).equals(m);
    });

    test('equality', () {
      final a = makeMode();
      final b = makeMode();
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });

    test('inequality when name differs', () {
      check(makeMode(name: 'A')).not((it) => it.equals(makeMode(name: 'B')));
    });

    test('inequality when chainSteps differ', () {
      check(
        makeMode(steps: [holdStep()]),
      ).not((it) => it.equals(makeMode(steps: [holdStep(), smsStep()])));
    });

    test('toString contains id and name', () {
      final m = makeMode();
      final str = m.toString();
      check(str).contains(m.id);
      check(str).contains(m.name);
    });

    test('mode with all trigger types round-trips', () {
      final m = makeMode().copyWith(
        distressTriggers: const [
          HardwareButtonDistressTrigger(
            buttonType: ButtonType.volumeUp,
            trigger: LongPressTrigger(durationSeconds: 3.0),
          ),
        ],
        disarmTriggers: const [TimerDisarmTrigger(durationSeconds: 100)],
      );
      check(SessionMode.fromJson(m.toJson())).equals(m);
    });

    test('JSON round-trip with tracking fields (DE-3)', () {
      final m = makeMode().copyWith(
        trackingEnabled: true,
        trackingIntervalSeconds: 60,
        trackingBufferSize: 100,
      );
      check(SessionMode.fromJson(m.toJson())).equals(m);
    });

    test('copyWith replaces tracking fields independently', () {
      final m = makeMode();
      final m2 = m.copyWith(trackingEnabled: true);
      check(m2.trackingEnabled).isTrue();
      check(m2.trackingIntervalSeconds).equals(m.trackingIntervalSeconds);
      check(m2.trackingBufferSize).equals(m.trackingBufferSize);

      final m3 = m.copyWith(trackingIntervalSeconds: 30);
      check(m3.trackingIntervalSeconds).equals(30);
      check(m3.trackingEnabled).equals(m.trackingEnabled);

      final m4 = m.copyWith(trackingBufferSize: 25);
      check(m4.trackingBufferSize).equals(25);
    });

    test('inequality when tracking fields differ', () {
      final a = makeMode();
      check(a).not(
        (it) => it.equals(a.copyWith(trackingEnabled: true)),
      );
      check(a).not(
        (it) => it.equals(a.copyWith(trackingIntervalSeconds: 600)),
      );
      check(a).not(
        (it) => it.equals(a.copyWith(trackingBufferSize: 75)),
      );
    });

    test('fromJson defaults missing tracking fields', () {
      final json = {
        'id': 'm1',
        'name': 'X',
      };
      final m = SessionMode.fromJson(json);
      check(m.trackingEnabled).isFalse();
      check(m.trackingIntervalSeconds).equals(300);
      check(m.trackingBufferSize).equals(50);
    });

    test('iconName defaults to null', () {
      final m = makeMode();
      check(m.iconName).isNull();
    });

    test('JSON round-trip preserves iconName', () {
      final m = makeMode().copyWith(iconName: 'directions_walk');
      check(SessionMode.fromJson(m.toJson())).equals(m);
      check(SessionMode.fromJson(m.toJson()).iconName)
          .equals('directions_walk');
    });

    test('copyWith clearIconName resets the icon to null', () {
      final m = makeMode().copyWith(iconName: 'shield');
      check(m.iconName).equals('shield');
      check(m.copyWith(clearIconName: true).iconName).isNull();
    });

    test('inequality when iconName differs', () {
      final a = makeMode();
      check(a).not(
        (it) => it.equals(a.copyWith(iconName: 'fitness_center')),
      );
    });

    test('isDistressMode defaults to false', () {
      final m = makeMode();
      check(m.isDistressMode).isFalse();
    });

    test('JSON round-trip preserves isDistressMode', () {
      final m = makeMode().copyWith(isDistressMode: true);
      check(SessionMode.fromJson(m.toJson())).equals(m);
      check(SessionMode.fromJson(m.toJson()).isDistressMode).isTrue();
    });

    test('fromJson defaults missing isDistressMode to false', () {
      final json = {
        'id': 'm1',
        'name': 'X',
      };
      check(SessionMode.fromJson(json).isDistressMode).isFalse();
    });

    test('inequality when isDistressMode differs', () {
      final a = makeMode();
      check(a).not(
        (it) => it.equals(a.copyWith(isDistressMode: true)),
      );
    });
  });
}
