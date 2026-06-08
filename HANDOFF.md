# Guardian Angela v3 — Session Hand-off

**Snapshot:** 2026-06-08 — **M0 + M1 PUSHED. M2 PUSHED (presumed — was
gate-green + pre-authorized; `origin/main` should now carry it). M3 (#15
stealth) STARTED: chunk C1 (stealth session-screen UI) is DONE + GATE-GREEN +
COMMITTED (UNPUSHED).** C1 delivered the **fake music player** (disguises the
session screen, play/pause→`pause()`/`resume()`, swipe-on-progress→`disarm()`),
the spec-named **`SessionElapsedClock`** widget (normal/small/none + the G-018
10 s idle-fade), threaded `timerDisplay`+`sessionScreenStealth` into
`SessionState`, and the **`sessionScreenStealth` branding strip** (app-bar
title + brand-free end-session swipe/PIN). Authoritative gate is GREEN:
analyzer `--fatal-infos` = 0; full suite `flutter test --concurrency=6` =
**3843 pass** (3822 baseline + 21 net-new); emulator boot-smoke PASS on
`emulator-5554`; l10n parity 14/14 on 7 new keys; deferral-grep 0; OLD/ clean.
**NEXT ACTION = M3 C3** (notification/fakeName disguise + wire
`BackgroundSessionService` start/stop). See the **M3 chunk plan** + **M3
DECISIONS (user)** blocks below. C2 (spec-reconcile) + C5 (polish) follow C3.

---

## M3 chunk plan (#15 stealth — large, mostly-hollow; user-scoped)

- **C1 — stealth session-screen UI** ✅ DONE this session (`m3-#15-c1`,
  UNPUSHED). Fake music player + `SessionElapsedClock`(+G-018) + branding strip.
- **C3 — NEXT.** Notification/`fakeName` disguise + **wire
  `BackgroundSessionService`** to actually start/stop in M3 (user decision).
- **C2.** Spec-reconcile: bless the standalone `/settings/stealth` screen in
  spec 06; document `lockTaskMode`; add the spec remark that **stealth config
  cannot change during an active session**; decide the fate of the in-player
  "Stealth Mode: ON" toggle (see DECISIONS — I deferred it here, NOT a stub).
- **C4.** `fakeIcon` → FULL per-preset rework (user decision; process-kill
  mid-session risk is MOOT because config can't change mid-session).
- **C5.** Polish: `fakeName` in in-session chrome (the music player currently
  uses neutral localized track/artist strings); disguise template icons
  (render-if-present + Material fallback); tapWord decoy-word localization.

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

**Next action: M3 C3** — notification/`fakeName` disguise + wire
`BackgroundSessionService` to actually start/stop. Then C2 (spec-reconcile) and
C5 (polish). See the **M3 chunk plan** + **M3 DECISIONS (user)** blocks above.

C1 (this session) is COMMITTED but UNPUSHED (`m3-#15-c1`). The M2 stack was
gate-green + user-pre-authorized to push; this session ASSUMES the orchestrator
pushed it (confirm `git log origin/main` includes the M2 commits + `m2-handoff`
`b4c8b21`). Per-fix recipe (unchanged): verify the gap yourself → implement
(serial) → prove (host/widget tests driving the REAL controller/screen;
emulator for native) → l10n deltas → translate 13 locales → gate suite →
commit → **ask before pushing**.

**DO NOT PUSH** without explicit user authorization (Hard Rule 12).

---

## What's done THIS session (M3 C1 — UNPUSHED, `m3-#15-c1`)

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

**DEFERRED to C2 (NOT a stub):** the spec mockup's in-player "Stealth Mode: ON"
toggle (spec 04:914/924). Its spec semantics ("toggle stealth on/off") directly
conflict with the user decision that **stealth config cannot change during an
active session**. Rendering a non-functional toggle would be a stub; making it
functional would violate the decision. So C1 OMITS it and C2 (which already owns
the "can't-change-mid-session" spec remark) decides its fate. The
`sessionStealthToggleLabel` string is pre-staged.

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
- **#18 polish:** tapWord decoy words not localized; disguise icon is a neutral
  Material icon (template `iconAsset`/`imagePath` not rendered). → near #15.
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
flutter test --concurrency=6                                    # 3843 pass (M3 C1)
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
- **Milestones:** **M0 ✓ pushed. M1 ✓ pushed. M2 ✓ verified+gate-green
  (pushed/being-pushed by orchestrator).** **M3 (#15 stealth) IN PROGRESS** —
  **C1 ✓ DONE+GATE-GREEN+COMMITTED (UNPUSHED, `m3-#15-c1`)**; C3 NEXT, then C2,
  then C4/C5 (see the M3 chunk plan + M3 DECISIONS blocks near the top). Then
  M4 (#10/#9/#8/#16 + Tier-F), M5 (Phase-9: INT scenarios, device e2e incl. #11
  adb-gsm + #12 background-throttle, spec-coverage matrix, coverage floor). The
  in-memory TaskList is cleared on `/clear` — this bullet is the durable
  journal.

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
