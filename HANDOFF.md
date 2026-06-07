# Guardian Angela v3 — Session Hand-off

**Snapshot:** 2026-06-07 — **M0 COMPLETE+VERIFIED+PUSHED. M1 COMPLETE +
VERIFIED (cohort PASS); #11 ✓ + #22 ✓ PUSHED; #12 ✓ done, UNPUSHED —
push pending authorization.**

Everything through the prior handoff (`9f11ef8`) is on `origin/main`. **Two
commits are UNPUSHED, awaiting push authorization:** the #12 commit
(`2d968b4`) and this handoff commit (`HEAD`). Tree clean. **Tests: 3702
pass** (+8: #12 clamp host tests). Analyzer `--fatal-infos` clean. l10n
parity unchanged (no new strings). app_boot_smoke green on emulator.
Branch: `main`.

**M1 is complete AND verified — the M1 cohort (architect-reviewer
spec-vs-code + qa-expert spec-vs-tests, both `opus`) returned PASS, high
confidence, both reviewers; every M1 test would fail if its wiring were
removed. Next: push the 2-commit M1 stack (awaiting user authorization),
then start M2.** Cohort nits are recorded under DEFERRED — none block the
push. See "How to resume."

---

## How to resume

After `/clear`, paste:

> Continue from HANDOFF.md

**Recommended first action: push the M1 stack, then M2.** Two sub-steps:

1. **M1 is already verified (cohort PASS, 2026-06-07).** Both reviewers
   PASS, high confidence; each M1 test fails if its wiring is removed. If the
   stack is not yet pushed, **ask the user to push** `2d968b4` (#12) + the
   handoff commit (rule 12) before M2. Cohort nits are under DEFERRED; none
   block the push.

2. **M2 — Configuration UIs** (the big build). Entry point **#13**:
   mode-editor per-step config — `StepConfigPanel` / `EventSpecificConfig`
   is the spine, and it's where the `disguisedReminder` `templateIds` field
   (added in M0 #18) gets its editor. Then #14 (SMS contact grid), #23
   (alarm settings), #20 (channel-validation-on-save + SMS template editor +
   iOS warnings + the missing iOS `critical_alert.wav`). **Verify each gap
   yourself first** — M2 is UI, so the proof is widget tests + the emulator,
   not just host controller tests.

**Per-fix recipe:** verify the gap yourself → implement (serial) → prove
(host/widget tests driving the REAL controller+engine; emulator for native)
→ l10n deltas if any new user-facing string (spawn the language agent for
the 13 non-English locales) → gate suite → commit → **ask before pushing**.

---

## What's done (M0/M0-verify/#11/#22 PUSHED; #12 UNPUSHED)

**M0 — core escalation actually works** (4/4): `#21` audio assets (real
WAV siren/ring/countdown + CI asset gate + fixed a looping-source `play()`
hang). `#17` fakeCall answer/hang-up/decline wired to engine + full-screen
auto-appear. `#19` loudAlarm gradual-volume + DND-override gating (default
was inverted). `#18` disguisedReminder template selection + 4 confirmation
types + `earlyCheckIn` + full-screen route + the `templateIds` config field.
**M0-verify** (`6740ed3`): architect-reviewer PASS; qa-expert FIX_REQUIRED
on test *strength* (code was correct) — disarm tests now assert via the
engine stream + `EnginePhase`, added earpiece / `earlyCheckIn(reset=false)`
/ nonce auto-PUSH widget tests.

**M1 — Safety subsystems live** (SessionController lifecycle wiring) —
**COMPLETE**:

- **`#11`** (`79dea7b`, pushed): real incoming-call detection. A real call
  `pause(incomingCall)`s the engine (must pause even on a fakeCall step —
  `retryCount=0` would otherwise time out mid-call); non-fakeCall resumes on
  call-end; a fakeCall is cancelled (ring stopped + `fakeCallCancelNonce` →
  `FakeCallScreen` pops) and auto-disarms on call-end. `SessionState.pauseReason`
  → "Paused — incoming call" badge (14 locales). A user-requested pause is
  never clobbered (`_pausedByRealCall`). 9 host tests.
- **`#22`** (`a379738`, pushed): GPS logging wired in `startSession` (real
  sessions, when resolved `GpsLoggingConfig.enabled`); torn down via
  `_teardownGpsLogging()` from both dispose paths. Before this, `startTracking`
  had no caller, so `{location}` placeholders resolved to "Location
  unavailable". **Battery-alert feature REMOVED entirely** (user decision —
  out of scope): service+config+screen+route+widget-status+`battery_plus`
  dep + specs + 14 ARB locales + tests. Kept (different features): the
  "Battery Warning" disguised-reminder template/icon, battery-optimization
  whitelist warnings, 08's "ignore battery" note. 4 host tests.
- **`#12`** (`2d968b4`, **UNPUSHED**): background speed-clamp lifecycle
  (G-013) — the last M1 gap. Before this, `SessionEngine.setBackgroundClamp`
  had no caller, so the 60× effective-speed cap never engaged; a fast
  simulation pushed to the background could desync against OS-throttled
  timers. `SessionController` now mixes in `WidgetsBindingObserver`:
  `startSession` registers it with `WidgetsBinding` (unconditionally — a
  runtime no-op for real wall-clock sessions, so teardown stays symmetric);
  `didChangeAppLifecycleState` maps `paused`/`hidden` → `setBackgroundClamp(true)`,
  `resumed` → `(false)`, `inactive`/`detached` → no-op (exhaustive switch →
  a future `AppLifecycleState` is a compile error);
  `_teardownLifecycleObserver` removes it from BOTH dispose paths
  (`_disposeRunOnly` + `_disposeAll`), idempotent via a registered-guard.
  **Followed the canonical spec (01:700-712): `paused`/`hidden`, NOT the old
  handoff note's "inactive"** — `hidden` is the proper backgrounded
  precursor; `inactive` is a transient, still-visible state (app switcher)
  that must not clamp. 8 host tests (`session_controller_clamp_test.dart`)
  drive the REAL controller+engine: direct `didChangeAppLifecycleState`
  mapping for all 5 states, the 60× `effectiveSpeedMultiplier` cap,
  post-`endSession` no-op, **plus a real `flutter/lifecycle` platform
  message** proving the observer is actually registered with `WidgetsBinding`
  and re-registers for a 2nd session. `startSession` now needs an initialised
  binding → added `TestWidgetsFlutterBinding.ensureInitialized()` to the
  gps/dispatch/distress controller tests.

---

## Discovered / DEFERRED (note for the right milestone)

- **#12 clamp device-E2E → M5.** Actually backgrounding the app and
  observing timer-throttle behaviour is a device integration test, like
  #11's `adb emu gsm call`. The host tests (incl. the real `flutter/lifecycle`
  platform message) are the proof for the pure wiring; a true
  background-throttle E2E belongs in M5 "device e2e flows."
- **import_sorter + multi-line `show` flutter imports DON'T MIX (tooling
  gotcha, hit during #12).** A wrapped
  `import 'package:flutter/widgets.dart' show A, B, C;` gets misplaced by
  `import_sorter` (dumped in the bottom group) AND oscillates with
  `dart format` on blank lines — and the pre-commit hook runs format THEN
  import_sorter, so the commit lands format-dirty (CI `format` job would
  fail). **Fix: use a BARE `import 'package:flutter/foo.dart';`** (its own
  top group, like every other file) — it's a fixed point of both tools. A
  bare flutter import can make a separate `package:meta/meta.dart` import
  redundant (flutter re-exports `@immutable`/`@visibleForTesting`) → remove
  it (analyzer flags `unnecessary_import`).
- **#11 device E2E → M5.** A real `adb emu gsm call` end-to-end needs
  `READ_PHONE_STATE` + host/test timing orchestration → M5, not a flaky
  per-fix test. The native `CallStateChannel` input is contract-tested in
  `call_state_service_test.dart`.
- **Background full-screen launch-to-route.** Notification
  full-screen-intent → FakeCallScreen / DisguisedReminderScreen when the
  device is locked. #17/#18 do *foreground* auto-appear only. Also covers
  confirmation-type-specific notification text + tap-to-check-in deeplink
  (spec 02:121-125). → a notification-deeplink nav pass.
- **#18 polish (cosmetic):** tapWord decoy words are a fixed English-ish set
  (`reminder_word_choices.dart`), not localized; the disguise icon is a
  neutral Material icon (template `iconAsset`/`imagePath` not rendered). →
  fold near #15.
- **iOS `critical_alert.wav`** referenced in `notification_service.dart` but
  missing from the iOS bundle → iOS alarm notification falls back to the
  default critical-alert sound. → fold into #20 (M2). Core loud alarm is the
  `AudioService` siren (real), not the notification sound.
- **GPS accuracy not plumbed (#22 refinement).** `GpsLoggingConfig.accuracy`
  is resolved at `startSession` but not applied — `LocationServiceProtocol.startTracking({Duration interval})`
  has no accuracy param and `RealLocationService` hardcodes
  `LocationAccuracy.high`. Default config is `high`, so no discrepancy for
  the default; only a mode overriding accuracy to balanced/low is unhonoured.
  → extend protocol + Real impl + sim if/when a non-high accuracy is wanted.
- **#22 `GpsLoggingConfig` fields unconsumed (M1 cohort finding,
  important).** `includeInSms`, `format` (decimal/dms/address) and
  `historyRetentionDays` are resolved + persisted (the settings screen reads
  them) but never consumed at runtime: SMS location is gated *solely* by the
  per-step `SmsContactConfig.includeLocation` (so global `includeInSms` is a
  no-op), coordinates always render decimal, and history retention is
  unenforced. Pre-existing, outside #22's breadcrumb→`{location}` scope
  (which the cohort confirmed correct). → M2 / spec-cleanup: honour them at
  runtime OR drop them from spec+model.
- **M1 cohort nits (optional polish, non-blocking).** (a) #11 treats
  `CallState.offhook` as active, so an *outgoing* call also pauses the
  session — a safe superset (prevents false escalation during any call); add
  a one-line clarifying comment. (b) #11 pause/resume tests drive a
  disguisedReminder wait-phase step, not a `holdButton` step (Extra-30/31's
  headline) — the pause path is type-agnostic so coverage is real; an
  explicit holdButton case would mirror the spec verbatim. (c) #22 doesn't
  assert the configured interval is forwarded to `startTracking` (the sim
  ignores it). (d) **#12 `removeObserver` detachment is NOT behaviorally
  testable** — post-`endSession` `_engine` is null, so a *leaked* observer's
  `_engine?.setBackgroundClamp` is a no-op indistinguishable from a *removed*
  one. Do NOT add a "post-end lifecycle message" test for it (it would be
  trivially green — the exact anti-pattern the cohort guards against); the
  cross-session re-register test + the `_lifecycleObserverRegistered`
  idempotency guard are the real coverage.
- **`docs/review/remaining-gaps.md`** is a STALE v2-era artifact
  (2026-04-10; references `lib/services/implementations/…` absent in v3).
  GAP-66/67 there describe v2 audio — do NOT action against v3.

---

## Decisions made (all via AskUserQuestion)

1. Approve the remediation plan + milestone order; M0 first.
2. Tier-F descope → decide at M4 (deferred; do not cut yet).
3. R-8 emergency-number data → source from a citable public reference
   (ITU/Wikipedia) + flag for user review (an M4 item).
4. #17 → include full-screen auto-appear (not just the 3 buttons).
5. #18 fullScreen display style → pushed full-screen route
   (`DisguisedReminderScreen`); `subtle` stays an inline card.
6. Verify M0 (run the cohort) before M1; push the verified stack before
   continuing. **(Same gate now applies at the M1→M2 boundary: verify M1,
   then push, before M2.)**
7. **#22 battery-alert half DESCOPED → feature removed entirely** (user:
   "a low battery is beyond the scope of this app… remove it from specs as
   well"). #22 is now GPS-logging-only.

*(Note: #12's `paused`/`hidden` vs the old note's "inactive" was a
spec-driven implementation choice — spec 01 is canonical — not a user
decision, so it is recorded under "What's done", not here.)*

---

## Hard rules (unchanged — apply every stage)

1. **OLD/ is INERT.** Never read/list/glob/grep/import under `OLD/`.
   `git checkout HEAD -- OLD/` if a tool dirties it.
2. **NO STUBS at GA** (S-1..S-12 in `~/.claude/plans/make-sure-that-there-typed-tulip.md §NO-STUBS`). The wiring gaps are exactly what these prevent.
3. **NO INVENTED DEFERRALS.** Grep `lib/features/` for `Phase X` before every commit.
4. **DO NOT guess.** `AskUserQuestion` for spec ambiguity / value decisions.
5. **Pre-alpha = break compatibility freely.** Tests follow code; update tests that encoded a bug.
6. **Verify after EVERY fix.** analyzer + full tests + host controller/widget tests driving the REAL controller+engine (the proof for pure wiring); emulator for native playback. Re-engage the verifier cohort per milestone / on `FIX_REQUIRED`.
7. **Write/update HANDOFF.md before the session ends.**
8. **Serial default; parallel only when truly orthogonal.** Connected fixes stay serial.
9. **Co-Authored-By footer:** `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.
10. **Pure Dart in `lib/domain/`, `lib/services/protocols/`, `lib/data/`.**
11. **lefthook re-stages auto-fixes. NEVER `dart format .` / `import_sorter` REPO-WIDE** — scope to changed files. import_sorter strips inline import comments (don't rely on them). **A multi-line `show` flutter import oscillates with format + gets misplaced — use a bare `import 'package:flutter/x.dart';` (see DEFERRED).** A build run regenerates `lib/l10n/l10n/app_localizations*.dart` with blank-line drift → `git checkout -- lib/l10n/l10n/` to discard *only when no l10n source changed*; when you added a key, keep the regenerated files (verify the diff is just the new getter).
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
First Gradle build ~30–75 s (incremental is fast — APK cached). **Gotcha:**
Gradle can transiently fail to fetch `androidx.test.espresso` metadata —
cached, so a retry succeeds. **Don't** pipe a long backgrounded
`flutter test` through `| tail` (tail buffers → no output until exit).

---

## Quick verification commands

```bash
flutter analyze --fatal-infos                                   # 0 issues
flutter test --concurrency=6                                    # 3702 pass
dart format <changed .dart files>                              # scope to changed files only
grep -rnE "(Phase 8|Phase 9|Phase 10|Phase 11)" lib/features/  # 0
git status --porcelain -- OLD/                                  # empty
flutter gen-l10n                                                # after any ARB change
# asset-existence gate (CI job `assets-exist`):
for r in $(grep -rhoE "assets/[A-Za-z0-9_/.-]+\.[A-Za-z0-9]+" lib/ | sort -u); do [ -f "$r" ] || echo "MISSING $r"; done
```
lefthook pre-commit runs `dart format` + `import_sorter` and re-stages;
pre-push runs `flutter analyze --fatal-infos` + `flutter test`.

---

## The plan + task journal

- **Plan doc:** `docs/rewrite/ga-wiring-remediation.md` (gap inventory §2 =
  tasks #8–#23, method §3, milestones M0–M5 §4). #12 row marked wired.
- **Milestones:** **M0 ✓ (verified, pushed). M1 ✓ COMPLETE** — #11 ✓ +
  #22 ✓ pushed, **#12 ✓ done (UNPUSHED)**. Next: **verify M1 (cohort) →
  push → M2** (config UIs #13/#14/#23/#20 — #13's `StepConfigPanel` is where
  the new `templateIds` field gets its editor), then M3 (#15 stealth), M4
  (#10/#9/#8/#16 + Tier-F decisions), M5 (Phase-9 proper: INT scenarios,
  device e2e incl. #11 adb-gsm + #12 background-throttle, spec-coverage
  matrix, coverage floor). The in-memory TaskList is cleared on `/clear` —
  this bullet is the durable journal.

---

## End-of-session ritual (every session)

1. **Update HANDOFF.md** — snapshot, what changed, decisions, next action.
2. **Commit HANDOFF.md** (`…-handoff: …` + Co-Authored-By footer).
3. **Tell the user the resume prompt** exactly: `Continue from HANDOFF.md`.

Don't skip it because "the session went short."

---

End of hand-off. M0 verified + pushed; **M1 COMPLETE + VERIFIED (cohort
PASS)** — #11 + #22 pushed, #12 done (background clamp wired) UNPUSHED.
Resume by **pushing the M1 stack (awaiting auth) → starting M2 (#13
mode-editor config)**.
