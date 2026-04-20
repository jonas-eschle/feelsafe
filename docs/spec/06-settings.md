> **Normative status:** This document is NORMATIVE. In case of conflict
> with any other document (decisions log, audits, reviews), this document
> takes precedence. Key words "MUST", "SHOULD", "MAY" follow RFC 2119.

# 06 - Settings & Configuration Specification

## Overview

Guardian Angela's settings system provides comprehensive control over every aspect of the app's behavior. Settings are persisted in the encrypted Hive database (`AppSettings`, typeId 9) and can be accessed via `/settings` route. All configurable options have sensible defaults; users customize only what they need.

### Top-level = Theme + Language only (UI convention)

The top-level `/settings` screen shows ONLY the two controls that users change most often — **Theme** and **Language**. Every other setting lives on a dedicated subcategory screen linked from a tappable row below. This keeps the hub screen scannable and makes each subcategory self-contained (an important affordance for accessibility and translation — fewer cramped sections, fewer inline accordions).

The old two-level "Defaults" and "Modes & Chains" hubs have been removed. Each previously-grouped configuration is now its own screen:

| Section | Subcategory | Route |
|---------|-------------|-------|
| Session | Modes | `/modes` |
| Session | Distress chains | `/distress-chains` |
| Session | Battery alert | `/settings/battery-alert` |
| Security | Security (PIN, biometric, thresholds) | `/settings/security` |
| Security | Stealth | `/settings/stealth` |
| Defaults | Event defaults | `/settings/event-defaults` |
| Defaults | GPS logging | `/settings/gps-logging` |
| Defaults | Reminder templates | `/settings/reminder-templates` |
| Defaults | Notifications (permissions) | `/settings/notifications` |
| Data | Profile | `/profile` |
| Data | History & retention | `/settings/history-retention` |
| Data | Backup | `/settings/backup` |
| About | Feedback | `/settings/feedback` |
| About | About | `/settings/about` |

Every non-trivial settings field has a trailing ℹ info button that opens a modal bottom sheet with a short plain-language explanation. Timer-display, theme, emergency number, PIN timeout, and similar fields include an inline preview strip in addition to the info sheet. Shared widgets: `InfoIconButton` (`lib/core/widgets/info_icon_button.dart`) and `SettingsTile` (`lib/core/widgets/settings_tile.dart`).

**Distress chains are now managed like modes.** The Session section's "Distress chains" row opens the full `DistressChainsScreen` list at `/distress-chains` — add / rename / delete / duplicate / reorder / tap-to-edit. Each entry opens `DistressChainEditorScreen` at `/distress-chains/edit?chainId=...`, which is the same reorderable-step expansion-tile editor used by the Mode editor. A distress chain is a chain like any other; every event-specific configuration (message template, ring duration, emergency number, etc.) is fully editable per-step. The first chain in the list is the default used by any mode whose `distressChainId` is null. The former single `/settings/distress-chain` screen is removed.

---

## Settings Screen Layout

The main settings screen shows only Theme + Language, then a list of tappable subcategory rows. Details for each subcategory are below.

### General Section

Displays system-level settings that affect the entire app.

#### Theme
- **Options:** Dark / Light / System (default)
- **Control:** Radio buttons or toggle switch
- **Default:** System (B6 — follows OS setting)
- **Effect:** Rebuilds all screens with selected theme data
- **Persistence:** `AppSettings.themeMode` (string: "light", "dark", "system")

#### Language
- **Options:** English (en), German (de), Spanish (es), French (fr), Russian (ru), Chinese Simplified (zh), Chinese Traditional (zh_TW), Hindi (hi), Farsi (fa), Ukrainian (uk), Polish (pl), Greek (el), Arabic (ar), Hebrew (he) — 14 languages total
- **RTL support:** Farsi (fa), Arabic (ar), Hebrew (he)
- **Default:** Follows system language if available; defaults to English
- **Control:** Dropdown/segmented picker showing language names in their native script (not codes)
- **Effect:** Rebuilds app with new locale; `flutter gen-l10n` generated classes automatically used
- **Persistence:** `AppSettings.languageCode` (e.g., "en", "de", "fr", "es", "ru", "zh", "fa", "ar")

#### Log GPS with Events

GPS logging is a structured `GpsLoggingConfig` in `AppDefaults` (Settings → Defaults → GPS Logging). The General section links to the Defaults submenu.

See **Defaults Submenu → GPS Logging** below for the full configuration.

---

### Stealth Mode Section

Stealth mode is a structured `StealthConfig` managed as part of `AppDefaults.stealth`. Individual modes can override via `ModeOverrides.stealth`. Stealth mode is independent of PIN settings — a user may enable stealth without PIN or PIN without stealth.

This section is a **collapsible card directly on the main settings screen** (not a separate sub-screen). The collapsed state shows a summary line; expanding it reveals all `StealthConfig` fields inline.

**Collapsed state (default):**
- **Summary line:** "Stealth: OFF" or "Stealth: ON (3 options configured)"
- Tap to expand

**Expanded state shows all `StealthConfig` fields inline:**

| Field | Control | Default | Description |
|-------|---------|---------|-------------|
| **enabled** | Toggle switch | false | Master toggle — hides all safety indicators ℹ |
| **fakeName** | Text field (shown when enabled) | — | Fake app name in notifications and app switcher ℹ |
| **fakeIcon** | Toggle switch (shown when enabled) | false | Show generic icon instead of Guardian Angela logo ℹ |
| **notificationDisguise** | Toggle switch (shown when enabled) | false | Use generic notification channel name/icon ℹ |
| **timerDisplay** | 3-option selector: Normal / Small / None (shown when enabled) | Normal | Session timer visibility during session ℹ |
| **sessionScreenStealth** | Toggle switch (shown when enabled) | false | Remove Guardian Angela branding from session screen ℹ |

The sub-options (`fakeName`, `fakeIcon`, `notificationDisguise`, `timerDisplay`, `sessionScreenStealth`) are shown only when `enabled` is ON. When `enabled` is OFF, the section collapses to just the enabled toggle and the summary line.

**Info tooltips:**
- `enabled`: "Hides safety indicators. Useful if you don't want others to see you're using a safety app."
- `fakeName`: "App appears under this name in notifications and the app switcher."
- `fakeIcon`: "App uses a generic icon (e.g., calendar or fitness) instead of the Guardian Angela logo."
- `notificationDisguise`: "Notifications use a generic channel name like 'Reminders' or 'Updates'."
- `timerDisplay`: "Normal = timer at top. Small = clock-style in corner. None = hidden."
- `sessionScreenStealth`: "Removes Guardian Angela branding (logo, name) from the session screen."

Modes can override via `ModeOverrides.stealth`. The Defaults submenu (`/settings/defaults`) no longer contains a separate Stealth sub-screen — stealth is configured entirely from this collapsible section.

---

### Security Section (`/settings/security`)

Three independent PINs — all configured in **Settings → Security**. Each PIN has a dedicated setup screen (`/settings/pin-setup?type=...`).

Every non-trivial option in this section has an ℹ info button opening a bottom sheet explanation.

#### Session Locks (During Active Session)

The following actions are blocked during an active session to prevent data corruption or loss of safety context:

- **Contact deletion** — Blocked. Deleting a contact mid-session means escalation steps cannot find a recipient.
- **Mode editing** — Blocked. Editing a mode mid-session could break the running session logic.
- **Backup import** — Blocked. Importing data would overwrite the current session state.
- **Language change** — Blocked. Takes effect on next session start.
- **Prompt shown:** "End your current session to access this setting."

Users can modify settings freely when no session is active.

#### PIN Length — per-PIN, determined at setup

The shared global PIN length has been **removed**. Each PIN's length is now determined at setup time: the user types any number of digits between `kPinMinLength` (4) and `kPinMaxLength` (8) and taps Submit. The PIN entry dialog (`PinEntryDialog`) hashes the input on every keystroke starting at length 4 and auto-submits as soon as the hashed value matches the stored PIN or duress PIN. As a result, the app PIN, session-end PIN, and duress PIN may all have different lengths.

`AppSettings.pinLength` no longer exists. Legacy JSON with a `pinLength` key is ignored on load — this is a one-way schema change (no migration required because schema mismatches trigger a reseed per spec).

#### App PIN
- **Label:** "App PIN" ℹ
- **Info:** "Locks the app each time you open it. Anyone picking up your phone cannot see Guardian Angela without this PIN."
- **Control:** "Set PIN" / "Change PIN" / "Remove" button
- **Options:** Length chosen at setup (4–8 digits). Disabled by default.
- **Persistence:** `AppSettings.appPinHash` (hashed, stored in Hive)
- **Effect:** All app screens require PIN entry on launch.

#### Session End PIN
- **Label:** "Session End PIN" ℹ
- **Info:** "Required to disarm or manually end a running session. Prevents an attacker from stopping escalation. Times out after 15 seconds — if no PIN is entered, the session continues."
- **Control:** "Set PIN" / "Change PIN" / "Remove" button
- **Timeout:** Configurable slider (5–120s, default 15s)
- **Biometric:** Toggle "Biometric for session end" — when enabled, the session-end PIN prompt first shows the device biometric (fingerprint / Face ID) and only falls back to the PIN keypad on cancel, failure, or absence. Preference stored in `SharedPreferences` under `biometric_for_session_end` (default `false`); see `lib/core/utils/biometric_prefs.dart`. Callers wire up the hook via `promptBiometricThenPin(...)`.
- **Persistence:** `AppSettings.sessionEndPinHash` + `AppSettings.pinTimeoutSeconds`. Biometric toggle kept outside `AppSettings` to avoid schema churn.
- **Effect:** Disarm and manual session end require PIN entry (or biometric) with timeout.
- **Note:** Biometric may substitute for Session End PIN. It may NOT substitute for App PIN or Quick Exit (fingerprint can be forced from unconscious user).

#### Duress PIN
- **Label:** "Duress PIN" ℹ
- **Info:** "A secret PIN that appears to end the session but silently fires your selected distress chain. Use when forced to show your phone — the attacker sees 'Session ended' while help is on the way."
- **Control:** "Set PIN" / "Change PIN" / "Remove" button
- **Validation:** Must differ from both App PIN and Session End PIN
- **Setup flow (first-time):**
  1. Enter new duress PIN
  2. Confirm duress PIN
  3. **Preview:** Shows mock "Session ended" screen — "This is what the attacker sees. Behind this screen, your distress chain fires silently."
  4. Optionally navigate to Distress Chains to configure what happens (or accept defaults)
- **Where it works:** Any PIN prompt (App lock, Session End)
- **Behavior when entered:**
  - Shows fake "Session ended" to attacker
  - Fires the mode's selected `DistressChain` silently
  - Session logs record duress PIN entry with timestamp
- **Persistence:** `AppSettings.duressPinHash`
- **Default:** Disabled

#### Wrong PIN Behavior
- **Label:** "Wrong PIN attempts before escalation" ℹ
- **Info:** "After N wrong attempts, the deceptive 'Old pin entered' dialog appears, then your distress chain fires silently."
- **Control:** Slider (range 2–10, default 5)
- **Behavior:** After N consecutive wrong PIN entries:
  - Show deceptive dialog: "Old pin entered — are you sure you want to proceed?"
  - This deliberately misleads the attacker into thinking a previous PIN was entered
  - Regardless of attacker's choice, the selected distress chain fires silently
  - Reset attempt counter
- **Note:** All three PIN prompts share the same attempt counter. Counter resets on any correct PIN entry.

Both the duress PIN and wrong-PIN threshold fire the mode's selected `DistressChain` from the global list in `AppDefaults.distressChains`. See **Settings → Session → Distress chains** (`/distress-chains`) for the full list and editor.

---

### Battery Alert Section (`/settings/battery-alert`)

Optional low-battery one-shot alert. Battery alert is a one-shot SMS alert that does not pause the main session.

#### Enable Battery Alert
- **Label:** "Send alert if battery is low" ℹ
- **Info:** "When battery drops below the threshold during a session, sends a one-shot SMS to your emergency contacts. Fires once per session and does not pause the session."
- **Control:** Toggle switch
- **Default:** OFF
- **Persistence:** `BatteryAlertConfig.enabled`

#### Battery Threshold (If Enabled)
- **Label:** "Battery level for alert" ℹ
- **Control:** Slider with percentage display
- **Range:** 5–50% (default 10%)
- **Real-time display:** "10%"
- **Persistence:** `BatteryAlertConfig.thresholdPercent`
- **Behavior:** If battery drops below threshold during an active session, fires once per session.

#### Configure chain (If Enabled)
- **Label:** "Battery alert chain" ℹ
- **Info:** "The escalation chain that fires when the battery drops below the threshold. Edited with the same step-tile UI used by the mode editor."
- **Control:** Inline reorderable chain editor (add / remove / reorder / edit steps) with a "Reset to default" action. Only action step types are offered (no check-in types — battery alert is triggered, not held).
- **Default:** Single `smsContact` step targeting all emergency contacts (see seed data).
- **Persistence:** `BatteryAlertConfig.chain: List<ChainStep>`
- **Screen:** Embedded in `/settings/battery-alert` (see `battery_alert_screen.dart`).

---

### Emergency Number (Extra 25)

The emergency services number is a free-form text field so users can
configure country-specific short codes (112, 911, 999, etc.) or
carrier-specific variants.

- **Input:** Editable dialog triggered from Settings → Emergency
- **Validator:** Non-blocking. Implemented in
  `lib/core/utils/phone_validators.dart` as
  `PhoneValidators.warnEmergencyNumber`. Also used by the contact
  form (Extra 26) via `warnContactNumber` for per-contact fields.
- **Allowed characters:** digits 0-9, `+`, `*`, `#`. Any other
  character (letters, hyphens, spaces, parentheses) emits a
  non-blocking warning below the input.
- **Length guidance:**
  - Too short (< 3 digits): warn "Emergency numbers are usually at
    least 3 digits."
  - Too long (> 6 digits): warn "This looks like a regular phone
    number, not an emergency services number."
  - Empty input: blocks Save until non-empty.
- **Persistence:** `AppSettings.emergencyCallNumber`
- **Session lock:** Cannot be changed during an active session.
- **Scope — global default:** This setting is the **global default**. Individual `callEmergency` steps may override it via `CallEmergencyConfig.emergencyNumber` (see `02-event-types.md §9`). When a step's override is `null` or empty the strategy falls back to this global value; when the step override is non-empty it takes precedence for that step only. Use per-step overrides for travel modes or regional escalation chains instead of changing the global number.

---

### Alarm Section

Global alarm behavior (affects all loudAlarm steps).

#### Override Silent Mode / Do Not Disturb
- **Label:** "Alarm overrides silent/vibrate mode"
- **Control:** Toggle switch
- **Default:** ON
- **Persistence:** Custom AppSettings field (e.g., `alarmOverrideSilentMode`)
- **Effect:** When enabled, loudAlarm event plays at max volume even if phone is on silent or vibrate. On Android, uses the `STREAM_ALARM` audio stream to bypass Do Not Disturb.
- **Note:** Alarm is the ONLY event type that can override phone settings
- **Warning (if toggle is OFF):** "Warning: Alarm will be silent if phone is on silent mode"

#### Gradual Volume Increase
- **Label:** "Gradually increase alarm volume"
- **Control:** Toggle switch
- **Default:** ON
- **Persistence:** Custom AppSettings field (e.g., `alarmGradualVolume`)
- **Effect:** Affects all loudAlarm steps; overridden per-step if configured differently

#### Gradual Volume Duration (If Gradual Volume is ON)
- **Label:** "Ramp duration"
- **Control:** LogarithmicSlider (range 5–30 seconds, default 10s)
- **Real-time display:** "10s" or "30s" with unit suffix
- **Persistence:** Custom AppSettings field (e.g., `alarmGradualVolumeDuration`)
- **Effect:** Time to reach full volume from zero; linear ramp over this duration
- **Note:** Longer ramps are less startling but slower to reach full volume

---

### Navigation Links (Bottom of Settings Screen)

#### Profile → /profile
- Label: "Profile"
- Icon: user avatar or person icon
- Leads to user profile screen (name, physical description)

#### Feedback → /settings/feedback
- Label: "Send Feedback"
- Icon: speech bubble or mail
- **Primary:** Opens pre-filled GitHub Issue in browser via `feedback` package (screenshot annotation optional, no backend needed, privacy-safe)
- **Secondary:** `mailto:` link via `url_launcher` as fallback for users who prefer email
- No third-party analytics or telemetry services (privacy-critical safety app)

#### Redo Onboarding → (action)
- Label: "Redo Onboarding"
- Icon: refresh or tutorial
- Action: Clears `isFirstLaunch` flag and navigates to onboarding flow
- Confirmation: "This will reset your setup. Continue?"

#### Backup & Export
- Label: "Backup & Data"
- Icon: cloud or archive
- Navigation: `/settings/backup`
- Screen includes:
  - Export session logs (JSON / PDF)
  - Import session logs (from JSON file)
  - Manual backup creation (with optional encryption password)
  - Restore from backup
  - Data usage summary

#### Session Log Trash (Extra 11)
- Accessible from the trash icon in the `/past-events` app bar, not a settings row.
- Soft-deleted logs are kept in the repository with a tombstone recorded in `SharedPreferences` (`session_log_tombstones`).
- Tombstones older than `sessionLogRetentionDuration` (7 days) are hard-deleted on Past Events screen open and on `HistoryController` build.
- Per-entry actions in the Trash screen: Restore (clears the tombstone) and Delete Permanently (hard-delete + tombstone cleanup).
- "Clear All" on the Past Events screen bypasses Trash and wipes the repository plus every tombstone.

#### About → /settings/about
- Label: "About Guardian Angela"
- Icon: info or circle
- Leads to about screen (see "About Screen" section below)

#### Settings Version
- Display app version at bottom of settings screen (e.g., "v0.1.0")
- Format: Semantic versioning (MAJOR.MINOR.PATCH)

---

## Save Behavior

### Simple Toggles & Single-Field Settings

- **Auto-save:** Changes saved to Hive immediately on toggle/selection
- **Feedback:** Brief undo snackbar appears: "Setting changed" with optional "Undo" button
- **No confirmation:** User can undo within 3 seconds before actual persistence

### Complex Editors (Mode Editor, Duress Chain, Event Defaults)

- **Explicit save button:** All edits are in-memory until "Save" button pressed
- **Unsaved changes warning:** If user navigates away without saving, show dialog: "Discard unsaved changes?" with "Discard" / "Keep Editing" options
- **Confirmation after save:** Brief snackbar: "Changes saved"
- **Cancel button:** Reverts in-memory changes and navigates back

---

## Event Defaults (Global Config for All Steps)

Located at `/settings/event-defaults`. This screen displays editable global defaults for all 9 step types. When a `ChainStep` in a mode doesn't specify config, these defaults apply. Users can "Reset to defaults" per-step in the mode editor.

### Structure

The event defaults screen shows all 9 step types in a list or tabbed interface. Tapping each reveals a detail screen with type-specific configuration options.

### holdButton Defaults

| Option | Default | Type | Range | Description |
|--------|---------|------|-------|-------------|
| **holdStyle** | largeButton | enum | largeButton / fullScreen / fakeLockScreen | Visual style of the hold button |
| **releaseSensitivity** | 1.0 | float | 0.3–3.0 seconds | Time to ignore brief lifts (prevents accidental triggers) |
| **vibrateOnRelease** | true | bool | — | Haptic feedback when countdown begins |
| **soundOnRelease** | false | bool | — | Play warning sound when countdown begins |
| **blackScreenMode** | false | bool | — | Black screen that mimics locked phone; screen stays on so hardware buttons remain active |

**UI Notes:**
- Release sensitivity: LogarithmicSlider with real-time display (e.g., "0.5s", "1.5s")
- Info icon on releaseSensitivity explains jitter and accidental trigger prevention

### disguisedReminder Defaults

| Option | Default | Type | Description |
|--------|---------|------|-------------|
| **randomizeInterval** | true | bool | Add ±20% jitter to reminder wait time |
| **randomizeTemplateOrder** | true | bool | Pick random template each cycle (prevents pattern) |
| **blackScreenMode** | false | bool | Black screen that mimics locked phone during disguised reminder |

**UI Notes:**
- ± randomize toggles: filled teal badge (active) vs outlined grey (inactive)
- Info icon explains randomization prevents predictable patterns

### countdownWarning Defaults

| Option | Default | Type | Range | Description |
|--------|---------|------|-------|-------------|
| **style** | fullScreen | enum | fullScreen / notification / minimal | Visual presentation |
| **vibrate** | true | bool | — | Vibration pattern during countdown |
| **sound** | false | bool | — | Warning audio cue |

### fakeCall Defaults

| Option | Default | Type | Description |
|--------|---------|------|-------------|
| **callStyle** | android (on Android) / ios (on iOS) | enum | android / ios / whatsapp / telegram / signal — platform-native appearance |
| **callerName** | Angela | string | Name displayed on call screen |
| **callerPhotoPath** | (empty) | string | Optional contact photo (asset path or file URI) |
| **voiceRecordingPath** | (empty) | string | Optional custom voice message (file path; if empty, uses built-in language-specific greeting) |
| **voiceOutputMode** | earpiece | enum | earpiece (private) / speaker (audible to others) |
| **ringDurationSeconds** | 30 | int | Seconds the call "rings" (0–120) |
| **declineIsSafe** | true | bool | Whether declining the fake call counts as disarm or triggers grace period |

**UI Notes:**
- Voice recording management: record in-app (max 2 min) or pick from files
- LogarithmicSlider for ringDurationSeconds with real-time display (e.g., "30s", "1m 30s")
- Info icon on declineIsSafe explains behavior difference
- Info icon on voiceOutputMode notes privacy vs audibility trade-off

### smsContact Defaults

| Option | Default | Type | Description |
|--------|---------|------|-------------|
| **messageTemplate** | "Automated safety alert from Guardian Angela.\n{name} may need help.\nLast known location: {location}\nTime: {time}" | string | Fully customizable message with placeholders |
| **includeLocation** | true | bool | Attach Google Maps URL with GPS coordinates |
| **autoRecordAudio** | false | bool | Automatically start audio recording when step fires |
| **autoRecordVideo** | false | bool | Automatically start video recording (future feature) |
| **recordDurationSeconds** | 30 | int | Max duration for auto-recording (5–120) |

**UI Notes:**
- Message template editor: expandable text area with placeholder buttons ("Add {name}", "Add {location}", "Add {time}", "Add {description}") that insert at cursor
- Info icon on includeLocation explains that this creates a shareable maps link
- Info icon on autoRecordAudio: "Check local recording laws before enabling"
- Legal warning box: "Recording laws vary by jurisdiction. You are responsible for compliance."
- **Contact selection (per-step):** Inside any `smsContact` step config (in the Mode editor, Distress Chain editor, or Battery Alert editor) the former "All / First only / Specific" dropdown is replaced by a **grid of one clickable button per emergency contact**. Contacts whose `messageChannels` include SMS are enabled and default to ON for a new step; contacts without SMS as a channel render disabled and grayed out (cannot be toggled). At save time, an all-enabled selection maps to `SmsRecipient.allContacts`; a strict subset maps to `SmsRecipient.specificIds`. See **`04-screens-navigation.md` → SMS Contact Selection** for the full widget spec, and **`03-data-models.md`** for the model-level save-time inference contract.

### phoneCallContact Defaults

| Option | Default | Type | Description |
|--------|---------|------|-------------|
| **callChannel** | phone | enum | phone (tel: URI; WhatsApp/Telegram removed — cannot initiate calls via deep link) |
| **preSendSms** | true | bool | Send brief SMS before calling |
| **preSmsMessage** | "I may be in danger, calling you now" | string | SMS text (with placeholders: {name}, {location}, {time}) |
| **preSmsIncludeLocation** | true | bool | Include location URL in pre-SMS |
| **retryCount** | 1 | int | How many times to retry if no answer (0–5) |
| **alternativeContactIds** | (empty) | string | Comma-separated fallback contact IDs |

**UI Notes:**
- LogarithmicSlider for retryCount with real-time display
- Info icon on preSendSms explains contact will be forewarned
- preSmsMessage editor with placeholder buttons

### loudAlarm Defaults

| Option | Default | Type | Range | Description |
|--------|---------|------|-------|-------------|
| **volume** | 1.0 | float | 0.0–1.0 | Alarm volume level (0 = silent, 1 = max) |
| **soundChoice** | siren | enum | siren / whistle / scream / custom | Built-in or user-provided sound |
| **customSoundPath** | (empty) | string | File path to user's custom alarm sound |
| **flashLight** | false | bool | Strobe camera flashlight (SOS morse pattern) |
| **flashScreen** | false | bool | Flash screen white/red alternately |
| **flashSpeed** | medium | enum | fast (300ms) / medium (500ms) / slow (1000ms) — 3-option enum (B5) |
| **gradualVolume** | true | bool | Inherited from global Alarm section setting |
| **gradualVolumeDuration** | 10 | int | Inherited from global Alarm section setting |

**UI Notes:**
- Volume slider (0.0–1.0) with percentage display (0%–100%)
- Sound choice: radio buttons or dropdown
- Custom sound upload/file picker (if soundChoice = custom)
- Photosensitivity warning: shown when flashScreen is enabled
- Preview button: plays alarm at current settings for 3 seconds with "Stop" button
- Info icon on flashLight explains SOS pattern

### callEmergency Defaults

| Option | Default | Type | Range | Description |
|--------|---------|------|-------|-------------|
| **emergencyNumber** | 112 (locale-dependent; 911 for US, etc.) | string | Configurable emergency number for this region |
| **sendLocationSmsFirst** | true | bool | Send SMS to emergency services before calling |
| **showConfirmation** | true | bool | Show countdown before dialing (gives user last chance to cancel) |
| **confirmationDurationSeconds** | 5 | int | Countdown duration (1–30 seconds) |

**UI Notes:**
- Emergency number: dropdown with 80+ country presets + manual entry field
- Warning: "SMS to emergency services may not work in your country"
- LogarithmicSlider for confirmationDurationSeconds with real-time display
- Info icon on showConfirmation: "Confirmation countdown allows cancellation if triggered accidentally"
- Note: In production version, this defaults to ON (changed from false in spec)

**Emergency Call Disarm Confirmation:** When disarming during an emergency call countdown, a confirmation dialog is shown: "Are you sure? The emergency call will NOT be made." This prevents accidental disarm of a critical step.

### hardwareButton Defaults

| Option | Default | Type | Range | Description |
|--------|---------|------|-------|-------------|
| **buttonType** | volumeUp | enum | volumeUp / volumeDown | Which physical device button to use |
| **pressPattern** | repeatPress | enum | repeatPress (rapid presses) / longPress (sustained hold) | How to press the button |
| **pressCount** | 5 | int | 2–10 (repeatPress only) | Number of rapid presses needed — default 5 (B1) |
| **longPressDurationSeconds** | 2.0 | float | 1.0–10.0 (longPress only) | Sustained hold duration required |
| **targetStepIndex** | -1 | int | Negative index: -1 = escalate immediately; 0+ = jump to specific step |
| **blackScreenMode** | false | bool | Future: black screen during button detection |

**UI Notes:**
- Button type, press pattern: radio buttons or dropdowns
- Conditional display: pressCount slider appears only if pressPattern = repeatPress; longPressDurationSeconds appears only if pressPattern = longPress
- LogarithmicSliders with real-time display
- Test/Preview button: "Test Hardware Button" — shows simulation UI with "Button press detected!" feedback when user presses physical button
- Info icon on targetStepIndex explains escalation behavior
- Note: hardwareButton is an Android-only feature; iOS controls greyed out with explanation

---

## Defaults — separate screens per category (no combined hub)

Per the top-level restructuring, `/settings/defaults` has been removed. Each category of `AppDefaults` is now its own dedicated screen, linked directly from the Settings hub under the "Defaults" section. This makes each screen self-contained and avoids a deep two-level hub.

| Defaults category | Dedicated screen | Route |
|-------------------|------------------|-------|
| GPS logging | `GpsLoggingSettingsScreen` | `/settings/gps-logging` |
| Event defaults (per-step-type) | `EventDefaultsScreen` | `/settings/event-defaults` |
| Reminder templates | `TemplatesScreen` | `/settings/reminder-templates` |
| Distress chains (list + editor) | `DistressChainsScreen` / `DistressChainEditorScreen` | `/distress-chains`, `/distress-chains/edit?chainId=...` |
| Stealth | `StealthSettingsScreen` | `/settings/stealth` |

The model surface (`AppDefaults`) is unchanged. Only the navigation/UI surface has been restructured.

### GPS Logging (`/settings/defaults/gps-logging`)

Configures `AppDefaults.gpsLogging` (`GpsLoggingConfig`). Every non-trivial option has an ℹ info button.

| Option | Default | Type | Description |
|--------|---------|------|-------------|
| **enabled** | true | bool | Master toggle — log GPS during sessions ℹ |
| **intervalSeconds** | 30 | int | How often to log position (10–3600s) ℹ |
| **accuracy** | high | enum | high / balanced / low ℹ |
| **format** | decimal | enum | decimal / dms / address — how coordinates are displayed ℹ |
| **includeInSms** | true | bool | Append location URL to SMS steps ℹ |
| **historyRetentionDays** | 30 | int | How long GPS track history is kept ℹ |

**Info tooltips:**
- `enabled`: "Location is recorded during sessions to include in emergency messages and session logs."
- `intervalSeconds`: "How often your position is recorded. More frequent = better accuracy but higher battery drain."
- `accuracy`: "High = uses GPS chip (most accurate, more battery). Balanced = combines GPS and cell towers. Low = cell towers only."
- `includeInSms`: "When a step sends an SMS, the current location is appended as a Google Maps link."
- `historyRetentionDays`: "GPS tracks are automatically deleted after this many days."

Modes can override via `ModeOverrides.gpsLogging`.

### Stealth

Stealth configuration is handled by the collapsible **Stealth Mode Section** directly on the main settings screen — there is no separate `/settings/defaults/stealth` sub-screen. See **Stealth Mode Section** above for all `StealthConfig` fields and their controls.

Modes can override via `ModeOverrides.stealth` (accessible in the mode editor's Safety Options section).

### Distress Chains (list + editor)

Distress chains are managed as a list, mirroring the Modes pattern. The Session section's "Distress chains" row navigates to `DistressChainsScreen` at `/distress-chains`; tapping any entry opens `DistressChainEditorScreen` at `/distress-chains/edit?chainId=...`. The list supports add / rename / delete / duplicate / reorder and tap-to-edit. The editor is the same expansion-tile step editor used by the Mode editor, with full per-step event configuration (timing, event-specific fields, randomization jitter, retry count) for every distress-compatible step type (`smsContact`, `phoneCallContact`, `loudAlarm`, `callEmergency`, `countdownWarning`, `fakeCall`).

- **Label (Session section row):** "Distress chains" ℹ
- **Info:** "The distress chain used when a mode doesn't specify one, or when the hardware panic button fires. Tap to manage all chains — add, rename, reorder, or fully edit each one's escalation steps."
- **Default chain:** The first chain in the list. Mode pickers default to "Use default (first in list)" when `distressChainId` is null.
- **Per-mode selection:** Each `SessionMode` picks its distress chain by id in the mode editor's Safety Options section (see `04-screens-navigation.md` → Mode Editor → Safety Options).

See `04-screens-navigation.md` for full screen specs of `DistressChainsScreen` and `DistressChainEditorScreen`.

### Reminder Templates

Global `AppDefaults.templates` are managed on a dedicated screen at
`/settings/reminder-templates` (`TemplatesScreen`). The Event Defaults
screen has no templates section — that screen is strictly per-step-type
timing + config defaults.

Access:
- Directly from **Settings → Reminder Templates** (top-level entry).
- From the **DisguisedReminder event form** inside the mode editor via
  the "Manage reminder templates" link (so a user editing a disguised
  reminder step can jump straight into template management without
  leaving their workflow).

Modes can add mode-local templates via `ModeOverrides.localTemplates`
(appended to these globals). The Template Editor is a dedicated screen
navigated from the list.

### Event Defaults (`/settings/defaults/event-defaults`)

Manages `AppDefaults.eventDefaults` (`EventDefaults`). Accessible at `/settings/defaults/event-defaults`.

See **Event Defaults (Global Config for All Steps)** below for the per-type configuration options. These have not changed in structure — only their location in the navigation hierarchy has moved from `/settings/event-defaults` to `/settings/defaults/event-defaults`.

---

## Info Tooltips (All Event Default Screens)

Every non-obvious config option displays an (i) icon. Tapping shows tooltip text:

| Option | Tooltip Text |
|--------|-------------|
| Randomize | Adds ±20% variation so timing doesn't feel robotic or predictable |
| Release sensitivity | How long you must release the button before the grace period starts. Prevents accidental triggers from brief lifts. |
| Include location | Attaches a Google Maps URL with your GPS position so your emergency contact can find you |
| Auto-record | Automatically starts recording when this step fires. Recording is stored locally. Check local recording laws. |
| Pre-send SMS | Sends a brief text before calling, so your contact knows to pick up immediately |
| Decline is safe | Whether declining a fake call counts as confirming you're OK. If ON, declining resets the chain. If OFF, the call rings again. |
| Voice output | Whether voice recording plays through earpiece (private) or speaker (audible to others nearby). Speaker lets them know you called for help. |
| Flash light | Rapidly flashes camera flashlight in SOS morse pattern to attract attention from bystanders |
| Show confirmation | Shows countdown before dialing, giving you a last chance to cancel if triggered accidentally |
| Stealth mode | Hides all safety indicators so the app is invisible to others. Notification appears disguised. No end screen shown. |
| Override silent mode | When enabled, alarm plays at full volume even if phone is on silent or vibrate. Alarm is the only event that can override. |
| Gradual volume | Volume increases gradually from zero instead of starting at maximum. Less startling but slower to reach full alertness. |
| Battery threshold | When battery drops below this percentage during a session, send alert to emergency contacts and record location. Helps rescuers find you. |
| Wrong PIN attempts | Number of incorrect PIN attempts before triggering a safety escalation. Prevents attackers from repeatedly guessing your PIN. |
| Duress PIN | A secret PIN that appears to end the session but actually triggers escalation. Used if forced to unlock phone. |

---

## Reminder Templates

Accessible from Settings → Reminder Templates (route `/settings/reminder-templates`)
and from the DisguisedReminder event form in the mode editor (via the
"Manage reminder templates" link).

### Overview

Users view, edit, duplicate, delete, and create reminder templates. The
list UX mirrors the Modes screen — a FAB opens a create bottom sheet
with two options:

- **From template** — opens a sub-sheet listing the 8 built-in templates;
  picking one creates a new custom template pre-filled with that
  template's fields, suffixed " (Copy)" in its name. Opens the editor on
  the new copy so the user can rename/adjust.
- **From scratch** — opens the blank template editor directly.

Built-in templates (`isCustom = false`) cannot be deleted. Custom
templates (`isCustom = true`) can be duplicated or deleted via a popup
menu on each tile; deletion shows a confirmation dialog. Built-in
templates still show the Delete menu item, but it's disabled with a
tooltip ("Built-in templates cannot be deleted").

### Built-in Templates Table

| # | Name | Display Style | Confirmation Type | Keyword / Button |
|---|------|---------------|-------------------|-----------------|
| 1 | Calendar Event | fullScreen | tapButton | "Dismiss" |
| 2 | Language Lesson (Duolingo) | fullScreen | tapWord | "house" (3 word choices) |
| 3 | Delivery Update | subtle | swipe | — |
| 4 | Weather Alert | subtle | tapButton | "OK" |
| 5 | Fitness Reminder | fullScreen | tapButton | "Skip" |
| 6 | Message Preview | fullScreen | tapButton | "Reply" |
| 7 | App Update | subtle | tapButton | "Later" |
| 8 | Battery Warning | subtle | swipe | — |

### Template Editor Screen

When editing or creating a template:

- **Template name:** Text input (editable for custom; read-only for built-in)
- **Display style:** Radio (fullScreen / subtle)
- **Confirmation type:** Radio (tapButton / tapWord / swipe / dismiss)
- **Conditional fields:**
  - If tapButton: "Button label" text input
  - If tapWord: "Correct word" + "Word choices (comma-separated, 3 required)" text areas
  - If swipe: no additional fields (swipe direction implied)
  - If dismiss: no additional fields
- **Title & subtitle:** Text inputs (optional subtitle)
- **Body text:** Expandable text area (main notification text)
- **Icon/image:** File picker or asset selector (optional custom icon)
- **Live preview:** Scaled 55% below editor, shows how template looks on device
  - Shows both fullScreen and subtle versions
  - On iOS and Android styles
  - Updates real-time as user edits
- **Save button:** Explicit save for custom templates
- **Delete button:** Only for custom templates; confirmation dialog before deletion
- **Built-in warning:** Message above built-in templates stating "Built-in templates cannot be deleted but can be disabled"

### Template List Screen

Single unified list (no built-in/custom section split). Each template
renders as a Card tile with:

- Leading: circle avatar with the template's icon
- Title: template name, plus a "Template" badge for built-ins
- Subtitle: notification title + body preview (2 lines max)
- Trailing: popup menu with **Edit**, **Duplicate**, **Delete**.
  - Edit: opens the editor.
  - Duplicate: calls `TemplatesController.duplicate(id)` which creates
    a new template with a fresh UUID and the same fields; name is
    suffixed " (Copy)". Opens the editor on the new copy.
  - Delete: custom templates → confirmation dialog → removed.
    Built-in templates → the menu item is disabled with a tooltip
    ("Built-in templates cannot be deleted").

When the list is empty, an empty state renders instead of the list —
an icon, "No templates yet" + a short explanation, and a FilledButton
that triggers the create sheet.

**Info:** "Templates are randomly rotated during disguised reminder
steps (if randomizeTemplateOrder is enabled)"

---

## Wakelock Setting

Wakelock behavior is **not** a configurable setting but rather a consequence of certain choices:

- **fakeLockScreen holdStyle:** Wakelock always active (screen stays on but brightness set near-zero to save battery)
- **Hold button with check-in:** Wakelock only active during hold button phase, disabled during grace/wait phases
- **Normal operation:** Wakelock disabled by default; only activated when session is active and during escalation events
- **User consequence:** For long sessions, mention in UI: "Keeping screen awake may drain battery faster. Consider plugging in for long sessions."

**No explicit wakelock toggle** in settings; it's implicit to mode design.

---

## Session End Confirmation Methods

User can choose how to end a session or quickly exit:

1. **Swipe Confirmation (default):** Swipe slider showing "I'm Safe" and confirmation text
2. **PIN/Biometric (if configured):** If Session End PIN is set, user must enter PIN to end session
3. **Hardware Button:** If hardwareButton is configured in a mode, pressing the physical button can disarm
4. **Quick Exit:** Instantly hide and close the app. Requires Session End PIN (if configured; 15-second timeout). On Android: `finishAndRemoveTask()` removes app from recents. On iOS: decoy screenshot + `exit(0)`. **Session data (logs, GPS coordinates) is PRESERVED in encrypted storage and recoverable when the app is reopened.** Users may need session logs for police reports or restraining orders.

**Configuration location:** Settings > Security section
**Toggle:** "PIN required to manually end sessions" (if enabled, requires entering Session End PIN before disarm works)

**Simulation behavior:** When a simulation ends, the Session End PIN prompt is shown if configured — this lets the user practice the flow. A **"Skip" button** is always available so the PIN is never blocking. Wrong PINs show a shake animation but do NOT increment the failure counter or trigger the distress chain. No biometric in simulation (practice the manual flow). After PIN entry or skip, the Simulation Summary screen is shown. There is no "Start Real Session" button on the summary — the user must return home and start a real session intentionally.

---

## About Screen

Located at `/settings/about`. Displays app information, legal disclaimers, and links.

### Content Layout

#### Logo & App Name
- Display `GuardianAngelaLogo` widget
- App name: "Guardian Angela"
- Tagline: "Your angel's got your back."

#### Version Information
- Application ID: `com.guardianangela.app`
- Current version: e.g., "v0.1.0" (semantic versioning)
- Build number (if applicable)

#### Author & Contact
- Author: Jonas Eschle
- Email: guardian.angela.app@gmail.com
- Clickable email link opens device mail composer

#### External Links (Buttons or Clickable List Items)

| Link | URL | Notes |
|------|-----|-------|
| Privacy Policy | (TBD: hosted URL) | Opens in browser; required before app store submission |
| Terms of Service | (TBD: hosted URL) | Opens in browser; required before app store submission |
| Source Code Repository | (TBD: GitHub URL) | Public or private repo; opens in browser |
| Donation / Support | (TBD: funding page URL) | Optional; opens browser |

#### Open Source Licenses
- Button: "View Open Source Licenses"
- Action: Shows Flutter's built-in `LicensePage()` widget
- Displays all dependencies and their license texts

#### Legal Disclaimers (Collapsible Sections or Tabs)

##### Safety Disclaimer
> **Guardian Angela is not a substitute for emergency services.** Always call emergency services directly (112 in EU/UK, 911 in US, or your local number) when in immediate danger. This app is a supplementary safety tool designed to assist you when you cannot act directly.

##### Recording Laws Warning
> **Audio and video recording laws vary by jurisdiction.** Some places require all parties' consent before recording. Check your local laws before enabling automatic recording features. Guardian Angela does not provide legal advice. You are solely responsible for compliance.

##### Privacy & Data Warning
> All data is stored encrypted on your device. Session logs may be automatically backed up by your platform (iOS iCloud, Android Auto Backup) per platform policies. By using this app, you consent to local encryption and platform-managed backups.

##### Accessibility Statement
> Guardian Angela is designed to be accessible to users with disabilities. If you experience accessibility issues, please report them to guardian.angela.app@gmail.com.

#### Technical Information (Collapsed/Expandable)
- Device model
- OS version
- App version
- Dart/Flutter version (optional)
- Debug mode indicator (if running in debug)

---

## Legal & Compliance Notes

### Before App Store Submission

The following legal documents MUST be completed:

1. **Privacy Policy**
   - Clearly state what data is collected (session logs, GPS, contacts, emergency contact names)
   - Explain local storage and platform backups
   - Explain optional analytics (if enabled in future)
   - Data retention: "Session logs are retained until manually deleted by user"
   - No third-party sharing except emergency contacts (when escalation fires)

2. **Terms of Service**
   - Liability limitations (app is supplementary, not a guarantee of safety)
   - User responsibility for compliance with local recording laws
   - No warranty of uninterrupted service
   - Right to modify app features
   - Acceptable use policy (no misuse for harassment, etc.)

3. **App Store Compliance**
   - **Apple App Store:** Safety apps may require special review; prepare clear documentation of app purpose
   - **Google Play Store:** Same; document all permissions and their purpose
   - Both: Include in-app disclaimers visible during onboarding

4. **Regional Law Review**
   - **UK:** Contact Ask for Angela campaign re: trademark/partnership
   - **EU/GDPR:** Ensure data processing consent and GDPR compliance
   - **US/CCPA:** California Privacy Rights Act compliance if applicable
   - **Recording laws:** Vary by jurisdiction; warn users prominently

### Disclaimers (Always Visible)

- **Onboarding flow:** Show legal disclaimers before allowing app use; require checkbox acknowledgment
- **Settings > About:** Repeat disclaimers in collapsed sections
- **Before SMS/call events:** Show "This will send your location to your emergency contacts" confirmation
- **Before emergency call:** Show "This will dial emergency services" confirmation (unless confirmation countdown is shown)

---

## Data Export / Import

Located at Settings > Backup & Data (`/settings/backup`).

### Export Options

1. **Export Session Logs (JSON)**
   - Format: JSON array of SessionLog objects
   - Includes: timestamps, event timeline, GPS coordinates, duration, mode used
   - Option: Include all or filter by date range
   - File size: ~5–20 KB per 100 sessions
   - User can share/backup outside app

2. **Export Session Logs (PDF)**
   - Generates human-readable PDF with tables and location maps
   - Includes all session details formatted for printing/sharing
   - File size: ~100–200 KB per 100 sessions

3. **Manual Backup**
   - Creates encrypted backup of entire app database (all settings, modes, logs, contacts)
   - User can set optional encryption password
   - File format: `.guardianangela.bak` (proprietary encrypted format)
   - User can store on cloud or external storage

### Import Options

1. **Import Session Logs (JSON)**
   - User selects JSON file
   - App merges logs with existing logs (no duplicates)
   - Confirmation: "Imported N sessions"

2. **Restore from Backup**
   - User selects `.guardianangela.bak` file
   - If encrypted, prompt for password
   - Confirmation: "This will replace all current data. Continue?" with undo option
   - Overwrites entire Hive database with backup contents

### Data Usage Summary

Display below import/export buttons:
- Number of stored session logs
- Total storage size (MB)
- Date of oldest/newest session
- Number of saved modes
- Number of emergency contacts
- Encryption status: "Your data is encrypted with AES-256"

---

## Advanced Settings (Future)

Placeholder section for planned advanced features:

- **Sim card detection:** Alert if SIM card changed (stolen phone detection)
- **Geofencing:** Trigger escalation if user leaves designated safe zones
- **Panic word:** Trigger escalation by saying specific phrase (voice detection)
- **Timezone management:** For frequent travelers
- **Integration with wearables:** Receive check-ins on smartwatch
- **Cloud sync (opt-in):** Optionally sync encrypted backups to cloud

---

## Persistence & Data Model

All settings stored in encrypted Hive database:

**Primary model:** `AppSettings` (typeId 9)

```dart
@HiveType(typeId: 9)
class AppSettings extends HiveObject {
  // Theme & Language
  bool isDarkTheme;              // "light", "dark", or "system"
  String languageCode;           // "en", "de", "fr", "es", "ru", ...

  // Three PIN hashes (null = disabled)
  String? appPinHash;            // App lock PIN
  String? sessionEndPinHash;     // Session disarm/end PIN (biometric may substitute)
  String? duressPinHash;         // Duress PIN — fires distress chain silently
  int pinTimeoutSeconds;         // default 15

  // GPS and Stealth consolidated into AppDefaults
  AppDefaults defaults;          // GPS logging, stealth, templates, event defaults, distress chains

  // Alarm Behavior
  bool alarmOverrideSilentMode;  // default: true
  bool alarmGradualVolume;       // default: true
  int alarmGradualVolumeDuration; // default: 10 seconds

  // Battery Alert
  BatteryAlertConfig? batteryAlert; // null = disabled

  // Other fields...
}
```

**Security settings** all live in `AppSettings` (encrypted in Hive via HiveAesCipher).
PIN hashes stored as bcrypt hashes. No separate `flutter_secure_storage` entries for PINs.

**Distress chains:** Stored in `AppDefaults.distressChains` (List of `DistressChain` objects).
First in list = default. Managed via Settings → Session → Distress chains (`DistressChainsScreen` at `/distress-chains`); each chain is edited in `DistressChainEditorScreen` at `/distress-chains/edit?chainId=...`.

**Reminder templates:** Stored in `AppDefaults.templates` (global) and
`SessionMode.overrides.localTemplates` (mode-local, appended to global).

---

## Screens & Routes Summary

| Route | Purpose | Persistence |
|-------|---------|-------------|
| `/settings` | Main settings screen | AppSettings |
| `/settings/backup` | Export/import/backup | File I/O |
| `/settings/about` | App info, legal, links | None (read-only) |
| `/profile` | User profile (name, description, contacts) | UserProfile (typeId X) |
| `/modes` | List of session modes | SessionMode (typeId 8) |
| `/distress-chains` | List of global distress chains | AppDefaults.distressChains |
| `/distress-chains/edit?chainId=...` | Distress chain editor (full step editor) | AppDefaults.distressChains |

---

## Future Considerations

### Planned Features (Not in Current Spec)
- Cloud sync with E2E encryption
- Wearable integration (smartwatch check-ins)
- Voice command check-ins
- Panic word detection
- Integration with emergency dispatch systems
- Advanced analytics dashboard (opt-in)

### Accessibility & Localization
- All labels translated via ARB files
- High contrast mode toggle
- Font size override
- Screen reader optimizations
- Voice control support

### Performance & Security
- Settings screen lazy-loads event defaults (only loaded when tab accessed)
- PIN entry validated with rate limiting
- Brute force protection via wrong PIN threshold
- Security audit logging (optional, for transparency)

---

**Document Status:** Complete settings specification for Guardian Angela v0.x  
**Last Updated:** 2026-04-02  
**Author:** Documentation Team  
**References:** CLAUDE.md project guidelines, spec/00-overview.md, spec/02-event-types.md, spec/03-data-models.md
