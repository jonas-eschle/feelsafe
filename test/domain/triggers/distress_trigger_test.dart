/// Unit tests for [DistressTrigger] sealed hierarchy per spec 03 §DistressTrigger.
///
/// Covers default values, both [PressPattern.repeatPress] and
/// [PressPattern.longPress] variants (G-005), `type` discriminator in JSON,
/// `DistressTrigger.fromJson` dispatch, equality + hashCode, and round-trip
/// preservation for every field combination shipped at v3 GA.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/triggers/distress_trigger.dart';

void main() {
  group(
    'HardwareButtonDistressTrigger — defaults match spec 03 §DistressTrigger',
    () {
      test('default buttonType is ButtonType.volumeUp', () {
        const trigger = HardwareButtonDistressTrigger();
        check(trigger.buttonType).equals(ButtonType.volumeUp);
      });

      test('default pattern is PressPattern.repeatPress', () {
        const trigger = HardwareButtonDistressTrigger();
        check(trigger.pattern).equals(PressPattern.repeatPress);
      });

      test('default pressCount is 5 (B1)', () {
        const trigger = HardwareButtonDistressTrigger();
        check(trigger.pressCount).equals(5);
      });

      test('default durationSeconds is null (only set for longPress)', () {
        const trigger = HardwareButtonDistressTrigger();
        check(trigger.durationSeconds).isNull();
      });
    },
  );

  group('HardwareButtonDistressTrigger — toJson discriminator', () {
    test('toJson includes type=hardware_button discriminator', () {
      const trigger = HardwareButtonDistressTrigger();
      final json = trigger.toJson();
      check(json['type']).equals('hardware_button');
    });

    test('toJson encodes pattern as its enum name', () {
      const trigger = HardwareButtonDistressTrigger(
        pattern: PressPattern.longPress,
        durationSeconds: 2.0,
      );
      final json = trigger.toJson();
      check(json['pattern']).equals('longPress');
    });

    test('toJson encodes buttonType as its enum name', () {
      const trigger = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeDown,
      );
      final json = trigger.toJson();
      check(json['buttonType']).equals('volumeDown');
    });

    test('toJson omits durationSeconds when null (repeatPress)', () {
      const trigger = HardwareButtonDistressTrigger();
      final json = trigger.toJson();
      check(json.containsKey('durationSeconds')).isFalse();
    });

    test('toJson includes durationSeconds when non-null (longPress)', () {
      const trigger = HardwareButtonDistressTrigger(
        pattern: PressPattern.longPress,
        durationSeconds: 2.0,
      );
      final json = trigger.toJson();
      check(json['durationSeconds']).equals(2.0);
    });

    test('toJson always includes pressCount field', () {
      const trigger = HardwareButtonDistressTrigger(pressCount: 7);
      final json = trigger.toJson();
      check(json['pressCount']).equals(7);
    });
  });

  group('DistressTrigger.fromJson — dispatch on type discriminator', () {
    test('dispatches hardware_button to HardwareButtonDistressTrigger', () {
      final json = <String, dynamic>{
        'type': 'hardware_button',
        'buttonType': 'volumeUp',
        'pattern': 'repeatPress',
        'pressCount': 5,
      };
      final restored = DistressTrigger.fromJson(json);
      check(restored).isA<HardwareButtonDistressTrigger>();
    });

    test('unknown type throws ArgumentError', () {
      final json = <String, dynamic>{'type': 'mystery_trigger'};
      check(() => DistressTrigger.fromJson(json)).throws<ArgumentError>();
    });
  });

  group('HardwareButtonDistressTrigger — JSON round-trip', () {
    test('round-trip preserves repeatPress with default fields', () {
      const original = HardwareButtonDistressTrigger();
      final restored = DistressTrigger.fromJson(original.toJson());
      check(restored).equals(original);
    });

    test('round-trip preserves longPress with durationSeconds=2.0', () {
      const original = HardwareButtonDistressTrigger(
        pattern: PressPattern.longPress,
        durationSeconds: 2.0,
      );
      final restored = DistressTrigger.fromJson(original.toJson());
      check(restored).equals(original);
      final restoredTyped = restored as HardwareButtonDistressTrigger;
      check(restoredTyped.durationSeconds).equals(2.0);
      check(restoredTyped.pattern).equals(PressPattern.longPress);
    });

    test('round-trip preserves volumeDown button choice', () {
      const original = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeDown,
      );
      final restored = DistressTrigger.fromJson(original.toJson());
      check(restored).equals(original);
      check(
        (restored as HardwareButtonDistressTrigger).buttonType,
      ).equals(ButtonType.volumeDown);
    });

    test('round-trip preserves non-default pressCount', () {
      const original = HardwareButtonDistressTrigger(pressCount: 10);
      final restored = DistressTrigger.fromJson(original.toJson());
      check(restored).equals(original);
      check((restored as HardwareButtonDistressTrigger).pressCount).equals(10);
    });

    test('round-trip drops durationSeconds for repeatPress', () {
      const original = HardwareButtonDistressTrigger();
      final json = original.toJson();
      check(json.containsKey('durationSeconds')).isFalse();
      final restored =
          DistressTrigger.fromJson(json) as HardwareButtonDistressTrigger;
      check(restored.durationSeconds).isNull();
    });

    test('fromJson accepts integer durationSeconds (num.toDouble)', () {
      // JSON sometimes ships integers for whole-second values.
      final json = <String, dynamic>{
        'type': 'hardware_button',
        'buttonType': 'volumeUp',
        'pattern': 'longPress',
        'pressCount': 5,
        'durationSeconds': 3, // int, not double
      };
      final restored =
          DistressTrigger.fromJson(json) as HardwareButtonDistressTrigger;
      check(restored.durationSeconds).equals(3.0);
    });
  });

  group('HardwareButtonDistressTrigger — equality and hashCode', () {
    test('two equal triggers are == and share hashCode', () {
      const a = HardwareButtonDistressTrigger(
        pattern: PressPattern.longPress,
        durationSeconds: 2.0,
      );
      const b = HardwareButtonDistressTrigger(
        pattern: PressPattern.longPress,
        durationSeconds: 2.0,
      );
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });

    test('different buttonType makes triggers unequal', () {
      const a = HardwareButtonDistressTrigger();
      const b = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeDown,
      );
      check(a).not((it) => it.equals(b));
    });

    test('different pattern makes triggers unequal', () {
      const a = HardwareButtonDistressTrigger();
      const b = HardwareButtonDistressTrigger(
        pattern: PressPattern.longPress,
        durationSeconds: 2.0,
      );
      check(a).not((it) => it.equals(b));
    });

    test('different pressCount makes triggers unequal', () {
      const a = HardwareButtonDistressTrigger();
      const b = HardwareButtonDistressTrigger(pressCount: 6);
      check(a).not((it) => it.equals(b));
    });

    test('different durationSeconds makes triggers unequal', () {
      const a = HardwareButtonDistressTrigger(
        pattern: PressPattern.longPress,
        durationSeconds: 2.0,
      );
      const b = HardwareButtonDistressTrigger(
        pattern: PressPattern.longPress,
        durationSeconds: 3.0,
      );
      check(a).not((it) => it.equals(b));
    });

    test('null vs non-null durationSeconds makes triggers unequal', () {
      const a = HardwareButtonDistressTrigger();
      const b = HardwareButtonDistressTrigger(durationSeconds: 2.0);
      check(a).not((it) => it.equals(b));
    });

    test('identical triggers are == (identity short-circuit)', () {
      const a = HardwareButtonDistressTrigger();
      check(a).equals(a);
    });

    test('trigger is not equal to an object of a different type', () {
      const a = HardwareButtonDistressTrigger();
      // ignore: unrelated_type_equality_checks
      check(a == const Object()).isFalse();
    });
  });

  group('DistressTrigger — sealed hierarchy assertions', () {
    test('HardwareButtonDistressTrigger is-a DistressTrigger', () {
      const trigger = HardwareButtonDistressTrigger();
      check(trigger).isA<DistressTrigger>();
    });

    test('toJson is part of the sealed interface (no missing override)', () {
      const DistressTrigger upcast = HardwareButtonDistressTrigger();
      // Calling via the supertype reference must succeed.
      check(upcast.toJson()).isA<Map<String, dynamic>>();
    });
  });
}
