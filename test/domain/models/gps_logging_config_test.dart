// Unit tests for [GpsLoggingConfig].
//
// Verifies constructor defaults, JSON round-trip, copyWith behaviour,
// equality / hashCode contract, and enum coverage per
// docs/spec/03-data-models.md §GpsLoggingConfig and Q21.

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/gps_accuracy.dart';
import 'package:guardianangela/domain/enums/gps_format.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';

void main() {
  group('GpsLoggingConfig', () {
    group('defaults', () {
      test('enabled defaults to true (master toggle)', () {
        // Arrange + Act
        const cfg = GpsLoggingConfig();

        // Assert
        check(cfg.enabled).isTrue();
      });

      test('intervalSeconds defaults to 30 (Q21)', () {
        // Arrange + Act
        const cfg = GpsLoggingConfig();

        // Assert
        check(cfg.intervalSeconds).equals(30);
      });

      test('accuracy defaults to GpsAccuracy.high (Q21)', () {
        // Arrange + Act
        const cfg = GpsLoggingConfig();

        // Assert
        check(cfg.accuracy).equals(GpsAccuracy.high);
      });

      test('format defaults to GpsFormat.decimal (Q21)', () {
        // Arrange + Act
        const cfg = GpsLoggingConfig();

        // Assert
        check(cfg.format).equals(GpsFormat.decimal);
      });

      test('includeInSms defaults to true', () {
        // Arrange + Act
        const cfg = GpsLoggingConfig();

        // Assert
        check(cfg.includeInSms).isTrue();
      });

      test('historyRetentionDays defaults to 30', () {
        // Arrange + Act
        const cfg = GpsLoggingConfig();

        // Assert
        check(cfg.historyRetentionDays).equals(30);
      });

      test('non-default values stored unchanged', () {
        // Arrange + Act
        const cfg = GpsLoggingConfig(
          enabled: false,
          intervalSeconds: 120,
          accuracy: GpsAccuracy.low,
          format: GpsFormat.dms,
          includeInSms: false,
          historyRetentionDays: 7,
        );

        // Assert
        check(cfg.enabled).isFalse();
        check(cfg.intervalSeconds).equals(120);
        check(cfg.accuracy).equals(GpsAccuracy.low);
        check(cfg.format).equals(GpsFormat.dms);
        check(cfg.includeInSms).isFalse();
        check(cfg.historyRetentionDays).equals(7);
      });
    });

    group('JSON round-trip', () {
      test('toJson contains all six keys', () {
        // Arrange
        const cfg = GpsLoggingConfig();

        // Act
        final json = cfg.toJson();

        // Assert
        check(json).containsKey('enabled');
        check(json).containsKey('intervalSeconds');
        check(json).containsKey('accuracy');
        check(json).containsKey('format');
        check(json).containsKey('includeInSms');
        check(json).containsKey('historyRetentionDays');
      });

      test('toJson encodes accuracy by enum name', () {
        // Arrange
        const cfg = GpsLoggingConfig(accuracy: GpsAccuracy.medium);

        // Act
        final json = cfg.toJson();

        // Assert
        check(json['accuracy']).equals('medium');
      });

      test('toJson encodes format by enum name', () {
        // Arrange
        const cfg = GpsLoggingConfig(format: GpsFormat.openLocationCode);

        // Act
        final json = cfg.toJson();

        // Assert
        check(json['format']).equals('openLocationCode');
      });

      test('fromJson(toJson) round-trips default config', () {
        // Arrange
        const original = GpsLoggingConfig();

        // Act
        final restored = GpsLoggingConfig.fromJson(original.toJson());

        // Assert
        check(restored).equals(original);
      });

      test('fromJson(toJson) round-trips fully customised config', () {
        // Arrange
        const original = GpsLoggingConfig(
          enabled: false,
          intervalSeconds: 90,
          accuracy: GpsAccuracy.medium,
          format: GpsFormat.openLocationCode,
          includeInSms: false,
          historyRetentionDays: 365,
        );

        // Act
        final restored = GpsLoggingConfig.fromJson(original.toJson());

        // Assert
        check(restored).equals(original);
      });

      test('fromJson applies all defaults to empty map', () {
        // Arrange + Act
        final cfg = GpsLoggingConfig.fromJson(const <String, dynamic>{});

        // Assert — matches default constructor
        check(cfg).equals(const GpsLoggingConfig());
      });

      test('fromJson tolerates numeric ints encoded as doubles', () {
        // Arrange — JSON decoders sometimes give num instead of int
        final json = <String, dynamic>{
          'intervalSeconds': 45.0,
          'historyRetentionDays': 14.0,
        };

        // Act
        final cfg = GpsLoggingConfig.fromJson(json);

        // Assert
        check(cfg.intervalSeconds).equals(45);
        check(cfg.historyRetentionDays).equals(14);
      });

      test('all GpsAccuracy values round-trip via JSON', () {
        for (final value in GpsAccuracy.values) {
          // Arrange
          final original = GpsLoggingConfig(accuracy: value);

          // Act
          final restored = GpsLoggingConfig.fromJson(original.toJson());

          // Assert
          check(restored.accuracy).equals(value);
        }
      });

      test('all GpsFormat values round-trip via JSON', () {
        for (final value in GpsFormat.values) {
          // Arrange
          final original = GpsLoggingConfig(format: value);

          // Act
          final restored = GpsLoggingConfig.fromJson(original.toJson());

          // Assert
          check(restored.format).equals(value);
        }
      });
    });

    group('copyWith', () {
      test('with no arguments returns equal object', () {
        // Arrange
        const base = GpsLoggingConfig();

        // Act
        final copy = base.copyWith();

        // Assert
        check(copy).equals(base);
      });

      test('replaces enabled only', () {
        // Arrange
        const base = GpsLoggingConfig();

        // Act
        final next = base.copyWith(enabled: false);

        // Assert
        check(next.enabled).isFalse();
        check(next.intervalSeconds).equals(base.intervalSeconds);
        check(next.accuracy).equals(base.accuracy);
        check(next.format).equals(base.format);
        check(next.includeInSms).equals(base.includeInSms);
        check(next.historyRetentionDays).equals(base.historyRetentionDays);
      });

      test('replaces intervalSeconds only', () {
        // Arrange
        const base = GpsLoggingConfig();

        // Act
        final next = base.copyWith(intervalSeconds: 60);

        // Assert
        check(next.intervalSeconds).equals(60);
        check(next.enabled).equals(base.enabled);
      });

      test('replaces accuracy only', () {
        // Arrange
        const base = GpsLoggingConfig();

        // Act
        final next = base.copyWith(accuracy: GpsAccuracy.low);

        // Assert
        check(next.accuracy).equals(GpsAccuracy.low);
        check(next.format).equals(base.format);
      });

      test('replaces format only', () {
        // Arrange
        const base = GpsLoggingConfig();

        // Act
        final next = base.copyWith(format: GpsFormat.dms);

        // Assert
        check(next.format).equals(GpsFormat.dms);
        check(next.accuracy).equals(base.accuracy);
      });

      test('replaces includeInSms only', () {
        // Arrange
        const base = GpsLoggingConfig();

        // Act
        final next = base.copyWith(includeInSms: false);

        // Assert
        check(next.includeInSms).isFalse();
        check(next.enabled).equals(base.enabled);
      });

      test('replaces historyRetentionDays only', () {
        // Arrange
        const base = GpsLoggingConfig();

        // Act
        final next = base.copyWith(historyRetentionDays: 14);

        // Assert
        check(next.historyRetentionDays).equals(14);
        check(next.intervalSeconds).equals(base.intervalSeconds);
      });

      test('replaces all fields together', () {
        // Arrange
        const base = GpsLoggingConfig();

        // Act
        final next = base.copyWith(
          enabled: false,
          intervalSeconds: 5,
          accuracy: GpsAccuracy.low,
          format: GpsFormat.dms,
          includeInSms: false,
          historyRetentionDays: 1,
        );

        // Assert
        check(next.enabled).isFalse();
        check(next.intervalSeconds).equals(5);
        check(next.accuracy).equals(GpsAccuracy.low);
        check(next.format).equals(GpsFormat.dms);
        check(next.includeInSms).isFalse();
        check(next.historyRetentionDays).equals(1);
      });
    });

    group('equality + hashCode', () {
      test('two identically-constructed configs are equal', () {
        // Arrange
        const a = GpsLoggingConfig();
        const b = GpsLoggingConfig();

        // Act + Assert
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('equality is reflexive', () {
        // Arrange
        const cfg = GpsLoggingConfig();

        // Act + Assert
        check(cfg).equals(cfg);
      });

      test('equality is symmetric and transitive', () {
        // Arrange
        const a = GpsLoggingConfig(intervalSeconds: 60);
        const b = GpsLoggingConfig(intervalSeconds: 60);
        const c = GpsLoggingConfig(intervalSeconds: 60);

        // Assert
        check(a == b).isTrue();
        check(b == a).isTrue();
        check(b == c).isTrue();
        check(a == c).isTrue();
      });

      test('different enabled breaks equality', () {
        // Arrange
        const a = GpsLoggingConfig();
        const b = GpsLoggingConfig(enabled: false);

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different intervalSeconds breaks equality', () {
        // Arrange
        const a = GpsLoggingConfig();
        const b = GpsLoggingConfig(intervalSeconds: 31);

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different accuracy breaks equality', () {
        // Arrange
        const a = GpsLoggingConfig();
        const b = GpsLoggingConfig(accuracy: GpsAccuracy.low);

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different format breaks equality', () {
        // Arrange
        const a = GpsLoggingConfig();
        const b = GpsLoggingConfig(format: GpsFormat.dms);

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different includeInSms breaks equality', () {
        // Arrange
        const a = GpsLoggingConfig();
        const b = GpsLoggingConfig(includeInSms: false);

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different historyRetentionDays breaks equality', () {
        // Arrange
        const a = GpsLoggingConfig();
        const b = GpsLoggingConfig(historyRetentionDays: 90);

        // Act + Assert
        check(a == b).isFalse();
      });

      test('hashCode equals when configs are equal', () {
        // Arrange
        const a = GpsLoggingConfig(intervalSeconds: 7, includeInSms: false);
        const b = GpsLoggingConfig(intervalSeconds: 7, includeInSms: false);

        // Act + Assert
        check(a.hashCode).equals(b.hashCode);
      });

      test('not equal to objects of a different type', () {
        // Arrange
        const cfg = GpsLoggingConfig();

        // Act + Assert
        check(cfg == const Object()).isFalse();
      });
    });

    group('edge cases', () {
      test('intervalSeconds can hold large positive values', () {
        // Arrange + Act
        const cfg = GpsLoggingConfig(intervalSeconds: 3600);

        // Assert
        check(cfg.intervalSeconds).equals(3600);
      });

      test('historyRetentionDays can hold large positive values', () {
        // Arrange + Act
        const cfg = GpsLoggingConfig(historyRetentionDays: 365);

        // Assert
        check(cfg.historyRetentionDays).equals(365);
      });
    });
  });
}
