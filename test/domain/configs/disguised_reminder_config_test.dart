/// Unit tests for [DisguisedReminderConfig] per spec 03 §StepConfig.
///
/// Covers default values, JSON round-trip, [copyWith] semantics,
/// equality + hashCode invariants, and the D4 resetOnEarlyCheckIn rule.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';

void main() {
  group('DisguisedReminderConfig — defaults match spec 03:330-335', () {
    test('default randomizeInterval is true', () {
      const cfg = DisguisedReminderConfig();
      check(cfg.randomizeInterval).isTrue();
    });

    test('default randomizeTemplateOrder is true', () {
      const cfg = DisguisedReminderConfig();
      check(cfg.randomizeTemplateOrder).isTrue();
    });

    test(
      'default resetOnEarlyCheckIn is true (D4 — early tap resets timer)',
      () {
        const cfg = DisguisedReminderConfig();
        check(cfg.resetOnEarlyCheckIn).isTrue();
      },
    );

    test('default blackScreenMode is false', () {
      const cfg = DisguisedReminderConfig();
      check(cfg.blackScreenMode).isFalse();
    });

    test('constructor is const (compile-time constant)', () {
      // ignore: prefer_const_constructors
      const a = DisguisedReminderConfig();
      const b = DisguisedReminderConfig();
      check(identical(a, b)).isTrue();
    });
  });

  group('DisguisedReminderConfig — JSON round-trip', () {
    test('toJson emits all four keys', () {
      const cfg = DisguisedReminderConfig();
      final json = cfg.toJson();
      check(json.keys.toSet()).deepEquals({
        'randomizeInterval',
        'randomizeTemplateOrder',
        'resetOnEarlyCheckIn',
        'blackScreenMode',
      });
    });

    test('round-trip preserves default values', () {
      const original = DisguisedReminderConfig();
      final restored = StepConfig.fromJson(
        ChainStepType.disguisedReminder,
        original.toJson(),
      );
      check(restored).equals(original);
    });

    test('round-trip preserves all-false custom values', () {
      const original = DisguisedReminderConfig(
        randomizeInterval: false,
        randomizeTemplateOrder: false,
        resetOnEarlyCheckIn: false,
        blackScreenMode: true,
      );
      final restored = StepConfig.fromJson(
        ChainStepType.disguisedReminder,
        original.toJson(),
      );
      check(restored).equals(original);
    });

    test('fromJson falls back to defaults when fields missing', () {
      final cfg = DisguisedReminderConfig.fromJson(const <String, dynamic>{});
      check(cfg).equals(const DisguisedReminderConfig());
    });

    test('StepConfig.fromJson with ChainStepType.disguisedReminder returns '
        'DisguisedReminderConfig', () {
      const original = DisguisedReminderConfig(randomizeInterval: false);
      final restored = StepConfig.fromJson(
        ChainStepType.disguisedReminder,
        original.toJson(),
      );
      check(restored).isA<DisguisedReminderConfig>();
    });

    test('toJson booleans are typed bool', () {
      const cfg = DisguisedReminderConfig(resetOnEarlyCheckIn: false);
      final json = cfg.toJson();
      check(json['resetOnEarlyCheckIn']).isA<bool>().isFalse();
      check(json['randomizeInterval']).isA<bool>().isTrue();
    });
  });

  group('DisguisedReminderConfig — copyWith', () {
    test('no-arg copyWith() returns an equivalent value', () {
      const cfg = DisguisedReminderConfig(
        randomizeInterval: false,
        randomizeTemplateOrder: false,
        resetOnEarlyCheckIn: false,
        blackScreenMode: true,
      );
      check(cfg.copyWith()).equals(cfg);
    });

    test('copyWith replaces randomizeInterval', () {
      const cfg = DisguisedReminderConfig();
      final updated = cfg.copyWith(randomizeInterval: false);
      check(updated.randomizeInterval).isFalse();
      check(updated.randomizeTemplateOrder).equals(cfg.randomizeTemplateOrder);
    });

    test('copyWith replaces randomizeTemplateOrder', () {
      const cfg = DisguisedReminderConfig();
      final updated = cfg.copyWith(randomizeTemplateOrder: false);
      check(updated.randomizeTemplateOrder).isFalse();
    });

    test('copyWith replaces resetOnEarlyCheckIn', () {
      const cfg = DisguisedReminderConfig();
      final updated = cfg.copyWith(resetOnEarlyCheckIn: false);
      check(updated.resetOnEarlyCheckIn).isFalse();
    });

    test('copyWith replaces blackScreenMode', () {
      const cfg = DisguisedReminderConfig();
      final updated = cfg.copyWith(blackScreenMode: true);
      check(updated.blackScreenMode).isTrue();
    });

    test('copyWith with all fields swaps every value', () {
      const cfg = DisguisedReminderConfig();
      final updated = cfg.copyWith(
        randomizeInterval: false,
        randomizeTemplateOrder: false,
        resetOnEarlyCheckIn: false,
        blackScreenMode: true,
      );
      check(updated.randomizeInterval).isFalse();
      check(updated.randomizeTemplateOrder).isFalse();
      check(updated.resetOnEarlyCheckIn).isFalse();
      check(updated.blackScreenMode).isTrue();
    });
  });

  group('DisguisedReminderConfig — equality + hashCode', () {
    test('equality is reflexive', () {
      const cfg = DisguisedReminderConfig(randomizeInterval: false);
      check(cfg).equals(cfg);
    });

    test('equality is symmetric', () {
      const a = DisguisedReminderConfig(randomizeInterval: false);
      const b = DisguisedReminderConfig(randomizeInterval: false);
      check(a).equals(b);
      check(b).equals(a);
    });

    test('equality is transitive', () {
      const a = DisguisedReminderConfig(resetOnEarlyCheckIn: false);
      const b = DisguisedReminderConfig(resetOnEarlyCheckIn: false);
      const c = DisguisedReminderConfig(resetOnEarlyCheckIn: false);
      check(a == b).isTrue();
      check(b == c).isTrue();
      check(a == c).isTrue();
    });

    test('equal values have equal hashCodes', () {
      const a = DisguisedReminderConfig(
        randomizeInterval: false,
        blackScreenMode: true,
      );
      const b = DisguisedReminderConfig(
        randomizeInterval: false,
        blackScreenMode: true,
      );
      check(a.hashCode).equals(b.hashCode);
    });

    test('inequality on randomizeInterval', () {
      const a = DisguisedReminderConfig();
      const b = DisguisedReminderConfig(randomizeInterval: false);
      check(a == b).isFalse();
    });

    test('inequality on randomizeTemplateOrder', () {
      const a = DisguisedReminderConfig();
      const b = DisguisedReminderConfig(randomizeTemplateOrder: false);
      check(a == b).isFalse();
    });

    test('inequality on resetOnEarlyCheckIn', () {
      const a = DisguisedReminderConfig();
      const b = DisguisedReminderConfig(resetOnEarlyCheckIn: false);
      check(a == b).isFalse();
    });

    test('inequality on blackScreenMode', () {
      const a = DisguisedReminderConfig();
      const b = DisguisedReminderConfig(blackScreenMode: true);
      check(a == b).isFalse();
    });
  });
}
