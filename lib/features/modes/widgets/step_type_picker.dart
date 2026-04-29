/// Bottom-sheet picker for choosing a [ChainStepType].
library;

import 'package:flutter/material.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Categories used by the step-type picker filter.
///
/// Categories are an editor-only grouping — they are NOT persisted on
/// [ChainStep]. *Why:* a small "Action / Reminder / Check-in" filter
/// scales the picker as new step types are added without adding a
/// new model field. Each [ChainStepType] has exactly one category.
enum StepCategory {
  /// All categories.
  all,

  /// Outgoing actions: SMS, calls, alarms.
  action,

  /// Reminder / countdown surfaces.
  reminder,

  /// Check-in / disarm steps (hold button, hardware button).
  disarm,
}

/// Maps a step type to its category for the picker filter.
StepCategory categoryOf(ChainStepType type) => switch (type) {
  ChainStepType.holdButton => StepCategory.disarm,
  ChainStepType.hardwareButton => StepCategory.disarm,
  ChainStepType.disguisedReminder => StepCategory.reminder,
  ChainStepType.countdownWarning => StepCategory.reminder,
  ChainStepType.fakeCall => StepCategory.action,
  ChainStepType.smsContact => StepCategory.action,
  ChainStepType.phoneCallContact => StepCategory.action,
  ChainStepType.loudAlarm => StepCategory.action,
  ChainStepType.callEmergency => StepCategory.action,
};

/// Opens a modal bottom sheet; returns the chosen [ChainStepType]
/// or null if cancelled.
///
/// The picker exposes a [StepCategory] filter so a user adding a
/// fifth SMS step doesn't have to scroll past every reminder type.
Future<ChainStepType?> showStepTypePicker(BuildContext context) =>
    showModalBottomSheet<ChainStepType>(
      context: context,
      builder: (context) => const _StepTypePickerSheet(),
    );

/// Returns the localized label for a [ChainStepType].
String stepTypeLabel(BuildContext context, ChainStepType type) {
  final l = AppLocalizations.of(context);
  return switch (type) {
    ChainStepType.holdButton => l.stepTypeHoldButton,
    ChainStepType.disguisedReminder => l.stepTypeDisguisedReminder,
    ChainStepType.countdownWarning => l.stepTypeCountdownWarning,
    ChainStepType.fakeCall => l.stepTypeFakeCall,
    ChainStepType.smsContact => l.stepTypeSmsContact,
    ChainStepType.phoneCallContact => l.stepTypePhoneCallContact,
    ChainStepType.loudAlarm => l.stepTypeLoudAlarm,
    ChainStepType.callEmergency => l.stepTypeCallEmergency,
    ChainStepType.hardwareButton => l.stepTypeHardwareButton,
  };
}

/// Returns the localized label for a [StepCategory] chip.
String stepCategoryLabel(BuildContext context, StepCategory cat) {
  final l = AppLocalizations.of(context);
  return switch (cat) {
    StepCategory.all => l.stepCategoryAll,
    StepCategory.action => l.stepCategoryAction,
    StepCategory.reminder => l.stepCategoryReminder,
    StepCategory.disarm => l.stepCategoryDisarm,
  };
}

class _StepTypePickerSheet extends StatefulWidget {
  const _StepTypePickerSheet();

  @override
  State<_StepTypePickerSheet> createState() => _StepTypePickerSheetState();
}

class _StepTypePickerSheetState extends State<_StepTypePickerSheet> {
  StepCategory _filter = StepCategory.all;

  @override
  Widget build(BuildContext context) {
    final entries = <(ChainStepType, IconData)>[
      (ChainStepType.holdButton, Icons.touch_app),
      (ChainStepType.disguisedReminder, Icons.notifications),
      (ChainStepType.countdownWarning, Icons.timer),
      (ChainStepType.fakeCall, Icons.call),
      (ChainStepType.smsContact, Icons.sms),
      (ChainStepType.phoneCallContact, Icons.phone_forwarded),
      (ChainStepType.loudAlarm, Icons.alarm),
      (ChainStepType.callEmergency, Icons.emergency),
      (ChainStepType.hardwareButton, Icons.power_settings_new),
    ];
    final filtered = _filter == StepCategory.all
        ? entries
        : [for (final e in entries) if (categoryOf(e.$1) == _filter) e];
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final cat in StepCategory.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(stepCategoryLabel(context, cat)),
                        selected: _filter == cat,
                        onSelected: (sel) {
                          if (sel) setState(() => _filter = cat);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final e in filtered)
                  ListTile(
                    leading: Icon(e.$2),
                    title: Text(stepTypeLabel(context, e.$1)),
                    onTap: () => Navigator.of(context).pop(e.$1),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
