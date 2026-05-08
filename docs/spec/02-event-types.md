> **Normative status:** This document is NORMATIVE. In case of conflict
> with any other document (decisions log, audits, reviews), this document
> takes precedence. Key words "MUST", "SHOULD", "MAY" follow RFC 2119.

# 02 - Event Types Specification

## 9 Step Types

The chain consists of **9 step types**. Some serve as check-in methods (how the user confirms safety), others are escalation actions. Every step has:
- **Action**: what happens when the step fires
- **Disarm mechanism**: how the user proves they're OK
- **Grace period**: time before auto-advancing to next step
- **Config**: type-specific settings (global defaults + per-instance overrides)
- **Real mode**: actual execution (send SMS, play alarm, etc.)
- **Simulation mode**: description text only, no real actions

### Mode Editor Features

**Duplicate Step:** In the mode editor, any step can be duplicated with a single click. This creates a copy of the step with all the same settings, inserted right after the original.

**Timing Configuration:** All step types share a common "Timing" configuration group shown as a collapsible section in the mode editor. The timing section includes:
- `waitSeconds` — delay before event fires
- `durationSeconds` — how long the event actively runs
- `gracePeriodSeconds` — dead time after event, before advance/repeat
- `retryCount` — how many retries before advancing to next step

---

## 1. holdButton (Check-in Method)

**Purpose:** Dead man's switch. User holds screen; releasing starts countdown.

**Lifecycle:**
```
Step starts → Wait for user touch → User holds → User releases → 
Sensitivity delay (1s) → Grace countdown (10s) → Advance to next step
```

**Disarm:** Re-hold the button before grace expires.

**Hold Styles:**
- `largeButton`: 200x200px circle (default)
- `fullScreen`: entire screen is touch target, app-styled with text
- `fakeLockScreen`: black full-screen overlay, touch anywhere (mimics locked phone). Any `onTapDown` / `onLongPressStart` is treated as the hold-start event, and release/cancel runs the usual hold-release logic. Implementation: `_FakeLockScreenHold` in `lib/features/session/session_screen.dart` (Extra 40). Screen brightness set to near-zero to save battery. Wakelock active.

**Session Start Behavior:** Engine waits for first `holdStart()`. Does NOT assume user is holding. UI shows "Touch to begin" prompt. Session timer starts on first touch.

**Release Sensitivity:** Configurable per mode (not just global defaults), range 0.3–3.0 seconds, default 1.0s. Ignores brief lifts shorter than the configured sensitivity.

**Feedback:**
- Haptic feedback on release: toggleable (default on)
- Sound on release: toggleable (default off)

**Config Keys:**
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| holdStyle | enum | largeButton | largeButton, fullScreen, fakeLockScreen |
| releaseSensitivity | float | 1.0 | Seconds to ignore brief lifts (0.3–3.0) |
| vibrateOnRelease | bool | true | Vibrate when countdown begins |
| soundOnRelease | bool | false | Play warning sound on release |

**Timing Defaults:** waitSeconds=0, durationSeconds=10, gracePeriodSeconds=0 (issues-v4 #16 — was 5; user-test feedback was that the extra wait after the countdown ends doesn't aid recovery), retryCount=0

**Real Mode:** No service action — purely UI-driven.
**Simulation:** No toast needed — UI shows hold button.

---

## 2. disguisedReminder (Check-in Method)

**Purpose:** Periodic fake notifications looking like real apps. User confirms by interacting with the notification.

**Lifecycle:**
```
Step starts → Wait repeatInterval → Fire reminder (reminderFired event) →
Wait gracePeriod for user to confirm → 
  If confirmed: restart cycle (disarm)
  If missed: increment missCount → 
    If missCount >= retryCount: advance to next step
    Else: wait repeatInterval → fire again
```

**Disarm:** Interact with the reminder overlay based on confirmation type:
- **tapButton**: Tap a realistic button label (positioned like a real notification button)
- **tapWord**: Tap correct word from 3 options (words provided per template, multiple word sets)
- **swipe**: Swipe to dismiss (like real notification, specific direction)
- **dismiss**: Realistic dismiss gesture (not just tap anywhere)

**Template Selection (Extra-8, C4):**

The reminder strategy selects a template from the merged pool of templates available in the session context (`SessionContext.reminderTemplates`). The pool is the merge of global `AppDefaults` templates and any mode-local templates.

Selection algorithm:
1. If `templateIds` is non-empty, filter pool to only those IDs.
2. If the filtered pool is empty (no matching templates), fall back to the first template in the unfiltered pool. If the pool is entirely empty, use a hard-coded built-in template.
3. If `randomizeTemplateOrder = false`, use `pool[0]` (first matching template).
4. If `randomizeTemplateOrder = true`, use a time-based index (`millisecondsSinceEpoch ~/ 1000 % pool.length`) to introduce variation without needing a `Random` instance in the stateless strategy.

**Avoiding same template twice (C4):** The session controller tracks the ID of the last shown template and passes an updated `templateIds` exclusion list (or re-ordered pool) when building the next `SessionContext`. The strategy itself is stateless; avoidance logic lives in the controller.

**Built-in Templates:**
- 8 built-in templates (Calendar, Duolingo, Delivery, Weather, Email, Chat, Bank, Social Media)
- Can be more sophisticated than user-created ones
- Built-in templates can be disabled from rotation but not deleted
- Template rotation avoids same template twice in a row (controller responsibility, see above)

**Template management from this event form:**

The DisguisedReminder form in the mode editor renders a "Manage
reminder templates" `ListTile` (leading `collections_outlined`,
chevron trailing) that navigates to `/settings/reminder-templates`.
An `InfoIconButton` above the link explains that templates are the
disguised notifications this step draws from. Users can jump from the
step config directly into template management (create / duplicate /
edit / delete) without leaving the mode editor flow.

**Display Styles:**
- `fullScreen`: wakes screen, shows full-screen overlay
- `subtle`: notification card (system notification when app backgrounded)

**Background Behavior:**
- When app backgrounded: system notification is shown
- Tapping notification = check-in for simple types (tapButton, dismiss)
- tapWord confirmation: opens full-screen overlay (notification says "tap to check in")
- Swipe confirmation: notification text says "swipe to dismiss"

**OS Matching Notification Style:** iOS or Android default appearance (configurable, defaults to current OS).

**Duration Visible:** Configurable (how long before auto-dismissing counts as miss).

**Early Check-in (D4 — `resetOnEarlyCheckIn`):**

When the user taps the reminder notification **before** the reminder fires (during the wait phase), the engine calls `earlyCheckIn()`:
- **`resetOnEarlyCheckIn = true`** (default): The tap counts as a valid check-in. `disarm()` is called, resetting the cycle to step 0.
- **`resetOnEarlyCheckIn = false`**: The tap is ignored. The existing wait timer runs to completion, and the reminder fires at its scheduled time. Useful for modes where the user must wait until the reminder actively appears before checking in (stricter verification).

**Config Keys:**
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| templateIds | comma-sep string | all | Which reminder templates can appear |
| waitSeconds | int | 1800 | Seconds between reminders (30 min) |
| randomizeInterval | bool | true | Add ±20% jitter to interval |
| randomizeTemplateOrder | bool | true | Pick random template each time |
| retryCount | int | 1 | How many misses before advancing (B2) |
| resetOnEarlyCheckIn | bool | true | Whether tapping early (in wait phase) counts as a check-in |

**Timing Defaults:** waitSeconds=1800, durationSeconds=60, gracePeriodSeconds=5, retryCount=1 (B2)

**Real Mode:** No service action — reminder is UI only. Notification when backgrounded.
**Simulation:** Actual reminder overlay shown — identical to real mode. Notification carries `[SIM]` suffix. No toast substitution.

---

## 3. hardwareButton (Check-in Method)

**Purpose:** Discreet hardware button check-in. User presses physical device button instead of touching screen.

**Platform Support:**
- **Android only** — iOS option greyed out (platform limitations prevent reliable button detection)

**Android Implementation:**
- `dispatchKeyEvent` in MainActivity returns true (consumed) for volume key events
- Suppresses both the volume change and the volume HUD

**Detection Patterns:**
- `repeatPress`: 2–10 presses within configurable window (default 5 presses, 500ms window)
- `longPress`: 1–10 seconds sustained hold (default 2s)
- One or the other active, not both simultaneously

**Behavior:** Pattern triggers `disarm()` → reset to step 0

**Test/Preview:** Available in settings — same UI as simulation mode, shows "Button press detected!" feedback.

**Config Keys:**
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| buttonType | enum | volumeUp | volumeUp, volumeDown |
| pressPattern | enum | repeatPress | repeatPress, longPress |
| pressCount | int | 5 | Number of rapid presses (2–10, repeatPress only) — default 5 (B1) |
| longPressDurationSeconds | float | 2.0 | Duration (1–10s, longPress only) |

**Timing Defaults:** waitSeconds=0, durationSeconds=0, gracePeriodSeconds=0, retryCount=0

**Permissions:** Only CALL_PHONE requested when hardware button configured in mode. Volume key detection requires no special permission.

**Real Mode:** Platform key detection only (no service calls).
**Simulation:** Toast: "Button press detected!"

---

## 4. countdownWarning

**Purpose:** Visual/audio countdown with vibration before escalation.

**Disarm:** Swipe "I'm Safe" slider (any disarm interaction works).

**Config Keys:**
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| style | enum | fullScreen | fullScreen, notification, minimal |
| vibrate | bool | true | Vibration pattern during countdown |
| sound | bool | false | Warning sound |
| soundAsset | string | null | Custom warning sound file path |

**Timing Defaults:** waitSeconds=0, durationSeconds=10, gracePeriodSeconds=3, retryCount=0

**Real Mode:** VibrationService.warningPattern() + optional audio.
**Simulation:** Actual countdown UI fires — identical to real mode (large countdown number, circular progress, vibration). No toast substitution.

---

## 5. fakeCall

**Purpose:** Realistic incoming call screen mimicking real apps.

**Call Styles:**
- `android`: Android native call UI
- `ios`: iPhone call UI
- `whatsapp`: WhatsApp call UI
- `telegram`: Telegram call UI
- `signal`: Signal call UI
- Default: native OS style (android on Android, ios on iOS)

**Ringtone:** Matches call style (Android default ringtone for android style, iOS for ios style, WhatsApp ringtone for whatsapp style, etc.).

**Fake Call Lifecycle (Two-Phase Model):**

The fake call follows a two-phase interaction model:

1. **Ringing Phase**
   - Call rings with configured ringtone and vibration pattern
   - User has three options: Answer, Decline, or wait for timeout

2. **User Actions**
   - **Answer**: Stops ringtone → "Calling..." screen → chain PAUSES (no escalation) → voice recording plays → user manually hangs up → DISARM (reset to step 0)
   - **Decline (brief tap)**: Default behavior depends on `declineIsSafe` flag:
     - If `declineIsSafe=true` (default): Disarm immediately (reset to step 0)
     - If `declineIsSafe=false`: Counts as a miss → call rings again per `retryCount`
   - **Decline with Distress (5s hold on Decline button)**: Triggers the mode's selected distress chain. Visual feedback: progress ring on Decline button, haptic feedback at 800ms. Distress chain replaces the main chain permanently.
   - **Timeout (no action within `ringDurationSeconds`)**: Counts as a miss → call rings again per `retryCount`

**Voice Recording:**
- Built-in voice recording per supported language (generic "Hey, it's Angela, just checking in..." type message)
- Voice plays through earpiece by default (configurable to speaker, like a real call)
- After voice recording ends: UI remains on "Calling..." screen. User manually hangs up. No auto-hang-up timeout (user may be pretending to talk).
- If no voice recording configured: stays on "Calling..." screen until user hangs up.

**Real Phone Call Interaction:**
If a real phone call comes in while a fake call is active, the fake call auto-disarms silently when the real call ends. The user was genuinely in a call, so the safety check-in is considered satisfied.

**Chain Pausing vs Disarming:**
- **Chain PAUSES on answer**: When user answers, timers stop but the session continues. No escalation to next step until hang-up.
- **DISARM on hang-up**: When user manually hangs up, disarm fires (reset to step 0) and chain restarts from the beginning.

**Vibration:** Realistic phone call vibration pattern (matches OS).

**Phone Settings:** Respects phone ringer settings (silent/vibrate/volume).

**Background Behavior:** Wakes screen, shows full-screen call UI on both platforms (like a real incoming call).

**Config Keys:**
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| callStyle | enum | (native OS) | android, ios, whatsapp, telegram, signal |
| callerName | string | Angela | Name shown on the call screen |
| callerPhotoPath | string | null | Photo shown on the call screen |
| voiceRecordingPath | string | null | Audio played when call is "answered". When null, `AudioService` selects the built-in per-language clip for the device locale (see spec/05, Voice Recordings C2). User-recorded files are capped at `kMaxVoiceRecordingDurationSeconds` = 120 seconds per Extra 39 |
| voiceOutputMode | enum | earpiece | earpiece, speaker |
| ringDurationSeconds | int | 30 | How long the call rings (= duration) |
| declineIsSafe | bool | true | Decline = disarm (true) or miss (false) |

**Timing Defaults:** waitSeconds=0, durationSeconds=30, gracePeriodSeconds=5, retryCount=0 (B3 — one attempt only)

**Engine Methods:**
- `answerFakeCall()`: Pauses chain timers, does NOT disarm
- `hangUp()`: Fires disarm (reset to step 0)

**Real Mode:** Audio ringtone via AudioService, vibration, call screen UI.
**Simulation:** Call screen shown with working interactions (real experience); toast: "Fake call from Angela would ring"

---

## 6. smsContact

**Purpose:** Send emergency message with GPS location to selected contacts.

**Message Template Placeholders:**
- `{name}`: contact name, or "the owner of this phone" if no name set
- `{location}`: Google Maps URL if available. If no GPS: "Location unavailable". If only stale location: "Last known location at {timestamp}: {url}" with accuracy info
- `{time}`: timestamp
- `{description}`: user-defined physical description
- `{photo}`: NOT sent via SMS (MMS unreliable). Reserved for future channels

**Default Template:**
```
Automated safety alert from Guardian Angela.
{name} may need help.
Last known location: {location}
Time: {time}
Physical description: {description}
```

**Template Editing:** Fully editable by user with "insert placeholder" buttons for each.

**Contact Selection:** Per-step config, driven by `SmsContactConfig.contactSelection` (enum `SmsContactSelection`):
- `allContacts` (default, backwards-compatible): send to every emergency contact. For legacy modes that set `contactIds` without setting `contactSelection`, the strategy treats the list as specific IDs.
- `firstContact`: send only to the default contact — the one with the lowest `EmergencyContact.sortOrder` (ties broken stably by list order). Used by the default distress chain.
- `specificIds`: send only to contacts whose IDs appear in `SmsContactConfig.contactIds` (empty/null list ⇒ nobody).

Only contacts with a valid channel for the selected send method are targeted; the rest are filtered out at runtime.

**Single-Channel Dispatch (Extra-15 / 15b):**

Each `smsContact` step sends via **exactly ONE** messaging channel, specified by `SmsContactConfig.channel` (default: `sms`). Contacts that do not have the configured channel enabled are excluded at runtime. This prevents accidental multi-channel sends from a single step.

To send via multiple channels in a session (e.g., SMS + WhatsApp), configure two separate `smsContact` steps — one per channel.

Validation also blocks saving a mode where a step's `channel` is not present on any of the targeted contacts.

**Channel Options:**
- **SMS** (primary)
  - Android: auto-send silently via SmsManager
  - iOS: opens Messages app pre-filled — **user must manually press Send**
  - **iOS platform warning (MUST show in mode editor):** "On iPhone, SMS requires you to manually press Send in the Messages app. If you cannot interact with your phone, the message will not send. Consider using WhatsApp or Telegram instead."
- **WhatsApp**: sends via `wa.me` deep link; user must press Send
- **Telegram**: sends via `tg://msg` deep link; user must press Send

**SMS Retry:** Indefinite retry queue via native Kotlin WorkManager. Queues SMS when no signal, retries until delivered or session ends. Survives process death.

**Auto-Recording:** Starts audio recording when step fires (option, default off). Recording stored locally only — NOT attached to messages (deferred feature). Greyed out if channel is SMS.

**Legal Warning:** Shown during setup and before session start.

**Location Recording:** Triggered based on settings (on escalation steps / on all events).

**Non-Blocking on Failure:** Advanced per-step toggle. If SMS fails, log and continue chain.

**Config Keys:**
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| contactIds | List&lt;String&gt;? | null | Specific contact IDs. Meaningful only when `contactSelection == specificIds`. Also honoured for legacy modes where `contactSelection` is left at the default. |
| contactSelection | enum | allContacts | `allContacts`, `firstContact`, or `specificIds`. Controls which contacts the step targets. |
| channel | enum | sms | The ONE channel to send via (sms, whatsapp, telegram) |
| messageTemplate | string | (default) | Customizable message with placeholders |
| includeLocation | bool | true | Attach Google Maps link |
| includeMedicalInfo | bool | false | Include user medical info from profile |
| autoRecordAudio | bool | false | Auto-start audio recording |
| recordDurationSeconds | int | 30 | Duration of auto-recording |

**Timing Defaults:** waitSeconds=0, durationSeconds=15, gracePeriodSeconds=5, retryCount=0

**Real Mode:** `SmsContactStrategy.executeReal()` — filters contacts to those with the configured `channel`, sends via that single channel. LocationService provides GPS URL. Optional audio recording.
**Simulation:** Toast: "Would send to N contacts via [channel]"

---

## 7. phoneCallContact

**Purpose:** Auto-dial a specific friend/family member.

**Channel:** **Phone call only** (tel: URI). WhatsApp/Telegram/Signal voice calls removed — deep links cannot initiate calls, only open chats.

**Pre-SMS Before Calling:**
- Uses same placeholder system as smsContact
- Default message: "I may be in danger, calling you now.\nMy location: {location}"
- Optional, configurable toggle

**Call Detection:** App cannot detect if call was answered (platform limitation). Call fires, duration timer runs, then grace.

**Retry Logic:**
- `retryCount`: how many times to retry if no answer (default 1)
- Retry delay = grace period
- After all retries + alternatives exhausted: advance

**Alternative Contacts:** Fallback list (alternativeContactIds, comma-separated).

**Config Keys:**
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| contactId | string? | null | Primary contact id; null = first-sorted contact. |
| alternativeContactIds | List<String> | [] | Fallback contact ids tried in order if the primary fails. |
| logGps | LogGpsOverride | useDefault | Per-step GPS-logging override (DE-2). |

`retryCount` lives on the parent `ChainStep`, not on this config. Pre-call SMS is **not** part of `phoneCallContact` — calling a personal contact doesn't warrant an automatic pre-warning SMS. The pre-call location-SMS toggle exists only on `CallEmergencyConfig.sendLocationSmsFirst` (§9 below).

**Timing Defaults:** waitSeconds=0, durationSeconds=60, gracePeriodSeconds=5, retryCount=1

**Permissions:**
- Android: CALL_PHONE permission enables auto-dial without confirmation dialog
- iOS: always shows confirmation dialog (documented limitation)

**Real Mode:** PhoneService.call() iterates primary then alternatives.
**Simulation:** Toast: "Would call [contact name]"

---

## 8. loudAlarm

**Purpose:** Maximum volume siren to attract attention.

**Always Disarmable:** The alarm is always disarmable — there is no `canDisarm=false` option, as accidental triggers must be stoppable.

**Volume:** User-configurable (0.0–1.0, default 1.0).

**Gradual Volume Increase:** Linear ramp over configurable duration (default 10s). Timer.periodic at 100ms intervals.

**System Volume Override:** Configurable toggle. When enabled, sets system media stream to max before playing. Only the alarm overrides silent/vibrate mode (other events respect phone settings).

**Sound Options:**
- Built-in `siren` (default)
- `custom`: user-supplied audio file or in-app recording

**Camera Flash:** SOS morse pattern (··· −−− ···). Configurable toggle (default off).

**Screen Flash:** White/red alternating. Two options:
- Fast (500ms intervals) — more attention-grabbing
- Slow (1000ms intervals) — safer for photosensitive users (default if enabled)

**Photosensitivity Warning:** Shown when enabling screen flash.

**Vibration:** Always plays alarm pattern (continuous strong pulsing). Alarm is the ONE exception that overrides silent mode.

**Config Keys:**
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| volume | double | 1.0 | Linear volume 0.0–1.0 |
| soundChoice | LoudAlarmSound | siren | `siren` or `custom` |
| flashLight | bool | true | Strobe camera flashlight |
| flashScreen | bool | false | Strobe screen (photosensitive warning) |
| flashSpeed | double | 0.5 | (legacy) seconds per flash cycle |
| flashSpeedMs | int | 500 | Flash cycle length in ms |
| maxVolume | bool | true | (legacy) force system media volume to max |
| gradualVolume | bool | false | Ramp volume from silence to `volume` |
| blackScreenMode | bool | false | Render under black overlay (stealth alarm) |
| logGps | LogGpsOverride | useDefault | Per-step GPS-logging override (DE-2) |

The ramp duration is **not** on `LoudAlarmConfig` — it lives globally on `AppSettings.alarmGradualVolumeDurationSeconds` (default 5 s). When `gradualVolume` is true the alarm ramps to `volume` over that many seconds.

**Timing Defaults:** waitSeconds=0, durationSeconds=30, gracePeriodSeconds=5, retryCount=0

**Real Mode:** AudioService.playAlarm() + VibrationService.alarmPattern() + optional camera/screen flash.
**Simulation:** Toast: "Would play loud alarm"

---

## 9. callEmergency

**Purpose:** Dial emergency services (112/911/etc.).

**Emergency Number:** Locale-aware with 80+ country mapping. The number is resolved at run time with the following precedence:

1. **Per-step override** — `CallEmergencyConfig.emergencyNumber` on the active step, when set to a non-null, non-empty string.
2. **Global default** — `AppSettings.emergencyCallNumber`, seeded from the device locale during onboarding and editable in Settings.

`CallEmergencyConfig.emergencyNumber` defaults to `null` which means "inherit the global default". The mode editor shows the current global value as the field's placeholder; leaving the field blank keeps the inheritance behaviour. A non-empty value overrides the global for that step only — useful for per-mode travel configurations without touching the app-wide setting.

**Confirmation Countdown:** **Default ON** (configurable, default duration 5s). Shows countdown before dialing, giving last chance to cancel. When disabled, call initiates immediately.

**Cancel confirmation swipe (Extra 56):** The "cancel emergency call" action during the confirmation countdown requires a swipe-to-confirm slider (`SwipeSlider` in `lib/core/widgets/swipe_slider.dart`). Users must drag the knob 70% of the track width before `onConfirm` fires, preventing a stray tap from aborting a real emergency call. Releasing below the threshold animates the knob back to the start. The dialog still exposes a `[Keep calling]` button for the common case of a fat-fingered open.

**Pre-Call SMS to Emergency Number:** Configurable (sendLocationSmsFirst, default true). Note: "SMS to emergency services may not work in your country"

**NOT Necessarily Terminal:** Can have steps after it. "I'm okay" disarm available (standard swipe slider).

**Config Keys:**
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| emergencyNumber | String? | null (inherit `AppSettings.emergencyCallNumber`) | Per-step override. Blank / null = use global Settings default (112, 911, …). |
| sendLocationSmsFirst | bool | true | Send location SMS before calling |
| showConfirmation | bool | true | Show countdown before dialing |
| confirmationDurationSeconds | int | 5 | Confirmation countdown duration |

**Timing Defaults:** waitSeconds=0, durationSeconds=5, gracePeriodSeconds=0, retryCount=0

**Permissions:**
- Android: CALL_PHONE permission enables auto-dial without confirmation dialog
- iOS: always shows confirmation dialog — single tap required (documented limitation, warn user during setup)
- **iOS limitation warning:** During mode creation, if an iOS user adds a callEmergency step, show: "On iPhone, a confirmation dialog will appear before dialing. Tap 'Call' quickly."

**Real Mode:** PhoneService.callEmergency() + optional MessagingService SMS.
**Simulation:** Toast: "Would call [number]"

---

## Distress Chain & Condition-Triggered Chains

Condition-triggered actions. The distress chain **replaces** the main chain (stops and discards it permanently — no return). Battery alert is a one-shot side-action that does not interrupt the main chain.

### Distress Chain

A **distress chain** is the `chainSteps` of a distress mode — a regular `SessionMode` with `isDistressMode = true`. Each `SessionMode` selects one via `distressModeId` (null = inherit `AppDefaults.defaultDistressModeId`).

Distress modes are managed under `/distress-modes` (Settings → Modes & Chains → Distress Modes). They are edited with the same `ModeEditorScreen` used for regular modes (passed `isDistress: true`).

**Three Trigger Types (All Fire the Same Distress Chain):**

All three condition-triggered distress mechanisms fire the **same selected distress chain** for the mode. There are no separate models per trigger type.

1. **Hardware Panic Button (5× Volume)**
   - User rapidly presses the volume button 5+ times while session is active
   - Triggers distress chain silently
   - May be used discreetly when attacker is nearby

2. **Duress PIN Entry**
   - User enters a secondary PIN (configured in Settings) at any PIN prompt (app PIN, session end PIN, or as part of a PIN-based check-in)
   - Shows fake "Session ended" message to attacker (mimics normal PIN entry)
   - Fires distress chain silently in the background
   - Critical feature for situations where user is forced to unlock the app under duress

3. **Wrong PIN Threshold**
   - Configurable number of consecutive wrong PIN attempts trigger the chain
   - User is not aware that attempts are being tracked
   - Provides automatic escalation if attacker is guessing the PIN

### Low Battery Alert

- Fires when OS battery level drops below `BatteryAlertConfig.thresholdPercent`
- Optional, off by default (`BatteryAlertConfig.enabled`)
- One-shot alert: fires once per session, does NOT repeat
- **Runs a chain** — `BatteryAlertConfig.chain: List<ChainStep>` is executed through the same engine/orchestrator used for session chains
- Default seed chain is a single `smsContact` step that contacts the user's emergency contacts. Users can edit the chain in `/settings/battery-alert`
- Main session continues uninterrupted
- Logged in session history for reference

---

## Event Execution: Strategy Pattern

```dart
abstract class EventStrategy {
  /// Perform the real action (send SMS, play alarm, etc.)
  Future<void> executeReal(ChainStep step, EventServices services);
  
  /// Return description for simulation toast. Null = no toast needed.
  String? simulationDescription(ChainStep step, EventServices services);
}
```

EventServices bundles all dependencies:

```dart
class EventServices {
  final AudioService audio;
  final VibrationService vibration;
  final MessagingService messaging;
  final PhoneService phone;
  final LocationService location;
  final RecordingService recording;
  final FlashService flash;
  final ContactService contacts;
  final String? userName;
  final String? userDescription;
  final VoidCallback? isCancelled;
  final Function(bool)? onScreenFlash;
}
```

### Strategy Implementations

| Strategy | Real Action | Simulation |
|---|---|---|
| **HoldButton** | No-op (UI-driven) | Silent (no toast) |
| **DisguisedReminder** | No-op (UI-driven) | Actual overlay shown — identical to real mode; `[SIM]` suffix on notification |
| **HardwareButton** | No-op (platform detection) | Toast: "Button press detected!" |
| **CountdownWarning** | Vibration.warningPattern() | Actual countdown UI + vibration fires normally |
| **FakeCall** | Call screen shown (even in sim) | Call screen + ringtone fire normally |
| **SmsContact** | `messaging.sendMessage()` per contact via the single configured `channel` (Extra-15) | BLOCKED → logged as `sim_blocked`; toast shown |
| **PhoneCallContact** | Phone.call() + optional pre-SMS | BLOCKED → logged as `sim_blocked`; toast shown |
| **LoudAlarm** | Audio.playAlarm() + vibration + optional flash | MUTED; notification shown ("Alarm would sound") |
| **CallEmergency** | Phone.callEmergency() + optional SMS | BLOCKED → logged as `sim_blocked`; toast shown |

**Simulation behavior summary — principle: identical UI for all local-only actions:**
- **Fires normally with identical UI (local-only):** Fake call screen + ringtone, actual countdown warning UI + vibration, actual disguised reminder overlay + notification (`[SIM]` suffix), foreground notification (SIMULATION prefix), location/GPS tracking
- **Blocked (logged as `sim_blocked`):** SMS, WhatsApp, Telegram, phone calls to contacts, emergency calls, audio recording
- **Muted:** Loud alarm (silent with notification indicator showing "Alarm would have sounded at full volume")

**Defense-in-depth:** Real actions NEVER fire during simulation. Guards at engine flag, strategy, service parameter, and subclass level — structurally impossible to reach real SMS/call code.

---

## Configuration Defaults (Global & Per-Step)

All steps have global defaults in `EventDefaults` (typeId 13), overridable per-chain-instance in `ChainStep.config`.

**Global Config Pattern:**
```dart
// lib/data/models/event_defaults.dart
EventDefaults {
  final ChainStepType type;
  final int defaultWaitSeconds;
  final int defaultDurationSeconds;
  final int defaultGracePeriodSeconds;
  final int defaultRepeatCount;
  final Map<String, String> defaultConfig; // type-specific
}
```

**Usage:**
```dart
// In SessionMode: list of ChainSteps, each can override global defaults
ChainStep {
  type: ChainStepType.smsContact,
  waitSeconds: 0,              // from EventDefaults if not set
  durationSeconds: 15,         // from EventDefaults if not set
  gracePeriodSeconds: 5,       // from EventDefaults if not set
  retryCount: 0,              // from EventDefaults if not set
  config: {
    'contactIds': '1,2,3',     // override per-step
    'messageTemplate': '...',  // override per-step
  },
}
```
