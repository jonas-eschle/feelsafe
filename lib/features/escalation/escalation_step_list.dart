import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safewayhome/l10n/app_localizations.dart';

import '../../core/constants/route_names.dart';
import '../../core/widgets/logarithmic_slider.dart';
import '../../data/models/escalation_step.dart';
import '../contacts/contacts_controller.dart';
import '../fake_call/fake_call_controller.dart';
import '../settings/settings_controller.dart';
import '../templates/templates_controller.dart';

/// Reusable reorderable escalation step list widget with expandable inline
/// configuration, add/remove steps, and per-step previews.
class EscalationStepList extends ConsumerStatefulWidget {
  final List<EscalationStep> steps;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int index) onRemove;
  final void Function(EscalationStepType type) onAdd;
  final void Function(int index, int seconds) onTimeoutChanged;

  const EscalationStepList({
    super.key,
    required this.steps,
    required this.onReorder,
    required this.onRemove,
    required this.onAdd,
    required this.onTimeoutChanged,
  });

  static String stepLabel(AppLocalizations l10n, EscalationStepType type) {
    return switch (type) {
      EscalationStepType.countdownWarning => l10n.stepCountdownWarning,
      EscalationStepType.disguisedReminder => l10n.stepDisguisedReminder,
      EscalationStepType.fakeCall => l10n.stepFakeCall,
      EscalationStepType.smsContacts => l10n.stepSmsContacts,
      EscalationStepType.loudAlarm => l10n.stepLoudAlarm,
      EscalationStepType.callEmergencyServices => l10n.stepCallEmergency,
    };
  }

  static IconData stepIcon(EscalationStepType type) {
    return switch (type) {
      EscalationStepType.countdownWarning => Icons.timer,
      EscalationStepType.disguisedReminder => Icons.notifications,
      EscalationStepType.fakeCall => Icons.phone_callback,
      EscalationStepType.smsContacts => Icons.sms,
      EscalationStepType.loudAlarm => Icons.volume_up,
      EscalationStepType.callEmergencyServices => Icons.emergency,
    };
  }

  @override
  ConsumerState<EscalationStepList> createState() => _EscalationStepListState();
}

class _EscalationStepListState extends ConsumerState<EscalationStepList> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.steps.length,
          onReorder: (oldIndex, newIndex) {
            // Adjust expanded index after reorder.
            setState(() {
              if (_expandedIndex == oldIndex) {
                final adjusted =
                    newIndex > oldIndex ? newIndex - 1 : newIndex;
                _expandedIndex = adjusted;
              } else {
                _expandedIndex = null;
              }
            });
            widget.onReorder(oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            final step = widget.steps[index];
            return _EscalationStepTile(
              key: ValueKey('${step.type.name}_$index'),
              step: step,
              index: index,
              label: EscalationStepList.stepLabel(l10n, step.type),
              icon: EscalationStepList.stepIcon(step.type),
              previewText: _previewText(step.type),
              isExpanded: _expandedIndex == index,
              canRemove: widget.steps.length > 1,
              onTap: () {
                setState(() {
                  _expandedIndex =
                      _expandedIndex == index ? null : index;
                });
              },
              onTimeoutChanged: (seconds) =>
                  widget.onTimeoutChanged(index, seconds),
              onRemove: () => widget.onRemove(index),
            );
          },
        ),
        _AddStepButton(
          existingTypes:
              widget.steps.map((s) => s.type).toSet(),
          onAdd: widget.onAdd,
        ),
      ],
    );
  }

  String _previewText(EscalationStepType type) {
    return switch (type) {
      EscalationStepType.countdownWarning => _countdownPreview(),
      EscalationStepType.fakeCall => _fakeCallPreview(),
      EscalationStepType.smsContacts => _smsPreview(),
      EscalationStepType.loudAlarm => 'Max volume siren',
      EscalationStepType.callEmergencyServices => _emergencyPreview(),
      EscalationStepType.disguisedReminder => _templatePreview(),
    };
  }

  String _countdownPreview() {
    final step = widget.steps
        .where((s) => s.type == EscalationStepType.countdownWarning)
        .firstOrNull;
    final secs = step?.timeoutSeconds ?? 10;
    return '${humanDuration(secs)} countdown with vibration';
  }

  String _fakeCallPreview() {
    final config = ref.watch(fakeCallConfigProvider).valueOrNull;
    final name = config?.callerName ?? 'Mom';
    return 'Caller: $name';
  }

  String _smsPreview() {
    final contacts = ref.watch(contactsControllerProvider).valueOrNull;
    final count = contacts?.length ?? 0;
    return 'Send to $count contact${count == 1 ? '' : 's'}';
  }

  String _emergencyPreview() {
    final settings = ref.watch(settingsControllerProvider).valueOrNull;
    final number = settings?.emergencyNumber ?? '112';
    return 'Call $number';
  }

  String _templatePreview() {
    final templates = ref.watch(templatesControllerProvider).valueOrNull;
    final count = templates?.length ?? 0;
    return 'Random from $count template${count == 1 ? '' : 's'}';
  }
}

class _EscalationStepTile extends StatelessWidget {
  final EscalationStep step;
  final int index;
  final String label;
  final IconData icon;
  final String previewText;
  final bool isExpanded;
  final bool canRemove;
  final VoidCallback onTap;
  final ValueChanged<int> onTimeoutChanged;
  final VoidCallback onRemove;

  const _EscalationStepTile({
    super.key,
    required this.step,
    required this.index,
    required this.label,
    required this.icon,
    required this.previewText,
    required this.isExpanded,
    required this.canRemove,
    required this.onTap,
    required this.onTimeoutChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Collapsed header -- always visible
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(icon, color: theme.colorScheme.primary),
                title: Text(label),
                subtitle: Text(
                  previewText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expanded settings
          if (isExpanded)
            _ExpandedSettings(
              step: step,
              canRemove: canRemove,
              onTimeoutChanged: onTimeoutChanged,
              onRemove: onRemove,
            ),
        ],
      ),
    );
  }
}

class _ExpandedSettings extends ConsumerWidget {
  final EscalationStep step;
  final bool canRemove;
  final ValueChanged<int> onTimeoutChanged;
  final VoidCallback onRemove;

  const _ExpandedSettings({
    required this.step,
    required this.canRemove,
    required this.onTimeoutChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          // Timeout slider (all steps)
          Text(
            l10n.checkInInterval,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 4),
          LogarithmicSlider(
            min: 5,
            max: 600,
            value: step.timeoutSeconds.toDouble().clamp(5, 600),
            onChanged: (v) => onTimeoutChanged(v.round()),
          ),
          const SizedBox(height: 8),

          // Step-specific extras
          ..._stepSpecificWidgets(context, ref),

          // Remove button
          if (canRemove) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.delete),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _stepSpecificWidgets(BuildContext context, WidgetRef ref) {
    return switch (step.type) {
      EscalationStepType.fakeCall => _fakeCallWidgets(context),
      EscalationStepType.smsContacts => _smsWidgets(context, ref),
      EscalationStepType.callEmergencyServices =>
        _emergencyWidgets(context, ref),
      EscalationStepType.disguisedReminder => _reminderWidgets(context, ref),
      _ => const [],
    };
  }

  List<Widget> _fakeCallWidgets(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      OutlinedButton.icon(
        onPressed: () => context.push(RouteNames.fakeCallSettings),
        icon: const Icon(Icons.settings),
        label: Text(l10n.fakeCallSettings),
      ),
    ];
  }

  List<Widget> _smsWidgets(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsControllerProvider).valueOrNull;
    final count = contacts?.length ?? 0;
    return [
      ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.people_outline),
        title: Text('Send to $count contact${count == 1 ? '' : 's'}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(RouteNames.contacts),
      ),
    ];
  }

  List<Widget> _emergencyWidgets(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider).valueOrNull;
    final number = settings?.emergencyNumber ?? '112';
    return [
      ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.emergency),
        title: Text('${AppLocalizations.of(context).emergencyNumber}: $number'),
      ),
    ];
  }

  List<Widget> _reminderWidgets(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templatesControllerProvider).valueOrNull;
    final count = templates?.length ?? 0;
    return [
      ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.shuffle),
        title: Text('Random from $count template${count == 1 ? '' : 's'}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(RouteNames.reminderTemplates),
      ),
    ];
  }
}

/// Button at the bottom of the step list to add a new step type not already
/// present in the chain.
class _AddStepButton extends StatelessWidget {
  final Set<EscalationStepType> existingTypes;
  final void Function(EscalationStepType type) onAdd;

  const _AddStepButton({
    required this.existingTypes,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final available = EscalationStepType.values
        .where((t) => !existingTypes.contains(t))
        .toList();

    if (available.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: OutlinedButton.icon(
        onPressed: () => _showAddSheet(context, available),
        icon: const Icon(Icons.add),
        label: const Text('Add Step'),
      ),
    );
  }

  void _showAddSheet(
    BuildContext context,
    List<EscalationStepType> available,
  ) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Add Step',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
              ...available.map((type) => ListTile(
                    leading: Icon(EscalationStepList.stepIcon(type)),
                    title:
                        Text(EscalationStepList.stepLabel(l10n, type)),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      onAdd(type);
                    },
                  )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
