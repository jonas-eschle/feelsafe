# Guardian Angela v3 — Session Hand-off

**Snapshot:** 2026-06-08 — **M0 + M1 COMPLETE+VERIFIED+PUSHED. M2 IN
PROGRESS: #13a + #13b + #14 + #13c (COMPLETE + cohort-VERIFIED PASS at
`d54b986`+`81f131f`) + #13d COMPLETE + cohort-VERIFIED (PASS) at `0788c52` +
#23 COMPLETE + cohort-VERIFIED (PASS) at `8c191ac` + #20 (channel validation
+ SMS template editor + iOS warnings) **PARTIAL**: sub-parts 1–3 COMPLETE +
committed (UNPUSHED); sub-part 4 (iOS `critical_alert.wav`) **BLOCKED — needs
user decision** (no such asset exists in the repo; recommendation below).
Next: resolve #20 sub-part 4 → M2 cohort → push.**

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
- `<this>`   m2-#20 — channel validation + SMS template editor + iOS warnings
              (sub-parts 1–3; sub-part 4 critical_alert.wav BLOCKED)
- (+ this handoff commit)

**Tests: 3808 pass** (3788 prior + 20 net-new #20 tests: 8 pure-Dart
channel-validation cases in `mode_draft_validator_test`, 4 mode-editor widget
tests driving the REAL `_save()`/draft→DB (channel-validation block + allow,
messageTemplate round-trip + placeholder-chip insert), 8 `EventSpecificConfig`
widget tests under a `ThemeData(platform:)` override (iOS SMS warning
show/hide + channel-gate, iOS callEmergency warning show/hide, template field
+ chips, blank→null clear)). Analyzer `--fatal-infos` clean. l10n parity green
(5 new #20 keys × 14 locales; additions-only regen). deferral-grep 0; OLD/
clean. Tree clean. Branch: `main`. (Pure-Dart validator + Flutter-only UI/l10n
— no native/model/strategy change in the committed sub-parts; the iOS bundle
change is sub-part 4, which is BLOCKED and NOT committed.)

**#20 BLOCKED sub-part (NEEDS USER DECISION):** iOS `critical_alert.wav` does
NOT exist anywhere in the repo (verified: only `siren.wav`,
`ringtone_default.wav`, `countdown_warning.wav` ship under `assets/audio/`;
the 14 voice m4a; nothing named `critical_alert.*` is or ever was tracked).
`lib/services/notification_service.dart:391` passes `sound:
'critical_alert.wav'` to `DarwinNotificationDetails` for iOS escalation
notifications (alarm/emergency/fakeCall), so iOS would fall back to the
default notification sound — the bespoke critical-alert siren never plays.
The task's hypothesis ("a Flutter asset already ships it; iOS just doesn't
bundle it") is FALSE. **Recommendation:** the canonical alarm/critical sound
the app already ships and plays on BOTH platforms is `assets/audio/siren.wav`
(RIFF/WAVE PCM 16-bit mono 44.1 kHz, a valid `UNNotificationSound` format and
well under the iOS 30 s limit; `audio_service.dart:244` notes "WAV decodes on
both Android and iOS"). Bundling a copy of `siren.wav` as the iOS notification
sound `critical_alert.wav` (root of `ios/Runner`, referenced from
`Runner.xcodeproj` + `Info.plist`/Copy-Bundle-Resources) is a real,
already-approved-as-the-alarm asset — NOT fabricated junk. But it is a
safety-relevant UX decision (which sound iOS critical alerts play), so per
Hard Rule 4 it needs explicit user sign-off before committing the copy. I did
NOT commit a placeholder/junk wav (that would be a stub). **Decision needed:**
(a) approve sourcing iOS `critical_alert.wav` from `siren.wav`, or (b) provide
a dedicated critical-alert audio file. After the decision, the remaining work
is mechanical: drop the file at `ios/Runner/critical_alert.wav`, add it to the
`Runner` target's resources in `project.pbxproj` (PBXBuildFile +
PBXFileReference + Resources build phase), and verify via CI `build-ios`.

---

## How to resume

After `/clear`, paste:

> Continue from HANDOFF.md

**Next action: (1) resolve #20 sub-part 4 (iOS `critical_alert.wav`) — see the
BLOCKED section above; one AskUserQuestion (source from `siren.wav` vs. a
dedicated file), then the mechanical bundle/pbxproj wiring + CI `build-ios`.
(2) Run the M2 verifier cohort (architect-reviewer spec-vs-code + qa-expert
spec-vs-tests, both `opus`) → gate → push the M2 stack.** Per-fix recipe
(unchanged): verify the gap yourself → implement (serial) → prove (host/widget
tests driving the REAL controller; emulator for native) → l10n deltas →
language agent for 13 locales → gate suite → commit → **ask before pushing**.

**M2 remaining chunks (the spine — #13a/#13b/#14 — AND #13c AND #13d AND #23
— are done; #20 sub-parts 1–3 done):**

1. **#20 sub-part 4 only** — iOS `critical_alert.wav` bundle (BLOCKED on a
   user decision; sub-parts 1–3 — channel-validation-on-save, SMS
   message-template editor, iOS SMS+callEmergency warnings — are COMPLETE +
   committed). See the BLOCKED section.

Then: **M2 verifier cohort** (architect-reviewer spec-vs-code + qa-expert
spec-vs-tests, both `opus`) → gate → **ask the user to push the M2 stack.**

---

## What's done this session (M2 spine — UNPUSHED)

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

---

## KEY FINDINGS (carry into the next session)

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
- **`allContacts` + non-empty `contactIds` ⇒ treated as SPECIFIC IDs** by
  `sms_contact_strategy.dart:135` (legacy back-compat). So true "all" MUST
  null `contactIds`. `SmsContactConfig.copyWith` (and `ChainStep.copyWith`)
  CANNOT null a field (`x ?? this.x`) — construct the object directly to clear.
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
- **iOS `critical_alert.wav`** missing from the iOS bundle → now the ACTIVE
  **#20 sub-part 4 BLOCKED** item (see the BLOCKED section near the top — it
  needs a user decision: source from `siren.wav` vs. a dedicated file).
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
flutter test --concurrency=6                                    # 3788 pass
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
- **Milestones:** **M0 ✓ pushed. M1 ✓ pushed. M2 IN PROGRESS** — #13a ✓ +
  #13b ✓ + #14 ✓ + #13c ✓ + #13d ✓ + #23 ✓ + #20 sub-parts 1–3 ✓ done
  (UNPUSHED); remaining **#20 sub-part 4 (iOS `critical_alert.wav`, BLOCKED on
  a user decision) → M2 cohort → push.** Then M3 (#15 stealth), M4
  (#10/#9/#8/#16 + Tier-F), M5 (Phase-9: INT scenarios, device e2e incl.
  #11 adb-gsm + #12 background-throttle, spec-coverage matrix, coverage floor).
  The in-memory TaskList is cleared on `/clear` — this bullet is the durable
  journal.

---

## End-of-session ritual (every session)

1. **Update HANDOFF.md** — snapshot, what changed, decisions, next action.
2. **Commit HANDOFF.md** (`…-handoff: …` + Co-Authored-By footer).
3. **Tell the user the resume prompt** exactly: `Continue from HANDOFF.md`.

Don't skip it because "the session went short."

---

End of hand-off. M0+M1 verified+pushed; **M2 config-UI in progress** — #13a +
#13b (per-step config) + #14 (SMS contact grid) + #13c (Safety Options) + #13d
(save + trigger save-validation) + #23 (alarm settings section) committed,
UNPUSHED. Resume by **building #20 → M2 cohort → push.**
