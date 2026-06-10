/// Shared presentation helpers for [ChainStepType] step tiles.
///
/// Used by both the Mode Editor and the Event Defaults screen so a step's
/// icon and one-sentence description stay consistent (spec 04 §Step Type
/// Preview). The descriptions mirror the per-type explanations in the spec's
/// step-type list.
library;

import 'package:flutter/material.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/orchestration/resolve_sms_targets.dart';
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

/// One-line per-type key-config summary for a collapsed step tile.
///
/// Spec 04:1631: "Key config summary (e.g., '30s ring, 5s grace' or
/// 'Contacts: Alice, Bob') — updates live as settings change", with the
/// Tier-1 examples of 04:1599 ("30s ring, 5s grace" for fakeCall; "30 min
/// interval, 3 retries" for disguisedReminder). The spec folds the timing
/// facts that matter for a type INTO this per-type line (grace for
/// fakeCall/holdButton, interval for disguisedReminder, duration for
/// countdownWarning) — there is no separate generic timing subtitle.
///
/// [config] must be the step's RESOLVED config (`step.config ??` the
/// `AppDefaults.eventDefaults` entry) — the same resolution the expanded
/// form edits and `startSession` snapshots, so the line never shows a
/// value the runtime would not use. The remaining inputs mirror runtime
/// resolution layers the summary depends on:
/// - [contacts]: the full contact list; smsContact recipients run through
///   [resolveSmsTargets] + the per-channel capability filter exactly as
///   `SmsContactStrategy` does, and phoneCallContact mirrors
///   `PhoneCallContactStrategy`'s primary → first-sorted → alternatives
///   fallback chain.
/// - [masterGradualVolume]: `AppSettings.alarmGradualVolume`; the alarm
///   ramps only when BOTH it and the step flag are on, so the ramp wording
///   appears only when the runtime would really ramp.
/// - [defaultEmergencyNumber]: `AppSettings.emergencyCallNumber`, the
///   number `CallEmergencyStrategy` dials when the step has no override.
String stepConfigSummary(
  AppLocalizations l10n, {
  required ChainStep step,
  required StepConfig config,
  required List<EmergencyContact> contacts,
  required bool masterGradualVolume,
  required String defaultEmergencyNumber,
}) => switch (config) {
  final HoldButtonConfig c => l10n.stepSummaryHoldButton(
    c.holdStyle.name,
    step.gracePeriodSeconds,
  ),
  DisguisedReminderConfig() => l10n.stepSummaryDisguisedReminder(
    _compactDuration(l10n, step.waitSeconds),
    l10n.stepSummaryRetryCount(step.retryCount),
  ),
  final CountdownWarningConfig c => l10n.stepSummaryCountdown(
    step.durationSeconds,
    c.style.name,
  ),
  final FakeCallConfig c => l10n.stepSummaryFakeCall(
    c.ringDurationSeconds,
    step.gracePeriodSeconds,
  ),
  final SmsContactConfig c => _smsSummary(l10n, c, contacts),
  final PhoneCallContactConfig c => _phoneCallSummary(l10n, c, contacts),
  final LoudAlarmConfig c =>
    (c.gradualVolume && masterGradualVolume)
        ? l10n.stepSummaryLoudAlarmRamp(
            (c.volume * 100).round(),
            c.soundChoice.name,
          )
        : l10n.stepSummaryLoudAlarm(
            (c.volume * 100).round(),
            c.soundChoice.name,
          ),
  final CallEmergencyConfig c =>
    c.sendLocationSmsFirst
        ? l10n.stepSummaryCallEmergencySmsFirst(
            c.emergencyNumber ?? defaultEmergencyNumber,
          )
        : l10n.stepSummaryCallEmergency(
            c.emergencyNumber ?? defaultEmergencyNumber,
          ),
  final HardwareButtonConfig c => switch (c.pressPattern) {
    PressPattern.repeatPress => l10n.stepSummaryHardwareRepeat(
      c.buttonType.name,
      c.pressCount,
    ),
    PressPattern.longPress => l10n.stepSummaryHardwareLong(
      c.buttonType.name,
      _trimSeconds(c.longPressDurationSeconds),
    ),
  },
};

/// How many leading recipient names an smsContact summary spells out
/// before truncating to "+N more" (spec 04:1631 "Contacts: Alice, Bob").
const int _kSmsSummaryMaxNames = 2;

/// Recipients line for an smsContact step ("To: Alice, Bob +3 more").
///
/// Pipeline mirrors the runtime: [resolveSmsTargets] (selection mode +
/// legacy id-list back-compat + stale-id skipping) restricted to contacts
/// whose channels include the configured channel — the same filter
/// `SmsContactStrategy` applies at dispatch. An empty result surfaces as
/// an explicit "no recipients" line rather than a blank.
String _smsSummary(
  AppLocalizations l10n,
  SmsContactConfig config,
  List<EmergencyContact> contacts,
) {
  final List<String> names = <String>[
    for (final EmergencyContact c in resolveSmsTargets(config, contacts))
      if (c.channels.contains(config.channel)) c.name,
  ];
  if (names.isEmpty) return l10n.stepSummarySmsNone;
  if (names.length <= _kSmsSummaryMaxNames) {
    return l10n.stepSummarySmsTo(names.join(', '));
  }
  final String shown = names.take(_kSmsSummaryMaxNames).join(', ');
  final String more = l10n.stepSummarySmsMore(
    names.length - _kSmsSummaryMaxNames,
  );
  return l10n.stepSummarySmsTo('$shown $more');
}

/// Callee line for a phoneCallContact step ("Calls Alice").
///
/// Mirrors `PhoneCallContactStrategy._resolveContact` exactly: explicit
/// primary id → first contact by sortOrder when no primary is set →
/// alternatives in order; when nothing resolves the runtime skips the
/// call, so the summary says so.
String _phoneCallSummary(
  AppLocalizations l10n,
  PhoneCallContactConfig config,
  List<EmergencyContact> contacts,
) {
  EmergencyContact? resolved;
  final String? primaryId = config.contactId;
  if (primaryId != null) {
    resolved = _contactById(contacts, primaryId);
  } else if (contacts.isNotEmpty) {
    final List<EmergencyContact> sorted = List<EmergencyContact>.of(contacts)
      ..sort(
        (EmergencyContact a, EmergencyContact b) =>
            a.sortOrder.compareTo(b.sortOrder),
      );
    resolved = sorted.first;
  }
  if (resolved == null) {
    for (final String altId in config.alternativeContactIds) {
      resolved = _contactById(contacts, altId);
      if (resolved != null) break;
    }
  }
  return resolved == null
      ? l10n.stepSummaryPhoneCallNone
      : l10n.stepSummaryPhoneCall(resolved.name);
}

EmergencyContact? _contactById(List<EmergencyContact> contacts, String id) {
  for (final EmergencyContact c in contacts) {
    if (c.id == id) return c;
  }
  return null;
}

/// Compact duration: whole minutes as "30 min", anything else as "45s"
/// (matches the spec 04:1599 "30 min interval" example).
String _compactDuration(AppLocalizations l10n, int seconds) =>
    (seconds >= 60 && seconds % 60 == 0)
    ? l10n.stepSummaryMinutes(seconds ~/ 60)
    : l10n.stepSummarySeconds(seconds);

/// Renders a seconds double without a trailing ".0" (2.0 → "2", 2.5 → "2.5").
String _trimSeconds(double seconds) => seconds == seconds.roundToDouble()
    ? seconds.round().toString()
    : seconds.toString();
