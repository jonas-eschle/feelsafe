# Guardian Angela v3 — Session Hand-off

**Snapshot:** 2026-06-07 — **M0 COMPLETE+VERIFIED+PUSHED. M1 in progress
(2/3: #11 done+pushed; #22 done, UNPUSHED).**

**M0 + M0-verify + #11 are PUSHED to `origin/main` (`cbe27a4`).** **Two
commits are UNPUSHED** — the #22 commit at `HEAD` (folds in this handoff
update) and the prior session's `4f09cc1` handoff commit — awaiting user
authorization to push. Tree clean. **Tests: 3694 pass** (−115: battery-alert
feature removed).
Analyzer `--fatal-infos` clean. l10n parity 556×14. app_boot_smoke green.
Branch: `main`.

**Next action: M1 #12** (background clamp) — the last M1 item. See "How to
resume."

---

## How to resume

After `/clear`, paste:

> Continue from HANDOFF.md

**First action: #12 — background speed-clamp lifecycle** (🟡 sim-only).
Audit: `SessionEngine.setBackgroundClamp` is never called, so G-013's
background timer clamp (cap effective speed at 60× when the app is
backgrounded) never engages. Spec **01:700-703**. This is **SessionController
lifecycle wiring** driven by an app-lifecycle observer
(`WidgetsBindingObserver.didChangeAppLifecycleState`): clamp on
`paused`/`inactive`, release on `resumed`. The engine method already exists
(`session_engine.dart` `setBackgroundClamp`, `effectiveSpeedMultiplier`,
`isBackgroundClamped`) — only the caller is missing.

**The #11/#22 wiring is your template** (`lib/features/session/session_controller.dart`):
work started in `startSession` and torn down via a `_teardown…()` helper
called from BOTH dispose paths (`_disposeRunOnly` + `_disposeAll`). When you
wire a new service into `startSession`, **add its sim-provider override to
every session-running test container** — grep for containers overriding
`phoneServiceProvider`/`locationServiceProvider` that lack the new provider,
or they'll hit the real platform-channel service and fail. (For #12 the
lifecycle observer is host-testable directly.)

**Per-fix recipe:** verify the gap yourself first → implement (serial) →
prove with host controller/widget tests that drive the **real**
controller+engine (that is the proof for pure wiring — see rule 6) → l10n
deltas if any new user-facing string (spawn the language agent for the 13
non-English locales) → gate suite → commit → **ask before pushing**.

**M1 remaining:** just **#12 background clamp** — then M1 is complete.

---

## What's done (M0/M0-verify/#11 PUSHED; #22 UNPUSHED)

**M0 — core escalation actually works** (4/4):
- `#21` audio assets — real WAV siren/ring/countdown + CI asset-exist gate
  + fixed a latent `play()` fire-and-forget hang on looping sources.
- `#17` fakeCall — answer/hang-up/decline wired to the engine + full-screen
  auto-appear via `fakeCallShowNonce`.
- `#19` loudAlarm — gradual-volume (needs BOTH global + per-step) +
  DND-override gating from settings (default was inverted).
- `#18` disguisedReminder — template selection + 4 confirmation types +
  `earlyCheckIn` + full-screen `DisguisedReminderScreen` route + the
  `templateIds` config field.

**M0-verify** (`6740ed3`): the deferred verifier cohort ran —
architect-reviewer (spec-vs-code) **PASS**, qa-expert (spec-vs-tests)
**FIX_REQUIRED** on test *strength* (code was correct). The single-step
`_fakeCallMode` made the disarm tests' `currentStepIndex==0` trivially
green; now they assert `ChainEvent.userDisarmed` via the engine stream and
`EnginePhase.grace` for decline-unsafe. Added earpiece (useSpeaker:false),
`earlyCheckIn(reset=false)`, and nonce auto-PUSH widget tests.

**M1 `#11`** (`79dea7b`): real incoming-call detection. A real call now
`pause(incomingCall)`s the engine (must pause even on a fakeCall step —
`retryCount=0` (B3) means it would otherwise time out and escalate to the
next step mid-call); non-fakeCall resumes on call-end (A2 / holdButton
Extra-30/31); a fakeCall is cancelled (ring stopped + `fakeCallCancelNonce`
→ `FakeCallScreen` pops itself) and auto-disarms on call-end (Extra-24/25).
New `SessionState.pauseReason` → "Paused — incoming call" badge (14
locales) and `SessionState.fakeCallCancelNonce`. Edge: a user-requested
pause is never clobbered (`_pausedByRealCall`). 9 host tests drive the real
controller+engine; app_boot_smoke green on emulator.

**M1 `#22`** (UNPUSHED): two parts.
- **GPS logging wired (the GA-blocker that stays).** `SessionController`
  now starts `LocationService` breadcrumb tracking in `startSession` (real
  sessions only, when the resolved `GpsLoggingConfig.enabled`;
  `mode.overrides?.gpsLogging ?? settings.defaults.gpsLogging`) and tears it
  down via `_teardownGpsLogging()` (stop + `clearHistory`) from BOTH dispose
  paths. **Impact:** before this, `startTracking` had no caller, so
  `_history` was always empty and every `smsContact`/`callEmergency`
  `{location}` placeholder resolved to "Location unavailable"
  (strategies read `getLastLocationUrl()` ← history). Honours the configured
  interval; accuracy stays at the service default (high) — protocol's
  `startTracking({Duration interval})` can't carry accuracy (deferred
  refinement). 4 host tests drive the real controller+engine
  (`session_controller_gps_test.dart`).
- **Battery-alert feature REMOVED entirely** (user decision via
  AskUserQuestion: "a low battery is beyond the scope of this app").
  Deleted `BatteryMonitorService` (+sim+protocol), `BatteryAlertConfig`
  (+repo+seed default), `BatteryAlertController` + `/settings/battery-alert`
  screen+route+settings row, the home-widget `batteryAlert` status,
  `notifyBatteryAlert()`, the backup field, the `battery_plus` dependency,
  and all battery-alert tests. Stripped from canonical specs
  (00,01,02,03,04,05,06,08,09,10 + the pre-session low-battery warning in 01),
  the remediation plan #22, `wiring-map.md`, the feature-coverage matrix, and
  all 14 ARB locales. **Kept** (different features): the "Battery Warning"
  disguised-reminder template + battery disguise icon; "battery optimization"
  whitelist warnings; 08's "Low Battery → no power-saving" note (documents we
  ignore battery). `settings_screen_test` got a tall-viewport helper so
  bottom rows stay tappable after the tile removal shifted the list.

---

## Discovered / DEFERRED (note for the right milestone)

- **#11 device E2E → M5.** A real `adb emu gsm call` end-to-end. #11 is
  pure wiring, so host tests (real controller+engine) are the proof and the
  native `CallStateChannel` input is contract-tested in
  `call_state_service_test.dart`. A gsm test needs `READ_PHONE_STATE`
  granted + host/test timing orchestration → belongs in M5 "device e2e
  flows," not a flaky per-fix test.
- **Background full-screen launch-to-route.** Notification
  full-screen-intent → FakeCallScreen / DisguisedReminderScreen when the
  device is locked. #17/#18 do *foreground* auto-appear only; the
  backgrounded path relies on the notification. Also covers the
  confirmation-type-specific notification text + tap-to-check-in deeplink
  (spec 02:121-125). → a notification-deeplink nav pass.
- **#18 polish (cosmetic):** tapWord decoy words are a fixed English-ish
  set (`reminder_word_choices.dart`), not localized; the disguise icon is a
  neutral Material icon (template `iconAsset`/`imagePath` not rendered). →
  fold near #15.
- **iOS `critical_alert.wav`** is referenced in `notification_service.dart`
  but missing from the iOS bundle → iOS alarm notification falls back to
  the default critical-alert sound. → fold into #20 (M2). The core loud
  alarm is the `AudioService` siren (real), not the notification sound.
- **`docs/review/remaining-gaps.md`** is a STALE v2-era artifact
  (2026-04-10; references `lib/services/implementations/…` paths absent in
  v3). GAP-66/67 there describe v2 audio — do NOT action against v3.

---

## Decisions made (all via AskUserQuestion)

1. Approve the remediation plan + milestone order; M0 first.
2. Tier-F descope → decide at M4 (deferred; do not cut yet).
3. R-8 emergency-number data → source from a citable public reference
   (ITU/Wikipedia) + flag for user review (an M4 item).
4. #17 → include full-screen auto-appear (not just the 3 buttons).
5. #18 fullScreen display style → pushed full-screen route
   (`DisguisedReminderScreen`); `subtle` stays an inline card.
6. Verify M0 (run the cohort) before M1; push the verified M0 + #11 stack
   before continuing to #22.
7. **#22 battery-alert half DESCOPED → feature removed entirely** (not just
   the firing). User: "a low battery is beyond the scope of this app… remove
   it from specs as well." Confirmed full-footprint removal (code + specs +
   l10n + tests + `battery_plus` dep) vs. the narrow "drop the banner" read.
   #22 is now GPS-logging-only. If the user later wants the "Battery Warning"
   disguise template/icon gone too, that's a trivial follow-up (kept for now
   — it's a disguisedReminder option, not a battery feature).

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
11. **lefthook re-stages auto-fixes. NEVER `dart format .` / `import_sorter` REPO-WIDE** — scope to changed files. import_sorter strips inline import comments (don't rely on them). A build run regenerates `lib/l10n/l10n/app_localizations*.dart` with blank-line drift → `git checkout -- lib/l10n/l10n/` to discard *only when no l10n source changed*; when you added a key, keep the regenerated files (verify the diff is just the new getter).
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
flutter test --concurrency=6                                    # 3694 pass
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
  tasks #8–#23, method §3, milestones M0–M5 §4).
- **Milestones:** **M0 ✓ (verified, pushed). M1: #11 ✓ (pushed), #22 ✓
  (GPS wired; battery-alert removed — UNPUSHED)** — remaining **#12 clamp**,
  then M1 complete. Then M2 (config UIs #13/#14/#23/#20 — #13's
  `StepConfigPanel` is where the new `templateIds` field gets its editor),
  M3 (#15 stealth), M4 (#10/#9/#8/#16 + Tier-F decisions), M5 (Phase-9
  proper: INT scenarios, **device e2e incl. #11 adb-gsm**, spec-coverage
  matrix, coverage floor). The in-memory TaskList is cleared on `/clear` —
  this bullet is the durable journal.

---

## End-of-session ritual (every session)

1. **Update HANDOFF.md** — snapshot, what changed, decisions, next action.
2. **Commit HANDOFF.md** (`…-handoff: …` + Co-Authored-By footer).
3. **Tell the user the resume prompt** exactly: `Continue from HANDOFF.md`.

Don't skip it because "the session went short."

---

End of hand-off. M0 is verified + pushed; M1 #11 is done + pushed. Resume
with **#22** (GPS logging + battery-alert firing), then #12.
