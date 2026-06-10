// Spec-coverage matrix — Phase 9 ENFORCED (M5/C8).
//
// Three matrices, all asserted mechanically (no aspirational rows):
//
//  1. [_rNnCoverage] — every R-NN resolution item from
//     docs/rewrite/spec-audit.md §Resolution table (45 total) → ≥ 1 live
//     test file. Items whose resolution was a pure spec edit (or that
//     were superseded before v3 code existed) carry an explicit
//     rationale marker instead — see [_markerPattern]. Empty rows are
//     always a failure.
//  2. [_specSectionCoverage] — every numbered spec-section ID → ≥ 1
//     live test file.
//  3. [_contractTestIds] / [_deviceE2eRows] — every INT-###/WID-###
//     test-ID from the spec-07 contract table → the file whose test
//     NAMES embed the ID (the grep-able convention, e.g. `INT-007`),
//     plus the device-e2e rows (#11, #12-A/B, stealth per-preset).
//     Device rows live under integration_test/ and run only via
//     tool/device_e2e/*.sh on a real device/emulator — they are
//     NEVER marked host-green; here we pin file + embedded marker +
//     runner script so the contract cannot silently rot.
//
// Fail-loud rules (Phase 9, D6):
//  - empty row → fail
//  - referenced file missing on disk → fail
//  - rationale marker without a recognised reason prefix → fail
//  - INT/WID/device ID absent from a test name in its file → fail
//  - an INT-/WID- ID mentioned in docs/spec/07-test-plan.md that has
//    no matrix row → fail (both directions are mechanical)

import 'dart:io';

import 'package:test/test.dart';

/// Recognised non-file rationale rows.
///
/// Why: some audit items were resolved purely inside the spec (doc
/// edits) or reference a feature dropped before v3 code existed —
/// demanding a test file there would force a fake test. The marker must
/// still carry an explicit reason; an empty row remains a hard fail, so
/// nothing can be waved through silently.
final RegExp _markerPattern = RegExp(r'^\((doc-edit|superseded|ci): .+\)$');

/// Matches an ID embedded at the start of a `test(...)` /
/// `testWidgets(...)` name (single-quoted, possibly on the next line).
RegExp _testNamePattern(String id) =>
    RegExp("(?:test|testWidgets)\\(\\s*'${RegExp.escape(id)}");

// ─────────────────────────────────────────────────────────────────────
// 1. Audit R-NN items (docs/rewrite/spec-audit.md §Resolution, 45 total)
//
// Comments quote the audit item (the Phase-0 skeleton paraphrases had
// drifted from the audit's numbering; the audit table is the source).
// ─────────────────────────────────────────────────────────────────────
const Map<String, List<String>> _rNnCoverage = {
  // R-1: fakeCall is an event, not a pause (Pivot 2).
  'R-1': ['test/domain/engine/fake_call_is_event_test.dart'],
  // R-2: holdButton grace default 0; Walk-Mode seed keeps 1 as override.
  'R-2': [
    'test/data/seed_data_test.dart',
    'test/domain/models/event_defaults_test.dart',
  ],
  // R-3: LoudAlarmSound = {siren, custom} only.
  'R-3': [
    'test/domain/enums/exhaustiveness_test.dart',
    'test/domain/configs/loud_alarm_config_test.dart',
  ],
  // R-4: gradual-volume ramp default 5 s.
  'R-4': ['test/domain/configs/loud_alarm_config_test.dart'],
  // R-5: StealthConfig.notificationDisguise is bool.
  'R-5': ['test/domain/models/stealth_config_test.dart'],
  // R-6: StealthConfig.fakeIcon is StealthIconPreset.
  'R-6': ['test/domain/models/stealth_config_test.dart'],
  // R-7: AppSettings canonical model lives in spec 03 (sketch deleted).
  'R-7': ['test/domain/models/app_settings_test.dart'],
  // R-8: emergency number blank ⇒ device locale ⇒ fallback '112'.
  'R-8': ['test/domain/models/emergency_numbers_test.dart'],
  // R-9: repeatCount → retryCount rename (legacy name is a CI grep gate).
  'R-9': ['test/domain/models/chain_step_test.dart'],
  // R-10: simulationSilent defaults to true (Extra 49).
  'R-10': ['test/features/session/session_controller_lifecycle_test.dart'],
  // R-11: canonical declineIsSafe = true (decline = disarm).
  'R-11': ['test/domain/configs/fake_call_config_test.dart'],
  // R-12: soft-delete + 7-day trash shipped (INT-014).
  'R-12': ['test/integration/log_soft_delete_test.dart'],
  // R-13: /settings/modes-and-chains hub deleted (route table has no
  // such route; the router test pins the full table).
  'R-13': ['test/router/app_router_test.dart'],
  // R-14: three hold styles {largeButton, fullScreen, fakeLockScreen}.
  'R-14': ['test/domain/enums/exhaustiveness_test.dart'],
  // R-15: template editor route /settings/templates/edit.
  'R-15': ['test/features/template_editor/template_editor_screen_test.dart'],
  // R-16: 3-screen onboarding.
  'R-16': ['test/integration/onboarding_flow_widget_test.dart'],
  // R-17: SmsContactSelection enum (SmsRecipient deleted).
  'R-17': ['test/domain/enums/exhaustiveness_test.dart'],
  // R-18: "Distress Mode(s)" terminology in UI.
  'R-18': ['test/features/distress_modes/distress_modes_screen_test.dart'],
  // R-19: spec doc index rows for 09/10/11.
  'R-19': ['(doc-edit: spec index rows added — no runtime surface)'],
  // R-20: engine leap() API name.
  'R-20': ['test/domain/engine/leap_test.dart'],
  // R-21: LogGpsOverride enum added to spec 03.
  'R-21': ['test/domain/enums/exhaustiveness_test.dart'],
  // R-22: CountdownStyle enum added to spec 03.
  'R-22': ['test/domain/enums/exhaustiveness_test.dart'],
  // R-23: DistressTrigger / DisarmTrigger sealed schemas.
  'R-23': [
    'test/domain/triggers/distress_trigger_test.dart',
    'test/domain/triggers/disarm_trigger_test.dart',
  ],
  // R-24: GpsDestinationSource enum added to spec 03.
  'R-24': ['test/domain/enums/exhaustiveness_test.dart'],
  // R-25: SessionLogRecorder service + engine→recorder subscription.
  'R-25': ['test/services/session_log_recorder_test.dart'],
  // R-26: no stored PIN length — per-keystroke hash compare instead
  // (spec 06:151: AppSettings.pinLength no longer exists).
  'R-26': ['test/features/launch_gate/launch_pin_screen_test.dart'],
  // R-27: wrong-PIN counter scope — in-memory, shared across prompts,
  // resets on correct entry (spec 06:187 §Counter scope).
  'R-27': ['test/features/session/session_screen_test.dart'],
  // R-28: permission audit flow (cold start / session start /
  // mid-session revocation check points).
  'R-28': ['test/services/permission_audit_service_test.dart'],
  // R-29: "Session interrupted" prompt (INT-012; informational only —
  // there is NO session restore from disk).
  'R-29': ['test/integration/interrupted_prompt_session_test.dart'],
  // R-30: gradual volume requires per-step AND global flags.
  'R-30': [
    'test/domain/orchestration/strategies/loud_alarm_strategy_test.dart',
  ],
  // R-31: biometric flags live in AppSettings (no SharedPreferences fork).
  'R-31': ['test/domain/models/app_settings_test.dart'],
  // R-32: distress-cancel biometric branch parallel to the PIN branch.
  'R-32': ['test/features/session/session_screen_test.dart'],
  // R-33: empty-distress-modes invariant (last/default mode undeletable).
  'R-33': ['test/features/distress_modes/distress_modes_controller_test.dart'],
  // R-34: BatteryAlertConfig step-type whitelist.
  'R-34': [
    '(superseded: BatteryAlertConfig dropped from v3 — absent from spec 03 and lib/)',
  ],
  // R-35: sessionLogRetentionDays (180) and trashRetentionDays (7) are
  // distinct (INT-013 two-stage retention).
  'R-35': ['test/integration/log_retention_test.dart'],
  // R-36: Route Names appendix (GoRouter name: values).
  'R-36': ['test/router/app_router_test.dart'],
  // R-37: StealthIconPreset.none ⇒ no icon override.
  'R-37': ['test/domain/models/stealth_config_test.dart'],
  // R-38: HiveRecoveryApp reference removed (Hive retired).
  'R-38': ['(doc-edit: Hive recovery reference deleted — Hive retired)'],
  // R-39: spec-11 §DE-2/§DE-3 cross-references resolved.
  'R-39': ['(doc-edit: spec-11 DE-2/DE-3 cross-references resolved)'],
  // R-40: single SessionLog.hadMedicalInfo definition.
  'R-40': ['test/domain/models/session_log_test.dart'],
  // R-41: BatteryAlertConfig.sendSms legacy getter deleted.
  'R-41': [
    '(superseded: BatteryAlertConfig dropped from v3 — absent from spec 03 and lib/)',
  ],
  // R-42: deceptive "Old PIN entered" dialog has mock + event + test.
  'R-42': [
    'test/features/session/session_screen_test.dart',
    'test/core/widgets/core_widget_tails_test.dart',
  ],
  // R-43: glossary deduplicated into 09-glossary.md.
  'R-43': ['(doc-edit: glossary deduplicated into 09-glossary.md)'],
  // R-44: notificationDisguise prose aligned to bool (per R-5).
  'R-44': [
    'test/domain/models/stealth_config_test.dart',
    '(doc-edit: prose aligned to bool per R-5)',
  ],
  // R-45: legacy sound-name mentions cleaned up (per R-3).
  'R-45': ['(doc-edit: sound-name cleanup pass per R-3)'],
};

// ─────────────────────────────────────────────────────────────────────
// 2. Spec section IDs
// ─────────────────────────────────────────────────────────────────────
const Map<String, List<String>> _specSectionCoverage = {
  '00:Architecture': [
    'test/main_bootstrap_test.dart',
    'test/services/service_providers_wiring_test.dart',
  ],
  '00:Invariants': ['test/domain/engine/invariants_test.dart'],
  '00:Localization': [
    'test/l10n/parity_test.dart',
    'test/l10n/locale_smoke_test.dart',
  ],
  '01:EngineState sealed': ['test/domain/engine/state_machine_test.dart'],
  '01:Invariant 1': ['test/domain/engine/invariants_test.dart'],
  '01:Invariant 2': ['test/domain/engine/invariants_test.dart'],
  '01:Invariant 3': ['test/domain/engine/invariants_test.dart'],
  '01:Invariant 4': ['test/domain/engine/invariants_test.dart'],
  '01:Invariant 5': ['test/domain/engine/invariants_test.dart'],
  '01:Invariant 6': [
    'test/domain/engine/invariants_test.dart',
    'test/domain/engine/hold_button_state_machine_test.dart',
  ],
  '01:ThreePhaseTimer': ['test/domain/engine/three_phase_timing_test.dart'],
  '01:Jitter': ['test/domain/engine/jitter_bounds_test.dart'],
  '01:SpeedMultiplier': [
    'test/domain/engine/speed_multiplier_test.dart',
    'test/domain/engine/background_clamp_test.dart',
  ],
  '01:DistressReplacement': [
    'test/domain/engine/distress_replacement_finality_test.dart',
  ],
  '01:Events': ['test/domain/engine/events_emitted_test.dart'],
  '02:holdButton': [
    'test/domain/orchestration/strategies/hold_button_strategy_test.dart',
    'test/domain/configs/hold_button_config_test.dart',
  ],
  '02:disguisedReminder': [
    'test/domain/orchestration/strategies/disguised_reminder_strategy_test.dart',
    'test/domain/configs/disguised_reminder_config_test.dart',
  ],
  '02:hardwareButton': [
    'test/domain/orchestration/strategies/hardware_button_strategy_test.dart',
    'test/domain/configs/hardware_button_config_test.dart',
  ],
  '02:countdownWarning': [
    'test/domain/orchestration/strategies/countdown_warning_strategy_test.dart',
    'test/domain/configs/countdown_warning_config_test.dart',
  ],
  '02:phoneCallContact': [
    'test/domain/orchestration/strategies/phone_call_contact_strategy_test.dart',
    'test/domain/configs/phone_call_contact_config_test.dart',
  ],
  '02:smsContact': [
    'test/domain/orchestration/strategies/sms_contact_strategy_test.dart',
    'test/domain/configs/sms_contact_config_test.dart',
  ],
  '02:loudAlarm': [
    'test/domain/orchestration/strategies/loud_alarm_strategy_test.dart',
    'test/domain/configs/loud_alarm_config_test.dart',
  ],
  '02:fakeCall': [
    'test/domain/orchestration/strategies/fake_call_strategy_test.dart',
    'test/domain/configs/fake_call_config_test.dart',
  ],
  // Was '02:vibrationOnly' in the Phase-0 skeleton — stale: spec 02 has
  // no vibrationOnly step type; the ninth type is callEmergency
  // (lib/domain/enums/chain_step_type.dart).
  '02:callEmergency': [
    'test/domain/orchestration/strategies/call_emergency_strategy_test.dart',
    'test/domain/configs/call_emergency_config_test.dart',
  ],
  '03:Models': [
    'test/domain/models/chain_step_test.dart',
    'test/domain/models/session_mode_test.dart',
    'test/domain/models/session_log_test.dart',
  ],
  '03:Enums': ['test/domain/enums/exhaustiveness_test.dart'],
  '03:SealedHierarchies': [
    'test/domain/triggers/distress_trigger_test.dart',
    'test/domain/triggers/disarm_trigger_test.dart',
  ],
  '03:Persistence': [
    'test/data/db/database_test.dart',
    'test/data/db/dao/session_logs_dao_test.dart',
  ],
  '03:Seed': [
    'test/data/seed_data_test.dart',
    'test/data/seed/schema_mismatch_nukes_test.dart',
  ],
  '04:24screens': ['test/router/app_router_test.dart'],
  '04:Routing': ['test/router/app_router_test.dart'],
  '04:Onboarding': ['test/integration/onboarding_flow_widget_test.dart'],
  '04:DeceptiveOldPinDialog': [
    'test/features/session/session_screen_test.dart',
    'test/core/widgets/core_widget_tails_test.dart',
  ],
  '05:Services': ['test/services/service_providers_wiring_test.dart'],
  '05:ServiceProviders': ['test/services/service_providers_wiring_test.dart'],
  '05:SessionLogRecorder': ['test/services/session_log_recorder_test.dart'],
  '05:PermissionAudit': ['test/services/permission_audit_service_test.dart'],
  '05:NativeChannels': [
    'test/services/call_state_service_real_test.dart',
    'test/services/flash_service_real_test.dart',
    'test/services/hardware_button_service_real_test.dart',
  ],
  '06:Security': [
    'test/features/settings_security/settings_security_controller_test.dart',
    'test/integration/wrong_pin_distress_session_test.dart',
  ],
  '06:AppDefaults': ['test/domain/models/app_defaults_test.dart'],
  '06:ModeOverrides': ['test/domain/models/mode_overrides_test.dart'],
  '06:StealthConfig': [
    'test/domain/models/stealth_config_test.dart',
    'test/features/settings_stealth/settings_stealth_controller_test.dart',
  ],
  '06:GpsLogging': [
    'test/domain/models/gps_logging_config_test.dart',
    'test/features/gps_logging/gps_logging_controller_test.dart',
  ],
  '07:WalkModeFlow': ['test/integration/walk_mode_session_test.dart'],
  '07:DateModeFlow': ['test/integration/date_mode_session_test.dart'],
  '07:DistressFlow': ['test/integration/distress_session_test.dart'],
  '07:SimulationFlow': ['test/integration/simulation_disarm_session_test.dart'],
  // Android-only capabilities are proven on a real device/emulator via
  // tool/device_e2e/*.sh — the files are pinned here, but the rows are
  // never marked host-green (see _deviceE2eRows).
  '10:AndroidMatrix': [
    'integration_test/real_call_pause_test.dart',
    'integration_test/background_throttle_test.dart',
    'integration_test/stealth_icon_switch_test.dart',
  ],
  // iOS-specific behaviour is proven by the CI build-ios job only —
  // never faked as device-green (owner decision). Host tests pin the
  // Dart-side iOS branches where they exist.
  '10:iOSMatrix': [
    '(ci: build-ios — sole proof for iOS-specific rows; never faked as device-green)',
    'test/core/utils/permission_utils_test.dart',
  ],
};

// ─────────────────────────────────────────────────────────────────────
// 3. Spec-07 contract test-IDs (embedded in test names — grep-able)
// ─────────────────────────────────────────────────────────────────────
const Map<String, String> _contractTestIds = {
  'INT-001': 'test/integration/walk_mode_session_test.dart',
  'INT-002': 'test/integration/walk_mode_session_test.dart',
  'INT-003': 'test/integration/date_mode_session_test.dart',
  'INT-004': 'test/integration/date_mode_session_test.dart',
  'INT-005': 'test/integration/distress_session_test.dart',
  'INT-006': 'test/integration/distress_session_test.dart',
  // INT-007/008 host halves; the device half of INT-007 is the
  // '#11' row in _deviceE2eRows (integration_test/real_call_pause_test).
  'INT-007': 'test/integration/call_state_session_test.dart',
  'INT-008': 'test/integration/call_state_session_test.dart',
  'INT-009': 'test/integration/simulation_disarm_session_test.dart',
  'INT-010': 'test/integration/simulation_disarm_session_test.dart',
  'INT-011': 'test/integration/wrong_pin_distress_session_test.dart',
  'INT-012': 'test/integration/interrupted_prompt_session_test.dart',
  'INT-013': 'test/integration/log_retention_test.dart',
  'INT-014': 'test/integration/log_soft_delete_test.dart',
  'WID-001': 'test/integration/onboarding_flow_widget_test.dart',
  'WID-002': 'test/integration/language_switch_widget_test.dart',
};

/// Device-e2e rows: marker embedded in a `testWidgets` name → file.
///
/// These run ONLY on a device/emulator via the paired runner script
/// (tag `device-e2e`); the host suite merely pins that the contract
/// (file + named test + runner) keeps existing.
const Map<String, String> _deviceE2eRows = {
  // #11 — incoming-call pause/resume (device half of INT-007).
  '#11': 'integration_test/real_call_pause_test.dart',
  // #12 — background-throttle survival (60x clamp + round-trip).
  '#12-A': 'integration_test/background_throttle_test.dart',
  '#12-B': 'integration_test/background_throttle_test.dart',
  // Stealth launcher-alias swap, one assertion per preset.
  'per-preset': 'integration_test/stealth_icon_switch_test.dart',
};

const List<String> _deviceE2eRunners = [
  'tool/device_e2e/run_real_call_pause.sh',
  'tool/device_e2e/run_background_throttle.sh',
  'tool/device_e2e/run_stealth_per_preset.sh',
];

void main() {
  group('Spec coverage matrix (Phase 9 — enforced)', () {
    test('R-NN coverage map has 45 entries', () {
      expect(_rNnCoverage.length, 45);
    });

    test('every R-NN row has ≥ 1 live test file or explicit rationale', () {
      for (final entry in _rNnCoverage.entries) {
        expect(
          entry.value,
          isNotEmpty,
          reason: '${entry.key} has no test coverage',
        );
        for (final ref in entry.value) {
          if (ref.startsWith('(')) {
            expect(
              _markerPattern.hasMatch(ref),
              isTrue,
              reason:
                  '${entry.key}: rationale marker "$ref" must match '
                  '$_markerPattern',
            );
          } else {
            expect(
              File(ref).existsSync(),
              isTrue,
              reason: '${entry.key}: referenced test file missing: $ref',
            );
          }
        }
      }
    });

    test('every spec section has ≥ 1 live test file', () {
      for (final entry in _specSectionCoverage.entries) {
        expect(
          entry.value,
          isNotEmpty,
          reason: '${entry.key} has no test coverage',
        );
        for (final ref in entry.value) {
          if (ref.startsWith('(')) {
            expect(
              _markerPattern.hasMatch(ref),
              isTrue,
              reason:
                  '${entry.key}: rationale marker "$ref" must match '
                  '$_markerPattern',
            );
          } else {
            expect(
              File(ref).existsSync(),
              isTrue,
              reason: '${entry.key}: referenced test file missing: $ref',
            );
          }
        }
      }
    });

    test('every INT/WID contract ID is embedded in a test name '
        'in its mapped file', () {
      for (final entry in _contractTestIds.entries) {
        final file = File(entry.value);
        expect(
          file.existsSync(),
          isTrue,
          reason: '${entry.key}: mapped file missing: ${entry.value}',
        );
        final content = file.readAsStringSync();
        expect(
          _testNamePattern(entry.key).hasMatch(content),
          isTrue,
          reason:
              '${entry.key} is not embedded in any test name in '
              '${entry.value} (convention: names start with the ID)',
        );
      }
    });

    test('the spec-07 scenario IDs and this matrix agree (both ways)', () {
      final spec = File('docs/spec/07-test-plan.md');
      expect(spec.existsSync(), isTrue, reason: 'spec-07 missing');
      final specIds = RegExp(
        r'(?:INT|WID)-\d{3}',
      ).allMatches(spec.readAsStringSync()).map((m) => m.group(0)!).toSet();
      expect(
        specIds.difference(_contractTestIds.keys.toSet()),
        isEmpty,
        reason: 'spec-07 mentions IDs with no matrix row — map them here',
      );
      expect(
        _contractTestIds.keys.toSet().difference(specIds),
        isEmpty,
        reason: 'matrix has IDs the spec-07 contract no longer mentions',
      );
    });

    test('device-e2e rows: file exists, marker named, runner present', () {
      for (final entry in _deviceE2eRows.entries) {
        final file = File(entry.value);
        expect(
          file.existsSync(),
          isTrue,
          reason: 'device-e2e file missing: ${entry.value}',
        );
        expect(
          _testNamePattern(entry.key).hasMatch(file.readAsStringSync()),
          isTrue,
          reason:
              'device-e2e marker "${entry.key}" is not embedded in a '
              'test name in ${entry.value}',
        );
      }
      for (final runner in _deviceE2eRunners) {
        expect(
          File(runner).existsSync(),
          isTrue,
          reason: 'device-e2e runner script missing: $runner',
        );
      }
    });
  });
}
