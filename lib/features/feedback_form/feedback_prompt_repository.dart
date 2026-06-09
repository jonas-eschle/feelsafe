import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// Tracks how many real safety sessions have completed cleanly, gating the
/// optional post-session feedback prompt (spec 04 §Chain Exhausted Screen —
/// "Feedback prompt (optional, appears after 3 successful sessions)").
///
/// State is a single integer counter backed by [SharedPreferences]. Only
/// **real** session completions are counted (simulations are practice and
/// never bump the counter); the counter is incremented exactly once per
/// clean end on the [SessionCompletedScreen] path. The prompt is offered
/// when the counter reaches [promptThreshold]; once offered, a sticky flag
/// keeps it offered on every subsequent completion (the destination —
/// `/settings/feedback` — is always reachable, so there is no reason to
/// hide it again).
///
/// All reads and writes are no-throw: a [SharedPreferences] failure falls
/// back to "do not show the prompt", so a storage error can never surface a
/// spurious prompt or crash the completion screen.
class FeedbackPromptRepository {
  /// Creates a [FeedbackPromptRepository].
  ///
  /// Pass [prefsLoader] to inject a fake `SharedPreferences` in tests.
  /// Defaults to [SharedPreferences.getInstance].
  FeedbackPromptRepository({Future<SharedPreferences> Function()? prefsLoader})
    : _prefsLoader = prefsLoader ?? SharedPreferences.getInstance;

  final Future<SharedPreferences> Function() _prefsLoader;

  /// SharedPreferences key for the cumulative successful-completion count.
  static const String completedCountKey = 'feedback_prompt_completed_count';

  /// Number of clean real-session completions after which the prompt is
  /// first offered (spec 04:1250 — "after 3 successful sessions").
  static const int promptThreshold = 3;

  /// The current cumulative count of clean real-session completions.
  Future<int> completedCount() async {
    try {
      final prefs = await _prefsLoader();
      return prefs.getInt(completedCountKey) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Records one clean real-session completion, returning the new count.
  ///
  /// Returns the pre-increment value (0) on a storage failure so the caller
  /// never mistakes an error for a threshold crossing.
  Future<int> recordCompletedSession() async {
    try {
      final prefs = await _prefsLoader();
      final next = (prefs.getInt(completedCountKey) ?? 0) + 1;
      await prefs.setInt(completedCountKey, next);
      return next;
    } catch (_) {
      return 0;
    }
  }

  /// Whether the feedback prompt should be offered, i.e. at least
  /// [promptThreshold] real sessions have completed cleanly.
  Future<bool> shouldShowPrompt() async =>
      await completedCount() >= promptThreshold;
}
