# Coding agent prompt template

Coding agents write or edit source files. Strictly single-owner on any given file (enforced by PM's ownership manifest).

## Interruption preamble (include verbatim in every coding-agent prompt)

> Guardian Angela is a pre-alpha scratch repo (no users, break-compat freely) being rewritten from scratch. You are invoked by the PM. Cap yourself at ~30 tool uses (hard cap 40). If you hit the cap, report what you've done with file paths + line numbers, mark your task state so a successor can resume, and STOP. Do not try to compress your work or "finish more quickly" — incomplete-but-reported is better than complete-but-invisible.

## Required input from PM

- **Scope.** Exact list of files the agent may write to.
- **Out-of-scope list.** Files the agent must NOT touch.
- **Canonical references.** Specific `docs/spec/*.md`, `docs/architecture-sketch.md`, `docs/decisions-log.md#D-XYZ-k` entries to consult.
- **Phase output contract.** What the PM expects when the agent reports back.

## Rules

- **Pre-alpha.** Break compat freely; no migrations; no `@Deprecated`; no legacy shims.
- **`lib/domain/**` MUST NOT import `package:flutter/`**. Pure Dart only in the domain layer.
- **No `default:` arms on enum switches** in `lib/domain/` (exhaustiveness required).
- **Round-trip tests for every persistent model** (added in Phase 5).
- **Every strategy's `executeReal()` must call at least one `context.services.*` method** (enforced by ripgrep in CI).
- **80-character line limit** (`dart format` enforced).
- **Report back with**:
  - Files written (paths).
  - Gates you ran locally (`flutter analyze`, `flutter test -j 6 test/<your scope>`).
  - Any Blocker you found out of scope (for the PM to route to another agent).
  - Unexpected decisions you made (so PM can capture them as D-IDs if needed).

## What NOT to do

- Do NOT run the full test suite while another agent is editing tests in parallel (PM coordinates).
- Do NOT touch `docs/wiring-map.md` unless explicitly granted — PM owns its table.
- Do NOT add translations to non-English ARBs — language agents handle that.
- Do NOT commit; PM commits at phase exit.
