/// Unit tests for [CountdownWarningConfig] per spec 03 §StepConfig.
///
/// Covers default values, JSON round-trip across every [CountdownStyle],
/// [copyWith] semantics, and equality + hashCode invariants.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/countdown_style.dart';

void main() {
  group('CountdownWarningConfig — defaults match spec 03:337-342', () {
    test('default style is CountdownStyle.fullScreen', () {
      const cfg = CountdownWarningConfig();
      check(cfg.style).equals(CountdownStyle.fullScreen);
    });

    test('default vibrate is true', () {
      const cfg = CountdownWarningConfig();
      check(cfg.vibrate).isTrue();
    });

    test('default sound is false', () {
      const cfg = CountdownWarningConfig();
      check(cfg.sound).isFalse();
    });

    test('default blackScreenMode is false', () {
      const cfg = CountdownWarningConfig();
      check(cfg.blackScreenMode).isFalse();
    });

    test('constructor is const (compile-time constant)', () {
      // ignore: prefer_const_constructors
      const a = CountdownWarningConfig();
      const b = CountdownWarningConfig();
      check(identical(a, b)).isTrue();
    });
  });

  group('CountdownWarningConfig — JSON round-trip', () {
    test('toJson emits all four keys', () {
      const cfg = CountdownWarningConfig();
      final json = cfg.toJson();
      check(
        json.keys.toSet(),
      ).deepEquals({'style', 'vibrate', 'sound', 'blackScreenMode'});
    });

    test('toJson serialises style by enum name', () {
      const cfg = CountdownWarningConfig(style: CountdownStyle.notification);
      check(cfg.toJson()['style']).equals('notification');
    });

    test('round-trip preserves default values', () {
      const original = CountdownWarningConfig();
      final restored = StepConfig.fromJson(
        ChainStepType.countdownWarning,
        original.toJson(),
      );
      check(restored).equals(original);
    });

    test('round-trip preserves custom values', () {
      const original = CountdownWarningConfig(
        style: CountdownStyle.minimal,
        vibrate: false,
        sound: true,
        blackScreenMode: true,
      );
      final restored = StepConfig.fromJson(
        ChainStepType.countdownWarning,
        original.toJson(),
      );
      check(restored).equals(original);
    });

    test('fromJson falls back to defaults when fields missing', () {
      final cfg = CountdownWarningConfig.fromJson(const <String, dynamic>{});
      check(cfg).equals(const CountdownWarningConfig());
    });

    test('round-trip preserves every CountdownStyle value', () {
      for (final style in CountdownStyle.values) {
        final original = CountdownWarningConfig(style: style);
        final restored = StepConfig.fromJson(
          ChainStepType.countdownWarning,
          original.toJson(),
        );
        check(restored).equals(original);
        check((restored as CountdownWarningConfig).style).equals(style);
      }
    });

    test('StepConfig.fromJson with ChainStepType.countdownWarning returns '
        'CountdownWarningConfig', () {
      const original = CountdownWarningConfig(sound: true);
      final restored = StepConfig.fromJson(
        ChainStepType.countdownWarning,
        original.toJson(),
      );
      check(restored).isA<CountdownWarningConfig>();
    });
  });

  group('CountdownWarningConfig — copyWith', () {
    test('no-arg copyWith() returns an equivalent value', () {
      const cfg = CountdownWarningConfig(
        style: CountdownStyle.notification,
        vibrate: false,
        sound: true,
        blackScreenMode: true,
      );
      check(cfg.copyWith()).equals(cfg);
    });

    test('copyWith replaces style', () {
      const cfg = CountdownWarningConfig();
      final updated = cfg.copyWith(style: CountdownStyle.minimal);
      check(updated.style).equals(CountdownStyle.minimal);
      check(updated.vibrate).equals(cfg.vibrate);
    });

    test('copyWith replaces vibrate', () {
      const cfg = CountdownWarningConfig();
      final updated = cfg.copyWith(vibrate: false);
      check(updated.vibrate).isFalse();
    });

    test('copyWith replaces sound', () {
      const cfg = CountdownWarningConfig();
      final updated = cfg.copyWith(sound: true);
      check(updated.sound).isTrue();
    });

    test('copyWith replaces blackScreenMode', () {
      const cfg = CountdownWarningConfig();
      final updated = cfg.copyWith(blackScreenMode: true);
      check(updated.blackScreenMode).isTrue();
    });

    test('copyWith with all fields swaps every value', () {
      const cfg = CountdownWarningConfig();
      final updated = cfg.copyWith(
        style: CountdownStyle.notification,
        vibrate: false,
        sound: true,
        blackScreenMode: true,
      );
      check(updated.style).equals(CountdownStyle.notification);
      check(updated.vibrate).isFalse();
      check(updated.sound).isTrue();
      check(updated.blackScreenMode).isTrue();
    });
  });

  group('CountdownWarningConfig — equality + hashCode', () {
    test('equality is reflexive', () {
      const cfg = CountdownWarningConfig(style: CountdownStyle.minimal);
      check(cfg).equals(cfg);
    });

    test('equality is symmetric', () {
      const a = CountdownWarningConfig(style: CountdownStyle.minimal);
      const b = CountdownWarningConfig(style: CountdownStyle.minimal);
      check(a).equals(b);
      check(b).equals(a);
    });

    test('equality is transitive', () {
      const a = CountdownWarningConfig(sound: true);
      const b = CountdownWarningConfig(sound: true);
      const c = CountdownWarningConfig(sound: true);
      check(a == b).isTrue();
      check(b == c).isTrue();
      check(a == c).isTrue();
    });

    test('equal values have equal hashCodes', () {
      const a = CountdownWarningConfig(
        style: CountdownStyle.notification,
        vibrate: false,
      );
      const b = CountdownWarningConfig(
        style: CountdownStyle.notification,
        vibrate: false,
      );
      check(a.hashCode).equals(b.hashCode);
    });

    test('inequality on style', () {
      const a = CountdownWarningConfig();
      const b = CountdownWarningConfig(style: CountdownStyle.minimal);
      check(a == b).isFalse();
    });

    test('inequality on vibrate', () {
      const a = CountdownWarningConfig();
      const b = CountdownWarningConfig(vibrate: false);
      check(a == b).isFalse();
    });

    test('inequality on sound', () {
      const a = CountdownWarningConfig();
      const b = CountdownWarningConfig(sound: true);
      check(a == b).isFalse();
    });

    test('inequality on blackScreenMode', () {
      const a = CountdownWarningConfig();
      const b = CountdownWarningConfig(blackScreenMode: true);
      check(a == b).isFalse();
    });
  });
}
