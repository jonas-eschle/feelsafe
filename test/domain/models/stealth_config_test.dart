// Unit tests for [StealthConfig].
//
// Verifies constructor defaults, JSON round-trip, copyWith behaviour,
// equality / hashCode contract, and enum coverage per
// docs/spec/00-overview.md §6 (Stealth Mode), docs/spec/03-data-models.md
// §StealthConfig, and Q20.

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardianangela/domain/enums/stealth_icon_preset.dart';
import 'package:guardianangela/domain/enums/stealth_timer_display.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';

void main() {
  group('StealthConfig', () {
    group('defaults', () {
      test('enabled defaults to false (master toggle off)', () {
        // A safety app must not surprise users by enabling stealth by
        // default (spec 03 §StealthConfig).
        // Arrange + Act
        const cfg = StealthConfig();

        // Assert
        check(cfg.enabled).isFalse();
      });

      test("fakeName defaults to 'Music' (Q20)", () {
        // Arrange + Act
        const cfg = StealthConfig();

        // Assert
        check(cfg.fakeName).equals('Music');
      });

      test('fakeIcon defaults to StealthIconPreset.music (Q20)', () {
        // Arrange + Act
        const cfg = StealthConfig();

        // Assert
        check(cfg.fakeIcon).equals(StealthIconPreset.music);
      });

      test('notificationDisguise defaults to true', () {
        // Arrange + Act
        const cfg = StealthConfig();

        // Assert — spec 03 §StealthConfig: default true.
        check(cfg.notificationDisguise).isTrue();
      });

      test('timerDisplay defaults to StealthTimerDisplay.normal', () {
        // Arrange + Act
        const cfg = StealthConfig();

        // Assert
        check(cfg.timerDisplay).equals(StealthTimerDisplay.normal);
      });

      test('sessionScreenStealth defaults to true', () {
        // Arrange + Act
        const cfg = StealthConfig();

        // Assert
        check(cfg.sessionScreenStealth).isTrue();
      });

      test('non-default values stored unchanged', () {
        // Arrange + Act
        const cfg = StealthConfig(
          enabled: true,
          fakeName: 'Notes',
          fakeIcon: StealthIconPreset.notes,
          notificationDisguise: false,
          timerDisplay: StealthTimerDisplay.small,
          sessionScreenStealth: false,
        );

        // Assert
        check(cfg.enabled).isTrue();
        check(cfg.fakeName).equals('Notes');
        check(cfg.fakeIcon).equals(StealthIconPreset.notes);
        check(cfg.notificationDisguise).isFalse();
        check(cfg.timerDisplay).equals(StealthTimerDisplay.small);
        check(cfg.sessionScreenStealth).isFalse();
      });
    });

    group('JSON round-trip', () {
      test('toJson contains all six keys', () {
        // Arrange
        const cfg = StealthConfig();

        // Act
        final json = cfg.toJson();

        // Assert
        check(json).containsKey('enabled');
        check(json).containsKey('fakeName');
        check(json).containsKey('fakeIcon');
        check(json).containsKey('notificationDisguise');
        check(json).containsKey('timerDisplay');
        check(json).containsKey('sessionScreenStealth');
      });

      test('toJson encodes fakeIcon by enum name', () {
        // Arrange
        const cfg = StealthConfig(fakeIcon: StealthIconPreset.calendar);

        // Act
        final json = cfg.toJson();

        // Assert
        check(json['fakeIcon']).equals('calendar');
      });

      test('toJson encodes timerDisplay by enum name', () {
        // Arrange
        const cfg = StealthConfig(timerDisplay: StealthTimerDisplay.none);

        // Act
        final json = cfg.toJson();

        // Assert
        check(json['timerDisplay']).equals('none');
      });

      test('fromJson(toJson) round-trips default config', () {
        // Arrange
        const original = StealthConfig();

        // Act
        final restored = StealthConfig.fromJson(original.toJson());

        // Assert
        check(restored).equals(original);
      });

      test('fromJson(toJson) preserves all fields in customised config', () {
        // Arrange
        const original = StealthConfig(
          enabled: true,
          fakeName: 'Weather',
          fakeIcon: StealthIconPreset.weather,
          notificationDisguise: false,
          timerDisplay: StealthTimerDisplay.small,
          sessionScreenStealth: false,
        );

        // Act
        final restored = StealthConfig.fromJson(original.toJson());

        // Assert
        check(restored).equals(original);
      });

      test('fromJson applies all defaults to empty map', () {
        // Arrange + Act
        final cfg = StealthConfig.fromJson(const <String, dynamic>{});

        // Assert — matches default constructor
        check(cfg).equals(const StealthConfig());
      });

      test('all StealthIconPreset values round-trip via JSON', () {
        for (final value in StealthIconPreset.values) {
          // Arrange
          final original = StealthConfig(fakeIcon: value);

          // Act
          final restored = StealthConfig.fromJson(original.toJson());

          // Assert
          check(restored.fakeIcon).equals(value);
        }
      });

      test('all StealthTimerDisplay values round-trip via JSON', () {
        for (final value in StealthTimerDisplay.values) {
          // Arrange
          final original = StealthConfig(timerDisplay: value);

          // Act
          final restored = StealthConfig.fromJson(original.toJson());

          // Assert
          check(restored.timerDisplay).equals(value);
        }
      });

      test('fromJson preserves fakeName with custom string', () {
        // Arrange
        const original = StealthConfig(fakeName: 'Podcast Player');

        // Act
        final restored = StealthConfig.fromJson(original.toJson());

        // Assert
        check(restored.fakeName).equals('Podcast Player');
      });
    });

    group('copyWith', () {
      test('with no arguments returns equal object', () {
        // Arrange
        const base = StealthConfig();

        // Act
        final copy = base.copyWith();

        // Assert
        check(copy).equals(base);
      });

      test('replaces enabled only', () {
        // Arrange
        const base = StealthConfig();

        // Act
        final next = base.copyWith(enabled: true);

        // Assert
        check(next.enabled).isTrue();
        check(next.fakeName).equals(base.fakeName);
        check(next.fakeIcon).equals(base.fakeIcon);
      });

      test('replaces fakeName only', () {
        // Arrange
        const base = StealthConfig();

        // Act
        final next = base.copyWith(fakeName: 'Calendar');

        // Assert
        check(next.fakeName).equals('Calendar');
        check(next.fakeIcon).equals(base.fakeIcon);
      });

      test('replaces fakeIcon only', () {
        // Arrange
        const base = StealthConfig();

        // Act
        final next = base.copyWith(fakeIcon: StealthIconPreset.clock);

        // Assert
        check(next.fakeIcon).equals(StealthIconPreset.clock);
        check(next.fakeName).equals(base.fakeName);
      });

      test('replaces notificationDisguise only', () {
        // Arrange
        const base = StealthConfig();

        // Act
        final next = base.copyWith(notificationDisguise: false);

        // Assert
        check(next.notificationDisguise).isFalse();
        check(next.enabled).equals(base.enabled);
      });

      test('replaces timerDisplay only', () {
        // Arrange
        const base = StealthConfig();

        // Act
        final next = base.copyWith(timerDisplay: StealthTimerDisplay.none);

        // Assert
        check(next.timerDisplay).equals(StealthTimerDisplay.none);
        check(next.enabled).equals(base.enabled);
      });

      test('replaces sessionScreenStealth only', () {
        // Arrange
        const base = StealthConfig();

        // Act
        final next = base.copyWith(sessionScreenStealth: false);

        // Assert
        check(next.sessionScreenStealth).isFalse();
        check(next.enabled).equals(base.enabled);
      });

      test('replaces all fields together', () {
        // Arrange
        const base = StealthConfig();

        // Act
        final next = base.copyWith(
          enabled: true,
          fakeName: 'Fitness',
          fakeIcon: StealthIconPreset.fitness,
          notificationDisguise: false,
          timerDisplay: StealthTimerDisplay.small,
          sessionScreenStealth: false,
        );

        // Assert
        check(next.enabled).isTrue();
        check(next.fakeName).equals('Fitness');
        check(next.fakeIcon).equals(StealthIconPreset.fitness);
        check(next.notificationDisguise).isFalse();
        check(next.timerDisplay).equals(StealthTimerDisplay.small);
        check(next.sessionScreenStealth).isFalse();
      });
    });

    group('equality + hashCode', () {
      test('two identically-constructed configs are equal', () {
        // Arrange
        const a = StealthConfig();
        const b = StealthConfig();

        // Act + Assert
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('equality is reflexive', () {
        // Arrange
        const cfg = StealthConfig();

        // Act + Assert
        check(cfg).equals(cfg);
      });

      test('equality is symmetric and transitive', () {
        // Arrange
        const a = StealthConfig(enabled: true);
        const b = StealthConfig(enabled: true);
        const c = StealthConfig(enabled: true);

        // Assert
        check(a == b).isTrue();
        check(b == a).isTrue();
        check(b == c).isTrue();
        check(a == c).isTrue();
      });

      test('different enabled breaks equality', () {
        // Arrange
        const a = StealthConfig();
        const b = StealthConfig(enabled: true);

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different fakeName breaks equality', () {
        // Arrange
        const a = StealthConfig();
        const b = StealthConfig(fakeName: 'Calendar');

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different fakeIcon breaks equality', () {
        // Arrange
        const a = StealthConfig();
        const b = StealthConfig(fakeIcon: StealthIconPreset.fitness);

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different notificationDisguise breaks equality', () {
        // Arrange
        const a = StealthConfig();
        const b = StealthConfig(notificationDisguise: false);

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different timerDisplay breaks equality', () {
        // Arrange
        const a = StealthConfig();
        const b = StealthConfig(timerDisplay: StealthTimerDisplay.none);

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different sessionScreenStealth breaks equality', () {
        // Arrange
        const a = StealthConfig();
        const b = StealthConfig(sessionScreenStealth: false);

        // Act + Assert
        check(a == b).isFalse();
      });

      test('hashCode equals when configs are equal', () {
        // Arrange
        const a = StealthConfig(fakeName: 'X');
        const b = StealthConfig(fakeName: 'X');

        // Act + Assert
        check(a.hashCode).equals(b.hashCode);
      });

      test('not equal to object of different type', () {
        // Arrange
        const cfg = StealthConfig();

        // Act + Assert
        check(cfg == const Object()).isFalse();
      });
    });

    group('edge cases', () {
      test('fakeIcon=none is a valid preset', () {
        // Arrange + Act — `none` means "no icon override" per spec.
        const cfg = StealthConfig(fakeIcon: StealthIconPreset.none);

        // Assert
        check(cfg.fakeIcon).equals(StealthIconPreset.none);
      });

      test('timerDisplay=none round-trips via JSON', () {
        // Arrange
        const original = StealthConfig(timerDisplay: StealthTimerDisplay.none);

        // Act
        final restored = StealthConfig.fromJson(original.toJson());

        // Assert
        check(restored.timerDisplay).equals(StealthTimerDisplay.none);
      });

      test('fakeName accepts empty string (no implicit validation)', () {
        // Arrange + Act — spec does not mandate non-empty.
        const cfg = StealthConfig(fakeName: '');

        // Assert
        check(cfg.fakeName).equals('');
      });
    });
  });
}
