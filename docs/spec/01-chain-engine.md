> **Normative status:** This document is NORMATIVE. In case of conflict
> with any other document (decisions log, audits, reviews), this document
> takes precedence. Key words "MUST", "SHOULD", "MAY" follow RFC 2119.

# 01 - Chain Engine Specification

## Overview

The chain engine is a **pure Dart state machine** that walks through a list of `ChainStep` objects in order. It has zero Flutter dependencies — only `dart:async` and `dart:math`. All interaction with Flutter (UI, services, navigation) is handled by the `SessionController` which wraps the engine.

The engine drives the core safety session lifecycle: walking the chain of events, escalating automatically when the user fails to respond to interactive steps, and coordinating with platform services (notifications, alarms, SMS, calls).

---

## Core Concepts

### Chain

An ordered list of `ChainStep` objects. Immutable once started — steps don't change, only the execution position advances through the chain.

Every step in the chain is on equal footing — there is no special "check-in" slot. The first step simply runs first. A typical chain orders its steps from "low-key, requires user response" to "loud / automatic":

- An interactive step such as `holdButton` or `disguisedReminder` near the front: the user can disarm by responding.
- Increasingly urgent steps later (`fakeCall`, `loudAlarm`, `smsContact`, `phoneCallContact`, `countdownWarning`, `callEmergency`) that fire automatically when earlier steps elapse without disarm.

Nothing in the model labels any step as "the check-in" — order alone determines what runs when.

### Three-Phase Timing Model

Every step has **three sequential phases**:

```
┌─────────────┐     ┌──────────┐     ┌──────────────┐
│  Wait Time  │ ──► │ Duration │ ──► │ Grace Period │ ──► Advance/Repeat
│ (optional)  │     │ (active) │     │  (dead time) │
└─────────────┘     └──────────┘     └──────────────┘
```

1. **Wait Time** (`waitSeconds`): Delay before the event fires.
   - **disguisedReminder**: the interval between confirmed check-ins (e.g., 30 min). Also the initial delay before the first reminder.
   - **holdButton**: N/A — user-driven, no timer.
   - **All others**: 0 (fires immediately).

2. **Duration** (`durationSeconds`): How long the event actively runs.
   - **fakeCall**: how long the call rings (e.g., 30s)
   - **loudAlarm**: how long the alarm plays (e.g., 30s)
   - **disguisedReminder**: how long the reminder overlay stays visible (e.g., 60s)
   - **countdownWarning**: the countdown length (e.g., 10s)
   - **smsContact**: time allowed to send (e.g., 15s)
   - **phoneCallContact**: time allowed to initiate call (e.g., 15s)
   - **callEmergency**: confirmation countdown (e.g., 5s)
   - **holdButton**: the visible countdown length (e.g., 10s) — displayed while user holds button

3. **Grace Period** (`gracePeriodSeconds`): Dead time after the event ends, before advancing or repeating.
   - Event has stopped (alarm silent, call ended, reminder gone, countdown done).
   - User can still disarm during this window.
   - Typically 5–10s.
   - After grace expires: either advance to next step (if no repeats left) or repeat the step.
   - **On first execution**: wait → duration → grace.
   - **On retries**: duration → grace (wait is skipped on retries; see Repeat Config section).

### Repeat Config

- `retryCount`: defines the number of retries allowed on a step.
  - **retryCount = 0**: single attempt only → grace expires → advance to next step.
  - **retryCount = 1**: 1 retry allowed → 2 total attempts (initial + 1 retry).
  - **retryCount = 2**: 2 retries allowed → 3 total attempts.
  - **retryCount = N**: N retries → N+1 total attempts.

- **Miss counting**: Each grace period that expires without disarm counts as one miss.
  - On first execution: wait → duration → grace expires → miss 1.
  - On retry: duration → grace expires → miss counted → repeat.
  - After `retryCount` misses → advance to next step.

- **Universal retry timing rule**: The `wait` phase only executes on FIRST execution of a step (when advancing to it). On ALL retries: `duration → grace → miss → repeat`. This applies to ALL step types universally.

- **Miss count state**: Per-step, resets to 0 when:
  - Step is advanced to (via `_advanceToNext()`).
  - User disarms (via `disarm()`).

- **Disarm always resets**: `disarm()` resets the entire chain to step 0 AND clears miss count.

### Timing Refactor: Disguised Reminders

For `disguisedReminder`, the `waitSeconds` field serves **double duty**:
- It is both the **initial delay** before the first reminder fires.
- AND the **interval between confirmed check-ins** — after user successfully checks in, the timer resets to `waitSeconds`.

No separate `repeatIntervalSeconds` config key is needed.

**Disguised reminder lifecycle:**
```
Wait (30 min) → reminderFired event → Duration (60s, overlay visible) → Grace (5s)
    ↓ (user checks in during wait, duration, or grace)
Reset to Wait (30 min)
    ↓ (grace expires without check-in)
Miss count++, retry fires IMMEDIATELY (skip wait, go straight to duration → grace)
    ↓ (after retryCount misses)
Advance to next step
```

**Retry timing after miss:** When a check-in is missed (grace expires without disarm), the retry fires immediately — it skips the wait phase and goes directly to duration → grace. This follows the universal retry timing rule: the wait phase only executes on the FIRST execution of a step. The full wait interval only applies between *confirmed* check-ins, not between missed retries. This ensures rapid escalation when the user is unresponsive (e.g., incapacitated on a date) rather than waiting another 30 minutes per retry.

### Randomization (Jitter)

When `randomize=true` on a step (or per-field config flags), apply ±20% jitter to timing values.

**Formula**: `factor = 0.8 + random.nextDouble() * 0.4` (range 0.8–1.2)

**Per-field config keys** (checked first; fall back to blanket `step.randomize`):
- `randomizeInterval`: applies to `waitSeconds` (e.g., disguisedReminder intervals)
- `randomizeRingDuration`: applies to `durationSeconds` (fakeCall only)
- `randomizeDuration`: applies to `durationSeconds` (all other types)
- `randomizeGrace`: applies to `gracePeriodSeconds`

**Application order**:
1. Read configured value (e.g., 30s wait).
2. Apply randomization if enabled: `randomized = 30 * factor` (e.g., 24–36s).
3. Apply speed multiplier: `adjusted = randomized / speedMultiplier`.

### Speed Multiplier

Divides all durations to simulate fast-forward. Useful for testing and demonstration.

- **Formula**: `adjusted_duration = duration / speedMultiplier`
- **Default**: 1.0 (no change)
- **Restriction — Simulation Only**: Only available in simulation mode. Real sessions MUST enforce 1.0x.
  - Engine MUST reject `setSpeedMultiplier(v)` where `v != 1.0` when `isSimulation == false`.
  - Reject NaN, Infinity, and negative values.
  - Clamp valid values to [0.01, 1000.0].
- **In-app simulation**: 1x–1000x via logarithmic slider and preset buttons.
- **Background simulation**: 1x–60x (notification rate limiting above 60x).
- **Timing**: applied at timer creation, and rescaled on running timers.
  - Changing the multiplier mid-session immediately rescales the running timer's remaining duration proportionally.

### Interactive Step Types

Two step types are *interactive* — the user can disarm the chain by responding to them:

1. **`holdButton`** — User touches and holds the screen while the step is active.
2. **`disguisedReminder`** — User taps / interacts with the fake notification overlay while the step is active.

Both trigger `disarm()`, which resets the chain to step 0 and re-runs the first step. Either type can appear anywhere in the chain; placing one first gives the chain a familiar "user-prompted" feel, while a chain with no interactive steps escalates automatically end-to-end.

### Hardware Button — Triple Role

The hardware button (typically volume button) has three distinct roles:

1. **Disarm shortcut when `hardwareButton` is the running step**: pressing the configured button counts as the user response — triggers disarm (reset to step 0).

2. **Chain step at any position**: The `hardwareButton` can appear as a regular step in the chain at any position, awaiting a button press to advance.

3. **Global panic trigger**: Available at ANY step, minimum **5 presses** within a time window. Acts as an escalation tool — fires the mode's distress chain (see § Distress Chain section). When both a hardwareButton chain step AND a distress trigger are configured in the same mode, the trigger system takes priority.

**Minimum press count**: 5 presses (not fewer) to minimize accidental triggers from pocket jostling or adjusting volume.

Detection and routing is handled by platform-specific service (`HardwareButtonService`); the engine provides `advanceFromHardwarePanic()` and `jumpToStep(index)` methods.

---

## ChainStep Data Model

```dart
final class ChainStep {
  final String id;              // UUID
  final ChainStepType type;     // One of 9 types
  final int order;              // Position in chain (0-indexed)
  final int durationSeconds;    // How long event actively runs
  final int gracePeriodSeconds; // Dead time after event, before
                                // advance/repeat
  final int retryCount;         // 0 = no retry, N = retry N times
  final int waitSeconds;        // Time before event fires. For
                                // disguisedReminder: interval
                                // between reminders.
  final double randomize;       // Jitter factor in [0, 1]; 0 = no
                                // jitter, 1 = full ±20% range.
  final StepConfig? config;     // Typed per-step config (sealed
                                // hierarchy); null = inherit from
                                // EventDefaults.forType(type).
}
```

`randomize` is a `double` so the UI can expose a "how much jitter" slider rather than a binary on/off — the legacy boolean form was widened to allow gradual jitter control.

**ChainStepType enum** (9 types):

| Type | Description |
|------|-------------|
| `holdButton` | User holds the screen to prove presence; releasing during the active phase counts as a disarm. Interactive step type. |
| `disguisedReminder` | Fake notification overlay prompts the user; tapping it counts as a disarm. Interactive step type. |
| `countdownWarning` | Visual countdown (e.g., "Emergency in 10s"). Warning before serious action. |
| `fakeCall` | Phone rings with caller ID spoofed to trusted contact. User can decline to restart or answer to disarm. |
| `smsContact` | Sends SMS to a configured emergency contact with location/message. |
| `phoneCallContact` | Auto-initiates call to emergency contact. Operator can be briefed in advance (e.g., "Ask for Angela" campaign). |
| `loudAlarm` | Device plays loud alarm sound. Disarmable by swiping slider or tapping stop button. |
| `callEmergency` | Calls 999/911/112 emergency number. Requires explicit confirmation before placing call. |
| `hardwareButton` | Awaits physical device button press (e.g., volume button). Advances chain or jumps to target step. |

---

## State Machine

The engine walks through a linear state machine:

```
Idle → Step0_Wait → Step0_Duration → Step0_Grace → [advance or repeat]
       → Step1_Wait → Step1_Duration → Step1_Grace → [advance or repeat]
       → ...
       → StepN_Grace → Exhausted
```

**Key transitions:**

- **User disarms** (any phase) → reset to Step0_Wait, clear miss count.
- **Grace expires with repeats left** → restart same step (same wait → duration → grace cycle).
- **Grace expires with no repeats left** → advance to next step.
- **Last step's grace expires** → `chainExhausted`, session ends.

### Hold Button State Machine (User-Driven)

`holdButton` is unique — it's **not timer-driven on entry**. Instead, the engine waits for the user to call `holdStart()` and `holdRelease()`:

```
Session starts, step 0 = holdButton
  ↓ emit stepStarted(holdButton)
  ↓ Show "Touch to begin" prompt
  ↓ Wait for user touch

holdStart() called
  ↓ _isHolding = true
  ↓ User is holding. Holding state visible in UI.
  ↓ Cancel any pending timers (sensitivity, duration).

holdRelease() called
  ↓ _isHolding = false
  ↓ Start sensitivity timer (e.g., 1.0s, from step config 'releaseSensitivity')

During sensitivity window:
  If holdStart() called again
    ↓ Brief release detected (< 1s)
    ↓ Cancel sensitivity timer, ignore release
    ↓ Resume holding (no escalation)
  Else (sensitivity expires without re-hold)
    ↓ Start duration timer (countdown display, e.g., 10s)
    ↓ **Visible countdown shown:** large prominent number (e.g., "10" → "9" → "8"...)
       with circular progress indicator. This is the user's visual warning that they
       must re-hold or the chain will escalate. Countdown occupies the primary area
       of the session screen for maximum visibility.

During duration countdown:
  If holdStart() called
    ↓ User re-held. Cancel countdown, resume holding.
    ↓ No escalation yet.
  Else (countdown expires)
    ↓ Start grace timer (e.g., 5s)
    ↓ Grace: user can re-hold to disarm
    ↓ Screen shows neutral state (countdown done)

During grace:
  If holdStart() called
    ↓ User re-holds during grace
    ↓ **Disarm triggered** → reset to step 0
  Else (grace expires)
    ↓ Advance to next step (escalation)
```

**Key design points:**

- **Sensitivity window**: Brief releases (<1s) are ignored — avoids accidental escalation from finger twitch.
- **Countdown duration**: Visible countdown (e.g., 10s) happens during the "duration" phase. The countdown MUST tick every second (`"10" → "9" → "8" → ... → "1"`), updating the UI in real time so the user knows exactly how long they have. See "Countdown Timer Implementation" below.
- **Grace period**: After countdown, user has a dead time (e.g., 5s) to re-hold and disarm.
- **Re-hold in grace**: Holding during grace is a disarm action (reset to step 0), not just cancelling escalation.
- **Holding state**: `isHolding` property visible in UI so user knows they're safe while holding.

#### Countdown Timer Implementation

The `SessionController` MUST drive the visible countdown with a **periodic `Timer` that fires every 1 second**, independent of engine phase-transition events (which only fire on state changes, not on every tick). The implementation requirement:

1. When the engine emits a `durationStarted` event for a `holdButton` step, `SessionController` starts a `Timer.periodic(Duration(seconds: 1), ...)`.
2. On each tick, the controller reads the remaining duration from the engine and updates the UI state.
3. The timer is cancelled when the engine emits `durationEnded`, `stepDisarmed`, or any session-terminating event.
4. The UI renders the remaining seconds as a **large centered number** inside a circular progress indicator that drains from full to empty as the countdown progresses.
5. The engine is the source of truth for timing; the periodic timer is a UI-polling mechanism only — it never mutates engine state.

### Disguised Reminder State Machine (Repeating Checks)

```
Step starts (step.type = disguisedReminder)
  ↓ emit stepStarted
  ↓ Start wait timer (waitSeconds, e.g., 30 min)

Wait fires
  ↓ _onReminderFired() called
  ↓ emit reminderFired event
  ↓ Show notification overlay (fake reminder)
  ↓ Start duration timer (durationSeconds, e.g., 60s)

Duration fires
  ↓ Overlay disappears
  ↓ Start grace timer (gracePeriodSeconds, e.g., 5s)

During duration or grace:
  User checks in (via overlay button or explicit disarm)
    ↓ disarm() called
    ↓ emit userDisarmed event
    ↓ Reset to step 0, clear miss count
    ↓ End of session (step 0 entered)

Grace expires without check-in
  ↓ _missedRepeats++ (count a miss)
  ↓ emit repeatMissed event (missCount, step)
  ↓ Check: _missedRepeats > retryCount?
    If NO: restart step (skip wait → duration → grace)
    If YES: advance to next step
```

**Example (retryCount = 2):**
- Attempt 1: wait → fire → duration → grace expires → miss 1
- Attempt 2 (retry): fire → duration → grace expires → miss 2
- Attempt 3 (retry): fire → duration → grace expires → miss 3 (> retryCount 2) → advance

---

## General Step Execution (fakeCall, loudAlarm, smsContact, etc.)

All non-holdButton, non-disguisedReminder, non-hardwareButton steps follow the same pattern:

```
Step starts
  ↓ emit stepStarted
  ↓ Check if waitSeconds > 0
    If YES: start wait timer
    If NO: skip to duration immediately

Wait fires (only on FIRST execution of step; skipped on retries)
  ↓ Start duration timer (event actively running)

Duration fires
  ↓ Event ends (alarm silent, call ended, SMS sent, etc.)
  ↓ Start grace timer (dead time)

During grace:
  User disarms
    ↓ disarm() called
    ↓ Reset to step 0
  Grace expires without disarm
    ↓ Check: step.retryCount > 0 and _missedRepeats < step.retryCount?
      If YES: increment miss count, restart step (duration → grace cycle, skipping wait)
      If NO: advance to next step
```

**Universal retry rule**: The `wait` phase only executes on the FIRST execution of a step (when advancing to it). On retries: `duration → grace → miss counted → repeat`. This applies to ALL step types universally, not just disguisedReminder.

---

## Fake Call Lifecycle

The fake call step has a **two-phase interaction model**:

```
Ring → Answer → Voice plays (engine timer keeps running) → User hangs up → DISARM
Ring → Decline → declineIsSafe? disarm : miss (restartCurrentStep)
Ring → Decline (5s hold) → DISTRESS CHAIN triggered
Ring → Timeout → miss
```

### Fake Call Methods

```dart
void answerFakeCall()
```
- Called when user answers the fake call.
- **Pivot 2 — fakeCall is event, not pause.** The engine timer keeps
  running while the voice clip plays — `FakeCallScreen` is a route
  push, not a pause-and-overlay. This method is a no-op at the
  engine level; the UI layer performs the navigation and audio
  playback. Rationale: pausing on every fake call would create gaps
  in the escalation that an attacker could exploit by quickly
  declining/answering to delay the chain.
- Does NOT disarm — the chain is not ended.

```dart
void hangUp()
```
- Called when user hangs up after answering or during call.
- Fires disarm (resets chain to step 0).
- Used after voice recording ends (no auto-hang-up timeout).

### Decline Behavior

When a user declines (does not answer) a fake call:

- **declineIsSafe = true** (default): Decline = disarm (reset to step 0). User is saying "I'm fine."
- **declineIsSafe = false**: Decline = miss. Call rings again per retryCount.

The `declineIsSafe` flag is per-mode configurable on `FakeCallConfig`.

### Decline with Distress (5-Second Hold)

Holding the Decline button for 5 seconds (configurable, advanced setting) triggers the mode's distress chain:
- Visual feedback: progress ring on Decline button.
- Haptic feedback at 800ms into the hold.
- After 5s: distress chain replaces current chain, executes immediately.

### Real Phone Call During Fake Call (Extra-24/25)

If a real incoming phone call arrives while the fake call is active:
- The fake call is silently cancelled (ringtone/vibration stops).
- The real phone call proceeds normally (not intercepted).
- When the real call ends, the session auto-disarms silently.
- **Rationale:** The user now has a genuine excuse to be on the phone — the fake call's cover story has served its purpose. Auto-disarming avoids further escalation.

### Real Phone Call During holdButton Step (Extra-30/31)

If a real incoming phone call arrives while a `holdButton` step is active:
- The session automatically pauses (same as `pause()` method).
- The hold-button countdown is suspended.
- When the real call ends, the session automatically resumes from the exact point of interruption.
- **Rationale:** The user cannot hold the screen button while on the phone. Pausing prevents false escalation during an expected interruption.

---

## Real Phone Call Detection (A2)

When the user is in an active session and a real phone call arrives:

- **Android:** `PhoneStateListener` detects incoming call. Session automatically pauses.
- **iOS:** CXCallObserver detects incoming call (when audio is active).
- **Behavior:** Chain timers are suspended (same as `pause()` method). When the call ends, the session automatically resumes from the exact point of interruption.
- **User experience:** User receives the incoming call notification normally. Handling the real call doesn't trigger any session actions. When the call ends, session continues as if no interruption occurred.
- **Pause reason:** `PauseReason.incomingCall` is recorded so the UI can show "Session paused: incoming call" instead of the generic "Paused" message.
- **Exception — fake call active:** When the current step is `fakeCall` and a real call arrives, the fake call is cancelled rather than pausing. See § Fake Call Lifecycle — Real Phone Call During Fake Call (Extra-24/25) above.

---

## Timing Configuration

All non-holdButton steps support the `waitSeconds` field:

- For reminder steps (`disguisedReminder`): `waitSeconds` is the interval between confirmed check-ins AND the initial delay before the first reminder.
- For all other steps: `waitSeconds` defaults to 0 (fires immediately) but is configurable per step.
- All steps also support `durationSeconds`, `gracePeriodSeconds`, and `retryCount` for full timing control.

---

## Engine API

### Constructor

```dart
SessionEngine({
  required List<ChainStep> chainSteps,
  bool isSimulation = false,
  double speedMultiplier = 1.0,
  Random? random,
  DateTime Function()? clock,
  Duration? maxPauseDuration,
})
```

| Parameter | Default | Notes |
|-----------|---------|-------|
| `chainSteps` | — | List of steps to execute in order. Must not be empty. |
| `isSimulation` | `false` | If `true`, enables simulation mode (`leap`, `jumpToStep`, mid-run `setSpeedMultiplier`). |
| `speedMultiplier` | 1.0 | Divides all durations. Real sessions MUST be `1.0` — non-1.0 throws `ArgumentError`. Clamped to `[0.01, 1000.0]`. NaN / infinity / non-positive values throw. |
| `random` | `Random()` | Randomizer for jitter. Pass deterministic instance for testing. |
| `clock` | `DateTime.now` (via `package:clock`) | Wall-clock source. Pass a fake to drive tests. |
| `maxPauseDuration` | `null` | When non-null, pausing starts a timer; on expiry the engine emits `pauseExpired` and auto-resumes. `null` disables auto-resume. |

### State Accessors

```dart
int get currentStepIndex;              // Current step index, or -1 if not started
ChainStep? get currentStep;            // Current step, or null if not started or ended
bool get isEnded;                      // True if endSession() called
bool get isHolding;                    // True if user is currently holding (holdButton only)
bool get isSimulation;                 // True if simulation mode enabled
bool get isPaused;                     // True if pause() called, not yet resumed
Stream<ChainEventData> get events;     // Event stream
```

### Lifecycle Methods

```dart
void start()
```
- Begin session execution.
- Sets `currentStepIndex = 0` and executes the first step.
- **Fail-loud**: Calling `start()` on an already-running engine throws an error. Not a silent no-op.
- Emits `stepStarted` for step 0.

```dart
void endSession()
```
- Clean shutdown.
- Cancels all timers.
- Transitions immediately to `EngineEnded`.
- Emits `sessionEnded` event.
- No further events after this.
- Fire-and-forget: Already-dispatched SMS/calls in WorkManager still deliver. The engine doesn't wait or block them.
- Idempotent.

### Hold Button Methods

```dart
void holdStart()
```
- Called when user begins holding the screen.
- **Guard**: no-op if current step is not `holdButton`.
- **Edge-triggered**: no-op if already holding (prevents timer storms from rapid tapping).
- Sets `_isHolding = true`.
- If in grace phase, triggers disarm (re-hold in grace = disarm).
- Otherwise, cancels sensitivity and duration timers.

```dart
void holdRelease()
```
- Called when user releases the screen.
- **Guard**: no-op if current step is not `holdButton`.
- **Edge-triggered**: no-op if not currently holding (prevents timer storms from rapid tapping).
- Sets `_isHolding = false`.
- Starts sensitivity timer (from step config `releaseSensitivity`, default 1.0s).
- If user re-holds before sensitivity fires, release is ignored.
- If sensitivity fires, starts duration countdown.
- **Cancel and restart on re-release (D1):** If the user releases again during the duration countdown (after the sensitivity window has expired), the countdown is cancelled and restarted from the full duration. This allows the user to "cancel" a mis-release by immediately releasing and re-holding, without committing to an escalation. Specifically:
  - `holdStart()` during duration → countdown pauses (holding).
  - `holdRelease()` during duration → countdown cancels; sensitivity timer starts fresh; if sensitivity fires → full duration countdown restarts from beginning.

### Disarm / Check-in

```dart
void disarm()
```
- **Re-arms the chain to step 0 — does NOT end the session.**
- Clears miss count (`_missedRepeats = 0`).
- Emits `userDisarmed` event carrying the step index the user was on at the moment of disarm (so the log records *where* the user re-armed from).
- Re-executes step 0.
- **No-op outside `EngineRunning`** — callers must `resume()` a paused engine first to make the disarm effective.
- **PIN requirement**: If PIN configured for session-end, execution pauses, PIN prompt shown. Correct PIN → disarm proceeds. Timeout → action blocked, escalation continues.
- **To end the session**, callers fire `endSession(reason: ...)` explicitly — `disarm()` never sets `EngineEnded`.

```dart
void checkIn()
```
- Alias for `disarm()`. Used by `SessionController` and the disguised-reminder UI to express the "I'm safe" intent. Re-arms the chain to step 0 (does NOT advance to the next step).

### Early Check-in for Disguised Reminder (D4)

```dart
void earlyCheckIn({required bool resetOnEarlyCheckIn})
```
- Called when the user taps the disguised-reminder notification **during the wait phase** (before the reminder has fired).
- **Guard — step type**: No-op if the current step is not `disguisedReminder`.
- **Guard — engine state**: No-op if the engine is not in `EngineRunning`.
- **Guard — phase**: Only acts during the **wait phase**. No-op during duration or grace.
- **Behavior when `resetOnEarlyCheckIn = true`** (default): Calls `disarm()` — resets to step 0. This is the user proactively checking in early.
- **Behavior when `resetOnEarlyCheckIn = false`**: No-op — the early tap is ignored and the existing wait timer continues. The reminder fires at the original scheduled time.
- **Rationale (D4):** Lets mode designers choose whether tapping a reminder notification early counts as a valid check-in (reset cycle) or should be ignored (reminder fires on schedule regardless of the early tap).

### Disarm During Grace (Extra-46)

Grace is always a disarm window regardless of `retryCount`. When a user disarms during any step's grace period:
- `disarm()` is called normally.
- The chain resets to step 0.
- No "late disarm" penalty applies.

### Fake Call Methods

```dart
void answerFakeCall()
```
- Called when user answers the fake call.
- **Pivot 2 — fakeCall is event, not pause.** The engine timer keeps
  running while the voice clip plays — `FakeCallScreen` is a route
  push, not a pause-and-overlay. This method is a no-op at the
  engine level; the UI layer performs the navigation and audio
  playback. Rationale: pausing on every fake call would create gaps
  in the escalation that an attacker could exploit by quickly
  declining/answering to delay the chain.
- Does NOT disarm — the chain is not ended.

```dart
void hangUp()
```
- Called when user hangs up after answering.
- Fires disarm (resets chain to step 0).
- No auto-hang-up timeout — user manually hangs up.

```dart
void restartCurrentStep()
```
- Restart the current step after waiting the grace period.
- Used when user declines a fake call (when `declineIsSafe=false`).
- **Preserves miss count** — miss count continues to accumulate across restarts.
- Applies grace period duration, then re-executes the same step.

### Hardware Panic

```dart
void advanceFromHardwarePanic()
```
- Advance to the next step.
- Called when hardware panic button (e.g., volume button) is detected.
- Does NOT disarm — escalation happens instead.

```dart
void jumpToStep(int index)
```
- Jump directly to a specific step index.
- Called when hardware panic is configured with a target step.
- Resets miss count to 0.
- Re-executes the target step.

### Pause / Resume

```dart
void pause()
```
- Suspend all active timers immediately.
- Stop ALL active audio, vibration, and camera flash immediately.
- Save the current timer phase (wait/duration/grace/sensitivity) and remaining time.
- Configurable maximum pause duration per mode (default: unlimited). If configured and exceeded, show notification "Session paused for X minutes."
- No-op if already paused or ended.
- Triggered from notification action (pause button) or in-app UI.

```dart
void resume()
```
- Resume after a `pause()`.
- Restart the previously active timer phase with exact remaining duration.
- No grace reset, no buffer — if 3 seconds of grace remained, 3 seconds remain after resume.
- No-op if not paused or ended.
- Timer restoration is deterministic — same remaining time resumes exactly.

**Special case: Real phone call detection**
When a real incoming phone call is detected during an active session:
- Session automatically pauses (same behavior as `pause()` method).
- When the call ends, the session automatically resumes from the exact point of interruption.
- This is transparent to the user — no additional action required.

**No resume after force-close (Extra-13):**
If the app process is killed by the OS or the user (force-stop, OOM kill):
- The session does NOT automatically resume on next launch.
- On next app launch, a "Session interrupted" prompt is shown, giving the user the option to manually resume or dismiss.
- **Rationale:** Automatic silent resumption after a process kill could restart escalation at an unexpected moment (e.g., minutes or hours later). The user must consciously decide to continue. The Android foreground service uses `START_STICKY` to survive normal backgrounding; force-close is an explicit user or OS action that breaks this contract.
- **iOS:** App kill is detected only at next launch (no AlarmManager watchdog). Behaviour is identical — prompt on next launch.

**Pause/resume use cases:**
- User receives foreground notification with pause action.
- User minimizes app during session.
- Fake call screen is displayed (optional pause).
- Real incoming phone call received (automatic pause/resume).

### Simulation

```dart
void leap()
```
- **Simulation mode only** — fires the active timer immediately, collapsing the remaining duration of the current phase to zero.
- Throws `StateError` if `isSimulation == false`.
- No-op when not `EngineRunning` (idle, paused, ended).

```dart
void jumpToStep(int index)
```
- **Simulation mode only** — jump directly to a specific step index.
- Throws `StateError` if `isSimulation == false`.
- Throws `StateError` if not `EngineRunning` (use `start` for the initial entry).
- Throws `RangeError` if `index` is out of range.
- Resets miss count to 0 and re-executes the target step.

```dart
void setSpeedMultiplier(double value)
```
- **Simulation mode only** — adjust speed multiplier mid-run.
- Throws `StateError` on non-simulation engines.
- Throws `ArgumentError` on NaN, infinity, or non-positive values.
- Clamped to `[0.01, 1000.0]`.
- Currently-scheduled timers keep their original wall-clock deadlines; the new multiplier applies to every phase scheduled after the call.

```dart
void setBackgroundClamp(bool value)
```
- **Simulation mode only** — engages a 60× cap on the *effective* speed multiplier when the OS pushes the simulation app into the background. The stored `speedMultiplier` is left untouched; `effectiveSpeedMultiplier` returns `min(speedMultiplier, 60)` while engaged. No-op for real (non-simulation) sessions — real timers are already wall-clock-driven.
- **Layer ownership (G-013):** `SessionController` (the Riverpod layer that wraps the engine) observes `AppLifecycleState` via `WidgetsBindingObserver`. On `AppLifecycleState.paused` or `AppLifecycleState.hidden` it calls `engine.setBackgroundClamp(true)`; on `AppLifecycleState.resumed` it calls `engine.setBackgroundClamp(false)`. The engine itself has no Flutter dependency and cannot read lifecycle — the controller is the single owner of this signal. The foreground cap remains 1000× (the engine's `speedMultiplier` clamp range `[0.01, 1000.0]`); the background cap is 60× applied via `setBackgroundClamp`.

---

## Events Emitted

The engine emits the following events on its broadcast event stream:

```dart
enum ChainEvent {
  sessionStarted,        // A new session just started.
  stepStarted,           // A step entered its duration phase.
  stepAdvancing,         // A step's grace phase expired and the
                         // engine is advancing.
  graceExpired,          // A step's grace phase expired before the
                         // user responded.
  repeatMissed,          // A disguised-reminder retry fired with no
                         // response.
  reminderFired,         // A disguised-reminder step entered its
                         // duration phase — overlay is now visible.
  pauseExpired,          // A pause exceeded `maxPauseDuration` and
                         // the engine auto-resumed.
  stepExecutionFailed,   // A strategy's `executeReal` threw; emitted
                         // by the orchestrator's error-isolation
                         // catch (D-STRATEGY-2). The chain itself
                         // keeps running.
  distressTriggered,     // Distress trigger fired; the engine
                         // replaced the main chain with the distress
                         // chain.
  distressCompleted,     // Distress chain finished.
  sessionPaused,         // Session was paused.
  sessionResumed,        // Session was resumed from pause.
  userDisarmed,          // User disarmed/checked-in: chain was
                         // reset to step 0 without ending the
                         // session.
  deceptiveOldPinShown,  // Wrong PIN entered while
                         // `AppSettings.deceptivePinDialogEnabled` is
                         // true — the "Old PIN entered" dialog (spec
                         // 04 §DeceptiveOldPinDialog) was shown.
                         // metadata['attemptCount'] = post-increment
                         // wrong-PIN counter value.
  sessionEnded,          // Session ended (any reason).
}

final class ChainEventData {
  final ChainEvent event;
  final DateTime timestamp;
  final int? stepIndex;            // Index into the active chain
                                   // (null = chain-level event).
  final ChainStepType? stepType;   // Step type the event refers to.
  final Map<String, Object?> metadata;
}
```

**Event stream**: Broadcast stream — multiple listeners OK. Synchronous so listeners see events in the order emitted without microtask latency (essential for deterministic test assertions). Closed when the engine is disposed.

**Notes:**
- Distress chains are integrated into the main engine as chain replacements, not separate entities.
- `pauseExpired` is emitted by the engine when the constructor's `maxPauseDuration` is non-null and a pause exceeds it; the engine auto-resumes immediately afterwards.
- `stepExecutionFailed` is emitted by the orchestrator (`emitStepExecutionFailed`) when a strategy's `executeReal` throws, so callers can isolate strategy errors from engine state. The chain keeps running.

---

## Sealed EngineState

The engine uses a sealed class hierarchy for state management (no boolean soup):

```dart
sealed class EngineState {}

final class EngineIdle extends EngineState {}

final class EngineRunning extends EngineState {
  int stepIndex;
  TimerPhase phase;       // wait, duration, grace, holdWait,
                          // sensitivity
  Duration remaining;
  int missCount;
  bool isHolding;
}

final class EnginePaused extends EngineState {
  EngineRunning snapshot;   // Frozen running state
  PauseReason reason;
}

final class EngineEnded extends EngineState {
  EndReason reason;
}

enum PauseReason {
  userRequested,        // The UI / user explicitly requested a pause.
  incomingCall,         // Incoming phone call detected; engine pauses
                        // so audio does not bleed into the call.
                        // Auto-resumes when the call ends.
  bootRestart,          // App relaunched after backgrounding long
                        // enough that recovery-dialog flow is needed
                        // (D-ENGINE-22 — no auto-resume).
}

enum EndReason {
  disarm,               // User-initiated disarm (I'm safe / session-end
                        // PIN / GPS arrival).
  chainExhausted,       // Last chain step completed successfully.
  hardwarePanic,        // Hardware panic trigger fired; distress chain
                        // completed.
  duressPin,            // Duress PIN entered; distress chain completed.
  wrongPinExhausted,    // Wrong-PIN threshold hit; distress chain
                        // completed.
  userQuit,             // User quit the session (app-level termination
                        // path).
  appTermination,       // Application termination without an in-progress
                        // recovery dialog.
}
```

State transitions are exhaustive via `switch` expressions on the sealed type.

---

## Foreground Service Notification

While a session is active, the engine drives a persistent notification displayed by the platform:

### Normal Mode

- **Title**: "Guardian Angela is active"
- **Body**: Mode name (e.g., "Walk Mode", "Date Mode")
- **Action button**: "I'm Safe" (triggers `disarm()`)
- **Customizable button text**: From session mode config (default "I'm Safe")

### Stealth Mode

- **Title**: Disguised text (e.g., "Music playing", "Fitness tracking")
- **Body**: Blank or non-safety text
- **Action button**: "Pause" (triggers `disarm()`)
- **Customizable button text**: From stealth settings (e.g., "⏸", "Skip")
- **Icon**: Neutral preset icon (e.g., music player icon, not a shield)

**Notification disarm behavior:**
- If **Session End PIN is configured**: tapping the notification action brings the app to foreground and shows a PIN prompt with the standard `ImSafeSlider`. The user must swipe the slider and enter the PIN to disarm.
- If **no PIN is configured**: tapping the notification action brings the app to foreground and shows the `ImSafeSlider`. The user must swipe the slider to disarm.
- Works from any step, any phase, even when app is backgrounded.

**Stealth notification label:** When stealth mode is active, the action button label is disguised to match the fake app persona (e.g., "Mark as read", "Remind me later", "Skip") instead of "I'm Safe". Controlled by `StealthConfig.notificationDisguise`.

**Additional actions** (optional, platform-dependent):
- "Pause" / "Resume" — toggles `pause()` and `resume()`.
- Quick disarm — direct action without opening app.

---

## Pause / Resume Deep Dive

### Pause State Capture

When `pause()` is called:

1. Record which timer phase is currently active (wait, duration, grace, or sensitivity).
2. Calculate elapsed time since phase started.
3. Calculate remaining time = total duration − elapsed.
4. Save: phase, remaining duration, current step.
5. Cancel all active timers.

### Resume Restoration

When `resume()` is called:

1. Retrieve saved phase and remaining duration.
2. Restart that specific phase with the remaining duration.
3. Clear pause state.
4. Continue normally.

**Example:**
- Grace timer started with 5s total.
- Paused after 2s → remaining = 3s.
- Resumed → restart grace timer with 3s.
- When grace expires → process as normal (advance/repeat).

### Invariant

Resume is **deterministic** — same paused state always resumes to the same remaining time. No loss of accuracy between pause and resume.

---


## Session Start Validation

Before starting a session, the app should validate:

1. **Required permissions granted**: notification always required; others based on chain steps.
   - SMS/call permissions if chain includes `smsContact` / `phoneCallContact`.
   - Audio permission if chain includes `loudAlarm`.
   - Location permission if any step sends location.

2. **Emergency contacts configured**: if chain includes `smsContact` / `phoneCallContact`.
   - Error: "No emergency contact set. Add contact in Settings > Emergency Contacts."

3. **Required apps installed**: if chain uses messaging channels (WhatsApp, Telegram).
   - Error: "WhatsApp not installed. Install to use WhatsApp escalation."

4. **Emergency number set**: if chain includes `callEmergency`.
   - Error: "Emergency number not configured. Set in Settings > Emergency."

5. **Battery optimization whitelisted** (warn, don't block):
   - Warning: "Battery optimization may interrupt session. Whitelist app in Settings?"

**Validation failure**: show dialog with specific issues and action buttons ("Add Contact", "Edit Mode", "Back").

---

## Non-Blocking Event Execution

Each event action (`executeReal()`) is wrapped with a configurable timeout (default 30s):

- **Timeout**: If action takes > 30s, log failure, continue to next phase.
- **Exception**: If action throws, log failure, continue.
- **Config**: Per-step `nonBlockingOnFailure` toggle (default true).
  - If true: failures don't block chain advancement.
  - If false: failures may block (reserved for critical actions like `callEmergency`).

**Example**: SMS contact fails to send → logged as failure → grace period continues → chain advances on time. User not left hanging.

### Action Delivery Verification

Every real action (SMS, phone call, emergency call) MUST log its **outcome** in `SessionLogEvent`, not just "attempted":

- `"sms_sent"` — successfully handed to OS for delivery
- `"sms_queued"` — queued in WorkManager (no signal), pending
- `"sms_failed"` — OS rejected the send (invalid number, permission denied)
- `"call_initiated"` — dialer opened / call placed
- `"call_failed"` — OS rejected (no signal, permission denied)

The session log detail screen MUST show per-action success/failure status. Users MUST be able to see whether their emergency contacts were actually reached.

### Network Status Awareness

The session screen SHOULD show a network status indicator (signal strength icon or connectivity status). If the device has no cellular signal when an SMS/call step fires, the session log MUST record `"no_signal"` alongside the queued/failed status.

### Pre-Session Checks

Before starting any session:
1. **Battery warning:** If battery < 20%, show warning: "Low battery. Session may be interrupted if phone dies."
2. **Permission audit:** Verify all permissions required by the mode's chain steps are still granted. If any revoked, show dialog with specific issues and action buttons.
3. **Network check:** If no cellular signal, warn: "No signal. SMS and calls may not work."

### Simulation Safety Guards

Simulation mode MUST be enforced at **two independent levels**:
1. **Controller level:** `SessionController` checks `isSimulation` before calling any strategy's `executeReal()`
2. **Service level:** Each service method (`MessagingService.sendToAll()`, `PhoneService.callEmergency()`, etc.) MUST accept an `isSimulation` parameter and no-op when true

This defense-in-depth prevents accidental real actions even if one guard is bypassed.

---

## Distress Chain (Replacement)

When any distress trigger fires, the main chain is **stopped and discarded**. The selected distress mode's chain becomes the active chain. There is no return to the main chain.

### Distress Mode Selection (Pivot 3 — distress is a Mode)

Distress chains are not a separate model. A **distress mode** is a regular `SessionMode` with `isDistressMode = true`; the runtime treats its `chainSteps` as the distress chain. Each `SessionMode` carries a `distressModeId` field — the id of the distress mode whose chain should fire when a distress trigger hits this mode. `null` means "use `AppDefaults.defaultDistressModeId`"; if that is also null, the mode blocks at session start (validation error). Distress modes are managed in the UI under `/distress-modes` (see spec 04).

### Three Triggers — Same Result

All three triggers fire the **SAME selected distress chain** — no per-trigger customization:

1. **Hardware panic** (5× volume button press) — fires the selected distress chain
2. **Wrong PIN threshold** (default 5 consecutive failures) — fires the selected distress chain (A3)
3. **Duress PIN** — user enters their secret duress PIN at any prompt; fires distress chain silently

All three use the same code path: `engine.replaceWithDistressChain(steps)`. There is no per-trigger chain configuration.

#### Wrong PIN Auto-Trigger (A3)

After a configurable number of consecutive wrong PIN attempts (default: 5), the distress chain is triggered automatically:
- The UI shows the same response as an incorrect PIN (no visible difference to the attacker).
- The distress chain fires silently in the background.
- The wrong-PIN counter resets after a successful unlock.
- **Rationale:** Prevents an attacker from guessing the PIN indefinitely. After N wrong attempts the phone appears to continue behaving normally, but escalation has already begun.

#### Duress PIN During Active Distress Chain (A4)

If the user enters the duress PIN **while a distress chain is already executing**:
- The input is a no-op. The distress chain is **not** reset or re-triggered.
- The UI shows the normal duress-PIN response (fake "session ended").
- **Rationale:** The distress chain is already running; restarting it would discard in-progress escalation steps (e.g., an SMS already queued). A second duress-PIN entry is most likely a repeat press rather than a meaningful new trigger.
- **Implementation:** `SessionController` checks `engine.isDistressChain` before calling `triggerDistress()`. If already in distress, the duress PIN input is silently swallowed.

### Distress Confirmation Window

After a distress trigger fires, a **5-second configurable confirmation window** is shown before the distress chain begins executing:
- Display: "Distress activated — tap to cancel"
- During this window, the user can cancel if they triggered accidentally.
- If PIN is configured for session-end, canceling requires PIN entry (standard 15s timeout).
- Correct PIN → cancellation proceeds, session continues normally.
- Timeout or no action → after 5s, distress chain starts.
- Confirmation UI respects stealth mode (no app branding, disguised appearance).

**Biometric branch (`distressCancelBiometricEnabled = true`):** The cancel prompt accepts either PIN or biometric (Q18). Biometric is shown first; failure or cancel falls through to PIN entry within the same 15s timeout window. The biometric path is opt-in and has no effect when the flag is `false`.

**Rationale**: Prevents false positives from accidental volume button presses while maintaining rapid escalation in real emergencies.

### Battery Alert (One-Shot Side Action)

**Not** a chain replacement. When battery drops below threshold: fire a one-shot notification and optional SMS alert. The main chain continues uninterrupted. Default: OFF.

### Distress Chain Mechanics

- **Architecture**: Uses the same `SessionEngine` with `replaceWithDistressChain(steps, triggerReason: ...)` — the engine clears current steps and starts from step 0 of the distress chain. The trigger reason is propagated to `sessionEnded.endReason` (one of `hardwarePanic`, `duressPin`, `wrongPinExhausted`).
- **No return**: Once distress fires, the main chain steps are gone. The engine ends with the matching `EndReason` (`hardwarePanic` / `duressPin` / `wrongPinExhausted`) when the distress chain completes.
- **Step types**: Both main and distress chains can contain any of the 9 step types. No restrictions.
- **After completion**: UI shows a fake "session ended" screen (to fool an attacker in the duress scenario).
- **Event logging**: Distress trigger event logged to `SessionLog` with trigger type.

---

## Invariants

1. **currentStepIndex** always in range [−1, chainSteps.length).
   - −1 if not started.
   - [0, chainSteps.length−1] if active.
   - chainSteps.length−1 if last step executing.

2. **disarm()** always resets to step 0 and clears miss count, regardless of current step or phase.

3. **endSession()** is idempotent — calling multiple times is safe.

4. **No events after endSession()** — event stream closed, no further emissions.

5. **Speed multiplier** applies to ALL timers (wait, duration, grace, sensitivity).
   - Changing mid-session rescales the running timer immediately.
   - ≤ 0 returns original duration unchanged (safety fallback).

6. **Session timer starts on user interaction**, not on `start()`.
   - For `holdButton`: starts on first `holdStart()` or `holdRelease()`.
   - For `disguisedReminder`: starts on `start()` (wait timer immediately begins).

7. **Only one session active at a time** — ensured by `SessionController` (not engine invariant, but platform invariant).

8. **Distress chain replaces main chain** — main chain stops permanently; distress chain runs to completion.

9. **Pause state is deterministic** — same paused state always resumes to exact remaining time.

10. **Hold button behavior**:
    - `holdStart()` / `holdRelease()` no-op on non-holdButton steps.
    - Re-hold during grace phase triggers disarm (not just cancelling escalation).
    - Brief releases (<sensitivity window) ignored.

11. **Miss count per-step** — resets when step advances or user disarms.

12. **No step content changes mid-session** — steps immutable after `start()`.

13. **Disarm during distress is per-mode configurable (G-014)** — when the engine is running a distress chain (entered via `replaceWithDistressChain`), it checks the active mode's `allowDisarmAsDistress` flag. If `true` (default), `disarmTriggers` (`GpsArrivalDisarmTrigger`, `TimerDisarmTrigger`) fire normally. If `false`, the engine ignores them and the chain runs to exhaustion. Hardware-button distress, duress PIN, and wrong-PIN threshold continue to be the only paths INTO distress; this invariant only controls whether disarm can take you OUT.

---

## Randomization Details

### When Randomization Applies

Randomization is applied **per-field** at the moment the timer is created:

1. Check if per-field config flag is true (e.g., `randomizeInterval`).
   - If yes: apply ±20% jitter.
   - If no: check blanket `step.randomize` flag.
2. If blanket flag true: apply ±20% jitter.
3. Apply speed multiplier to the (possibly randomized) duration.

### Randomization Formula

```
factor = 0.8 + random.nextDouble() * 0.4     // range [0.8, 1.2]
jittered_duration = original_duration * factor
```

**Example** (waitSeconds = 1800s with randomize=true, speedMultiplier=10):
1. Jittered: 1800 * (0.8 to 1.2) = 1440 to 2160 seconds.
2. Speed-adjusted: (1440 to 2160) / 10 = 144 to 216 seconds.

### Per-Field Config Keys

Checked in `_shouldRandomize()`:

| Config Key | Applies To | Example Step |
|------------|-----------|--------------|
| `randomizeInterval` | `waitSeconds` | disguisedReminder |
| `randomizeRingDuration` | `durationSeconds` | fakeCall |
| `randomizeDuration` | `durationSeconds` | loudAlarm, countdownWarning, smsContact |
| `randomizeGrace` | `gracePeriodSeconds` | Any step |

---

## Example Chains

### Walk Mode

```
Step 0: holdButton (interactive — user holds the button to disarm)
  waitSeconds: 0
  durationSeconds: 10 (countdown visible)
  gracePeriodSeconds: 1
  retryCount: 0

Step 1: fakeCall (fake incoming call)
  waitSeconds: 0
  durationSeconds: 30 (call rings)
  gracePeriodSeconds: 5
  retryCount: 0 (1 attempt only)

Step 2: smsContact (send to emergency contacts)
  waitSeconds: 0
  durationSeconds: 15 (send time)
  gracePeriodSeconds: 5
  retryCount: 0

Step 3: phoneCallContact (call emergency contact)
  waitSeconds: 0
  durationSeconds: 60
  gracePeriodSeconds: 5
  retryCount: 0

Step 4: callEmergency
  waitSeconds: 0
  durationSeconds: 5 (confirmation countdown)
  gracePeriodSeconds: 0
  retryCount: 0
```

### Date Mode

```
Step 0: disguisedReminder (interactive — periodic prompt disguised as app notification; tap to disarm)
  waitSeconds: 1800 (30 min intervals)
  durationSeconds: 60 (reminder overlay visible)
  gracePeriodSeconds: 120
  retryCount: 1 (2 total attempts)

Step 1: fakeCall (fake incoming call from trusted contact)
  waitSeconds: 0
  durationSeconds: 30 (call rings)
  gracePeriodSeconds: 5
  retryCount: 0 (1 attempt only)

Step 2: smsContact (send to emergency contacts)
  waitSeconds: 0
  durationSeconds: 15 (send time)
  gracePeriodSeconds: 5
  retryCount: 0

Step 3: phoneCallContact (actual call to emergency contact)
  waitSeconds: 0
  durationSeconds: 60 (time to place call)
  gracePeriodSeconds: 5
  retryCount: 0 (1 call attempt)

Step 4: callEmergency
  waitSeconds: 0
  durationSeconds: 10
  gracePeriodSeconds: 0
  retryCount: 0
  config: showConfirmation=true
```

---

## Testing and Simulation

### Deterministic Randomization

For testing, pass a deterministic `Random` instance that always returns 0.5:

```dart
final testRandom = _FixedRandom(); // returns 0.5
final engine = SessionEngine(
  chainSteps: testSteps,
  isSimulation: false,
  random: testRandom,
);
```

This eliminates jitter variation, making tests predictable:
- jitter factor = 0.8 + 0.5 * 0.4 = 1.0 (no actual jitter).

### Simulation Mode

In simulation mode (`isSimulation=true`):
- `leap()` available — fires the active timer immediately, collapsing the remaining duration of the current phase to zero. Surfaced in the simulation UI as the "Leap" button.
- Speed bar UI allows user to set multiplier (1x–1000x) via a logarithmic slider.
- Preset speed stops: **1x**, **2x**, **5x**, **10x**, **20x**, **50x**, **100x**, **500x**, **1000x**.
- Default speed: 1x (real-time). User can drag to any value or tap preset stops.
- Useful for demos and testing long chains quickly.

### Test Helpers

```dart
// Factory to create ChainStep with sensible defaults
ChainStep _step({
  required ChainStepType type,
  int waitSeconds = 0,
  int durationSeconds = 10,
  int gracePeriodSeconds = 5,
  int retryCount = 0,
  bool randomize = false,
}) {
  return ChainStep(
    id: const Uuid().v4(),
    type: type,
    order: 0,
    waitSeconds: waitSeconds,
    durationSeconds: durationSeconds,
    gracePeriodSeconds: gracePeriodSeconds,
    retryCount: retryCount,
    randomize: randomize,
    config: null,
  );
}
```

### Test Patterns

Use `fakeAsync()` wrapper for timer testing:

```dart
test('grace period expires, advance to next', () {
  fakeAsync((async) {
    final engine = SessionEngine(
      chainSteps: [
        _step(type: ChainStepType.loudAlarm),
        _step(type: ChainStepType.callEmergency),
      ],
      random: _FixedRandom(),
    );

    engine.start();
    async.flushMicrotasks();
    expect(engine.currentStepIndex, 0);

    async.elapse(const Duration(seconds: 15)); // duration + grace
    expect(engine.currentStepIndex, 1);

    engine.endSession();
  });
});
```

---

## Integration with SessionController

The `SessionController` (Riverpod Notifier) wraps the `SessionEngine` and:

1. **Manages lifecycle**: calls `engine.start()`, `engine.endSession()`.
2. **Listens to events**: subscribes to `engine.events` stream.
3. **Persists state**: logs events to `SessionLog` via repository.
4. **Coordinates services**: calls platform service methods (play alarm, send SMS, etc.) in response to events.
5. **Updates UI**: emits controller state changes (e.g., `WalkSession` updates) for screens to rebuild.

**Event → Action mapping**:
- `stepStarted` → log event, show UI for step type.
- `reminderFired` → show notification overlay.
- `repeatMissed` → log miss, update badge count.
- `stepAdvancing` → trigger action service (e.g., play alarm).
- `userDisarmed` → show confirmation, log session.
- `chainExhausted` → show end screen (or silent exit in stealth mode).
- `sessionEnded` → clean up foreground service, release resources.

---

## Glossary

See `09-glossary.md` for the single canonical glossary covering every term used across the spec set.

