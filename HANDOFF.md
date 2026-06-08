# Guardian Angela v3 — Session Hand-off

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

**Next action: the M3 verifier cohort** — M3 is FULLY IMPLEMENTED (C1–C5).
Run the cohort (architect-reviewer spec-vs-code + qa-expert spec-vs-tests, both
opus, across the WHOLE M3 stack C1+C2+C3+C4+C5) → full gate → **push the M3
stack** (user pre-authorized). See the **M3 chunk plan** + **M3 DECISIONS
(user)** blocks above. Re-engage the implementing path on any `FIX_REQUIRED`.

C1 + C2 + C3 + C4 + C5 are COMMITTED but UNPUSHED (`ac65b9e` + `a6c36ef` +
`837c1e4` + `55f958d` + `m3-#15-c5`). The M2 stack is PUSHED — confirmed
`origin/main` = `b4c8b21` (includes the M2 commits + `m2-handoff`). Per-fix
recipe (unchanged): verify the gap yourself → implement (serial) → prove
(host/widget tests driving the REAL controller/screen; emulator for native) →
l10n deltas → translate 13 locales → gate suite → commit → **ask before
pushing**.

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
flutter test --concurrency=6                                    # 3882 pass (M3 C5)
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
- **Milestones:** **M0 ✓ pushed. M1 ✓ pushed. M2 ✓ pushed (`origin/main` =
  `b4c8b21`).** **M3 (#15 stealth) FULLY IMPLEMENTED** — **C1 + C2 + C3 + C4 +
  C5 ✓ DONE+GATE-GREEN+COMMITTED (UNPUSHED, `ac65b9e` / `55f958d` / `a6c36ef` /
  `837c1e4` / `m3-#15-c5`)**; **NEXT = the M3 verifier cohort + push** (see the
  M3 chunk plan + M3 DECISIONS blocks near the top). Then M4 (#10/#9/#8/#16 +
  Tier-F + the `service_providers.dart` Phase-7 doc-sweep), M5 (Phase-9: INT
  scenarios, device e2e incl. #11 adb-gsm + #12 background-throttle,
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
