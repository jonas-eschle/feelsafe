/// Unit tests for [HoldButtonConfig] per spec 03 §StepConfig.
///
/// Covers default values, JSON round-trip, [copyWith] semantics,
/// equality + hashCode invariants, and per-config edge cases.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/hold_style.dart';

void main() {
  group('HoldButtonConfig — defaults match spec 03:322-328', () {
    test('default holdStyle is HoldStyle.largeButton', () {
      const cfg = HoldButtonConfig();
      check(cfg.holdStyle).equals(HoldStyle.largeButton);
    });

    test('default releaseSensitivity is 1.0', () {
      const cfg = HoldButtonConfig();
      check(cfg.releaseSensitivity).equals(1.0);
    });

    test('default vibrateOnRelease is true', () {
      const cfg = HoldButtonConfig();
      check(cfg.vibrateOnRelease).isTrue();
    });

    test('default soundOnRelease is false', () {
      const cfg = HoldButtonConfig();
      check(cfg.soundOnRelease).isFalse();
    });

    test('default blackScreenMode is false', () {
      const cfg = HoldButtonConfig();
      check(cfg.blackScreenMode).isFalse();
    });

    test('constructor is const (compile-time constant)', () {
      // ignore: prefer_const_constructors
      const a = HoldButtonConfig();
      const b = HoldButtonConfig();
      check(identical(a, b)).isTrue();
    });
  });

  group('HoldButtonConfig — JSON round-trip', () {
    test('toJson emits all five keys', () {
      const cfg = HoldButtonConfig();
      final json = cfg.toJson();
      check(json.keys.toSet()).deepEquals({
        'holdStyle',
        'releaseSensitivity',
        'vibrateOnRelease',
        'soundOnRelease',
        'blackScreenMode',
      });
    });

    test('toJson serialises holdStyle by enum name', () {
      const cfg = HoldButtonConfig(holdStyle: HoldStyle.fakeLockScreen);
      check(cfg.toJson()['holdStyle']).equals('fakeLockScreen');
    });

    test('round-trip preserves default values', () {
      const original = HoldButtonConfig();
      final restored = StepConfig.fromJson(
        ChainStepType.holdButton,
        original.toJson(),
      );
      check(restored).equals(original);
    });

    test('round-trip preserves custom values', () {
      const original = HoldButtonConfig(
        holdStyle: HoldStyle.fullScreen,
        releaseSensitivity: 2.5,
        vibrateOnRelease: false,
        soundOnRelease: true,
        blackScreenMode: true,
      );
      final restored = StepConfig.fromJson(
        ChainStepType.holdButton,
        original.toJson(),
      );
      check(restored).equals(original);
    });

    test('fromJson falls back to defaults when fields missing', () {
      final cfg = HoldButtonConfig.fromJson(const <String, dynamic>{});
      check(cfg).equals(const HoldButtonConfig());
    });

    test('round-trip preserves every HoldStyle value', () {
      for (final style in HoldStyle.values) {
        final original = HoldButtonConfig(holdStyle: style);
        final restored = StepConfig.fromJson(
          ChainStepType.holdButton,
          original.toJson(),
        );
        check(restored).equals(original);
      }
    });

    test('StepConfig.fromJson with ChainStepType.holdButton returns '
        'HoldButtonConfig', () {
      const original = HoldButtonConfig(releaseSensitivity: 1.7);
      final restored = StepConfig.fromJson(
        ChainStepType.holdButton,
        original.toJson(),
      );
      check(restored).isA<HoldButtonConfig>();
    });
  });

  group('HoldButtonConfig — copyWith', () {
    test('no-arg copyWith() returns an equivalent value', () {
      const cfg = HoldButtonConfig(
        holdStyle: HoldStyle.fullScreen,
        releaseSensitivity: 1.4,
        vibrateOnRelease: false,
        soundOnRelease: true,
        blackScreenMode: true,
      );
      check(cfg.copyWith()).equals(cfg);
    });

    test('copyWith replaces holdStyle', () {
      const cfg = HoldButtonConfig();
      final updated = cfg.copyWith(holdStyle: HoldStyle.fakeLockScreen);
      check(updated.holdStyle).equals(HoldStyle.fakeLockScreen);
      check(updated.releaseSensitivity).equals(cfg.releaseSensitivity);
    });

    test('copyWith replaces releaseSensitivity', () {
      const cfg = HoldButtonConfig();
      final updated = cfg.copyWith(releaseSensitivity: 0.3);
      check(updated.releaseSensitivity).equals(0.3);
      check(updated.holdStyle).equals(cfg.holdStyle);
    });

    test('copyWith replaces vibrateOnRelease', () {
      const cfg = HoldButtonConfig();
      final updated = cfg.copyWith(vibrateOnRelease: false);
      check(updated.vibrateOnRelease).isFalse();
    });

    test('copyWith replaces soundOnRelease', () {
      const cfg = HoldButtonConfig();
      final updated = cfg.copyWith(soundOnRelease: true);
      check(updated.soundOnRelease).isTrue();
    });

    test('copyWith replaces blackScreenMode', () {
      const cfg = HoldButtonConfig();
      final updated = cfg.copyWith(blackScreenMode: true);
      check(updated.blackScreenMode).isTrue();
    });
  });

  group('HoldButtonConfig — equality + hashCode', () {
    test('equality is reflexive', () {
      const cfg = HoldButtonConfig(releaseSensitivity: 1.5);
      check(cfg).equals(cfg);
    });

    test('equality is symmetric', () {
      const a = HoldButtonConfig(releaseSensitivity: 1.5);
      const b = HoldButtonConfig(releaseSensitivity: 1.5);
      check(a).equals(b);
      check(b).equals(a);
    });

    test('equality is transitive', () {
      const a = HoldButtonConfig(releaseSensitivity: 1.5);
      const b = HoldButtonConfig(releaseSensitivity: 1.5);
      const c = HoldButtonConfig(releaseSensitivity: 1.5);
      check(a == b).isTrue();
      check(b == c).isTrue();
      check(a == c).isTrue();
    });

    test('equal values have equal hashCodes', () {
      const a = HoldButtonConfig(
        holdStyle: HoldStyle.fullScreen,
        releaseSensitivity: 2.0,
      );
      const b = HoldButtonConfig(
        holdStyle: HoldStyle.fullScreen,
        releaseSensitivity: 2.0,
      );
      check(a.hashCode).equals(b.hashCode);
    });

    test('inequality on holdStyle', () {
      const a = HoldButtonConfig();
      const b = HoldButtonConfig(holdStyle: HoldStyle.fullScreen);
      check(a == b).isFalse();
    });

    test('inequality on releaseSensitivity', () {
      const a = HoldButtonConfig();
      const b = HoldButtonConfig(releaseSensitivity: 2.0);
      check(a == b).isFalse();
    });

    test('inequality on vibrateOnRelease', () {
      const a = HoldButtonConfig();
      const b = HoldButtonConfig(vibrateOnRelease: false);
      check(a == b).isFalse();
    });

    test('inequality on soundOnRelease', () {
      const a = HoldButtonConfig();
      const b = HoldButtonConfig(soundOnRelease: true);
      check(a == b).isFalse();
    });

    test('inequality on blackScreenMode', () {
      const a = HoldButtonConfig();
      const b = HoldButtonConfig(blackScreenMode: true);
      check(a == b).isFalse();
    });
  });

  group('HoldButtonConfig — edge cases', () {
    test('releaseSensitivity accepts spec lower bound 0.3', () {
      const cfg = HoldButtonConfig(releaseSensitivity: 0.3);
      check(cfg.releaseSensitivity).equals(0.3);
    });

    test('releaseSensitivity accepts spec upper bound 3.0', () {
      const cfg = HoldButtonConfig(releaseSensitivity: 3.0);
      check(cfg.releaseSensitivity).equals(3.0);
    });

    test('fromJson accepts integer for releaseSensitivity', () {
      final cfg = HoldButtonConfig.fromJson(const <String, dynamic>{
        'releaseSensitivity': 2,
      });
      check(cfg.releaseSensitivity).equals(2.0);
    });
  });
}
