// Unit tests for [CallEmergencyConfig].
//
// Verifies constructor defaults, JSON round-trip, copyWith behaviour,
// equality / hashCode contract, and edge cases per
// docs/spec/03-data-models.md §CallEmergencyConfig (spec 03:543-553)
// and the confirmation-range note in docs/spec/06-settings.md:499
// (`confirmationDurationSeconds` range 1-30).
//
// ignore_for_file: avoid_redundant_argument_values
// Tests intentionally pass default values to verify round-trip and
// equality semantics.

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';

void main() {
  group('CallEmergencyConfig', () {
    group('constructor defaults', () {
      test('emergencyNumber defaults to null (inherits AppSettings '
          'emergencyCallNumber)', () {
        // Arrange + Act
        const cfg = CallEmergencyConfig();

        // Assert
        check(cfg.emergencyNumber).isNull();
      });

      test('sendLocationSmsFirst defaults to true', () {
        // Arrange + Act
        const cfg = CallEmergencyConfig();

        // Assert
        check(cfg.sendLocationSmsFirst).isTrue();
      });

      test('showConfirmation defaults to true (safety)', () {
        // Arrange + Act
        const cfg = CallEmergencyConfig();

        // Assert
        check(cfg.showConfirmation).isTrue();
      });

      test('confirmationDurationSeconds defaults to 5', () {
        // Arrange + Act
        const cfg = CallEmergencyConfig();

        // Assert
        check(cfg.confirmationDurationSeconds).equals(5);
      });

      test('blackScreenMode defaults to false', () {
        // Arrange + Act
        const cfg = CallEmergencyConfig();

        // Assert
        check(cfg.blackScreenMode).isFalse();
      });
    });

    group('field schema', () {
      test('toJson omits emergencyNumber when null', () {
        // Arrange
        const cfg = CallEmergencyConfig();

        // Act
        final json = cfg.toJson();

        // Assert
        check(json.containsKey('emergencyNumber')).isFalse();
      });

      test('toJson includes emergencyNumber when non-null', () {
        // Arrange
        const cfg = CallEmergencyConfig(emergencyNumber: '911');

        // Act
        final json = cfg.toJson();

        // Assert
        check(json['emergencyNumber']).equals('911');
      });

      test('toJson exposes all expected keys when fully populated', () {
        // Arrange
        const cfg = CallEmergencyConfig(
          emergencyNumber: '112',
          sendLocationSmsFirst: false,
          showConfirmation: false,
          confirmationDurationSeconds: 10,
          blackScreenMode: true,
        );

        // Act
        final json = cfg.toJson();

        // Assert
        check(json.containsKey('emergencyNumber')).isTrue();
        check(json.containsKey('sendLocationSmsFirst')).isTrue();
        check(json.containsKey('showConfirmation')).isTrue();
        check(json.containsKey('confirmationDurationSeconds')).isTrue();
        check(json.containsKey('blackScreenMode')).isTrue();
      });
    });

    group('JSON round-trip', () {
      test('default config round-trips equal', () {
        // Arrange
        const cfg = CallEmergencyConfig();

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.callEmergency,
          cfg.toJson(),
        );

        // Assert
        check(decoded).isA<CallEmergencyConfig>();
        check(decoded as CallEmergencyConfig).equals(cfg);
      });

      test('fully-populated config round-trips equal', () {
        // Arrange
        const cfg = CallEmergencyConfig(
          emergencyNumber: '999',
          sendLocationSmsFirst: false,
          showConfirmation: false,
          confirmationDurationSeconds: 15,
          blackScreenMode: true,
        );

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.callEmergency,
          cfg.toJson(),
        );

        // Assert
        check(decoded as CallEmergencyConfig).equals(cfg);
      });

      test('round-trip preserves null emergencyNumber', () {
        // Arrange
        const cfg = CallEmergencyConfig();

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.callEmergency,
          cfg.toJson(),
        );

        // Assert
        check((decoded as CallEmergencyConfig).emergencyNumber).isNull();
      });

      test('round-trip preserves non-null emergencyNumber', () {
        // Arrange
        const cfg = CallEmergencyConfig(emergencyNumber: '+15551234567');

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.callEmergency,
          cfg.toJson(),
        );

        // Assert
        check(
          (decoded as CallEmergencyConfig).emergencyNumber,
        ).equals('+15551234567');
      });

      test('round-trip preserves confirmationDurationSeconds at lower bound 1 '
          '(per spec 06:499)', () {
        // Arrange
        const cfg = CallEmergencyConfig(confirmationDurationSeconds: 1);

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.callEmergency,
          cfg.toJson(),
        );

        // Assert
        check(
          (decoded as CallEmergencyConfig).confirmationDurationSeconds,
        ).equals(1);
      });

      test('round-trip preserves confirmationDurationSeconds at upper bound 30 '
          '(per spec 06:499)', () {
        // Arrange
        const cfg = CallEmergencyConfig(confirmationDurationSeconds: 30);

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.callEmergency,
          cfg.toJson(),
        );

        // Assert
        check(
          (decoded as CallEmergencyConfig).confirmationDurationSeconds,
        ).equals(30);
      });

      test('round-trip preserves boolean flags toggled off', () {
        // Arrange
        const cfg = CallEmergencyConfig(
          sendLocationSmsFirst: false,
          showConfirmation: false,
        );

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.callEmergency,
          cfg.toJson(),
        );

        // Assert
        check((decoded as CallEmergencyConfig).sendLocationSmsFirst).isFalse();
        check(decoded.showConfirmation).isFalse();
      });

      test('fromJson with empty map produces all defaults', () {
        // Arrange + Act
        final decoded = StepConfig.fromJson(
          ChainStepType.callEmergency,
          <String, dynamic>{},
        );

        // Assert
        check(
          decoded as CallEmergencyConfig,
        ).equals(const CallEmergencyConfig());
      });
    });

    group('copyWith + equality + hashCode', () {
      test('copyWith with no args returns equal instance', () {
        // Arrange
        const cfg = CallEmergencyConfig(emergencyNumber: '911');

        // Act
        final copy = cfg.copyWith();

        // Assert
        check(copy).equals(cfg);
        check(copy.hashCode).equals(cfg.hashCode);
      });

      test('copyWith replaces only the specified field', () {
        // Arrange
        const cfg = CallEmergencyConfig();

        // Act
        final copy = cfg.copyWith(confirmationDurationSeconds: 7);

        // Assert
        check(copy.confirmationDurationSeconds).equals(7);
        check(copy.emergencyNumber).equals(cfg.emergencyNumber);
        check(copy.sendLocationSmsFirst).equals(cfg.sendLocationSmsFirst);
      });

      test('two configs with identical fields are equal', () {
        // Arrange
        const a = CallEmergencyConfig(
          emergencyNumber: '112',
          confirmationDurationSeconds: 5,
        );
        const b = CallEmergencyConfig(
          emergencyNumber: '112',
          confirmationDurationSeconds: 5,
        );

        // Assert
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('configs with differing emergencyNumber are not equal', () {
        // Arrange
        const a = CallEmergencyConfig(emergencyNumber: '112');
        const b = CallEmergencyConfig(emergencyNumber: '911');

        // Assert
        check(a == b).isFalse();
      });

      test(
        'configs with one null and one non-null emergencyNumber are not equal',
        () {
          // Arrange
          const a = CallEmergencyConfig();
          const b = CallEmergencyConfig(emergencyNumber: '112');

          // Assert
          check(a == b).isFalse();
        },
      );

      test('configs with differing showConfirmation are not equal', () {
        // Arrange
        const a = CallEmergencyConfig(showConfirmation: true);
        const b = CallEmergencyConfig(showConfirmation: false);

        // Assert
        check(a == b).isFalse();
      });

      test('identical reference equals itself (short-circuit)', () {
        // Arrange
        const cfg = CallEmergencyConfig();

        // Assert
        check(cfg == cfg).isTrue();
      });

      test('config never equals an unrelated type', () {
        // Arrange
        const cfg = CallEmergencyConfig();

        // Assert
        check(cfg == const Object()).isFalse();
      });
    });
  });
}
