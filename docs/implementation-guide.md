# Guardian Angela — Implementation Guide

> **Purpose:** This document is the authoritative guide for the complete rewrite
> of Guardian Angela from scratch. It captures all resolved architecture
> decisions, the phased build plan with gate criteria, testing strategy, service
> layer design, engine notes, and known risks. A developer or agent reading
> only this document and the specs (00-11) should be able to build the app.

---

## Part 1: Resolved Architecture Decisions

### AD-1: Strategy ↔ Service Wiring

**Decision:** Strategies call services directly via an `EventServices` bundle.

Each strategy's `executeReal(ChainStep step, EventServices services)` receives
a typed bundle containing all service references. The `SessionController`
constructs the bundle at session start by reading Riverpod providers. In
simulation mode, the bundle contains `SimulationMessagingService` /
`SimulationPhoneService` instead of real implementations.

**Rationale:** 9-to-1 panel consensus. Direct calls mean a bug in one strategy
breaks only that step type. Intent-return adds a dispatch layer where a single
mapping bug silently drops all steps. The EventServices pattern is already in
the spec and half-built in the codebase.

### AD-2: "I'm Safe" from Background Notification

**Decision:** If a Session End PIN is configured, bring the app to foreground
and show a PIN prompt (with the standard `ImSafeSlider`). If no PIN is
configured, the notification action directly ends the session.

The notification action button uses a slider interaction (not a simple tap) to
prevent accidental or attacker-initiated session termination.

In stealth mode, the notification button label is disguised (e.g., "Mark as
read", "Skip") instead of "I'm Safe".

### AD-3: Audio STREAM_ALARM Native Channel

**Decision:** Include from the start.

Add `AlarmAudioChannel.kt` (~40 lines) using `MediaPlayer` with
`AudioAttributes.USAGE_ALARM` / `STREAM_ALARM`. This bypasses DND and silent
mode on API 26-35. The Flutter `AudioService` calls this channel for the
`loudAlarm` step; all other audio (ringtones, voice recordings) uses
`just_audio` through the default stream.

During mode setup, if the phone is on silent/DND, show a one-time contextual
warning: "Your phone is on silent. The alarm step uses alarm volume, which
will override silent mode. Test this now?" with a "Test Alarm" button.

### AD-4: SMS and Messaging Channels

**Decision:** The channel is configured per-contact via
`EmergencyContact.channels` (`List<MessageChannel>`). When a messaging step
fires, it sends via ALL enabled channels for each contact in that step.

- **SMS (Android):** Auto-send silently via `SmsManager` + WorkManager retry.
- **SMS (iOS):** Opens Messages app pre-filled — user must press Send.
- **WhatsApp/Telegram:** Attempt deep link. Log failure if it can't launch
  from background (expected on Android 14+). These are best-effort
  supplementary channels, not guaranteed delivery.

No "fan-out strategy" logic — the step sends via whatever the contact has
configured. No priority sequencing or delay between channels.

### AD-5: DistressChain Storage

**Decision:** Hybrid — store by ID, resolve by value at session start.

`SessionMode.distressChainId` references a global `DistressChain` by ID.
At `startSession()` time, the controller resolves the ID to a
`List<ChainStep>` and passes it by value to the engine. If the ID is missing
(chain deleted), fall back to the first chain in `AppDefaults.distressChains`.

The engine receives concrete steps, never an ID. No async lookup at trigger
time. No race condition.

### AD-6: WorkManager SMS

**Decision:** Dual path — synchronous first, WorkManager as durable backup.

1. Attempt synchronous `SmsManager.sendTextMessage()` for immediate delivery.
2. Simultaneously enqueue via WorkManager as a durable fallback.
3. If the process dies, WorkManager picks up the retry.
4. iOS uses synchronous path only (no WorkManager equivalent).

Fix required: `SmsChannel.enqueueSms()` must return the WorkManager UUID to
Dart (currently discarded). `SmsChannel.cancelWork()` must call
`WorkManager.cancelWorkById()` (currently a stub).

### AD-7: Native Kotlin Tests in CI

**Decision:** Include now, minimal scope.

- JUnit4 + Robolectric for `SmsWorker` (WorkManager `TestDriver`).
- String literal matching: channel method names match between Dart and Kotlin.
- One smoke test per channel.

Extract `SmsManager` interaction behind a `SmsSender` interface for testability.
`SmsWorker` accepts a factory or service locator (WorkManager workers can't
have constructor-injected dependencies without a custom `WorkerFactory`).

### AD-8: Firebase Test Lab

**Decision:** Defer until test suite is stable and the app has external users.

### AD-9: Distress Confirmation Window

**Decision:** 5 seconds, configurable. The `distressCancelWindowSeconds`
constant is separate from step grace periods. Large full-width cancel button.
PIN required to cancel if configured.

### AD-10: Session Start Flow

**Decision:** Keep multi-step flow. GPS destination prompt is configurable per
mode (whether to show it at session start). Flow:

1. User taps "Start [Mode Name]"
2. Validation check (contacts, permissions, signal)
3. Trigger summary (active triggers for this mode)
4. GPS destination prompt (if mode has GPS disarm trigger configured and
   `promptForDestination` is true; skippable)
5. Session starts

### AD-11: v0.1 Scope

**Decision:** Full spec scope. No cuts to ModeOverrides/AppDefaults
inheritance, biometric, or EvidenceExport.

### AD-12: Stealth Notification Label

**Decision:** Yes. When stealth mode is active, the notification "I'm Safe"
button is disguised (e.g., "Mark as read", "Remind me later") matching the
fake app persona from `StealthConfig`.

---

## Part 2: Phased Build Plan

### Lessons from v1 (non-negotiable rules)

1. **SPEC → TEST → CODE.** Write failing tests before implementation.
2. **Wiring map is a test file** (`test/wiring/wiring_contract_test.dart`),
   not a markdown document. It compiles, runs, and fails loudly.
3. **Integration tests at EACH phase gate**, not just at the end.
4. **NO parallel agents for connected code.** Services → controller → screens
   must be sequential with explicit hand-off.
5. **Stubs throw `UnimplementedError`**, never silently succeed.
6. **Single wiring owner** reviews every phase for: are all providers used?
   Are all fields threaded? Are all screens wired?

---

### Phase 0: Contracts (sequential, single agent)

**Deliverables:**
- `docs/contract/type_catalog.dart` — compilable file with all sealed class
  skeletons, enum definitions, interface signatures (`throw UnimplementedError()`
  bodies). This is the contract; it does NOT ship.
- `docs/contract/provider_catalog.dart` — every Riverpod provider name, type,
  and owning file.
- `docs/contract/route_table.md` — 24 routes, paths, query params, screen
  classes.
- `docs/contract/file_ownership.md` — which phase creates which files. No
  overlaps.
- `docs/contract/wiring_map.md` — initial version: `Model Field → Engine
  Param → Controller Line → Strategy Call → Service Method`. Every field that
  touches the engine gets a row.

**Gate:** `type_catalog.dart` compiles with `dart analyze --fatal-infos`.
Wiring map has a row for every `StepConfig` subtype, `EngineState`, `Trigger`,
and `ChainEventData` variant. Team signs off before Phase 1.

---

### Phase 1: Models and Codegen (parallel model files, sequential codegen)

**What gets built:**
All files under `lib/data/models/`:
- Enums: `MessageChannel`, `ChainStepType`, `ConfirmationType`,
  `ReminderDisplayStyle`
- Core: `ChainStep`, `StepConfig` (sealed, 9 subtypes), `SessionMode`,
  `EmergencyContact`, `DistressChain`, `AppDefaults`, `ModeOverrides`,
  `AppSettings`, `UserProfile`, `ReminderTemplate`, `BatteryAlertConfig`
- Session: `WalkSession`, `SessionPhase` (sealed), `SessionLog`,
  `SessionLogEvent`
- Config: `GpsLoggingConfig`, `StealthConfig`, `EventDefaults`
- Triggers: `Trigger` (sealed), `DistressTrigger`, `DisarmTrigger`

Then `flutter pub run build_runner build --delete-conflicting-outputs`.

**Tests (written BEFORE implementation):**
- Round-trip JSON test for every model: `fromJson(toJson(x)) == x`
- Hive TypeId uniqueness test (no collisions across 0-19)
- `StepConfig` exhaustive switch test (every `ChainStepType` maps to a config)

**Gate:**
- `build_runner` exits 0
- All model tests pass
- `flutter analyze --fatal-infos` passes

**Parallelization:** Model files can be written in parallel (data classes with
no cross-imports except sealed hierarchies). Run `build_runner` once at the end.

---

### Phase 2: Repositories and Seed Data (sequential)

**What gets built:**
- `lib/data/repositories/json_singleton_repository.dart`
- `lib/data/repositories/json_list_repository.dart`
- Feature repositories: contacts, modes, settings, session_log, distress_chain
- `lib/data/seed_data.dart` — 2 modes, 8 templates, 1 distress chain, event
  defaults, emergency number mapping

**Tests:**
- Repository CRUD: write, read, update, delete for each type
- Seed data test: instantiate all seed objects, serialize, deserialize, assert
  field equality (catches any model field seed data forgot to populate)
- First-launch integration test: fresh Hive box → seed runs → repos return
  expected counts

**Gate:** All repo + seed tests pass.

---

### Phase 3: Native Platform Channels (parallel with Phase 2)

**What gets built (Android Kotlin):**
- `MainActivity.kt` — channel registration skeleton
- `SmsChannel.kt` + `SmsWorker.kt` (with UUID return fix)
- `AlarmAudioChannel.kt` — STREAM_ALARM bypass (~40 lines)
- `CallStateChannel.kt` — TelephonyCallback
- `SystemUiChannel.kt` — Quick Exit, battery exemption
- `PhoneCallHelper.kt` — auto-dial
- `BootReceiver.kt` — WorkManager re-init
- `NotificationActionReceiver.kt` — background notification button handler

**What gets built (iOS Swift):**
- `CallStatePlugin.swift` — CXCallObserver
- `SystemUiPlugin.swift` — stubs

**What gets built (Kotlin tests):**
- `SmsWorkerTest.kt` — Robolectric + WorkManagerTestInitHelper
- Channel name string matching tests

**Gate:** Each channel has a manual smoke test on a device. Kotlin unit tests
pass in CI.

---

### Phase 4: Service Layer (sequential)

**What gets built:**
- `lib/services/audio_service.dart`
- `lib/services/vibration_service.dart`
- `lib/services/messaging_service.dart`
- `lib/services/phone_service.dart`
- `lib/services/location_service.dart`
- `lib/services/notification_service.dart`
- `lib/services/wakelock_service.dart`
- `lib/services/permission_service.dart`
- `lib/services/service_providers.dart` — all providers registered here
- `lib/services/simulation/simulation_messaging_service.dart`
- `lib/services/simulation/simulation_phone_service.dart`
- `test/fakes/` — `FakeXxxService` for every service (records calls, throws
  `UnimplementedError` for un-faked methods)

**Tests:**
- Provider resolution test: `ProviderContainer` → every provider resolves
- Each fake passes a contract test: call every method, assert recorded calls
- Simulation services: `canAutoSend` always false, no real sends

**Gate:**
- `service_providers.dart` compiles and resolves in `ProviderContainer`
- All fake contract tests pass
- `flutter analyze --fatal-infos` passes

---

### Phase 5: Session Engine (sequential, wiring owner reviews)

**What gets built:**
- `lib/domain/session_engine.dart`
- `lib/domain/engine_state.dart` (sealed hierarchy)
- `lib/domain/chain_event_data.dart`

**Critical design notes (from state machine expert):**
- **Inject a `DateTime Function()` clock** — `DateTime.now()` is NOT
  overridden by `fakeAsync`. Replace every `DateTime.now()` call with
  `_now()` where `_now` is an injected clock. In tests, pass a clock that
  reads from `FakeAsync.elapsed`.
- Consider deriving `isAwaitingFirstTouch` from `phase == TimerPhase.holdWait`
  instead of storing it as a separate field (reduces state duplication).
- Keep fake call (`answerFakeCall`/`hangUp`), hold button
  (`holdStart`/`holdRelease`), and distress chain replacement inside the
  engine — they all affect timer state directly.
- Broadcast stream with `sync: true` is correct — events fire synchronously,
  no microtask pumping needed in `fakeAsync` tests.
- Do NOT add `ValueNotifier<EngineState>` — the controller is the single
  observer. Expose `state` as a plain getter.

**Tests (written BEFORE engine):**
- All 4 state transitions (Idle→Running→Paused→Ended)
- Three-phase timing: wait→duration→grace for each step type
- Retry cycles: miss counting, wait-skip on retries
- Speed multiplier rejection for real sessions
- Distress chain replacement mid-session
- Fake call two-phase lifecycle
- Hold button sensitivity window
- Pause/resume exact remaining time
- Jitter within ±20% bounds
- `start()` on running engine throws

All tests use `fakeAsync` + `_FixedRandom(0.5)` + injected clock.

**Gate:** All engine tests pass. Wiring map updated: every `ChainEventData`
emission has a corresponding row showing which controller method consumes it.

---

### Phase 6: Event Strategies (sequential, wiring owner reviews)

**What gets built:**
- `lib/features/session/event_strategies/base_strategy.dart`
- 9 strategy files (one per step type)
- `lib/features/session/event_strategies/event_strategy_registry.dart`
- `lib/features/session/event_strategies/event_services.dart`

**Critical implementation note:** Every strategy's `executeReal()` MUST
actually call the corresponding service method. The v1 strategies were stubs
that called nothing. This is the #1 priority defect to prevent.

**Tests:**
- For each of 9 strategies × 2 modes (real/sim) = 18 paths:
  - Real mode: assert the correct service method was called on the fake
  - Sim mode: assert NO service method was called, `simulationDescription()`
    returns non-empty string
- No `UnimplementedError` remains in any strategy

**Gate:** All 18 strategy tests pass. 4-layer simulation defense verified:
1. Engine `isSimulation` flag → controller checks before calling `executeReal`
2. Strategy guard → `simulationDescription()` used instead
3. Service param → `isSimulation` passed, methods no-op when true
4. Separate subclass → `SimulationMessagingService` structurally can't send

---

### Phase 7: SessionController + Router (sequential, wiring owner — HIGHEST RISK)

**What gets built:**
- `lib/features/session/session_controller.dart` — Riverpod `AsyncNotifier`
- `lib/router/app_router.dart` — all 24 routes
- `lib/core/constants/route_names.dart`
- `test/wiring/wiring_contract_test.dart` — the living wiring map

**This is where v1 failed.** The wiring owner checks:
- Every `ChainEventData` type has a handler in the controller
- Every handler calls a strategy via the registry
- Every service provider from Phase 4 is injected into `EventServices`
- `maxPauseDuration` from mode is forwarded to engine
- `distressChainId` is resolved to steps at start time
- `isSimulation` controls which messaging/phone provider is injected
- Battery alert uses the injected `_messaging`, not a raw provider read

**Tests (written BEFORE controller):**
- `session_controller_wiring_test.dart`:
  - Real session: `smsContact` step → `messagingService.sendToAll()` called
  - Simulation: `messagingService` NOT called, `simulationMessaging` IS used
  - `triggerDistressChain()` → engine.replaceWithDistressChain() called
  - Wrong PIN threshold → distress fires
  - Duress PIN → distress fires
  - Incoming call → engine paused; call ended → engine resumed
  - Battery alert → uses injected `_messaging`, not raw provider
  - `endSession()` → session log saved
- Router test: every named route resolves without throwing

**Gate:**
- Integration test: `ProviderContainer` with all fakes, engine driven through
  a complete session, assert each fake recorded the expected call sequence.
- Router test passes.
- Wiring contract test passes.

---

### Phase 8: Localization (parallel with Phase 7)

**What gets built:**
- All 14 ARB files in `lib/l10n/l10n/` (~335 keys each)
- `flutter gen-l10n`
- `tool/verify_l10n.dart` — script that checks every key in `app_en.arb`
  exists in all 13 other ARB files

**Gate:** `flutter gen-l10n` exits 0. Verification script passes.

---

### Phase 9: Core UI Infrastructure (sequential)

**What gets built:**
- `lib/core/theme/` — AppColors, typography, ThemeExtension,
  `GuardianAngelaLogo`, dark/light/system themes
- `lib/core/widgets/pin_keypad.dart`
- `lib/core/widgets/logarithmic_slider.dart`
- `lib/app.dart` — `MaterialApp.router` with GoRouter, theme, l10n delegates
- `tool/generate_icon.dart` + launcher icon generation

**Gate:** Widget tests for `PinKeypad` and `LogarithmicSlider`. App launches
to home screen on emulator without crash.

---

### Phase 10: Screens (sequenced groups)

**Group A (sequential):** Onboarding + Settings + PIN screens
- Wire to repositories and permission service
- Onboarding: 3 pages (Welcome, Profile+Contact, Permissions)
- PinSetup, PinEntry screens

**Group B (parallel, after A):** CRUD screens
- Contacts + ContactForm
- Modes + ModeEditor
- Templates + TemplateEditor
- DistressChain editor

**Group C (sequential, after B):** Session flow — highest wiring risk
- HomeScreen
- SessionScreen (dynamic UI per step type)
- FakeCallScreen
- SimulationSummary (with PIN practice + Skip, no "Start Real Session")
- SessionCompleted

**Group D (parallel, after C):** Remaining screens
- Profile, PastEvents, PastEventDetail, EvidenceExport
- About, Feedback, Backup
- BatteryAlert, EventDefaults

**Gate per group:** Widget test for happy path. No `UnimplementedError` in any
rendered widget. After Group C: integration test for full session flow
(Onboarding → Home → Start Session → Escalate → End).

---

### Phase 11: End-to-End Verification (sequential)

- Run all tests: `flutter test`
- Run `flutter analyze --fatal-infos`
- Run wiring contract test
- Manual device test: complete session on Android + iOS
- Verify all 14 languages render (including RTL: fa, ar, he)
- Verify stealth mode hides all branding
- Verify simulation blocks all real actions (4-layer defense)

---

## Part 3: Testing Strategy

### Testing Pyramid

**70% unit : 20% widget : 10% integration**

Unit tests are fast, deterministic, and cover the safety logic. Widget tests
verify UI wires to controllers. Integration tests are the 10% that prevent
shipping broken wiring — they are the most important tests despite being
fewest.

### Critical Integration Tests (P0 — must exist before any code ships)

| Test Name | What It Verifies |
|-----------|-----------------|
| `session_controller_sms_sends_via_messaging` | Engine fires smsContact step → fake messaging service received `sendToAll()` call |
| `session_controller_sim_blocks_real_messaging` | isSimulation=true → real messaging gets 0 calls, sim messaging gets calls |
| `session_controller_distress_pin_triggers_chain` | Duress PIN → `engine.replaceWithDistressChain()` called |
| `session_controller_wrong_pin_threshold` | N wrong PINs → distress chain fires |
| `session_controller_incoming_call_pauses` | Call state "ringing" → engine paused; "idle" → engine resumed |
| `session_controller_battery_alert_uses_injected` | Battery alert SMS uses `_messaging` field, not raw provider |
| `session_controller_end_persists_log` | `endSession()` → `sessionLogsRepo.save()` called |
| `session_controller_maxPauseDuration_forwarded` | Mode's `maxPauseDuration` reaches engine constructor |
| `wiring_contract_test` | Every provider resolves, every strategy holds correct service ref |

### Wiring Map

The wiring map is `test/wiring/wiring_contract_test.dart`. It:
- Instantiates `ProviderContainer` with all fakes
- Reads every service provider → asserts non-null
- Constructs `EventServices` bundle → asserts every field populated
- Verifies `EventStrategyRegistry` maps every `ChainStepType` to a strategy
- Asserts each strategy's service reference matches the injected fake

This test runs in < 2 seconds and fails loudly on any missing registration.

### Simulation 4-Layer Defense Tests

One test per layer boundary:

| Layer | Test |
|-------|------|
| 1. Engine flag | Engine with `isSimulation: true` still emits events (flag is informational, not blocking) |
| 2. Controller guard | Controller checks `isSimulation` before calling `strategy.executeReal()` |
| 3. Service param | `messagingService.sendMessage(isSimulation: true)` → no-op |
| 4. Subclass injection | `startSession(isSimulation: true)` → `simulationMessagingProvider` read, not `messagingServiceProvider` |

### Engine Testing Patterns

- All timer tests use `fakeAsync` + `_FixedRandom(0.5)` + injected clock.
- Event stream assertions: collect events into a list, assert sequence.
- Use explicit `async.elapse()` calls, never `flushTimers()`.
- Jitter tests: use `Random(seed)` to verify bounds, not exact values.
- Distress replacement: assert `isDistressChain` flag AND that original chain
  timers no longer fire.

---

## Part 4: Service Layer Design

### Service Interface Pattern

Services are concrete classes. Real and simulation behavior coexist via
two mechanisms:

- **Audio, Vibration, Notification, Location, Wakelock, Permission:**
  Single concrete class. `isSimulation` parameter on methods that need it
  (e.g., `playAlarm(isSimulation:)` → muted with notification in sim).

- **Messaging, Phone:** Separate subclasses.
  `SimulationMessagingService extends MessagingService` — structurally cannot
  reach real SMS/call code (no platform channel imports). The controller
  injects the simulation subclass when `isSimulation=true`.

### Provider Injection Rule

**Services must NOT read from Riverpod providers internally.** Dependencies
are passed at construction time or as method parameters. This prevents the
v1 bug where battery alert read a real provider instead of the injected one.

```dart
// WRONG — reads provider inside service
class BatteryMonitor {
  void check() {
    final threshold = ref.read(settingsProvider).batteryThreshold; // BUG
  }
}

// RIGHT — threshold passed in by controller
class BatteryMonitor {
  void check(int threshold) { ... }
}
```

### Platform Channel Architecture

| Channel | Type | Direction | Purpose |
|---------|------|-----------|---------|
| `com.guardianangela.app/sms` | MethodChannel | Dart→Native | SMS send + WorkManager enqueue |
| `com.guardianangela.app/audio` | MethodChannel | Dart→Native | STREAM_ALARM, earpiece/speaker routing, audio ducking |
| `com.guardianangela.app/phone` | MethodChannel | Dart→Native | Auto-dial with CALL_PHONE |
| `com.guardianangela.app/system_ui` | MethodChannel | Dart→Native | Quick Exit, battery exemption |
| `com.guardianangela.app/hardware_buttons` | EventChannel | Native→Dart | Volume key event stream |
| `com.guardianangela.app/call_state` | EventChannel | Native→Dart | Telephony state (idle/ringing/active) |
| `com.guardianangela.app/session_control` | MethodChannel | Dart→Native | Enable/disable button interception |
| `com.guardianangela.app/notification_actions` | EventChannel | Native→Dart | "I'm Safe" / "Pause" notification button taps |

No version numbers in channel names — Dart and Kotlin ship together.

### WorkManager SMS Contract

```
Dart → invokeMethod("enqueueSms", {phone, message})
     ← returns WorkManager UUID string (not a local counter)

Dart → invokeMethod("cancelWork", {workId: uuid})
     ← returns bool (actually calls WorkManager.cancelWorkById)

Dart → invokeMethod("sendSms", {phone, message})
     ← returns bool (synchronous SmsManager.sendTextMessage)
```

Primary path: `sendSms` (synchronous, immediate). Fallback: `enqueueSms`
(durable, survives process death). Both attempted for emergency SMS.

---

## Part 5: Engine Design Notes

### Injectable Clock

```dart
class SessionEngine {
  final DateTime Function() _now;

  SessionEngine({
    required List<ChainStep> chainSteps,
    bool isSimulation = false,
    double speedMultiplier = 1.0,
    Random? random,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;
}
```

Replace every `DateTime.now()` in the engine with `_now()`. In `fakeAsync`
tests, pass a clock that reads from the zone's elapsed time.

### Timer Pattern

Single active timer + state enum (`TimerPhase`). Pause captures remaining
duration via `_phaseTotalDuration - (_now() - _phaseStartedAt)`. Resume
creates a new timer with the captured remaining duration.

### Engine Boundary

The engine is pure Dart. It:
- Manages all timer state (wait, duration, grace, sensitivity)
- Handles hold button (holdStart/holdRelease with sensitivity window)
- Handles fake call (answerFakeCall pauses, hangUp disarms)
- Handles distress chain replacement (replaceWithDistressChain)
- Emits 10 events via broadcast stream
- Exposes `EngineState` via plain getter

The engine does NOT:
- Know about services, strategies, or providers
- Perform any I/O or side effects
- Import any Flutter package

---

## Part 6: UX Implementation Notes

### Hold Button in Dark (`fakeLockScreen` style)

Haptic feedback is the primary state confirmation channel when brightness is
near-zero:
- Strong single vibration on `holdStart()`
- Distinct double pulse on grace period entry
- Continuous short pulses during grace countdown

Visual color changes remain for normal use but are redundant in dark mode.

### Fake Call: Decline-with-Distress

Teach this gesture during simulation. `FakeCallStrategy.simulationDescription`
should say: "In a real session: hold Decline for 5s to trigger distress
silently." In real sessions, no visible hint (stealth).

### Onboarding

3 pages. Page 2 collects only name + phone (minimal). Explicitly tell user:
"They'll receive a text if you don't check in — you can change this anytime."

---

## Part 7: Known Risks and Mitigations

### Risk 1: Controller Wiring Gap (Phase 7)

This is where v1 failed. Mitigation: the wiring contract test and all P0
integration tests must pass before Phase 7 gate. Wiring owner reviews every
line of the controller.

### Risk 2: Race — Real Call During Fake Call

If a real call arrives during a fake call step, the fake call screen may
render on top of the real call UI. Mitigation: `CallStateChannel` emits
"ringing" → controller immediately dismisses fake call screen and pauses
engine. On call end, auto-disarm (user had a real call, safety satisfied).

### Risk 3: Timer Starvation (Battery Saver / Doze)

Android battery saver can delay timer callbacks by 30s+. Mitigation:
foreground service with `START_STICKY` + exact alarms via `AlarmManager` as
a watchdog. If the engine timer hasn't fired within 2× expected duration,
the watchdog fires a notification.

### Risk 4: Process Death

Engine state is in-memory only. If Android kills the process, the session
is lost. WorkManager SMS jobs already queued still fire but without context.
Mitigation: this is a known limitation documented in the spec. The watchdog
notification ("Your safety session was interrupted — tap to restart") alerts
the user on next launch. No auto-resume (user must consciously restart).

### Risk 5: Hive Encryption Key Loss

If `flutter_secure_storage` loses the key (device lock screen disabled,
keystore reset), all Hive data is unreadable. Current policy: nuke and
re-seed. Mitigation: manual JSON export/import as a backup mechanism.
On first launch, prompt user to export a backup after setup.

### Risk 6: Dual-SIM SMS

`SmsManager` on dual-SIM devices may send from the wrong SIM. Contacts
receive message from unknown number. Mitigation for v1: document limitation.
Future: allow user to select SIM subscription in settings.

### Risk 7: Seed Data Field Drift

A model field added after seed data is written won't be covered. Mitigation:
seed data test deserializes and re-serializes, failing on missing required
fields.

### Risk 8: build_runner Stale Outputs

If a model is touched after codegen, `.g.dart` is stale. Mitigation: CI runs
`build_runner build --delete-conflicting-outputs` on every push.

---

## Part 8: Parallelization Summary

| Phase | Can Run In Parallel With |
|-------|-------------------------|
| 3 (Native Channels) | 2 (Repos + Seed Data) |
| 8 (Localization) | 7 (Controller + Router) |
| 10 Group B (CRUD screens) | Each other |
| 10 Group D (Leaf screens) | Each other |

All other phases are strictly sequential.

---

## Part 9: Package Recommendations

| Purpose | Package | Notes |
|---------|---------|-------|
| State management | `flutter_riverpod` | NotifierProvider, AsyncNotifier |
| Navigation | `go_router` | Declarative, deep-linkable |
| Local storage | `hive_ce` + `hive_ce_flutter` | Always-encrypted via `HiveAesCipher` |
| Code generation | `hive_ce_generator` + `build_runner` | `.g.dart` type adapters |
| Secure storage | `flutter_secure_storage` | Encryption key storage |
| Audio playback | `just_audio` | Ringtones, voice recordings (NOT alarm) |
| Alarm audio | Native channel | `STREAM_ALARM` via Kotlin `MediaPlayer` |
| Vibration | `vibration` or `flutter_vibrate` | Pattern-based haptics |
| Location | `geolocator` | GPS coordinates |
| Notifications | `flutter_local_notifications` | Foreground + disguised |
| Background service | `flutter_background_service` | Persistent foreground service |
| Biometric auth | `local_auth` | Fingerprint / Face ID |
| URL launcher | `url_launcher` | WhatsApp/Telegram deep links, phone calls |
| Permissions | `permission_handler` | Runtime permission requests |
| Home widget | `home_widget` | Quick actions widget |
| Timer testing | `fake_async` | `fakeAsync()` wrapper |
| Test assertions | `checks` | Expressive assertions |
| Mocking | `mocktail` | Only when fakes insufficient |
| UUID generation | `uuid` | Model IDs |

---

## Part 10: Lessons Learned — Preventing Spec Drift

> **Context:** The v5 rewrite had 14 BLOCK-severity spec deviations
> found during post-implementation audit. All 14 were traced to a
> single root cause: agents copied behavior from old code (old5/)
> instead of reading the spec. This section documents the systemic
> failures and the mandatory process fixes.

### Root Cause: Old Code Treated as Authority

The skeleton phase instructed agents to "read old5 for reference."
Agents faithfully reproduced old5's bugs — wrong default values,
missing fields, missing methods, prohibited UI elements — because
the old code was treated as the source of truth instead of the spec.

**14 of 14 blockers were present in old5.** Zero were newly
introduced. The rewrite was a high-fidelity copy of the previous
rewrite's bugs.

### Failure Taxonomy

| Category | Count | Examples |
|----------|-------|---------|
| Wrong default values | 5 | `showConfirmation=false` (spec: true), `randomizeInterval=false` (spec: true), `sound=true` (spec: false), `sendSms=false` (spec: true), `recordDurationSeconds=120` (spec: 30) |
| Missing fields | 4 | `blackScreenMode` on 7 subtypes, `autoRecordVideo`, `callChannel`, `retryCount`, `isGlobal` |
| Missing methods | 1 | `EventDefaults.forType()` |
| No-op stubs shipped as done | 1 | `advanceFromHardwarePanic()` was a no-op |
| Prohibited UI present | 1 | "Start Real Session" button on SimulationSummary |
| Wrong simulation behavior | 1 | Fake call ringtone blocked in simulation (spec: fires normally) |
| Incomplete feature wiring | 1 | Session locks only on contacts (spec: also modes, backup, language) |

### Why the Process Didn't Catch It

1. **Tests verified consistency, not correctness.** A test that
   checks `default == false` passes even when the spec says `true`.
   Tests validated "does the code do what the code says?" not "does
   the code do what the spec says?"

2. **Reviews checked structure, not values.** The 3-expert review
   caught missing model classes (5 structural gaps fixed) but missed
   wrong defaults because reviewers checked "is the field present?"
   not "is the default value correct per the spec table?"

3. **No machine-verifiable spec compliance.** There was no automated
   test that loaded spec default values and compared them to code.

### Mandatory Process Rules (for all future work)

#### Rule 1: Spec Is Sole Authority

> **Old code is NEVER the source of truth.** Use old code ONLY for
> Dart syntax patterns (how to write `toJson`, how to structure a
> provider). NEVER copy field names, default values, method behavior,
> or UI decisions from old code. Every implementation decision must
> trace to a line in specs 00-11.

Agent prompts MUST include:
```
The SPEC is your sole authority. The old code has KNOWN BUGS.
Do NOT copy default values, field lists, or business logic from
old code. Read the spec for every field, every default, every
behavior. If the spec and old code disagree, the spec wins.
```

#### Rule 2: Spec Compliance Tests (spec_defaults_test.dart)

A dedicated test file MUST exist that hard-codes every default
value from the spec and asserts the code matches:

```dart
// test/regression/spec_defaults_test.dart
test('CallEmergencyConfig.showConfirmation defaults to true', () {
  check(const CallEmergencyConfig().showConfirmation).isTrue();
});
test('DisguisedReminderConfig.randomizeInterval defaults to true', () {
  check(const DisguisedReminderConfig().randomizeInterval).isTrue();
});
test('BatteryAlertConfig.sendSms defaults to true', () {
  check(const BatteryAlertConfig().sendSms).isTrue();
});
// ... one test per field with a spec-defined default
```

This file is written by reading the spec tables directly — NOT by
reading the code. It is the "spec-to-code bridge" that catches
drift automatically on every CI run.

#### Rule 3: Review Checklist Must Include Value Verification

Every phase review MUST include this checklist item:

> For every model field that has a default value: open the spec,
> find the field in the spec table, read the spec's default value,
> compare to the code's default value. Report any mismatch as
> BLOCK.

The review prompt MUST say:
```
Check EVERY default value against the spec table at
docs/spec/03-data-models.md. Do not trust the code's defaults
— verify each one independently against the spec. Wrong defaults
are safety-critical bugs.
```

#### Rule 4: Prohibited Feature Checklist

Maintain a list of features the spec explicitly prohibits:

- No "Start Real Session" button on SimulationSummary
- No sub-chains (distress REPLACES main chain)
- No crash recovery / checkpoint / SharedPreferences
- No `preferredChannel` on EmergencyContact
- No auto-resume after process death
- Shake-to-SOS rejected (false positive risk)

Agent prompts for UI phases MUST include:
```
The following features are EXPLICITLY PROHIBITED by the spec.
If you find any of these in old code, do NOT reproduce them:
[list above]
```

#### Rule 5: Simulation Behavior Matrix

Every service method must be checked against this matrix:

| Action | Real Mode | Simulation Mode |
|--------|-----------|-----------------|
| Fake call ringtone | Plays | **Plays (fires normally)** |
| Fake call vibration | Vibrates | **Vibrates (fires normally)** |
| Countdown vibration | Vibrates | **Vibrates (fires normally)** |
| Disguised reminder notification | Shows | **Shows ([SIM] suffix)** |
| GPS tracking | Records | **Records (fires normally)** |
| SMS / WhatsApp / Telegram | Sends | **BLOCKED (sim_blocked)** |
| Phone calls to contacts | Dials | **BLOCKED (sim_blocked)** |
| Emergency calls | Dials | **BLOCKED (sim_blocked)** |
| Loud alarm | Plays | **MUTED (notification shown)** |
| Audio recording | Records | **BLOCKED (sim_blocked)** |

Any `isSimulation` guard on a service method MUST be checked
against this matrix. A guard on `playRingtone` is WRONG (ringtone
fires normally in sim). A guard on `playAlarm` is CORRECT (alarm
is muted in sim).

#### Rule 6: Machine-Readable Spec Defaults (future)

Consider creating `docs/spec/defaults.json`:
```json
{
  "CallEmergencyConfig.showConfirmation": true,
  "DisguisedReminderConfig.randomizeInterval": true,
  "BatteryAlertConfig.sendSms": true,
  "SmsContactConfig.recordDurationSeconds": 30,
  ...
}
```

A test loads this JSON and verifies each key against the
corresponding Dart constructor default. This makes spec compliance
fully automated and eliminates the possibility of a human missing
a value during manual review.

### Metrics from the v5 Rewrite

| Metric | Value |
|--------|-------|
| Total blockers found in audit | 14 |
| Blockers inherited from old code | 14 (100%) |
| Blockers newly introduced | 0 |
| Blockers caught by 3-expert review (Phase B) | 5 structural |
| Blockers missed by review | 14 value/behavior |
| Blockers caught by spec compliance audit | 14 |
| Tests that passed despite wrong defaults | ~50 |
| Time to fix all blockers | ~2 hours |

**Conclusion:** The architecture, wiring, and engine are correct.
The failures were all in "did we read the spec table carefully
enough?" — a problem that is fully solvable with automated spec
compliance tests and stricter prompt engineering.

---

**Document generated:** 2026-04-14
**Last updated:** 2026-04-16 (added Part 10: Lessons Learned)
**Status:** Complete — implementation and audit done
