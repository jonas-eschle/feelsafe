// Unit tests for [GpsLoggingConfig].
//
// Verifies constructor defaults, JSON round-trip, copyWith behaviour,
// equality / hashCode contract, and enum coverage per
// docs/spec/03-data-models.md §GpsLoggingConfig and Q21.
//
// The model is exactly {enabled, intervalSeconds, accuracy}: the former
// format / includeInSms / historyRetentionDays fields were trimmed
// (D-DATA-22, M6-P5) because nothing consumed them — location-in-SMS is
// per-step `SmsContactConfig.includeLocation`, `{location}` is always a
// Google Maps URL, and GPS history is in-memory only. The legacy-key
// tests below pin that old-shape JSON still parses cleanly.

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/gps_accuracy.dart';
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

      test('non-default values stored unchanged', () {
        // Arrange + Act
        const cfg = GpsLoggingConfig(
          enabled: false,
          intervalSeconds: 120,
          accuracy: GpsAccuracy.low,
        );

        // Assert
        check(cfg.enabled).isFalse();
        check(cfg.intervalSeconds).equals(120);
        check(cfg.accuracy).equals(GpsAccuracy.low);
      });

      test('off is the defaults with only enabled switched to false', () {
        // Assert — flipping enabled back on must yield the all-defaults
        // config, proving no other field deviates.
        check(GpsLoggingConfig.off.enabled).isFalse();
        check(
          GpsLoggingConfig.off.copyWith(enabled: true),
        ).equals(const GpsLoggingConfig());
      });
    });

    group('JSON round-trip', () {
      test('toJson contains exactly the three model keys '
          '(D-DATA-22 trim: no format/includeInSms/historyRetentionDays)', () {
        // Arrange
        const cfg = GpsLoggingConfig();

        // Act
        final json = cfg.toJson();

        // Assert
        check(
          json.keys.toSet(),
        ).deepEquals({'enabled', 'intervalSeconds', 'accuracy'});
      });

      test('toJson encodes accuracy by enum name', () {
        // Arrange
        const cfg = GpsLoggingConfig(accuracy: GpsAccuracy.medium);

        // Act
        final json = cfg.toJson();

        // Assert
        check(json['accuracy']).equals('medium');
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
        final json = <String, dynamic>{'intervalSeconds': 45.0};

        // Act
        final cfg = GpsLoggingConfig.fromJson(json);

        // Assert
        check(cfg.intervalSeconds).equals(45);
      });

      test('fromJson ignores the legacy includeInSms, format, and '
          'historyRetentionDays keys (old-shape backup gpsLogging blob; '
          'trimmed by D-DATA-22, lenient per the existing fromJson '
          'style)', () {
        // Arrange — the gpsLogging blob a pre-trim backup carries.
        final Map<String, dynamic> oldShape = {
          'enabled': false,
          'intervalSeconds': 90,
          'accuracy': 'medium',
          'format': 'openLocationCode',
          'includeInSms': false,
          'historyRetentionDays': 365,
        };

        // Act
        final restored = GpsLoggingConfig.fromJson(oldShape);

        // Assert — known keys parse; the legacy keys are dropped silently
        // and never re-emitted.
        check(restored).equals(
          const GpsLoggingConfig(
            enabled: false,
            intervalSeconds: 90,
            accuracy: GpsAccuracy.medium,
          ),
        );
        check(restored.toJson().containsKey('format')).isFalse();
        check(restored.toJson().containsKey('includeInSms')).isFalse();
        check(restored.toJson().containsKey('historyRetentionDays')).isFalse();
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
        );

        // Assert
        check(next.enabled).isFalse();
        check(next.intervalSeconds).equals(5);
        check(next.accuracy).equals(GpsAccuracy.low);
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
        const b = GpsLoggingConfig.off;

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

      test('hashCode equals when configs are equal', () {
        // Arrange
        const a = GpsLoggingConfig(intervalSeconds: 7, enabled: false);
        const b = GpsLoggingConfig(intervalSeconds: 7, enabled: false);

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
    });
  });
}
