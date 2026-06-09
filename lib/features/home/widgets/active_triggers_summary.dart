import 'package:flutter/material.dart';

import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/gps_destination_source.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/domain/triggers/distress_trigger.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// On-tap "Active Triggers Summary" dialog (spec 04 §Start Session Button —
/// On tap, lines 456-468).
///
/// Shown the moment the user taps **Start**: it summarises the selected
/// mode's configured distress and auto-disarm triggers with brief
/// configuration details so the user can confirm the session behaves as
/// expected before it begins.
///
/// Per decision D4 the GPS-destination prompt itself stays **in-session**
/// (rendered by `session_screen.dart`'s `_GpsDestinationPrompt` when
/// `SessionState.needsGpsDestinationPrompt`). This summary only *mentions*
/// that a prompt-at-start GPS trigger will ask for its destination after
/// the session begins; it does not collect coordinates here.
///
/// Returns `true` when the user taps **Start now** (proceed), `false`
/// otherwise (cancel or barrier dismiss).
class ActiveTriggersSummaryDialog extends StatelessWidget {
  /// Creates an [ActiveTriggersSummaryDialog] for [mode].
  const ActiveTriggersSummaryDialog({super.key, required this.mode});

  /// The mode whose triggers are summarised.
  final SessionMode mode;

  /// Shows the dialog and resolves to whether the user chose to proceed.
  static Future<bool> show(BuildContext context, SessionMode mode) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (BuildContext _) => ActiveTriggersSummaryDialog(mode: mode),
    );
    return proceed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final distressLines = mode.distressTriggers
        .map((DistressTrigger t) => _distressDetail(l10n, t))
        .toList();
    final disarmLines = mode.disarmTriggers
        .map((DisarmTrigger t) => _disarmDetail(l10n, t))
        .toList();
    return AlertDialog(
      title: Text(l10n.homeStartTriggersSummaryTitle),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _TriggerSection(
              heading: l10n.homeStartTriggersDistressHeading,
              icon: Icons.warning_amber_rounded,
              details: distressLines,
              emptyLabel: l10n.homeStartTriggersNone,
            ),
            const SizedBox(height: 12),
            _TriggerSection(
              heading: l10n.homeStartTriggersDisarmHeading,
              icon: Icons.flag_outlined,
              details: disarmLines,
              emptyLabel: l10n.homeStartTriggersNone,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.homeStartTriggersCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.homeStartTriggersContinue),
        ),
      ],
      // Keep the summary readable under large system font scaling.
      scrollable: true,
      titleTextStyle: theme.textTheme.titleLarge,
    );
  }

  /// One-line summary of a distress trigger's configuration.
  static String _distressDetail(AppLocalizations l10n, DistressTrigger t) {
    return switch (t) {
      HardwareButtonDistressTrigger(:final buttonType, :final pattern) =>
        switch (pattern) {
          PressPattern.repeatPress => l10n.homeStartTriggerButtonRepeat(
            _buttonName(l10n, buttonType),
            '${t.pressCount}',
          ),
          PressPattern.longPress => l10n.homeStartTriggerButtonLong(
            _buttonName(l10n, buttonType),
            _trimZero(t.durationSeconds ?? 2.0),
          ),
        },
    };
  }

  /// One-line summary of a disarm trigger's configuration. A
  /// prompt-at-start GPS trigger appends a note that the destination is
  /// collected in-session (decision D4).
  static String _disarmDetail(AppLocalizations l10n, DisarmTrigger t) {
    return switch (t) {
      GpsArrivalDisarmTrigger(:final radiusMeters, :final destinationSource) =>
        destinationSource == GpsDestinationSource.promptAtStart
            ? '${l10n.homeStartTriggerGpsArrival('$radiusMeters')}\n'
                  '${l10n.homeStartTriggerGpsPrompt}'
            : l10n.homeStartTriggerGpsArrival('$radiusMeters'),
      TimerDisarmTrigger(:final durationSeconds) => l10n.homeStartTriggerTimer(
        '${(durationSeconds / 60).round()}',
      ),
    };
  }

  static String _buttonName(AppLocalizations l10n, ButtonType b) => switch (b) {
    ButtonType.volumeUp => l10n.homeStartTriggerButtonVolumeUp,
    ButtonType.volumeDown => l10n.homeStartTriggerButtonVolumeDown,
  };

  /// Renders a double like `2.0` as `2` and `1.5` as `1.5`.
  static String _trimZero(double v) =>
      v == v.roundToDouble() ? '${v.round()}' : '$v';
}

/// A heading + its trigger detail lines (or an "empty" line when the mode
/// has no trigger of that kind).
class _TriggerSection extends StatelessWidget {
  const _TriggerSection({
    required this.heading,
    required this.icon,
    required this.details,
    required this.emptyLabel,
  });

  final String heading;
  final IconData icon;
  final List<String> details;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text(heading, style: theme.textTheme.titleSmall),
          ],
        ),
        const SizedBox(height: 4),
        if (details.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              emptyLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final line in details)
            Padding(
              padding: const EdgeInsets.only(left: 26, bottom: 2),
              child: Text(line, style: theme.textTheme.bodyMedium),
            ),
      ],
    );
  }
}
