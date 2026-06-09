/// Coarse, dependency-free relative-time bucketing for human-readable
/// "… ago" strings.
///
/// Used by the Session-Interrupted Prompt (spec 04 Extra 13) to render the
/// prior session's start time as a relative phrase instead of a raw
/// timestamp. The bucketing is intentionally coarse (just-now / minutes /
/// hours / days) because the prompt only needs to convey *roughly* how long
/// ago the interruption happened. Localisation of the chosen bucket lives in
/// the UI layer (`relative_time_l10n.dart`); this file is pure Dart so it can
/// be unit-tested without Flutter.
library;

/// The coarse time bucket a [RelativeTime] falls into.
enum RelativeTimeUnit {
  /// Less than a minute ago (or in the future / clock skew — clamped here).
  justNow,

  /// Between one minute and one hour ago; [RelativeTime.value] holds whole
  /// minutes (1–59).
  minutes,

  /// Between one hour and one day ago; [RelativeTime.value] holds whole
  /// hours (1–23).
  hours,

  /// One day ago or more; [RelativeTime.value] holds whole days (≥ 1).
  days,
}

/// A bucketed relative duration: a [unit] plus its whole-number [value].
///
/// For [RelativeTimeUnit.justNow] the [value] is always 0.
final class RelativeTime {
  /// Creates a [RelativeTime] from a [unit] and its whole-number [value].
  const RelativeTime(this.unit, this.value);

  /// The coarse bucket.
  final RelativeTimeUnit unit;

  /// Whole-number magnitude within [unit] (minutes / hours / days). Always 0
  /// for [RelativeTimeUnit.justNow].
  final int value;

  /// Buckets the elapsed time between [from] and [now] into a [RelativeTime].
  ///
  /// A [from] in the future (or within the last minute) clamps to
  /// [RelativeTimeUnit.justNow] so the prompt never shows a negative or
  /// "0 minutes" phrase. [now] defaults to [DateTime.now]; pass it explicitly
  /// in tests for determinism.
  factory RelativeTime.between(DateTime from, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final delta = reference.difference(from);
    if (delta.inMinutes < 1) {
      return const RelativeTime(RelativeTimeUnit.justNow, 0);
    }
    if (delta.inHours < 1) {
      return RelativeTime(RelativeTimeUnit.minutes, delta.inMinutes);
    }
    if (delta.inDays < 1) {
      return RelativeTime(RelativeTimeUnit.hours, delta.inHours);
    }
    return RelativeTime(RelativeTimeUnit.days, delta.inDays);
  }
}
