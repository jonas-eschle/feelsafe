// Unit tests for [LoudAlarmConfig].
//
// Verifies constructor defaults, JSON round-trip, copyWith behaviour,
// equality / hashCode contract, and edge cases per
// docs/spec/03-data-models.md §LoudAlarmConfig (spec 03:446-455 / Q9).
// Asserts legacy `flashSpeed` / `maxVolume` are gone per pre-flight
// fix G-006.
//
// ignore_for_file: avoid_redundant_argument_values
// Tests intentionally pass default values to verify round-trip and
// equality semantics.

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/log_gps_override.dart';
import 'package:guardianangela/domain/enums/loud_alarm_sound.dart';

void main() {
  group('LoudAlarmConfig', () {
    group('constructor defaults', () {
      test('volume defaults to 1.0 (max linear)', () {
        // Arrange + Act
        const cfg = LoudAlarmConfig();

        // Assert
        check(cfg.volume).equals(1.0);
      });

      test('soundChoice defaults to siren', () {
        // Arrange + Act
        const cfg = LoudAlarmConfig();

        // Assert
        check(cfg.soundChoice).equals(LoudAlarmSound.siren);
      });

      test('flashLight defaults to true', () {
        // Arrange + Act
        const cfg = LoudAlarmConfig();

        // Assert
        check(cfg.flashLight).isTrue();
      });

      test('flashScreen defaults to false (photosensitivity safe)', () {
        // Arrange + Act
        const cfg = LoudAlarmConfig();

        // Assert
        check(cfg.flashScreen).isFalse();
      });

      test('flashSpeedMs defaults to 500', () {
        // Arrange + Act
        const cfg = LoudAlarmConfig();

        // Assert
        check(cfg.flashSpeedMs).equals(500);
      });

      test('gradualVolume defaults to false', () {
        // Arrange + Act
        const cfg = LoudAlarmConfig();

        // Assert
        check(cfg.gradualVolume).isFalse();
      });

      test('logGps defaults to useDefault', () {
        // Arrange + Act
        const cfg = LoudAlarmConfig();

        // Assert
        check(cfg.logGps).equals(LogGpsOverride.useDefault);
      });

      test('blackScreenMode defaults to false', () {
        // Arrange + Act
        const cfg = LoudAlarmConfig();

        // Assert
        check(cfg.blackScreenMode).isFalse();
      });
    });

    group('legacy field schema (G-006)', () {
      test('toJson does NOT contain legacy flashSpeed key', () {
        // Arrange
        const cfg = LoudAlarmConfig();

        // Act
        final json = cfg.toJson();

        // Assert
        check(json.containsKey('flashSpeed')).isFalse();
      });

      test('toJson does NOT contain legacy maxVolume key', () {
        // Arrange
        const cfg = LoudAlarmConfig();

        // Act
        final json = cfg.toJson();

        // Assert
        check(json.containsKey('maxVolume')).isFalse();
      });

      test('toJson exposes canonical flashSpeedMs key', () {
        // Arrange
        const cfg = LoudAlarmConfig();

        // Act
        final json = cfg.toJson();

        // Assert
        check(json.containsKey('flashSpeedMs')).isTrue();
      });

      test('toJson exposes canonical volume key', () {
        // Arrange
        const cfg = LoudAlarmConfig();

        // Act
        final json = cfg.toJson();

        // Assert
        check(json.containsKey('volume')).isTrue();
      });

      test('toJson exposes all expected keys', () {
        // Arrange
        const cfg = LoudAlarmConfig();

        // Act
        final json = cfg.toJson();

        // Assert
        check(json.containsKey('flashScreen')).isTrue();
        check(json.containsKey('flashSpeedMs')).isTrue();
        check(json.containsKey('volume')).isTrue();
        check(json.containsKey('soundChoice')).isTrue();
        check(json.containsKey('gradualVolume')).isTrue();
        check(json.containsKey('flashLight')).isTrue();
        check(json.containsKey('blackScreenMode')).isTrue();
        check(json.containsKey('logGps')).isTrue();
      });
    });

    group('JSON round-trip', () {
      test('default config round-trips equal', () {
        // Arrange
        const cfg = LoudAlarmConfig();

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.loudAlarm,
          cfg.toJson(),
        );

        // Assert
        check(decoded).isA<LoudAlarmConfig>();
        check(decoded as LoudAlarmConfig).equals(cfg);
      });

      test('fully-populated config round-trips equal', () {
        // Arrange
        const cfg = LoudAlarmConfig(
          flashScreen: true,
          flashSpeedMs: 250,
          volume: 0.75,
          soundChoice: LoudAlarmSound.custom,
          gradualVolume: true,
          flashLight: false,
          blackScreenMode: true,
          logGps: LogGpsOverride.forceOff,
        );

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.loudAlarm,
          cfg.toJson(),
        );

        // Assert
        check(decoded as LoudAlarmConfig).equals(cfg);
      });

      test('round-trip preserves LoudAlarmSound.siren by name', () {
        // Arrange
        const cfg = LoudAlarmConfig(soundChoice: LoudAlarmSound.siren);

        // Act
        final json = cfg.toJson();
        final decoded = StepConfig.fromJson(ChainStepType.loudAlarm, json);

        // Assert
        check(json['soundChoice']).equals('siren');
        check(
          (decoded as LoudAlarmConfig).soundChoice,
        ).equals(LoudAlarmSound.siren);
      });

      test('round-trip preserves LoudAlarmSound.custom by name', () {
        // Arrange
        const cfg = LoudAlarmConfig(soundChoice: LoudAlarmSound.custom);

        // Act
        final json = cfg.toJson();
        final decoded = StepConfig.fromJson(ChainStepType.loudAlarm, json);

        // Assert
        check(json['soundChoice']).equals('custom');
        check(
          (decoded as LoudAlarmConfig).soundChoice,
        ).equals(LoudAlarmSound.custom);
      });

      test('round-trip preserves volume range 0.0', () {
        // Arrange
        const cfg = LoudAlarmConfig(volume: 0.0);

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.loudAlarm,
          cfg.toJson(),
        );

        // Assert
        check((decoded as LoudAlarmConfig).volume).equals(0.0);
      });

      test('round-trip preserves volume range 1.0', () {
        // Arrange
        const cfg = LoudAlarmConfig(volume: 1.0);

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.loudAlarm,
          cfg.toJson(),
        );

        // Assert
        check((decoded as LoudAlarmConfig).volume).equals(1.0);
      });

      test('round-trip preserves every LogGpsOverride value', () {
        for (final v in LogGpsOverride.values) {
          // Arrange
          final cfg = LoudAlarmConfig(logGps: v);

          // Act
          final decoded = StepConfig.fromJson(
            ChainStepType.loudAlarm,
            cfg.toJson(),
          );

          // Assert
          check((decoded as LoudAlarmConfig).logGps).equals(v);
        }
      });

      test('fromJson with empty map produces all defaults', () {
        // Arrange + Act
        final decoded = StepConfig.fromJson(
          ChainStepType.loudAlarm,
          <String, dynamic>{},
        );

        // Assert
        check(decoded as LoudAlarmConfig).equals(const LoudAlarmConfig());
      });
    });

    group('copyWith + equality + hashCode', () {
      test('copyWith with no args returns equal instance', () {
        // Arrange
        const cfg = LoudAlarmConfig(volume: 0.5);

        // Act
        final copy = cfg.copyWith();

        // Assert
        check(copy).equals(cfg);
        check(copy.hashCode).equals(cfg.hashCode);
      });

      test('copyWith replaces only the specified field', () {
        // Arrange
        const cfg = LoudAlarmConfig();

        // Act
        final copy = cfg.copyWith(volume: 0.3, flashScreen: true);

        // Assert
        check(copy.volume).equals(0.3);
        check(copy.flashScreen).isTrue();
        check(copy.flashLight).equals(cfg.flashLight);
        check(copy.soundChoice).equals(cfg.soundChoice);
      });

      test('two configs with identical fields are equal', () {
        // Arrange
        const a = LoudAlarmConfig(
          volume: 0.8,
          soundChoice: LoudAlarmSound.custom,
        );
        const b = LoudAlarmConfig(
          volume: 0.8,
          soundChoice: LoudAlarmSound.custom,
        );

        // Assert
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('configs with differing volume are not equal', () {
        // Arrange
        const a = LoudAlarmConfig(volume: 0.5);
        const b = LoudAlarmConfig(volume: 0.6);

        // Assert
        check(a == b).isFalse();
      });

      test('configs with differing soundChoice are not equal', () {
        // Arrange
        const a = LoudAlarmConfig(soundChoice: LoudAlarmSound.siren);
        const b = LoudAlarmConfig(soundChoice: LoudAlarmSound.custom);

        // Assert
        check(a == b).isFalse();
      });

      test('configs with differing flashSpeedMs are not equal', () {
        // Arrange
        const a = LoudAlarmConfig(flashSpeedMs: 500);
        const b = LoudAlarmConfig(flashSpeedMs: 250);

        // Assert
        check(a == b).isFalse();
      });

      test('identical reference equals itself (short-circuit)', () {
        // Arrange
        const cfg = LoudAlarmConfig();

        // Assert
        check(cfg == cfg).isTrue();
      });

      test('config never equals an unrelated type', () {
        // Arrange
        const cfg = LoudAlarmConfig();

        // Assert
        check(cfg == const Object()).isFalse();
      });
    });
  });
}
