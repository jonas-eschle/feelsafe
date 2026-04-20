# Guardian Angela Rewrite -- PM Final Status Report

**Date:** 2026-04-10
**Reviewer:** Architecture Review Agent (PM role)
**Plan reference:** `spicy-enchanting-honey.md`
**Design decisions:** `docs/spec/12-rewrite-decisions.md`

---

## 1. Current Stats

| Metric                  | Count   |
|-------------------------|---------|
| Dart source files (lib) | 123     |
| Dart test files (test)  | 11      |
| Source lines (lib)      | 7,943   |
| Test lines (test)       | 2,752   |
| Individual test cases   | 132     |
| TODO comments (lib)     | 32      |
| TODO comments (test)    | 0       |
| Stub screens (empty UI) | 18      |
| Localization languages  | 14 ARB  |
| Messages per language   | 48      |

### Lines by layer

| Layer              | Files | Lines |
|--------------------|-------|-------|
| domain/            | 33    | 2,552 |
| data/              | 7     | 427   |
| services/          | 36    | 1,985 |
| features/          | 33    | 1,825 |
| core/              | 9     | 397   |
| router/            | 1     | 129   |
| main.dart+app.dart | 2     | 53    |

---

## 2. What Is DONE (solid, tested, working)

### 2a. SessionEngine -- DONE, WELL-TESTED

The core state machine (`lib/domain/engine/`) is the most complete and best-tested component in the project. 595 lines of pure Dart with zero Flutter dependencies.

**Tested behaviors (4 test files, ~2,000 lines, ~80 test cases):**
- Sealed `EngineState` hierarchy (Idle, Running, Paused, SubChainActive, Ended)
- Five `TimerPhase` values (wait, duration, grace, sensitivity, holdWait)
- Three-phase timing model (wait -> duration -> grace) with fakeAsync
- Retry logic: wait skipped on retries (goes straight to duration)
- Hold button edge-triggered: holdStart/holdRelease no-ops when redundant
- Hold sensitivity window: brief lifts within window do NOT escalate
- Re-hold during grace: full disarm
- Fake call lifecycle: answer pauses, hang-up disarms
- declineIsSafe=true -> disarm; declineIsSafe=false -> miss
- Universal disarm from any phase (wait, duration, grace)
- Pause/resume with exact remaining time
- Chain exhaustion (single-step and multi-step)
- Speed multiplier validation (NaN, Infinity, negative, zero, >1x on real)
- start() fail-loud (throws StateError on double-call)
- jumpToStep bounds checking (throws RangeError)
- Empty chain rejection (throws ArgumentError)
- Snooze (extends wait/grace timer, rejects non-positive)
- leapToNextEvent (simulation only)
- Sub-chain start/complete/duress-end flow
- Edge cases: dispose mid-timer, start+endSession same frame, holdRelease while paused, answerFakeCall on wrong step type, zero-duration timers, re-entrant events

**Known bugs documented in tests:**
- BUG-A: Timer.run return value discarded; zero-duration timer can fire after dispose (no crash, but state advances)
- BUG-C: holdRelease while paused clears internal _isHolding but resume restores from snapshot (net: silently swallowed)

### 2b. Domain Models -- DONE, TESTED

All 16 domain models are plain Dart with no Hive annotations (as specified).

| Model                 | File                              | Status   |
|-----------------------|-----------------------------------|----------|
| ChainStep             | domain/models/chain_step.dart     | Complete |
| StepConfig (sealed)   | domain/models/step_config.dart    | Complete, 9 subclasses |
| ChainEvent            | domain/models/chain_event.dart    | Complete, 12 events |
| SessionMode           | domain/models/session_mode.dart   | Complete |
| EmergencyContact      | domain/models/emergency_contact.dart | Complete |
| UserProfile           | domain/models/user_profile.dart   | Complete, medical fields |
| AppSettings           | domain/models/app_settings.dart   | Complete, copyWith tested |
| EventDefaults         | domain/models/event_defaults.dart | Complete |
| ReminderTemplate      | domain/models/reminder_template.dart | Complete |
| SessionLog            | domain/models/session_log.dart    | Complete, ActionDeliveryStatus |
| LocationPoint         | domain/models/location_point.dart | Complete |
| DuressChainConfig     | domain/models/duress_chain_config.dart | Complete |
| BatteryAlertConfig    | domain/models/battery_alert_config.dart | Complete |
| WrongPinChainConfig   | domain/models/wrong_pin_chain_config.dart | Complete |
| Trigger (sealed)      | domain/models/trigger.dart        | Complete |
| WalkSession           | features/session/walk_session.dart | Complete |

**Tests:** chain_step_test.dart (101 lines), step_config_test.dart (146 lines), chain_event_test.dart (59 lines), app_settings_test.dart (77 lines), seed_data_test.dart (109 lines). All verify exhaustive switches, defaults, and type hierarchies.

### 2c. Engine State Hierarchy -- DONE, TESTED

`engine_state.dart`: Sealed class with 5 concrete subtypes. `EngineRunning.copyWith` tested. All `EndReason`, `PauseReason`, `SubChainType` enums covered.

### 2d. Orchestration Layer -- DONE (partially)

- `EventStrategy` abstract class: complete
- `EventStrategyRegistry`: complete
- `SessionContext` with placeholder resolution: complete
- `SessionOrchestrator`: complete (handles stepStarted, userDisarmed, sessionEnded, chainExhausted)
- All 9 concrete strategies: complete (see section 3 for caveats)

### 2e. Service Protocols -- DONE

All 11 service protocols defined as abstract classes:
AudioServiceProtocol, VibrationServiceProtocol, MessagingServiceProtocol, PhoneServiceProtocol, LocationServiceProtocol, NotificationServiceProtocol, DeviceStateProtocol, HardwareButtonServiceProtocol, BatteryMonitorServiceProtocol, IncomingCallServiceProtocol, GeofenceServiceProtocol.

All 11 have corresponding fake implementations for testing. All 11 have real implementations.

### 2f. Service Providers -- DONE (wired to fakes)

`service_providers.dart` defines 11 Riverpod providers. Currently all point to fakes (TODO marker).

### 2g. Core Utilities -- DONE

- `PinUtils`: SHA-256 hash with salt, constant-time comparison
- `CountryDetector`: 60+ countries mapped to emergency numbers
- `StealthConfig`: resolves from AppSettings
- `QuickExit`: Android finishAndRemoveTask + iOS decoy screen
- `AppConstants`: schema version, limits, timing defaults
- `RouteNames`: 27 route paths
- `StepHelpers`: name/icon/isAction/isCheckIn per step type
- `AppColors`: brand colors, pride gradient, simulation orange
- `AppTheme`: light + dark Material 3

### 2h. Data Layer -- DONE (JSON approach)

- `HiveBoxes`: encrypted box management with flutter_secure_storage
- `ListRepository<T>` and `SingletonRepository<T>`: generic CRUD
- `HiveTypeIds`: central ID registry
- `json_adapter.dart`: JSON encode/decode helpers
- `register_adapters.dart`: no-op (deliberate JSON-over-TypeAdapter approach)
- `seed_data.dart`: Walk Mode, Date Mode, 8 reminder templates, defaults

### 2i. Localization -- DONE (14 languages)

14 ARB files with 48 messages each: en, de, es, fr, ru, ar, el, fa, he, hi, pl, uk, zh, zh_TW. Only `app_localizations.dart` and `app_localizations_en.dart` are generated; other language Dart files are missing from gen-l10n output.

### 2j. Native Kotlin Code -- PARTIALLY DONE

- `MainActivity.kt`: volume button interception via EventChannel + session control MethodChannel
- `SmsChannel.kt`: SMS sending via SmsManager
- `SmsWorker.kt`: WorkManager-based persistent SMS retry
- `PhoneCallHelper.kt`: ACTION_CALL with CALL_PHONE permission fallback
- `BootReceiver.kt`: exists (not in plan manifest)

### 2k. Router -- DONE

`app_router.dart`: GoRouter with 22 routes, first-launch redirect to onboarding.

### 2l. Session Controller -- DONE

`session_controller.dart`: Riverpod Notifier bridging engine to UI. Owns engine + orchestrator. All engine methods forwarded. WalkSession state updated from engine events.

### 2m. Functional Screens -- 4 DONE

| Screen            | Status          |
|-------------------|-----------------|
| HomeScreen        | Functional: mode chips, chain summary, contact preview, start/simulate buttons |
| SessionScreen     | Functional: phase-based rendering, hold button, slider, simulation border/banner, timer, end session |
| OnboardingScreen  | Functional: 3-page flow (welcome/profile+contact/permissions), skip, save |
| FakeCallScreen    | Partially functional: UI renders, but buttons are NOT wired (TODO) |

### 2n. Functional Widgets -- 3 DONE

| Widget            | Status          |
|-------------------|-----------------|
| HoldButton        | Functional: GestureDetector, animated circle, 3 states |
| ImSafeSlider      | Functional: swipe-to-disarm at 85%, spring-back animation |
| FakeMusicPlayer   | Functional: stealth disguise with hidden disarm slider at 85% |

---

## 3. What Is a STUB (compiles but placeholder)

### 3a. 18 Stub Screens (empty Scaffold with centered text)

These files exist and compile but have ZERO functional UI:

| Screen                    | File                                         |
|---------------------------|----------------------------------------------|
| PinEntryScreen            | features/auth/pin_entry_screen.dart          |
| PinSetupScreen            | features/auth/pin_setup_screen.dart          |
| ChainExhaustedScreen      | features/session/chain_exhausted_screen.dart |
| SimulationSummaryScreen   | features/session/simulation_summary_screen.dart |
| ProfileEditorScreen       | features/profile/profile_editor_screen.dart  |
| PastEventsScreen          | features/history/past_events_screen.dart     |
| SessionLogDetailScreen    | features/history/session_log_detail_screen.dart |
| TemplateEditorScreen      | features/templates/template_editor_screen.dart |
| ReminderTemplatesScreen   | features/templates/reminder_templates_screen.dart |
| ModeEditorScreen          | features/modes/mode_editor_screen.dart       |
| ModesScreen               | features/modes/modes_screen.dart             |
| FeedbackScreen            | features/settings/feedback_screen.dart       |
| BackupScreen              | features/settings/backup_screen.dart         |
| EventDefaultsScreen       | features/settings/event_defaults_screen.dart |
| SettingsScreen            | features/settings/settings_screen.dart       |
| AboutScreen               | features/settings/about_screen.dart          |
| ContactsScreen            | features/contacts/contacts_screen.dart       |
| ContactFormScreen         | features/contacts/contact_form_screen.dart   |

### 3b. Stub Controllers (in-memory only, no persistence)

All 5 controllers work in memory but have no Hive integration:

| Controller              | TODOs                                    |
|-------------------------|------------------------------------------|
| ContactsController      | 5 TODOs: load/persist/delete/reorder     |
| ModesController         | 3 TODOs: load/persist/delete             |
| TemplatesController     | 1 TODO: load from repository             |
| ProfileController       | 2 TODOs: load/persist                    |
| SettingsController      | 1 TODO: load from repository             |
| EventDefaultsController | 2 TODOs: load/persist                    |

### 3c. Stub Sub-Chain Execution

`session_engine.dart` line 311: `// TODO: Execute sub-chain steps sequentially.` The `startSubChain()` method immediately completes the sub-chain instead of executing steps. This means sub-chains (duress, battery, wrongPin, distress) are structurally wired but functionally inert.

### 3d. Stub Service Provider Wiring

`service_providers.dart` line 32: `// TODO: Replace fakes with real implementations when available.` All 11 Riverpod providers return fakes. Real implementations exist in `services/implementations/` but are not wired.

### 3e. Stub main.dart

4 TODOs: Hive init, schema migration, seed defaults, load settings. Currently hardcodes `isFirstLaunch = true` (always shows onboarding).

### 3f. Strategies With Limited Real Logic

4 of 9 strategies are pure no-ops (UI-driven): HoldButtonStrategy, FakeCallStrategy, DisguisedReminderStrategy, HardwareButtonStrategy. The other 5 (SmsContact, PhoneCallContact, CallEmergency, LoudAlarm, CountdownWarning) have real logic but depend on service implementations that are not wired.

### 3g. FakeCallScreen Buttons Not Wired

`fake_call_screen.dart` lines 71, 78: Decline and Answer buttons have `onPressed: () {}` with TODO comments. No SessionController reference passed to this screen.

---

## 4. What Is MISSING (not started)

### 4a. Missing Domain Models (from plan manifest)

| Model             | Planned file                   |
|-------------------|--------------------------------|
| Destination       | domain/models/destination.dart |
| EvidencePackage   | domain/models/evidence_package.dart |

### 4b. Missing Service Protocols (from plan manifest)

| Protocol                    | Planned file                              |
|-----------------------------|-------------------------------------------|
| PermissionServiceProtocol   | services/protocols/permission_service_protocol.dart |
| BackupServiceProtocol       | services/protocols/backup_service_protocol.dart     |
| EvidenceServiceProtocol     | services/protocols/evidence_service_protocol.dart   |

### 4c. Missing Native Code (from plan manifest)

| File                  | Platform | Purpose                     |
|-----------------------|----------|-----------------------------|
| CallStateChannel.kt  | Android  | TelephonyCallback EventChannel for incoming call detection |
| SystemUiChannel.kt   | Android  | Quick Exit + battery exemption |
| CallStatePlugin.swift | iOS     | CXCallObserver              |
| SystemUiPlugin.swift  | iOS     | Decoy + exit                |

### 4d. Missing Feature Files (from plan manifest)

| Feature                  | Planned file                               |
|--------------------------|---------------------------------------------|
| Home widget config       | features/home/widgets/home_widget_config.dart |
| Session engine bridge    | features/session/session_engine_bridge.dart  |

### 4e. Missing Entire Features (Phase 5 from plan)

| Feature                    | Status      |
|----------------------------|-------------|
| Quick Exit wiring          | QuickExit utility exists but not integrated into any screen |
| Icon disguise (activity-alias) | Not started |
| Notification hardening     | Not started |
| Destination auto-arrive    | Geofence service exists but no Destination model or UI |
| Evidence package export    | Not started |
| Home screen OS widget      | Not started |
| "Decline with Distress" (3s hold) | Not started (fake call buttons not wired) |
| Safety Setup checklist card | Not started (plan specifies Slack-style banner on home screen) |
| Wrong-PIN chain editor     | Route defined but no screen |
| Duress chain editor        | Route defined but no screen |
| Battery alert chain editor | Route defined but no screen |

### 4f. Missing Localization Integration

`app.dart` does NOT set `localizationsDelegates` or `supportedLocales`. The 14 ARB files exist and `gen-l10n` was partially run, but:
- Only 2 of 16 generated Dart files exist (en + base class)
- Zero screens use `AppLocalizations.of(context)` -- all strings are hardcoded in English
- The localization system is structurally present but completely disconnected

### 4g. Missing GuardianAngelaLogo Widget

The plan and CLAUDE.md reference `GuardianAngelaLogo` in `lib/core/theme/guardian_angela_logo.dart`. This file does not exist. The onboarding welcome page has a TODO comment for it.

---

## 5. Critical Bugs Found

### BUG-1 (P0): SMS Platform Channel Name Mismatch

**Kotlin:** `const val CHANNEL_NAME = "guardianangela/sms"` (`SmsChannel.kt`)
**Dart:** `MethodChannel('com.guardianangela.app/sms')` (`messaging_service.dart`)

These do not match. SMS sending will throw `MissingPluginException` at runtime. Every SMS escalation step will silently fail.

### BUG-2 (P0): Hardware Button EventChannel Name Mismatch

**Kotlin:** `const val CHANNEL_VOLUME_BUTTONS = "com.guardianangela.app/volume_buttons"` (`MainActivity.kt`)
**Dart:** `EventChannel('com.guardianangela.app/hardware_buttons')` (`hardware_button_service.dart`)

Volume button detection will never work. Hardware panic trigger is dead.

### BUG-3 (P1): SessionValidator Permission Severity Always Warning

```dart
final permSeverity = isSimulation
    ? IssueSeverity.warning
    : IssueSeverity.warning; // BUG: should be IssueSeverity.error for real sessions
```

Missing permissions in real sessions should be errors (blocking), not warnings. Currently a user can start a real session without notification or location permissions and the validator will not block it.

### BUG-4 (P1): SmsWorker Still Has NetworkType.CONNECTED Constraint

`SmsWorker.kt` line 59: `.setRequiredNetworkType(NetworkType.CONNECTED)`

The plan explicitly says to remove this. SMS uses the cellular radio directly and does not require WiFi/data. This constraint will cause SMS to fail when the user has no WiFi/data connection, which is precisely the scenario where the app is most needed.

### BUG-5 (P1): Packages Not Removed Per Plan

`pubspec.yaml` still includes `camera` (~500KB), `font_awesome_flutter` (~700KB), and `audio_service`. The plan says to remove all three. `camera` and `font_awesome_flutter` are not imported anywhere in the rewritten code.

### BUG-6 (P2): Sub-Chain Execution Is a No-Op

`session_engine.dart` line 311-312: `// TODO: Execute sub-chain steps sequentially. // For now, immediately complete the sub-chain.`

If a user enters the duress PIN, the duress chain fires but executes zero steps (no SMS, no calls). Same for battery alert and wrong-PIN chains. This is a safety-critical gap.

### BUG-7 (P2): FakeCallScreen Buttons Disconnected

`fake_call_screen.dart` lines 71, 78: Both Answer and Decline buttons have `onPressed: () {}`. The screen does not accept a controller reference. When a fake call step fires, the user cannot answer or decline -- the escalation chain will timeout and advance regardless of user action.

### BUG-8 (P2): Localization Not Wired

`app.dart` missing `localizationsDelegates` and `supportedLocales`. All UI text is hardcoded English. Changing language in settings does nothing.

### BUG-9 (P2): main.dart Hardcodes isFirstLaunch = true

Line 18: `final isFirstLaunch = true;` Hive init is commented out. The app will always show onboarding on every launch.

### BUG-10 (P3): Service Providers All Return Fakes

`service_providers.dart` wires all 11 providers to fakes. Real implementations (`services/implementations/`) exist but are unused. A real session will log "sent" but actually send nothing.

---

## 6. Test Debt

### 6a. What Has Tests (good)

| Component                | Test file(s)                           | Cases |
|--------------------------|----------------------------------------|-------|
| SessionEngine (P0)       | session_engine_test.dart               | 12    |
| SessionEngine (timing)   | engine_timing_test.dart                | ~25   |
| SessionEngine (edges)    | engine_edge_cases_test.dart            | ~45   |
| EngineState hierarchy    | engine_state_test.dart                 | 10    |
| AppSettings.copyWith     | app_settings_test.dart                 | 3     |
| ChainEvent enum          | chain_event_test.dart                  | 3     |
| ChainStep model          | chain_step_test.dart                   | 7     |
| StepConfig hierarchy     | step_config_test.dart                  | 12    |
| Seed data                | seed_data_test.dart                    | 12    |
| Test helpers             | test_helpers.dart                      | (factories) |

### 6b. What Has ZERO Test Coverage

**Domain (zero tests):**
- SessionOrchestrator (`domain/orchestration/session_orchestrator.dart`)
- All 9 event strategies (`domain/orchestration/strategies/`)
- SessionValidator (`domain/validation/session_validator.dart`)
- SessionContext placeholder resolution
- Trigger model hierarchy (`domain/models/trigger.dart`)
- EmergencyContact model
- UserProfile model (medical summary, hasMedicalInfo)
- SessionMode model (sorting, checkInType getter)
- SessionLog model
- ReminderTemplate model
- LocationPoint model

**Data (zero tests):**
- ListRepository
- SingletonRepository
- HiveBoxes encryption init
- JSON adapter round-trip

**Services (zero tests):**
- All 11 fake services (recording behavior)
- All 11 real implementations
- Service provider wiring

**Features (zero tests):**
- SessionController (Riverpod notifier)
- ContactsController
- ModesController
- TemplatesController
- ProfileController
- SettingsController
- EventDefaultsController
- All 22 screen widgets (zero widget tests)

**Core (zero tests):**
- PinUtils (hash, verify, constant-time comparison)
- CountryDetector
- StealthConfig.fromSettings
- QuickExit
- AppTheme
- StepHelpers

### 6c. P0 Tests Still Missing (from plan's "7 safety-critical" list)

| P0 Test                                      | Status           |
|----------------------------------------------|------------------|
| declineIsSafe=true engine behavior            | DONE             |
| Hold sensitivity window boundary (+/- 1ms)   | PARTIAL (exact boundary not tested) |
| Date mode miss-then-checkin boundary          | NOT DONE         |
| Snooze extends, never escalates              | NOT DONE         |
| Destination auto-arrive during escalation    | NOT DONE (no destination model) |
| Real incoming call pauses (not escalates)    | NOT DONE         |
| Empty chain + single-step chain              | DONE             |

### 6d. P1 Tests Missing (from plan)

18 test files were planned. 9 exist. Missing:
- `test/domain/orchestration/session_orchestrator_test.dart`
- `test/domain/orchestration/strategies/*_test.dart` (9 strategy tests)
- `test/domain/validation/session_validator_test.dart`
- `test/data/repositories/*_test.dart`
- `test/features/session/session_controller_test.dart`
- `test/features/contacts/contacts_controller_test.dart`
- `test/features/settings/settings_controller_test.dart`

---

## 7. Next Steps (priority order)

### Priority 1: Fix Safety-Critical Bugs

1. **Fix SMS channel name mismatch** (BUG-1). Change `SmsChannel.kt` CHANNEL_NAME to `"com.guardianangela.app/sms"` or change Dart to match Kotlin. This is a one-line fix that unblocks the entire SMS escalation path.

2. **Fix hardware button channel name mismatch** (BUG-2). Change `hardware_button_service.dart` to use `"com.guardianangela.app/volume_buttons"`. One-line fix.

3. **Fix SessionValidator permission severity** (BUG-3). Change the `else` branch from `IssueSeverity.warning` to `IssueSeverity.error`. One-line fix.

4. **Remove NetworkType.CONNECTED from SmsWorker** (BUG-4). Delete the `.setRequiredNetworkType(NetworkType.CONNECTED)` line. One-line fix.

### Priority 2: Wire Fake Call Buttons + Sub-Chain Execution

5. **Wire FakeCallScreen** to SessionController (BUG-7). Pass controller callbacks for answer/decline/hangUp. Critical for Walk Mode usability.

6. **Implement sub-chain step execution** (BUG-6). Replace the TODO in `startSubChain()` with sequential step execution. Critical for duress PIN and battery alert to actually work.

### Priority 3: Wire Service Providers to Real Implementations

7. **Replace fakes with real implementations** in `service_providers.dart` (BUG-10). The real service code exists and compiles. This is mostly mechanical wiring.

### Priority 4: Wire Persistence Layer

8. **Implement Hive init in main.dart** (BUG-9). Uncomment HiveBoxes.init, add schema migration, seed defaults, load settings for initial route.

9. **Wire all 6 controllers to repositories.** Each controller has TODO markers for load/persist. Estimated: 2-3 hours of mechanical work using the existing ListRepository/SingletonRepository.

### Priority 5: Wire Localization

10. **Add localization delegates to app.dart** (BUG-8). Add `localizationsDelegates: AppLocalizations.localizationsDelegates`, `supportedLocales: AppLocalizations.supportedLocales`. Run `flutter gen-l10n` to generate all language files.

11. **Replace hardcoded strings** with `AppLocalizations.of(context)` calls across all screens.

### Priority 6: Build Critical Missing Screens

12. **ContactsScreen + ContactFormScreen** -- users cannot add/edit contacts without this. Blocks real session testing.

13. **PinEntryScreen + PinSetupScreen** -- required for PIN safety speed bump (core design principle).

14. **SettingsScreen** -- entry point for stealth mode, PIN setup, emergency number, language.

15. **ModeEditorScreen + ModesScreen** -- users cannot customize escalation chains without this.

### Priority 7: Write Missing P0/P1 Tests

16. Write `session_orchestrator_test.dart` -- test handleEvent dispatching, cleanDisarm, simulation description.

17. Write `session_validator_test.dart` -- test all validation rules (empty chain, missing contacts, missing permissions, simulation leniency).

18. Write `session_controller_test.dart` -- test engine lifecycle, state derivation, orchestrator integration.

### Priority 8: Missing Features from Plan

19. Add `Destination` model and GPS arrival disarm UI flow.
20. Implement "Decline with Distress" (3s hold) on FakeCallScreen.
21. Build Safety Setup checklist card for HomeScreen.
22. Build wrong-PIN/duress/battery chain editor screens.
23. Add native CallStateChannel (Android) and CallStatePlugin (iOS) for auto-pause on incoming calls.
24. Add native SystemUiChannel (Android) and SystemUiPlugin (iOS) for Quick Exit.
25. Remove unused dependencies (camera, font_awesome_flutter, audio_service).
26. Build GuardianAngelaLogo widget.
27. Evidence package export.
28. Home screen OS widget.
29. Icon disguise via activity-alias.

---

## Summary

The rewrite has a **strong foundation**. The engine state machine is well-designed, thoroughly tested, and faithful to the spec. The domain model layer is clean, pure Dart, and complete (minus 2 models). The service protocol/fake/implementation triad is architecturally sound.

However, the project is at approximately **Phase 2.5 of the 7-phase plan**. The foundation is built, but the wiring is missing. The most concerning gaps are:

1. **Two platform channel name mismatches** that make SMS and hardware button detection completely non-functional at runtime. These are silent failures.
2. **18 of 22 screens are empty stubs.** The app can be launched and sessions can be started, but every CRUD operation (contacts, modes, settings, templates, profile) is a dead end.
3. **All service providers return fakes.** Even with the engine running perfectly, a real session sends zero SMS, makes zero calls, and triggers zero alarms.
4. **Sub-chain execution is a no-op.** Duress PIN, battery alert, and wrong-PIN chain features are structurally present but functionally inert.
5. **Localization is disconnected.** 14 languages translated but zero strings are loaded at runtime.

The engine + orchestration + model layer quality is high (I would rate it 8/10). The overall project completion against the plan is approximately **35-40%**. The next 20% of effort (fixing bugs, wiring services, wiring persistence) would unlock approximately 60% of the app's functional surface area.
