/// Expandable tile rendering one chain step with inline config.
library;

import 'package:flutter/material.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/modes/widgets/step_config_form.dart';
import 'package:guardianangela/features/modes/widgets/step_type_picker.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// One-tile view of a [ChainStep] inside a reorderable list.
class ChainStepTile extends StatelessWidget {
  /// Creates the tile.
  const ChainStepTile({
    super.key,
    required this.step,
    required this.onChanged,
    required this.onDelete,
    this.onDuplicate,
  });

  /// The step rendered.
  final ChainStep step;

  /// Fires with the updated step.
  final ValueChanged<ChainStep> onChanged;

  /// Fires when the user taps delete.
  final VoidCallback onDelete;

  /// Fires when the user taps duplicate. When null the duplicate
  /// icon is hidden — keeps existing test fixtures that didn't
  /// supply a duplicator working.
  final VoidCallback? onDuplicate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      child: ExpansionTile(
        title: Text(stepTypeLabel(context, step.type)),
        subtitle: Text(
          '${step.waitSeconds}s wait · '
          '${step.durationSeconds}s active · '
          '${step.gracePeriodSeconds}s grace',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onDuplicate != null)
              IconButton(
                icon: const Icon(Icons.content_copy_outlined),
                tooltip: l.stepDuplicate,
                onPressed: onDuplicate,
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          // Spec 04 §ModeEditor — the chain-step type can be swapped
          // post-creation; config resets to null because configs
          // are type-specific. Timings are preserved.
          DropdownButtonFormField<ChainStepType>(
            initialValue: step.type,
            decoration: InputDecoration(labelText: l.stepTypePickerLabel),
            items: [
              for (final t in ChainStepType.values)
                DropdownMenuItem<ChainStepType>(
                  value: t,
                  child: Text(stepTypeLabel(context, t)),
                ),
            ],
            onChanged: (t) {
              if (t == null || t == step.type) return;
              onChanged(
                ChainStep(
                  id: step.id,
                  type: t,
                  order: step.order,
                  durationSeconds: step.durationSeconds,
                  gracePeriodSeconds: step.gracePeriodSeconds,
                  waitSeconds: step.waitSeconds,
                  retryCount: step.retryCount,
                  randomize: step.randomize,
                  // config intentionally dropped — wrong type.
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          StepConfigForm(step: step, onChanged: onChanged),
        ],
      ),
    );
  }
}
