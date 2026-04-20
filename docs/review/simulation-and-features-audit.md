# Simulation Mode & Feature Completeness Audit

**Date**: 2026-04-11
**Spec**: `docs/spec/12-rewrite-decisions.md` (normative)
**Scope**: Every simulation requirement + full feature scan


## 1. SIMULATION MODE

### 1.1 Defense-in-Depth (4 layers)

**Layer 1 - Engine flag `isSimulation` is final**: IMPLEMENTED
- `lib/domain/engine/session_engine.dart` line 29: `_isSimulation` is a private
  final field. Cannot be changed after construction.
- Speed multiplier guard at line 422: rejects >1.0 when `!_isSimulation`.

**Layer 2 - Strategy guard (executeReal checks isSimulation)**: PARTIALLY IMPLEMENTED
- `lib/domain/orchestration/session_orchestrator.dart` line 92: the orchestrator
  checks `isSimulation` and calls `simulationDescription` instead of
  `executeReal`. This means `executeReal` is never called in simulation mode.
- However, the spec says "Every `executeReal()` checks `isSimulation` first."
  Individual strategies do NOT check `isSimulation` themselves -- they rely
  entirely on the orchestrator gate. If anyone ever calls `executeReal`
  directly, no guard exists. This is a single-point-of-failure design flaw.
  **GAP: strategies should have their own isSimulation guard as defense-in-depth.**

**Layer 3 - Service parameter (isSimulation no-ops)**: IMPLEMENTED
- `MessagingService.sendMessage()` line 36: `if (isSimulation) return`.
- `MessagingService.sendFalseAlarm()` line 97: `if (isSimulation) return`.
- `PhoneService.callEmergency()` line 18: `if (isSimulation) return`.
- `PhoneService.call()` line 33: `if (isSimulation) return`.
- `AudioService.playRingtone()` line 23: `if (isSimulation) return`.
- `AudioService.playAlarm()` line 42: `if (isSimulation) return`.
- `AudioService.playVoiceRecording()` line 73: `if (isSimulation) return`.
- `AudioService.startRecording()` line 97: `if (isSimulation) return '/dev/null'`.

**Layer 4 - Separate subclasses**: IMPLEMENTED
- `SimulationMessagingService` in `lib/services/fakes/fake_messaging_service.dart`
  line 75: overrides `sendMessage` and `sendFalseAlarm` to log `SIM_BLOCKED`.
- `SimulationPhoneService` in `lib/services/fakes/fake_phone_service.dart`
  line 27: overrides `callEmergency` and `call` to log `SIM_BLOCKED`.

**CRITICAL GAP**: These subclasses exist but are NEVER injected during simulation
sessions. The `SessionController.startSession()` at
`lib/features/session/session_controller.dart` line 69-75 always reads from the
standard Riverpod providers (`messagingServiceProvider`, `phoneServiceProvider`),
which provide `MessagingService` and `PhoneService` (the REAL implementations).
The `SimulationMessagingService` and `SimulationPhoneService` are never
instantiated outside of test code. Layer 4 is dead code in production.


### 1.2 Speed Controls

**Engine support**: IMPLEMENTED
- `setSpeedMultiplier()` at session_engine.dart line 421-436 works correctly.
- Range clamped to [0.01, 1000.0], rejects NaN/Infinity/negative.
- Real sessions reject >1.0.

**Controller wiring**: IMPLEMENTED
- `SessionController.setSimulationSpeed()` at session_controller.dart line 321.

**UI controls**: MISSING
- The session screen (`lib/features/session/session_screen.dart`) has NO speed
  control UI. No slider, no preset buttons (1x, 2x, 5x, 10x), no logarithmic
  slider. The spec requires "Logarithmic slider + preset buttons."
- The `LogarithmicSlider` widget has been DELETED (git status shows
  `deleted: lib/core/widgets/logarithmic_slider.dart`).
- There is no simulation control strip anywhere in the session screen.

**Status: Engine ready, UI entirely missing.**


### 1.3 Simulation Summary Screen

**Route**: IMPLEMENTED (`/session/simulation-summary`)
**Screen**: IMPLEMENTED at `lib/features/session/simulation_summary_screen.dart`
- Shows mode name, event count, event timeline via ListView.
- Reads `lastSessionLog` from controller.

**GAP**: The screen is never navigated to. The session screen at line 36-44
navigates to `RouteNames.sessionCompleted` when a session log exists, regardless
of whether it was a simulation. There is no routing logic that redirects
simulation sessions to the simulation summary screen instead.


### 1.4 Leap-to-Next-Event Button

**Engine**: IMPLEMENTED at session_engine.dart line 414-418.
**Controller**: IMPLEMENTED at session_controller.dart line 326.
**UI**: MISSING. No button in the session screen calls `leapToNextEvent()`.


### 1.5 Simulation Loading Screen

**Route**: IMPLEMENTED (`/session/simulation-loading`)
**Screen**: STUB at app_router.dart line 153-154. It is a bare
`Scaffold(body: Center(child: CircularProgressIndicator()))` with no
simulation-specific content, no mode preview, no "starting simulation" text.
**Navigation**: MISSING. Nothing ever navigates to this route.


### 1.6 Toast/Log of What WOULD Happen

**Mechanism**: IMPLEMENTED in orchestrator. `onSimulationDescription` callback
fires and updates `WalkSession.lastSimulationDescription` and
`WalkSession.firedStepDescriptions`.

**UI display**: MISSING. The session screen never reads
`session.lastSimulationDescription` or `session.firedStepDescriptions`. No
toast, no snackbar, no log panel is shown. The data is computed but never
rendered.


### 1.7 isSimulation Threading to Services

The `isSimulation` flag IS threaded through `SessionContext` to strategies.
Strategies like `SmsContactStrategy` pass `context.isSimulation` to
`messaging.sendToAll()`. This works correctly.

**GAP**: The fake call screen (`lib/features/fake_call/fake_call_screen.dart`)
receives `isSimulation` as a constructor parameter (line 18), but the router at
app_router.dart line 71 always constructs `const FakeCallScreen()` without
passing `isSimulation: true`. The simulation badge on the fake call screen is
therefore never shown via normal routing.


### 1.8 SIM Indicators

**Orange banner**: IMPLEMENTED in session_screen.dart line 81-95. Shows
"SIMULATION -- No real actions" with orange background when `session.isSimulation`.

**Stealth simulation watermark**: MISSING. Spec says "SIM watermark (not orange
border). Tests stealth appearance." No stealth-aware simulation indicator exists.

**Foreground notification [SIM] prefix**: IMPLEMENTED in notification_service.dart
line 39: `'SIMULATION -- $title'`.

**Disguised reminder [SIM] suffix**: IMPLEMENTED in notification_service.dart
line 74: `'$title -- SIM'`.


### 1.9 Simulation Trigger Buttons

**Spec**: "Behind 'Advanced' toggle: Trigger Arrival, Trigger Low Battery,
Trigger Hardware Panic."

**Status**: MISSING. No simulation trigger buttons exist anywhere in the session
screen or any other UI. The controller methods exist (`hardwarePanic()`,
`triggerDuress()`) but no UI exposes them during simulation.


### 1.10 Simulation Validation (Lenient)

**Status**: IMPLEMENTED. `SessionValidator.validate()` at
`lib/domain/validation/session_validator.dart` line 97 and 140 treats missing
contacts and permissions as warnings (not errors) when `isSimulation: true`.

**GAP**: The home screen at line 137 hardcodes all permission checks to `true`:
`hasLocationPermission: true, hasSmsPermission: true, hasPhonePermission: true,
hasNotificationPermission: true`. Real permission state is never queried.


### 1.11 Simulation-Specific Spec Items Not Found

- **Background simulation**: No foreground service integration for simulation
  mode. No `[SIM]` prefix on foreground notification title. (Wait -- the
  notification service does add it, but there is no foreground service code at
  all in the Flutter layer.)
- **Speed control from notification action**: MISSING. Spec says "cycle
  1x->10x->60x->1x" from notification. Not implemented.
- **Background simulation speed cap 60x**: Not enforced. Engine allows up to
  1000x regardless of foreground/background state.
- **No auto-end timeout**: Correct (not implemented, which matches spec).
- **No "GO LIVE" button**: Correct (not implemented, which matches spec).


---

## 2. STEALTH MODE

### 2.1 StealthConfig Helper
IMPLEMENTED at `lib/core/utils/stealth_config.dart`. Resolves flags from
AppSettings into a config object.

### 2.2 Stealth Settings in AppSettings Model
IMPLEMENTED. Fields: `stealthMode`, `stealthHideProgressBar`,
`stealthHideMissedIndicators`, `stealthHideGraceVisuals`,
`stealthSuppressEndScreen`, `stealthDisguiseNotification`,
`stealthNotificationBody`, `stealthActionButtonLabel`,
`stealthTimerDisplay`, `stealthNotificationIcon`.

### 2.3 Stealth Toggle in Settings UI
IMPLEMENTED at settings_screen.dart line 54-60. Simple toggle, no sub-settings
for individual stealth features.

### 2.4 FakeMusicPlayer Widget
IMPLEMENTED at `lib/features/session/widgets/fake_music_player.dart`. Full
fake music player UI with disguised disarm slider.

### 2.5 Session Screen Integration
**MISSING**. `StealthConfig` is never imported or used in the session screen.
The `FakeMusicPlayer` is never rendered. When stealth mode is enabled, the
session screen shows the exact same UI as normal mode. The stealth timer
display options (`normal`/`small`/`none`) are never applied. The stealth
hide-progress-bar, hide-missed-indicators, hide-grace-visuals flags are
never checked.

### 2.6 Stealth Notification Disguise
**STUB**. The notification service uses generic channel names ("Media",
"Updates") which is good, but `stealthDisguiseNotification` and
`stealthNotificationBody` are never read by the notification service during
session notifications.

### 2.7 Stealth Sub-Settings UI
**MISSING**. The settings screen has a single toggle for stealth mode.
There is no UI to configure timer display, progress bar hiding, missed
indicator hiding, notification body text, slider label text, etc. All
sub-settings exist in the model but have no UI to modify them.


---

## 3. EVENT DEFAULTS EDITOR

### 3.1 List Screen
IMPLEMENTED at `lib/features/settings/event_defaults_screen.dart`. Shows a
list of all 9 step types with icons.

### 3.2 Detail Editor
**STUB**. The `onTap` handler at event_defaults_screen.dart line 20-21 is
empty (no navigation). The route `eventDefaultDetail` at app_router.dart
line 137-142 renders an inline `Scaffold(body: Center(child: Text('Default editor')))`.
No actual editing of step-type defaults is possible.

### 3.3 Wiring to Engine
**MISSING**. Even if defaults could be edited, the `EventDefaults` model
is never loaded from storage or applied to chain steps that lack per-step
config. Strategies fall back to hardcoded `const` defaults in each
`StepConfig` subclass.


---

## 4. TEMPLATE EDITOR

### 4.1 Template List Screen
IMPLEMENTED at `lib/features/templates/templates_screen.dart`. Shows
templates with name, title, confirmation type, delete button for custom.

### 4.2 Template Editor Screen
**STUB**. Route `templateEdit` at app_router.dart line 146-149 renders
`Scaffold(body: Center(child: Text('Template editor')))`. No form fields,
no save logic. Templates cannot be created or edited.

### 4.3 Template CRUD Controller
PARTIALLY IMPLEMENTED at `lib/features/templates/templates_controller.dart`.
Has `addTemplate`, `deleteTemplate`, `updateTemplate` methods. But no UI
invokes add/update -- only delete is wired (in the list screen).


---

## 5. EVIDENCE EXPORT

### 5.1 Screen
STUB at `lib/features/history/evidence_export_screen.dart`. Shows an icon,
description text, and a button that shows snackbar "Export not yet available".
No actual export logic (no ZIP creation, no encryption, no file sharing).

### 5.2 Session Log Data
The `SessionLog` model is fully implemented with events, GPS coordinates,
delivery status. The data layer is ready but export is not.


---

## 6. BACKUP / RESTORE

### 6.1 Screen
STUB at `lib/features/settings/backup_screen.dart`. Both Export and Import
buttons show snackbar "not yet implemented".

### 6.2 Session Lock
**MISSING**. Spec says "Backup import: BLOCKED during active session." No
such check exists.


---

## 7. FEEDBACK SCREEN

IMPLEMENTED (minimal) at `lib/features/settings/feedback_screen.dart`.
Shows a static GitHub link. No in-app form, no email integration. This is
adequate for an early release but basic.


---

## 8. PERMISSION REQUESTS (ONBOARDING)

### 8.1 Permission Page UI
IMPLEMENTED at `lib/features/onboarding/onboarding_screen.dart` line 191-208.
Shows 4 permission items (Notifications, Location, Phone, SMS) with "Grant"
buttons.

### 8.2 Actual Permission Requests
**MISSING**. The "Grant" button handler at line 202-203 is:
```dart
onPressed: () {
  // Permission requests wired in Slice 6.
},
```
This is a no-op. No permission_handler package usage, no platform permission
requests. The `PermissionService` file has been DELETED (git status:
`deleted: lib/core/permissions/permission_service.dart`).

### 8.3 Permission State Checking
**MISSING**. Home screen at line 137 hardcodes all permissions to `true`.
Actual permission state is never queried from the platform.


---

## 9. SESSION COMPLETION SCREEN

IMPLEMENTED at `lib/features/session/session_completed_screen.dart`. Shows:
- Mode name
- Duration
- Event count
- Simulation flag
- Full event timeline with timestamps

This is functional and shows real data from the session log.

**GAP**: Simulation sessions should route to `SimulationSummaryScreen` instead,
but both always go to `SessionCompletedScreen` (see section 1.3).


---

## 10. PAST EVENTS SCREEN

### 10.1 List Screen
**STUB** at `lib/features/history/past_events_screen.dart`. Shows static
"No past sessions yet" message with no data loading logic. Never reads from
`sessionLogsRepoProvider`.

### 10.2 Detail Screen
**STUB** at `lib/features/history/past_event_detail_screen.dart`. Shows
`Text('Session log: ${logId ?? "unknown"}')`. No data loading.

### 10.3 Session Log Persistence
**MISSING**. `SessionController` creates `SessionLogRecorder` and records
events, but `endSession()` at session_controller.dart line 332-337 calls
`_logRecorder?.close()` (sets endTime) then immediately nulls the engine.
**The log is never saved to the `sessionLogsRepoProvider` repository.**
`lastSessionLog` is accessible only as an in-memory reference until the
next session starts or the app restarts. Past events cannot accumulate.


---

## 11. FAKE CALL SCREEN

### 11.1 UI
IMPLEMENTED at `lib/features/fake_call/fake_call_screen.dart`. Shows caller
name, avatar placeholder, answer/decline/hangup buttons. Engine integration
is wired.

### 11.2 Ringtone Audio
**NOT WIRED IN UI**. The `AudioService` has `playRingtone()` but nothing
in the fake call screen or fake call strategy calls it. The
`FakeCallStrategy.executeReal()` is a no-op (line 12-14: "No-op: UI
navigates to fake call screen"). No code initiates ringtone playback when
the fake call screen appears.

### 11.3 Caller Photo
**MISSING**. Shows generic `Icon(Icons.person)`. No mechanism to configure
or display a caller photo.

### 11.4 Voice Recording Playback
**NOT WIRED**. `AudioService` has `playVoiceRecording()` but the fake call
screen never calls it after "answer". Spec says "voice plays" after answer.

### 11.5 Decline-with-Distress (3s hold)
**MISSING**. Spec: "Holding the Decline button for 3 seconds triggers the
mode's distress chain." The decline button is a simple `onPressed` callback
with no long-press or hold detection. No progress ring, no 800ms haptic.

### 11.6 Ring Timeout
**MISSING**. Spec: "ring -> timeout -> miss." No timeout mechanism exists
in the fake call screen to auto-advance if the user doesn't answer.


---

## 12. COUNTDOWN WARNING

### 12.1 Strategy
IMPLEMENTED at `lib/domain/orchestration/strategies/countdown_warning_strategy.dart`.
Fires `vibration.warningPattern()`.

### 12.2 Visual Overlay
**MISSING**. Spec calls this "countdown warning screen/overlay." The session
screen shows a generic text "Step N: countdownWarning" for this step type.
No countdown timer display, no warning overlay, no urgency indicators.


---

## 13. LOUD ALARM

### 13.1 Strategy
IMPLEMENTED at `lib/domain/orchestration/strategies/loud_alarm_strategy.dart`.
Calls audio, vibration, flashlight, screen flash.

### 13.2 Audio Playback
IMPLEMENTED. `AudioService.playAlarm()` uses just_audio with configurable
sound, volume ramp, looping.

### 13.3 DND Override
**PARTIALLY IMPLEMENTED**. `AppSettings.alarmOverrideSilentMode` exists and
is togglable. However, no code actually sets `STREAM_ALARM` or requests
DND override permission. The audio service uses default stream.


---

## 14. PROFILE / MEDICAL INFO

### 14.1 Data Model
IMPLEMENTED at `lib/domain/models/user_profile.dart`. All medical fields:
bloodType, allergies, medications, medicalConditions, emergencyMedicalNotes.

### 14.2 Profile Editor UI
**PARTIAL**. `lib/features/profile/profile_editor_screen.dart` only has
name and phone number fields. No fields for physical description, blood
type, allergies, medications, conditions, or medical notes.


---

## 15. LANGUAGE SELECTOR

### 15.1 14-Language Support
PARTIALLY IMPLEMENTED. ARB files exist for 14 locales (en, de, es, fr, ru,
zh, ar, el, fa, he, hi, pl, uk). Generated localizations exist.

### 15.2 Language Selector UI
**MISSING**. Settings screen has no language picker. `setLanguage()` method
exists on the controller but no UI calls it.

### 15.3 Session Lock on Language Change
**MISSING**. Spec: "Language change: BLOCKED during active session."


---

## 16. MODE EDITOR

### 16.1 Step Reorder, Add, Delete
IMPLEMENTED at `lib/features/modes/mode_editor_screen.dart`. Working
ReorderableListView with add/delete.

### 16.2 Step Config Editing
**MISSING**. Step type can be changed (dropdown), but wait/duration/grace/retry
values are displayed as read-only text (subtitle). No form to edit individual
step parameters or StepConfig properties (e.g., declineIsSafe, preSendSms).

### 16.3 Distress Chain Configuration
**MISSING**. SessionMode has `distressChainSteps` field but mode editor has
no UI to configure it.

### 16.4 Trigger Configuration
**MISSING**. SessionMode has `distressTriggers` and `disarmTriggers` but
mode editor has no UI for them.


---

## 17. QUICK EXIT

### 17.1 Implementation
IMPLEMENTED at `lib/core/utils/quick_exit.dart`. Android:
`finishAndRemoveTask()` via platform channel. iOS: decoy screen + exit(0).
PIN-gated via `executeWithPin()`.

### 17.2 UI Access
**MISSING**. No button or gesture anywhere in the app invokes Quick Exit.
The code exists but is unreachable from the UI.


---

## 18. MISCELLANEOUS GAPS

### 18.1 Session Locks
**MISSING**. Spec: "Contact deletion: BLOCKED during active session. Backup
import: BLOCKED. Language change: BLOCKED. Schema migration: BLOCKED."
None of these guards exist.

### 18.2 Emergency Call Confirmation
**MISSING**. Spec: "Disarm during countdown: show 'Are you sure? Call will
NOT be made' confirmation dialog." Not implemented.

### 18.3 Biometric Auth
**MISSING**. `AppSettings.biometricEnabled` field exists but no biometric
authentication code exists anywhere.

### 18.4 Session End PIN
**PARTIAL**. `AppSettings.sessionEndPinHash` exists and is checked in the
session screen. But there is no separate UI to set the session-end PIN
distinct from the app PIN. The PIN setup screen creates `appPinHash` or
`duressPinHash` but never `sessionEndPinHash`.

### 18.5 Home Screen Safety Setup Checklist
**MISSING**. Spec: "Slack-style collapsible banner with progress bar" for
guided setup. No such widget exists.

### 18.6 Foreground Service
**MISSING**. No Android foreground service implementation. The
AndroidManifest.xml changes are in progress (git modified) but no Kotlin
service class exists (the old MainActivity.kt is deleted).


---

## PRIORITIZED BUILD LIST

Ordered by user impact (safety-critical first):

### P0 -- Safety-Critical

1. **Wire SimulationMessagingService/SimulationPhoneService during simulation
   sessions** -- Layer 4 defense-in-depth is dead code. In production simulation,
   real SMS/phone services are used (protected only by `isSimulation` parameter
   checks, not structural separation).

2. **Permission requests in onboarding** -- Buttons are no-ops. Without
   permissions, real sessions will silently fail to send SMS, make calls, track
   location, or show notifications.

3. **Persist session logs** -- Session history is lost on session end. Critical
   for the evidence export feature and for users reviewing their safety history.

### P1 -- Core Simulation UX

4. **Simulation speed control UI** -- Engine supports it, controller supports it,
   but no slider or buttons in session screen. Users cannot speed up simulations.

5. **Simulation-to-summary routing** -- Simulation sessions go to the wrong
   completion screen.

6. **Toast/log display for simulation descriptions** -- Data is computed but
   never rendered. Users get no feedback on what WOULD happen.

7. **Leap-to-next-event button** -- Engine ready, no UI.

8. **Simulation trigger buttons** -- Trigger Arrival, Low Battery, Hardware
   Panic buttons missing from simulation UI.

### P2 -- Feature Completeness

9. **Fake call ringtone + voice playback** -- Fake call is silent. No ringtone
   plays, no voice recording plays after answer.

10. **Fake call decline-with-distress (3s hold)** -- Spec feature entirely
    missing.

11. **Countdown warning visual overlay** -- Just vibrates, no visual countdown.

12. **Stealth mode session UI integration** -- StealthConfig is never used.
    FakeMusicPlayer is never rendered. All stealth sub-settings are dead code.

13. **Profile editor medical fields** -- Data model ready, UI only has name and
    phone.

14. **Mode editor step config editing** -- Can change step type but not
    parameters.

15. **Language selector** -- 14 languages supported, no way to switch.

16. **Quick Exit button** -- Code complete, unreachable from UI.

17. **Event defaults detail editor** -- Stub screen.

18. **Template editor** -- Stub screen.

### P3 -- Polish

19. **Past events screen data loading** -- Stub (depends on P0 #3).

20. **Evidence export logic** -- Stub button, needs ZIP creation.

21. **Backup/restore logic** -- Stub buttons.

22. **DND override for alarm** -- Setting exists, not enforced in audio stream.

23. **Session locks** -- No guards on contact deletion, backup import, language
    change during active session.

24. **Home screen safety setup checklist** -- Guided setup banner missing.

25. **Stealth sub-settings UI** -- Single toggle, no individual feature config.

26. **Biometric authentication** -- Field exists, no implementation.

27. **Foreground service (Android)** -- No foreground service for session
    persistence across process death.
