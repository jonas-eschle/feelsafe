/// Full step-config editor — timing fields + event-specific config.
library;

import 'package:flutter/material.dart';

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/modes/widgets/event_specific_config.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Editor for a single [ChainStep]. Composes a timing block with
/// [EventSpecificConfig].
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
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          initialValue: step.waitSeconds.toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l.stepFieldWait),
          onChanged: (v) => onChanged(
            step.copyWith(waitSeconds: int.tryParse(v) ?? step.waitSeconds),
          ),
        ),
        TextFormField(
          initialValue: step.durationSeconds.toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l.stepFieldDuration),
          onChanged: (v) => onChanged(step.copyWith(
            durationSeconds: int.tryParse(v) ?? step.durationSeconds,
          )),
        ),
        TextFormField(
          initialValue: step.gracePeriodSeconds.toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l.stepFieldGrace),
          onChanged: (v) => onChanged(step.copyWith(
            gracePeriodSeconds: int.tryParse(v) ?? step.gracePeriodSeconds,
          )),
        ),
        TextFormField(
          initialValue: step.retryCount.toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l.stepFieldRetryCount),
          onChanged: (v) => onChanged(
            step.copyWith(retryCount: int.tryParse(v) ?? step.retryCount),
          ),
        ),
        const SizedBox(height: 16),
        EventSpecificConfig(step: step, onChanged: onChanged),
      ],
    );
  }
}
