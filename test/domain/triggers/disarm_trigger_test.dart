/// Unit tests for [DisarmTrigger] sealed hierarchy per spec 03 §DisarmTrigger.
///
/// Covers default values for [GpsArrivalDisarmTrigger] (radius=200,
/// source=promptAtStart), [TimerDisarmTrigger] required `durationSeconds`,
/// `type` discriminator on JSON (`gps_arrival` / `timer`),
/// `DisarmTrigger.fromJson` dispatch, equality + hashCode for both
/// subclasses, and JSON round-trip preserving both shapes.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/gps_destination_source.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';

void main() {
  group('GpsArrivalDisarmTrigger — defaults match spec 03 §DisarmTrigger', () {
    test('default radiusMeters is 200', () {
      const trigger = GpsArrivalDisarmTrigger();
      check(trigger.radiusMeters).equals(200);
    });

    test('default destinationSource is GpsDestinationSource.promptAtStart', () {
      const trigger = GpsArrivalDisarmTrigger();
      check(
        trigger.destinationSource,
      ).equals(GpsDestinationSource.promptAtStart);
    });

    test('default lat is null (no coordinate stored on the trigger)', () {
      const trigger = GpsArrivalDisarmTrigger();
      check(trigger.lat).isNull();
    });

    test('default lng is null (no coordinate stored on the trigger)', () {
      const trigger = GpsArrivalDisarmTrigger();
      check(trigger.lng).isNull();
    });
  });

  group('GpsArrivalDisarmTrigger — toJson discriminator and fields', () {
    test('toJson includes type=gps_arrival discriminator', () {
      const trigger = GpsArrivalDisarmTrigger();
      final json = trigger.toJson();
      check(json['type']).equals('gps_arrival');
    });

    test('toJson encodes radiusMeters as an int', () {
      const trigger = GpsArrivalDisarmTrigger(radiusMeters: 500);
      final json = trigger.toJson();
      check(json['radiusMeters']).equals(500);
    });

    test('toJson encodes destinationSource as enum name', () {
      const trigger = GpsArrivalDisarmTrigger(
        destinationSource: GpsDestinationSource.fixed,
        lat: 37.7749,
        lng: -122.4194,
      );
      final json = trigger.toJson();
      check(json['destinationSource']).equals('fixed');
    });

    test('toJson omits lat/lng when null (promptAtStart trigger)', () {
      const trigger = GpsArrivalDisarmTrigger();
      final json = trigger.toJson();
      check(json.containsKey('lat')).isFalse();
      check(json.containsKey('lng')).isFalse();
    });

    test('toJson includes lat and lng when non-null (fixed trigger)', () {
      const trigger = GpsArrivalDisarmTrigger(
        destinationSource: GpsDestinationSource.fixed,
        lat: 51.5074,
        lng: -0.1278,
      );
      final json = trigger.toJson();
      check(json['lat']).equals(51.5074);
      check(json['lng']).equals(-0.1278);
    });
  });

  group('TimerDisarmTrigger — fields and toJson', () {
    test('durationSeconds is captured exactly as supplied', () {
      const trigger = TimerDisarmTrigger(durationSeconds: 3600);
      check(trigger.durationSeconds).equals(3600);
    });

    test('toJson includes type=timer discriminator', () {
      const trigger = TimerDisarmTrigger(durationSeconds: 1800);
      final json = trigger.toJson();
      check(json['type']).equals('timer');
    });

    test('toJson encodes durationSeconds field', () {
      const trigger = TimerDisarmTrigger(durationSeconds: 7200);
      final json = trigger.toJson();
      check(json['durationSeconds']).equals(7200);
    });

    test('toJson has exactly two keys (type + durationSeconds)', () {
      const trigger = TimerDisarmTrigger(durationSeconds: 60);
      final json = trigger.toJson();
      check(json.keys.toSet()).deepEquals({'type', 'durationSeconds'});
    });
  });

  group('DisarmTrigger.fromJson — dispatch on type discriminator', () {
    test('dispatches gps_arrival to GpsArrivalDisarmTrigger', () {
      final json = <String, dynamic>{
        'type': 'gps_arrival',
        'radiusMeters': 200,
        'destinationSource': 'promptAtStart',
      };
      final restored = DisarmTrigger.fromJson(json);
      check(restored).isA<GpsArrivalDisarmTrigger>();
    });

    test('dispatches timer to TimerDisarmTrigger', () {
      final json = <String, dynamic>{'type': 'timer', 'durationSeconds': 600};
      final restored = DisarmTrigger.fromJson(json);
      check(restored).isA<TimerDisarmTrigger>();
    });

    test('unknown type throws ArgumentError', () {
      final json = <String, dynamic>{'type': 'wifi_arrival'};
      check(() => DisarmTrigger.fromJson(json)).throws<ArgumentError>();
    });

    test(
      'fromJson accepts int values where double expected (num.toDouble)',
      () {
        final json = <String, dynamic>{
          'type': 'gps_arrival',
          'radiusMeters': 250,
          'destinationSource': 'fixed',
          'lat': 0, // int, not double
          'lng': 0,
        };
        final restored =
            DisarmTrigger.fromJson(json) as GpsArrivalDisarmTrigger;
        check(restored.lat).equals(0.0);
        check(restored.lng).equals(0.0);
      },
    );
  });

  group('GpsArrivalDisarmTrigger — JSON round-trip', () {
    test('round-trip preserves default promptAtStart configuration', () {
      const original = GpsArrivalDisarmTrigger();
      final restored = DisarmTrigger.fromJson(original.toJson());
      check(restored).equals(original);
    });

    test('round-trip preserves fixed coordinates', () {
      const original = GpsArrivalDisarmTrigger(
        radiusMeters: 150,
        destinationSource: GpsDestinationSource.fixed,
        lat: 37.7749,
        lng: -122.4194,
      );
      final restored = DisarmTrigger.fromJson(original.toJson());
      check(restored).equals(original);
      final typed = restored as GpsArrivalDisarmTrigger;
      check(typed.lat).equals(37.7749);
      check(typed.lng).equals(-122.4194);
      check(typed.destinationSource).equals(GpsDestinationSource.fixed);
    });

    test('round-trip preserves custom radius without coordinates', () {
      const original = GpsArrivalDisarmTrigger(radiusMeters: 50);
      final restored = DisarmTrigger.fromJson(original.toJson());
      check(restored).equals(original);
      check((restored as GpsArrivalDisarmTrigger).radiusMeters).equals(50);
    });
  });

  group('TimerDisarmTrigger — JSON round-trip', () {
    test('round-trip preserves durationSeconds for a short timer', () {
      const original = TimerDisarmTrigger(durationSeconds: 60);
      final restored = DisarmTrigger.fromJson(original.toJson());
      check(restored).equals(original);
    });

    test('round-trip preserves a multi-hour timer', () {
      const original = TimerDisarmTrigger(durationSeconds: 14400);
      final restored = DisarmTrigger.fromJson(original.toJson());
      check(restored).equals(original);
      check((restored as TimerDisarmTrigger).durationSeconds).equals(14400);
    });
  });

  group('GpsArrivalDisarmTrigger — equality and hashCode', () {
    test('equal triggers are == and share hashCode', () {
      const a = GpsArrivalDisarmTrigger(
        destinationSource: GpsDestinationSource.fixed,
        lat: 1.0,
        lng: 2.0,
      );
      const b = GpsArrivalDisarmTrigger(
        destinationSource: GpsDestinationSource.fixed,
        lat: 1.0,
        lng: 2.0,
      );
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });

    test('different radiusMeters makes triggers unequal', () {
      const a = GpsArrivalDisarmTrigger();
      const b = GpsArrivalDisarmTrigger(radiusMeters: 500);
      check(a).not((it) => it.equals(b));
    });

    test('different destinationSource makes triggers unequal', () {
      const a = GpsArrivalDisarmTrigger();
      const b = GpsArrivalDisarmTrigger(
        destinationSource: GpsDestinationSource.fixed,
        lat: 0.0,
        lng: 0.0,
      );
      check(a).not((it) => it.equals(b));
    });

    test('different lat/lng makes triggers unequal', () {
      const a = GpsArrivalDisarmTrigger(
        destinationSource: GpsDestinationSource.fixed,
        lat: 1.0,
        lng: 2.0,
      );
      const b = GpsArrivalDisarmTrigger(
        destinationSource: GpsDestinationSource.fixed,
        lat: 1.0,
        lng: 3.0,
      );
      check(a).not((it) => it.equals(b));
    });

    test('null vs non-null lat makes triggers unequal', () {
      const a = GpsArrivalDisarmTrigger();
      const b = GpsArrivalDisarmTrigger(lat: 0.0);
      check(a).not((it) => it.equals(b));
    });

    test('identical references are == (identity short-circuit)', () {
      const a = GpsArrivalDisarmTrigger();
      check(a).equals(a);
    });
  });

  group('TimerDisarmTrigger — equality and hashCode', () {
    test('equal triggers are == and share hashCode', () {
      const a = TimerDisarmTrigger(durationSeconds: 600);
      const b = TimerDisarmTrigger(durationSeconds: 600);
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });

    test('different durationSeconds makes triggers unequal', () {
      const a = TimerDisarmTrigger(durationSeconds: 600);
      const b = TimerDisarmTrigger(durationSeconds: 601);
      check(a).not((it) => it.equals(b));
    });

    test('TimerDisarmTrigger is not == to GpsArrivalDisarmTrigger', () {
      const a = TimerDisarmTrigger(durationSeconds: 200);
      const b = GpsArrivalDisarmTrigger();
      // ignore: unrelated_type_equality_checks
      check(a == b).isFalse();
    });

    test('identical references are == (identity short-circuit)', () {
      const a = TimerDisarmTrigger(durationSeconds: 10);
      check(a).equals(a);
    });
  });

  group('DisarmTrigger — sealed hierarchy assertions', () {
    test('GpsArrivalDisarmTrigger is-a DisarmTrigger', () {
      const t = GpsArrivalDisarmTrigger();
      check(t).isA<DisarmTrigger>();
    });

    test('TimerDisarmTrigger is-a DisarmTrigger', () {
      const t = TimerDisarmTrigger(durationSeconds: 30);
      check(t).isA<DisarmTrigger>();
    });

    test('toJson reachable through supertype reference', () {
      const DisarmTrigger upcast = TimerDisarmTrigger(durationSeconds: 30);
      check(upcast.toJson()['type']).equals('timer');
    });
  });
}
