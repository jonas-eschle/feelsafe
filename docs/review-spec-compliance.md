# Spec Compliance Review

Review date: 2026-03-31
Compared: `docs/spec/00-overview.md` through `08-decisions-consolidated.md`, `docs/decisions-log.md`, `docs/issues-v4.md` against the current implementation.

---

## Section A: Spec Deviations (code doesn't match spec)

### A1. ChainStep model: `waitSeconds` renamed to `repeatIntervalSeconds`

**Spec** (`03-data-models.md`): ChainStep has field `waitSeconds` (HiveField 3) — "time BEFORE event fires (0 for most types)".

**Code** (`lib/data/models/chain_step.dart`): Field is named `repeatIntervalSeconds` (HiveField 5), and `gracePeriodSeconds` occupies HiveField 3. The HiveField indices do not match the spec at all:
- Spec: `waitSeconds` = HiveField(3), `durationSeconds` = HiveField(4), `gracePeriodSeconds` = HiveField(5), `repeatCount` = HiveField(6), `randomize` = HiveField(7), `config` = HiveField(8)
- Code: `gracePeriodSeconds` = HiveField(3), `repeatCount` = HiveField(4), `repeatIntervalSeconds` = HiveField(5), `config` = HiveField(6), `durationSeconds` = HiveField(7), `randomize` = HiveField(8)

**Impact**: The field indices are an internal Hive concern and don't affect behavior, but the semantic difference matters: the spec's `waitSeconds` is a general-purpose "time before event fires" field for ALL step types. The implementation's `repeatIntervalSeconds` is only used by disguisedReminder. For generic steps (fakeCall, loudAlarm, etc.), the engine's `_effectiveWait()` reads `repeatIntervalSeconds`, which is always 0 for non-reminder types — so the behavior is equivalent. However, this means you cannot configure a wait time before a non-reminder step fires, which the spec implies should be possible ("Wait time (optional)" in the timing diagram, spec 01 line 25-28).

**Severity**: Medium. Breaks the spec's three-phase timing model for non-reminder steps. A fakeCall or loudAlarm cannot have a `waitSeconds > 0` delay before firing.

### A2. Fake call decline: miss counting contradiction

**Spec** (`01-chain-engine.md` lines 213-225): "Declining a fake call is NOT a disarm... This counts as a miss toward repeatCount."

**Decisions** (`08-decisions-consolidated.md` line 8): "`declineIsSafe = false` (default): Decline is NOT safe. Grace period -> call rings again. Does NOT count as a miss."

**Decisions log** (`decisions-log.md` line 7): "Decline -> grace period -> call rings again. Decline counts as a miss toward retryCount."

**Code** (`session_engine.dart` `restartCurrentStep()`): Uses `preserveMissCount: true`, meaning the miss counter is NOT incremented on decline. The decline itself doesn't count as a miss — only a timeout (grace expiry without action) does.

**Impact**: Three spec documents give contradictory answers. The code follows the `08-decisions-consolidated.md` version (decline does NOT count as a miss). The `decisions-log.md` and `01-chain-engine.md` say the opposite.

**Severity**: Medium. The contradictory specs need resolution. The code's behavior (decline != miss) is arguably more user-friendly.

### A3. Simulation default speed: spec says 1x, home screen starts at 1x (matches)

**Spec** (`08-decisions-consolidated.md`): "Default speed: 1x (real-time)"

**Code** (`session_controller.dart:103`): `speedMultiplier: 1.0` — Matches.

**BUT**: Spec `00-overview.md` line 47 says "Test the entire chain at 5x speed with no real actions." This implies simulation always runs at 5x, contradicting the decisions doc.

**Severity**: Low. The decisions doc (08) is authoritative per its own header, and the code follows it.

### A4. Hold button: `durationSeconds` vs `gracePeriodSeconds` semantics

**Spec** (`01-chain-engine.md` line 165): "For holdButton, `durationSeconds` = the visible countdown, `gracePeriodSeconds` = dead time after countdown before escalating."

**Spec** (`03-data-models.md` default table): holdButton defaults: `durationSeconds=10`, `gracePeriodSeconds=5`.

**Decisions** (`08-decisions-consolidated.md`): "Hold button grace period default: 0 (escalate immediately after countdown — no dead time)"

**Code** (`chain_step.dart` comment at line 72-76): "For holdButton this is the visible countdown (what the spec calls 'durationSeconds' conceptually, but we store it here because the model was originally simplified)."

**Code** (`seed_data.dart`): holdButton has `durationSeconds: 10`, `gracePeriodSeconds: 0`.

**Code** (`session_engine.dart`): The engine's `_startHoldDurationPhase()` uses `_effectiveDuration(step)` for the countdown, then `_startHoldGracePhase()` uses `_effectiveGrace(step)` for dead time. So `durationSeconds=10` IS the visible countdown and `gracePeriodSeconds=0` IS the dead time.

**Impact**: The model comment says gracePeriodSeconds is "the visible countdown" which contradicts both the spec and the actual engine code. The engine code is correct — `durationSeconds` = countdown, `gracePeriodSeconds` = dead time. But the model's inline documentation is misleading.

**Severity**: Low (documentation-only issue, behavior is correct).

### A5. Reminder Templates not accessible from Settings screen

**Spec** (`04-screens-navigation.md` lines 257-260): Settings screen links to "Profile -> /profile", "Events -> /settings/event-defaults", "Modes -> /modes". Templates are accessible from the event defaults detail page for disguisedReminder type.

**Spec** (`04-screens-navigation.md` navigation map): Settings -> TEMPLATES (Reminder Templates).

**Code** (`settings_screen.dart`): No direct link to Reminder Templates. Templates are only reachable from the Event Defaults detail screen for disguisedReminder (via a "Reminder Templates" list tile).

**Impact**: The navigation map shows Templates as a direct child of Settings, but the actual settings screen doesn't have a link. Users must navigate Settings -> Events -> Disguised Reminder -> Reminder Templates.

**Severity**: Low. Templates are accessible, just not from the top-level Settings screen as the nav map suggests.

### A6. Settings autosave + undo snackbar: partially implemented

**Spec** (`08-decisions-consolidated.md`): "Autosave everything + undo snackbar after each change. No save buttons anywhere."

**Code**: Event defaults detail screen (`event_default_detail_screen.dart`) implements autosave with undo snackbar. BUT the Settings screen itself (theme, language, stealth toggles) auto-saves without undo snackbar. The mode editor also autosaves without undo.

**Severity**: Low. The most complex config screen (event defaults) has undo. Simple toggles (theme, language) don't need undo.

### A7. SessionLogEvent missing location fields

**Spec** (`08-decisions-consolidated.md` lines 73-76): "Location Logging: Configurable toggle in settings: 'Log GPS with events' (default: off). When on: each SessionLogEvent gets lat/lng coordinates. Requires SessionLogEvent model update + Hive schema v4."

**Code** (`session_log_event.dart`): No lat/lng fields. Schema is still v3.

**Impact**: Location logging per event is not implemented. The spec explicitly calls this out as requiring a schema v4 migration.

**Severity**: Medium. This is a documented future feature that hasn't been implemented yet.

---

## Section B: Undocumented Behaviors (code does something spec doesn't mention)

### B1. Black screen mode

**Code** (`session_mode.dart`): `blackScreenMode` field (HiveField 5) on SessionMode. When enabled, the session screen shows a black overlay mimicking a locked phone, with wakelock keeping the screen on.

**Spec** (`08-decisions-consolidated.md`): Mentions "Black screen mode: Configurable per mode" under Hold Button section. Also mentioned under Hardware Button: "When hardware button mode is active, app can show black screen mimicking locked phone."

**Assessment**: Partially documented in decisions doc but not in the main spec files (01-07). The implementation adds it as a per-mode toggle rather than a per-step-type feature.

### B2. FlashService and ScreenFlashOverlay

**Code**: `FlashService` for camera SOS flash pattern, `ScreenFlashOverlay` widget for alternating white/red screen flash during loud alarm.

**Spec** (`02-event-types.md`): Mentions `flashLight` and `flashScreen` config for loudAlarm. The implementation exists but `decisions-log.md` lists "Camera flash SOS pattern during alarm" and "Screen flash during alarm" as "Features Confirmed but NOT Implemented."

**Assessment**: These features ARE implemented despite the decisions log saying they aren't. The decisions log is stale.

### B3. RecordingService for audio recording during SMS step

**Code**: `RecordingService` is used by `SmsContactStrategy` to auto-record audio when `autoRecordAudio=true`. Video recording logs a "not yet implemented" message.

**Spec**: Audio recording is specified. Video recording is mentioned but not implemented.

### B4. BackgroundService integration

**Code** (`session_controller.dart`): Integrates with `backgroundServiceProvider` for foreground service notifications, including "I'm Safe" button handling and stealth mode notification text.

**Spec** (`05-services.md`): Specifies ForegroundService. The implementation uses `flutter_background_service` as noted in decisions doc.

### B5. PhoneService.callViaChannel routing

**Code** (`phone_call_contact_strategy.dart`): `phone.callViaChannel(number, channel)` routes calls through phone/whatsapp/telegram.

**Spec**: Mentions `callChannel` config but doesn't specify a `callViaChannel` method on PhoneService.

### B6. HardwareButtonService full implementation

**Code**: Complete hardware button detection service with platform channel support, configurable button type, press patterns, and panic event stream.

**Spec**: Specifies the feature. Implementation exists and matches.

---

## Section C: Missing Implementations (spec says X, code doesn't do X)

### C1. `waitSeconds` field for generic steps

**Spec** (`01-chain-engine.md`): Every step has three timing phases: wait -> duration -> grace. "Wait time (`waitSeconds`): Time before the event fires."

**Code**: Only `repeatIntervalSeconds` exists, which is only meaningful for disguisedReminder. Other step types (fakeCall, smsContact, etc.) cannot have a configurable wait delay before firing.

**Status**: Missing. The spec's general `waitSeconds` is not available for non-reminder steps.

### C2. Location logging per SessionLogEvent

**Spec** (`08-decisions-consolidated.md`): "Configurable toggle in settings: 'Log GPS with events'. Each SessionLogEvent gets lat/lng coordinates."

**Code**: SessionLogEvent has no location fields. No settings toggle for GPS logging.

**Status**: Not implemented. Requires schema v4 migration.

### C3. Voice recording configuration for fake calls

**Spec** (`08-decisions-consolidated.md`): "User can record in-app OR pick from files. Plays through earpiece (default) or speaker (configurable)."

**Code**: `voiceRecordingPath` config exists and voice recording playback works via `AudioService.playVoiceRecording()`. However, there is no in-app recording UI or earpiece/speaker toggle.

**Status**: Partially implemented. Playback works but recording UI and speaker choice are missing.

### C4. Video recording during SMS step

**Spec** (`02-event-types.md`): `autoRecordVideo` config for smsContact.

**Code** (`sms_contact_strategy.dart:60-64`): Logs "not yet implemented — requires camera service".

**Status**: Not implemented. Audio recording works; video does not.

### C5. Emergency confirmation dialog UI

**Spec** (`02-event-types.md`): "If showConfirmation=true, grace = confirmation countdown. User can cancel during this time."

**Code** (`call_emergency_strategy.dart`): Uses `Future.delayed(Duration(seconds: step.durationSeconds))` with an `isCancelled` callback check. This provides the delay but there is no visible confirmation dialog UI — the session screen shows the generic status body with "I'm Safe" button, which triggers `checkIn()` (full disarm). The spec implies a specific confirmation dialog with a countdown.

**Status**: Functionally works (user can disarm during the delay), but no dedicated confirmation dialog UI.

### C6. Foreground service notification "I'm Safe" button (platform implementation)

**Spec** (`01-chain-engine.md`): Persistent notification with "I'm Safe" / "Pause" action button.

**Code**: `BackgroundService` is integrated and `onImSafe` stream is listened to. The actual platform notification implementation depends on `flutter_background_service` configuration which wasn't fully reviewed, but the Dart-side wiring is complete.

**Status**: Dart-side complete. Platform-side implementation not verified.

### C7. Lock button removed from hardware button options

**Spec** (`08-decisions-consolidated.md`): "Lock button: Removed from options (not detectable on any platform)"

**Code** (`event_defaults.dart`): Default `buttonType` is `volumeUp`. The enum in `HardwareButtonService` only has `volumeUp` and `volumeDown`.

**BUT** (`chain_step.dart` ChainStepType enum, `event_defaults.dart`): The hardware button config key `buttonType` accepts string values, and the event defaults screen may still show `lockButton` as an option.

**Status**: Need to verify the UI doesn't offer `lockButton` as a choice. The service correctly only supports volume buttons.

### C8. Preview button per step in mode editor

**Spec** (`issues-v4.md` items 10, 13): "Each step in the chain editor gets a 'Preview' button that shows the event with simulation styling."

**Code** (`escalation_step_list.dart`): Preview buttons are implemented for all 9 step types. Hold button and fake call show the actual UI (issues 13, 14). Loud alarm plays actual audio for 3s.

**Status**: IMPLEMENTED. Matches spec.

### C9. Minimum reminder interval = 10s

**Spec** (`issues-v4.md` item 5): "Change LogarithmicSlider min for disguisedReminder wait from 60 to 10."

**Code** (`escalation_step_list.dart:1073`): `LogarithmicSlider(min: 10, max: 86400, ...)`.

**Status**: IMPLEMENTED. Matches spec.

---

## Section D: Questions for the User (ambiguous areas)

### D1. Fake call decline: should it count as a miss?

Three documents give different answers:
- `01-chain-engine.md`: "This counts as a miss toward repeatCount" (YES)
- `08-decisions-consolidated.md`: "Does NOT count as a miss" (NO)
- `decisions-log.md`: "Decline counts as a miss toward retryCount" (YES)

The code follows 08's "does NOT count" behavior. Which is authoritative?

### D2. `waitSeconds` generalization

Should the `repeatIntervalSeconds` field be renamed/generalized to `waitSeconds` so that ANY step type can have a configurable delay before firing? This would match the spec's three-phase model exactly. Currently, only disguisedReminder uses the wait phase.

### D3. Simulation speed: 1x or 5x default?

`00-overview.md` says "5x speed" for simulation. `08-decisions-consolidated.md` says "Default speed: 1x". Code uses 1x. Should 00-overview.md be updated to reflect the decision?

### D4. Settings screen: should Reminder Templates be a top-level link?

The navigation map in `04-screens-navigation.md` shows Templates as a direct child of Settings, but the current implementation only makes it reachable through Event Defaults -> Disguised Reminder -> Reminder Templates. Which is intended?

### D5. Schema version for location logging

`08-decisions-consolidated.md` says location logging "Requires SessionLogEvent model update + Hive schema v4." Is this planned for the current development phase, or is it deferred to a later phase?

### D6. `repeatCount` semantics: retries vs total attempts

**Spec** (`01-chain-engine.md`): "`repeatCount`: how many times the step can repeat before advancing (0 = no repeat)"

**Decisions** (`08-decisions-consolidated.md`): "`repeatCount` = number of retries. N retries = N+1 total attempts before advancing."

**Code** (`session_engine.dart:267`): `if (_missedRepeats > step.repeatCount)` — meaning with repeatCount=3, you need 4 misses to advance (3 repeats + 1 original = 4 total attempts). This matches the decisions doc.

**BUT** the disguised reminder's cycle comment in `01-chain-engine.md` lines 172-188 shows 3 cycles with "3 misses before advancing" and `repeatCount: 3`. If repeatCount=3 means 3 retries (4 total), then 3 misses would NOT trigger advancement — you'd need 4 misses. This contradicts the example.

The code uses `>` (strictly greater than), so `repeatCount=3` advances after 4 misses. Is this the intended behavior, or should `repeatCount=3` mean "advance after 3 misses" (using `>=`)?

---

## Summary

| Category | Count | Critical | Medium | Low |
|----------|-------|----------|--------|-----|
| A: Spec deviations | 7 | 0 | 3 | 4 |
| B: Undocumented behaviors | 6 | 0 | 0 | 6 |
| C: Missing implementations | 7 (+ 2 verified OK) | 0 | 2 | 5 |
| D: Questions | 6 | - | - | - |

C8 and C9 were verified as implemented correctly.

**Most impactful issues:**
1. **A1/C1**: `waitSeconds` not available for non-reminder steps — breaks the spec's universal 3-phase timing model
2. **A2/D1**: Fake call decline miss counting — contradictory specs
3. **C2/D5**: Location logging per event not implemented (schema v4)
4. **D6**: `repeatCount` semantics ambiguity (retries vs total misses)
