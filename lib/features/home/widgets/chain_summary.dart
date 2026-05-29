import 'package:flutter/material.dart';

import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Horizontal "Chain Summary" pill row at the top of the home screen.
///
/// Renders one tappable pill per step in the selected mode's chain
/// (`[icon] Label → [icon] Label → ...`), wrapped in a horizontally
/// scrollable row so long chains do not push the rest of the home
/// layout offscreen. Tapping a pill opens [ChainStepTimingSheet] — a
/// modal bottom sheet that shows the step's wait / active / grace
/// timings plus the name of the next step in the chain.
///
/// When [steps] is empty the widget renders a single-line "empty"
/// helper text so the surface remains discoverable.
///
/// Spec ref: 04 §Chain Summary (lines 429-439).
class ChainSummary extends StatelessWidget {
  /// Creates a [ChainSummary].
  const ChainSummary({super.key, required this.steps});

  /// Chain steps to render, in execution order.
  final List<ChainStep> steps;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final cs = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.homeChainSummaryTitle, style: textTheme.titleSmall),
            const SizedBox(height: 8),
            if (steps.isEmpty)
              Text(
                l10n.homeChainSummaryEmpty,
                style: textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              )
            else
              _PillRow(steps: steps),
          ],
        ),
      ),
    );
  }
}

/// Horizontally scrollable row of [_StepPill] widgets separated by an
/// arrow glyph. Sized to never expand the parent column past its given
/// width — overflow is absorbed by the inner [SingleChildScrollView].
class _PillRow extends StatelessWidget {
  const _PillRow({required this.steps});

  final List<ChainStep> steps;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < steps.length; i++) ...<Widget>[
            _StepPill(step: steps[i], index: i, chain: steps),
            if (i != steps.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.chevron_right, size: 18),
              ),
          ],
        ],
      ),
    );
  }
}

/// Tappable teal pill rendering `[icon] Label` for a single chain step.
/// Tapping opens [ChainStepTimingSheet] for the step.
class _StepPill extends StatelessWidget {
  const _StepPill({
    required this.step,
    required this.index,
    required this.chain,
  });

  final ChainStep step;
  final int index;
  final List<ChainStep> chain;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final label = chainStepDisplayName(step.type, l10n);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => ChainStepTimingSheet.show(
        context,
        step: step,
        nextStep: index + 1 < chain.length ? chain[index + 1] : null,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(chainStepIcon(step.type), size: 16, color: cs.onPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: cs.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal bottom sheet shown when a [ChainSummary] pill is tapped.
///
/// Renders the timing breakdown for [step]: wait / active / grace
/// durations, retry count, and the name of [nextStep] (or "end of
/// chain" when [step] is the last). Spec ref: 04:433-439.
class ChainStepTimingSheet extends StatelessWidget {
  /// Creates a [ChainStepTimingSheet].
  const ChainStepTimingSheet({
    super.key,
    required this.step,
    required this.nextStep,
  });

  /// The step being inspected.
  final ChainStep step;

  /// The step immediately following [step] in the chain, or null if
  /// [step] is the last step.
  final ChainStep? nextStep;

  /// Convenience launcher that wraps [ChainStepTimingSheet] in
  /// [showModalBottomSheet] and disposes the route when the sheet is
  /// dismissed.
  static Future<void> show(
    BuildContext context, {
    required ChainStep step,
    required ChainStep? nextStep,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext _) =>
          ChainStepTimingSheet(step: step, nextStep: nextStep),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final name = chainStepDisplayName(step.type, l10n);
    final nextName = nextStep == null
        ? null
        : chainStepDisplayName(nextStep!.type, l10n);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(chainStepIcon(step.type)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.homeChainSummaryTimingTitle(name),
                    style: textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.homeChainSummaryWait('${step.waitSeconds}')),
            Text(l10n.homeChainSummaryDuration('${step.durationSeconds}')),
            Text(l10n.homeChainSummaryGrace('${step.gracePeriodSeconds}')),
            Text(l10n.homeChainSummaryRetry('${step.retryCount}')),
            const SizedBox(height: 12),
            Text(
              nextName == null
                  ? l10n.homeChainSummaryNextStepNone
                  : l10n.homeChainSummaryNextStep(nextName),
              style: textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.homeChainSummaryClose),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Maps a [ChainStepType] to the icon used in the chain-summary pill.
/// Top-level so widget tests can verify the mapping without rendering.
IconData chainStepIcon(ChainStepType type) => switch (type) {
  ChainStepType.holdButton => Icons.touch_app,
  ChainStepType.disguisedReminder => Icons.notifications_active,
  ChainStepType.countdownWarning => Icons.timer_outlined,
  ChainStepType.fakeCall => Icons.phone_in_talk,
  ChainStepType.smsContact => Icons.sms_outlined,
  ChainStepType.phoneCallContact => Icons.phone_forwarded,
  ChainStepType.loudAlarm => Icons.volume_up,
  ChainStepType.callEmergency => Icons.emergency,
  ChainStepType.hardwareButton => Icons.bolt,
};

/// Maps a [ChainStepType] to its localized human-readable display name.
String chainStepDisplayName(ChainStepType type, AppLocalizations l10n) =>
    switch (type) {
      ChainStepType.holdButton => l10n.chainStepNameHoldButton,
      ChainStepType.disguisedReminder => l10n.chainStepNameDisguisedReminder,
      ChainStepType.countdownWarning => l10n.chainStepNameCountdownWarning,
      ChainStepType.fakeCall => l10n.chainStepNameFakeCall,
      ChainStepType.smsContact => l10n.chainStepNameSmsContact,
      ChainStepType.phoneCallContact => l10n.chainStepNamePhoneCallContact,
      ChainStepType.loudAlarm => l10n.chainStepNameLoudAlarm,
      ChainStepType.callEmergency => l10n.chainStepNameCallEmergency,
      ChainStepType.hardwareButton => l10n.chainStepNameHardwareButton,
    };
