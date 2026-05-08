> **Normative status:** This document is NORMATIVE. In case of conflict
> with any other document (decisions log, audits, reviews), this document
> takes precedence. Key words "MUST", "SHOULD", "MAY" follow RFC 2119.

# 03 - Data Models Specification

> **Pivot 3 — distress is a Mode.** `DistressChain` no longer exists.
> Distress modes are persisted as `SessionMode`s with
> `isDistressMode = true`. `SessionMode.distressModeId` references
> another mode by id. The `distress_chains` table / DAO / repository
> have been deleted; pre-alpha policy is nuke-and-reseed on schema
> mismatch.
>
> **Storage backend.** Persistence uses JSON-backed repositories
> (`JsonSingletonRepository`, `JsonListRepository`) — each model is
> serialized to a JSON string keyed by id. The `@HiveType` /
> `@HiveField` annotations below are kept for historical context but
> the runtime no longer uses Hive. Models live in `lib/domain/models/`
> with hand-rolled `toJson`/`fromJson`.

Guardian Angela's data models are built on **Hive CE** (Community Edition), a lightweight local NoSQL database optimized for mobile. All persistent data is encrypted at rest and supports automatic cloud backup on both Android and iOS.

## Storage Architecture

### Hive CE (Local NoSQL)

Hive CE provides fast, type-safe key-value storage with minimal overhead:
- Stores Dart objects directly (no SQL/queries required)
- Schema defined via `@HiveType` and `@HiveField` annotations
- Generated adapters (`.g.dart` files) handle serialization
- Box-based API: `Box<T>` for each model type

### Encryption: Always-On

**Guardian Angela encrypts ALL data at rest without exception.**

- **Cipher:** `HiveAesCipher` with 256-bit AES encryption
- **Key generation:** Randomly generated on first app launch (if no key exists)
- **Key storage:** Platform-native secure storage:
  - **Android:** Android Keystore System (requires Google Play Services for hardware-backed security)
  - **iOS:** Keychain (always encrypted at OS level)
- **Encryption key:** Retrieved from `flutter_secure_storage` when opening Hive boxes
- **No opt-out:** Encryption is mandatory — there is no "unencrypted" mode

All Hive boxes are opened with encryption enabled. Code pattern:

```dart
final cipher = HiveAesCipher(encryptionKey);  // 32-byte key from secure storage
final box = await Hive.openBox<SessionMode>(
  'modes',
  encryptionCipher: cipher,
);
```

### Backup Strategy

#### Android Auto Backup

- **What:** System-level encrypted backup to Google Drive (max 25 MB)
- **When:** Automatic, managed by Android OS (usually daily, on idle + charging)
- **Configuration:** Add `android/app/src/main/res/xml/backup_rules.xml`:
  ```xml
  <?xml version="1.0" encoding="utf-8"?>
  <full-backup-content>
    <!-- Include Hive database files (already encrypted) -->
    <include domain="database" path="." />
    <!-- Include flutter_secure_storage encrypted files -->
    <include domain="sharedpref" path="FlutterSecureStorage" />
  </full-backup-content>
  ```
- **Manifest:** Add `android:allowBackup="true"` and `android:backupAgent` if custom agent needed
- **Encryption:** Hive files are already encrypted; Android transport layer adds another layer

#### iOS iCloud Backup

- **What:** System-level backup to iCloud (user opt-in, managed in Settings > iCloud)
- **When:** Automatic when device plugged in and connected to WiFi
- **Configuration:** No code needed — works by default for files in `Documents/` and app data directory
- **Path:** Hive creates databases in app-internal directory, automatically included in iCloud backup
- **Encryption:** iCloud transport is encrypted; Hive adds application-level encryption

#### Manual JSON Export/Import

For reliable cross-device migration when cloud backup may fail (e.g., keystore key doesn't transfer to new device):

**Export Format:** Single JSON file containing:
- Schema version (compatibility check)
- `appSettings` — theme, language, three PIN hashes, emergencyCallNumber, alarmDndOverride, biometric / telemetry / launch-auth toggles, alarm gradual-volume settings
- `appDefaults` — GPS logging config, stealth config, global templates, event defaults, `defaultDistressModeId`
- `userProfile` — name, phone, description (free-form text), medical fields (each `String?`)
- `emergencyContacts` — all contacts with channels, per-contact language
- `sessionModes` — all custom + built-in modes (regular and distress-flagged) with chain steps, distressModeId, triggers, overrides
- `sessionLogs` — all session history (optional, can be excluded)
- Optional media:
  - Audio files (fake call recordings, alarms)
  - Photos (contact photos, user profile photo)

**User-initiated flow:**
1. Settings > Backup & Restore > Export
2. Optional: include session logs and media
3. File picker -> save as `guardian_angela_backup_YYYY-MM-DD.json`
4. Auto-compress media into ZIP if included
5. Share via email, cloud storage, etc.

**Import flow:**
1. Settings > Backup & Restore > Import
2. File picker -> select `guardian_angela_backup_*.json`
3. Validate schema version (reject if > current version)
4. Optionally extract media from ZIP
5. Merge or replace existing data (user chooses)

**Schema versioning in export:**
```json
{
  "_schemaVersion": 5,
  "_exportedAt": "2026-04-02T14:30:00Z",
  "appSettings": { ... },
  "userProfile": { ... },
  ...
}
```

**Rationale for JSON export:**
- Platform-agnostic fallback if cloud backup fails
- Lets users verify their data before import
- Enables data portability if transitioning away from the app
- Media files in ZIP ensure all assets travel together

---

## Hive TypeId Registry

The Hive type-id table below is **historical**. The current persistence layer is JSON files, not Hive. Models map one-to-one to JSON repositories under `lib/data/repositories/`:

| Model | Repository file (JSON) | Notes |
|-------|------------------------|-------|
| MessageChannel (enum) | — | SMS, WhatsApp, Telegram, Phone |
| EmergencyContact | `contacts.json` | name, phone, channels, languageCode, sortOrder |
| ConfirmationType (enum) | — | tapButton, tapWord, swipe, dismiss |
| ReminderTemplate | `templates.json` | title, body, confirmationType, displayStyle, isGlobal |
| SessionMode | `modes.json` | name, chainSteps, distressModeId, isDistressMode, triggers, overrides |
| AppSettings | `app_settings.json` (singleton) | three PIN hashes, theme, language, emergencyNumber, alarmDndOverride, biometric/telemetry/launch-auth toggles, alarm gradual-volume settings, `AppDefaults` |
| ChainStep | — | part of `SessionMode.chainSteps` |
| ChainStepType (enum) | — | 9 escalation step types |
| UserProfile | `user_profile.json` (singleton) | name, age, phoneNumber, photoPath, physicalDescription, medical fields |
| EventDefaults | (in AppSettings.defaults) | per-step-type configuration |
| ReminderDisplayStyle (enum) | — | fullScreen, subtle |
| SessionLog | `session_logs.json` | mode, timestamps, events, isSimulation, hadMedicalInfo |
| SessionLogEvent | — | part of `SessionLog.events` |
| AppDefaults | (in AppSettings) | gpsLogging, stealth, templates, eventDefaults, defaultDistressModeId |
| BatteryAlertConfig | `battery_alert.json` (singleton) | low-battery alert config (enabled, thresholdPercent, chain: List<ChainStep>) |

The former `DistressChain` Hive type (`typeId 17`) and `distress_chains` box are gone. Distress modes are stored alongside regular modes in `modes.json` and discriminated via `isDistressMode = true`.

---

## Model Definitions

### MessageChannel (typeId: 0)

```dart
@HiveType(typeId: 0)
enum MessageChannel {
  @HiveField(0) sms,
  @HiveField(1) whatsapp,
  @HiveField(2) telegram,
  @HiveField(3) phoneCall,
}
```

**Usage:** Defines preferred communication channels for emergency contacts. A contact can have multiple channels.

---

### EmergencyContact (typeId: 1)

```dart
@HiveType(typeId: 1)
class EmergencyContact extends HiveObject {
  @HiveField(0) final String id;              // UUID
  @HiveField(1) String name;
  @HiveField(2) String phoneNumber;           // E.164 format preferred
  @HiveField(3) String? relationship;         // Optional: "Mom", "Friend", etc.
  @HiveField(4) int sortOrder;                // 0-based, ascending
  @HiveField(5) List<MessageChannel> channels;   // Active channels; default [MessageChannel.sms]
  @HiveField(6) String? languageCode;         // Per-contact SMS language (null = app language)
}
```

**Key design decisions:**
- **No `preferredChannel` field:** All enabled channels are used for every step that contacts this person — unless the `ChainStep` specifies a single channel via `SmsContactConfig.channel` (decision 15/15b).
- **Default channels:** Non-nullable, defaults to `[MessageChannel.sms]`. All contacts start with SMS enabled.
- **No contact limit:** Users can add as many contacts as needed
- **Multiple channels:** Each contact can have SMS, WhatsApp, Telegram, and phone call enabled simultaneously
- **Per-contact language:** `languageCode` overrides the app language for SMS messages to this contact
- **Address book import:** Can be imported from device contacts (requires `CONTACTS` permission)
- **Sort order:** Integer field for manual reordering (e.g., primary contact first)

**Validation:**
- Phone number: E.164 format (`+1234567890`), fallback to local format with region warning
- Name: non-empty, max 255 characters
- Relationship: optional, informational only

---

### ConfirmationType (typeId: 4)

```dart
@HiveType(typeId: 4)
enum ConfirmationType {
  @HiveField(0) tapButton,   // Tap labeled button
  @HiveField(1) tapWord,     // Tap correct word from grid
  @HiveField(2) swipe,       // Swipe in direction
  @HiveField(3) dismiss,     // Tap to dismiss (no confirmation)
}
```

**Usage:** Determines how user confirms they are safe during disguised reminder steps. Each `ReminderTemplate` specifies a confirmation type.

---

### ReminderTemplate (typeId: 5)

```dart
@HiveType(typeId: 5)
class ReminderTemplate extends HiveObject {
  @HiveField(0) final String id;                  // UUID
  @HiveField(1) String name;                      // "Calendar Event", "Weather Alert", etc.
  @HiveField(2) String title;
  @HiveField(3) String body;
  @HiveField(4) String? iconAsset;                // e.g., "assets/icons/calendar.png"
  @HiveField(5) ConfirmationType confirmationType;
  @HiveField(6) String? keyword;                  // For tapWord: correct word
  @HiveField(7) String? buttonLabel;              // For tapButton: button text
  @HiveField(8) bool isCustom;                    // true = user-created, false = built-in
  @HiveField(9) String? imagePath;                // Custom image path (optional)
  @HiveField(10) String? subtitle;                // Optional subtitle between title/body
  @HiveField(11) ReminderDisplayStyle displayStyle;  // fullScreen or subtle
  @HiveField(12) bool isGlobal;                   // true = from AppDefaults.templates; false = mode-local (ModeOverrides.localTemplates)
}
```

**Key fields:**
- **isCustom:** Built-in templates (`isCustom: false`) can be disabled but not deleted. Custom templates can be deleted freely.
- **isGlobal:** `true` = stored in `AppDefaults.templates` (available to all modes). `false` = stored in `ModeOverrides.localTemplates` for a specific mode, appended to global templates for that mode only.
- **keyword:** For `ConfirmationType.tapWord`, the correct word user must tap (e.g., "SAFE"). Decoy words are generated UI-side.
- **displayStyle:** Controls how reminder appears:
  - `fullScreen` — Takes over entire screen (like a calendar event)
  - `subtle` — Notification card overlay (less intrusive)

**Built-in templates (8 defaults):**
1. Calendar Event
2. Language Lesson (Duolingo style)
3. Delivery Update
4. Weather Alert
5. Fitness Reminder
6. Message Preview
7. App Update
8. Battery Warning

**Validation:**
- name, title, body: non-empty, max 255 characters each
- keyword (if tapWord): non-empty, max 50 characters, case-insensitive matching in UI

---

### ChainStepType (typeId: 11)

```dart
@HiveType(typeId: 11)
enum ChainStepType {
  @HiveField(0) holdButton,          // Check-in: hold button or release
  @HiveField(1) disguisedReminder,   // Periodic disguised notification
  @HiveField(2) countdownWarning,    // Visible countdown before escalation
  @HiveField(3) fakeCall,            // Simulated incoming call
  @HiveField(4) smsContact,          // Send SMS to contact
  @HiveField(5) phoneCallContact,    // Call contact
  @HiveField(6) loudAlarm,           // Play loud alarm
  @HiveField(7) callEmergency,       // Call emergency number
  @HiveField(8) hardwareButton,      // Panic trigger via volume/power button
}
```

**Nine escalation step types.** Order matters: earlier steps are less severe, later steps (loudAlarm, callEmergency) are most severe.

---

### ChainStep (typeId: 10)

**Core model for the safety chain.** Drives SessionEngine timing and escalation logic.

```dart
@HiveType(typeId: 10)
class ChainStep extends HiveObject {
  @HiveField(0) final String id;           // UUID
  @HiveField(1) ChainStepType type;
  @HiveField(2) int order;                 // 0-based position in chain
  
  // Three-phase timing (most steps):
  @HiveField(5) int waitSeconds;           // Delay before event fires (0 for most)
  @HiveField(7) int durationSeconds;       // How long event runs
  @HiveField(3) int gracePeriodSeconds;    // Dead time after event before escalating
  
  @HiveField(4) int retryCount;           // 0 = no repeat, N = up to N misses
  @HiveField(8) bool randomize;            // ±20% jitter on all timing
  @HiveField(6) StepConfig? config;        // Typed, per-step-type config (sealed class)
}
```

### StepConfig (Sealed Class Hierarchy)

Step configuration uses a **sealed class hierarchy** instead of `Map<String, String>`. This provides compile-time type safety, IDE autocomplete, and validation in constructors. Each step type has its own config class with typed fields and defaults.

```dart
sealed class StepConfig {
  /// Whether to show black screen mimicking a locked phone.
  bool get blackScreenMode;

  Map<String, dynamic> toJson();
  static StepConfig fromJson(ChainStepType type, Map<String, dynamic> json);
}

class HoldButtonConfig extends StepConfig {
  final HoldStyle holdStyle;           // default: largeButton
  final double releaseSensitivity;     // default: 1.0, range 0.3–3.0
  final bool vibrateOnRelease;         // default: true
  final bool soundOnRelease;           // default: false
  @override final bool blackScreenMode; // default: false
}

class DisguisedReminderConfig extends StepConfig {
  final bool randomizeInterval;        // default: true
  final bool randomizeTemplateOrder;   // default: true
  final bool resetOnEarlyCheckIn;      // default: true — early notification tap resets timer (D4)
  @override final bool blackScreenMode; // default: false
}

class CountdownWarningConfig extends StepConfig {
  final CountdownStyle style;          // default: fullScreen
  final bool vibrate;                  // default: true
  final bool sound;                    // default: false
  @override final bool blackScreenMode; // default: false
}

class FakeCallConfig extends StepConfig {
  final CallStyle callStyle;           // default: platform-native
  final String callerName;             // default: "Angela"
  final String? callerPhotoPath;
  final String? voiceRecordingPath;    // null = built-in per-language recording (C2/32); max 2 min (39)
  final VoiceOutputMode voiceOutputMode; // default: earpiece
  final int ringDurationSeconds;       // default: 30, range 5–120
  final bool declineIsSafe;            // default: true — decline resets chain to step 0 (A1)
  final int declineWithDistressHoldSeconds; // default: 5
  @override final bool blackScreenMode; // default: false
}

/// Selects which contacts an smsContact step targets.
///
/// `allContacts` — every emergency contact that has the step's
/// `channel` in its `channels` list. Default. This selection is
/// **dynamic**: contacts added to the repository after the step was
/// saved are automatically included on the next run (provided they
/// have the channel).
/// `firstContact` — only the contact with the lowest sortOrder
/// (ties broken by list order). Used by the default distress chain.
/// No longer reachable from the redesigned contact-button UI
/// (see "SmsContactConfig UI-button selection" below) but
/// preserved in the enum to honour earlier stored configs.
/// `specificIds` — only contacts whose IDs appear in `contactIds`.
/// This selection is **static**: contacts added to the repository
/// later are NOT auto-included.
enum SmsContactSelection { allContacts, firstContact, specificIds }

class SmsContactConfig extends StepConfig {
  final List<String>? contactIds;              // meaningful for specificIds (and legacy allContacts)
  final SmsContactSelection contactSelection;  // default: allContacts (ITEM 6)
  final MessageChannel channel;        // default: MessageChannel.sms — ONE channel per step (15/15b)
  final bool includeLocation;          // default: true
  final bool includeMedicalInfo;       // default: false — per-step toggle (C3)
  final bool autoRecordAudio;          // default: false
  final bool autoRecordVideo;          // default: false
  final int recordDurationSeconds;     // default: 30
  final String messageTemplate;        // default: see seed data
  @override final bool blackScreenMode; // default: false
}

/// Each SMS/messaging step uses ONE channel. Contacts without the selected
/// channel are greyed out in the contact picker. If a contact lacks the
/// channel at runtime, the failure is logged and execution continues (15c).
/// Validation blocks saving a step whose contactIds all lack the channel.

#### SmsContactConfig UI-button selection

The contact picker for an `smsContact` step is a **row of clickable contact buttons**, one per contact in the emergency-contacts repository. The dropdown-style selector is retired.

**Rendering rules (one per contact):**
1. **Channel-capable + selected** — contact's `channels` contains the step's `channel`, and the contact is currently included. Rendered as an enabled, highlighted button ("on"). Tapping toggles it off.
2. **Channel-capable + unselected** — contact has the channel but is currently excluded. Rendered as an enabled, de-emphasised button ("off"). Tapping toggles it on.
3. **Not channel-capable** — contact's `channels` does NOT contain the step's `channel`. Rendered **disabled and grayed out**, non-tappable. These contacts cannot be added to the step's `contactIds` regardless of user action. A tooltip/help text explains that the contact has no matching channel.

**Initial state when the editor opens:**
- All channel-capable buttons start enabled ("on") by default when the user creates a new step (equivalent to `allContacts`).
- When editing an existing step whose `contactSelection == specificIds`, only buttons whose id appears in `contactIds` start "on"; the rest start "off".
- When editing an existing step whose `contactSelection == allContacts`, all channel-capable buttons start "on".
- When editing a legacy step whose `contactSelection == firstContact`, only the first-sorted channel-capable contact starts "on". Saving will re-infer the selection per the save-time rule below (so `firstContact` is not preserved unless the user leaves exactly that one button on and that contact is actually the first-sorted one; in practice `firstContact` is a write-only legacy value).

**Save-time inference rule:**
When the user saves the step, `contactSelection` and `contactIds` are inferred from which buttons are "on":
- If **all** channel-capable contacts are "on" → persist as `contactSelection = allContacts`, `contactIds = null`.
- If a **strict subset** of the channel-capable contacts is "on" → persist as `contactSelection = specificIds`, `contactIds = [ids of the on buttons]`.
- `firstContact` is **not** reachable from the redesigned UI. It remains in the enum for backwards compatibility with earlier stored configs (notably the seeded default distress chain, which is still stored as `firstContact` in seed data) and is honoured at runtime.

**Behavioural consequence — adding a contact later:**
- Steps saved as `allContacts` auto-include a newly added contact on the next run, provided the new contact has the step's `channel`.
- Steps saved as `specificIds` do NOT auto-include a newly added contact. The user must edit the step and toggle the new button on.
- Steps saved as `firstContact` always target the currently first-sorted channel-capable contact, which may change if contact sort order changes.

**Validation:**
- A step must have at least one "on" button at save time. Saving with all buttons off is blocked.
- If every contact in the repository lacks the step's `channel`, the editor displays an error explaining that no contact can receive the step via that channel; the step cannot be saved.

final class PhoneCallContactConfig extends StepConfig {
  final String? contactId;                // null = first-sorted contact
  final List<String> alternativeContactIds; // default: empty
  @override final LogGpsOverride logGps;  // default: useDefault
}

// Q12: pre-call SMS configuration was removed from
// PhoneCallContactConfig — calling a personal contact does not warrant
// an automatic pre-warning SMS. The pre-call location-SMS toggle now
// lives only on CallEmergencyConfig.sendLocationSmsFirst.

final class LoudAlarmConfig extends StepConfig {
  final bool flashScreen;                 // default: false (photosensitive warning)
  final double flashSpeed;                // legacy — seconds per flash cycle (default 0.5)
  final int flashSpeedMs;                 // canonical — flash cycle in ms (default 500)
  final bool maxVolume;                   // legacy — force system media to max (default true)
  final double volume;                    // 0.0–1.0 linear (default 1.0)
  final LoudAlarmSound soundChoice;       // siren | custom (default siren) — Q9
  final bool gradualVolume;               // default: false (ramp from 0 → volume)
  final bool flashLight;                  // default: true (strobe camera flash)
  final bool blackScreenMode;             // default: false (stealth alarm)
  @override final LogGpsOverride logGps;  // default: useDefault
}

/// Q9 — alarm sounds reduced to two values. `whoop` and `bell` are
/// removed. The persisted form of `siren` / `custom` round-trips
/// directly; legacy values are nuked-and-reseeded under the
/// pre-alpha policy.
enum LoudAlarmSound { siren, custom }

class CallEmergencyConfig extends StepConfig {
  /// Per-step override. `null` (default) = inherit the app-wide
  /// `AppSettings.emergencyCallNumber` (locale-aware, 112/911/…).
  /// A non-null value overrides the global default for this step
  /// only — useful for travel modes or regional escalation chains.
  final String? emergencyNumber;
  final bool sendLocationSmsFirst;     // default: true
  final bool showConfirmation;         // default: true
  final int confirmationDurationSeconds; // default: 5
  @override final bool blackScreenMode; // default: false
}

class HardwareButtonConfig extends StepConfig {
  final ButtonType buttonType;         // default: volumeUp
  final PressPattern pressPattern;     // default: repeatPress
  final int pressCount;                // default: 5 (B1) — 5 presses to trigger
  final double longPressDurationSeconds; // default: 2.0
  final int targetStepIndex;           // default: -1 (next step)
  @override final bool blackScreenMode; // default: false
}
```

**Hive serialization:** StepConfig subclasses serialize to/from JSON via `toJson()`/`fromJson()`. Stored in Hive as a JSON string within the ChainStep adapter. The `ChainStepType` discriminator selects the correct subclass during deserialization.

**EventDefaults:** `EventDefaults` stores one instance of each `StepConfig` subclass as the global default. When a `ChainStep.config` is null, the matching `EventDefaults` config is used. When non-null, per-step values override defaults field by field via `copyWith`.

**Timing model — Three phases:**

1. **Wait phase** (`waitSeconds`): Time before event fires. For `disguisedReminder`, this is the interval between reminders. 0 for all other types.
2. **Active phase** (`durationSeconds`): Event is running/visible. User must disarm within this window or event considered "missed."
3. **Grace phase** (`gracePeriodSeconds`): Dead time after event ends. User can still disarm, but no new interactions happen. If user fails to disarm within grace, advance to next step.

**Repeat logic:**
- `retryCount: 0` → Fire once, then advance to next step (or end chain)
- `retryCount: 3` → Fire up to 4 times (initial + 3 repeats). Each repeat: wait → duration → grace. Advance after 4 total fires or if user disarms

**Randomization:**
- `randomize: true` → Apply ±20% jitter to all timing values (wait, duration, grace)
- Rationale: Prevents predictable escalation patterns
- Implementation: `_FixedRandom(0.5)` in tests returns 0.5, eliminating jitter for determinism

**Config (typed):**
- Type-specific overrides via sealed `StepConfig` class hierarchy.
- Examples:
  - `fakeCall`: `FakeCallConfig(callerName: 'Mom', ringDurationSeconds: 30)`
  - `smsContact`: `SmsContactConfig(messageTemplate: '...', includeLocation: true)`
  - `loudAlarm`: `LoudAlarmConfig(volume: 0.8, soundChoice: AlarmSound.siren)`
- If null, `EventDefaults.forType(stepType)` provides the default config.
- If non-null, per-step values override defaults field by field.

**Duration getters:**
```dart
Duration get waitDuration => Duration(seconds: waitSeconds);
Duration get activeDuration => Duration(seconds: durationSeconds);
Duration get gracePeriod => Duration(seconds: gracePeriodSeconds);
int get totalCycleSeconds => waitSeconds + durationSeconds + gracePeriodSeconds;
```

---

### Default Timing Values by Type

These are seed defaults — each step can override via its `config` map.

| Type | waitSeconds | durationSeconds | gracePeriodSeconds | retryCount | Notes |
|------|-------------|-----------------|-------------------|-------------|-------|
| holdButton | 0 | 10 | 5 | 0 | Countdown length |
| disguisedReminder | 1800 | 60 | 120 | 1 | 30min interval, 2 total attempts (B2) |
| countdownWarning | 0 | 10 | 3 | 0 | Visible pre-escalation countdown |
| fakeCall | 0 | 30 | 5 | 0 | Ring time, 1 attempt only (B3) |
| smsContact | 0 | 15 | 5 | 0 | Send time (no retry by default) |
| phoneCallContact | 0 | 60 | 5 | 1 | Call time, 1 retry |
| loudAlarm | 0 | 30 | 5 | 0 | Alarm duration |
| callEmergency | 0 | 5 | 0 | 0 | Confirmation only, no grace |
| hardwareButton | 0 | 0 | 0 | 0 | Immediate trigger, no timing |

**Decision B2:** `disguisedReminder` global default retryCount = **1** (2 total attempts: initial + 1 retry). Seed data and `EventDefaults` must both reflect this.

**Decision B3:** `fakeCall` global default retryCount = **0** (1 attempt only). Extra rings add noise in genuine emergencies.

**Repeat semantics:** `retryCount: N` means the step fires N+1 times total (initial + N retries). After all fires, the chain escalates to the next step.

---

### SessionMode (typeId: 8)

```dart
final class SessionMode {
  final String id;                          // UUID
  final String name;                        // "Walk Mode", "Date Mode", etc.
  final String? iconName;                   // e.g., "directions_walk"
  final ChainStepType checkInType;          // First-step type
  final List<ChainStep> chainSteps;         // Unified chain (first step is check-in)
  final String? distressModeId;             // id of a distress mode (a SessionMode with isDistressMode = true);
                                            // null = inherit AppDefaults.defaultDistressModeId
  final List<DistressTrigger> distressTriggers;
  final List<DisarmTrigger> disarmTriggers;
  final ModeOverrides? overrides;           // null = inherit all from AppDefaults
  final bool trackingEnabled;               // Spec 11 §DE-3 (default false)
  final int trackingIntervalSeconds;        // Spec 11 §DE-3 (default 300)
  final int trackingBufferSize;             // Spec 11 §DE-3 (default 50)
  final bool pauseAllowed;                  // default true
  final int? maxPauseMinutes;               // null = unlimited
  final bool isDistressMode;                // True iff this mode IS a distress mode that
                                            // other modes reference via distressModeId.
                                            // Distress modes are managed under
                                            // /distress-modes (separate UI list).
}
```

**Key design decisions:**
- **Unified chain:** First step determines check-in mechanism (holdButton or disguisedReminder). All subsequent steps are escalation.
- **Distress mode by id:** `distressModeId` references another `SessionMode` (with `isDistressMode = true`) by id. `null` means "inherit `AppDefaults.defaultDistressModeId`". If neither resolves, the mode blocks at session start (validation error).
- **Inheritance:** When `overrides` is null, all per-mode settings (GPS logging, stealth, templates, event defaults) are inherited from `AppDefaults`. When `overrides` is non-null, any non-null field in `ModeOverrides` replaces the corresponding `AppDefaults` value for that mode only.
- **Template lists:** The effective reminder template list for a mode = `AppDefaults.templates` + `ModeOverrides.localTemplates` (if any). Local templates are appended, not replacing.
- **All modes deletable:** Every mode, including Walk Mode and Date Mode, can be deleted. There are no protected built-in modes.
- **Templates for creation:** Walk Mode and Date Mode are available as **seed templates** used only when creating a new mode ("From Template").
- **Cannot save empty:** Must have at least 1 chain step
- **No limit on modes:** Only practical UI limits (pagination/search at ~100+ modes)
- **Max chain length:** 10,000 steps (prevents runaway configs)

**Seed templates (used only for mode creation, not stored as modes):**
1. **Walk Mode template** — `holdButton` check-in, escalates via fake calls → SMS → emergency
2. **Date Mode template** — `disguisedReminder` check-in, periodic reminders, escalates like Walk Mode

**Adding new mode:**
1. User selects "From Template" (Walk/Date seed) or "From Scratch"
2. Configures chain steps
3. Saves with unique name and UUID
4. Mode stored with `isFromTemplate: true` if created from a seed template

**Derived property:**
```dart
ChainStepType? get checkInType =>
  chainSteps.isNotEmpty ? chainSteps.first.type : null;
```

---

### AppSettings (typeId: 9)

```dart
final class AppSettings {
  // Display
  final AppThemeMode themeMode;            // light, dark, system (default)
  final String languageCode;               // default: 'en'
  final bool isFirstLaunch;                // default: true
  final String? selectedModeId;            // currently selected mode

  // Security — three independent PIN hashes (each nullable = disabled)
  final String? appPinHash;                // locks the app on open
  final String? sessionEndPinHash;         // required to disarm/end session
  final String? duressPinHash;             // silently fires distress chain
  final int pinTimeoutSeconds;             // default: 15; max: 120
  final int wrongPinThreshold;             // default: 5 — wrong PINs that
                                           // silently fire distress (A3)

  // Biometric / launch-auth toggles (Q14)
  final bool appPinBiometricEnabled;       // try biometric first at app PIN
  final bool sessionEndPinBiometricEnabled;// try biometric first at session-end PIN
  final bool distressCancelBiometricEnabled;// try biometric first at distress-cancel
  final bool requireLaunchAuth;            // gate home screen on cold start
  final bool launchAuthBiometric;          // launch gate prefers biometric

  // Global behavior
  final String emergencyCallNumber;        // default: '112' (Settings has editor)
  final bool alarmDndOverride;             // default: false (Q19)
  final bool alarmGradualVolume;           // default: false
  final int alarmGradualVolumeDurationSeconds; // default: 5
  final int sessionLogRetentionDays;       // default: 180

  // Telemetry
  final bool telemetryOptOut;              // legacy opt-out flag
  final bool sentryEnabled;                // master Sentry toggle (default false; opt-in)

  // AppDefaults (GPS logging, stealth, templates, event defaults,
  // defaultDistressModeId)
  final AppDefaults defaults;
}
```

**Display settings:**
- `themeMode`: `system` (default), `light`, `dark`.
- `languageCode`: 'en', 'de', 'es', 'fr', 'ru', 'zh', 'zh_TW', 'hi', 'fa', 'uk', 'pl', 'el', 'ar', 'he'. Settings has a Language picker.
- `selectedModeId`: UUID of the current active mode (for quick resume).

**Security — three distinct PINs:**
- `appPinHash`: When set, unlocks the app on every open. Null = no app lock. May try biometric first via `appPinBiometricEnabled`.
- `sessionEndPinHash`: When set, required to disarm or manually end a running session. Timeout configurable via `pinTimeoutSeconds` (default 15 s, max 120 s). May try biometric first via `sessionEndPinBiometricEnabled`.
- `duressPinHash`: When entered at ANY PIN prompt, shows a fake "Session ended" screen to the attacker and silently fires the mode's selected distress mode. Must differ from the other two PINs.
- `wrongPinThreshold`: After this many wrong attempts at a PIN prompt, silently fire distress (A3). Default 5.
- `requireLaunchAuth` + `launchAuthBiometric`: gate the home screen behind a PIN-or-biometric prompt on cold start. Both default off / on respectively (Q14).

**Global behavior:**
- `emergencyCallNumber`: defaults to `112`. Settings has an "Emergency number" editor.
- `alarmDndOverride`: defaults to **false** (Q19) — opt-in.
- `alarmGradualVolume` + `alarmGradualVolumeDurationSeconds`: when enabled, the loud-alarm step ramps volume from silence to `LoudAlarmConfig.volume` over the configured number of seconds. Default 5 s. Settings → Alarm exposes both.
- `sessionLogRetentionDays`: auto-delete logs older than this many days; default 180.

**Telemetry:**
- `sentryEnabled`: master toggle, default **false** (opt-in). Q42 amended.
- `telemetryOptOut`: retained legacy flag.

**AppDefaults:**
- `defaults`: Holds `GpsLoggingConfig`, `StealthConfig`, global `ReminderTemplate` list, `EventDefaults`, and `defaultDistressModeId`. All modes inherit from these unless they specify a `ModeOverrides`.

**Schema:**
- On mismatch: nuke all repositories and re-seed from defaults (pre-alpha policy — no migrations).

**Quick Exit behavior:**
- Quick Exit (`finishAndRemoveTask` on Android) removes the app from the recents list and closes the app immediately.
- Data is preserved: all session logs, contacts, modes, and settings remain in storage.
- Quick Exit is NOT a data wipe — it is a visibility/exit mechanism only.

---

### UserProfile (typeId: 12)

```dart
final class UserProfile {
  final String? name;                  // User's display name
  final int? age;                      // years
  final String? phoneNumber;           // E.164 format preferred
  final String? photoPath;             // app-internal image path
  final String? physicalDescription;   // free-form: "175cm, brown hair, wearing red"
  final String? bloodType;             // free-form: "O+"
  final String? allergies;             // free-form text
  final String? medications;           // free-form text
  final String? medicalConditions;     // free-form text
  final String? emergencyInstructions; // free-form text
}
```

Every medical field is `String?` (free-form text) — not a typed list. The form layer accepts comma-separated entries and stores them as a single string. `UserProfile.hasMedicalInfo` returns true when any medical field carries content; `SessionLog.hadMedicalInfo` is stamped from this getter at session start.

**Usage:**
- `name`: substituted into SMS message templates ("`{name}` may need help").
- `phoneNumber`: own phone number; included in some emergency SMS templates.
- `photoPath`: stored in app-internal documents directory.
- `physicalDescription`: free-form description for responders.
- Medical fields: included in emergency SMS only when the active step opts in (`SmsContactConfig.includeMedicalInfo == true`).

---

### EventDefaults (typeId: 13)

```dart
@HiveType(typeId: 13)
class EventDefaults extends HiveObject {
  @HiveField(0) HoldButtonConfig holdButton;
  @HiveField(1) DisguisedReminderConfig disguisedReminder;
  @HiveField(2) CountdownWarningConfig countdownWarning;
  @HiveField(3) FakeCallConfig fakeCall;
  @HiveField(4) SmsContactConfig smsContact;
  @HiveField(5) PhoneCallContactConfig phoneCallContact;
  @HiveField(6) LoudAlarmConfig loudAlarm;
  @HiveField(7) CallEmergencyConfig callEmergency;
  @HiveField(8) HardwareButtonConfig hardwareButton;
  
  /// Returns the typed default config for a given step type.
  StepConfig forType(ChainStepType type) => switch (type) {
    ChainStepType.holdButton => holdButton,
    ChainStepType.disguisedReminder => disguisedReminder,
    // ... exhaustive match
  };
}
```

**Purpose:** Global per-step-type configuration using typed `StepConfig` classes. When a `ChainStep.config` is null, the engine uses the matching `EventDefaults` config. When non-null, per-step values override via `copyWith()`.

**Seed defaults:** Each `StepConfig` subclass has a constructor with sensible defaults (see field defaults in the sealed class definitions above). The `EventDefaults` object is seeded on first launch with default-constructed instances of each config class.

**Immutable copy pattern:**
- Stored once in Hive, retrieved once at app startup
- Loaded into memory singleton
- Updates via `copyWith()` → save back to Hive → broadcast update notification

**Locale-aware overrides:**
Emergency number defaults by region (80+ countries):
- 112 (EU, Asia-Pacific)
- 911 (North America)
- 999 (UK, parts of Middle East)
- 000 (Australia)
- 111 (New Zealand)
- 110 (China)
- ...and more

---

### ReminderDisplayStyle (typeId: 14)

```dart
@HiveType(typeId: 14)
enum ReminderDisplayStyle {
  @HiveField(0) fullScreen,    // Takes over entire screen
  @HiveField(1) subtle,        // Overlay/notification card
}
```

**Usage:** Determines UI appearance of `disguisedReminder` steps.

---

### SessionLog

```dart
final class SessionLog {
  final String id;                 // UUID
  final String modeId;             // mode that ran
  final String modeName;           // mode name cached at session start
  final DateTime startedAt;
  final DateTime? endedAt;         // null if session ongoing
  final EndReason? endReason;      // null if still running
  final bool isSimulation;
  final bool hadMedicalInfo;       // default: false. Stamped at log creation
                                   // by SessionLogRecorder when the user
                                   // profile carries medical info AND at
                                   // least one step opts in via
                                   // SmsContactConfig.includeMedicalInfo.
  final List<SessionLogEvent> events;
}
```

**Purpose:** Persistent record of completed safety sessions. For each session started, one log is created and events appended.

**Key fields:**
- `startTime` / `endTime`: Session lifecycle
- `modeName`: Human-readable name (in case mode is later deleted)
- `modeId`: UUID reference to original mode
- `isSimulation`: Indicates a practice-mode session (user interacted with real step UIs; destructive actions were blocked)
- `events`: Ordered list of events that occurred
- `hadMedicalInfo` *(Extra 47)*: `true` iff at least one `smsContact` step in the session had `includeMedicalInfo=true` AND the user profile had any medical information at session start. Stamped at log creation by the `SessionLogRecorder` from the resolved `SessionContext`. Export logic uses this flag to decide whether the exported log should surface medical info — logs that captured medical info can be exported with it, logs that did not cannot fabricate it retroactively.

**Storage & retention (B8):**
- All session logs persisted in Hive (encrypted)
- Auto-delete: configurable via `AppSettings.sessionLogRetentionDays` (default **180 days**)
- **Smart retention algorithm (B8):** at app startup the data layer calls
  `SessionLogRepository.purgeExpiredLogs(retentionDays: N, now: now)`:
  1. Iterate all stored logs.
  2. For each log, compute `isCritical` — true iff any event in `log.events`
     has an `eventType` indicating that a destructive action actually fired
     (`step_started` / `stepAdvancing` for steps whose type is `smsContact`,
     `phoneCallContact`, `callEmergency`, or `loudAlarm`, any event with
     `deliveryStatus == sent|queued`, or any event generated while the
     distress chain was active).
  3. Skip critical logs — they are kept **indefinitely**.
  4. For non-critical logs, check `endTime`. If null (session never
     finished), fall back to `startTime`.
  5. If the reference time is older than `now - Duration(days:
     retentionDays)`, delete the log. Until Extra-11 (soft-delete) lands,
     this is a hard delete; afterwards the same method will transition
     into a soft-delete that moves the log into a trash box for 7 days
     before a second-pass purge.
- Soft delete + undo (decision 11): deleted logs enter a recoverable trash state for 7 days before permanent purge
- Storage warning when database size exceeds threshold (e.g., 100 MB)
- Manual export/import via JSON (see Backup Strategy section)

**Privacy defaults for export/share:**
- Location data: **excluded by default** (opt-in checkbox "Include location data?")
- Timestamps: included by default
- Contact names: included by default (opt-in anonymization available)
- Session log export always requires PIN if PIN is enabled

---

### SessionLogEvent (typeId: 16)

```dart
@HiveType(typeId: 16)
class SessionLogEvent extends HiveObject {
  @HiveField(0) DateTime timestamp;
  @HiveField(1) String eventType;              // "started", "step_fired", "disarmed", etc.
  @HiveField(2) String? stepType;              // ChainStepType name or null
  @HiveField(3) int stepIndex;                 // Position in chain
  @HiveField(4) String description;            // Human-readable summary
  @HiveField(5) double? latitude;              // Nullable, only if GPS logging enabled
  @HiveField(6) double? longitude;             // Nullable, only if GPS logging enabled
  @HiveField(7) String? deliveryStatus;        // "sent", "queued", "failed", "simBlocked" (for message steps)
}
```

**Event types:**
- `"started"` — Session initialized
- `"step_fired"` — A chain step became active
- `"disarmed"` — User confirmed safety (successful disarm)
- `"missed"` — User failed to disarm within window
- `"escalated"` — Automatic advance to next step
- `"completed"` — All steps processed or manually ended
- `"error"` — Something went wrong (e.g., SMS send failed)

**Delivery status** (for message-based steps):
- `"sent"` — Message successfully delivered
- `"queued"` — Message queued for delivery (background sender pending)
- `"failed"` — Message delivery failed (network issue, invalid number, etc.)
- `"simBlocked"` — Blocked by SIM (IMEI/IMSI mismatch in demo mode)

**Example log entry:**
```json
{
  "timestamp": "2026-04-02T14:25:30.123Z",
  "eventType": "step_fired",
  "stepType": "fakeCall",
  "stepIndex": 1,
  "description": "Fake call from Angela started (ring 30s)",
  "latitude": 37.7749,
  "longitude": -122.4194
}
```

**Location recording:**
- `latitude` / `longitude`: Captured from Geolocator when `GpsLoggingConfig.enabled = true`
  (from `AppDefaults.gpsLogging`, overridable per-mode in `ModeOverrides.gpsLogging`)
- `null` if feature disabled or location permission not granted
- Timezone: All timestamps in UTC (ISO 8601)

---

### WalkSession (ephemeral, not persisted)

```dart
final class WalkSession {
  final String id;
  final String modeId;
  final bool isSimulation;
  final DateTime startedAt;
  final SessionPhase phase;            // sealed: idle / active / paused / ended
  final double simulationSpeed;        // default 1.0
  final int currentStepIndex;
  final ChainStepType? currentStepType;
  final int missCount;
  final int? remainingSeconds;
  final Duration simulatedElapsed;
  final List<SimulationDescription> firedStepDescriptions;
  final SimulationDescription? lastSimulationDescription;
  final bool isBackgroundAlert;
  final int totalSteps;
  final bool simulationSilent;         // suppress sim toasts/beeps
                                       // (default false; set true by the
                                       // simulation summary screen for a
                                       // silent replay)
}
```

**Purpose:** Ephemeral UI-layer snapshot of the active session. **Not persisted** to disk — derived from `EngineState` on each engine event. The `SessionController` owns it; the `SessionScreen` watches it. App death = session is gone (no resume-from-disk).

**Named constructors:**
- `WalkSession.startingReal({...})` — initializes a real session. `isSimulation = false`, `simulationSilent = false`, `simulationSpeed = 1.0`.
- `WalkSession.startingSimulation({...})` — initializes a simulation session. `isSimulation = true`, `simulationSilent` defaulting to `false`; pass `silent: true` for a silent replay.

Controllers MUST use the matching named constructor when kicking off a session — the unnamed constructor exists only for `copyWith` round-trips.

---

### Distress modes (Pivot 3)

There is no `DistressChain` model. A distress chain is the `chainSteps` of a `SessionMode` flagged with `isDistressMode = true`. Distress modes live alongside regular modes in `modes.json` and are filtered into a separate UI list under `/distress-modes`.

**Selection:**
- `SessionMode.distressModeId == null` → resolve via `AppDefaults.defaultDistressModeId`.
- `AppDefaults.defaultDistressModeId == null` → mode validation blocks session start.
- The resolved id is looked up in `modes.json`; missing id is a hard validation error (no silent fallback).

**Default distress mode:** seeded on first launch. The default chain is two steps — `smsContact` (location to all contacts) → `callEmergency`. Users can edit or replace it; nuke-and-reseed restores the default on schema mismatch.

**Allowed step types:** any of the 9 step types. The editor warns against UI-driven steps in distress chains but does not block them.

---

### AppDefaults

```dart
final class AppDefaults {
  final GpsLoggingConfig gpsLogging;
  final StealthConfig stealth;
  final List<ReminderTemplate> templates;       // global reminder templates
  final EventDefaults eventDefaults;
  final String? defaultDistressModeId;          // id of a SessionMode with
                                                // isDistressMode = true; null
                                                // means "no global default —
                                                // modes without their own
                                                // distressModeId block".
}
```

**Purpose:** Master source for configurable defaults that modes can inherit and override. Modes inherit from `AppDefaults` unless they specify a `ModeOverrides`. The `defaultDistressModeId` field is the runtime resolution target when `SessionMode.distressModeId` is null.

**Accessible from:** Settings → Defaults (sub-items: GPS Logging, Event Defaults / Templates). The Default Distress Mode selector lives under Settings → Modes & Chains → Distress Modes, alongside the distress-mode list.

---

### ModeOverrides

```dart
class ModeOverrides {
  GpsLoggingConfig? gpsLogging;     // null = inherit from AppDefaults
  StealthConfig? stealth;           // null = inherit from AppDefaults
  List<ReminderTemplate>? localTemplates; // appended to AppDefaults.templates (not replacing)
  EventDefaults? eventDefaults;     // null = inherit from AppDefaults
}
```

**Purpose:** Per-mode optional overrides. When `ModeOverrides` is set on a mode, any non-null field replaces the corresponding `AppDefaults` value for that mode only. `localTemplates` are APPENDED to global templates — the effective template list = `AppDefaults.templates` + `localTemplates`.

**Note:** the per-mode distress selection is NOT in `ModeOverrides` — it lives directly on `SessionMode.distressModeId`.

---

### GpsLoggingConfig

```dart
final class GpsLoggingConfig {
  final bool enabled;               // master toggle; default true
  final int intervalSeconds;        // default 30 (Q21)
  final GpsAccuracy accuracy;       // low / medium / high; default high (Q21)
  final GpsFormat format;           // dms / decimal / openLocationCode;
                                    // default decimal (Q21)
  final bool includeInSms;          // append location to SMS steps; default true
  final int historyRetentionDays;   // default 30
}
```

**Purpose:** Configures HOW GPS is logged during sessions. Global config lives in `AppDefaults.gpsLogging`; modes can override via `ModeOverrides.gpsLogging`.

**Accessible from:** Settings → Defaults → GPS Logging

---

### StealthConfig

```dart
final class StealthConfig {
  final bool enabled;                     // master toggle; default false
  final String fakeName;                  // default 'Music' (Q20)
  final StealthIconPreset fakeIcon;       // default StealthIconPreset.music (Q20)
  final bool notificationDisguise;        // default true
  final StealthTimerDisplay timerDisplay; // normal / small / none; default normal
  final bool sessionScreenStealth;        // default true
}

enum StealthIconPreset {
  music, calendar, fitness, weather, news, photos, notes, clock,
  podcast, none,
}

enum StealthTimerDisplay { normal, small, none }
```

**Field defaults:**
- `fakeName`: `'Music'` (Q20). Always non-null.
- `fakeIcon`: `StealthIconPreset.music` (Q20). The helper `iconFromStealth(preset)` resolves to a Material `IconData`.
- `notificationDisguise`: `true` — disguised channel name / icon when stealth is on.
- `timerDisplay`: `normal` — session timer appearance in stealth mode.
- `sessionScreenStealth`: `true` — strip Guardian Angela branding from the session screen when stealth is on.

**Sub-option visibility:** All stealth sub-options are **always visible** in the UI, even when `enabled = false`. This lets users pre-configure stealth appearance before enabling it (D5).

**Purpose:** Configures HOW stealth is applied. Global config in `AppDefaults.stealth`; modes can override via `ModeOverrides.stealth`. All fields are independent — enabling stealth does not force all options on.

**Accessible from:** Settings → Stealth (dedicated screen at `/settings/stealth`).

---

### BatteryAlertConfig

```dart
final class BatteryAlertConfig {
  final bool enabled;                  // default: false (Q22 — opt-in)
  final int thresholdPercent;          // default: 10
  final List<ChainStep> chain;         // configurable escalation chain
                                       // (default: empty)
}
```

`enabled` defaults to `false` (Q22): a safety app must not surprise users with new automatic alerts. `thresholdPercent` defaults to **10** so the alert fires close to a real emergency rather than spamming the user.

**Purpose:** A one-shot side-action that fires once per session when battery drops below threshold during an active session. Does not interrupt the main session chain. Disabled by default (`enabled: false`).

**ITEM 8 — Chain-based model:**
- The alert now carries a **configurable chain** (`List<ChainStep>`) rather than a single `sendSms` boolean. The chain can include `smsContact`, `phoneCallContact`, `callEmergency`, `loudAlarm`, `countdownWarning`, and `fakeCall` steps.
- Seed default: `[smsContact]` with `includeLocation: true`, matching pre-ITEM-8 behaviour so existing users see no functional regression once they toggle `enabled` on.
- Legacy JSON upgrade: when an exported `sendSms` boolean is encountered without a `chain` field, `BatteryAlertConfig.fromJson` synthesises a single-step `smsContact` chain if `sendSms: true`, or an empty chain if `sendSms: false`.
- The `sendSms` getter returns `true` iff the chain contains an `smsContact` step. It is retained only until the battery-monitor side-action is rewritten to drive the full chain through the session engine.

**Behavior:**
- Only fires if enabled AND battery reaches the threshold during an active session
- Fires exactly once per session (no repeats)
- Runs the configured chain (or no-ops if chain is empty) — main session continues uninterrupted
- Chain steps execute through the same strategies the main session uses

**TODO:** `lib/services/implementations/battery_monitor_service.dart` and `lib/features/session/session_controller.dart` (`_startBatteryMonitor`) must be migrated from the legacy `sendSms` boolean path to driving the full chain via the session engine. See the TODO in the model file.

---

## Seed Data

Seed data is installed on first app launch (or after schema migration) via `lib/data/seed_data.dart`.

### Walk Mode (Built-in Template)

Check-in via hold-button. Quick escalation path.

```
Step 0: holdButton
  - waitSeconds: 0
  - durationSeconds: 10 (countdown length)
  - gracePeriodSeconds: 1
  - retryCount: 0
  - config: holdStyle=largeButton

Step 1: fakeCall
  - waitSeconds: 0
  - durationSeconds: 30
  - gracePeriodSeconds: 5
  - retryCount: 0 (1 attempt only)
  - config: null (use EventDefaults)

Step 2: smsContact
  - waitSeconds: 0
  - durationSeconds: 15
  - gracePeriodSeconds: 5
  - retryCount: 0

Step 3: phoneCallContact
  - waitSeconds: 0
  - durationSeconds: 60
  - gracePeriodSeconds: 5
  - retryCount: 0

Step 4: callEmergency
  - waitSeconds: 0
  - durationSeconds: 5
  - gracePeriodSeconds: 0 (no dead time)
  - retryCount: 0
```

### Date Mode (Built-in Template)

Check-in via periodic disguised reminders. For situations where continuous holding is not feasible.

```
Step 0: disguisedReminder
  - waitSeconds: 1800 (30 minutes)
  - durationSeconds: 60
  - gracePeriodSeconds: 120
  - retryCount: 1 (2 total attempts, B2)
  - config: randomizeInterval=true, randomizeTemplateOrder=true, resetOnEarlyCheckIn=true (D4)

Step 1: fakeCall
  - waitSeconds: 0
  - durationSeconds: 30
  - gracePeriodSeconds: 5
  - retryCount: 0 (1 attempt only)

Step 2: smsContact
  - waitSeconds: 0
  - durationSeconds: 15
  - gracePeriodSeconds: 5
  - retryCount: 0

Step 3: phoneCallContact
  - waitSeconds: 0
  - durationSeconds: 60
  - gracePeriodSeconds: 5
  - retryCount: 0 (1 call attempt)

Step 4: callEmergency
  - waitSeconds: 0
  - durationSeconds: 10
  - gracePeriodSeconds: 0
  - retryCount: 0
  - config: showConfirmation=true
```

### Default Distress Mode

Seeded as a `SessionMode` with `isDistressMode = true`; its id is stored in `AppDefaults.defaultDistressModeId`. Used whenever `SessionMode.distressModeId` is null.

```
Step 1: smsContact
  - waitSeconds: 0
  - durationSeconds: 15
  - gracePeriodSeconds: 0
  - retryCount: 0
  - config: contactSelection=firstContact (ITEM 6 — SMS the
            DEFAULT / uppermost emergency contact only,
            NOT every contact),
            includeLocation=true

Step 2: callEmergency
  - waitSeconds: 10   (ITEM 6 — give the SMS 10 s to leave
                       the outbox before tying up the radio)
  - durationSeconds: 5
  - gracePeriodSeconds: 0
  - retryCount: 0
  - config: sendLocationSmsFirst=true, showConfirmation=false
             (no confirmation countdown in distress — fires immediately)
```

This chain is also referenced in the overview and 00-overview.md Seed Data section. The design ensures the user's primary emergency contact receives location data first (before the phone dials emergency services and ties up the radio), without spamming every contact on every trigger.

The `smsContact` strategy MUST honour `SmsContactConfig.contactSelection`; see `lib/domain/orchestration/strategies/sms_contact_strategy.dart`.

### Eight Built-in Reminder Templates

Used by `disguisedReminder` steps. Seeded with realistic daily-life triggers.

| # | Name | Title | Body | ConfirmationType | DisplayStyle |
|---|------|-------|------|------------------|--------------|
| 1 | Calendar Event | You have an appointment | Meeting with Alex at 3 PM | tapButton | fullScreen |
| 2 | Duolingo Lesson | Time for your lesson! | Keep your 50-day streak going | tapWord | subtle |
| 3 | Delivery Update | Your package arrived | Check the front porch | tapButton | fullScreen |
| 4 | Weather Alert | Rainy tomorrow | Bring an umbrella | dismiss | subtle |
| 5 | Fitness Reminder | Time to exercise | Your workout is due | tapButton | subtle |
| 6 | Message Preview | New message from Sarah | "Hey, what's up?" | dismiss | subtle |
| 7 | App Update | Updates available | Tap to install | tapButton | fullScreen |
| 8 | Battery Warning | Battery low | Plug in soon | dismiss | subtle |

**Keyword examples (for `tapWord` type):**
- Calendar: "SAFE"
- Duolingo: "STREAK"
- etc.

All built-in templates have `isCustom: false`. Users can create custom templates with `isCustom: true`.

### Emergency Number Mapping

Global defaults by region (80+ countries), grouped by emergency number:

```dart
const emergencyNumbers = {
  '112': ['AT', 'BE', 'CH', 'DE', 'DK', 'ES', 'FI', 'FR', 'GR', 'IE', 'IT', ...],
  '911': ['US', 'CA', 'MX', 'AQ', ...],
  '999': ['GB', 'KE', 'UG', 'ZA', ...],
  '000': ['AU'],
  '111': ['NZ'],
  '110': ['CN', 'JP'],
  // ... more
};
```

Falls back to `112` (GSM international standard) for unmapped locales. Users can edit the number before calling.

---

## Migration Strategy

No backwards compatibility is maintained. On schema version mismatch, all Hive boxes are nuked and re-seeded from defaults. User data loss is acceptable during pre-release development.

**On launch:**
1. Try to read `AppSettings.schemaVersion`
2. If it doesn't match `AppConstants.currentSchemaVersion` (5), delete all boxes
3. Re-run `seedDefaults()` to populate fresh data
4. Set `schemaVersion = 5`

---

## Type Safety & Code Generation

All Hive models use code generation via `build_runner`:

```bash
flutter pub run build_runner build
```

This generates `*.g.dart` files with:
- `TypeAdapter<T>` implementations for serialization
- Field mappings for binary format
- Backward compatibility helpers

**Pre-commit hook:** `lefthook` runs import_sorter and lint checks. Pre-push runs `flutter test`.

**After any `@HiveType` or `@HiveField` change:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Encryption & Security

### Key Management

1. **First launch:** Generate random 32-byte AES key
2. **Storage:** Save to platform-native secure storage
   - Android: Android Keystore (requires Google Play Services for hardware-backed keys)
   - iOS: Keychain (automatic encryption at OS level)
3. **Retrieval:** Load from secure storage before opening Hive boxes
4. **No export:** Never write key to file or log

### Secure Storage Implementation

Using `flutter_secure_storage`:

```dart
final secureStorage = FlutterSecureStorage();
final keyString = await secureStorage.read(key: 'hive_encryption_key');
if (keyString == null) {
  // Generate new key on first launch
  final newKey = Hive.generateSecureKey();
  await secureStorage.write(
    key: 'hive_encryption_key',
    value: base64Encode(newKey),
  );
}
```

### Backup Encryption

- **Android Auto Backup:** Hive files already encrypted; Android adds transport encryption
- **iOS iCloud:** Hive files already encrypted; iCloud adds transport encryption
- **Manual export:** Optional encryption of JSON export (not implemented yet, future enhancement)

### Data at Rest

All persistent data encrypted at rest:
- Hive boxes: `HiveAesCipher` with 256-bit key
- Audio files: Innocuous filenames + OS sandboxing
- Photos: App-internal directory + OS sandboxing
- Session logs: Same encryption as other Hive data

---

## Testing & Validation

### Unit Tests

`test/unit/models/` includes:
- **ChainStep tests:** Timing calculations, jitter, config fallbacks
- **SessionMode tests:** Chain validation, check-in type detection
- **EventDefaults tests:** Type-specific config lookups
- **AppSettings tests:** Theme/language/stealth option combinations
- **SessionLog tests:** Event ordering, timestamp validation
- **Hive TypeId test:** All typeIds unique, no collisions

### Integration Tests

`test/integration/` includes:
- **Hive lifecycle:** Open, encrypt, close, re-open
- **Migration:** Schema version bump, data preservation
- **Seed data:** All defaults load, no corruption

### Property-based Tests

Using `proptest` (Dart equivalent) for randomized input validation:
- ChainStep timing always positive, total < max
- SessionMode chain non-empty, typeIds unique
- Contact phone numbers E.164 compliant or gracefully fail

---

## Summary

Guardian Angela's data models prioritize:
- **Security:** Always-encrypted, no opt-out
- **Portability:** Cloud backup + JSON export fallback
- **User control:** Editable modes, custom contacts, rich configuration
- **Data integrity:** Type-safe Hive, migrations, version tracking
- **Privacy:** Local-first, minimal third-party dependencies, transparent logs

All models are immutable where possible, use `copyWith()` for updates, and follow Effective Dart guidelines.
