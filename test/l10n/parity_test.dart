/// L10n key-parity tests — the in-repo mirror of the CI `l10n-parity`
/// gate (`.github/workflows/ci.yml`). Every message key in the
/// `app_en.arb` template must exist in all 13 other locale ARBs, and no
/// locale may carry a key the template lacks. See spec 00 §Localization
/// and `~/.claude/plans/rippling-weaving-puffin.md` §Phase 8.
library;

import 'dart:convert';
import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

/// Directory holding the ARB sources, relative to the package root (the
/// working directory under `flutter test`).
final Directory _arbDir = Directory('lib/l10n/l10n');

/// Message keys = every top-level ARB entry that is not metadata (`@key`)
/// or the resource-bundle marker (`@@locale`).
Set<String> _messageKeys(File arb) {
  final data = jsonDecode(arb.readAsStringSync()) as Map<String, dynamic>;
  return data.keys.where((String k) => !k.startsWith('@')).toSet();
}

/// Every `app_*.arb` except the English template, sorted for stable
/// test ordering.
List<File> _localeArbs() =>
    _arbDir
        .listSync()
        .whereType<File>()
        .where(
          (File f) => f.path.endsWith('.arb') && !f.path.endsWith('app_en.arb'),
        )
        .toList()
      ..sort((File a, File b) => a.path.compareTo(b.path));

void main() {
  final File enFile = File('${_arbDir.path}/app_en.arb');

  test('app_en.arb template exists and is non-trivial', () {
    check(enFile.existsSync()).isTrue();
    check(_messageKeys(enFile).length).isGreaterThan(100);
  });

  test('exactly 13 non-English locale ARBs are present', () {
    // de es fr ru zh zh_TW hi fa uk pl el ar he
    check(_localeArbs().length).equals(13);
  });

  final Set<String> enKeys = _messageKeys(enFile);

  for (final File file in _localeArbs()) {
    final String name = file.uri.pathSegments.last;
    group(name, () {
      final Set<String> keys = _messageKeys(file);

      test('contains every app_en.arb key (no missing translations)', () {
        final List<String> missing = enKeys.difference(keys).toList()..sort();
        check(missing).isEmpty();
      });

      test('carries no key absent from app_en.arb (no orphan keys)', () {
        final List<String> extra = keys.difference(enKeys).toList()..sort();
        check(extra).isEmpty();
      });
    });
  }
}
