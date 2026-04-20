# Guardian Angela Rewrite -- PM Status Report (v2)

**Date:** 2026-04-10 (updated)
**Reviewer:** Architecture & PM Review Agent
**Codebase snapshot:** 95 lib files, 6,882 lines in lib/, 120 tests passing, 13 analysis issues (5 warnings in test/, 8 compile errors in one service impl)

---

## 1. Progress vs Plan

### Phase 0: Spec Hardening -- 90% complete (unchanged)

Spec 12 is normative and covers all decisions. Missing standalone spec files for Quick Exit, evidence export, home widget (described in prose only).

### Phase 1: Tests from Specs -- 15% complete (unchanged)

120 tests in 8 files. Covers engine contract (P0), timing, edge cases, models, seed data. Missing: orchestrator tests, validator tests, strategy tests, controller tests, widget tests, integration scenario tests, i18n/RTL tests.

### Phase 2: Foundation -- 85% complete (was 75%)

| Item | Status | Notes |
|------|--------|-------|
| Plain Dart models | DONE | 14 model files, all pure Dart |
| Hive adapters strategy | DONE (changed approach) | JSON-string storage via Box<String> instead of custom TypeAdapters. register_adapters.dart, json_adapter.dart, hive_type_ids.dart exist. No build_runner needed. |
| Service protocols + fakes | DONE | 11 protocols, 11 fakes |
| SessionEngine | DONE | 606 lines. Sub-chain stub remains. |
| Strategies (9 concrete) | DONE | All 9 present |
| Orchestrator | DONE | Passive handler + cleanDisarm (still partial) |
| SessionValidator | DONE | |
| Constants, theme, routes | DONE | |
| Gate: analyze + tests | PARTIAL | 120 tests pass. 8 compile errors in notification_service.dart. 5 test warnings. |

**Change since v1:** Adapter approach changed to JSON serialization via `Box<String>`. This is pragmatic -- avoids writing 15+ TypeAdapters and eliminates build_runner dependency for Hive. Trade-off: slower than binary, but acceptable for this app's data volume.

### Phase 3: Parallel Implementation -- 45% complete (was 10%)

| Agent Scope | Status | Detail |
|---|---|---|
| A: Engine + Orchestration + Native | 75% | Engine: 80% (sub-chain stub). Orchestrator: 70%. Native Android: 40% (5 Kotlin files, missing CallStateChannel, SystemUiChannel). Native iOS: 0%. |
| B: Data + Services | 50% | Protocols: 100%. Fakes: 100%. Implementations: 6 of 11 started (phone, audio, messaging, notification, location, vibration). notification_service.dart has 8 compile errors (API mismatch with flutter_local_notifications). Still missing: device_state, hardware_button, battery_monitor, geofence, incoming_call. |
| C: Session features | 55% | SessionController: real (171 lines, wired). SessionScreen: real (241 lines, phase-based rendering, wired to controller). FakeCallScreen: layout done (132 lines), buttons NOT wired. HoldButton + ImSafeSlider: functional widgets. chain_exhausted, simulation_summary: stubs. |
| D: CRUD features | 35% | HomeScreen: real (162 lines, mode selector chips, chain summary, contacts preview, start/simulate buttons, wired to controllers). Contacts/Modes/Templates/Profile: controllers exist with add/update/delete/reorder methods but no persistence. All editor/list screens remain 12-line stubs. |
| E: Settings + Auth + Onboarding | 40% | OnboardingScreen: real (326 lines, 3 pages: Welcome, Profile+Contact, Permissions, all skippable, wired). SettingsController: real (81 lines, theme/language/stealth/mode/emergency setters). PinUtils: real (44 lines, SHA-256+salt, constant-time comparison). All settings sub-screens: stubs. PIN entry/setup screens: stubs. |

### Phase 4: Integration -- 60% complete (was 5%)

| Item | Status |
|------|--------|
| Router | DONE -- 20 routes registered, all screens imported |
| main.dart | PARTIAL -- ProviderScope wraps app. HiveBoxes.init() still commented out. No adapter registration. No seed logic. isFirstLaunch hardcoded true. |
| app.dart | DONE -- MaterialApp.router with light/dark theme. No localization delegates wired. |
| Route guards | NOT DONE -- first-launch redirect works, no auth gate, no session-active guard |
| Quick Exit | DONE -- 57 lines, Android finishAndRemoveTask via platform channel, iOS decoy+exit. Not wired to UI. |
| Auth gate | NOT DONE |
| service_providers.dart | DONE -- 11 providers, all using fakes (TODO: swap to real implementations) |

### Phase 5: Stealth + New Features -- 5% complete (was 0%)

| Feature | Status |
|---------|--------|
| Quick Exit implementation | DONE (not wired) |
| StealthConfig resolver | DONE (41 lines, fromSettings factory) |
| PinUtils (hash/verify) | DONE |
| Icon disguise | NOT DONE |
| Notification hardening (stealth channel names) | PARTIAL -- notification_service.dart uses "Media" and "Updates" channel names |
| Destination auto-arrive | NOT DONE (model missing) |
| Evidence export | NOT DONE (model missing) |
| Home widget | NOT DONE |

### Phase 6: Translations -- 5% complete (unchanged)

Only English (1 of 14 languages). 51 ARB keys. 0 RTL languages.

### Phase 7: Polish -- 0% complete (unchanged)

---

## 2. Implementation Gaps -- File Manifest vs Reality

### New since v1

| File | Status |
|------|--------|
| data/adapters/register_adapters.dart | EXISTS -- no-op (JSON approach) |
| data/adapters/json_adapter.dart | EXISTS -- toJsonString/fromJsonString utilities |
| data/adapters/hive_type_ids.dart | EXISTS -- ID registry (20 entries) |
| services/service_providers.dart | EXISTS -- 11 Riverpod providers (all fakes) |
| services/implementations/phone_service.dart | EXISTS -- 58 lines, functional |
| services/implementations/audio_service.dart | EXISTS -- 138 lines, functional |
| services/implementations/messaging_service.dart | EXISTS -- 168 lines, functional |
| services/implementations/notification_service.dart | EXISTS -- 164 lines, COMPILE ERRORS |
| services/implementations/location_service.dart | EXISTS -- 107 lines, functional |
| services/implementations/vibration_service.dart | EXISTS -- 75 lines, functional |
| features/contacts/contacts_controller.dart | EXISTS -- 66 lines, in-memory CRUD |
| features/modes/modes_controller.dart | EXISTS -- 32 lines, seeded with Walk+Date |
| features/settings/settings_controller.dart | EXISTS -- 81 lines, granular setters |
| features/settings/event_defaults_controller.dart | EXISTS -- 19 lines |
| features/templates/templates_controller.dart | EXISTS -- 28 lines |
| features/profile/profile_controller.dart | EXISTS -- 45 lines |

### Still Missing from Plan

**Domain models:**
- `domain/models/destination.dart` -- needed for GPS auto-arrive
- `domain/models/evidence_package.dart` -- needed for evidence export

**Service implementations (5 of 11 missing):**
- `services/implementations/device_state_service.dart` -- wakelock + screen flash
- `services/implementations/hardware_button_service.dart` -- volume key detection
- `services/implementations/battery_monitor_service.dart` -- low battery trigger
- `services/implementations/geofence_service.dart` -- GPS arrival trigger
- `services/implementations/incoming_call_service.dart` -- auto-pause on real call

**Service protocols (3 missing from plan's 14):**
- `permission_service_protocol.dart`
- `backup_service_protocol.dart`
- `evidence_service_protocol.dart`

**Native code (4 files missing):**
- Android: `CallStateChannel.kt` -- TelephonyCallback for incoming call detection
- Android: `SystemUiChannel.kt` -- Quick Exit + battery exemption
- iOS: `CallStatePlugin.swift` -- CXCallObserver
- iOS: `SystemUiPlugin.swift` -- decoy + exit

**Features:**
- `features/home/widgets/home_widget_config.dart` -- OS-level home screen widget
- `features/session/session_engine_bridge.dart` -- (may not be needed; controller fulfills this role)

**Screens that remain 12-line stubs (18 of 23):**
contacts_screen, contact_form_screen, modes_screen, mode_editor_screen, settings_screen, profile_editor_screen, event_defaults_screen, reminder_templates_screen, template_editor_screen, about_screen, feedback_screen, backup_screen, pin_entry_screen, pin_setup_screen, past_events_screen, session_log_detail_screen, chain_exhausted_screen, simulation_summary_screen

**Real screens (5 of 23):**
home_screen (162 lines), session_screen (241 lines), fake_call_screen (132 lines), onboarding_screen (326 lines), [walk_session + session_controller are non-screen but functional]

---

## 3. Test Coverage Assessment

Unchanged from v1: 120 tests in 8 files. No new tests were added alongside the new controllers, service implementations, or screens.

### Critical Untested Code Added Since v1

| New Code | Lines | Tests |
|----------|-------|-------|
| ContactsController | 66 | 0 |
| ModesController | 32 | 0 |
| SettingsController | 81 | 0 |
| ProfileController | 45 | 0 |
| TemplatesController | 28 | 0 |
| EventDefaultsController | 19 | 0 |
| SessionController (full wiring) | 171 | 0 |
| PhoneService | 58 | 0 |
| AudioService | 138 | 0 |
| MessagingService | 168 | 0 |
| NotificationService | 164 | 0 (does not compile) |
| LocationService | 107 | 0 |
| VibrationService | 75 | 0 |
| PinUtils | 44 | 0 |
| QuickExit | 57 | 0 |
| HomeScreen | 162 | 0 |
| OnboardingScreen | 326 | 0 |
| SessionScreen | 241 | 0 |
| WalkSession | 111 | 0 |

**Total untested new code: ~2,093 lines across 19 files.** The test-to-code ratio is declining as features are added without tests.

---

## 4. Spec Compliance Check

### Newly Compliant Since v1

| Decision | Status |
|----------|--------|
| Controller owns stream subscription, calls orchestrator.handleEvent() | COMPLIANT -- SessionController._onEngineEvent dispatches to orchestrator |
| Service protocols typed via Riverpod Provider<T> | COMPLIANT -- service_providers.dart |
| Onboarding 3 pages (Welcome, Profile+Contact, Permissions) | COMPLIANT -- full implementation |
| PIN hashing with salt + constant-time comparison | COMPLIANT -- PinUtils |
| Quick Exit Android: finishAndRemoveTask | COMPLIANT -- via platform channel |
| Quick Exit iOS: decoy screenshot + exit(0) | COMPLIANT |
| Stealth notification channels: generic names ("Media", "Updates") | COMPLIANT -- in NotificationService |
| isSimulation on all service methods (defense-in-depth) | COMPLIANT -- all 6 real implementations check isSimulation |

### Still Non-Compliant (key items)

| Decision | Gap | Severity |
|----------|-----|----------|
| Sub-chain step-by-step execution | Engine stub immediately completes | HIGH |
| PIN prompt on critical actions (disarm during escalation, end session, Quick Exit) | No PIN flow wired anywhere; screens are stubs | HIGH |
| Wrong-PIN threshold: pause main -> deceptive dialog -> sub-chain -> resume | Not implemented | HIGH |
| Pause stops all audio/vibration/flash immediately | Orchestrator cleanDisarm() only clears message IDs | HIGH |
| Session locks (block contact deletion, backup import during session) | Not implemented | MEDIUM |
| Decline with Distress (hold decline 3s -> distress chain) | FakeCallScreen buttons not wired | MEDIUM |
| GPS disarm: geofence-based, always asks confirmation | No implementation, no geofence service impl | MEDIUM |
| Background session service (foreground service + notifications) | No BackgroundSessionService implementation | HIGH |
| 14 languages (3 RTL) | Only English | HIGH (for shipping) |
| Remove camera, font_awesome_flutter, audio_service from pubspec | All 3 still present | LOW |
| Add archive, geofence_service packages | Neither added | LOW |

---

## 5. Architecture Concerns

### Strengths (unchanged)

1. Domain purity maintained -- all models plain Dart.
2. Sealed types used correctly throughout.
3. Engine is pure Dart, fully testable.
4. Strategy pattern for step execution.
5. Clean dependency flow: features -> domain, services -> domain/models.
6. No circular imports.
7. No god classes -- largest file is 606 lines (engine).

### New Concerns

1. **notification_service.dart has 8 compile errors.** The `_plugin.show()` call signature does not match the flutter_local_notifications API. Positional vs named arguments mismatch. This file cannot be used until fixed. This is the ONLY service implementation with errors -- the other 5 compile and look correct.

2. **Controllers have no persistence.** Every controller (contacts, modes, settings, profile, templates, event_defaults) builds with hardcoded defaults and has `// TODO: Persist to repository` comments on every mutation. Data lives in memory only. If the app is restarted, all user data is lost. The JSON adapter infrastructure exists (`json_adapter.dart`) but is not actually used by any controller or repository.

3. **SettingsController manually reconstructs AppSettings on every setter call.** Each setter (setThemeMode, setLanguage, setSelectedModeId, etc.) creates a new AppSettings by manually copying all fields. This is error-prone -- AppSettings has 20+ fields but the setters only copy 6. All stealth fields, security fields, alarm settings, GPS settings, PIN hashes, wrong-PIN threshold, and schemaVersion are silently reset to defaults on every single setter call. **This is a data-loss bug.** AppSettings needs a `copyWith()` method.

4. **service_providers.dart still wires all fakes.** The 6 real service implementations exist but are not used. The TODO comment acknowledges this. Swapping to real implementations requires either conditional logic or separate provider overrides for testing.

5. **FakeCallScreen is not wired to SessionController.** Both Answer and Decline buttons have `onPressed: () {}` (no-op). The screen also does not use ConsumerWidget and cannot access Riverpod providers. It needs to be converted to ConsumerWidget and wired.

6. **HomeScreen "Start Session" button navigates to session route but does not call SessionController.startSession().** The session screen shows "No active session" because no one starts the engine. The TODO comment acknowledges this. This is the critical gap preventing end-to-end flow.

7. **main.dart HiveBoxes.init() is commented out.** The app boots with in-memory defaults only. No encryption key is generated, no boxes are opened, no data is persisted.

8. **Seed data generates new UUIDs on every call.** ModesController.build() calls seedWalkMode() and seedDateMode() which use `Uuid().v4()` for step IDs. Every app restart produces different step IDs. This prevents any ID-based references from surviving a restart. Either use fixed IDs for built-in modes or ensure seeding only happens once.

---

## 6. Next Priority Recommendations

### The critical path to a working end-to-end demo

The app is tantalizingly close to an end-to-end working demo (onboarding -> home -> start session -> hold button -> disarm -> end session). The blockers are small but numerous:

**Priority 1: Fix the 3 wiring gaps that prevent the core flow**

1. **Add `copyWith()` to AppSettings.** The current SettingsController silently drops 15+ fields on every mutation. This is a data-loss bug that will cause bizarre behavior the moment anyone changes a setting. Estimated: 30 minutes.

2. **Wire HomeScreen "Start Session" to SessionController.startSession().** Currently navigates to /session without starting the engine. Need to resolve the selected mode, create the strategy registry with real/fake services from providers, and call startSession before navigating. Estimated: 1 hour.

3. **Fix notification_service.dart compile errors.** 8 errors in flutter_local_notifications API usage (positional vs named argument mismatch). Likely a version difference. Estimated: 30 minutes.

**Priority 2: Close the persistence gap**

4. **Connect controllers to repositories.** The JSON adapter exists. The repositories exist. The controllers have TODO markers. Each controller's `build()` needs to load from repository, and each mutation needs to persist. This is straightforward wiring. Estimated: 2-3 hours for all 6 controllers.

5. **Uncomment main.dart initialization.** Call HiveBoxes.init(), call registerHiveAdapters(), check for first launch, seed defaults, load settings for initial route. Estimated: 1 hour.

**Priority 3: Wire FakeCallScreen and complete session flow**

6. **Convert FakeCallScreen to ConsumerWidget.** Wire Answer/Decline to SessionController. Add "Decline with Distress" (3s hold on decline button). Estimated: 1-2 hours.

7. **Swap service_providers.dart from fakes to real implementations** (for the 5 that compile). Keep fakes for the 5 that don't have implementations yet. Estimated: 30 minutes.

**Priority 4: Fill the remaining screen stubs (CRUD)**

8. **ContactsScreen + ContactFormScreen.** List with reorder, edit/delete, form with name/phone/relationship/channel. Estimated: 3-4 hours.

9. **SettingsScreen.** Section list: Theme, Language, Stealth toggles, Security (PIN setup), Emergency number, About/Feedback/Backup links. Estimated: 2-3 hours.

10. **ModesScreen + ModeEditorScreen.** List of modes, chain step drag-and-drop editor. This is the most complex CRUD screen. Estimated: 4-6 hours.

**Priority 5: Remaining service implementations**

11. **device_state_service.dart** (wakelock + screen flash) -- uses wakelock_plus
12. **hardware_button_service.dart** -- wraps platform channel from MainActivity
13. **battery_monitor_service.dart** -- uses battery_plus
14. **incoming_call_service.dart** -- needs native CallStateChannel first
15. **geofence_service.dart** -- needs geofence_service package added

**Priority 6: Engine sub-chain execution**

16. Replace the sub-chain stub with real step-by-step timer execution. This is needed for duress, battery, and wrong-PIN chains. Estimated: 4-6 hours.

**Priority 7: PIN authentication flow**

17. PinEntryScreen (real UI, timeout countdown, biometric option).
18. PinSetupScreen (enter, confirm, store hash).
19. Wire PIN prompts into SessionController for disarm/end/Quick Exit.

**Priority 8: Everything else** (translations, stealth hardening, tests, polish, native iOS code)

---

## 7. Risk Register

### Critical Risks

| # | Risk | Impact | Status |
|---|------|--------|--------|
| 1 | **AppSettings copyWith missing -- data loss on every setter call** | Every settings change silently resets stealth flags, PIN hashes, alarm config, emergency number to defaults. Will cause "stealth mode keeps turning off" and "PIN keeps getting deleted" bugs. | NEW. Must fix before any user testing. |
| 2 | **No persistence -- controllers are in-memory only** | All user data lost on app restart. Contacts, modes, settings, profile, templates -- everything. | Infrastructure exists (JSON adapters, repositories, Hive boxes) but wiring is missing. |
| 3 | **Sub-chain execution is a stub** | Duress chain, battery chain, wrong-PIN chain cannot actually run step-by-step. | Unchanged. |
| 4 | **notification_service.dart does not compile** | Cannot use real notifications until fixed. Blocks background session, disguised reminders, and foreground service notification. | NEW. 8 errors in flutter_local_notifications API usage. |
| 5 | **No background session service** | Session dies when app is backgrounded. | Unchanged. No foreground service wiring exists on either platform. |

### High Risks

| # | Risk | Impact | Status |
|---|------|--------|--------|
| 6 | **HomeScreen does not start engine** | Tapping "Start Session" shows "No active session" screen. Core user flow is broken. | NEW. Easy fix but blocks all manual testing. |
| 7 | **FakeCallScreen not wired** | Answer/Decline buttons do nothing. Fake call step type is non-functional in UI. | Unchanged. |
| 8 | **Seed data UUIDs are non-deterministic** | Built-in mode step IDs change on every restart. Any ID-based reference (selectedModeId in settings, contactIds in step configs) breaks across restarts. | Unchanged. |
| 9 | **pubspec not cleaned up** | camera, font_awesome_flutter, audio_service still included (~700KB bloat). archive, geofence_service not added. | Unchanged. |
| 10 | **PIN flow not implemented** | Abuser can end session, Quick Exit, disarm during escalation without PIN challenge. | Unchanged. |
| 11 | **Only 1 of 14 languages** | Cannot ship internationally. No RTL testing. | Unchanged. |
| 12 | **Test coverage declining** | 2,093 lines of new code added with zero new tests. Test-to-code ratio dropped from ~45% to ~37%. Controllers and service implementations are completely untested. | NEW. |

### Positive Changes Since v1

- ProviderScope wrapping is done -- Riverpod works end-to-end
- Router is fully wired with 20 routes
- 6 of 11 service implementations exist and are functional (except notification)
- Onboarding is complete and functional
- HomeScreen has real UI with mode selector, chain preview, contacts
- SessionScreen has phase-based rendering wired to engine state
- Controllers exist for all CRUD entities with proper state management
- JSON persistence strategy eliminates build_runner dependency

---

## Overall Assessment

**Revised completion estimate: 40%.** Up from 25% in v1.

The project has made meaningful progress in Phase 3 and Phase 4. The integration layer (router, providers, controllers) is the biggest win -- it was the most critical missing piece. The codebase went from "interesting engine with placeholder everything" to "almost runnable app with wiring gaps."

**The distance to a working demo is small.** The 3 highest-priority items (AppSettings.copyWith, wire HomeScreen start, fix notification compile errors) together represent perhaps 2 hours of work and would unlock the first end-to-end manual test of the core safety flow.

**The distance to a shippable app is still large.** 18 stub screens, 5 missing service implementations, 0 persistence wiring, 0 PIN flow, 0 background session, 0 translations, 0 tests for any new code, sub-chain stub, native iOS code entirely missing.

**Most impactful single task right now:** Fix AppSettings.copyWith and wire HomeScreen to SessionController.startSession(). This unblocks manual testing of the entire onboarding-to-session flow and makes every subsequent task easier to validate.
