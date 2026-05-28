# Guardian Angela v3 — Session Hand-off

**Snapshot:** 2026-05-28 — **Phase 6 fix-pass C completed; ready for PM re-verify → architect → qa.** All 4 PM P0 defects + the P1 ARB sweep + the P3 nits are addressed. Next step is to re-run the PM verifier on this HEAD; if PASS, dispatch the architect + qa-expert verifiers in parallel.
**HEAD:** `e77900e` (`phase-6-fix-c6: nits — main.dart present-tense comment + 6 home tests`).
**Tests passing:** `3582/3582` (`flutter test --concurrency=6`).
**Analyzer:** `0 issues` (`flutter analyze --fatal-infos`).
**Branch:** `main`. **Not pushed.** **OLD/ is INERT** (restored twice already; fix-pass-C agents did not touch it).

---

## How to resume

After `/clear`, say "Continue from handoff.md" and start from §"Next actions". The plan files in `~/.claude/plans/` (`make-sure-that-there-typed-tulip.md` + `rippling-weaving-puffin.md`) and `docs/rewrite/v3-plan.md` remain the source of truth.

---

## Hard rules (unchanged — applies to every stage going forward)

1. **OLD/ is INERT.** Never read/list/glob/grep/import anything under `OLD/`. If a hook touches it, restore with `git checkout <prior-commit> -- OLD/` — *do not browse the files*. Already happened twice (Phase 5C; Phase 6 mega-agent dispatch).
2. **NO STUBS at GA.** All 12 S-NN categories in `~/.claude/plans/make-sure-that-there-typed-tulip.md §NO-STUBS` are CI hard fails.
3. **NO INVENTED DEFERRALS.** "Phase X" comments are legitimate ONLY if the named phase's plan actually scopes the work. The Phase 5 user reinforcement and Phase 6 fix-pass B both proved this. See `feedback_no_invented_deferrals.md` in user memory. Grep `lib/features/` for `"Phase 7\|Phase 8\|Phase 9\|Phase 10\|Phase 11"` before every commit; MUST be empty. (`lib/services/` Phase-7 comments are LEGITIMATE — Phase 7 scopes native channels.)
4. **DO NOT guess.** Use `AskUserQuestion` for spec ambiguity.
5. **Pre-alpha = break compatibility freely.** (Drift schema is at v4 now; bump and nuke-and-reseed.)
6. **Verify after EVERY fix or stage.** Analyzer + tests + grep gates. Re-engage the same verifier on `FIX_REQUIRED`.
7. **Write/update HANDOFF.md after each phase if tokens exceed 200k.** (This update is at ~411k.)
8. **Serial default; parallel only at sanctioned points.** Phase 6 used 4 waves of parallel widget-test agents (6+8+8+6, all disjoint files) and 6 parallel golden agents — all succeeded. Sequential for implementation work.
9. **Co-Authored-By footer:** `Claude Opus 4.7 <noreply@anthropic.com>`.
10. **Pure Dart in `lib/domain/`, `lib/services/protocols/`, `lib/data/`.**

---

## Current state at a glance

| Phase | Status | Tests | Commits |
|---|---|---|---|
| Pre-flight (spec rework + 20 gaps + DE-N + Hive→Drift) | ✅ Done | — | `40d9add` + 6 fix commits |
| Phase 0 (flutter create + CI + day-1 Sentry + OLD/ extractions) | ✅ Done | 9 | `ca4343a`, `5608102`, `7f63e73` |
| Phase 1a/1b (domain models + 994 tests) | ✅ Done | 1003 | `d797697`–`7157883` |
| Phase 2 (pure-Dart SessionEngine) | ✅ Done | 1161 | `fb4ce10`–`c7e8774` |
| Phase 3 (Event Strategies + 9 protocols) | ✅ Done | 1581 | `f9bc996`–`03287d1` |
| Phase 4 (Repositories + Drift schema + seed data) | ✅ Done | 1711 | `4969161`–`8cedc2c` |
| Phase 5 (services + Sentry + wiring map) | ✅ Done — 3-agent cohort PASS | 2447 | `5b0bd02`..`36d30cf` (18 commits) |
| Phase 6 (screens + routing + R-42 + tests + goldens) | ✅ Implementation + tests + fix-pass-C done | 3538 | `ee73b62`..`cedaecf` (30 commits) |
| **Phase 6 fix-pass C (PM-FIX_REQUIRED defects)** | ✅ **Implementation done; pending PM re-verify** | **3582** | `5bd1486`..`e77900e` (7 commits) |
| Phase 7..11 | Pending |  |  |

---

## What Phase 6 delivered (commits `ee73b62..cedaecf`, 30 commits)

### Implementation (5 commits)
- `ee73b62` phase-6a: foundation + screen scaffolds (router, route_names, shared widgets, ARB keys, `_AppShell` replacement, 25 feature folders).
- `3dce0ae` phase-6b: remove invented Phase-7 deferrals from features/ (session_controller engine bridge, past_events tombstones, battery_alert step-chain editor, home startSession, event_defaults per-field editors).
- `01177c1` phase-6c-1: past-events 7-day trash + `deletedAtMs` schema (Drift v1→v2, dedicated PastEventsTrashScreen at `/past-events/trash`).
- `621e071` phase-6c-2: quick-exit service triplet (Phase 7 native landing — protocol + Real with MethodChannel + Sim).
- `d451de5` phase-6c-3: `engine.snapshot` getter + session_controller precise remaining time (sealed `EngineState` returned by a getter).

### Widget tests (6 commits, 966 tests across 30 files)
- `8baa89c` phase-6-tests-prelude: shared widget-test harness (`pumpScreen`).
- `8ce5ee7` phase-6-tests: home_screen widget test (cohort reference pattern, 19 tests).
- `d7fa8c8` phase-6-tests-w1: 6 runtime screens — session(53), onboarding(37), fake_call(34), mode_editor(33), contact_form(32), contacts(28). 217 tests.
- `f9d021a` phase-6-tests-w2: 8 settings+profile screens — profile(39), settings_stealth(37), about(33), settings_security(32), pin_setup(31), settings(31), feedback_form(31), backup_restore(31). 265 tests.
- `9c6e0b2` phase-6-tests-w3: 8 config+history screens — event_defaults(58), template_editor(35), history_retention(34), battery_alert(34), notifications_settings(34), gps_logging(31), past_events(31), reminder_templates(27). 284 tests.
- `6c92934` phase-6-tests-w4: 6 remaining screens — past_events_trash(32), distress_modes(31), modes(31), past_events_detail(30), session_completed(30), simulation_summary(27). 181 tests.

### Fix-pass A (8 commits — major spec gaps)
- `7c9a139` phase-6-fix-a-flake: pin past-events-trash remaining-days test to real now (was time-sensitive against `_kNow = 2026-05-27`; the calendar moved past it).
- `41fc163` phase-6-fix-a-format: lefthook format/import-sort cleanup.
- `48ef136` phase-6-fix-a1: fake_call full rewrite — 5 CallStyles (added `whatsapp`, `telegram`, `signal` to the enum), slide-to-answer, declineIsSafe label variants, voice/vibration chips, hold-5s-for-distress.
- `95e7bcc` phase-6-fix-a2: simulation_summary full rewrite — `SimulationSummaryController` + `_PinPrompt` with shake animation + event timeline + Share via share_plus.
- `df91c69` phase-6-fix-a3: notifications_settings per-channel toggles — `NotificationChannelKey` enum, isChannelEnabled + openChannelSettings on the protocol, Real impl using flutter_local_notifications.
- `ce81cd3` phase-6-fix-a4: contacts import + reorder + delete-all — flutter_contacts native picker, ReorderableListView, typed "DELETE ALL" confirmation; DAO gained `bulkUpdate` + `deleteAll`.
- `06f607e` phase-6-fix-a5: modes isBuiltIn schema (v2→v3 + nuke-reseed) + built-in protection (chip + disabled-with-tooltip + swipe-to-delete on custom only).
- `7b10b4f` phase-6-fix-a6: session_completed route params (`?id=` + `?simulation=`) + simulation indicator + View Event Log → /past-events/detail.

### Fix-pass B (7 commits — remaining medium+small gaps)
- `384fda1` phase-6-fix-b1: forms & validation — contact_form iOS SMS warning + per-contact language Dropdown; profile FocusNode blur listener + dedupe l10n keys.
- `4629583` phase-6-fix-b2: security & stealth — biometric toggle, per-PIN Off (clearPin) with confirm, "What is this?" info dialogs, timeout slider moved into Session-End card; StealthIconPreset picker, lock-task toggle wired through session controller.
- `fbfd6a7` phase-6-fix-b3: backup & history — `_includeLogs/_includeMedia` wired into `exportToJson`, error-handling SnackBars, LinearProgressIndicator ribbon, `AppSettings.lastBackupAt` tile, active-session guard; `_SnapSlider` with [1,3,7,14,30,60,90,180,365] stops, Purge-Now button, "Retention updated" snackbar.
- `196c813` phase-6-fix-b4: templates & editors — From-template/From-scratch FAB bottom sheet, delete confirmation dialog, built-in tooltip, beefed-up empty state CTA; Cancel TextButton with discard-changes dialog, Icon picker DropdownButtonFormField, 55%-scaled Live Preview; Delete IconButton + Share menu now Text+PDF (added `pdf ^3.12.0`, `printing ^5.14.3`); outcome Chip per row.
- `db1ab1a` phase-6-fix-b5: onboarding & about — "Use my SIM number" button (Extra 28) wired to new `deviceInfoServiceProvider` triplet, Skip TextButton on pages 2/3; Technical Information section with Bundle ID + Platforms tiles.
- `be8ba73` phase-6-fix-b6: feedback, settings, smaller fixes — RadioListTile + Cancel + new `FeedbackEntry` Drift table (v3→v4) and `FeedbackHistory` DAO/repository; session-lock guard on Redo Onboarding, Emergency Number row with country-preset bottom sheet; Empty trash overflow with typed confirmation; distress_modes empty state + in-use ref check + tooltips; mode editor distress title branching; gps "Address" → "Plus Code"; spec edits at 04:1893–1904 and 04:2109.

### Golden tests (1 commit — 6 alchemist files, 37 scenarios, 59 PNG baselines)
- `cedaecf` phase-6-tests-goldens: home(6), session(6), session_distress_confirmation(6), fake_call(7), onboarding(6), settings(6). Generates both CI and Linux baselines automatically via alchemist.

### Notable new artifacts
- New service triplets: `quick_exit_service`, `device_info_service`.
- New Drift schema columns/tables: `deletedAtMs` on session_logs (v1→v2), `isBuiltIn` on session_modes (v2→v3), `feedback_history` table (v3→v4).
- New shared widgets: `step_chain_editor`, `info_icon_button`, `settings_tile` (in addition to Phase 6a foundation).
- New domain: `FeedbackType` enum, `FeedbackEntry` model, `outcomeFromEndReason()` mapper.
- pubspec.yaml deps added: `flutter_localizations` (sdk), `pdf ^3.12.0`, `printing ^5.14.3`. Dev deps: `permission_handler_platform_interface ^4.3.0`, `plugin_platform_interface ^2.1.0`, `share_plus_platform_interface ^7.1.0`.

---

## Phase 6 fix-pass C — landed (commits `5bd1486..e77900e`, 7 commits)

- `5bd1486` phase-6-fix-c-prelude: HANDOFF.md update + leftover dart format / import_sorter output from after the goldens commit (cedaecf). Zero-functional change.
- `5dc9b05` phase-6-fix-c1: SwipeSlider (`lib/core/widgets/swipe_slider.dart`, 70 % threshold) + EmergencyConfirmOverlay (`lib/features/session/widgets/emergency_confirm_overlay.dart`). The overlay replaces `_CallEmergencyStepUi` during the `duration` phase of a `callEmergency` step. Keep-calling dismisses locally; swipe-to-cancel ends the session (real) or shows a SnackBar (sim, no real call). +6 EN ARB keys. +18 tests.
- `62fcc21` phase-6-fix-c2: session-end SwipeSlider + PIN gate + wrong-PIN distress. Replaced `_confirmEnd` with `EndSessionOverlay`, a two-stage widget (swipe-to-end → PIN keypad). PIN ladder: Duress > App-mismatch hint > Session End > wrong-PIN counter. Wrong PIN count fires distress at `wrongPinThreshold` (default 5) in real session; sim shows informational SnackBar. Deceptive dialog gated behind `appSettings.deceptivePinDialogEnabled`. Wrong-PIN counter lives on `SessionController` (in-memory, shared with C3). Existing canonical `EndReason.duressPin` and `EndReason.wrongPinExhausted` used. +10 EN ARB keys. +10 tests.
- `be29430` phase-6-fix-c3: distress-cancel PIN gate with 15s timeout. Rewrote `_DistressConfirmationOverlay` as `ConsumerStatefulWidget` two-stage state machine (confirmation → pinPrompt). Tap Cancel: if Session End PIN configured, the 5-second distress countdown pauses (via new `controller.pauseDistressCountdown`/`resumeDistressCountdown`) while a 15-second PIN prompt opens. Same PIN ladder as C2. Timeout fires distress with new `EndReason.distressConfirmTimeout`. Exhaustive switches updated (1 production + 2 tests). +7 EN ARB keys. +11 tests.
- `4525a76` phase-6-fix-c5: ARB orphan sweep — dropped 454 keys with no `l10n.<key>` reference in `lib/` or `test/`. Sweep was JSON-safe (python script preserving authoring order) across all 14 ARB files. EN: 1841 → 1005 entries. `flutter gen-l10n` regenerated the 14 `app_localizations*.dart` files.
- `9ffa48e` phase-6-fix-c5-import-sort: post-commit import_sorter blank-line additions on the regenerated l10n .dart files. Zero functional change.
- `e77900e` phase-6-fix-c6: nits — main.dart `:19`/`:163` "Phase 6 will replace..." → present-tense; +6 HomeScreen reference tests (19 → 25 to hit plan target). Validation-error dialog, clearValidationErrors, empty-contacts banner, 8-contact overflow, mode-chip selection follow-through, simulate-button enable.

### Out-of-scope findings noted during fix-pass C

- **`PinEntryScreen` / app-lock-on-launch does NOT exist.** Per spec 04:1900-1945 + 06:130 the App PIN is supposed to lock the app on open. There is no route, no screen, and no app-startup gate. PM verifier did not catch it. Not fixed in fix-pass C (out of scope). Architect should flag.
- **`SettingsSecurityScreen._confirmClear` removes a PIN without verifying the existing PIN first** (`lib/features/settings_security/settings_security_screen.dart:204-231`). An attacker who can unlock the device can remove any configured PIN. Out of fix-pass C scope; flag for architect.
- **Strategy dispatch (`controller -> strategy.executeReal`) is NOT WIRED.** The `EventStrategyRegistry` is only used by tests; no production code path calls a strategy. The engine fires phase timers but no SMS, no phone call, no alarm ever runs. Likely a Phase 7 (native channels) item; flag explicitly so it's not silently deferred.

## PM verifier output — 2026-05-28 (BLOCKING, must fix before architect runs)

Verdict: **FIX_REQUIRED**. 12/14 checks PASS. Two FAILs and one INFO-coverage skipped.

### P0 defects (security/correctness — block Phase 7)

1. **`DeceptiveOldPinDialog` is never invoked.** Widget exists at `lib/core/widgets/deceptive_old_pin_dialog.dart` but `grep -rn 'DeceptiveOldPinDialog\.show\|DeceptiveOldPinDialog(' lib/features/` returns empty. Spec 04:2580 mandates it at PinEntryScreen, SessionScreen session-end prompt, and distress-cancel prompt on every wrong-PIN entry when `AppSettings.deceptivePinDialogEnabled` is true. Deliverable #3 partially met (widget exists), wiring missing.
2. **Session-end confirm is a generic AlertDialog.** `lib/features/session/session_screen.dart:72-102 _confirmEnd` uses Cancel/Confirm — no swipe-slider, no PIN entry, no wrong-PIN-fires-distress. Spec 04:543-545: "Swipe-to-confirm slider; if PIN required, prompt for PIN after swipe; wrong PIN 5× fires the mode's selected distress chain."
3. **Distress confirmation Cancel ignores Session-End PIN gate.** `lib/features/session/session_screen.dart:393-469 _DistressConfirmationOverlay` calls `cancelDistress()` immediately on FilledButton tap. Spec 04:640-642: "If Session End PIN configured, PIN prompt appears (15 s timeout); correct PIN dismisses, wrong PIN shakes + 'Incorrect PIN' (or deceptive dialog), timeout fires distress."
4. **`EmergencyConfirmScreen` + `SwipeSlider` are not implemented.** Spec 02:458-460 requires a confirmation countdown UI before the call (with `SwipeSlider` per spec 02:460 Extra 56 + `[Keep calling]` button). `lib/features/session/session_screen.dart:1004-1028 _CallEmergencyStepUi` shows only a status label. `lib/core/widgets/swipe_slider.dart` does NOT exist. `lib/domain/orchestration/strategies/call_emergency_strategy.dart:20-23` documents the missing controller wiring. Q27 ties this to an `emergencyConfirmationRequests` stream that is absent from `SessionEngine`. Deliverable #4 unmet.

### P1 — must land before Phase 8 fanout
5. **418 of 902 EN ARB keys are orphan** (no `.<key>` reference in `lib/features|core|main|router`). Sample: `commonYes`, `commonNo`, `commonAdd`, `commonDone`, `commonRetry`, `aboutCredits`, `audioRunningLatePhrase`, `backupExport`, `distressConfirmationTitle`, `distressConfirmationCountdown`. Per the pre-flight contract freeze, ARB keys should be finalized — 46 % unused will mislead Phase 8 translators. Fix: either delete the unused keys or wire them to their intended sites.

### P3 — nits
6. **Stale "Phase 6 will replace…" comments** at `lib/main.dart:19` and `:163`. Replace with present-tense.
7. **Home reference test has 19 tests vs the ≥25 plan target.** Other 28 features all meet/exceed. Add ~6 more (empty state checklist progress, simulation/real toggle, etc.) for parity.

---

## Next actions (resume here)

**Phase 6 fix-pass C is done. Re-run PM verifier → architect → qa.**

### Step 1 — DONE (kept for reference)

### Old Fix-Pass C plan (kept for reference)

Scope and suggested commit chain:

- `phase-6-fix-c1: SwipeSlider widget + EmergencyConfirmScreen` — create `lib/core/widgets/swipe_slider.dart` (HorizontalDragGesture + Animated progress, ≥85 % to fire); create `lib/features/session/widgets/emergency_confirm_overlay.dart` rendering during `_CallEmergencyStepUi` step. Wire through `SessionEngine.emergencyConfirmationRequests` (add the stream) per Q27. Strategy fires only after user swipes; `[Keep calling]` extends the countdown.
- `phase-6-fix-c2: session-end swipe-slider + PIN gate + wrong-PIN distress` — replace `_confirmEnd` with a SwipeSlider; when `appSettings.sessionEndPinHash != null`, prompt PinKeypad after swipe; wrong PIN increments a controller counter and fires distress at 5×; wire `DeceptiveOldPinDialog.show(...)` when `appSettings.deceptivePinDialogEnabled`.
- `phase-6-fix-c3: distress-cancel PIN gate` — `_DistressConfirmationOverlay` Cancel button → if Session-End PIN configured, PinKeypad with 15 s timeout; correct dismisses, wrong shakes + (deceptive dialog if enabled), timeout fires distress.
- `phase-6-fix-c4: deceptive-PIN dialog wiring everywhere` — call sites at PinSetupScreen (when entering wrong existing PIN), SessionScreen session-end PIN, distress-cancel PIN, app-PIN unlock. Gate behind `appSettings.deceptivePinDialogEnabled`.
- `phase-6-fix-c5: ARB sweep` — delete unused EN keys (the 418 orphans) and verify nothing in `lib/` references them; OR wire them to their intended sites if they were meant to be used. Note: this affects only `app_en.arb`; Phase 8 fan-out hasn't touched the others yet.
- `phase-6-fix-c6: nits` — main.dart Phase-6 comment cleanup; +6 home reference tests.

Each commit runs the standard verification gates (see below). Update relevant widget tests to lock the new behavior.

### Step 2 — Re-run PM verifier

Same prompt as the PM agent that ran at `cedaecf`. Pass HEAD = the new fix-pass-c HEAD. Verdict must be PASS before architect runs.

### Step 3 — Spec-vs-code agent (`voltagent-qa-sec:architect-reviewer`, opus)

Per the plan §Post-Phase Verification Cohort. For each normative requirement in spec 04 + spec 06 (the screens phase), find the corresponding code and report alignment. Verdict: PASS/FIX_REQUIRED/QUESTION.

### Step 4 — Spec-vs-tests agent (`voltagent-qa-sec:qa-expert`, opus)

For each spec requirement, find the test that exercises it. Verdict: PASS/FIX_REQUIRED/QUESTION. Spec coverage matrix must be advanced.

### Step 5 — Phase 6 close

When all 3 verifiers PASS, mark Phase 6 closed. Phase 7 (native channels) starts.

---

## Reading list for the resumer

- `~/.claude/plans/rippling-weaving-puffin.md §Phase 6` and §Post-Phase Verification Cohort.
- `docs/spec/04-screens-navigation.md` — the spec the verifiers compare against.
- `docs/spec/06-settings.md` — per-setting semantics.
- `lib/core/widgets/deceptive_old_pin_dialog.dart` — exists; needs callers.
- `lib/features/session/session_screen.dart` — _confirmEnd + _DistressConfirmationOverlay + _CallEmergencyStepUi (the 3 P0 wiring sites).
- `lib/services/service_providers.dart` — wiring graph; no changes expected from fix-pass C unless new providers needed.
- `lib/l10n/l10n/app_en.arb` — 1101 → ~1500 lines after fix-pass B. The orphan sweep will trim or fill.

---

## Quick verification commands (run after every fix or stage — per Rule 6)

```bash
flutter analyze --fatal-infos                          # 0 issues
flutter test --concurrency=6                           # all pass (currently 3538)
grep -r 'package:flutter' lib/domain/                  # must be empty (S-7)
grep -r 'package:flutter' lib/services/protocols/      # must be empty (S-7)
grep -r 'package:flutter' lib/data/                    # must be empty (S-7)
grep -rEn 'UnimplementedError|throw .TODO|TODO|FIXME|XXX|HACK|Container\(\)|Placeholder\(\)' lib/ | grep -v 'ProviderContainer()'    # only ProviderContainer() in main.dart (Riverpod, allowed)
grep -rn "Phase 9 file-picker\|will be available in a future\|coming in Phase\|deferred to Phase" lib/    # 0
grep -rnE "(Phase 7|Phase 8|Phase 9|Phase 10|Phase 11)" lib/features/    # 0 (legitimate refs are in lib/services/ — Phase 7 = native channels)
grep -rEn 'class DistressChain|repeatCount|leapToNextEvent|LoudAlarmSound\.(beep|whistle|scream|whoop)|SmsRecipient|flashSpeed\b|maxVolume\b|Hive\b|@HiveType|@HiveField|PauseReason\.bootRestart|EndReason\.appTermination|fakeCallAnswered' lib/ test/ integration_test/   # 0 (S-4)
grep -rn "import.*['\"].*OLD/" lib/ test/ integration_test/   # 0 (S-5)
git diff-tree -r --name-only HEAD -- OLD/              # empty (OLD/ untouched)
grep -rn 'Real.*Service(' lib/ | grep -v service_providers.dart | grep -v 'lib/services/[^/]*_service\.dart:.*class Real'  # only constructor declarations inside their own service file
```

**All currently pass at HEAD `cedaecf`** except `DeceptiveOldPinDialog` wiring + 3 PIN-gate defects + 1 EmergencyConfirmScreen + 1 SwipeSlider widget + 1 P1 ARB sweep + 2 P3 nits (per PM verifier).

---

## Files / paths for the resumer

- **Plans:** `~/.claude/plans/make-sure-that-there-typed-tulip.md`, `~/.claude/plans/rippling-weaving-puffin.md`, `docs/rewrite/v3-plan.md`, `docs/rewrite/lessons-learned.md`.
- **Spec (12 files):** `docs/spec/00-overview.md` … `docs/spec/11-deferred-enhancements.md`. Phase 6 patched 04:1893–1904 (inline stealth card → "superseded by routed pattern") and 04:2109 (auto-save on collapse → "auto-save on each edit").
- **Phase 6 screen layer:**
  - 31 routes in `lib/router/app_router.dart` (29 spec routes + Past Events Trash + Past Events Evidence) consuming `lib/core/constants/route_names.dart`.
  - 31 feature folders under `lib/features/` (one per route + shared mode_editor for distress modes).
  - Shared widgets in `lib/core/widgets/`: pin_keypad, timing_slider, deceptive_old_pin_dialog (R-42), pride_page_indicator, settings_tile, info_icon_button, step_chain_editor.
  - Tests in `test/features/<feature>/*_test.dart` × 30 (966 widget tests) + `*_golden_test.dart` × 6 (37 alchemist scenarios + 59 PNG baselines).
  - Wiring map at `docs/wiring-map.md` updated for new triplets (quick_exit, device_info, feedback_history).

End of hand-off. Resume from §"Next actions".
