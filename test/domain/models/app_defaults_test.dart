// Unit tests for [AppDefaults].
//
// Verifies the default values per docs/spec/03-data-models.md
// §AppDefaults, JSON round-trip stability, copyWith semantics, and
// the equality / hashCode contract. Since bug #14 the model carries NO
// reminder templates — the Drift `reminder_templates` table is the single
// source of truth for globals — and `fromJson` must ignore the legacy
// `templates` key found in old-shape backups.

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/stealth_icon_preset.dart';
import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';

void main() {
  group('AppDefaults', () {
    group('defaults', () {
      test('defaultDistressModeId defaults to null', () {
        const defaults = AppDefaults();

        check(defaults.defaultDistressModeId).isNull();
      });

      test('gpsLogging defaults to a GpsLoggingConfig with enabled = true', () {
        const defaults = AppDefaults();

        check(defaults.gpsLogging).equals(const GpsLoggingConfig());
        check(defaults.gpsLogging.enabled).isTrue();
      });

      test('stealth defaults to a StealthConfig with enabled = false', () {
        const defaults = AppDefaults();

        check(defaults.stealth).equals(const StealthConfig());
        check(defaults.stealth.enabled).isFalse();
      });

      test('eventDefaults defaults to a non-null EventDefaults instance', () {
        const defaults = AppDefaults();

        check(defaults.eventDefaults).equals(const EventDefaults());
      });

      test('default stealth fakeName is "Music"', () {
        // Sanity-check Q20 propagation through AppDefaults.
        const defaults = AppDefaults();

        check(defaults.stealth.fakeName).equals('Music');
        check(defaults.stealth.fakeIcon).equals(StealthIconPreset.music);
      });
    });

    group('JSON round-trip', () {
      test('default instance round-trips', () {
        // Arrange
        const original = AppDefaults();

        // Act
        final restored = AppDefaults.fromJson(original.toJson());

        // Assert
        check(restored).equals(original);
      });

      test('defaultDistressModeId round-trips when set', () {
        const defaults = AppDefaults(defaultDistressModeId: 'distress-mode-1');

        final restored = AppDefaults.fromJson(defaults.toJson());

        check(restored.defaultDistressModeId).equals('distress-mode-1');
      });

      test('defaultDistressModeId is omitted from JSON when null', () {
        // Arrange
        const defaults = AppDefaults();

        // Act
        final json = defaults.toJson();

        // Assert — null values are not serialised.
        check(json.containsKey('defaultDistressModeId')).isFalse();
      });

      test('fromJson IGNORES a legacy templates key (old-shape backup '
          'settings blob) — lenient per the existing fromJson style; the '
          'Drift DAO restored from payload[templates] is the only template '
          'carrier (bug #14)', () {
        // Arrange — the settings blob an old-shape backup carries.
        final Map<String, dynamic> oldShape = {
          'templates': <dynamic>[
            {
              'id': 'tpl-legacy',
              'name': 'Calendar',
              'title': 'Calendar Event',
              'body': 'Meeting with Alex at 3 PM',
              'confirmationType': 'tapButton',
              'isCustom': false,
              'displayStyle': 'fullScreen',
              'isGlobal': true,
            },
          ],
          'defaultDistressModeId': 'd-1',
        };

        // Act
        final restored = AppDefaults.fromJson(oldShape);

        // Assert — known keys parse; the legacy key is dropped silently and
        // never re-emitted.
        check(restored.defaultDistressModeId).equals('d-1');
        check(restored.toJson().containsKey('templates')).isFalse();
      });

      test('non-default GpsLoggingConfig round-trips through JSON', () {
        // Arrange
        const defaults = AppDefaults(
          gpsLogging: GpsLoggingConfig(enabled: false, intervalSeconds: 60),
        );

        // Act
        final restored = AppDefaults.fromJson(defaults.toJson());

        // Assert
        check(restored.gpsLogging.enabled).isFalse();
        check(restored.gpsLogging.intervalSeconds).equals(60);
      });

      test('non-default StealthConfig round-trips through JSON', () {
        // Arrange
        const defaults = AppDefaults(
          stealth: StealthConfig(enabled: true, fakeName: 'Notes'),
        );

        // Act
        final restored = AppDefaults.fromJson(defaults.toJson());

        // Assert
        check(restored.stealth.enabled).isTrue();
        check(restored.stealth.fakeName).equals('Notes');
      });

      test('fromJson on empty map fills in all defaults', () {
        // Arrange
        final Map<String, dynamic> json = {};

        // Act
        final restored = AppDefaults.fromJson(json);

        // Assert
        check(restored).equals(const AppDefaults());
      });

      test('toJson never emits a templates key — the settings blob must not '
          'duplicate the DAO template store (bug #14)', () {
        // Arrange
        const defaults = AppDefaults();

        // Act
        final json = defaults.toJson();

        // Assert
        check(json.containsKey('templates')).isFalse();
      });
    });

    group('copyWith', () {
      test('copyWith() with no args returns an equivalent instance', () {
        const original = AppDefaults();

        final copy = original.copyWith();

        check(copy).equals(original);
      });

      test('copyWith can replace gpsLogging', () {
        const original = AppDefaults();
        const newGps = GpsLoggingConfig.off;

        final copy = original.copyWith(gpsLogging: newGps);

        check(copy.gpsLogging).equals(newGps);
        check(copy.stealth).equals(original.stealth);
      });

      test('copyWith can replace stealth', () {
        const original = AppDefaults();
        const newStealth = StealthConfig(enabled: true);

        final copy = original.copyWith(stealth: newStealth);

        check(copy.stealth).equals(newStealth);
      });

      test('copyWith can replace eventDefaults', () {
        const original = AppDefaults();
        final newEd = original.eventDefaults.copyWith();
        final copy = original.copyWith(eventDefaults: newEd);

        check(copy.eventDefaults).equals(newEd);
      });

      test('copyWith can replace defaultDistressModeId', () {
        const original = AppDefaults();

        final copy = original.copyWith(defaultDistressModeId: 'd-99');

        check(copy.defaultDistressModeId).equals('d-99');
      });

      test('copyWith preserves nested gpsLogging identity when not '
          'replaced', () {
        const customGps = GpsLoggingConfig(intervalSeconds: 17);
        const original = AppDefaults(gpsLogging: customGps);

        final copy = original.copyWith(defaultDistressModeId: 'whatever');

        check(identical(copy.gpsLogging, customGps)).isTrue();
      });
    });

    group('equality and hashCode', () {
      test('two default instances are equal', () {
        const a = AppDefaults();
        const b = AppDefaults();

        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('reflexive: equals itself', () {
        const defaults = AppDefaults();

        check(defaults).equals(defaults);
      });

      test('symmetric: a == b implies b == a', () {
        const a = AppDefaults(defaultDistressModeId: 'x');
        const b = AppDefaults(defaultDistressModeId: 'x');

        check(a == b).isTrue();
        check(b == a).isTrue();
      });

      test('inequality on differing defaultDistressModeId', () {
        const a = AppDefaults();
        const b = AppDefaults(defaultDistressModeId: 'd');

        check(a == b).isFalse();
      });

      test('inequality on differing gpsLogging', () {
        const a = AppDefaults();
        const b = AppDefaults(gpsLogging: GpsLoggingConfig.off);

        check(a == b).isFalse();
      });

      test('inequality on differing stealth', () {
        const a = AppDefaults();
        const b = AppDefaults(stealth: StealthConfig(enabled: true));

        check(a == b).isFalse();
      });

      test('hashCode is stable across calls', () {
        const defaults = AppDefaults(defaultDistressModeId: 'd');

        check(defaults.hashCode).equals(defaults.hashCode);
      });
    });
  });
}
