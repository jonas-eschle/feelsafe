# Phase 2 Engine Correctness Review

**Scope:** `lib/domain/engine/session_engine.dart`, `engine_state.dart`,
supporting model types, checked against spec 12 (normative) and spec 01.

**Verdict:** 3 critical bugs, 4 significant issues, 5 minor issues.

---

## Critical Bugs

### C1. Pause/resume does not track elapsed time — restarts full phase

**Files:** `session_engine.dart` lines 383-397, 236-260

The `remaining` field in `EngineRunning` is set to the full phase duration
when a phase starts (`_startTimerForPhase` line 388) and is **never
decremented** as wall-clock time elapses. There is no `Stopwatch`,
`DateTime.now()` recording, or any other elapsed-time tracking.

When `pause()` captures the running state snapshot, it captures whatever
`remaining` was set at phase start — the full duration, not the actual
remaining time. On `resume()`, the timer restarts with the full duration.

**Example:** Grace timer started with 5s. Paused after 4s. Resume restarts
grace with 5s instead of 1s.

**Spec 12 reference:** "Resume with exact remaining time. No grace reset, no
buffer. If 3 seconds of grace remained, 3 seconds of grace remain after the
call."

**Impact:** Violates a core spec invariant. Real incoming phone calls during
a session would reset all timer progress, potentially delaying critical
escalation by the full phase duration.

**Fix:** Record `_phaseStartTime = DateTime.now()` when starting each phase.
Compute `remaining = phaseDuration - elapsed` dynamically, either via a
getter on the engine or by updating `remaining` when `pause()` is called.

### C2. `setSpeedMultiplier` rescale uses stale `remaining` — same root cause

**File:** `session_engine.dart` lines 294-301

`setSpeedMultiplier` reads `running.remaining` to rescale the active timer,
but `remaining` is the full phase duration (see C1). Changing speed mid-timer
restarts the full phase duration under the new multiplier instead of only
the actual remaining portion.

**Example:** 30s wait phase, 20s elapsed, user changes from 1x to 10x.
Expected: 1s remaining at 10x. Actual: 3s (full 30s / 10x).

**Fix:** Same as C1 — compute actual remaining before rescaling.

### C3. Hold button first-touch starts duration timer immediately

**File:** `session_engine.dart` lines 110-114

On first `holdStart()`, the implementation sets `_awaitingFirstTouch = false`
and immediately calls `_startPhase(TimerPhase.duration)`. This starts the
countdown timer while the user is still holding the button.

**Spec 01 state machine:**
```
holdStart() called
  -> _isHolding = true
  -> User is holding. (No timer starts.)

holdRelease() called
  -> Start sensitivity timer

Sensitivity expires
  -> Start duration timer (countdown)
```

The duration countdown should only begin after the user releases AND the
sensitivity window expires without re-hold. The current implementation starts
the countdown the moment the user first touches the button, which means:
- The countdown runs while the user is holding (user sees "10... 9... 8..."
  while their finger is still on screen)
- The user cannot simply "hold to be safe" — the timer is always ticking

**Fix:** On first touch, transition to a "holding" state (e.g., update running
state with `phase: TimerPhase.duration` but no timer scheduled, or use a
dedicated `TimerPhase.holding` value). Only start the actual duration timer
after `holdRelease() -> sensitivity expires`.

---

## Significant Issues

### S1. `holdStart()` during duration phase is silently ignored

**File:** `session_engine.dart` lines 117-120

The implementation only handles re-hold during `sensitivity` and `grace`
phases (calls `disarm()`). If the user re-holds during the **duration**
phase (countdown), nothing happens — the countdown continues.

**Spec 01:** "During duration countdown: If holdStart() called -> User
re-held. Cancel countdown, resume holding. No escalation yet."

The spec defines three distinct behaviors for re-hold:
- Sensitivity: cancel sensitivity, resume holding (NOT disarm)
- Duration: cancel countdown, resume holding (NOT disarm)
- Grace: disarm (reset to step 0)

The implementation treats both sensitivity and grace as disarm, and ignores
duration entirely.

**Impact:** User cannot cancel the countdown by re-holding. This removes a
critical safety valve — a user who briefly lifts their finger and misses
the sensitivity window cannot recover by re-holding during countdown.

### S2. Re-hold during sensitivity triggers disarm instead of resuming hold

**File:** `session_engine.dart` lines 117-120

When a user re-holds during the sensitivity window, the implementation calls
`disarm()` (full chain reset to step 0). Spec 01 says this should simply
cancel the sensitivity timer and resume the holding state — no escalation,
no disarm, just "ignore the brief release."

**Spec 01:** "During sensitivity window: If holdStart() called again ->
Brief release detected (< 1s). Cancel sensitivity timer, ignore release.
Resume holding (no escalation)."

**Impact:** Brief finger twitches during hold mode trigger a full disarm
(userDisarmed event emitted, chain resets). While this is not dangerous
(errs on the safe side), it resets the user's session unnecessarily and
generates spurious `userDisarmed` events in the session log.

### S3. `disarm()` callable from `EngineIdle` — starts the session

**File:** `session_engine.dart` lines 146-153

`disarm()` only guards against `EngineEnded`. If called when the engine is
in `EngineIdle` state (before `start()`), it proceeds: emits `userDisarmed`,
calls `_advanceToStep(0)`, which transitions to `EngineRunning` and starts
the first step. This effectively starts a session via `disarm()` instead
of `start()`.

**Fix:** Add guard: `if (_state is! EngineRunning && _state is! EnginePaused)
return;` or explicitly check for `EngineRunning` only. The spec says disarm
works "from any phase of any step" — implying an active session.

### S4. Sub-chain support not implemented

**File:** `session_engine.dart` (entire file)

Spec 12 explicitly states: "Sub-chains are internal to the main engine (NOT
separate SessionEngine instances). The main engine tracks sub-chain state in
EngineSubChainActive."

The `EngineSubChainActive` state variant is defined in `engine_state.dart`
but the engine has zero sub-chain logic. No methods to start/stop sub-chains,
no duress chain, no battery chain, no wrong-pin chain.

`advanceFromHardwarePanic()` returns a boolean for the caller to handle
externally, rather than driving the distress sub-chain internally.

**Impact:** Phase 1 feature gap. Duress PIN, battery alerts, and distress
chains are non-functional. This should be tracked as a known TODO rather
than a bug, but the state type exists without any code path reaching it.

---

## Minor Issues

### M1. Speed multiplier range not clamped per spec

**File:** `session_engine.dart` lines 284-302

Spec 12: "Clamp to [0.01, 1000.0]." The implementation rejects <= 0, NaN,
and Infinity, but accepts values like 0.001 or 5000.0. A very small
multiplier (e.g., 0.0001) would make timers fire in microseconds, potentially
causing rapid-fire event storms.

**Fix:** Add `value = value.clamp(0.01, 1000.0);` or throw for out-of-range.

### M2. `leapToNextEvent` fires immediately instead of 1s delay

**File:** `session_engine.dart` lines 277-281

Spec 01: "Replace any active timer with a 1s countdown." Implementation
cancels the timer and calls `_onTimerFired()` directly (zero delay). This
is arguably better for testing but deviates from spec. In production
simulation mode, the UI would get no time to render the "about to fire"
state.

### M3. `snooze()` not in any spec

**File:** `session_engine.dart` lines 265-272

The `snooze()` method is not documented in spec 01 or spec 12. It extends
the current phase timer by an additional duration. While potentially useful,
it should be documented in the spec or removed to avoid undocumented API
surface.

### M4. `dispose()` does not transition to `EngineEnded`

**File:** `session_engine.dart` lines 306-309

After `dispose()`, the engine state remains whatever it was before (e.g.,
`EngineRunning`). While timers are cancelled and the stream is closed, any
code checking `engine.state` will see a stale state. This could cause
confusion if `dispose()` is called without prior `endSession()`.

**Fix:** Either document that `endSession()` must be called before `dispose()`,
or have `dispose()` transition to `EngineEnded` as well.

### M5. Spec 01 safety fallback for speed multiplier <= 0 not implemented

**File:** `session_engine.dart` line 449 (`_scale` method)

Spec 01 says: "Speed multiplier <= 0 returns original duration unchanged
(safety fallback)." The implementation throws on <= 0 in
`setSpeedMultiplier` (line 290) and has no fallback in `_scale`. Since the
setter rejects invalid values, this is safe in practice, but the `_scale`
method lacks its own defensive guard.

---

## Spec Compliance Checklist

### API Methods (spec 01 + spec 12)

| Method                  | Implemented | Correct | Notes |
|-------------------------|:-----------:|:-------:|-------|
| `start()`               | Yes         | Yes     | Throws on double-call per spec 12 |
| `endSession()`          | Yes         | Yes     | Idempotent, guards EngineEnded |
| `holdStart()`           | Yes         | **No**  | C3, S1, S2 — first touch, duration, sensitivity wrong |
| `holdRelease()`         | Yes         | Yes     | Edge-triggered, starts sensitivity |
| `disarm()`              | Yes         | Partial | Works universally but also from Idle (S3) |
| `checkIn()`             | Yes         | Yes     | Alias for disarm |
| `answerFakeCall()`      | Yes         | Yes     | Pauses chain, waits for hangUp |
| `hangUp()`              | Yes         | Yes     | Fires disarm |
| `declineFakeCall()`     | Yes         | Yes     | Respects declineIsSafe per spec 12 |
| `restartCurrentStep()`  | Yes         | Yes     | Skips wait on retry per spec 12 |
| `advanceFromHardwarePanic()` | Yes    | Partial | Returns bool, no internal distress chain |
| `jumpToStep()`          | Yes         | Yes     | Range-checked |
| `pause()`               | Yes         | **No**  | C1 — remaining time is full phase duration |
| `resume()`              | Yes         | **No**  | C1 — restarts from wrong remaining |
| `snooze()`              | Yes         | N/A     | Not in spec |
| `leapToNextEvent()`     | Yes         | Partial | Fires immediately vs 1s delay (M2) |
| `setSpeedMultiplier()`  | Yes         | Partial | No clamping (M1), rescale broken (C2) |
| `dispose()`             | Yes         | Partial | No state transition (M4) |

### State Machine Transitions

| Transition              | Correct | Notes |
|-------------------------|:-------:|-------|
| Idle -> Running         | Yes     | `start()` |
| Running -> Running      | Yes     | Phase transitions within step |
| Running -> Paused       | **No**  | Remaining time wrong (C1) |
| Paused -> Running       | **No**  | Resumes with wrong remaining (C1) |
| Running -> Ended        | Yes     | Both userTerminated and chainExhausted |
| Idle -> Running (bug)   | **Bug** | `disarm()` from Idle starts engine (S3) |
| Running -> SubChain     | N/A     | Not implemented (S4) |

### Timer Safety

| Concern                        | Status  | Notes |
|--------------------------------|:-------:|-------|
| Timer fires after dispose      | Safe    | `_onTimerFired` checks `_state is! EngineRunning` |
| Timer fires after endSession   | Safe    | State is EngineEnded, guard catches it |
| Timer fires after pause        | Safe    | State is EnginePaused, guard catches it |
| Re-entrant event emission      | Safe    | `_emitting` flag + pending queue |
| Stream closed before emit      | Safe    | `!_controller.isClosed` checks |
| Double endSession              | Safe    | `_state is EngineEnded` guard |
| Double controller.close()      | Safe    | `!_controller.isClosed` in dispose |

### Retry Logic (spec 12 compliance)

| Aspect                          | Correct | Notes |
|---------------------------------|:-------:|-------|
| Wait skipped on ALL retries     | Yes     | Both `_onGraceExpired` and `restartCurrentStep` go to duration |
| Grace period IS retry delay     | Yes     | `grace -> _onGraceExpired -> duration -> grace` |
| Miss count resets on step advance | Yes   | `_advanceToStep` sets `_missCount = 0` |
| Miss count resets on disarm     | Yes     | `disarm()` sets `_missCount = 0` |
| `retryCount` boundary correct   | Yes     | `_missCount > step.retryCount` means N+1 total attempts |

---

## Recommendation Priority

1. **Fix C1 immediately** (pause/resume elapsed tracking) — this is the
   highest-impact bug. Add `_phaseStartedAt` timestamp and compute remaining
   dynamically.
2. **Fix C3 next** (hold button first-touch) — the entire hold-button flow
   is architecturally wrong; the duration timer should not start on first
   touch.
3. **Fix C2** follows automatically from C1.
4. **Fix S1 and S2 together** (hold button phase-specific behavior) — these
   are part of the same incorrect hold-button state machine.
5. **Fix S3** (disarm from Idle) — add a state guard.
6. **Track S4** (sub-chains) as a known Phase 1 gap.
7. Minor issues can be addressed in a follow-up pass.
