# Engine & Chain Logic Audit

Audit date: 2026-03-31
Scope: `session_engine.dart`, `session_controller.dart`, all 9 event strategies, `chain_step.dart`, `seed_data.dart`, `event_defaults.dart` vs specs `01-chain-engine.md`, `02-event-types.md`, and `issues-v4.md`.

---

## A. Spec vs Implementation Mismatches

### A1. ChainStep model: `waitSeconds` field missing

**Spec** (`01-chain-engine.md` line 65): The `ChainStep` model specifies a `waitSeconds` field for "time before the event fires".

**Implementation** (`chain_step.dart`): There is no `waitSeconds` field. Instead, `repeatIntervalSeconds` is used as the wait time. The engine's `_effectiveWait()` reads `step.repeatIntervalSeconds`.

**Impact**: For non-disguisedReminder steps, the spec says most types have `waitSeconds = 0`. The implementation works because `repeatIntervalSeconds` defaults to 0, but the naming is misleading. The spec's `waitSeconds` concept (independent of repeat interval) is conflated with `repeatIntervalSeconds`. This means a step cannot have a non-zero initial wait time without also being treated as having a repeat interval.

**Severity**: Low (works correctly for current use cases since only disguisedReminder uses a non-zero wait).

---

### A2. Randomize scope does not match spec

**Spec** (`01-chain-engine.md` line 49): "`randomize` flag per step (applies to wait time, duration, and grace)."

**User decision** (issue 11): "Add randomize toggle to: Repetition interval, fake call ring duration. NOT on: SMS duration, alarm, emergency confirm."

**Implementation** (`session_engine.dart` lines 102-119): The engine's `randomize` field on `ChainStep` applies ±20% jitter to ALL three timing values (wait, duration, grace) unconditionally when the flag is set.

**Additionally** (`escalation_step_list.dart`): The UI has a separate `randomizeInterval` config key for disguisedReminder and a `randomizeRingDuration` config key for fakeCall. These are stored in the step's `config` map but the engine does NOT read them — the engine only looks at `step.randomize`.

**Impact**: The per-field randomize toggles in the UI (`randomizeInterval`, `randomizeRingDuration`) are cosmetic only — they have no effect on engine behavior. The engine's `step.randomize` flag randomizes everything or nothing.

**Severity**: Medium. The UI presents fine-grained control that doesn't actually work.

---

### A3. Simulation speed: hardcoded 5x, spec says 1x default with 5x toggle

**User decision**: "Simulation: 1x default speed, 5x toggle, skip button."

**Implementation** (`session_controller.dart` line 91):
```dart
speedMultiplier: isSimulation ? 5.0 : 1.0,
```

Speed is hardcoded to 5x for all simulations. There is no 1x default and no toggle to switch between 1x and 5x.

**Impact**: Users cannot run simulations at real-time speed. The skip button IS implemented (via `SimulationBorder` widget).

**Severity**: Low-Medium. Skip button provides similar functionality, but 1x mode is missing.

---

### A4. holdButton: auto-holds on session start, spec says "Touch to begin"

**Spec** (`01-chain-engine.md` lines 127-130): "Step starts -> Wait for user touch -> User holds". Engine should show "Touch to begin" prompt. NO timer, waiting for user touch.

**Engine** (`session_engine.dart` line 176): Correctly does nothing on holdButton step start — waits for `holdStart()`.

**UI** (`session_screen.dart` lines 276-289):
```dart
bool _isHolding = true; // assume held when walk mode starts
...
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (mounted && !_initialHoldSent) {
    _initialHoldSent = true;
    ref.read(sessionControllerProvider.notifier).holdStart();
  }
});
```

The UI immediately sends `holdStart()` on session start and sets `_isHolding = true`. This means the user never sees a "Touch to begin" prompt — the session assumes the user is already holding.

**Impact**: The spec's "Touch to begin" UX is bypassed. The user starts in a "holding" state automatically.

**Severity**: Medium. This is a deliberate UX choice but contradicts the spec.

---

### A5. holdButton grace period meaning is swapped with duration

**Spec** (`01-chain-engine.md` line 165): "For holdButton, `durationSeconds` = the visible countdown, `gracePeriodSeconds` = dead time after countdown before escalating."

**Model comment** (`chain_step.dart` lines 71-76): Documents that for holdButton, gracePeriodSeconds IS the visible countdown — contradicting the spec.

**Engine** (`session_engine.dart`): The engine uses `_effectiveDuration()` for the countdown timer in `_startHoldDurationPhase()` and `_effectiveGrace()` for the dead time in `_startHoldGracePhase()`. This matches the spec.

**Seed data** (`seed_data.dart` lines 59-62): `durationSeconds: 10, gracePeriodSeconds: 0` — the countdown is 10s via duration, grace is 0s. This matches the spec's intent.

**Impact**: The model comment is misleading but the actual behavior is correct.

**Severity**: Documentation-only issue.

---

### A6. repeatCount semantics: spec says "misses before advancing", user decision says "retries (N retries = N+1 total attempts)"

**User decision**: "repeatCount = retries (N retries = N+1 total attempts)"

**Implementation** (`session_engine.dart` line 239): Comment says "repeatCount = N means N retries -> advance after N+1 total misses." Code: `if (_missedRepeats > step.repeatCount)` — advances when misses EXCEED repeatCount. With repeatCount=2, advances after 3 misses (the initial attempt + 2 retries). This matches the user decision.

**Spec** (`01-chain-engine.md` line 47): "repeatCount: how many times the step can repeat before advancing (0 = no repeat)." The spec wording is ambiguous — "repeat N times" could mean N total or N retries.

**Impact**: None — implementation matches user decision. Spec wording could be clearer.

**Severity**: None (correct).

---

### A7. Fake call decline: spec says grace then re-ring, implementation matches

**Spec** (`01-chain-engine.md` lines 216-225): Decline -> `restartCurrentStep()` -> grace period -> ring again. Counts as a miss toward repeatCount.

**Implementation** (`session_engine.dart` lines 481-497): `restartCurrentStep()` cancels all timers, waits the grace period, then re-executes the step with `preserveMissCount: true`.

**Issue**: `restartCurrentStep()` does NOT increment `_missedRepeats`. It preserves the existing count. The spec says "This counts as a miss toward repeatCount" but the code does not count it as a miss — only grace expiration without disarm counts as a miss via `_onGraceExpired()`. When `restartCurrentStep()` is called, the grace timer's callback re-executes the step, bypassing `_onGraceExpired()`.

**Impact**: Declining a fake call does NOT count as a miss. The user can decline indefinitely without the chain advancing (until the grace -> duration cycle eventually expires without user interaction). This contradicts the spec.

**Severity**: Medium. A user who keeps declining will never exhaust the repeat count via decline alone.

---

### A8. stepAdvancing emitted before chainExhausted — CORRECT

**User decision**: "stepAdvancing emitted before chainExhausted"

**Implementation** (`session_engine.dart` lines 417-439): `_advanceToNext()` emits `stepAdvancing` first, then checks if past the end and emits `chainExhausted`. Correct.

---

### A9. Spec invariant: "loudAlarm with canDisarm=false ignores disarm()" — IMPLEMENTED

**Implementation** (`session_engine.dart` lines 449-457): `disarm()` checks for loudAlarm with `canDisarm == 'false'` and returns early. Correct.

---

### A10. Spec invariant: "hardwareButton panic trigger advances chain (not disarms)" — NOT IMPLEMENTED

**Spec** (`01-chain-engine.md` line 329, `02-event-types.md` lines 229-233): hardwareButton should detect a button press pattern and advance the chain (jump to targetStepIndex or next step).

**Implementation**: `HardwareButtonStrategy.executeReal()` is a no-op. There is no platform channel code, no `MediaButtonReceiver`, no `MPRemoteCommandCenter`. The hardware button step type exists in the model and UI config, but the actual button detection is completely unimplemented.

**Impact**: hardwareButton steps in a chain will do nothing when reached by the engine. The UI config for button type, press pattern, press count, etc. is all present but non-functional.

**Severity**: High. This is a fully designed but unimplemented feature.

---

### A11. Spec: foreground service notification with disarm button — NOT IMPLEMENTED

**Spec** (`01-chain-engine.md` lines 284-298): A persistent notification with an "I'm Safe" / "Pause" button that acts as a universal disarm, working from any screen and in the background.

**Implementation**: No foreground service, no persistent notification, no notification action button. `flutter_background_service` or equivalent is not in the dependencies. There is no code referencing foreground notifications anywhere in `lib/`.

**Impact**: Sessions cannot run reliably in the background. The universal disarm via notification is missing.

**Severity**: High. Critical for real-world usage.

---

## B. User Decisions vs Implementation

### B1. Fake call: answer shows "Calling...", chain resets only on HANG UP — CORRECT

**Implementation** (`fake_call_screen.dart`):
- `_answer()` sets `_answered = true`, shows `_ActiveCallBody` with "Calling..." text. Does NOT call `checkIn()`.
- `_hangUp()` calls `checkIn()` which triggers `disarm()`.
- `_decline()` calls `restartCurrentStep()`.

All correct per user decision.

---

### B2. Simulation: 1x default speed, 5x toggle, skip button — PARTIALLY

- Skip button: Implemented via `SimulationBorder` widget with "Skip" + fast-forward icon. CORRECT.
- Speed: Hardcoded 5x. No 1x default, no toggle. MISSING (see A3).

---

### B3. Stealth mode: collapsible per-feature toggles — NOT IMPLEMENTED

**Implementation** (`app_settings.dart`): `stealthMode` bool and `notificationDisguise` string exist in the model. However:
- No UI reads `stealthMode` to change behavior.
- No settings screen UI exposes stealth mode toggles.
- No per-feature collapsible toggles.
- The `settings_screen.dart` has no stealth section.
- No code in `session_screen.dart` or `session_controller.dart` checks stealth mode.

**Impact**: Stealth mode is defined in the data model but has zero effect on the app.

**Severity**: High. The entire stealth mode feature is a stub.

---

### B4. holdButton grace period default = 0 — CORRECT

**Implementation** (`seed_data.dart` line 61): `gracePeriodSeconds: 0` for holdButton in Walk Mode. Matches user decision.

---

### B5. Hardware button: repeatPress with press count slider (2-10x) or longPress with duration — UI ONLY

**Implementation** (`escalation_step_list.dart` lines 835-903): Full UI config with:
- Button type segmented button (volumeUp/volumeDown/lockButton)
- Press pattern segmented button (repeatPress/longPress)
- Press count slider (2-10) for repeatPress
- Long press duration slider (1-10s) for longPress

All config keys are saved but never read by any platform code. See A10.

---

### B6. Randomize toggle on repeat interval + fake call ring duration only — UI PRESENT, ENGINE IGNORES

See A2. The UI has `randomizeInterval` and `randomizeRingDuration` toggles, but the engine only uses `step.randomize` which is a blanket flag.

---

### B7. SMS message: default template pre-filled, not auto-prepended — CORRECT

**Implementation** (`sms_contact_strategy.dart` lines 17-31): Uses step-level `messageTemplate` if configured, falls back to localized template, then to a basic fallback. Does NOT auto-prepend any text.

**Event defaults** (`event_defaults.dart` lines 87-88): Default `messageTemplate` includes the "Automated safety alert..." text as part of the template, which the user can edit/remove. Matches user decision.

---

## C. Half-Implemented Features

### C1. Stealth mode — model only, no behavior

- `AppSettings.stealthMode` (bool) — stored but never read by UI or controller
- `AppSettings.notificationDisguise` (string) — stored but never read
- Spec defines extensive stealth behavior table (hidden badge, silent exit, disguised notification) — none implemented

### C2. Hardware button — UI config only, no platform code

- `ChainStepType.hardwareButton` exists in the enum
- `_HardwareButtonConfig` widget provides full configuration UI
- `HardwareButtonStrategy` exists but is a no-op
- `EventDefaults._defaultHardwareButton` has config values
- No `MethodChannel`, no native code, no button detection

### C3. Randomize per-field toggles — UI present, engine ignores

- `randomizeInterval` config key for disguisedReminder — UI toggle exists, engine ignores
- `randomizeRingDuration` config key for fakeCall — UI toggle exists, engine ignores
- Engine only reads `step.randomize` (the blanket field)

### C4. Voice recording for fake calls — config present, recording UI missing

- `EventDefaults._defaultFakeCall` has `voiceRecordingPath` key
- `FakeCallScreen._answer()` checks for voice path and plays it
- `FakeCallConfigController` has `clearVoiceRecording()` method
- But: no UI to RECORD a voice. The user can only clear it. The fake call settings screen likely has a file picker but no recorder.

### C5. Auto-record video/audio for SMS — config present, no recording service

- `EventDefaults._defaultSmsContact` has `autoRecordVideo`, `autoRecordAudio`, `recordDurationSeconds` keys
- `SmsContactStrategy.executeReal()` does NOT check these keys or start any recording
- No `RecordingService` or camera/microphone recording code exists anywhere
- UI toggles for auto-record exist in the escalation step list config

### C6. loudAlarm config keys defined but not all read

- `soundChoice` (siren/whistle/scream/custom) — stored but `LoudAlarmStrategy` just calls `audio.playAlarm()` with no sound selection
- `customSoundPath` — stored but never read
- `volume` — stored but never read; alarm plays at whatever the AudioService default is
- `flashLight` — stored but no camera flash code exists
- `flashScreen` — stored but no screen flash code exists

### C7. countdownWarning config keys partially used

- `style` (fullScreen/notification/discrete) — stored but the countdown UI is always full-screen
- `vibrate` — stored but `CountdownWarningStrategy` unconditionally calls `vibration.warningPattern()`
- `sound` — stored but never read
- `soundAsset` — stored but never read

### C8. callEmergency `showConfirmation` — config present, no confirmation dialog

- `showConfirmation` config key exists in defaults and is read in preview (`escalation_step_list.dart` line 570)
- `CallEmergencyStrategy.executeReal()` does NOT check `showConfirmation` — it calls `phone.callEmergency()` immediately
- No confirmation dialog is shown before dialing emergency services

### C9. phoneCallContact `alternativeContactIds` — spec defines it, never implemented

- Spec (`02-event-types.md` line 163): `alternativeContactIds` for fallback contacts
- Not in `EventDefaults._defaultPhoneCallContact`
- Not read by `PhoneCallContactStrategy`
- No UI for configuring alternative contacts

### C10. phoneCallContact `callChannel` — config stored, strategy ignores it

- `callChannel` config (phone/whatsapp/telegram) is stored and has UI
- `PhoneCallContactStrategy.executeReal()` always calls `services.phone.call(contact.phoneNumber)` — ignores the channel
- Should route through WhatsApp/Telegram when configured

---

## D. Missing Features (Not Implemented At All)

### D1. Background execution / foreground service

No foreground service implementation. The app cannot:
- Run timers when backgrounded
- Show persistent notification
- Keep the session alive when screen is off
- Provide the "I'm Safe" notification button

This is the single most critical missing feature for a safety app.

### D2. Voice recording UI for fake calls

Config infrastructure exists (`voiceRecordingPath`), playback works, but there is no way for the user to record a voice clip within the app.

### D3. Auto-record video/audio

Spec (`02-event-types.md` lines 134-136): `autoRecordVideo`, `autoRecordAudio`, `recordDurationSeconds` for smsContact. Config keys exist but no recording service or camera/microphone integration.

### D4. Camera flash / screen flash for loud alarm

Spec (`02-event-types.md` lines 188-189): `flashLight` and `flashScreen` for loudAlarm. Config keys exist but no implementation.

### D5. Hardware button platform channel

Spec (`02-event-types.md` lines 238): Requires platform-specific code — Android `MediaButtonReceiver` / iOS `MPRemoteCommandCenter`. No native code exists.

### D6. Phone call retry logic with delay

`PhoneCallContactStrategy` has retry logic but it's a tight loop with no delay:
```dart
for (var i = 0; i < retryCount && !called; i++) {
  called = await services.phone.call(contact.phoneNumber);
}
```
No waiting between retries. If the call fails, it immediately retries. Should have a delay (e.g., 30s) between attempts.

### D7. Emergency confirmation dialog

Spec (`02-event-types.md` lines 207-208): `showConfirmation = true` should show a 5-second confirmation countdown before dialing. Not implemented in the strategy — emergency call fires immediately.

### D8. Notification-based disguised reminders in background

Spec (`02-event-types.md` lines 67-69): When app is backgrounded, disguised reminders should appear as system notifications. Requires foreground service (D1) plus notification channel integration.

### D9. SMS to emergency number before emergency call

`CallEmergencyStrategy` does implement this (`sendLocationSmsFirst`), but it sends to the emergency number itself (e.g., 112). Sending SMS to emergency numbers is generally not supported by carriers and will silently fail. This may need rethinking.

### D10. Stealth mode behavior

Spec (`01-chain-engine.md` lines 303-310): Extensive table of normal vs stealth behavior. Zero implementation beyond the `stealthMode` bool in settings.

---

## E. Questions for the User

### E1. Hardware button: ship without platform code?

The hardware button has full UI config but zero native implementation. Should it be:
- (a) Hidden from the UI until platform channels are built
- (b) Shown but marked as "Coming Soon"
- (c) Left as-is (configurable but non-functional)

### E2. Foreground service priority

Background execution is the most critical missing piece. What platform(s) should be prioritized? Android-only first (easier with `flutter_foreground_task`)? Or both Android + iOS simultaneously?

### E3. Stealth mode scope

Stealth mode is fully specced but has zero implementation. Is this a post-launch feature, or does it need to be in v1?

### E4. Auto-record video/audio: privacy implications

The spec includes auto-recording when SMS is sent. This has significant privacy and legal implications (two-party consent laws). Should this be:
- (a) Implemented as specced
- (b) Deferred with a clear "future feature" note
- (c) Removed from the spec

### E5. Emergency SMS to 112/911

`CallEmergencyStrategy` tries to send an SMS to the emergency number before calling. Most carriers don't support SMS to emergency numbers. Should this be:
- (a) Removed (SMS to emergency contacts only, call to 112)
- (b) Changed to SMS to user's emergency contacts instead
- (c) Left as-is (best effort, may silently fail)

### E6. Simulation speed toggle

The user decided "1x default, 5x toggle" but current implementation is 5x-only. Is the 1x default still desired, or is 5x with skip button sufficient?

### E7. "Touch to begin" vs auto-hold

The spec says holdButton should show "Touch to begin" and wait. The implementation auto-holds on session start. Which behavior is desired?

### E8. Fake call decline: should it count as a miss?

Spec says decline counts as a miss toward repeatCount. Implementation does not count it. Which is correct?

### E9. randomize granularity

Current engine: all-or-nothing randomize per step. UI: per-field toggles for interval and ring duration. Should the engine be updated to read per-field config keys, or should the UI be simplified to match the engine?

---

## Summary Table

| Area | Status | Severity |
|------|--------|----------|
| Engine three-phase timing | CORRECT | - |
| holdButton user-driven flow | CORRECT (engine) | - |
| holdButton auto-hold on start | DEVIATES from spec | Medium |
| disguisedReminder cycle | CORRECT | - |
| Fake call answer/decline/hangup | CORRECT (UI) | - |
| Fake call decline miss counting | DEVIATES from spec | Medium |
| repeatCount = retries semantics | CORRECT | - |
| stepAdvancing before chainExhausted | CORRECT | - |
| loudAlarm canDisarm=false | CORRECT | - |
| Foreground service / background | NOT IMPLEMENTED | **Critical** |
| Hardware button platform code | NOT IMPLEMENTED | High |
| Stealth mode | STUB (model only) | High |
| Randomize per-field toggles | UI only, engine ignores | Medium |
| Simulation speed toggle | Hardcoded 5x | Low-Medium |
| Auto-record video/audio | Config only, no service | Medium |
| Camera/screen flash for alarm | Config only, no code | Low |
| Emergency confirmation dialog | Config only, no dialog | Medium |
| Phone call channel routing | Config only, strategy ignores | Medium |
| Alternative contacts for phone call | Not in code | Low |
| Voice recording UI | Playback works, no recorder | Low |
