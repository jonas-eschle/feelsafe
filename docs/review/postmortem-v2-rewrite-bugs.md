# Postmortem: Why Did the v2 Clean Rewrite Have So Many Bugs?

**Date:** 2026-04-13
**Context:** Guardian Angela v2 was a complete rewrite from clean slate with a
thoroughly reviewed spec (13-rewrite-v2-spec.md). Despite this, the
verification pass found 2 critical, 5 high, 10 medium bugs, 7 partial spec
items, and 10 test failures. This document analyzes WHY and proposes process
changes for future rewrites.

---

## The 5 Categories of Failure

### 1. WIRING FAILURES (most bugs, most dangerous)

**Pattern:** Infrastructure created correctly, integration hookup missed.

| Bug | What existed | What was missing |
|-----|-------------|-----------------|
| Simulation phone service never injected | `SimulationPhoneService` class, `simulationPhoneProvider` | No code swaps phone provider in `startSession()` |
| maxPauseDuration never passed to engine | Field on `SessionMode`, parameter on `SessionEngine` | `session_controller.dart` never passes it |
| Battery alert SMS uses real provider | `_messaging` field set correctly for simulation | Battery code read `messagingServiceProvider` directly instead of using `_messaging` |
| TimerDisarmTrigger model exists but unwired | `TimerDisarmTrigger` class with JSON serialization | `TriggerManager.start()` didn't iterate disarm triggers |

**Root cause:** Each layer was built by a separate agent (models, services,
engine, controller, screens). Each agent verified its own layer compiled and
passed tests. Nobody verified the CONNECTIONS between layers.

**The test gap:** Unit tests verify components in isolation. Integration tests
verify connections. We had 900+ unit tests and ZERO integration tests that
tested "simulation mode uses simulation services" or "maxPauseDuration from
mode reaches engine."

### 2. COPY-PASTE ADAPTATION FAILURES

**Pattern:** Code copied from old4, partially adapted for v2, critical detail
missed.

| Bug | Copied from | What changed in v2 | What was missed |
|-----|------------|-------------------|----------------|
| Decline-with-distress calls `_decline()` | old4 fake_call_screen | v2 adds distress chain trigger | Timer completion block still called `_decline()` not `_triggerDistress()` |
| Session controller reads phone from real provider | old4 session_controller | v2 needs simulation swap | Phone service swap line was never added (messaging was) |

**Root cause:** Copy-paste creates an illusion of completeness. The file
exists, it compiles, it even runs. But one line buried in a callback is
wrong. The agent that copied the file adapted 95% of it correctly but missed
the 5% that matters most.

**The test gap:** No behavioral test: "when decline is held for 5s, the
distress chain fires (not a normal decline)." This is a spec-derived test
that should have been written FROM the spec before the code was written.

### 3. SPEC GAPS THAT BECAME CODE GAPS

**Pattern:** Spec says WHAT but not WHERE or HOW. Implementer fills in the
gap with a reasonable but wrong default.

| Spec section | What it said | What it didn't say | Bug |
|-------------|-------------|-------------------|-----|
| 3.4a Real call during fake call | "auto-disarm silently" | WHERE in the code this check goes | Incoming call listener resumes instead of disarming when fake call active |
| 3.3 HW button mutual exclusion | "either step OR trigger, not both" | That the validator should enforce this | No validation, user could configure both |
| 6.3 Background speed cap | "Background: 1x-60x" | How engine distinguishes foreground vs background | Engine had single 1000x cap for all modes |

**Root cause:** The spec is a design document, not an implementation guide.
It describes desired behavior but not code locations. When an agent reads
"auto-disarm silently when real call ends during fake call," it needs to
know: does this go in the engine? The controller? The screen? The incoming
call listener? Without explicit guidance, the agent puts it nowhere.

### 4. AGENT COMMUNICATION FAILURES

**Pattern:** Parallel agents create matching interfaces but don't coordinate
on usage.

| Agent A created | Agent B created | Nobody created |
|----------------|----------------|---------------|
| `SimulationPhoneService` | `PhoneServiceProtocol` | The line that injects one into the other |
| `distress_confirmation.dart` with hardcoded text | `app_en.arb` with l10n keys | The import + usage of l10n in the widget |
| `trigger_summary_dialog.dart` | `home_screen.dart` start flow | The call to show the dialog before starting |

**Root cause:** Agents worked on orthogonal files. Agent A built services,
Agent B built screens. Each verified their own work compiles. But the
contract between them ("screen X must use service Y") was implicit, not
explicit. No agent was responsible for verifying cross-boundary wiring.

### 5. VERIFICATION TIMING

**Pattern:** Bugs found only at the end, during the final verification pass.
By then, many layers of code depend on the buggy behavior.

**What happened:**
- Phase 1-8 each had "run flutter analyze + flutter test" as verification
- Tests were unit-focused (engine, models, controllers in isolation)
- No phase had "run an integration test that exercises the FULL flow"
- The 5 verification agents at the end found everything — but fixing required
  understanding 8 phases of accumulated code

**Why this is bad:** Late bug discovery means:
- More code to read to understand the bug
- More tests that might break when you fix it
- Higher risk of fix introducing new bugs
- The bug may have shaped other design decisions ("oh, this doesn't work,
  let me work around it")

---

## What Would Have Prevented Each Bug

### Simulation injection (C1, C2)
**Prevention:** A single integration test written at Phase 2:
```dart
test('simulation session uses SimulationMessagingService', () {
  final controller = createController();
  controller.startSession(mode, isSimulation: true);
  // Assert: the messaging service IS SimulationMessagingService
  expect(controller.messagingService, isA<SimulationMessagingService>());
  expect(controller.phoneService, isA<SimulationPhoneService>());
});
```
This test would have failed at Phase 3 when the controller was created.

### Decline-with-distress (3.4 BUG)
**Prevention:** A spec-derived test written at Phase 1:
```dart
test('spec 3.4: decline held 5s triggers distress, not normal decline', () {
  // This test doesn't need the screen — just the engine API
  engine.start();
  // advance to fake call step
  engine.answerFakeCall(); // now on fake call
  // simulate decline-with-distress
  engine.triggerDistress(); // should call replaceWithDistressChain
  expect(engine.isDistressChain, true);
});
```

### maxPauseDuration (3.10 GAP)
**Prevention:** A wiring checklist:
```
SessionMode fields that must reach SessionEngine:
  [ ] chainSteps → steps ✓
  [ ] isSimulation → isSimulation ✓
  [ ] maxPauseDuration → maxPauseDuration ✗ MISSING
```

### l10n not wired (H4)
**Prevention:** An automated lint rule:
```
RULE: No string literal in a Widget.build() method unless it's a key,
      a semantic label, or explicitly marked @nonLocalizable.
```

---

## Process Changes for Next Rewrite

### 1. SPEC → TEST → CODE (not SPEC → CODE → TEST)

Write tests FROM the spec BEFORE writing implementation:
- Every numbered spec section gets at least one test
- Tests are written against the public API (engine methods, controller
  methods) and initially FAIL
- Implementation makes them pass
- This inverts the current flow where tests were written to match what
  the code already does (which doesn't catch missing features)

### 2. WIRING MAP (mandatory artifact)

Before implementation, create a document:
```
Model Field          → Constructor Param    → Controller Line
SessionMode.maxPause → SessionEngine(maxP:) → session_controller:104
SessionMode.distress → engine.replace(...)  → session_controller:449
AppSettings.pinTimeout → PinDialog(timeout:) → session_screen:207
```
Every row must have all three columns filled. Review at each phase.

### 3. INTEGRATION TESTS AT EACH PHASE (not just at the end)

After Phase 3 (core screens), add integration tests:
- "Full walk mode flow: start → hold → release → grace → disarm"
- "Full simulation flow: start → speed 10x → SMS step → sim_blocked"
- "Distress flow: hardware panic → confirmation → chain replacement"

These run at every subsequent phase and catch regressions.

### 4. NO PARALLEL AGENTS FOR CONNECTED CODE

The agent parallelization strategy was wrong:
- ✓ SAFE to parallelize: models + engine tests (no shared state)
- ✗ UNSAFE to parallelize: session_controller + service_providers +
  screens (deeply connected, need coordinated wiring)

For connected code, use sequential agents with explicit hand-off:
1. Agent A creates services + providers
2. Agent A writes a CONTRACT: "Session controller MUST read
   simulationMessagingProvider when isSimulation=true"
3. Agent B reads the CONTRACT and implements session_controller
4. Agent B verifies the CONTRACT is satisfied

### 5. STUB DETECTION

Any method body that is empty or just logs should:
- Throw `UnimplementedError('TODO: wire to messaging service')`
- OR be tested with a test that will fail when the stub is reached
- OR be annotated with `@mustBeOverridden` or similar

This makes "code exists but does nothing" impossible to miss.

### 6. VERIFICATION AT BUILD TIME, NOT AT THE END

Instead of 5 verification agents at the end:
- After EACH phase, run ONE verification agent that checks spec
  compliance for THAT phase's items
- Fix issues immediately (while the code is fresh)
- The final verification should find nothing new

### 7. SINGLE OWNER FOR CROSS-CUTTING CONCERNS

Assign one agent as the "wiring owner" who:
- Doesn't write features
- Reviews every PR/phase for: "Are all new providers used? Are all new
  model fields threaded through? Are all new screens wired to router?"
- Maintains the wiring map
- Writes the integration tests

---

## Summary

The bugs weren't caused by bad code or a bad spec. They were caused by
**good components that weren't connected.** Each layer (models, engine,
services, controllers, screens) was individually correct. The failures were
all at the BOUNDARIES between layers:

- Service defined ↔ service injected
- Model field defined ↔ field passed to engine
- Spec behavior described ↔ behavior tested
- l10n key defined ↔ key used in widget

**The lesson:** A clean rewrite with a clear spec prevents DESIGN bugs
(wrong architecture, wrong state model). It does NOT prevent WIRING bugs
(right components, wrong connections). Preventing wiring bugs requires
integration tests, wiring maps, and cross-boundary verification — none of
which were part of the v2 process.
