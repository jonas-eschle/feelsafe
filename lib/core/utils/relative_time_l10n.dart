import 'package:guardianangela/core/utils/relative_time.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Maps a pure-Dart [RelativeTime] bucket to its localized "… ago" phrase.
///
/// The Session-Interrupted Prompt (spec 04 Extra 13) renders the prior
/// session's start time relatively (e.g. "5 minutes ago"). [RelativeTime] is
/// computed Flutter-free in `relative_time.dart`; this UI-glue helper turns
/// the chosen bucket into a localised string via the `sessionInterrupted*Ago`
/// ICU-plural keys.
String relativeTimeLabel(AppLocalizations l10n, RelativeTime relative) {
  return switch (relative.unit) {
    RelativeTimeUnit.justNow => l10n.sessionInterruptedJustNow,
    RelativeTimeUnit.minutes => l10n.sessionInterruptedMinutesAgo(
      relative.value,
    ),
    RelativeTimeUnit.hours => l10n.sessionInterruptedHoursAgo(relative.value),
    RelativeTimeUnit.days => l10n.sessionInterruptedDaysAgo(relative.value),
  };
}
