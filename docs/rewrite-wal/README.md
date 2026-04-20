# Rewrite WAL — checkpoint journal

Per the Guardian Angela complete rewrite plan (`/home/jonas/.claude/plans/spicy-enchanting-honey.md`), each phase carries a write-ahead-log file so a resuming PM (after rate-limit, session restart, or any interruption) can pick up cleanly without guessing.

## File layout

`docs/rewrite-wal/phase-NN.json` — one file per phase, overwritten (not appended) at every PM update. When a phase exits green, its WAL file stays on disk as a historical record; the next phase starts a new file.

## Schema

```json
{
  "phase": "NN",
  "title": "Phase title for humans",
  "step": "design | code | review | fix | verify | exit",
  "iteration": 0,
  "owner_agent": "<name or null>",
  "owned_files": ["lib/domain/engine/session_engine.dart", ...],
  "decisions_added": ["D-ENGINE-5", ...],
  "gates_passed": ["analyze", "build_runner", "flutter_test"],
  "gates_pending": ["coverage", "manual_device_test"],
  "next_action": "single sentence",
  "last_update_iso": "2026-04-20T13:30:00Z",
  "notes": "free-form PM notes, optional"
}
```

## Field semantics

| Field | Meaning |
|-------|---------|
| `phase` | Two-digit phase number (`"00"`..`"16"`) |
| `step` | Where we are in the phase: `design` (pre-coding ADR discussion), `code` (an agent is editing source), `review` (review-loop running), `fix` (fixer dispatched on a Block), `verify` (Verifier agent running gates), `exit` (phase done; about to checkpoint commit) |
| `iteration` | Review-loop iteration (0–3). Incremented each time a fixer re-closes a Block |
| `owner_agent` | The sub-agent currently holding a write lock on the files in `owned_files`. `null` when the PM itself holds the tree |
| `owned_files` | Absolute paths of files the active agent may write to. No other agent may edit these paths until the active agent reports |
| `decisions_added` | D-IDs appended to `docs/decisions-log.md` during this phase |
| `gates_passed` / `gates_pending` | Universal + phase-specific gates (see plan §"Universal gates" and §"Per-phase gates") |
| `next_action` | One sentence, executable. A successor PM reads this and dispatches exactly this action |
| `last_update_iso` | ISO-8601 timestamp. Resuming PM uses this to judge staleness |
| `notes` | Free-form PM notes; optional |

## Resume protocol

When a new PM session starts mid-phase:

1. Read the latest `phase-NN.json` file (highest NN).
2. Read open `TaskUpdate` subtasks — find any with status `in-flight`.
3. Run `git log --oneline -20` to see last checkpoint commit.
4. Run `git status` to confirm working tree matches `owned_files`.
5. Re-run the universal gates (analyze, test) — if broken, dispatch Verifier first to diagnose.
6. Dispatch exactly one action specified by `next_action` or the next WAL step.
7. Never guess; if ambiguous, stop and surface to user.

## PM update discipline

- Write the WAL BEFORE dispatching any agent.
- Update the WAL IMMEDIATELY AFTER the agent reports back (success or failure).
- On rate-limit: the outgoing PM's last action is a WAL update. The incoming PM's first action is a WAL read.
- Never let a sub-agent edit its own WAL entry. PM owns the WAL.
