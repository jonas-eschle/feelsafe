# Audit consolidation — decision questions for spec rewrite (2026-04-25)

Six parallel auditors (spec compliance, bug/quality, architecture, scenarios,
documentation, security) reviewed `lib/`, `docs/spec/`, `CLAUDE.md`, and the
Android/iOS native code. This document collapses their findings into a single
list of **decisions you need to make**. Each answer becomes a normative spec
entry and may trigger code changes.

The findings cluster into 12 themes. Each section starts with a brief snapshot
of what's broken / contradictory today, then a numbered list of questions.

---

## 1. Engine semantics — what does `disarm()` actually mean?

**Snapshot.** Spec 01 says `disarm()` resets to step 0, clears miss count,
emits `userDisarmed`, and re-executes step 0. Code (`session_engine.dart:191`)
calls `endSession(reason: EndReason.disarm)` instead — session ends; no
`userDisarmed` event is ever emitted (spec lists it; code doesn't have it).

The "I'm Safe" slider on the SessionScreen wires the user's mental model to
"end the session". The engine code matches that. The spec is stale.

There's a related expansion: spec lists 11 events; code emits 13
(`sessionStarted`, `graceExpired` are extras). Spec lists 3 `EndReason` values;
code has 8. Spec lists 2 `PauseReason` values; code has 4.

**Q1.** Should `disarm()` end the session (current code) or reset to step 0
(current spec)? — If end-session, the spec needs a rewrite of §Engine API and
§Disarm; the `userDisarmed` event should be removed.

**Q2.** Are the extra events (`sessionStarted`, `graceExpired`,
`distressTriggered`, `distressCompleted`, `pauseExpired`,
`stepExecutionFailed`) all canonical? — If yes, the spec event list needs to
go from 11 to 13 with explicit semantics for each.

**Q3.** Are the extra `EndReason` values canonical (`disarm`, `chainExhausted`,
`hardwarePanic`, `duressPin`, `wrongPinExhausted`, `userQuit`,
`appTermination`, `pauseExpired`)? — If yes, spec must enumerate all 8.

**Q4.** Same for `PauseReason` (4 in code: `userRequested`, `incomingCall`,
`fakeCallAnswered`, `bootRestart`). Canonical?

**Q5.** Spec 01 §Pause Behavior says the engine emits `pauseExpired` and
auto-ENDS on expiry. Spec 01 §Events Emitted (different paragraph) implies
auto-RESUME. Code auto-ends but the engine never emits `pauseExpired` —
the controller bypasses the event stream. Which is correct: end-on-expiry
(yes/no) and emit-from-engine vs from-controller?

**Q6.** `engine.checkIn()` exists for `disguisedReminder` steps but is **never
called** from any UI (`grep -rn '\.checkIn(' lib/`). Date Mode users have
nothing but the I'm-Safe slider, which ends the whole session. Should the
disguised-reminder notification action call `checkIn()`? Should there be an
in-app "I checked in" button that doesn't end the session?

---

## 2. Trigger system — half of it doesn't run on a real device

**Snapshot.**
- `HardwareButtonService.start()` is **never invoked** from production code.
  Volume-button panic is dead on a real device.
  (`hardware_button_service.dart:43`, `trigger_manager.dart:96-100`)
- `TriggerManager._onPanic` does not filter by configured `buttonType` /
  `pattern` / `pressCount`. Any panic event fires distress regardless.
  (`trigger_manager.dart:149-165`)
- `WrongPinThresholdDisarmTrigger` is parsed from JSON but **no code subscribes
  to it**. Wrong-PIN logic lives in a hardcoded `static const int
  wrongPinThreshold = 5` in `SessionController` (`session_controller.dart:163`),
  ignoring `AppSettings.wrongPinThreshold`. THREE sources of truth, one wins.
- Mode editor doesn't expose `disarmTriggers` (GPS arrival, timer) — those
  fields are unreachable from the UI.

**Q7.** Should `TriggerManager.start()` call
`hardwareButtonService.start(buttonType, pattern)` for each configured trigger?

**Q8.** Should `_onPanic` filter events vs `mode.distressTriggers[i]`'s
`buttonType` / `pattern` / `pressCount` / `windowMs`?

**Q9.** Three sources of truth for wrong-PIN threshold:
`AppSettings.wrongPinThreshold` (model field, configurable),
`SessionController.wrongPinThreshold = 5` (hardcoded const), and
`WrongPinThresholdDisarmTrigger.threshold` (parsed but ignored). Which is
canonical? Recommendation: keep only `AppSettings.wrongPinThreshold` (with
slider 2-10 in Security settings), delete the other two.

**Q10.** Mode editor doesn't expose `disarmTriggers`. Should it? — If yes,
spec 04 §ModeEditor needs a section. If no, those triggers are admin-only
and the `disarmTriggers` field should be removed from the user-facing mode
JSON.

**Q11.** Same for `SessionMode.pauseAllowed` and `maxPauseMinutes` — neither
is editable from UI. In or out of scope for the user-facing editor?

---

## 3. PIN / biometric / auth

**Snapshot.**
- PIN dialog only emits `PinResult.wrong` after the user types **8 digits**
  (`pin_entry_dialog.dart:170`). A 4-digit wrong PIN sits silent. Reaching
  the 5-attempt threshold takes 40 deliberate digits.
- Duress PIN is checked **before** session-end PIN
  (`pin_entry_dialog.dart:153-158`). If a user accidentally configures
  `duressPin == sessionEndPin`, every legitimate disarm fires distress.
- No app-level PIN gate at launch. Force-quit + relaunch lands on Home;
  `appPinHash` is only consulted in distress-cancel flow.
- PIN-failure threshold is per-prompt; the counter resets every time the
  dialog reopens. A patient attacker burns ~1.3 s/attempt of Argon2 offline
  (~3.6 h for 10 000 4-digit PINs once DB+passphrase are exfiltrated).
- Argon2id parameters (m=64 MiB, t=3, p=4) are nowhere in the spec. 64 MiB
  may OOM on low-end Android devices.
- "Old PIN from Angela" deceptive dialog title is hardcoded; not blended
  with active stealth disguise.

**Q12.** PIN dialog: should `wrong` be emitted at length-match (4 digits if
PIN is 4-digit) or after a Submit button, instead of waiting for 8 digits?

**Q13.** Should `setDuressPinHash` reject a value equal to `sessionEndPinHash`
or `appPinHash`? (Currently no guard.)

**Q14.** Should there be an app-launch PIN/biometric gate when `appPinHash`
is set? (Spec 06 implies it; code does not implement it.)

**Q15.** Wrong-PIN counter persistence: per-prompt (resets on close, current)
or persistent across the whole session / app lifetime? Per-prompt makes
brute force easy; persistent risks accidental lockout.

**Q16.** Argon2id parameters: keep m=64 MiB despite low-end-device OOM risk?
Document in spec 06 + decisions log either way.

**Q17.** Should the deceptive wrong-PIN dialog title adapt to the active
stealth disguise (e.g. "Old playlist from Angela" / "Old reminder from
Angela") instead of the fixed "Old PIN from Angela"?

---

## 4. Duress PIN — silent duress is not actually silent

**Snapshot.** Currently when the user enters a duress PIN, the distress chain
replaces the main chain and `_enterStep(0)` runs the first distress step
**immediately**. If the seed default distress chain starts with `smsContact`
or any step that produces audio/vibration, an observer hears/feels the SMS
notification or vibration the moment the duress PIN is pressed.

Also: the duress PIN's resulting `EndReason` is `chainExhausted`, not
`duressPin` — duress origin is lost from the session log
(`session_controller.dart:572-587`).

**Q18.** Should the first step of any distress chain triggered by
*duress PIN* be silenced for some grace period (e.g. 30s) so the observer
doesn't immediately notice? Or should the spec instead require duress chains
to start with a silent step (smsContact in background) and reject any chain
whose first step is audible?

**Q19.** Should `replaceWithDistressChain` accept a `triggerReason` and
propagate it to the eventual `sessionEnded`'s `EndReason`, so the session
log distinguishes `duressPin` / `wrongPinExhausted` / `hardwarePanic`
endings? Or should those reasons be opaquely coalesced into `EndReason.distress`
to remove forensic evidence-of-duress from the encrypted DB?

---

## 5. Fake call & disguised reminder — the navigation glue is missing

**Snapshot.**
- When the engine enters a `fakeCall` step, the `SessionScreen` does **not**
  push `RouteNames.fakeCall`. The user only hears the ringtone; there is no
  Answer/Decline UI. Strategies are firing but the screen never opens.
  (`session_screen.dart:356` only handles `holdButton`)
- "Decline with Distress" hold = 5s + haptic@800ms is hardcoded in the UI
  (`fake_call_screen.dart:27,32`) — fine. But `FakeCallConfig.declineWithDistressHoldSeconds`
  defaults to **2.0** in the model (`step_config.dart:563`) — model contradicts
  UI and spec.
- Disguised reminder: notification fires, but tapping the notification does
  not call `engine.checkIn()`.
- `SessionScreen` step label uses `currentIndex+2` instead of
  `chain.length` — always "Step 1 of 2", "Step 2 of 3"…
  (`session_screen.dart:339`)

**Q20.** Should `SessionScreen` auto-push `/fake-call` on
`stepStarted` for `ChainStepType.fakeCall`? Or should FakeCallScreen
become an inline overlay inside SessionScreen (pros: simpler routing;
cons: stealth-mode disguise harder)?

**Q21.** `FakeCallConfig.declineWithDistressHoldSeconds = 2.0` (model) vs
5s (UI). Reconcile to 5s? Or make the UI honor the model field
(per-mode configurable hold time)?

**Q22.** Notification-action wiring for disguised reminders: should the
notification's primary action call `engine.checkIn()`? Should there also
be an in-app "I checked in" button on the SessionScreen for Date Mode?

**Q23.** Step label "Step X of Y" — Y should be `chain.length`. Confirm
this is a bug to fix (vs. `currentIndex+2` being intentional for some
reason I missed).

---

## 6. Stealth — fake music player doesn't exist

**Snapshot.**
- Spec describes a "fake music player" disguise; code has no such widget.
  `sessionScreenStealth=true` only blanks the AppBar title.
- `StealthConfig` defaults are inverted vs spec:
  - `fakeName`: code 'Calendar' / spec 'Music'
  - `fakeIcon`: code is enum `StealthIconPreset.calendar` / spec is bool
  - `notificationDisguise`: code true / spec false
  - `sessionScreenStealth`: code true / spec false
  - `timerDisplay`: code bool / spec enum (normal/small/none)

**Q24.** Should the spec describe a real fake music/podcast player UI for
the session screen when stealth is active? If yes, this is substantial UI
work — what does the player look like (controls, "now playing", swipe-to-disarm)?

**Q25.** `StealthConfig` defaults: spec values, code values, or a third
option? Decide each field individually.

**Q26.** `timerDisplay`: keep the code's bool (visible / hidden) or restore
the spec's three-state enum (normal / small / none)? The bool is simpler;
the enum was for "small" being a less-conspicuous integer-only display.

**Q27.** Should the deceptive Angela dialog respect stealth mode (no
"Angela" wording when disguised as Music/Calendar)?

---

## 7. Onboarding & home — drift from spec

**Snapshot.**
- Onboarding contact form is a custom 2-field form (name + phone, channels
  hardcoded to `[MessageChannel.sms]`). Spec/CLAUDE.md says it should reuse
  `ContactFormScreen` with all fields.
- Home shows mode chips + Run button (recently changed). The previous
  spec had ChoiceChips visible immediately + Start session at the bottom;
  current matches that.

**Q28.** Should onboarding use the full `ContactFormScreen` (relationships,
channel toggles, language) or stay minimal (name + phone, SMS-only)?
Current implementation is minimal.

---

## 8. Mode editor & seed data — substantial spec drift

**Snapshot.**
- Walk Mode seed chain: spec says holdButton → fakeCall → smsContact →
  phoneCallContact → callEmergency (5 steps); code has holdButton →
  countdownWarning → loudAlarm (3 steps), no SMS or emergency call.
- Date Mode seed chain: spec says disguisedReminder (waitSeconds:1800,
  retry 1) → fakeCall → smsContact → phoneCallContact → callEmergency
  (5 steps); code has 3 steps (disguisedReminder → fakeCall → smsContact),
  `intervalSeconds:600` instead of `waitSeconds:1800`.
- Default distress chain has 3 steps; spec says 2 (smsContact +
  callEmergency, with `waitSeconds:10` on the call).
- `ChainStep.randomize` is `double` in code, `bool` in spec.
- A long list of config defaults differ between code and spec
  (LoudAlarmConfig.gradualVolume false vs true; flashLight true vs false;
  DisguisedReminderConfig.randomizeInterval false vs true;
  PhoneCallContactConfig.preSendSms false vs true, no retryCount, no
  callChannel; HardwareButtonConfig.targetStepIndex missing;
  SmsContactConfig.recordDurationSeconds 15 vs 30).

**Q29.** Walk Mode seed chain: keep the simpler 3-step chain (current code)
or restore the full 5-step chain (spec)? If 5-step, what comes after
holdButton — fakeCall first, or countdownWarning first?

**Q30.** Date Mode seed chain: similar question — 3 vs 5 steps. And the
disguised-reminder timing: `waitSeconds:1800` (spec) means a 30-min wait
between reminders; `intervalSeconds:600` (code) is a 10-min interval. Which?

**Q31.** Default distress chain: 2 or 3 steps? With or without
countdownWarning between SMS and emergency call?

**Q32.** `ChainStep.randomize`: `bool` (spec) or `double` jitter factor
(code, [0,1])? Double is more flexible; bool is simpler.

**Q33.** Each of the ~10 config-default mismatches needs a verdict (one
question for the bundle): defer to spec, defer to code, or pick a third
value?

---

## 9. Battery alert — default ON in code, OFF in spec

**Snapshot.**
- `BatteryAlertConfig.enabled` defaults `true` in code; spec 03/06 say
  default OFF.
- `thresholdPercent` defaults 15 in code; spec says 10.
- The watcher in `main.dart` only runs once at launch with a snapshot
  config; toggling ON in Settings doesn't arm it until the next app
  restart.

**Q34.** Default battery alert ON (current code, more safety) or OFF
(spec, fewer false positives)?

**Q35.** Default threshold 10% (spec) or 15% (code)?

**Q36.** Should the watcher re-arm on `batteryAlertController` changes
(via `ref.listen`) so toggling in Settings takes effect immediately?

---

## 10. Storage layer — spec describes Hive, code uses Drift

**Snapshot.** Spec 03 §Storage Architecture describes Hive CE + HiveAesCipher
with typeIds 0–19, schemaVersion 5, and `JsonSingletonRepository` /
`JsonListRepository` classes. None of that is in the codebase. The
codebase is 100% Drift + SQLite + SQLCipher (`drift: ^2.32.0`,
`lib/data/db/app_database.dart`, schema v1, DAO-backed repositories).
CLAUDE.md repeats the Hive description.

**Q37.** Confirm: the storage layer is Drift-and-SQLCipher and the spec
should be rewritten to describe that. (I'm 99% sure this is the answer
but want explicit confirmation since the spec rewrite touches many
spec files and CLAUDE.md.)

---

## 11. Security & privacy — multiple hardening gaps

**Snapshot (P0 / P1):**
1. `flutter_secure_storage` uses default Android backend
   (`encryptedSharedPreferences=false`), so the SQLCipher passphrase and
   telemetry-opt-out flag are stored in soft-Keystore-wrapped
   SharedPreferences. Recoverable on rooted devices.
2. AndroidManifest is missing `android:allowBackup="false"` / no
   `dataExtractionRules`. `adb backup` extracts everything.
3. No `FLAG_SECURE` on the session / fake-call / PIN screens. Recents
   thumbnails capture the session UI; screen-recording is allowed.
4. WorkManager `workdb` (plain SQLite, NOT SQLCipher) stores full distress
   SMS body + recipient for up to 10 retries.
5. Sentry is opt-IN by default (default flag = false, telemetry on). May
   not be GDPR-compliant for the EU-host target.
6. Sentry DSN is a `const String` literal in source — supply-chain risk.
7. `SessionLog.endReason` persists `duressPin` / `wrongPinExhausted` —
   forensic adversary who breaks SQLCipher sees exactly which sessions
   ended via duress.
8. iOS `Info.plist` is missing `NSFaceIDUsageDescription` — biometric
   prompts may fail on Face ID devices.
9. SMS template default `'{name} may need help. Location: {location}.
   Time: {time}.'` — `{location}` is never resolved (always empty).
   Recipient gets "Location: ." trailing the message.
10. Quick Exit IS implemented in `SystemUiService.quickExit` despite the
    spec saying "explicitly NOT a feature".

**Q38.** Switch to `AndroidOptions(encryptedSharedPreferences: true)` for
flutter_secure_storage? (One-line change.)

**Q39.** Add `android:allowBackup="false"` to release manifest?

**Q40.** Add `FLAG_SECURE` to session / fake-call / PIN screens during
sensitive moments? (Trade-off: blocks user from screenshotting their own
session for evidence.)

**Q41.** Encrypt SMS body in WorkManager `workdb` (encrypt at enqueue,
decrypt in `doWork()`), or shorten retry count from 10 → 3 to bound
exposure window?

**Q42.** Sentry: switch to opt-OUT (default off)? Required for GDPR
compliance in EU.

**Q43.** Sentry DSN: ship as build-time constant from `--dart-define`
instead of a source literal?

**Q44.** `SessionLog.endReason` for duress: persist exact reason (current,
helps user in court) or coalesce to opaque `distress` (safer if DB is
breached)?

**Q45.** Add `NSFaceIDUsageDescription` to iOS Info.plist?

**Q46.** Distress SMS `{location}` placeholder: plumb `services.context.lastLocation`
through (recipient gets actual GPS) or remove `{location}` from the
default template (no leak, but rescuer has no location)?

**Q47.** Quick Exit: spec says NOT a feature; code implements
`finishAndRemoveTask` via `SystemUiService.quickExit`. Remove the code
or update the spec to acknowledge it ships? — Note: `finishAndRemoveTask`
does NOT wipe data; it just closes the task. If the spec intent was a
data wipe, the code is wrong.

---

## 12. Architecture refactors

**Snapshot.**
- `SessionController` is 1026 LOC with 6+ concerns (engine assembly,
  service resolution, PIN gating, lifecycle observer, distress
  orchestration, emergency-confirm broadcast, background-disarm broadcast,
  pause/resume timer, battery-alert sub-pipeline).
- `lib/data/models/enums.dart` holds domain vocabulary (`ChainStepType`,
  `ConfirmationType`, `ReminderDisplayStyle`) but lives in the data layer.
  16+ domain files import from `data/`.
- `BatteryMonitorService` is the only stream-owning service whose provider
  doesn't `ref.onDispose` — leaks on container reset.
- `step_config.dart` is 1363 lines (9 sealed-class subtypes, each with
  fromJson/toJson/copyWith/==/hashCode).
- `ModeOverrides.distressChainId` duplicates `SessionMode.distressChainId`
  — one of them is dead.

**Q48.** Split `SessionController` into smaller controllers
(`SessionLifecycleController`, `PinGateController`, `DistressOrchestrationController`,
`BatteryAlertController`)? — The current "single-owner" rule (file
header) intentionally keeps it monolithic; reversing is a clear decision.

**Q49.** Move `lib/data/models/enums.dart` → `lib/domain/models/enums.dart`?
This is a low-risk refactor (16+ import-path updates) that fixes the
layer-direction inversion.

**Q50.** Add `ref.onDispose(() => service.dispose())` for
`BatteryMonitorService`? (Should be a 2-line fix in `service_providers.dart`.)

**Q51.** Split `step_config.dart` into one file per subtype? Pros: each
subtype becomes diff-friendly. Cons: the exhaustive-switch audit gets
spread across 9 files.

**Q52.** Delete `ModeOverrides.distressChainId` (keep only the canonical
`SessionMode.distressChainId`)?

---

## 13. Documentation drift

**Snapshot.**
- CLAUDE.md says Hive (× 4 places); reality is Drift.
- CLAUDE.md says 24 screens; 32 exist.
- 9 decision IDs (`D-SEC-5`, `D-SEC-10`, `D-SAFETY-6/7/11/17`, `D-UX-4`,
  `D-DATA-7`, `D-DATA-21`) cited in 14+ places under `lib/` live ONLY
  in `docs/decisions-log.md`, not `docs/spec/08-decisions-consolidated.md`.
- Spec 03 contradicts itself: `FakeCallConfig.callerName` says "Angela"
  at line 339 and "Mom" at line 507.
- `docs/SPEC_INDEX.md` and 4 review docs linked to a phantom
  `docs/spec/<rewrite-decisions>.md` filename that does not exist.
  Canonical home is `docs/spec/08-decisions-consolidated.md`.
- Phase tags in TODOs (`Phase 15.1`, `phase-4b`) reference a phase plan
  no longer present in the spec.

**Q53.** CLAUDE.md rewrite mandate: rewrite to describe Drift, the actual
32 screens, and the actual file paths? (I'd say obviously yes.)

**Q54.** Decision IDs: import the 9 missing entries from
`decisions-log.md` into `08-decisions-consolidated.md`? Or have code
comments link to `decisions-log.md` instead?

**Q55.** Spec 03 internal contradictions (callerName "Angela" vs "Mom"):
which is canonical? (Code uses "Angela".)

**Q56.** Stale references to the phantom rewrite-decisions filename:
delete those links / update to `08-decisions-consolidated.md`?

**Q57.** Phase tags in TODOs: replace with decision IDs (e.g.
`TODO(D-SEC-13)`) or remove?

---

---

## 14. Bugs revealed by integration tests (1044 tests written)

These are not decision questions — they are clear bugs that should be fixed
during the rewrite. Listed for traceability.

**B1.** `lib/domain/engine/session_engine.dart:344` — `final declineIsSafe =
cfg is FakeCallConfig ? cfg.declineIsSafe : false;`. When a `fakeCall`
ChainStep has `config: null`, the engine falls back to `false`, but
`FakeCallConfig()`'s default is `true`. Decline of a null-config fake call
is incorrectly counted as a miss. Fix:
```dart
final declineIsSafe = (cfg is FakeCallConfig
    ? cfg : const FakeCallConfig()).declineIsSafe;
```

**B2.** `lib/features/session/session_controller.dart` —
`_handleEngineEvent`'s `sessionEnded` branch persists the log but never
calls `_disposeRuntime()`. Result: `_runtime` stays non-null after
`disarm()` / `chainExhausted` / etc., and a second `startSession()` in
the same `ProviderContainer` throws `StateError("A user session is
already running")`. Users would have to restart the app between sessions.
Fix: call `_disposeRuntime()` after persisting the log.

**B3.** `lib/features/session/session_controller.dart`
`_fireDistressBecauseOfPin` — `await onAngelaDeceptiveDialog!()` is not
wrapped in try/catch. If the dialog callback throws (OS dismisses dialog,
navigator pop race), the exception escapes unhandled and the distress
chain may not fire. The safety-critical path must not be gated on UI
side effects. Fix:
```dart
if (onAngelaDeceptiveDialog != null) {
  try { await onAngelaDeceptiveDialog!(); }
  catch (_) { /* dialog errors must NOT abort distress */ }
}
```

**B4.** Pre-existing test failure surfaced by W2: `Wrong PIN at 8 digits
resolves with PinResult.wrong` — see Q12 (PIN dialog only emits `wrong`
after 8 digits typed; needs a length-match or Submit button).

**B5.** `TriggerManager` has a `batteryMonitorService` constructor
parameter it never subscribes to. Either remove the parameter or make
the manager take ownership of the battery-alert pipeline (currently
lives in `SessionController.startBatteryAlertSession`).

---

## How to use this document

1. Walk through each numbered question.
2. For each, give a one-line answer (or "defer" / "no opinion").
3. Once answered, the spec rewrite picks up your decisions and rewrites
   the affected sections normatively.
4. Code changes follow from the spec, not the other way around.

The 5 background integration-test writers (1000+ realistic strict tests)
are still running. Their failure reports will surface incremental
behavior gaps — those will be appended to this document under a separate
"Q58–QXX" section once they finish.
