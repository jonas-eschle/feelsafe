/// Bottom-sheet picker for choosing a [ChainStepType].
library;

import 'package:flutter/material.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Opens a modal bottom sheet; returns the chosen [ChainStepType]
/// or null if cancelled.
Future<ChainStepType?> showStepTypePicker(BuildContext context) =>
    showModalBottomSheet<ChainStepType>(
      context: context,
      builder: (context) {
        final l = AppLocalizations.of(context);
        final entries = <(ChainStepType, String, IconData)>[
          (ChainStepType.holdButton, l.stepTypeHoldButton, Icons.touch_app),
          (
            ChainStepType.disguisedReminder,
            l.stepTypeDisguisedReminder,
            Icons.notifications,
          ),
          (
            ChainStepType.countdownWarning,
            l.stepTypeCountdownWarning,
            Icons.timer,
          ),
          (ChainStepType.fakeCall, l.stepTypeFakeCall, Icons.call),
          (ChainStepType.smsContact, l.stepTypeSmsContact, Icons.sms),
          (
            ChainStepType.phoneCallContact,
            l.stepTypePhoneCallContact,
            Icons.phone_forwarded,
          ),
          (ChainStepType.loudAlarm, l.stepTypeLoudAlarm, Icons.alarm),
          (
            ChainStepType.callEmergency,
            l.stepTypeCallEmergency,
            Icons.emergency,
          ),
          (
            ChainStepType.hardwareButton,
            l.stepTypeHardwareButton,
            Icons.power_settings_new,
          ),
        ];
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final e in entries)
                ListTile(
                  leading: Icon(e.$3),
                  title: Text(e.$2),
                  onTap: () => Navigator.of(context).pop(e.$1),
                ),
            ],
          ),
        );
      },
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
