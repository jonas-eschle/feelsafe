/// Unit tests for [localeForLanguageCode] — the shared stored-languageCode →
/// [Locale] mapper used by both the root `MaterialApp.locale` and the
/// session-start localized-copy hop.
///
/// The load-bearing case is `'zh_TW'`: a single-argument `Locale('zh_TW')`
/// has `languageCode == 'zh_TW'`, which matches NO supported locale and makes
/// resolution fall back to the wrong language (production bug #15). The helper
/// must split the region into the country slot so it becomes
/// `Locale('zh', 'TW')`.
library;

import 'package:flutter/widgets.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/utils/locale_utils.dart';

void main() {
  group('localeForLanguageCode', () {
    test('plain code maps to a single-argument Locale', () {
      final locale = localeForLanguageCode('de');
      check(locale).equals(const Locale('de'));
      check(locale.languageCode).equals('de');
      check(locale.countryCode).isNull();
    });

    test('every plain supported code round-trips to its single-arg Locale', () {
      for (final code in const <String>[
        'en',
        'de',
        'es',
        'fr',
        'ru',
        'zh',
        'hi',
        'fa',
        'uk',
        'pl',
        'el',
        'ar',
        'he',
      ]) {
        check(localeForLanguageCode(code)).equals(Locale(code));
      }
    });

    test('underscore region code splits into language + country (bug #15)', () {
      final locale = localeForLanguageCode('zh_TW');
      check(locale).equals(const Locale('zh', 'TW'));
      check(locale.languageCode).equals('zh');
      check(locale.countryCode).equals('TW');
      // The bug: a single-arg Locale would carry the whole string as the
      // language code and match no supported locale.
      check(locale.languageCode).not((it) => it.equals('zh_TW'));
    });

    test('hyphen region code splits the same way (separator robustness)', () {
      // A sibling convention stores hyphenated tags; the helper must accept
      // both so a stored 'zh-TW' never falls through to the wrong language.
      check(localeForLanguageCode('zh-TW')).equals(const Locale('zh', 'TW'));
    });
  });
}
