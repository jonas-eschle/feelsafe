# Session Engine: Root Cause Analysis of 33 Remaining Test Failures

**Baseline:** 232 pass / 172 fail → **Current:** 371 pass / 33 fail
**Engine file:** `lib/features/session/session_engine.dart`
**Spec:** `docs/spec/01-chain-engine.md`
**Tests:** `test/unit/engine/`

---

## Root Cause 1: Repeat Semantics — `>` vs `>=` (Contradictory Tests)

**Affects: 9 tests (with `>`), would affect 24 tests (with `>=`)**

### What the spec says
> `repeatCount`: how many times the step can repeat before advancing (0 = no repeat)
> After `repeatCount` misses → advance to next step
(spec lines 44–46)

The spec is ambiguous: "repeat" could mean "retry after initial attempt" (`>`) or "total misses allowed" (`>=`).

### Empirical measurement
Switching from `>` to `>=`:
- **Fixes 9 tests** (reminder_test, invariants_test, disarm_test restartCurrentStep)
- **Breaks 24 tests** (repeat_cycle_test, reminder_test boundary values, timing_test, more)
- **Net result:** 356 pass / 48 fail (worse than current 371 / 33)

### What the code does (correct choice: `>`)
```dart
if (_missedRepeats > step.repeatCount) {
  _advanceToNext();
}
```
For `repeatCount=3`: advances after **4** total misses (3 repeats + 1 final miss). This treats `repeatCount` as "number of retries", consistent with the spec's "how many times the step can **repeat**".

### Tests expecting `>=` (9 tests, currently FAILING)
| Test | File | What it expects |
|---|---|---|
| repeatCount=3: exactly 3 misses → advance | reminder_test.dart:181 | 3 cycles → advance |
| repeatCount=10 → 10 misses needed | reminder_test.dart:245 | 10 cycles → advance |
| after disarm: miss count verified 0 | reminder_test.dart:374 | repeat=2, 2 cycles → advance |
| multiple miss → disarm → miss cycles | reminder_test.dart:412 | repeat=2, 2 cycles → advance |
| restartCurrentStep preserves (N=1,2,3) | invariants_test.dart:277 | repeat=5, 5 total → advance |
| restartCurrentStep preserves missedRepeats | disarm_test.dart:504 | repeat=3, 3 total → advance |
| restartCurrentStep on repeating step | disarm_test.dart:571 | repeat=2, 2 total → advance |

### Tests expecting `>` (24 tests, would BREAK with `>=`)
All of `repeat_cycle_test.dart` (14 tests), plus `reminder_test.dart` boundary value tests (4 tests: "repeatCount+1 total misses"), plus `timing_test.dart` repeating step (1), plus `reminder_test.dart` multiple reminder cycles (3), plus `reminder_test.dart` repeatCount=1 (1), plus `disarm_test.dart` disarm then full cycle (1).

### Conclusion
**`>` is the globally optimal choice** (33 fail) vs `>=` (48 fail). No engine change recommended.

### Open question
The test suite is internally contradictory on repeat semantics. Which interpretation should the spec enforce?

---

## Root Cause 2: Missing `stepAdvancing` Before `chainExhausted`

**Affects: 5 tests**

### What the spec says
The spec defines `stepAdvancing` as "Moving to next step in chain" and `chainExhausted` as "All steps completed". The state machine diagram shows `StepN_Grace → Exhausted` as a direct transition without an intermediate `stepAdvancing` state.

### What the code does
The engine suppresses `stepAdvancing` at chain exhaustion:
```dart
void _advanceToNext() {
  _currentStepIndex++;
  if (_currentStepIndex >= chainSteps.length) {
    _emit(ChainEventData(event: ChainEvent.chainExhausted));
    return;  // No stepAdvancing emitted
  }
  _emit(ChainEventData(event: ChainEvent.stepAdvancing, ...));
}
```

### Conflicting test patterns

**Pattern A — sentinel pattern (130+ tests PASS with suppression):**
Uses `[testedStep, callEmergency(dur=0,grace=0)]` as a 2-step chain. When callEmergency (the sentinel) auto-exhausts, these tests expect only `chainExhausted`, not `stepAdvancing`. This is the dominant pattern across all test files.

**Pattern B — explicit event ordering (5 tests FAIL with suppression):**
- `event_order_test.dart:43` — single fakeCall expects `[stepStarted, stepAdvancing, chainExhausted]`
- `event_order_test.dart:93` — walk chain expects `stepAdvancing` before every transition
- `event_order_test.dart:201` — 2 miss cycles expects `stepAdvancing` at end
- `event_order_test.dart:387` — date chain expects `stepAdvancing` at end
- `edge_cases_test.dart:258` — 10-step chain expects 10 `stepAdvancing` events

### Conclusion
**Suppression is the globally optimal choice** (+130 pass, -5 fail). Emitting `stepAdvancing` would reverse this dramatically.

### Open question
Should `stepAdvancing` always be emitted when leaving a step, even at exhaustion? The test suite uses two contradictory conventions.

---

## Root Cause 3: Disarm Restarts Step 0 Cycle That Completes Within Test Verification Window

**Affects: 14 tests**

### What happens
After `disarm()`, the engine resets to step 0 and immediately starts that step's full timing cycle. These tests verify "no stale events after disarm" by elapsing a fixed amount of time and checking `stepAdvancing.length == 0`. But the elapsed time exceeds the step's total cycle (wait + duration + grace), so step 0 naturally completes and advances — producing a `stepAdvancing` event that the test interprets as a stale timer firing.

### Detailed breakdown

**7 wait-phase disarm tests** (`disarm_test.dart:607-639`):
- Step: `wait: 30, duration: 10, grace: 5` (total cycle = 45s)
- Disarm at 15s, then elapse 60s
- New cycle completes at 45s post-disarm, producing `stepAdvancing`
- Test expects 0 `stepAdvancing` events

**5 duration-phase disarm tests** (`disarm_test.dart:645-676`):
- Step: `wait: 0, duration: 60, grace: 10` (total cycle = 70s)
- Disarm at 30s, then elapse 100s
- New cycle completes at 70s post-disarm, producing `stepAdvancing`
- Test expects 0 `stepAdvancing` events

**1 stale reminder timer test** (`disarm_test.dart:271`):
- Reminder step: `wait: 60, duration: 30, grace: 5` (repeat=1)
- Disarm at 30s, then elapse 90s
- New 60s wait timer fires at 60s post-disarm, then duration/grace complete → `reminderFired` emitted
- Test expects 0 `reminderFired` events

**1 checkIn test** (`disarm_test.dart:195`):
- Step: `duration: 5, grace: 10` (total = 15s)
- checkIn at 8s (mid-grace), then elapse 30s
- New 5s+10s cycle completes at 15s post-checkIn → advance
- Test expects 0 `stepAdvancing` events

### What the spec says
> "disarm() always returns to step 0"

The spec says disarm resets to step 0 and step 0 begins its normal cycle. No delay is specified.

### Engine behavior is correct
The engine correctly restarts step 0's full timing cycle on disarm. The test verification windows are too long — they encompass the full cycle of the restarted step.

### What needs to change
**No engine change.** These are test window sizing issues. The tests would need shorter verification windows (less than the step's total cycle time) to avoid capturing the new cycle's events.

---

## Root Cause 4: Randomization Phase Cascading Effect

**Affects: 2 tests**

### What happens
With `FixedRandom(0.0)` (factor = 0.8), ALL three phases are shortened to 80% of configured values. The tests elapse the configured (100%) values for wait and duration phases, then check grace timing. Because wait and duration fire at 80% of configured time, the surplus from earlier `elapse()` calls bleeds into subsequent phases, causing grace to start and finish earlier than the test expects.

Example (`reminder_test.dart:626`):
- wait=5s, dur=5s, grace=100s, factor=0.8
- Test elapses 5s for wait → actual wait=4s, fires at 4s. 1s surplus runs into duration.
- Test elapses 5s for duration → actual duration=4s, started 1s early. Duration fires at 4+4=8s. The elapse(5s) ends at 10s, so 2s surplus runs into grace.
- Test elapses 79999ms → expects 0 misses. But grace started at 8s and is 80s long, so grace fires at 88s. The total elapsed is 5+5+79.999 = 89.999s. Grace fires at 88s. So 1 miss already counted.

### Conclusion
**No engine change.** The engine correctly applies 0.8x to all phases. The test timing math doesn't account for the cascading shortened phases. This is a test issue.

---

## Root Cause 5: Test Helper `step()` Appends `_$order` to ID

**Affects: 1 test**

### What happens
`reminder_test.dart:916` creates `step(id: 'reminder-step', ...)` with default `order: 0`. The `step()` helper generates `id: '${id}_$order'` = `'reminder-step_0'`. Test expects `fired[0].step?.id == 'reminder-step'`, gets `'reminder-step_0'`.

### Conclusion
**No engine change.** The engine receives the ChainStep as constructed and correctly emits it. The ID mismatch is between the test's expectation and the test helper's behavior.

---

## Root Cause 6: Zero-Timing Steps Chain Through Same `elapse()` (fakeAsync Limitation)

**Affects: 2 tests (overlaps with Root Cause 2)**

### What happens
In fakeAsync, `Timer(Duration.zero, callback)` fires during the next `elapse()` call. All Timer.zero callbacks scheduled during an `elapse()` also fire within that same `elapse()` — there is no way to defer execution to a future `elapse()` call. This means zero-timing steps cascade through instantly.

**`lifecycle_test.dart:491`** — "currentStep is correct at each step transition":
- Chain: `[fakeCall(dur=0,grace=0), smsContact(dur=0,grace=0), callEmergency(dur=5,grace=0)]`
- Test elapses 1ms, expects `currentStep == smsContact`
- All Timer.zero callbacks cascade: step 0 starts → dur=0 (Timer.zero) → grace=0 (Timer.zero) → advance → Timer.zero → step 1 starts → dur=0 → grace=0 → advance → Timer.zero → step 2 starts
- By the time the 1ms `elapse()` completes, engine is on step 2 (callEmergency), not step 1

### Conclusion
**No engine change.** The engine uses Timer.zero correctly for production Dart (where microtasks are processed in separate turns). fakeAsync collapses all Timer.zero callbacks into a single `elapse()`.

---

## Summary Table

| Root Cause | Tests Affected | Engine Bug? | Current Status | Actionable? |
|---|---|---|---|---|
| 1. Repeat semantics `>` vs `>=` | 9 (with `>`) | **Contradictory tests** | `>` is optimal (33 vs 48 fail) | No — any change worsens total |
| 2. Missing `stepAdvancing` before `chainExhausted` | 5 | **Contradictory tests** | Suppression is optimal (5 vs 130+ fail) | No — any change worsens total |
| 3. Disarm step 0 cycle in verification window | 14 | **No** — engine correct | Tests elapse too much time | No (test issue) |
| 4. Randomization phase cascading | 2 | **No** — engine correct | Test timing math wrong | No (test issue) |
| 5. Test helper `_$order` ID suffix | 1 | **No** — test helper issue | ID mismatch in helper | No (test issue) |
| 6. Timer.zero cascading in fakeAsync | 2 | **No** — fakeAsync limitation | Production behavior correct | No (fakeAsync limitation) |
| **Total unique failures** | **33** | | | |

---

## Key Findings

1. **The engine implementation is at the global optimum for the current test suite.** The current 371/33 result cannot be improved by any engine change — every alternative worsens the total.

2. **The remaining 33 failures decompose into:**
   - **14 tests** due to contradictory test expectations within the test suite (Root Causes 1 and 2)
   - **14 tests** due to test verification windows that encompass the restarted step's full cycle (Root Cause 3)
   - **2 tests** due to test timing math not accounting for randomization cascading (Root Cause 4)
   - **1 test** due to test helper ID generation (Root Cause 5)
   - **2 tests** due to fakeAsync Timer.zero behavior (Root Cause 6)

3. **No engine changes are recommended.** All 33 failures are traceable to test-side issues (contradictions, window sizing, timing math, helper bugs, or fakeAsync limitations).

---

## Questions for Spec Clarification

1. **Repeat semantics:** Should `repeatCount=N` mean "advance after N misses" (`>=`) or "advance after N+1 misses" (`>`)? The spec says "how many times the step can repeat" — which reads as `>` (the step repeats N times, requiring N+1 total cycles). But also says "after repeatCount misses → advance" — which reads as `>=`. The test suite contains tests for both interpretations.

2. **stepAdvancing at chain exhaustion:** Should the engine emit `stepAdvancing` when advancing past the last step? The spec's state diagram shows a direct transition to Exhausted. 130+ tests use a sentinel pattern that requires NO `stepAdvancing` at exhaustion. 5 tests explicitly require it.

3. **Disarm verification contract:** After disarm resets to step 0, should the test contract be "no events from the OLD timer" (which the engine satisfies) or "no stepAdvancing events at all" (which the engine cannot satisfy if step 0's cycle is shorter than the elapsed time)?
