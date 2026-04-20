# Edge Cases and Logic Flaws Review

Reviewer: QA Engineer (automated review)
Date: 2026-03-31
Scope: SessionEngine, SessionController, SessionScreen, SeedData, EventStrategies, EscalationStepList

---

## Severity scale

- **CRITICAL** -- Can cause real-world safety failure (missed escalation, stuck chain, silent failure during emergency)
- **HIGH** -- Incorrect behavior that a user will encounter under normal use
- **MEDIUM** -- Incorrect behavior under unusual but possible conditions
- **LOW** -- Cosmetic, theoretical, or defense-in-depth issue

---

## 1. Engine Edge Cases

### 1.1 CRITICAL -- CallEmergencyStrategy double-waits the duration phase

**File:** `lib/features/session/event_strategies/call_emergency_strategy.dart:12-18`

When `showConfirmation` is true, the strategy does:
```dart
await Future<void>.delayed(Duration(seconds: step.durationSeconds));
```

But the engine has *already* started its own duration timer for this step via `_startGenericStep` -> `_startDurationPhase`. The strategy's `Future.delayed` runs concurrently with the engine's `_durationTimer`. After the strategy's delay completes and calls `services.phone.callEmergency()`, the engine's duration timer will *also* fire and start the grace phase, potentially advancing the chain while the emergency call is in progress.

**Impact:** In the worst case, the chain advances past the emergency call step while the call is being placed. The engine moves to `chainExhausted`, the session ends, and services are stopped -- potentially interrupting the emergency call.

**Reproduction:**
1. Create a mode with `callEmergency` as the last step, `showConfirmation=true`, `durationSeconds=5`.
2. Start session, let escalation reach callEmergency.
3. After 5s the strategy calls the emergency number, but simultaneously the engine's duration timer fires, starts the (0s) grace phase, then advances. Chain exhausts. `endSession()` fires `_stopServices()`.

**Fix:** The strategy should not independently delay. Either (a) the engine should skip its duration timer for callEmergency when showConfirmation=true and let the strategy control timing, or (b) the strategy should only check `isCancelled` without its own delay.

---

### 1.2 HIGH -- speedMultiplier changed mid-timer has no effect on running timers

**File:** `lib/features/session/session_engine.dart:619-621`

The doc comment on `setSpeedMultiplier` correctly notes: "Takes effect on the next timer that is created; existing timers are not retroactively adjusted." However, the UI exposes a speed toggle button during simulation that the user may press mid-step. The currently running timer continues at the old speed, which can be confusing (e.g., user switches to 5x during a 30-minute wait, but nothing happens until the original timer fires).

**Impact:** Simulation UX issue. The user toggles speed but sees no immediate effect. Not a safety issue since it only affects simulation mode.

**Reproduction:**
1. Start simulation of Date Mode.
2. During the 30-minute disguised reminder wait phase, toggle speed to 5x.
3. The wait timer continues for the original ~30 minutes (adjusted), not 6 minutes.

**Fix:** Either cancel and recreate the current timer with the remaining duration divided by the new multiplier, or document this clearly in the UI.

---

### 1.3 MEDIUM -- Zero-duration timing values cause Timer(Duration.zero) micro-task scheduling

**File:** `lib/features/session/session_engine.dart:230-236, 248-252`

When `durationSeconds` or `gracePeriodSeconds` is 0, the engine uses `Timer(Duration.zero, ...)`. This schedules the callback as a microtask-like event (runs on the next event loop iteration). With all three phases at 0 seconds (`repeatIntervalSeconds=0, durationSeconds=0, gracePeriodSeconds=0`), the step completes almost instantly and advances to the next step.

With a chain of 100 steps all having zero durations, this creates a rapid cascade of 100+ timers firing in quick succession. Each `Timer(Duration.zero, ...)` callback creates the next timer, so this is sequential (not a stack overflow), but it will:
- Emit ~300+ events in under a second (stepStarted, stepAdvancing, etc.)
- The SessionController's `_onEvent` will rebuild the UI state ~300+ times
- The session log will record ~300+ events

This is theoretically possible if a user creates a mode with many steps and sets all timings to minimum values.

**Impact:** Performance degradation, rapid UI flicker, but no crash or stuck state. The chain does complete correctly.

**Reproduction:**
1. Create a mode with 20+ steps, all with durationSeconds=0, gracePeriodSeconds=0.
2. Start session. All steps fire nearly instantly.

---

### 1.4 MEDIUM -- holdStart() during grace phase calls disarm(), which resets _isHolding implicitly

**File:** `lib/features/session/session_engine.dart:360-374`

When `holdStart()` is called during the grace phase:
1. `_isHolding` is set to `true` (line 362)
2. `disarm()` is called (line 369)
3. `disarm()` resets to step 0 and calls `_executeStep(0)`
4. But `_isHolding` is *still true* from step 1

The holdButton step at index 0 now starts with `_isHolding = true`, but the hold button UI widget has been reset. The engine thinks the user is holding, but the UI widget's local `_isHolding` state is independent. On the next `holdRelease()`, the engine will process it, but if the user doesn't release (because they didn't actually start a new hold), the engine stays in a state where `_isHolding = true` indefinitely.

**Impact:** After disarming via re-hold during grace, the engine's hold state is desynchronized from the UI. The sensitivity timer won't start because the engine thinks the button is still held.

**Reproduction:**
1. Start Walk Mode.
2. Hold button, release it.
3. Wait for sensitivity + duration to pass, entering grace phase.
4. Hold button again during grace (triggers disarm).
5. Engine resets to step 0 with `_isHolding = true`, but UI shows unheld state.

**Fix:** Reset `_isHolding = false` in `disarm()` or at the start of `_executeStep()`.

---

### 1.5 MEDIUM -- Rapid holdStart()/holdRelease() calls can create orphaned sensitivity timers

**File:** `lib/features/session/session_engine.dart:355-402`

Calling `holdStart()` cancels `_sensitivityTimer` and `_durationTimer` (lines 373-374). Calling `holdRelease()` cancels `_sensitivityTimer` and creates a new one (lines 395-396). But if the user rapidly taps (hold-release-hold-release-hold-release) within the sensitivity window, each `holdRelease()` creates a new `_sensitivityTimer`, and each subsequent `holdStart()` cancels it. This is actually handled correctly because of the cancel-on-enter pattern.

However, there is a subtle issue: if `holdStart()` is called while `_isHolding` is already true (double-tap start without release), the second `holdStart()` still cancels the sensitivity and duration timers. This is benign but worth noting.

**Impact:** Low. The cancel-then-create pattern handles this correctly in practice.

---

### 1.6 MEDIUM -- disarm() during endSession() race condition

**File:** `lib/features/session/session_engine.dart:164-170, 471-488`

If `disarm()` and `endSession()` are called near-simultaneously (e.g., user taps "I'm Safe" right as the chain exhausts):

1. `endSession()` sets `_ended = true`, cancels timers, adds `sessionEnded` event, closes the stream.
2. If `disarm()` runs first, it emits `userDisarmed`, resets to step 0, and starts executing. Then `endSession()` fires, sets `_ended = true`.
3. If `endSession()` runs first, `disarm()` returns early because `_ended` is true (line 472).

Since Dart is single-threaded, these cannot truly race. But both `chainExhausted` and `sessionEnded` events trigger `_saveSessionLog()` in the controller (lines 279, 283). The `_saveSessionLog` method guards against double-save by nulling `_sessionStartTime`, so this is safe.

**Impact:** None -- properly guarded. Noted for completeness.

---

### 1.7 LOW -- _randomized() can produce 0ms duration from small inputs

**File:** `lib/features/session/session_engine.dart:98-101`

`_randomized(Duration d)` applies factor 0.8-1.2. If `d` is 1 second (1000ms) and factor is 0.8, result is 800ms -- fine. But if `d` is 0 seconds, factor * 0 = 0 -- also fine. The function cannot produce negative durations because the factor range is [0.8, 1.2] and durations are non-negative. This is correct.

**Impact:** None. Included to confirm no negative duration issue exists.

---

### 1.8 LOW -- Chain modification while session is running

The engine takes `chainSteps` as a `List<ChainStep>` in the constructor. The controller creates this list with `List.of(mode.chainSteps)..sort(...)` (session_controller.dart:100-101), which creates a shallow copy. Since `ChainStep` extends `HiveObject` (mutable), if the user edits the mode's chain steps in the Hive box while a session is running, the engine's list references could see mutated objects.

However, the mode editor requires ending the session first (enforced by UI navigation), so this is unlikely in practice.

**Impact:** Theoretical. The UI prevents editing during an active session.

---

## 2. Controller Edge Cases

### 2.1 HIGH -- SMS step silently does nothing when contacts list is empty

**File:** `lib/features/session/event_strategies/sms_contact_strategy.dart:9`

```dart
if (services.contacts.isEmpty) return;
```

When the SMS step fires and there are no emergency contacts configured, it silently returns. The engine continues its duration -> grace -> advance cycle. The user has no indication that SMS was not sent.

**Impact:** The user believes SMS was sent to contacts, but nothing happened. This is a safety-critical silent failure. The chain advances past the SMS step as if it succeeded.

**Reproduction:**
1. Create a mode with smsContact step.
2. Don't add any emergency contacts.
3. Start session, let it escalate to SMS step.
4. Step appears to execute (UI shows "SMS Sent" state) but no message is sent.

**Fix:** Either (a) prevent starting a session with SMS steps when no contacts are configured, (b) show a warning/toast, or (c) don't advance and retry.

---

### 2.2 HIGH -- PhoneCallContactStrategy silently fails when contactId is not configured

**File:** `lib/features/session/event_strategies/phone_call_contact_strategy.dart:9`

```dart
if (contactId == null) return;
```

If the user adds a phoneCallContact step but never configures which contact to call, `contactId` is null. The strategy silently returns, and the engine's timer cycle advances past the step. No call is made, no error is shown.

**Impact:** Same as 2.1 -- silent failure of a safety-critical action.

**Reproduction:**
1. Add a phoneCallContact step without configuring a contact.
2. Start session, let it escalate.
3. Step fires but does nothing.

---

### 2.3 HIGH -- LoudAlarm screen flash is never turned off

**File:** `lib/features/session/event_strategies/loud_alarm_strategy.dart:23-25`

The strategy calls `services.onScreenFlash?.call(true)` to activate the screen flash overlay, but never calls `services.onScreenFlash?.call(false)` to deactivate it. The flash persists until:
- The user disarms (controller's `checkIn()` sets it to false -- session_controller.dart:176)
- The session ends (controller's `_stopServices()` sets it to false -- session_controller.dart:474)
- The chain advances to the next step -- but **it does NOT turn off the flash on advance**

If the loud alarm step completes and advances to the next step (e.g., callEmergency), the screen flash overlay continues flashing because `_onEvent` for `stepStarted` does not clear `screenFlashActiveProvider`.

**Impact:** Screen flash persists through subsequent steps after loud alarm, including the emergency call step. This may interfere with the user's ability to interact with the emergency call UI.

**Reproduction:**
1. Create mode: loudAlarm (flashScreen=true) -> callEmergency.
2. Start session, let it escalate through alarm to emergency.
3. Screen flash continues during the emergency call step.

**Fix:** Clear `screenFlashActiveProvider` in `_onEvent` when `stepStarted` fires for a non-loudAlarm step, or in the `stepAdvancing` handler.

---

### 2.4 MEDIUM -- _executeStepAction is fire-and-forget with no error handling

**File:** `lib/features/session/session_controller.dart:390-409`

`_executeStepAction` calls `strategy.executeReal(step, services)` which returns a `Future<void>`, but the call is not awaited and no `.catchError` is attached. If the strategy throws (e.g., SMS service throws due to no permissions, audio file not found), the error propagates as an unhandled future.

**Impact:** Unhandled exceptions may crash the app or silently fail depending on the Flutter error handler. The chain engine continues regardless, potentially advancing past a failed step.

**Reproduction:**
1. Revoke SMS permissions while a session is active.
2. Let the chain escalate to the SMS step.
3. The messaging service throws a permission error. The error is unhandled.

---

### 2.5 MEDIUM -- startSession() disposes old engine but does not await _stopServices()

**File:** `lib/features/session/session_controller.dart:85-87`

When `startSession()` is called while a session is active:
```dart
if (_engine != null) {
  _dispose();
}
```

`_dispose()` cancels subscriptions and nulls the engine, but does NOT call `_stopServices()`. So the wakelock, location tracking, background service, and hardware button listening from the previous session continue running. A new session then starts with new service initialization, potentially conflicting with the old.

**Impact:** Resource leak -- old services (wakelock, location, background service) from the previous session are not stopped before starting new ones.

**Reproduction:**
1. Start a Walk Mode session.
2. Without ending it, programmatically call `startSession()` again (e.g., via a hardware panic that somehow re-triggers start).

**Fix:** Call `_stopServices()` before `_dispose()` when restarting, or call `endSession()` first.

---

### 2.6 MEDIUM -- PhoneCallContactStrategy retries block the event loop for 30+ seconds

**File:** `lib/features/session/event_strategies/phone_call_contact_strategy.dart:45-52`

The retry loop uses `await Future<void>.delayed(const Duration(seconds: 30))`. Since `executeReal` is fire-and-forget from the controller (not awaited), this delay runs in the background. But during this 30-second delay, if the user disarms, the `isCancelled` callback is not checked. The strategy will still attempt the retry call after 30 seconds even if the user has already disarmed.

**Impact:** An unwanted phone call may be placed after the user has already disarmed and reset the chain.

**Reproduction:**
1. Configure phoneCallContact with retryCount=1.
2. Start session, let it escalate to phone call step.
3. The first call fails. Strategy starts a 30-second delay for retry.
4. User disarms during the 30-second delay.
5. After 30 seconds, strategy retries the call despite the user having disarmed.

**Fix:** Check `isCancelled` before each retry attempt.

---

### 2.7 LOW -- Double session log save on chainExhausted + sessionEnded

**File:** `lib/features/session/session_controller.dart:279-284`

Both `chainExhausted` and `sessionEnded` events call `_saveSessionLog()`. When the chain exhausts naturally:
1. Engine emits `chainExhausted` -> controller saves log (nulls `_sessionStartTime`)
2. UI listener detects `SessionState.completed` -> calls `controller.endSession()`
3. `endSession()` calls `_engine?.endSession()` -> engine emits `sessionEnded`
4. Controller receives `sessionEnded` -> calls `_saveSessionLog()` again
5. Second call returns early because `_sessionStartTime` is null (guard works)

**Impact:** None -- the guard prevents actual double-save. But the second event wastefully creates a log object with null start time, which is thrown away. Minor inefficiency.

---

## 3. UI Edge Cases

### 3.1 HIGH -- Empty chain (0 steps) starts a session that never progresses

**File:** `lib/features/session/session_engine.dart:157-160`

```dart
void start() {
  if (_ended || chainSteps.isEmpty || _started) return;
```

If `chainSteps` is empty, `start()` returns early. The engine never emits any event. The controller has already set `state` to an active `WalkSession` (session_controller.dart:106-110). The session screen shows an active session with no step type, displaying the default `_StatusBody` widget. The user can only end the session via the "End Session" button.

The UI does not prevent creating a mode with 0 steps -- `ChainStepList` shows an empty hint but the mode editor allows saving.

**Impact:** User starts a session that appears active but does nothing. No escalation will ever occur.

**Reproduction:**
1. Create a custom mode with no steps (remove all default steps).
2. Start a session with this mode.
3. Session screen shows active status but nothing happens.

**Fix:** Prevent starting a session with an empty chain, or show a warning.

---

### 3.2 MEDIUM -- Session screen pops when session is null but navigation may have already changed

**File:** `lib/features/session/session_screen.dart:70-75`

```dart
if (session == null) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted && context.canPop()) context.pop();
  });
  return const Scaffold(body: SizedBox.shrink());
}
```

If the session becomes null (e.g., `endSession()` called), a post-frame callback pops the route. But the `ref.listen` callbacks (lines 124-161) may have already navigated to the chain exhausted screen or simulation summary. The `context.canPop()` check helps, but there is a potential for double-navigation: the listener navigates to chain exhausted, then the next build finds `session == null` and tries to pop.

**Impact:** Potential for brief navigation glitch (pop after push). The `mounted` and `canPop()` guards reduce the risk.

---

### 3.3 MEDIUM -- _SessionTopBar endSession button has no confirmation dialog

**File:** `lib/features/session/session_screen.dart:847`

```dart
onPressed: controller.endSession,
```

A single tap on "End Session" immediately stops the entire safety session with no confirmation. During a real emergency scenario, an accidental tap (or an attacker forcing the user to tap) ends all protection instantly.

**Impact:** Safety concern -- too easy to accidentally or forcibly end the session.

**Reproduction:** Tap the "End Session" button during an active session.

---

### 3.4 LOW -- Elapsed timer continues after session ends

**File:** `lib/features/session/session_screen.dart:40-47`

The `_elapsedTimer` (1-second periodic timer) is only cancelled in `dispose()`. If the session ends but the screen remains mounted briefly (during navigation transition), the timer continues ticking and calling `setState`. This is harmless but wasteful.

---

### 3.5 LOW -- Theme/language changes mid-session are handled correctly

The session screen uses `Theme.of(context)` and `AppLocalizations.of(context)` in the `build()` method, so theme and language changes will be reflected on the next rebuild. No edge case here -- Flutter's reactive model handles this correctly.

---

## 4. Logic Flaws

### 4.1 CRITICAL -- holdButton grace phase semantics are inverted vs. documentation

**File:** `lib/features/session/session_engine.dart:404-433`

The comment in `chain_step.dart:73-75` says:
> For holdButton this is the visible countdown (what the spec calls "durationSeconds" conceptually, but we store it here because the model was originally simplified).

The engine's hold button flow is:
1. User releases button
2. Sensitivity timer fires (configurable, default 1s)
3. `_startHoldDurationPhase` -- uses `durationSeconds` for the countdown
4. `_startHoldGracePhase` -- uses `gracePeriodSeconds` for dead time after countdown
5. Advance to next step

But the seed data for Walk Mode's holdButton has `durationSeconds: 10, gracePeriodSeconds: 0`:
```dart
ChainStep(
  type: ChainStepType.holdButton,
  durationSeconds: 10, // visible countdown
  gracePeriodSeconds: 0, // escalate immediately after countdown
)
```

This means: after the sensitivity delay, there's a 10-second countdown (duration), then 0 grace, then immediate escalation. However, the `_HoldButtonBody` UI (session_screen.dart:371-377) calculates:
```dart
final totalSeconds = graceSeconds + sensitivitySecs.ceil();
```

It uses `gracePeriodSeconds` (0) + sensitivity (1) = 1 second for the countdown display. But the engine actually counts down `durationSeconds` (10 seconds) before grace. **The UI countdown does not match the engine's actual timing.**

**Impact:** The user sees a 1-second countdown in the UI, but the engine gives them 10 seconds (duration) + 0 seconds (grace) before escalating. The UI countdown expires 9 seconds before actual escalation, causing the user to panic unnecessarily or be confused.

**Reproduction:**
1. Start Walk Mode.
2. Release the hold button.
3. UI shows 1s countdown, but the engine gives 10+1=11 seconds before escalation.

**Fix:** The UI should display `durationSeconds + sensitivitySecs` for the total countdown, not `gracePeriodSeconds + sensitivitySecs`.

---

### 4.2 HIGH -- disguisedReminder with repeatCount=0 still increments _missedRepeats and advances

**File:** `lib/features/session/session_engine.dart:332-348`

In `_onReminderGraceExpired`:
```dart
_missedRepeats++;
_emit(ChainEvent.repeatMissed, ...);
if (_missedRepeats > step.repeatCount) {
  _advanceToNext();
}
```

When `repeatCount` is 0: `_missedRepeats` becomes 1, and `1 > 0` is true, so it advances immediately. This means a disguised reminder with `repeatCount=0` will fire once, and if the user misses it, advance immediately. This is probably correct behavior (0 retries = no second chances), but the name "repeatCount" suggests 0 = no repeats = fire once and advance. Consistent with the generic step path.

BUT there is an asymmetry: in `_onGraceExpired` (the generic step path, line 256-276):
```dart
if (step.repeatCount > 0) {
  _missedRepeats++;
  if (_missedRepeats > step.repeatCount) {
    _advanceToNext();
  } else {
    _startGenericStep(step); // restart
  }
} else {
  _advanceToNext(); // repeatCount=0 means advance immediately
}
```

Generic steps with `repeatCount=0` skip the miss-counting entirely and advance. But disguised reminders with `repeatCount=0` still increment `_missedRepeats` and emit `repeatMissed` before advancing. This inconsistency means:
- Generic step (repeatCount=0): no `repeatMissed` event emitted, just advances
- Disguised reminder (repeatCount=0): emits `repeatMissed` with missCount=1, then advances

**Impact:** The session log shows a "missed" event for disguised reminders even when repeatCount=0, but not for generic steps. The UI may briefly show "Missed (1)" for disguised reminders. Inconsistent but not dangerous.

---

### 4.3 MEDIUM -- The chain can get stuck if holdButton is not step 0 and user cannot interact

**File:** `lib/features/session/session_engine.dart:187-190`

When a `holdButton` step is reached (not at index 0), the engine emits `stepStarted` and then waits for `holdStart()`/`holdRelease()` user interaction. There is no timeout. If the user's phone screen is off, or the app is backgrounded, or the hold button UI is not visible (e.g., because a dialog is on top), the chain is permanently stuck at this step.

The `holdButton` step has no grace period mechanism to auto-advance if the user doesn't interact. Unlike disguised reminders which have a wait -> fire -> grace -> advance cycle, hold buttons require explicit user input.

**Impact:** If a holdButton step is placed anywhere other than position 0 (e.g., as step 2 in a chain), and the chain escalates to it, the user must actively hold and release the button to either disarm or advance. If they cannot interact, the chain is stuck.

**Reproduction:**
1. Create mode: disguisedReminder -> holdButton -> callEmergency
2. Miss all reminders, chain advances to holdButton.
3. User is incapacitated and cannot hold button.
4. Chain never advances to callEmergency.

**Fix:** Either (a) add a timeout/auto-advance for holdButton when it's not step 0, (b) prevent holdButton from being placed at non-zero positions, or (c) document this as intentional.

---

### 4.4 MEDIUM -- hardwareButton step blocks the chain similarly to holdButton

**File:** `lib/features/session/session_engine.dart:195-197`

The `hardwareButton` step type emits `stepStarted` and then waits for external input (hardware button press detected by `HardwareButtonService`). If the hardware button service fails to detect presses (e.g., the phone doesn't support it, or the service crashes), the chain is stuck.

**Impact:** Same as 4.3 -- chain gets permanently stuck if hardware detection fails.

---

### 4.5 LOW -- Two events cannot fire simultaneously (confirmed safe)

Dart is single-threaded with an event loop. All timer callbacks and stream events are processed sequentially. The `sync: true` on the broadcast `StreamController` (line 63) means events are delivered synchronously within the callback. Since `_cancelAllTimers()` is called at each phase transition, at most one timer is active per phase at any time. **No two events can fire simultaneously.**

---

### 4.6 LOW -- All state transitions are valid (confirmed safe)

The engine's state transitions follow a strict pattern:
- `start()` -> `_executeStep(0)` -> `stepStarted`
- Each step type follows its specific phase chain
- `_advanceToNext()` -> `stepAdvancing` -> `_executeStep(next)` -> `stepStarted`
- Chain end -> `chainExhausted`
- `endSession()` -> `sessionEnded`
- `disarm()` -> `userDisarmed` -> `_executeStep(0)` -> `stepStarted`

All transitions check `_ended` first. The `_cancelAllTimers()` call prevents stale timers from firing after a transition. No impossible transitions exist.

---

## 5. Escalation Step List Edge Cases

### 5.1 MEDIUM -- Grace period slider minimum is 3 seconds, but seed data has gracePeriodSeconds=0

**File:** `lib/features/escalation/escalation_step_list.dart:316-319, 324-327`

The `LogarithmicSlider` for grace period has `min: 3`. But the Walk Mode seed data creates holdButton with `gracePeriodSeconds: 0` and callEmergency with `gracePeriodSeconds: 0`. When the user opens these steps in the editor, the slider clamps 0 to its minimum of 3, displaying 3s instead of the actual 0s. If the user saves without changing anything, the grace period silently changes from 0 to 3.

**Impact:** Built-in mode behavior changes after the user views and saves a step's configuration, even without intentional modification.

---

### 5.2 LOW -- Reorder callback adjusts _expandedIndex but can leave it stale

**File:** `lib/features/escalation/escalation_step_list.dart:160-174`

When reordering, if a non-expanded item is moved, `_expandedIndex` is set to null. This collapses the currently expanded step, which is functional but may surprise the user.

---

## Summary of Findings by Severity

| Severity | Count | IDs |
|----------|-------|-----|
| CRITICAL | 2     | 1.1, 4.1 |
| HIGH     | 4     | 1.2, 2.1, 2.2, 2.3, 4.2 |
| MEDIUM   | 8     | 1.3, 1.4, 2.4, 2.5, 2.6, 3.2, 4.3, 4.4, 5.1 |
| LOW      | 6     | 1.5, 1.7, 1.8, 2.7, 3.3, 3.4, 3.5, 4.5, 4.6, 5.2 |

### Top Priority Fixes

1. **4.1** (CRITICAL) -- Fix holdButton UI countdown to use `durationSeconds` instead of `gracePeriodSeconds`
2. **1.1** (CRITICAL) -- Fix CallEmergencyStrategy double-duration race with engine timer
3. **2.3** (HIGH) -- Clear screen flash on step advance
4. **2.1/2.2** (HIGH) -- Warn or prevent session start when contacts/contactId not configured
5. **1.4** (MEDIUM) -- Reset `_isHolding` in disarm()
6. **2.6** (MEDIUM) -- Check `isCancelled` in PhoneCallContactStrategy retry loop
