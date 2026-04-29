/// `LogGpsSelector` — tri-state selector for [LogGpsOverride] per
/// spec 11 §DE-2.
///
/// Renders a labelled segmented control with three options:
///   - Default — defer to the next layer in the resolution order;
///     when the resolved fallback is on/off, the muted subtitle
///     reads "Default (On)" / "Default (Off)" so users see the
///     effective behaviour without expanding the resolution tree.
///   - On — force GPS on regardless of any default.
///   - Off — skip GPS for this step regardless.
///
/// Pure UI: callers feed in the current value plus the resolved
/// fallback boolean and receive change notifications via
/// [onChanged].
library;

import 'package:flutter/material.dart';

import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Tri-state selector for the per-step `logGps` override (DE-2).
class LogGpsSelector extends StatelessWidget {
  /// Creates the selector.
  ///
  /// [value] — current per-step override.
  /// [resolvedFallback] — what the fallback chain resolves to when
  /// this step uses [LogGpsOverride.useDefault]. Drives the muted
  /// "Default (On / Off)" subtitle.
  /// [onChanged] — callback fired when the user picks a new value.
  const LogGpsSelector({
    super.key,
    required this.value,
    required this.resolvedFallback,
    required this.onChanged,
  });

  /// Current override.
  final LogGpsOverride value;

  /// Effective fallback when [value] is [LogGpsOverride.useDefault].
  final bool resolvedFallback;

  /// Change callback.
  final ValueChanged<LogGpsOverride> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final subtitle = value == LogGpsOverride.useDefault
        ? (resolvedFallback
              ? l.stepConfigLogGpsDefaultOn
              : l.stepConfigLogGpsDefaultOff)
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4, top: 8),
          child: Text(
            l.stepConfigLogGpsLabel,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        SegmentedButton<LogGpsOverride>(
          segments: [
            ButtonSegment(
              value: LogGpsOverride.useDefault,
              label: Text(l.stepConfigLogGpsDefault),
            ),
            ButtonSegment(
              value: LogGpsOverride.forceOn,
              label: Text(l.stepConfigLogGpsOn),
            ),
            ButtonSegment(
              value: LogGpsOverride.forceOff,
              label: Text(l.stepConfigLogGpsOff),
            ),
          ],
          selected: {value},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
