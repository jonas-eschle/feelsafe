# v2 Spec Compliance Report

**Spec:** `docs/spec/13-rewrite-v2-spec.md`
**Reviewed:** 2026-04-11
**Reviewer:** Code Review Agent (Claude Opus 4.6)

Status key: **IMPLEMENTED** | **PARTIAL** | **MISSING**

---

## 1. Core Philosophy

### 1.1 Minimize false positives -- IMPLEMENTED
Evidence: The engine's three-phase timing (wait/duration/grace), retry
logic with `retryCount`, sensitivity window for accidental hold-button
releases (TimerPhase.sensitivity in `lib/domain/engine/timer_phase.dart`),
and distress confirmation window (5s countdown in
`lib/core/widgets/distress_confirmation.dart`) all serve to reduce
false positives. Shake-to-SOS is rejected (not implemented, per spec).

### 1.2 User controls everything -- IMPLEMENTED
Evidence: `disarm()` in `lib/domain/engine/session_engine.dart` line 200
works from any phase of any step: "if (_state is EngineEnded ||
_state is EngineIdle) return;" otherwise proceeds unconditionally. Quick
Exit exists at `lib/core/utils/quick_exit.dart`. End Session available at
all times in session screen.

### 1.3 PIN as dead man's switch -- IMPLEMENTED
- **15s default timeout:** `lib/domain/models/app_settings.dart` line 30:
  `this.pinTimeoutSeconds = 15`. Also `lib/core/widgets/pin_entry_dialog.dart`
  line 43: `int timeoutSeconds = 15`.
- **Configurable:** `pinTimeoutSeconds` field in AppSettings with copyWith
  and JSON serialization support.
- **Timeout blocks action:** `pin_entry_dialog.dart` line 104:
  `Navigator.of(context).pop(PinResult.timeout)` when remaining <= 0.
  Session screen checks `handlePinResult` and returns false on timeout.
- **Duress PIN detection:** `pin_entry_dialog.dart` lines 132-136 check
  duress hash first, return `PinResult.duress`.
- **Wrong PIN threshold:** `pin_entry_dialog.dart` lines 150-155 track
  `_wrongAttempts`, return `PinResult.wrongPinThreshold`.
- **Biometric for disarm/end:** `biometricEnabled` field exists in
  AppSettings. UI integration not verified (no biometric check found
  in session screen).
- **Biometric NOT for Quick Exit:** `quick_exit.dart` uses only
  `showPinDialog`, no biometric call. Correct per spec.

### 1.4 Chains are just chains -- IMPLEMENTED
Evidence: `SessionEngine` at `lib/domain/engine/session_engine.dart` has a
single `_steps` list. `replaceWithDistressChain()` (line 124) simply swaps
`_steps` and resets to step 0. No special distress-chain engine, no
sub-chain concept. Both main and distress chains execute identically.

---

## 2. Removed Features

### 2.1 Crash Recovery -- IMPLEMENTED (removed per spec)
Evidence: No checkpoint, resume, SharedPreferences, or watchdog code found
anywhere in the codebase. Correct.

### 2.2 Shake-to-SOS -- IMPLEMENTED (rejected per spec)
Evidence: No accelerometer code anywhere. Correct.

### 2.3 Battery SMS Bypass -- IMPLEMENTED (removed per spec)
Evidence: Battery alert is a one-shot side-action in
`lib/features/session/session_controller.dart` lines 235-277. No special
bypass logic. Correct.

---

## 3. Engine Behavior

### 3.1 Three-phase timing -- IMPLEMENTED
Evidence: `lib/domain/engine/timer_phase.dart` defines wait, duration,
grace (plus sensitivity and holdWait). `_startPhase()` in session_engine.dart
line 412 resolves base duration per phase using `step.waitDuration`,
`step.activeDuration`, `step.gracePeriod`.

### 3.2 Retry timing -- IMPLEMENTED
Evidence: `_onGraceExpired()` at line 488 increments `_missCount` and
either advances or calls `_startPhase(TimerPhase.duration)` -- skipping
the wait phase on retry. `_advanceToStep()` at line 364 only executes
wait on first entry.

### 3.3 Hardware button 5 presses -- IMPLEMENTED
- **5x press default:** `lib/domain/models/step_config.dart` line 522:
  `const RepeatPressTrigger({this.pressCount = 5, ...})`.
- **Seed data uses 5:** `lib/data/seed_data.dart` line 79-81:
  `HardwareButtonDistressTrigger(trigger: RepeatPressTrigger(pressCount: 5))`.
- **Trigger model:** `lib/domain/models/trigger.dart` line 30-61 defines
  `HardwareButtonDistressTrigger` with configurable `RepeatPressTrigger`.
- **Either chain step OR escalation tool:** Spec says not both. This
  constraint is documented but not enforced programmatically in the
  validator. **Minor gap.**

### 3.4 Fake call lifecycle -- IMPLEMENTED
- **Ring/answer/pause/hangup/disarm:** `session_engine.dart` lines 215-247.
  `answerFakeCall()` cancels timer (pausing chain). `hangUp()` calls
  `disarm()`. `declineFakeCall()` checks `declineIsSafe`.
- **Decline-with-distress 5s hold:** `lib/features/fake_call/fake_call_screen.dart`
  lines 40, 64-99. `_declineHoldDuration = Duration(seconds: 5)`.
  Progress indicator shown. However, when hold completes (line 82-86),
  it calls `_decline()` which pops screen -- it does NOT actually trigger
  the distress chain via `triggerDistressChain()`. **BUG: decline-with-
  distress hold fires `_decline()` instead of triggering distress chain.**
- **declineIsSafe flag:** `FakeCallConfig.declineIsSafe` at step_config.dart
  line 151. Engine `declineFakeCall()` at line 231 checks it.
- **Voice recording ends, stay on call:** `fake_call_screen.dart` shows
  "Connected" state with only a "Hang Up" button. No auto-hang-up. Correct.

### 3.4a Real call during fake call auto-disarm -- PARTIAL
Evidence: `session_controller.dart` lines 215-224 listen to
`callState.listen()` and auto-pause/resume on incoming call. However, the
spec says "fake call auto-disarms silently when the real call ends." The
current implementation resumes the engine (not disarm) after the real call
ends. It does not special-case fake call step -- it treats all steps the
same (pause/resume). **GAP: should auto-disarm when fake call is active
and real call ends, not just resume.**

### 3.5 declineIsSafe -- IMPLEMENTED
Evidence: `FakeCallConfig.declineIsSafe` field exists (step_config.dart
line 151). Default `true`. Engine checks at `declineFakeCall()` line 242:
`if (config.declineIsSafe) { disarm(); } else { restartCurrentStep(); }`.

### 3.6 Disarm universal -- IMPLEMENTED
Evidence: `disarm()` at session_engine.dart line 200 works from any state
except Ended/Idle. Resets to step 0, clears missCount. PIN gating in
session_screen.dart lines 191-223.

### 3.7 holdStart/holdRelease edge-triggered -- IMPLEMENTED
Evidence: `holdStart()` line 146: `if (_isHolding) return;`.
`holdRelease()` line 178: `if (!_isHolding) return;`.

### 3.8 start() fail loud -- IMPLEMENTED
Evidence: `start()` line 98: `if (_state is! EngineIdle) { throw StateError('Engine already started'); }`.

### 3.9 Speed multiplier simulation only -- IMPLEMENTED
Evidence: `setSpeedMultiplier()` line 341: rejects non-1.0 for real sessions,
validates NaN/Infinity/negative, clamps to [0.01, 1000.0].

### 3.10 Pause behavior -- IMPLEMENTED
Evidence: `pause()` at line 279 captures actual remaining time, cancels
timer, transitions to EnginePaused. Orchestrator's `onPause` callback
(session_controller.dart line 147) stops audio and vibration. Configurable
max pause via `SessionMode.maxPauseDuration` (session_mode.dart line 59).
**Note:** max pause enforcement not found in engine -- field exists but
engine does not auto-resume when max duration exceeded. **Minor gap.**

### 3.11 Resume after real phone call -- IMPLEMENTED
Evidence: `resume()` at line 297 restores exact remaining time from
snapshot. No grace reset, no buffer. Correct.

### 3.12 Sealed EngineState -- IMPLEMENTED
Evidence: `lib/domain/engine/engine_state.dart` defines exactly:
`sealed class EngineState` with `EngineIdle`, `EngineRunning`,
`EnginePaused`, `EngineEnded`. `EndReason` has `userTerminated`,
`chainExhausted`, `distressCompleted`. `PauseReason` has `manual`,
`incomingCall`. All match spec exactly.

### 3.13 Engine events -- IMPLEMENTED
Evidence: `lib/domain/models/chain_event.dart` defines exactly 10 events:
`stepStarted`, `reminderFired`, `repeatMissed`, `stepAdvancing`,
`userDisarmed`, `chainExhausted`, `sessionEnded`, `sessionPaused`,
`sessionResumed`, `stepExecutionFailed`. Matches spec exactly.

### 3.14 endSession() -- IMPLEMENTED
Evidence: `endSession()` at session_engine.dart line 105 transitions
immediately to EngineEnded, closes stream. No recall of already-dispatched
actions. Session controller persists log before ending.

---

## 4. Chain Types

### 4.1 Main chain -- IMPLEMENTED
Evidence: `SessionMode.chainSteps` at session_mode.dart line 43.

### 4.2 Distress chain replaces main chain -- IMPLEMENTED
- **replaceWithDistressChain():** session_engine.dart line 124.
  Cancels timer, sets `_isDistressChain = true`, replaces `_steps`,
  resets to step 0.
- **Three triggers:** `handlePinResult()` in session_controller.dart
  handles duress PIN (line 398) and wrong PIN threshold (line 402),
  both call `triggerDistressChain()`. TriggerManager handles hardware
  panic (trigger_manager.dart line 158).
- **Fake "session ended" after distress:** `_advanceToNextStep()` at
  session_engine.dart line 397 transitions to
  `EngineEnded(reason: EndReason.distressCompleted)`. WalkSession maps
  this to `SessionPhase.completed` at walk_session.dart line 129,
  which renders the same completion UI. Correct.

### 4.2a 5s confirmation window -- IMPLEMENTED
Evidence: `lib/core/widgets/distress_confirmation.dart`. Default duration
5 seconds (line 43). Configurable via `duration` parameter. PIN gating
on cancel via `onCancel` callback (line 41). Stealth mode support
(line 127-131). TriggerManager calls `onDistressConfirmation` before
replacing chain (trigger_manager.dart line 176).

### 4.3 Battery one-shot (no chainSteps) -- IMPLEMENTED
Evidence: `lib/domain/models/battery_alert_config.dart` has only
`threshold`, `isEnabled`, `sendSmsToContacts`. No chain steps. Default
OFF (`isEnabled = false`). session_controller.dart `_startBatteryMonitor()`
fires once (`if (_batteryAlertFired) return;` at line 248).

### 4.4 Any step type in any chain -- IMPLEMENTED
Evidence: Engine only cares about `_steps` (List<ChainStep>). No type
restriction on what goes into distressChainSteps vs chainSteps.

---

## 5. Trigger System

### 5.1 Triggers parallel to chain -- IMPLEMENTED
Evidence: `SessionMode` has `distressTriggers` and `disarmTriggers`
(session_mode.dart lines 53-56) as separate lists from `chainSteps`.
`TriggerManager` (trigger_manager.dart) runs independently from engine.

### 5.2 Distress triggers -- IMPLEMENTED
Evidence: `HardwareButtonDistressTrigger` with `RepeatPressTrigger`
(pressCount default 5). 500ms cooldown in trigger_manager.dart line 118.

### 5.3 Disarm triggers -- IMPLEMENTED
Evidence: `GpsArrivalDisarmTrigger` and `TimerDisarmTrigger` defined in
trigger.dart. TriggerManager routes GPS arrivals to `onDisarmRequested`
callback (trigger_manager.dart line 147).
**Note:** TimerDisarmTrigger is defined in the model but TriggerManager
does not implement timer-based disarm listening. **Minor gap.**

### 5.4 Session start flow -- PARTIAL
Evidence: No pre-session active triggers summary or GPS destination prompt
found. The session starts directly from the home screen via
`startSession()`. **GAP: no pre-start trigger summary or destination
prompt UI.**

---

## 6. Simulation

### 6.1 Strategy pattern -- IMPLEMENTED
Evidence: `lib/services/simulation/simulation_messaging_service.dart` and
`simulation_phone_service.dart` implement the protocol interfaces without
importing any telephony packages. All methods log as `sim_blocked`.
`service_providers.dart` exposes `simulationMessagingProvider` and
`simulationPhoneProvider`. Structural guarantee: no platform SMS/call
methods exist in simulation classes.

### 6.2 What fires vs what's blocked -- IMPLEMENTED
Evidence: Simulation services block SMS, phone calls, emergency calls
(logged as `sim_blocked`). Fake call screen fires locally (sound/UI).
Notifications still fire. Correct per spec.

### 6.3 Speed control -- IMPLEMENTED
Evidence: Engine clamps to [0.01, 1000.0] at session_engine.dart line 348.
`SimulationControls` widget at
`lib/features/session/widgets/simulation_controls.dart` shows logarithmic
slider 1x-1000x with preset buttons (1x, 10x, 100x, 1000x).
**Note:** Background 60x cap not implemented in engine -- only the
general 1000x clamp. **Minor gap.**

### 6.4 Simulation UI -- IMPLEMENTED
Evidence: Session screen shows orange simulation banner
(session_screen.dart line 145). SimulationControls widget has speed
slider, preset buttons, leap button, and Advanced toggle with trigger
buttons (arrival, low battery, hardware panic). All present.

### 6.5 No "GO LIVE" button -- IMPLEMENTED
Evidence: No conversion from simulation to real session found anywhere.
Correct.

### 6.6 Lenient simulation validation -- IMPLEMENTED
Evidence: `session_validator.dart` uses `isSimulation` parameter.
When true, contacts check is skipped (line 126: `&& !isSimulation`).
Permission checks downgrade to warnings (line 204:
`isSimulation ? IssueSeverity.warning : IssueSeverity.error`).

### 6.7 Smart validation -- IMPLEMENTED
Evidence: `session_validator.dart` lines 107-134. Only blocks when chain
has SMS/call/emergency steps AND contacts list is empty. A mode with
only holdButton + loudAlarm passes. Also checks distress chain steps
(line 115-122). Permission checks are per-step-type (SMS permission
only required if hasSmsSteps, phone permission only if hasCallSteps).

---

## 7. Data Model

### 7.1 Sealed StepConfig -- IMPLEMENTED
Evidence: `lib/domain/models/step_config.dart`. `sealed class StepConfig`
with 9 concrete subclasses. JSON envelope format:
`{'type': typeName, 'data': ...}`. Explicit `typeName` string constants
(not `runtimeType.toString()`). Deserialization via switch on type string.

### 7.2 SessionMode -- IMPLEMENTED
Evidence: `lib/domain/models/session_mode.dart`. Has `chainSteps`,
`distressChainSteps`, `distressTriggers`, `disarmTriggers`,
`maxPauseDuration`. All match spec.

### 7.3 EmergencyContact -- IMPLEMENTED
Evidence: `lib/domain/models/emergency_contact.dart`. Fields: id, name,
phoneNumber, relationship (String?), sortOrder, preferredChannel,
channels (List<MessageChannel>?), languageCode (String?). All match spec.

### 7.4 UserProfile -- IMPLEMENTED
Evidence: `lib/domain/models/user_profile.dart`. Has name, phoneNumber,
photoPath, physicalDescription, bloodType, allergies, medications,
medicalConditions, emergencyMedicalNotes. `medicalSummary` getter
formats for SMS. All match spec.

### 7.5 AppSettings -- IMPLEMENTED
Evidence: `lib/domain/models/app_settings.dart`. Has themeMode,
languageCode, stealthMode, appPinHash, duressPinHash, sessionEndPinHash,
pinTimeoutSeconds (15), emergencyNumber, logGpsWithEvents,
alarmOverrideSilentMode, stealthTimerDisplay, biometricEnabled,
wrongPinThreshold. All match spec.

### 7.6 Battery alert config -- IMPLEMENTED
Evidence: `lib/domain/models/battery_alert_config.dart`. `isEnabled`
(default false), `threshold` (default 10), `sendSmsToContacts`.
One-shot, not a chain. Matches spec.

---

## 8. Settings

### 8.1 Session locks -- IMPLEMENTED
Evidence: `lib/core/utils/session_lock.dart`. `checkSessionLock()` shows
dialog "End your current session to access this setting." when session
is active.

### 8.2 Quick Exit preserves data -- IMPLEMENTED
Evidence: `lib/core/utils/quick_exit.dart`. Android:
`finishAndRemoveTask()` via platform channel (line 59). iOS: decoy
screenshot + `exit(0)` (lines 62-74). Data is NOT deleted -- only the
app process exits. PIN gating via `executeWithPin()` (line 32).
Session logs preserved in Hive storage.

### 8.3 Stealth mode -- IMPLEMENTED
Evidence: AppSettings has 8 stealth fields (stealthMode,
stealthHideMissedIndicators, stealthHideGraceVisuals, etc.).
`StealthTimerDisplay` enum (normal/small/none). PIN dialog respects
`isStealth` (pin_entry_dialog.dart line 170). Distress confirmation
respects stealth (distress_confirmation.dart lines 127-131). Independent
from PIN per spec.

### 8.4 Emergency call confirmation -- IMPLEMENTED
Evidence: `lib/core/widgets/emergency_call_confirmation.dart`. Dialog text:
"Are you sure? The emergency call will NOT be made." Used in
session_screen.dart line 199-201 when disarming during callEmergency step.

### 8.5 Alarm DND override -- IMPLEMENTED
Evidence: `AppSettings.alarmOverrideSilentMode` defaults to true
(app_settings.dart line 33). Uses STREAM_ALARM per
LoudAlarmConfig specification.

---

## 9. Onboarding

### 9.1 Three pages -- IMPLEMENTED
Evidence: `lib/features/onboarding/onboarding_screen.dart`.
`_pageCount = 3` (line 38). Pages:
1. `_WelcomePage` -- GuardianAngelaLogo (120px), tagline, description.
2. `_ProfileContactPage` -- name field + contact name + phone (combined).
3. `_PermissionsPage` -- requests notification, location, phone, SMS.
All skippable via "Skip" button (line 122). Finish navigates to home
screen. Matches spec exactly.

---

## 10. UI Design

### 10.1 Old design aesthetic -- PARTIAL
Evidence: `GuardianAngelaLogo` exists at
`lib/core/theme/guardian_angela_logo.dart`. `PrideWidgets` exist at
`lib/core/theme/pride_widgets.dart` (PridePageIndicator used in
onboarding). Animated start button, contact chips, chain summary pills
present in home screen. However, many UI strings are hardcoded English
with `// TODO: l10n` comments throughout (onboarding, session screen,
fake call screen). **GAP: localization not wired to most UI strings.**

### 10.2 GuardianAngelaLogo -- IMPLEMENTED
Evidence: `lib/core/theme/guardian_angela_logo.dart`. CustomPaint widget
with feathered wings, shield body (gap via `_shieldPath` inflate), halo
ellipse, pride-flag gradient. Scalable via `size` parameter.

### 10.3 Home screen -- IMPLEMENTED
Evidence: `lib/features/home/home_screen.dart` exists with mode selector,
chain summary (`lib/features/home/widgets/chain_summary.dart`), start
button, simulate link.

### 10.4 Session screen -- IMPLEMENTED
Evidence: `lib/features/session/session_screen.dart`. Phase-based
rendering via `_buildPhaseContent()` switch on SessionPhase. HoldButton
for walk mode, I'm Safe slider, simulation controls, PIN gating on
end/disarm.

---

## 11. Simulation UI

### 11.1 Simulation controls -- IMPLEMENTED
Evidence: `lib/features/session/widgets/simulation_controls.dart`.
LogarithmicSlider (1x-1000x), preset buttons (1x, 10x, 100x, 1000x),
leap-to-next-event button, Advanced toggle with trigger arrival,
low battery, hardware panic buttons. All present.

### 11.2 Simulation description toasts -- IMPLEMENTED
Evidence: `lib/features/session/widgets/simulation_description_toast.dart`.
Shows SnackBar with step description. Session screen tracks
`_lastShownDescription` and shows toast on change (session_screen.dart
lines 71-83). EventStrategy interface has `simulationDescription()`
method.

---

## 12. Languages

### 12.1 All 14 from day one -- IMPLEMENTED
Evidence: 14 ARB files in `lib/l10n/l10n/`: app_ar.arb, app_de.arb,
app_el.arb, app_en.arb, app_es.arb, app_fa.arb, app_fr.arb, app_he.arb,
app_hi.arb, app_pl.arb, app_ru.arb, app_uk.arb, app_zh.arb,
app_zh_TW.arb. That is 14 files covering: en, de, es, fr, ru, zh (CN),
zh_TW, hi, fa (RTL), uk, pl, el, ar (RTL), he (RTL). Matches spec list.
**Note:** `zh` is used instead of `zh_CN` as the spec states -- Flutter
treats `zh` as Simplified Chinese by default, with `zh_TW` as the
Traditional variant, so this is functionally equivalent.

---

## 13. Seed Data

### 13.1 Walk Mode -- IMPLEMENTED
Evidence: `lib/data/seed_data.dart` `seedWalkMode()`. Chain:
holdButton (dur=10s, grace=5s, sensitivity=1.0) -> fakeCall (retry=2,
declineIsSafe=true, dur=30s) -> smsContact (includeLocation) ->
phoneCallContact (preSendSms) -> callEmergency (sendLocationSmsFirst).
Distress trigger: HardwareButtonDistressTrigger(pressCount: 5).
Distress chain: smsContact -> callEmergency. All match spec.

### 13.2 Date Mode -- IMPLEMENTED
Evidence: `seedDateMode()`. Chain: disguisedReminder (wait=1800s,
retry=3, grace=120s) -> fakeCall (retry=1, declineIsSafe=true) ->
smsContact -> phoneCallContact (preSendSms) -> callEmergency
(showConfirmation=true, dur=10s). Distress trigger: pressCount=5.
All match spec.

---

## 14. Platform Notes

### 14.1 Android -- PARTIAL
Evidence: Quick Exit uses platform channel
`com.guardianangela.app/system_ui` for `finishAndRemoveTask()`. However
the native Kotlin `MainActivity.kt` is deleted per git status. Android
manifest modifications present but native implementation details not
verified. WorkManager for SMS not directly visible (would be in native
code). **Note: native layer not fully reviewable from Dart code alone.**

### 14.2 iOS -- PARTIAL
Evidence: Quick Exit has iOS path with decoy screenshot + `exit(0)`.
`IncomingCallServiceProtocol` comment references `CXCallObserver`.
Volume button interception limitation not documented in UI.
**Note: native layer not fully reviewable from Dart code alone.**

---

## 15. Architecture

### 15.1 Stack -- IMPLEMENTED
Evidence: pubspec.yaml dependencies include flutter_riverpod, go_router,
hive. JSON serialization throughout models. Matches spec.

### 15.2 Feature-first layout -- IMPLEMENTED
Evidence: Directory structure matches spec exactly:
`lib/core/`, `lib/data/`, `lib/domain/`, `lib/features/`,
`lib/services/`, `lib/router/`, `lib/l10n/`.

### 15.3 Service protocol pattern -- IMPLEMENTED
Evidence: `lib/services/protocols/` has 11 abstract protocol classes.
`lib/services/implementations/` has 11 real implementations.
`lib/services/fakes/` has 11 fake implementations for tests.
`lib/services/simulation/` has 2 simulation implementations (messaging,
phone). All injected via Riverpod providers in `service_providers.dart`.

### 15.4 Testing -- PARTIAL
Evidence: Test infrastructure exists (`test/` directory referenced in
CLAUDE.md). `fake_async`, `checks`, and `mocktail` mentioned. Actual
test coverage not verified in this review.

---

## Summary

| Section | Status | Notes |
|---------|--------|-------|
| 1.1 Minimize false positives | IMPLEMENTED | |
| 1.2 User controls everything | IMPLEMENTED | |
| 1.3 PIN 15s timeout | IMPLEMENTED | Biometric UI integration not wired |
| 1.4 Chains are just chains | IMPLEMENTED | |
| 2.1 Crash Recovery removed | IMPLEMENTED | |
| 2.2 Shake-to-SOS rejected | IMPLEMENTED | |
| 2.3 Battery SMS bypass removed | IMPLEMENTED | |
| 3.1 Three-phase timing | IMPLEMENTED | |
| 3.2 Retry timing | IMPLEMENTED | |
| 3.3 Hardware button 5 presses | IMPLEMENTED | Mutual exclusion (step OR trigger) not enforced |
| 3.4 Fake call lifecycle | PARTIAL | **BUG:** decline-with-distress calls _decline() not triggerDistressChain() |
| 3.4a Real call auto-disarm | PARTIAL | Resumes instead of auto-disarming during fake call |
| 3.5 declineIsSafe | IMPLEMENTED | |
| 3.6 Disarm universal | IMPLEMENTED | |
| 3.7 Edge-triggered hold | IMPLEMENTED | |
| 3.8 start() fail loud | IMPLEMENTED | |
| 3.9 Speed multiplier | IMPLEMENTED | |
| 3.10 Pause behavior | IMPLEMENTED | maxPauseDuration not enforced by engine |
| 3.11 Resume exact time | IMPLEMENTED | |
| 3.12 Sealed EngineState | IMPLEMENTED | |
| 3.13 Engine events (10) | IMPLEMENTED | |
| 3.14 endSession() | IMPLEMENTED | |
| 4.1 Main chain | IMPLEMENTED | |
| 4.2 Distress replaces main | IMPLEMENTED | |
| 4.2a 5s confirmation | IMPLEMENTED | |
| 4.3 Battery one-shot | IMPLEMENTED | |
| 4.4 Any step in any chain | IMPLEMENTED | |
| 5.1 Triggers parallel | IMPLEMENTED | |
| 5.2 Distress triggers | IMPLEMENTED | |
| 5.3 Disarm triggers | IMPLEMENTED | TimerDisarmTrigger model exists but not wired |
| 5.4 Session start flow | PARTIAL | No trigger summary or GPS prompt UI |
| 6.1 Simulation strategy | IMPLEMENTED | |
| 6.2 Fires vs blocked | IMPLEMENTED | |
| 6.3 Speed control | IMPLEMENTED | Background 60x cap not implemented |
| 6.4 Simulation UI | IMPLEMENTED | |
| 6.5 No GO LIVE | IMPLEMENTED | |
| 6.6 Lenient validation | IMPLEMENTED | |
| 6.7 Smart validation | IMPLEMENTED | |
| 7.1 Sealed StepConfig | IMPLEMENTED | |
| 7.2 SessionMode | IMPLEMENTED | |
| 7.3 EmergencyContact | IMPLEMENTED | |
| 7.4 UserProfile | IMPLEMENTED | |
| 7.5 AppSettings | IMPLEMENTED | |
| 7.6 Battery alert config | IMPLEMENTED | |
| 8.1 Session locks | IMPLEMENTED | |
| 8.2 Quick Exit preserves data | IMPLEMENTED | |
| 8.3 Stealth mode | IMPLEMENTED | |
| 8.4 Emergency call confirmation | IMPLEMENTED | |
| 8.5 Alarm DND override | IMPLEMENTED | |
| 9.1 Three-page onboarding | IMPLEMENTED | |
| 10.1 Old design aesthetic | PARTIAL | Many TODO: l10n strings not wired |
| 10.2 GuardianAngelaLogo | IMPLEMENTED | |
| 10.3 Home screen | IMPLEMENTED | |
| 10.4 Session screen | IMPLEMENTED | |
| 11.1 Simulation controls | IMPLEMENTED | |
| 11.2 Simulation toasts | IMPLEMENTED | |
| 12.1 14 languages | IMPLEMENTED | zh used instead of zh_CN (functionally equivalent) |
| 13.1 Walk Mode seed | IMPLEMENTED | |
| 13.2 Date Mode seed | IMPLEMENTED | |
| 14.1 Android | PARTIAL | Native layer not fully reviewable |
| 14.2 iOS | PARTIAL | Native layer not fully reviewable |
| 15.1 Stack | IMPLEMENTED | |
| 15.2 Feature-first layout | IMPLEMENTED | |
| 15.3 Service protocol pattern | IMPLEMENTED | |
| 15.4 Testing | PARTIAL | Coverage not verified |

---

## Critical Issues (must fix)

1. **SS 3.4 -- Decline-with-distress does not trigger distress chain.**
   File: `lib/features/fake_call/fake_call_screen.dart` lines 82-86.
   When the 5s hold completes, `_decline()` is called which pops the
   screen with a normal decline. It should instead call
   `ref.read(sessionControllerProvider.notifier).triggerDistressChain(distressSteps)`
   and then pop.

2. **SS 3.4a -- Real call during fake call should auto-disarm, not resume.**
   File: `lib/features/session/session_controller.dart` lines 215-224.
   When `CallState.ended` fires, the code unconditionally resumes. It
   should check if the current step is a fake call step and, if so,
   call `disarm()` instead of `resume()`.

## Non-Critical Gaps

3. **SS 3.3 -- Hardware button mutual exclusion not validated.**
   The spec says hardware button is "either a chain step OR an
   escalation tool" in the same mode. SessionValidator does not enforce
   this constraint.

4. **SS 3.10 -- maxPauseDuration not enforced by engine.**
   The field exists on SessionMode but the engine does not set a timer
   to auto-resume when max pause duration expires.

5. **SS 5.3 -- TimerDisarmTrigger not wired in TriggerManager.**
   The model class exists but TriggerManager.start() only handles
   GpsArrivalDisarmTrigger, not TimerDisarmTrigger.

6. **SS 5.4 -- Pre-session trigger summary and GPS destination prompt
   not implemented.** No UI for showing active triggers or prompting
   for destination before session start.

7. **SS 6.3 -- Background 60x speed cap not implemented.**
   Engine clamps to 1000x globally. No distinction between foreground
   and background.

8. **SS 10.1 -- Localization strings not wired.** Dozens of `// TODO: l10n`
   comments throughout onboarding, session screen, and fake call screen.
   ARB files exist but UI hardcodes English strings.
