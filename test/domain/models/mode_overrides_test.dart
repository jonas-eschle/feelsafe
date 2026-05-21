// Unit tests for [ModeOverrides].
//
// Verifies that every field defaults to null (the inheritance
// sentinel) per docs/spec/03-data-models.md §ModeOverrides,
// JSON round-trip stability, copyWith semantics, and the equality /
// hashCode contract (including list-content comparison for
// [localTemplates]).

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';
import 'package:guardianangela/domain/models/mode_overrides.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';

ReminderTemplate _localTemplate({
  String id = 'mode-tpl-1',
  String name = 'Local Calendar',
}) => ReminderTemplate(
  id: id,
  name: name,
  title: 'Mode-local Calendar Event',
  body: 'Meeting with Alex at 3 PM',
  confirmationType: ConfirmationType.tapButton,
  isCustom: true,
  displayStyle: ReminderDisplayStyle.fullScreen,
  isGlobal: false,
);

void main() {
  group('ModeOverrides', () {
    group('defaults (inheritance sentinels)', () {
      test('gpsLogging defaults to null (inherit AppDefaults.gpsLogging)', () {
        const overrides = ModeOverrides();

        check(overrides.gpsLogging).isNull();
      });

      test('stealth defaults to null (inherit AppDefaults.stealth)', () {
        const overrides = ModeOverrides();

        check(overrides.stealth).isNull();
      });

      test('localTemplates defaults to null (not empty list — null IS the '
          'inheritance sentinel)', () {
        // Per spec 03 §ModeOverrides: a null localTemplates is the
        // "inherit only" signal. An empty list would still be a
        // user-set value (append nothing).
        const overrides = ModeOverrides();

        check(overrides.localTemplates).isNull();
      });

      test(
        'eventDefaults defaults to null (inherit AppDefaults.eventDefaults)',
        () {
          const overrides = ModeOverrides();

          check(overrides.eventDefaults).isNull();
        },
      );

      test('empty ModeOverrides means "inherit all four fields"', () {
        const overrides = ModeOverrides();

        check(overrides.gpsLogging).isNull();
        check(overrides.stealth).isNull();
        check(overrides.localTemplates).isNull();
        check(overrides.eventDefaults).isNull();
      });
    });

    group('JSON round-trip', () {
      test('default (all-null) instance round-trips', () {
        // Arrange
        const original = ModeOverrides();

        // Act
        final restored = ModeOverrides.fromJson(original.toJson());

        // Assert
        check(restored).equals(original);
      });

      test('default ModeOverrides serialises to an empty JSON map', () {
        // Arrange
        const overrides = ModeOverrides();

        // Act
        final json = overrides.toJson();

        // Assert — nulls are stripped so we can tell "set" vs "inherit"
        // apart in the persisted form.
        check(json).isEmpty();
      });

      test('non-null gpsLogging round-trips', () {
        // Arrange
        const overrides = ModeOverrides(
          gpsLogging: GpsLoggingConfig(enabled: false, intervalSeconds: 90),
        );

        // Act
        final restored = ModeOverrides.fromJson(overrides.toJson());

        // Assert
        check(restored.gpsLogging).isNotNull();
        check(restored.gpsLogging!.enabled).isFalse();
        check(restored.gpsLogging!.intervalSeconds).equals(90);
      });

      test('non-null stealth round-trips', () {
        // Arrange
        const overrides = ModeOverrides(
          stealth: StealthConfig(enabled: true, fakeName: 'Notes'),
        );

        // Act
        final restored = ModeOverrides.fromJson(overrides.toJson());

        // Assert
        check(restored.stealth).isNotNull();
        check(restored.stealth!.enabled).isTrue();
        check(restored.stealth!.fakeName).equals('Notes');
      });

      test('non-null eventDefaults round-trips', () {
        // Arrange
        final overrides = ModeOverrides(
          eventDefaults: const EventDefaults().copyWith(),
        );

        // Act
        final restored = ModeOverrides.fromJson(overrides.toJson());

        // Assert
        check(restored.eventDefaults).isNotNull();
        check(restored.eventDefaults).equals(const EventDefaults());
      });

      test('non-null localTemplates list round-trips contents in order', () {
        // Arrange
        final overrides = ModeOverrides(
          localTemplates: [
            _localTemplate(id: 'a'),
            _localTemplate(id: 'b'),
          ],
        );

        // Act
        final restored = ModeOverrides.fromJson(overrides.toJson());

        // Assert
        check(restored.localTemplates).isNotNull();
        check(restored.localTemplates!.length).equals(2);
        check(restored.localTemplates![0].id).equals('a');
        check(restored.localTemplates![1].id).equals('b');
      });

      test('empty localTemplates list survives round-trip as empty (not '
          'null)', () {
        // Arrange — explicit empty list means "override with zero
        // local templates", distinct from null = "inherit only".
        const overrides = ModeOverrides(localTemplates: []);

        // Act
        final restored = ModeOverrides.fromJson(overrides.toJson());

        // Assert
        check(restored.localTemplates).isNotNull();
        check(restored.localTemplates!).isEmpty();
      });

      test('fromJson on empty map yields all-null instance', () {
        // Arrange
        final Map<String, dynamic> json = {};

        // Act
        final restored = ModeOverrides.fromJson(json);

        // Assert
        check(restored).equals(const ModeOverrides());
      });
    });

    group('copyWith', () {
      test('copyWith() with no args returns an equivalent instance', () {
        // Arrange
        const original = ModeOverrides();

        // Act
        final copy = original.copyWith();

        // Assert
        check(copy).equals(original);
      });

      test('copyWith can set gpsLogging', () {
        const original = ModeOverrides();
        const newGps = GpsLoggingConfig(enabled: false);

        final copy = original.copyWith(gpsLogging: newGps);

        check(copy.gpsLogging).equals(newGps);
        check(copy.stealth).isNull();
      });

      test('copyWith can set stealth', () {
        const original = ModeOverrides();
        const newStealth = StealthConfig(enabled: true);

        final copy = original.copyWith(stealth: newStealth);

        check(copy.stealth).equals(newStealth);
      });

      test('copyWith can set localTemplates', () {
        const original = ModeOverrides();
        final templates = [_localTemplate()];

        final copy = original.copyWith(localTemplates: templates);

        check(copy.localTemplates).isNotNull();
        check(copy.localTemplates!.length).equals(1);
        check(copy.localTemplates![0].id).equals('mode-tpl-1');
      });

      test('copyWith can set eventDefaults', () {
        const original = ModeOverrides();
        const newEd = EventDefaults();

        final copy = original.copyWith(eventDefaults: newEd);

        check(copy.eventDefaults).equals(newEd);
      });

      test('copyWith preserves existing non-null field when not replaced', () {
        // Arrange
        const gps = GpsLoggingConfig(intervalSeconds: 42);
        const original = ModeOverrides(gpsLogging: gps);

        // Act
        final copy = original.copyWith(
          stealth: const StealthConfig(enabled: true),
        );

        // Assert
        check(identical(copy.gpsLogging, gps)).isTrue();
        check(copy.stealth).isNotNull();
      });

      test('copyWith does NOT clear a non-null field with explicit null', () {
        // The copyWith implementation uses `arg ?? this.field`, so passing
        // null cannot clear a previously-set field. This is the existing
        // pattern across all model copyWith methods in this codebase.
        const original = ModeOverrides(
          gpsLogging: GpsLoggingConfig(enabled: false),
        );

        // Act
        final copy = original.copyWith();

        // Assert
        check(copy.gpsLogging).equals(original.gpsLogging);
      });
    });

    group('equality and hashCode', () {
      test('two default (all-null) instances are equal', () {
        const a = ModeOverrides();
        const b = ModeOverrides();

        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('reflexive: equals itself', () {
        const overrides = ModeOverrides();

        check(overrides).equals(overrides);
      });

      test('symmetric: a == b implies b == a', () {
        const a = ModeOverrides(
          gpsLogging: GpsLoggingConfig(intervalSeconds: 60),
        );
        const b = ModeOverrides(
          gpsLogging: GpsLoggingConfig(intervalSeconds: 60),
        );

        check(a == b).isTrue();
        check(b == a).isTrue();
      });

      test('inequality on differing gpsLogging', () {
        const a = ModeOverrides();
        const b = ModeOverrides(gpsLogging: GpsLoggingConfig(enabled: false));

        check(a == b).isFalse();
      });

      test('inequality on differing stealth', () {
        const a = ModeOverrides();
        const b = ModeOverrides(stealth: StealthConfig(enabled: true));

        check(a == b).isFalse();
      });

      test('inequality on differing localTemplates length', () {
        final a = ModeOverrides(localTemplates: [_localTemplate(id: 'one')]);
        const b = ModeOverrides();

        check(a == b).isFalse();
      });

      test('inequality on differing local template content', () {
        final a = ModeOverrides(localTemplates: [_localTemplate(id: 'a')]);
        final b = ModeOverrides(localTemplates: [_localTemplate(id: 'b')]);

        check(a == b).isFalse();
      });

      test('inequality on differing eventDefaults', () {
        const a = ModeOverrides();
        final b = ModeOverrides(
          eventDefaults: const EventDefaults().copyWith(),
        );

        check(a == b).isFalse();
      });

      test('null vs empty list localTemplates are NOT equal', () {
        // Per spec 03: null means "inherit only", empty list means
        // "override with zero" — these are distinct intents.
        const nullList = ModeOverrides();
        const emptyList = ModeOverrides(localTemplates: []);

        check(nullList == emptyList).isFalse();
      });

      test('hashCode is stable across calls', () {
        const overrides = ModeOverrides(stealth: StealthConfig(enabled: true));

        check(overrides.hashCode).equals(overrides.hashCode);
      });

      test('hashCode equal for equal local-templates lists', () {
        final a = ModeOverrides(localTemplates: [_localTemplate(id: 'same')]);
        final b = ModeOverrides(localTemplates: [_localTemplate(id: 'same')]);

        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });
    });
  });
}
