/// Unit tests for the mode icon vocabulary (spec 04:1483, 1539-1540):
/// name → glyph resolution, the null-default and unknown-name fallback
/// policies, and the localized picker labels.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/utils/mode_icons.dart';
import 'package:guardianangela/data/seed_data.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

void main() {
  group('kModeIcons vocabulary', () {
    test('contains the spec example trio (shield / heart / lock)', () {
      check(kModeIcons['shield']).equals(Icons.shield);
      check(kModeIcons['favorite']).equals(Icons.favorite);
      check(kModeIcons['lock']).equals(Icons.lock);
    });

    test('covers every seeded iconName', () {
      for (final String? name in <String?>[
        SeedData.walkMode().iconName,
        SeedData.dateMode().iconName,
        SeedData.defaultDistressMode().iconName,
      ]) {
        check(name).isNotNull();
        check(kModeIcons.containsKey(name)).isTrue();
      }
    });

    test('is the curated 16-icon picker set', () {
      check(kModeIcons.length).equals(16);
    });
  });

  group('modeIcon resolution', () {
    test('a known name resolves to its mapped glyph', () {
      check(modeIcon('directions_walk')).equals(Icons.directions_walk);
      check(modeIcon('warning')).equals(Icons.warning);
    });

    test('null (never chosen) renders the shield default', () {
      check(modeIcon(null)).equals(kModeIconDefault);
      check(kModeIconDefault).equals(Icons.shield);
    });

    test('an unknown / stale name renders the deliberate fallback '
        'instead of throwing', () {
      check(modeIcon('no_such_icon')).equals(kModeIconFallback);
      check(kModeIconFallback).equals(Icons.help_outline);
    });

    test('the fallback glyph is outside the picker vocabulary so '
        'corruption stays visible', () {
      check(kModeIcons.values).not((it) => it.contains(kModeIconFallback));
    });
  });

  group('modeIconLabel', () {
    test(
      'labels the whole vocabulary with non-empty distinct strings',
      () async {
        final AppLocalizations l10n = await AppLocalizations.delegate.load(
          const Locale('en'),
        );
        final Set<String> labels = <String>{};
        for (final String name in kModeIcons.keys) {
          final String label = modeIconLabel(l10n, name);
          check(label).isNotEmpty();
          check(labels.add(label)).isTrue();
        }
      },
    );

    test('fails loud for a name outside the vocabulary', () async {
      final AppLocalizations l10n = await AppLocalizations.delegate.load(
        const Locale('en'),
      );
      check(() => modeIconLabel(l10n, 'no_such_icon')).throws<ArgumentError>();
    });
  });
}
