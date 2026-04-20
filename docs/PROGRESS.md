# Guardian Angela — Rewrite Progress Log

## Status as of session restart

### Completed
- [x] Spec documents written (docs/spec/00 through 07)
- [x] ChainStep model rewritten with 3-phase timing fields (durationSeconds, gracePeriodSeconds, repeatIntervalSeconds + non-persisted randomize)
- [x] ChainStepType enum updated with hardwareButton (9th type)
- [x] SessionEngine rewritten from scratch (546 lines, pure Dart state machine)
- [x] Test suite: ~1,084 tests across 28 files (TDD — most will fail until full implementation)
- [x] Audit completed: 21 issues identified
- [x] Test helper (_mocks.dart) with FixedRandom, step(), walkModeChain(), dateModeChain()

### Test Files Written
- test/unit/engine/ (10 files, ~404 tests): lifecycle, hold_button, reminder, timing, disarm, simulation, event_order, invariants, repeat_cycle, edge_cases
- test/unit/models/ (11 files, ~379 tests): chain_step, session_mode, app_settings, event_defaults, walk_session, seed_data, emergency_contact, session_log, user_profile, reminder_template, hive_type_ids
- test/integration/ (7 files, ~301 tests): walk_scenarios, date_scenarios, fake_call_scenarios, alarm_scenarios, emergency_scenarios, simulation_scenarios, chain_edge_cases

### Known Issues from Audit
1. ChainStep: durationSeconds and randomize NOT persisted (no @HiveField) — durationSeconds now has no @HiveField, randomize has no @HiveField
2. AppSettings: missing stealthMode, notificationDisguise fields, schemaVersion still 2 (should be 3)
3. EventDefaults: missing hardwareButton config map
4. EventStrategyRegistry: missing hardwareButton strategy
5. Seed data: timing values don't match spec table (grace has what should be duration)
6. Migration: checks v<2, should check v<3
7. Chain exhausted screen: "View Log" navigates to home instead of log detail

### Changes Made This Session (bash broken, documenting for next session)
- [x] ChainStep: added @HiveField(7) to durationSeconds, @HiveField(8) to randomize
- [x] AppSettings: added stealthMode(@HiveField 6), notificationDisguise(@HiveField 7), schemaVersion default 3
- [x] EventDefaults: added hardwareButton map (@HiveField 8) with defaults (volumeUp, triplePress, -1)
- [x] Seed data: REWRITTEN with correct 3-phase timing (durationSeconds + gracePeriodSeconds per spec table)
- [x] Migration: updated to check v<3, init stealthMode=false
- [x] HardwareButtonStrategy: created event_strategies/hardware_button_strategy.dart
- [x] EventStrategyRegistry: added hardwareButton → HardwareButtonStrategy()
- [x] ChainExhaustedScreen: "View Log" now navigates to pastEventDetail with lastLogId (was navigating to home)

### Still Needs To Be Done
1. **Regenerate Hive adapters** — `flutter pub run build_runner build --delete-conflicting-outputs`
2. **Create hardware_button_strategy.dart** — event strategy for panic trigger
3. **Rewrite session controller** for new engine API (3-phase timing)
4. **Fix chain exhausted screen** — "View Log" should navigate to log detail with lastLogId
5. **Add stealth mode toggle** to settings screen
6. **Add simulation speed toggle** (1x/5x) to session screen
7. **Run tests** — verify how many of 1,084 pass
8. **Full build verification** — `flutter build apk --debug`

### Test Results (current)
- **Model tests**: 398/398 pass (100%)
- **Engine tests**: 178/404 pass (44%) — 226 fail due to spec/implementation mismatches
- **Integration tests**: compilation errors in some files (API differences)
- **Total**: 576 pass, 233 fail
- **APK**: builds successfully
- **flutter analyze**: 0 errors in lib/, ~438 in test/ (expected TDD failures)

### Next Priority: Fix failing engine tests
The 226 engine failures are the spec encoded as assertions. Fix the engine to match.
Common failure patterns:
- Tests expect 3-phase timing (wait→duration→grace) but engine uses different field names
- Tests expect specific event ordering that doesn't match
- Repeat count semantics (> vs >=) mismatch between test files

### Key Design Decisions (from spec)
- Simulation: 1x default speed, 5x toggle, skip button (1s leap)
- Stealth: collapsible per-feature toggles in settings
- holdButton: "Touch to begin" prompt, NO auto-timer on start
- fakeCall decline: grace → ring again (NOT disarm)
- Notification: "I'm Safe" / "Pause" universal disarm button
- 9 event types: holdButton, disguisedReminder, countdownWarning, fakeCall, smsContact, phoneCallContact, loudAlarm, callEmergency, hardwareButton
