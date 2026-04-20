# Engine Logic Review: State Machine Completeness, Race Conditions, Missing Transitions

Reviewer: Claude Opus 4.6 (1M context) -- state machine & concurrency specialist
Date: 2026-04-11
Scope: Spec 13 (v2, normative), Spec 01 (chain engine), Spec 12 (rewrite decisions)
Focus: Logical contradictions, race conditions, missing state transitions

---

## 0. Document Hierarchy and Contradictions Between Specs

Before analyzing the engine, the three normative documents contradict each
other on the fundamental architecture of distress/sub-chains. This must be
resolved before implementation.

### CONTRADICTION C0-1: Distress chain as "replacement" vs "sub-chain"

**Spec 13 (v2) section 4.2:** "When triggered, the main chain is **stopped
and discarded**. The distress chain becomes THE active chain. No going back
to the main chain."

**Spec 12 section "Sub-Chains":** "Sub-chains are internal to the main engine.
The main engine tracks sub-chain state in `EngineSubChainActive`." Sub-chains
"pause the main chain, execute independently, then return."

**Spec 12 section "Sealed EngineState":** Defines `EngineSubChainActive`
with `mainSnapshot: EngineRunning` -- implying the main chain state is
preserved for later restoration.

These are mutually exclusive designs:

- Spec 13 says: **replace**. Main chain is gone. `EngineEnded` when distress
  completes. `EndReason.distressCompleted`.
- Spec 12 says: **pause-and-return**. Main chain snapshot preserved.
  `EngineSubChainActive` holds both states.

**Spec 13 supersedes** (per its normative status header). This means:

1. `EngineSubChainActive` is the WRONG state for distress chains. Distress
   should transition the engine to `EngineRunning` with the distress chain
   steps loaded, discarding the main chain entirely.
2. The `mainSnapshot` field in `EngineSubChainActive` is dead weight for
   distress -- there is no "return to main."
3. `EngineSubChainActive` may still be needed for battery alerts (spec 12
   describes battery chain as pause-and-return), but spec 13 section 4.3
   redesigns battery as a "one-shot side action" that "does NOT interrupt
   or replace the main chain." This eliminates the sub-chain model for
   battery too.

**Resolution needed:** Remove `EngineSubChainActive` entirely. The engine
has four states: `Idle`, `Running`, `Paused`, `Ended`. Distress triggers
swap the chain steps and reset to step 0 within `Running`. Battery alert
is a fire-and-forget action outside the engine entirely.

### CONTRADICTION C0-2: Sub-chain allowed step types vs "any step in any chain"

**Spec 12:** "Only allowed step types in sub-chains: smsContact,
phoneCallContact, loudAlarm, callEmergency, countdownWarning."

**Spec 13 section 4.4:** "Both main and distress chains can contain any of
the 9 step types. No restrictions."

Spec 13 supersedes. The distress chain allows all 9 step types.

### CONTRADICTION C0-3: start() behavior

**Spec 01:** "Idempotent -- calling multiple times is a no-op."
**Spec 12 & 13:** "Calling start() on an already-running engine throws."

Spec 13 supersedes. `start()` must throw on double-call.

### CONTRADICTION C0-4: Distress triggers -- advance vs replace

**Spec 12 "Distress Triggers":** "Actions that ESCALATE the chain. Advance
by 1 step (or jump to specific step)."

**Spec 13 section 4.2:** "THREE triggers, same result: [...] The main chain
is stopped and discarded. The distress chain becomes THE active chain."

Spec 12 describes distress as a chain-advancement mechanism. Spec 13 describes
it as a complete chain replacement. These cannot both be true.

**Resolution:** Under spec 13, all three distress triggers (hardware panic,
wrong PIN threshold, duress PIN) replace the main chain with the distress
chain. They do not "advance by 1 step."

---

## 1. State Machine Completeness

### 1.1 Canonical states (per spec 13 section 3.12)

```
EngineIdle       -- constructed, not started
EngineRunning    -- active session (stepIndex, phase, remaining, etc.)
EnginePaused     -- timers suspended (snapshot + reason)
EngineEnded      -- terminal (userTerminated | chainExhausted | distressCompleted)
```

### 1.2 Method validity matrix

Every public method must have defined behavior for every state. "X" means
the method should have an effect. "-" means no-op or throw.

| Method                     | Idle    | Running | Paused  | Ended   |
|----------------------------|---------|---------|---------|---------|
| `start()`                  | X       | THROW   | THROW   | THROW   |
| `endSession()`             | -[1]    | X       | X       | -       |
| `holdStart()`              | -       | X[2]    | -[3]    | -       |
| `holdRelease()`            | -       | X[2]    | -[3]    | -       |
| `disarm()`                 | -[1]    | X       | X[4]    | -       |
| `checkIn()`                | -[1]    | X       | X[4]    | -       |
| `answerFakeCall()`         | -       | X[5]    | -       | -       |
| `hangUp()`                 | -       | X[6]    | -       | -       |
| `declineFakeCall()`        | -       | X[5]    | -       | -       |
| `restartCurrentStep()`     | -       | X       | -       | -       |
| `advanceFromHardwarePanic()` | -     | X       | -[7]    | -       |
| `jumpToStep(n)`            | -       | X       | -       | -       |
| `pause()`                  | -       | X       | -       | -       |
| `resume()`                 | -       | -       | X       | -       |
| `leapToNextEvent()`        | -       | X[8]    | -       | -       |
| `setSpeedMultiplier(v)`    | X[9]    | X       | X       | -       |
| `dispose()`                | X       | X[10]   | X[10]   | X       |
| `triggerDistressChain()`   | -       | X       | ?[11]   | -       |

Notes:
- [1] `disarm()`, `checkIn()`, `endSession()` from Idle must be no-op or
  throw. Previous audit found `disarm()` from Idle starts the engine -- BUG.
- [2] Only meaningful when current step is `holdButton`. No-op otherwise.
- [3] Spec says pause stops everything. Hold events during pause are no-ops.
- [4] Disarm from Paused: spec 13 says "disarm is ALWAYS possible from any
  state." This should unpause + disarm. But this needs careful definition
  (see finding F1-1).
- [5] Only meaningful during fakeCall step's duration phase.
- [6] Only meaningful while fake call is answered (chain paused by
  answerFakeCall).
- [7] Hardware panic during pause -- UNDEFINED (see finding F1-2).
- [8] Simulation only.
- [9] Can set before start, validated on start.
- [10] Should transition to Ended first, or at minimum cancel timers.
- [11] Distress trigger during pause -- CRITICAL UNDEFINED (see section 2).

### FINDING F1-1: Disarm from Paused state is under-specified

**Issue:** Spec 13 section 3.6 says disarm works from "ANY phase of ANY step
in ANY chain." Spec 13 section 3.12 defines `EnginePaused` as a state. Disarm
from Paused requires two atomic actions: (1) resume engine, (2) execute disarm
(reset to step 0). The order matters:

- Resume then disarm: a timer could fire in the microseconds between resume
  and disarm, causing a spurious event before the disarm takes effect.
- Disarm then resume: nonsensical -- disarm modifies Running state, but
  state is Paused.

**Required behavior:** Disarm from Paused must atomically transition:
`EnginePaused -> EngineRunning(step=0, phase=initial)` with no intermediate
timer ticks. Implementation: do NOT resume the paused timer. Instead, discard
the pause snapshot, reset to step 0, and start fresh. This avoids any race
between resume and disarm.

### FINDING F1-2: End session from Paused is under-specified

**Issue:** Same as F1-1 but for `endSession()`. Must transition directly:
`EnginePaused -> EngineEnded(userTerminated)` without resuming timers.
Cancel all timers, emit `sessionEnded`, close stream.

### FINDING F1-3: Missing transitions for hold button phases

Spec 01 defines four hold-button sub-phases: awaiting-first-touch, holding,
sensitivity, duration (countdown), grace. The sealed `EngineRunning` state
has `TimerPhase` which presumably covers wait/duration/grace but not
sensitivity or the "holding without timer" state.

**Required:** `TimerPhase` must include `sensitivity` as a distinct phase.
The "holding" state is tracked by `isHolding=true` on `EngineRunning` and
does not need its own `TimerPhase` value -- but there must be no active timer
while the user is holding. The current phase should be either none (no timer
running) or the cancelled timer's phase.

### FINDING F1-4: `EngineEnded` is terminal but `dispose()` is separate

Spec 01 says "No events after endSession()." But `dispose()` closes the
stream controller. If code calls `endSession()` followed by `dispose()`, the
stream is closed twice. If code calls `dispose()` WITHOUT `endSession()`,
no `sessionEnded` event is emitted but the stream closes. This inconsistency
can cause listener errors.

**Required:** `dispose()` must call `endSession()` if not already in
`EngineEnded` state, then close the stream controller. Make it idempotent.

---

## 2. Distress Chain Replacement

### 2.1 Timer cleanup on distress trigger

When `triggerDistressChain()` is called:

1. All running timers from the main chain MUST be cancelled.
2. All pause state MUST be discarded.
3. All sub-phase state (sensitivity timers, hold state) MUST be reset.
4. Miss count MUST be reset to 0.
5. Step index MUST be reset to 0 (of the distress chain).
6. The chain step list MUST be swapped to the distress chain steps.
7. The engine MUST emit an event indicating distress chain activation.

**FINDING F2-1: No event type for distress chain activation**

Spec 13 section 3.13 lists 10 events. None of them is "distressChainStarted"
or similar. Spec 12 defines `subChainStarted` and `subChainCompleted`, but
spec 13 eliminates sub-chains in favor of chain replacement.

**Required:** Add `distressChainStarted` to `ChainEvent`. Without this, the
UI/controller has no way to know the distress chain has activated (for logging,
UI changes like showing fake "session ended" screen).

### 2.2 Distress during pause

**Scenario:** User pauses session (manual or incoming call). While paused,
they press volume button 5x (hardware panic).

**FINDING F2-2: Distress during pause -- behavior undefined**

Spec 13 section 3.10 says pause stops everything. Section 4.2 says distress
triggers fire at "ANY step." But "any step" is ambiguous about "any state."

Three possible behaviors:
1. **Distress overrides pause:** Immediately unpause, swap to distress chain,
   start executing. This is consistent with "user is in danger NOW."
2. **Distress is queued until resume:** Dangerous -- user pressed panic, but
   nothing happens until they or the incoming call ends resume.
3. **Distress is ignored during pause:** Dangerous -- same problem.

**Required:** Option 1. Distress must override pause. The user pressed the
panic button -- they need help NOW. The engine should:
`EnginePaused -> EngineRunning(distress chain, step 0)` atomically.

But this raises a question about the incoming-call pause reason. If a real
phone call caused the pause, and the user presses volume 5x, the distress
chain starts while the user is on a real call. The engine should start
executing the distress chain (it runs timers), but some steps (loudAlarm,
fakeCall) would conflict with the active phone call. This is acceptable --
the steps that matter in distress (SMS, emergency call) are fire-and-forget
via WorkManager and do not require audio.

### 2.3 Distress during wait phase

**Scenario:** Date Mode, step 0 (disguisedReminder), currently in the 30-min
wait phase before the first reminder fires. User presses volume 5x.

**Analysis:** Straightforward. Cancel the wait timer, swap to distress chain,
start at step 0. No special handling needed. The wait timer is just a timer
like any other.

### 2.4 Distress during grace phase

**Scenario:** Any step, grace phase running (last chance before escalation).
User presses volume 5x.

**Analysis:** Straightforward. Cancel the grace timer, swap to distress chain.
The grace period was the user's last chance on the MAIN chain -- but they've
explicitly chosen to escalate beyond it.

### 2.5 Distress during active distress chain

**FINDING F2-3: Double distress trigger -- behavior undefined**

**Scenario:** User triggers distress (hardware panic). Distress chain starts.
While distress chain is running at step 1, user presses volume 5x again.

Possible behaviors:
1. **No-op (ignore):** The distress chain is already running. Another trigger
   is meaningless. This is safe and simple.
2. **Restart distress chain from step 0:** Potentially harmful -- resets
   progress through the distress chain.
3. **Advance distress chain by 1 step:** Useful -- user is VERY panicked and
   wants to skip ahead.

Spec 13 section 5.2 says "500ms cooldown between triggers." This addresses
accidental double-taps but not deliberate re-triggering minutes later.

**Recommended:** No-op. The distress chain is already the most aggressive
response. Re-triggering it does not add safety value and risks resetting
progress. However, spec 12's `advanceFromHardwarePanic()` method suggests
the volume button should ADVANCE the chain at any position. If the engine is
running the distress chain, a hardware panic could advance the distress chain
by 1 step (skip to the next distress step). This is potentially useful but
needs explicit specification.

**Decision required from spec author:** When the distress chain is already
active, does hardware panic: (a) no-op, (b) advance distress chain by 1 step,
or (c) restart distress chain?

### 2.6 Disarm during distress chain

**Spec 13 section 4.2:** "After distress chain completes: UI shows fake
'session ended' to fool an attacker (covers the duress scenario)."

**Spec 13 section 3.6:** "disarm() works from ANY phase of ANY step in ANY
chain. Always resets to step 0 and clears miss count."

**FINDING F2-4: Disarm during distress chain -- contradictory spec**

If `disarm()` resets to step 0 and clears miss count universally, then during
the distress chain, disarm resets to step 0 OF THE DISTRESS CHAIN (since the
main chain was discarded). This means:

- The distress chain starts over from step 0.
- The user (or attacker) can keep resetting the distress chain indefinitely.
- This is gated by PIN, so an attacker cannot disarm. But the legitimate
  user CAN disarm.

But wait -- should disarm during distress END the session instead? The main
chain is gone. "Reset to step 0" of the distress chain means re-running the
entire distress escalation. This seems wrong. If the user disarms during
distress, they are saying "I'm safe now." The correct response is to end the
session entirely.

**Resolution options:**
1. **Disarm during distress = end session.** Clean and logical. The user
   triggered distress, then said "I'm safe." Session over.
2. **Disarm during distress = reset distress chain to step 0.** Consistent
   with universal disarm behavior, but semantically weird.
3. **Disarm during distress = disallowed.** Violates spec 13 section 1.2
   ("user controls everything").

**Recommended:** Option 1. When the engine is running the distress chain,
`disarm()` should transition to `EngineEnded(userTerminated)`. PIN still
required. This aligns with "user controls everything" while not creating the
nonsensical "restart distress from step 0" behavior.

However, this is a deviation from the universal rule "disarm resets to step 0."
The spec author must approve.

### 2.7 Distress chain exhaustion

**Scenario:** Distress chain runs to completion (all steps exhausted).

**Spec 13 section 4.2:** "After distress chain completes: UI shows fake
'session ended' to fool an attacker."

**Spec 13 section 3.12:** `EndReason.distressCompleted`.

**Analysis:** When the distress chain exhausts, emit `chainExhausted`, then
transition to `EngineEnded(distressCompleted)`. The UI interprets
`distressCompleted` as "show fake ended screen." Clear and well-specified.

### 2.8 What if distressChainSteps is null/empty?

**Spec 12:** "If distressChainSteps is null or empty, hardware panic at the
last step is a no-op."

**But spec 13 says triggers fire at ANY step, not just the last.** If the
user has no distress chain configured and presses volume 5x at step 2 of 5,
what happens?

**FINDING F2-5: No distress chain configured -- all triggers are no-ops**

If `SessionMode.distressChainSteps` is null or empty, ALL distress triggers
must be no-ops, not just at the last step. There is no chain to swap to.

The engine should log this as a configuration issue. The session start
validation should warn: "Distress triggers are configured but no distress
chain is set up."

---

## 3. Fake Call + Distress Interaction

### 3.1 Fake call lifecycle recap

```
ring (duration phase) -> answer -> chain PAUSED -> voice plays -> hang up -> DISARM
ring (duration phase) -> decline -> declineIsSafe? disarm : miss
ring (duration phase) -> decline-hold-5s -> DISTRESS CHAIN
ring (duration phase) -> timeout -> miss -> grace -> advance/retry
```

Note: "chain PAUSED" after answering is a special pause. It is NOT the same
as `EnginePaused(manual)` or `EnginePaused(incomingCall)`. It is a
domain-specific pause that happens because the user is pretending to talk.
The engine state might still be `EngineRunning` with a special "fake call
answered" flag, or it might be `EnginePaused(fakeCallAnswered)`.

### FINDING F3-1: Fake call pause needs its own PauseReason

Spec 13 defines `PauseReason { manual, incomingCall }`. The fake call answer
pause is neither manual nor incoming call. It should be:
`PauseReason { manual, incomingCall, fakeCallAnswered }`.

Without a distinct reason, the UI cannot distinguish between "user paused
session" and "user answered fake call." The fake call screen must remain
visible during fakeCallAnswered pause; the regular pause UI must not.

### 3.2 Hardware panic during answered fake call

**Scenario:** User answers fake call (chain paused, fake call screen visible,
voice recording playing). User presses volume 5x.

**FINDING F3-2: Distress during fake call answer -- behavior undefined**

The chain is in a fake-call-answered pause state. The user has hit the panic
button. Options:

1. **Distress overrides fake call pause.** Dismiss fake call screen, swap to
   distress chain, start executing. The user is clearly in danger (they
   answered the fake call as cover, but then panicked).
2. **Ignore the hardware panic.** Dangerous -- user cannot escalate while
   on fake call.

**Required:** Option 1, same reasoning as F2-2. Distress always overrides
any pause. The fake call screen must be dismissed. The distress chain starts.

Implementation detail: the SessionController must listen for distress chain
activation events and pop the fake call screen from the navigation stack.

### 3.3 Hardware panic during fake call ring (not answered)

**Scenario:** Fake call is ringing (duration phase, waiting for user to
answer/decline/timeout). User presses volume 5x.

**Analysis:** The chain is in `EngineRunning` state, fakeCall step, duration
phase. Distress trigger fires. The engine should:
1. Cancel the duration timer (ring stops).
2. Swap to distress chain.
3. Start at distress step 0.

The fake call screen should be dismissed. The ringtone should stop.

### 3.4 Decline-hold-5s distress vs hardware panic distress

Spec 13 defines TWO ways to trigger distress from a fake call:
1. Hold decline button for 5 seconds.
2. Press volume 5x.

What if both happen simultaneously? The 500ms cooldown (spec 13 section 5.2)
should handle this -- the first trigger that fires activates the distress
chain, the second is a no-op because the distress chain is already active.

But if the decline-hold triggers FIRST and the distress chain has no steps
(empty/null), it is a no-op (F2-5). Then the volume press arrives and is also
a no-op. Both fail silently. This is a configuration error that should be
caught at session start validation.

---

## 4. PIN Timeout + Engine State

### 4.1 PIN dialog lifecycle

Per spec 13 section 1.3: PIN dialog appears for critical actions (disarm, end
session, Quick Exit). 15-second configurable timeout. Engine continues running
behind the dialog.

### FINDING F4-1: Step advancement during PIN dialog

**Scenario:** User tries to disarm. PIN dialog appears. While user is entering
PIN, the grace period expires and the engine advances to the next step.

The disarm action is gated behind the PIN. The engine does not know about the
PIN dialog -- it just keeps running. If the step advances before the PIN is
entered:

1. **PIN entered correctly after step advance:** The disarm still fires,
   resetting to step 0. The new step was briefly active but gets cancelled.
   This is correct -- the user proved they are the real user.

2. **PIN times out after step advance:** The disarm is blocked. The engine
   is now on a different step than when the PIN was requested. This is
   correct -- the dead man's switch worked.

**Key insight:** The PIN gate is a UI-layer concern. The engine has no
knowledge of PIN dialogs. The SessionController shows the PIN dialog, and
only calls `engine.disarm()` if the PIN succeeds within the timeout. The
engine continues running independently.

**No engine bug here.** But the UI must handle the case where the step has
changed between PIN request and PIN success. Specifically:

- If the user was disarming during an emergency call countdown, and the step
  advances to the actual emergency call while PIN is showing, the disarm
  should still work (cancel the call). But the call may have already been
  initiated (fire-and-forget).

### FINDING F4-2: Chain exhaustion during PIN dialog

**Scenario:** User tries to disarm at the last step. PIN dialog appears. While
entering PIN, the last step's grace expires. The chain exhausts. Engine
transitions to `EngineEnded(chainExhausted)`.

Now the user enters the correct PIN. The SessionController calls
`engine.disarm()`. But the engine is in `EngineEnded` state. `disarm()` on
`EngineEnded` should be a no-op (per the method validity matrix).

**Result:** The user entered the correct PIN, but the session has already
ended. The UI should handle this gracefully -- show "Session already ended"
instead of a confusing state. The PIN dialog should detect that the engine
state changed to `EngineEnded` while it was open and auto-dismiss.

**Required:** The PIN dialog widget should watch the engine state and dismiss
itself if the engine transitions to `EngineEnded` while the dialog is showing.

### FINDING F4-3: Distress trigger during PIN dialog

**Scenario:** User tries to disarm. PIN dialog appears. While entering PIN,
the hardware panic fires (volume 5x -- maybe by accident, or someone else
grabbed the phone).

The distress chain activates. The PIN dialog is still showing. Now what?

The PIN dialog was for a disarm action. But the context has changed completely
-- the engine is now running the distress chain. If the user completes the
PIN, `disarm()` fires on the distress chain. Per F2-4, this should end the
session.

**Required:** The PIN dialog should dismiss itself when the distress chain
activates (engine event `distressChainStarted`). The disarm request is
superseded by the distress escalation.

### FINDING F4-4: Multiple PIN dialogs

**Scenario:** User taps "End Session" -> PIN dialog appears. While entering
PIN, user taps "I'm Safe" (disarm) from the notification. Another PIN dialog
should NOT appear -- one PIN dialog at a time.

**Required:** The SessionController must track whether a PIN dialog is already
showing and reject duplicate PIN requests. The notification's "I'm Safe"
action should be queued or ignored while a PIN dialog is active.

---

## 5. Concurrent Triggers

### 5.1 Hardware panic + GPS arrival simultaneously

**Scenario:** The GPS geofence fires (user arrived at destination) at the
same time as the hardware panic button fires (5x volume press).

These are opposite actions:
- GPS arrival = disarm trigger (wants to end session)
- Hardware panic = distress trigger (wants to escalate to distress chain)

**FINDING F5-1: Conflicting simultaneous triggers**

Spec 13 section 5.2 specifies 500ms cooldown between distress triggers. But
there is no cooldown between distress and disarm triggers, and no priority
order between trigger types.

**Required resolution:**
1. Distress triggers MUST take priority over disarm triggers. If both fire
   within the same processing cycle, distress wins. Rationale: if the user is
   pressing the panic button, they are NOT safe, regardless of what GPS says.
2. Implementation: process distress triggers before disarm triggers in each
   event loop iteration. Use a single-threaded event queue.

### 5.2 Two timers expiring at the same microsecond

**Scenario:** Duration timer and some other scheduled callback (e.g., battery
check, trigger evaluation) fire at the same Dart event loop tick.

**Analysis:** Dart is single-threaded. Even if two timers are scheduled for
the same `DateTime`, they execute sequentially in the event loop. The first
timer callback completes before the second starts. There is no true
concurrent execution.

**However,** the ORDER of execution for two same-deadline timers is undefined
by the Dart specification (`Timer` makes no ordering guarantee for timers
scheduled at the same time).

**FINDING F5-2: Timer ordering is non-deterministic for same-deadline timers**

If a grace timer and a trigger evaluation timer fire in the same event loop
tick, the result depends on which the Dart VM processes first. Consider:

- Grace expires first -> step advances -> then trigger fires on the new step.
- Trigger fires first -> distress chain activates -> then grace timer fires
  on a cancelled timer (should be caught by state guards).

**Mitigation:** Every timer callback must check the current engine state
before acting. If the state has changed (e.g., engine ended, chain swapped),
the callback should be a no-op. This is a standard pattern and the existing
implementation's `_state is! EngineRunning` guards are correct.

**Recommendation:** Add an incrementing generation counter. Each time the
chain steps are swapped or the step index changes, increment the counter.
Timer callbacks capture the generation at scheduling time and bail if it has
changed when they fire. This is a lightweight, bulletproof guard against
stale timer execution.

### 5.3 Rapid hold/release events from gesture detector

**Scenario:** User's finger slips, generating rapid holdStart/holdRelease
events (e.g., 10 events in 100ms).

**Spec 13 section 3.7:** "holdStart() is no-op if already holding.
holdRelease() is no-op if not holding."

**Analysis:** Edge-triggering prevents timer storms. If the events arrive as
`start, release, start, release, start`, each toggles the `_isHolding` flag.
The sensitivity timer is started on each release and cancelled on each
re-hold. The final state depends on whether the last event was start or
release.

This is correct behavior. The sensitivity window (default 1s) absorbs the
noise -- as long as the user re-holds within 1s, no escalation occurs.

**No bug,** but the sensitivity timer must be properly cancelled on each
`holdStart()`. If the timer cancellation has any async delay, a race could
occur. In Dart, `Timer.cancel()` is synchronous and immediate. Safe.

### 5.4 endSession() called from two places simultaneously

**Scenario:** User taps "End Session" button AND the notification "End"
action fires at the same event loop tick (e.g., user tapped both).

**Analysis:** `endSession()` is idempotent (spec 13). The first call
transitions to `EngineEnded`. The second call checks state, sees `EngineEnded`,
returns immediately.

**No bug.** Idempotency handles this correctly.

---

## 6. Battery Alert as Side-Action

### 6.1 Spec 13 design

Battery alert is a one-shot side-action (section 4.3):
- Fires when battery drops below threshold.
- Sends notification to user, optional SMS to contacts.
- Does NOT interrupt or replace the main chain.
- Default: OFF.
- Fires once per session only.

### 6.2 Independence from engine

**FINDING F6-1: Battery alert is truly outside the engine**

Under spec 13, battery alert is NOT a chain, NOT a sub-chain, NOT an engine
concern. It is a service-level action:

1. `BatteryMonitorService` watches battery level.
2. When threshold crossed, it notifies the `SessionController`.
3. `SessionController` sends notification and optional SMS (via messaging
   service).
4. The engine is not involved. No state change. No events.

This is clean and correct. The battery alert has no interaction with the
engine state machine.

### 6.3 Battery alert during distress chain

**Scenario:** Distress chain is running. Battery drops to 5%.

**Analysis:** Battery alert fires its one-shot action (notification + SMS).
The distress chain continues uninterrupted. The SMS from the battery alert
is independent of the SMS steps in the distress chain. Both may send SMS to
the same contacts, but that is not a problem -- redundant notifications
during a real emergency are acceptable.

**No interaction issue.** The battery alert and engine are fully independent.

### 6.4 Battery alert during pause

**Scenario:** Session is paused. Battery drops below threshold.

**Analysis:** The battery monitor service is watching battery level
independently of the engine state. It fires regardless. The notification
and SMS go out. The engine remains paused.

**No interaction issue.** But the session log should record the battery alert
even during pause.

### 6.5 Battery alert fires once per session only

**FINDING F6-2: "Once per session" requires a flag in the SessionController**

The `BatteryMonitorService` might emit multiple low-battery events (battery
fluctuates around threshold). The `SessionController` must track a
`_batteryAlertFired` boolean and ignore subsequent events after the first.

This is a simple implementation detail but must not be overlooked. If the
flag is stored in the service, it survives session restarts (wrong -- should
reset per session). If stored in the controller, it resets correctly when a
new session starts.

---

## 7. Additional Edge Cases and Findings

### FINDING F7-1: Fake call answer -> hang up -> DISARM path bypasses PIN

Spec 13 section 3.4: "ring -> answer -> chain PAUSES -> voice plays -> hang
up -> DISARM." Section 3.6: "PIN required if configured."

When the user hangs up the fake call, does PIN get checked before disarming?
The spec says "hang up -> DISARM" but also says "PIN required if configured"
for disarm. These must be consistent.

**Required:** If PIN is configured, hanging up the fake call should trigger
the PIN dialog. Only on correct PIN does the disarm execute. On timeout, the
engine resumes from the paused state (fake call screen dismissed, chain
continues from where it was).

If PIN is NOT required, hang up directly disarms.

### FINDING F7-2: Quick Exit during distress chain

Spec 13 section 8.2: Quick Exit kills everything. Requires PIN.

During distress chain, Quick Exit is particularly sensitive. If the user
entered the duress PIN (which triggered the distress chain), and then tries
Quick Exit, the PIN dialog appears. Which PIN is required?

- The REAL PIN (since Quick Exit is a "trusted user" action).
- NOT the duress PIN (which is the "I'm under duress" signal).

**Analysis:** If the attacker forces the user to enter the duress PIN, the
distress chain runs. The attacker then tries Quick Exit (to destroy evidence).
Quick Exit requires the REAL PIN. The attacker does not know it. Quick Exit
fails. Distress chain continues.

**This is correct and well-designed.** But it must be explicitly documented:
Quick Exit always requires the REAL PIN, never the duress PIN.

### FINDING F7-3: Wrong PIN threshold during distress chain

Spec 13 section 4.2 lists "wrong PIN threshold" as a distress trigger. But
what if the distress chain is already running (triggered by hardware panic)
and someone enters wrong PINs?

Should wrong-PIN-threshold trigger distress again? Per F2-3, this would be a
double distress trigger. The distress chain is already active. The trigger
should be a no-op (or advance the distress chain by 1 step, per F2-3's
unresolved question).

### FINDING F7-4: Duress PIN during distress chain

Same pattern. If distress is already running (from hardware panic), and the
user enters the duress PIN, should it re-trigger distress? No -- distress is
already active. No-op.

### FINDING F7-5: `maxPauseDuration` enforcement

Spec 13 section 7.2: `SessionMode.maxPauseDuration` (null = unlimited).

When max pause duration is exceeded, what happens?

Options:
1. Auto-resume and continue the chain.
2. Auto-resume and disarm.
3. End session.

**FINDING:** The spec does not define the behavior when `maxPauseDuration`
is exceeded. The most safety-conscious option is (1): auto-resume. If the
user paused and forgot, the dead man's switch should re-engage.

**Required:** Spec must define max-pause-exceeded behavior. Recommendation:
auto-resume + emit `sessionResumed` event with a reason indicating timeout.

### FINDING F7-6: `leapToNextEvent()` during hold-button awaiting first touch

**Scenario:** Simulation mode. Step 0 is holdButton. Engine is waiting for
first touch. User presses "Leap to next event."

**Issue:** There is no active timer to leap past. The engine is in a
user-driven waiting state. `leapToNextEvent()` should either:
1. Be a no-op (no timer to accelerate).
2. Simulate a hold-and-release, triggering the sensitivity -> duration ->
   grace -> advance sequence.

**Recommended:** Option 2 for simulation UX. In simulation, "leap" should
skip the user-interaction requirement and advance to the next timer-driven
phase. Otherwise, users cannot simulate hold-button mode without physically
holding the screen.

### FINDING F7-7: Speed multiplier change during fake-call-answered pause

**Scenario:** Simulation mode. User answers fake call (chain paused). User
changes speed multiplier from 10x to 100x.

**Issue:** Chain is paused. No timer is running. The speed change is stored
but has no immediate effect. When the user hangs up and disarm fires, the
new speed applies to subsequent timers.

**No bug.** Speed changes during any pause state are stored and applied on
resume.

---

## 8. Summary of Findings by Severity

### Spec contradictions requiring resolution (BLOCKING)

| ID   | Issue | Resolution |
|------|-------|------------|
| C0-1 | Distress as replacement (13) vs sub-chain (12) | Follow 13: replace, remove EngineSubChainActive |
| C0-2 | Sub-chain step type restriction (12) vs any type (13) | Follow 13: any step type in distress chain |
| C0-4 | Distress advances chain (12) vs replaces chain (13) | Follow 13: replace, not advance |

### Critical design gaps (must resolve before implementation)

| ID   | Issue | Recommended |
|------|-------|-------------|
| F2-1 | No event for distress chain activation | Add `distressChainStarted` to ChainEvent |
| F2-2 | Distress during pause undefined | Distress overrides pause |
| F2-4 | Disarm during distress contradicts universal disarm | Disarm during distress = end session |
| F3-1 | Fake call pause needs distinct PauseReason | Add `fakeCallAnswered` to PauseReason |
| F3-2 | Distress during fake call answer undefined | Distress overrides fake call pause |
| F5-1 | Conflicting simultaneous triggers (GPS + panic) | Distress takes priority over disarm |

### Important design gaps (should resolve before implementation)

| ID   | Issue | Recommended |
|------|-------|-------------|
| F1-1 | Disarm from Paused under-specified | Atomic: discard snapshot, reset to step 0 |
| F1-2 | endSession from Paused under-specified | Direct transition, no resume |
| F1-3 | Hold-button sensitivity not in TimerPhase | Add `sensitivity` to TimerPhase |
| F1-4 | dispose() vs endSession() inconsistency | dispose() calls endSession() first |
| F2-3 | Double distress trigger behavior | Author decision: no-op or advance |
| F2-5 | No distress chain configured -> all triggers no-op | Validate at session start |
| F4-2 | Chain exhaustion during PIN dialog | PIN dialog watches engine state, auto-dismisses |
| F4-3 | Distress trigger during PIN dialog | PIN dialog dismisses on distressChainStarted |
| F4-4 | Multiple simultaneous PIN dialogs | Track and reject duplicates |
| F7-1 | Fake call hang-up may bypass PIN | PIN check required on hang-up disarm |
| F7-5 | maxPauseDuration exceeded behavior undefined | Auto-resume |

### Informational (no bug, but document)

| ID   | Issue | Status |
|------|-------|--------|
| F5-2 | Timer ordering non-deterministic | Mitigated by state guards + generation counter |
| F6-1 | Battery alert is outside engine | Correct by design |
| F6-2 | Battery alert once-per-session flag | Simple implementation detail |
| F7-2 | Quick Exit during distress uses REAL PIN | Correct, document explicitly |
| F7-3 | Wrong PIN threshold during distress | No-op (distress already active) |
| F7-4 | Duress PIN during distress | No-op (distress already active) |
| F7-6 | Leap during hold-button awaiting touch | Simulate hold-release in sim mode |
| F7-7 | Speed change during fake-call pause | No bug, speed stored for later |

---

## 9. Recommended State Machine (Corrected)

Based on spec 13 + all findings above:

```
sealed class EngineState
  EngineIdle
  EngineRunning {
    stepIndex: int,
    phase: TimerPhase,          // wait, duration, grace, sensitivity
    remaining: Duration,
    missCount: int,
    isHolding: bool,
    isAwaitingFirstTouch: bool,
    isDistressChain: bool,      // NEW: tracks which chain is active
  }
  EnginePaused {
    snapshot: EngineRunning,
    reason: PauseReason,        // manual, incomingCall, fakeCallAnswered
  }
  EngineEnded {
    reason: EndReason,          // userTerminated, chainExhausted, distressCompleted
  }

enum TimerPhase { wait, duration, grace, sensitivity }

enum PauseReason { manual, incomingCall, fakeCallAnswered }

enum EndReason { userTerminated, chainExhausted, distressCompleted }

enum ChainEvent {
  stepStarted,
  reminderFired,
  repeatMissed,
  stepAdvancing,
  userDisarmed,
  chainExhausted,
  sessionEnded,
  sessionPaused,
  sessionResumed,
  stepExecutionFailed,
  distressChainStarted,       // NEW
}
```

### Transition diagram

```
EngineIdle
  -> start()                     -> EngineRunning(step=0)
  -> endSession()                -> no-op (or throw)
  -> anything else               -> no-op

EngineRunning
  -> timer fires (phase advance) -> EngineRunning(same step, next phase)
  -> grace expires, retries left -> EngineRunning(same step, duration phase)
  -> grace expires, no retries   -> EngineRunning(next step, wait/duration)
  -> last step grace expires     -> EngineEnded(chainExhausted)
  -> disarm()                    -> EngineRunning(step=0) [if main chain]
                                    EngineEnded(userTerminated) [if distress]
  -> endSession()                -> EngineEnded(userTerminated)
  -> pause()                     -> EnginePaused(snapshot, reason)
  -> answerFakeCall()            -> EnginePaused(snapshot, fakeCallAnswered)
  -> triggerDistressChain()      -> EngineRunning(distress step=0, isDistress=true)
  -> dispose()                   -> EngineEnded(userTerminated) then close stream

EnginePaused
  -> resume()                    -> EngineRunning(from snapshot)
  -> disarm()                    -> EngineRunning(step=0) [main]
                                    EngineEnded(userTerminated) [distress]
  -> endSession()                -> EngineEnded(userTerminated)
  -> triggerDistressChain()      -> EngineRunning(distress step=0)
  -> hangUp() [if fakeCall]      -> [PIN check then] disarm flow
  -> dispose()                   -> EngineEnded(userTerminated) then close

EngineEnded
  -> any method                  -> no-op (except dispose which closes stream)
```

---

## 10. Implementation Recommendations

1. **Use a generation counter** for stale timer detection. Increment on every
   state transition. Timer callbacks check the generation and bail if stale.

2. **Track `_phaseStartedAt`** (DateTime) for accurate pause/resume. Compute
   remaining = scheduledDuration - (now - _phaseStartedAt). This was the #1
   bug in the previous implementation (C1 in phase2-engine-correctness.md).

3. **Store the chain steps as a mutable field** that can be swapped when
   distress triggers. The engine holds `List<ChainStep> _activeChain` and a
   `bool _isDistressChain`. `triggerDistressChain(List<ChainStep> steps)`
   swaps the list and resets.

4. **Single event queue** for all triggers. Process distress triggers before
   disarm triggers. Use the 500ms cooldown as a debounce, not as a queue.

5. **PIN dialog is a controller concern, not an engine concern.** The engine
   never knows about PIN. The SessionController intercepts disarm/endSession
   calls, shows PIN UI, and only calls the engine method on success.

6. **Fake call answer is a pause with a special reason.** Use
   `EnginePaused(fakeCallAnswered)` so the UI knows to show the call screen.
   `hangUp()` triggers resume + disarm (or PIN gate + disarm).

7. **Test all state combinations.** The method validity matrix (section 1.2)
   defines 17 methods x 4 states = 68 combinations. Each must have a unit
   test. Use `fake_async` and `_FixedRandom` per existing test conventions.
