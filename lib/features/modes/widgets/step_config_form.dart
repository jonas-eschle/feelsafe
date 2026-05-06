/// Full step-config editor — timing fields + event-specific config.
///
/// All four timing controls (wait + duration + grace + retries) sit
/// inside a collapsible [ExpansionTile] that defaults to closed so
/// the editor surface stays compact for typical chains.
library;

import 'package:flutter/material.dart';

import 'package:guardianangela/core/widgets/timing_slider.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/modes/widgets/event_specific_config.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Editor for a single [ChainStep]. Composes a collapsible timing
/// block with [EventSpecificConfig].
class StepConfigForm extends StatelessWidget {
  /// Creates the form.
  const StepConfigForm({
    super.key,
    required this.step,
    required this.onChanged,
  });

  /// Current step.
  final ChainStep step;

  /// Callback fired with the updated step.
  final ValueChanged<ChainStep> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TimingPanel(step: step, onChanged: onChanged),
        const SizedBox(height: 16),
        EventSpecificConfig(step: step, onChanged: onChanged),
      ],
    );
  }
}

/// Returns true if [type] supports the per-step randomize toggle
/// (issues-v4 #11). Only steps whose timing is user-perceivable as a
/// repeating cadence — disguisedReminder + fakeCall — get the
/// toggle. SMS / alarm / emergency-confirm are excluded by design
/// (the user wants those at predictable times).
bool stepSupportsRandomizeToggle(ChainStepType type) =>
    type == ChainStepType.disguisedReminder ||
    type == ChainStepType.fakeCall;

/// Collapsible panel grouping the three timing fields plus retries.
///
/// Defaults to closed; the collapsed header summarises the three
/// values so the user can read the timing without expanding the
/// panel. *Why:* most steps run with reasonable defaults; surfacing
/// four numeric fields by default doubles the perceived complexity.
///
/// Issues-v4 #4: for disguisedReminder steps the wait field is
/// labelled "Repeat interval" (that's its semantic on the engine
/// side) and a tooltip explains both wait and grace. Field order is
/// Repeat Interval → Grace (other timings continue to follow the
/// generic Wait → Duration → Grace order).
///
/// Issues-v4 #11: a "Randomize timing (±20%)" switch appears for
/// step types that benefit from cadence variation. Toggle on sets
/// `randomize` to 0.2; off resets it to 0.0.
class _TimingPanel extends StatelessWidget {
  const _TimingPanel({required this.step, required this.onChanged});

  final ChainStep step;
  final ValueChanged<ChainStep> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isReminder = step.type == ChainStepType.disguisedReminder;
    final showRandomize = stepSupportsRandomizeToggle(step.type);
    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        title: Text(l.stepTimingHeader),
        subtitle: Text(
          l.stepTimingSummary(
            formatTimingLabel(step.waitSeconds),
            formatTimingLabel(step.durationSeconds),
            formatTimingLabel(step.gracePeriodSeconds),
          ),
        ),
        initiallyExpanded: false,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          if (isReminder) ...[
            // Issues-v4 #4 — for disguisedReminder, "wait" IS the
            // repeat interval. Show Repeat Interval first, then
            // Grace. Duration of the reminder pop-up itself is
            // usually irrelevant so it's collapsed below.
            _TimingRow(
              label: l.stepConfigReminderInterval,
              tooltip: l.stepFieldReminderIntervalTooltip,
              seconds: step.waitSeconds,
              onChanged: (v) => onChanged(step.copyWith(waitSeconds: v)),
            ),
            _TimingRow(
              label: l.stepFieldGrace,
              tooltip: l.stepFieldReminderGraceTooltip,
              seconds: step.gracePeriodSeconds,
              onChanged: (v) =>
                  onChanged(step.copyWith(gracePeriodSeconds: v)),
            ),
            _TimingRow(
              label: l.stepFieldDuration,
              tooltip: l.stepFieldDurationTooltip,
              seconds: step.durationSeconds,
              onChanged: (v) => onChanged(step.copyWith(durationSeconds: v)),
            ),
          ] else ...[
            _TimingRow(
              label: l.stepFieldWait,
              tooltip: l.stepFieldWaitTooltip,
              seconds: step.waitSeconds,
              onChanged: (v) => onChanged(step.copyWith(waitSeconds: v)),
            ),
            _TimingRow(
              label: l.stepFieldDuration,
              tooltip: l.stepFieldDurationTooltip,
              seconds: step.durationSeconds,
              onChanged: (v) => onChanged(step.copyWith(durationSeconds: v)),
            ),
            _TimingRow(
              label: l.stepFieldGrace,
              tooltip: l.stepFieldGraceTooltip,
              seconds: step.gracePeriodSeconds,
              onChanged: (v) =>
                  onChanged(step.copyWith(gracePeriodSeconds: v)),
            ),
          ],
          _RetriesField(step: step, onChanged: onChanged),
          if (showRandomize)
            // Issues-v4 #11 — single double serves as a flag with the
            // 0.2 ratio (±20% jitter). 0.0 disables jitter; toggling
            // back to true restores 0.2 even if the user had a custom
            // value. *Why a single field?* The model already owns
            // [ChainStep.randomize] as a double; carving out a
            // separate `enabled` bool would split the source of truth.
            SwitchListTile(
              key: ValueKey('randomize-${step.id}'),
              contentPadding: EdgeInsets.zero,
              title: Text(l.stepFieldRandomizeToggle),
              value: step.randomize > 0,
              onChanged: (v) =>
                  onChanged(step.copyWith(randomize: v ? 0.2 : 0.0)),
            ),
        ],
      ),
    );
  }
}

/// One labelled timing row with an info tooltip (issues-v4 #4).
///
/// The tooltip is hung off an [Icon] inside a [Tooltip] so VoiceOver /
/// TalkBack pick it up as descriptive text alongside the label.
class _TimingRow extends StatelessWidget {
  const _TimingRow({
    required this.label,
    required this.seconds,
    required this.onChanged,
    this.tooltip,
  });

  final String label;
  final int seconds;
  final ValueChanged<int> onChanged;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final tip = tooltip;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tip != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: tip,
                  child: const Icon(
                    Icons.info_outline,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        TimingSlider(
          // When a tooltip header is rendered above, suppress the
          // duplicate label inside the slider to avoid double-text.
          label: tip == null ? label : null,
          seconds: seconds,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Plain text-field for the retry-count integer with an info tooltip.
class _RetriesField extends StatelessWidget {
  const _RetriesField({required this.step, required this.onChanged});

  final ChainStep step;
  final ValueChanged<ChainStep> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            key: ValueKey('retry-${step.id}-${step.retryCount}'),
            initialValue: step.retryCount.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l.stepFieldRetryCount),
            onChanged: (v) => onChanged(
              step.copyWith(retryCount: int.tryParse(v) ?? step.retryCount),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Tooltip(
          message: l.stepFieldRetryCountTooltip,
          child: const Icon(Icons.info_outline, size: 16),
        ),
      ],
    );
  }
}
