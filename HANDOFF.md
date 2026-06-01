# Guardian Angela v3 — Session Hand-off

**Snapshot:** 2026-06-01 — **i18n backfill COMPLETE — issue #1 RESOLVED.** All 355 previously-missing ARB keys are now translated into all 13 non-EN locales (4,615 translations) via a 13-agent parallel campaign. CI's `l10n-parity` gate now PASSES (0 missing/locale). A latent confirm-dialog bug surfaced during validation and was fixed (trash "EMPTY TRASH" typed-token). 11 RTL/Arabic goldens regenerated (text-only reflow; layout verified intact, no overflow). **Phase 7 (native channels) is next.** The push decision is now unblocked — CI will pass on `l10n-parity` — but pushing is still the user's call.
**HEAD:** `fdb85c7` (`phase-6-i18n-backfill`) — the HANDOFF commit will sit on top.
**Tests passing:** `3661/3661` (`flutter test --concurrency=6`; goldens regenerated).
**Analyzer:** `0 issues` (`flutter analyze --fatal-infos`).
**Branch:** `main`. **STILL NEVER pushed** (96+ commits ahead of origin — CI has never run, but `l10n-parity` will now pass). **OLD/ is INERT.**

---

## How to resume

After `/clear`, paste:

> Continue from HANDOFF.md

Start from §"High-priority discovered issues", then §"Next actions". Plan files in `~/.claude/plans/` (`make-sure-that-there-typed-tulip.md` + `rippling-weaving-puffin.md`) and `docs/rewrite/v3-plan.md` remain the source of truth.

---

## Hard rules (unchanged — applies to every stage going forward)

1. **OLD/ is INERT.** Never read/list/glob/grep/import anything under `OLD/`. If a hook touches it, restore with `git checkout <prior-commit> -- OLD/` — *do not browse the files*.
2. **NO STUBS at GA.** All 12 S-NN categories in `~/.claude/plans/make-sure-that-there-typed-tulip.md §NO-STUBS` are CI hard fails.
3. **NO INVENTED DEFERRALS.** "Phase X" comments are legitimate ONLY if the named phase's plan actually scopes the work. Grep `lib/features/` for `"Phase 7\|Phase 8\|Phase 9\|Phase 10\|Phase 11"` before every commit; MUST be empty. (`lib/services/` Phase-7 comments are legitimate.)
4. **DO NOT guess.** Use `AskUserQuestion` for spec ambiguity. (Used twice this session — launch-gate design + wrong-PIN semantics. The user's answers are baked into the commits; see below.)
5. **Pre-alpha = break compatibility freely.** (Drift schema is at v4; bump and nuke-and-reseed when needed.)
6. **Verify after EVERY fix or stage.** Analyzer + tests + grep gates. Re-engage the same verifier on `FIX_REQUIRED`.
7. **Write/update HANDOFF.md before the session ends** (see §"End-of-session ritual").
8. **Serial default; parallel only when truly orthogonal.** Verifier cohorts may run in parallel.
9. **Co-Authored-By footer:** the model running the session. This session used `Claude Opus 4.8 (1M context) <noreply@anthropic.com>` (the harness-mandated, accurate footer). Earlier commits used `Claude Opus 4.7` — both are fine; attribute to whatever model is actually running.
10. **Pure Dart in `lib/domain/`, `lib/services/protocols/`, `lib/data/`.** No `package:flutter` imports.
11. **lefthook now re-stages auto-fixes** (`stage_fixed: true`). Every commit's format+import-sort fixes are re-staged automatically — the tree stays clean after commit. Do NOT bypass hooks.

---

## Current state at a glance

| Phase | Status | Tests | Commits |
|---|---|---|---|
| Pre-flight + Phase 0..5 | ✅ Done | 2447 | `40d9add..36d30cf` |
| Phase 6 (screens + routing + tests + goldens) | ✅ Done | 3538 | `ee73b62..cedaecf` |
| Phase 6 fix-pass C / D | ✅ Done | 3619 | `5bd1486..92dfd88` |
| **Housekeeping + pre-Phase-7 fix-pass E** | ✅ **CLOSED** | **3661** | `54a1d04..64cd14a` (8 commits) |
| **i18n backfill — 355 keys × 13 locales** | ✅ **DONE** | **3661** | `fdb85c7` (1 commit) |
| Phase 7..11 | Pending |  |  |

---

## What the i18n-backfill session delivered (`fdb85c7`, 1 commit)

Resolved issue #1. Workflow (all artifacts in `/tmp/ga_i18n/`, throwaway):

- **Source delta.** Built `source_355.json` — the 355 missing keys (identical set across all 13 locales) with EN value + extracted `{placeholder}` list + EN description as translation context.
- **13 parallel agents** (`general-purpose`, Opus), one per locale (`ar de el es fa fr he hi pl ru uk zh zh_TW`) — truly orthogonal (disjoint output files, read-only shared source). Each read the source + its existing ARB (for terminology consistency) and wrote `out_<code>.json`. NOT direct ARB edits — that kept RTL/CJK JSON safe and gave a single deterministic merge point.
- **Validation + merge (Python, deterministic).** Asserted per locale: valid JSON, key-set == the 355, `{placeholder}` set per value == EN, no empty values. Merged by **text-append** (load→dump would reflow the existing compact `@`-metadata, so existing bytes are preserved exactly; diff = +355 keys, the `-1` is the comma on the prior last line). All 13 → 552 plain keys == EN.
- **Correctness fix.** `past_events_trash_screen.dart` hardcodes `expected:'EMPTY TRASH'`; de/es/fr/pl had translated that token in the confirm body → users would type a never-matching string. Swapped the token back to literal "EMPTY TRASH" (surrounding text stays localized). Contacts delete-all uses a *localized* sentinel and was consistent in all 13. See discovered-issue #4.
- **Regen + goldens.** `flutter gen-l10n` (12 locale classes; `app_localizations.dart` + `_en.dart` regenerated identical since EN was untouched). 11 RTL/Arabic goldens reflowed (EN-fallback→translated text); verified visually (settings 13.7%, distress overlay) as text-only with intact layout, then regenerated (`flutter test --update-goldens`). No EN/LTR golden changed.

## What the prior session delivered — fix-pass E (`54a1d04..64cd14a`, 8 commits)

**Housekeeping (`54a1d04`).** The tree was dirty at session start (format + import-sort drift on Phase-6 files). Root cause: lefthook's `format` / `import-sorter` pre-commit commands rewrote files but never re-staged them (no `stage_fixed`), so every prior commit landed format/sort-dirty and **would fail CI's format + import gates** (`ci.yml:30`, `:48`). Fixed lefthook (`stage_fixed: true`, verified by probe), committed the accumulated normalization, and added the format + import-sort gates to the verification commands below.

**Pre-Phase-7 fix-pass E (`4039113..64cd14a`, 7 commits).** Resolves out-of-scope findings #1 + #2 from the prior handoff, plus a discovered bug and a security review.

- **e1 `4039113` — BiometricService triplet + native config.** `local_auth ^3.0.0` (already in pubspec, unused) wired behind protocol/real/sim/provider. Biometric-only, fail-soft (any error → false → PIN fallback). Native: MainActivity → `FlutterFragmentActivity`; AndroidManifest `USE_BIOMETRIC`; iOS `NSFaceIDUsageDescription`. 12 tests.
- **e2 `957a979` — App-PIN launch gate.** Decided via AskUserQuestion: **cold-start only**, shown iff `appPinHash != null`; **full duress semantics**; **biometric opt-in** (default off). `LaunchPinScreen` + `LaunchGateController` (in-memory lock) + router `/launch-pin` redirect (seeded synchronously in `main.dart` bootstrap → no content flash) + `SessionController.startDistressSession` (cold-start distress via the global default distress mode). App-PIN biometric toggle added to Settings → Security. 4 EN ARB keys. +30 tests.
- **e3 `0a67092` — false-distress fix (count wrong PIN only at max length).** DISCOVERED during e2: the shared keypads counted a wrong PIN at 4 digits, so a legit 5–8 digit PIN holder could never enter it and would **fire their own distress chain**. User decision: count wrong only at `kPinMaxLength` (8); fix all three sites (launch gate, `EndSessionOverlay`, distress-cancel). New `core/constants/pin_constants.dart`. +2 regression tests + session tests updated to 8-digit wrong entries.
- **e4 `927600a` — PIN-removal verification (fix #2).** `RemovePinDialog`: removing a PIN now requires re-entering it (was a one-tap "are you sure?"). 2 EN ARB keys. +6 tests.
- **e5 `2e7e451` — spec updates (doc only).** 06 §App PIN now allows biometric (opt-in) + documents the gate; 06:162 prohibition reversed + reconciled with 03/glossary; new wrong-at-max-length §; 04 two HANDOFF drifts fixed (`?type=session`→`sessionEnd`, `/settings/defaults`→`/settings/stealth`); 03 marks `requireLaunchAuth`/`launchAuthBiometric` superseded.
- **e6 `5aeeff9` — translations.** Language agent translated the 6 new keys into all 13 non-EN locales.
- **e7 `64cd14a` — stealth-marker fix (HIGH review finding).** The cold-start distress wrote an interrupt marker (`modeName: "Default Distress"`); a force-stop mid-chain would surface "Session interrupted — Mode: Default Distress" on next launch, revealing the covert Duress run. Fixed: `startSession` gained `writeInterruptMarker` (false for cold-start distress). +1 end-to-end regression test. **Re-verified PASS** by the same code-reviewer (both Duress + wrong-PIN cold-start paths closed; null `_markerLogId` doesn't break `_finaliseLog`; normal interrupt detection byte-for-byte unchanged).

---

## High-priority discovered issues (read before Phase 7)

1. **✅ RESOLVED (`fdb85c7`) — i18n backfill complete.** All 355 previously-missing keys translated into all 13 non-EN locales (4,615 strings) by a 13-agent parallel campaign; each output validated for exact key-set parity, ICU `{placeholder}` integrity, and non-empty values; merged via deterministic text-append (existing bytes untouched). `flutter gen-l10n` regenerated; the MISSING-key parity check now returns **0/locale**, so CI's `l10n-parity` job (`ci.yml:199-212`) will pass. Translations are machine-generated (not human-reviewed) — same provenance as the original 197 keys/locale; a native-speaker pass is a future nicety, not a blocker. The agents flagged minor judgment calls per locale (e.g. "Duress PIN" wording, whether to keep the "PHONE"/"CALL" fake-call badges Latin) — see the `phase-6-i18n-backfill` commit body / agent notes if refining.
2. **🟡 Dead model fields `requireLaunchAuth` + `launchAuthBiometric`** (`AppSettings`). Superseded by `appPinHash` + `appPinBiometricEnabled` (the gate reads the latter). Only copied through in `settings_security_controller.dart`. Spec 03 marks them superseded; remove in a schema-cleanup pass (pre-alpha break-compat is fine). Verify first: `grep -rn "requireLaunchAuth\|launchAuthBiometric" lib/ test/`.
3. **🟡 Deferred low findings from the e7 security review** (code-reviewer, all LOW): (a) duress fake-unlock waits for the full engine-bootstrap before unlocking — perceptible latency vs a normal unlock; consider firing distress + unlocking in parallel. (b) `LaunchPinScreen` / `RemovePinDialog` build their tree inline rather than extracting private stage widgets like `EndSessionOverlay` does — a CLAUDE.md style consistency nit, not a violation.
4. **🟡 Two "type-to-confirm" dialogs use INCONSISTENT sentinel mechanisms** (found during i18n validation; both currently correct, but inconsistent UX). `contacts_screen.dart` compares typed input against the **localized** `l10n.contactsDeleteAllTypeConfirmSentinel`, so a German user types "ALLE LÖSCHEN". `past_events_trash_screen.dart:56` hardcodes `expected:'EMPTY TRASH'` (English, used as both field hint and match target), so every locale's `pastEventsTrashEmptyAllConfirmBody` MUST keep the literal "EMPTY TRASH" — which the backfill now enforces. To unify (optional, out of scope here): add a `pastEventsTrashEmptyAllSentinel` l10n key + read it in the dialog, then localize the body token + update the test that types `'EMPTY TRASH'`. Until then, do NOT let a future translation pass "fix" the English token in the trash body — it would break the confirm flow.

---

## Out-of-scope findings carried from the prior handoff — status

1. ✅ **App-PIN-on-launch** — DONE (e2).
2. ✅ **PIN-removal verification** — DONE (e4).
3. ⏳ **Strategy dispatch (`controller → strategy.executeReal`) NOT wired in production** — still open, **Phase 7 scope**. `grep -rn "\.executeReal" lib/` returns only doc comments; the `EventStrategyRegistry` is used only by tests. So today NO real session (normal OR cold-start distress) actually sends SMS / places calls — the engine fires events + logs but dispatches nothing. Phase 7 native channels give the strategies something to dispatch to; verify the wiring lands.

---

## Next actions (resume here)

**i18n gap (issue #1) is RESOLVED** — `l10n-parity` will pass, so the branch is push-ready on that axis. Pushing the first time (96+ commits) is still the user's call; expect *other* CI jobs to surface their own first-run issues. Then:

**Phase 7 — Native channels (PARALLEL: Android ∥ iOS).** Per `~/.claude/plans/rippling-weaving-puffin.md §Phase 7`:
- **Pre-flight:** confirm `lib/services/*/native_*_bridge.dart` contracts (Phase 5 commit range). `grep -n "Phase 7" lib/services/` for intentional markers needing wiring. Note: `MainActivity.kt` is now `FlutterFragmentActivity` (e1) and AndroidManifest gained `USE_BIOMETRIC` — Phase 7 builds on these.
- **Agents (parallel — disjoint platform trees):**
  - `voltagent-lang:kotlin-specialist` → Android Kotlin files + AndroidManifest + resources.
  - `voltagent-lang:swift-expert` → iOS Swift files + Info.plist + entitlements.
- **Wire strategy dispatch** (out-of-scope #3) — confirm `controller → strategy.executeReal` lands.
- **Tests:** Patrol integration (emulator + simulator). **Verify:** `flutter build apk --debug` + `flutter build ios --no-codesign` succeed; no `import.*OLD/`.
- **Post-phase cohort (mandatory):** PM (`voltagent-qa-sec:code-reviewer`) → architect (`voltagent-qa-sec:architect-reviewer`) → qa-expert serial gate. **This cohort should also sweep the fix-pass-E surfaces** (launch gate, biometric, PIN-removal, the e3 wrong-PIN change in all three keypads).

---

## Reading list for the resumer

- `~/.claude/plans/rippling-weaving-puffin.md §Phase 7` + §Post-Phase Verification Cohort.
- `docs/spec/05-services.md §Native channels` + `docs/spec/10-platform-matrix.md`.
- New fix-pass-E surfaces:
  - `lib/features/launch_gate/launch_pin_screen.dart` + `launch_gate_controller.dart`
  - `lib/features/session/session_controller.dart` (`startDistressSession`, `startSession` `writeInterruptMarker`)
  - `lib/services/biometric_service.dart` + `protocols/biometric_service_protocol.dart` + `sim/biometric_service_sim.dart`
  - `lib/features/settings_security/remove_pin_dialog.dart`
  - `lib/core/constants/pin_constants.dart` (kPinMinLength=4, kPinMaxLength=8 — the e3 wrong-PIN semantics)
  - `lib/router/app_router.dart` (`/launch-pin` redirect) + `lib/main.dart` (bootstrap seed)

---

## Quick verification commands (run after every fix or stage — per Rule 6)

```bash
dart format --output=none --set-exit-if-changed lib/ test/                   # 0 changed (CI format gate, ci.yml:30)
dart run import_sorter:main --no-comments --exit-if-changed                  # Sorted 0 files (CI import gate, ci.yml:48)
flutter analyze --fatal-infos                                                # 0 issues
flutter test --concurrency=6                                                 # all pass (currently 3661)
grep -r 'package:flutter' lib/domain/ lib/services/protocols/ lib/data/      # empty (S-7)
grep -rEn 'UnimplementedError|throw .TODO|TODO|FIXME|XXX|HACK|Container\(\)|Placeholder\(\)' lib/ | grep -v 'ProviderContainer()'  # only ProviderContainer() in main.dart
grep -rnE "(Phase 7|Phase 8|Phase 9|Phase 10|Phase 11)" lib/features/        # 0 (legit refs are in lib/services/)
grep -rn "import.*['\"].*OLD/" lib/ test/ integration_test/                  # 0 (S-5)
git diff-tree -r --name-only HEAD -- OLD/                                    # empty (OLD/ untouched)
# ARB parity — ORPHAN check (extra keys in non-EN). Currently 0:
python3 -c "import json; from pathlib import Path; en={k for k in json.loads(Path('lib/l10n/l10n/app_en.arb').read_text()) if not k.startswith('@')}; [print(arb.name,'orphan:',sorted({k for k in json.loads(arb.read_text()) if not k.startswith('@')} - en)) for arb in sorted(Path('lib/l10n/l10n').glob('app_*.arb')) if arb.name != 'app_en.arb' and ({k for k in json.loads(arb.read_text()) if not k.startswith('@')} - en)]"  # 0 orphan lines
# ARB parity — MISSING check (this is what CI enforces, ci.yml:205). NOW PASSES: 0 missing/locale (issue #1 resolved):
python3 -c "import json; from pathlib import Path; en={k for k in json.loads(Path('lib/l10n/l10n/app_en.arb').read_text()) if not k.startswith('@')}; [print(arb.name,'missing',len(en-{k for k in json.loads(arb.read_text()) if not k.startswith('@')})) for arb in sorted(Path('lib/l10n/l10n').glob('app_*.arb')) if arb.name not in ('app_en.arb',)]"
```

All gates pass at HEAD `fdb85c7` (including the MISSING-key check — 0/locale). After re-running `flutter gen-l10n` clean, re-run `dart run import_sorter:main --no-comments` then `dart format` to normalize the freshly-generated `app_localizations_*.dart` (gen-l10n emits a different import order; lefthook does this on commit anyway).

---

## End-of-session ritual (do this before stopping, every session)

When the user is about to stop — or context fills up (>200k tokens) and `/clear` is near — **always run this ritual before the conversation ends**:

1. **Update HANDOFF.md.** Rewrite the snapshot (date, HEAD sha, tests, analyzer), refresh the state table, append a one-line summary of every commit landed this session, refresh "Next actions", update the verification-command expectations (test count). Drop obsolete sections. Keep the hard rules + this ritual untouched.
2. **Commit the HANDOFF.md update** with a message like `phase-N-fix-cX-handoff: …` + the Co-Authored-By footer.
3. **Tell the user the resume prompt.** Print, in chat, exactly:

   > After `/clear`, paste: **`Continue from HANDOFF.md`**

   Include the new HEAD sha.

This keeps the handoff self-sustaining. Don't skip it because "the session went short."

---

End of hand-off. Resume from §"High-priority discovered issues", then §"Next actions".
