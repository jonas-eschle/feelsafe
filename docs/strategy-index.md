# Guardian Angela — Strategy & Planning Documents

Start here. These documents are the canonical reference for the Guardian
Angela rewrite. Read in order on first visit, then jump by topic.

## Document hierarchy

1. **[decisions-log.md](./decisions-log.md)** — Canonical record of every
   resolved, open, rejected, and superseded decision. **Read first.**
   Every binding choice (storage, platform floor, coverage target, iOS
   entitlements, etc.) is recorded here with a `D-CATEGORY-N` ID. Cite
   the ID when implementing ("per D-PLATFORM-1, use Drift").

2. **[architecture-sketch.md](./architecture-sketch.md)** — The shape of
   the code: 6 layers, directory tree, 19 models, 9 strategies, 15
   services, 29 routes, pinned dependency list with rationale. **Read
   second.** When writing code, start here to know where it goes.

3. **[rebuild-strategy.md](./rebuild-strategy.md)** — How to execute
   the rewrite end-to-end. 10 numbered phases with entry/exit criteria,
   time estimates, risks, and accepted risks (Ask-for-Angela trademark,
   Play-SMS review, translation lag, iOS 17 floor). **Read before
   starting each phase.**

4. **[test-strategy.md](./test-strategy.md)** — 99%+ coverage policy,
   149 `TEST-###` scenarios, patrol + Maestro + Appium E2E stack, full
   golden coverage across 5-device matrix, strict pixel-match review
   workflow. **Read when writing tests.**

5. **[audit-spec-vs-code.md](./audit-spec-vs-code.md)** — Snapshot of
   the pre-rewrite spec↔code drift. Eight spec fixes were applied;
   six architectural ambiguities recorded and now resolved via
   decisions-log. **Read for archaeology — not normative for the
   rewrite.**

6. **[interruption-resilience-strategy.md](./interruption-resilience-strategy.md)**
   — Checkpoint + resume protocol for long multi-agent sessions so
   rate-limits don't erase progress. **Read before launching any
   multi-hour agent orchestration.**

## When in doubt

- **Architecture question** ("where does this live?") → architecture-sketch.md
- **"Should we X?"** (policy or product choice) → decisions-log.md (search the topic)
- **How to implement phase N** → rebuild-strategy.md §Phase N
- **Is this behavior tested?** → test-strategy.md Coverage Matrix (§9)
- **Am I allowed to X?** → decisions-log.md — REJECTED section
- **An agent just crashed, what now?** → interruption-resilience-strategy.md §Recovery Protocol

## Glossary shortcut

- **D-ID** — decision identifier in `decisions-log.md` (e.g., D-PLATFORM-1)
- **TEST-###** — test-scenario identifier in `test-strategy.md`
- **Phase N** — rewrite phase in `rebuild-strategy.md`
- **Layer L-X** — architectural layer in `architecture-sketch.md`
- **DE-N** — Deferred Enhancement, now all scheduled for v1 (see D-META-NEW-1)

## Status

- **As of:** 2026-04-20
- **Baseline code state:** 4818 tests passing, 0 analyze issues,
  `flutter build appbundle --debug` succeeds
- **Decisions:** 163 resolved, ~28 new decisions added from latest Q&A
  rounds (Argon2id, Sentry, GitHub Actions + Firebase Test Lab, all
  DE-1..4 shipping in v1, TTS-only voice for v1, no auto-resume, iOS
  Critical Alert at v1, Strict-pixel-match golden, etc.), with a
  handful of OPEN items tracked at the bottom of `decisions-log.md`
- **Rewrite status:** NOT YET STARTED. Documentation phase complete.
  Product owner may review the 6 docs + the `decisions-log.md`
  "OPEN questions" section before authorizing Phase 1 of the rewrite.

## Change tracking

Pre-alpha, scratch repository. No changelog maintained — use
TaskCreate/TaskUpdate for in-flight orchestration state and `git log`
for historical context.

## Compatibility

**Pre-alpha / first version. No users.** Break any compatibility
freely — no migrations needed, no backward-compat shims, no legacy
field preservation. Every design iteration may nuke on-disk data.

## READY FOR REWRITE PLANNING REVIEW
