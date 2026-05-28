# Guardian Angela v3 — Session Hand-off

**Snapshot:** 2026-05-28 — **Phase 6 fix-pass C done + PM re-verifier PASS.** The architect + qa-expert verifier cohort is the next stop; both run in parallel (read-only). When both PASS, Phase 6 closes and Phase 7 (native channels) begins.
**HEAD:** `b66f5e4` (`phase-6-fix-c-handoff-2: update HANDOFF.md for PM PASS + next-step pointers`).
**Tests passing:** `3582/3582` (`flutter test --concurrency=6`).
**Analyzer:** `0 issues` (`flutter analyze --fatal-infos`).
**Branch:** `main`. **Not pushed.** **OLD/ is INERT.**

---

## How to resume

After `/clear`, paste:

> Continue from HANDOFF.md

Start from §"Next actions". The plan files in `~/.claude/plans/` (`make-sure-that-there-typed-tulip.md` + `rippling-weaving-puffin.md`) and `docs/rewrite/v3-plan.md` remain the source of truth.

---

## Hard rules (unchanged — applies to every stage going forward)

1. **OLD/ is INERT.** Never read/list/glob/grep/import anything under `OLD/`. If a hook touches it, restore with `git checkout <prior-commit> -- OLD/` — *do not browse the files*.
2. **NO STUBS at GA.** All 12 S-NN categories in `~/.claude/plans/make-sure-that-there-typed-tulip.md §NO-STUBS` are CI hard fails.
3. **NO INVENTED DEFERRALS.** "Phase X" comments are legitimate ONLY if the named phase's plan actually scopes the work. Grep `lib/features/` for `"Phase 7\|Phase 8\|Phase 9\|Phase 10\|Phase 11"` before every commit; MUST be empty. (`lib/services/` Phase-7 comments are legitimate — Phase 7 scopes native channels.)
4. **DO NOT guess.** Use `AskUserQuestion` for spec ambiguity.
5. **Pre-alpha = break compatibility freely.** (Drift schema is at v4; bump and nuke-and-reseed when needed.)
6. **Verify after EVERY fix or stage.** Analyzer + tests + grep gates. Re-engage the same verifier on `FIX_REQUIRED`.
7. **Write/update HANDOFF.md before the session ends** (see §"End-of-session ritual" at the bottom).
8. **Serial default; parallel only when truly orthogonal** (disjoint files + no shared mutable state). Verifier cohorts may run in parallel.
9. **Co-Authored-By footer:** `Claude Opus 4.7 <noreply@anthropic.com>`.
10. **Pure Dart in `lib/domain/`, `lib/services/protocols/`, `lib/data/`.** No `package:flutter` imports.

---

## Current state at a glance

| Phase | Status | Tests | Commits |
|---|---|---|---|
| Pre-flight + Phase 0..5 | ✅ Done — 3-agent cohort PASS | 2447 | `40d9add..36d30cf` |
| Phase 6 (screens + routing + R-42 + tests + goldens) | ✅ Implementation + tests | 3538 | `ee73b62..cedaecf` (30 commits) |
| **Phase 6 fix-pass C (PM-FIX_REQUIRED defects)** | ✅ **PM PASS at `2edca2d`; pending architect + qa-expert** | **3582** | `5bd1486..b66f5e4` (11 commits) |
| Phase 7..11 | Pending |  |  |

---

## What Phase 6 fix-pass C delivered (commits `5bd1486..b66f5e4`, 11 commits)

- `5bd1486` phase-6-fix-c-prelude: HANDOFF.md update + leftover `dart format` / `import_sorter` output from after the goldens commit. Zero functional change.
- `5dc9b05` phase-6-fix-c1: `SwipeSlider` widget (70 % threshold, single-fire per drag) + `EmergencyConfirmOverlay` that replaces `_CallEmergencyStepUi` during the `duration` phase of a `callEmergency` step. Keep-calling dismisses locally; swipe-cancel ends the session (real) or shows a SnackBar (sim). +6 EN ARB keys. +18 tests.
- `62fcc21` phase-6-fix-c2: `EndSessionOverlay` replaces the generic AlertDialog. Two-stage state machine (swipe-to-end → PIN keypad). PIN ladder: Duress > App-mismatch hint > Session End > wrong-PIN counter. 5 wrong PINs fires distress in real session; sim shows informational SnackBar. Deceptive dialog gated behind `appSettings.deceptivePinDialogEnabled`. Wrong-PIN counter on `SessionController` (in-memory, shared with C3). +10 EN ARB keys. +10 tests.
- `be29430` phase-6-fix-c3: distress-cancel PIN gate with 15-second timeout. Rewrote `_DistressConfirmationOverlay` as `ConsumerStatefulWidget`. Tap Cancel pauses the 5s distress countdown (new `pauseDistressCountdown`/`resumeDistressCountdown` on the controller) while a 15s PIN prompt opens. Same PIN ladder as C2. Timeout fires distress via new `EndReason.distressConfirmTimeout`. +7 EN ARB keys. +11 tests.
- `4525a76` phase-6-fix-c5: ARB orphan sweep — dropped 454 keys with no `l10n.<key>` reference in `lib/` or `test/` from all 14 ARB files. EN: 1841 → 502 keys. `flutter gen-l10n` regenerated.
- `9ffa48e` phase-6-fix-c5-import-sort: post-commit `import_sorter` follow-up (zero functional change).
- `e77900e` phase-6-fix-c6: nits — `main.dart:19,163` "Phase 6 will replace..." → present-tense; +6 HomeScreen reference tests (19 → 25 to hit plan target).
- `007fa6a` phase-6-fix-c-handoff: HANDOFF.md update with the new HEAD + out-of-scope findings.
- `c691798` phase-6-fix-c7: drop two stale profile-field keys (`profileFieldPhoneNumber`, `profileFieldPhysicalDescription`) from all 13 non-EN ARBs. They were absent from EN but still in non-EN — violated the "non-EN MUST be a subset of EN" parity gate (PM re-verifier defect at `007fa6a`).
- `2edca2d` phase-6-fix-c7-import-sort: post-commit `import_sorter` follow-up (zero functional change).
- `b66f5e4` phase-6-fix-c-handoff-2: HANDOFF.md update for PM PASS + next-step pointers.

C4 (DeceptiveOldPinDialog wiring at remaining sites) was effectively empty — C2 + C3 covered the two active spec sites; the third (`PinEntryScreen`) does not exist; the simulation summary `_PinPrompt` is intentionally shake-only per spec 04:548.

---

## Out-of-scope findings (architect should NOT double-flag these)

These three real defects surfaced during fix-pass C but are intentionally not in fix-pass C scope. They should be addressed in a separate fix pass or in Phase 7.

1. **`PinEntryScreen` / app-lock-on-launch does NOT exist.** Per spec 04:1900-1945 + 06:130 the App PIN is supposed to lock the app on open. There is no route, no screen, no app-startup gate.
2. **`SettingsSecurityScreen._confirmClear` removes a PIN without verifying the existing PIN first** (`lib/features/settings_security/settings_security_screen.dart:204-231`). An attacker who can unlock the device can remove any configured PIN.
3. **Strategy dispatch (`controller → strategy.executeReal`) is NOT WIRED in production.** The `EventStrategyRegistry` is only used by tests; no production code path calls a strategy. The engine fires phase timers but no SMS, no phone call, no alarm ever runs. Likely a Phase 7 (native channels) item.

---

## Next actions (resume here)

**Dispatch the architect + qa-expert verifiers in parallel.** Both are read-only — they can run concurrently without contention. When both PASS, Phase 6 closes.

### Step 1 — Spec-vs-code agent (`voltagent-qa-sec:architect-reviewer`, opus, parallel with Step 2)

Prompt skeleton: `~/.claude/plans/rippling-weaving-puffin.md §Spec-vs-code agent prompt skeleton`. Phase = "Phase 6 (screens, routing, R-42 + tests + fix-pass C)". Scope:
- `docs/spec/04-screens-navigation.md` (24 screens + global UI patterns + `DeceptiveOldPinDialog` + `SwipeSlider` Extra 56)
- `docs/spec/06-settings.md` (PIN priority, R-27, R-42, Session End methods)
- `docs/spec/02-event-types.md` lines 440-475 (callEmergency confirmation)
- `lib/features/`, `lib/router/`, `lib/core/widgets/` at HEAD `b66f5e4`

Prefix the brief with the three out-of-scope findings above so the architect doesn't double-flag them. Verdict must be PASS before Phase 6 closes; FIX_REQUIRED triggers another fix-pass round on the architect-flagged defects only.

### Step 2 — Spec-vs-tests agent (`voltagent-qa-sec:qa-expert`, opus, parallel with Step 1)

Prompt skeleton: `~/.claude/plans/rippling-weaving-puffin.md §Spec-vs-tests agent prompt skeleton`. Tests in scope:
- 30 widget tests in `test/features/<feature>/*_test.dart`
- 6 alchemist golden tests in `test/features/<feature>/*_golden_test.dart`
- Fix-pass-C tests: `test/core/widgets/swipe_slider_test.dart`, `test/features/session/widgets/emergency_confirm_overlay_test.dart`, `test/features/session/session_screen_test.dart` (now ~88 tests including PIN-gate coverage), `test/features/home/home_screen_test.dart` (25 tests)

Confirm each normative spec requirement has a test that exercises the behaviour (not just imports the symbol). Mark `test/spec_coverage_test.dart` rows. Verdict must be PASS.

### Step 3 — Phase 6 close

When both verifiers PASS, mark Phase 6 closed in HANDOFF.md + the plan. Phase 7 (native channels — Android SMS, phone, audio; iOS CallKit) starts. Re-evaluate the three out-of-scope findings above against Phase 7's plan and pull any that don't fit into a follow-up fix pass.

---

## Reading list for the resumer

- `~/.claude/plans/rippling-weaving-puffin.md §Phase 6` + §Post-Phase Verification Cohort.
- `docs/spec/04-screens-navigation.md`, `docs/spec/06-settings.md`, `docs/spec/02-event-types.md` 440-475.
- New widgets at HEAD `b66f5e4`:
  - `lib/core/widgets/swipe_slider.dart`
  - `lib/features/session/widgets/emergency_confirm_overlay.dart`
  - `lib/features/session/widgets/end_session_overlay.dart`
- Updated session UI:
  - `lib/features/session/session_screen.dart` — `_DistressConfirmationOverlay` is now `ConsumerStatefulWidget`; PIN gate, 15s timeout, sim Skip
  - `lib/features/session/session_controller.dart` — `pauseDistressCountdown` / `resumeDistressCountdown`, wrong-PIN counter
- `lib/domain/enums/end_reason.dart` — added `distressConfirmTimeout`
- `lib/l10n/l10n/app_en.arb` — now 502 keys after orphan sweep

---

## Quick verification commands (run after every fix or stage — per Rule 6)

```bash
flutter analyze --fatal-infos                                                # 0 issues
flutter test --concurrency=6                                                 # all pass (currently 3582)
grep -r 'package:flutter' lib/domain/                                        # empty (S-7)
grep -r 'package:flutter' lib/services/protocols/                            # empty (S-7)
grep -r 'package:flutter' lib/data/                                          # empty (S-7)
grep -rEn 'UnimplementedError|throw .TODO|TODO|FIXME|XXX|HACK|Container\(\)|Placeholder\(\)' lib/ | grep -v 'ProviderContainer()'  # only ProviderContainer() in main.dart
grep -rn "will be available in a future\|coming in Phase\|deferred to Phase" lib/                                                   # 0
grep -rnE "(Phase 7|Phase 8|Phase 9|Phase 10|Phase 11)" lib/features/        # 0 (legit refs are in lib/services/)
grep -rEn 'class DistressChain|repeatCount|leapToNextEvent|LoudAlarmSound\.(beep|whistle|scream|whoop)|SmsRecipient|flashSpeed\b|maxVolume\b|Hive\b|@HiveType|@HiveField|PauseReason\.bootRestart|EndReason\.appTermination|fakeCallAnswered' lib/ test/ integration_test/  # 0 (S-4)
grep -rn "import.*['\"].*OLD/" lib/ test/ integration_test/                  # 0 (S-5)
git diff-tree -r --name-only HEAD -- OLD/                                    # empty (OLD/ untouched)
python3 -c "import json; from pathlib import Path; en={k for k in json.loads(Path('lib/l10n/l10n/app_en.arb').read_text()) if not k.startswith('@')}; [print(arb.name,'orphan:',sorted({k for k in json.loads(arb.read_text()) if not k.startswith('@')} - en)) for arb in sorted(Path('lib/l10n/l10n').glob('app_*.arb')) if arb.name != 'app_en.arb' and ({k for k in json.loads(arb.read_text()) if not k.startswith('@')} - en)]"  # 0 lines (ARB parity)
```

All currently pass at HEAD `b66f5e4`.

---

## End-of-session ritual (do this before stopping, every session)

When the user is about to stop a session — or when context is filling up (>200k tokens) and you anticipate `/clear` — **always run this ritual before the conversation ends**:

1. **Update HANDOFF.md.** Rewrite the snapshot (date, HEAD sha, tests passing, analyzer state), refresh the "Current state at a glance" table, append a one-line summary of every commit landed this session under a new "What this session delivered" sub-heading, refresh the "Next actions" pointers, and update the "Quick verification commands" output expectations (test count, etc.). Drop any obsolete sections (closed PM defect lists, completed plans). Keep the hard rules + end-of-session ritual sections untouched.
2. **Commit the HANDOFF.md update** with a message like `phase-N-fix-cX-handoff: …` and the Co-Authored-By footer.
3. **Tell the user the resume prompt.** Print, in chat, exactly:

   > After `/clear`, paste: **`Continue from HANDOFF.md`**

   Include the new HEAD sha so the user can sanity-check the next session's starting state.

This ritual keeps the handoff self-sustaining: future sessions read the same instruction and renew it. Don't skip it because "the session went short" — even a one-commit session benefits from a fresh snapshot.

---

End of hand-off. Resume from §"Next actions".
