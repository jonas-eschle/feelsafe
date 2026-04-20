# Spec Compliance Review: Implementation vs docs/spec/12-rewrite-decisions.md

**Reviewer:** Architecture Review Agent (Claude Opus 4.6)
**Date:** 2026-04-10
**Scope:** Every design decision in the normative spec verified against `lib/`

---

## 1. Core Philosophy

### 1.1 "User is always in control" -- Disarm from any state

**Spec:** Disarm is ALWAYS possible from any state, any step, including during
duress/sub-chains. No hard-coded blocking of user actions.

**Implementation:** `SessionEngine.disarm()` (line 177) accepts calls from any
state except `EngineEnded` and `EngineIdle`. It clears sub-chain state
(`_subChainSteps`, `_activeSubChainType`, `_subChainQueue`,
`_mainChainSnapshot`), resets `_missCount`, emits `userDisarmed`, and advances
to step 0. The `SessionScreen` wraps disarm (via `ImSafeSlider`) with
`_pinGatedAction` which prompts for PIN if configured.

**Verdict:** IMPLEMENTED

### 1.2 PIN as safety speed bump

**Spec:** Critical actions (disarm, end session, Quick Exit) require PIN if
configured. 10-second configurable timeout. Correct PIN -> action proceeds.
Timeout -> action BLOCKED. Biometric MAY substitute for PIN on disarm/end but
NOT Quick Exit.

**Implementation:**
- `pin_entry_dialog.dart` implements PIN with countdown timer. Default timeout
  10s, configurable via `AppSettings.pinTimeoutSeconds`.
- `SessionScreen._pinGatedAction()` wraps both End Session and disarm (checkIn).
- `PinResult.timeout` -> action blocked (break, escalation continues).
- `PinResult.correct` -> action proceeds.
- `PinResult.duress` -> triggers duress sub-chain.
- `PinResult.wrongPinThreshold` -> triggers wrong-PIN chain.
- Biometric NOT implemented (field exists in AppSettings but no usage).
- Quick Exit (`QuickExit.execute()`) does NOT have PIN gating in the class
  itself -- the caller must implement it. No caller currently gates Quick Exit
  behind PIN.

**Verdict:** PARTIAL

**Gap:** Quick Exit is not PIN-gated anywhere in the codebase. The spec
mandates "Requires PIN if configured (10s timeout)" for Quick Exit. Also,
biometric substitution is declared in `AppSettings.biometricEnabled` but never
consumed.

### 1.3 Chains are chains -- no special architecture

**Spec:** Main, distress, duress, battery, wrongPin chains all use the same
chain mechanism.

**Implementation:** All sub-chains pass through `SessionEngine.startSubChain()`
with a `SubChainType` enum (`duress`, `battery`, `wrongPin`, `distress`). The
engine replaces `_effectiveSteps` with the sub-chain's step list and runs the
same `_advanceToStep` / timer / retry logic. Correct.

**Verdict:** IMPLEMENTED

---

## 2. Removed Features

### 2.1 Crash Recovery -- REMOVED

**Spec:** No crash recovery. No checkpoint, no SharedPreferences, no watchdog.

**Implementation:** No `CrashRecoveryService` exists. No SharedPreferences
checkpoint code. `SessionEngine` is entirely ephemeral.

**Note:** The AndroidManifest still declares `USE_EXACT_ALARM` /
`SCHEDULE_EXACT_ALARM` and `RECEIVE_BOOT_COMPLETED` with a `BootReceiver`,
which are crash-recovery artifacts. These should be removed to match the spec
unless they serve another purpose.

**Verdict:** IMPLEMENTED (with minor artifact in AndroidManifest)

### 2.2 Shake-to-SOS -- EXPLICITLY NOT A FEATURE

**Spec:** Will NEVER be implemented.

**Implementation:** No accelerometer code, no shake detection.

**Verdict:** IMPLEMENTED

### 2.3 Battery SMS Bypass -- REMOVED

**Spec:** No special critical-battery override. Default: OFF.

**Implementation:** `BatteryAlertConfig` defaults to `isEnabled: false`. No
"critical bypass" logic. The battery sub-chain follows normal configuration.

**Verdict:** IMPLEMENTED

---

## 3. Engine Behavior Amendments

### 3.1 Grace period IS the retry delay (wait skipped on retries)

**Spec:** After a miss: `duration -> grace -> miss -> duration -> grace -> ...`.
The `wait` phase only executes on the FIRST execution of a step. Applies to ALL
step types.

**Implementation:** In `_onGraceExpired()` (line 593): after incrementing
`_missCount`, if retries remain, calls `_startPhase(TimerPhase.duration)` --
skipping wait. In `restartCurrentStep()` (line 234): same pattern, increments
miss, if retries remain, starts at `TimerPhase.duration`. The `_advanceToStep()`
method (line 428) is only called for first execution and DOES include wait.
`TimerPhase.wait` doc comment (line 8) says "Skipped on retries."

**Verdict:** IMPLEMENTED

### 3.2 Hardware Button -- TRIPLE ROLE

**Spec:** (1) Check-in at step 0. (2) Chain step at specific position.
(3) Global panic override at ANY step (advance by 1; if at last step, trigger
distress chain). Minimum press count: 3.

**Implementation:**
- Role 1 (check-in at step 0): `HardwareButtonStrategy` is registered. At step
  0, the engine emits `stepStarted` and the UI/platform detects button events
  to call `checkIn()`.
- Role 2 (chain step): `ChainStepType.hardwareButton` exists with
  `HardwareButtonConfig`.
- Role 3 (global panic): `advanceFromHardwarePanic()` works from any step.
  Returns `true` at last step. `TriggerManager._handleDistress()` calls
  `advanceFromHardwarePanic()` and if at last step, starts distress sub-chain.
- Minimum press count: `RepeatPressTrigger` defaults to `pressCount: 3`.
  Seed data uses `pressCount: 3`.

**Verdict:** IMPLEMENTED

### 3.3 Fake Call Lifecycle

**Spec:**
```
ring -> answer -> chain PAUSES -> voice plays -> hangUp -> DISARM
ring -> decline -> declineIsSafe? disarm : miss
ring -> decline (3s hold) -> DISTRESS CHAIN triggered
ring -> timeout -> miss
```

**Implementation:**
- `answerFakeCall()` cancels timer, updates phase to duration -- chain pauses.
- `hangUp()` calls `disarm()` -- correct.
- `declineFakeCall()` checks `config.declineIsSafe`: true -> disarm, false ->
  `restartCurrentStep()` (miss + retry).
- `FakeCallScreen` wires: Answer -> `answerFakeCall()`, Decline ->
  `declineFakeCall()`, Hang Up (after answer) -> `hangUp()`.
- After voice recording: stays on screen (user manually hangs up). No
  auto-hang-up. Correct.

**Missing:** "Decline with Distress" (3-second hold on Decline to trigger
distress chain) is NOT implemented. `FakeCallScreen._decline()` fires
immediately. No long-press gesture detector, no progress ring, no haptic at
800ms.

**Verdict:** PARTIAL

**Gap:** "Decline with Distress" (3s hold) feature is missing from
`FakeCallScreen`.

### 3.4 declineIsSafe default true

**Spec:** Per-mode configurable flag on `FakeCallConfig`. Default: true.

**Implementation:** `FakeCallConfig` constructor: `this.declineIsSafe = true`.
Seed data Walk Mode: `declineIsSafe: true`. Seed data Date Mode:
`declineIsSafe: true`.

**Verdict:** IMPLEMENTED

### 3.5 Disarm -- UNIVERSAL

**Spec:** `disarm()` works from ANY phase of ANY step. Always resets to step 0
and clears miss count. If PIN configured, execution pauses, prompts, 10s
timeout.

**Implementation:** `disarm()` has no phase or step type checks (beyond
EngineEnded/EngineIdle guard). Resets `_missCount = 0`, emits `userDisarmed`,
calls `_advanceToStep(0)`. Works during sub-chains (clears sub-chain state
first). PIN gating is handled in `SessionScreen._pinGatedAction()`.

**Verdict:** IMPLEMENTED

### 3.6 holdStart/holdRelease -- EDGE-TRIGGERED

**Spec:** `holdStart()` is no-op if already holding. `holdRelease()` is no-op
if not holding. Prevents timer storms.

**Implementation:** `holdStart()` line 125: `if (_isHolding) return;`.
`holdRelease()` line 155: `if (!_isHolding) return;`.

**Verdict:** IMPLEMENTED

### 3.7 start() -- FAIL LOUD

**Spec:** Calling `start()` on already-running engine throws. Not a no-op.

**Implementation:** Line 102: `if (_state is! EngineIdle)
throw StateError('Engine already started');`.

**Verdict:** IMPLEMENTED

### 3.8 Speed Multiplier -- RESTRICTED

**Spec:** Only in simulation. Real sessions MUST be 1.0x. Reject NaN/Infinity/
negative. Clamp to [0.01, 1000.0].

**Implementation:** `setSpeedMultiplier()` (line 403):
- `if (!_isSimulation && value != 1.0) throw ArgumentError(...)` -- correct.
- `if (value.isNaN || value.isInfinite || value <= 0) throw ArgumentError(...)`.
- `_speedMultiplier = value.clamp(0.01, 1000.0)` -- correct.
- `_isSimulation` is `final` (immutable) -- correct (layer 1 defense-in-depth).

**Verdict:** IMPLEMENTED

### 3.9 Pause Behavior

**Spec:** Pause stops all active audio/vibration/flash. Restart from remaining
duration on resume. Configurable max pause duration per mode (default
unlimited). After 30 min pause: show notification.

**Implementation:**
- `pause()` captures `_actualRemaining()`, cancels timer, emits `sessionPaused`.
- `resume()` restores from snapshot with exact remaining time. Correct.
- `SessionMode.maxPauseDuration` field exists (nullable, default null =
  unlimited). Correct.
- Stopping audio/vibration/flash on pause: NOT implemented in the engine
  (engine is pure Dart). The orchestrator's `handleEvent` for `sessionPaused`
  is a no-op (`break`). There is no call to stop audio/vibration services.
- 30-minute notification: NOT implemented.

**Verdict:** PARTIAL

**Gap:** Pause does not stop active audio/vibration/flash services.
`maxPauseDuration` enforcement is missing. 30-minute pause notification is
missing.

### 3.10 Resume After Real Phone Call

**Spec:** Resume with exact remaining time. No grace reset, no buffer.

**Implementation:** Incoming call auto-pause is wired in
`SessionController._startServices()` (line 214): `callState == ringing/active`
-> `engine.pause(reason: PauseReason.incomingCall)`. `callState == ended` ->
`engine.resume()`. Resume uses exact remaining from snapshot. Correct.

**Verdict:** IMPLEMENTED

### 3.11 Sub-Chains -- Internal to Engine

**Spec:** DELIBERATE REVERSAL of spec 01. Sub-chains are internal to the main
engine (NOT separate SessionEngine instances). Main engine tracks sub-chain
state in EngineSubChainActive.

**Implementation:** `SessionEngine` has `_subChainSteps`, `_activeSubChainType`,
`_mainChainSnapshot`, `_subChainQueue`. `startSubChain()` swaps
`_effectiveSteps`. `_completeSubChain()` restores main chain. No separate engine
instances. Correct.

- Sub-chain priority queue: panic (duress/distress) overrides immediately,
  others FIFO. Implemented at line 331: duress/distress completes current
  sub-chain then starts new. Others add to `_subChainQueue`.
- `endSession()` during sub-chain: clears all sub-chain state, transitions to
  `EngineEnded`. Correct per spec.
- Allowed step types in sub-chains: NOT enforced. The engine accepts any
  step type in a sub-chain.

**Verdict:** PARTIAL

**Gap:** No validation that sub-chain steps are limited to the 5 allowed types
(smsContact, phoneCallContact, loudAlarm, callEmergency, countdownWarning).

### 3.12 Engine Events -- EXPANDED (12 total)

**Spec:** 7 original + 5 new = 12.

**Implementation:** `ChainEvent` enum has exactly 12 values: stepStarted,
reminderFired, repeatMissed, stepAdvancing, userDisarmed, chainExhausted,
sessionEnded, sessionPaused, sessionResumed, subChainStarted,
subChainCompleted, stepExecutionFailed.

**Verdict:** IMPLEMENTED

### 3.13 Sealed EngineState

**Spec:** Replace boolean soup with sealed class hierarchy: EngineIdle,
EngineRunning, EnginePaused, EngineSubChainActive, EngineEnded.

**Implementation:** `engine_state.dart` defines `sealed class EngineState` with
exactly these 5 subclasses. `EndReason` enum: userTerminated, chainExhausted,
duressCompleted. `PauseReason` enum: manual, incomingCall. `SubChainType` enum:
duress, battery, wrongPin, distress.

**Verdict:** IMPLEMENTED

### 3.14 Duress Ends Session -- EngineEnded(duressCompleted)

**Spec:** Duress sub-chain completion ends session with
`EngineEnded(duressCompleted)`.

**Implementation:** `_completeSubChain()` line 487:
`if (type == SubChainType.duress)` -> transitions to
`EngineEnded(reason: EndReason.duressCompleted)`, emits `sessionEnded`, closes
stream. Correct.

**Verdict:** IMPLEMENTED

---

## 4. Trigger System

### 4.1 Triggers Parallel to Chain

**Spec:** Triggers are NOT chain steps. Configured per SessionMode as two
lists: distressTriggers and disarmTriggers.

**Implementation:** `SessionMode` has `distressTriggers` (List<DistressTrigger>)
and `disarmTriggers` (List<DisarmTrigger>). `TriggerManager` operates in
parallel, subscribing to services and calling engine methods.

**Verdict:** IMPLEMENTED

### 4.2 Distress Chain Model

**Spec:** `SessionMode.distressChainSteps` field. If null/empty, hardware panic
at last step is no-op.

**Implementation:** `SessionMode.distressChainSteps` is `List<ChainStep>?`.
`TriggerManager._handleDistress()` checks `mode.distressChainSteps != null`
before starting distress sub-chain.

**Verdict:** IMPLEMENTED

### 4.3 Distress Triggers (Phase 1)

**Spec:** `HardwareButtonDistressTrigger` with volume button patterns (min 3
presses). Configurable: button, pattern, count, window, target step.

**Implementation:** `HardwareButtonDistressTrigger` is a sealed subclass of
`DistressTrigger`. Fields: `buttonType`, `trigger` (HardwareTrigger sealed:
RepeatPressTrigger or LongPressTrigger), `targetStepIndex`. Default
`pressCount: 3`. `TriggerManager` wires it to `HardwareButtonServiceProtocol`.

**Verdict:** IMPLEMENTED

### 4.4 Disarm Triggers (Phase 1)

**Spec:** `GpsArrivalDisarmTrigger` (geofence, always confirm),
`TimerDisarmTrigger`.

**Implementation:** Both exist as sealed subclasses of `DisarmTrigger`.
`GpsArrivalDisarmTrigger` has radius, dwellTime, destinationSource.
`TimerDisarmTrigger` has durationSeconds, showReminderBeforeEnd.
`TriggerManager` wires GPS arrivals to `onDisarmRequested` callback.
However, `TimerDisarmTrigger` is NOT wired in `TriggerManager` -- it only
handles `GpsArrivalDisarmTrigger`.

**Verdict:** PARTIAL

**Gap:** `TimerDisarmTrigger` model exists but is not wired in TriggerManager.

### 4.5 Trigger Behavior Rules

**Spec:** (1) Disarm triggers always ask for confirmation. (2) PIN required if
configured. (3) During duress: confirmation requires PIN. (4) 500ms cooldown.

**Implementation:**
- `TriggerManager.onDisarmRequested` callback fires, but just calls
  `checkIn()` directly -- NO confirmation notification.
- 500ms cooldown: implemented in `_handleDistress()` (line 79-84).
- Distress during sub-chain: not explicitly handled -- `advanceFromHardwarePanic`
  doesn't check sub-chain state.

**Verdict:** PARTIAL

**Gap:** Disarm trigger confirmation notification is not implemented. The
`onDisarmRequested` callback is wired to `checkIn` directly in the session
controller (line 255), bypassing confirmation.

### 4.6 Session Start Flow

**Spec:** Before engine.start(): show trigger summary, prompt for destination
if GPS configured, skip = disable for session.

**Implementation:** `HomeScreen._startSession()` validates then immediately
starts the session. No trigger configuration summary screen, no destination
prompt.

**Verdict:** MISSING

---

## 5. Simulation System

### 5.1 Background Simulation

**Spec:** Same foreground service + notification. Title:
"SIMULATION -- [mode]". Disguised reminders with `[SIM]` suffix.

**Implementation:** The session controller starts notification with
`isSimulation` flag. The notification service receives it. Session screen shows
orange "SIMULATION -- No real actions" banner.

**Verdict:** PARTIAL

**Gap:** The notification title format "SIMULATION -- [mode]" and `[SIM]`
suffix on disguised reminders are not verified in the current implementation.
The notification service protocol passes `isSimulation` but the implementation
stub (`NotificationService`) would need to format correctly.

### 5.2 What Fires vs What's Blocked

**Spec:** SMS/WhatsApp/Telegram, phone calls, emergency calls, audio recording
-> BLOCKED (sim_blocked). Fake call screen, countdown vibration, location ->
fire normally.

**Implementation:**
- `SmsContactStrategy.executeReal()` passes `isSimulation` to
  `messaging.sendToAll()`. `FakeMessagingService` checks `isSimulation` and
  skips `sentMessages` when true. `SimulationMessagingService` logs
  `SIM_BLOCKED`.
- `FakePhoneService` logs `SIM_BLOCKED` when `isSimulation=true`.
  `SimulationPhoneService` always logs `SIM_BLOCKED`.
- However, the orchestrator's `_executeStep()` checks `isSimulation` first and
  calls `simulationDescription()` instead of `executeReal()`. This means in
  simulation mode, `executeReal()` is never reached at all -- strategies are
  bypassed entirely.

**Defense-in-depth layers:**
1. Engine flag `_isSimulation` is `final` (immutable). IMPLEMENTED.
2. Strategy guard (every executeReal checks isSimulation): NOT implemented --
   strategies do NOT check `isSimulation` themselves. The orchestrator does.
3. Service parameter: services accept `isSimulation`. IMPLEMENTED.
4. Separate subclasses: `SimulationMessagingService` and
   `SimulationPhoneService` exist. IMPLEMENTED.

**Verdict:** PARTIAL

**Gap:** Layer 2 ("every executeReal checks isSimulation first") is not
implemented. The orchestrator handles this at a higher level, but individual
strategies do not have their own guard. This reduces defense-in-depth from 4
layers to 3.

### 5.3 SIM Indicators

**Spec:** In-app: orange border + "SIMULATION" banner, cannot be hidden.
Background: `[SIM]` prefix. Stealth simulation: SIM watermark. No SYSTEM_ALERT_WINDOW.

**Implementation:** `SessionScreen` shows orange `Container` with "SIMULATION"
text when `session.isSimulation`. `FakeCallScreen` shows orange "SIMULATION"
chip. No system overlay (correct).

**Gap:** Orange *border* around the entire screen is not implemented -- only a
top banner. Stealth simulation watermark is not implemented.

**Verdict:** PARTIAL

### 5.4 Speed Control

**Spec:** In-app: 1x-1000x, logarithmic slider. Background: 1x-60x. Default
1x. Speed from notification action: cycle 1x->10x->60x->1x.

**Implementation:** `setSpeedMultiplier()` clamps to [0.01, 1000.0].
`SessionController.setSimulationSpeed()` calls through.
No distinction between in-app (1000x) and background (60x) maximum.
No logarithmic slider widget (the slider component is `LogarithmicSlider`
mentioned in CLAUDE.md but not found in `lib/`).
No notification speed cycling action.

**Verdict:** PARTIAL

**Gap:** No background vs in-app speed cap distinction. No logarithmic slider.
No notification speed cycling.

### 5.5 Simulation Validation -- Lenient

**Spec:** Warn but allow starting with missing contacts/permissions.

**Implementation:** `SessionValidator.validate()` uses `permSeverity =
isSimulation ? IssueSeverity.warning : IssueSeverity.error`. Contacts check:
`!isSimulation` guard on the error. Correct -- simulation can start with
missing contacts (warning only).

**Verdict:** IMPLEMENTED

### 5.6 No Auto-End Timeout

**Spec:** User is responsible for ending simulation.

**Implementation:** No timeout logic in simulation mode.

**Verdict:** IMPLEMENTED

### 5.7 No "GO LIVE" Button

**Spec:** Too dangerous.

**Implementation:** No transition from simulation to real mode exists.

**Verdict:** IMPLEMENTED

### 5.8 Simulation Trigger Buttons

**Spec:** Behind "Advanced" toggle: "Trigger Arrival", "Trigger Low Battery",
"Trigger Hardware Panic".

**Implementation:** Not found in `SessionScreen`. No simulation control strip.

**Verdict:** MISSING

---

## 6. Data Model Amendments

### 6.1 Sealed StepConfig -- REPLACES Map<String, String>

**Spec:** 9 concrete subclasses (one per step type). Serialized as versioned
JSON envelope.

**Implementation:** `step_config.dart` defines `sealed class StepConfig` with 9
concrete subclasses: HoldButtonConfig, FakeCallConfig, SmsContactConfig,
PhoneCallContactConfig, LoudAlarmConfig, CallEmergencyConfig,
CountdownWarningConfig, DisguisedReminderConfig, HardwareButtonConfig.
Serialized as `{"type": "...", "data": {...}}`.

**Note:** No `"version"` field in the envelope. Spec says
`{"version": 1, "type": "...", "data": {...}}`.

**Verdict:** PARTIAL

**Gap:** Missing `version` field in JSON envelope.

### 6.2 New/Modified Model Fields

| Field | Spec | Impl | Status |
|-------|------|------|--------|
| EmergencyContact.relationship | String? | String? | IMPLEMENTED |
| EmergencyContact.languageCode | String? | String? | IMPLEMENTED |
| UserProfile.bloodType | String? | String? | IMPLEMENTED |
| UserProfile.allergies | String? | String? | IMPLEMENTED |
| UserProfile.medications | String? | String? | IMPLEMENTED |
| UserProfile.medicalConditions | String? | String? | IMPLEMENTED |
| UserProfile.emergencyMedicalNotes | String? | String? | IMPLEMENTED |
| AppSettings.stealthTimerDisplay | enum | enum StealthTimerDisplay | IMPLEMENTED |
| AppSettings.stealthNotificationIcon | String | String? | IMPLEMENTED |
| AppSettings.alarmOverrideSilentMode | bool, true | bool, true | IMPLEMENTED |
| SessionLogEvent.deliveryStatus | enum | enum ActionDeliveryStatus | IMPLEMENTED |
| SessionMode.distressTriggers | List | List<DistressTrigger> | IMPLEMENTED |
| SessionMode.disarmTriggers | List | List<DisarmTrigger> | IMPLEMENTED |
| SessionMode.maxPauseDuration | Duration? | Duration? | IMPLEMENTED |

**Verdict:** IMPLEMENTED

### 6.3 Battery Alert Config

**Spec:** Default OFF. Fire once per session only. No critical battery bypass.

**Implementation:** `BatteryAlertConfig.isEnabled` defaults to `false`.
"Fire once" behavior: the `onLowBattery` stream subscription in
`SessionController._startServices()` fires whenever the service reports low
battery. There is no explicit "once per session" guard.

**Verdict:** PARTIAL

**Gap:** No "fire once per session" guard for battery alert.

---

## 7. Settings Amendments

### 7.1 Stealth Mode

**Spec:** Does NOT require PIN. Independent features. Fake music player: remove
stealth toggle entirely. Slider text: configurable, default "I'm fine" (never
"Angela"). Notification channels: generic names.

**Implementation:**
- Stealth does not require PIN: `SettingsScreen` has `toggleStealthMode()`
  with no PIN gate. Correct.
- `FakeMusicPlayer` exists with `disarmLabel` defaulting to `"I'm fine"`.
  Correct.
- `ImSafeSlider` has `label` defaulting to `"I'm Safe"`. The spec says the
  slider text should default to "I'm fine" -- there is a mismatch.
- `StealthConfig` resolves all stealth flags from `AppSettings`. Correct.

**Verdict:** PARTIAL

**Gap:** `ImSafeSlider` default label is "I'm Safe" instead of spec's "I'm
fine". Minor but explicit spec violation.

### 7.2 Alarm DND Override

**Spec:** Configurable toggle, default ON. Uses STREAM_ALARM.

**Implementation:** `AppSettings.alarmOverrideSilentMode` defaults to `true`.
Settings screen has toggle. STREAM_ALARM usage depends on the real audio
service implementation (stub only).

**Verdict:** IMPLEMENTED

### 7.3 Session Locks

**Spec:** During active session: contact deletion BLOCKED, backup import
BLOCKED, language change BLOCKED, schema migration BLOCKED.

**Implementation:** No session-lock guards found in any controller. The
contacts controller, backup screen, and settings controller have no checks for
active session state.

**Verdict:** MISSING

### 7.4 Quick Exit

**Spec:** Requires PIN if configured. Then: cancel everything. Android:
`finishAndRemoveTask()`. iOS: decoy screenshot + `exit(0)`.

**Implementation:** `QuickExit.execute()` implements Android
(`finishAndRemoveTask` via platform channel) and iOS (decoy + `exit(0)`).
However, PIN gate is NOT implemented -- `QuickExit.execute()` runs immediately.
No caller wraps it with PIN verification.

**Verdict:** PARTIAL

**Gap:** Quick Exit not PIN-gated.

### 7.5 Emergency Call Confirmation

**Spec:** Disarm during countdown: show "Are you sure? Call will NOT be made"
dialog.

**Implementation:** `CallEmergencyConfig.showConfirmation` and
`confirmationDurationSeconds` fields exist. The seed data Date Mode has
`showConfirmation: true`. However, the `CallEmergencyStrategy.executeReal()`
does NOT implement the confirmation dialog -- it calls `phone.callEmergency()`
directly.

**Verdict:** PARTIAL

**Gap:** `showConfirmation` field is present but not consumed by the strategy.

---

## 8. Seed Data

### 8.1 Walk Mode

| # | Spec | Impl | Match |
|---|------|------|-------|
| 0 | holdButton, dur=10s, grace=5s, sens=1.0 | holdButton, dur=10, grace=5, sens=1.0 | MATCH |
| 1 | fakeCall, retry=2, declineIsSafe=true, ring=30s | fakeCall, dur=30, grace=5, retry=2, declineIsSafe=true | MATCH |
| 2 | smsContact, all contacts, includeLocation | smsContact, dur=15, grace=5, includeLocation=true | MATCH |
| 3 | phoneCallContact, primary, preSMS=true | phoneCallContact, dur=60, preSendSms=true | MATCH |
| 4 | callEmergency, locale-aware, sendLocationSmsFirst | callEmergency, dur=5, sendLocationSmsFirst=true | MATCH |
| - | distress trigger: hw button 3x vol up | HardwareButtonDistressTrigger(pressCount: 3) | MATCH |

**Verdict:** IMPLEMENTED

### 8.2 Date Mode

| # | Spec | Impl | Match |
|---|------|------|-------|
| 0 | disguisedReminder, wait=1800s, retry=3, grace=120s | wait=1800, dur=60, grace=120, retry=3 | MATCH |
| 1 | fakeCall, retry=1, declineIsSafe=true | dur=30, grace=5, retry=1, declineIsSafe=true | MATCH |
| 2 | smsContact, all, includeLocation | dur=15, grace=5, includeLocation=true | MATCH |
| 3 | phoneCallContact, primary, preSMS=true | dur=60, preSendSms=true | MATCH |
| 4 | callEmergency, locale-aware, showConfirmation=true, 10s | dur=10, showConfirmation=true, confirmDur=10 | MATCH |
| - | distress trigger: hw button 3x vol up | HardwareButtonDistressTrigger(pressCount: 3) | MATCH |

**Verdict:** IMPLEMENTED

---

## 9. Onboarding

**Spec:** 3 pages (all skippable): (1) Welcome (2) Profile + First Contact
(combined) (3) Permissions (POST_NOTIFICATIONS first).

**Implementation:** `OnboardingScreen` has 3 pages via `PageView`: Welcome,
Profile+Contact, Permissions. All skippable (Skip button calls `_finish()`).
Permissions page lists POST_NOTIFICATIONS first.

**Note:** Spec says 3 pages. CLAUDE.md says "4 screens" and "Welcome ->
Identity -> First Contact -> Permissions". The normative spec (12-rewrite)
overrides and says 3, which matches the implementation.

**Verdict:** IMPLEMENTED

---

## 10. Language Expansion

**Spec:** 14 languages: en, de, es, fr, ru, zh_CN, zh_TW, hi, fa, uk, pl, el,
ar, he.

**Implementation:**
- ARB files exist for: en, de, es, fr, ru, zh, zh_TW, hi, fa, uk, pl, el, ar,
  he. That is 14 (zh covers zh_CN).
- `app.dart` `supportedLocales` lists all 14.
- Generated localization files exist for all.

**Note:** Spec says `zh_CN` but implementation uses `zh` (which defaults to
simplified). This is a reasonable mapping.

**Verdict:** IMPLEMENTED

---

## 11. Simulation Decisions (Summary)

| Decision | Status |
|----------|--------|
| Background simulation with foreground service | PARTIAL (service setup exists, notification format not verified) |
| Fires vs blocked matrix | IMPLEMENTED (orchestrator skips executeReal in sim) |
| 4-layer defense-in-depth | PARTIAL (layer 2 -- per-strategy guard -- missing) |
| SIM indicators (orange border, banner) | PARTIAL (banner exists, border and stealth watermark missing) |
| Speed control (log slider, bg cap) | PARTIAL (clamp exists, no log slider, no bg cap) |
| Simulation trigger buttons | MISSING |
| Lenient validation | IMPLEMENTED |
| No auto-end timeout | IMPLEMENTED |
| No "GO LIVE" button | IMPLEMENTED |

---

## 12. Stealth Decisions (Summary)

| Decision | Status |
|----------|--------|
| Stealth does not require PIN | IMPLEMENTED |
| Fake music player with disarm slider | IMPLEMENTED |
| Slider text configurable, default "I'm fine" | PARTIAL ("I'm Safe" default on ImSafeSlider) |
| StealthConfig resolves from AppSettings | IMPLEMENTED |
| StealthTimerDisplay (normal/small/none) | IMPLEMENTED |
| Stealth notification body/icon configurable | IMPLEMENTED |
| Hide progress bar, missed indicators, grace | IMPLEMENTED (fields in config, UI consumption varies) |

---

## 13. PIN/Security Decisions (Summary)

| Decision | Status |
|----------|--------|
| PIN on disarm during escalation | IMPLEMENTED (via _pinGatedAction) |
| PIN on end session | IMPLEMENTED (via _pinGatedAction) |
| PIN on Quick Exit | MISSING |
| 10s configurable timeout | IMPLEMENTED (pinTimeoutSeconds) |
| Timeout = action BLOCKED | IMPLEMENTED (PinResult.timeout -> break) |
| Correct PIN = action PROCEEDS | IMPLEMENTED (PinResult.correct -> action()) |
| Duress PIN detection | IMPLEMENTED (PinResult.duress -> triggerDuress) |
| Wrong PIN threshold chain | IMPLEMENTED (PinResult.wrongPinThreshold -> triggerWrongPinChain) |
| Biometric substitution (not Quick Exit) | MISSING (field exists, not consumed) |
| Constant-time PIN comparison | IMPLEMENTED (PinUtils._constantTimeEquals) |

---

## Summary Tally

| Status | Count | Items |
|--------|-------|-------|
| IMPLEMENTED | 29 | Core philosophy #1/#3, Crash recovery, Shake-to-SOS, Battery bypass, Retry timing, Hardware triple role, declineIsSafe default, Universal disarm, Edge-triggered hold, start() fail loud, Speed multiplier, Resume after call, Sub-chains internal, 12 events, Sealed EngineState, Duress ends session, Triggers parallel, Distress chain model, Distress triggers, All model fields, Alarm DND, Seed Walk/Date, Onboarding 3 pages, 14 languages, Sim validation lenient, No auto-end, No GO LIVE, Stealth no PIN, PIN timeout/correct/timeout/duress/wrongPin/constant-time |
| PARTIAL | 15 | PIN as speed bump (#1.2), Fake call lifecycle (#3.3), Pause behavior (#3.9), Sub-chain allowed types (#3.11), Disarm triggers wiring (#4.4), Trigger behavior rules (#4.5), Sealed StepConfig version (#6.1), Battery once-per-session (#6.3), Stealth slider text (#7.1), Quick Exit PIN (#7.4), Emergency confirmation (#7.5), Simulation defense-in-depth (#5.2), SIM indicators (#5.3), Speed control (#5.4), Background simulation (#5.1) |
| MISSING | 4 | Session start flow (#4.6), Session locks (#7.3), Simulation trigger buttons (#5.8), Biometric (#1.2 sub-item) |

---

## Critical Gaps (Prioritized)

### P0 -- Safety-Critical

1. **Quick Exit not PIN-gated** -- An attacker could trigger Quick Exit without
   PIN, wiping evidence. File: `lib/core/utils/quick_exit.dart` and callers.

2. **Session locks missing** -- Contacts can be deleted during active session,
   breaking SMS steps mid-escalation. Affects: contacts_controller,
   settings_controller, backup_screen.

3. **Disarm trigger fires without confirmation** -- GPS arrival directly calls
   `checkIn()` (line 255 of session_controller.dart) instead of showing a
   confirmation notification. An attacker could spoof location to auto-disarm.

### P1 -- Functional

4. **"Decline with Distress" (3s hold) missing** -- Fake call decline does not
   support long-press distress trigger. File: `lib/features/fake_call/
   fake_call_screen.dart`.

5. **Pause does not stop audio/vibration** -- When engine pauses, the
   orchestrator does not stop active services. A loud alarm would continue
   playing through a pause.

6. **Emergency call confirmation dialog not implemented** -- The
   `showConfirmation` flag is stored but never consumed. File:
   `lib/domain/orchestration/strategies/call_emergency_strategy.dart`.

7. **Battery alert has no once-per-session guard** -- Could fire repeatedly.

8. **Sub-chain step type validation missing** -- Engine accepts any step type
   in sub-chains, but spec restricts to 5 types.

### P2 -- Polish

9. **TimerDisarmTrigger not wired** -- Model exists but TriggerManager ignores it.

10. **Simulation trigger buttons missing** -- No way to test arrival/battery/
    panic triggers during simulation.

11. **Defense-in-depth layer 2 missing** -- Strategies don't individually guard
    `isSimulation`.

12. **StepConfig JSON envelope missing `version` field**.

13. **ImSafeSlider default label "I'm Safe" vs spec "I'm fine"**.

14. **Speed control UI (logarithmic slider, notification cycling) missing**.

15. **SIM indicators incomplete** -- No orange border around screen, no stealth
    watermark.

16. **Session start trigger summary screen missing**.

17. **Biometric authentication not implemented** -- Field exists but never used.

18. **AndroidManifest has crash-recovery artifacts** (`EXACT_ALARM`,
    `BootReceiver`) that should be removed.

---

## File References

- Engine: `/home/jonas/Documents/software/android/safetyapp1/safewayhome/lib/domain/engine/session_engine.dart`
- Engine state: `/home/jonas/Documents/software/android/safetyapp1/safewayhome/lib/domain/engine/engine_state.dart`
- Timer phase: `/home/jonas/Documents/software/android/safetyapp1/safewayhome/lib/domain/engine/timer_phase.dart`
- Trigger manager: `/home/jonas/Documents/software/android/safetyapp1/safewayhome/lib/domain/engine/trigger_manager.dart`
- Step config: `/home/jonas/Documents/software/android/safetyapp1/safewayhome/lib/domain/models/step_config.dart`
- Session mode: `/home/jonas/Documents/software/android/safetyapp1/safewayhome/lib/domain/models/session_mode.dart`
- Triggers: `/home/jonas/Documents/software/android/safetyapp1/safewayhome/lib/domain/models/trigger.dart`
- App settings: `/home/jonas/Documents/software/android/safetyapp1/safewayhome/lib/domain/models/app_settings.dart`
- Session controller: `/home/jonas/Documents/software/android/safetyapp1/safewayhome/lib/features/session/session_controller.dart`
- Session screen: `/home/jonas/Documents/software/android/safetyapp1/safewayhome/lib/features/session/session_screen.dart`
- Fake call screen: `/home/jonas/Documents/software/android/safetyapp1/safewayhome/lib/features/fake_call/fake_call_screen.dart`
- PIN dialog: `/home/jonas/Documents/software/android/safetyapp1/safewayhome/lib/core/widgets/pin_entry_dialog.dart`
- Quick exit: `/home/jonas/Documents/software/android/safetyapp1/safewayhome/lib/core/utils/quick_exit.dart`
- Seed data: `/home/jonas/Documents/software/android/safetyapp1/safewayhome/lib/data/seed_data.dart`
- Orchestrator: `/home/jonas/Documents/software/android/safetyapp1/safewayhome/lib/domain/orchestration/session_orchestrator.dart`
- Home screen: `/home/jonas/Documents/software/android/safetyapp1/safewayhome/lib/features/home/home_screen.dart`
- AndroidManifest: `/home/jonas/Documents/software/android/safetyapp1/safewayhome/android/app/src/main/AndroidManifest.xml`
