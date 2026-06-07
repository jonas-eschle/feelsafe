import 'package:flutter/material.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/features/modes/widgets/config_fields.dart';
import 'package:guardianangela/features/modes/widgets/event_specific_config.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Inline editor for a single [ChainStep], shown as the expanded body of a
/// step tile in the Mode Editor.
///
/// Stacks three collapsible subsections (spec 04 §Step Expansion):
/// 1. **Timing** — wait / duration / grace (initially expanded).
/// 2. **Event configuration** — the type-specific [EventSpecificConfig]
///    (initially expanded).
/// 3. **Retry & Advanced** — retry count and timing randomisation
///    (initially collapsed).
///
/// When [step].config is null the form displays [defaultConfig] (resolved
/// from `AppDefaults.eventDefaults`); editing any field materialises a
/// concrete per-step config via [onChanged]. A trailing action row exposes
/// Reset-to-defaults, Duplicate, and Delete.
class StepConfigPanel extends StatelessWidget {
  /// Creates a [StepConfigPanel].
  const StepConfigPanel({
    super.key,
    required this.step,
    required this.defaultConfig,
    required this.onChanged,
    required this.onDuplicate,
    required this.onReset,
    required this.onDelete,
    this.canDelete = true,
    this.contacts,
    this.onManageContacts,
  });

  /// The step being edited.
  final ChainStep step;

  /// The resolved default config for [step]'s type (shown when
  /// [ChainStep.config] is null, and the target of [onReset]).
  final StepConfig defaultConfig;

  /// Called with the updated step whenever a field changes.
  final ValueChanged<ChainStep> onChanged;

  /// All emergency contacts, for an `smsContact` step's recipient grid.
  final List<EmergencyContact>? contacts;

  /// Called when the user wants to manage contacts (empty-state deep link).
  final VoidCallback? onManageContacts;

  /// Called when the user taps Duplicate.
  final VoidCallback onDuplicate;

  /// Called when the user taps Reset to defaults.
  final VoidCallback onReset;

  /// Called when the user taps Delete.
  final VoidCallback onDelete;

  /// Whether the Delete action is enabled (false for the last remaining step).
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final StepConfig effective = step.config ?? defaultConfig;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Subsection(
          title: l10n.stepConfigTimingHeader,
          initiallyExpanded: true,
          children: <Widget>[
            IntTextField(
              label: l10n.stepFieldWait,
              value: step.waitSeconds,
              onChanged: (int v) => onChanged(step.copyWith(waitSeconds: v)),
            ),
            IntTextField(
              label: l10n.stepFieldDuration,
              value: step.durationSeconds,
              onChanged: (int v) =>
                  onChanged(step.copyWith(durationSeconds: v)),
            ),
            IntTextField(
              label: l10n.stepFieldGrace,
              value: step.gracePeriodSeconds,
              onChanged: (int v) =>
                  onChanged(step.copyWith(gracePeriodSeconds: v)),
            ),
          ],
        ),
        _Subsection(
          title: l10n.stepConfigEventHeader,
          initiallyExpanded: true,
          children: <Widget>[
            EventSpecificConfig(
              config: effective,
              onChanged: (StepConfig c) => onChanged(step.copyWith(config: c)),
              contacts: contacts,
              onManageContacts: onManageContacts,
            ),
          ],
        ),
        _Subsection(
          title: l10n.stepConfigAdvancedHeader,
          initiallyExpanded: false,
          children: <Widget>[
            IntSpinnerField(
              label: l10n.stepFieldRetryCount,
              value: step.retryCount,
              max: 10,
              onChanged: (int v) => onChanged(step.copyWith(retryCount: v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.stepFieldRandomize),
              value: step.randomize,
              onChanged: (bool v) => onChanged(step.copyWith(randomize: v)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: <Widget>[
            TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.restore),
              label: Text(l10n.stepResetDefaults),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextButton.icon(
                  onPressed: onDuplicate,
                  icon: const Icon(Icons.copy_outlined),
                  label: Text(l10n.stepDuplicate),
                ),
                TextButton.icon(
                  onPressed: canDelete ? onDelete : null,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.commonDelete),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// A collapsible subsection inside the step panel, with a flush header.
class _Subsection extends StatelessWidget {
  const _Subsection({
    required this.title,
    required this.initiallyExpanded,
    required this.children,
  });

  final String title;
  final bool initiallyExpanded;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      children: children,
    );
  }
}
