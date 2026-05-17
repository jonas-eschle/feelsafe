# Guardian Angela — Spec Audit (Pre-Rewrite)

> **Read-only audit.** No spec files were modified. This document collects
> internal contradictions, cross-spec disagreements, outdated symbols, and
> missing definitions in `docs/spec/00-overview.md` through
> `docs/spec/11-deferred-enhancements.md`. Recommendations propose the
> cleanest pre-alpha resolution (backward compatibility NOT a constraint).

---

## Summary (top issues)

1. **`fakeCall` semantics are self-contradicting throughout the spec set.**
   `01-chain-engine.md:373` declares Pivot 2: "fakeCall is event, not
   pause — engine timer keeps running" — yet the same file lines 361–365
   and 235–252 of `02-event-types.md` and 1095–1099 of
   `08-decisions-consolidated.md` plus tests TC-47, TC-48, TC-93 all
   assert "answer → chain PAUSES". `engine.answerFakeCall()` is
   described in two places as "no-op at engine level" *and* as a method
   that "pauses chain timers". Pick one and propagate.

2. **The `DistressChain` model is dead but the term "Distress Chains"
   is still used as a UI label, hub route, and table heading.** Pivot 3
   replaced the model, but `04-screens-navigation.md:1393–1419, 1873,
   1944–1979` still describes a "Modes & Chains" hub with a
   "DISTRESS CHAINS" section and `/settings/modes-and-chains` route, even
   though the same file at line 121–123 lists this route as REMOVED.
   `06-settings.md:157, 882` and the duress PIN setup flow still
   reference "Distress Chains".

3. **`LogGpsOverride` is referenced six times but never defined.** Used
   in `PhoneCallContactConfig` and `LoudAlarmConfig`
   (`03-data-models.md:425, 443`) plus event-types and settings tables,
   yet no enum declaration exists. Same for `CountdownStyle`
   (`03-data-models.md:339`) — used in `CountdownWarningConfig` but
   never declared. `DistressTrigger` / `DisarmTrigger`
   (`03-data-models.md:546–547`) are used as List<T> but the type
   hierarchy is only sketched informally in `00-overview.md:274`.

4. **Spec doc index in `00-overview.md:566–576` only lists docs
   00–08.** Documents 09 (Glossary), 10 (Platform Matrix), and 11
   (Deferred Enhancements) all exist in the directory but are absent
   from the official index. New readers will miss them.

5. **Alarm sound options diverge across 4 specs.** Q9 fixed the enum at
   `{siren, custom}` only (`03-data-models.md:450`). But
   `05-services.md:87` still says `'siren' | 'beep' | 'custom'`,
   `08-decisions-consolidated.md:294` says `"Siren (default), whistle,
   scream"`, `10-platform-matrix.md:102` says `"siren/beep"`, and the
   user note in this audit's intro says only `siren|custom` were
   intended. Also `03-data-models.md:498` references `AlarmSound.siren`
   (wrong class name — should be `LoudAlarmSound`).

---

## Per-spec findings

### `docs/spec/00-overview.md`

- **00:566–576** — Spec Document Index lists only 00–08; missing 09
  (Glossary), 10 (Platform Matrix), 11 (Deferred Enhancements). All
  three exist on disk.
- **00:301, 707** — Walk Mode "1-sec grace" cited; but the canonical
  default in `03-data-models.md:516–528` and
  `02-event-types.md:62` is `gracePeriodSeconds = 0` for holdButton,
  and the Walk Mode seed in `03-data-models.md:1049` uses
  `gracePeriodSeconds: 1`. So "1 sec" matches the seed but not the
  type-level default. Decide whether the seed overrides the default
  or follows it.
- **00:240** — `notificationDisguise` described as "generic channel
  name/icon" (a behavior); but `03-data-models.md:978` defines it as
  `bool notificationDisguise` while `08-decisions-consolidated.md:377`
  defines it as `String? notificationDisguise` ("title text default
  'Music playing'"). Three different definitions for one field.
- **00:564** — File ends with no `## 11` link in index; the
  "Spec Document Index" header (line 564) should also include 09–11.
- **00:601** — "New Flutter versions tested within 2 weeks of release"
  is informative-looking but appears in a Normative document; either
  promote to a definitive policy or move to the changelog.

### `docs/spec/01-chain-engine.md`

- **01:361, 393–396** vs **01:373, 380** — INTERNAL CONTRADICTION on
  `fakeCall` answer semantics:
  - Line 361: "Ring → Answer → Chain PAUSES → Voice plays → User hangs
    up → DISARM"
  - Line 373: "Pivot 2 — fakeCall is event, not pause. The engine timer
    keeps running while the voice clip plays … This method [
    answerFakeCall()] is a no-op at the engine level."
  These two paragraphs are 12 lines apart and directly contradict each
  other. The same `answerFakeCall()` method spec is duplicated at lines
  570–581 with identical contradictory body.
- **01:594** — `restartCurrentStep()` "used when user declines a fake
  call (when `declineIsSafe=false`)" but `01:362` flow box also shows
  decline routing to `restartCurrentStep` regardless of `declineIsSafe`
  ("declineIsSafe? disarm : miss (restartCurrentStep)").
- **01:464** — Constructor param list says simulation enables `leap`,
  `jumpToStep`, mid-run `setSpeedMultiplier`; the API method is named
  `leap()` (01:658). But every other doc calls it
  `leapToNextEvent()` (`09-glossary.md:160`,
  `01-chain-engine.md:1165`, `07-test-plan.md:199, 1283`).
- **01:953** — `engine.replaceWithDistressChain(steps)` shown without
  the `triggerReason:` parameter; but lines 273, 989, and
  `06-settings.md:161` always pass `triggerReason: ...`. Pick a
  signature.
- **01:1024–1031** — Invariant 6: "Session timer starts on user
  interaction, not on `start()`". This contradicts the
  `disguisedReminder` lifecycle (01:289–291) which states the wait
  timer begins on `start()`. The invariant as written is wrong for
  every step type except holdButton; clarify.
- **01:567** — Title "Disarm During retryCount = 0 Grace (Extra-46)"
  says "Contrast with retryCount > 0: disarming during grace also
  resets to step 0". So the entire section is a non-contrast — disarm
  is always the same. Either delete the section or clarify what's
  actually special.
- **01:1264** — Glossary inside the doc redefines "Distress Chain" but
  the same term is defined in `09-glossary.md:27` with different
  phrasing. Two glossaries, two definitions.

### `docs/spec/02-event-types.md`

- **02:62** — holdButton timing default `gracePeriodSeconds=0` (with
  note "was 5; issues-v4 #16"). But:
  - `03-data-models.md:518` defaults table says `gracePeriodSeconds=5`.
  - `03-data-models.md:1049` Walk Mode seed uses `gracePeriodSeconds=1`.
  - `01-chain-engine.md:1078` Walk Mode example uses
    `gracePeriodSeconds=1`.
  - `00-overview.md:301` says "1-sec grace".
  Four different numbers; resolve which one is the "default".
- **02:102, 06-settings.md:610–622, 03-data-models.md:253–259** — Three
  different built-in-template name lists:
  - 02 lists "Calendar, Duolingo, Delivery, Weather, Email, Chat, Bank,
    Social Media".
  - 03 lists "Calendar Event, Language Lesson, Delivery Update,
    Weather Alert, Fitness Reminder, Message Preview, App Update,
    Battery Warning".
  - 06 lists same as 03 plus button labels.
  - `00-overview.md:711` says "Calendar, Duolingo, Delivery, Weather,
    Fitness, Message, Update, Battery".
- **02:235–252** — Fake-call lifecycle text "Chain PAUSES on answer"
  contradicts the Pivot 2 statement (see top finding #1).
- **02:270** — `declineIsSafe: true` is the default ("Decline = disarm").
  But `07-test-plan.md:928, 949` says "Fake call decline counts as miss
  toward retryCount" — these tests assume `declineIsSafe = false`.
  Pick the canonical default and update the tests (or vice versa).
- **02:412–434** — `LoudAlarmConfig` table includes
  `soundChoice: LoudAlarmSound, siren | custom`, but the same row's
  prose at 02:410–412 lists "Built-in `siren` (default)" and
  "`custom`: user-supplied audio". The spec text reasonable, but
  `05-services.md:87` and `04-screens-navigation.md:1610` and
  `08-decisions-consolidated.md:294` still say `beep|whistle|scream`.
  Outdated.
- **02:421** — "alarm is the ONE exception that overrides silent mode"
  vs `03-data-models.md:610` which makes `alarmDndOverride` default
  `false` (opt-in). The text reads as if override is built-in/always.
- **02:382, 02:435** — `logGps: LogGpsOverride` — the enum
  `LogGpsOverride` is referenced but never defined in any spec doc.
  Used here, plus in `03-data-models.md:425, 443` and
  `06-settings.md:414`.
- **02:549** — `EventServices` includes `final FlashService flash;` but
  the LoudAlarm strategy is the only listed user; `ScreenFlashService`
  is separately listed in `05-services.md:594` and not bundled here.

### `docs/spec/03-data-models.md`

- **03:153 vs 03:899** — Both repeat that `DistressChain` is gone, but
  the latter section header reads "Distress modes (Pivot 3)" while the
  former still uses the legacy phrasing "former DistressChain Hive type
  (typeId 17)". Consolidate into one explanation block.
- **03:339** — `CountdownWarningConfig` declares
  `final CountdownStyle style` — the enum `CountdownStyle` is never
  defined anywhere in this file or any other spec. (The values
  "fullScreen / notification / minimal" appear at
  `02-event-types.md:200` but the type is undeclared.)
- **03:425, 443** — `LogGpsOverride` referenced as a type in
  `PhoneCallContactConfig` and `LoudAlarmConfig`, never defined.
- **03:498** — Example shows `loudAlarm: LoudAlarmConfig(volume: 0.8,
  soundChoice: AlarmSound.siren)` — wrong class name. Should be
  `LoudAlarmSound.siren`.
- **03:546–547** — `final List<DistressTrigger> distressTriggers; final
  List<DisarmTrigger> disarmTriggers;` — `DistressTrigger` and
  `DisarmTrigger` are referenced as types but the sealed hierarchy is
  only sketched in `00-overview.md:274`. Subclasses
  `HardwareButtonDistressTrigger`, `GpsArrivalDisarmTrigger`,
  `TimerDisarmTrigger` are mentioned but never given full schemas
  (no field lists, no JSON shape, no defaults).
- **03:563–568** — "If neither [distressModeId nor
  defaultDistressModeId] resolves, the mode blocks at session start
  (validation error)". But the default-distress mode is seeded on first
  launch (03:1117–1140), so the unresolved case should be impossible
  after seed. State whether the validation is defensive-only.
- **03:1024–1027** — `BatteryAlertConfig.fromJson` legacy synthesis
  rule is described — but the pre-alpha policy
  (`03-data-models.md:1190`) says "nuke and reseed on schema mismatch,
  no migrations". Legacy synthesis is a migration. Either delete the
  synthesis (per policy) or amend the policy.
- **03:758, 775** — `SessionLog.hadMedicalInfo` semantics differ in two
  places of the same file. 758: "stamped at log creation by
  SessionLogRecorder when the user profile carries medical info AND at
  least one step opts in". 775: "iff at least one smsContact step in
  the session had includeMedicalInfo=true AND the user profile had any
  medical information at session start". Same meaning, but two distinct
  sentences — pick one and remove the other.
- **03:609** — `emergencyCallNumber` default `'112'`, but
  `06-settings.md:230` says "Empty input blocks Save until non-empty"
  and the spec also says it's seeded from device locale. Three
  different defaults (literal '112' vs locale-derived vs blank).
- **03:880** — `WalkSession.simulationSilent` "default false; set true
  by the simulation summary screen for a silent replay" — but
  `04-screens-navigation.md:534` says "Every simulation session starts
  with `simulationSilent = true` (Extra 49)". The default contradicts.
- **03:1024–1033** — `sendSms` field is "legacy", "deferred", and
  guarded by a TODO. Either delete the field or document its keep-alive
  contract.
- **03:1213** — Code-generation note "After any @HiveType or @HiveField
  change: flutter pub run build_runner build" — but the doc header
  (line 7–13) says Hive has been retired in favor of JSON-backed
  repositories. The build-runner instruction is obsolete.

### `docs/spec/04-screens-navigation.md`

- **04:118–123** vs **04:1393–1419, 1944, 1979** — Route map at top
  lists `/settings/modes-and-chains` as REMOVED. But the same file
  still spends ~30 lines documenting the "Modes & Chains Screen
  (`/settings/modes-and-chains`)" hub, including a "DISTRESS CHAINS"
  section. The Settings hub layout (04:1944) lists "Modes & Chains"
  navigation target as `/settings/modes-and-chains` again.
- **04:476** — "Navigate to `/session/simulation-loading` (1.5s loading
  screen)" — `/session/simulation-loading` is not listed in the Route
  Map (04:84–129).
- **04:534** — Extra 49: simulation starts silent. Contradicts
  `03-data-models.md:880` (default false) and
  `00-overview.md:203` ("toggle defaults to off each session").
- **04:580–584** — Silent toggle "Defaults OFF (default)". Same
  contradiction with Extra 49 at 04:534.
- **04:1605** — Hold style menu lists "discreteButton/largeButton/
  fullScreen/fakeLockScreen" (4 options). But the model
  (`03-data-models.md:325`) and event-types
  (`02-event-types.md:42–44, 57`) and decisions
  (`08-decisions-consolidated.md:118–125`) all list 3 options
  (largeButton, fullScreen, fakeLockScreen). `discreteButton` is
  mentioned only in screens-navigation (04:656).
- **04:1610** — loudAlarm sound choice "siren/beep/custom" — should be
  `siren/custom` per Q9.
- **04:1873** — Defaults submenu lists "Default Distress Chain" — the
  Pivot 3 rename is to "Default Distress Mode".
- **04:1989–1993** — Session-locks list includes "Profile/Redo
  Onboarding" — but Profile editing is NOT listed elsewhere as locked
  (Profile screen at 04:1997 has no lock note).
- **04:2202** — Template Editor route printed as
  `/settings/defaults/event-defaults/templates/edit` — but route map
  at 04:111 uses `/settings/templates/edit`. Pick one.
- **04:2716–2727** — Summary section claims "9-page guided setup" for
  onboarding, but onboarding is "3 Screens" (04:134, 04:138).
- **04:1659** — "Modes referenced by `SessionMode.distressModeId` from
  any regular mode also block deletion" — but there is no spec for how
  reference-counting is implemented or where this check lives.
- **04:1736–1741** — `SmsRecipient` sealed type is referenced
  (`SmsRecipient.allContacts`, `SmsRecipient.specificIds`,
  `SmsRecipient.firstOnly`) but the actual model
  (`03-data-models.md:372`) uses `enum SmsContactSelection { allContacts,
  firstContact, specificIds }`. Different name (`SmsRecipient` vs
  `SmsContactSelection`) and different "first" case (`firstOnly` vs
  `firstContact`).

### `docs/spec/05-services.md`

- **05:87** — `soundChoice: 'siren' | 'beep' | 'custom'` —
  contradicts `03-data-models.md:450` (`{siren, custom}` only, Q9).
- **05:93** — Gradual volume default "10 seconds" — contradicts
  `03-data-models.md:612` (default 5s) and
  `06-settings.md:258` (default 5s) and the Q33 decision.
- **05:140** — TODO: "all 14 M4A files are listed in the asset manifest
  but the audio bytes still need to be recorded — track this under
  spec/11-deferred-enhancements.md". Already partially in 11; see
  alignment recommendation.
- **05:294** — Native TODO for SmsRetryExhausted MethodChannel
  emission. Spec assumes Dart-side wiring exists; the cross-stack
  contract should make the dependency direction explicit.
- **05:32–34** — Mermaid graph shows `S7 --> FS[FlashService]`. But the
  text at 05:594 introduces a separate `ScreenFlashService`. The
  diagram doesn't show ScreenFlashService at all.
- **05:1066–1075** — `BatteryMonitorService` legacy contract talks
  about `smsEnabled` boolean ("optionally sends an SMS to contacts (if
  BatteryAlertConfig.smsEnabled)"). Model uses neither `sendSms` nor
  `smsEnabled`; the chain-based model
  (`03-data-models.md:1009–1015`) has `enabled`, `thresholdPercent`,
  `chain`. Update the service spec.

### `docs/spec/06-settings.md`

- **06:115–118** — Session Locks list includes "Mode editing — Blocked
  during active session". Not enumerated anywhere else (00-overview's
  Session Locks list at 332–339 does not include mode editing).
- **06:117** — Same list says "Backup import". Yet the next subsection
  (06:285–294, 06:2419–2421) describes export+import as "blocked
  during active session" — the lock applies to both, not just import.
  Spec text is inconsistent.
- **06:142** — Session End PIN timeout "Configurable slider (5–120s,
  default 15s)". `03-data-models.md:597` says `default 15; max 120`.
  Consistent — but no `min` field. The slider min of 5 is asserted
  only here; the model has no enforcement.
- **06:163** — "Persistence: AppSettings.duressPinHash" — but
  duress-PIN validation rule (06:152) "Must differ from both App PIN
  and Session End PIN" is not encoded anywhere except prose; no
  invariant test or model assertion.
- **06:170–175** — Wrong PIN deceptive dialog "'Old pin entered — are
  you sure you want to proceed?'" — this UX is described only here.
  No screen mock in 04, no engine event for it, no test in 07.
- **06:294** — "Soft-delete + undo (decision 11): deleted logs enter
  a recoverable trash state for 7 days before permanent purge". But
  `03-data-models.md:797` says "Until Extra-11 (soft-delete) lands,
  this is a hard delete". Two versions of the same feature: shipped or
  pending?
- **06:299** — Tombstones older than `sessionLogRetentionDuration` (7
  days). Field name elsewhere is `sessionLogRetentionDays` (default
  180). Two different fields conflated.
- **06:432** — LoudAlarmConfig table includes both `flashSpeed`
  (legacy, seconds/cycle) and `flashSpeedMs` (canonical, ms/cycle).
  Both exist in `03-data-models.md:435–436`. Either the legacy field
  should be deleted (pre-alpha policy) or its purpose documented.
- **06:606** — `isCustom` vs `isGlobal` confusion: built-in templates
  use `isCustom = false`. But `03-data-models.md:239` introduces
  `isGlobal` as a separate concept (true = AppDefaults; false =
  mode-local). Two flags, two semantics, both on
  `ReminderTemplate`. Make their relationship explicit (or merge if
  redundant — built-in is always global; user-created can be either).
- **06:880–893** — `AppSettings` Dart sketch is incomplete:
  - Uses `bool isDarkTheme` instead of `AppThemeMode themeMode` (the
    canonical model at `03-data-models.md:588` uses the enum).
  - Lists `bool alarmOverrideSilentMode` while the canonical model
    uses `bool alarmDndOverride`.
  - Lists `int alarmGradualVolumeDuration` (default 10) vs the model
    `int alarmGradualVolumeDurationSeconds` (default 5).
  - Missing every biometric / launch-auth toggle from Q14/Q18.
  - Missing `wrongPinThreshold`, `sentryEnabled`, `telemetryOptOut`,
    `sessionLogRetentionDays`.
  Replace with the canonical sketch from `03-data-models.md:584–622`.
- **06:1144** — Schema version listed in the file as the wrong number
  in some places vs `03-data-models.md:1194` ("currentSchemaVersion (5)").

### `docs/spec/07-test-plan.md`

- **07:754** — `_step()` factory uses parameter `int repeatCount = 0`
  and passes `repeatCount: repeatCount` to ChainStep. But the canonical
  model field is `retryCount` (see test plan table at 07:1027 "ChainStep
  field: retryCount (not repeatCount)" — the file fights itself).
- **07:154, 168, 188–190, 244–245, 255–257** — Throughout test
  scenarios, the parameter is still called `repeatCount`. Renaming
  agreement is in `09-glossary.md` and `01-chain-engine.md:64`; the
  test plan never caught up.
- **07:154** — "3 misses → advance to next step" with
  `repeatCount=2`. With `retryCount=2`, the universal rule is "N+1
  total attempts" = 3 attempts, so 3rd miss → advance. Correct math,
  but the scenario uses `repeatCount=2` (old field name).
- **07:928, 949** — Spec-to-test contract: "Fake call decline counts as
  miss". Default of `declineIsSafe` is `true` (decline = disarm), so
  the test as written assumes the non-default; flag the assumed
  override or change the canonical default.
- **07:1208** — INT-005 references "engine.steps" — no such accessor
  exists in the engine API at `01-chain-engine.md:472–480`. Use
  `engine.chainSteps` or `engine.currentStep`.
- **07:1325** — Coverage matrix lists future scenarios but never
  promotes them to INT-### — drop "(future)" entries or assign a tag.

### `docs/spec/08-decisions-consolidated.md`

- **08:294** — "Built-in sounds: Siren (default), whistle, scream" —
  contradicts Q9 (08:1113: `{siren, custom}` only) and is the most
  out-of-date sound list anywhere in the spec set.
- **08:288** — "Gradual volume increase: Linear ramp over configurable
  duration (default 10 seconds)" — contradicts Q33 (08:1134: default
  5s).
- **08:376–377** — `StealthConfig` table:
  - `fakeIcon: String?` (description: "Icon asset path") — but Q20
    (08:1124) uses `StealthIconPreset.music` enum.
  - `notificationDisguise: String?` (description: "Notification title
    text default 'Music playing'") — but `03-data-models.md:978`
    declares it `bool notificationDisguise; default true`. Two
    incompatible types.
- **08:418** — "5 wrong attempts (configurable)". Default 5 is in
  `03-data-models.md:598` and confirmed at `06-settings.md:170`.
  Consistent, but the field name `wrongPinThreshold` should be cited
  here instead of just "configurable".
- **08:1109** — Q1 row in the Q-decisions index reads "DE-1 / DE-2 /
  DE-3 / DE-4 LANDED. DE-5 LANDED on Android; iOS interactive widget
  deferred." Spec 11 only documents DE-1, DE-4, DE-5 explicitly; DE-2
  and DE-3 are "landed silently" — but DE-3's fields
  (`trackingEnabled` etc) are only documented as "Spec 11 §DE-3"
  callouts in `03-data-models.md:549–551`, and §DE-3 doesn't exist in
  spec 11. Dead reference.
- **08:1140** — Changelog explicitly says "Removed `whoop` / `bell`
  alarm sounds" — but the same file still lists "whistle, scream" at
  08:294. Either delete the changelog entry or update the body.

### `docs/spec/09-glossary.md`

- **09:27** — "Distress Chain" defined again here; redundant with
  `01-chain-engine.md:1264` glossary entry. Keep one source.
- **09:72** — `ReminderTemplate` glossary entry uses `isGlobal` only.
  No mention of `isCustom`. Same dual-flag issue as 06:606.
- **09:99** — "Alarm Sound: continuous siren sound plays at max
  volume" — but max-volume is conditional on `alarmDndOverride =
  true` (default false). Glossary entry is misleading.
- **09:160** — `leapToNextEvent()` — but engine API
  (`01-chain-engine.md:658`) calls the method `leap()`. The two
  conflict on the actual name.
- **09:174** — Says biometric "may substitute" for Session End PIN —
  consistent with 03 and 06. But App PIN entry (09:173) says "No
  biometric" — also consistent. Issue is upstream
  (`10-platform-matrix.md:186`): "App PIN | 4–6 digit PIN | No
  biometric" while `06-settings.md:131` says PIN length is 4–8 digits
  (Q35-era). Spec 09 is not wrong; 10 needs an update.

### `docs/spec/10-platform-matrix.md`

- **10:99** — Gradual Volume Increase "default 10s" — wrong; default
  is 5s per Q33.
- **10:102** — "siren/beep" — outdated; should be `siren/custom`.
- **10:186** — App PIN length "4–6 digit" — outdated; per
  `06-settings.md:126` PIN length is now 4–8 (configurable per PIN at
  setup; `AppSettings.pinLength` removed).
- **10:189** — "Simulation Mode (SMS/calls blocked) — Fake call,
  vibration, reminders fire normally". Consistent with the principle,
  but "Loud alarm" should be in the "muted in sim" list — appears
  nowhere here.

### `docs/spec/11-deferred-enhancements.md`

- **11:5–8** — "DE-2 (per-event GPS) and DE-3 (interval tracking)
  LANDED silently and are no longer documented separately". But
  `03-data-models.md:549–551` cites "Spec 11 §DE-3" as the rationale
  for `trackingEnabled` / `trackingIntervalSeconds` /
  `trackingBufferSize`. §DE-3 has been removed from spec 11 — dead
  cross-reference.
- **11:74–82** — "Voice Recording Assets (14 Languages)" — TODO/asset
  production. Same TODO appears in `05-services.md:140`. Should be in
  one place to avoid divergence (file naming, languages list, etc.).

---

## Cross-spec contradictions

| # | Topic | Disagreeing sources | Reality check / decision needed |
|---|-------|---------------------|---------------------------------|
| X-1 | `fakeCall` answer: pause or non-pause? | `01:361,235` say pauses; `01:373` says event-not-pause | Pick one (Pivot 2 reads canonical) and rewrite both passages. |
| X-2 | holdButton default `gracePeriodSeconds` | `02:62`=0; `03:518`=5; `00:301`=1; Walk-Mode seed `03:1049`=1 | Pick canonical default + distinguish from seed override. |
| X-3 | Walk Mode hold grace in seed | `03:1049`=1; `01:1078`=1; `00:301`="1 sec" | Currently consistent; just clarify in 02 that seed overrides default. |
| X-4 | `LoudAlarmSound` enum | `03:450`={siren,custom}; `05:87`={siren,beep,custom}; `08:294`={siren,whistle,scream}; `10:102`={siren,beep} | Use `{siren, custom}` per Q9; purge legacy. |
| X-5 | Gradual volume default duration | `03:612`=5s; `06:259`=5s; `05:93`=10s; `08:288`=10s; `10:99`=10s | Per Q33 use 5s. |
| X-6 | `StealthConfig.notificationDisguise` type | `03:978` bool default true; `08:377` String? default "Music playing"; `00:240` "generic channel name/icon" (behavior) | Pick bool (matches model) and migrate prose. |
| X-7 | `StealthConfig.fakeIcon` type | `03:977` `StealthIconPreset` enum; `08:376` `String?` asset path | Use enum per Q20. |
| X-8 | App-Settings model sketch | `03:584-622` (canonical) vs `06:870-893` (legacy field names: `isDarkTheme`, `alarmOverrideSilentMode`, `alarmGradualVolumeDuration`) | Replace 06's sketch with 03's. |
| X-9 | `AppSettings.emergencyCallNumber` default | `03:609`="112" literal; `06:230` validator demands non-empty (no default); locale-aware mapping `03:1170` populates per-region | State precedence: blank field → seed from locale → fallback 112. |
| X-10 | `repeatCount` vs `retryCount` field name | `07:154-257, 754` use `repeatCount`; `03:304, 09:19` canonical is `retryCount` | Pre-alpha rename → `retryCount` everywhere; rip up test plan. |
| X-11 | `WalkSession.simulationSilent` default | `03:880` false; `04:534` true (Extra 49); `04:580` false; `00:203` false | Pick one; default `true` matches Extra 49 intent. |
| X-12 | `disarm()` semantics | `01:534` "re-arms to step 0, does NOT end session"; `09:15` user-facing "Tap to check in" sounds like end; `08:111` "Disarm" terms still ambiguous in user docs | Spec already converged on Q8; tighten user-facing prose. |
| X-13 | `fakeCall` decline default behavior | `02:270, 03:352` `declineIsSafe = true` (disarm); `07:928, 07:949` tests assert decline → miss; `04:1053` UI label varies | Pick canonical default and align tests. |
| X-14 | Soft-delete vs hard-delete for session logs | `03:797` says hard delete until Extra-11 lands; `06:294` says soft-delete + undo IS implemented | Pick current state. |
| X-15 | Routes — `/settings/modes-and-chains` | `04:121` REMOVED; `04:1393, 1944, 1979` still in active use; `06:13` removed | Delete the hub fully or revive the route. |
| X-16 | Hold button styles count | `02:42, 03:325, 08:120` = 3 styles; `04:1605, 04:656` = 4 styles (adds `discreteButton`) | Drop `discreteButton` or document it as a 4th option in 02/03. |
| X-17 | Template Editor route | `04:111` `/settings/templates/edit`; `04:2202` `/settings/defaults/event-defaults/templates/edit`; `08:1131` Q29 `/settings/templates/edit` | Use Q29 canonical. |
| X-18 | Onboarding page count | `00:710` "3-page"; `04:134, 138` "3 Screens"; `04:2718` "9-page guided setup" | All but 04:2718 say 3; fix the summary. |
| X-19 | `SmsRecipient` vs `SmsContactSelection` | `04:1736-1741` `SmsRecipient` sealed; `03:372` `SmsContactSelection` enum | Pick one (enum is simpler). |
| X-20 | "Distress Chain" terminology | Modes UI under Pivot 3 should say "Distress Mode"; `04:1411` "DISTRESS CHAINS", `06:157` "Distress Chains", `04:1873` "Default Distress Chain" | Global find-and-replace to "Distress Mode" except where referring to `chainSteps` of a distress mode. |
| X-21 | Spec doc index | `00:566-576` only lists 00-08; 09/10/11 exist on disk but unlisted | Add three rows. |
| X-22 | `leap()` vs `leapToNextEvent()` | `01:464, 658` `leap`; `09:160, 07:1283` `leapToNextEvent`; `04:586` "Leap" button name | Pick the API name and use everywhere. |
| X-23 | Telemetry / Sentry | `03:617` `sentryEnabled` default false; `05` no service for Sentry; `08` doesn't decide | Define `SentryService` or move flag to deferred. |

---

## Missing pieces (need definition before rewrite)

1. **`LogGpsOverride` enum** — referenced 6×; never declared. Likely
   values: `useDefault`, `forceOn`, `forceOff`. Define in `03-data-models.md`.
2. **`CountdownStyle` enum** — referenced once; never declared. Values
   exist as strings in `02:200` (`fullScreen | notification | minimal`).
   Promote to an enum in `03-data-models.md`.
3. **`DistressTrigger` / `DisarmTrigger` sealed hierarchies** — used in
   `SessionMode.distressTriggers` / `disarmTriggers` lists but no class
   shape, JSON serialization, defaults, or validation rules. The
   subclass names appear in prose only:
   - `HardwareButtonDistressTrigger` (with `RepeatPressTrigger`,
     `pressCount`)
   - `GpsArrivalDisarmTrigger` (radius, destinationSource, lat/lng)
   - `TimerDisarmTrigger` (duration)
   Each needs a schema + JSON shape + UI semantics + persistence rules.
4. **`GpsDestinationSource` enum** — appears in
   `04:530` (`promptAtStart`); no other values listed; never declared.
5. **`SessionLogRecorder` contract** — referenced in
   `03:758, 775` ("stamped by SessionLogRecorder") but no service spec
   in `05-services.md`. Where does it live, what API does it expose,
   how does it interact with the engine event stream?
6. **PIN length per-PIN storage** — `06:126` removes
   `AppSettings.pinLength` and says "each PIN's length is determined at
   setup time". But where is the per-PIN length stored? Only the hash
   is in `AppSettings`; the hash doesn't carry length. The `PinEntryDialog`
   "auto-submits as soon as the hashed value matches" — but you can't
   hash without knowing length unless you hash on every keystroke ≥ 4
   and compare against all three stored hashes. Document the algorithm.
7. **Wrong-PIN counter scope** — `06:175` "All three PIN prompts share
   the same attempt counter" — where is this counter stored? Is it
   persisted across app restart? Reset rules ("on any correct PIN
   entry" + "time-based reset") need timer specifics.
8. **Permission audit flow** — referenced in `01:923`,
   `04:464` ("ensureNotificationPermission"), and the home checklist —
   but the audit's exact lifecycle (when checked, when re-asked, what
   happens on revocation mid-session) is scattered. Needs one
   normative section.
9. **Session-restore semantics on app kill** — `01:643` "No resume
   after force-close (Extra-13): prompt user on next launch". But the
   prompt's wording, the data preserved, the UI screen, and the
   resume-restart contract are all only in prose. No screen in spec 04
   describes the "Session interrupted" prompt.
10. **Gradual-volume alarm config — global vs per-step interaction** —
    `02:437` says "ramp duration is not on LoudAlarmConfig — it lives
    globally on AppSettings.alarmGradualVolumeDurationSeconds". But
    `LoudAlarmConfig.gradualVolume` (per-step) toggles whether the ramp
    applies at all. What happens when global `alarmGradualVolume` is
    OFF but per-step `gradualVolume` is ON? Spec doesn't say.
11. **Biometric flags** — Q18 adds
    `appPinBiometricEnabled`, `sessionEndPinBiometricEnabled`,
    `distressCancelBiometricEnabled`. But `06:143` says "Biometric
    toggle kept outside AppSettings to avoid schema churn" stored in
    `SharedPreferences`. Two storage locations for the same concept —
    pick one.
12. **`distressCancelBiometricEnabled`** — flag exists in `AppSettings`
    (Q18) but no spec section describes the distress-cancel biometric
    flow (only PIN flow at `01:976`).
13. **Default-distress-mode invariant on delete** — `04:1659` "Refuses
    to delete the mode currently set as defaultDistressModeId until
    another distress mode is promoted." But what if a user deletes ALL
    distress modes? Spec is silent on the empty case.
14. **`BatteryAlertConfig.chain` step types allowed** — `04:1786`
    excludes `holdButton`, `disguisedReminder`, `hardwareButton`;
    `02:520` says "BatteryAlertConfig.chain: List<ChainStep> is executed
    through the same engine/orchestrator used for session chains".
    Neither spec encodes the type whitelist as a validation rule on
    the model.
15. **`sessionLogRetentionDuration`** (06:299) vs
    `sessionLogRetentionDays` (03:613) — two fields, one for trash
    purge (7 days fixed?) and one for log retention (default 180).
    Define both as separate fields, or merge.
16. **GoRouter route enum** — most routes are paths but route name
    `distress_modes` / `distress_mode_editor` is mentioned at
    `04:1643, 1670`. Listing of all route names (not paths) is missing.
17. **`StealthConfig.fakeIcon = StealthIconPreset.none`** —
    enum includes `none` (03:984); behavior is undocumented.
18. **`HiveRecoveryApp`** — referenced in `10:205` (Hive Key Loss
    Recovery, Extra 21) but the spec system says Hive has been
    retired. Either retire the recovery path or move it to the JSON
    repository layer.

---

## Recommended resolutions (one line each)

| # | Item | Recommendation |
|---|------|----------------|
| R-1 | fakeCall pause vs event (X-1) | Keep Pivot 2 (event, no pause). Delete all "Chain PAUSES" prose in 01:361, 02:235, 02:252, 07-test cases, 08:189. |
| R-2 | holdButton grace default (X-2) | Use `gracePeriodSeconds = 0` (per 02:62, latest user-test feedback). Walk-Mode seed keeps `1` as a deliberate override. Update 03:518 and 00:301. |
| R-3 | Alarm sound enum (X-4) | Keep `{siren, custom}` per Q9. Purge `beep`, `whistle`, `scream` from 05:87, 08:294, 10:102, 04:1610. |
| R-4 | Gradual volume default (X-5) | Use 5s per Q33. Update 05:93, 08:288, 10:99. |
| R-5 | `StealthConfig.notificationDisguise` type (X-6) | Keep `bool` per the model. Delete the `String?` line from 08:377 and the "title text" prose. |
| R-6 | `StealthConfig.fakeIcon` type (X-7) | Use `StealthIconPreset` enum per Q20. Delete the `String?` row in 08:376. |
| R-7 | AppSettings sketch (X-8) | Delete the sketch at 06:870-893 and reference 03:584-622 by link. |
| R-8 | Emergency number default (X-9) | Spec: blank ⇒ seed from device locale ⇒ fallback `'112'`. Document precedence in 06:210. |
| R-9 | `repeatCount` → `retryCount` (X-10) | Find-and-replace `repeatCount` in 07-test-plan to `retryCount`. Update `_step()` factory at 07:754. |
| R-10 | `simulationSilent` default (X-11) | Default `true` (Extra 49). Fix 03:880, 04:580, 00:203. |
| R-11 | Decline-is-safe default (X-13) | Pick canonical `declineIsSafe = true` (decline = disarm). Rewrite tests TC-49, TC-50 to use `declineIsSafe = false` explicitly or remove the "counts as miss" claim. |
| R-12 | Soft-delete logs (X-14) | Pick state-of-the-world: prefer "shipped soft-delete + 7-day trash". Remove 03:797 fallback prose. |
| R-13 | Modes & Chains hub (X-15) | Delete the `/settings/modes-and-chains` hub fully. Remove 04:1393-1419, 04:1944, 04:1979 references; the route map note at 04:121 is correct. |
| R-14 | Hold button styles (X-16) | Three styles: `largeButton`, `fullScreen`, `fakeLockScreen`. Delete `discreteButton` mock in 04:656 and the menu entry at 04:1605. |
| R-15 | Template Editor route (X-17) | Use `/settings/templates/edit` per Q29. Delete 04:2202 long route. |
| R-16 | Onboarding page count (X-18) | "3-screen onboarding". Fix 04:2718 summary. |
| R-17 | Contact selection naming (X-19) | Use `SmsContactSelection` enum (matches model). Delete `SmsRecipient` references in 04:1736-1741. |
| R-18 | "Distress Chain" terminology (X-20) | Rename UI labels and section headings to "Distress Mode(s)" except where referring to `chainSteps` of a distress mode. Update 04:1411, 04:1873, 04:1944, 04:1979, 06:157. |
| R-19 | Spec doc index (X-21) | Add rows for 09, 10, 11 to `00:566-576`. |
| R-20 | Engine `leap()` API name (X-22) | Use `leap()` (current method) everywhere. Update glossary at 09:160 and tests at 07:1283. The button label can remain "Leap >>". |
| R-21 | `LogGpsOverride` enum (Missing #1) | Add: `enum LogGpsOverride { useDefault, forceOn, forceOff }` to 03. |
| R-22 | `CountdownStyle` enum (Missing #2) | Add: `enum CountdownStyle { fullScreen, notification, minimal }` to 03. |
| R-23 | DistressTrigger / DisarmTrigger schemas (Missing #3) | Add full sealed class spec in 03 with subclass field lists. |
| R-24 | `GpsDestinationSource` enum (Missing #4) | Add to 03 with values at least `promptAtStart`. |
| R-25 | `SessionLogRecorder` service (Missing #5) | Add a service section to 05; document the engine→recorder event subscription contract. |
| R-26 | PIN length storage (Missing #6) | Add a per-PIN length field in `AppSettings` (e.g., `int? appPinLength`, etc.) OR document the multi-keystroke hash-compare algorithm explicitly. |
| R-27 | Wrong-PIN counter scope (Missing #7) | Specify: in-memory counter only; resets on correct entry; shared across all 3 prompts. Add to 06:175. |
| R-28 | Permission audit flow (Missing #8) | Add one normative subsection in 05 enumerating all check points (cold start, session start, mid-session revocation). |
| R-29 | Session-restore prompt (Missing #9) | Add a screen mock for "Session interrupted" in 04 with PIN gate, recovery buttons, and data preserved details. |
| R-30 | Gradual volume per-step × global (Missing #10) | Document: per-step `gradualVolume = true` requires both flags; if global is OFF the per-step ramp is suppressed. Add to 02:437. |
| R-31 | Biometric storage location (Missing #11) | Move biometric flags into `AppSettings` (consistent with Q18) and delete the SharedPreferences fork from 06:143. |
| R-32 | Distress-cancel biometric flow (Missing #12) | Add to 01:976 a biometric branch parallel to the PIN branch when `distressCancelBiometricEnabled = true`. |
| R-33 | Empty-distress-modes invariant (Missing #13) | Forbid deletion of the last distress mode in 04:1659 and require a non-null `defaultDistressModeId` invariant. |
| R-34 | BatteryAlertConfig step type whitelist (Missing #14) | Encode the whitelist on the model with `BatteryAlertConfig.validateChain()` and document it once in 03. |
| R-35 | sessionLogRetention fields (Missing #15) | Keep both as distinct: `sessionLogRetentionDays` (180, log-level retention) and `trashRetentionDays` (7, soft-delete grace). |
| R-36 | Route name enum (Missing #16) | Add a Route Names appendix in 04 enumerating GoRouter `name:` values. |
| R-37 | StealthIconPreset.none semantics (Missing #17) | Document: `none` ⇒ no icon override, use app icon. Add to 03:984. |
| R-38 | HiveRecoveryApp on JSON layer (Missing #18) | Either delete 10:205 reference (Hive retired) or repurpose to "JSON corruption recovery". |
| R-39 | Dead refs to spec 11 §DE-2/§DE-3 | Re-add the sections to spec 11 (short summary + "landed" tag) OR remove the cross-references in 03:549-551. |
| R-40 | `SessionLog.hadMedicalInfo` definition | Pick one of the two prose blocks (03:758 vs 03:775) and delete the other. |
| R-41 | `BatteryAlertConfig.sendSms` legacy getter (03:1024-1033) | Delete the getter and the legacy-JSON synthesis per pre-alpha policy (no migrations). Update battery-monitor service to consume `chain` directly. |
| R-42 | `06:170-175` deceptive "Old pin entered" UI | Add a screen mock + engine event + test, OR drop the spec entirely. Currently floating with no implementation hooks. |
| R-43 | Glossary deduplication (09 vs 01) | Keep `09-glossary.md` as the sole glossary; delete the in-doc glossaries from `01:1247-1267` and the duplicate "Distress Chain" entries. |
| R-44 | `00:240, 03:978, 08:377` notificationDisguise prose | Aligned to bool per R-5. |
| R-45 | Whoop/bell/scream/whistle/beep sound mentions | Already covered by R-3; one global cleanup pass after R-3. |

---

## Notes on read-only constraints honoured

- No spec files were modified.
- This document is the only new file under `docs/rewrite/` and was
  created with the parent directory pre-existing (verified via `ls`).
- All recommendations target the "cleanest pre-alpha spec" without
  introducing new features.
