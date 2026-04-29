/// Full step-config editor — timing fields + event-specific config.
///
/// All four timing controls (wait + duration + grace + retries) sit
/// inside a collapsible [ExpansionTile] that defaults to closed so
/// the editor surface stays compact for typical chains.
library;

import 'package:flutter/material.dart';

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
            step.waitSeconds.toString(),
            step.durationSeconds.toString(),
            step.gracePeriodSeconds.toString(),
          ),
        ),
        initiallyExpanded: false,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          TextFormField(
            // Force rebuild on type-swap so the displayed value
            // reflects the current step (TextFormField caches
            // initialValue otherwise).
            key: ValueKey('wait-${step.id}-${step.waitSeconds}'),
            initialValue: step.waitSeconds.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l.stepFieldWait),
            onChanged: (v) => onChanged(
              step.copyWith(waitSeconds: int.tryParse(v) ?? step.waitSeconds),
            ),
          ),
          TextFormField(
            key: ValueKey('dur-${step.id}-${step.durationSeconds}'),
            initialValue: step.durationSeconds.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l.stepFieldDuration),
            onChanged: (v) => onChanged(
              step.copyWith(
                durationSeconds: int.tryParse(v) ?? step.durationSeconds,
              ),
            ),
          ),
          TextFormField(
            key: ValueKey('grace-${step.id}-${step.gracePeriodSeconds}'),
            initialValue: step.gracePeriodSeconds.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l.stepFieldGrace),
            onChanged: (v) => onChanged(
              step.copyWith(
                gracePeriodSeconds:
                    int.tryParse(v) ?? step.gracePeriodSeconds,
              ),
            ),
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
