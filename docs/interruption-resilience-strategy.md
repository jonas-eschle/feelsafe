# Guardian Angela — Interruption Resilience Strategy

> **Status:** ADVISORY. Describes HOW multi-agent orchestrations for
> Guardian Angela (rewrite planning, spec consolidation, audit sweeps)
> SHOULD survive rate-limits, timeouts, and user interruptions without
> losing work or requiring a full rediscovery of state. Key words MUST,
> SHOULD, MAY follow RFC 2119.

---

## 1. Problem statement

Long-running agent tasks in this repository have failed the same way
repeatedly. The two dominant failure modes are:

1. **Rate-limit truncation.** Anthropic's per-organization rate limiter
   interrupts agents mid-tool-call once they accumulate 50-150 tool
   uses in a short window. The agent's summary message never reaches
   the caller; file writes that did complete stay on disk, but nothing
   tells the orchestrator what was done and what was in-flight.
2. **User interruption (ESC / "stop").** The operator cancels an agent
   that is mid-multi-file edit. Some files are updated; others are
   stale. Some decisions were made verbally in chain-of-thought but
   never persisted. The next agent has no way to tell what was decided.

### Observed incidents in this repo

- **2026-04-20: Consistency agent (56 tool uses).** An agent tasked with
  propagating ~28 new decisions across `decisions-log.md`,
  `rebuild-strategy.md`, `test-strategy.md`, `architecture-sketch.md`,
  and creating a new `strategy-index.md` was rate-limited on the last
  step. The propagation work landed; `strategy-index.md` was never
  created. The orchestrator had no trail — reconstructing "done vs
  not-done" required diffing every affected file against the pre-agent
  git SHA. See `CHANGELOG.md` entry for 2026-04-20 10:54 UTC.
- **v2 rewrite postmortem** (`docs/review/postmortem-v2-rewrite-bugs.md`).
  Parallel coding agents each built one layer; nobody owned the seams
  between layers. Interruption of the wiring agent was indistinguishable
  from its successful completion, because there was no journal of
  which seams had been wired.
- **Spec-drift during rename operations** (`docs/rebuild-strategy.md`
  L2). A half-completed rename propagation left the repo with both
  old and new identifiers; the next agent assumed the rename was
  finished and introduced inconsistent third references.

### Root cause

Claude agents have **no persistent runtime between invocations**. The
only carryover is the filesystem and git. Without an explicit journal
on disk, "what got done" lives only in the agent's last message —
which is also the thing a rate-limit destroys.

This strategy treats the filesystem as the **single source of truth
for progress**, applying the same write-ahead-log (WAL) and
durable-execution principles Temporal.io, PostgreSQL, and LangGraph
use for the same problem class.

---

## 2. Principles

These ten principles are MANDATORY for any agent-driven task in this
repo that is expected to exceed 10 tool uses or touch more than 2 files.

1. **Checkpoint after every completed side-effect.** Record the
   previous action as finished before starting the next. If the
   agent dies between steps, the journal tells the successor what
   not to redo.
2. **No work without a write.** Decisions held only in chain-of-
   thought do not exist. Writing to disk creates durable state;
   plans in the final message are lost on rate-limit.
3. **Idempotent operations wherever possible.** Prefer "replace
   block X with Y" over "append Y after X." A resume agent running
   the same action twice MUST NOT corrupt state.
4. **Single source of truth for "what's done."** Exactly one file
   (`CHANGELOG.md`) is authoritative. No parallel progress files;
   successors look in one place.
5. **Resume-by-reading, not by-remembering.** Every agent spec MUST
   begin with "read `CHANGELOG.md` top block first." Orchestrator
   summaries of prior work are lossy and not trusted.
6. **Declare before you act.** Append an `in-flight:` line to the
   journal BEFORE the side-effect. Flip to `done:` after. An
   `in-flight:` at the top is the signal "interrupted — verify or
   redo."
7. **Name every file you will touch.** Journal the blast radius at
   the top of the entry so successors know what to inspect on
   resume.
8. **Split, don't stretch.** If a task exceeds 30 tool uses, split
   it. Three 50-turn agents beat one 150-turn agent every time,
   because the 150-turn agent will hit the rate limiter.
9. **Atomic writes for multi-section files.** Larger-than-one-line
   edits write to `<file>.tmp` and rename. A kill mid-write SHALL
   NOT produce a half-written file.
10. **Commit at phase boundaries.** At every clean phase end, create
    a git commit named `checkpoint: <phase> — <status>`. `git log`
    then indexes `CHANGELOG.md` at coarse granularity.

---

## 3. Concrete mechanisms

### 3.1 `CHANGELOG.md` — the checkpoint journal

**Location.** Single file, repository root: `/CHANGELOG.md`. For long
sessions that would balloon the root file beyond ~500 lines, agents
MAY roll daily chunks into `docs/changelog/YYYY-MM-DD.md` and leave
only a pointer-line in the root file. The root file MUST always exist
and MUST always contain the most recent in-flight/done entries.

**Format.** Newest-first reverse-chronological, following the Keep a
Changelog spirit but with statuses adapted for agent checkpointing.
Each entry is one line:

```
[YYYY-MM-DD HH:MM UTC] <status>: <scope> — <detail>
```

Statuses (exhaustive):
- `done:` — the action completed and the side-effect is visible on disk.
- `in-flight:` — the action was started; completion not yet confirmed.
  A successor agent MUST verify this line against disk before continuing.
- `blocked:` — the action was attempted but cannot proceed (e.g., needs
  human decision). Includes a pointer to what unblocks it.
- `note:` — observation; does not count as a checkpoint.

Entries are grouped under ISO-date headings (`## 2026-04-20 — Session
topic`), newest session first. Within a session, newest action first.

**Example (lifted from the current repo):**

```markdown
## 2026-04-20 — Strategy docs suite + interruption resilience

- [2026-04-20 11:00 UTC] done: CHANGELOG.md — created, seeded.
- [2026-04-20 10:58 UTC] done: strategy-index.md — written by
  orchestrator after the consistency agent was rate-limited.
- [2026-04-20 10:55 UTC] in-flight: interruption-resilience-strategy.md
  — research agent spawned. Verify file exists, ~2500-4000 words.
- [2026-04-20 10:54 UTC] done: decisions-log.md — 28 new decisions
  propagated (Argon2id, Sentry, Drift, iOS 17+, ...).
- [2026-04-20 10:30 UTC] done: rebuild-strategy.md — updated to Drift.
```

**Resume semantics.** On resume, a successor agent:

1. Reads the first block of `CHANGELOG.md`.
2. If the top entry is `in-flight:`, it treats that action as the one
   to complete or redo. It verifies against the filesystem:
   - If the file exists and looks complete, flip the line to `done:`
     and continue with the next planned action.
   - If the file does not exist or is half-written, redo the action
     from scratch (leveraging idempotency, Principle 3).
3. If the top entry is `done:`, it proceeds with the next planned
   action from the orchestrator's resume prompt.
4. If the top entry is `blocked:`, it stops and reports; no action.

### 3.2 Agent-prompt preamble for interruption awareness

Every long-running agent spec MUST include the following preamble,
copy-pasted verbatim (template in section 5.2):

> **Before you begin:** Read `CHANGELOG.md` top block. If an entry is
> `in-flight:`, verify it against the filesystem and either flip it
> to `done:` or redo it. Do not start new work until the journal is
> consistent with disk.
>
> **For every substantive write:**
> 1. Append an `in-flight:` line to `CHANGELOG.md` naming the file and
>    the action BEFORE you perform the action.
> 2. Perform the action.
> 3. Flip the line to `done:` (Edit the same line, do not append a
>    second line).
>
> **At the end of the task:** Append a `done:` summary line naming
> every file you touched. If you ran out of budget before finishing,
> leave the final action as `in-flight:` and end with a `note:` line
> describing exactly what remains so a successor can resume.

Agents MUST NOT skip the journal entry because "it was a small edit."
Consistency of the journal is what makes resume safe.

### 3.3 File-ownership manifest

For any orchestration that spawns two or more parallel agents, the
orchestrator MUST publish a file-ownership manifest before spawning.
The manifest lives either:

- Inline in `CHANGELOG.md` as a `note:` block at the top of the
  session heading, OR
- As a section in `docs/ownership.md` for longer-lived ownership
  (e.g., "agent A owns all files under `docs/spec/`").

**Format:**

```markdown
### Ownership — 2026-04-20 10:30 UTC

- agent-A (research): docs/interruption-resilience-strategy.md
- agent-B (consistency): decisions-log.md, rebuild-strategy.md,
  test-strategy.md, architecture-sketch.md
- agent-C (indexer): strategy-index.md, README.md
```

**Rule.** Two agents MUST NOT hold write ownership of the same file
in the same session. If a manifest entry would collide, the
orchestrator serializes (run B after A) or splits the file into
distinct regions owned separately. This is the same principle as
Guardian Angela's code-level wiring map (`docs/rebuild-strategy.md`
L11): explicit ownership prevents last-writer-wins bugs.

On resume, the manifest tells the successor "agent B was running when
the kill hit — its files are: ...; diff them against the last known
clean SHA to see what's half-done."

### 3.4 Atomic writes pattern

Only applies to files larger than a single-line edit where a
mid-write crash could leave the file in a syntactically invalid or
partially-consistent state. For a Flutter/Dart repo, this primarily
means: generated files, large markdown docs, JSON configs, and
Drift/Hive schema dumps.

**Pattern (shell, usable by agents via Bash tool):**

```bash
# write new content to a sibling tempfile
echo "$CONTENT" > docs/spec/03-data-models.md.tmp
# fsync-equivalent: make sure the write has hit disk before rename
sync docs/spec/03-data-models.md.tmp || true
# atomic rename within the same filesystem replaces the target
mv docs/spec/03-data-models.md.tmp docs/spec/03-data-models.md
```

**Pattern (via the Write tool).** The Write tool already performs a
single-file-replacement operation, but a kill between its invocation
and its commit is observationally atomic from the shell's point of
view. For Edit tool chains that perform many sequential edits on the
same file, bundle them into a single Write if possible, or create
intermediate checkpoints in the journal so a resume agent knows
which edits landed.

**When to skip atomicity.** For single-line edits, regenerated
artifacts (like `*.g.dart`), or append-only journals (`CHANGELOG.md`
itself), atomic writes are overhead with no benefit. The journal's
worst case is a truncated final line, which is visible and
trivially fixable.

### 3.5 Git checkpointing

Git is the coarse-grained complement to `CHANGELOG.md`: the journal
records every action, commits mark phase boundaries.

**When to commit:**
- End of a logical phase ("decisions propagated to all four docs").
- Before spawning a fresh agent — never spawn with a dirty tree
  unless the new agent is deliberately told to continue an
  unfinished edit.
- Before any risky action (force-push requires explicit user
  request; see `CLAUDE.md` git-safety protocol).

**Commit message format:**

```
checkpoint: <phase-name> — <one-line status>

<optional body listing files affected, cross-ref to CHANGELOG>
```

Example:
```
checkpoint: decisions-propagation — 28 new decisions, 4 docs updated

Affected: decisions-log.md, rebuild-strategy.md, test-strategy.md,
architecture-sketch.md. See CHANGELOG.md 2026-04-20 block.
```

**On resume:** `git log --oneline -n 20` plus the top block of
`CHANGELOG.md` gives the successor agent the entire working context
in two tool calls.

**Precondition.** Agents MUST NOT leave a dirty tree across sessions
with uncommitted work they did not journal. If an agent cannot
commit (e.g., pre-commit hooks fail), it MUST journal the failure
as `blocked:` and stop, rather than leaving ambiguous state.

### 3.6 Tool-use budgeting

The observed rate-limit threshold for this account is roughly 50-75
tool uses in a short window (the consistency agent died at 56).
Anthropic publishes task budget primitives (`max_budget_usd`, token
counters) for agents that can self-limit. The practical rule for this
repo:

- **Soft cap per agent: 30 tool uses.** If the agent is approaching
  30, it MUST stop, checkpoint, and return a resume prompt for a
  successor.
- **Hard cap per agent: 40 tool uses.** No single agent should ever
  exceed 40 tool uses in one invocation. If a task cannot fit, it
  MUST be split at the orchestrator layer.

**Splitting template.** The orchestrator spec for a large task SHOULD
look like:

```
Phase 1 — agent A (budget: 25 tool uses): Propagate decisions 1-14
  into decisions-log.md. End with CHANGELOG entry + git checkpoint.
Phase 2 — agent B (budget: 25 tool uses): Propagate decisions 15-28
  into decisions-log.md. End with CHANGELOG entry + git checkpoint.
Phase 3 — agent C (budget: 20 tool uses): Propagate across the three
  consumer docs. End with CHANGELOG entry + git checkpoint.
Phase 4 — agent D (budget: 15 tool uses): Create strategy-index.md
  based on the now-stable primary docs. End with CHANGELOG entry +
  git checkpoint.
```

This matches the pattern Temporal.io calls "continue-as-new" — a
workflow that clears its history and hands off to a fresh instance
before it exhausts event-history limits.

### 3.7 Recovery protocol

When a rate limit, timeout, or user interrupt hits, the orchestrator
(or the next human invocation) follows this exact sequence:

1. **Check task notification status.** If a background agent exists,
   its completion/failure notification tells you which phase was
   running.
2. **Read `CHANGELOG.md` top block.** Identify the most recent
   `in-flight:` entry if any. That is the action the dead agent was
   mid-execution on.
3. **Verify disk state against the journal.**
   - For `in-flight:` file creations: does the file exist? Is it
     syntactically valid? Does its content match what the journal
     implies (e.g., word count, section count)?
   - For `in-flight:` multi-file propagations: diff every claimed
     target against the last known-clean git SHA. Which ones landed?
4. **Read the source docs that were inputs to the dead agent.** Do
   not trust the dead agent's summary — reconstruct its inputs from
   scratch.
5. **Spawn a fresh agent with a resume prompt** (template in section
   5.3). The resume prompt MUST contain:
   - A pointer to `CHANGELOG.md` and the specific entry to resume from.
   - A statement of what the dead agent was trying to do.
   - A statement of what disk inspection showed already landed.
   - A precise description of what remains.
6. **After the resume agent reports success:** flip the former
   `in-flight:` line to `done:`, append new `done:` lines for what
   the resume agent accomplished, and make a git checkpoint commit.

This is the same shape as Temporal's replay mechanism: on worker
restart, the durable history is authoritative, and the code is
re-driven through it.

### 3.8 Testing the recovery

Resilience never exercised rots. At least once per rewrite cycle, run
a chaos test: spawn an agent on a non-critical task, kill it at ~50%
completion, spawn a resume agent with only the resume-prompt template
and `CHANGELOG.md`, verify the final state matches an uninterrupted
run.

**Known flaky-resume scenarios:**
- **Half-written generated files** (`*.g.dart`). A kill during
  `build_runner` leaves invalid Dart; regenerate on resume rather
  than trusting mid-session artifacts.
- **ARB translations in progress.** A half-done language file may
  mix old and new keys; re-run the full translation for that
  language, not a diff.
- **Decisions-log edits.** The log is append-only in spirit but edits
  can reorder blocks; a resume agent MUST read the tail carefully
  and not assume the last `## ` heading is the current section.

---

## 4. Decision table: when to use which mechanism

| Scenario                          | CHANGELOG | Atomic write | Git commit | Splitting | Manifest |
|-----------------------------------|-----------|--------------|------------|-----------|----------|
| Single-line edit to one file      | no        | no           | no         | no        | no       |
| Multi-section edit to one file    | yes       | yes          | no         | no        | no       |
| Multi-file refactor (3-5 files)   | yes       | yes          | yes        | consider  | no       |
| Long audit (reading 20+ files)    | yes       | no           | yes        | yes       | no       |
| Parallel sub-agents (2+)          | yes       | yes          | yes        | yes       | YES      |
| New file creation, standalone     | yes       | no           | yes        | no        | no       |
| Cross-doc propagation (rename)    | yes       | yes          | yes        | yes       | no       |
| ARB translation sweep (14 langs)  | yes       | yes          | yes        | YES       | YES      |
| Schema dump regeneration          | yes       | yes          | yes        | no        | no       |
| Single-commit doc update (this)   | yes       | no           | yes        | no        | no       |

"YES" (uppercase) indicates the mechanism is load-bearing for that
scenario; "yes" indicates SHOULD; "consider" indicates judgment call;
"no" indicates the overhead is not justified.

---

## 5. Templates

### 5.1 `CHANGELOG.md` initial header

Copy this as the root file if none exists. Subsequent sessions append
new `## YYYY-MM-DD` blocks above the previous ones.

```markdown
# Changelog — Guardian Angela

Newest entries on top. Format:
`[YYYY-MM-DD HH:MM UTC] <status>: <scope> — <detail>`

Statuses:
- `done:` — checkpoint reached and verified on disk.
- `in-flight:` — started but not yet confirmed done. A resuming agent
  MUST verify or redo this before continuing further work.
- `blocked:` — cannot proceed; pointer to what unblocks it.
- `note:` — observation; does not count as a checkpoint.

See `docs/interruption-resilience-strategy.md` for the resume protocol.

---

## YYYY-MM-DD — <session-topic>

- [YYYY-MM-DD HH:MM UTC] <status>: <scope> — <detail>
```

### 5.2 Agent-prompt preamble

Prepend this block verbatim to every spec for an agent expected to
exceed 10 tool uses or touch more than 2 files:

```markdown
## Interruption protocol (MANDATORY)

You MUST follow this protocol for every file write in this task.
Failure to follow it risks lost work if a rate-limit or interruption
hits.

1. **Before anything else:** Read the top block of `CHANGELOG.md`.
   - If the top entry is `in-flight:`, you are a resume agent. Verify
     that action against the filesystem. If it landed cleanly, flip
     the line to `done:` and proceed. If it is half-done, redo it.
   - If the top entry is `done:`, continue with the task as briefed.
2. **For every substantive file write:**
   a. Append ONE line to `CHANGELOG.md` under today's `##` heading:
      `[<UTC-timestamp>] in-flight: <filename> — <one-line action>`.
   b. Perform the write.
   c. Edit the same line to replace `in-flight:` with `done:`.
3. **Budget:** You have a soft cap of 30 tool uses, hard cap 40. If
   you sense you will exceed 30, stop, checkpoint, and return a
   resume-prompt for a successor rather than pushing to completion.
4. **At the end:** Append a summary `done:` line naming every file
   you touched. If you could not finish, leave the final step as
   `in-flight:` and add a `note:` line explaining exactly what
   remains.
5. **No work without a write.** Any decision you make in chain-of-
   thought but never persist to disk does not exist. Write decisions
   into `decisions-log.md` (or the task's designated output) before
   moving on.
```

### 5.3 Resume-prompt template

Use this template when spawning a successor for a dead agent:

```markdown
You are a resume agent. The previous agent was interrupted (rate
limit / timeout / user cancel).

## Step 0 — Discover state

1. Read the top block of `CHANGELOG.md`. The most recent `in-flight:`
   entry is where the previous agent was when it died.
2. Read the predecessor's task briefing: <paste or link original
   prompt>.
3. Inspect the filesystem to confirm what did and did not land.
   Commands that help:
   - `git status`
   - `git diff <last-clean-SHA>...HEAD`
   - `ls` / `Read` on files the journal claims were in-flight.

## Step 1 — Reconcile the journal

- If the in-flight action landed cleanly: flip its line to `done:`.
- If it did not land or is half-done: redo it. The action is
  idempotent per the interruption protocol.

## Step 2 — Continue the task

The predecessor's remaining work is:

- <bullet list of what remains, reconstructed from the briefing minus
  what the journal shows already landed>

Follow the standard interruption protocol (preamble in section 5.2
of `docs/interruption-resilience-strategy.md`) for every write.

## Step 3 — Close out

Before ending your turn, ensure:
- `CHANGELOG.md` top entry is a `done:` or `blocked:` — never
  `in-flight:` at session end.
- If the repo is clean enough for a git checkpoint, create one:
  `checkpoint: <phase> — <status>`.
```

---

## 6. Integration with Guardian Angela's rewrite

The rewrite is organised into ten phases (`docs/rebuild-strategy.md`
section 4). The interruption-resilience strategy integrates as
follows:

### 6.1 Phase-boundary checklist

Every phase in `rebuild-strategy.md` already has entry and exit
criteria. Amend every exit criterion with:

- **Journal-closeness:** `CHANGELOG.md` has no `in-flight:` entries
  for this phase.
- **Commit-closeness:** a `checkpoint: <phase>` commit exists on the
  current branch.
- **Manifest-closeness:** if the phase spawned parallel agents, its
  ownership manifest has a `done:` line for every listed agent.

A phase that fails any of these three checks is not exited, even if
its technical work appears complete — the risk is that unfinished
paperwork later masquerades as finished work during the next resume.

### 6.2 Orchestrator pre-spawn checklist

Before the orchestrator spawns any sub-agent, it MUST:

1. Confirm `CHANGELOG.md` top entry is not `in-flight:`.
2. Confirm git tree is clean (no uncommitted edits from a prior
   dead agent).
3. Publish the ownership manifest if this spawn is parallel.
4. Include the section-5.2 preamble in the sub-agent's prompt.
5. State the sub-agent's tool-use budget explicitly.

### 6.3 CI warning hook (future)

A lightweight CI check: when a PR touches 3 or more files under
`docs/`, warn if the PR does not also update `CHANGELOG.md`. This
is a nudge, not a gate — the author may have valid reason (e.g.,
renaming a file). Implementation: a `check_changelog.sh` script that
lists touched files and grep-counts the session block of
`CHANGELOG.md`.

### 6.4 AGENTS.md pointer

`AGENTS.md` SHOULD point new contributors to this strategy in its
"How to run a multi-agent task" section. The one-line summary to
add: "Every long-running agent MUST follow
`docs/interruption-resilience-strategy.md` sections 3.1, 3.2, 5.2."

---

## 7. Open questions / future work

1. **Pre-write hook for CHANGELOG.** A hook wrapping Write and Edit
   could emit `in-flight`/`done` lines automatically. The
   update-config skill suggests this is possible via
   `settings.json` hooks. Open: can a hook infer a useful detail
   string, or must it settle for generic text?
2. **Formalize as a tool, not a convention.** A dedicated
   `checkpoint` MCP tool that both appends the journal and performs
   the write atomically would be more robust. Trade-off: one more
   dependency.
3. **Session-id headings vs dates.** For multi-day sessions the
   `## YYYY-MM-DD` heading fragments context. Alternative:
   `## <session-slug>` (e.g., "strategy-docs-suite"). Revisit after
   ~5 sessions.
4. **Auto-detect stale in-flight entries.** A startup script that
   flags "in-flight entry older than 4h without a matching commit"
   would let a fresh session recognise a dead predecessor.
5. **Chaos-test automation.** Section 3.8 is manual today. A scripted
   chaos-test would catch protocol regressions before real sessions
   hit them.

---

## 8. Appendix — lessons from past incidents

### 8.1 Consistency agent rate-limit (2026-04-20)

**What happened.** Agent B propagated 28 decisions across four docs,
then hit the rate limiter on the first Write for `strategy-index.md`.
The agent output was truncated; the orchestrator learned of the failure
only from the Bash exit code.

**What would have prevented it.** If the agent had followed section
5.2's preamble, `CHANGELOG.md` would have contained a clear
`in-flight: strategy-index.md` line and five `done:` lines above it.
Recovery would be a two-minute read, not a 15-minute cross-diff of
four files.

### 8.2 V2 rewrite wiring gaps (2026-04-13)

**What happened.** Parallel agents built each layer; nobody owned the
seams. Integration was broken in four places (see
`docs/review/postmortem-v2-rewrite-bugs.md`). The outcome had the
shape of an interruption even without one: pieces looked complete,
but the seams between them were half-done.

**What would have prevented it.** A wiring manifest (section 3.3)
naming each seam as an explicit work item with its own `done:` entry.
An absent seam at session end would be a visible `in-flight:` problem.

### 8.3 Spec-drift during `repeatCount` → `retryCount` rename

**What happened.** A rename pass updated some files; a later agent
assumed the rename was finished and added new code using the old
name. Both names coexisted for days.

**What would have prevented it.** The spec-lock protocol
(`docs/rebuild-strategy.md` L2), an atomic rename manifest (3.4),
and a single `checkpoint: rename-repeatCount-to-retryCount` commit.
A successor would see either "done (commit exists)" or "in-flight
(journal says so)" — never the ambiguous half-state.

### 8.4 User interruption during decisions consolidation

**What happened.** A user pressed ESC mid-write. `decisions-log.md`
was left with a duplicated heading and a half-copied entry. The next
agent saw a valid-looking file and continued, producing downstream
work from corrupt input.

**What would have prevented it.** Atomic write (section 3.4): the
half-written `.tmp` would have been discarded, leaving the original
intact. The journal's `in-flight:` would have triggered a clean redo.

---

## 9. One-page cheat sheet

For daily reference, the entire protocol collapses to:

1. **Read `CHANGELOG.md` before you touch anything.**
2. **Journal `in-flight:` before every write; flip to `done:` after.**
3. **Stay under 30 tool uses; split if you must.**
4. **Commit `checkpoint:` at phase boundaries.**
5. **No work without a write.**
6. **Resume-by-reading, never by-remembering.**

If every agent does these six things, every rate-limit is a minor
pause and every user interrupt is trivially recoverable.
