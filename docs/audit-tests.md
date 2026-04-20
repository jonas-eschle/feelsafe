# Test Suite, Translations & Data Layer Audit

Generated: 2026-03-31

Reference: `docs/spec/07-test-plan.md` (78 numbered test cases)

---

## A. Test Coverage Gaps

### Coverage Matrix: Spec Test Plan vs Actual Tests

| Spec # | Description | Covered? | Test File |
|--------|-------------|----------|-----------|
| 1-8 | Hold Button | YES | `test/unit/engine/hold_button_test.dart` |
| 9-15 | Disguised Reminder | YES | `test/unit/engine/reminder_test.dart` |
| 16-20 | General Step Lifecycle | YES | `test/unit/engine/timing_test.dart`, `edge_cases_test.dart` |
| 21-24 | Disarm | YES | `test/unit/engine/disarm_test.dart` |
| 25-27 | Fake Call Decline | YES | `test/unit/engine/disarm_test.dart` (restartCurrentStep group) |
| 28-30 | Simulation | YES | `test/unit/engine/simulation_test.dart` |
| 31-37 | Edge Cases | PARTIAL | `test/unit/engine/edge_cases_test.dart`, `lifecycle_test.dart` |
| 38-42 | Walk Home Scenarios | YES | `test/integration/walk_scenarios_test.dart` |
| 43-46 | Date Mode Scenarios | PARTIAL | `test/integration/date_scenarios_test.dart` |
| 47-50 | Fake Call Scenarios | YES | `test/integration/fake_call_scenarios_test.dart` |
| 51-53 | Stealth Mode (scenarios) | **NO** | No test file exists |
| 54-56 | Model: ChainStep | YES | `test/unit/models/chain_step_test.dart` |
| 57 | Model: SessionMode ordering | **NO** | No test for chainSteps sort-by-order |
| 58 | Model: AppSettings stealth default | YES (TDD) | `test/unit/models/app_settings_test.dart` |
| 59 | Model: EventDefaults 9 types | YES | `test/unit/models/event_defaults_test.dart` |
| 60 | Seed data: Walk/Date different | YES | `test/unit/models/seed_data_test.dart` |
| 61 | Hive typeIds unique | YES | `test/unit/models/hive_type_ids_test.dart` |
| 62 | Migration v2->v3 preserves contacts | **NO** | No migration integration test |
| 63 | Session log on chainExhausted | **NO** | Only model-level tests exist |
| 64 | Session log on manual endSession | **NO** | Only model-level tests exist |
| 65 | Session log events have timestamps | **NO** | Only model-level tests exist |
| 66 | Session log records step+event type | **NO** | Only model-level tests exist |
| 67 | Location logged at events | **NO** | Model lacks lat/lng fields entirely |
| 68 | Location NOT logged when disabled | **NO** | Model lacks lat/lng fields entirely |
| 69 | Simulation sessions marked in log | **NO** | Only model-level tests exist |
| 70 | Delete log by ID | **NO** | No repository test |
| 71 | Delete logs older than duration | **NO** | No repository test |
| 72-75 | Stealth Mode (dedicated) | **NO** | No test file exists |
| 76-78 | Background Execution | **NO** | No test file exists |

### Missing Test Categories (by severity)

**CRITICAL -- entire spec sections with zero coverage:**

1. **Stealth Mode tests (spec #51-53, #72-75)**
   No tests exist for stealth mode behavior: silent chain exhaustion, hidden missed indicator, disguised notification text, neutral grace-phase screen. These are safety-critical -- if stealth mode leaks information visually, it could endanger the user.

2. **Background Execution tests (spec #76-78)**
   No tests for foreground service lifecycle, "I'm Safe" notification button, or background timer continuity. These require platform integration testing (Android services).

3. **Session Log integration tests (spec #63-71)**
   Only model construction tests exist (`test/unit/models/session_log_test.dart`). No tests verify that:
   - `SessionController` creates a `SessionLog` on `chainExhausted` or `endSession`
   - Events have correct timestamps
   - Step type and event type are recorded correctly
   - Simulation sessions are flagged `isSimulation = true`
   - Repository delete operations work (by ID, by age)

**HIGH -- spec items with no tests:**

4. **SessionMode chainSteps ordering (spec #57)**
   No test verifies that `SessionMode.chainSteps` is sorted by the `order` field.

5. **Migration preserves contacts (spec #62)**
   `lib/main.dart` migration logic deletes modes/templates/event_defaults boxes but should preserve contacts. No test confirms contacts survive migration.

**MODERATE -- spec items with structural blockers:**

6. **Location logging (spec #67-68)**
   `SessionLogEvent` (`lib/data/models/session_log_event.dart`) has no `latitude`/`longitude` fields. Tests #67 and #68 cannot be written until the model is extended. This is a **spec gap**: the model is missing fields the spec requires.

### Key Behaviors Checklist

The 10 behaviors that MUST have tests, with status:

| # | Behavior | Status |
|---|----------|--------|
| 1 | Hold-button release under sensitivity threshold is ignored | COVERED -- `hold_button_test.dart` parametrized sensitivity tests (0.3s, 0.5s, 1.0s, 2.0s, 3.0s thresholds) |
| 2 | Disguised reminder fires only after wait interval | COVERED -- `reminder_test.dart` "no premature reminderFired" test |
| 3 | repeatCount=N means N+1 total misses before advance | COVERED -- `repeat_cycle_test.dart` parametrized (repeat=0,1,2,3,5) |
| 4 | Disarm always resets to step 0 | COVERED -- `invariants_test.dart` parametrized from steps 0-3, `disarm_test.dart` |
| 5 | restartCurrentStep preserves miss count | COVERED -- `disarm_test.dart` restartCurrentStep group, `invariants_test.dart` |
| 6 | loudAlarm canDisarm=false rejects disarm() | COVERED -- `disarm_test.dart`, `invariants_test.dart`, `alarm_scenarios_test.dart` |
| 7 | Simulation speed multiplier applies to all phases | COVERED -- `simulation_test.dart` (wait, duration, grace, sensitivity at 5x) |
| 8 | leapToNextEvent is no-op in non-simulation mode | COVERED -- `simulation_test.dart` |
| 9 | endSession is idempotent | COVERED -- `lifecycle_test.dart`, `invariants_test.dart` (2,3,5,10 calls) |
| 10 | Stealth mode hides chain exhaustion UI | **NOT COVERED** -- no stealth tests exist |

**Widget tests (spec level 2):** Entirely absent. The `test/widget/` directory was deleted. All deleted widget tests appear in the git diff (`contacts_screen_test.dart`, `fake_call_screen_test.dart`, `home_screen_test.dart`, `disguised_reminder_overlay_test.dart`). No replacements exist.

---

## B. Tests That May Be Wrong

### 1. fakeCall repeat semantics: engine vs integration test contradiction

**repeat_cycle_test.dart** tests that the engine handles fakeCall repeat cycles natively:
```
fakeCall repeat=0: advance after first cycle completes
fakeCall repeat=1: 1 miss -> still active, 2 misses -> advance
fakeCall repeat=2: exactly 3 cycles needed
```

**fake_call_scenarios_test.dart** (line 8) explicitly states:
> "The `repeat` field on fakeCall is metadata for the UI/strategy layer only. The ENGINE does not track fakeCall misses."

**walk_scenarios_test.dart** (line 17) repeats the same claim:
> "fakeCall.repeat is metadata for the UI layer only. The engine does NOT handle fakeCall repeat cycles automatically."

These are contradictory. Either:
- (a) The engine DOES handle fakeCall repeats (in which case the integration test comments are wrong and should be updated), or
- (b) The engine does NOT handle them (in which case `repeat_cycle_test.dart` tests for fakeCall are asserting engine behavior that should not exist).

**Resolution needed:** Check the engine source. If `_startRepeatCycle()` runs for all step types (not just disguisedReminder), then (a) is correct and the integration test comments are stale. If it only runs for disguisedReminder, then the repeat_cycle_test.dart fakeCall tests are testing imaginary behavior and will fail.

### 2. walk_scenarios_test.dart uses different chain than _mocks.dart

`walk_scenarios_test.dart` defines a local `walkChain()` with **grace-only timing** (no duration on any step):
```dart
step(type: ChainStepType.holdButton, order: 0, grace: 5),
step(type: ChainStepType.fakeCall, order: 1, grace: 5),
```

While `_mocks.dart` `walkModeChain()` uses **duration + grace**:
```dart
step(type: ChainStepType.holdButton, order: 0, duration: 10, grace: 0),
step(type: ChainStepType.fakeCall, order: 1, duration: 30, grace: 5, repeat: 2),
```

This is documented in the test header and is intentional (simpler timing for scenario focus), but means walk_scenarios_test.dart does NOT test the actual seed data Walk Mode timing. The seed data timing is only tested in `seed_data_test.dart` at the model level (field values), not at the engine level (timers firing).

### 3. app_settings_test.dart stale TDD markers

Tests marked `[TDD]` for `stealthMode` and `notificationDisguise` use `as dynamic` casting:
```dart
expect((settings as dynamic).stealthMode, isFalse);
```
But these fields already exist on `AppSettings` with proper types. The `as dynamic` casts are unnecessary and the `[TDD]` labels are outdated. Not a correctness issue, but misleading -- suggests the fields are still unimplemented when they are not.

### 4. seed_data_test.dart template displayStyle assumptions

The test file constructs templates with explicit `displayStyle` values:
```dart
ReminderTemplate(id: 'tpl_calendar', ..., displayStyle: ReminderDisplayStyle.fullScreen)
```

But the actual seed data in `lib/data/seed_data.dart` for `tpl_calendar` does NOT set `displayStyle`, relying on the default. If the default is `fullScreen`, the test passes by coincidence. If the default changes, the test would still pass while the seed data behavior changes silently. This coupling is fragile.

Templates affected: `tpl_calendar`, `tpl_duolingo`, `tpl_fitness`, `tpl_message` -- all set `displayStyle: ReminderDisplayStyle.fullScreen` in the test but omit it in the actual seed data.

---

## C. Translation Gaps

### Key counts

| Language | Total Keys | Status |
|----------|-----------|--------|
| en | 336 | Reference |
| de | 335 | 3 missing, 2 stale |
| es | 335 | 3 missing, 2 stale |
| fr | 335 | 3 missing, 2 stale |
| ru | 335 | 3 missing, 2 stale |

### Missing keys (present in en, absent in de/es/fr/ru)

| Key | English Value |
|-----|---------------|
| `edCallStyleIos` | iOS-style call UI |
| `hwPressCount` | Press count |
| `hwRepeatPress` | Repeat press |

All 3 keys are missing from ALL 4 non-English ARB files.

### Stale keys (present in de/es/fr/ru, absent in en)

| Key | Notes |
|-----|-------|
| `hwDoublePress` | Renamed/removed from English |
| `hwTriplePress` | Renamed/removed from English |

These 2 keys exist in all 4 non-English ARB files but were removed from the English source. They should be removed from de/es/fr/ru to avoid bloat and confusion.

### Net action items

1. Translate `edCallStyleIos`, `hwPressCount`, `hwRepeatPress` into de, es, fr, ru (4 files x 3 keys = 12 additions)
2. Remove `hwDoublePress`, `hwTriplePress` from de, es, fr, ru (4 files x 2 keys = 8 deletions)
3. Run `flutter gen-l10n` to regenerate Dart localization classes

---

## D. Data Model Issues

### Hive TypeId Registry

| TypeId | Model | Status |
|--------|-------|--------|
| 0 | EmergencyContact | OK |
| 1 | EmergencyContactAdapter (legacy?) | OK |
| 4 | MessagingChannel | OK |
| 5 | ConfirmationType | OK |
| 8 | SessionMode | OK |
| 9 | AppSettings | OK |
| 10 | ChainStep | OK |
| 11 | ChainStepType | OK |
| 12 | ReminderTemplate | OK |
| 13 | EventDefaults | OK |
| 14 | ReminderDisplayStyle | OK |
| 15 | SessionLog | OK |
| 16 | SessionLogEvent | OK |

- **13 type IDs allocated, all unique.** Verified by `hive_type_ids_test.dart`.
- **Gaps at 2, 3, 6, 7** -- intentional (deleted models: EscalationStep, FakeCallConfig, etc.).
- **Range:** All values <= 223 (Hive max). Passes.

### Migration Logic

`lib/main.dart` `_migrateIfNeeded()`:
- Checks `schemaVersion < 3`
- Deletes boxes: `modes`, `templates`, `event_defaults`, `fake_call_config`
- Re-seeds via `seedDefaults()`
- Sets `schemaVersion = 3`, `stealthMode = false`
- **Contacts box is NOT deleted** -- contacts survive migration. Correct per spec #62.

**Issue:** No integration test verifies this. The migration path is only tested indirectly via `app_settings_test.dart` (schema version field default). A test that simulates a v2 -> v3 upgrade and confirms contacts persist would close spec #62.

### Seed Data vs Spec Timing

Walk Mode chain (from `seed_data.dart`):

| Step | Type | wait | duration | grace | repeat |
|------|------|------|----------|-------|--------|
| 0 | holdButton | 0 | 10 | 0 | 0 |
| 1 | fakeCall | 0 | 30 | 5 | 2 |
| 2 | smsContact | 0 | 15 | 5 | 0 |
| 3 | callEmergency | 0 | 5 | 0 | 0 |

Date Mode chain (from `seed_data.dart`):

| Step | Type | wait | duration | grace | repeat |
|------|------|------|----------|-------|--------|
| 0 | disguisedReminder | 1800 | 60 | 5 | 3 |
| 1 | fakeCall | 0 | 30 | 5 | 2 |
| 2 | smsContact | 0 | 15 | 5 | 0 |
| 3 | callEmergency | 0 | 5 | 0 | 0 |

**Verified correct.** `seed_data_test.dart` checks these values. The `_mocks.dart` helper chains (`walkModeChain()`, `dateModeChain()`) produce identical values and are used throughout the engine tests.

### SessionLogEvent Missing Location Fields

`SessionLogEvent` (typeId 16) has fields: `timestamp`, `eventType`, `stepType`, `stepIndex`, `description`.

**Missing:** `latitude`, `longitude` (or equivalent location fields).

Spec test cases #67 and #68 require GPS coordinate logging per event. This is a model gap that blocks both implementation and testing.

---

## E. Questions for the User

1. **fakeCall repeat semantics:** Does the engine handle fakeCall repeat cycles directly (like disguisedReminder), or is repeat handling delegated to the SessionController/UI layer? The test suite has contradictory assumptions (see Section B.1). This determines whether ~6 tests in `repeat_cycle_test.dart` are correct or testing phantom behavior.

2. **Location logging priority:** The `SessionLogEvent` model lacks latitude/longitude fields, blocking spec #67-68. Should this be added now (requires Hive migration to schema v4), or deferred?

3. **Widget tests:** All widget tests were deleted. Should new widget tests be written (spec level 2), or is the current engine+integration test coverage sufficient for now?

4. **Stealth mode tests:** These require widget/UI testing infrastructure (checking screen navigation, rendered elements, notification text). Should these be implemented as widget tests, or should the stealth logic be extracted into a testable controller first?

5. **Background execution tests (spec #76-78):** These require platform-specific testing (Android foreground service, notification actions). Are these expected as part of this test suite, or will they be handled separately as instrumentation/device tests?
