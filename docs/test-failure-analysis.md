# Test Failure Analysis: 40 Failing Tests

**Date:** 2026-03-31
**State:** 769 pass, 40 fail
**Analyzed by:** Claude Opus 4.6

---

## Category A: 7 Integration Test Compilation Errors

**Files:**
- `test/integration/alarm_scenarios_test.dart`
- `test/integration/chain_edge_cases_test.dart`
- `test/integration/date_scenarios_test.dart`
- `test/integration/emergency_scenarios_test.dart`
- `test/integration/fake_call_scenarios_test.dart`
- `test/integration/simulation_scenarios_test.dart`
- `test/integration/walk_scenarios_test.dart`

**Root cause:** Missing import. All 7 files import `session_engine.dart` and `../unit/_mocks.dart`, but they use `ChainStepType` and `ChainStep` directly in their own code (outside the `step()` helper). The `_mocks.dart` file imports `chain_step.dart` but does **not** re-export it. Dart imports are private to the importing file, so `ChainStepType`/`ChainStep` are not transitively available.

The passing unit tests (e.g., `disarm_test.dart`, `event_order_test.dart`) all have an explicit `import 'package:guardianangela/data/models/chain_step.dart';` which the integration tests lack.

**Verdict:** TEST BUG (trivial)
**Fix:** Add `import 'package:guardianangela/data/models/chain_step.dart';` to each of the 7 integration test files, or add `export 'package:guardianangela/data/models/chain_step.dart';` to `_mocks.dart`.

---

## Category B: 14 "Disarm during wait/duration phase" Failures

**Failing tests:**
- `disarm_test.dart`: "disarm during wait phase of X resets to step 0" (7 step types: disguisedReminder, countdownWarning, fakeCall, smsContact, phoneCallContact, loudAlarm, callEmergency)
- `disarm_test.dart`: "disarm during duration phase of X resets to step 0" (5 step types: fakeCall, smsContact, loudAlarm, countdownWarning, phoneCallContact)
- `disarm_test.dart`: "checkIn during grace resets to step 0"
- `disarm_test.dart`: "disarm during wait (reminder): no stale remind timer fires"

**Root cause:** All these tests verify that after disarm, "no stale timers fire." They disarm mid-phase, then elapse a large amount of time (30-100s), and assert `stepAdvancing.length == 0`. The problem: `disarm()` resets to step 0 and calls `_executeStep(0)`, which starts a **fresh** timer cycle for step 0. The elapsed time is long enough for the freshly restarted step to complete its full cycle (wait + duration + grace) and advance.

Example (wait-phase parametrized test):
- Chain: `[step(type: fakeCall, wait: 30, dur: 10, grace: 5), callEmergency]`
- Disarm at 15s (mid-wait). Step 0 restarts with a new 30s wait.
- Test then elapses 60s total after disarm → the restarted step completes (30+10+5=45s) and advances.
- Test expects `stepAdvancing.length == 0`, but gets 1 from the legitimately restarted step.

For the "disarm during wait (reminder)" test:
- Chain: `[disguisedReminder(wait: 60), callEmergency]`
- Disarm at 30s. Step 0 restarts with a fresh 60s wait.
- Test elapses 90s → new reminder fires at 60s after disarm. Test expects `reminderFired.length == 0`, gets 1.

**Verdict:** TEST BUG (all 14 tests)
**Fix:** Either reduce the elapsed time after disarm to less than the step's total cycle, or adjust the assertion to allow events from the legitimately restarted step. The existing non-parametrized disarm tests (e.g., "disarm during duration: no stale duration timer fires" at line 222) handle this correctly by carefully choosing elapsed times.

---

## Category C: 5 Repeat Count Semantics Failures

**Failing tests:**
- `reminder_test.dart`: "repeatCount=3: exactly 3 misses -> advance to next step"
- `reminder_test.dart`: "repeatCount=10 -> 10 misses needed before advance"
- `event_order_test.dart`: "disguisedReminder: 2 full miss cycles, 3rd advances" (repeat=2)
- `reminder_test.dart`: "after disarm: miss count verified 0 -- next cycle needs full repeatCount misses"
- `reminder_test.dart`: "multiple miss -> disarm -> miss cycles: miss count resets each time"

**Root cause:** The engine uses `_missedRepeats > step.repeatCount` to decide when to advance. This means with `repeatCount=N`, the engine requires **N+1 misses** before advancing. Some tests expect **N misses**.

Engine code (`_onReminderGraceExpired` and `_onGraceExpired`):
```dart
_missedRepeats++;
if (_missedRepeats > step.repeatCount) {  // strict greater-than
    _advanceToNext();
}
```

The spec (01-chain-engine.md) is **self-contradictory**:
- Line 44: `repeatCount: how many times the step can **repeat** before advancing (0 = no repeat)` -- implies N repeats = N+1 total cycles = N+1 misses
- Line 46: `After repeatCount misses -> advance to next step` -- implies exactly N misses

**Within the same test file** (`reminder_test.dart`), there are contradicting test groups:
- Line 181: "repeatCount=3: exactly 3 misses -> advance" (expects N misses) -- **FAILS**
- Line 862: "repeatCount boundary values: advance requires repeatCount+1 total misses" -- "repeatCount=3: advance after exactly 4 miss(es)" (expects N+1 misses) -- **PASSES**

The passing boundary-value tests (line 860-893) match the engine's N+1 behavior. The failing tests match the spec's "After repeatCount misses" wording.

The last two failing tests in this category ("after disarm: miss count verified 0" and "multiple miss -> disarm -> miss cycles") fail for the same reason: they assume N misses to advance after disarm, but the engine needs N+1.

**Verdict:** SPEC AMBIGUITY / CONFLICTING TESTS

**Question for user:**
> Which semantics do you want for `repeatCount`?
> - **Option A (current engine + passing tests):** `repeatCount` = number of additional repeats. Total misses before advance = `repeatCount + 1`. So `repeatCount=3` means 4 misses.
> - **Option B (spec line 46 + failing tests):** `repeatCount` = total misses before advance. `repeatCount=3` means 3 misses. Change engine condition from `>` to `>=`.
>
> Note: Option B would break the 5 currently-passing boundary-value tests. Option A requires fixing the 5 failing tests.

---

## Category D: 5 Event Ordering / stepAdvancing-at-Exhaustion Failures

**Failing tests:**
- `event_order_test.dart`: "single fakeCall: stepStarted, then stepAdvancing, then chainExhausted"
- `event_order_test.dart`: "walk chain: complete event sequence verified"
- `event_order_test.dart`: "stepAdvancing.nextStep = null when last step advances (chain exhausting)"
- `event_order_test.dart`: "date chain first miss cycle event order"
- `edge_cases_test.dart`: "10-step all-zero chain: chainExhausted emitted after start" (expects 10 stepAdvancing, gets 9)

**Root cause:** The engine's `_advanceToNext()` does NOT emit `stepAdvancing` when advancing past the last step. It jumps directly to `chainExhausted`:

```dart
void _advanceToNext() {
    _cancelAllTimers();
    final fromStep = currentStep;
    _currentStepIndex++;

    if (_currentStepIndex >= chainSteps.length) {
      _emit(ChainEventData(event: ChainEvent.chainExhausted));
      return;  // <--- No stepAdvancing emitted here
    }

    _emit(ChainEventData(
      event: ChainEvent.stepAdvancing,
      step: fromStep,
      nextStep: toStep,
    ));
```

The tests expect `stepAdvancing` to always be emitted before `chainExhausted` (even for the final step). The engine suppresses it.

Specific consequences:
1. "single fakeCall" expects `[stepStarted, stepAdvancing, chainExhausted]`, gets `[stepStarted, chainExhausted]`.
2. "walk chain" expects `stepAdvancing` after callEmergency before `chainExhausted`, gets `chainExhausted` directly.
3. "stepAdvancing.nextStep = null" test does `events.firstWhere((e) => e.event == ChainEvent.stepAdvancing)` -- throws `Bad state: No element` because no `stepAdvancing` was emitted at all (single-step chain).
4. "10-step all-zero chain" expects 10 `stepAdvancing` events; gets 9 (the last step goes directly to `chainExhausted`).
5. "date chain first miss cycle" expects `types[9] == stepAdvancing` but gets `chainExhausted`.

**Verdict:** SPEC AMBIGUITY

The spec's event list includes `stepAdvancing` ("Moving to next step in chain") and `chainExhausted` ("All steps completed") as separate events. The spec does not explicitly state whether `stepAdvancing` should be emitted for the final step.

**Question for user:**
> Should `stepAdvancing` be emitted for the last step before `chainExhausted`?
> - **Option A (current engine):** Only emit `chainExhausted` when the last step completes. No `stepAdvancing` since there's no "next step" to advance to.
> - **Option B (what tests expect):** Always emit `stepAdvancing` (with `nextStep = null`) followed by `chainExhausted`. This gives consumers a chance to see the "departing" step.
>
> Option B would require changing `_advanceToNext()` to emit `stepAdvancing(step: fromStep, nextStep: null)` before `chainExhausted`.

---

## Category E: 5 Miscellaneous Failures

### E1: Lifecycle currentStep tracking (1 failure)

**Test:** `lifecycle_test.dart`: "currentStep is correct at each step transition"

**Root cause:** The test creates a 3-step chain where steps 0 and 1 have all-zero timing (dur=0, grace=0) and step 2 has dur=5. After `engine.start()` + `elapse(1ms)`, the test expects `currentStep == smsContact` (step 1). But both step 0 and step 1 complete instantly (via cascading `Timer(Duration.zero, ...)` callbacks) within the single `elapse(1ms)` call. The engine ends up on step 2 (callEmergency).

**Verdict:** TEST BUG
**Fix:** Add non-zero timing to step 1, or check `currentStep` between each micro-tick rather than after a bulk `elapse`.

### E2: Randomization timing (2 failures)

**Tests:**
- `timing_test.dart`: "FixedRandom(0.0) with randomize=true: all phases scaled to 0.8x"
- `reminder_test.dart`: "randomize applies to grace phase (FixedRandom(0.0): grace*0.8)"

**Root cause (timing_test.dart):** The test elapses wall-clock time using **non-randomized** values for wait and duration phases, but expects **randomized** grace timing. With FixedRandom(0.0), all phases are scaled to 0.8x:
- wait=100 -> 80s, dur=50 -> 40s, grace=20 -> 16s
- Test elapses 79s (correct for wait), then 2s, then 39s, then 2s (cumulative: 122s)
- At this point, it expects grace hasn't fired. But grace started at 120s (80+40=120), and 16s grace ends at 136s. At 122s, grace hasn't fired yet. So far OK.
- Then test elapses 15s more (137s total), expects `repeatMissed.length == 0`. But grace fires at 136s, so a miss WAS counted. Test miscounts because the elapsed values for wait/duration phases don't consume exactly the randomized amount -- the excess time carries forward.

Actually re-checking: `elapse(79)` = 79s. Then `elapse(2)` = 81s. Wait fires at 80s, so at 81s reminderFired is emitted. Duration starts at 80s. Duration = 40s, ends at 120s. Then `elapse(39)` = 81+39=120s. Duration ends exactly. Then `elapse(2)` = 122s. Grace starts at 120. Then `elapse(15)` = 137s. Grace at 120+16=136s < 137s. Miss fired. Test expected 0. The issue is the test counts time from its `elapse` calls rather than from when the phase actually starts.

**Root cause (reminder_test.dart):** Similar miscalculation. FixedRandom(0.0) means wait=5*0.8=4s, dur=5*0.8=4s, grace=100*0.8=80s. Test elapses `waitSec=5` (1s excess), then `durSec=5` (1s excess), then 79999ms. Total: 5+5+79.999=89.999s. Grace started at 4+4=8s, ends at 8+80=88s. At 89.999s, grace has already expired. Test expects 0 misses, gets 1.

**Verdict:** TEST BUG (both)
**Fix:** When randomize=true, calculate elapsed times from the randomized values, not the configured values.

### E3: reminderFired payload ID check (1 failure)

**Test:** `reminder_test.dart`: "reminderFired payload.step.type == disguisedReminder"

**Root cause:** The test creates `step(id: 'reminder-step', type: ..., order: 0, ...)` and expects `step.id == 'reminder-step'`. But the `step()` helper in `_mocks.dart` appends `_$order` to the ID:
```dart
return ChainStep(id: '${id}_$order', ...)
```
So the actual ID is `'reminder-step_0'`, not `'reminder-step'`.

**Verdict:** TEST BUG
**Fix:** Either change the test to expect `'reminder-step_0'`, or change the helper to not append order when a custom ID is provided.

### E4: restartCurrentStep miss preservation (3 failures)

**Tests:**
- `invariants_test.dart`: "restartCurrentStep after N misses: count preserved" (N=1,2,3)
- `disarm_test.dart`: "restartCurrentStep: preserves missedRepeats count"
- `disarm_test.dart`: "restartCurrentStep on repeating step: miss count preserved across restarts"

**Root cause:** Same as Category C (repeat count semantics). These tests assume `repeatCount=N` means N misses to advance, but the engine requires N+1. After `restartCurrentStep`, the tests provide exactly `repeatCount - missesBeforeRestart` more misses, which is one short of what the engine requires.

For the invariants test: `repeat=5`, expects advance after 5 total misses. Engine needs 6. The test accumulates `missesBeforeRestart` + `(5 - missesBeforeRestart)` = 5 misses, one short.

**Verdict:** Same as Category C -- depends on the repeat count semantics decision.

---

## Summary Table

| Category | Count | Root Cause | Verdict | Action |
|----------|-------|------------|---------|--------|
| A: Compilation errors | 7 | Missing `chain_step.dart` import | Test bug | Add import |
| B: Disarm stale timer | 14 | Restarted step completes within test's elapsed time | Test bug | Shorten elapsed time or adjust assertion |
| C: Repeat count semantics | 5 | Engine uses `> N` (N+1 misses); some tests expect `>= N` (N misses) | Spec ambiguity | User decision needed |
| D: stepAdvancing at exhaustion | 5 | Engine suppresses `stepAdvancing` for last step | Spec ambiguity | User decision needed |
| E1: currentStep tracking | 1 | Zero-timing steps cascade in one tick | Test bug | Add timing to intermediate step |
| E2: Randomization timing | 2 | Tests use non-randomized values for phase timing | Test bug | Use randomized values |
| E3: Payload ID check | 1 | `step()` helper appends `_$order` | Test bug | Fix expected value |
| E4: restartCurrentStep | 5 | Same as Category C | Depends on C | Same decision |
| **Total** | **40** | | | |

---

## Questions for the User

### Q1: Repeat count semantics (Categories C + E4, 10 tests)

The spec says two things:
1. `repeatCount: how many times the step can repeat before advancing (0 = no repeat)` -- suggests N+1 total cycles
2. `After repeatCount misses -> advance to next step` -- suggests N total misses

Which do you want?
- **N+1 misses (current engine):** `repeatCount=3` means 3 repeats + 1 initial = 4 cycles = 4 misses to advance. Fix 10 failing tests.
- **N misses:** `repeatCount=3` means 3 misses to advance. Change engine `>` to `>=`. Fix 5 passing boundary-value tests.

### Q2: stepAdvancing before chainExhausted (Category D, 5 tests)

Should the engine emit `stepAdvancing(step: lastStep, nextStep: null)` before `chainExhausted` when the last step completes?
- **Current engine:** Only emits `chainExhausted`. Simpler, but consumers can't see which step was the "departing" step.
- **Tests expect:** `stepAdvancing` always emitted, with `nextStep: null` for the final transition. More complete event stream.
