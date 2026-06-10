/// Unit tests for [selectReminderTemplate] per spec 02 §disguisedReminder
/// template selection (Extra-8, C4).
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/orchestration/reminder_template_selector.dart';

ReminderTemplate _tmpl(String id) => ReminderTemplate(
  id: id,
  name: id,
  title: 'Title $id',
  body: 'Body $id',
  confirmationType: ConfirmationType.dismiss,
  isCustom: false,
  displayStyle: ReminderDisplayStyle.subtle,
  isGlobal: true,
);

void main() {
  final pool = [_tmpl('a'), _tmpl('b'), _tmpl('c')];

  group('empty pool', () {
    test('returns the hard-coded built-in fallback (spec step 2)', () {
      final chosen = selectReminderTemplate(
        pool: const [],
        templateIds: const [],
        randomizeTemplateOrder: true,
        nowMillis: 12345000,
      );
      check(chosen.id).equals('builtin_reminder_fallback');
    });
  });

  group('randomizeTemplateOrder = false', () {
    test('returns the first eligible template', () {
      final chosen = selectReminderTemplate(
        pool: pool,
        templateIds: const [],
        randomizeTemplateOrder: false,
        nowMillis: 999000,
      );
      check(chosen.id).equals('a');
    });
  });

  group('templateIds filtering', () {
    test('restricts selection to matching ids', () {
      final chosen = selectReminderTemplate(
        pool: pool,
        templateIds: const ['c'],
        randomizeTemplateOrder: false,
        nowMillis: 0,
      );
      check(chosen.id).equals('c');
    });

    test('non-matching ids fall back to the full pool (spec step 2)', () {
      final chosen = selectReminderTemplate(
        pool: pool,
        templateIds: const ['does_not_exist'],
        randomizeTemplateOrder: false,
        nowMillis: 0,
      );
      check(chosen.id).equals('a');
    });

    test('a stale id mixed with a valid one is ignored — the valid id still '
        'filters (the per-step picker mirrors this)', () {
      final chosen = selectReminderTemplate(
        pool: pool,
        templateIds: const ['ghost', 'b'],
        randomizeTemplateOrder: false,
        nowMillis: 0,
      );
      check(chosen.id).equals('b');
    });
  });

  group('randomizeTemplateOrder = true (time-based index)', () {
    test('index = nowMillis ~/ 1000 % length', () {
      // (7000 ~/ 1000) % 3 == 7 % 3 == 1 → pool[1] == 'b'.
      final chosen = selectReminderTemplate(
        pool: pool,
        templateIds: const [],
        randomizeTemplateOrder: true,
        nowMillis: 7000,
      );
      check(chosen.id).equals('b');
    });

    test('wraps around the pool length', () {
      // (9000 ~/ 1000) % 3 == 9 % 3 == 0 → pool[0] == 'a'.
      final chosen = selectReminderTemplate(
        pool: pool,
        templateIds: const [],
        randomizeTemplateOrder: true,
        nowMillis: 9000,
      );
      check(chosen.id).equals('a');
    });
  });

  group('avoidId (C4 — no repeat in a row)', () {
    test('skips to the next template when the pick matches avoidId', () {
      // Base pick is 'a' (index 0); avoidId 'a' → next is 'b'.
      final chosen = selectReminderTemplate(
        pool: pool,
        templateIds: const [],
        randomizeTemplateOrder: false,
        nowMillis: 0,
        avoidId: 'a',
      );
      check(chosen.id).equals('b');
    });

    test('returns the same template when it is the only candidate', () {
      final chosen = selectReminderTemplate(
        pool: [_tmpl('solo')],
        templateIds: const [],
        randomizeTemplateOrder: false,
        nowMillis: 0,
        avoidId: 'solo',
      );
      check(chosen.id).equals('solo');
    });

    test('does not skip when avoidId does not match the pick', () {
      final chosen = selectReminderTemplate(
        pool: pool,
        templateIds: const [],
        randomizeTemplateOrder: false,
        nowMillis: 0,
        avoidId: 'c',
      );
      check(chosen.id).equals('a');
    });
  });
}
