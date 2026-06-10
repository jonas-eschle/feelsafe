/// Mapping between persisted `SessionMode.iconName` strings and Material
/// icons, plus the curated picker vocabulary (spec 04:1483, 1539-1540).
///
/// A `const` name → [IconData] map keeps icon resolution tree-shake safe:
/// every glyph referenced here is a compile-time `Icons` constant, so
/// `--tree-shake-icons` keeps exactly these glyphs and nothing resolves
/// icons from strings reflectively at runtime.
library;

import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Curated mode-icon vocabulary offered by the mode editor's icon selector.
///
/// Keys are the persisted `SessionMode.iconName` strings; each key is
/// exactly the name of the `Icons` member it maps to, so the stored value
/// stays greppable against the Flutter icon catalogue. Covers the three
/// seeded names (`directions_walk`, `restaurant`, `warning` — see
/// `lib/data/seed_data.dart`) plus the spec's example trio
/// (shield / heart / lock, spec 04:1540) and further everyday safety
/// contexts (commute, night out, sport, travel).
const Map<String, IconData> kModeIcons = <String, IconData>{
  'shield': Icons.shield,
  'favorite': Icons.favorite,
  'lock': Icons.lock,
  'directions_walk': Icons.directions_walk,
  'restaurant': Icons.restaurant,
  'warning': Icons.warning,
  'nightlife': Icons.nightlife,
  'directions_run': Icons.directions_run,
  'directions_bike': Icons.directions_bike,
  'home': Icons.home,
  'work': Icons.work,
  'school': Icons.school,
  'local_taxi': Icons.local_taxi,
  'flight': Icons.flight,
  'hiking': Icons.hiking,
  'celebration': Icons.celebration,
};

/// Icon rendered for a mode whose `iconName` is null (never chosen).
///
/// The shield is the app's signature motif, so an icon-less mode still
/// reads as "a Guardian Angela mode" rather than as broken data.
const IconData kModeIconDefault = Icons.shield;

/// Deliberate fallback for an unknown / stale persisted icon name.
///
/// Visually distinct from every picker icon so corrupted data stays
/// noticeable, while the screen keeps working.
const IconData kModeIconFallback = Icons.help_outline;

/// Resolves a persisted [iconName] to its glyph.
///
/// - null → [kModeIconDefault] (a legitimate "not chosen yet" state);
/// - unknown name → [kModeIconFallback] plus a `dart:developer` log.
///
/// Why not fail loud here: this runs while painting the home and modes
/// lists of a safety app — a stale string (e.g. an icon removed from the
/// vocabulary after a restore from backup) must never take down the
/// screens that start or edit sessions. The deliberate fallback glyph plus
/// the log keeps the corruption visible without making it dangerous.
IconData modeIcon(String? iconName) {
  if (iconName == null) return kModeIconDefault;
  final IconData? icon = kModeIcons[iconName];
  if (icon == null) {
    log(
      'Unknown mode iconName "$iconName"; rendering fallback icon',
      name: 'mode_icons',
    );
    return kModeIconFallback;
  }
  return icon;
}

/// Localized accessibility label for a picker icon (spec 04:1539).
///
/// Total over [kModeIcons]; an unmapped name is a programming error (the
/// picker only ever renders map keys) and fails loud.
String modeIconLabel(AppLocalizations l10n, String iconName) =>
    switch (iconName) {
      'shield' => l10n.modeIconLabelShield,
      'favorite' => l10n.modeIconLabelFavorite,
      'lock' => l10n.modeIconLabelLock,
      'directions_walk' => l10n.modeIconLabelDirectionsWalk,
      'restaurant' => l10n.modeIconLabelRestaurant,
      'warning' => l10n.modeIconLabelWarning,
      'nightlife' => l10n.modeIconLabelNightlife,
      'directions_run' => l10n.modeIconLabelDirectionsRun,
      'directions_bike' => l10n.modeIconLabelDirectionsBike,
      'home' => l10n.modeIconLabelHome,
      'work' => l10n.modeIconLabelWork,
      'school' => l10n.modeIconLabelSchool,
      'local_taxi' => l10n.modeIconLabelLocalTaxi,
      'flight' => l10n.modeIconLabelFlight,
      'hiking' => l10n.modeIconLabelHiking,
      'celebration' => l10n.modeIconLabelCelebration,
      _ => throw ArgumentError.value(
        iconName,
        'iconName',
        'not in kModeIcons — picker labels must cover the whole vocabulary',
      ),
    };
