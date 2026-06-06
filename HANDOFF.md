# Guardian Angela v3 — Session Hand-off

**Snapshot:** 2026-06-06 — **M0 COMPLETE + VERIFIED. M1 in progress (1/3:
#11 done).** All committed, UNPUSHED.

**HEAD:** `79dea7b` (#11) → **9 commits ahead of `origin/main`, all
UNPUSHED**. **Tests: 3809 pass** (M0 baseline 3795 → +5 m0-verify → 3800
→ +9 #11 → 3809). **Analyzer:** `--fatal-infos` clean. **Tree:** clean.
**Branch:** `main`. **Push needs your explicit authorization** (rule 12).

This session:
- **M0 verifier cohort ran** (was deferred). architect-reviewer
  (spec-vs-code) = **PASS** all 4 M0 fixes; qa-expert (spec-vs-tests) =
  **FIX_REQUIRED** (test strength only — code was correct). Closed the
  real gaps in **`6740ed3` (m0-verify)**: the single-step `_fakeCallMode`
  made the decline/hang-up tests' `currentStepIndex==0` trivially true
  (didn't prove disarm) → now assert `ChainEvent.userDisarmed` via the
  engine stream; decline-unsafe asserts `EnginePhase.grace` (miss, not
  disarm); added earpiece + earlyCheckIn(reset=false) + nonce auto-PUSH
  widget tests.
- **M1 #11 done** — `79dea7b`. See the shipped table.

**The big lesson held again:** "green means works." Verifying M0 myself
(not trusting the audit) found the disarm tests were trivially green, and
building #11 surfaced that a real call must **pause** the engine even on a
fakeCall step — fakeCall defaults to `retryCount=0` (B3), so without the
pause it times out mid-call and **escalates to the next step** during the
real call.

---

## How to resume

After `/clear`, paste:

> Continue from HANDOFF.md

**First action: continue M1 with #22** (GPS logging start/stop +
battery-alert firing — spec 06:208-233,549-569). Then **#12 background
clamp** (fold in — `setBackgroundClamp`, spec 01:700-703, sim-only/🟡).
M0 is verified + #11 is done. The 9 commits can be pushed once you
authorize.

**M1 status:** #11 ✓ (`79dea7b`). Remaining: **#22**, **#12**. All
SessionController lifecycle wiring; keep them serial. **Verify each gap
yourself first** — every audit one-liner so far undersold the work (#11
"unwired callStateServiceProvider" was: pause/resume A2 + holdButton
Extra-30/31 + fakeCall cancel Extra-24/25 + a `pauseReason` field + a
`fakeCallCancelNonce` dismissal signal + a localized badge + the
user-pause-not-clobbered edge).

**Deferred to M5 (device e2e):** a real `adb emu gsm call` device E2E for
#11. Per the recipe, #11 is *pure wiring* → host tests (real
controller+engine) are the proof; the native `CallStateChannel` input is
contract-tested in `call_state_service_test.dart`. A true gsm test needs
`READ_PHONE_STATE` granted + host/test timing orchestration → belongs in
M5's "device e2e flows" pass, not a flaky per-fix test.

**Per-fix recipe (unchanged):** verify gap yourself → implement (serial)
→ prove with an emulator integration test (host widget/controller tests
for pure wiring; emulator for native playback) → l10n deltas (spawn the
language agent if you add user-facing strings) → gate suite → commit.
Re-engage the verifier cohort on `FIX_REQUIRED`.

---

## What shipped THIS SESSION (M0-verify + M1 #11)

| Commit | Fix | What it really was |
|---|---|---|
| `79dea7b` | **#11 real incoming-call detection** (M1, 1/3) | `callStateServiceProvider` had no consumer. SessionController now subscribes for the session lifetime (non-sim). (1) Real call **always pauses** the engine first (prevents escalation during the call — fakeCall has `retryCount=0` so it would otherwise advance mid-call). (2) Non-fakeCall → `pause(incomingCall)` + resume on idle (A2 / holdButton Extra-30/31). (3) fakeCall → stop ring + dismiss screen (new `SessionState.fakeCallCancelNonce` → `FakeCallScreen` pops itself) + auto-disarm (resume+disarm) on call end (Extra-24/25). (4) New `SessionState.pauseReason` → localized **"Paused — incoming call"** badge (14 locales). (5) Edges: user-pause not clobbered (`_pausedByRealCall`); ringing→offhook no double-fire; teardown in both dispose paths. 9 host tests (6 controller dispatch + FakeCallScreen dismissal + 2 badge). Fixed 3 session-running test containers that lacked the `callStateServiceProvider` sim override (dispatch/distress/home-widget). `FakeCallScreen` dismiss uses the cancel nonce, NOT engine phase (Pivot-2 keeps fakeCall in `duration` while answered). |
| `6740ed3` | **M0-verify test hardening** | Deferred verifier cohort ran: architect=PASS (code correct), qa=FIX_REQUIRED (tests). Single-step `_fakeCallMode` made `currentStepIndex==0` trivially true → decline-safe/unsafe + hang-up now assert `userDisarmed` (engine stream) / `EnginePhase.grace`. Added earpiece (useSpeaker:false), earlyCheckIn(reset=false) controller test, and the nonce auto-PUSH widget tests (FakeCallScreen + DisguisedReminderScreen + subtle-stays-inline) the cohort flagged WEAK. Test-only; +5 tests. |

## What shipped (M0: 4/4 — COMPLETE)

| Commit | Fix | What it really was (bigger than the audit one-liner) |
|---|---|---|
| `764a3ed` | **#18 disguisedReminder** | Was a whole feature, not a wiring tweak. (1) New pure selection algorithm `reminder_template_selector.dart` (spec 02:89-99: templateIds filter, randomize via injected `nowMillis`, avoid-last-shown C4). (2) Added the **missing `templateIds` field** to `DisguisedReminderConfig` (spec required it; editor is #13/M2). (3) Merged mode-local templates into the pool at `startSession` (was global-only). (4) Controller selects on `reminderFired` → `SessionState.activeReminderTemplate` + `reminderShowNonce`; passes the pick to the strategy via `EventServices.copyWith`. (5) Strategy notification now uses the template title/body (was hard-coded "Check in now"). (6) **Wired `earlyCheckIn`** (was dead) — wait-phase tap → `controller.earlyCheckIn()` honoring `resetOnEarlyCheckIn`. (7) New shared `ReminderConfirmation`/`ReminderDisguiseContent` rendering all 4 confirmation types (tapButton/tapWord-with-decoys/swipe/dismiss). (8) New **full-screen `DisguisedReminderScreen` route** for `fullScreen` templates (your AskUserQuestion choice), auto-pushed via the nonce like #17's fakeCall, auto-pops when the engine moves on. Fixed a latent loading-frame premature-pop. 5 new l10n keys × 14 locales. |
| `6c65a96` | **#21 audio assets** | 3 referenced `.ogg` didn't exist → alarm/ring/countdown SILENT. Shipped cross-platform **WAV** (OGG doesn't decode on iOS). Found `alarm.mp3` was a **0.26 s silent stub** mislabeled "source-of-truth" → removed it, kept the real `ringtone.wav` (renamed `ringtone_default.wav`), synthesized `siren.wav`+`countdown_warning.wav` (`tool/generate_audio_assets.py`). New CI **`assets-exist`** gate. **Fixed a latent `play()` fire-and-forget hang** (awaiting `play()` on a looping source never returns — `_startPlayback()` now used at all 5 sites). Fixed the drifted preservation-manifest. |
| `168d67c` | **#17 fakeCall** | Buttons only `context.pop()`'d. Wired answer→stop-ring+play-voice, hang-up→`engine.hangUp()`→disarm, decline→disarm(safe)/`restartCurrentStep`(unsafe). **You chose to include full-screen auto-appear** → `SessionState.fakeCallShowNonce` bumps on each fakeCall `stepStarted`; session screen pushes `FakeCallScreen` (guarded, re-appears on retry). Fixed 2 latent bugs: nav pushed without the step config; strategy played `voiceRecordingPath` AS the ringtone. Added `playVoiceRecording` to `AudioServiceProtocol` (+Real/Sim `@override`, +5 test fakes). Corrected a test that *encoded* the ringtone bug. |
| `3ec5b1c` | **#19 loudAlarm gradual/DND** | Strategy never passed `rampSeconds`/`alarmDndOverride` → service defaults won: alarm **always** ramped (5 s) and DND-override was **always on** (inverse of the Q19 opt-in). AppSettings already had the right values; threaded them via `EventServices` → `LoudAlarmStrategy` (ramp needs BOTH global `alarmGradualVolume` AND per-step `gradualVolume`; DND from `alarmDndOverride`). |

**Verification standard met for each:** full `flutter analyze
--fatal-infos`, full `flutter test` (now 3795), emulator integration test,
format + import_sorter + S-NN + Phase-X + OLD greps + the asset gate.
Emulator tests: `integration_test/audio_assets_test.dart` (#21 audio
decode) and `integration_test/disguised_reminder_test.dart` (#18 — all 4
confirmation interactions render + confirm through the real Android engine
on `emulator-5554`).

---

## Discovered but DEFERRED (note for the right milestone)

- **Background full-screen launch-to-route** (notification
  full-screen-intent → routes to FakeCallScreen / DisguisedReminderScreen
  when device is locked). Both #17 and #18 do *foreground* auto-appear; the
  backgrounded path relies on the notification. This now covers the
  disguisedReminder too, **plus its confirmation-type-specific notification
  text + tap-to-check-in deeplink** (spec 02:121-125 — tapWord "tap to check
  in" / swipe "swipe to dismiss"; the #18 notification currently shows the
  plain disguise title/body, which is correct but inert when tapped). →
  notification-deeplink pass, likely with #11/M1 or a nav pass.
- **#18 polish (minor):** tapWord decoy words are a fixed English-ish set
  (`reminder_word_choices.dart`), not localized; the disguise icon is a
  neutral Material icon (template `iconAsset`/`imagePath` not yet rendered).
  Both are cosmetic — fold into a later stealth/templates polish (near #15).
- **iOS `critical_alert.wav`** notification sound is referenced in
  `notification_service.dart` (`DarwinNotificationDetails(sound:)`) but
  doesn't exist in the iOS bundle → iOS alarm notification falls back to
  the default critical-alert sound. Minor iOS polish. → fold into **#20**
  (iOS strings/notification, M2). The *core* loud alarm is the
  `AudioService` siren (now real), not the notification sound.
- **`docs/review/remaining-gaps.md`** is a **stale v2-era artifact**
  (dated 2026-04-10, references `lib/services/implementations/…` paths
  that don't exist in v3). GAP-66/67 there describe v2 audio code — do
  NOT action them against v3. Left as-is.

---

## Decisions made (all via AskUserQuestion)

1. **Approve the remediation plan + milestone order; start M0 now.**
2. **Tier-F descope → decide at M4** (deferred; do not cut yet).
3. **R-8 emergency-number data → source from a citable public reference
   (ITU/Wikipedia) + flag for user review** (an M4 item).
4. **#17 scope → include full-screen auto-appear** (not just the 3
   buttons).
5. **#18 fullScreen display style → pushed full-screen route** (new
   `DisguisedReminderScreen`, hides chrome), mirroring #17. `subtle` stays
   an inline card.

---

## Hard rules (unchanged — apply every stage)

1. **OLD/ is INERT.** Never read/list/glob/grep/import under `OLD/`.
   `git checkout HEAD -- OLD/` if a tool dirties it.
2. **NO STUBS at GA** (S-1..S-12 in `~/.claude/plans/make-sure-that-there-typed-tulip.md §NO-STUBS`). The wiring gaps are exactly what these prevent.
3. **NO INVENTED DEFERRALS.** Grep `lib/features/` for `Phase X` before every commit.
4. **DO NOT guess.** `AskUserQuestion` for spec ambiguity / value decisions.
5. **Pre-alpha = break compatibility freely.** Tests follow code; update tests that encoded a bug (did this twice this session).
6. **Verify after EVERY fix.** analyzer + full tests + emulator + grep gates. Re-engage the verifier on `FIX_REQUIRED`.
7. **Write/update HANDOFF.md before the session ends.**
8. **Serial default; parallel only when truly orthogonal.** Connected fixes stay serial.
9. **Co-Authored-By footer:** `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.
10. **Pure Dart in `lib/domain/`, `lib/services/protocols/`, `lib/data/`.**
11. **lefthook re-stages auto-fixes. NEVER `dart format .` / `import_sorter` REPO-WIDE** — scope to changed files. The emulator build regenerates `lib/l10n/l10n/app_localizations*.dart` with blank-line drift → `git checkout -- lib/l10n/l10n/` to discard (done every commit this session).
12. **Pushing to `main` needs explicit user authorization each time.**

---

## Emulator (the verification standard — validated again this session)

```bash
export ANDROID_HOME=/home/jonas/Android/Sdk
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"
adb devices    # an emulator-5554 may still be up from this session
# If not booted, cold-boot headless (AVD Pixel_9_Pro / API 36 pre-exists):
emulator -avd Pixel_9_Pro -no-window -no-audio -no-boot-anim \
  -gpu swiftshader_indirect -no-snapshot &
until [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ]; \
  do sleep 3; done; adb shell input keyevent 82
# Run an integration test (wrap in `timeout` — a hung test won't self-kill):
timeout 480 flutter test integration_test/audio_assets_test.dart -d emulator-5554
```
First Gradle build ~30–75 s (incremental builds are fast — the APK is
cached). **Gotcha:** Gradle can transiently fail to fetch
`androidx.test.espresso` metadata from Maven — it's cached, so a retry
succeeds. **Don't** pipe a long `flutter test` through `| tail` when
backgrounding (tail buffers → empty output until exit; you can't see a
hang).

---

## Quick verification commands

```bash
flutter analyze --fatal-infos                                   # 0 issues
flutter test --concurrency=6                                    # 3809 pass
dart format --output=none --set-exit-if-changed <changed .dart files>
dart run import_sorter:main --no-comments --exit-if-changed
grep -rnE "(Phase 8|Phase 9|Phase 10|Phase 11)" lib/features/  # 0
git status --porcelain -- OLD/                                  # empty
git checkout -- lib/l10n/l10n/   # discard generated blank-line drift if a build ran
# asset-existence gate (now in CI as job `assets-exist`):
for r in $(grep -rhoE "assets/[A-Za-z0-9_/.-]+\.[A-Za-z0-9]+" lib/ | sort -u); do [ -f "$r" ] || echo "MISSING $r"; done
```

---

## The plan + task journal

- **Plan doc:** `docs/rewrite/ga-wiring-remediation.md` (corrected status
  §1, gap inventory §2 = tasks #8–#23, method §3, milestones M0–M5 §4).
- **Task journal** (TaskList): **M0 done+verified — #21✓ #17✓ #19✓ #18✓
  + m0-verify✓. M1: #11✓.** Next: **#22 GPS/battery, #12 clamp** (rest of
  M1), then M2 (config UIs
  #13/#14/#23/#20 — #13's StepConfigPanel is where the new `templateIds`
  field gets its editor), M3 (#15 stealth), M4 (#10/#9/#8/#16 + Tier-F
  decisions), M5 (Phase-9 proper: INT scenarios, device e2e, spec-coverage
  matrix, coverage floor). The in-memory TaskList is cleared on `/clear` —
  this bullet is the durable journal.

---

## End-of-session ritual (every session)

1. **Update HANDOFF.md** (this file) — snapshot, what changed, decisions, next action, emulator cmd.
2. **Commit HANDOFF.md** (`…-handoff: …` + Co-Authored-By footer).
3. **Tell the user the resume prompt** exactly: `Continue from HANDOFF.md`.

Don't skip it because "the session went short."

---

End of hand-off. M0 is 3/4 done and committed (unpushed). Resume with
**#18**, then the M0 verifier cohort, then ask about pushing.
