import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';

import 'package:guardianangela/core/widgets/timing_slider.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Reusable list-of-steps editor used by the mode editor.
///
/// Owners pass the current ordered [steps] and an [onChanged] callback;
/// the widget renders a list with per-step expandable timing controls,
/// delete buttons, reorderable handles, and a sheet-driven "Add step"
/// button. Allowed step types can be filtered via [allowedTypes] so a
/// caller can restrict which step types may be added.
class StepChainEditor extends StatelessWidget {
  /// Creates a [StepChainEditor].
  const StepChainEditor({
    super.key,
    required this.steps,
    required this.onChanged,
    this.allowedTypes,
    this.minSteps = 1,
  });

  /// Current ordered list of steps.
  final List<ChainStep> steps;

  /// Called with the new list when the user adds/removes/edits a step.
  final ValueChanged<List<ChainStep>> onChanged;

  /// When non-null, restricts the add-sheet to these types.
  final Set<ChainStepType>? allowedTypes;

  /// Minimum number of steps that must remain in the chain.
  final int minSteps;

  void _replaceAt(int index, ChainStep updated) {
    final next = <ChainStep>[...steps];
    next[index] = updated.copyWith(order: index);
    onChanged(next);
  }

  void _removeAt(int index) {
    if (steps.length <= minSteps) return;
    final next = <ChainStep>[...steps]..removeAt(index);
    for (int i = 0; i < next.length; i++) {
      next[i] = next[i].copyWith(order: i);
    }
    onChanged(next);
  }

  Future<void> _add(BuildContext context) async {
    final types = (allowedTypes ?? ChainStepType.values.toSet()).toList(
      growable: false,
    );
    final selected = await showModalBottomSheet<ChainStepType>(
      context: context,
      builder: (BuildContext ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            for (final t in types)
              ListTile(
                title: Text(t.name),
                onTap: () => Navigator.of(ctx).pop(t),
              ),
          ],
        ),
      ),
    );
    if (selected != null) {
      final next = <ChainStep>[
        ...steps,
        ChainStep(
          id: const Uuid().v4(),
          type: selected,
          order: steps.length,
          waitSeconds: 0,
          durationSeconds: 10,
          gracePeriodSeconds: 5,
          retryCount: 0,
          randomize: false,
        ),
      ];
      onChanged(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < steps.length; i++)
          _StepCard(
            index: i,
            step: steps[i],
            canRemove: steps.length > minSteps,
            onChanged: (ChainStep updated) => _replaceAt(i, updated),
            onRemove: () => _removeAt(i),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: Text(l10n.modeChainAddStep),
          onPressed: () => _add(context),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.step,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final ChainStep step;
  final bool canRemove;
  final ValueChanged<ChainStep> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      key: ValueKey<String>('step-${step.id}'),
      child: ExpansionTile(
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text(step.type.name),
        subtitle: Text(
          l10n.stepTimingSummary(
            step.waitSeconds.toString(),
            step.durationSeconds.toString(),
            step.gracePeriodSeconds.toString(),
          ),
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TimingSlider(
                  label: l10n.stepEditorWait,
                  valueSeconds: step.waitSeconds,
                  onChanged: (int v) =>
                      onChanged(step.copyWith(waitSeconds: v)),
                ),
                TimingSlider(
                  label: l10n.stepEditorDuration,
                  valueSeconds: step.durationSeconds,
                  onChanged: (int v) =>
                      onChanged(step.copyWith(durationSeconds: v)),
                ),
                TimingSlider(
                  label: l10n.stepEditorGrace,
                  valueSeconds: step.gracePeriodSeconds,
                  onChanged: (int v) =>
                      onChanged(step.copyWith(gracePeriodSeconds: v)),
                ),
                _IntSpinner(
                  label: l10n.stepEditorRetryCount,
                  value: step.retryCount,
                  onChanged: (int v) => onChanged(step.copyWith(retryCount: v)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.stepEditorRandomize),
                  value: step.randomize,
                  onChanged: (bool v) => onChanged(step.copyWith(randomize: v)),
                ),
                if (canRemove)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.stepEditorRemove),
                      onPressed: onRemove,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntSpinner extends StatelessWidget {
  const _IntSpinner({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  static const int min = 0;
  static const int max = 10;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value <= min ? null : () => onChanged(value - 1),
          ),
          Text(value.toString()),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: value >= max ? null : () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}
