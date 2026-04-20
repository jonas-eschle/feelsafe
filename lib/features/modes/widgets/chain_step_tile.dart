/// Expandable tile rendering one chain step with inline config.
library;

import 'package:flutter/material.dart';

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/modes/widgets/step_config_form.dart';
import 'package:guardianangela/features/modes/widgets/step_type_picker.dart';

/// One-tile view of a [ChainStep] inside a reorderable list.
class ChainStepTile extends StatelessWidget {
  /// Creates the tile.
  const ChainStepTile({
    super.key,
    required this.step,
    required this.onChanged,
    required this.onDelete,
  });

  /// The step rendered.
  final ChainStep step;

  /// Fires with the updated step.
  final ValueChanged<ChainStep> onChanged;

  /// Fires when the user taps delete.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
        child: ExpansionTile(
          title: Text(stepTypeLabel(context, step.type)),
          subtitle: Text(
            '${step.waitSeconds}s wait · '
            '${step.durationSeconds}s active · '
            '${step.gracePeriodSeconds}s grace',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            StepConfigForm(step: step, onChanged: onChanged),
          ],
        ),
      );
}
