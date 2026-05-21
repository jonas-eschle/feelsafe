// Unit tests for [HardwareButtonConfig].
//
// Verifies constructor defaults, JSON round-trip, copyWith behaviour,
// equality / hashCode contract, and edge cases per
// docs/spec/03-data-models.md §HardwareButtonConfig (spec 03:555-562)
// and the decision B1 (5 presses default) / G-005 (both repeatPress
// and longPress ship at v3 GA).
//
// ignore_for_file: avoid_redundant_argument_values
// Tests intentionally pass default values to verify round-trip and
// equality semantics.

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';

void main() {
  group('HardwareButtonConfig', () {
    group('constructor defaults', () {
      test('buttonType defaults to volumeUp', () {
        // Arrange + Act
        const cfg = HardwareButtonConfig();

        // Assert
        check(cfg.buttonType).equals(ButtonType.volumeUp);
      });

      test('pressPattern defaults to repeatPress', () {
        // Arrange + Act
        const cfg = HardwareButtonConfig();

        // Assert
        check(cfg.pressPattern).equals(PressPattern.repeatPress);
      });

      test('pressCount defaults to 5 (B1)', () {
        // Arrange + Act
        const cfg = HardwareButtonConfig();

        // Assert
        check(cfg.pressCount).equals(5);
      });

      test('longPressDurationSeconds defaults to 2.0', () {
        // Arrange + Act
        const cfg = HardwareButtonConfig();

        // Assert
        check(cfg.longPressDurationSeconds).equals(2.0);
      });

      test('targetStepIndex defaults to -1 (next step)', () {
        // Arrange + Act
        const cfg = HardwareButtonConfig();

        // Assert
        check(cfg.targetStepIndex).equals(-1);
      });

      test('blackScreenMode defaults to false', () {
        // Arrange + Act
        const cfg = HardwareButtonConfig();

        // Assert
        check(cfg.blackScreenMode).isFalse();
      });
    });

    group('field schema', () {
      test('toJson exposes all expected keys', () {
        // Arrange
        const cfg = HardwareButtonConfig();

        // Act
        final json = cfg.toJson();

        // Assert
        check(json.containsKey('buttonType')).isTrue();
        check(json.containsKey('pressPattern')).isTrue();
        check(json.containsKey('pressCount')).isTrue();
        check(json.containsKey('longPressDurationSeconds')).isTrue();
        check(json.containsKey('targetStepIndex')).isTrue();
        check(json.containsKey('blackScreenMode')).isTrue();
      });

      test('toJson serialises enums via .name', () {
        // Arrange
        const cfg = HardwareButtonConfig(
          buttonType: ButtonType.volumeDown,
          pressPattern: PressPattern.longPress,
        );

        // Act
        final json = cfg.toJson();

        // Assert
        check(json['buttonType']).equals('volumeDown');
        check(json['pressPattern']).equals('longPress');
      });
    });

    group('JSON round-trip', () {
      test('default config round-trips equal', () {
        // Arrange
        const cfg = HardwareButtonConfig();

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.hardwareButton,
          cfg.toJson(),
        );

        // Assert
        check(decoded).isA<HardwareButtonConfig>();
        check(decoded as HardwareButtonConfig).equals(cfg);
      });

      test('fully-populated config round-trips equal', () {
        // Arrange
        const cfg = HardwareButtonConfig(
          buttonType: ButtonType.volumeDown,
          pressPattern: PressPattern.longPress,
          pressCount: 8,
          longPressDurationSeconds: 3.5,
          targetStepIndex: 4,
          blackScreenMode: true,
        );

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.hardwareButton,
          cfg.toJson(),
        );

        // Assert
        check(decoded as HardwareButtonConfig).equals(cfg);
      });

      test('round-trip preserves PressPattern.repeatPress (G-005)', () {
        // Arrange
        const cfg = HardwareButtonConfig(
          pressPattern: PressPattern.repeatPress,
        );

        // Act
        final json = cfg.toJson();
        final decoded = StepConfig.fromJson(ChainStepType.hardwareButton, json);

        // Assert
        check(json['pressPattern']).equals('repeatPress');
        check(
          (decoded as HardwareButtonConfig).pressPattern,
        ).equals(PressPattern.repeatPress);
      });

      test('round-trip preserves PressPattern.longPress (G-005)', () {
        // Arrange
        const cfg = HardwareButtonConfig(pressPattern: PressPattern.longPress);

        // Act
        final json = cfg.toJson();
        final decoded = StepConfig.fromJson(ChainStepType.hardwareButton, json);

        // Assert
        check(json['pressPattern']).equals('longPress');
        check(
          (decoded as HardwareButtonConfig).pressPattern,
        ).equals(PressPattern.longPress);
      });

      test('round-trip preserves every ButtonType', () {
        for (final v in ButtonType.values) {
          // Arrange
          final cfg = HardwareButtonConfig(buttonType: v);

          // Act
          final decoded = StepConfig.fromJson(
            ChainStepType.hardwareButton,
            cfg.toJson(),
          );

          // Assert
          check((decoded as HardwareButtonConfig).buttonType).equals(v);
        }
      });

      test(
        'round-trip preserves longPressDurationSeconds at lower bound 1.0',
        () {
          // Arrange
          const cfg = HardwareButtonConfig(longPressDurationSeconds: 1.0);

          // Act
          final decoded = StepConfig.fromJson(
            ChainStepType.hardwareButton,
            cfg.toJson(),
          );

          // Assert
          check(
            (decoded as HardwareButtonConfig).longPressDurationSeconds,
          ).equals(1.0);
        },
      );

      test(
        'round-trip preserves longPressDurationSeconds at upper bound 10.0',
        () {
          // Arrange
          const cfg = HardwareButtonConfig(longPressDurationSeconds: 10.0);

          // Act
          final decoded = StepConfig.fromJson(
            ChainStepType.hardwareButton,
            cfg.toJson(),
          );

          // Assert
          check(
            (decoded as HardwareButtonConfig).longPressDurationSeconds,
          ).equals(10.0);
        },
      );

      test('round-trip preserves targetStepIndex == -1 sentinel', () {
        // Arrange
        const cfg = HardwareButtonConfig(targetStepIndex: -1);

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.hardwareButton,
          cfg.toJson(),
        );

        // Assert
        check((decoded as HardwareButtonConfig).targetStepIndex).equals(-1);
      });

      test('round-trip preserves explicit non-negative targetStepIndex', () {
        // Arrange
        const cfg = HardwareButtonConfig(targetStepIndex: 7);

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.hardwareButton,
          cfg.toJson(),
        );

        // Assert
        check((decoded as HardwareButtonConfig).targetStepIndex).equals(7);
      });

      test('fromJson with empty map produces all defaults', () {
        // Arrange + Act
        final decoded = StepConfig.fromJson(
          ChainStepType.hardwareButton,
          <String, dynamic>{},
        );

        // Assert
        check(
          decoded as HardwareButtonConfig,
        ).equals(const HardwareButtonConfig());
      });
    });

    group('copyWith + equality + hashCode', () {
      test('copyWith with no args returns equal instance', () {
        // Arrange
        const cfg = HardwareButtonConfig(pressCount: 7);

        // Act
        final copy = cfg.copyWith();

        // Assert
        check(copy).equals(cfg);
        check(copy.hashCode).equals(cfg.hashCode);
      });

      test('copyWith replaces only the specified field', () {
        // Arrange
        const cfg = HardwareButtonConfig();

        // Act
        final copy = cfg.copyWith(
          pressPattern: PressPattern.longPress,
          longPressDurationSeconds: 5.0,
        );

        // Assert
        check(copy.pressPattern).equals(PressPattern.longPress);
        check(copy.longPressDurationSeconds).equals(5.0);
        check(copy.buttonType).equals(cfg.buttonType);
        check(copy.pressCount).equals(cfg.pressCount);
      });

      test('two configs with identical fields are equal', () {
        // Arrange
        const a = HardwareButtonConfig(
          buttonType: ButtonType.volumeUp,
          pressCount: 5,
        );
        const b = HardwareButtonConfig(
          buttonType: ButtonType.volumeUp,
          pressCount: 5,
        );

        // Assert
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('configs with differing buttonType are not equal', () {
        // Arrange
        const a = HardwareButtonConfig(buttonType: ButtonType.volumeUp);
        const b = HardwareButtonConfig(buttonType: ButtonType.volumeDown);

        // Assert
        check(a == b).isFalse();
      });

      test('configs with differing pressPattern are not equal', () {
        // Arrange
        const a = HardwareButtonConfig(pressPattern: PressPattern.repeatPress);
        const b = HardwareButtonConfig(pressPattern: PressPattern.longPress);

        // Assert
        check(a == b).isFalse();
      });

      test('configs with differing targetStepIndex are not equal', () {
        // Arrange
        const a = HardwareButtonConfig(targetStepIndex: -1);
        const b = HardwareButtonConfig(targetStepIndex: 2);

        // Assert
        check(a == b).isFalse();
      });

      test('identical reference equals itself (short-circuit)', () {
        // Arrange
        const cfg = HardwareButtonConfig();

        // Assert
        check(cfg == cfg).isTrue();
      });

      test('config never equals an unrelated type', () {
        // Arrange
        const cfg = HardwareButtonConfig();

        // Assert
        check(cfg == const Object()).isFalse();
      });
    });
  });
}
