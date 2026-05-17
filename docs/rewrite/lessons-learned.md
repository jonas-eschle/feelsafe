# Guardian Angela — Lessons Learned for v3 Rewrite

> **Audience:** A rewrite team (human + agents) starting from an empty
> folder. You have NEVER seen this codebase. Read this file BEFORE
> reading the spec, before reading any source, before writing the first
> line of code. Every rule below is in the file because some previous
> rewrite ignored it and paid for it.
>
> **Source of every rule** is cited in parentheses (`feedback_*.md`,
> `project_*.md`, or the v2 postmortem) so future-you can trace it back.
>
> **Scope:** This file is process, philosophy, and history. For
> *current architecture* read `CLAUDE.md`. For *current spec* read
> `docs/spec/*.md`. For *what to build next* read the rewrite plan
> (when it exists). This file tells you what NOT to do.

---

## 1. TL;DR — Five rules to internalize before writing any code

1. **WIRING is the failure mode, not design.** Every v2 bug was a
   *connection* bug, not a *component* bug. Components compiled and
   passed unit tests; the lines that connected them were missing.
   Build the wiring map FIRST, then write code into it. (Per
   `feedback_rewrite_process.md` + `docs/review/postmortem-v2-rewrite-bugs.md`.)

2. **SPEC → TEST → CODE.** Never SPEC → CODE → TEST. Write a failing
   integration test for every spec section BEFORE the implementation
   exists. An undelivered feature MUST fail a test, not silently ship
   as a stub. (Per `feedback_rewrite_process.md` rule 1.)

3. **Default to sequential agent dispatch.** Parallel is a performance
   optimization, never the default. Only parallelize when files are
   fully disjoint, no shared mutable state, and no shared artifact
   either agent writes to. When in doubt, serialize. (Per
   `feedback_parallelism_default_sequential.md`.)

4. **Minimize false positives over all else.** This is a safety app
   where a false 112 call has real consequences. Generous grace
   periods, generous retry counts, repeat-step-on-doubt, auto-pause
   on real calls, default-true `declineIsSafe`. When unsure: do NOT
   escalate. (Per `feedback_false_positives.md`.)

5. **Pre-alpha: no migrations, no shims, no CHANGELOG.** There are
   no users. On schema change: nuke and re-seed. Refactors are
   atomic — the same PR that introduces the new shape removes the
   old one. (Per `project_prealpha_break_compat.md`.)

---

## 2. What broke in v2 — the failure catalog

These are the bugs the v2 verification audit found
(`docs/review/postmortem-v2-rewrite-bugs.md`). Every one of them
was preventable with a wiring map and integration tests at each phase.

### 2.1 Wiring failures (dominant, most dangerous)

Each layer was correct in isolation; the connections were missing.

| What existed | What was missing | Symptom |
|---|---|---|
| `SimulationPhoneService` class + `simulationPhoneProvider` | `SessionController.startSession()` never swapped the phone provider when `isSimulation=true` | Simulations made real phone calls |
| `maxPauseDuration` field on `SessionMode` + parameter on `SessionEngine` | The line in `session_controller.dart` that passes it | Pause cap was always infinity |
| Battery alert `_messaging` field plumbed for simulation | Battery code read `messagingServiceProvider` directly anyway | Battery alert SMS bypassed the simulation swap |
| `TimerDisarmTrigger` model + JSON serialization | `TriggerManager.start()` never iterated disarm triggers | Timer-based disarm silently did nothing |
| `appPinHash`, `duressPinHash`, `sessionEndPinHash` removed from `AppSettings` | `PinEntryScreen` / `PinSetupScreen` still existed and looked complete | PIN UI rendered, captured input, persisted nowhere |
| `EventStrategyRegistry._map` registered 6 of 9 strategies | Three `ChainStepType` values had no registration | Runtime `ArgumentError` when those step types fired |

**Lesson:** Unit tests verify components. Integration tests verify
connections. v2 had 900+ unit tests and ZERO integration tests for
"simulation mode uses simulation services" or "field X reaches engine
parameter Y." Every wiring bug above would have been caught by a
single integration test.

### 2.2 Copy-paste adaptation failures

`fake_call_screen.dart` was copied from `old4/`. The Decline button was
updated to fire the distress chain. But the decline-with-distress
*timer callback* in the same file still called `_decline()` (normal
decline). The file looked correct in diff; 95% of it was adapted
correctly; the 5% that mattered most was missed.

**Lesson:** Wholesale file copy from `old*/` is forbidden. Re-implement
from the current spec even if the pseudocode looks identical.
(Per `docs/rebuild-strategy.md` L4.)

### 2.3 Spec gaps that became code gaps

Spec said WHAT, not WHERE or HOW. Implementer guessed and guessed wrong.

- "Auto-disarm silently when a real call ends during a fake call" — spec
  did not say which layer owns this check. Result: the incoming-call
  listener *resumed* instead of disarming.
- "Hardware button is either a step OR a distress trigger, not both" —
  spec did not say the validator must enforce this. Result: no
  validation, users could configure both.
- "Background speed cap is 1x–60x; foreground 1x–1000x" — spec did
  not say how the engine distinguishes foreground vs background.
  Result: single 1000x cap for everything.

**Lesson:** Specs need code locations. Every normative spec line
needs an owner (file + class + method). The wiring map closes
this gap.

### 2.4 Parallel-agent communication failures

Agent A built `SimulationPhoneService` and `PhoneServiceProtocol`.
Agent B built `SessionController`. Neither created the line that
injects one into the other. Each agent verified their own work
compiled — no agent owned the seam.

Agent A built `distress_confirmation.dart` with hardcoded English
text. Agent B added the l10n keys to `app_en.arb`. The widget never
imported or used the keys.

**Lesson:** When the seam between two agents is implicit, the seam
is missing. Make it explicit (wiring map row) or serialize the
agents. (Per `feedback_parallel_agents.md` + 
`feedback_parallelism_default_sequential.md`.)

### 2.5 Verification timed at the end, not per-phase

Phase 1–8 ran `flutter analyze` + `flutter test`. None ran spec-
compliance verification. The single final audit at the end found
2 critical, 5 high, 10 medium bugs — and fixing them required
re-reading eight phases of accumulated code.

**Lesson:** Each phase must end with a spec-compliance check
scoped to that phase. The final audit should find nothing new.
(Per `docs/rebuild-strategy.md` L7.)

### 2.6 Native code "done" in Dart, broken on device

`SmsWorker.kt`, `CallStateChannel.kt`, and friends existed but were
exercised only by fakes in unit tests. On real devices:
- `NotificationService.init()` was never called from `main.dart`
  (`remaining-gaps.md` GAP-13).
- SMS retry queue used `url_launcher` to fire SMS intents instead
  of the direct platform channel, so automatic escalation opened
  the SMS composer and waited for a human tap.

**Lesson:** "Done" requires one real-device end-to-end run.
Platform-channel methods must be exercised by an integration test
or a manual smoke run, not only by fakes. (Per
`docs/rebuild-strategy.md` L10.)

### 2.7 Hot-spot files shared across agents

`session_controller.dart`, `step_config.dart` (then `event_specific_config.dart`),
and `service_providers.dart` were each edited by 3+ agents in
parallel. `session_controller.dart` ended up with two `startSession()`
method bodies that had to be merged manually.

**Lesson:** File-level ownership is mandatory. One agent per file
per phase. Cross-cutting edits get serialized through the owner.
(Per `docs/rebuild-strategy.md` L5.)

### 2.8 Translations queued as "do at the end"

Every feature added 2–8 new ARB keys. By the end there were
hundreds of untranslated keys; non-English users saw silent
English fallback mid-screen. Adversarial review caught this in
v4 and v5 — but each time the backlog had grown.

**Lesson:** Translation is part of "done" for any user-facing
change. CI must fail when a non-English ARB lacks a key present
in `app_en.arb`. (Per `feedback_language_agent_on_change.md`.)

### 2.9 Controllers hardcoded fakes instead of reading providers

`SessionController` lines 59–96 (in v2) instantiated
`FakeMessagingService`, `FakePhoneService`, etc. directly while
the controller author waited on the service agent. The service
agent finished. Nobody revisited the controller. **Real sessions
never sent SMS, never called contacts, never played alarms.**

**Lesson:** Stubs that silently succeed are worse than missing
features. Every stub must throw `UnimplementedError` with a
specific message, or be gated behind a test-only constructor that
production code cannot reach. (Per `feedback_rewrite_process.md`
rule 5 + `docs/rebuild-strategy.md` L14.)

---

## 3. What worked in v2 — patterns to keep

These are the survivors. They earned their place. v3 should keep them.

- **Pure-Dart `SessionEngine`** — no Flutter dependency, sealed
  `EngineState` hierarchy, stream of `ChainEventData`. Lets you
  test the state machine with `fakeAsync` and a `_FixedRandom`
  helper, deterministically. Huge productivity win for engine
  tests. (See `CLAUDE.md` "Core domain: SessionEngine".)

- **Event strategy registry** (`lib/features/session/event_strategies/`)
  — one `EventStrategy` per `ChainStepType` with `executeReal()` and
  `simulationDescription()`. Replaced scattered switch statements in
  `SessionController._executeStepAction()` and
  `_emitSimulationToast()`. Per `event_strategy_design.md`.
  **Caveat:** v2 had the bug of registering only 6 of 9 strategies
  — v3 must enforce exhaustiveness (sealed switch over enum, or
  a test that iterates all enum values).

- **Service triplet** (`Real…Service`, `Simulation…Service`,
  `Fake…Service`) with a `…ServiceProtocol` interface. Riverpod
  provider chooses at runtime. **Caveat:** v2 forgot to actually
  inject the Simulation variant. Wiring map closes this.

- **`package:checks`** for assertions over default matchers
  (per `CLAUDE.md` Testing section). More expressive, fewer
  generic-matcher footguns.

- **`fake_async`** for timer-driven tests + `_FixedRandom` (returns
  0.5) to eliminate jitter non-determinism in engine tests.

- **ARB fan-out via parallel language agents** — when it
  *actually* ran on every string change. The 13 non-English ARBs
  live in disjoint files, so they ARE a legal parallel batch.

- **Strict analysis (`strict-casts`, `strict-inference`,
  `strict-raw-types`) + lefthook pre-push (`flutter analyze` +
  `flutter test`)** — caught drift early. Keep this.

- **CI dep-audit for discontinued packages** with hard fail
  (`.github/workflows/ci.yml`). Caught `golden_toolkit` and
  `sqlcipher_flutter_libs` while they were still cheap to swap.

- **`docs/wiring-map.md` + `test/wiring/wiring_map_coverage_test.dart`**
  — checked-in artifact, test verifies every row maps to a real
  provider, every provider has a row. This is the formalized fix
  for the v2 wiring catastrophe. Keep this pattern; expand it.

- **Phase-checkpoint git commits** (`phase-01/foundation-scaffold`,
  `phase-02/types`, …, `phase-16/verification`). One commit per
  phase, clear rollback points. Keep this discipline.

---

## 4. Process rules for v3

These are the operating rules. Each cites the memory file it
came from so you can audit later.

### 4.1 Spec → test → code, every time

Per `feedback_rewrite_process.md` rule 1:

- Every numbered spec section gets at least one **failing**
  integration test before any implementation exists.
- Tests are written against the public API (engine methods,
  controller methods) and initially fail.
- Implementation makes them pass.
- Stubs (`UnimplementedError`) keep code honest while tests
  are still red.

This inverts the v2 anti-pattern where tests were written to
match what the code already did — which proved nothing and
caught no missing features.

### 4.2 Wiring map is a mandatory artifact

Per `feedback_rewrite_process.md` rule 2 +
`docs/rebuild-strategy.md` L11:

Before any feature is coded, fill in:

```
Model Field          → Constructor Param    → Controller Line
SessionMode.maxPause → SessionEngine(maxP:) → session_controller:104
AppSettings.duressPinHash → PinDialog(hash:) → pin_entry:84
```

Empty cells are forbidden. v2 kept the wiring map as
`docs/wiring-map.md` with a coverage test
(`test/wiring/wiring_map_coverage_test.dart`) that asserts every
row maps to a real provider binding. **Continue this. Expand it.**

### 4.3 Default to sequential agent dispatch

Per `feedback_parallelism_default_sequential.md`:

Before launching two agents in parallel, enumerate:

- (a) files each will write — must be fully disjoint;
- (b) shared artifacts either might write — ARB files,
  `wiring-map.md`, `decisions-log.md`, provider-registration
  files — these break orthogonality even if main work files
  differ;
- (c) shared mutable state — singleton configs, test helpers,
  route tables.

**If any of (a), (b), (c) is shared: serialize.** Do NOT try to
"carefully coordinate" parallel agents around shared seams.

Legal parallel examples:
- Different language ARB files (13 locales).
- Android native ∥ iOS native (disjoint platform trees).
- Source + docs where the docs agent only reads code.

Illegal-looking-legal examples:
- "Different screens" — often share controller reads + ARB +
  wiring-map.
- "Different services" — register in the same provider file.
- "Different test files" — share `test/helpers/test_helpers.dart`.

### 4.4 Connected code is sequential, with hand-off contracts

Per `feedback_rewrite_process.md` rule 4 + the v2 postmortem
section "Agent communication failures":

- Services + controller + screens MUST be sequential.
- Each agent writes a CONTRACT before handing off: "Session
  controller MUST read `simulationMessagingProvider` when
  `isSimulation=true`."
- The next agent reads the contract and verifies it on completion.
- Only truly independent work (models vs theme, engine vs UI
  tests) gets parallelized.

### 4.5 Integration tests at EACH phase, not at the end

Per `feedback_rewrite_process.md` rule 3 +
`docs/rebuild-strategy.md` L7:

After every phase, add (and run, and keep green) end-to-end
flow tests:

- Full walk-mode flow: start → hold → release → grace → disarm.
- Full simulation flow: start → speed 10x → SMS step → sim_blocked.
- Distress flow: hardware panic → confirmation → chain replacement.

These run at every subsequent phase and catch regressions.

### 4.6 Stub detection: silent success is forbidden

Per `feedback_rewrite_process.md` rule 5 +
`docs/rebuild-strategy.md` L14:

- Empty method bodies MUST throw
  `UnimplementedError('TODO: wire to messaging service')`.
- Or be tested with a test that will fail when the stub is reached.
- Or be annotated as `@mustBeOverridden` or similar.

A TODO comment alone is INSUFFICIENT. "Code exists but does
nothing" must be impossible to ship.

### 4.7 Single "wiring owner" agent

Per `feedback_rewrite_process.md` rule 6:

One agent across the entire rewrite whose ONLY job is:

- Don't write features.
- Review every phase for: Are all new providers used? Are all
  new fields threaded through? Are all new screens wired to
  the router? Are all new strategies registered?
- Maintain the wiring map.
- Write the integration tests.

This agent doesn't have a feature backlog. It has a connection
backlog.

### 4.8 ARB fan-out: 13 parallel language agents per string change

Per `feedback_language_agent_on_change.md`:

Every change that adds or modifies user-facing strings MUST
end with a language-agent fan-out:

- Diff `app_en.arb` against the 13 non-English files.
- Translate every missing/changed key.
- Preserve placeholders (`{length}`, `{name}`, `{seconds}`) exactly.
- Brand names ("Guardian Angela", "Duolingo") stay in Latin script.
- Safety-critical strings prioritize clarity over elegance.
- Run `flutter gen-l10n`; verify zero untranslated-message warnings.

This is the canonical legal-parallel batch — 13 disjoint
files, no shared state, no shared artifact. Always parallel.

### 4.9 Flutter test concurrency

Per `feedback_test_concurrency.md`:

- Default: `flutter test --concurrency=6` (12-core box; 6 keeps
  half free for OS + IDE).
- When other agents are also running `flutter test`: drop the
  flag and run serially. 5 background agents × 6 each saturates
  the box and makes every run slower than serial.

Before invoking `flutter test`, check if any background-launched
agents are running test suites.

### 4.10 Pre-alpha policy: nuke and re-seed

Per `project_prealpha_break_compat.md`:

- **Break schemas freely.** No JSON-fallback paths. No preserved
  removed fields. No `fromJson` branches for old shapes.
- **No `@Deprecated` shims.** Delete removed code; update or
  delete tests that referenced it.
- **No "legacy" / "migration" code** in models, services, or
  repositories unless the product owner explicitly asks.
- **No CHANGELOG.md.** Scratch repo. Use TaskCreate/TaskUpdate
  for orchestration state and `git log` for history.

Reopen this policy at first beta release.

### 4.11 Interruption-resilient task ledgers

Per `feedback_interruption_resilience.md`:

Long multi-agent runs (50+ tool uses) hit rate limits. Don't
use a `CHANGELOG.md` — use TaskCreate / TaskUpdate / TaskList
as the checkpoint journal.

- Before launching a batch, create a task with subject + short
  description.
- Each agent's task description is the checkpoint: what they're
  doing, which files they own, next step.
- On spawn, mark `in_progress` with ownership notes.
- On each substantive step, TaskUpdate the description to
  reflect progress.
- On interruption / rate-limit, a fresh orchestrator reads the
  task list first, sees `in_progress` + ownership, verifies on
  disk, resumes or re-spawns.
- Cap agents at ~30 tool uses per spawn. Bigger tasks split
  into sequential agents with explicit handoff.
- Atomic writes for multi-section docs: write to `foo.md.tmp`,
  rename.

### 4.12 Always include motivation in specs and questions

Per `feedback_motivation_in_specs.md`:

- Every normative spec entry (MUST/SHOULD) gets a "Why:" line
  that names the threat / user need / trade-off.
- Every decision question option gets a description explaining
  WHY someone might pick it.
- Defaults that look conservative ("off by default") need
  justification too — not just "safer", but "safer because X".
- When the answer is "do nothing", the motivation is "the threat
  doesn't exist for our model" — say so.

Concrete past example: a security FLAG_SECURE proposal was
shipped without motivation; the user pushed back ("nothing here
is sensitive") and couldn't evaluate without knowing the threat
(recents-thumbnail leak, screen-recording capture).

### 4.13 Hard fail on legacy identifiers, l10n drift, exhaustiveness gaps

Per `docs/rebuild-strategy.md` L2, L6, L9:

- CI grep-check on a list of forbidden legacy identifiers (e.g.,
  `repeatCount` after rename to `retryCount`,
  `DistressChain` after removal). Hard fail.
- CI l10n-parity check: every non-English ARB must have every
  key from `app_en.arb`. Hard fail.
- CI dep-audit: any direct dep with `isDiscontinued: true`
  must be swapped in the same cycle. Hard fail.
- Every dispatch table indexed by an enum has a test that
  iterates the enum values and asserts each is handled. Better:
  use a Dart sealed class or switch expression that the compiler
  verifies exhaustive.

---

## 5. Architectural decisions that should carry over

These are settled. v3 starts with them; don't relitigate.

### 5.1 Distress IS a Mode (unified data model)

Per `project_distress_is_mode.md` (decided 2026-04-26, Q52):

- **There is no `DistressChain` class.** Do not create one.
- One model: `Mode` (rename from `SessionMode` if helpful).
  Holds: `id, name, chain, distressModeId (String?), disarmTriggers,
  pauseAllowed, maxPauseMinutes, modeOverrides`.
- `Mode.distressModeId` references another `Mode` by id; null
  inherits from `AppDefaults.defaultDistressModeId`.
- `AppDefaults.distressChains: List<DistressChain>` becomes
  `AppDefaults.defaultDistressModeId: String?`.
- ModeEditor is a single editor. A "Distress" section picks
  `distressModeId` from any saved mode.
- "Make distress chain" UX = duplicate-as-new-mode + set as
  distress for the source mode.
- `disarmTriggers` / `pauseAllowed` / `maxPauseMinutes` are
  ignored at runtime when a mode is invoked AS the distress
  (engine does not auto-disarm a distress chain).
- `ModeOverrides.distressChainId` field also deleted.

**Override resolution for any `ChainStep`'s runtime config:**

1. `step.config` (innermost; wins if non-null).
2. `mode.modeOverrides.eventDefaults[step.type]` (mode-level
   override, if set).
3. `AppDefaults.eventDefaults[step.type]` (global default).

### 5.2 No session restore from disk

Per `feedback_no_session_restore.md`:

- Session state is **in-memory only**.
- `SessionLog` is one atomic write at the moment `sessionEnded`
  is emitted. Nothing partial.
- `WalkSession` is ephemeral; not persisted.
- App lifecycle observer does NOT checkpoint mid-session state.
- No `bootRestart` / `appRestored` / `appTermination`
  `PauseReason` or `EndReason` values.
- No code that scans Hive/Drift on launch for open sessions.
- Spec 01 MUST state this explicitly under §Engine API and
  §Lifecycle.

Rationale: complicates state management, opens forensic-leak
surface (encrypted DB stores partial distress state), breaks
the "session = single contiguous in-memory run" engine invariant.

### 5.3 FakeCall is an event, not a pause

Per `feedback_fakecall_not_pause.md`:

- The fake-call step OVERLAYS the session UI but does NOT pause
  the engine timer.
- The engine timer keeps running while `FakeCallScreen` is on screen.
- There is NO `fakeCallAnswered` `PauseReason`.
- Pause reasons are ONLY: `userRequested` (explicit Pause tap)
  and `incomingCall` (real OS-level incoming call).
- `FakeCallScreen` is a route push, not a pause-and-overlay.

Rationale: pausing for the fake call would break escalation
timing and let an attacker stall the chain by triggering a fake
call. The fake call IS the event.

### 5.4 Minimize false positives, above all

Per `feedback_false_positives.md` + `project_rewrite_decisions.md`:

- Grace periods generous, not tight.
- Retry counts generous, multiple chances.
- Auto-pause on real phone calls.
- Snooze/extend is a first-class feature.
- Hold-button sensitivity defaults minimize accidental releases.
- `declineIsSafe = true` default for Walk Mode (declining the
  fake call = user is fine).
- Emergency calls prefer user confirmation (Date Mode
  `showConfirmation = true`).
- **When in doubt, repeat the current step rather than advance.**

Rationale: a false 112 call has real consequences. False alarms
erode trust; users stop using the app. Safety apps die from
false positives faster than from false negatives.

### 5.5 PIN as speed bump

Per `project_rewrite_decisions.md`:

- Critical actions (disarm, end session, Quick Exit) require PIN
  if configured.
- 10s timeout. Correct PIN → action cancelled. Timeout → action
  continues.
- Quick Exit requires PIN if configured. Then cancel everything
  (total wipe).
- App crash = session lost. No checkpoint, no resume. (Restates
  5.2.)

### 5.6 Shake-to-SOS is NEVER a feature

Per `project_rewrite_decisions.md`. Add to spec explicitly so a
future agent doesn't propose it. Accelerometer triggers are
permanently off the table.

### 5.7 Hard-coded distress invariants

- Disarm during duress: hard-coded IGNORE. Non-negotiable.
- Distress chain REPLACES main chain. No sub-chains. No going back.
- Three distress triggers: hardware panic (5x volume), wrong-PIN
  threshold, duress PIN. No more.

### 5.8 Simulation defense-in-depth

- Separate `SimulationMessagingService` / `SimulationPhoneService`
  subclasses, not `if (isSimulation) return;` branches inside the
  Real services. (The v2 bug was forgetting to inject the
  simulation subclass — the bug was wiring, not architecture.)
- No "GO LIVE" button mid-simulation. Too dangerous.
- Stealth simulation mode has its own SIM watermark; no orange
  border.
- Simulation runs in background like a real session.

---

## 6. Anti-patterns to avoid

Things previous sessions did, the user corrected, and v3 must
NOT repeat.

### 6.1 Maintaining a `CHANGELOG.md` in pre-alpha

Per `project_prealpha_break_compat.md` +
`feedback_interruption_resilience.md`. Don't. Use git log + task
ledgers. The CHANGELOG was explicitly rejected.

### 6.2 Coordinating parallel agents through shared edits

If two agents are about to write into the same file (even
"different sections"), they will conflict. The fix is NOT to
"carefully coordinate" — it's to serialize them. Per
`feedback_parallelism_default_sequential.md`.

### 6.3 "Different screens" as a parallel-safe excuse

Different screens share: a controller, a provider file, an ARB
file, the wiring map, sometimes route tables. "Different
screens" is NOT orthogonal by default. Per
`feedback_parallelism_default_sequential.md`.

### 6.4 Copy-pasting from `old*/` directories

`old/`, `old2/`, …, `old6/` are reference material for
discussion. Never source of truth. Re-implement from spec.
Per `docs/rebuild-strategy.md` L4.

### 6.5 Shipping security features without a threat model

Per `feedback_motivation_in_specs.md`. The FLAG_SECURE incident:
proposed without motivation; user couldn't evaluate; pushed
back. Every security feature gets a Why line naming the actual
threat.

### 6.6 Adding a feature without thinking about false positives

Per `feedback_false_positives.md`. Every new escalation path
must answer: "What's the false-positive cost? Does this add
ways the chain fires when the user is fine?"

### 6.7 Auto-pausing on fake-call answer

Per `feedback_fakecall_not_pause.md`. The fake call is an event,
not a pause. Don't add `fakeCallAnswered` to any pause-reason
enum, ever.

### 6.8 Adding "resume from disk" code

Per `feedback_no_session_restore.md`. Don't write
`appRestored` / `appTermination` reasons. Don't add a launcher
scan for open sessions. App-death = session is gone, period.

### 6.9 Deferring translations to "the end"

Per `feedback_language_agent_on_change.md`. The 40–150 key
backlog has repeatedly bottlenecked release. Fan out language
agents in the same session as the English change.

### 6.10 Stubs that silently succeed

Per `feedback_rewrite_process.md` rule 5 +
`docs/rebuild-strategy.md` L14. An empty method body in a
service is worse than a missing method — it advertises
functionality that doesn't exist. Throw `UnimplementedError`
or write a failing test.

### 6.11 "Test count" metric drift

Per `docs/rebuild-strategy.md` L13. Two verification agents
reported 4789 vs 4818 tests for the same commit. Cause:
different counting methods (`--reporter expanded` vs grep).
Fix: `docs/baseline.md` is the single source of truth for
metrics; CI updates it on every green build; agents READ it,
never compute their own.

### 6.12 Treating "looks right in diff" as "is right"

The v2 fake-call decline bug looked right in diff. So did the
"PIN UI exists but `appPinHash` doesn't" bug. So did the
"6-of-9 strategies registered" bug. Diff review is necessary
and insufficient. The wiring map + integration tests catch
what diff review cannot.

---

## 7. The one-paragraph summary

The v2 bugs were not design bugs. They were **wiring bugs**:
right components, wrong connections. Preventing them requires
(a) a wiring map filled in before code is written,
(b) integration tests at every phase that exercise the connections,
(c) sequential agent dispatch as the default with explicit
written contracts at every hand-off,
(d) a single wiring-owner agent who reviews connections rather
than writing features,
(e) hard-failing CI on l10n drift, legacy identifiers, exhaustiveness
gaps, and discontinued deps,
(f) language fan-out in the same session as every string change,
(g) atomic refactors with no migration shims (pre-alpha),
(h) task-ledger checkpointing instead of trusting agent memory.

Combined with the carry-over architectural decisions (distress=
mode, no session restore, fakeCall is event not pause, minimize
false positives, PIN as speed bump), v3 has a fighting chance at
shipping connected code instead of a beautifully-tested pile of
disconnected components.

---

## 8. Where to look next

- `CLAUDE.md` (project root) — current architecture conventions.
- `docs/spec/*.md` — current spec (read after this file, not before).
- `docs/rebuild-strategy.md` — the long-form version of this file
  with L1–L14 lessons and 10-phase rewrite plan.
- `docs/review/postmortem-v2-rewrite-bugs.md` — the source of
  every "what broke in v2" claim above.
- `docs/wiring-map.md` + `test/wiring/wiring_map_coverage_test.dart`
  — the v2 fix for the wiring catastrophe. Pattern to keep.
- `~/.claude/projects/-home-jonas-Documents-software-android-safetyapp1-guardianangela/memory/`
  — all the `feedback_*.md` and `project_*.md` files cited above.
  Authoritative source for every rule in this document.
