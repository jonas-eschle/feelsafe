/// Shared presentation helpers for [ChainStepType] step tiles.
///
/// Used by both the Mode Editor and the Event Defaults screen so a step's
/// icon and one-sentence description stay consistent (spec 04 §Step Type
/// Preview). The descriptions mirror the per-type explanations in the spec's
/// step-type list.
library;

import 'package:flutter/material.dart';

import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Returns the localized, user-facing name of [type] for a step tile title.
String stepName(AppLocalizations l10n, ChainStepType type) => switch (type) {
  ChainStepType.holdButton => l10n.chainStepNameHoldButton,
  ChainStepType.disguisedReminder => l10n.chainStepNameDisguisedReminder,
  ChainStepType.countdownWarning => l10n.chainStepNameCountdownWarning,
  ChainStepType.fakeCall => l10n.chainStepNameFakeCall,
  ChainStepType.smsContact => l10n.chainStepNameSmsContact,
  ChainStepType.phoneCallContact => l10n.chainStepNamePhoneCallContact,
  ChainStepType.loudAlarm => l10n.chainStepNameLoudAlarm,
  ChainStepType.callEmergency => l10n.chainStepNameCallEmergency,
  ChainStepType.hardwareButton => l10n.chainStepNameHardwareButton,
};

/// Returns the Material icon representing [type].
IconData stepIcon(ChainStepType type) => switch (type) {
  ChainStepType.holdButton => Icons.touch_app_outlined,
  ChainStepType.disguisedReminder => Icons.notifications_outlined,
  ChainStepType.countdownWarning => Icons.warning_amber_outlined,
  ChainStepType.fakeCall => Icons.phone_outlined,
  ChainStepType.smsContact => Icons.message_outlined,
  ChainStepType.phoneCallContact => Icons.phone_forwarded_outlined,
  ChainStepType.loudAlarm => Icons.volume_up_outlined,
  ChainStepType.callEmergency => Icons.emergency_outlined,
  ChainStepType.hardwareButton => Icons.touch_app,
};

/// Returns the localized one-sentence description of what [type] does.
///
/// Sentences mirror spec 04:1621-1630 (§Step Type Preview) verbatim.
String stepDescription(AppLocalizations l10n, ChainStepType type) =>
    switch (type) {
      ChainStepType.holdButton => l10n.chainStepDescHoldButton,
      ChainStepType.disguisedReminder => l10n.chainStepDescDisguisedReminder,
      ChainStepType.countdownWarning => l10n.chainStepDescCountdownWarning,
      ChainStepType.fakeCall => l10n.chainStepDescFakeCall,
      ChainStepType.smsContact => l10n.chainStepDescSmsContact,
      ChainStepType.phoneCallContact => l10n.chainStepDescPhoneCallContact,
      ChainStepType.loudAlarm => l10n.chainStepDescLoudAlarm,
      ChainStepType.callEmergency => l10n.chainStepDescCallEmergency,
      ChainStepType.hardwareButton => l10n.chainStepDescHardwareButton,
    };
