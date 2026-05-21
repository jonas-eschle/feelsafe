// Unit tests for [ReminderTemplate].
//
// Verifies constructor invariants, JSON round-trip, copyWith behaviour,
// equality / hashCode contract, and edge cases per
// docs/spec/03-data-models.md §ReminderTemplate.

// Tests legitimately exercise default values for explicit defaults-
// match assertions.
// ignore_for_file: avoid_redundant_argument_values

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';

ReminderTemplate _make({
  String id = 't-1',
  String name = 'Calendar',
  String title = 'Event',
  String body = 'You have an appointment',
  String? iconAsset,
  ConfirmationType confirmationType = ConfirmationType.tapButton,
  String? keyword,
  String? buttonLabel,
  bool isCustom = false,
  String? imagePath,
  String? subtitle,
  ReminderDisplayStyle displayStyle = ReminderDisplayStyle.fullScreen,
  bool isGlobal = true,
}) => ReminderTemplate(
  id: id,
  name: name,
  title: title,
  body: body,
  iconAsset: iconAsset,
  confirmationType: confirmationType,
  keyword: keyword,
  buttonLabel: buttonLabel,
  isCustom: isCustom,
  imagePath: imagePath,
  subtitle: subtitle,
  displayStyle: displayStyle,
  isGlobal: isGlobal,
);

void main() {
  group('ReminderTemplate', () {
    group('constructor + defaults', () {
      test('all required fields are stored unchanged', () {
        // Arrange + Act
        final t = ReminderTemplate(
          id: 'tpl-1',
          name: 'My Tpl',
          title: 'Hello',
          body: 'World',
          confirmationType: ConfirmationType.dismiss,
          isCustom: true,
          displayStyle: ReminderDisplayStyle.subtle,
          isGlobal: false,
        );

        // Assert
        check(t.id).equals('tpl-1');
        check(t.name).equals('My Tpl');
        check(t.title).equals('Hello');
        check(t.body).equals('World');
        check(t.confirmationType).equals(ConfirmationType.dismiss);
        check(t.isCustom).isTrue();
        check(t.displayStyle).equals(ReminderDisplayStyle.subtle);
        check(t.isGlobal).isFalse();
      });

      test('optional fields default to null', () {
        // Arrange + Act
        final t = _make();

        // Assert
        check(t.iconAsset).isNull();
        check(t.keyword).isNull();
        check(t.buttonLabel).isNull();
        check(t.imagePath).isNull();
        check(t.subtitle).isNull();
      });

      test('keyword stored when set', () {
        // Arrange + Act
        final t = _make(
          confirmationType: ConfirmationType.tapWord,
          keyword: 'SAFE',
        );

        // Assert
        check(t.keyword).equals('SAFE');
      });

      test('built-in templates have isCustom=false', () {
        // Arrange + Act — built-in convention (spec 03 line 246)
        final t = _make();

        // Assert
        check(t.isCustom).isFalse();
      });

      test('isGlobal=true marks AppDefaults-global template', () {
        // Arrange + Act
        final t = _make();

        // Assert
        check(t.isGlobal).isTrue();
      });

      test('isGlobal=false marks mode-local template', () {
        // Arrange + Act
        final t = _make(isGlobal: false);

        // Assert
        check(t.isGlobal).isFalse();
      });

      test('accepts title at exactly 255 chars (boundary)', () {
        // Arrange + Act
        final longTitle = 'x' * 255;
        final t = _make(title: longTitle);

        // Assert
        check(t.title).equals(longTitle);
      });

      test('accepts keyword at exactly 50 chars (boundary)', () {
        // Arrange + Act
        final longKeyword = 'k' * 50;
        final t = _make(
          confirmationType: ConfirmationType.tapWord,
          keyword: longKeyword,
        );

        // Assert
        check(t.keyword).equals(longKeyword);
      });
    });

    group('JSON round-trip', () {
      test('toJson contains all required keys', () {
        // Arrange
        final t = _make();

        // Act
        final json = t.toJson();

        // Assert
        check(json).containsKey('id');
        check(json).containsKey('name');
        check(json).containsKey('title');
        check(json).containsKey('body');
        check(json).containsKey('confirmationType');
        check(json).containsKey('isCustom');
        check(json).containsKey('displayStyle');
        check(json).containsKey('isGlobal');
      });

      test('toJson omits null optional fields', () {
        // Arrange
        final t = _make();

        // Act
        final json = t.toJson();

        // Assert
        check(json.containsKey('iconAsset')).isFalse();
        check(json.containsKey('keyword')).isFalse();
        check(json.containsKey('buttonLabel')).isFalse();
        check(json.containsKey('imagePath')).isFalse();
        check(json.containsKey('subtitle')).isFalse();
      });

      test('toJson encodes enums by name string (not index)', () {
        // Arrange
        final t = _make(
          confirmationType: ConfirmationType.tapWord,
          displayStyle: ReminderDisplayStyle.subtle,
        );

        // Act
        final json = t.toJson();

        // Assert
        check(json['confirmationType']).equals('tapWord');
        check(json['displayStyle']).equals('subtle');
      });

      test('fromJson(toJson) preserves equality for minimal template', () {
        // Arrange
        final original = _make();

        // Act
        final restored = ReminderTemplate.fromJson(original.toJson());

        // Assert
        check(restored).equals(original);
      });

      test('fromJson(toJson) preserves all fields', () {
        // Arrange
        final original = ReminderTemplate(
          id: 'full',
          name: 'Full',
          title: 'Title',
          body: 'Body',
          iconAsset: 'assets/icons/calendar.png',
          confirmationType: ConfirmationType.tapWord,
          keyword: 'SAFE',
          buttonLabel: "I'm safe",
          isCustom: true,
          imagePath: '/path/to/image.png',
          subtitle: 'Subtitle text',
          displayStyle: ReminderDisplayStyle.fullScreen,
          isGlobal: false,
        );

        // Act
        final restored = ReminderTemplate.fromJson(original.toJson());

        // Assert
        check(restored).equals(original);
        check(restored.iconAsset).equals('assets/icons/calendar.png');
        check(restored.keyword).equals('SAFE');
        check(restored.buttonLabel).equals("I'm safe");
        check(restored.subtitle).equals('Subtitle text');
        check(restored.imagePath).equals('/path/to/image.png');
      });

      test('fromJson restores ConfirmationType.tapWord by name', () {
        // Arrange
        final original = _make(
          confirmationType: ConfirmationType.tapWord,
          keyword: 'OK',
        );

        // Act
        final restored = ReminderTemplate.fromJson(original.toJson());

        // Assert
        check(restored.confirmationType).equals(ConfirmationType.tapWord);
      });

      test('fromJson restores ReminderDisplayStyle.subtle by name', () {
        // Arrange
        final original = _make(displayStyle: ReminderDisplayStyle.subtle);

        // Act
        final restored = ReminderTemplate.fromJson(original.toJson());

        // Assert
        check(restored.displayStyle).equals(ReminderDisplayStyle.subtle);
      });

      test('fromJson preserves null optional fields as null', () {
        // Arrange
        final original = _make();

        // Act
        final restored = ReminderTemplate.fromJson(original.toJson());

        // Assert
        check(restored.iconAsset).isNull();
        check(restored.keyword).isNull();
        check(restored.subtitle).isNull();
      });

      test('fromJson preserves isCustom and isGlobal', () {
        // Arrange
        final original = _make(isCustom: true, isGlobal: false);

        // Act
        final restored = ReminderTemplate.fromJson(original.toJson());

        // Assert
        check(restored.isCustom).isTrue();
        check(restored.isGlobal).isFalse();
      });
    });

    group('copyWith', () {
      test('with no arguments returns equal object', () {
        // Arrange
        final base = _make();

        // Act
        final copy = base.copyWith();

        // Assert
        check(copy).equals(base);
      });

      test('replaces id only', () {
        // Arrange
        final base = _make(id: 'old');

        // Act
        final next = base.copyWith(id: 'new');

        // Assert
        check(next.id).equals('new');
        check(next.name).equals(base.name);
      });

      test('replaces name', () {
        // Arrange
        final base = _make(name: 'Cal');

        // Act
        final next = base.copyWith(name: 'Duo');

        // Assert
        check(next.name).equals('Duo');
      });

      test('replaces title and body together', () {
        // Arrange
        final base = _make();

        // Act
        final next = base.copyWith(title: 'New Title', body: 'New Body');

        // Assert
        check(next.title).equals('New Title');
        check(next.body).equals('New Body');
      });

      test('replaces confirmationType', () {
        // Arrange
        final base = _make(confirmationType: ConfirmationType.tapButton);

        // Act
        final next = base.copyWith(confirmationType: ConfirmationType.swipe);

        // Assert
        check(next.confirmationType).equals(ConfirmationType.swipe);
      });

      test('replaces keyword', () {
        // Arrange
        final base = _make();

        // Act
        final next = base.copyWith(keyword: 'STREAK');

        // Assert
        check(next.keyword).equals('STREAK');
      });

      test('replaces displayStyle', () {
        // Arrange
        final base = _make(displayStyle: ReminderDisplayStyle.fullScreen);

        // Act
        final next = base.copyWith(displayStyle: ReminderDisplayStyle.subtle);

        // Assert
        check(next.displayStyle).equals(ReminderDisplayStyle.subtle);
      });

      test('replaces isCustom toggle', () {
        // Arrange
        final base = _make(isCustom: false);

        // Act
        final next = base.copyWith(isCustom: true);

        // Assert
        check(next.isCustom).isTrue();
      });

      test('replaces isGlobal toggle', () {
        // Arrange
        final base = _make(isGlobal: true);

        // Act
        final next = base.copyWith(isGlobal: false);

        // Assert
        check(next.isGlobal).isFalse();
      });

      test('omitting a field preserves the original value', () {
        // Arrange
        final base = _make(title: 'Stay');

        // Act
        final next = base.copyWith(id: 'changed');

        // Assert
        check(next.title).equals('Stay');
        check(next.id).equals('changed');
      });
    });

    group('equality + hashCode', () {
      test('two identically-constructed templates are equal', () {
        // Arrange + Act
        final a = _make();
        final b = _make();

        // Assert
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('equality is reflexive', () {
        // Arrange
        final t = _make();

        // Act + Assert
        check(t).equals(t);
      });

      test('equality is symmetric and transitive over three instances', () {
        // Arrange
        final a = _make(id: 'eq');
        final b = _make(id: 'eq');
        final c = _make(id: 'eq');

        // Assert
        check(a == b).isTrue();
        check(b == a).isTrue();
        check(b == c).isTrue();
        check(a == c).isTrue();
      });

      test('different id breaks equality', () {
        // Arrange + Act
        final a = _make(id: 'a');
        final b = _make(id: 'b');

        // Assert
        check(a == b).isFalse();
      });

      test('different name breaks equality', () {
        // Arrange + Act
        final a = _make(name: 'Cal');
        final b = _make(name: 'Duo');

        // Assert
        check(a == b).isFalse();
      });

      test('different title breaks equality', () {
        // Arrange + Act
        final a = _make(title: 'A');
        final b = _make(title: 'B');

        // Assert
        check(a == b).isFalse();
      });

      test('different body breaks equality', () {
        // Arrange + Act
        final a = _make(body: 'A');
        final b = _make(body: 'B');

        // Assert
        check(a == b).isFalse();
      });

      test('different confirmationType breaks equality', () {
        // Arrange + Act
        final a = _make(confirmationType: ConfirmationType.tapButton);
        final b = _make(confirmationType: ConfirmationType.dismiss);

        // Assert
        check(a == b).isFalse();
      });

      test('different displayStyle breaks equality', () {
        // Arrange + Act
        final a = _make(displayStyle: ReminderDisplayStyle.fullScreen);
        final b = _make(displayStyle: ReminderDisplayStyle.subtle);

        // Assert
        check(a == b).isFalse();
      });

      test('different isCustom breaks equality', () {
        // Arrange + Act
        final a = _make(isCustom: false);
        final b = _make(isCustom: true);

        // Assert
        check(a == b).isFalse();
      });

      test('different isGlobal breaks equality', () {
        // Arrange + Act
        final a = _make(isGlobal: true);
        final b = _make(isGlobal: false);

        // Assert
        check(a == b).isFalse();
      });

      test('different keyword breaks equality', () {
        // Arrange + Act
        final a = _make(keyword: 'SAFE');
        final b = _make(keyword: 'STREAK');

        // Assert
        check(a == b).isFalse();
      });

      test('hashCode equals when templates are equal', () {
        // Arrange + Act
        final a = _make();
        final b = _make();

        // Assert
        check(a.hashCode).equals(b.hashCode);
      });
    });

    group('validation', () {
      test('rejects empty id', () {
        // Act + Assert
        check(() => _make(id: '')).throws<AssertionError>();
      });

      test('rejects empty name', () {
        // Act + Assert
        check(() => _make(name: '')).throws<AssertionError>();
      });

      test('rejects empty title', () {
        // Act + Assert
        check(() => _make(title: '')).throws<AssertionError>();
      });

      test('rejects empty body', () {
        // Act + Assert
        check(() => _make(body: '')).throws<AssertionError>();
      });

      test('rejects name longer than 255 chars', () {
        // Act + Assert — spec 03 line 264
        check(() => _make(name: 'x' * 256)).throws<AssertionError>();
      });

      test('rejects title longer than 255 chars', () {
        // Act + Assert
        check(() => _make(title: 'x' * 256)).throws<AssertionError>();
      });

      test('rejects body longer than 255 chars', () {
        // Act + Assert
        check(() => _make(body: 'x' * 256)).throws<AssertionError>();
      });

      test('rejects keyword longer than 50 chars', () {
        // Act + Assert — spec 03 line 265: keyword max 50 chars
        check(
          () => _make(
            confirmationType: ConfirmationType.tapWord,
            keyword: 'k' * 51,
          ),
        ).throws<AssertionError>();
      });

      test('rejects empty keyword when set (must be 1-50)', () {
        // Act + Assert
        check(
          () => _make(confirmationType: ConfirmationType.tapWord, keyword: ''),
        ).throws<AssertionError>();
      });

      test('accepts null keyword for non-tapWord templates', () {
        // Arrange + Act
        final t = _make(confirmationType: ConfirmationType.dismiss);

        // Assert
        check(t.keyword).isNull();
      });
    });
  });
}
