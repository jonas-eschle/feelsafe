# Guardian Angela -- Exhaustive Remaining Gaps

Generated: 2026-04-10

---

## A. ROUTES: Defined in RouteNames but not registered in app_router.dart

```
[ ] GAP-1: [MISSING] Route simulationLoading not registered
    File: lib/core/constants/route_names.dart:12
    Fix: Either create a SimulationLoadingScreen and register the route, or remove the constant if it is unused.

[ ] GAP-2: [MISSING] Route simulationSummary not registered
    File: lib/core/constants/route_names.dart:13
    Fix: Either create a SimulationSummaryScreen and register the route, or remove the constant.

[ ] GAP-3: [MISSING] Route eventDefaults not registered
    File: lib/core/constants/route_names.dart:25
    Fix: Create an EventDefaultsScreen to list/edit per-step-type global defaults and register the route.

[ ] GAP-4: [MISSING] Route eventDefaultDetail not registered
    File: lib/core/constants/route_names.dart:26
    Fix: Create an EventDefaultDetailScreen (accepts ?type= query parameter) and register the route.

[ ] GAP-5: [MISSING] Route templateEdit not registered
    File: lib/core/constants/route_names.dart:28
    Fix: Create a TemplateEditScreen (accepts ?id= query parameter) and register the route in app_router.dart.

[ ] GAP-6: [MISSING] Route pastEventDetail not registered
    File: lib/core/constants/route_names.dart:38
    Fix: Create a PastEventDetailScreen (accepts ?id= query parameter) and register the route.

[ ] GAP-7: [MISSING] Route evidenceExport not registered
    File: lib/core/constants/route_names.dart:39
    Fix: Create an EvidenceExportScreen (accepts ?id= query parameter) for text/JSON/PDF export and register the route.
```

---

## B. APP BOOTSTRAP AND WIRING

```
[ ] GAP-8: [WIRING] app.dart does not use AppTheme (light/dark) or respond to settings.themeMode
    File: lib/app.dart:15-21
    Fix: Inject AppSettings themeMode, use AppTheme.light()/dark(), set ThemeMode based on the setting. Currently hardcodes dark theme and ignores AppTheme entirely.

[ ] GAP-9: [WIRING] app.dart does not use AppLocalizations.delegate -- localization is non-functional
    File: lib/app.dart:22-28
    Fix: Replace GlobalLocalizations delegates with AppLocalizations.localizationsDelegates and AppLocalizations.supportedLocales. Currently only supports Locale('en') and doesn't include the generated AppLocalizations delegate.

[ ] GAP-10: [WIRING] app.dart hardcodes supportedLocales to [Locale('en')] -- 13 other languages wasted
    File: lib/app.dart:27
    Fix: Use AppLocalizations.supportedLocales (auto-generated from all ARB files).

[ ] GAP-11: [WIRING] main.dart does not pass isFirstLaunch from settings to createRouter()
    File: lib/main.dart:12
    Fix: Read AppSettings from the settings repo before creating the router, pass isFirstLaunch to createRouter(). Currently first-launch redirect never fires.

[ ] GAP-12: [WIRING] main.dart does not call registerHiveAdapters()
    File: lib/main.dart:10
    Fix: Call registerHiveAdapters() after Hive init. Currently a no-op function but should be called for forward-compatibility.

[ ] GAP-13: [WIRING] NotificationService.init() is never called
    File: lib/services/implementations/notification_service.dart:17
    Fix: Call init() in main.dart or in the provider. Without it, flutter_local_notifications is uninitialized and all notification calls will fail silently.

[ ] GAP-14: [WIRING] app.dart does not respond to settings.languageCode for locale switching
    File: lib/app.dart:13
    Fix: Watch settingsControllerProvider.languageCode and set MaterialApp.router locale accordingly.
```

---

## C. SESSION CONTROLLER -- MISSING SERVICE WIRING

```
[ ] GAP-15: [MISSING] SessionController never calls locationService.startTracking() / stopTracking()
    File: lib/features/session/session_controller.dart:57-166
    Fix: Call startTracking() in startSession() and stopTracking() in endSession(). GPS logging is configured but never activated.

[ ] GAP-16: [MISSING] SessionController never calls deviceStateService.enableWakelock() / disableWakelock()
    File: lib/features/session/session_controller.dart:57-166
    Fix: Enable wakelock at session start, disable at session end. Without this the screen can turn off during a safety session.

[ ] GAP-17: [MISSING] SessionController never calls notificationService.showSessionNotification()
    File: lib/features/session/session_controller.dart:57-166
    Fix: Show the persistent foreground notification at session start, update it on events, cancel on session end.

[ ] GAP-18: [MISSING] SessionController does not create or wire TriggerManager
    File: lib/features/session/session_controller.dart
    Fix: Instantiate TriggerManager with the engine, mode, and services. Call start() at session start and dispose() at session end. Without this, hardware button distress triggers and GPS arrival disarm triggers do not function.

[ ] GAP-19: [MISSING] SessionController does not wire battery monitor for sub-chain
    File: lib/features/session/session_controller.dart
    Fix: If BatteryAlertConfig.isEnabled, start the BatteryMonitorService at session start, subscribe to onLowBattery, and call engine.startSubChain(SubChainType.battery, ...) when it fires.

[ ] GAP-20: [MISSING] SessionController does not set session active on Android (volume key interception)
    File: lib/features/session/session_controller.dart
    Fix: Call MethodChannel('com.guardianangela.app/session_control').invokeMethod('setSessionActive', true) at session start and false at session end. Without this, volume keys are not intercepted during sessions.

[ ] GAP-21: [MISSING] cleanDisarm in orchestrator does not actually cancel pending SMS or send false alarm
    File: lib/domain/orchestration/session_orchestrator.dart:106-113
    Fix: Pass the MessagingServiceProtocol to the orchestrator. On cleanDisarm(), call messaging.cancelPending(pendingMessageIds) and messaging.sendFalseAlarm(...). Currently only clears the local list.

[ ] GAP-22: [MISSING] SessionController never persists the session log to sessionLogsRepoProvider
    File: lib/features/session/session_controller.dart:255-260
    Fix: After _logRecorder.close(), save the session log via ref.read(sessionLogsRepoProvider).save(logRecorder.sessionLog).

[ ] GAP-23: [MISSING] SessionController does not stop audio/vibration/flash on disarm or session end
    File: lib/features/session/session_controller.dart:255-260
    Fix: Call audio.stop(), vibration.cancel(), deviceState.stopFlash(), deviceState.stopScreenFlash(), notificationService.cancelAll() on session end and on disarm events.
```

---

## D. SUB-CHAIN CONTROLLERS -- NO PERSISTENCE

```
[ ] GAP-24: [WIRING] DuressChainController has no Hive persistence
    File: lib/features/settings/duress_chain_controller.dart:11-22
    Fix: Load from duressChainRepoProvider in build(), save to repo in setEnabled() and updateChainSteps(). Currently starts from default empty state every app launch.

[ ] GAP-25: [WIRING] BatteryAlertController has no Hive persistence
    File: lib/features/settings/battery_alert_controller.dart:10-38
    Fix: Load from batteryAlertRepoProvider in build(), save to repo on every mutation.

[ ] GAP-26: [WIRING] WrongPinChainController has no Hive persistence
    File: lib/features/settings/wrong_pin_chain_controller.dart:10-22
    Fix: Load from wrongPinChainRepoProvider in build(), save to repo on every mutation.

[ ] GAP-27: [WIRING] TemplatesController has no Hive persistence
    File: lib/features/templates/templates_controller.dart:13-30
    Fix: Load from templatesRepoProvider in build(), persist on saveTemplate() and deleteTemplate(). Currently re-seeds from seedReminderTemplates() every app launch, losing user edits.
```

---

## E. SUB-CHAIN SCREENS -- MISSING STEP EDITING

```
[ ] GAP-28: [MISSING] DuressChainScreen has no UI to add/remove/reorder chain steps
    File: lib/features/settings/duress_chain_screen.dart:29-55
    Fix: Add an "Add Step" FAB and delete/reorder controls for the step list. Currently read-only display of an always-empty list.

[ ] GAP-29: [MISSING] WrongPinChainScreen has no UI to add/remove chain steps
    File: lib/features/settings/wrong_pin_chain_screen.dart:20-38
    Fix: Add step editing UI similar to DuressChainScreen.

[ ] GAP-30: [MISSING] BatteryAlertScreen has no UI to add/remove chain steps
    File: lib/features/settings/battery_alert_screen.dart:17-45
    Fix: Add a chain steps section below the threshold slider.
```

---

## F. HISTORY / PAST EVENTS

```
[ ] GAP-31: [STUB] PastEventsScreen always shows empty state, never loads from repo
    File: lib/features/history/past_events_screen.dart:6
    Fix: Make it a ConsumerWidget, watch sessionLogsRepoProvider, display actual session logs. The comment says "Persistence wired in Slice 4" but it was never done.

[ ] GAP-32: [MISSING] No PastEventDetailScreen exists
    File: lib/core/constants/route_names.dart:38
    Fix: Create a detail screen showing full event timeline, GPS track, and metadata for a single session log.

[ ] GAP-33: [MISSING] No EvidenceExportScreen exists (text/JSON/PDF export)
    File: lib/core/constants/route_names.dart:39
    Fix: Create the screen with export options using share_plus and path_provider.
```

---

## G. BACKUP & RESTORE

```
[ ] GAP-34: [STUB] Backup export button shows "Export not yet implemented" snackbar
    File: lib/features/settings/backup_screen.dart:29
    Fix: Implement JSON export of all boxes (settings, contacts, modes, templates, logs, sub-chain configs) as an encrypted file. Use share_plus for sharing.

[ ] GAP-35: [STUB] Backup import button shows "Import not yet implemented" snackbar
    File: lib/features/settings/backup_screen.dart:39
    Fix: Implement file picker + JSON import with validation and schema version check.
```

---

## H. ONBOARDING -- PERMISSION REQUESTS

```
[ ] GAP-36: [STUB] Onboarding permission "Grant" buttons do nothing
    File: lib/features/onboarding/onboarding_screen.dart:216
    Fix: Wire each button to the corresponding permission_handler request (notifications, location, phone, SMS). The comment says "Permission requests wired in Slice 6" but it was never done.
```

---

## I. CONTACT FORM

```
[ ] GAP-37: [BUG] ContactFormScreen uses DropdownButtonFormField with `initialValue` which is not a valid parameter
    File: lib/features/contacts/contact_form_screen.dart:68
    Fix: Change `initialValue: _channel` to `value: _channel`. DropdownButtonFormField uses `value`, not `initialValue`. This will cause a compile error or runtime assertion failure.

[ ] GAP-38: [MISSING] ContactFormScreen only supports "Add" -- no edit mode
    File: lib/features/contacts/contact_form_screen.dart:29-38
    Fix: Read the ?id= query parameter, pre-fill fields from existing contact, call updateContact() instead of addContact() when editing. The route is /contacts/edit?id=...

[ ] GAP-39: [MISSING] ContactsScreen has no tap-to-edit on contact list tiles
    File: lib/features/contacts/contacts_screen.dart:29-42
    Fix: Add onTap to ListTile that navigates to contact form with ?id=<contact.id>.
```

---

## J. MODE EDITOR GAPS

```
[ ] GAP-40: [MISSING] ModeEditorScreen has no per-step timing editor
    File: lib/features/modes/mode_editor_screen.dart:187-195
    Fix: The subtitle shows wait/duration/grace/retries but there is no way to edit them. Add expandable per-step timing controls.

[ ] GAP-41: [MISSING] ModeEditorScreen has no per-step config editor
    File: lib/features/modes/mode_editor_screen.dart
    Fix: Add a way to configure the step-type-specific StepConfig (e.g., FakeCallConfig callerName, SmsContactConfig contactIds). Currently all steps get null config and rely on EventDefaults.

[ ] GAP-42: [MISSING] No EventDefaults editor screen exists
    File: lib/core/constants/route_names.dart:25-26
    Fix: Create EventDefaultsScreen and EventDefaultDetailScreen to let users customize global per-step-type defaults.
```

---

## K. PROFILE EDITOR GAPS

```
[ ] GAP-43: [MISSING] ProfileEditorScreen does not include medical profile fields
    File: lib/features/profile/profile_editor_screen.dart:50-66
    Fix: Add fields for physicalDescription, bloodType, allergies, medications, medicalConditions, emergencyMedicalNotes. These fields exist on UserProfile but cannot be edited.
```

---

## L. SETTINGS GAPS

```
[ ] GAP-44: [MISSING] No PIN setup/change UI -- settings declares appPinHash, sessionEndPinHash, duressPinHash but no screen to set them
    File: lib/domain/models/app_settings.dart:56-60
    Fix: Create a PinSetupScreen (or a section in settings) to set/change the app PIN, session-end PIN, and duress PIN. Currently PinEntryDialog reads these hashes but there is no way to create them.

[ ] GAP-45: [MISSING] SettingsController has no methods for setting PIN hashes
    File: lib/features/settings/settings_controller.dart
    Fix: Add setAppPinHash(), setSessionEndPinHash(), setDuressPinHash(), clearAppPinHash() methods.

[ ] GAP-46: [MISSING] Settings screen has no link to PIN setup
    File: lib/features/settings/settings_screen.dart
    Fix: Add a Security section with PIN setup/change/clear tiles.

[ ] GAP-47: [MISSING] No language selector in settings -- setLanguage() exists but is never called from UI
    File: lib/features/settings/settings_controller.dart:43
    Fix: Add a language picker to settings screen that calls setLanguage().

[ ] GAP-48: [MISSING] Stealth mode sub-settings not configurable from UI
    File: lib/features/settings/settings_screen.dart:53-58
    Fix: When stealth mode is toggled on, show sub-options: hide progress bar, hide missed indicators, hide grace visuals, suppress end screen, disguise notification, timer display mode, etc. Currently only a single on/off toggle.

[ ] GAP-49: [MISSING] No biometric authentication setup (local_auth is in dependencies but never used)
    File: pubspec.yaml:74
    Fix: Wire local_auth for biometric unlock as an alternative to PIN entry.
```

---

## M. DEVICE STATE SERVICE -- STUB IMPLEMENTATIONS

```
[ ] GAP-50: [STUB] DeviceStateService.startScreenFlash() only sets a boolean, does not actually flash
    File: lib/services/implementations/device_state_service.dart:32
    Fix: Implement actual screen flashing using an overlay or color alternation timer.

[ ] GAP-51: [STUB] DeviceStateService.startSosFlash() only sets a boolean, does not drive camera torch
    File: lib/services/implementations/device_state_service.dart:39
    Fix: Implement SOS morse pattern (... --- ...) using torch_light or camera API.

[ ] GAP-52: [STUB] DeviceStateService.startContinuousFlash() only sets a boolean
    File: lib/services/implementations/device_state_service.dart:42
    Fix: Implement continuous camera torch using torch_light or camera API.
```

---

## N. QUICK EXIT -- MISSING NATIVE CODE

```
[ ] GAP-53: [MISSING] Quick Exit Android native method 'clearRecentsAndExit' not implemented
    File: lib/core/utils/quick_exit.dart:22
    Fix: Add a MethodChannel handler in MainActivity.kt for 'com.guardianangela.app/system_ui' that calls finishAndRemoveTask(). Currently the method channel has no handler and will throw PlatformException.

[ ] GAP-54: [WIRING] QuickExit is never used from any screen
    File: lib/core/utils/quick_exit.dart
    Fix: Add a Quick Exit button to the session screen or home screen (typically power-button double-tap or a hidden gesture).
```

---

## O. FAKE CALL SCREEN GAPS

```
[ ] GAP-55: [MISSING] FakeCallScreen does not read FakeCallConfig for callerName, callStyle, voiceRecording
    File: lib/features/fake_call/fake_call_screen.dart:19-20
    Fix: Pass the current step's FakeCallConfig from SessionController. Currently hardcodes callerName='Angela' and ignores callStyle, voice recording, caller photo.

[ ] GAP-56: [MISSING] FakeCallScreen does not play ringtone or vibrate
    File: lib/features/fake_call/fake_call_screen.dart
    Fix: Call audioService.playRingtone() and vibrationService.fakeCallPattern() when the screen appears, and stop on answer/decline.

[ ] GAP-57: [MISSING] FakeCallScreen does not play voice recording after answering
    File: lib/features/fake_call/fake_call_screen.dart:31-33
    Fix: If FakeCallConfig.voiceRecordingPath is set, play it via audioService.playVoiceRecording() after the call is answered.
```

---

## P. SESSION SCREEN GAPS

```
[ ] GAP-58: [MISSING] SessionScreen does not show disguised reminder overlays
    File: lib/features/session/session_screen.dart
    Fix: When currentStepType == disguisedReminder and phase == stepActive, show the disguised reminder UI (template-based notification overlay with confirmation).

[ ] GAP-59: [MISSING] SessionScreen does not use FakeMusicPlayer for stealth mode
    File: lib/features/session/widgets/fake_music_player.dart
    Fix: When StealthConfig.isEnabled, replace the session screen UI with FakeMusicPlayer. The widget exists but is never instantiated.

[ ] GAP-60: [MISSING] SessionScreen does not show simulation speed controls or description log
    File: lib/features/session/session_screen.dart
    Fix: When isSimulation, show a speed slider (calling setSimulationSpeed), a "Skip to Next" button (calling leapToNextEvent), and the firedStepDescriptions list.

[ ] GAP-61: [MISSING] SessionScreen does not show countdown warning UI
    File: lib/features/session/session_screen.dart:160-213
    Fix: When currentStepType == countdownWarning, show a visual countdown timer with the configured style (fullScreen/notification/minimal).

[ ] GAP-62: [MISSING] SessionScreen does not show loud alarm visual indicators
    File: lib/features/session/session_screen.dart
    Fix: When currentStepType == loudAlarm, show flashing screen effect and alarm status.

[ ] GAP-63: [MISSING] SessionScreen pause/resume has no UI button
    File: lib/features/session/session_screen.dart
    Fix: Add a pause button to _TopBar. Currently only available programmatically (incoming call auto-pause).
```

---

## Q. FOREGROUND SERVICE / BACKGROUND EXECUTION

```
[ ] GAP-64: [MISSING] flutter_background_service is a dependency but never initialized or used
    File: pubspec.yaml:64-65
    Fix: Configure and start the foreground service at session start so the app survives background. Without this, Android kills the app after ~1 minute in background, making the entire safety mechanism unreliable.

[ ] GAP-65: [MISSING] No incoming call auto-pause functionality
    File: lib/services/fakes/fake_incoming_call_service.dart
    Fix: Create a real IncomingCallService implementation (Android TelephonyCallback, iOS CXCallObserver) and wire it to SessionController to auto-pause on incoming calls.
```

---

## R. AUDIO ASSETS

```
[ ] GAP-66: [MISSING] Audio assets incomplete -- code references alarm_siren.mp3 but only alarm.mp3 exists
    File: lib/services/implementations/audio_service.dart:48
    Fix: Rename assets/audio/alarm.mp3 to alarm_siren.mp3, or add multiple alarm sound files (alarm_siren.mp3, alarm_whistle.mp3, alarm_scream.mp3). Code constructs path as 'assets/audio/alarm_$soundChoice.mp3'.

[ ] GAP-67: [MISSING] No ringtone.mp3 asset -- code references ringtone.mp3 but file is ringtone.wav
    File: lib/services/implementations/audio_service.dart:24
    Fix: Either rename ringtone.wav to ringtone.mp3, or change the default assetPath to 'assets/audio/ringtone.wav'.
```

---

## S. LOCALIZATION -- UI NOT LOCALIZED

```
[ ] GAP-68: [MISSING] All UI strings are hardcoded in English, not using AppLocalizations
    File: (all screen files in lib/features/)
    Fix: Replace all hardcoded strings with AppLocalizations.of(context).keyName calls. The ARB files and generated localization classes exist but are never used by any widget.
```

---

## T. MISSING TESTS

```
[ ] GAP-69: [MISSING] No test for DuressChainController
    File: test/features/settings/ (missing)
    Fix: Add duress_chain_controller_test.dart testing setEnabled, updateChainSteps, and persistence.

[ ] GAP-70: [MISSING] No test for BatteryAlertController
    File: test/features/settings/ (missing)
    Fix: Add battery_alert_controller_test.dart testing setEnabled, setThreshold, updateChainSteps.

[ ] GAP-71: [MISSING] No test for WrongPinChainController
    File: test/features/settings/ (missing)
    Fix: Add wrong_pin_chain_controller_test.dart.

[ ] GAP-72: [MISSING] No test for TemplatesController
    File: test/features/templates/ (missing)
    Fix: Add templates_controller_test.dart testing save, delete, seed data init.

[ ] GAP-73: [MISSING] No widget tests for any screen
    File: test/ (missing)
    Fix: Add widget tests for at least: HomeScreen, SessionScreen, ContactsScreen, SettingsScreen, OnboardingScreen, FakeCallScreen.

[ ] GAP-74: [MISSING] No test for PinEntryDialog / PinUtils integration
    File: test/core/widgets/ (missing)
    Fix: Add pin_entry_dialog_test.dart testing correct PIN, wrong PIN, timeout, duress detection, wrongPinThreshold.

[ ] GAP-75: [MISSING] No test for StealthConfig
    File: test/core/utils/ (missing)
    Fix: Add stealth_config_test.dart testing StealthConfig.fromSettings().

[ ] GAP-76: [MISSING] No test for QuickExit
    File: test/core/utils/ (missing)
    Fix: Add quick_exit_test.dart (at least test that execute() calls the platform channel on Android).

[ ] GAP-77: [MISSING] No test for individual event strategies (sms, phone call, loud alarm, call emergency)
    File: test/domain/orchestration/strategies/ (missing)
    Fix: Add per-strategy unit tests using fake services. EventStrategyRegistry and SessionOrchestrator tests exist but individual strategy executeReal() logic is untested.

[ ] GAP-78: [MISSING] No test for WalkSession.copyWith
    File: test/features/session/ (missing)
    Fix: Add walk_session_test.dart testing copyWith immutability and field updates.

[ ] GAP-79: [MISSING] No tests for real service implementations
    File: test/services/ (missing)
    Fix: At minimum, add tests for MessagingService URL construction, LocationService history management, and BatteryMonitorService threshold logic.
```

---

## U. DATA INTEGRITY

```
[ ] GAP-80: [MISSING] No schema migration logic -- only nuclear "nuke and re-seed"
    File: lib/data/hive_boxes.dart
    Fix: The CLAUDE.md says "on schema mismatch, all boxes are nuked and re-seeded" but no code actually checks schemaVersion or performs the nuke. If schemaVersion changes, stale data silently persists.

[ ] GAP-81: [MISSING] ListRepository<T> and SingletonRepository<T> are unused dead code
    File: lib/data/repositories/list_repository.dart, singleton_repository.dart
    Fix: These generic (non-JSON) repos require Hive TypeAdapters which were never implemented. Delete them or document why they exist.
```

---

## V. CONTACT EDIT ROUTING

```
[ ] GAP-82: [WIRING] ContactFormScreen does not read the ?id= query parameter for editing
    File: lib/router/app_router.dart:51-52 and lib/features/contacts/contact_form_screen.dart
    Fix: Pass state.uri.queryParameters['id'] to ContactFormScreen and implement edit mode.
```

---

## W. HOME SCREEN

```
[ ] GAP-83: [BUG] HomeScreen validation hardcodes all permissions to true
    File: lib/features/home/home_screen.dart:127-130
    Fix: Actually check permissions via permission_handler before starting a session. The comment says "Assume for now" but this bypasses all permission validation.

[ ] GAP-84: [MISSING] HomeScreen has no Safety Setup checklist / onboarding banner
    File: lib/features/home/home_screen.dart
    Fix: Per CLAUDE.md spec, show a "Safety Setup checklist card" (Slack-style collapsible banner with progress bar) for PIN setup, duress PIN, mode customization, additional contacts, etc.

[ ] GAP-85: [MISSING] HomeScreen has no history / past events quick access
    File: lib/features/home/home_screen.dart
    Fix: Add a "Recent Sessions" section or link to past events screen.
```

---

## X. MISCELLANEOUS

```
[ ] GAP-86: [MISSING] GuardianAngelaLogo widget referenced in CLAUDE.md does not exist
    File: lib/core/theme/guardian_angela_logo.dart (missing)
    Fix: Create the logo widget as specified (Pride-flag gradient angel with feathered wings, shield body, halo).

[ ] GAP-87: [MISSING] No PinKeypad shared widget -- CLAUDE.md references lib/core/widgets/pin_keypad.dart but only pin_entry_dialog.dart exists
    File: lib/core/widgets/pin_keypad.dart (missing)
    Fix: Extract the keypad from _PinDialog into a reusable PinKeypad widget for use in both PinEntryScreen and PinSetupScreen.

[ ] GAP-88: [MISSING] No PinEntryScreen or PinSetupScreen -- only PinEntryDialog exists
    File: lib/core/widgets/ (missing)
    Fix: Create full-screen PIN entry and PIN setup screens for app-lock and session-end PIN flows.

[ ] GAP-89: [MISSING] alarmOverrideSilentMode setting is read but never applied
    File: lib/domain/models/app_settings.dart:69
    Fix: Pass the flag to AudioService and use Android's AudioManager to set STREAM_ALARM or request DND override when playing alarms.

[ ] GAP-90: [MISSING] CountdownWarningStrategy only vibrates -- no countdown sound
    File: lib/domain/orchestration/strategies/countdown_warning_strategy.dart:16-18
    Fix: If CountdownWarningConfig.sound is true, play a countdown sound asset via AudioService.

[ ] GAP-91: [MISSING] DisguisedReminderStrategy is a complete no-op -- does not show notification
    File: lib/domain/orchestration/strategies/disguised_reminder_strategy.dart:9-13
    Fix: Call notificationService.showDisguisedReminder() with template data. The comment says "UI shows reminder overlay on ChainEvent.reminderFired" but neither the strategy nor the UI does anything.

[ ] GAP-92: [MISSING] SmsContactConfig.autoRecordAudio feature not implemented
    File: lib/domain/models/step_config.dart:138
    Fix: If autoRecordAudio is true, call audioService.startRecording() when the SMS step executes.

[ ] GAP-93: [MISSING] No LogarithmicSlider widget referenced in CLAUDE.md
    File: lib/core/widgets/ (missing)
    Fix: Create a LogarithmicSlider widget if needed for simulation speed control, or remove the reference.

[ ] GAP-94: [MISSING] SeedData generates new UUIDs on every call -- built-in mode IDs are unstable
    File: lib/data/seed_data.dart:22-66
    Fix: Chain step IDs within built-in modes use _uuid.v4() (random each time). This means the "same" built-in mode has different step IDs on every app start. Use deterministic IDs for built-in steps.

[ ] GAP-95: [MISSING] No permission_handler usage anywhere -- package is a dependency but never imported
    File: pubspec.yaml:31
    Fix: Use permission_handler in onboarding and pre-session validation to request and check notification, location, phone, and SMS permissions.

[ ] GAP-96: [MISSING] SessionMode.reminderTemplateIds field from CLAUDE.md spec not implemented
    File: lib/domain/models/session_mode.dart
    Fix: Add reminderTemplateIds field to SessionMode for per-mode template filtering, as described in the CLAUDE.md architecture docs.

[ ] GAP-97: [MISSING] No shared_preferences usage -- package is a dependency but never imported
    File: pubspec.yaml:71
    Fix: Either use shared_preferences for lightweight settings (isFirstLaunch could be simpler here), or remove the unused dependency.

[ ] GAP-98: [MISSING] clock package is a dependency but never used
    File: pubspec.yaml:75
    Fix: Use Clock from the clock package for testable time in SessionEngine instead of DateTime.now(), or remove the dependency.

[ ] GAP-99: [MISSING] image_picker and file_picker are dependencies but never used in the app
    File: pubspec.yaml:48, 54
    Fix: Wire image_picker for fake call caller photo selection and file_picker for custom alarm sound selection, or remove unused dependencies.

[ ] GAP-100: [MISSING] flutter_background_service_android dependency unused
    File: pubspec.yaml:65
    Fix: Wire into foreground service implementation (see GAP-64).

[ ] GAP-101: [MISSING] share_plus dependency unused
    File: pubspec.yaml:72
    Fix: Wire into evidence export (see GAP-33) and backup export (see GAP-34).

[ ] GAP-102: [MISSING] path_provider dependency unused
    File: pubspec.yaml:57
    Fix: Use for generating file paths for audio recordings, backup files, and evidence exports.

[ ] GAP-103: [MISSING] Recording path hardcoded to /tmp/ which does not exist on mobile
    File: lib/services/implementations/audio_service.dart:99
    Fix: Use path_provider to get the app documents directory for recording output.

[ ] GAP-104: [MISSING] BootReceiver.kt registered but likely incomplete
    File: android/app/src/main/kotlin/com/guardianangela/app/BootReceiver.kt
    Fix: Verify BootReceiver implementation restarts the foreground service after device reboot (critical for sessions that survive reboots).
```
