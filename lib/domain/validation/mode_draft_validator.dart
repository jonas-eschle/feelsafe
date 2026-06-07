import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/gps_destination_source.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/domain/triggers/distress_trigger.dart';

/// A single issue found by [validateModeDraft].
///
/// The [code] identifies the rule; the UI layer maps it to a localized
/// message. [blocking] mirrors the errors/warnings split used by
/// `ValidationResult` (spec 05 §SessionStartValidator): blocking issues
/// must prevent the save; non-blocking issues are surfaced as warnings the
/// user may acknowledge and proceed (aligns with the app philosophy of
/// minimizing false positives — a distress mode without an outbound step
/// may be intentional).
final class ModeValidationIssue {
  /// Creates a mode-validation issue.
  const ModeValidationIssue(this.code, {required this.blocking});

  /// The rule that was violated.
  final ModeValidationCode code;

  /// Whether this issue must block the save.
  final bool blocking;
}

/// The set of mode-editor save-validation rules (spec 04:1595-1599,
/// 1656-1659).
enum ModeValidationCode {
  /// Mode name is shorter than [kMinModeNameLength] characters (blocking).
  nameTooShort,

  /// The escalation chain has no steps (blocking).
  chainEmpty,

  /// A distress mode has no SMS / call action step, so it leaves no
  /// outbound trail (non-blocking warning, spec 04:1659).
  distressNoActionStep,

  /// A GPS-arrival disarm trigger uses a fixed destination but is missing
  /// its latitude or longitude (blocking, spec 03 §GpsArrivalDisarmTrigger).
  gpsFixedMissingCoords,

  /// A hardware-button distress trigger is internally inconsistent — e.g.
  /// long-press without a positive hold duration, or repeat-press carrying
  /// a stray duration / sub-minimum press count (blocking, spec 03
  /// §DistressTrigger; the enum doc mandates a save-time check).
  hardwareTriggerInconsistent,

  /// An `smsContact` step targets one or more contacts, but none of those
  /// targeted contacts has the step's send channel enabled — so the step
  /// would message nobody at runtime (blocking, spec 02:319 / 03:319).
  smsChannelNotOnContacts,
}

/// Minimum number of characters required for a mode name (spec 04:1597).
const int kMinModeNameLength = 2;

/// Minimum number of presses that counts as a repeat-press pattern.
///
/// A single press is indistinguishable from an accidental tap, so the
/// editor's spinner floors at this value; the validator treats anything
/// below it as inconsistent.
const int kMinRepeatPressCount = 2;

/// The chain step types that produce an outbound trail (SMS or a call).
///
/// Used to decide whether a distress mode has an action step
/// (spec 04:1659).
const Set<ChainStepType> _actionStepTypes = <ChainStepType>{
  ChainStepType.smsContact,
  ChainStepType.phoneCallContact,
  ChainStepType.callEmergency,
};

/// Validates a draft [mode] at save time, returning all issues.
///
/// The caller (the mode editor's save handler) blocks the save when any
/// returned issue has `blocking == true`, and surfaces non-blocking issues
/// as a confirm-to-proceed warning. The returned list preserves rule order
/// so the UI can show the first blocking issue deterministically.
///
/// [name] is the trimmed, current name from the editor's text field (the
/// draft's persisted name may still be the placeholder until save).
///
/// [contacts] is the full emergency-contact list, used to validate that each
/// `smsContact` step's send channel is enabled on at least one targeted
/// contact (spec 02:319). Defaults to an empty list — pass the real contacts
/// from the editor so the channel check can run.
List<ModeValidationIssue> validateModeDraft(
  SessionMode mode, {
  required String name,
  List<EmergencyContact> contacts = const <EmergencyContact>[],
}) {
  final issues = <ModeValidationIssue>[];

  if (name.trim().length < kMinModeNameLength) {
    issues.add(
      const ModeValidationIssue(
        ModeValidationCode.nameTooShort,
        blocking: true,
      ),
    );
  }

  if (mode.chainSteps.isEmpty) {
    issues.add(
      const ModeValidationIssue(ModeValidationCode.chainEmpty, blocking: true),
    );
  }

  if (mode.isDistressMode &&
      !mode.chainSteps.any((s) => _actionStepTypes.contains(s.type))) {
    issues.add(
      const ModeValidationIssue(
        ModeValidationCode.distressNoActionStep,
        blocking: false,
      ),
    );
  }

  for (final DisarmTrigger trigger in mode.disarmTriggers) {
    if (trigger is GpsArrivalDisarmTrigger &&
        trigger.destinationSource == GpsDestinationSource.fixed &&
        (trigger.lat == null || trigger.lng == null)) {
      issues.add(
        const ModeValidationIssue(
          ModeValidationCode.gpsFixedMissingCoords,
          blocking: true,
        ),
      );
    }
  }

  for (final DistressTrigger trigger in mode.distressTriggers) {
    if (trigger is HardwareButtonDistressTrigger &&
        !_hardwareTriggerConsistent(trigger)) {
      issues.add(
        const ModeValidationIssue(
          ModeValidationCode.hardwareTriggerInconsistent,
          blocking: true,
        ),
      );
    }
  }

  for (final ChainStep step in mode.chainSteps) {
    final StepConfig? config = step.config;
    if (config is SmsContactConfig &&
        _smsStepTargetsContactsWithoutChannel(config, contacts)) {
      issues.add(
        const ModeValidationIssue(
          ModeValidationCode.smsChannelNotOnContacts,
          blocking: true,
        ),
      );
    }
  }

  return issues;
}

/// Whether an `smsContact` [config] targets at least one contact yet none of
/// those targeted contacts has [SmsContactConfig.channel] enabled.
///
/// Mirrors the runtime resolver (`sms_contact_strategy._resolveContacts` +
/// the `channels.contains` filter): the step's selected recipients are
/// resolved first, then filtered by channel. A step that targets nobody
/// (empty repo, `specificIds` with no ids) is NOT flagged here — an empty
/// recipient set is the no-contacts concern handled (as a warning, not a
/// block) by `SessionStartValidator`, and blocking it would be a false
/// positive while the user is still building the mode. Only a genuine
/// misconfiguration — recipients chosen, but the chosen channel is on none
/// of them — blocks the save (spec 02:319).
bool _smsStepTargetsContactsWithoutChannel(
  SmsContactConfig config,
  List<EmergencyContact> contacts,
) {
  final List<EmergencyContact> targeted = _resolveSmsTargets(config, contacts);
  if (targeted.isEmpty) return false;
  return !targeted.any((c) => c.channels.contains(config.channel));
}

/// Resolves the contacts an `smsContact` [config] targets, before the
/// channel filter, mirroring `sms_contact_strategy._resolveContacts`.
List<EmergencyContact> _resolveSmsTargets(
  SmsContactConfig config,
  List<EmergencyContact> contacts,
) {
  // Legacy back-compat: allContacts + explicit contactIds → specific IDs.
  final List<String>? ids = config.contactIds;
  if (config.contactSelection == SmsContactSelection.allContacts &&
      ids != null &&
      ids.isNotEmpty) {
    return _contactsByIds(ids, contacts);
  }
  return switch (config.contactSelection) {
    SmsContactSelection.allContacts => contacts,
    SmsContactSelection.firstContact =>
      contacts.isEmpty
          ? const <EmergencyContact>[]
          : <EmergencyContact>[
              (List<EmergencyContact>.from(
                contacts,
              )..sort((a, b) => a.sortOrder.compareTo(b.sortOrder))).first,
            ],
    SmsContactSelection.specificIds =>
      (ids == null || ids.isEmpty)
          ? const <EmergencyContact>[]
          : _contactsByIds(ids, contacts),
  };
}

/// The contacts in [contacts] whose id appears in [ids] (order preserved).
List<EmergencyContact> _contactsByIds(
  List<String> ids,
  List<EmergencyContact> contacts,
) {
  final Map<String, EmergencyContact> byId = <String, EmergencyContact>{
    for (final EmergencyContact c in contacts) c.id: c,
  };
  return <EmergencyContact>[
    for (final String id in ids)
      if (byId[id] case final EmergencyContact c) c,
  ];
}

/// Whether [trigger] satisfies its pattern's field-consistency contract.
///
/// - [PressPattern.repeatPress]: needs a press count of at least
///   [kMinRepeatPressCount] and no stray hold duration.
/// - [PressPattern.longPress]: needs a positive hold duration.
bool _hardwareTriggerConsistent(HardwareButtonDistressTrigger trigger) =>
    switch (trigger.pattern) {
      PressPattern.repeatPress =>
        trigger.pressCount >= kMinRepeatPressCount &&
            trigger.durationSeconds == null,
      PressPattern.longPress =>
        trigger.durationSeconds != null && trigger.durationSeconds! > 0,
    };
