# Guardian Angela v3 — Session Hand-off

**Snapshot:** 2026-05-29 — **Phase 6 CLOSED.** PM (`2edca2d`) + architect + qa-expert verifiers all PASS on fix-pass-D HEAD. Phase 7 (native channels — Android SMS, phone, audio; iOS CallKit) is next.
**HEAD:** `92dfd88` (`phase-6-fix-d8: backfill R-27 row in spec_coverage_test for the cross-overlay PIN test`).
**Tests passing:** `3619/3619` (`flutter test --concurrency=6`).
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
| Phase 6 (screens + routing + R-42 + tests + goldens) | ✅ Done | 3538 | `ee73b62..cedaecf` |
| Phase 6 fix-pass C (PM-FIX_REQUIRED) | ✅ Done — PM PASS at `2edca2d` | 3582 | `5bd1486..b66f5e4` |
| **Phase 6 fix-pass D (architect + qa-expert FIX_REQUIRED + scope expansion)** | ✅ **CLOSED — architect + qa-expert PASS at `58e0155`** | **3619** | `a41ab4d..92dfd88` (5 commits) |
| Phase 7..11 | Pending |  |  |

---

## What Phase 6 fix-pass D delivered (commits `a41ab4d..92dfd88`, 5 commits)

Architect (`voltagent-qa-sec:architect-reviewer`) returned FIX_REQUIRED with 1 defect at HEAD `ce6d224`. qa-expert (`voltagent-qa-sec:qa-expert`) returned FIX_REQUIRED with 3 numbered defects + 1 QUESTION + 3 untriaged MISSING/WEAK alignment rows. Secondary investigation flagged the latter two MISSING rows as full missing-implementation defects (not test-only gaps). User answered the QUESTION (haptic is normative) and approved scope expansion to ship D5 + D6 in fix-pass D.

- `a41ab4d` phase-6-fix-d1-d4 — grace-period SwipeSlider, haptic, back-forward + cross-overlay tests.
  - **D1** `_DisarmAction` (`session_screen.dart:1108-1131`) replaced with `SwipeSlider(threshold: 0.85)`. New `SessionState.stealthEnabled` (resolved at startSession from `mode.overrides?.stealth ?? appDefaults.stealth`) drives the label switch between `sessionDisarm` ("I'm safe") and the new `sessionDisarmStealth` ("No Angela needed") ARB keys. Spec 04:849-852.
  - **D2** `SwipeSlider` gains `HapticFeedback.lightImpact()` on threshold cross; spec 02:460 Extra 56 updated to document the haptic + single-fire wording.
  - **D3** New `swipe_slider_test.dart` test for back-then-forward gesture (drag +240, -200, +240, release) asserting confirmCount == 1.
  - **D4** New `session_screen_test.dart` cross-overlay test: 2 wrong PINs in EndSessionOverlay, dismiss, distress-cancel gate, 3 wrong PINs → confirmDistress fires once with `wrongPinExhausted` (proves R-27 shared counter).
- `e3c1f99` phase-6-fix-d5 — HomeScreen Chain Summary pill row + timing-details sheet.
  - New widget `lib/features/home/widgets/chain_summary.dart` with `ChainSummary` card + `ChainStepTimingSheet` modal + top-level `chainStepIcon` / `chainStepDisplayName` helpers (exhaustive `switch` on `ChainStepType`). 11 EN ARB keys (`homeChainSummaryTitle` etc) + 9 `chainStepName*` keys. 5 widget tests under `HomeScreen — chain summary` group. Spec 04:429-439.
- `ed9f79e` phase-6-fix-d6 — HomeScreen Safety Setup Checklist + tutorials + info sheets + persistence.
  - New widget `lib/features/home/widgets/safety_setup_checklist.dart` (`ConsumerStatefulWidget` + `WidgetsBindingObserver`) with collapsible `Card`, 6 tappable rows, `LinearProgressIndicator`, `ChecklistSheetContent` shared tutorial/info layout. Completion sources: HomeState (contacts, modes), AppSettings (PIN, stealth), `HomeChecklistRepository` (simulation flag, dismissed flag, first-visit flag, SharedPreferences-backed), `Permission.notification.status`. New provider `homeChecklistRepositoryProvider` in `service_providers.dart` + row in `docs/wiring-map.md`. `home_controller.dart` calls `markSimulationDone()` on first simulate=true. 24 new EN ARB keys + 21 new widget tests in `safety_setup_checklist_test.dart`. Spec 04:480-518.
- `58e0155` phase-6-fix-d7 — language agent translated the 44 new EN keys (D1+D5+D6) into all 13 non-EN ARBs (ar, de, el, es, fa, fr, he, hi, pl, ru, uk, zh, zh_TW). ICU placeholders preserved; `@<key>` description blocks kept byte-identical to EN. `flutter gen-l10n` regenerated dart bindings.
- `92dfd88` phase-6-fix-d8 — qa-expert housekeeping: backfill R-27 row in `test/spec_coverage_test.dart` to reference `session_screen_test.dart` for the new cross-overlay shared wrong-PIN counter test.

Tests: 3582 → 3619 (+37). Analyzer 0. ARB parity green.

---

## Spec-vs-spec drifts surfaced during architect re-review (NOT blockers — spec cleanup items)

The architect's PASS-pass at HEAD `58e0155` flagged two internal spec contradictions inside `docs/spec/`. **The code chose the only working route in each case.** These are spec-team cleanup items, not implementation defects:

1. **Spec 04:491 / 04:501 vs 06:128-138.** The Home § mocks write `?type=session` as the PIN-setup discriminator, but the working discriminator (per `PinSetupScreen` + spec 06) is `sessionEnd`. Code uses `sessionEnd`. → Patch 04:491/501 to match.
2. **Spec 04:492 / 04:502 vs 06:533 + 06:569.** The Home § says "Configure stealth → `/settings/defaults`" but Pivot 3 explicitly removed `/settings/defaults` from the route map; the surviving route is `/settings/stealth`. Code targets `/settings/stealth`. → Patch 04:492/502 to match.

Open a separate `phase-6-spec-cleanup` PR to fix 04 to match 06 — no code change.

---

## Out-of-scope findings carried into Phase 7 (or a follow-up fix pass)

The three defects flagged during fix-pass C are still open. Phase 7's plan covers exactly one (the strategy-dispatch wiring); the other two need their own fix pass.

1. **`PinEntryScreen` / app-lock-on-launch does NOT exist.** Spec 04:1900-1945 + 06:130 mandate an App PIN gate on app open. No route, no screen, no app-startup gate. **Not Phase 7 scope.** Open a follow-up `phase-6-fix-e1` or similar before Phase 7 close.
2. **`SettingsSecurityScreen._confirmClear` removes a PIN without verifying the existing PIN first** (`lib/features/settings_security/settings_security_screen.dart:204-231`). An attacker who can unlock the device can wipe any configured PIN. **Not Phase 7 scope.** Same fix pass as #1.
3. **Strategy dispatch (`controller → strategy.executeReal`) is NOT WIRED in production.** The `EventStrategyRegistry` is only used by tests; the engine fires phase timers but no SMS, no phone call, no alarm ever runs. **Phase 7 scope** — native channels finally give strategies something to dispatch to. Verify the wiring lands during Phase 7.

---

## Next actions (resume here)

**Phase 7 — Native channels (PARALLEL: Android ∥ iOS).**

Per `~/.claude/plans/rippling-weaving-puffin.md §Phase 7`:

- **Pre-flight contract:** Dart bridge interfaces in `lib/services/*/native_*_bridge.dart` finalized in Phase 5; verify before dispatching.
- **Agents (parallel — disjoint platform trees, proven safe):**
  - `voltagent-lang:kotlin-specialist` → Android: 11 Kotlin files (`MainActivity`, `SmsChannel`, `SmsWorker`, `CallStateChannel`, `SystemUiChannel`, `PhoneCallHelper`, `BootReceiver`, `HardwareButtonChannel`, `DeviceStateChannel`, `StealthIconChannel`, `GuardianAngelaAppWidget`) + `AndroidManifest.xml` permissions + drawables/layouts/mipmaps resources.
  - `voltagent-lang:swift-expert` → iOS: 5 Swift files (`AppDelegate`, `SceneDelegate`, `CallStatePlugin`, `SystemUiPlugin`, `AlarmAudioPlugin`) + `Info.plist` (literal copy from OLD per D4 one-time extraction) + entitlements.
- **Tests:** Patrol integration tests on emulator (Android) + simulator (iOS): SMS send, phone call, call state listener, hardware button panic, GPS arrival, notification disguise.
- **Verification:** `flutter build apk --debug` succeeds; `flutter build ios --no-codesign` succeeds; native integration tests green; no `import.*OLD/` in either tree.
- **Commit:** single `phase-7: native channels android+ios` after both platforms land.
- **Post-phase cohort (mandatory):** PM (`code-reviewer`) → architect (`architect-reviewer`) → qa-expert serial gate per `rippling-weaving-puffin.md §Post-Phase Verification Cohort`.

**Before Phase 7 starts, dispatch the follow-up fix pass for Out-of-scope items #1 and #2** (PIN entry on launch + PIN-removal verification). These are Dart UI/logic changes that don't depend on native channels and the verifier cohort should sweep them too.

### Phase 7 prep checklist
- [ ] Confirm `lib/services/*/native_*_bridge.dart` contracts are finalized (Phase 5 commit `40d9add..36d30cf` range).
- [ ] Sanity-check: `grep -n "Phase 7" lib/services/` — there should be intentional Phase 7 markers in service files that need wiring.
- [ ] Dispatch Android + iOS agents in parallel.
- [ ] Re-evaluate out-of-scope finding #3 (strategy dispatch wiring) during Phase 7 verification — confirm it landed.

---

## Reading list for the resumer

- `~/.claude/plans/rippling-weaving-puffin.md §Phase 7` (lines 172-181) + §Post-Phase Verification Cohort.
- `docs/spec/05-services.md` §Native channels + `docs/spec/10-platform-matrix.md` for the per-platform capability matrix.
- `lib/services/protocols/` for the Dart bridge interfaces Phase 7 implements behind.
- New surfaces from fix-pass D:
  - `lib/core/widgets/swipe_slider.dart` (haptic + back-forward guard)
  - `lib/features/session/session_screen.dart` (grace-period SwipeSlider + stealth label)
  - `lib/features/session/session_controller.dart` (`stealthEnabled` flag)
  - `lib/features/home/widgets/chain_summary.dart` + `safety_setup_checklist.dart`
  - `lib/features/home/home_checklist_repository.dart` + `homeChecklistRepositoryProvider`
- ARB delta from D1+D5+D6: 44 new EN keys, translated into 13 non-EN locales.

---

## Quick verification commands (run after every fix or stage — per Rule 6)

```bash
flutter analyze --fatal-infos                                                # 0 issues
flutter test --concurrency=6                                                 # all pass (currently 3619)
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

All currently pass at HEAD `92dfd88`.

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
