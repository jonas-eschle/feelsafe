/// Curated icon set for [SessionMode] tiles + the icon-picker UI.
///
/// Icon names ARE the persisted strings on `SessionMode.iconName`.
/// They map to constant `IconData` values from Material Symbols. We
/// keep the set small (and locale-agnostic) so the picker fits one
/// scrollable sheet and the persisted names stay stable across
/// locale and theme. *Why:* a fixed catalogue avoids accidentally
/// referencing icons that might be tree-shaken out of release builds
/// when looked up by code-point.
library;

import 'package:flutter/material.dart';

/// One catalogue entry: a stable id (the `iconName` persisted on
/// [SessionMode]) plus the resolved [IconData].
class ModeIconEntry {
  /// Creates a catalogue entry.
  const ModeIconEntry(this.name, this.icon);

  /// Stable persisted name (e.g. `directions_walk`).
  final String name;

  /// The resolved Material icon.
  final IconData icon;
}

/// Curated palette of mode icons. Order is the order shown in the
/// picker — most common safety modes first.
const List<ModeIconEntry> kModeIconLibrary = [
  ModeIconEntry('shield', Icons.shield),
  ModeIconEntry('directions_walk', Icons.directions_walk),
  ModeIconEntry('directions_run', Icons.directions_run),
  ModeIconEntry('directions_bike', Icons.directions_bike),
  ModeIconEntry('directions_car', Icons.directions_car),
  ModeIconEntry('favorite', Icons.favorite),
  ModeIconEntry('restaurant', Icons.restaurant),
  ModeIconEntry('fitness_center', Icons.fitness_center),
  ModeIconEntry('work', Icons.work),
  ModeIconEntry('school', Icons.school),
  ModeIconEntry('beach_access', Icons.beach_access),
  ModeIconEntry('nightlight_round', Icons.nightlight_round),
  ModeIconEntry('home', Icons.home),
  ModeIconEntry('luggage', Icons.luggage),
];

/// Resolves a stored [iconName] to a Material [IconData], or `null`
/// when the name is unknown / null. The UI may then fall back to
/// its name-based heuristic.
IconData? iconForName(String? iconName) {
  if (iconName == null) return null;
  for (final e in kModeIconLibrary) {
    if (e.name == iconName) return e.icon;
  }
  return null;
}
