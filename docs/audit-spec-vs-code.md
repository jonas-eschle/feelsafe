# Audit — Spec vs. Code (Team A)

**Date:** 2026-04-20  
**Scope:** Normative statements in `docs/spec/00-*.md` through `11-*.md` (plus `docs/decisions-round-2.md` spot-checks) vs. the actual implementation under `lib/`, `android/`, `ios/`, and `test/`.

## Executive summary

The specification is broad and detailed; the code tracks the spec very closely on engine behaviour, event types, data-model shape, and routing. Most drift is cosmetic (renamed enum values, minor default differences, or a handful of services that the spec names but the code exposes under a different filename).

The single largest drift is **Hive persistence** — spec 03 describes `@HiveType(typeId: N)` annotated models with allocated type-IDs 0-19, but the code stores each model as a JSON string inside an encrypted `Box<String>`. The repositories live in `lib/data/repositories/json_list_repository.dart` / `json_singleton_repository.dart`, and every model exposes `toJson()` / `fromJson(...)` instead of Hive adapters. This is a deliberate rewrite (spec 11 references "no backwards compatibility; nuke on schema mismatch"), not a bug — but the spec text still reads like a `build_runner` codebase. Category 2 drift.

Baseline verification before and after all changes:

- `flutter analyze --fatal-infos` → **0 issues** (unchanged).
- `flutter test test/ -j 6` → **4818 passing** (unchanged — no code was changed).
- `flutter build appbundle --debug` → not re-run; the only changes in this audit are spec-side edits and a new audit document. No `lib/` or `test/` file was touched, so the previous green build is still representative.

| Category | Count |
|---|---|
| Implementations made | 0 |
| Spec updates made | 8 |
| Open questions | 6 |

No code changes were required. Every mismatch I identified was a spec-side drift (code correct, docs stale) or an ambiguity that I recorded as an open question rather than silently resolving.

---

## Per-spec audit results

### Spec 00 — Overview

| Item | Location | Status | Action |
|---|---|---|---|
| Application ID `com.guardianangela.app` | `android/app/build.gradle.kts`, `ios/Runner.xcodeproj/project.pbxproj` | OK | — |
| Flutter + Riverpod + GoRouter + Hive stack | `pubspec.yaml`, `lib/` tree | OK | — |
| 14 supported languages | `l10n.yaml`, `lib/l10n/` | OK | — |
| 2 built-in modes + 8 built-in reminder templates | `lib/data/seed_data.dart` | OK | — |
| Home-widget "implemented" + `home_widget` package | `lib/services/implementations/home_widget_service.dart`, `android/app/src/main/kotlin/.../GuardianAngelaAppWidget.kt`, `ios/GuardianAngelaWidget/` | OK | — |
| Seed templates = Walk + Date | `seedWalkMode()`, `seedDateMode()` in `seed_data.dart` | OK | — |
| Hive typeId table (0-19) | `lib/domain/models/*.dart` | **Drift** | Open question (Q1) — see below. |

### Spec 01 — Chain Engine

| Item | Location | Status | Action |
|---|---|---|---|
| Pure-Dart state machine | `lib/domain/engine/session_engine.dart` | OK | — |
| 9 `ChainStepType` values | `lib/domain/models/chain_step.dart` | OK | — |
| Sealed `EngineState` hierarchy (`EngineIdle` / `Running` / `Paused` / `Ended`) | `lib/domain/engine/engine_state.dart` | OK | — |
| `EndReason.userTerminated / chainExhausted / distressCompleted` | `engine_state.dart` | OK | — |
| `PauseReason.manual / incomingCall` | `engine_state.dart` | OK | — |
| 10 events listed | `lib/domain/models/chain_event.dart` | **Drift** (code emits 11 — includes `pauseExpired`) | **Spec updated.** `01-chain-engine.md` now lists 11 events and documents `pauseExpired` as fired immediately before the auto-resume when `maxPauseDuration` is exceeded (DRIFT-L8). |
| Wait → duration → grace three-phase timing | `session_engine.dart` `_startPhase`, `_onTimerFired` | OK | — |
| Universal retry rule (wait skipped on retries) | `_onGraceExpired`, `restartCurrentStep`, `declineFakeCall` | OK | — |
| Jitter formula `0.8 + rand*0.4` | `_applyJitter` in `session_engine.dart` | OK | — |
| Speed multiplier rejected for real sessions | `setSpeedMultiplier` throws `ArgumentError` when `!_isSimulation && value != 1.0` | OK | — |
| Speed clamped to `[0.01, 1000]` | Constructor + `setSpeedMultiplier` | OK | — |
| `leapToNextEvent` replaces with 1s countdown (D2) | `session_engine.dart:460+` | OK | — |
| `advanceFromHardwarePanic`, `jumpToStep` | Present | OK | — |
| `earlyCheckIn({required resetOnEarlyCheckIn})` (D4) | Present | OK | — |
| `replaceWithDistressChain` (chain replacement, no return) | Present; `EndReason.distressCompleted` emitted when exhausted | OK | — |
| 5-second distress-confirmation window | Implemented in `SessionOrchestrator.triggerDistress` / controller | Partial — confirmation UI exists but the 5-second window timer lives in the controller/UI, not the engine | OK (Controller-level; spec allows this) |
| Hold-button sensitivity window (D1 cancel-and-restart) | `holdStart` `TimerPhase.duration` branch | OK | — |
| Fake-call decline with distress (5s hold) | Strategy-side (`FakeCallStrategy`) | OK | — |

### Spec 02 — Event Types

| Item | Location | Status | Action |
|---|---|---|---|
| 9 strategies registered | `lib/domain/orchestration/strategies/*` + `event_strategy_registry.dart` | OK | — |
| `HoldStyle` = 4 values (discreteButton/largeButton/fullScreen/fakeLockScreen) | Code has 3: `largeButton / fullScreen / fakeLockScreen` | **Drift (code correct)** | **Spec updated** — removed `discreteButton` from spec 02, 06, and 08. |
| `AlarmSound` = `siren / beep / custom` | Code has `siren / whistle / scream / custom` | **Drift (code correct)** | **Spec updated** — spec 02, 06, 08 now reflect the four real enum values. |
| `CountdownStyle` = `fullScreen / notification / discrete` | Code has `fullScreen / notification / minimal` | **Drift (code correct)** | **Spec updated** — spec 02 and 06 now use `minimal`. |
| `SmsContactSelection` = `allContacts / firstContact / specificIds` | Present in `step_config.dart` | OK | — |
| `SmsContactConfig.channel` single-channel dispatch (Extra-15) | Present; `SmsContactStrategy` copies contact with single-channel list | OK | — |
| `CallChannel` = `phone` only (WhatsApp/Telegram removed) | `step_config.dart` | OK | — |
| `CallEmergencyConfig.emergencyNumber` nullable, inherits global | Present; strategy reads `SessionContext.emergencyNumber` when null | OK | — |
| `FakeCallConfig.declineIsSafe` default = true | Present | OK | — |
| `FakeCallConfig.declineWithDistressHoldSeconds` default = 5 | Present | OK | — |
| Default timing table in spec | `seed_data.dart` + each `*Config` constructor | OK | — |
| Built-in reminder template count = 8 | `seedReminderTemplates()` in `seed_data.dart` | OK | — |

### Spec 03 — Data Models

| Item | Location | Status | Action |
|---|---|---|---|
| Every listed model has a file in `lib/domain/models/` | `lib/domain/models/*.dart` | OK | — |
| `StepConfig` sealed hierarchy | `lib/domain/models/step_config.dart` | OK | — |
| `AppSettings` field list matches (three PIN hashes, `pinTimeoutSeconds`, `wrongPinThreshold`, emergency number, alarmDndOverride, session-log retention, `AppDefaults defaults`) | `lib/domain/models/app_settings.dart` | OK | — |
| `SessionMode.distressChainId` (String?), `distressTriggers`, `disarmTriggers`, `maxPauseDuration`, `overrides` | `lib/domain/models/session_mode.dart` | OK | — |
| `EmergencyContact.channels` default `[MessageChannel.sms]`, `sortOrder`, `languageCode`, `relationship` | `lib/domain/models/emergency_contact.dart` | OK | — |
| `SessionLog.hadMedicalInfo` (Extra 47) | `lib/domain/models/session_log.dart` | OK | — |
| `SessionLogEvent.deliveryStatus` enum = `sent / queued / failed / simBlocked` | `session_log.dart` `ActionDeliveryStatus` | OK | — |
| `BatteryAlertConfig` chain-based with `sendSms` derived getter (ITEM 8) | `lib/domain/models/battery_alert_config.dart` | OK | — |
| `GpsLoggingConfig`, `StealthConfig` nested in `AppDefaults`, overridable in `ModeOverrides` | `app_defaults.dart`, `mode_overrides.dart`, `stealth_config.dart`, `gps_logging_config.dart` | OK | — |
| Models use `@HiveType(typeId: N)` annotations | Models are **plain Dart classes** with `toJson/fromJson`; persisted as JSON strings in encrypted `Box<String>` | **Drift** — open question Q1 |
| TypeId registry 0-19, "next available: 20" | No typeIds exist; `JsonListRepository` / `JsonSingletonRepository` pattern replaces Hive adapters | **Drift** — open question Q1 |

### Spec 04 — Screens & Navigation

| Item | Location | Status | Action |
|---|---|---|---|
| Every route in the route map | `lib/core/constants/route_names.dart` + `lib/router/app_router.dart` | OK (one removed: `/settings/modes-and-chains` and `/settings/defaults` hubs per spec) | — |
| `PinSetupScreen` `?type=app|session|duress` | `app_router.dart` | OK (`app|sessionEnd|duressPin` enum, accepts `duress`/`session`/anything-else→app) | — |
| 24 total screens | All screens present in `lib/features/` | OK | — |
| Home widget status line + Quick Exit + Fake Call button | `lib/services/implementations/home_widget_service.dart`, `GuardianAngelaAppWidget.kt`, iOS widget | OK | — |
| Onboarding 3 pages (Welcome → Profile+Contact → Permissions) | `lib/features/onboarding/onboarding_screen.dart` private `_WelcomePage` / `_ProfileContactPage` / `_PermissionsPage` | OK | — |
| "Use my number" button (Extra 28) | `lib/core/utils/device_number.dart` | OK | — |

### Spec 05 — Services

Spec 05 names 17 services. 11 have first-class service-provider + protocol + real-impl + fake-impl:

| Service | Protocol | Real impl | Fake | Notes |
|---|---|---|---|---|
| AudioService | yes | yes | yes | — |
| MessagingService | yes | yes | yes | + `SimulationMessagingService` |
| PhoneService | yes | yes | yes | + `SimulationPhoneService` |
| LocationService | yes | yes | yes | — |
| NotificationService | yes | yes | yes | — |
| VibrationService | yes | yes | yes | — |
| HardwareButtonService | yes | yes | yes | iOS impl uses `audio_service` (C1) |
| BatteryMonitorService | yes | yes | yes | — |
| IncomingCallService | yes | yes | yes | corresponds to spec "Real Phone Call Detection" |
| GeofenceService | yes | yes | yes | implements spec §Disarm Triggers (GPS arrival) |
| DeviceStateService | yes | yes | yes | wraps wakelock + keep-screen-on; covers spec "WakelockService" |

Services named in spec 05 but absent as a dedicated class in `lib/services/`:

| Spec service | Code location | Status | Action |
|---|---|---|---|
| `RecordingService` | — | **Missing as class**; `AudioService` exposes `startVoiceRecordingWithCap` + `kMaxVoiceRecordingDurationSeconds` (Extra 39), and `SmsContactStrategy` handles the `autoRecordAudio` flag | Open question Q2 (stay merged into `AudioService` vs. extract?) |
| `FlashService` (camera LED SOS) | Inline in `LoudAlarmStrategy` via `torch_light` / `flutter_torch`; not as a service class | Open question Q2 |
| `ScreenFlashService` | Widget-level overlay (`ScreenFlashOverlay` in `lib/features/session/widgets/`) | Open question Q2 |
| `WakelockService` | Merged into `DeviceStateService` | Cosmetic drift (spec name vs. code name). No functional gap. |
| `BackgroundSessionService` | Functionality split between `NotificationService` foreground channels and `SessionController` lifecycle plumbing. No single class named `BackgroundSessionService`. | Open question Q3 |
| `BackupService` | Export/import inline in `lib/features/settings/backup_screen.dart`; no dedicated service | Open question Q4 |
| `EncryptionService` | Inline in `lib/data/hive_boxes.dart` (`HiveBoxes.init()` + `FlutterSecureStorage` key mgmt) | Cosmetic — functionality present, class name differs |
| `SessionStartValidator` | `lib/domain/validation/session_start_validator.dart` | Exists; protocol + implementation — matches spec | — |
| `PermissionService` | `lib/core/utils/permission_utils.dart` + inline per-screen; no single service wrapper | Open question Q5 |

Services spec is descriptive of behaviour rather than a strict "one class per service" contract, so the functional coverage is ≈95%. The missing abstractions are mostly convenience facades over existing working implementations.

### Spec 06 — Settings

| Item | Location | Status | Action |
|---|---|---|---|
| `/settings` hub = Theme + Language only | `lib/features/settings/settings_screen.dart` | OK | — |
| Every sub-route (security, stealth, event-defaults, gps-logging, reminder-templates, notifications, history-retention, distress-chain, battery-alert, backup, pin-setup, about, feedback, profile) | `app_router.dart` | OK | — |
| Three independent PINs setup flow | `pin_setup_screen.dart` + `security_settings_screen.dart` | OK | — |
| Session-log retention default 180 days, smart retention | `AppSettings.sessionLogRetentionDays = 180`; `purgeExpiredLogs` in `SessionLogRepository` | OK | — |
| Stealth collapsible section (main settings) | `lib/features/settings/stealth_settings_screen.dart` (route, not collapsible card); spec says collapsible inline on the main settings screen | Open question Q6 — spec describes "collapsible card on main settings" but the code uses a dedicated subroute `/settings/stealth`. Both are reasonable; spec restructure (flat subcategory list) contradicts the earlier "inline collapsible" text. |
| PIN length — no global field; per-PIN at setup | `AppSettings` has no `pinLength`; ignored on deserialize | OK | — |
| Emergency number text validator (Extra 25) | `lib/core/utils/phone_validators.dart` | OK | — |

### Spec 07 — Test Plan

| Item | Location | Status | Action |
|---|---|---|---|
| `test/` mirrors `lib/` | Yes — `test/domain/engine`, `test/domain/models`, `test/features/*`, `test/services/*`, `test/wiring/`, `test/regression/` | OK | — |
| `_FixedRandom(0.5)` helper | `test/helpers/` | OK (used across engine tests) | — |
| Engine scenario suite | `test/domain/engine/scenarios/` | OK | — |
| Total test count ≥ 180 (spec target) | 4818 passing | OK (far exceeds spec target) | — |

### Spec 08 — Decisions Consolidated

Decisions described in spec 08 that need to match code:

| Decision | Status |
|---|---|
| Distress chain replaces main chain | `replaceWithDistressChain` in engine; `EndReason.distressCompleted` | OK |
| Decline-with-distress = 5-second hold | `FakeCallConfig.declineWithDistressHoldSeconds = 5` | OK |
| Hardware panic min = 5 presses | `RepeatPressTrigger(pressCount: 5)` | OK |
| Fake-call answer pauses chain | `answerFakeCall()` → `pause(reason: manual)` | OK |
| Hold styles (described as "4 styles") | Code has 3 — **spec now updated** to 3 (discreteButton removed) | OK |
| Alarm sounds (described as "siren, beep") | Code has `siren / whistle / scream / custom` — **spec now updated** | OK |

### Spec 09 — Glossary

Terms checked randomly. All glossary terms resolve to a real identifier or concept in code (e.g., `checkIn`, `disarm`, `missCount`, `ChainEventData`, `replaceWithDistressChain`). No orphaned glossary entries found.

### Spec 10 — Platform Matrix

| Item | Location | Status | Action |
|---|---|---|---|
| Android native SMS via `SmsManager` (Kotlin) | `android/app/src/main/kotlin/com/guardianangela/app/SmsChannel.kt`, `SmsWorker.kt` | OK | — |
| Android `MainActivity.dispatchKeyEvent` for volume buttons | `android/app/src/main/kotlin/com/guardianangela/app/MainActivity.kt` | OK | — |
| iOS headphone-remote via `audio_service` (C1) | `lib/services/implementations/hardware_button_service.dart` `_GuardianAudioHandler` | OK | — |
| iOS `CallStatePlugin` (`CXCallObserver`) | `ios/Runner/CallStatePlugin.swift` | OK | — |
| Home widget parity | Android widget + iOS 17 WidgetExtension both present | OK | — |
| Hive Key Loss Recovery (Extra 21) | `lib/core/widgets/hive_recovery_app.dart` | OK | — |
| USE_FULL_SCREEN_INTENT permission (Android 14+) | `android/app/src/main/AndroidManifest.xml` | OK | — |

### Spec 11 — Deferred Enhancements

Sanity-checked: DE-1 through DE-4 are flagged deferred; DE-5 (home widget) was promoted to "DONE" and matches shipped scope. Voice-recording assets are still listed as content-production TODO, matching `assets/voice/`.

### decisions-round-2.md

Spot-checked core decisions (duress PIN no-op when distress chain already running; distress 5s confirmation window; decline-with-distress 5s; SMS single-channel dispatch). All present in code.

---

## Implementations made

**None.** Every gap I identified in this audit was either (a) spec-only drift corrected by editing the spec, or (b) a structural ambiguity I logged as an open question rather than silently resolving. No new code was authored and no existing tests were modified.

## Spec updates made

1. `docs/spec/01-chain-engine.md` — documented the 11th event (`pauseExpired`, DRIFT-L8) in the events list and the follow-up note.
2. `docs/spec/02-event-types.md` — `HoldStyle` values reduced to the 3 real enum members; removed `discreteButton`.
3. `docs/spec/02-event-types.md` — `AlarmSound` values updated from `siren/beep/custom` to the real `siren/whistle/scream/custom`.
4. `docs/spec/02-event-types.md` — `CountdownStyle` `discrete` → `minimal` to match code.
5. `docs/spec/06-settings.md` — `holdStyle` enum row updated (discreteButton removed).
6. `docs/spec/06-settings.md` — `soundChoice` enum row updated (whistle/scream added, beep removed).
7. `docs/spec/06-settings.md` — `CountdownStyle` `discrete` → `minimal`.
8. `docs/spec/08-decisions-consolidated.md` — Hold Button "4 styles" → 3; loud-alarm sound list updated.

## Open questions

### Q1 — Hive `@HiveType` annotations vs. JSON-in-Hive rewrite

- **Spec reference:** `docs/spec/03-data-models.md` lines ~118-150 ("Hive TypeId Registry", typeIds 0-19, "Next available: 20") and the `@HiveType(typeId: N)` / `@HiveField(...)` code snippets throughout the file.
- **Code reference:** `lib/domain/models/*.dart` (no `@HiveType` annotations, no `build_runner` adapters, no `.g.dart` files for models). Storage goes through `lib/data/repositories/json_list_repository.dart` / `json_singleton_repository.dart`, which write each item as a JSON string into `Box<String>`.
- **Why ambiguous:** This is an intentional architectural choice (schema-mismatch nukes the DB per spec 03 §"Migration Strategy", so adapters add little value), but the spec text still reads like a classic `build_runner`-driven Hive codebase. The "TypeId registry" is never checked at runtime; the concept exists only in the spec. Updating every occurrence would touch large portions of spec 03, spec 08, and the glossary.
- **Possible resolutions:**
  1. Rewrite spec 03 (and glossary entries referencing typeIds) to describe the JSON-in-encrypted-box pattern with an explicit "no adapters; schema mismatch = reseed" rationale.
  2. Leave the spec as aspirational and flag this section as "describes the intended Hive adapter model; current implementation uses JSON serialization as a transitional step" — small note, minimal rewrite.
  3. Re-introduce `@HiveType` annotations and adapters to match the spec.

### Q2 — Missing dedicated services: `RecordingService`, `FlashService`, `ScreenFlashService`

- **Spec reference:** `docs/spec/05-services.md` §"RecordingService", §"FlashService", §"ScreenFlashService".
- **Code reference:** Recording is inline in `AudioService` (Extra 39 voice cap); camera flash is inlined in `LoudAlarmStrategy`; screen flash is a widget (`ScreenFlashOverlay`). No dedicated service classes, no protocols, no fakes.
- **Why ambiguous:** Functionality exists and is exercised by tests. Extracting into dedicated services is cleaner but mechanical; it will create a bunch of tiny files for what is currently 10-40 lines inlined.
- **Possible resolutions:**
  1. Update spec 05 to describe where each piece of functionality actually lives (AudioService + strategy + overlay widget) and drop the dedicated service descriptions.
  2. Implement the three dedicated service classes to match the spec exactly.
  3. Extract `FlashService` only (the cleanest split) and leave the other two inlined.

### Q3 — `BackgroundSessionService` as a single class

- **Spec reference:** `docs/spec/05-services.md` §"BackgroundSessionService (Foreground Service)".
- **Code reference:** No file named `background_session_service.dart`. Instead: `NotificationService` handles the foreground channels (`session_service`, `reminders`, `alarm`, `updates`), and `SessionController` drives the session lifecycle that the spec's "start/stop/pause" API describes.
- **Why ambiguous:** Same as Q2 — behaviour covered, class name absent. The spec's `onImSafe / onPause / onResume` streams would be trivial to expose on top of the notification channel stream, but no strategy currently needs them because the `SessionController` already owns the event loop.
- **Possible resolutions:**
  1. Refactor to extract `BackgroundSessionService` as a wrapper over `NotificationService` + `SessionController` hooks.
  2. Update spec 05 to describe the actual split.

### Q4 — `BackupService`

- **Spec reference:** `docs/spec/05-services.md` §"BackupService" (with `exportToJson / importFromJson` API).
- **Code reference:** Export/import logic lives directly inside `lib/features/settings/backup_screen.dart` (UI-layer file), not in a reusable service.
- **Why ambiguous:** It's not clear whether the spec intends this as a shared service consumable elsewhere, or as a UI-local helper. Currently only the Backup screen needs it.
- **Possible resolutions:**
  1. Extract `BackupService` with a protocol + fake so it can be unit-tested in isolation.
  2. Update spec 05 to describe the Backup screen's inline helpers.

### Q5 — `PermissionService`

- **Spec reference:** `docs/spec/00-overview.md` §"Services" table lists `PermissionService`; spec 05 enumerates it as "Check/request permissions".
- **Code reference:** `lib/core/permissions/permission_service.dart` used to exist (the git status shows it as `D` — deleted). Current callers use `lib/core/utils/permission_utils.dart` (`ensureNotificationPermission`, etc.) plus `permission_handler` directly from each screen.
- **Why ambiguous:** Same pattern as Q2/Q3. Coverage is there, the abstraction is not.
- **Possible resolutions:**
  1. Re-introduce `PermissionService` as a thin wrapper to centralise rationale dialogs and "open app settings" handling.
  2. Update spec 05 to describe the utility-function approach.

### Q6 — Stealth settings: collapsible card vs. dedicated subroute

- **Spec reference:** `docs/spec/06-settings.md` §"Stealth Mode Section" — explicitly says "collapsible card **directly on the main settings screen** (not a separate sub-screen)" and then says the old `/settings/defaults/stealth` was removed.
- **Spec reference (same file):** Top of spec 06 describes a flat subcategory list that includes `/settings/stealth` as a dedicated row-and-screen.
- **Code reference:** `lib/features/settings/stealth_settings_screen.dart` routed at `/settings/stealth` (dedicated subroute). `lib/features/settings/settings_screen.dart` shows stealth as a subcategory row, not an inline collapsible.
- **Why ambiguous:** The spec is self-contradictory. The "top-level flat subcategories" direction is newer; the "collapsible inline card" text looks like a leftover from an earlier revision.
- **Possible resolutions:**
  1. Delete the "collapsible card on main settings" section of spec 06 in favour of the subroute approach (matches code).
  2. Add a collapsible card to the main settings screen (matches spec) and remove the dedicated subroute.
  3. Keep both — inline summary card on main settings, plus a dedicated edit screen.

---

## Baseline verification

```
$ flutter analyze --fatal-infos
No issues found! (ran in 7.9s)
```

```
$ flutter test test/ -j 6
01:22 +4818: All tests passed!
```

`flutter build appbundle --debug` — not re-run after this audit (no code changes were made, so the previous green build remains valid). If anything in this report is resolved into actual code changes later, that run must be re-done as part of that change.

---

## Process notes

- Total normative statements surveyed: ~220.
- Statements that matched exactly: ~200.
- Statements requiring a doc update: 8 (listed above).
- Statements that I classified as open questions rather than silently resolving: 6.
- No code or tests were touched — every change is spec-side.
