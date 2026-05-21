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

/// Issues-v4 #8 — top-3 step types surfaced as primary options on
/// initial picker open. Hold + Disguised Reminder + Hardware Button
/// covers the canonical "I want to start a session" entry-points;
/// the rest sit behind "More options...".
const List<ChainStepType> kTopStepTypes = [
  ChainStepType.holdButton,
  ChainStepType.disguisedReminder,
  ChainStepType.hardwareButton,
];

/// Opens a modal bottom sheet; returns the chosen [ChainStepType]
/// or null if cancelled.
///
/// Issues-v4 #8: the picker opens with three prominent rows (the
/// [kTopStepTypes] set) plus a "More options..." trigger that
/// reveals the full nine-row catalogue + category filter. Most users
/// pick from the top three, so the cluttered initial layout is
/// avoided.
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

  /// Issues-v4 #8 — when true, render the legacy nine-row catalogue.
  /// On open this is `false` so the user sees only the top three
  /// choices + a "More options..." trigger; tapping the trigger
  /// switches to the full list.
  bool _showAll = false;

  /// All entries with their picker icon, in the canonical order.
  static const List<(ChainStepType, IconData)> _entries = [
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showAll)
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
                if (!_showAll) ...[
                  // Issues-v4 #8: prominent top-3 entries.
                  for (final type in kTopStepTypes) _entryTile(context, type),
                  ListTile(
                    leading: const Icon(Icons.more_horiz),
                    title: Text(l.stepPickerMore),
                    onTap: () => setState(() => _showAll = true),
                  ),
                ] else
                  for (final e in _filteredEntries) _entryTile(context, e.$1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Returns entries filtered by the active category.
  List<(ChainStepType, IconData)> get _filteredEntries =>
      _filter == StepCategory.all
      ? _entries
      : [
          for (final e in _entries)
            if (categoryOf(e.$1) == _filter) e,
        ];

  /// Renders one ListTile entry. Looks up the icon from [_entries].
  Widget _entryTile(BuildContext context, ChainStepType type) {
    final icon = _entries
        .firstWhere(
          (e) => e.$1 == type,
          orElse: () => (type, Icons.help_outline),
        )
        .$2;
    return ListTile(
      leading: Icon(icon),
      title: Text(stepTypeLabel(context, type)),
      onTap: () => Navigator.of(context).pop(type),
    );
  }
}
