# Rewrite Review: New Implementation vs Specs and Old Code

**Date:** 2026-04-03
**Reviewer:** Automated review agent (Claude)
**Scope:** `lib/` (new) vs `old2/lib/` (old) vs `docs/spec/01`--`07`

---

## 1. Spec Compliance

### 01 - Chain Engine (lib/features/session/session_engine.dart)

**Met:**
- Pure Dart state machine with zero Flutter dependencies (only dart:async, dart:math, dart:developer).
- Three-phase timing model (wait, duration, grace) implemented correctly.
- Jitter with per-field config keys (`randomizeInterval`, `randomizeRingDuration`, `randomizeDuration`, `randomizeGrace`) falling back to blanket `step.randomize`.
- Formula `0.8 + random.nextDouble() * 0.4` matches spec exactly.
- Speed multiplier divides all durations; safety fallback for multiplier <= 0.
- Hold button state machine: holdStart/holdRelease, sensitivity timer, re-hold in grace triggers disarm.
- Disguised reminder: wait -> reminderFired event -> duration -> grace -> miss counting.
- Miss count logic: `_missCount > step.retryCount` (retryCount=0 means 1 attempt, retryCount=N means N+1 attempts).
- Fake call decline via `restartCurrentStep()` preserves miss count.
- Pause/resume with exact remaining-time restoration.
- Sub-chain support via `pauseForSubChain()` / `resumeFromSubChain()`.
- Leap to next event (simulation only, replaces active timer with 1s countdown).
- `setSpeedMultiplier()` affects only new timers.
- ChainEvent enum matches spec: stepStarted, reminderFired, repeatMissed, stepAdvancing, userDisarmed, chainExhausted, sessionEnded.
- ChainEventData structure matches spec.
- Hardware panic: `advanceFromHardwarePanic()` and `jumpToStep()`.
- All invariants from spec section "Invariants" are met.

**Missing:**
- **(M1) `checkIn()` is just an alias for `disarm()`** -- spec says this, implementation matches. No issue.
- **(M2) `answerFakeCall()` method not on engine.** Spec 01 mentions fake call answer flow but the engine does not have an explicit `answerFakeCall()`. This is handled at the controller/UI level instead. Acceptable divergence since the engine is pure state machine.

### 02 - Event Types

**Met:**
- All 9 ChainStepType values present in the enum (holdButton, disguisedReminder, countdownWarning, fakeCall, smsContact, phoneCallContact, loudAlarm, callEmergency, hardwareButton).
- Strategy files exist for all 9 types: HoldButtonStrategy, DisguisedReminderStrategy, CountdownWarningStrategy, FakeCallStrategy, SmsContactStrategy, PhoneCallContactStrategy, LoudAlarmStrategy, CallEmergencyStrategy, HardwareButtonStrategy.
- Config keys for each type are consumed via `step.configValue()` / `step.configValueOr()`.
- Fake call: voice recording path, caller name, call style config keys present.
- SMS contact: message template with placeholder resolution (`{name}`, `{location}`, `{time}`, `{description}`).
- Phone call contact: pre-call SMS, alternative contact fallback.
- Loud alarm: volume, sound choice, flash light, flash screen config keys.
- Call emergency: emergency number config, confirmation countdown.
- Hardware button: no-op strategy (platform detection handled externally).

**CRITICAL: EventStrategyRegistry only registers 6 of 9 strategies.**
The registry `_map` contains: countdownWarning, disguisedReminder, fakeCall, smsContact, loudAlarm, callEmergency. Missing from registry:
- **holdButton** (HoldButtonStrategy exists as a file but is not in the map)
- **phoneCallContact** (PhoneCallContactStrategy exists as a file but is not in the map)
- **hardwareButton** (HardwareButtonStrategy exists as a file but is not in the map)

This means calling `EventStrategyRegistry.forStep()` on any of these 3 types will throw `ArgumentError`. The old code has the same bug -- both old and new registries are identical. This is safe only if the controller never calls the registry for these types (holdButton and hardwareButton are no-ops, phoneCallContact has its own strategy file). However, if the session controller dispatches steps generically via the registry, this will crash at runtime for phoneCallContact steps.

### 03 - Data Models

**Met:**
- All Hive TypeIds match spec: MessageChannel(0), EmergencyContact(1), ConfirmationType(4), ReminderTemplate(5), SessionMode(8), AppSettings(9), ChainStep(10), ChainStepType(11), UserProfile(12), EventDefaults(13), ReminderDisplayStyle(14), SessionLog(15), SessionLogEvent(16).
- DuressChainConfig(17) and BatteryAlertConfig(18) use reserved TypeIds from spec.
- EmergencyContact has `effectiveChannels` derived property as spec requires.
- ChainStep has all fields: id, type, order, waitSeconds, durationSeconds, gracePeriodSeconds, retryCount, randomize, config.
- Duration getters (`waitDuration`, `activeDuration`, `gracePeriod`, `totalCycleSeconds`) match spec.
- SessionMode has chainSteps, isBuiltIn, iconName.
- SessionLog has id, startTime, endTime, modeName, modeId, isSimulation, events.
- SessionLogEvent has timestamp, eventType, stepType, stepIndex, description, latitude, longitude.

**Missing from new AppSettings (compared to spec 03 and old code):**
- **(M3) `appPinHash`** (HiveField 16 in old) -- removed from new AppSettings.
- **(M4) `biometricEnabled`** (HiveField 17 in old) -- removed from new AppSettings.
- **(M5) `duressPinHash`** (HiveField 18 in old) -- removed from new AppSettings.
- **(M6) `sessionEndPinHash`** (HiveField 19 in old) -- removed from new AppSettings.
- **(M7) `emergencyNumber`** (HiveField 20 in old) -- removed from new AppSettings.

The new code has PIN entry/setup screens (`pin_entry_screen.dart`, `pin_setup_screen.dart`) and PIN utilities (`pin_utils.dart`), but the AppSettings model has no fields to store PIN hashes. The AuthGate is a no-op pass-through. This means **PIN authentication is fully broken in the new code** -- the screens exist but have no backing data model.

The `emergencyNumber` field was in old AppSettings but is absent from the new. Instead, emergency number is read from step config or defaulted to '112'. The spec says AppSettings should store the user's configured emergency number.

### 04 - Screens & Navigation

**Met:**
- All routes from spec exist in `app_router.dart`: /, /onboarding, /session, /fake-call, /session/completed, /session/simulation-loading, /session/simulation-summary, /contacts, /contacts/edit, /modes, /modes/edit, /settings, /profile, /settings/event-defaults, /settings/event-defaults/detail, /settings/templates, /settings/templates/edit, /settings/about, /settings/feedback, /past-events, /past-events/detail.
- Duress chain and battery alert chain screens exist at their routes.
- Onboarding screen exists.
- Mode editor, chain step list, template editor all exist.

**Missing:**
- **(M8) No PIN setup screen route** in the router. `PinSetupScreen` and `PinEntryScreen` files exist but are not wired into GoRouter routes.
- **(M9) No backup/restore route** (`/settings/backup` from spec 06). BackupService exists but there is no screen to trigger export/import.

### 05 - Services

**Met:**
- All services from spec exist as files and Riverpod providers:
  AudioService, VibrationService, MessagingService, PhoneService, LocationService, WakelockService, NotificationService, FlashService, ScreenFlashService, RecordingService, HardwareButtonService, BackgroundSessionService, CrashRecoveryService, EncryptionService, BackupService, BatteryMonitorService.
- Service providers exposed via `service_providers.dart`.
- SMS retry queue exists (`sms_retry_queue.dart`).
- Location recorder exists (`location_recorder.dart`).
- Alarm volume ramp exists (`alarm_volume_ramp.dart`).
- Volume capture service exists (`volume_capture_service.dart`).
- Session checkpoint service exists (`session_checkpoint_service.dart`).

**Missing:**
- **(M10) No PermissionService provider** in `service_providers.dart`. The `PermissionService` file exists at `lib/core/permissions/permission_service.dart` but is not exposed as a Riverpod provider alongside the other services.

### 06 - Settings & Configuration

**Met:**
- Settings screen has: theme toggle, language picker, GPS logging toggle, stealth mode section with per-feature toggles.
- Event defaults screen with per-type detail editors.
- Duress chain and battery alert chain configuration screens.
- Feedback screen with email.
- About screen.

**Missing:**
- **(M11) No PIN/biometric configuration** in settings screen. Spec 06 "Security Section" requires: App PIN setup, biometric toggle, session end PIN, duress PIN, wrong PIN threshold slider, wrong PIN escalation chain. The settings screen has no security PIN controls (only duress chain and battery alert links).
- **(M12) No alarm global settings** in settings screen. Spec 06 "Alarm Section" requires: override silent mode toggle, gradual volume toggle, gradual volume duration slider. These are only available per-step in event defaults.
- **(M13) No backup/restore UI** in settings screen. Spec 06 requires export/import controls.
- **(M14) No "Redo Onboarding" button** in settings. Spec 06 lists this as a navigation link.

### 07 - Test Plan

Test plan is a spec document for test requirements. Compliance cannot be fully verified without running the test suite, but the test infrastructure (fakeAsync, FixedRandom, step factories) matches spec requirements.

---

## 2. Missing Features (old code has, new code lacks)

### Critical

| Feature | Old Location | New Status | Impact |
|---------|-------------|------------|--------|
| **App PIN authentication** | `old2/lib/features/auth/auth_gate.dart` (full ConsumerStatefulWidget with PIN check) | `lib/features/auth/auth_gate.dart` is a no-op pass-through | HIGH: App has no access protection |
| **PIN fields in AppSettings** | `old2/lib/data/models/app_settings.dart` (fields 16-20) | Removed from new AppSettings model | HIGH: No storage for PIN hashes |
| **Emergency number in AppSettings** | `old2/lib/data/models/app_settings.dart` (field 20, default '112') | Not in new AppSettings | MEDIUM: Emergency number not persisted globally |
| **Contact import** | `old2/lib/data/models/contact_import.dart` | No equivalent in new code | LOW: Convenience feature for importing device contacts |

### Non-Critical

| Feature | Old Location | New Status | Impact |
|---------|-------------|------------|--------|
| AppSettings `_keep` sentinel for nullable copyWith | Old code uses sentinel to distinguish null from unset | New code uses simple nullable params (cannot explicitly set to null) | LOW: Cosmetic, may cause subtle bugs if PIN fields are re-added |

---

## 3. Regressions

### 3.1 AuthGate is a no-op

The old `AuthGate` was a fully functional `ConsumerStatefulWidget` that:
- Checked `settings.appPinHash` to determine if PIN is required
- Showed `PinEntryScreen` with correct hash, duress hash, and biometric flag
- Handled duress PIN trigger via `duressTriggeredProvider`
- Only passed through to the child widget after successful authentication

The new `AuthGate` is a `StatelessWidget` that always returns the child. The comment says "PIN authentication is currently not available in this model version." This is a security regression if users expect PIN protection.

### 3.2 EventStrategyRegistry missing 3 strategies

Both old and new code have the same bug: `holdButton`, `phoneCallContact`, and `hardwareButton` are not registered in the registry map. However, the strategy files exist for all three. This means:
- If the session controller calls `EventStrategyRegistry.forStep()` for a `phoneCallContact` step, it will throw an `ArgumentError` at runtime.
- The `PhoneCallContactStrategy` implements pre-call SMS and contact fallback logic that will never execute via the registry.

### 3.3 Emergency number not globally stored

The old code stored `emergencyNumber` in `AppSettings` (field 20, default '112'). The new code reads emergency number from step config or the onboarding screen, but does not persist it in AppSettings. This means:
- No single source of truth for the user's emergency number
- Onboarding sets it, but there is no settings UI to change it later
- Steps that use `callEmergency` must each have the number in their config

---

## 4. Improvements

### 4.1 Sub-chain controller is well-architected

The new `SubChainController` is a clean Riverpod `AsyncNotifier` that:
- Correctly handles duress and battery sub-chains
- Uses sealed classes for state (`SubChainIdle`, `SubChainRunning`, `SubChainDone`)
- Enforces single-sub-chain-at-a-time invariant
- Properly pauses/resumes the main engine

### 4.2 DuressChainConfig and BatteryAlertConfig are separate Hive models

The new code separates these into their own models (TypeId 17 and 18) with dedicated repositories, which is cleaner than embedding them in AppSettings.

### 4.3 Session start validation

The `SessionStartValidator` class is well-structured with clear permission and contact checks. The old code had similar validation but the new implementation is more modular.

### 4.4 EventServices and SessionContext

The `EventServices` bundle and `SessionContext` with `resolvePlaceholders()` provide a clean contract for strategies. The old code had a similar pattern but the new version is more cohesive.

### 4.5 Backup service

The new `BackupService` with `BackupPayload` is a clean implementation for JSON export/import, even though the UI for triggering it is missing.

### 4.6 Crash recovery service

The new `CrashRecoveryService` with `SessionCheckpoint` and native AlarmManager watchdog integration is well-designed per the spec's crash recovery requirements.

### 4.7 File structure parity

The new code maintains feature-first organization and has the same logical layers as the old code. No structural regressions.

---

## 5. Design Decisions Needed

### D1: Are PIN features intentionally deferred?

The new `AuthGate` comment says "PIN authentication is currently not available in this model version." Was this an intentional decision to ship without PIN support and add it later, or an oversight during the rewrite? The PIN screens exist (`PinEntryScreen`, `PinSetupScreen`, `pin_utils.dart`) but the AppSettings model lacks the fields to store hashes.

**Options:**
- (a) Re-add HiveFields 16-20 to new AppSettings and wire up AuthGate (full parity with old code)
- (b) Move PIN storage to `flutter_secure_storage` (spec 06 recommends this for security) and use a separate provider
- (c) Defer PIN features to a later milestone

### D2: Where should the global emergency number live?

Old code: `AppSettings.emergencyNumber` (HiveField 20).
New code: No global field; read from step config or `emergency_numbers.dart`.

**Options:**
- (a) Re-add `emergencyNumber` to AppSettings
- (b) Store in a dedicated settings key in secure storage
- (c) Keep current approach (per-step config only) -- but add a settings UI to set a default

### D3: Should the EventStrategyRegistry include all 9 types?

Currently holdButton, phoneCallContact, and hardwareButton are not in the registry. The strategy files exist but are orphaned.

**Options:**
- (a) Add all 3 to the registry map (ensures registry.forStep() never throws for valid types)
- (b) Keep current approach but ensure the controller never calls the registry for these types
- (c) Use a different dispatch mechanism for no-op strategies

### D4: Is contact import from device needed for MVP?

Old code had `ContactImportException`, `ContactImportError`, `RawContactEntry`. New code has none of this. The contact form screen may or may not support importing from the device address book.

---

## 6. Action Items (Prioritized)

### P0 -- Critical (blocks correct operation)

1. **Fix EventStrategyRegistry** -- Add `phoneCallContact` to the registry map. Without this, any mode with a phoneCallContact step will crash at runtime when the controller dispatches via the registry. holdButton and hardwareButton are no-ops but should also be registered for completeness.
   - File: `lib/features/session/event_strategies/event_strategy_registry.dart`

### P1 -- High (security/spec compliance)

2. **Restore PIN fields to AppSettings** -- Add `appPinHash` (field 16), `biometricEnabled` (field 17), `duressPinHash` (field 18), `sessionEndPinHash` (field 19) back to `lib/data/models/app_settings.dart`. Re-run `build_runner` to regenerate the adapter.

3. **Wire up AuthGate** -- Replace the no-op `AuthGate` with the old code's `ConsumerStatefulWidget` implementation that checks `appPinHash` and shows `PinEntryScreen`.

4. **Add PIN configuration to Settings screen** -- Add the Security section from spec 06: app PIN setup, biometric toggle, session end PIN, duress PIN configuration, wrong PIN threshold.

5. **Add `emergencyNumber` to AppSettings** -- Re-add HiveField 20 with default '112'. Expose in settings UI so users can change it.

### P2 -- Medium (feature completeness)

6. **Add backup/restore UI** -- Create a settings sub-screen for JSON export/import. The `BackupService` already exists.

7. **Add "Redo Onboarding" to Settings** -- Add a button that clears `isFirstLaunch` and navigates to onboarding.

8. **Add global alarm settings to Settings** -- Override silent mode toggle, gradual volume toggle and duration slider per spec 06 "Alarm Section".

9. **Add contact import capability** -- Implement device contacts import (old code's `contact_import.dart` patterns).

10. **Wire PIN routes into GoRouter** -- Add routes for PIN setup and PIN entry screens.

### P3 -- Low (polish)

11. **Add PermissionService to service_providers.dart** -- Expose as a Riverpod provider for consistency.

12. **Verify backup service includes all data types** -- Ensure export covers AppSettings, UserProfile, contacts, modes, templates, event defaults, session logs per spec 03.

13. **AppSettings copyWith nullable sentinel** -- Consider adopting the old code's `_keep` sentinel pattern to allow explicitly setting nullable fields to null in `copyWith()`. This will be important when PIN fields are re-added.
