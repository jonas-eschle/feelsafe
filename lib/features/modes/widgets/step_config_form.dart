/// Full step-config editor — timing fields + event-specific config.
///
/// All four timing controls (wait + duration + grace + retries) sit
/// inside a collapsible [ExpansionTile] that defaults to closed so
/// the editor surface stays compact for typical chains.
library;

import 'package:flutter/material.dart';

import 'package:guardianangela/core/widgets/timing_slider.dart';
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

/// Collapsible panel grouping the three timing fields plus retries.
///
/// Defaults to closed; the collapsed header summarises the three
/// values so the user can read the timing without expanding the
/// panel. *Why:* most steps run with reasonable defaults; surfacing
/// four numeric fields by default doubles the perceived complexity.
class _TimingPanel extends StatelessWidget {
  const _TimingPanel({required this.step, required this.onChanged});

  final ChainStep step;
  final ValueChanged<ChainStep> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
          // Phase 4.2: timing fields use TimingSlider (DE-1) — log
          // snap stops + 0 minimum + numeric entry chip.
          TimingSlider(
            label: l.stepFieldWait,
            seconds: step.waitSeconds,
            onChanged: (v) => onChanged(step.copyWith(waitSeconds: v)),
          ),
          TimingSlider(
            label: l.stepFieldDuration,
            seconds: step.durationSeconds,
            onChanged: (v) => onChanged(step.copyWith(durationSeconds: v)),
          ),
          TimingSlider(
            label: l.stepFieldGrace,
            seconds: step.gracePeriodSeconds,
            onChanged: (v) =>
                onChanged(step.copyWith(gracePeriodSeconds: v)),
          ),
          TextFormField(
            key: ValueKey('retry-${step.id}-${step.retryCount}'),
            initialValue: step.retryCount.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l.stepFieldRetryCount),
            onChanged: (v) => onChanged(
              step.copyWith(retryCount: int.tryParse(v) ?? step.retryCount),
            ),
          ),
        ],
      ),
    );
  }
}
