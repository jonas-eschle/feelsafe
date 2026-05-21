// Unit tests for [PhoneCallContactConfig].
//
// Verifies constructor defaults, JSON round-trip, copyWith behaviour,
// equality / hashCode contract, and edge cases per
// docs/spec/03-data-models.md §PhoneCallContactConfig (spec 03:431-444).
// `blackScreenMode` parity with other configs was added in
// commit 936515d.

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/log_gps_override.dart';

void main() {
  group('PhoneCallContactConfig', () {
    group('constructor defaults', () {
      test('contactId defaults to null (first-sorted contact)', () {
        // Arrange + Act
        const cfg = PhoneCallContactConfig();

        // Assert
        check(cfg.contactId).isNull();
      });

      test('alternativeContactIds defaults to empty list', () {
        // Arrange + Act
        const cfg = PhoneCallContactConfig();

        // Assert
        check(cfg.alternativeContactIds).isEmpty();
      });

      test('logGps defaults to useDefault', () {
        // Arrange + Act
        const cfg = PhoneCallContactConfig();

        // Assert
        check(cfg.logGps).equals(LogGpsOverride.useDefault);
      });

      test('blackScreenMode defaults to false (parity fix in 936515d)', () {
        // Arrange + Act
        const cfg = PhoneCallContactConfig();

        // Assert
        check(cfg.blackScreenMode).isFalse();
      });
    });

    group('field schema', () {
      test('toJson omits contactId when null', () {
        // Arrange
        const cfg = PhoneCallContactConfig();

        // Act
        final json = cfg.toJson();

        // Assert
        check(json.containsKey('contactId')).isFalse();
      });

      test('toJson includes contactId when non-null', () {
        // Arrange
        const cfg = PhoneCallContactConfig(contactId: 'contact-abc');

        // Act
        final json = cfg.toJson();

        // Assert
        check(json['contactId']).equals('contact-abc');
      });

      test('toJson includes blackScreenMode key', () {
        // Arrange
        const cfg = PhoneCallContactConfig();

        // Act
        final json = cfg.toJson();

        // Assert
        check(json.containsKey('blackScreenMode')).isTrue();
      });

      test('toJson includes alternativeContactIds key as array', () {
        // Arrange
        const cfg = PhoneCallContactConfig(alternativeContactIds: ['a', 'b']);

        // Act
        final json = cfg.toJson();

        // Assert
        check(json['alternativeContactIds']).isA<List<dynamic>>();
        check(
          json['alternativeContactIds'] as List<dynamic>,
        ).deepEquals(['a', 'b']);
      });

      test('toJson serialises logGps via enum name', () {
        // Arrange
        const cfg = PhoneCallContactConfig(logGps: LogGpsOverride.forceOff);

        // Act
        final json = cfg.toJson();

        // Assert
        check(json['logGps']).equals('forceOff');
      });
    });

    group('JSON round-trip', () {
      test('default config round-trips equal', () {
        // Arrange
        const cfg = PhoneCallContactConfig();

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.phoneCallContact,
          cfg.toJson(),
        );

        // Assert
        check(decoded).isA<PhoneCallContactConfig>();
        check(decoded as PhoneCallContactConfig).equals(cfg);
      });

      test('fully-populated config round-trips equal', () {
        // Arrange
        const cfg = PhoneCallContactConfig(
          contactId: 'primary',
          alternativeContactIds: ['alt-1', 'alt-2', 'alt-3'],
          logGps: LogGpsOverride.forceOn,
          blackScreenMode: true,
        );

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.phoneCallContact,
          cfg.toJson(),
        );

        // Assert
        check(decoded as PhoneCallContactConfig).equals(cfg);
      });

      test('round-trip preserves null contactId', () {
        // Arrange
        const cfg = PhoneCallContactConfig();

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.phoneCallContact,
          cfg.toJson(),
        );

        // Assert
        check((decoded as PhoneCallContactConfig).contactId).isNull();
      });

      test('round-trip preserves alternativeContactIds order', () {
        // Arrange
        const cfg = PhoneCallContactConfig(
          alternativeContactIds: ['z', 'a', 'm'],
        );

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.phoneCallContact,
          cfg.toJson(),
        );

        // Assert
        check(
          (decoded as PhoneCallContactConfig).alternativeContactIds,
        ).deepEquals(['z', 'a', 'm']);
      });

      test('round-trip preserves every LogGpsOverride value', () {
        for (final v in LogGpsOverride.values) {
          // Arrange
          final cfg = PhoneCallContactConfig(logGps: v);

          // Act
          final decoded = StepConfig.fromJson(
            ChainStepType.phoneCallContact,
            cfg.toJson(),
          );

          // Assert
          check((decoded as PhoneCallContactConfig).logGps).equals(v);
        }
      });

      test('round-trip preserves blackScreenMode true', () {
        // Arrange
        const cfg = PhoneCallContactConfig(blackScreenMode: true);

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.phoneCallContact,
          cfg.toJson(),
        );

        // Assert
        check((decoded as PhoneCallContactConfig).blackScreenMode).isTrue();
      });

      test('fromJson with empty map produces all defaults', () {
        // Arrange + Act
        final decoded = StepConfig.fromJson(
          ChainStepType.phoneCallContact,
          <String, dynamic>{},
        );

        // Assert
        check(decoded).isA<PhoneCallContactConfig>();
        check(
          decoded as PhoneCallContactConfig,
        ).equals(const PhoneCallContactConfig());
      });

      test('fromJson uses ChainStepType.phoneCallContact discriminator', () {
        // Arrange
        const cfg = PhoneCallContactConfig(contactId: 'x');

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.phoneCallContact,
          cfg.toJson(),
        );

        // Assert
        check(decoded).isA<PhoneCallContactConfig>();
      });
    });

    group('copyWith + equality + hashCode', () {
      test('copyWith with no args returns equal instance', () {
        // Arrange
        const cfg = PhoneCallContactConfig(contactId: 'abc');

        // Act
        final copy = cfg.copyWith();

        // Assert
        check(copy).equals(cfg);
        check(copy.hashCode).equals(cfg.hashCode);
      });

      test('copyWith replaces only the specified field', () {
        // Arrange
        const cfg = PhoneCallContactConfig();

        // Act
        final copy = cfg.copyWith(blackScreenMode: true);

        // Assert
        check(copy.blackScreenMode).isTrue();
        check(copy.contactId).equals(cfg.contactId);
        check(copy.logGps).equals(cfg.logGps);
      });

      test('two configs with identical fields are equal', () {
        // Arrange
        const a = PhoneCallContactConfig(
          contactId: 'c',
          alternativeContactIds: ['x', 'y'],
          logGps: LogGpsOverride.forceOff,
        );
        const b = PhoneCallContactConfig(
          contactId: 'c',
          alternativeContactIds: ['x', 'y'],
          logGps: LogGpsOverride.forceOff,
        );

        // Assert
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('configs with differing contactId are not equal', () {
        // Arrange
        const a = PhoneCallContactConfig(contactId: 'x');
        const b = PhoneCallContactConfig(contactId: 'y');

        // Assert
        check(a == b).isFalse();
      });

      test(
        'configs with differing alternativeContactIds order are not equal',
        () {
          // Arrange
          const a = PhoneCallContactConfig(alternativeContactIds: ['x', 'y']);
          const b = PhoneCallContactConfig(alternativeContactIds: ['y', 'x']);

          // Assert
          check(a == b).isFalse();
        },
      );

      test(
        'configs with differing alternativeContactIds length are not equal',
        () {
          // Arrange
          const a = PhoneCallContactConfig(alternativeContactIds: ['x']);
          const b = PhoneCallContactConfig(alternativeContactIds: ['x', 'y']);

          // Assert
          check(a == b).isFalse();
        },
      );

      test('identical reference equals itself (short-circuit)', () {
        // Arrange
        const cfg = PhoneCallContactConfig();

        // Assert
        check(cfg == cfg).isTrue();
      });

      test('config never equals an unrelated type', () {
        // Arrange
        const cfg = PhoneCallContactConfig();

        // Assert
        check(cfg == const Object()).isFalse();
      });
    });
  });
}
