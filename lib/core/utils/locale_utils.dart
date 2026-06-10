/// Maps a persisted `AppSettings.languageCode` string to a [Locale].
///
/// The settings language picker (spec 04 §Language) stores plain language
/// codes (`'en'`, `'de'`, …) plus the one region-qualified form `'zh_TW'`
/// for Traditional Chinese. A region-qualified code MUST be split into the
/// [Locale] constructor's `languageCode` + `countryCode` arguments: a
/// single-argument `Locale('zh_TW')` produces a locale whose `languageCode`
/// is the literal string `'zh_TW'`, which matches NO supported locale, so
/// `MaterialApp` / `lookupAppLocalizations` silently fall back to the wrong
/// language (the first supported locale). Splitting yields the correct
/// `Locale('zh', 'TW')`.
///
/// This single helper is shared by the root `MaterialApp.locale` binding
/// (`lib/main.dart`) and the session-start localized-copy hop
/// (`lib/features/session/session_controller.dart`) so both honour the same
/// rule and the `'zh_TW'` regression can never resurface in only one path.
library;

import 'dart:ui' show Locale;

/// Builds the [Locale] for a stored `AppSettings.languageCode`.
///
/// A plain code maps directly: `'de'` → `Locale('de')`. A region-qualified
/// code is split on the first separator so the region lands in the country
/// slot: `'zh_TW'` → `Locale('zh', 'TW')`. Both the underscore convention
/// used by the settings picker (`'zh_TW'`) and the hyphen convention used by
/// some sibling code (`'zh-TW'`) are accepted, so the helper is robust to the
/// stored-code separator without callers needing to normalise first.
///
/// ```dart
/// localeForLanguageCode('en');    // Locale('en')
/// localeForLanguageCode('zh_TW'); // Locale('zh', 'TW')
/// localeForLanguageCode('zh-TW'); // Locale('zh', 'TW')
/// ```
Locale localeForLanguageCode(String languageCode) {
  // Split on the first '_' or '-' so a region/script tail moves into the
  // country slot. Plain codes have no separator and return single-arg.
  final parts = languageCode.split(RegExp('[_-]'));
  return parts.length >= 2
      ? Locale(parts.first, parts[1])
      : Locale(languageCode);
}
