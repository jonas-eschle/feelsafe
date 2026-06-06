# Guardian Angela v3 — Session Hand-off

**Snapshot:** 2026-06-06 — **Remediation plan APPROVED; executing M0.**
3 of 4 M0 fixes are **done, verified, and committed** (#21, #17, #19).
**#18 is the only M0 item left.** Then M1–M5 (see the plan doc).

**HEAD:** `3ec5b1c`. **4 commits ahead of `origin/main`, all UNPUSHED**
(`808a83f` audit handoff + the 3 M0 commits below). **Tests: 3753 pass**
(was 3744 at plan time; +9 net new). **Analyzer:** `--fatal-infos` clean.
**Tree:** clean. **Branch:** `main`. **Push needs your explicit
authorization** (rule 12) — nothing has been pushed.

**The big lesson this session held up:** the emulator integration test is
worth its weight. It caught two things unit tests *structurally could
not* — the missing audio assets AND a latent `just_audio.play()` hang that
only manifests with a real player on a looping source. "Green" now means
"works."

---

## How to resume

After `/clear`, paste:

> Continue from HANDOFF.md

**First action: do M0 #18** (the last M0 fix), then run the M0 **verifier
cohort** (per the plan's method), then this session's commits + #18 can be
pushed once you authorize.

**#18 — disguisedReminder template rendering + confirmation types +
`earlyCheckIn` (spec 02:89-135, task #4).** The audit found: renders no
template/disguise/confirmation-types; the check-in prompt is hard-coded
"Check in now"; `engine.earlyCheckIn()` is never called. **Verify the gap
yourself first** (the audit one-liners undersold #17 and #19 — both hid
extra bugs). Likely touches: the disguised-reminder screen/notification,
the 8 seed reminder templates (`lib/data/seed_data.dart`), confirmation
types, and wiring `earlyCheckIn`. Watch for the same pattern as #17: a
config that isn't passed, or a setting that isn't consumed.

**Per-fix recipe (unchanged):** verify gap yourself → implement (serial)
→ prove with an emulator integration test (host widget/controller tests
for pure wiring; emulator for native playback) → l10n deltas (spawn the
language agent if you add user-facing strings) → gate suite → commit.
Re-engage the verifier cohort on `FIX_REQUIRED`.

---

## What shipped this session (M0: 3/4)

| Commit | Fix | What it really was (bigger than the audit one-liner) |
|---|---|---|
| `6c65a96` | **#21 audio assets** | 3 referenced `.ogg` didn't exist → alarm/ring/countdown SILENT. Shipped cross-platform **WAV** (OGG doesn't decode on iOS). Found `alarm.mp3` was a **0.26 s silent stub** mislabeled "source-of-truth" → removed it, kept the real `ringtone.wav` (renamed `ringtone_default.wav`), synthesized `siren.wav`+`countdown_warning.wav` (`tool/generate_audio_assets.py`). New CI **`assets-exist`** gate. **Fixed a latent `play()` fire-and-forget hang** (awaiting `play()` on a looping source never returns — `_startPlayback()` now used at all 5 sites). Fixed the drifted preservation-manifest. |
| `168d67c` | **#17 fakeCall** | Buttons only `context.pop()`'d. Wired answer→stop-ring+play-voice, hang-up→`engine.hangUp()`→disarm, decline→disarm(safe)/`restartCurrentStep`(unsafe). **You chose to include full-screen auto-appear** → `SessionState.fakeCallShowNonce` bumps on each fakeCall `stepStarted`; session screen pushes `FakeCallScreen` (guarded, re-appears on retry). Fixed 2 latent bugs: nav pushed without the step config; strategy played `voiceRecordingPath` AS the ringtone. Added `playVoiceRecording` to `AudioServiceProtocol` (+Real/Sim `@override`, +5 test fakes). Corrected a test that *encoded* the ringtone bug. |
| `3ec5b1c` | **#19 loudAlarm gradual/DND** | Strategy never passed `rampSeconds`/`alarmDndOverride` → service defaults won: alarm **always** ramped (5 s) and DND-override was **always on** (inverse of the Q19 opt-in). AppSettings already had the right values; threaded them via `EventServices` → `LoudAlarmStrategy` (ramp needs BOTH global `alarmGradualVolume` AND per-step `gradualVolume`; DND from `alarmDndOverride`). |

**Verification standard met for each:** full `flutter analyze
--fatal-infos`, full `flutter test` (3753), emulator integration test
(`integration_test/audio_assets_test.dart` — 4 tests: siren / ringtone /
countdown / built-in voice all decode on `Pixel_9_Pro`), format +
import_sorter + S-NN + Phase-X + OLD greps + the asset gate.

---

## Discovered but DEFERRED (note for the right milestone)

- **Background fakeCall full-screen launch-to-route** (notification
  full-screen-intent → routes to FakeCallScreen when device is locked).
  Separate from #17 (which did foreground auto-appear). A
  notification-deeplink concern. → likely with #11/M1 or a nav pass.
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
flutter test --concurrency=6                                    # 3753 pass
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
- **Task journal** (TaskList): #21✓ #17✓ #19✓ done; **#18 pending** is the
  last M0 item. Then M1 (#11 real-call, #22 GPS/battery, #12 clamp), M2
  (config UIs #13/#14/#23/#20), M3 (#15 stealth), M4 (#10/#9/#8/#16 +
  Tier-F decisions), M5 (Phase-9 proper: INT scenarios, device e2e,
  spec-coverage matrix, coverage floor).

---

## End-of-session ritual (every session)

1. **Update HANDOFF.md** (this file) — snapshot, what changed, decisions, next action, emulator cmd.
2. **Commit HANDOFF.md** (`…-handoff: …` + Co-Authored-By footer).
3. **Tell the user the resume prompt** exactly: `Continue from HANDOFF.md`.

Don't skip it because "the session went short."

---

End of hand-off. M0 is 3/4 done and committed (unpushed). Resume with
**#18**, then the M0 verifier cohort, then ask about pushing.
