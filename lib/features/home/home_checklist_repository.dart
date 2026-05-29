import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists the "Safety Setup Checklist" UI state flags (spec 04 §Safety
/// Setup Checklist — Behavior).
///
/// The repository owns three boolean flags backed by [SharedPreferences]:
///
/// * [dismissed] — true after the user explicitly closed the checklist
///   card; the card never reappears unless the user reinstalls or wipes
///   the app data.
/// * [simulationDone] — true after the first simulation session has run,
///   independently of the in-memory chain log.
/// * [firstVisitDone] — true after the home screen has rendered with the
///   checklist visible at least once; drives "expanded by default first
///   visit, collapsed on subsequent" per spec 04:511.
///
/// Read paths are async because `SharedPreferences.getInstance()` is
/// async; both reads and writes are no-throw — failures fall back to
/// the default "false" so the card remains discoverable.
class HomeChecklistRepository {
  /// Creates a [HomeChecklistRepository].
  ///
  /// Pass [prefsLoader] to inject a fake `SharedPreferences` in tests.
  /// Defaults to [SharedPreferences.getInstance].
  HomeChecklistRepository({Future<SharedPreferences> Function()? prefsLoader})
    : _prefsLoader = prefsLoader ?? SharedPreferences.getInstance;

  final Future<SharedPreferences> Function() _prefsLoader;

  /// SharedPreferences key for the manual-dismiss flag.
  static const String dismissedKey = 'home_checklist_dismissed';

  /// SharedPreferences key for the first-simulation-run flag.
  static const String simulationDoneKey = 'home_checklist_simulation_done';

  /// SharedPreferences key for the first-card-render flag.
  static const String firstVisitDoneKey = 'home_checklist_first_visit_done';

  /// Whether the user permanently dismissed the checklist card.
  Future<bool> dismissed() async {
    try {
      final prefs = await _prefsLoader();
      return prefs.getBool(dismissedKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Persists the manual-dismiss flag. Subsequent home renders skip the
  /// card entirely.
  Future<void> setDismissed() async {
    try {
      final prefs = await _prefsLoader();
      await prefs.setBool(dismissedKey, true);
    } catch (_) {
      // Best effort; the next dismiss attempt re-tries.
    }
  }

  /// Whether the user has run at least one simulation session.
  Future<bool> simulationDone() async {
    try {
      final prefs = await _prefsLoader();
      return prefs.getBool(simulationDoneKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Persists the simulation-done flag (called by the session controller
  /// when a simulation session is started).
  Future<void> markSimulationDone() async {
    try {
      final prefs = await _prefsLoader();
      await prefs.setBool(simulationDoneKey, true);
    } catch (_) {
      // Best effort.
    }
  }

  /// Whether the checklist has been rendered before. Drives the
  /// expanded-on-first-visit / collapsed-on-subsequent behavior.
  Future<bool> firstVisitDone() async {
    try {
      final prefs = await _prefsLoader();
      return prefs.getBool(firstVisitDoneKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Persists the first-visit flag (called by the widget after the first
  /// render so subsequent home renders default to collapsed).
  Future<void> markFirstVisitDone() async {
    try {
      final prefs = await _prefsLoader();
      await prefs.setBool(firstVisitDoneKey, true);
    } catch (_) {
      // Best effort.
    }
  }
}
