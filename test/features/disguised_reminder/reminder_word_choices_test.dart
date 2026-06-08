/// Unit tests for [buildReminderWordChoices] (tapWord decoy generation,
/// spec 02 §disguisedReminder Disarm tapWord / spec 03 §ReminderTemplate).
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/features/disguised_reminder/reminder_word_choices.dart';

void main() {
  test('default returns three words including the keyword', () {
    final words = buildReminderWordChoices('STREAK');
    check(words.length).equals(3);
    check(words).contains('STREAK');
  });

  test('respects a custom option count', () {
    final words = buildReminderWordChoices('SAFE', optionCount: 4);
    check(words.length).equals(4);
    check(words).contains('SAFE');
  });

  test('option count of one returns only the keyword', () {
    final words = buildReminderWordChoices('SAFE', optionCount: 1);
    check(words).deepEquals(const ['SAFE']);
  });

  test('contains no duplicate words', () {
    final words = buildReminderWordChoices('STREAK');
    check(words.toSet().length).equals(words.length);
  });

  test('decoys never equal the keyword (case-insensitive)', () {
    final words = buildReminderWordChoices('skip');
    final decoys = words.where((w) => w != 'skip').toList();
    for (final d in decoys) {
      check(d.toUpperCase()).not((it) => it.equals('SKIP'));
    }
  });

  test('is deterministic for a given keyword', () {
    final a = buildReminderWordChoices('STREAK');
    final b = buildReminderWordChoices('STREAK');
    check(a).deepEquals(b);
  });

  test('the keyword is not always placed first', () {
    // At least one keyword among a varied set should land off index 0,
    // proving the rotation runs.
    final keywords = ['SAFE', 'STREAK', 'HELLO', 'WORD', 'CHECK', 'GREEN'];
    final anyNonZero = keywords.any(
      (k) => buildReminderWordChoices(k).indexOf(k) != 0,
    );
    check(anyNonZero).isTrue();
  });

  group('localized decoy pool', () {
    test('decoys are drawn from the supplied pool, not the fallback', () {
      const pool = ['MAÑANA', 'OMITIR', 'HECHO', 'ABRIR', 'VER'];
      final words = buildReminderWordChoices('STREAK', decoyPool: pool);
      check(words).contains('STREAK');
      final decoys = words.where((w) => w != 'STREAK');
      for (final d in decoys) {
        check(pool).contains(d);
      }
      // And NONE of the English fallback words leaked in.
      for (final d in decoys) {
        check(kReminderDecoyPoolFallback).not((it) => it.contains(d));
      }
    });

    test('an empty pool falls back to the English pool', () {
      // The default (omitted) decoyPool is null, so the no-arg result already
      // uses the English fallback; an explicitly empty pool must match it.
      final fromEmpty = buildReminderWordChoices(
        'STREAK',
        decoyPool: const <String>[],
      );
      final fromDefault = buildReminderWordChoices('STREAK');
      check(fromEmpty).deepEquals(fromDefault);
      // Every word in the fallback result is sourced from the English pool.
      final decoys = fromDefault.where((w) => w != 'STREAK');
      for (final d in decoys) {
        check(kReminderDecoyPoolFallback).contains(d);
      }
    });

    test('a decoy equal to the keyword is filtered (case-insensitive)', () {
      // 'skip' collides with the pool's 'SKIP' — it must be excluded even
      // though the casing differs.
      const pool = ['SKIP', 'LATER', 'DONE', 'OPEN'];
      final words = buildReminderWordChoices(
        'skip',
        optionCount: 4,
        decoyPool: pool,
      );
      check(words).contains('skip');
      final decoys = words.where((w) => w != 'skip');
      for (final d in decoys) {
        check(d.toUpperCase()).not((it) => it.equals('SKIP'));
      }
    });
  });
}
