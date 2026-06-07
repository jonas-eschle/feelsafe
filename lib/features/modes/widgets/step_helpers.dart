/// Shared presentation helpers for [ChainStepType] step tiles.
///
/// Used by both the Mode Editor and the Event Defaults screen so a step's
/// icon and one-sentence description stay consistent (spec 04 §Step Type
/// Preview). The descriptions mirror the per-type explanations in the spec's
/// step-type list.
library;

import 'package:flutter/material.dart';

import 'package:guardianangela/domain/enums/chain_step_type.dart';

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

/// Returns a one-sentence, user-facing description of what [type] does.
String stepDescription(ChainStepType type) => switch (type) {
  ChainStepType.holdButton =>
    'Hold to stay safe — releasing starts a grace countdown.',
  ChainStepType.disguisedReminder =>
    'Sends a disguised notification — respond to confirm safety.',
  ChainStepType.countdownWarning =>
    'Shows a countdown with sound and flash as a last warning.',
  ChainStepType.fakeCall => 'Simulates an incoming call — answer or decline.',
  ChainStepType.smsContact =>
    'Sends an SMS with your location to emergency contacts.',
  ChainStepType.phoneCallContact => 'Calls an emergency contact directly.',
  ChainStepType.loudAlarm =>
    'Plays a max-volume alarm with flash to attract attention.',
  ChainStepType.callEmergency =>
    'Calls emergency services (112/911) automatically.',
  ChainStepType.hardwareButton =>
    'Watches a hardware button for a panic press pattern.',
};
