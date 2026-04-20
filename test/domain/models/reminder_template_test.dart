/// Unit tests for `ReminderTemplate` — round-trip, isGlobal flag.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';

void main() {
  group('ReminderTemplate', () {
    const minimal = ReminderTemplate(
      id: 't1',
      name: 'Calendar',
      title: 'Meeting',
      body: 'Starts in 5 minutes',
      confirmationType: ConfirmationType.tapButton,
      displayStyle: ReminderDisplayStyle.subtle,
      isGlobal: true,
    );

    test('minimal construction', () {
      check(minimal.id).equals('t1');
      check(minimal.isGlobal).isTrue();
      check(minimal.isCustom).isFalse();
      check(minimal.iconAsset).isNull();
      check(minimal.keyword).isNull();
      check(minimal.buttonLabel).isNull();
      check(minimal.imagePath).isNull();
      check(minimal.subtitle).isNull();
    });

    test('round-trip minimal', () {
      check(ReminderTemplate.fromJson(minimal.toJson())).equals(minimal);
    });

    test('round-trip full', () {
      const t = ReminderTemplate(
        id: 't2',
        name: 'Duo',
        title: 'Streak',
        body: 'Complete lesson',
        confirmationType: ConfirmationType.tapWord,
        displayStyle: ReminderDisplayStyle.fullScreen,
        isGlobal: false,
        isCustom: true,
        iconAsset: 'a.png',
        keyword: 'owl',
        buttonLabel: 'Continue',
        imagePath: 'i.png',
        subtitle: 'subtitle',
      );
      check(ReminderTemplate.fromJson(t.toJson())).equals(t);
    });

    test('copyWith', () {
      final t = minimal.copyWith(isGlobal: false, isCustom: true);
      check(t.isGlobal).isFalse();
      check(t.isCustom).isTrue();
      check(t.id).equals(minimal.id);
    });

    test('fromJson unknown ConfirmationType throws', () {
      check(() => ReminderTemplate.fromJson(const {
            'id': 'x',
            'name': 'n',
            'title': 't',
            'body': 'b',
            'confirmationType': 'bogus',
            'displayStyle': 'subtle',
          })).throws<ArgumentError>();
    });

    test('fromJson unknown ReminderDisplayStyle throws', () {
      check(() => ReminderTemplate.fromJson(const {
            'id': 'x',
            'name': 'n',
            'title': 't',
            'body': 'b',
            'confirmationType': 'tapButton',
            'displayStyle': 'bogus',
          })).throws<ArgumentError>();
    });

    test('equality', () {
      check(minimal).equals(minimal.copyWith());
    });

    test('inequality on different title', () {
      check(minimal).not((it) => it.equals(minimal.copyWith(title: 'Other')));
    });

    test('all ConfirmationTypes round-trip', () {
      for (final type in ConfirmationType.values) {
        final t = minimal.copyWith(confirmationType: type);
        check(
          ReminderTemplate.fromJson(t.toJson()).confirmationType,
        ).equals(type);
      }
    });

    test('all ReminderDisplayStyles round-trip', () {
      for (final style in ReminderDisplayStyle.values) {
        final t = minimal.copyWith(displayStyle: style);
        check(
          ReminderTemplate.fromJson(t.toJson()).displayStyle,
        ).equals(style);
      }
    });
  });
}
