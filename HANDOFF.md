# Guardian Angela v3 — Session Hand-off

## ⇒ ORCHESTRATOR RESUME — READ THIS FIRST (fresh-session entry point)

**Run AS ORCHESTRATOR, not implementer** (memory `feedback_orchestration_handoff_baton`):
stay lean, delegate ALL spec/source reading to fresh Opus sub-agents, consume only
this baton + each agent's final report. Per chunk: fresh implementer (Opus,
background, **SOLE committer** on the tree) → per-chunk **cohort** (architect-reviewer
spec-vs-code + qa-expert spec-vs-tests, both Opus, parallel, READ-ONLY) → on
FIX_REQUIRED a fresh fix agent → re-cohort the delta → advance. Do a cheap
orchestrator `git` sanity-check after each agent BEFORE spending cohort tokens. **ONE
committing agent on the tree at a time.** Auto-chain + push are pre-authorized for this
run; interrupt the user ONLY for a genuine BLOCKED value/spec decision.

**VERIFIED STATE (clean stop):** HEAD = the baton commit atop code commit `e98bb1a`,
**+18 commits UNPUSHED** vs origin/main (=`f5eea2c`), tree clean. Suite **4464 pass**,
`analyze --fatal-infos` = 0, **coverage-of-logic 93.11%**, floor 92.5. M0–M4 PUSHED;
M5 (FINAL milestone) in progress. (NB: local commits survive a `/clear`; the fresh
session continues C7d→C10 then pushes the whole stack at C10.)

**COHORT-VERIFIED LEDGER — do NOT re-verify; resume at C7d:** C1/C2/C3/A5 (INT scenarios
+ SMS-cancel-on-disarm, prior sessions) · C4 (device-e2e #11/#12/stealth) · C4-fix
(device-e2e honesty — tagged `@Tags(['device-e2e'])` + #12 hardened to fail-loud on host)
· C5 (coverage-of-logic gate + ratchet floor; honest 2-file exclude) · C6 (5 safety
services + main.dart) · C6b (non-feature tail) · C7a (session + fake_call feature
tail) · C7b (modes feature — incl. an arch systemic sweep proving the
clear-to-null fix is the COMPLETE remediation across lib/) · **C7c (editors +
distress + the fake-call hold de-flake; distress delete-guards verified against
spec end-to-end; NO new bugs — clear-to-null pattern re-checked clean)** — ALL
architect+qa **PASS**.

**5 production bugs found+fixed+verified this run** (for the C10 milestone summary):
(1) `RealFlashService.stopFlash()` hung while a flash loop ran → SOS flash couldn't stop
on disarm; (2) `messaging._launchUrl`/`phone._dial` un-awaited `return launchUrl()` let an
async rejection escape the degrade catch → a failed distress-SMS/call threw instead of
degrading to `false`; (3) C4 `CallStateChannel.kt` MethodChannel/EventChannel name-shadow
→ a real incoming call never paused a session; (4) C7a `SessionController.
_stopForegroundService` read `ref` during `onDispose` teardown (`UnmountedRefException`,
swallowed by the non-fatal catch) → the persistent foreground notification leaked on
mid-session teardown; fix = capture `_backgroundService` at session start
(architect-verified against the Riverpod 3.2.1 source); (5) C7b clear-to-null —
`_PhoneCallContactForm`/`_CallEmergencyForm` cleared contactId/emergencyNumber via
`copyWith(null)`, silently swallowed by the `?? this.x` idiom (`step_config.dart:699/:921`)
→ a user reverting to the regional default emergency number kept dialing the stale one;
fix = direct-construction helpers `_withContactId`/`_withNumber` (red→green proven).

**NEXT = C7d (history/logs).** The fake-call hold flake is FIXED (C7c: `now` clock seam
on FakeCallScreen, test lockstep-deterministic, 10s Stopwatch = backstop only). Remaining
slices (~150–180 missed lines per agent — calibration: C7a 188L/6f = 335k actual, C7b
158L/10f = 249k, C7c 144L/12f+pretask = 202k; always read the harness usage line, never
self-reports):
- **C7d — history/logs (180, 6 files):** past_events_trash_screen 41/119 + _controller
  39/43, past_events_detail_screen 38/122, past_events_controller 36/40,
  history_retention_controller 15/18 + _screen 11/73.
- **C7e — home + post-session (170, 9 files):** home_controller 39/52, home_screen
  28/195, chain_summary 12/102, safety_setup_checklist 10/224, simulation_summary_screen
  29/199 + _controller 26/49, gps_logging_controller 24/27, feedback_form_screen 2/80.
- **C7f — nav/entry + contacts (159, 8 files):** app_router 60/111, contacts_screen
  29/131 + _controller 27/30, onboarding_screen 26/190 + _controller 5/31,
  contact_form_screen 6/157, launch_pin_screen 6/120.
- **C7g — settings + misc (155, 11 files):** settings_security_controller 55/75 +
  _screen 7/117 + remove_pin_dialog 5/77, settings_screen 21/235 + _controller 15/50,
  backup_restore_screen 22/122, profile_controller 10/13 + _screen 5/137,
  settings_stealth_controller 9/41 + _screen 1/89, about_screen 4/72, pin_setup_screen
  1/90.
Only ~5 of these lines are `Platform.is*` device-only (about/contacts/contact_form;
fake_call's were host-covered by C7a). Implementer lessons now baked into prompts: pipe
coverage-run output to a FILE, never through `tail` (a truncated log forced C7a to
duplicate a full coverage run); NEVER run bare `dart format .` (it reformats OLD/ —
scope to `dart format lib test`).

**THEN:** **C8** — populate `test/spec_coverage_test.dart` + enable its Phase-9
assertions; reconcile the stale `docs/spec/07-test-plan.md` contract table. C8 list now
also includes: the **6 C6 + 10 C6b coverage host-test files have NO spec-07 IDs** (add
rows or a "coverage host-tests" annex); split **INT-007** into host (`test/integration/
call_state_session_test.dart`) vs device (`integration_test/real_call_pause_test.dart`);
add device rows for **#12 background-throttle** + the **stealth launcher-alias swap**; iOS
rows = "(CI build-ios)" only, never faked device-green; spec-05 notes (the stopFlash
per-loop-captured-completer invariant is load-bearing; the launch degrade-to-`false`
contract). → **C9** — doc-sweep: **~31 stale `Phase [0-9]` comment markers across ~27
`lib/services/` files** (incl. `protocols/*` "Phase 5 supplies…" boilerplate,
`service_providers.dart:8`, `quick_exit_service`, `background_session_service`,
`audio_service`, `permission_audit_service`) + the CLAUDE.md native-files list tidy
(**`PhoneChannel.kt`/`DeviceStateChannel.kt` are listed but don't exist**). → **C10** —
final GA-readiness milestone cohort + the authoritative full gate + **PUSH the whole M5
stack** (declares the v3 wiring remediation DONE). **Do NOT push before C10.**

**C10 DENOMINATOR DECISION (orchestrator/user call at C8 or C10):** to set the final
~99%-of-logic target, decide (a) exclude the **~71 codegen Drift-DSL lines** (glob
`lib/data/db/tables/*.dart`; PROVEN to throw "should not be called at runtime" — legit,
structurally like `*.g.dart`); (b) treat the **~96 `Platform.is*` device-only lines** as
device-e2e/CI-build-covered (user already ruled iOS = "CI-build-verified is sufficient").
With both handled, 99%-of-logic is reachable; the census confirms a ~98–99% host ceiling.

---

**Snapshot:** 2026-06-09 — **M0–M4 PUSHED (`origin/main` = `f5eea2c`). M5
(FINAL milestone, Phase-9) IN PROGRESS — C1 + C2 + C3 + A5 + C4 + C4-fix + C5 +
C6 + C6b + C7a + C7b + **C7c (editors + distress + de-flake)** DONE +
COHORT-VERIFIED (architect+qa PASS; all UNPUSHED — code HEAD = `e98bb1a` + the
`m5-c7c` baton commit atop, ahead of origin/main by **18**). THIS session:
**C7a (89.46→90.86%, bug #4) + C7b (→92.05%, bug #5) + C7c (→93.11%, fake-call
hold test de-flaked, distress delete-guards spec-verified) — all cohort-PASS.
NEXT = C7d (history/logs), then C7e..C7g per the resume block.**

---

## KEY FINDINGS (C7c — new baseline + carry to C7d..g)

**Coverage-of-logic 92.05% → 93.11%** (12385 / 13302; +140 covered). **Floor
91.4 → 92.5** (gate OK at 92.5, RED at 99.9). Suite **4422 → 4464** (+42), 0
fail. analyze 0. distress_modes_controller 42→0, reminder_templates 50→1,
template_editor 27→0, event_defaults 11→0, mode_editor 7→2, reminder_confirmation
3→0.

**FLAKE FIXED (the C7a haptics hold test):** `FakeCallScreen` gained an optional
`now` clock param (`@visibleForTesting`, defaults `DateTime.now` — sole
production caller `app_router.dart:128` omits it). Test drives a fake clock in
lockstep with the 80ms ticker pumps → fully deterministic (42/42 in ~2s vs the
old 10s wall-clock race; Stopwatch budget = runaway backstop only). Hang-up test
now also pins `confirmDistressCalls == 0`. Arch verified hold semantics
unchanged vs spec-02 §fakeCall (haptic 800ms once-window, confirm at ≥hold,
hang-up never escalates; fakeCall stays an event-not-pause).

**NO new bugs** (clear-to-null copyWith pattern explicitly re-checked on these
surfaces — clean). RED-proofs: distress delete-default guard (controller) +
in-use delete second-line-of-defense (screen), both directions pinned.

**Remaining missed (4, honest):** mode_editor_screen:219-220 `distressNoActionStep`
`_issueMessage` arm — defensive-unreachable (validator only emits it
non-blocking; QA verified vs mode_draft_validator:122; exists for switch
exhaustiveness — C9 may annotate); 2 `const …Screen({super.key})`
const-canonicalization jitter lines (standard Dart lcov noise, absorbed by the
−0.6 floor buffer; ALSO note C7b pinned the same phenomenon by constructing one
instance non-const with UniqueKey — a reusable trick).

**QA minor (parked):** reminder_templates_screen_test:710-727 "tapping disabled
Delete" never taps — convert to drive `onSelected?.call('delete')` like the
distress-modes pattern (harmless noise today).

**C9 additions from C7c:** distress_modes_screen_test ~:96 orphaned doc comment
("Records routes pushed…" belongs to _FakeNavigatorObserver); fake_call test
header says "hold-5s" but drives a 1s configured hold; mode_editor_screen:219
dead-arm annotation candidate.

**Orchestrator calibration:** C7c = 144 missed / 12 files + pre-task → **202k
actual, 161 tool-uses, 31 min**. Cohort: arch 61k + qa 131k. Most expensive:
reminder_templates_screen FAB/sheet/builtin-picker modal flows (router-harness
upgrade), then the distress_modes safety matrix.

---

## KEY FINDINGS (C7b — new baseline + carry to C7c..g)

**Coverage-of-logic 90.86% → 92.05%** (12245 / 13302 lines; +168 covered).
**Floor ratcheted 90.2 → 91.4** (gate PROVEN OK at 91.4, RED at 99.9). Suite
**4357 → 4422** (+65), 0 fail. analyze 0. All 10 modes files at **ZERO missed**.

**PRODUCTION BUG #5 (fixed, cohort-verified + systemic sweep):** see resume
block. Arch cohort enumerated EVERY clear-to-null path through `?? this.x`
copyWiths across lib/ — the 2 fixed instances were the only REAL bugs; all
sibling forms already use direct-construction helpers (`_withTemplate`,
`_modeWithOverrides` family, `_gpsWithLat/Lng`, `_withSelection`) or explicit
`clearX`-flag copyWiths. Pattern note for future code: `SessionMode.copyWith`
/ step-config copyWiths CANNOT null a field — use the helper pattern.

**Known flake (C7a-origin, MUST FIX in C7c):** fake_call haptics hold test
races real wall-clock — see the NEXT block for the QA hardening prescription.

**QA minors (parked, non-blocking):** event_specific_config_test could assert
spinner disappearance when showConfirmation flips false; modes_screen "distress
modes NOT shown" test name/docstring misaligned (the real gate is proven in
modes_controller_test:65-72); mode_event_defaults 9-type routing proof relies
partly on type-cast crash semantics (sound); modes_controller ordering-stability
untested (out of scope).

**C9 addition from C7b:** hard-coded English snackbar
`'Name, title, and body required.'` at
`lib/features/modes/widgets/safety_options_section.dart:837` — not localized
(needs an l10n key + the 13-language delta per the language-agent rule).

**Orchestrator calibration:** C7b = 158 missed / 10 files → **249k actual,
144 tool-uses, 31 min**. Cohort: arch 75k + qa 103k. Wall-clock dominated by
the two full-suite runs (plain ~25 min, coverage ~45 min). Most expensive
sub-surface: safety_options_test (full ModeEditorScreen + in-memory DB pumps
per test — now the longest-running touched suite).

---

## KEY FINDINGS (C7a — new baseline + carry to C7b..g)

**Coverage-of-logic 89.46% → 90.86%** (12077 / 13292 lines; +191 covered).
**Floor ratcheted 88.8 → 90.2** (gate PROVEN OK at 90.2, RED at 99.9). Suite
**4287 → 4357** (+70), 0 fail. analyze `--fatal-infos` = 0. Host only.

**Per-file (missed before→after):** session_controller 80→2 (the 2 =
defensive-unreachable :1136 null-state tick guard + :1515 `EngineRunning(-1)`
pattern arm); session_screen 70→2 (:469 DEAD stealth-disarm ternary — the
`_StandardSessionBody` only builds when `!stealthEnabled`; **C9 candidate**;
:888 unmounted pin-timer guard); end_session_overlay 14→0;
session_elapsed_clock 8→0; fake_call_screen 12→0; fake_call_controller 4→0.

**PRODUCTION BUG #4 (fixed, cohort-verified):** see the resume block. Test
"disposing the container mid-session … stops the foreground service" pins it
(red pre-fix). Seams added (C6 pattern): `session_controller.dart:1737`
`eventServices` getter + `:1743` `debugHandleEngineEvent(...)`.

**Cohort PASS ×2 with MINOR notes (non-blocking, parked):** (arch) `_disposeAll`
stops the FG service but not lock-task mode — PRE-EXISTING asymmetry, moot
(pinning dies with the process; `toggleLockTaskMode` would hit the same
ref-in-teardown throw — same capture-at-start pattern is the fix if ever
wanted); (qa) fake_call hang-up test could add an explicit
`confirmDistressCalls == 0`; the active-ticker test only proves no-crash (pump
can't advance wall-clock); lifecycle test uses 8s Stopwatch polling loops where
async DB writes prevent fakeAsync.

**C9 additions from C7a:** session_screen.dart:464-471 dead stealth ternary;
`EventServices.isCancelled` has NO production consumer though its doc says
strategies poll it (`event_services.dart:169-172`) + stale
`// ignore: avoid_returning_null_for_void` there.

**Orchestrator calibration:** C7a = 188 missed lines / 6 files → **335k actual
subagent-tokens, 217 tool-uses, 55 min** (self-estimate said 180k — LOW).
Cohort cost: arch 61k + qa 90k. Most expensive sub-surface: the
session_controller lifecycle suite (3 fix iterations: holdWait-vs-wait phases,
sim-recorder non-persistence, `??` downward-inference nullability) + a
duplicated full coverage run (truncated `tail` log).

---

## KEY FINDINGS (C6b — new baseline + carry to C7)

**Coverage-of-logic 87.14% → 89.46%** (11886 / 13286 lines; +310 covered).
**Floor ratcheted 86.5 → 88.8** (`tool/coverage/coverage_floor.txt`, ~0.6%
jitter headroom; gate PROVEN OK at 88.8, RED at 99.0). Suite **4173 → 4287**
(+114 net-new), 0 failures. analyze `--fatal-infos` = 0. Host only, no emulator.

**Per-file results (C6b targets, all driven by REAL host tests — real in-memory
Drift `GuardianAngelaDatabase.memory()`, real MethodChannels via
`TestDefaultBinaryMessenger`, `fakeAsync`, mock plugins — NOT the Sim services,
no vacuous asserts):**
- `recording_service` 12%→**100%** (`recording_service_real_test.dart`): mocked
  `AudioRecorder` + path_provider; permission StateError, path construction,
  the auto-stop cap Timer under fakeAsync, Extra-39 validation.
- `phone_service` 69%→**100%** (real `_dial` via url_launcher mock + the
  degrade catch — see the bug below).
- `timing_slider` 61%→**100%** (`timing_slider_test.dart`, widget): log-scale
  Slider commit-on-release, snap, s/m/h/d formatting, didUpdateWidget, the
  manual-entry dialog (valid/clamp, non-numeric, Cancel, same-value).
- feedback-history **dao+repo+table 0%→100%** (`feedback_history_test.dart`):
  one coherent in-memory-DB test (insert/getAll-desc/deleteAll, mappers, the
  table column DSL, every FeedbackType).
- `contacts_repository` 44%→**100%** (`contacts_repository_test.dart`);
  `contacts_dao` (bulkUpdate+deleteAll) / `sms_retry_jobs_dao` (hashCode) /
  `database` (real `open()` via path_provider mock + a quoted key → the
  `_escapePragma` path) / `pin_keypad` / `home_widget` / `chain_event` +
  `permission_revocation` toString → **100%**.
- `json_singleton_repository` 92%→**98.7%** (the DEFAULT path_provider-backed
  resolveDir + the save dir-create branch).
- `audio_service` 55%→**96%** (`audio_service_real_test.dart`): playSound /
  playAlarmWithConfig (custom + immediate-volume + ArgumentError) /
  playVoiceRecording (file + built-in + Layer-3) / stop / bootstrapVoiceAssets
  (per-locale TTS synth, skip-cached, onFailure, zh BCP-47 map).
- `messaging_service` 82%→**92.5%** (phoneCall dispatcher, Telegram https
  fallback, `_launchUrl` degrade, iOS sms: fallback, `SmsRetryExhaustedEvent`).
- `session_start_validator` 74%→**94.4%** (`updateCachedState` drives the real
  permission loop + the `_toHandlerPermission` switch over all six perms + the
  battery check; refreshed cache flips validate() outcomes).
- `service_providers` 60%→**95.3%** (`service_providers_wiring_test.dart`):
  every Real* provider lambda READ through a real `ProviderContainer` (in-mem
  DB + sim-encryption overrides) so the construction runs; record/home_widget
  channels mocked; the real `databaseProvider.open()` body covered separately.
- `notification_service` 46%→**76%** (`isChannelEnabled` iOS branch + catch,
  desktop `requestPermission`, `cancel`, `_onResponse`, the top-level
  `_onBackgroundResponse` via a `@visibleForTesting` alias). The remaining 31
  are Android/iOS `Platform.is*`-gated — device-only.
- `permission_audit` 95%→**98.7%** (the no-perm step-type switch arms);
  `session_engine` 97%→**98.8%** (`engine_edges_test.dart`: empty-chain
  ArgumentErrors, grace-retry re-exec, holdWait pause/resume no-op);
  `swipe_slider`→92% (pan-cancel test added; the `_onPanCancel` body still
  shows uncovered — the test-arena cancel routes to `_onPanEnd`, which IS
  covered and is functionally identical; a 7-line cosmetic gap).

**PRODUCTION BUG FOUND + FIXED (`messaging._launchUrl` + `phone._dial`).** Both
had `return launchUrl(uri, ...)` INSIDE a `try` WITHOUT `await`. Because
`launchUrl` is async, the `try` completed normally returning the pending
future, so the `catch (e) { log; return false; }` was DEAD for async
rejections — a failed launch (PlatformException: no handler app / no foreground
activity) propagated an UNHANDLED exception up the dispatch chain instead of
degrading to `false` per the methods' documented contract. A safety app whose
SMS/phone/url launch crashes the dispatch on a missing handler is a real
defect. FIX: `return await launchUrl(...)` in both, so the degrade catch fires
(host-proven red→green). Caught only because C6b drove the REAL launch.

**Test seam added** (matches the C6 hardware_button pattern): a
`@visibleForTesting notificationBackgroundResponse(...)` alias in
`notification_service.dart` exposes the private top-level `_onBackgroundResponse`
(`@pragma('vm:entry-point')`) so the real SharedPreferences replay-queue persist
runs on the host.

**THE DEVICE-ONLY / CODEGEN-ONLY CENSUS (for C7 host-ceiling planning).** The
NON-feature surface that NO host test can reach (left in the denominator, NOT
excluded — honest):
- **Codegen-only Drift table DSLs ≈ 71 lines** — the column getters in
  `lib/data/db/tables/*.dart` (contacts 9, session_modes 18, reminder_templates
  15, session_logs 12, sms_retry_jobs 9, feedback_history 8). Drift's
  `text()`/`integer()`/… DSL methods THROW `"This method should not be called
  at runtime"` (PROVEN) — they are compile-time-only inputs to build_runner,
  reachable by no test (host OR device). Structurally equivalent to `*.g.dart`.
  **A future exclusion (glob `lib/data/db/tables/*.dart`) is a defensible
  orchestrator call — flag for C8/C9** (would lift the denominator by ~71).
- **Platform.is*-gated native service paths ≈ 96 lines** — concentrated in 5
  files: `notification_service` (Android channel-query + Android/iOS
  requestPermission + `_channelIdFor` ≈31), `device_info_service` (Android
  getSimPhoneNumber channel + exception branches ≈10), `messaging_service`
  (Android enqueueSms + cancelPending body ≈8), `hardware_button_service` (iOS
  headphone-remote ≈21, already noted by C6), `background_session_service`
  (`_onBackgroundStart` isolate entrypoint + iOS configure closure ≈13).
  Covered by device-e2e (`tool/device_e2e/*.sh`) / CI build-ios, not host.
- **Thin Sentry SDK passthrough ≈ 9 lines** — `_RealSentrySdk.init/
  captureException/close` wrap `SentryFlutter`/`Sentry` statics; tests inject a
  fake SDK (driving real `RealSentryService` logic), so the wrapper only runs
  against the real network SDK.
- **`main.dart` ≈12** (the real `runApp` entry + a few recovery edge taps) and
  small Sim-service tails (`audio_service_sim` 2, `phone_service_sim` 4,
  `recording_service_sim` 3) round out the non-feature remainder.

**MAGNITUDE for the host-coverage ceiling:** the non-feature device/codegen-only
floor is **≈ 185 lines** (71 codegen + ≈96 native + 9 sentry + small tails).
**The `lib/features/` surface is overwhelmingly host-reachable** — only ~5
`Platform.is*`-gated lines across all of `lib/features/` (about/contacts/
fake_call/contact_form screens). So C7's 1153-missed feature surface (85.7%
covered today) is nearly all coverable by widget + controller host tests; the
host ceiling for the WHOLE app is high (~98–99% once C7 lands), the device-only
floor sits almost entirely in the ~185 non-feature lines above.

**Coverage tooling reminders (unchanged from C5/C6):** `flutter test --coverage
--concurrency=6` → `LCOV_BIN=/home/jonas/lcov/bin/lcov bash
tool/coverage/filter_coverage.sh` → `bash tool/coverage/check_floor.sh` (the
`Coverage of LOGIC: NN.NN%` line). lcov is the vendored perl clone at
`/home/jonas/lcov/bin/lcov` (not on PATH). Bump the floor in
`coverage_floor.txt` AFTER the covering tests land. The exclusion list
(`coverage_excludes.txt`) is unchanged by C6b (5 globs: l10n / `*.g.dart` /
`*.freezed.dart` / system_ui / wakelock); the C6b "DELIBERATELY NOT EXCLUDED"
census is recorded in its comment block.

---

**THE C6 WORK (the prior session):**
- **5 priority safety services driven by REAL host tests** (NOT the
  simulations — the genuine production parse/detection/timing logic runs via
  `TestDefaultBinaryMessenger` mock channels + `fakeAsync`). +99 service tests:
  - `call_state_service.dart` 0%→**100%** (`call_state_service_real_test.dart`,
    20 tests) — drives the real EventChannel via a StandardMethodCodec success
    envelope so `_onNativeEvent` + the `_parseCallState` string→enum switch run,
    incl. the unknown-string / non-String / stream-error / endOfStream /
    MethodChannel-throw branches.
  - `flash_service.dart` 0%→**100%** (`flash_service_real_test.dart`, 14 tests)
    — real SOS morse + continuous loops under `fakeAsync` against a mocked
    `torch_light` channel; graceful-degradation catch; the stopFlash
    Completer-fix. **SURFACED + FIXED A REAL PRODUCTION BUG** (see below).
  - `location_service.dart` 0%→**100%** (`location_service_real_test.dart`,
    28 tests) — mocked `geolocator` MethodChannel + `geolocator_updates`
    EventChannel: requestPermission (all 5 branches), fresh-vs-cached fallback,
    stale-note ISO-8601 formatting, the 1000-point FIFO history eviction.
  - `contact_service.dart` 0%→**100%** (`contact_service_real_test.dart`,
    12 tests) — repo-backed cache against a real in-memory Drift DB.
  - `hardware_button_service.dart` 0%→**81.6%** (`hardware_button_service_real_test.dart`,
    25 tests) — the VOLUME-BUTTON DISTRESS TRIGGER. A `@visibleForTesting`
    `subscribeNativeChannelForTest()` seam (wires the real Android EventChannel
    regardless of host platform — `start()` gates it on `Platform.isAndroid`)
    lets the test drive real `{action,key}` events through the channel so the
    real `_onNativeEvent` parse + key-filter + repeat-press sliding-window +
    long-press duration + param clamping run. Both directions of the
    false-positive-vs-missed-trigger boundary are asserted. **The ~21
    uncovered lines are the iOS headphone-remote path (`_startIos` /
    `_onIosButtonPress` / `_GuardianAudioHandler`) — needs a real iOS audio
    session, CI-build-ios / device-only, NOT host-reachable.**
- **`main.dart` 76.9%→92.3%** (+6 tests in `main_bootstrap_test.dart`):
  `GuardianAngelaApp.build` theme (light/dark/system) + locale resolution; the
  runBootstrap step-4 deleted>0 + purge-failure-Sentry-capture branches; the
  step-6 TTS-failure Sentry callback; the recovery-without-ProviderScope path.
  Remaining 12 lines = `main()`'s real `runApp` entry (top-level, untestable
  cleanly) + a few recovery edge taps (start-fresh actual-delete + error,
  restore own-container fallback, restore-progress spinner) — C6b candidates.
- **PRODUCTION BUG FOUND + FIXED (`RealFlashService.stopFlash` hangs).**
  `stopFlash()` set `_loopDone = null` BEFORE `await done.future`; the loop's
  `finally` did `_loopDone?.complete()` on the now-null field → a no-op → the
  awaited completer NEVER completed → **`stopFlash()` never returned while a
  flash loop was active** (PROVEN red in real wall-clock: a 3s timeout fired;
  also under fakeAsync). FIX: each loop (`_sosLoop`/`_continuousLoop`) captures
  the completer into a local at entry and the `finally` completes THAT
  (`if (done != null && !done.isCompleted) done.complete()`), so a nulled field
  can't strand stopFlash. Host-proven by the race-fix tests (a safety app whose
  SOS flash can't be stopped on disarm is a real defect — caught only because
  C6 drove the REAL loop, not the sim).
- **Stale-comment cleanup (no-invented-deferrals):** removed the
  `// Native channel handler lands in Phase 7` headers + the "Phase 7 not yet
  landed" / "(Phase 7)" doc lines in `call_state_service.dart` +
  `hardware_button_service.dart` (the channels exist; C4 fixed
  `CallStateChannel.kt`), and the "(used by Phase 6 direct call)" note in
  `flash_service.dart`. (`main.dart:54` "Phase 5C bootstrap" is a factual
  historical note in a file C6 did NOT edit — left as-is.)

**KEY FINDINGS (C6) — new baseline + carry to C6b/C7:**
- **Coverage-of-logic 84.49% → 87.14%** (11576 / 13284 lines; +356 covered).
  **Floor ratcheted 84.0 → 86.5** (`tool/coverage/coverage_floor.txt`, ~0.6%
  jitter headroom; gate PROVEN OK at 86.5, RED at 99.0). Per-file C6 results
  recorded in the "DELIBERATELY NOT EXCLUDED" block of `coverage_excludes.txt`.
- **The EventChannel host-drive recipe (reusable for any channel-backed Real
  service):** `defaultBinaryMessenger.handlePlatformMessage(channelName,
  StandardMethodCodec().encodeSuccessEnvelope(event), (_){})` pushes one
  onData; `encodeErrorEnvelope(code:...)` → onError; a `null` raw message →
  onDone (`platform_channel.dart:699`). For a service whose `start()` gates the
  subscription on `Platform.isAndroid` (host = false), add a small
  `@visibleForTesting` method that calls the private `_startAndroid()` so the
  real subscription+parse runs on the host (used for hardware_button; matches
  the repo's existing `messaging_service` channel-test pattern). The
  `Real*Service` constructor-location rule (CI S-6) only greps
  `Simulation.*Service(`/`Fake.*Repository(` in `lib/` — constructing
  `Real*Service` in `test/` is NOT forbidden (the existing service tests already
  do negative name-checks).
- **`Geolocator` host seam:** channel `flutter.baseflow.com/geolocator`
  (`getCurrentPosition` returns a `{latitude,longitude,timestamp(ms),accuracy,
  …}` map for `Position.fromMap`; `checkPermission`/`requestPermission` return
  the `LocationPermission` enum INDEX as an int — 0 denied / 1 deniedForever /
  2 whileInUse / 3 always); the position stream is
  `EventChannel('flutter.baseflow.com/geolocator_updates')` driven via
  `setMockStreamHandler` + `MockStreamHandlerEventSink.success/error`.
- **`fakeAsync` + a mock MethodChannel works** — the mock reply resolves
  in-zone after `async.flushMicrotasks()`; a detached loop parked in a
  `Future.delayed` needs `async.elapse(...)` (not just flushMicrotasks) to
  resume. (Proven while debugging the flash loops.)
- **C6b — remaining NON-feature files NOT yet covered (the next coverage
  batch, all outside `lib/features/`):** `lib/router/app_router.dart` (111L,
  0% — GoRouter config; needs a router-build/redirect test, couples to feature
  screens so could pair with C7); `lib/services/notification_service.dart`
  (69L missing), `audio_service.dart` (56L), `recording_service.dart` (37L),
  `service_providers.dart` (35L), `messaging_service.dart` (19L),
  `session_start_validator.dart` (23L), `background_session_service.dart`
  (13L), `device_info_service.dart` (10L), `phone_service.dart` (5L),
  `home_widget_service.dart` (6L), `sentry_service.dart` (7L),
  `backup_service.dart` (4L); the data layer — `feedback_history_dao.dart`
  (24L, 0%) + `feedback_history_repository.dart` (4L, 0%) +
  `feedback_history_table.dart` (8L, 0%) (one coherent feedback-history test),
  the 0% Drift `tables/*.dart` (`session_modes`/`reminder_templates`/
  `session_logs`/`sms_retry_jobs`/`contacts` — column DSL, likely covered by
  instantiating the schema), `contacts_dao.dart` (5L),
  `sms_retry_jobs_dao.dart` (9L), `database.dart` (7L), `json_singleton_repository.dart`
  (6L), `contacts_repository.dart` (4L); domain — `chain_event.dart` (4L,
  lines 125-128), `permission_revocation.dart` (2L), `session_engine.dart`
  (9L), `session_log.dart` (1L), `seed_data.dart` (1L), `mode_draft_validator.dart`
  (1L), `event_services.dart` (1L), `event_strategy.dart` (1L),
  `route_names.dart` (1L); core widgets — `timing_slider.dart` (31L),
  `swipe_slider.dart` (7L), `pin_keypad.dart` (3L), `ringtone_picker.dart`
  (3L), `guardian_angela_logo.dart` (2L), `info_icon_button.dart` (1L),
  `deceptive_old_pin_dialog.dart` (2L) + the `lib/services/sim/*` partial gaps.
  (NOTE: `lib/features/` controllers + screens are **C7**, NOT C6b.)

---

## M5 (FINAL) — START HERE

### M5 DECISIONS (user, 2026-06-09)
- **Coverage target = push to ~99% of the LOGIC surface** with an EXCLUSION
  LIST (set in C5's coverage config): generated `lib/l10n/**`,
  `*.g.dart` / `*.freezed.dart`, the **seven host-uncoverable `Real*Service`
  native wrappers** (hardware_button / location / flash / call_state / contact /
  system_ui / wakelock), `main.dart`, and protocol-only abstract files.
- **iOS = CI-build-verified ONLY.** Mark iOS-specific spec-coverage rows
  `(CI build-ios)`; NEVER fake device-green for iOS.
- **Keep all 14 INT scenarios.** Rename the stale spec-07 contract-table rows to
  the real files (C8 — the table is aspirational, names files that don't exist).
- **Do NOT build a hosted-emulator CI job** — device-e2e stays tag-gated +
  documented (C4 runs it locally on the Pixel_9_Pro emulator standard).
- **Ringtone-audio + live-OS-notification = host+boot-proven** (don't fake
  audibility).

### M5 chunk plan
- **C1 — INT-001..004 + integration harness ✓ DONE.**
- **C2 — INT-005..010 ✓ DONE (this session)** (distress-panic / duress-no-op /
  real-call pause+resume / real-call-over-fakeCall / sim-leap / SMS-disarm).
- **C3 — INT-011..014 + WID-001/002 ✓ DONE (this session)** (wrongPIN→distress /
  cold-launch interrupted-prompt / smart-retention clock-advance / soft-delete
  restore+purge; onboarding full-flow + language-switch widget cohort).
- **C4 — device-e2e #11/#12 + stealth-icon hardening ✓ DONE (this session,
  `m5-e2e`)** — all EMULATOR-PROVEN on `emulator-5554`; found+fixed a real
  CallStateChannel production bug. See the **"M5 C4 — DONE"** section below.
- **C5 — coverage config + the exclusion list above.** NOTE the C5 exclusion
  list (above) lists `call_state` among the "host-uncoverable `Real*Service`
  native wrappers" — but C4 now makes `RealCallStateService`'s native path
  DEVICE-coverable AND `CallStateChannel.kt` is now bug-fixed; C5/C8 should note
  the native-channel device-e2e coverage (it stays host-EXCLUDED for the host
  coverage floor, but the device-e2e is a real proof, not a gap).
- **C6 — coverage: 5 zero-coverage safety services + main.dart ✓ DONE (this
  session, `m5-c6`)** — 84.49%→87.14%-of-logic, floor 84.0→86.5, found+fixed
  a real flash stopFlash-hang bug. **C6b** (the remaining NON-feature files —
  app_router, notification/audio/recording/service_providers, the data layer,
  domain + core-widget tails) carried in the C6 KEY FINDINGS above.
- **C7 — coverage: `lib/features/` controllers + screens — SPLIT a..g.**
  **C7a (session + fake_call) ✓ DONE** (89.46→90.86%, floor 90.2, bug #4) ·
  **C7b (modes) ✓ DONE** (→92.05%, floor 91.4, bug #5 clear-to-null) ·
  **C7c (editors + distress + de-flake) ✓ DONE** (→93.11%, floor 92.5) — all
  cohort-verified. NEXT: C7d (history/logs) → C7e (home + post-session) →
  C7f (nav/entry + contacts) → C7g (settings + misc); slices in resume block.
- **C8 — spec-coverage matrix + flip the Phase-9 assertions** (+ rename stale
  spec-07 contract-table rows to real files).
- **C9 — doc-sweep tail + CLAUDE.md tidy.**
- **C10 — final cohort + push.**

### M5 A5 — SMS-cancel-on-disarm (DONE this session, `m5-A5`, UNPUSHED)

**The verified gap (now closed):** a distress SMS is sent via a background
WorkManager job with up to 10 retries (minutes/hours on poor signal). Disarming
after the SMS step fired did NOT cancel that queued job → a false-alarm distress
SMS could reach the emergency contacts AFTER the user was safe. The native cancel
already existed + was device-tested (`SmsChannel.cancelWork` →
`WorkManager.cancelWorkById`; `RealMessagingService.cancelPending`
`messaging_service.dart:177`; both concrete `cancelPending` + the native
`cancelWork` host unit tests in `messaging_service_test.dart:497-514`). Only the
Dart plumbing was missing.

**The 3 plumbing links built (SERIAL — signature first, then propagate, then
controller):**
1. **Protocol widened.** Added `Future<void> cancelPending(List<MessageWorkId>
   workIds)` to `MessagingServiceProtocol`
   (`lib/services/protocols/messaging_service_protocol.dart:33`). Both concretes
   already implemented it → added `@override` (`messaging_service.dart:177`,
   `messaging_service_sim.dart:116`).
2. **`executeReal` returns the work-ids (CROSS-CUTTING).** Changed
   `EventStrategy.executeReal` `Future<void>` → `Future<List<MessageWorkId>>`
   (`event_strategy.dart:43`). **All 9 strategies updated:** the 7 non-SMS ones
   return `const []` (every short-circuit path too); `SmsContactStrategy`
   (`sms_contact_strategy.dart:107` — `Future.wait(sends).whereType<MessageWorkId>()`)
   AND `CallEmergencyStrategy` (`call_emergency_strategy.dart:40` + `_sendPreCallSms`
   — **second SMS source**, fires when `sendLocationSmsFirst`) return their real
   work-ids. Behavior unchanged except the return → all 448 strategy/dispatch
   tests stayed green (the `await stmt;` test call-sites are source-compatible).
3. **Controller accumulate + cancel.** New session-scoped `_smsWorkIds`
   (`session_controller.dart:~410`); `_dispatchStep` appends each step's returned
   ids (`:~1490`). `_cancelPendingSms()` (`:926`) passes the list to
   `messaging.cancelPending` (fire-and-forget) then clears it. Called from
   **`disarm()`** (`:915`, the "I'm safe" slider — cancels then re-arms to step 0)
   AND from the **safe-end branch of `_finaliseLog`** (`:1369`, gated on
   `_isSafeEnd(reason)` = `disarm`|`userQuit`). **NOT** cancelled on
   distress/escalation ends (`chainExhausted`/`hardwarePanic`/`duressPin`/
   `wrongPinExhausted`/`distressConfirmTimeout`) — the message must still go out.

**The cancel-proof test (`test/integration/simulation_disarm_session_test.dart`,
INT-010 rewritten + 2 net-new cases, RED-proven):** drives the REAL controller
with `FakeMessagingService(workIds: ['wm-sms-job-1'])` (the fake now records
`cancelPending` in `cancelledWorkIds` + returns a deterministic work-id).
Case 1: smsContact fires → `disarm()` → assert `cancelledWorkIds` contains the id
+ one `userDisarmed` + re-armed at step 0 + no escalation. Case 2: clean end via
`endSession(reason: disarm)` → id cancelled. Case 3 (NEGATIVE gating): a lone
exhausting smsContact (`chainExhausted`) → SMS fired but `cancelledWorkIds`
EMPTY. **RED-proven both points:** removing `_cancelPendingSms()` from `disarm()`
fails case 1; removing the safe-end branch from `_finaliseLog` fails case 2
(independent paths).

**Spec reconciled:** `05-services §A5` (now "BUILT" — documents the
`executeReal`-return → `_smsWorkIds` → `cancelPending` flow + the safe-end gating
+ that there is NO `SessionOrchestrator`/`cleanDisarm`/`registerSmsWorkId`);
`07-test-plan` INT-010 (rewritten to the real wiring + 3 cases + RED proof), the
coverage-matrix row ("BUILT"), and the stale INT-001 `cleanDisarm`-invoked-once
expected-outcome (→ the empty-list no-op note). The C8 "A5 unbuilt" list entry is
removed (see below).

**Gate (ALL GREEN):** `flutter analyze --fatal-infos` = **0** (whole project);
`flutter test --concurrency=6` = **4068 pass** (4066 + 2 net-new); `test/integration/`
= **35/35**, flake-free **5×** under `--concurrency=6` (no segfault — the
`closeIntegrationDb` drain is UNCHANGED + reused by the new cases); deferral-grep
= **0**; `git status --porcelain -- OLD/` empty; no stub markers in changed lib.
Host only (the native cancel is already device-tested) — no emulator.

**KEY FINDINGS (A5) — carry to C4/C8:**
- **TWO SMS sources, not one.** `CallEmergencyStrategy._sendPreCallSms` (when
  `sendLocationSmsFirst`) ALSO enqueues SMS via `sendMessage` and was discarding
  the work-ids — it now collects + returns them alongside `SmsContactStrategy`.
  Any future SMS-enqueuing path MUST return its ids through `executeReal`.
- **`_finaliseLog` is the single universal termination funnel** — called by both
  `controller.endSession()` (:1266) AND the engine-driven `sessionEnded` event
  handler (:1628, e.g. `chainExhausted`/distress self-end). Gating the cancel
  there on `_isSafeEnd` covers clean-end correctly while never touching
  distress/escalation ends. The double-call (endSession path fires the event
  THEN awaits `_finaliseLog`) is idempotent — `_smsWorkIds.isEmpty` /
  `_eventServices == null` guards make the 2nd call a no-op.
- **`disarm()` does NOT end the session** (it re-arms to step 0 and may re-send),
  so its cancel runs against the still-live `_eventServices.messaging` and clears
  `_smsWorkIds` so the re-armed step's fresh SMS is tracked from scratch.
- **The `executeReal` return-type change is source-compatible for every existing
  test** — all 200+ strategy-test call-sites are `await x.executeReal(...);`
  statements (none assign/inspect the return), so awaiting a `Future<List<…>>`
  needs zero test edits. Only `FakeMessagingService` needed the new
  `cancelPending` impl (protocol now requires it) + a `workIds` knob.
- **`lib/domain/orchestration/` already depends on the messaging protocol**
  (`event_services.dart` imports it) — adding `MessageWorkId` imports to the
  strategies follows the established layering (the protocol is the domain-facing
  contract), no new `lib/domain`→`lib/services` violation.

### M5 C1 — INT-001..004 + harness (DONE this session, `m5-int`, UNPUSHED)

**Created `test/integration/`** (did not exist). Three files:
- **`_session_harness.dart`** — the REUSABLE host harness C2/C3 import. Provides:
  `RecordingFakes` (bundle of the established recording fakes from
  `test/domain/orchestration/_test_fakes.dart`, re-exported), a
  `buildIntegrationContainer({db, fakes, settings, profile})` that overrides
  EVERY service provider with fakes + an in-memory DB + the real
  `SimulationSessionLogRecorder` (so the SessionLog marker path runs for real),
  and a `SessionDriver` that starts a real `SessionController` session under
  `fakeAsync`, collects the engine event log, and exposes
  `snapshot`/`events`/`currentStepIndex`/`isDistressChain`/`endReason`/`state`/
  `count(event)`/`stop(async)`.
- **`walk_mode_session_test.dart`** — INT-001 (Walk happy: hold→checkIn→re-arm at
  step 0, no SMS), INT-002 (Walk worst: hold→release→idle → graceExpired×3 +
  stepAdvancing×3 → `chainExhausted`; smsContact `sendMessage` + callEmergency
  `callEmergency('112')` recorded).
- **`date_mode_session_test.dart`** — INT-003 (Date happy: reminderFired ≥1 +
  template surfaced, 3× checkIn, chain parked at step 0, no SMS, clean `userQuit`
  end), INT-004 (Date worst: reminderFired×2 [initial+1 retry] + repeatMissed +
  stepAdvancing×3 → `chainExhausted`; SMS + callEmergency recorded).

Each test is tagged with its `INT-00N` id in the test NAME (grep-able for the C8
matrix). All four drive the REAL controller/engine end-to-end (no vacuous
assertions — they go red if the orchestration breaks).

**Gate:** `flutter analyze --fatal-infos` = **0**; `flutter test --concurrency=6`
= **4037 pass** (4033 + 4 net-new); integration dir **10/10** consecutive
(determinism proven after fixing the jitter flake — see KEY FINDINGS);
deferral-grep = **0**; `git status --porcelain -- OLD/` empty; no
`expect(true,true)`/`.skip` filler. Pure-Dart/`fakeAsync` → host only, no
emulator.

**KEY FINDINGS / orchestrator-API drift reconciled (C1):**
- **The spec-07 INT prose names DO NOT match the real API** (Hard Rule 6). Drove
  the real methods: `engine.state`→`engine.snapshot`; the orchestrator
  `cleanDisarm`/`registerSmsWorkId` DO NOT EXIST (the disarm path is
  `controller.disarm()`→`engine.disarm()`); spec messaging
  `sentMessages`/`sendToAll` → the real `MessagingServiceProtocol.sendMessage`
  (records in `FakeMessagingService.calls`); `FakePhoneService` records
  `call`/`callEmergency`; `EndReason` has NO `userTerminated` (→ `userQuit`).
- **INT-002 as literally written is a spec/code contradiction (REAL FINDING,
  reconciled — not vacuous):** it expects a `holdButton` step to "time out" when
  the user never holds, but the engine starts **no timer** for a `holdWait`
  phase (`_executeHoldButtonStep`, line 708) — spec **02:46** is explicit
  ("Engine waits for first `holdStart()`. Does NOT assume user is holding"). A
  never-touched hold step sits FOREVER and never exhausts. The faithful worst
  case drives hold→release→idle (the post-release sensitivity→duration→grace
  timers + `retryCount=0` advance the chain). Captured in the test header.
- **`repeatMissed` is disguisedReminder-ONLY** (engine `_onGraceExpired` only
  emits it when `step.type == disguisedReminder`). For Walk Mode the missed
  signal is `graceExpired`+`stepAdvancing` (INT-002 asserts those); INT-004
  (Date) asserts `repeatMissed`.
- **THE JITTER FLAKE (must-know for C2/C3):** `SessionController.startSession`
  builds its `SessionEngine` with the real `Random()` (it does NOT inject
  `FixedRandom`). Plain steps are deterministic via `randomize: false`, BUT
  `DisguisedReminderConfig.randomizeInterval` + `.randomizeTemplateOrder` both
  default to **TRUE** and `ChainStep.randomize` does NOT override them — so a
  disguisedReminder wait jitters ±20% (10s→8–12s) → a `fakeAsync` boundary flake
  (caught at ~50% under `--concurrency=6`). FIX: set BOTH config flags to
  `false`. Documented in the harness `_FixedRandom` contract doc-comment.
- **`SessionDriver` cannot capture the t=0 `sessionStarted`/`stepStarted(0)`**
  (they fire synchronously inside `engine.start()` during the same microtask
  drain the driver flushes before it can grab the engine + subscribe). Those are
  proven instead by the engine STATE right after start (`currentStepIndex==0` +
  phase); every later event IS captured (fires during `async.elapse`). Documented
  on `SessionDriver`.
- **Reusable harness location for C2/C3:**
  `test/integration/_session_harness.dart` (import it + add a new
  `<scenario>_test.dart`; the recording fakes are re-exported so one import
  suffices). **Next action = "M5 C3 — INT-011..014 + WID-001/002 (reuse the
  C1 harness)".**

### M5 C2 — INT-005..010 (DONE this session, `m5-int`, UNPUSHED)

**Three new files** under `test/integration/`, each scenario tagged with its
`INT-00N` id in the test NAME (grep-able for the C8 matrix), all driving the
REAL controller/engine end-to-end via the C1 `SessionDriver` + recording fakes
(every one fails RED on a wiring regression — red-proven for INT-005/006 [remove
the `confirmDistress` call → both fail] and INT-007/008 [remove the call-state
`ringing` event → both fail]):

- **`distress_session_test.dart`** — INT-005 (distress via panic: real
  `controller.confirmDistress()` → `engine.replaceWithDistressChain(chain:
  distressMode.chainSteps, triggerReason: hardwarePanic)`; `isDistressChain`
  true + `currentStepIndex==0` immediately; one `distressTriggered`; distress
  chain smsContact+callEmergency fire [`sendMessage` + `callEmergency('112')`
  recorded]; terminal `distressCompleted` → `sessionEnded(hardwarePanic)`),
  INT-006 (A4: a SECOND `confirmDistress(duressPin)` while distress is active is
  a NO-OP — engine guard `if (_isDistressChain) return`, line 519; still ONE
  `distressTriggered`, no re-arm, SMS count unchanged, session still ends with
  the FIRST trigger's `hardwarePanic` not `duressPin`).
- **`call_state_session_test.dart`** — INT-007 (real call pause/resume: inject a
  controllable `SimulationCallStateService`, `setState(CallState.ringing)` →
  controller `_onCallStateChanged` → `engine.pause(incomingCall)`; chain does
  NOT advance over a 60s pause; `setState(CallState.idle)` → `engine.resume()`;
  the saved `remaining` is EXACTLY 20s preserved across the pause; the chain
  advances only after the preserved timer elapses), INT-008 (real call over a
  fakeCall step: `holdButton → fakeCall` chain, real call during the fakeCall →
  `sessionPaused(incomingCall)` + fake-call cancelled [`audio.stop()` recorded +
  `fakeCallCancelNonce` bumped]; call-end → `sessionResumed` + auto-`userDisarmed`
  → step 0, `isHolding==false`, no SMS).
- **`simulation_disarm_session_test.dart`** — INT-009 (sim `leap()`: SIMULATION
  session, `controller.leap()` → `engine.leap()` collapses the 30s duration
  timer → transitions to `grace` phase with `remaining` reflecting the 10s grace,
  NOT a stale 30s; chain not advanced by the leap), INT-010 (the A5 gap — see
  the C8 reconciliation list: faithful disarm-after-queued-SMS behavior, NOT a
  cancel test).

**Harness extension (minimal):** `buildIntegrationContainer` gained an optional
`callState: SimulationCallStateService?` param so a scenario can inject its own
controllable instance and drive `setState(...)` (the sim service already exposes
`setState`/`isStarted`/`dispose`). When omitted, a fresh no-op instance is used
(unchanged for C1's files). Plus the C1 freebie comment fix at
`walk_mode_session_test.dart:193` (the `equals(3)` was always right; the comment
now explains the 3rd `stepAdvancing` is the terminal exhaustion advance).

**Gate:** analyzer `--fatal-infos` = **0** (whole project); full suite
`flutter test --concurrency=6` = **4043 pass** (4037 + 6 net-new);
`test/integration/` **10/10** (5× consecutive full-dir + 6× the new-files
stress, no jitter flake); deferral-grep = **0**; `git status --porcelain --
OLD/` empty; no `expect(true,true)`/`.skip` filler. Pure-Dart/`fakeAsync` → host
only, no emulator.

**KEY FINDINGS (C2) — carry to C3:**
- **The C1 harness API is exactly right for C2** — `SessionDriver` already
  accepted `simulate` + `distressMode` params; INT-005/009 needed nothing new
  except the one optional `callState` injection. C3 should reuse it the same
  way.
- **Real distress path = `controller.confirmDistress({reason})`** (NOT a bare
  `engine.replaceWithDistressChain`); it resolves `_distressMode` (supplied via
  `startSession`/`SessionDriver.start(distressMode:)`) and forwards
  `dist.chainSteps`. The distress chain self-ends via `_advanceToNext` →
  `endSession(reason: _distressTriggerReason)` which emits `distressCompleted`
  THEN `sessionEnded(<triggerReason>)`. `EndReason.duressPin` (NOT `duress`).
- **A4 no-op is enforced AT THE ENGINE** (`replaceWithDistressChain` line 519:
  `if (_isDistressChain) return`). The controller has no duress-PIN entry point
  that bypasses it — the duress PIN routes through the same replacement, so the
  engine guard is the single A4 source of truth. (Re-armed/duplicate distress is
  structurally impossible at the engine.)
- **Real-call path is fully wired in the controller** (`_onCallStateChanged`
  :1157 → `_onRealCallStarted`/`_onRealCallEnded`): active(`!=idle`) →
  `engine.pause(incomingCall)` + `_pausedByRealCall`; on a fakeCall step ALSO
  `audio.stop()` + `_disarmOnRealCallEnd` + `fakeCallCancelNonce++`; idle →
  `engine.resume()` then (if flagged) `engine.disarm()`. The `SimulationCallStateService`
  (`lib/services/sim/call_state_service_sim.dart`) `setState(CallState)` is the
  HOST seam (no native channel). Broadcast-stream delivery needs an
  `async.flushMicrotasks()` after each `setState`.
- **`engine.leap()` requires `_isSimulation`** (throws otherwise) → INT-009 MUST
  use `simulate: true`. In a sim session `SessionController._dispatchStep` is a
  Layer-1 no-op (`if (... services.isSimulation) return`, :1467) → the fakes
  record NOTHING in sim; assert engine STATE/phase only (which is all D2
  specifies). `leap()` cancels the phase timer and fires `_fireCurrentPhase()`
  SYNCHRONOUSLY (so duration→grace happens within the same call). `EngineRunning.remaining`
  is the value set at `_startPhaseTimer` (not live-recomputed) — so it reads the
  fresh phase's full duration, never a stale prior-phase value.
- **`EngineRunning.remaining` is only recomputed on `pause`** (`_computeRemaining`
  from wall-clock). Otherwise the snapshot carries the duration set when the
  phase timer started. So INT-007's "remaining ≈1s" is proven via the PRESERVED
  `EnginePaused.snapshot.remaining` (exactly 20s) + the timer firing after the
  matching elapse — not via a live remaining read.

### M5 C3 — INT-011..014 + WID-001/002 (DONE this session, `m5-int`, UNPUSHED)

**Six new files** under `test/integration/` (no `lib/` change — pure test
additions, no l10n touched). Each scenario tagged with its `INT-0NN` / `WID-00N`
id in the test NAME (grep-able for the C8 matrix). The four INT session ones
reuse the C1 `SessionDriver`/harness; INT-013/014 drive the REAL
`SessionLogRepository` directly; the two WID ones are widget tests against the
REAL screens/controllers. Net **+23** tests → suite **4066** (4043 + 23).

- **`wrong_pin_distress_session_test.dart`** — **INT-011** (A3, +2). Drives the
  REAL wired wrong-PIN path: `controller.notifyWrongPinAttempt()` ×(threshold−1)
  ticks the in-memory counter + emits `deceptiveOldPinShown` each time (no
  escalation below threshold); the threshold-th attempt + the wired
  `controller.confirmDistress(reason: EndReason.wrongPinExhausted)` swaps in the
  distress chain (`distressTriggered` ×1, distress smsContact+callEmergency fire
  [`sendMessage` + `callEmergency('112')`], terminal `distressCompleted` →
  `sessionEnded(wrongPinExhausted)`). 2nd test = spec-30d sim carve-out
  (faithful controller-level form — see C8 list). **RED-proven** logically: drop
  the `confirmDistress` and INT-011 fails (no distress).
- **`interrupted_prompt_session_test.dart`** — **INT-012** (Extra-13 / M4-C4 e2e,
  +5). Seeds an orphan `SessionLog` (endedAt==null) directly into the in-memory
  DB via `SessionLogRepository.upsert`, builds the REAL `SessionController`, and
  asserts `build()` orphan-detection surfaces `priorInterrupted` + `priorModeId`
  / `priorModeName` / `priorStartedAt`; that detection **hard-deletes** the
  orphan (fires once — 2nd cold launch sees nothing); a cleanly-finalised log
  (endedAt set) does NOT surface; newest-orphan-wins + ALL orphans cleared;
  `acknowledgeInterruptedPrompt()` clears the flags. This is the real M4-C4
  feature proven end-to-end (not rebuilt). (Duress-PIN carve-out
  `writeInterruptMarker:false` documented in the header — writes no marker, so
  nothing to assert there.)
- **`log_retention_test.dart`** — **INT-013** (B8, +5). Drives the REAL
  `SessionLogRepository.purgeExpiredLogs({retentionDays, now})` over a real
  in-memory DB with the clock injected as the `now` value (NO `package:clock` /
  `fake_async` needed — `now` is a plain param). Proves: stale NON-critical
  purged but stale CRITICAL kept indefinitely; in-window kept; reference time is
  `endedAt ?? startedAt` (old-start/recent-end kept by endedAt; orphan judged by
  startedAt); mixed-cohort delete count. Fixtures grounded in the REAL
  `SessionLogsDao.isCritical` predicate (asserted alongside).
- **`log_soft_delete_test.dart`** — **INT-014** (Extra-11, +6). Drives the REAL
  repo trash lifecycle: softDelete→trash (hidden from live, `deletedAt` set,
  getById still returns it) → restore→live (deletedAt cleared, survives a
  subsequent age purge) → re-trash → hard-purge. The default 7-day trash window
  purges a 10-day-old trash; **the trash purge IGNORES criticality** (a trashed
  CRITICAL log past the window is hard-deleted even with an infinite age window
  — the key Extra-11 invariant); `hardDeleteAllTrashed` ("Empty trash") removes
  every trashed row regardless of age, leaving live logs intact.
- **`onboarding_flow_widget_test.dart`** — **WID-001** (+2). Drives the REAL
  `OnboardingController` (NOT the existing canned `_FakeOnboardingController`)
  through the FULL welcome→profile→permissions→"Get started" flow, asserting the
  wired completion side-effects via in-memory recording repos that round-trip
  save→load: the typed profile draft is persisted (name+phone), `isFirstLaunch`
  flips true→false, nav leaves onboarding for home. Uses the established
  `_FakePermissionHandlerPlatform` seam (real `requestAllPermissions`
  `permission_handler` call → deterministic no-op). 2nd test: empty draft →
  null name/phone, flag still flips.
- **`language_switch_widget_test.dart`** — **WID-002** (decision 43, +3). Proves
  the real localization wiring: a `MaterialApp.locale` driven by a watched
  language-code provider (mirroring `main.dart:260`
  `locale: Locale(s.languageCode)`) re-resolves the REAL `AppLocalizations`
  delegate the instant the value flips — `homeTagline` flips en
  ("Your angel's got your back.") → de ("Dein Engel passt auf dich auf.") → en
  with no restart. An anchor-precondition test guards en≠de. A 3rd test drives
  the REAL `SettingsController.setLanguage('de')` → asserts it persists the code
  to the repo (the wiring behind the Settings language picker; the existing
  settings_screen test only asserts the fake is *called*).

**Gate (ALL GREEN):** whole-project `flutter analyze --fatal-infos` = **0**;
full suite `flutter test --concurrency=6` = **4066 pass** (4043 + 23 net-new);
`test/integration/` = **33/33** + **3× the 6 new files under `--concurrency=6`,
no flake** (DB/widget tests, no Random → no jitter trap; cross-test in-memory
DBs are isolated per `setUp`); no `expect(true,true)`/`.skip` filler;
deferral-grep = **0**; `git status --porcelain -- OLD/` empty. Host only
(fakeAsync/DB/widget) — **no emulator** (C4's job).

**KEY FINDINGS (C3) — carry to C4/C8:**
- **A3 terminal reason is `EndReason.wrongPinExhausted`** (NOT `wrongPinThreshold`
  / `duressPin`). The wired sequence (`session_screen.dart:1020-1027`,
  `launch_pin_screen.dart:167-170`, `end_session_overlay.dart:354-357`) is:
  `controller.notifyWrongPinAttempt()` (increments `_wrongPinAttempts`, calls
  `engine.notifyWrongPin(count)` → emits `deceptiveOldPinShown`, returns the
  post-increment count) → the **caller** compares `>= settings.wrongPinThreshold`
  (default 5) → `controller.confirmDistress(reason: wrongPinExhausted)`. The
  engine's `notifyWrongPin` ONLY emits the forensic `deceptiveOldPinShown`; it
  does NOT itself escalate — the threshold compare + `confirmDistress` live in
  the UI layer.
- **`SessionState` has NO `isSessionActive`** — that getter is on the
  `SessionController` notifier (`:1652`, `engine != null && !engine.isEnded`).
  `SessionState` carries `phase`/`priorInterrupted`/… For "no live session"
  assert `notifier.isSessionActive == false`.
- **`SessionLogRepository.purgeExpiredLogs` + `softDelete` take `now`/`now:` as
  plain params** — INT-013/014 need NO `package:clock`/`fake_async`; inject the
  reference time directly. Criticality = `SessionLogsDao.isCritical(log)`
  (public for tests): destructive step types `{smsContact, phoneCallContact,
  callEmergency, loudAlarm}` × fired eventTypes `{step_started, stepAdvancing,
  step_fired}`, OR ANY event with `deliveryStatus` in `{sent, queued}`. Build a
  critical fixture with `SessionLogEvent(eventType:'step_fired',
  stepType:'smsContact', deliveryStatus:'sent')`; a non-critical one with
  `eventType:'started', stepType:'holdButton'`.
- **The harness fakes can't prove a WRITE.** `FakeAppSettingsRepository`/
  `FakeUserProfileRepository` override `load()` to a FIXED value and ignore
  `save()`. WID-001 (and the WID-002 setLanguage test) needed small in-memory
  recording subclasses (`save` updates an in-memory field, `load`/`loadOrNull`
  return it) to assert what `completeOnboarding`/`setLanguage` persisted.
- **Riverpod-3 gotchas in test code:** `Override` is NOT exported by
  `flutter_riverpod/flutter_riverpod.dart` — import
  `package:flutter_riverpod/misc.dart show Override` (as the existing onboarding
  test does). `StateProvider` is legacy in Riverpod 3 and unused project-wide —
  use a tiny `Notifier`/`NotifierProvider` instead. A bare-`ProviderContainer`
  test that calls a notifier method doing `ref.invalidateSelf()` leaks a
  pending timer under `testWidgets`; mount the container via
  `UncontrolledProviderScope` in the tree + `pumpAndSettle` so the rebuild
  drains (or write it as a plain `test()`).
- **WID-001 vs the existing onboarding test:** the pre-existing
  `onboarding_screen_test.dart` is a render/navigation test on a canned
  `_FakeOnboardingController` (it overrides `completeOnboarding` to a no-op). The
  genuine gap WID-001 fills is driving the REAL controller so the persisted
  side-effects (profile + isFirstLaunch flip) are actually proven — not
  duplicate coverage.

### M5 C4 — device-e2e #11/#12 + stealth-icon hardening (DONE this session, `m5-e2e`, UNPUSHED)

All three items run on `emulator-5554` (Pixel_9_Pro/API36) via dedicated host
runners in **`tool/device_e2e/`** + on-device tests in **`integration_test/`**.
**HONEST device-vs-host-vs-CI accounting per item below.** New shared helper
`integration_test/_device_e2e_support.dart` (`emitMarker`, `pollUntil`,
`waitForPhonePermission`, `holdOnlyMode`, `buildDeviceE2eContainer`).

**#11 — incoming-call pause/resume — DEVICE-PROVEN (exit=0, re-run stable 2×).**
`integration_test/real_call_pause_test.dart` + `tool/device_e2e/run_real_call_pause.sh`.
Drives the FULL real telephony path: `adb emu gsm call <n>` → `TelephonyManager
CALL_STATE_RINGING` → `CallStateChannel.kt` "ringing" on the EventChannel →
`RealCallStateService` → `SessionController._onCallStateChanged` →
`engine.pause(incomingCall)`; the on-device test polls the REAL `SessionState`
and ASSERTS `isPaused==true && pauseReason==PauseReason.incomingCall` (marker
`PAUSE-OBSERVED reason=PauseReason.incomingCall`); then `adb emu gsm cancel` →
`idle` → `engine.resume()` → `isPaused==false` (`RESUME-OBSERVED`), session still
live. **THIS SURFACED + FIXED A REAL PRODUCTION BUG** (see KEY FINDINGS) —
`android/.../CallStateChannel.kt` `onListen` now calls `startTelephonyListener()`.

**#12 — background-throttle — DEVICE-PROVEN (exit=0, both proofs).**
`integration_test/background_throttle_test.dart` +
`tool/device_e2e/run_background_throttle.sh`. (A) CLAMP: a SIM session at 200×;
real OS `adb shell input keyevent KEYCODE_HOME` DID deliver
`AppLifecycleState.paused` to the controller observer →
`engine.setBackgroundClamp(true)` → `effectiveSpeedMultiplier` capped 200→**60**;
`monkey` foreground → released → 200 (marker `A-BACKGROUNDED osClamp=true` +
`A-FOREGROUNDED viaRealOs=true` — the STRONGEST path, real OS → observer →
engine, NOT the direct-drive fallback). (B) LIVENESS: a REAL session stays live
across the real HOME→foreground round-trip (`B-SURVIVED`, engine not ended).
Observed via the `@visibleForTesting SessionController.engine` getter.

**Stealth per-preset hardening — DEVICE-PROVEN (FAILS=0, re-run stable; closes
the M3-C4 deferral).** `integration_test/stealth_icon_switch_test.dart` (rewritten
to a single comprehensive per-preset test) +
`tool/device_e2e/run_stealth_per_preset.sh`. The in-process test walks ALL 10
presets via the REAL `RealSystemUiService.setStealthIcon` (each apply asserts
no-throw on-device); the host TIGHT-POLLS `cmd package resolve-activity -a MAIN
-c LAUNCHER` throughout and verifies the launcher resolver matches each preset's
alias AFTER its switch — **6–9 of 10 distinct preset aliases caught per run**
(`music/calendar/fitness/weather/news/photos/notes/clock/podcast/none`→
`.MainActivityAlias`), gate = ≥2 distinct (NOT just the final — the M3-C4 gap) +
final = `.StealthAlias_music`. The 1–4 "not sampled" per run are the coarse adb
poll missing a transient, logged INFO (not failures).

**Honest device-vs-host-vs-CI:**
- **#11 / #12 / stealth: EMULATOR-PROVEN** on `emulator-5554` (the exact runs +
  markers above; re-run stable).
- **iOS** (CallKit/CXCallObserver `CallStatePlugin.swift`; iOS `setStealthIcon`
  no-ops) = **CI `build-ios` ONLY**, NOT device-provable on this Linux box.
- The background-clamp WIRING + the FG-service START are ALSO host-tested
  (`session_controller_clamp_test.dart`, `background_clamp_test.dart`); #12-B does
  NOT claim FG-service OS-kill-resistance (the harness SIMs
  `flutter_background_service` — it hangs headless), only that the lifecycle
  round-trip doesn't END the session. The clamp speed-EFFECT is sim-only by
  design (no-op for real wall-clock sessions).

**Coordination pattern (the reusable C4 finding):** the on-device test emits
`GA-E2E <MARKER>` via `debugPrint` (routes to the HOST `flutter test` STDOUT,
captured to the runner's log file — `dart:developer log` does NOT reach logcat in
this embedder, verified); the host greps that log and fires the matching `adb`
command at each marker boundary; the on-device test polls REAL state with
wall-clock `pollUntil` and ASSERTS there (a wrong host action → `pollUntil`
times out → red test; no vacuous pass). Runners wrap `flutter test` in `timeout`
and redirect to a file (never pipe a long run through `tail`).

**Gate (ALL GREEN):** whole-project `flutter analyze --fatal-infos` = **0**; host
`flutter test test/ --concurrency=6` = **4068 pass** (UNCHANGED — device tests
live in `integration_test/`, excluded from the host run); `test/integration/` =
**35/35** flake-free (no f22ea41 regression); the 3 device runs above ran green
on `emulator-5554` (exit=0 / FAILS=0); deferral-grep = **0**; `git
status --porcelain -- OLD/` empty. Native `CallStateChannel.kt` has the one-line
fix + an explanatory comment; no Kotlin host-test framework exists (native is
device-tested per project convention).

**KEY FINDINGS (C4) — carry to C5/C8:**
- **PRODUCTION BUG FOUND + FIXED (`CallStateChannel.kt`).** A `MethodChannel`
  and an `EventChannel` registered under the SAME channel name
  (`com.guardianangela.app/call_state`, MainActivity:45-48) share ONE
  `BinaryMessenger` message-handler slot — the EventChannel's StreamHandler
  (registered 2nd) SHADOWS the MethodChannel handler. So
  `RealCallStateService.start()`'s `invokeMethod("startListening")` ALWAYS
  resolved to `MissingPluginException` (swallowed by the service's try/catch),
  and `onListen` only set `eventSink` WITHOUT starting the listener → **the
  telephony listener never registered → a real incoming call would NOT pause the
  session in production.** FIX: `onListen` now calls `startTelephonyListener()`
  (the EventChannel subscription is the real lifecycle signal;
  `RealCallStateService` subscribes via `receiveBroadcastStream()`). `onCancel`
  already stopped it symmetrically. Host tests (INT-007/008) use the
  `SimulationCallStateService.setState` seam, which bypasses the native channel —
  so ONLY the device-e2e could catch this. (Re-verify on iOS in CI: the iOS
  `CallStatePlugin.swift` path is independent.)
- **`flutter test integration_test/<file>` does NOT register MainActivity's
  MANUAL platform channels for the test isolate UNTIL the full app launches.** A
  bare integration test that builds its own container hits
  `MissingPluginException` on `call_state`/`system_ui`/`stealth_icon`. FIX:
  call `await app.main()` first (channels are process-global on the default
  binary messenger; the test's own container then reaches them). This is why #11
  and the stealth test both call `app.main()`.
- **`dart:developer log` does NOT reach `adb logcat` under `flutter test
  integration_test`; `debugPrint` DOES reach the host test stdout.** Host↔device
  coordination must poll the captured `flutter test` STDOUT log, not logcat.
  `debugPrint` is THROTTLED for bursts — use `debugPrintSynchronously` when
  emitting many markers rapidly (the stealth walk needed this).
- **`flutter test`'s reinstall WIPES pre-granted runtime permissions.** A grant
  BEFORE `flutter test` is lost. The on-device test must GATE on the permission
  (`waitForPhonePermission` polls `Permission.phone.status`, emits
  `AWAITING-PHONE-GRANT`) while the host `pm grant`s in a loop. Note
  `Permission.phone` (permission_handler) checks the whole phone GROUP
  (READ_PHONE_STATE + READ_PHONE_NUMBERS + CALL_PHONE) — grant ALL three or the
  status never flips, even though the native channel only needs READ_PHONE_STATE.
- **The `emu gsm` listener fires only on a STATE TRANSITION (idle→ringing).** A
  leftover ringing call from an aborted prior run means NO transition when the
  next listener registers → no pause. The runner WAITS for `mCallState=0` before
  the run. `adb -s emulator-5554 emu gsm call/cancel <num>` is confirmed working
  on this emulator (`emu gsm status` = OK; drives `mCallState` 0↔1).
- **A REAL session HANGS on a headless `integration_test` embedder unless
  `flutter_background_service` + `flutter_local_notifications` are SIM'd** (FG
  `configure()`/`startService()` never completes; `setSmallIcon` NPEs on the bare
  engine). `buildDeviceE2eContainer` SIMs those + location/contacts/phone/
  messaging, keeps `call_state` + the engine/controller REAL.
- **Disabling the RUNNING activity's OWN launcher alias detaches the Flutter
  engine ~3.5s later** (the platform reacts to the component-disable), which
  stalls a long in-process preset walk — the PRE-EXISTING all-presets stealth
  test has the same behaviour (it never reaches "All tests passed" cleanly; the
  M3-C4 "proof" was the adb resolve-activity observation, not a green test). FIX:
  a MINIMAL single-frame-pump walk completes all 10 switches before the detach;
  the HOST runner is the authoritative arbiter (observed launcher resolvers),
  NOT the in-process test's exit code (which the runner kills).
- **Emulator DISK fills up** (180MB debug APK × repeated reinstalls; `/data` hit
  94%). `adb -s emulator-5554 shell pm trim-caches 5G` + `pm compile -a --reset`
  reclaims space; uninstalling GA frees the APK. Trim before each device run if
  tight (a failed reinstall SIGKILLs the test → exit 137 mid-run).

To re-run the C4 device proofs: `bash tool/device_e2e/run_real_call_pause.sh`,
`run_background_throttle.sh`, `run_stealth_per_preset.sh` (each wraps `timeout`;
needs `emulator-5554` up + `ANDROID_HOME`/PATH exported per the Emulator standard
below; `pm trim-caches 5G` first if `/data` is tight).

### M5 C5 — coverage-of-logic gate + ratchet floor (DONE this session, `m5-c5`, UNPUSHED)

Replaced the inert Phase-0 `COVERAGE_FLOOR=0` stub in `ci.yml` with an HONEST
coverage-of-LOGIC gate. **NO `lib/` or test change** — config/scripts only
(`ci.yml` + new `tool/coverage/`), so the host suite stays **4068** and analyze
stays **0**.

**The pipeline (identical local + CI):** `flutter test --coverage` →
`tool/coverage/filter_coverage.sh` (lcov `--remove` over the exclusion globs →
`coverage/lcov.filtered.info`) → `tool/coverage/check_floor.sh` (pure-awk
coverage-of-logic %, fails below `tool/coverage/coverage_floor.txt`). CI uses
system `lcov` (apt); locally the script falls back to a vendored perl `lcov` via
`LCOV_BIN` — **proven to give the identical 84.49%** on both paths.
`coverage/` is gitignored, so only the scripts are committed.

**THE EXCLUSION LIST (`tool/coverage/coverage_excludes.txt`, 23 files / 13425
lines removed) — each defended:**
- `lib/l10n/*` — **14 generated `AppLocalizations*.dart`, 10862 lines.** flutter
  gen-l10n output (emitted into the arb-dir; `l10n.yaml` has no `output-dir`).
  Pure generated message getters. Mirrors `analysis_options.yaml` exclude.
- `*.g.dart` — **7 Drift adapters, 2534 lines** (`database.g.dart` alone = 2499).
  build_runner output; CI hard-fails on a stale diff. Mirrors analyzer exclude.
- `*.freezed.dart` — **0 files today** (future-proof glob; `--ignore-errors
  unused` tolerates the no-match). Mirrors analyzer exclude.
- `lib/services/system_ui_service.dart` — **16 lines, thin passthrough.** Both
  methods are `if(!Platform.isAndroid){return;} try{invokeMethod}catch{log}`; on
  the Linux host only the iOS-no-op return is reachable, the rest is Android
  channel plumbing. Device-proven (`stealth_icon_switch_test.dart`).
- `lib/services/wakelock_service.dart` — **13 lines, thin passthrough.**
  `if(_isEnabled)return; await WakelockPlus.enable()/disable()` idempotency
  wrapper around a static plugin that throws off-device.

**THE BASELINE (measured 2026-06-09, 4068 host tests):** RAW = 53.33%
(14241/26705, **50.2% of all instrumented lines are generated**) → **coverage-of-
logic = 84.49% (11220/13280, 204 files)**. **FLOOR set to 84.0**
(`coverage_floor.txt`) = baseline − ~0.5% jitter headroom; the everyday gate
PASSES today. **Gate PROVEN:** floor 84.0 → OK exit 0; floor 99.0 → FAIL exit 1;
exact boundary 84.49 → OK / 84.50 → FAIL. Target stays ~99%-of-logic (owner
mandate + D6); the floor is a ratchet C6/C7 bump as tests land, C10 sets 99%.

**HONESTY DEVIATION FROM THE M5-DECISION DRAFT (orchestrator must note) — the
draft listed all 7 `Real*Service` wrappers + `main.dart` for exclusion; C5
excludes only 2 of the 7 and NOT `main.dart`, because the orchestrator's C5
brief OVERRIDES: "a file with host-testable logic must NOT be excluded — it must
be tested (flag it for C6/C7)." Line-by-line verified, these 6 hold real
host-testable logic and are LEFT IN the denominator as explicit C6 targets (the
exact files C6 attacks first):**
- `hardware_button_service.dart` — **112 lines, 0%.** Pure-Dart repeat-press
  sliding-window + long-press duration + param clamping (the doc-comment itself
  says "implemented in pure Dart so it is testable without platform").
- `location_service.dart` — **71 lines, 0%.** Fresh-vs-cached fallback decision,
  stale-note ISO formatting, bounded-history eviction at 1000.
- `flash_service.dart` — **59 lines, 0%.** SOS/continuous timing loops +
  graceful-degradation catch + Completer race-fix (fakeAsync + faked TorchLight).
- `call_state_service.dart` — **32 lines, 0%.** `_parseCallState` string→enum
  switch + `_onNativeEvent` dispatch (also device-proven in C4; host-testable via
  the `TestDefaultBinaryMessenger` mock-channel seam the file's doc names).
- `contact_service.dart` — **17 lines, 0%.** Repo-backed cache (start/byId/all/
  stop); **NO native channel at all** — 100% host-testable (injected
  `ContactsRepository`). Calling it a "native wrapper" was wrong.
- `main.dart` — **156 lines, 76.9% ALREADY covered** (`seedFirstLaunchSettings`,
  `runBootstrap`, `JsonRecoveryApp` recovery flow all have tests). Blanket-
  excluding it would DROP 120 covered lines AND hide 36 uncovered branching lines.

**Protocol-only abstracts = NO exclusion needed (M5-draft no-op):** 23 of 25
`lib/services/protocols/*.dart` contribute ZERO instrumented lines (abstract
declarations have no executable lines → already absent from the denominator);
the 2 that appear (`location_service_protocol.dart`,
`device_info_service_protocol.dart`) hold concrete, well-covered data classes
and must stay.

**KEY FINDINGS (C5) — carry to C6/C7:**
- **C6 highest-yield targets (0%-but-host-testable, in descending line count):**
  `hardware_button` (112) > `location` (71) > `flash` (59) > `call_state` (32) >
  `contact` (17). These 291 lines are the single biggest cheap win toward 99% —
  all host-testable; none need a device. The 4 existing `*_service_test.dart`
  for hardware_button/location/call_state/system_ui only NAME-CHECK the Real
  class in a negative assertion; they exercise the Sim, so the Real classes are
  0%. C6 should add Real-class host tests (mock the geolocator/EventChannel/
  TorchLight/`TestDefaultBinaryMessenger`).
- **The gate denominator = whatever the host suite LOADS.** lcov only emits
  records for loaded files; 204 logic files appear today. As C6/C7 add tests
  that import currently-unloaded files, the denominator can GROW — `check_floor.sh`
  recomputes from the live filtered report each run, so a freshly-loaded 0% file
  can briefly DIP the %. Bump the floor only after the covering tests land
  (the ratchet rule), and add the new file's tests in the same commit.
- **To bump the floor:** edit the single number in
  `tool/coverage/coverage_floor.txt` to the new measured baseline (run
  `flutter test --coverage` → `bash tool/coverage/filter_coverage.sh` → the
  `Coverage of LOGIC: NN.NN%` line printed by `check_floor.sh`). Keep ~0.5%
  headroom under the measurement.
- **To add/adjust an exclusion:** add a glob line to `coverage_excludes.txt`
  with a one-sentence defense (HONESTY CONTRACT: generated or host-unreachable
  ONLY). The filter reads it directly — no script edit needed.
- **lcov is REQUIRED.** The CI `test` job installs it (apt). Locally, clone
  `linux-test-project/lcov` (v2.0) and `export LCOV_BIN=/path/to/bin/lcov`; the
  scripts run via perl with no root. `--rc branch_coverage=0` + `--ignore-errors
  unused` keep lcov 2.x quiet on the no-match `*.freezed.dart` glob.

**[C5's + C6's next-actions — now SUPERSEDED: C6 AND C6b are DONE.]** C6 covered
the five 0%-but-host-testable service files + main.dart (floor 84.0→86.5); C6b
covered the rest of the NON-feature surface (services + data layer + domain/core
tails; floor 86.5→88.8). See the **C6b KEY FINDINGS block at the top** (new
89.46% baseline, per-file results, the `_launchUrl`/`_dial` bug fix, and the
DEVICE-ONLY / CODEGEN-ONLY census). **The CURRENT next-action is below.**

**Next action = "M5 C7 — coverage push: `lib/features/` controllers + screens
+ `app_router` (split as needed)"** — the feature tail toward ~99%-of-logic;
bump `tool/coverage/coverage_floor.txt` as each batch lands (re-measure via
`flutter test --coverage` → `LCOV_BIN=/home/jonas/lcov/bin/lcov bash
tool/coverage/filter_coverage.sh` → the `Coverage of LOGIC: NN.NN%` line from
`check_floor.sh`). C7's surface = **1153 missed across 8074 feature+router
logic lines (85.7% covered today)**, almost entirely host-reachable (only ~5
`Platform.is*`-gated lines in all of `lib/features/`) → widget + controller
tests reach it. `app_router.dart` (111 lines, 0%) needs a router-build/redirect
test and couples to feature screens (pair it with the screens or do it first).
The NON-feature surface is now DONE (C6+C6b); the only remaining non-feature
gaps are the device-only/codegen-only census lines above. The device-e2e
standard + the C8 reconciliation list (below) stay intact.

### C8 spec-07 reconciliation list (CARRY — grows each INT chunk)

The spec-07 §Integration Test Scenarios prose has drifted from the real API in
several places. Each INT scenario reconciles to the FAITHFUL real behavior and
documents it in its test header; C8 must fold these into the spec-07 rewrite
(and rename the aspirational contract-table rows to the real files). Items so
far (C1 + C2):

- **INT-002** — spec expects a never-touched `holdButton` to "time out"; the
  engine starts NO timer for `holdWait` (spec 02:46 — waits for the first
  `holdStart()`, does not assume holding), so a never-touched hold sits forever.
  Reconciled to hold→release→miss→advance→exhaust.
- **INT-002/004** — spec says `repeatMissed` "per step"; the engine emits it
  ONLY for `disguisedReminder` steps (`_onGraceExpired`). Walk-Mode worst case
  asserts `graceExpired`+`stepAdvancing`; Date-Mode asserts `repeatMissed`.
- **INT-003** — terminal reason `userTerminated` does NOT exist in `EndReason`;
  the deliberate user-quit value is `userQuit`.
- **INT-005** — `hw.simulatePanic()` + a hand-written engine subscriber → real
  wired path is `controller.confirmDistress()` → `replaceWithDistressChain(chain,
  triggerReason)`; `engine.chainSteps`-is-distress → assert `isDistressChain` +
  `currentStepIndex==0`; `sendToAll` → `sendMessage`.
- **INT-006** — "the orchestrator must debounce re-entry" → the A4 no-op is
  enforced AT THE ENGINE (`replaceWithDistressChain` early-return on
  `_isDistressChain`); there is no separate orchestrator debounce layer.
- **INT-007/008** — `FakeIncomingCallService` → use the injected
  `SimulationCallStateService.setState(...)` driving the controller's wired
  `_onCallStateChanged`; `FixedRandom` → `randomize:false` at source;
  `sentMessages` → `calls`.
- **INT-010 (A5) — NOW BUILT (`m5-A5`, this session). Reconciliation COMPLETE,
  no longer a C8 open item.** A5 SMS-cancel-on-disarm is wired + proven; the spec
  (`05-services §A5`, `07-test-plan` INT-010 + the coverage-matrix row + the
  INT-001 `cleanDisarm` note) is reconciled to the BUILT wiring with the real
  method names. The old gap (interface lacked `cancelPending`, `executeReal`
  returned `Future<void>` discarding the work-id, `disarm()` was bare
  `engine.disarm()`) is closed. See the **"M5 A5 — DONE"** section above for the
  3 plumbing links + the RED-proven test. C8 has nothing left to do for A5 beyond
  what is already in the spec; the spec no longer names any
  `SessionOrchestrator`/`cleanDisarm`/`registerSmsWorkId` API (only notes they do
  not exist).

Items added by C3 (INT-011..014 + WID):

- **INT-011 (A3)** — spec scenarios 70/71 describe the behaviour ("enter wrong
  PIN 5×" → "distress chain fired") without naming an API; the spec-07 table row
  just says "wrongPinThreshold (A3)". The wired path has NO single
  "wrongPinThreshold" entry point: it's `controller.notifyWrongPinAttempt()`
  (counter + `deceptiveOldPinShown`, returns count) → the UI compares
  `>= settings.wrongPinThreshold` → `controller.confirmDistress(reason:
  EndReason.wrongPinExhausted)`. The terminal `EndReason` is **`wrongPinExhausted`**
  (the spec's implied `wrongPinThreshold` enum case does NOT exist).
- **INT-011 (spec-30d sim carve-out)** — spec 30d ("simulation wrong PIN does
  NOT fire distress") is enforced in the **UI** (`session_screen.dart:990`: a sim
  session uses a local `_simWrongAttempts`, shows the educational SnackBar, and
  never calls the controller). The CONTROLLER itself has no `isSimulation` guard
  inside `notifyWrongPinAttempt`/`confirmDistress`. The faithful controller-level
  invariant tested: in a sim session the wrong-PIN counter alone never escalates
  — distress only ever fires on an explicit `confirmDistress` (which the UI never
  issues in sim). The UI gate proper is covered by the session_screen widget
  tests.
- **INT-012 (Extra-13)** — already reconciled in C5 from the stale
  `active_session_marker.json` to the real in-progress `SessionLog` row
  (endedAt==null). INT-012 drives THAT real marker via `SessionLogRepository`
  (seed orphan → real `SessionController.build()` detects+deletes → assert
  `priorInterrupted` + the prior fields → `acknowledgeInterruptedPrompt` clears).
  No separate JSON file exists. Duress-PIN cold-start distress uses
  `writeInterruptMarker:false` (no marker → never prompts; security carve-out).
  **No NEW divergence** beyond what C5 already noted — the test simply realises
  the C5-reconciled wording. C8 should confirm the spec-07 INT-012 row + spec 04
  §Session-Interrupted Prompt both read "orphan SessionLog row", which they now
  do.
- **INT-013/014 (B8 / Extra-11)** — spec-07 table rows say "clock-advance test"
  and "restore + hard-purge transitions" with no API. The real API needs NO
  clock library: `SessionLogRepository.purgeExpiredLogs({retentionDays, now})`
  and `softDelete(id, {now})` take the reference time as a plain param.
  Criticality is the public `SessionLogsDao.isCritical` predicate. No spec
  contradiction — just an API the table didn't name. C8 should rename the
  contract-table rows to the real files (`log_retention_test.dart` /
  `log_soft_delete_test.dart`).
- **WID-001 / WID-002** — spec-07 table rows ("Onboarding full flow" → "Phase 6
  widget cohort"; "Language switch instant rebuild (43)" → "Phase 6 widget
  cohort") name no files. They now map to
  `test/integration/onboarding_flow_widget_test.dart` /
  `language_switch_widget_test.dart`. WID-002's instant-rebuild is the real
  `MaterialApp.locale = Locale(languageCode)` + `AppLocalizations.delegate`
  mechanism (`main.dart:260`); there is no separate "live locale provider" to
  export — the test mirrors the production wiring with a watched code provider.
  C8 should add these two file names to the renamed contract table.

Items added by C4 (device-e2e #11/#12/stealth — from the qa-expert cohort; C8
must fold these into the spec-07 rewrite):

- **#12 has NO spec-07 row.** Add a device-e2e row for the background-clamp
  lifecycle (G-013), with an HONEST sim-only scope: the on-device proof
  (`integration_test/background_throttle_test.dart`, tag `device-e2e`) HARD-
  asserts a REAL OS background engages the clamp on a real engine + a real
  `paused→resumed` round-trip is observed; the clamp's SPEED EFFECT (200×→60×)
  is sim-only (no-op for real wall-clock sessions) and its ARITHMETIC is covered
  host-side (`test/domain/engine/background_clamp_test.dart`,
  `test/features/session/session_controller_clamp_test.dart`). Do NOT write a
  spec-07 row implying an OS-delivered real-speed clamp.
- **INT-007 should SPLIT host vs device.** The host scenario (preserved-remaining
  pause/resume via the injected `SimulationCallStateService.setState`, `fakeAsync`)
  lives at `test/integration/call_state_session_test.dart`; the real-telephony
  device proof (adb-gsm → native `CallStateChannel` → engine pause/resume) lives
  at `integration_test/real_call_pause_test.dart` (tag `device-e2e`). The spec-07
  INT-007 row currently conflates them — C8 should name both files with their
  distinct scopes.
- **The stealth launcher-alias swap has NO spec-07 row.** TC-51/52/53 cover
  stealth UI hiding only (progress-bar/missed-indicator/notification-disguise —
  spec-07:265-267, 1027-1029), NOT the per-preset launcher-alias swap. Add a
  device-e2e row for `integration_test/stealth_icon_switch_test.dart` (tag
  `device-e2e`; `RealSystemUiService.setStealthIcon` per-preset alias swap
  observed via the host `cmd package resolve-activity` poll).
- **Confirm iOS rows for #11 / #12 / stealth are "(CI build-ios)" ONLY** — never
  faked device-green. iOS call-state is CXCallObserver (`CallStatePlugin.swift`,
  audio-active only), iOS `setStealthIcon` no-ops, and the lifecycle clamp's iOS
  path is build-verified, not driven on this Linux box. Per the M5 decision, iOS
  spec-coverage rows are CI-build-verified only.

Item added by C5 (coverage gate):

- **spec-07 §Target Coverage table is stale vs the C5 gate.** It says "Overall
  ≥85% via `coverage` package / Whole codebase" and "engine ≥95% / models ≥90%
  / repos ≥85%". The real gate (C5) is **coverage-of-LOGIC** (whole-codebase
  minus generated + 2 thin passthroughs) with a committed ratchet floor
  (`tool/coverage/coverage_floor.txt`, 84.0 today → ~99% target). C8/C10 should
  reconcile the spec-07 table to: (a) the coverage-of-logic definition + the
  exclusion list source (`tool/coverage/coverage_excludes.txt`), (b) the ratchet
  floor mechanism (the two `tool/coverage/*.sh`), (c) the ~99%-of-logic final
  target (owner mandate + D6), superseding the per-layer % rows and the codecov
  upload snippet (CI uses the floor gate, not codecov).

Items added by C6b (coverage push — for C8/C9):

- **C9 candidate — exclude the codegen-only Drift table DSLs.** The column
  getters in `lib/data/db/tables/*.dart` (~71 lines, currently 0% and IN the
  denominator) call Drift DSL methods (`text()`/`integer()`/…) that THROW
  `"This method should not be called at runtime"` — they are compile-time-only
  build_runner inputs, reachable by NO test (host or device), structurally
  identical to `*.g.dart`. C6b LEFT them in the denominator (per the brief's
  "don't add new excludes" rule); a `lib/data/db/tables/*.dart` glob in
  `coverage_excludes.txt` is a defensible HONESTY-CONTRACT-compliant exclusion
  (generated-equivalent) that would lift the denominator by ~71 and raise the
  measured %. Orchestrator decision — flag for C8/C9, not done unilaterally.
- **The `_launchUrl`/`_dial` bug fix is BEHAVIOUR-NEUTRAL for the spec** (the
  documented contract — log + return false on a failed launch — was always the
  intent; the bug was that the async rejection escaped the catch). No spec
  change needed; C8 may note in `05-services` that messaging/phone launch
  failures degrade to `false` (now actually enforced). No new divergence.
CHUNKS DONE + MILESTONE-COHORT-VERIFIED (PASS, both opus) + owner emergency-map FINAL sign-off (DE→112, ET=911/CI=111 accepted with VERIFY flags), GATE-GREEN, READY TO PUSH — C1 (#9 biometric) + C2 (#10 R-8 emergency-number map +
`phone_validators` + locale seeding) + C3 (#16 notification re-ask +
Active-Triggers-Summary + shared `permission_utils.dart`) + C4 (#8
Session-Interrupted prompt) + C5 (Tier-F F1/F2 descope + REMOVE
`SCHEDULE_EXACT_ALARM` + spec/doc reconciliation) + C6 (Tier-F F3: user-supplied
fake-call ringtone + bundled-default fallback) + C8 (Tier-F F5: post-session
feedback prompt) — all BUILT + COHORT-VERIFIED + COMMITTED. **C7 (Tier-F F4:
`requireLaunchAuth` / `launchAuthBiometric`): owner DECIDED 2026-06-09 = DELETE
both redundant fields. DONE THIS SESSION (`m4-tierF-#F4`) — both fields removed
from `AppSettings` (8 model sites) + the 2 `clearPin` passthrough lines + 3 test
assertions + spec (03 field-defs + the superseded note → removal note; 08 Q18) +
the F4 entry in the remediation tracker; GATE-GREEN, COMMITTED, UNPUSHED. The
App-PIN gate (`appPinHash` + `appPinBiometricEnabled`) is the SOLE launch-auth,
UNCHANGED — no behavior lost.** With F4 deleted, M4 has NO open build items.
NEXT = **M4 milestone cohort (architect-reviewer spec-vs-code + qa-expert
spec-vs-tests, both opus, whole M4 stack) → owner emergency-map review (DE=110,
ET=911, CI=111) → push the M4 stack.**

> **OWNER FINAL pre-push emergency-map review (carry to the M4 push).** The C2
> R-8 map (`lib/domain/models/emergency_numbers.dart`, 109 countries) still
> awaits the owner's FINAL pre-push spot-confirm of the reviewed adjustments —
> **DE=110, ET=911, CI=111** (the orchestrator must surface the C2 "CHANGES
> FROM THE REVIEWED DRAFT" summary before pushing M4). The count is now
> guarded by an EXACT `== 109` test (C5), so a silent map edit fails CI.

---

## M4 C7 (Tier-F F4) — REDUNDANT → owner DECIDED DELETE → DONE (`m4-tierF-#F4`)

**Task:** wire `requireLaunchAuth` / `launchAuthBiometric` (`AppSettings`) per
spec — but FIRST determine whether they are DISTINCT from the existing App-PIN
launch gate or REDUNDANT. **Finding (prior session): both are REDUNDANT
(spec-confirmed dead fields).** The owner DECIDED 2026-06-09 to **DELETE both**;
that deletion is DONE this session — see "DELETION DONE" below. The evidence
that drove the decision is retained here for the record.

**STEP-1 evidence (decisive — the spec itself supersedes them):**
- **`docs/spec/03-data-models.md:813`** (verbatim): "`requireLaunchAuth` +
  `launchAuthBiometric`: **superseded (2026-06).** The launch gate is driven by
  `appPinHash != null` (trigger) + `appPinBiometricEnabled` (biometric), not by
  a separate toggle … These two fields are **retained on the model (default off
  / on) but currently unused; candidate for removal in a dedicated
  schema-cleanup pass.**"
- **`docs/spec/06-settings.md` §App PIN (153-161) + §Session End Note (171)** —
  the launch-gate effect, its trigger, and its biometric toggle are ALL spec'd
  on `appPinHash` / `appPinBiometricEnabled`. Neither F4 field is named as a
  control anywhere in 06; the only other refs are `08-decisions:1060` (Q18, a
  bare model-field inventory) and `docs/rewrite/ga-wiring-remediation.md:100`
  ("dead fields — redundant w/ App-PIN gate").
- **Runtime: ZERO consumer.** Grep of `lib/` + `test/` for both names →
  the model boilerplate ONLY (`app_settings.dart` ctor/fromJson/copyWith/toJson/
  ==/hashCode) + a pure passthrough in `settings_security_controller.dart:108-109`
  (`clearPin` direct-construct copies `s.requireLaunchAuth`/`s.launchAuthBiometric`
  forward UNCHANGED — never read for a decision) + persistence-round-trip tests.
  The launch gate is `appPinHash != null` end-to-end: `main.dart:120`
  `lockForLaunch(appPinSet: settings.appPinHash != null)` → `launch_gate_controller.dart`
  → `app_router.dart:87-91` redirect → `launch_pin_screen.dart:86` biometric
  branch gated on `appPinBiometricEnabled`.

**Per-field overlap:**
- **`requireLaunchAuth`** ≡ "an App PIN is set". The gate already shows iff
  `appPinHash != null`. A separate "require auth on launch" master toggle would
  be meaningless without a credential, and the credential (`appPinHash`) IS the
  toggle. No distinct behavior in the spec.
- **`launchAuthBiometric`** ≡ `appPinBiometricEnabled` (which ALREADY drives
  biometric-first at the gate, wired M4 C1). A 1:1 duplicate. (Note their
  defaults even disagree — `launchAuthBiometric` defaults **true**,
  `appPinBiometricEnabled` defaults **false** — so honoring `launchAuthBiometric`
  would silently flip the coercion-safe default to biometric-on, a
  security regression; another reason not to wire it.)

**Why REDUNDANT (the basis for the DELETE decision):** building Settings UI + a
consumer would produce dead-equivalent code that duplicates the App-PIN gate —
exactly what the brief said NOT to do. So instead of wiring, the owner chose to
delete the two dead fields. **Alternative the owner did NOT take:** re-spec
`requireLaunchAuth` as a *re-lock-on-resume* master (the current gate is
cold-start-ONLY — a "lock every time the app returns to foreground" toggle WOULD
be net-new behavior). That would have been a NEW feature; the owner chose the
clean deletion instead.

**DELETION DONE (this session, `m4-tierF-#F4`):**
- **Persistence model confirmed = JSON blob, no migration.**
  `AppSettingsRepository` wraps `JsonSingletonRepository<AppSettings>`
  (`toJson`/`fromJson`, on-disk file — "delete removes the stored file"). NOT a
  Drift table → no column migration. A previously-saved blob with the two extra
  keys simply has them IGNORED on load (the `fromJson` reads are gone); new
  writes omit them. Pre-alpha nuke-and-reseed = nothing to migrate.
- **Removed from `AppSettings`** (`lib/domain/models/app_settings.dart`) — all 8
  sites: ctor params (was :30-31) + the two field+doc declarations (was :161-166)
  + `fromJson` reads (was :87-88) + `copyWith` params (was :226-227) + `copyWith`
  body (was :256-257) + `toJson` writes (was :288-289) + `==` (was :321-322) +
  `hashCode` (was :350-351).
- **Dropped the 2 passthrough lines** in `settings_security_controller.dart`
  `clearPin` (was :108-109).
- **Tests** (deletions, tests follow code): removed the dedicated
  `requireLaunchAuth defaults … launchAuthBiometric defaults` test +
  `test/domain/models/app_settings_test.dart` round-trip ctor args (was :286-287)
  + `test/data/repositories/app_settings_repository_test.dart` ctor arg (was :72).
- **Spec:** `03-data-models.md` — removed the two model-sketch field lines (was
  :777-778) + rewrote the ":813 superseded/candidate-for-removal" bullet into a
  REMOVAL note (the App-PIN gate is the sole launch-auth; the fields were removed
  2026-06). `08-decisions-consolidated.md` Q18 (:1060) — dropped both from the
  field inventory + added the removal note. `docs/rewrite/ga-wiring-remediation.md`
  — F4 tracker item (:100) → ✅ DELETED, and the §6 open-question (:187) → RESOLVED.
- **Gate:** analyzer `--fatal-infos` = 0; full suite `flutter test
  --concurrency=6` = all green (baseline 4034; the suite drops by the deleted
  assertions — exact count in the commit); `grep -rn
  "requireLaunchAuth\|launchAuthBiometric" lib/ test/` = **0** (docs retain only
  removal-notes); deferral-grep = 0; `git status --porcelain -- OLD/` empty.
  Pure-Dart model + tests + spec, NO native → no emulator.
- **App-PIN gate UNTOUCHED** (`appPinHash`, `appPinBiometricEnabled`,
  `launch_pin_screen.dart`) — remains the sole launch-auth; no behavior changed
  anywhere.

---

## What's done THIS session (M4 C8 — UNPUSHED, `m4-tierF-#F5`)

**Tier-F F5 — post-session feedback prompt.** Spec marks it `[Optional]`; the
owner chose KEEP+BUILD.

**STEP-1 DETERMINE (was it the F4 void-trap? NO — coherent local destination).**
The app has no server, so the question was "where does the feedback GO?" The
NORMATIVE doc `04-screens-navigation.md:2338` answers it decisively: feedback is
saved to a **local `feedback_history` Drift table** (verbatim: *"offline-first;
no remote backend in v3. The history is exportable via Settings → Backup."*).
That whole pipeline ALREADY EXISTS and works: `feedback_history` table +
`FeedbackEntry` model + `FeedbackHistoryDao` + `FeedbackHistoryRepository` +
`FeedbackFormScreen` (which persists locally via
`feedbackHistoryRepositoryProvider` before the mailto). So F5 is NOT
purposeless — it has a real, server-free destination. (NOTE a spec conflict:
`06-settings.md:285` says the form opens a *GitHub Issue / mailto*; doc 04 is
NORMATIVE and wins — the local Drift table is the destination. The existing form
does BOTH: local write + mailto.) **The only gap was the spec mockup's
`[Send Feedback]/[Skip]` prompt on the Chain Exhausted screen — unbuilt.**
Judgment: **BUILD** (a sensible local destination exists → exactly the
lean-toward-build case).

**Built (all proven by host/widget tests driving the REAL path):**
1. **`FeedbackPromptRepository`** (`lib/features/feedback_form/feedback_prompt_repository.dart`,
   NEW) — SharedPreferences-backed counter of **clean REAL-session
   completions** (`completedCount` / `recordCompletedSession` /
   `shouldShowPrompt`), gate = `promptThreshold = 3` (spec 04:1250 "after 3
   successful sessions"). No-throw everywhere (a prefs failure → 0 → no prompt,
   never a spurious prompt or crash). Mirrors `HomeChecklistRepository` (same
   injectable-loader / mock-prefs pattern). Provider
   `feedbackPromptRepositoryProvider` (plain `Provider`, SharedPreferences —
   no DB) added to `service_providers.dart` + a row in `docs/wiring-map.md`
   (the wiring-map coverage test requires every provider to be registered —
   that was the lone first-run full-suite failure, now fixed).
2. **Counter hook + gating in `_confirmedEnd`** (`session_screen.dart` :221) —
   after the deliberate End-Session swipe+(PIN) clean end, **for a REAL,
   non-stealth session only**: `recordCompletedSession()` then
   `shouldShowPrompt()`; the result is passed as a `feedback=true` query param
   to `/session/completed`. Simulations NEVER count (practice mode); stealth
   NEVER counts/prompts (spec 04:1247 — stealth completion is silent). The
   stealth flag is resolved BEFORE the `await` so a post-await rebuild can't
   flip it.
3. **The prompt UI** (`session_completed_screen.dart`) — new
   `showFeedbackPrompt` field (wired from the route param in `app_router.dart`)
   gates a `_FeedbackPrompt` private **StatefulWidget**: a dismissible card
   ("How was your experience?" + **[Skip]** [hides locally] + **[Send
   feedback]** → `pushNamed(settingsFeedback)` → the existing local-persisting
   form). Additive — never replaces Return-Home / View-Log; the screen itself
   stays a `StatelessWidget`.

**Trigger correctness (NOT shown mid-emergency — verified):** `/session/completed`
is reached by ONLY ONE call site (`session_screen.dart:231` in `_confirmedEnd`,
the deliberate End-Session flow). Distress/escalation NEVER routes there — a
distress trigger fires the distress chain and the session CONTINUES; the
grace-period "I'm Safe" slider calls `engine.disarm()` which RESETS the chain to
step 0 (does NOT end the session). So the prompt can only appear after a calm,
user-chosen clean end. Proven by tests for stealth/simulation suppression.

**Tests (net +17 → suite 4034, baseline 4017):** +8
`feedback_prompt_repository_test.dart` (default 0 / increment-returns-new /
below-threshold-false / flips-true-AT-threshold / stays-true-beyond /
pre-seeded-honoured / **throwing-loader degrades to no-prompt, never throws**);
+5 `session_completed_screen_test.dart` feedback group (hidden by default; shown
when flag set; **Return-Home/View-Log remain alongside**; **[Skip] dismisses
without leaving the screen**; **[Send feedback] routes to the form**); +4
`session_screen_test.dart` REAL-path group driving the actual
`SessionController._confirmedEnd` swipe → REAL `FeedbackPromptRepository` → REAL
`SessionCompletedScreen` reading `feedback=` (clean real end AT threshold →
counter 2→3 + prompt SHOWS; below threshold → counts 0→1 + NO prompt; **SIMULATION
→ no count, no prompt**; **STEALTH → no count, no prompt**).

**l10n:** 3 NEW keys in `app_en.arb` (+`@meta`) — `sessionCompletedFeedbackPrompt`
("How was your experience?") / `…FeedbackSend` ("Send feedback") / `…FeedbackSkip`
("Skip") — + all 13 translation ARBs (additions-only via the proven JSON-load →
add → dump(indent=2, ensure_ascii=False) script; "Send feedback" reuses each
locale's existing `settingsFeedbackRow`, "Skip" reuses `onboardingSkip` for term
consistency). `gen-l10n` 0 untranslated; generated `.dart` strictly
additions-only (**+146, 0 deletions** ×14); parity 14/14.

**Gate (ALL GREEN):** analyzer `--fatal-infos` = **0**; full suite
`flutter test --concurrency=6` = **4034 pass** (4017 + 17 net-new);
deferral-grep (`grep -rnE "(Phase 8|Phase 9|Phase 10|Phase 11)" lib/features/`)
= **0**; `git status --porcelain -- OLD/` empty; wiring-map coverage GREEN (new
provider registered). **Pure Flutter — NO native path touched, so no emulator
run needed.**

**KEY FINDINGS (C8):**
- **F5 is NOT the F4 void-trap.** The NORMATIVE doc 04:2338 already settled the
  no-server question — feedback persists to the local `feedback_history` Drift
  table (exportable via Backup) — and the ENTIRE pipeline (table/model/dao/repo/
  form) was already built and wiring the form's local write. The only missing
  piece was the completed-screen *prompt*. (Doc 06:285's "GitHub Issue/mailto"
  is superseded by the NORMATIVE doc 04; the form does both.)
- **`/session/completed` has exactly ONE caller** (`_confirmedEnd`, the
  deliberate End-Session flow). The grace-period disarm slider calls
  `engine.disarm()` → RESET to step 0 (session CONTINUES, no nav); distress
  fires the distress chain (no nav). So the completed screen — and therefore
  the feedback prompt — is structurally unreachable mid-emergency. This made
  the "not shown during a real emergency aftermath" requirement free.
- **The wiring-map coverage test (`test/wiring/wiring_map_coverage_test.dart`)
  is a hard gate on every NEW `*Provider` in `service_providers.dart`** — it
  parses the file + `docs/wiring-map.md` and fails if a provider lacks a row.
  This was the sole first-run full-suite failure; ALWAYS add a wiring-map row
  when adding a provider.
- A simulation completion DOES reach `/session/completed` (with
  `simulation=true`); only the SEPARATE `/session/simulation-summary` is the
  sim-specific screen. So the prompt had to be gated on `!isSimulation` too, not
  just `!stealth`.

---

## What's done THIS session (M4 C6 — UNPUSHED, `m4-tierF-#F3`)

**Tier-F F3 — user-supplied fake-call ringtone (+ bundled-default fallback).**
The owner reframed the original spec (5 bundled per-`CallStyle` ringtone assets
— a trademark/licensing risk) to "let the user supply their OWN ringtone audio".

**GAP verified first (confirmed):** `playRingtone` was hard-wired to the bundled
default — `FakeCallStrategy.executeReal` called `playRingtone(null)`; there was
NO user-supplied-ringtone field anywhere (`grep customRingtone|ringtonePath|
file_picker|FilePicker lib/ test/` = 0). NOTE: `RealAudioService.playRingtone`
ALREADY routed a file path → `setFilePath` vs an `assets/` path → `setAsset` (so
the file-playback seam half-existed); the genuine gaps were (1) no config field,
(2) no picker, (3) no copy-to-app-storage, (4) NO missing-file fallback (a
deleted/corrupt custom file would have broken the ring).

**DESIGN CHOICE (documented):** **a single user-supplied custom ringtone per
fakeCall config** (NOT per-`CallStyle`). Rationale: the owner's intent is "allow
different ringtones, added by the user" — one user-chosen ringtone per fakeCall
step delivers exactly that; `CallStyle` is a purely *visual* call-sheet
appearance (Android/iOS/WhatsApp look), orthogonal to *which audio rings* —
coupling audio to the visual style would mean N picker fields + N stored files
for zero user benefit. Mirrors the existing single-nullable-path
`voiceRecordingPath` / `callerPhotoPath` pattern already in `FakeCallConfig`.

**DEP DECISION — `file_selector`, NOT `file_picker` (deviation from brief, flagged
to orchestrator).** The brief said `flutter pub add file_picker`. Per the
dependency policy I ran `flutter pub outdated` first, then tried `file_picker`:
the LATEST is `11.0.2`, but it resolves ONLY to the **2022-era `3.0.4`** here —
every version ≥5.3.4 conflicts with our existing direct deps `share_plus
^13.1.0` / `device_info_plus ^13.1.0` via a transitive `win32` constraint
(`file_picker ≥8.3.3` needs `win32 ^5.9.0`; `share_plus ≥13.1.0` needs
`win32 ^6.0.1`). A 5-majors-stale picker is exactly what the policy warns
against. **`file_selector` (Flutter-team / flutter.dev verified) resolves at the
current `1.1.0` with "No dependencies would change"** — it is ALREADY a
transitive dep (`file_selector_android 0.5.2+6` is compiled into our build) and
delivers the identical capability (`openFile({acceptedTypeGroups})` →
`XFile?`). I made the call to use `file_selector`, documented it here + in the
report. **If the orchestrator/owner insists on the literal `file_picker`, the
only resolvable version is `3.0.4` (stale) unless `share_plus`/`device_info_plus`
are downgraded — surface this trade-off.**

**Built (all proven by host tests):**
1. **`FakeCallConfig.customRingtonePath`** (`lib/domain/configs/step_config.dart`)
   — nullable `String?`, `if (x != null)` toJson (omit-when-null, like the
   sibling paths), in copyWith/`==`/`hashCode`. `copyWith` keeps `x ?? this.x`
   (CAN'T null — KEY FINDING); clearing back to the default is a direct
   construction (the editor's `_withCustomRingtone(null)` helper, mirroring
   `_SmsContactForm._withTemplate`).
2. **`RingtonePicker`** (`lib/core/utils/ringtone_picker.dart`, NEW) — opens the
   native audio picker (`file_selector.openFile`, `XTypeGroup(extensions:
   kRingtoneExtensions = mp3/m4a/aac/wav/ogg/flac)`), **copies the picked bytes
   into `<app-documents>/ringtones/<uuid>.<ext>`** (a picked URI is transient;
   the copy is durable + survives the source being moved/deleted), returns the
   stored path (or null on cancel). Injectable seams `opener` /
   `docsDirProvider` / `uuidGenerator` (defaults assigned in-body) → host-testable
   without platform channels.
3. **Picker UI** — `_RingtonePickerField` in
   `lib/features/modes/widgets/event_specific_config.dart` (`_FakeCallForm`):
   shows "Default ring" / "Custom: {fileName}", a "Choose ringtone…" button →
   `RingtonePicker.pickAndStoreRingtone()` → `onChanged(copyWith(customRingtonePath:
   stored))`, and a "Use default" clear (shown only when a custom path is set) →
   direct-construct to null. `EventSpecificConfig` gained an optional
   `ringtonePicker` injection (production → a default `RingtonePicker()`).
4. **Playback** — `FakeCallStrategy.executeReal` now passes
   `config.customRingtonePath` to `playRingtone` (was hard `null`).
   `RealAudioService.playRingtone` refactored to `_loadRingtoneSource`: null →
   bundled default; `assets/…` → that asset; a file path → **`File(path)
   .existsSync()` guard, then a try/catch around `setFilePath`** — a MISSING or
   UNREADABLE custom file degrades to `_loadDefaultRingtone()`
   (`assets/audio/ringtone_default.wav`). A broken custom file can NEVER break
   the fake-call disguise.

**The chain, file:line:** picker
(`ringtone_picker.dart:74 pickAndStoreRingtone` → copy to
`<docs>/ringtones/<uuid>.<ext>`) → config field
(`step_config.dart` `FakeCallConfig.customRingtonePath`, toJson/fromJson) → UI
(`event_specific_config.dart` `_RingtonePickerField`) → strategy
(`fake_call_strategy.dart:58 playRingtone(config.customRingtonePath)`) → playback
+ fallback (`audio_service.dart` `_loadRingtoneSource` / `_loadDefaultRingtone`).

**Tests (net +27 → suite 4017, baseline 3990):** +12 `fake_call_config_test.dart`
(default-null, toJson omit/include, round-trip-with-value [the picked-path →
draft → DB proof], copyWith-replace, **copyWith CANNOT clear**, direct-construct
clears, inequality); strategy `fake_call_strategy_test.dart` group-4 rewritten +
extended (no-custom→null/default; **custom path → playRingtone receives it**;
ringtone is the customRingtonePath NOT the voiceRecordingPath); +5
`audio_service_test.dart` Tier-F group via the `_MockAudioPlayer` seam
(null→default asset; assets/→that asset; **existing file→setFilePath**;
**MISSING file→default**; **undecodable file [setFilePath throws]→default, no
throw**); +8 `ringtone_picker_test.dart` (cancel→null; copy-to-`<uuid>.<ext>` +
real bytes; **stored copy survives source deletion**; ext preserved / .mp3
default; subdir created; audio type-group filtered; distinct UUIDs); +5
`event_specific_config_test.dart` fakeCall picker group (Default-ring shown;
filename shown; **tap Choose → emits stored path**; cancel → no emit; **Use
default → clears to null, other fields preserved**).

**l10n:** 5 NEW keys in `app_en.arb` (+`@meta`) — `eventDefaultsFakeCallRingtone`
/ `…RingtoneDefault` / `…RingtoneCustom` (`{fileName}` placeholder) /
`…RingtoneChoose` / `…RingtoneUseDefault` — + all 13 translation ARBs
(additions-only via the C4 JSON-load→add→dump(indent=2, ensure_ascii=False)
script; `{fileName}` preserved verbatim in every locale). `gen-l10n` 0
untranslated; generated `.dart` strictly additions-only (**271 insertions, 0
deletions** ×14); parity 14/14.

**Gate (ALL GREEN):** analyzer `--fatal-infos` = **0**; full suite
`flutter test --concurrency=6` = **4017 pass** (3990 + 27 net-new); **emulator
boot-smoke PASS** on `emulator-5554` (debug APK built 31.9s + installed + "app
boots to a MaterialApp shell" — the new `file_selector` dep LINKS; confirmed
`FileSelectorAndroidPlugin` in the generated plugin registrant); deferral-grep
(`grep -rnE "(Phase 8|Phase 9|Phase 10|Phase 11)" lib/features/`) = **0**;
`git status --porcelain -- OLD/` empty; `flutter pub outdated` run + the
`file_selector`-vs-`file_picker` decision documented above.

**KEY FINDINGS (C6):**
- **`file_picker` is unusable-current here (pinned to 2022's `3.0.4`)** — the
  `win32` transitive conflict with `share_plus`/`device_info_plus ^13.x` blocks
  every `file_picker ≥5.3.4`. `file_selector` (already a transitive dep, current
  `1.1.0`, Flutter-team) is the conflict-free replacement; `openFile(
  acceptedTypeGroups: [XTypeGroup(extensions: …)])` → `XFile?` (`.path`/`.name`/
  `.readAsBytes()`). **A future direct-dep `win32` bump or a `share_plus`/
  `device_info_plus` realignment would unblock `file_picker` if ever required.**
- **The file-playback seam half-existed** — `RealAudioService.playRingtone`
  already branched `assets/` vs file path; the missing piece was the
  existence/decode guard, which belongs at the audio boundary (the strategy
  stays pure — it just forwards the config path). The fallback lives in ONE
  place (`_loadRingtoneSource`), so both the missing-file and the
  undecodable-file cases degrade identically.
- **`file_selector` re-exports `XFile`/`XTypeGroup`** (no `cross_file` import
  needed; importing `cross_file` directly trips `--fatal-infos`
  `depend_on_referenced_packages`). `XFile(path)` is the host-test constructor
  for a fake pick.

---

## What's done THIS session (M4 C5 — UNPUSHED, `m4-tierF`)

**Low-risk cleanup chunk: Tier-F F1/F2 descope + the `SCHEDULE_EXACT_ALARM`
removal + a spec/doc reconciliation pass. All six items verified precisely
against the code/native side first.**

- **A. F1 descope (spec note).** `docs/spec/05-services.md` §System Volume
  Override — added a reconciliation note: the media-stream override is DESCOPED
  for GA because the loud alarm already plays on `STREAM_ALARM` (audible in
  silent/vibrate, governed by alarm volume), so forcing the *media* stream to
  max is redundant. Nothing was built for F1; this is a spec-only note.
- **B. F2 descope + permission REMOVED.** Removed `SCHEDULE_EXACT_ALARM` from
  `android/app/src/main/AndroidManifest.xml` (was line 63-64) — replaced with a
  descope-rationale comment. Added matching reconciliation notes to
  `docs/spec/10-platform-matrix.md`: the permission-list block (the line is
  deleted + a note) AND the Background-Execution table (the *Alarm Manager
  Watchdog* row → DESCOPED/DESCOPED; *App Kill Recovery* row → NO/NO launch-only;
  *Background Timer* reworded to "kept alive by the foreground service, no
  AlarmManager"). Rationale captured: a watchdog can only NOTIFY (not escalate)
  and is defeated by the force-stop it targets; FG service + the #8
  interrupted-prompt cover the realistic cases; app-death = session gone.
- **C. C4 spec reconciliation (the contradiction the C4 cohort flagged).**
  `docs/spec/01-chain-engine.md` §Extra-13 ("No resume after force-close",
  ≈657-665) REWRITTEN: the marker is the in-progress **`SessionLog` row** (no
  `endedAt`), written at `startSession`, deleted at clean end; detection in
  `SessionController.build` deletes orphans so it fires once; the stale
  "separate `active_session_marker.json`" + the FALSE "No `SessionLog` entry is
  written for the killed session" are gone (mirrors the note already at
  04:962-988). Added the **Duress-PIN carve-out** note there
  (`writeInterruptMarker: false` for the App-lock cold-start distress — exempt
  from interrupted-prompt detection BY DESIGN, security, not a bug).
  `docs/spec/07-test-plan.md` INT-012 reworded: "seed `active_session_marker.json`"
  → "seed an in-progress (orphan) `SessionLog` row (no `endedAt`)".
- **D. C3 spec-ordering note.** `docs/spec/04-screens-navigation.md` on-tap
  Start flow — added a one-line note that the notification re-ask runs BEFORE
  session creation (block-on-deny gate), reconciling the literal
  "step 3 after Create WalkSession" numbering.
- **E. `service_providers.dart` Phase-7 doc-sweep (verify-then-reword).** All
  **9** stale "Phase 7" strings reworded after verifying each against
  `MainActivity.kt` / `AppDelegate.swift` / the manifest:
  - **REGISTERED in `MainActivity.kt`** → reworded to say so: HardwareButton
    (`hardware_button` EventChannel), CallState (`call_state` Method+Event;
    iOS `CallStatePlugin.swift` in `AppDelegate`), DeviceInfo (`DeviceInfoChannel.kt`),
    SMS/Messaging (`SmsChannel.kt`+`SmsWorker.kt`), QuickExit (`quick_exit`
    handler → `finishAndRemoveTask()`; the `SystemNavigator.pop` is now framed
    as a defensive on-error fallback, NOT a missing-handler placeholder).
  - **Plugin self-registered (no custom channel)** → reworded: BackgroundSession
    (`flutter_background_service`; `BackgroundService` in the manifest;
    start/stop wired by `SessionController` M3 C3), HomeWidget (`home_widget` +
    `GuardianAngelaAppWidget.kt` RemoteViews receiver in the manifest).
  - **Genuinely NOT a native channel** → reworded to the accurate status (no
    invented Phase X): PermissionAudit — the comment referenced a
    `DeviceStateChannel` that **does not exist**; mid-session revocation is
    Dart-side polling via `permission_handler`. NOTE: `MainActivity.kt`'s own
    header still says "all 7 custom platform channels" (accurate: SMS,
    call_state, hardware_button, system_ui, stealth_icon, device_info,
    quick_exit) — left as-is (correct).
- **F. Emergency-map count tightened.** `test/domain/models/emergency_numbers_test.dart`
  — the `length >= 100` floor → exact `== 109` (confirmed 109 entries via regex
  count first); catches silent truncation / duplicate-key collapse.

**Gate (ALL GREEN):** analyzer `--fatal-infos` = **0**; full suite
`flutter test --concurrency=6` = **3990 pass** (unchanged — F tightened an
existing assertion, no count change); **emulator boot-smoke PASS** on
`emulator-5554` (debug APK builds 24-33s + installs + "app boots to a
MaterialApp shell"); **`SCHEDULE_EXACT_ALARM` confirmed REMOVED** from the built
APK (`aapt2 dump permissions build/app/outputs/flutter-apk/app-debug.apk` — the
permission is absent; `USE_EXACT_ALARM` also absent; no transitive dep re-added
it); deferral-grep (`grep -rnE "(Phase 8|Phase 9|Phase 10|Phase 11)"
lib/features/`) = **0** AND no new "Phase X" in `service_providers.dart`; `git
status --porcelain -- OLD/` empty. 8 files changed (1 manifest + 5 spec + 1
service-providers + 1 test).

**KEY FINDINGS (C5):**
- **The CLAUDE.md native-files list is slightly ahead of reality.** It names
  `PhoneChannel.kt` and `DeviceStateChannel.kt`, but NEITHER exists in
  `android/app/src/main/kotlin/com/guardianangela/app/`. Phone calls go via
  `url_launcher` (Dart-only `tel:`, no native channel); the SIM-number channel
  is `DeviceInfoChannel.kt` (= `com.guardianangela.app/device_info`). The
  PermissionAudit provider's "DeviceStateChannel will push events" comment was
  therefore describing a channel that was never built — reworded to the real
  Dart-side polling mechanism.
- **`aapt2 dump permissions <apk>` is the authoritative APK-permission check**
  (`~/Android/Sdk/build-tools/36.1.0/aapt2`). Grepping the AGP *merged*
  manifest is misleading here because the merger preserves XML comments — my
  descope-rationale comment text contains the string "SCHEDULE_EXACT_ALARM", so
  a naive grep "hits". The APK dump is unambiguous (the permission is gone).
- **`MainActivity.kt` registers exactly 7 custom channels** (SMS, call_state,
  hardware_button, system_ui, stealth_icon, device_info, quick_exit);
  BackgroundSession + HomeWidget are plugin-self-registered (manifest entries,
  generated plugin registrant), NOT MainActivity channels — the doc-sweep had
  to distinguish these two registration styles rather than blanket-claim
  "registered in MainActivity.kt".

---

## What's done THIS session (M4 C4 — UNPUSHED, `m4-#8`)

**GAP verified first (premise was PARTIALLY STALE — detection + an
informational widget ALREADY existed; the task was genuinely incomplete):**
`SessionController.build` (`session_controller.dart` ≈ :445-474) ALREADY
detected an orphan `SessionLog` (`endedAt == null`), deleted all orphans
(fires once), and seeded `priorInterrupted`/`priorModeName`/`priorStartedAt`;
the marker write (≈ :598-611) ALREADY stored `modeId`+`modeName`+`startedAt`;
an `_InterruptedPrompt` widget ALREADY rendered the 5 `sessionInterrupted*`
keys with an Acknowledge button (so the keys were NOT orphaned — the brief was
wrong on that). **The REAL gaps:** (1) the prompt only rendered inside
`SessionScreen` (`/session`), which the cold launch NEVER reaches (`/` → home)
— so **nothing surfaced it at cold launch**; (2) **no [Start same mode]** (no
key, no button, no controller path); (3) the detector captured `modeName` but
**not `modeId`** (needed to restart); (4) the started-line showed a **raw
`toLocal().toString()` timestamp**, not a relative phrase; (5) **deleted-mode**
for the restart was unhandled; (6) the spec still described a separate
`active_session_marker.json`.

**Built (all proven by host/widget tests):**

1. **`SessionState.priorModeId`** (`session_controller.dart`) — added to
   ctor/field/`copyWith` (cleared by `clearPrior`); the detector now captures
   `orphan.modeId` (≈ :480) so the restart can target the mode.
2. **`SessionController.startInterruptedModeAgain()` → `Future<bool>`**
   (`session_controller.dart` :507) — clears the prompt, looks up the mode by
   `priorModeId`, and when it still exists starts a **brand-new** real session
   (mirrors the home start path's distress-mode resolution); returns `false`
   (no session) when there is no id or the mode was deleted. The orphan marker
   was already deleted at detection, so no extra marker clearing. NOT a
   resume.
3. **`InterruptedPrompt`** (renamed `_InterruptedPrompt` → public,
   `session_screen.dart` ≈ :567): renders the relative-time started line
   (`relativeTimeLabel(l10n, RelativeTime.between(startedAt))`), shows
   **[Start same mode]** ONLY when `priorModeId != null` (deleted mode → only
   Acknowledge; the snapshotted mode name still renders), then **[Acknowledge]**.
   Start-same-mode → `startInterruptedModeAgain()` → routes `/session` on
   success / home on a deleted mode; Acknowledge → `acknowledgeInterruptedPrompt`
   → home.
4. **Cold-launch surfacing** (`home_screen.dart` ≈ :166-180, the CORE wiring
   gap): `HomeScreen.build` now `ref.watch(sessionControllerProvider)` (the
   detector already runs at home mount — `didChangeDependencies` reads the
   notifier) and, while `priorInterrupted`, **replaces the home body** with
   `InterruptedPrompt`. An errored/absent session AsyncValue (`.value == null`)
   cleanly falls through to the normal dashboard — so the existing home tests
   (no DB override) are unaffected.
5. **Relative-time helper** (pure Dart, dep-free): `core/utils/relative_time.dart`
   (`RelativeTime.between(from, {now})` → coarse justNow/minutes/hours/days
   bucket; future/clock-skew clamps to justNow) + `core/utils/relative_time_l10n.dart`
   (UI glue → the new `sessionInterrupted{JustNow,MinutesAgo,HoursAgo,DaysAgo}`
   keys, ICU-plural).

**Spec reconciliation (spec 04 §Session-Interrupted Prompt):** added an
**M4-C4 reconciliation note** — the marker is the existing SessionLog
in-progress row, NOT a separate `active_session_marker.json` (one on-disk
artifact, not two); rewrote the stale "Data preserved / No SessionLog entry"
paragraph + the "Either path clears `active_session_marker.json`" line to the
SessionLog approach; documented the deleted-mode button-hiding + the fire-once
(detection-time delete) behaviour + the cold-launch surfacing point + the
relative-time bucketer.

**Tests (net +23 → suite 3990):** 18 REAL-controller
`test/features/session/session_controller_interrupted_test.dart` (orphan →
priorInterrupted w/ id+name+start; detection DELETES the orphan; newest orphan
wins; **cleanly-ended (endedAt set) → NO prompt**; no-logs → NO prompt;
acknowledge clears flags; start-same-mode existing → fresh session +
`isSessionActive` + prompt cleared; **deleted mode → false, no session, cleared**;
start-same-mode writes a NEW marker row, not the old orphan) driving the real
`SessionController` against `GuardianAngelaDatabase.memory`; 9 pure
`test/core/utils/relative_time_test.dart` (all bucket boundaries 1m/59m/60m/
23h/24h + justNow + future-clamp); +5 `session_screen_test.dart` (relative-time
rendering; Start-same-mode button shown when mode exists / hidden when deleted;
tap Start-same-mode calls the method; the existing raw-timestamp assertion was
REWRITTEN to the relative phrase) + the fake gained `startInterruptedModeAgain`
+ `_runningState` gained `priorModeId`; +2 `home_screen_test.dart` cold-launch
(modal surfaces instead of the dashboard when `priorInterrupted`; normal
dashboard otherwise) + a local `_FakeSessionController`.

**l10n:** 5 NEW keys in `app_en.arb` (+`@meta`) — `sessionInterruptedStartSameMode`
+ the 3 ICU-plural relative-time keys (`…MinutesAgo`/`…HoursAgo`/`…DaysAgo`,
`{count}` int) + `…JustNow` — and all 13 translation ARBs (additions-only via a
JSON-load → add → dump(indent=2, ensure_ascii=False) Python script; **Slavic
pl/ru/uk use `=1`+`few`+`many`+`other`; Arabic uses zero/one/two/few/many/other;
Hebrew one/two/many/other; zh/zh_TW `other`-only**). `gen-l10n` 0 untranslated;
generated `.dart` strictly additions-only (**606 insertions, 0 deletions** ×14);
parity 14/14; locale-smoke green (all ICU plurals parse + substitute).

**KEY FINDINGS (C4):**
- **The brief's "orphaned `sessionInterrupted*` keys, no readers" was STALE** —
  a prior session had already built the detector + the modal widget + the
  Acknowledge path. Always grep the readers yourself: the keys had 5 readers in
  `session_screen.dart`. The genuine gap was the **cold-launch surfacing**
  (`_InterruptedPrompt` lived only on `/session`, which cold launch never hits)
  + the missing **[Start same mode]** half.
- `HomeScreen` already builds `sessionControllerProvider` at mount
  (`didChangeDependencies` → `configureWidgetLabels` reads `.notifier`), so the
  detector's `build()` already ran on every cold launch — only the *surfacing*
  was missing. `ref.watch(...).value == null` (errored async, e.g. no DB in a
  unit test) is the safe fall-through to the normal dashboard, which is why the
  DB-less home tests didn't need a session override.
- The SessionLog marker snapshots `modeName` at start (`modeName` column, "cached
  even if mode later deleted"), so **deleted-mode display is free**; only the
  restart needs the live `modeId` lookup (→ `getById` null → hide the button).
- `copyWith` can't null a field → `clearPrior` direct-constructs the nulls; the
  new `priorModeId` follows the same `clearPrior ? null : (… ?? this.…)` pattern.

---

## What's done THIS session (M4 C3 — UNPUSHED, `m4-#16`)

**GAPS verified first (all confirmed):** `lib/core/utils/permission_utils.dart`
+ `ensureNotificationPermission` did **not** exist (spec mandates them in 3
places: 04:461, 04:504 item 6, 10:90) — `ensureNotificationPermission`
appeared ONLY in spec/docs, zero code refs. There was **no on-tap
Active-Triggers-Summary** (the home `_onStart` jumped straight to
`startSession`). There was **no notif re-ask in the start flow**. The re-ask
logic was **duplicated** in two places: `notifications_settings_screen._request`
(plain `Permission.notification.request()`) and
`safety_setup_checklist._requestPermission` (request + `openAppSettings()` on
permanent denial). The in-session GPS prompt (`_GpsDestinationPrompt`,
`session_screen.dart:312`, gated on `SessionState.needsGpsDestinationPrompt`)
is already M1-wired — LEFT UNTOUCHED per decision D4. Onboarding's
`requestAllPermissions` is a bulk 6-permission `request()` (NOT the re-ask
pattern) — correctly out of scope.

**Built (all proven by host widget tests):**

1. **`ensureNotificationPermission(BuildContext) → Future<bool>`**
   (`lib/core/utils/permission_utils.dart`): iOS (gated on
   `Theme.of(context).platform != android` — host-testable) → no-op `true`;
   Android already-granted → `true` (no dialog); denied-not-permanent →
   `_NotifPermissionDialog` rationale → on Allow `Permission.notification.request()`
   → returns granted, on "Not now" → `false` (no request); permanently-denied →
   rationale dialog offering `openAppSettings()` deep-link → re-reads status →
   returns granted, never falls back to the OS request. Uses `permission_handler`
   (already a dep); has `statusReader`/`requester`/`settingsOpener` test seams
   (defaults assigned in-body, never as default params).
2. **Start-flow wiring** (`home_screen._onStart`, `_HomeBody`): tap Start →
   `ActiveTriggersSummaryDialog.show` (cancel aborts) →
   `ensureNotificationPermission(context)` → if `false` AND
   `chainNeedsNotifications(mode)` → inline `_showNotifBlocked` warning + abort;
   else `startSession`. Both Start AND Simulate go through this flow.
   `chainNeedsNotifications` (new top-level fn in `home_controller.dart`) =
   chain has a `disguisedReminder` OR `fakeCall` step (the two notification-
   delivering step types; a holdButton+loudAlarm chain is NOT blocked).
3. **DRY refactor (the 2 spec callers now delegate):**
   `notifications_settings_screen._request` → `ensureNotificationPermission` then
   re-reads status for the row; `safety_setup_checklist._requestPermission`
   default → `ensureNotificationPermission` (the duplicated request+openAppSettings
   block is GONE; tests still inject `permissionRequester` to bypass).
4. **Active-Triggers-Summary** (`lib/features/home/widgets/active_triggers_summary.dart`,
   `ActiveTriggersSummaryDialog`): renders the mode's `distressTriggers`
   (HardwareButton: repeat/long-press detail) + `disarmTriggers` (GpsArrival:
   radius + a prompt-at-start note that the destination is asked **in-session**;
   Timer: minutes) with "none configured" fallbacks. **GPS prompt stays
   in-session** — the dialog only *mentions* it (D4).

**Spec reconciliation (2 notes added to spec 04):** (a) the GPS-destination
prompt stays in-session (`_GpsDestinationPrompt`); the summary only mentions a
prompt-at-start trigger — it does not collect coords. (b) "session-notification
steps" maps to `disguisedReminder` + `fakeCall` (the `chainNeedsNotifications`
predicate) — a notification-free chain is not blocked.

**Tests (net +23 → suite 3967):** 8 `test/core/utils/permission_utils_test.dart`
(iOS no-op→true w/ zero perm calls; Android granted→true no dialog; denied
rationale→Allow→request granted/denied; "Not now"→false no request;
permanently-denied deep-link→openAppSettings→granted/denied; "Not now"→no
settings) + 9 `test/features/home/active_triggers_summary_test.dart` (headings,
none×2, repeat/long-press detail, GPS prompt-at-start note PRESENT [D4 proof],
fixed omits note, timer minutes, Start-now/Cancel) + 5 home on-tap in
`home_screen_test.dart` (summary-first; cancel aborts; granted→start;
denied+notif-chain→BLOCKED no start; denied+notif-free→ALLOWED starts) + 1
checklist DRY-delegation (item 6 with no injected requester → shared helper's
rationale dialog appears → requests on Allow) + notif-settings re-ask test
rewritten to assert the rationale dialog (DRY proof). 4 PRE-EXISTING home tests
updated to follow code (tap Start now routes through the summary →
`_installGrantedPerm` + `_tapStartAndProceed`). `pumpScreen` gained an optional
`platform` arg (additions-only) for the iOS branch.

**l10n:** 22 new keys in `app_en.arb` (with `@meta`) + all 13 translation ARBs
(JSON-appended, additions-only, placeholders `{button}/{count}/{seconds}/
{radius}/{minutes}` preserved + verified consistent across all 14). `gen-l10n`
0 untranslated; generated `.dart` additions-only (+1225/-0); parity 22/22 × 14.

**Emulator:** boot-smoke PASS on `emulator-5554` (`assembleDebug` 51.5s +
install + "app boots to a MaterialApp shell"). `POST_NOTIFICATIONS` is declared
in the manifest (line 69). The WIRING is proven by the 8 host tests; the live OS
`POST_NOTIFICATIONS` prompt + the app-notification-settings deep-link are
OS-rendered and need a user-driven denied-then-start — NOT exercised on-device
(no session-driving integration harness). iOS no-ops (proven by host test);
iOS is CI `build-ios`-gated — NO iOS claim.

**KEY FINDINGS (C3):**
- The translation ARBs are **NOT** in the same key order as `app_en.arb`
  (their last key was `phoneWarnEmergencyEmpty`, not the en template's
  `settingsAlarmRampInfo`) — gen-l10n matches by key NAME, so additions can go
  anywhere. The C1/C2 "additions-only" keys carry **no `@meta`** in
  translations (only the template needs `@meta`); a JSON-load → add-keys →
  JSON-dump (indent=2, ensure_ascii=False) is the safest additions-only insert.
- The existing notif-settings test + the checklist `_pump` helper both inject a
  fake `permissionRequester`, so they **bypass** the real delegation — proving
  the DRY required a NEW test that mounts the widget WITHOUT the injection (real
  default → shared helper) and asserts the helper's rationale dialog surfaces.
- `_FakePermissionHandlerPlatform extends PermissionHandlerPlatform with
  MockPlatformInterfaceMixin` + swapping `PermissionHandlerPlatform.instance`
  is the proven seam (override `checkPermissionStatus` / `requestPermissions` /
  `openAppSettings` / `shouldShowRequestPermissionRationale`).

---

**(prior C1+C2 snapshot retained below)**
C2 built the safety-critical R-8 country→emergency-number map (109 countries,
`lib/domain/models/emergency_numbers.dart`, owner-reviewed "unified-else-police"
rule, every adjusted entry web-verified + 2 `// VERIFY` flags), the mandated
`PhoneValidators` (`lib/core/utils/phone_validators.dart`), first-launch locale
seeding in `runBootstrap` (`seedFirstLaunchSettings`), an editable emergency-
number dialog with the validator wired (the old picker was preset-only, no
free-text — a spec gap), the contact-form `warnContactNumber` reuse, and the
`home_controller.startSession` hard-coded-`'112'`→`settings.emergencyCallNumber`
fix. Gate: analyzer `--fatal-infos` 0; full suite **3944** (3895 C1 baseline +
49 net-new); l10n parity 14/14 on 7 new keys; deferral-grep 0; OLD/ clean.
**The final emergency map is committed locally and awaits the owner's FINAL
pre-push review** (the orchestrator will surface the "CHANGES FROM THE REVIEWED
DRAFT" summary before the M4 push). **NEXT = M4 C3 — #16 notification re-ask +
Active-Triggers-Summary + the shared `permission_utils.dart`.** No native path
in C2 → no emulator run. See the **M4 DECISIONS** block below (F2 now DECIDED:
DESCOPE).

---

## What's done THIS session (M4 C2 — UNPUSHED, `m4-#10`)

**GAPS verified first (all confirmed):** the `emergencyNumbers` map existed
ONLY as a spec sketch (`docs/spec/03:1321`, ~6 grouped entries) — **no code
map**; `phone_validators.dart` did **not** exist; there was **no first-launch
locale seeding** (everyone got the model-default `'112'`);
`home_controller.startSession:118` passed a **hard-coded `'112'`** to the
start-validator. BONUS gap: the Settings emergency-number control was a
**preset-only bottom sheet** with NO free-text field and NO validator — the
spec (06:215-226) mandates an *editable* dialog, so the picker was incomplete.

**Built (all proven by pure-Dart unit tests + widget tests):**

1. **The R-8 map** — `lib/domain/models/emergency_numbers.dart`:
   `const Map<String,String> emergencyNumbers` (109 countries, ISO-alpha-2 keys)
   + `const kEmergencyFallback = '112'`. Header cites the methodology
   (Wikipedia base + ITU/gov cross-check, owner-reviewed 2026-06-09), the
   **unified-else-police** rule, and the `'112'` GSM-fallback rationale. Every
   entry has an inline source/role comment. Applied the owner's rules to the
   reviewed draft (see "CHANGES FROM THE REVIEWED DRAFT" in the final report).
2. **`emergencyNumberForLocale(String) → String`** (same file) — total, never
   throws: extracts the region subtag from a platform locale (`en_US`, `de-DE`,
   `pt_BR.UTF-8`, codeset/`@modifier` stripped), upper-cases, looks it up, and
   falls back to `'112'` for a bare/region-less/unmapped locale.
3. **`PhoneValidators`** — `lib/core/utils/phone_validators.dart` (pure Dart,
   Flutter-free, returns `PhoneNumberWarning?` codes, not strings):
   `warnEmergencyNumber` (empty→`empty` [Save-blocking]; non-`[0-9+*#]`→
   `invalidCharacters`; <3 **digits**→`tooShort`; >6 digits→
   `looksLikeRegularNumber`) + `warnContactNumber` (char-class only, additionally
   tolerates space/hyphen — a contact is a regular number, no length warning).
   Digit-count ignores `+ * #` (so `*12#`=2 digits=tooShort).
4. **First-launch locale seeding** — `seedFirstLaunchSettings(repo,
   {deviceLocale})` in `main.dart`, wired into `runBootstrap` Step 2 (uses
   `Platform.localeName`). Seeds ONLY when `repo.loadOrNull() == null` (genuine
   first launch — no settings file yet); a returning user's value is returned
   verbatim and **never overwritten** (precedence tier 1 wins, even if it equals
   `'112'`). `SeedData.defaultAppSettings` gained an `emergencyCallNumber`
   param (default `'112'`).
5. **Editable emergency dialog** — replaced the preset-only sheet with
   `_EmergencyNumberDialog` (`settings_screen.dart`): free-text `TextField` +
   live non-blocking `warnEmergencyNumber` warning (empty→`errorText` + Save
   disabled; other warnings→`helperText`, Save stays enabled) + common-number
   quick-fill tiles. Returns the trimmed value; a blank can never persist.
6. **Contact-form reuse** — `warnContactNumber` wired as live `helperText`
   below the phone field (`contact_form_screen.dart`); empty stays enforced by
   the form's own `validationPhoneRequired`.
7. **home_controller fix** — `startSession` now loads `settings` before the
   validator and passes `settings.emergencyCallNumber` (was `'112'`).
8. **Code→l10n glue** — `phoneWarningMessage(l10n, warning)` in
   `lib/core/utils/phone_warning_l10n.dart` (UI-glue, shared by the dialog +
   contact form) maps the pure-Dart code → localized string.

**Tests (net +49 → suite 3944):** 17 validator (`test/core/utils/
phone_validators_test.dart`: char-class, the 3/6-digit boundaries, empty,
contact leniency) + 24 map/locale (`test/domain/models/emergency_numbers_test.dart`:
well-formed keys/numbers, no-malformed, the mandated adjustments [PK==15,
DE==110, CO==123, ZA==112, ET==911, CI==111] + EU-112 block, locale resolution +
fallbacks + case-insensitivity) + 8 seeding (`test/main_seed_first_launch_test.dart`:
first-launch seeds+saves per region, unmapped→112, returning-user verbatim +
NO-save + 112-preserved) + 5 settings-dialog widget + 3 contact-form-warning
widget. A duplicate-key scan + a 109==literal-count check guard the map.

**l10n:** 7 new keys (`settingsEmergencyNumberEditTitle`/`…FieldLabel`/
`…PresetsLabel`, `phoneWarnInvalidChars`/`…TooShort`/`…LooksLikeRegular`/
`…EmergencyEmpty`) in `app_en.arb` (+`@meta`) + all 13 translation ARBs
(TEXT-INSERTED, additions-only: prior-last `distressCancelBiometricReason` gains
a comma + 7 new lines). `gen-l10n` 0 untranslated; generated `.dart` additions-
only; parity 14/14.

**Web-verification (the safety gate):** every adjusted/flagged entry was
cross-checked against Wikipedia + targeted gov/embassy/police-site searches —
see the final report's "CHANGES FROM THE REVIEWED DRAFT". The 2 `// VERIFY`
entries (ET=911, CI=111) ship the best pick + flag per the owner's accept.

---

**(prior C1 snapshot retained below)** This session wired the two dead biometric flags
(`sessionEndPinBiometricEnabled`, `distressCancelBiometricEnabled`) at their two
PIN prompts (biometric-first, PIN fallback), mirroring the launch-gate reference
pattern, and — because the distress-cancel flag had NO setter / NO Settings
toggle (a deeper dead-flag than the brief implied) — added the
`setDistressCancelBiometric` controller path + the Settings→Security toggle so
the feature is actually reachable. The distress-cancel 15s-timeout-window
invariant (spec 01:1019) is preserved: the timer starts BEFORE the biometric
prompt and is never reset on biometric failure (proven by a dedicated host
test). Gate: analyzer `--fatal-infos` 0; full suite **3895** (3882 M3-C5
baseline + 13 net-new); emulator boot-smoke PASS on `emulator-5554` (build still
links `local_auth`); l10n parity 14/14 on 3 new keys; deferral-grep 0; OLD/
clean. **NEXT = M4 C2 — #10 R-8 emergency-number map (Option B, user-reviewed) +
`phone_validators.dart` + first-launch locale seeding.** See the **M4 DECISIONS
(user, 2026-06-08/09)** block below. iOS Face ID is CI `build-ios`-gated (not
buildable on this Linux host) — NOT verified here.

---

## M4 DECISIONS (user, 2026-06-08/09) — carry into every M4 chunk

- **#9 biometric (session-end + distress-cancel)** = THIS chunk (C1, DONE).
  Both PIN prompts now try biometric first when the per-site flag is on and the
  device has enrolled biometrics, falling back to the PIN keypad on
  cancel/failure/absence (fail-soft toward the PIN, never toward an open app).
  The distress-cancel attempt runs INSIDE the already-started 15s window.
- **#10 R-8 emergency-number map = Option B.** Wikipedia base + ITU cross-check
  for the top ~40 by population; EVERY entry CITED; primary all-services number
  only; `'112'` fallback. **The produced map MUST be surfaced to the user for
  review BEFORE merge** (recorded requirement — do not merge the map unreviewed).
  Build `phone_validators.dart` (spec 06:227) + first-launch locale seeding; fix
  the hard-coded `'112'` in `home_controller.startSession:118`.
- **#16 = keep the GPS-destination prompt IN-SESSION** (already M1-wired); add
  ONLY (a) the on-tap Active-Triggers-Summary and (b) the notification re-ask via
  a NEW shared `lib/core/utils/permission_utils.dart::ensureNotificationPermission`
  (spec-mandated in 3 places; refactor the notif-settings screen + the
  Safety-Setup-Checklist item 6 to delegate to it).
- **#8 = build MINIMAL,** reusing the existing **SessionLog in-progress marker**
  (NOT the spec's separate JSON file); informational modal + [Start same mode]
  (a fresh session) / [Acknowledge]; reconcile the spec marker text to the
  SessionLog approach.
- **Tier-F:** **F1 DESCOPE.** **F2 DESCOPE — DECIDED (2026-06-09).** The
  orchestrator's force-kill-resilience research concluded and the user decided
  to **descope F2 and REMOVE the `SCHEDULE_EXACT_ALARM` permission** (no
  AlarmManager watchdog). The permission removal is **executed in C5** (a later
  M4 chunk) — do NOT touch the manifest / permission in C2/C3/C4; C5 owns it.
  **F3 = build as USER-SUPPLIED ringtones** (a ringtone picker/import in the
  fake-call config — the user provides their own audio, sidestepping licensing;
  NOT bundled per-style assets). **F4 = KEEP+BUILD** (wire `requireLaunchAuth` /
  `launchAuthBiometric` per spec — but FIRST determine from the spec what they do
  BEYOND the App-PIN launch gate; if genuinely identical/redundant, surface that
  to the orchestrator rather than building a duplicate). **F5 = KEEP+BUILD**
  (post-session feedback prompt).

---

## What's done THIS session (M4 C1 — UNPUSHED, `m4-#9`)

**GAP verified first (confirmed, deeper than briefed):** BOTH PIN prompts
ignored their persisted biometric flag — a classic dead-flag.
(1) `end_session_overlay._onSwipeConfirmed` jumped straight to the PIN keypad;
`sessionEndPinBiometricEnabled` was read NOWHERE. (2) `session_screen.dart`
distress-cancel `_onCancelTapped` jumped straight to the keypad + 15s timer;
`distressCancelBiometricEnabled` was read NOWHERE. (3) **The distress-cancel
flag had NO `setDistressCancelBiometric` setter, was NOT in `SettingsSecurityState`,
and had NO Settings toggle** — it was only read in `clearPin`'s reconstruction,
so it could never be turned on by any UI path (the brief's "the toggles are
already exposed" was wrong for distress-cancel; only App-PIN + Session-End were).
`SimulationBiometricService` (records `isAvailable`/`authenticate` in `.calls`)
already exists as the proven test double; the launch gate
(`launch_pin_screen.dart:82-111`) is the reference consumer.

**Built (all proven by host widget tests driving the REAL overlay/screen):**

1. **Session-end biometric** (`end_session_overlay.dart` :208-247). After the
   swipe confirms and a `sessionEndPinHash` is set, when
   `sessionEndPinBiometricEnabled` a new `_tryEndSessionBiometric()` runs
   `isAvailable()` → `authenticate(reason: sessionEndBiometricReason)`; success
   reports `EndSessionOutcome.endConfirmed` (short-circuits the keypad); any
   false path (absence/cancel/failure/unmounted) falls through to `_Stage.pin`.
   Mirrors the launch gate; PIN stays the fallback.
2. **Distress-cancel biometric** (`session_screen.dart` :776-822). In
   `_onCancelTapped`, after `pauseDistressCountdown()` + `setState(pinPrompt)`,
   the 15s timer is **started FIRST** (`_startPinTimer()`), THEN — when
   `distressCancelBiometricEnabled` — `_tryDistressCancelBiometric()` runs
   `isAvailable()` → `authenticate(reason: distressCancelBiometricReason)`;
   success → `resetWrongPinAttempts()` + cancel timer + `cancelDistress()`;
   failure/cancel → the keypad is already shown and the timer keeps running
   **untouched** (spec 01:1019 "within the same 15s timeout window"). `_pinTimer
   == null` guards the race where the window expires (fires distress + unmounts)
   during the async biometric call.
3. **Made the distress-cancel flag settable** (otherwise the C1 distress-cancel
   half is itself a dead flag): `distressCancelBiometricEnabled` added to
   `SettingsSecurityState` (+ `build()`), a `setDistressCancelBiometric` setter
   on `SettingsSecurityController` (copyWith→save→invalidateSelf, mirrors the
   other two), and a `SwitchListTile` toggle in the Session-End `_PinCard` of
   `settings_security_screen.dart` (new label `securityDistressCancelBiometric`).
4. **l10n:** 3 new keys — `securityDistressCancelBiometric` (toggle),
   `sessionEndBiometricReason`, `distressCancelBiometricReason` — in `app_en.arb`
   (with `@meta`) + all 13 translation ARBs (TEXT-INSERTED, additions-only: the
   prior-last `sessionReminderDecoyWords` line gains a trailing comma + 3 new
   lines). The two reason strings are intentionally **brand-free** ("Confirm to
   end the session" / "Confirm it's you to cancel") so the OS biometric sheet
   never reveals the safety app under stealth (spec 01:1017). `gen-l10n`
   additions-only (165 insertions, 0 deletions in the generated files); parity
   14/14.

**Tests (net +13 → suite 3895):** 3 session-end biometric (success→ends w/o
keypad; off→no call+keypad; failure→keypad+PIN still ends) + 4 distress-cancel
biometric (success→cancelDistress; off→no call+keypad; failure→keypad+PIN
cancels; **failure does NOT reset the 15s window — the keypad shows the full
remaining 15s and 16×1s ticks still fire `confirmDistress(distressConfirmTimeout)`**)
in `session_screen_test.dart`; 3 REAL-controller persist tests in the new
`settings_security_controller_test.dart` (build reflects flag / setter
round-trips through the repo / sibling flags untouched); 3 settings-screen
toggle tests (render / reflect-on / tap-calls-setter). Eight PRE-EXISTING
settings-screen tests (Duress-card title/body/buttons/3-card-count/accessibility)
were updated to `skipOffstage:false` presence finders because the new 4th
SwitchListTile pushed the Duress card below the test-viewport fold (tests follow
code; the card is laid out in the non-lazy ListView, just clipped).

**Emulator:** boot-smoke PASS on `emulator-5554` (`assembleDebug` + install +
"app boots to a MaterialApp shell"), confirming the build still links
`local_auth ^3.0.0`. The OS biometric sheet is system-rendered; the WIRING is
proven by the host widget tests above. iOS Face ID is CI `build-ios`-gated — NOT
verified on this Linux host.

---

## OLD pre-M4 snapshot (M0–M3 detail — retained for reference)

**Snapshot:** 2026-06-08 — **M0 + M1 + M2 PUSHED (`origin/main` = `b4c8b21`).
M3 (#15 stealth) FULLY IMPLEMENTED + MILESTONE-COHORT-VERIFIED (PASS),
GATE-GREEN, ready to push** — C1 (`ac65b9e`) + C3 (`a6c36ef`) + C4 (`837c1e4`)
+ C2 (`55f958d`) + C5 (`256bb93`). NEXT = **orchestrator pushes the M3 stack,
then M4 (#10/#9/#8/#16 + the Tier-F + R-8 emergency-number decisions).**
M3 milestone cohort (architect-reviewer spec-vs-code + qa-expert spec-vs-tests,
both opus, whole stack): **PASS** — all 5 stealth safety invariants verified at
integration level (disguised reminder still full-screen-fires; fakeIcon switch
leaves the app launchable; stealth immutable mid-session; FG service starts/stops
with the session; engine timer runs under the music-player disguise). 2
non-gating advisories carried → per-preset integration-test hardening (M5
device-e2e) + stale spec `06:521` summary-table cell (M4 doc-sweep).

**M3 C5 (THIS session) — #18 disguise polish (pure Flutter):**
(1) **Localized the tapWord decoy words.** The English-only `_decoyPool` in
`reminder_word_choices.dart` became `kReminderDecoyPoolFallback` (the documented
English fallback), and `buildReminderWordChoices` gained an optional
`List<String>? decoyPool` param (null/empty → fallback). `_TapWordChoices` in
`reminder_confirmation.dart` now sources the pool from a NEW l10n key
`sessionReminderDecoyWords` (a comma-separated list of ~10 neutral
notification-action words per locale), parsed via `_decoyPoolFor(l10n)`
(split-on-comma → trim → uppercase → drop blanks). Added the key to ALL 14 ARBs
(en template + 13 translations, text-inserted, additions-only) + `gen-l10n`.
**Hardened the safety invariant:** the decoy-collision filter is now
case-insensitive (`w.toUpperCase() != keyword.toUpperCase()`) so a localized
decoy can never accidentally equal the real keyword. The deterministic
seed/rotate selection (the real-word-among-decoys mechanism) is UNCHANGED — only
the pool source moved.
(2) **Rendered `ReminderTemplate.imagePath`/`iconAsset`** in
`ReminderDisguiseContent` via a new private `_TemplateDisguiseIcon`
(render-if-present + Material fallback, user decision #6): `imagePath` → `Image`
(asset, or `FileImage` for an absolute `/…` path) → wins; else `iconAsset` →
either a canonical category key (`kReminderIconCategories`, e.g. `'fitness'`) →
`reminderIconDataFor(key)` Material symbol, OR an asset-path-looking string
(contains `/` or an image extension, per spec 03's `"assets/icons/calendar.png"`
example) → `Image`; else the Material `Icons.notifications_active_outlined`
fallback. A broken image path degrades to the Material fallback via
`errorBuilder` (a bad path can NEVER expose the disguise). **Settable
assessment (per the task):** `iconAsset` IS settable in production — the M2
`ReminderTemplateForm` (`reminder_template_form.dart:133`) persists one of 8
category KEYS into it; so the category-key→Material-icon branch is the live
production path. `imagePath` is NOT settable by any production path today (no
seed template + the form has no image picker — only tests set it), but
render-if-present is the correct contract for when one does. NO asset/icon
picker built (out of C5 scope; an `imagePath` image-picker is a sensible future
item — noted under DEFERRED). NO new disguise art commissioned. Gate GREEN:
analyzer `--fatal-infos` = 0; full suite **3882** (3873 C2 baseline + 9 net-new:
3 pure-function decoy-pool + 6 widget [4 icon render/fallback + 2 localized-decoy
under a non-English `es` locale]); l10n parity 14/14 (`sessionReminderDecoyWords`
14/14); deferral-grep 0; OLD/ clean. **Pure Flutter — no native path touched, so
no emulator run needed.**

**M3 C2 (THIS session) — reconciliation + cleanup (mostly-spec, small UI):**
(1) **Spec 04-vs-06 contradiction resolved in favour of the standalone
`/settings/stealth` screen** (the user-kept design): spec 06 §Stealth Mode
Section no longer calls stealth a "collapsible card on the main settings
screen" — it now blesses the standalone `SettingsStealthScreen` (reached from
the Security → Stealth hub row), with an explicit *Reconciliation note (M3 C2)*
recording the superseded card phrasing. Spec 04:106 already named
`/settings/stealth` correctly (no edit needed). (2) **`lockTaskMode` KEPT +
documented:** it was ALREADY exposed as a `SwitchListTile` in the standalone
screen (with `stealthLockTaskSubtitle`); C2 added an **`InfoIconButton`
trade-off tooltip** beside it (new ARB key `stealthLockTaskInfo` × 14 locales:
the screen-pinning "App is pinned" banner + app-switch block mid-session) and
added `lockTaskMode` to the spec-06 field table as the **7th field** + an
info-tooltip line + a paragraph noting it is the only *OS-session-scoped*
StealthConfig field (engaged at session start, unlike the config-save-time
`fakeIcon`). (3) **In-player "Stealth Mode: ON" toggle RESOLVED → removed** from
the spec mockup (04:914/924, with a *Removed (M3 C2)* note explaining the
immutability conflict), and the pre-staged `sessionStealthToggleLabel` ARB key
**removed from all 14 ARBs** (had ZERO `lib/`+`test/` references — confirmed) +
`gen-l10n` regen. (4) **Stale "Phase 7" doc-comments fixed:**
`system_ui_service.dart` (:1-4 header + :38-40 class doc) and
`service_providers.dart` (:301-303 systemUi provider) now say the native
handlers are *registered in MainActivity.kt* (the StealthIconChannel handler
EXISTS) — no new "Phase X" string introduced. (Other services' Phase-7 comments
are out of C2 scope — system-ui/stealth only.) Gate GREEN: analyzer = 0; suite
**3873** (3868 C4 baseline + 5 net-new: 2 REAL-controller lockTaskMode persist +
3 screen InfoIconButton render/absent/tap-opens-sheet); l10n parity 14/14
(`stealthLockTaskInfo` added 14/14; `sessionStealthToggleLabel` removed 0/14);
deferral-grep 0; OLD/ clean. **No native path touched → no emulator run needed
(doc-comment + Flutter-UI + spec + ARB only).**

**M3 C4 (THIS session) — full per-preset `fakeIcon` launcher disguise:** the
single on/off `StealthIconChannel` alias is reworked to **10 launcher
activity-aliases** — the real `.MainActivityAlias` (= `StealthIconPreset.none`,
default `enabled=true`) + 9 disguise aliases `.StealthAlias_<preset>`
(`music/calendar/fitness/weather/news/photos/notes/clock/podcast`, default
`enabled=false`), exactly ONE enabled at a time. Each disguise alias has its own
adaptive launcher icon (`mipmap-anydpi-v26/ic_stealth_<preset>.xml` = solid
`#131118` background + a **Material Symbols** foreground vector
`drawable/ic_stealth_fg_<preset>.xml`, sourced from the design system, NOT
bespoke art; minSdk 26 ⇒ adaptive XML only, no raster fallback) + a neutral
`@string/stealth_label_<preset>` label. The Kotlin channel method is now
`setStealthIcon(preset)` (enable target alias first, then disable the others,
all `DONT_KILL_APP`). Dart triplet reworked in lockstep: protocol/Real/Sim
`setStealthIcon(StealthIconPreset)`; `StealthIconCall` now carries a `preset`
(was a `bool enabled`). **Runtime caller wired (was the ZERO-caller dead
method):** `SettingsStealthController._saveStealth` now calls
`_applyLauncherIcon(stealth)` on every save in `/settings/stealth` — preset =
`enabled ? fakeIcon : none`; **suppressed while a session is active**
(`SessionController.isSessionActive`, new public getter) so the alias swap can
never kill a live session (config still persists; icon reconciles on the next
no-session save). Spec remark added (spec 06 §Stealth Mode Section): stealth
settings are immutable during an active session, and the launcher icon applies
at **config-save** time (global `AppDefaults.stealth.fakeIcon`), unlike
session-scoped `lockTaskMode`. C3 closed the **background-survival gap**:
`BackgroundSessionService.startService`/`stopService` had ZERO callers — the
Android foreground service NEVER started, so a backgrounded session could be
OS-killed. C3 wires `startService` on session start + `stopService` on
end/disarm/dispose through the REAL `SessionController`; resolves
`fakeName`/`notificationDisguise` onto `SessionState` from the SAME
`StealthConfig` as C1; makes `showForegroundServiceNotification` +
`showDisguisedReminder` honor the disguise (generic channel name + neutral
`ic_stat_stealth` icon + `fakeName` title) — previously the `stealth` flag was
IGNORED (const details); replaces the hard-coded `'Music paused'` with
`'<fakeName> paused'`; and surfaces the real `fakeName` as the fake-music-player
header brand line (C1 had a neutral placeholder there). Authoritative gate is
GREEN: analyzer `--fatal-infos` = 0; full suite `flutter test --concurrency=6` =
**3861 pass** (3843 C1 baseline + 18 net-new); emulator boot-smoke PASS on
`emulator-5554` (+ `ic_stat_stealth.xml` confirmed compiled into the APK,
`res/drawable/ic_stat_stealth`); l10n parity 14/14 on 3 new keys; deferral-grep
0; OLD/ clean. **NEXT ACTION = M3 C4** (fakeIcon FULL per-preset rework: native
10 activity-aliases + icons + `setStealthIcon(preset)` + arm-time caller + the
spec remark that stealth settings are immutable during an active session). C2
(spec-reconcile) + C5 (polish) also remain. See the **M3 chunk plan** + **M3
DECISIONS (user)** blocks below.

---

## M3 chunk plan (#15 stealth — large, mostly-hollow; user-scoped)

- **C1 — stealth session-screen UI** ✅ DONE (`ac65b9e`, UNPUSHED). Fake music
  player + `SessionElapsedClock`(+G-018) + branding strip.
- **C3 — notification/`fakeName` disguise + foreground-service start/stop** ✅
  DONE this session (`m3-#15-c3`, UNPUSHED). See "What's done THIS session" below.
- **C4 — ✅ DONE this session (`m3-#15-c4`, UNPUSHED).** `fakeIcon` → FULL
  per-preset rework. Native: 10 launcher activity-aliases (1 real + 9 disguise)
  + 9 adaptive Material-sourced icons + `setStealthIcon(preset)` on
  `StealthIconChannel`. Caller wired at **config-save** time in
  `SettingsStealthController` (NOT arm-time — see the trigger finding below),
  guarded by `SessionController.isSessionActive` so the alias swap never runs
  mid-session. Spec remark added (the C2 task can cross-reference it). NOTE: C3's
  neutral *notification* small-icon (`ic_stat_stealth`) is the status-bar icon, a
  DIFFERENT concern from C4's *launcher* icon (both now exist, independently).
- **C2 — ✅ DONE this session (`m3-#15-c2`, UNPUSHED).** Spec-reconcile: spec 06
  §Stealth blesses the standalone `/settings/stealth` screen (collapsible-card
  phrasing superseded with a reconciliation note); `lockTaskMode` documented as
  the 7th field + an `InfoIconButton` trade-off tooltip added to the screen
  (new `stealthLockTaskInfo` × 14); the immutability remark already lives in
  spec 06 (C4); the in-player "Stealth Mode: ON" toggle RESOLVED → removed from
  the spec mockup + `sessionStealthToggleLabel` removed from all 14 ARBs; stale
  "Phase 7" system-ui doc-comments corrected. See "What's done THIS session".
- **C5 — ✅ DONE this session (`m3-#15-c5`, UNPUSHED).** #18 disguise polish:
  tapWord decoy-word localization (new `sessionReminderDecoyWords` × 14;
  `buildReminderWordChoices(decoyPool:)` + the English `kReminderDecoyPoolFallback`)
  + disguise template icon/image rendering (`_TemplateDisguiseIcon`,
  render-if-present + Material fallback). The music-player **track/artist** strings
  STAY neutral localized placeholders (C3 wired `fakeName` to the **header brand
  line** only — the spec's "Spotify/Apple Music" app-name slot — which is the
  correct fakeName home; track/artist are song metadata, intentionally left
  neutral; this is NOT a stub). See "What's done THIS session".

---

## M3 DECISIONS (user — carry into C2/C3/C4/C5)

1. **`fakeIcon` → FULL per-preset rework (C4).** Rationale: stealth settings
   are configured BEFORE a session and **cannot change during an active
   session**, so the "process-kill mid-session" risk is moot. (A spec remark to
   that effect is to be added in C2.)
2. **Config UI: KEEP the standalone `/settings/stealth` screen.** Spec 06 will
   be corrected to bless it (C2).
3. **`lockTaskMode`: KEEP + document** (C2). (Already wired:
   `session_controller.dart:630` engages it for real sessions; released on
   `endSession`.)
4. **`BackgroundSessionService`: WIRE it to actually start/stop in M3 (C3).**
5. **`fakeName` scope = notifications + in-session chrome (C5).**
6. **Disguise template icons = render-if-present + Material fallback (C5).**

---

## OLD pre-M3 snapshot (M2 detail — retained for reference)

**M2 WAS FULLY IMPLEMENTED + COHORT-VERIFIED (PASS) + THE LAST COVERAGE-GAP
FINDING CLOSED + GATE-GREEN.** The M2 cohort (architect-reviewer
spec-vs-code + qa-expert spec-vs-tests) PASSED with ONE low/non-blocking
finding: a missing END-TO-END widget test proving the SMS contact-grid
all-capable inference (`allContacts` ⇒ `contactIds = null`) persists through
the REAL Mode Editor to the DB. **That test is now added and green** (`abc1bbf`
— see below). The authoritative pre-push gate was re-run and is GREEN:
analyzer `--fatal-infos` = 0; full suite `flutter test --concurrency=6` =
**3822 pass** (3821 baseline + 1 new) with zero `sqlite3mc` errors; deferral-grep
0; OLD/ clean; tree clean. **NEXT ACTION = the ORCHESTRATOR PUSHES the M2 stack
(11 commits ahead of `origin/main`), then M3 (#15 stealth).** The M2 set is:
#13a + #13b + #14 + #13c (cohort-VERIFIED PASS at `d54b986`+`81f131f`) + #13d
(PASS `0788c52`) + #23 (PASS `8c191ac`) + #20 (ALL 4 SUB-PARTS) + #14-test
(`abc1bbf`, close M2-cohort finding).

**sqlite3mc native-asset note (carry forward):** the transient
`libsqlite3mc.x64.linux.so` "Hash of downloaded file … expected …" failure is a
**GitHub release-CDN flap**: direct `curl` of
`github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.3.1/libsqlite3mc.x64.linux.so`
intermittently returns **HTTP 504**, and the Dart hook's `HttpClient` streams the
504 error-page body AS the "binary" (so it hashes to garbage). The pin is
`9139316c6bffee12ea095c5353fa2a10362aa3698cf04cf12ffcf982e248dc1a`
(`sqlite3-3.3.1/lib/src/hook/asset_hashes.dart`). Recovery: **just re-run** — a
retry usually lands an HTTP 200 with correct bytes (verified this session: 504
then 200-GOOD on the next attempt), after which the hook caches the good file
in `.dart_tool/hooks_runner/shared/sqlite3/build/download-<random>/` and reuses
it. The `download-<hex>` dirname is `Object.hash(...).toRadixString(16)` and is
**randomised per Dart isolate**, so you cannot pre-seed it by name — retrying the
download is the fix, not cache surgery. This session's authoritative full run
completed with the native build succeeding cleanly (0 hash errors).

The M1 stack was already pushed before this session (the previous handoff was
written pre-push; `origin/main` = `b62ba2b`). M2 builds the configuration UIs.
**The M2 commits are UNPUSHED on local `main`**, by design — M2 pushes as
one milestone after the verifier cohort (rule 12 + plan §3.7):

- `8f74423` m2-#13a — extract shared `EventSpecificConfig` + `step_helpers`
- `b557f98` m2-#13b — rebuild Mode Editor chain (per-step `StepConfigPanel`)
- `11473ba` m2-#14 — SMS contact-selection grid
- `f40baba` m2-handoff (prior session boundary)
- `d54b986` m2-#13c — Mode Editor Safety Options
- `81f131f` m2-#13c-fix — cohort findings (local-template Add + test gaps)
- `0788c52` m2-#13d — save + trigger save-validation
- `8c191ac` m2-#23 — alarm settings section
- `967fe59` m2-#20 — channel validation + SMS template editor + iOS warnings
              (sub-parts 1–3)
- `<prior>`  m2-#20-fix — iOS `critical_alert.wav` (siren.wav) + shared
              SMS-target resolver (sub-part 4 + cohort DRY advisory + a test
              read-back)
- `abc1bbf`  m2-#14 — e2e grid-inference persistence test (close M2-cohort
              finding): one mode-editor widget test driving deselect→reselect
              of a contact chip, asserting the saved `SmsContactConfig` reloads
              from the DB as `allContacts` with `contactIds == null`
- (+ this handoff commit)

**Tests: 3822 pass** (3821 prior + 1 net-new end-to-end grid-inference widget
test in `test/features/mode_editor/mode_editor_screen_test.dart`). Analyzer
`--fatal-infos` clean (0 issues). deferral-grep 0; OLD/ clean. Tree clean.
Branch: `main` (11 commits ahead of `origin/main`). (Pure-Dart shared resolver +
strategy/validator delegation; the
iOS bundle change — `ios/Runner/critical_alert.wav` + `project.pbxproj`
entries — has NO local build proof: it builds in CI's `build-ios` job, the
real gate on a non-macOS host.)

**#20 sub-part 4 (RESOLVED):** the user approved sourcing iOS
`critical_alert.wav` from `assets/audio/siren.wav` (the canonical alarm sound
the app already ships and plays on both platforms; RIFF/WAVE PCM 16-bit mono
44.1 kHz, a valid `UNNotificationSound` format, well under the iOS 30 s limit).
Done this session: copied the bytes verbatim to `ios/Runner/critical_alert.wav`
(SHA-256 identical to `siren.wav`); added three `project.pbxproj` entries
modelled on the existing `Assets.xcassets` root resource — a `PBXFileReference`
(`GA00010000000000000000A1`, `lastKnownFileType = audio.wav`), a `PBXBuildFile`
(`GA00010000000000000000A0`), the file in the **Runner target's Resources build
phase** (`97C146EC…`), and a listing in the Runner `PBXGroup`. The pbxproj
parses (balanced braces/parens, 15/15 sections, cross-refs consistent).
`notification_service.dart:391` defaults `sound: 'critical_alert.wav'`, which
now resolves to the bundled file at runtime. **iOS build is NOT verifiable on
this Linux box — CI `build-ios` is the gate.** No `Info.plist` change is needed:
`UNNotificationSound(named:)` resolves bundle-root sounds without a plist key.

---

## How to resume

After `/clear`, paste:

> Continue from HANDOFF.md

**Next action: resolve the C7/F4 owner decision, THEN run the M4 milestone
cohort + owner emergency-map review + push the M4 stack.** With C8 (F5) BUILT,
**all M4 BUILD work is done**; the only OPEN item is the C7/F4 redundancy owner
decision (recommendation: DELETE both dead fields in a schema-cleanup — see the
C7 section). M0–M3 are PUSHED (`origin/main` = `5ab69c6`); the M4 UNPUSHED stack
is C1 (#9 biometric, `m4-#9`) + C2 (#10 R-8 map + `phone_validators` + locale
seeding, `m4-#10`) + C3 (#16 notification re-ask + Active-Triggers-Summary +
`permission_utils.dart`, `m4-#16`) + C4 (#8 Session-Interrupted prompt, `m4-#8`)
+ C5 (Tier-F F1/F2 descope + REMOVE `SCHEDULE_EXACT_ALARM` + spec/doc
reconciliation, `m4-tierF`) + C6 (Tier-F F3 user-supplied ringtone, `m4-tierF-#F3`)
+ **C8 (Tier-F F5 post-session feedback prompt, `m4-tierF-#F5`)** — all
DONE+GATE-GREEN+COMMITTED (UNPUSHED).

**DEFERRED — still TO DO (the orchestrator's pre-push items):**
- **F4 = C7 — DONE (`m4-tierF-#F4`), no longer deferred.** Owner DECIDED
  2026-06-09: DELETE both `requireLaunchAuth` / `launchAuthBiometric`. Deleted
  this session (8 model sites + 2 `clearPin` lines + 3 test assertions + spec 03
  & 08 + the remediation tracker). App-PIN gate is the sole launch-auth,
  unchanged. See the C7 section "DELETION DONE".
- **Owner FINAL pre-push emergency-map review** (the orchestrator must surface
  the C2 "CHANGES FROM THE REVIEWED DRAFT" summary before the M4 push;
  spot-confirm **DE=110, ET=911, CI=111**). The count is now `== 109`-guarded.
- **`lib/services/*` Phase-X doc-sweep tail + CLAUDE.md native-files tidy**
  (carried from prior chunks — C5 swept `service_providers.dart`'s 9 strings;
  CLAUDE.md still lists `PhoneChannel.kt`/`DeviceStateChannel.kt` which do NOT
  exist — see C5 KEY FINDINGS).

**DONE in C8 (`m4-tierF-#F5`):** post-session feedback prompt on
`SessionCompletedScreen` (optional/dismissible `[Send feedback]`/`[Skip]`,
gated to ≥3 clean REAL completions via the new SharedPreferences-backed
`FeedbackPromptRepository`, NEVER for simulation/stealth, NEVER mid-emergency)
→ routes to the existing `/settings/feedback` form (local `feedback_history`
Drift persistence; no server). +17 tests; +3 l10n keys ×14; new provider row in
`docs/wiring-map.md`. See the C8 section.

**DONE in C5 (`m4-tierF`):** Tier-F F1 DESCOPE (spec 05 note) + F2 DESCOPE +
`SCHEDULE_EXACT_ALARM` REMOVED from the manifest (spec 10 notes) +
`service_providers.dart` Phase-7 doc-sweep (all 9 strings) + the C4 spec-01
SessionLog-marker reconciliation + Duress-PIN carve-out note + the C3
spec-ordering note (04) + the emergency-map `== 109` exact-count tightening.

Per-chunk recipe (unchanged): verify the gap yourself → implement (serial) →
prove (host/widget tests driving the REAL controller/screen; emulator for
native) → l10n deltas → translate 13 locales → gate suite → commit → **ask
before pushing**.

**DO NOT PUSH** without explicit user authorization (Hard Rule 12).

---

## What's done THIS session (M3 C4 — UNPUSHED, `m3-#15-c4`)

**GAP verified first (confirmed):** `StealthIconChannel` was a single on/off
toggle of ONE alias (`.MainActivityAlias`, labelled `@string/widget_description`,
icon = the app's own `@mipmap/ic_launcher`); `setStealthIconEnabled(bool)` on the
Dart triplet had **ZERO runtime callers** — `SettingsStealthController.setFakeIcon`
only persisted the preset to the DB, never touching the native channel. The
`iconFromStealth(preset)` helper referenced in the enum doc **does not exist**
(only the comment mentions it). minSdk = 26 (so adaptive launcher icons are
XML-only). `StealthIconPreset` = 10 values (`music/calendar/fitness/weather/news/
photos/notes/clock/podcast/none`, `none` = the real GA icon). Spec 11 REJ-6
named the design intent verbatim (`StealthAlias_music`/`_podcast`/`_calendar`).

**Built (proven by host tests + an on-device alias-switch/relaunch check):**

1. **Per-preset Android activity-aliases** (`AndroidManifest.xml`): the one alias
   became **10 launcher aliases** — `.MainActivityAlias` (the real GA launcher =
   `none`, `enabled=true`, `@mipmap/ic_launcher`, `@string/app_name`) + 9
   `.StealthAlias_<preset>` (each `enabled=false`, own MAIN/LAUNCHER filter, own
   adaptive icon + `@string/stealth_label_<preset>`). Factory state = EXACTLY ONE
   enabled (the real launcher) → launchable out of the box. Verified in the
   merged manifest (`aapt2 dump xmltree`).
2. **Launcher icons** (design-system-sourced, NOT bespoke): 9 adaptive
   `mipmap-anydpi-v26/ic_stealth_<preset>.xml` = `@color/ic_stealth_background`
   (`#131118`, new `values/colors.xml`) + a Material Symbols `<foreground>`
   vector `drawable/ic_stealth_fg_<preset>.xml` (music_note, calendar_today,
   fitness_center, wb_sunny, article, photo_library, edit_note, schedule,
   podcasts — scaled 2.5× onto the 108-unit safe zone, white fill). All 9
   mipmaps + 9 vectors + the colour compiled into the APK (`aapt2 dump
   resources`); no dangling `android:icon` refs.
3. **Native channel + protocol rework:** `StealthIconChannel.setStealthIcon`
   (Kotlin; `aliasByPreset` map; enable target FIRST then disable the others, all
   `DONT_KILL_APP`; unknown preset → `result.error`). Dart triplet in lockstep:
   protocol/Real/Sim `setStealthIcon(StealthIconPreset)`; `StealthIconCall` now
   carries a `preset` (was `bool enabled`); the base `SystemUiCall` no longer has
   a shared `enabled` (moved onto `LockTaskCall`). Real instantiation stays in
   `service_providers.dart` (CI grep). `MainActivity.kt` channel registration
   unchanged (method name is dispatched inside the handler).
4. **Runtime caller + session-lock:** `SettingsStealthController._saveStealth`
   now calls `_applyLauncherIcon(stealth)` on EVERY save in `/settings/stealth`
   (preset = `enabled ? fakeIcon : none`), **suppressed while a session is
   active** via the new public `SessionController.isSessionActive` getter
   (`_engine != null && !_engine.isEnded`). Fail-soft (the Real service
   try/catches the channel). The config still persists during a session; the icon
   reconciles on the next no-session save.
5. **Spec remark** (`docs/spec/06-settings.md` §Stealth Mode Section): two
   paragraphs — (a) **stealth settings are immutable during an active session**
   (resolved once at `startSession`, frozen; this is what makes the eager alias
   swap safe); (b) **the `fakeIcon` launcher disguise applies at config-save
   time** from the GLOBAL `AppDefaults.stealth.fakeIcon` (persistent home-screen
   concealment, unlike session-scoped `lockTaskMode`); a `ModeOverrides` icon
   does not retarget the launcher.

**Tests (net +7 → suite 3868):** `test/services/system_ui_service_test.dart`
reworked to the preset API (sim records `StealthIconCall.preset`; lock-task tests
cast to `LockTaskCall` for `.enabled`). New
`test/features/settings_stealth/settings_stealth_controller_test.dart` — 7 tests
driving the REAL `SettingsStealthController` through `_saveStealth` with a
round-tripping in-memory repo + a `SimulationSystemUiService` override: enabling
applies the configured preset; changing the preset applies it; disabling →
`none`; a non-icon save still reconciles; persist round-trips; **session-active →
NO `setStealthIcon` call** (lock); session-active still PERSISTS the config. The
existing `settings_stealth_screen_test.dart` (fake-controller, doesn't hit
`_saveStealth`) stays green.

**l10n:** ZERO new ARB keys (the preset dropdown labels already exist as
`stealthPreset*`). The 9 launcher labels are **Android resource strings**
(`res/values/strings.xml` `stealth_label_<preset>` + `app_name`), rendered by the
OS launcher — static + English-only, intentionally generic; the 14-ARB parity
rule does not apply. No `gen-l10n` run needed.

**Emulator (the relaunch-after-switch proof):** boot-smoke PASS on
`emulator-5554` on the reworked build. Debug APK builds clean (manifest + 10
aliases + 9 icons through aapt2). **Relaunch-after-switch VERIFIED:** an
integration test (`integration_test/stealth_icon_switch_test.dart`) drove the
REAL `RealSystemUiService.setStealthIcon` in-process across all 10 presets and
left `music` enabled; while it ran, `cmd package resolve-activity -a MAIN -c
LAUNCHER` resolved to **`.StealthAlias_music`** (the disguise alias became the
sole launcher), `cmd package query-activities` listed only `.StealthAlias_music`,
and `am start -n …/.StealthAlias_music` launched the app with
`topResumedActivity = …/.StealthAlias_music` — i.e. **after the switch the app
STILL LAUNCHES via the disguise icon** (the unlaunchable-app failure mode is ruled
out). KEY FINDING: `pm enable` of another package's component is blocked from the
adb shell (`SecurityException … to 1`) and `adb root` is refused on this
production image — the swap can ONLY be driven from the app's own UID, hence the
integration-test path. (A naive concurrent `am start` mid-test stalls the
integration binding — observe alias state via adb instead; the proof above used
that.) iOS: `setStealthIcon` no-ops (component toggling unavailable); the iOS
stub compiles — CI `build-ios`-gated (not locally buildable on Linux).

---

## What's done last session (M3 C3 — UNPUSHED, `m3-#15-c3`)

**GAPS verified first (all confirmed):** (1) `BackgroundSessionService.startService`
/`stopService` had **ZERO callers** in `lib/features/` AND `configure()` was
**never called anywhere** (not even in `main.dart` — only a comment) → the
Android foreground service never started; a backgrounded session could be
OS-killed. (2) `showForegroundServiceNotification` **IGNORED** its `stealth`
param — `const NotificationDetails`, always channel `'System Service'`, no
fakeName, no icon swap. (3) `showDisguisedReminder` had **no** stealth/disguise
param (always `'Reminders'`). (4) `background_session_service._onActionTap`
hard-coded `'Music paused'`. (5) C1's `FakeMusicPlayer` header used the neutral
`sessionStealthNowPlaying` placeholder, NOT the resolved `fakeName`. Nobody
subscribed to the bg-service `onPause`/`onResume`/`onImSafe` streams;
`updateNotification` had zero callers (left as-is — out of C3 scope).

**Built (all proven by host/widget tests driving the REAL controller/services):**

1. **Resolve + carry `fakeName`/`notificationDisguise`.** Added both to
   `SessionState` (ctor + `copyWith` + reset-on-`endSession` to `'Music'`/`true`),
   resolved from the SAME `StealthConfig` C1 uses (`session_controller.dart`
   ≈ :635 `final stealth = …`). Also added `notificationStealth`
   (`= enabled && notificationDisguise`) to `EventServices` so the disguised
   reminder strategy knows whether to disguise.
2. **Notification disguise (service layer).** `notification_service.dart`:
   `showForegroundServiceNotification` + `showDisguisedReminder` now build
   **non-const** details and, when `stealth`, swap to a generic channel name
   (`'Updates'`, const `_kDisguisedChannelName` — the channel **id** is
   unchanged so the FG service stays bound to `session_service`) + a neutral
   small-icon (`'ic_stat_stealth'`, new vector drawable
   `android/app/src/main/res/drawable/ic_stat_stealth.xml`). **Extra-35
   lock-screen flags are PRESERVED** under stealth (a disguised reminder must
   still wake a locked device — asserted). Added `stealth`/`fakeName` params to
   the protocol + Real + Sim for both notification methods and for
   `BackgroundSessionServiceProtocol.startService`/`updateNotification`. The
   `_onActionTap` pause text is now `'<fakeName> paused'` (default fakeName
   `'Music'` → `'Music paused'`, so the existing G2 tests stay green).
   `DisguisedReminderStrategy` threads `services.notificationStealth` →
   `showDisguisedReminder(stealth:)`.
3. **WIRE foreground-service start/stop (user decision #4).** New
   `_startForegroundService({required StealthConfig stealth})` +
   `_stopForegroundService()` on `SessionController`. `startSession` calls start
   (after `engine.start()`), `endSession` + `_disposeAll` (provider-disposed,
   live-session path) call stop. `configure()` runs **once** per controller
   (guarded by `_backgroundConfigured`). The disguise title = `fakeName` when
   `enabled && notificationDisguise`, else the localized `_fgServiceTitle`; body
   = neutral `_fgServiceStealthBody` when disguised, else `_fgServiceBody`. The
   3 FG-service strings are pre-localised via an **extended
   `configureWidgetLabels`** (HomeScreen has the BuildContext; the notifier has
   none — same pattern as the widget labels). Both helpers are **fail-soft**
   (try/catch + log): a notification failure must never abort a session.
4. **Triplet consistency.** Real-only instantiation stays in
   `service_providers.dart` (the controller reads
   `backgroundSessionServiceProvider`); Sim + protocol updated in lockstep for
   every new param. False-positive philosophy: a **simulation** session ALSO
   starts the FG service (a practice run must survive backgrounding too) —
   asserted.
5. **C1 fake-music-player fakeName.** `FakeMusicPlayer` gained a `fakeName`
   param; the header brand line (the spec's "Spotify/Apple Music" app-name slot,
   04:897) now shows the resolved `fakeName`, falling back to the neutral
   `sessionStealthNowPlaying` label only when blank. Threaded from
   `session_screen.dart` (`state.fakeName`). (Track/artist stay neutral — they
   are song metadata, not the app name; spec 06:85 scopes fakeName to the app
   NAME. The track/artist polish is C5.)

**Tests (net +18 → suite 3861):** 6 FG-service lifecycle tests in
`session_controller_dispatch_test.dart` (start configures+startService;
endSession stopService; stealth+disguise → disguised start w/ fakeName title;
stealth-without-disguise → normal start; configure-once-across-two-sessions;
sim-also-starts) driving the REAL `SessionController` with a
`SimulationBackgroundSessionService` override (added to the test `_container`).
6 disguise tests in `notification_service_test.dart` (FG + reminder: non-stealth
real channel + null icon; stealth generic channel + `ic_stat_stealth`; reminder
stealth PRESERVES all Extra-35 flags; FG stealth keeps ongoing/low-importance).
2 strategy tests (`notificationStealth` true→`stealth:true`, default→false).
2 `FakeMusicPlayer` header tests (custom fakeName shown; blank→neutral
fallback). 2 bg-service tests (custom fakeName → `'<name> paused'`; fakeName
threaded). Updated test fakes: `_test_fakes.FakeNotificationService` +
`buildServices` (+`notificationStealth`), `_RecordingNotificationService` +
`_FakeSessionController.configureWidgetLabels` (new optional params),
`session_screen_test._runningState` (+`fakeName`). One s7 stealth golden
re-baselined (`linux/`; header text `Now playing`→`Music`; CI variant
font-blind, unchanged).

**l10n:** 3 new keys (`sessionServiceTitle`, `sessionServiceBody`,
`sessionServiceStealthBody`) in `app_en.arb` + all 13 translation ARBs
(TEXT-INSERTED after the `sessionStealthNowPlaying` anchor, additions-only: +3
per translation ARB / +12 en). `gen-l10n` regen additions-only; parity 14/14.
Brand name "Guardian Angela" kept untranslated.

**Emulator:** boot-smoke PASS on `emulator-5554`; the new
`ic_stat_stealth.xml` is **confirmed compiled into the APK**
(`aapt2 dump resources` → `res/drawable/ic_stat_stealth`), so the disguise
small-icon reference resolves at runtime (not a dangling ref). **NOT verified
on-device:** an actual session START driving the FG service to runtime (no
session-driving integration harness exists; that is M5 device-E2E territory).
The host tests prove the wiring; the emulator proves it compiles+boots+the icon
resource is real. iOS notification disguise is CI `build-ios`-gated (not locally
buildable on this Linux box).

**DEFERRED to C5 (NOT a stub):** music-player **track/artist** strings stay
neutral localized placeholders (fakeName's correct home is the header app-name
slot, now wired; track/artist are song metadata). `updateNotification` (and the
bg-service `onPause`/`onResume`/`onImSafe` streams) still have no controller
subscriber — the FG notification text does NOT live-update per engine event
(start posts it; the action-tap self-update handles pause/resume text). Wiring a
per-event `updateNotification` + subscribing the controller to the action
streams is a larger lifecycle task; the start/stop survival gap (the C3 mandate)
is closed. Not a stub — the notification is posted and persistent.

---

## What's done last session (M3 C1 — UNPUSHED, `ac65b9e`)

**GAP verified first:** the only previously-wired stealth effect was the
disarm-label swap (`sessionDisarm`→`sessionDisarmStealth` at
`session_screen.dart` `_SessionBody`); `SessionState` carried only
`stealthEnabled` (bare bool) and its doc OVER-CLAIMED it drove "fake music
player chrome and other stealth toggles" — it drove ONLY the label swap.
`timerDisplay`/`sessionScreenStealth` were resolved into a `StealthConfig` at
`session_controller.dart:563` but **thrown away** (never carried into the UI).

**Built (all proven by host/widget tests driving the REAL
`SessionScreen`→`SessionController`):**

1. **Fake music player** — new `lib/features/session/widgets/fake_music_player.dart`
   (`FakeMusicPlayer`). Album-art placeholder + brand line + track/artist
   chrome + transport controls. The **centre button is the REAL pause/resume**
   (`onPlayPause` → `controller.pause()`/`resume()` chosen by `isPaused`); the
   **progress track is a `SwipeSlider`** whose confirm = the REAL
   `controller.disarm()` (reuses `sessionDisarmStealth` label). Gated on
   `state.stealthEnabled` in `_SessionBody` (now a `ConsumerStatefulWidget`,
   `session_screen.dart` ≈ :311) which wraps it in a `Listener(onPointerDown:)`
   feeding the corner clock's G-018 idle-fade via a `ValueNotifier<int>`.
   Overflow-safe (`LayoutBuilder`+`SingleChildScrollView`+min-height). Skip
   prev/next are decorative (documented, not stubs). The disarm-label swap is
   PRESERVED (the non-stealth body still uses it).
2. **`SessionElapsedClock`** — new
   `lib/features/session/widgets/session_elapsed_clock.dart`, key
   `Key('session-elapsed-clock')` (const `sessionElapsedClockKey`). `normal` =
   monospace heading clock, **always 100 % opacity**, `H:MM:SS`/`M:SS`
   (non-padded leading field). `small` = 12 pt monospace `M:SS` (→ `H:MM` past
   99 min), **fades to 50 % after 10 s idle (G-018, 400 ms), restored to 100 %
   on any interaction** (driven by `interactionSignal`). `none` = `SizedBox`
   that STILL carries the key. Replaced `_SessionHeader`'s inline always-on
   timer (the old static `_formatElapsed` is DELETED). **Non-stealth sessions
   always render `normal`** (a safety choice — never hide elapsed time when the
   user isn't disguising; documented on `SessionState.timerDisplay`).
3. **`SessionState` threading** — added `timerDisplay` (`StealthTimerDisplay`,
   default `normal`) + `sessionScreenStealth` (`bool`, default `true`) to the
   ctor/`copyWith` (`session_controller.dart`), resolved from the SAME
   `StealthConfig` at `:563`, reset to defaults on `endSession`. Fixed the
   over-claiming `stealthEnabled` doc.
4. **`sessionScreenStealth` branding strip** — `SessionScreen` app-bar title is
   **null** when `stealthEnabled && sessionScreenStealth` (`session_screen.dart`
   ≈ :117). The end-session overlay gained a `stealth` flag
   (`end_session_overlay.dart`): the swipe stage drops the exit glyph + title +
   body, the PIN stage drops the lock glyph + "Session End PIN" title (spec
   04:932-937). Threaded from `_endSessionFlow`.

**Tests (net +21 → suite 3843):** new
`test/features/session/widgets/session_elapsed_clock_test.dart` (format matrix
+ G-018 fade via `tester.pump(Duration)` timer-advance + interaction-restore +
"normal never dims"); new `group('SessionScreen — stealth fake music player
(#15)')` in `session_screen_test.dart` (music player renders / not in
non-stealth; play→pause(), play→resume() when paused; **incremental** swipe →
disarm() [single-jump `tester.drag` loses the arena to the scroll view — use a
stepped gesture on a phone-sized surface]; timer normal/small/none; branding
strip on/off; brand-free end-session overlay). One pre-existing assertion
updated `01:05`→`1:05` (format change; tests follow code). `_FakeSessionController`
gained `pauseCalls`/`resumeCalls`; `_runningState` gained
`timerDisplay`/`sessionScreenStealth`/`isPaused`. Golden: new scenario 7
(`session_screen_s7_dark_stealth_music_player`); s1-s6 `linux/` goldens
re-baselined for the `0:42` format (ci/ variants unchanged — font-blind).
**Emulator boot-smoke PASS** on `emulator-5554`.

**l10n:** 7 new keys (`sessionStealthNowPlaying`, `…TrackTitle`, `…ArtistName`,
`…AlbumArtLabel`, `…Play`, `…Pause`, `…ToggleLabel`) in `app_en.arb` + all 13
translation ARBs (TEXT-INSERTED, additions-only: `8 +/1 -` per file = the prior
last line re-added with a comma + 7 new lines). `gen-l10n` reports 0
untranslated; parity 14/14. (`…ToggleLabel` is added for the future in-player
toggle but is **not yet rendered** — see DECISIONS / C2.)

**~~DEFERRED to C2~~ — RESOLVED in C2 (`m3-#15-c2`):** the spec mockup's
in-player "Stealth Mode: ON" toggle (spec 04:914/924). Its spec semantics
("toggle stealth on/off") conflict with the immutable-during-session decision —
a functional toggle violates it; a dead one is a stub. **C2 removed it** from
the spec mockup (with a *Removed (M3 C2)* note) and **deleted the pre-staged
`sessionStealthToggleLabel` key from all 14 ARBs** (zero `lib/`+`test/`
references — confirmed before removal). The session screen renders the resolved
stealth appearance only; stealth is configured pre-session on
`SettingsStealthScreen`.

---

## What's done (M2 spine — pushed/being-pushed)

- **#13a** (`8f74423`): pure refactor — moved the 9 per-type `StepConfig`
  forms + shared field editors out of `event_defaults_screen.dart` into a
  reusable public `EventSpecificConfig`
  (`lib/features/modes/widgets/event_specific_config.dart`) + added
  `step_helpers.dart` (`stepIcon`/`stepDescription`/`stepName`).
  EventDefaultsScreen consumes both. 58 event_defaults tests unchanged-green.
- **#13b** (`b557f98`): **per-step-config half of GA-blocker #13.** Mode
  Editor chain is now a `SliverReorderableList` of expandable step tiles;
  each expands inline to `StepConfigPanel` (3 collapsible groups: Timing /
  Event configuration via `EventSpecificConfig` / Retry & Advanced). A null
  config displays resolved `AppDefaults.eventDefaults` and materialises on
  first edit (spec 04:1541). Per-step Reset/Duplicate/Delete (Delete disabled
  at 1 step); drag-to-reorder re-indexes `order`; categorised Add-Step picker
  with localized names. New shared `config_fields.dart`
  (Int/Double/Enum/Text editors). 31 mode-editor widget tests (drive the real
  screen→draft→DB flow incl. a reorder-drag test). Emulator boot-smoke green.
- **#14** (`11473ba`): **GA-blocker #14.** smsContact config renders an
  `SmsContactGrid` (one FilterChip per contact) — Mode Editor context only
  (`EventSpecificConfig.contacts != null`; null in Event Defaults).
  Channel-incapable contacts greyed/unselectable. Toggle re-infers selection;
  **all-capable selected → `allContacts` with `contactIds = null`** (a
  non-null id list under `allContacts` is read as *specific IDs* by the
  runtime resolver — see KEY FINDINGS). Empty repo → deep-link to `/contacts`.
  8 grid tests (incl. the null-contactIds inference) + a mode-editor
  integration test.
- **#13c** (`<this>`): **Safety Options half of GA-blocker #13.** Collapsible
  "Safety options" `ExpansionTile` at the bottom of the editor
  (`lib/features/modes/widgets/safety_options_section.dart`), wired to the
  editor's in-memory `_draft` via a new `_updateDraft(SessionMode)` mutator.
  Sub-parts, all driving `_draft`→DB on Save: distress-mode picker (writes
  `distressModeId`; hidden in distress variant; "Use default" names the
  resolved default mode) + "Manage distress modes" link; distress-triggers
  list (add/edit/remove `HardwareButtonDistressTrigger`, pattern↔count/dur
  normalised on edit); disarm-triggers (GPS-arrival toggle+radius slider
  50m–5km+destination-source+fixed lat/lng; timer toggle+5min–8h slider);
  GPS-logging tri-state (Inherit/Custom/Off) with inline `GpsLoggingFields`;
  stealth tri-state with inline `StealthConfigFields`; mode-local templates
  list (remove + "Manage reminder templates" link); event-defaults tri-state
  (Inherit/Custom) with inline `ModeEventDefaults`; `allowDisarmAsDistress`
  toggle (distress variant only, G-014). Distress variant's `_AddStepSheet`
  omits the check-in category (spec 04:1649). `InfoIconButton`s throughout
  (now localized — `commonGotIt`). New controller-free field widgets
  `gps_logging_fields.dart` / `stealth_config_fields.dart` /
  `mode_event_defaults.dart` mirror the standalone screens. 20 widget tests
  (real screen→draft→DB, incl. override-clearing round-trip, fixed-source
  lat/lng, RTL-expanded render). 53 new l10n keys × 14 locales. Emulator
  boot-smoke green.
- **#13d** (`<this>`): **save + trigger save-validation** (the last piece of
  GA-blocker #13). New pure-Dart, Flutter-free `validateModeDraft(SessionMode,
  {name})` → `List<ModeValidationIssue>` (each carries a `ModeValidationCode`
  + `blocking` flag) in `lib/domain/validation/mode_draft_validator.dart`,
  reusing the errors/warnings (blocking/non-blocking) split that
  `ValidationResult`/`SessionStartValidator` already established. The editor's
  `_save()` (previously UNCONDITIONAL) now consumes it: first **blocking**
  issue → localized SnackBar + early return (mirrors `contact_form._save()`);
  any **non-blocking** warning → a "Save anyway?" confirm dialog; then persist
  with the trimmed name. Rules: (1) name <2 chars → BLOCK (reuses existing
  `validationNameTooShort`); (2) chain empty → BLOCK (release-mode defense —
  `SessionMode` asserts non-empty + the editor's delete-guard make it
  unreachable in debug, documented as such); (3) distress mode w/o
  smsContact/phoneCallContact/callEmergency → **WARN, non-blocking** (spec
  04:1659, app philosophy = don't over-block); (4) GPS-arrival `fixed`
  destination missing lat/lng → BLOCK (the validation deferred from #13c);
  (5) hardware-button distress trigger internally inconsistent (longPress w/o
  positive duration, or repeatPress w/ stray duration / pressCount<2) → BLOCK,
  a backstop to `_triggerWithPattern`'s on-edit normalisation. 6 new l10n keys
  × 14 locales. 28 net-new tests (21 pure-Dart validator + 7 widget tests
  driving the REAL `_save()`: too-short name blocked+error, fixed-GPS-no-coords
  blocked, valid-GPS saves, inconsistent-hardware blocked, distress-no-action
  warns-then-saves, warn-cancel-not-saved, distress-with-sms saves clean). Two
  pre-existing distress-mode-save tests updated to dismiss the new non-blocking
  warning (tests follow code). Pure-Dart UI+validation — no native path, so
  emulator boot-smoke not required (not run).
- **#23** (`<this>`): **GA-blocker #23 — Settings-level Alarm section** (spec
  06 §Alarm Section, 240-265 in `06-settings.md`; the task's "06:271-296" is
  the older line range). **GAP found:** the three `AppSettings` fields
  (`alarmDndOverride` / `alarmGradualVolume` /
  `alarmGradualVolumeDurationSeconds`) ALREADY existed (defaults false/false/5,
  JSON ser/deser, copyWith, ==, hashCode, + a `[1,60]` assert) and the runtime
  resolution was ALREADY fully wired by M0 #19 (`loud_alarm_strategy.dart:69-76`
  ANDs the global gradual master with per-step `config.gradualVolume`, uses the
  global duration as ramp seconds, passes `alarmDndOverride` through;
  `event_services.dart:123-187` mirrors them; `session_controller.dart:618-621`
  feeds them in). The per-step `_LoudAlarmForm` (#13a) exposes only the per-step
  `gradualVolume` toggle. **What was genuinely missing = the Settings-level UI
  only** (zero alarm matches in `settings_screen.dart`) + the controller
  setters to persist it. **Implemented:** extended `SettingsHubState` + `build()`
  with the 3 fields and added `setAlarmDndOverride` / `setAlarmGradualVolume` /
  `setAlarmGradualVolumeDurationSeconds` (load→copyWith→save→invalidateSelf,
  the GPS-logging-controller pattern; the duration setter `.clamp(1,60)` as a
  release-mode backstop to the model assert) in `settings_controller.dart`; a
  new private `_AlarmSection` `ConsumerWidget` in `settings_screen.dart`
  (own `_SectionHeader` between Configuration and App) — DND `SwitchListTile`
  + an error-coloured silent-mode warning shown only when OFF (spec 06:251) +
  `InfoIconButton`; gradual `SwitchListTile` + info; ramp `TimingSlider`
  (min 1, max 60s) revealed only when gradual is ON (spec 06:260) + info.
  8 l10n keys × 14 locales. 20 net-new tests (13 widget driving the REAL
  screen→controller, incl. warning-visibility-by-state, conditional ramp
  reveal, slider bounds, RTL/dark; 7 controller tests driving the REAL
  `SettingsController` through a round-tripping in-memory repo — persist +
  read-back + clamp-below/above + sibling-field preservation). Pure-Dart
  UI+controller — no model/strategy/native change, so emulator not required
  (not run). Settings goldens unchanged (Alarm section below the 844px fold).
- **#20** (`<this>`): **GA-blocker #20 — sub-parts 1–3** (sub-part 4 BLOCKED,
  see above). (1) **Channel-validation-on-save (BLOCK, spec 02:319 / 03:319):**
  extended the pure-Dart `validateModeDraft` with a new `contacts` param +
  `ModeValidationCode.smsChannelNotOnContacts`. For each `smsContact` step it
  resolves the targeted recipients (mirroring
  `sms_contact_strategy._resolveContacts` incl. the legacy allContacts+ids→
  specificIds back-compat and firstContact-by-sortOrder) and BLOCKS iff the
  step targets ≥1 contact but NONE carries the step's `channel`. An empty
  target set (empty repo / specificIds-with-no-ids) does NOT block — that's
  the no-contacts concern `SessionStartValidator` warns (not blocks) on, and
  blocking it would be a false positive (philosophy). Wired through the real
  `_save()` (`mode_editor_screen.dart:177-181` now passes `_contacts`) +
  `_issueMessage` arm + `validationSmsChannelNotOnContacts`. (2) **SMS
  `messageTemplate` editor (spec 02:287-304):** new reusable
  `MessageTemplateField` in `config_fields.dart` (multi-line; blank commits as
  `null` = seeded default; `ActionChip`s insert `{name}`/`{location}`/`{time}`/
  `{description}` at the caret — `kSmsTemplatePlaceholders` in
  `event_specific_config.dart`; `{photo}` excluded per G-017). `_SmsContactForm`
  uses a direct-construct `_withTemplate` helper because `copyWith` can't null
  the field. Persists draft→DB. (3) **iOS warnings (spec 02:325, 02:479):**
  `_PlatformWarning` banner in `_SmsContactForm` (iOS + `channel == sms`) and
  `_CallEmergencyForm` (iOS), gated on **`Theme.of(context).platform ==
  TargetPlatform.iOS`** (NOT `Platform.isIOS` — the Theme platform is
  host-test-overridable via `ThemeData(platform:)`). New keys
  `eventDefaultsSmsIosWarning` / `eventDefaultsCallEmergencyIosWarning`. 20
  net-new tests (see test-count note). 5 new l10n keys × 14 locales. Pure-Dart
  validator + Flutter-only UI — no native path in the committed parts, so
  emulator not required (not run); the iOS BUILD of sub-part 4's bundle change
  defers to CI `build-ios` (real platform constraint, not a deferral).
- **#20-fix** (`<this>`): closes #20 (sub-part 4) + one cohort DRY advisory + a
  test read-back. (A) **iOS `critical_alert.wav`** — see the resolved sub-part-4
  section above; `siren.wav` bytes → `ios/Runner/critical_alert.wav`, 3
  pbxproj entries + Runner-group listing, CI `build-ios` is the build gate.
  (B) **Shared SMS-target resolver (safety-critical DRY).** The validator's
  `_resolveSmsTargets` hand-duplicated the runtime
  `SmsContactStrategy._resolveContacts`; branch-equivalent but free to drift,
  and drift = the editor validating a different recipient set than distress
  actually messages. Extracted ONE pure-Dart function `resolveSmsTargets(
  SmsContactConfig, List<EmergencyContact>) → List<EmergencyContact>` into
  `lib/domain/orchestration/resolve_sms_targets.dart`. BOTH call sites now
  delegate to it (the strategy passes `services.contacts.all`; the validator
  passes its `contacts` param). Runtime semantics preserved EXACTLY (the
  runtime was the source of truth): all 35 `sms_contact_strategy_test` cases +
  all `mode_draft_validator_test` channel cases stay green unchanged. 13
  net-new direct branch tests cover every path (allContacts true-all + empty;
  legacy allContacts+ids→specificIds + empty-ids→genuine-all; firstContact by
  sortOrder + ties + no-mutate + empty; specificIds order + missing-id-skip +
  duplicate-preserve + null + empty). (C) **Test read-back** — the
  channel-mismatch blocked-save widget test now asserts the persisted step
  config is still `SmsContactConfig(channel: whatsapp)` (explicit no-persist
  proof; the comment previously advertised a read-back it didn't perform). No
  l10n/native/model change; pure-Dart + a test. Emulator not run (iOS bundle is
  the only native artifact, and it is CI-gated).

---

## KEY FINDINGS (carry into the next session)

- **(M4 C2) The emergency number flows `AppSettings.emergencyCallNumber` →
  `session_controller.dart:703` → `EventServices.emergencyNumberDefault` →
  `CallEmergencyStrategy`** (per-step `CallEmergencyConfig.emergencyNumber`
  overrides it). The map/seeding only sets the *default* the user sees + the
  validator gates; the dial path was already wired. To change "what number gets
  dialed by default," edit `emergencyNumbers` (the map) — the runtime already
  reads `settings.emergencyCallNumber`.
- **(M4 C2) First-launch detection = `AppSettingsRepository.loadOrNull() ==
  null`**, NOT `isFirstLaunch` (which the onboarding flow flips and is about
  routing, not persistence). `loadOrNull()` returns null iff no settings file
  exists on disk; `load()` returns seeded defaults even when absent, so it can't
  distinguish "never seeded" from "user-saved 112". Seed on the null signal,
  then NEVER re-seed (the file now exists) — that is what preserves a user value
  of `'112'` as a deliberate choice. The seed hook is `seedFirstLaunchSettings`
  in `main.dart`, called in `runBootstrap` Step 2 (NOT in the onboarding
  controller — seeding must happen on the very first boot, before any screen).
- **(M4 C2) `PhoneValidators` returns CODES, not strings** (pure Dart in
  `lib/core/utils/`, same Flutter-free pattern as `validateModeDraft`). The
  code→string mapper lives in `lib/core/utils/phone_warning_l10n.dart` (a
  separate UI-glue file that CAN import `AppLocalizations`) and is shared by the
  Settings dialog + the contact form. Keep the validator Flutter-free; add new
  warning strings to the mapper, not the validator.
- **(M4 C2) The emergency-number Settings control had to be REBUILT, not just
  wired** — it was a preset-only bottom sheet (no free-text, no validator),
  which violates spec 06:215-226 (an *editable* free-form field). The new
  `_EmergencyNumberDialog` is the live control: empty→`errorText`+Save-disabled
  (the only Save-blocking case), other warnings→non-blocking `helperText`, a
  blank never persists. If a future task touches the emergency number, edit the
  dialog (not a sheet).
- **(M4 C2) The R-8 "unified-else-police" rule** (owner, 2026-06-09): use the
  genuine all-services number where one exists, else the POLICE line for split
  countries. The map ships 109 countries; micro-states are deliberately ABSENT
  → they fall through to `kEmergencyFallback` `'112'`. Two entries carry
  `// VERIFY` (ET=911, CI=111 — sources genuinely conflict; owner accepted
  shipping the best pick + flag). A wrong police number is dangerous — web-verify
  before changing ANY entry, and prefer keeping the value + a `// VERIFY` over a
  confident-wrong change. The map AWAITS the owner's final pre-push review.
- **(M4 C1) The distress-cancel 15s window is a widget-local `Timer`
  (`_DistressConfirmationOverlayState._pinTimer` in `session_screen.dart`), so
  "don't reset it across a biometric attempt" = start it BEFORE the biometric
  and never call `_startPinTimer()` again on the failure path.** Unlike the
  launch gate (which has no timer), this overlay owns the window. The biometric
  attempt is `await`ed AFTER `_startPinTimer()`; the `_pinTimer == null` checks
  before/after `authenticate()` handle the race where the window expires
  mid-prompt (the expiry fires `confirmDistress` + unmounts the overlay).
  Provable in a `testWidgets` with `tester.pump(Duration(seconds:1))` ×16 — the
  in-widget periodic timer advances with the fake clock; assert the timeout
  STILL fires after a failed biometric (and that the keypad shows the full
  `distressCancelPinTimeoutLabel(15)` immediately after the attempt).
- **(M4 C1) `distressCancelBiometricEnabled` was a TRIPLE dead-flag** — ignored
  by the prompt AND unsettable (no setter, not in `SettingsSecurityState`, no
  toggle; only read in `clearPin`'s field-by-field reconstruction). Wiring just
  the prompt would have left it permanently false. The full path now exists:
  state field + `setDistressCancelBiometric` + a Session-End-card toggle. The
  brief's "the Settings→Security UI already exposes the toggles" held ONLY for
  App-PIN + Session-End; verify a flag is *settable* before assuming a prompt
  gap is the whole gap.
- **(M4 C1) Biometric reason strings for in-session prompts must be BRAND-FREE.**
  The launch gate uses `launchPinBiometricReason = "Unlock Guardian Angela"`
  (fine — pre-session), but the session-end and distress-cancel sheets can pop
  on a disguised device, so their reasons name no app (`sessionEndBiometricReason`
  / `distressCancelBiometricReason`). Spec 01:1017 ("Confirmation UI respects
  stealth mode — no app branding").
- **(M4 C1) `SimulationBiometricService(available:, authenticateResult:)`** is
  the ready-made test double (`lib/services/sim/biometric_service_sim.dart`); it
  records `'isAvailable'`/`'authenticate'` in `.calls` so a test can assert the
  consult ORDER and that an OFF toggle never consults it (`.calls.isEmpty()`).
  Override `biometricServiceProvider.overrideWithValue(bio)` in the existing
  `session_screen_test` `_pump`/`_pumpWithRouter` `extraOverrides`.
- **(M4 C1) Adding a SwitchListTile to a settings card pushes later cards below
  the 600px test-viewport fold** → pre-existing `find.text`/`find.byType`
  (default `skipOffstage:true`) finders silently miss them. Fix presence/count
  assertions with `skipOffstage:false`; fix a TAP with `tester.ensureVisible`
  first (offstage widgets aren't hittable). The settings ListView is non-lazy
  (`ListView(children:[...])`), so the widgets ARE built — just clipped.
- **(M3 C4) The launcher `fakeIcon` applies at CONFIG-SAVE time, NOT arm-time —
  this is the corrected trigger.** The HANDOFF chunk-plan previously said
  "resolve `stealth.fakeIcon` at `startSession`" (mirroring `lockTaskMode`).
  That is WRONG for the launcher: the home-screen icon is a *persistent*
  concealment — a user enabling stealth wants GA hidden from the launcher/app-
  switcher **at all times, including between sessions** (so a partner browsing
  the phone never sees a safety app). Arm-time apply+revert would expose the GA
  icon between sessions, defeating the disguise, AND would flip the alias at the
  most dangerous moment (session start) where a `DONT_KILL_APP` process-kill
  could abort the just-started session. So the caller lives in
  `SettingsStealthController._saveStealth → _applyLauncherIcon` (global
  `AppDefaults.stealth.fakeIcon`; preset = `enabled ? fakeIcon : none`), guarded
  by `SessionController.isSessionActive` (new public getter). `lockTaskMode`
  stays arm-time (it IS session-scoped). Documented in spec 06 §Stealth Mode
  Section. A `ModeOverrides.stealth.fakeIcon` does NOT retarget the launcher
  (device-global, not per-session) — it governs only in-session disguise
  surfaces; that mode-override field is effectively unused for the launcher.
- **(M3 C4) `pm enable` from the adb shell CANNOT toggle another package's
  components** (`SecurityException: Shell cannot change component state … to 1`),
  and `adb root` is refused on the production emulator image (`adbd cannot run as
  root in production builds`). So the alias swap can only be driven from the
  app's OWN UID. The relaunch-after-switch proof therefore runs as an
  integration test (`integration_test/stealth_icon_switch_test.dart`) that calls
  the REAL `RealSystemUiService.setStealthIcon(preset)` in-process for all 10
  presets (a missing alias / dangling icon would throw a PlatformException), and
  leaves the launcher on the `music` disguise. Component-enabled state is
  PERSISTENT in PackageManager (survives the app process), so a shell
  `cmd package resolve-activity -a MAIN -c LAUNCHER <pkg>` AFTER the run observes
  which alias resolves the launcher. NOTE: a fresh `flutter test` reinstall
  RESETS component state to the manifest factory defaults (real launcher on), so
  observe BEFORE re-running.
- **(M3 C4) minSdk 26 ⇒ adaptive launcher icons are XML-only — no raster
  fallback needed.** The app ships plain-PNG `mipmap-*/ic_launcher.png` (no
  pre-existing `mipmap-anydpi-v26/`), but for the disguise presets I used
  `<adaptive-icon>` (`@color/ic_stealth_background` `#131118` + a Material
  Symbols `<foreground>` vector scaled 2.5× and centred on the 108-unit safe
  zone). Sourcing the foregrounds from Material Symbols (e.g. `music_note`,
  `calendar_today`, `fitness_center`, `podcasts`) is the "design-system, not
  bespoke art" route — verify each in the APK with `aapt2 dump resources` (all 9
  mipmaps + 9 fg vectors + the colour compiled). The icons are SEPARATE from the
  flutter_launcher_icons-generated `ic_launcher`; don't regenerate launcher icons
  blindly or you may clobber them.
- **(M3 C4) `StealthIconChannel` enables target-alias FIRST, then disables the
  others** (both `DONT_KILL_APP`) so there is never a zero-launcher-entry window
  (which would make the app momentarily unlaunchable). The factory-default
  manifest state (real `.MainActivityAlias` enabled, all 9 disguises
  `enabled=false`) is the safety net — verified in the merged manifest via
  `aapt2 dump xmltree --file AndroidManifest.xml`. The disguise labels are
  **Android resource strings** (`res/values/strings.xml`
  `stealth_label_<preset>`), NOT Flutter ARB keys — the OS launcher renders them,
  so they're static + English-only (intentionally generic app-category words);
  the 14-ARB l10n-parity rule does not apply to them (zero ARB keys added in C4).
- **(M3 C3) Stealth is now a 5-field carry on `SessionState`:** C1's
  `stealthEnabled`/`timerDisplay`/`sessionScreenStealth` + C3's `fakeName`
  (String, default `'Music'`) + `notificationDisguise` (bool, default `true`) —
  ALL resolved together from ONE `StealthConfig` at `session_controller.dart`
  ≈ :635 and reset on `endSession`. The `notificationDisguise` toggle is
  INDEPENDENT of `sessionScreenStealth`: a session can hide on-screen branding
  yet keep a normal notification (or vice-versa) — both honored. `copyWith`
  defaults them (can't null; fine — non-nullable with defaults).
- **(M3 C3) The Android foreground service is what keeps a backgrounded session
  alive — and C3 is the FIRST thing that ever starts it.** `startService` is
  called from `startSession` (`_startForegroundService`), `stopService` from
  BOTH teardown paths (`endSession` clean-end + `_disposeAll` provider-disposed).
  `configure()` is guarded by `_backgroundConfigured` (once per controller). If
  a future change adds another session-end path, it MUST call
  `_stopForegroundService()` or the persistent notification will outlive the
  session.
- **(M3 C3) The FG-service channel NAME can't be changed per-notification for a
  LIVE channel** — `flutter_local_notifications` uses `AndroidNotificationDetails.
  channelName` only to CREATE the channel; the `session_service` channel is
  pre-created (`'System Service'`) by both `_createAndroidChannels` and
  `flutter_background_service`'s `AndroidConfiguration`. So the disguise that
  genuinely lands per-notification is the **title** (`fakeName`, caller-supplied)
  + the **small-icon** (`ic_stat_stealth`). C3 still sets the generic
  `channelName` in the details (harmless, and the capturing-plugin test asserts
  it) but the channel **id** is always `session_service`. 'System Service' /
  'Reminders' are already non-branded, so the live-channel-name limitation is
  not a privacy leak.
- **(M3 C3) Notification small-icon disguise needs a REAL drawable or the
  notification breaks at runtime.** `AndroidNotificationDetails.icon` is a
  resource NAME (String?); a dangling ref crashes the notification (opposite of
  a safety win). C3 ships ONE neutral vector `ic_stat_stealth.xml` (a generic
  music-note; system tints it monochrome). Verified it compiles into the APK via
  `aapt2 dump resources`. This is the STATUS-BAR icon and is SEPARATE from C4's
  *launcher* fakeIcon (activity-aliases). If C4 ever wants per-preset
  *notification* icons too, extend `_kDisguisedIcon` to a preset→drawable map.
- **(M3 C3) Foreground-service strings reach the notifier via
  `configureWidgetLabels`** (extended with 3 optional FG params) — same
  no-BuildContext pattern as the home-widget labels (HomeScreen calls it in
  `didChangeDependencies`). `fakeName` is DATA (from `StealthConfig`, not
  localisable); only the non-stealth title/body + the neutral disguised subtitle
  are l10n keys.
- **(M3 C3) `fakeName`'s in-player home is the HEADER brand line** (the spec
  mockup's "Spotify / Apple Music" app-name slot, 04:897), NOT the track/artist.
  Spec 06:85 scopes fakeName to the app NAME. C3 wired the header; track/artist
  remain neutral song-metadata placeholders (C5 polish, if wanted at all).
- **(M3 C1) Stealth is now a 3-field carry on `SessionState`:**
  `stealthEnabled` (bool), `timerDisplay` (`StealthTimerDisplay`),
  `sessionScreenStealth` (bool) — all resolved together from ONE
  `StealthConfig` at `session_controller.dart:563` and reset on `endSession`.
  `copyWith` defaults them (it can't null; not an issue — they're non-nullable
  with sensible defaults). The C5 `fakeName`/`notificationDisguise` wiring
  should resolve from the SAME `stealth` local and carry alongside (add fields,
  don't re-read providers in the UI).
- **(M3 C1) Stealth = the WHOLE session body swaps to `FakeMusicPlayer`**
  (`_SessionBody` branches on `state.stealthEnabled`); the standard
  header+step-UI+disarm-slider live in `_StandardSessionBody`. The music
  player binds to the EXISTING `pause()`/`resume()`/`disarm()` — do NOT invent
  session-control semantics; bind new disguises to the real controller too.
- **(M3 C1) `SwipeSlider` single-jump `tester.drag(Offset(2000,0))` FAILS
  inside a `SingleChildScrollView`** (the scroll view wins the gesture arena on
  one big move). Drive it with an **incremental stepped gesture** (40× 20 px
  `moveBy`) on a phone-sized surface (`tester.view.physicalSize`). A real
  horizontal swipe is incremental, so production is unaffected — only the
  one-shot test helper is. The non-stealth `_DisarmAction` slider has no scroll
  view, so its existing `tester.drag` test still works.
- **(M3 C1) Timer normal-mode format is `M:SS`/`H:MM:SS` (non-padded leading
  field)** per spec 04:928 — capital single letter = non-padded, doubled =
  zero-padded. This CHANGED the displayed string from the old `_formatElapsed`
  `MM:SS` (so `00:42`→`0:42`, `01:05`→`1:05`); one test assertion + the `linux/`
  goldens were re-baselined. The CI (font-blind) goldens did NOT change.
- **(M3 C1) G-018 corner-clock fade is `Timer`-based inside the widget**, fed by
  a `Listenable interactionSignal` the host bumps on every pointer-down (a
  `ValueNotifier<int>` in `_SessionBodyState` behind a root `Listener`).
  Testable with `tester.pump(Duration)` (advances the fake clock for in-widget
  timers) — no explicit `fakeAsync()` needed for a `testWidgets` timer.
- **`HardwareButtonDistressTrigger.pressCount` is NON-nullable `int`**
  (default 5) — the doc says it "MUST be null for longPress" but the field
  can't actually be null. So the only representable hardware-trigger
  inconsistencies are: longPress with `durationSeconds == null/≤0`, or
  repeatPress carrying a non-null `durationSeconds` / a `pressCount < 2`
  (UI spinner floors at 2). The save-validator (#13d) checks exactly these.
- **"Chain ≥ 1 step" is structurally unreachable as a save-blocker.**
  `SessionMode`'s constructor `assert(chainSteps.isNotEmpty)` fires under
  `flutter test` (asserts ON — verified empirically), and the editor's
  `_removeStep` no-ops at `length <= 1` + the Delete button is disabled at 1
  step. So an empty chain can't reach `_save()` in debug or via the UI. The
  `chainEmpty` validator rule is kept purely as a release-mode (asserts-off)
  defense and documented; its true-branch is intentionally untestable via a
  real `SessionMode`. If a future cohort flags it as a "dead branch," this is
  the rationale — it's defense-in-depth, not a stub.
- **`validateModeDraft` returns CODES, not strings** (the domain layer is
  Flutter-free). `ValidationResult`/`SessionStartValidator` carry hard-coded
  ENGLISH strings (they're services), but UI save-validation must be localized
  — so #13d's validator emits `ModeValidationCode`s and the screen maps each to
  an l10n key (`_issueMessage`). The `distressNoActionStep` arm in that switch
  is required only for enum exhaustiveness (it's non-blocking, so never passed
  to `_issueMessage` in practice).

- **`ModeOverrides.localTemplates` is LIVE, not legacy.**
  `session_controller.dart:495-500` merges `...?mode.overrides?.localTemplates`
  into the effective reminder-template pool a `disguisedReminder` draws from.
  The #13c-fix cohort flagged a possible "is this legacy?" ambiguity; the
  tripwire was checked and CLEARED — it is consumed at runtime, so the
  `[+ Add Template]` affordance (spec 04:1613) was implemented, not skipped.
- **Mode-local template Add reuses a shared form, NOT the global editor
  screen.** The global `TemplateEditorScreen._save()` is hardwired to upsert
  `isGlobal: true` straight to the DB and `context.pop()` with no return value
  — unusable for a draft-staged, `isGlobal: false`, not-yet-persisted local
  template. Refactored the form body out into a reusable, DB/router-free
  `ReminderTemplateForm` (`lib/features/template_editor/reminder_template_form.dart`,
  exposes `buildTemplate({existing, isGlobal})`). `TemplateEditorScreen` now
  composes it (global path unchanged — its existing tests stay green); the mode
  editor's `_LocalTemplatesEditor` opens it in a `fullscreenDialog`
  `MaterialPageRoute<ReminderTemplate>` and stages the result (`isGlobal: false`,
  `isCustom: true`) into `_draft` via the existing `_modeWithLocalTemplates`
  plumbing — nothing hits the DB until the mode itself is saved.
- **Contact channel field is `channels`** (not `messageChannels` as some spec
  prose says). SMS-capable = `contact.channels.contains(config.channel)`.
- **`allContacts` + non-empty `contactIds` ⇒ treated as SPECIFIC IDs** by the
  resolver (legacy back-compat). So true "all" MUST null `contactIds`.
  `SmsContactConfig.copyWith` (and `ChainStep.copyWith`) CANNOT null a field
  (`x ?? this.x`) — construct the object directly to clear.
- **SMS-target resolution is now ONE shared pure-Dart function**
  (`resolveSmsTargets` in `lib/domain/orchestration/resolve_sms_targets.dart`).
  The runtime `SmsContactStrategy._resolveContacts` AND the save-time
  `validateModeDraft` both delegate to it — they can no longer drift, so the
  recipient set the editor validates always equals the set distress messages
  at runtime. It is Flutter-free (lives in `lib/domain/`, takes a plain
  `List<EmergencyContact>`); the strategy adapts via `services.contacts.all`.
  Edit this ONE function (and its branch test) for any future change to "who
  gets messaged". Branch test: `test/domain/orchestration/resolve_sms_targets_test.dart`.
- **`EventSpecificConfig` is shared** (Mode Editor + Event Defaults). It keeps
  the existing `eventDefaults*` l10n keys (context-neutral). The smsContact
  grid only shows when `contacts != null`.
- **Mode-editor widget-test harness:** override `databaseProvider` (real
  in-memory `GuardianAngelaDatabase.memory`) + `appSettingsRepositoryProvider`
  (`_FakeAppSettingsRepository` returning `const AppSettings()`). Seed
  contacts via `db.contactsDao.upsert(...)`.
- **`flutter gen-l10n` after ARB edits** regenerates `app_localizations*.dart`
  (zh_TW is folded into `app_localizations_zh.dart` as `AppLocalizationsZhTw`).
  This session's regen diffs were additions-only (no blank-line drift). Keep
  them.
- **`copyWith` cannot null applies to `SessionMode.overrides` ITSELF, not just
  inner fields.** `_modeWithOverrides` must DIRECT-CONSTRUCT the SessionMode to
  set `overrides = null` — `mode.copyWith(overrides: _normalised(...))` silently
  KEEPS the stale overrides when `_normalised` returns null (the Inherit-clears
  path). A widget test (`Custom then Inherit clears the override`) caught this
  live; same trap as `distressModeId`. Likewise `ModeOverrides.copyWith` can't
  null an inner field → build `ModeOverrides(...)` directly + a `_normalised`
  helper that returns null when all four override slots are empty (so an
  all-inherit mode persists `overrides = null`, not an empty object).
- **Tri-state ⇄ override mapping:** Inherit = override field null; Custom = a
  config (force `enabled: true` so a previously-Off config flips on); Off =
  config with `enabled: false`. Event-defaults is two-state only (Inherit =
  null / Custom = `const EventDefaults()`).
- **Translation ARB edits must be TEXT-INSERTED, not `json.load`/`json.dump`.**
  Re-serialising reflows the existing collapsed `@`-metadata `placeholders`
  blocks → dozens of spurious deletions (violates additions-only). Insert the
  new `"k": "v",` lines before the file's final `}` and add a trailing comma to
  the prior last entry (the only existing line that changes: `-1 +N+1` per
  file). Placeholder tokens (`{button}`, `{count}`, `{km}`, …) stay inline; no
  `@`-metadata needed in the 13 translation ARBs (only `app_en.arb` carries it).
- **`InfoIconButton` is now localized** (`commonGotIt`) and needs
  `AppLocalizations.of(context)` — it had a hard-coded English "Got it".
- **Dropdown-open in widget tests:** tap the dropdown's CURRENT VALUE text (e.g.
  `safetyOptionsDestinationPrompt`), not the `InputDecorator` label — the label
  doesn't open the menu. Then tap the target item `.last` (overlay copy).

---

## DEFERRED — M4 (carry into the listed chunk / before the M4 push)

- **(C5) C2-cohort test-hardening — tighten the emergency-map count assertion
  to `== 109`.** `test/domain/models/emergency_numbers_test.dart` currently
  guards the literal count loosely; fold a strict `== 109` literal-count check
  into C5 (where the `SCHEDULE_EXACT_ALARM` manifest removal also lands).
- **(orchestrator surfaces before the M4 push) Owner's FINAL pre-push review of
  the C2 emergency map.** The R-8 country→emergency-number map is committed
  locally and awaits the owner's sign-off on the "CHANGES FROM THE REVIEWED
  DRAFT" summary — spot-confirm DE=110, ET=911 (`// VERIFY`), CI=111
  (`// VERIFY`). Do NOT push the M4 stack until the owner confirms.
- **(C3 done — no residual)** #16 is complete: `permission_utils.dart` +
  the start-flow block-on-deny + the DRY refactor of the 2 callers + the
  Active-Triggers-Summary all shipped + gate-green. The live OS
  `POST_NOTIFICATIONS` prompt / deep-link UX is proven only at the host-wiring
  level (no on-device session-driving harness) — a real-device sanity of the
  prompt is M5 device-e2e territory, NOT a stub.
- **(C6 done — residuals, NOT stubs)** F3 (user-supplied fake-call ringtone)
  shipped + gate-green. Residuals: (a) **actual audio OUTPUT of a custom
  ringtone is host-untestable** — the host tests prove the WIRING (path
  round-trips config→draft→DB; playback picks the custom path; missing/undecodable
  → bundled default) and the emulator proves the build LINKS+boots with
  `file_selector`, but hearing the ring is M5 device-e2e. (b) **`file_picker`
  was swapped for `file_selector`** (see the C6 dep decision + KEY FINDING) — if
  the owner wants the literal `file_picker`, it pins to the stale `3.0.4` here
  unless `share_plus`/`device_info_plus`/`win32` are realigned; surface before
  the M4 push. (c) the picker is reachable from the **Mode Editor**
  fakeCall-step config (`EventSpecificConfig` with a non-null `contacts`/editor
  context); the global Event-Defaults context also renders it (a global default
  ringtone is sensible) — both share the one widget, no extra path. (d) the
  fakeCall `callerPhotoPath` / `voiceRecordingPath` fields STILL have no picker
  UI (only `customRingtonePath` got one this chunk) — a sensible future item
  (same `file_selector` pattern), out of C6 scope, NOT a stub.
- **(C7 — NEXT) F4: wire `requireLaunchAuth` / `launchAuthBiometric`.** FIRST
  read the spec to determine what these do BEYOND the existing App-PIN launch
  gate (`launch_pin_screen.dart`); if genuinely identical/redundant, surface
  that to the orchestrator rather than building a duplicate. THEN F5
  (post-session feedback prompt). Both KEEP+BUILD per the M4 DECISIONS block.
- **(orchestrator / doc-sweep, carry) stale `lib/services/*` "Phase X"
  doc-comments + the CLAUDE.md native-files-list tidy.** C2/C5 cleared the
  system-ui/stealth + `service_providers.dart` Phase-7 strings; a broader
  `lib/services/*` doc-comment sweep for any remaining stale "Phase N" prose is
  still open. CLAUDE.md's native-files list names `PhoneChannel.kt` and
  `DeviceStateChannel.kt` which DO NOT EXIST (phone = `url_launcher` `tel:`;
  SIM-number = `DeviceInfoChannel.kt`) — tidy the list. Neither blocks the push.

## DEFERRED — M3 (NOT stubs; carry into the M3 cohort / M4 / M5)

- **(C5 DONE — these residuals carry, NOT stubs)** The music-player
  **track/artist** strings stay neutral localized placeholders (fakeName's home
  is the header brand line, wired in C3; track/artist are song metadata —
  intentional, not a stub). **A `ReminderTemplate.imagePath` image picker** in
  the M2 `ReminderTemplateForm` is a sensible FUTURE item: C5 RENDERS `imagePath`
  if present (the correct contract), but no production path SETS it today (the
  form only sets `iconAsset` category keys; no seed template sets either). An
  image-picker that writes `imagePath` (and/or lets a custom template pick a raw
  asset path for `iconAsset`) would light up the image branch — out of C5 scope,
  not built. (`iconAsset` IS already settable via the form's category dropdown.)
- **(M4 doc-sweep) Wholesale stale-"Phase 7" doc-comment cleanup in
  `service_providers.dart`** — 8+ service-provider handlers still carry
  "registered in Phase 7"-style doc-comments, several of which are now WIRED
  (e.g. the foreground/notification/stealth handlers via M3 C3/C4). C2 fixed
  ONLY the system-ui/stealth comments in scope; the rest is a future doc-sweep
  (no code change, comments only — verify each handler's real registration
  state in `MainActivity.kt` before rewording). Low priority; M4.
- **(C1, revisit) Small-mode corner-clock placement** — the `small` timer fades
  in the top-right corner over the standard chrome; if a full-bleed *stealth
  background* lands (a true blank/disguise canvas behind the music player), the
  corner-clock placement should be revisited so it floats above that background
  per spec 04:929 rather than the current body. Minor; no current visual bug.
- **(C3, revisit) FG-notification live-body-update + unwired bg-service
  streams.** `BackgroundSessionService.updateNotification` has no controller
  subscriber, and nobody subscribes the bg-service `onPause`/`onResume`/
  `onImSafe` streams — so the persistent FG notification text does NOT
  live-update per engine event (start posts it; the action-tap self-updates
  pause/resume text). Wiring a per-event `updateNotification` + the stream
  subscriptions is a larger lifecycle task; the start/stop *survival* gap (the
  C3 mandate) is closed. NOT a stub — the notification is posted + persistent.
- **(C4-cohort, fold into M5 device-e2e) Per-preset launcher-success
  on-device assertion.** The C4 integration test
  (`integration_test/stealth_icon_switch_test.dart`) drives all 10 presets and
  asserts the FINAL state (`music` resolves the launcher + relaunches). It does
  NOT assert success *per preset* mid-loop (a PlatformException would surface,
  but a silent per-preset alias mis-enable wouldn't be caught until the end).
  Harden it in M5 device-e2e to observe alias state after EACH preset, not just
  the last. (KEY FINDING: `pm enable` of the app's component is shell-blocked +
  `adb root` refused on the production image → the swap is only drivable from
  the app's own UID, so the in-process integration-test path is the only proof
  channel; a concurrent `am start` mid-test stalls the binding — observe via
  adb between runs.)

## DEFERRED — M2 polish (NOT stubs; fold into the listed chunk)

- **Spec 06:262 says the alarm ramp range is "0–60 s" but the
  model/controller/`TimingSlider` enforce `[1,60]`** (0 is redundant with
  gradual-OFF) — correct the spec prose `0`→`1`. (Flagged by the #23 cohort;
  spec-doc fix only, no code change.)
- **The `session_controller` AppSettings→EventServices copy-hop (≈618-621) is
  not value-tested;** mitigated by the `loud_alarm_strategy` boundary tests —
  add a dispatch-fake test asserting the recorded `rampSeconds` /
  `alarmDndOverride` in a future #19/session pass (M5 coverage). (Flagged by
  the #23 cohort.)
- **`kMinRepeatPressCount = 2` is a validator-introduced floor with no explicit
  spec line** (04:1589 lists "press count" as a field only) — defensible
  (single press ≈ accidental tap), self-documented; revisit if a future spec
  allows pressCount=1. (Flagged by the #13d cohort.)
- **Mode-local templates support add + remove but NOT in-place edit;** spec
  04:1613 mandates only `[+ Add Template]`, so the current impl is spec-faithful
  — revisit if in-place edit of a staged local template is wanted. (Flagged by
  the #13c re-cohort.)
- **Per-field info-icon buttons + preview cards on `EventSpecificConfig`**
  (fakeCall/smsContact/loudAlarm), spec 04:1538. STILL deferred — #13c added
  info buttons to the Safety-Options SECTIONS (distress/disarm/GPS/stealth/
  templates/event-defaults), not to the individual per-step event-config
  FIELDS inside `EventSpecificConfig`, nor the 3 preview cards. Batch all the
  per-field explanation strings into ONE language-agent run → a #13 polish pass.
- **Localized one-sentence step descriptions.** `step_helpers.stepDescription`
  is still English; `event_defaults_screen` still uses `type.name` titles +
  English descriptions. Localize `stepDescription` (add `chainStepDesc*` keys)
  and switch event_defaults to `stepName(l10n,…)` titles — **update the
  event_defaults test's `_tileName` accordingly.**
- **Mode icon selector** (spec 04:1487). `SessionMode.iconName` is unwired;
  needs a name↔IconData map (tree-shake-safe, no `Icons` reflection).
- **"Reset to defaults" resets config only, not timing** — no per-type
  timing-default source in `EventDefaults`; the spec's "Config Defaults" para
  is config-scoped, so this is defensible. Revisit if a timing-reset is wanted.
- **Per-type collapsed-header summary** ("30s ring, 5s grace"; "To: Alice,
  Bob") — the tile subtitle currently shows the generic `stepTimingSummary`.
- **`blackScreenMode` placement:** lives in the Event-config group
  (inside `EventSpecificConfig`), not Retry & Advanced as spec 04:1539/1561
  lists. Moving it generically needs a `StepConfig.copyWithBlackScreen` or a
  per-type switch — deferred to avoid model surgery. Minor.
- **Grid summary "+N more" truncation** — currently lists all selected names.

---

## DEFERRED — earlier milestones (unchanged from prior handoffs)

- **#11/#12 device E2E → M5** (adb-gsm call; background-throttle). Host tests
  + the real `flutter/lifecycle` platform message are the proof for the wiring.
- **#22 GPS:** `GpsLoggingConfig.accuracy` resolved but not applied
  (protocol has no accuracy param; Real hardcodes high — default is high, so
  no discrepancy). `includeInSms`/`format`/`historyRetentionDays` resolved +
  persisted but unconsumed at runtime → M2 spec-cleanup OR honour at runtime.
- **Background full-screen launch-to-route** (notification full-screen-intent →
  FakeCall/DisguisedReminder when locked) → a notification-deeplink nav pass.
- **#18 polish:** ✅ DONE in M3 C5 (`m3-#15-c5`) — tapWord decoy words localized
  (`sessionReminderDecoyWords` × 14); template `imagePath`/`iconAsset` rendered
  (`_TemplateDisguiseIcon`, render-if-present + Material fallback). No longer
  deferred.
- **iOS `critical_alert.wav`** — RESOLVED this session (#20 sub-part 4): bundled
  from `siren.wav` + wired in `project.pbxproj`; CI `build-ios` is the build
  gate. No longer deferred.
- **`docs/review/remaining-gaps.md`** is a STALE v2-era artifact — do NOT
  action against v3.

---

## Decisions made (all via AskUserQuestion, prior sessions)

1. Approve remediation plan + milestone order; M0 first.
2. Tier-F descope → decide at M4.
3. R-8 emergency-number data → citable public reference + user review (M4).
4. #17 → full-screen auto-appear. 5. #18 fullScreen → pushed route.
6. Verify each milestone (cohort) + push the verified stack before the next.
7. #22 battery-alert DESCOPED → feature removed entirely (GPS-logging-only).

*(M2 spine implementation choices — three-group panel, grid inference,
sharing EventSpecificConfig, the deferred-polish list — were spec-driven, not
user decisions, so they live under "What's done" / "DEFERRED".)*

---

## Hard rules (unchanged — apply every stage)

1. **OLD/ is INERT.** Never read/list/glob/grep/import under `OLD/`.
   `git checkout HEAD -- OLD/` if a tool dirties it.
2. **NO STUBS at GA** (S-1..S-12 in `~/.claude/plans/make-sure-that-there-typed-tulip.md §NO-STUBS`).
3. **NO INVENTED DEFERRALS.** Grep `lib/features/` for `Phase X` before every commit.
4. **DO NOT guess.** `AskUserQuestion` for spec ambiguity / value decisions.
5. **Pre-alpha = break compatibility freely.** Tests follow code.
6. **Verify after EVERY fix.** analyzer + full tests + host widget tests
   driving the REAL controller/engine; emulator for native. Cohort per
   milestone / on `FIX_REQUIRED`.
7. **Write/update HANDOFF.md before the session ends.**
8. **Serial default; parallel only when truly orthogonal.** (Language-agent
   ARB translation is the one safe parallel task.)
9. **Co-Authored-By footer:** `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.
10. **Pure Dart in `lib/domain/`, `lib/services/protocols/`, `lib/data/`.**
11. **lefthook re-stages auto-fixes. NEVER `dart format .` / `import_sorter`
    REPO-WIDE** — scope to changed files. A multi-line `show` flutter import
    oscillates with format — use a bare `import 'package:flutter/x.dart';`.
    After `gen-l10n`, KEEP the regenerated `app_localizations*.dart` when you
    added a key (verify the diff is additions-only).
12. **Pushing to `main` needs explicit user authorization each time.**

---

## Emulator (the verification standard)

```bash
export ANDROID_HOME=/home/jonas/Android/Sdk
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"
adb devices    # an emulator-5554 may still be up from a prior session
# If not booted, cold-boot headless (AVD Pixel_9_Pro / API 36 pre-exists):
emulator -avd Pixel_9_Pro -no-window -no-audio -no-boot-anim \
  -gpu swiftshader_indirect -no-snapshot &
until [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ]; \
  do sleep 3; done; adb shell input keyevent 82
# Run an integration test (wrap in `timeout` — a hung test won't self-kill):
timeout 480 flutter test integration_test/app_boot_smoke_test.dart -d emulator-5554
```
First Gradle build ~30–75 s (incremental is fast). **Don't** pipe a long
backgrounded `flutter test` through `| tail` (buffers → no output until exit);
redirect to a file with `>` instead.

---

## Quick verification commands

```bash
flutter analyze --fatal-infos                                   # 0 issues
flutter test --concurrency=6                                    # 3895 pass (M4 C1)
dart format <changed .dart files>                              # changed files only
grep -rnE "(Phase 8|Phase 9|Phase 10|Phase 11)" lib/features/  # 0
git status --porcelain -- OLD/                                  # empty
flutter gen-l10n                                                # after any ARB change
# l10n parity spot-check (each new key in all 14 ARBs):
for k in <newKey>; do echo "$k: $(grep -l "\"$k\"" lib/l10n/l10n/app_*.arb | wc -l)/14"; done
```
lefthook pre-commit runs `dart format` + `import_sorter` (re-stages);
pre-push runs `flutter analyze --fatal-infos` + `flutter test`.

---

## The plan + task journal

- **Plan doc:** `docs/rewrite/ga-wiring-remediation.md` (gap inventory §2 =
  tasks #8–#23, method §3, milestones M0–M5 §4).
- **Milestones:** **M0 ✓ pushed. M1 ✓ pushed. M2 ✓ pushed. M3 (#15 stealth) ✓
  pushed (`origin/main` = `5ab69c6`).** **M4 STARTED — C1 (#9 biometric) ✓
  DONE (UNPUSHED, `m4-#9`); C2 (#10 R-8 emergency map + `phone_validators` +
  locale seeding + the `home_controller` `'112'` fix) ✓ DONE+GATE-GREEN+
  COMMITTED (UNPUSHED, `m4-#10`) — the map awaits the owner's FINAL pre-push
  review.** **NEXT = M4 C3 — #16 notification re-ask + Active-Triggers-Summary +
  the shared `permission_utils.dart`.** Remaining M4 chunks
  (carry the M4 DECISIONS block near the top): #16 (C3, next), #8 (minimal
  in-progress-marker resume modal), Tier-F (F1 descope / **F2 DESCOPE — DECIDED;
  remove `SCHEDULE_EXACT_ALARM` in C5** / F3 user-supplied ringtones / F4
  launch-auth + redundancy check / F5 feedback prompt), and the
  `service_providers.dart` Phase-7 doc-sweep. Then M5 (Phase-9:
  INT scenarios, device e2e incl. #11 adb-gsm + #12 background-throttle,
  spec-coverage matrix, coverage floor). The in-memory TaskList is cleared on
  `/clear` — this bullet is the durable journal.

---

## End-of-session ritual (every session)

1. **Update HANDOFF.md** — snapshot, what changed, decisions, next action.
2. **Commit HANDOFF.md** (`…-handoff: …` + Co-Authored-By footer).
3. **Tell the user the resume prompt** exactly: `Continue from HANDOFF.md`.

Don't skip it because "the session went short."

---

End of hand-off. M0+M1 verified+pushed; **M2 config-UI IMPLEMENTATION COMPLETE**
— #13a + #13b (per-step config) + #14 (SMS contact grid) + #13c (Safety
Options) + #13d (save-validation) + #23 (alarm settings) + #20 (all 4
sub-parts: channel validation, SMS template editor, iOS warnings, iOS
`critical_alert.wav` bundle) committed, UNPUSHED. Resume by **running the M2
verifier cohort → full gate → push the M2 stack (user pre-authorized).**
