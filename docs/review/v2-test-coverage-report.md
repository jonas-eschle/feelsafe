# Guardian Angela v2 — Test Coverage Audit Report

**Date:** 2026-04-11
**Starting state:** 626 tests, 40 test files
**Final state:** 924 tests, 58 test files
**New tests added:** 298 across 18 new test files

---

## Summary

A comprehensive coverage audit was performed on all `lib/` source files. Every
file was read before writing tests. Below is the gap analysis and the changes
made.

---

## Gaps Found and Addressed

### 1. Controller Unit Tests (all controllers tested in isolation)

| Controller | Pre-audit | Tests Added | File |
|---|---|---|---|
| `ContactsController` | None | 14 | `test/features/contacts/contacts_controller_test.dart` |
| `ModesController` | None | 8 | `test/features/modes/modes_controller_test.dart` |
| `ProfileController` | None | 9 | `test/features/profile/profile_controller_test.dart` |
| `TemplatesController` | None | 7 | `test/features/templates/templates_controller_test.dart` |
| `SettingsController` | None | 24 | `test/features/settings/settings_controller_test.dart` |

**Key gaps covered:**
- `ContactsController.deleteContact()` throws `StateError` during active session
- `ContactsController.reorderContacts()` correct index math for both higher→lower
  and lower→higher directions, plus `sortOrder` re-assignment
- `ModesController.saveMode()` in-place update vs. append
- `ProfileController.updateName('')` / `updatePhone('')` clearing fields to null
- `SettingsController` all PIN hash clear patterns (`setAppPin(null)`, etc.)
- `AppSettings.copyWith(clearSelectedModeId: true)` semantics

### 2. Model Tests

| Model | Pre-audit | Tests Added | File |
|---|---|---|---|
| `SessionLog` + `SessionLogEvent` | None | 15 | `test/domain/models/session_log_test.dart` |
| `SessionMode` (full JSON + triggers) | None | 19 | `test/domain/models/session_mode_test.dart` |
| `UserProfile` (model behaviour) | None | 12 | Included in `profile_controller_test.dart` |
| `AppSettings` (model) | Partial | 4 | Included in `settings_controller_test.dart` |
| `BatteryAlertConfig` | None | 10 | `test/domain/models/battery_alert_config_test.dart` |
| `trigger.dart` hierarchy | None | 16 | `test/domain/models/trigger_test.dart` |
| `ChainStep` (all 9 configs) | Partial | 26 | `test/domain/models/chain_step_additional_test.dart` |
| `ReminderTemplate` | Partial | 4 | Included in `templates_controller_test.dart` |

**Key gaps covered:**
- `SessionLog.duration` returns null when in-progress
- `SessionMode` chain step sorting on construction
- `SessionMode.chainSteps` is unmodifiable (throws `UnsupportedError`)
- `SessionMode` distress chain / trigger round-trips
- All 9 `StepConfig` subclasses with non-default values
- `HardwareTrigger` sealed hierarchy (`RepeatPressTrigger`, `LongPressTrigger`)
- `DistressTrigger` and `DisarmTrigger` sealed hierarchies with `fromJson` error
  paths for unknown type names
- `UserProfile.hasMedicalInfo`, `medicalSummary` computed properties

### 3. Domain Logic Tests

| Domain | Pre-audit | Tests Added | File |
|---|---|---|---|
| `SessionLogRecorder` (GPS, descriptions, close) | Partial | 20 | `test/domain/engine/session_log_recorder_additional_test.dart` |
| `SessionContext.resolvePlaceholders` | None | 18 | `test/domain/models/session_context_additional_test.dart` |
| `SessionValidator` (distress chain, location perm) | Partial | 14 | `test/domain/validation/session_validator_additional_test.dart` |

**Key gaps covered:**
- `SessionLogRecorder`: GPS on/off, all 10 `ChainEvent` description strings,
  `close()` sets `endTime`
- `SessionContext`: `{userName}`, `{name}`, `{location}`, `{time}`, `{description}`,
  `{medical}` placeholders with fallback values; unknown placeholder left unchanged
- `SessionValidator`: distress chain contacts check, location permission not required
  for `holdButton`-only chains, empty emergency number warning vs. error distinction

### 4. Core Helpers Tests

| Helper | Pre-audit | Tests Added | File |
|---|---|---|---|
| `step_helpers.dart` | None | 37 | `test/core/constants/step_helpers_test.dart` |
| `session_lock.dart` | None | 6 | `test/core/widgets/session_lock_test.dart` |

**Key gaps covered:**
- `stepName()` / `stepIcon()` / `stepDescription()` for all 9 `ChainStepType` values
- `isActionStep()` / `isCheckInStep()` exhaustive coverage including the invariant
  that these two sets are disjoint
- `checkSessionLock()` returns `true` when no session, shows dialog and returns
  `false` when session active

### 5. Walk Session / Phase Derivation

| Area | Pre-audit | Tests Added | File |
|---|---|---|---|
| `WalkSession.phaseFromEngine` | None | 13 | `test/features/session/walk_session_test.dart` |
| `WalkSession.copyWith` | None | 10 | Same file |

**Key gaps covered:**
- Every `EngineState` variant maps to the correct `SessionPhase`
- `isAwaitingFirstTouch=true` and `isHolding=true` both map to correct phases
- All three `EndReason` values covered
- Both `PauseReason` values covered
- `copyWith` immutability: `startTime`, `modeId`, `modeName`, `isSimulation`
  preserved across copies

### 6. Simulation Service Tests

| Service | Pre-audit | Tests Added | File |
|---|---|---|---|
| `SimulationMessagingService` | None | 9 | `test/services/simulation/simulation_services_test.dart` |
| `SimulationPhoneService` | None | 6 | Same file |

**Key gaps covered:**
- `canAutoSend()` always returns `false` for all channel types
- Work ID uniqueness across multiple calls
- `sendToAll()` with zero contacts returns empty list
- Both `callEmergency()` and `call()` complete without throwing
- All `isSimulation=true` variants tested

---

## Remaining Uncovered Areas

These areas have no tests due to complexity requiring Flutter platform channels,
full Hive initialization, or real device APIs:

### Screens without widget tests
- `HomeScreen` — depends on many providers + router
- `SessionScreen` — complex state machine UI
- `OnboardingScreen` — requires router
- `ModeEditorScreen` / `ContactFormScreen` — complex forms
- `FakeCallScreen` — platform audio
- `EvidenceExportScreen` — platform sharing
- `PastEventDetailScreen` / `PastEventsScreen` (basic test exists)
- `ProfileEditorScreen`, `TemplatesScreen`, `TemplateEditorScreen`
- Settings subscreens: `BatteryAlertScreen`, `DistressChainScreen`,
  `EventDefaultsScreen`, `PinSetupScreen` (basic test exists), `BackupScreen`

### Integration tests
- Full walk-mode session flow (hold → release → grace → SMS)
- Full date-mode session flow (reminder → missed → escalate)
- Distress flow triggered by hardware button
- Simulation mode full execution

### Router tests
- `AppRouter` navigation guards (first-launch redirect)
- Deep-link parameter passing

### Rationale for skipping
Widget tests for the above screens require either a full `MaterialApp` with
GoRouter (which needs all providers), or complex mock orchestration that
duplicates engine logic. These are better covered by integration tests using
`package:integration_test` on a real device/emulator.

---

## Test Quality Notes

- All new tests follow the Arrange-Act-Assert pattern
- Fake notifiers extend real controllers and override `build()` + `_save()` to
  avoid Hive, matching the established pattern in `battery_alert_controller_test.dart`
- Fake repositories extend `JsonListRepository` and override all methods,
  matching the pattern in `history_controller_test.dart`
- No `unittest.TestCase`, only top-level `test()` functions and `group()` blocks
- Descriptive test names follow the existing convention
