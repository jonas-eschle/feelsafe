> **Normative status:** This document is INFORMATIVE. It provides a complete
> glossary of terminology used throughout the specification. In case of
> conflicting definitions, the normative spec documents (00-07) take precedence.

# 09 - Glossary & Terminology Reference

Complete reference of all terms, variable names, and concepts used in Guardian Angela specification.

---

## Core Concepts

| Term | Definition | Code Name | Used In | Example |
|---|---|---|---|---|
| **Check-in** | User action proving safety. Resets chain to step 0, clears miss count. User-facing term. | `checkIn()`, `disarm()` | UI, notifications, user docs | "Tap to check in" |
| **Disarm** | Engine-internal synonym for check-in. Resets chain to step 0. | `disarm()` | SessionEngine, SessionController | Engine emits `userDisarmed` event |
| **Miss** | Grace period expired without user response. Increments toward retry limit. | `missCount`, `_missedRepeats` | SessionEngine, session logs | "Missed: 2" on session screen |
| **Escalation** | Advancing to the next (more urgent) step after retries exhausted. | `stepAdvancing`, `advanceToNext()` | Chain engine, event stream | After 3 missed reminders, escalate to phone call |
| **Retry Count** | Max retry attempts before advancing. N retries = N+1 total attempts. | `retryCount` | ChainStep field, settings | `retryCount=2` means 3 total attempts (initial + 2 retries) |
| **Grace Period** | Dead time after event, user can still check in. | `gracePeriodSeconds` | ChainStep field, settings | User has 5 seconds after alarm stops to say "I'm OK" |
| **Wait Time** | Delay before event fires. 0 for most steps. Interval for reminders. | `waitSeconds` | ChainStep field, settings | Reminder fires every 30 min (waitSeconds=1800) |
| **Duration** | How long the event actively runs. | `durationSeconds` | ChainStep field, settings | Fake call rings for 30 seconds (durationSeconds=30) |
| **Session** | An active safety monitoring period from start to end/exhaustion. | `WalkSession` (ephemeral), `SessionLog` (persisted) | Engine, UI, repository | User starts session at 8:00pm, ends at 9:15pm |
| **Chain** | Ordered list of steps that fire sequentially during a session. | `chainSteps` | SessionMode, SessionEngine | "Walk Mode" has 3 steps: holdButton → fakeCall → loudAlarm |
| **Step** | One action in the chain (e.g., fake call, SMS, alarm). | `ChainStep` | Data model, settings | Step 2 is a fake call with 30s ring time |
| **Event** | Something that happens during a session (stepStarted, miss, disarm, etc.). | `ChainEvent`, `ChainEventData` | SessionEngine event stream | Engine emits `reminderFired` event when reminder shows |
| **Distress Chain** | The `chainSteps` of a distress mode that REPLACE the main chain when triggered. Never returns. | (no separate model — uses `SessionMode` with `isDistressMode = true`) | SessionMode (`distressModeId`), AppDefaults (`defaultDistressModeId`) | Duress PIN triggers distress chain (SMS all contacts + call 911) |
| **Jitter** | ±20% randomization on timing values. | `randomize`, `_shouldRandomize()` | ChainStep field, engine | 30s reminder interval ±20% = 24–36s |
| **Speed Multiplier** | Divides all timer durations (for simulation). | `speedMultiplier` | SessionEngine constructor, simulation UI | 10x speed makes 30s timer run in 3s |
| **Stealth Mode** | Hides all safety indicators, disguises app as music player. Configured via `StealthConfig`. Global in `AppDefaults.stealth`; override per-mode via `ModeOverrides.stealth`. | `StealthConfig`, `AppDefaults.stealth` | AppSettings, ModeOverrides | Notification says "Music playing" instead of "Safety active" |
| **Sensitivity** | Delay after hold button release before countdown starts. Prevents accidental triggers. | `releaseSensitivity` | holdButton config | User's brief 0.5s finger twitch ignored; re-hold starts countdown |

---

## Interactive Step Types

These step types let the user disarm the chain by responding. Any step type can appear anywhere in the chain — nothing labels one as "the check-in".

| Term | Definition | Code Name | Used In | Example |
|---|---|---|---|---|
| **Hold Button** | User holds the screen while the step is active. Releasing starts the grace period. | `ChainStepType.holdButton` | Any chain position, settings | User holds phone while walking |
| **Disguised Reminder** | Fake notification styled to look like a real app (Calendar, Duolingo, etc.). Tapping it disarms. | `ChainStepType.disguisedReminder` | Any chain position | "Meeting in 15 min" notification disarms when tapped |
| **Hardware Button** | Physical device button press (volume, headphone remote). | `ChainStepType.hardwareButton` | Any chain position; also a global panic trigger | Volume button + 5 rapid presses = escalate |
| **Panic Trigger** | Hardware button configured to manually escalate or jump to a specific step. | `hardwareButton` with `targetStep` | Settings config | Volume button holds → jump to "Call Emergency" step |

---

## Event Types (Escalation Steps)

| Term | Definition | Code Name | Used In | Example |
|---|---|---|---|---|
| **Count Down Warning** | Visual countdown (e.g., "Emergency in 10s"). Warning before serious action. | `ChainStepType.countdownWarning` | Chain | "Emergency call in 10 seconds" with vibration |
| **Fake Call** | Phone rings with caller ID spoofed to trusted contact. User can answer or decline. | `ChainStepType.fakeCall` | Chain | "Incoming call from Angela" screen mimics real call |
| **SMS Contact** | Sends SMS to configured emergency contact with location/message. | `ChainStepType.smsContact` | Chain | Auto-sends "I may need help. Location: [maps link]" |
| **Phone Call Contact** | Auto-initiates call to emergency contact. | `ChainStepType.phoneCallContact` | Chain | Dials friend's number; can answer and talk |
| **Loud Alarm** | Device plays loud alarm sound. Disarmable by swiping slider or tapping stop button. | `ChainStepType.loudAlarm` | Chain | Siren blasts at max volume, wakes attention |
| **Call Emergency** | Calls emergency number (999/911/112). Requires explicit confirmation before placing call. | `ChainStepType.callEmergency` | Chain, terminal step | Dials 911 after 5s confirmation countdown |

---

## Data Models & Persistence

| Term | Definition | Code Name | Used In | Example |
|---|---|---|---|---|
| **Session Mode** | Defines a chain of ChainSteps + `distressModeId` + triggers. Every step in `chainSteps` is on equal footing; the first step simply runs first. Distress modes are SessionModes with `isDistressMode = true`. May have per-mode `ModeOverrides`. | `SessionMode` | modes.json, settings, home screen | "Walk Mode": holdButton first, then fake call → alarm → emergency |
| **Chain Step** | One escalation step with timing, config, and type. | `ChainStep` | SessionMode, settings, engine | Fake call step: 30s ring, 5s grace, 2 retries |
| **Emergency Contact** | Named contact with phone + enabled messaging channels. All enabled channels are used (no single preferred channel). Includes `languageCode` and `relationship`. | `EmergencyContact` | Drift `contacts` table, settings, SMS/call services | "Alice" — SMS + WhatsApp enabled |
| **Event Defaults** | Global per-step-type configuration defaults. | `EventDefaults` (embedded in `AppDefaults`) | JSON singleton (in `app_settings.json`), settings | Default fake call: 30s ring, Android native style |
| **Session Log** | Persisted record of completed sessions with events, timing, GPS location. | `SessionLog` | Drift `session_logs` table, history screen | "Walk home - 45 min - 2 missed reminders" |
| **App Settings** | Global app configuration (theme, language, three PIN hashes, `AppDefaults`, etc.). | `AppSettings` | JSON singleton `app_settings.json`, settings screens | `appPinHash=...`, `languageCode='de'`, `defaults=AppDefaults(...)` |
| **Walk Session** | Ephemeral (non-persisted) session state object. | `WalkSession` | SessionController, UI | Current step=1, missCount=1, elapsed=2m30s |
| **Reminder Template** | Disguised notification design (Calendar Event, Language Lesson, Delivery Update, …). `isGlobal=true` if from AppDefaults; `isGlobal=false` if mode-local. | `ReminderTemplate` | Drift `reminder_templates` table, settings | Template ID `language_lesson`: "Time for a lesson!" with a language-app icon |
| **Distress Mode** | A `SessionMode` flagged with `isDistressMode = true`; its `chainSteps` are the distress chain. | `SessionMode` (with `isDistressMode = true`) | modes.json, AppDefaults.defaultDistressModeId | Default distress mode: SMS + call emergency |
| **App Defaults** | Master defaults for all modes: gpsLogging, stealth, templates, eventDefaults, defaultDistressModeId. Modes inherit and may override per-field. | `AppDefaults` | AppSettings.defaults | Global GPS interval=30s, stealth disabled |
| **Mode Overrides** | Per-mode optional override of any AppDefaults field. null field = inherit from AppDefaults. `localTemplates` appended to global templates. | `ModeOverrides` (inline in SessionMode) | SessionMode.overrides | Override stealth for Walk Mode only |
| **GPS Logging Config** | Structured GPS logging settings: enabled, intervalSeconds, accuracy (D-DATA-22 trim). | `GpsLoggingConfig` (inline in AppDefaults/ModeOverrides) | AppDefaults.gpsLogging, ModeOverrides.gpsLogging | interval=30s, accuracy=high |
| **Stealth Config** | Structured stealth settings: enabled, fakeName, fakeIcon, notificationDisguise, timerDisplay, sessionScreenStealth. | `StealthConfig` (inline in AppDefaults/ModeOverrides) | AppDefaults.stealth, ModeOverrides.stealth | fakeName="Music App", timerDisplay=none |

---

## Messaging & Contacts

| Term | Definition | Code Name | Used In | Example |
|---|---|---|---|---|
| **SMS Delivery Queue** | Persistent background retry for SMS when no signal. Separate from step retries. | WorkManager, MessagingService | Background service, SMS step | SMS queued when offline, delivered when signal returns |
| **Priority Contact** | Primary emergency contact, shown first in contact list. | `isPrimary` | EmergencyContact field, home screen | Alice (primary) vs. Bob (secondary) |
| **Message Template** | Customizable message with placeholder variables for SMS/messaging. | `messageTemplate` | smsContact config, settings | "I may need help. Location: {location}. Description: {description}" |
| **Messaging Channel** | Method to send message: SMS, WhatsApp, Telegram, Signal, etc. | `channel` | EmergencyContact, smsContact config | SMS channel: auto-send (Android) or opens Messages app (iOS) |
| **Pre-SMS (emergency only)** | Brief location SMS sent to contacts before dialing emergency services. Lives only on `CallEmergencyConfig.sendLocationSmsFirst` (Q12 — removed from `phoneCallContact`). | `sendLocationSmsFirst` | callEmergency config | "I may be in danger, calling 112 now." |

---

## Audio & Vibration

| Term | Definition | Code Name | Used In | Example |
|---|---|---|---|---|
| **Ringtone** | Phone call audio that loops until stopped. | `playRingtone()`, `AudioService` | fakeCall step | iPhone default ringtone loops during fake call |
| **Alarm Sound** | Siren audio for loudAlarm step. Plays at the configured `LoudAlarmConfig.volume`; only reaches max system volume when `AppSettings.alarmDndOverride = true` (opt-in, default `false`). | `playAlarm()`, `AudioService` | loudAlarm step | Continuous siren sound plays at the configured volume |
| **Voice Recording** | Audio message played when fake call is answered. | `voiceRecordingPath`, `playVoiceRecording()` | fakeCall config | "Hey, it's Angela, just checking in..." message |
| **Vibration Pattern** | Haptic feedback sequence (short pulses, long vibrations, etc.). | `vibrateOnRelease`, `VibrationService` | holdButton, countdownWarning, loudAlarm | Vibrate on button release, alarm vibration pattern on loudAlarm |

---

## Location & Logging

| Term | Definition | Code Name | Used In | Example |
|---|---|---|---|---|
| **GPS Location** | User's geographic coordinates recorded during session. | `LocationService`, `recordLocation()` | SessionLog, smsContact | "Last known location at 8:45pm: 40.7128, -74.0060" |
| **Location Recording** | Optional logging of GPS coordinates during session events. Configured via `GpsLoggingConfig`. | `GpsLoggingConfig`, `AppDefaults.gpsLogging` | AppSettings, ModeOverrides, LocationService | Interval=30s, accuracy=high |
| **Maps URL** | Google Maps link embedded in SMS messages. | `{location}` placeholder | Message templates, smsContact | "https://maps.google.com/?q=40.7128,-74.0060" |
| **Session Timeline** | Chronological record of all events during session. | `SessionLog.events` | Session logs, history detail | 8:00pm: session start, 8:15pm: reminder fired, 8:20pm: user disarmed |

---

## UI & UX Terms

| Term | Definition | Code Name | Used In | Example |
|---|---|---|---|---|
| **Disarm Slider** | "I'm Safe" gesture control: swipe left-to-right to confirm safety. | Slider widget in session screen | Session screen, notifications | User swipes slider to reset chain |
| **Grace Visual** | On-screen countdown shown during grace period. | Grace phase UI, session screen | countdownWarning, session screen | "10... 9... 8..." countdown before escalation |
| **Progress Bar** | Visual representation of session state with pride-flag gradient. | `_buildProgressBar()` | Session screen | Bar fills/empties showing step progression |
| **Missed Counter** | Badge showing "Missed: N" reminders/checks. | "Missed: N" label | Session screen | "Missed: 2" — user failed 2 checks in a row |
| **Step Indicator** | Visual label showing current step number and type. | Step number + icon | Session screen, mode editor | "Step 2: Fake Call" |
| **Confirmation Countdown** | Brief countdown before critical action (e.g., emergency call). | `callEmergency` with `showConfirmation=true` | Emergency call step | "Calling 911 in 5... 4... 3..." |

---

## Platform-Specific Terms

| Term | Definition | Code Name | Used In | Example |
|---|---|---|---|---|
| **Full-Screen Intent** | Android API to display call-like screen in foreground. | `foregroundIntent`, `PendingIntent` | Fake call Android implementation | Fake call shows full-screen over lock screen |
| **Foreground Service** | Android background process with persistent notification. | `START_STICKY`, notification channel | Session background execution | Session notification remains visible while app backgrounded |
| **Wake Lock** | Prevents device sleep during session. | `WakeLockService`, `wakelock` package | Session management | Device stays awake even if screen auto-locks |
| **App Kill Detection** | Android watchdog to detect when app is killed by OS. | AlarmManager, periodic alarm | App kill detection | Alarm fires every 3 min; if app is dead, shows notification |
| **Call Observer** | iOS API to detect incoming phone calls. | `CXCallObserver` | Real phone call detection | App pauses session when real call arrives |
| **Biometric Auth** | Fingerprint or Face ID authentication. | `local_auth` package | App lock, session end | User unlocks app with fingerprint instead of PIN |
| **Drift** | Typed SQL ORM for Flutter; generates code from table definitions. | `drift`, `drift_dev` | Data persistence | `EmergencyContact` table queried via `db.contactsDao.watchAll()` |
| **sqlite3mc** | SQLite3 Multiple Ciphers — the encrypted SQLite engine backing Drift. | `sqlite3` package with sqlite3mc build hook, `flutter_secure_storage` | Data persistence | Drift database file encrypted at rest with AES-256 |

---

## Localization & Internationalization

| Term | Definition | Code Name | Used In | Example |
|---|---|---|---|---|
| **ARB Format** | Application Resource Bundle—Flutter's standard for translations. | `.arb` files, `intl` package | Localization setup | `lib/l10n/app_en.arb`, `app_de.arb`, etc. |
| **Locale** | Language + region code (e.g., en_US, de_DE). | `Locale`, `AppLocalizations` | Language selection, i18n | User selects "Deutsch (DE)" locale |
| **Placeholder** | Text variable in localized string (e.g., {name}, {location}). | `{variable}` | Message templates, localization | "Hello {name}" → "Hello Alice" when rendered |
| **Native Speaker Review** | Human translation verification by fluent speaker. | Translation QA, user testing | Languages (de, fr, es, ru) | Native German speaker reviews all German strings |

---

## Testing & Simulation

| Term | Definition | Code Name | Used In | Example |
|---|---|---|---|---|
| **Simulation Mode** | Special app mode allowing testing without real actions (SMS, calls, alarms). | `isSimulation=true` | SessionEngine, home screen | "SIMULATION" banner shown; toasts instead of sending SMS |
| **Speed Bar** | UI slider to control simulation speed (1x–1000x). | Speed multiplier UI, `setSpeedMultiplier()` | Simulation screen | Drag to 10x: 30s timer runs in 3s |
| **Leap Button** | "Skip to next event" feature in simulation. | `leap()` (API name; UI label is "Leap >>") | Simulation UI | Fires the active phase timer immediately, collapsing remaining duration to zero |
| **Test Case** | Individual unit/widget/integration test with arrangement, act, assert. | Test function in `test/` directory | Test suite | `test('hold button: grace expires → advance')` |
| **Deterministic Random** | Fixed random number generator for reproducible tests. | `_FixedRandom(0.5)` | SessionEngine tests | Always returns 0.5 → jitter factor = 1.0 (no actual jitter) |
| **Fake Async** | Wrapper for controlled timer testing without real delays. | `fakeAsync()`, `async.elapse()` | Timer tests | Test progresses through timers in milliseconds |

---

## Settings & Configuration

| Term | Definition | Code Name | Used In | Example |
|---|---|---|---|---|
| **Global Defaults** | App-wide defaults for all configurable options (GPS, stealth, templates, event defaults, distress chains). Stored in `AppDefaults`. | `AppDefaults`, `EventDefaults` | Settings > Defaults | GPS interval=30s, stealth disabled |
| **Per-Step Override** | Configuration specific to one step in one chain. | `ChainStep.config` | Mode editor | This specific fake call: 60s ring, WhatsApp style |
| **App PIN** | PIN to lock app at launch (before home screen). No biometric. | `appPinHash`, AppSettings | Settings > Security | User must enter PIN to open app |
| **Session End PIN** | PIN required to disarm or end an active session. Biometric may substitute. 15s timeout (`pinTimeoutSeconds`). | `sessionEndPinHash`, AppSettings | Settings > Security | User must enter PIN to stop active session |
| **Duress PIN** | Third PIN that silently fires the selected distress chain when entered at any prompt. No error message shown. | `duressPinHash`, AppSettings | Settings > Security | Entering duress PIN secretly escalates while appearing to comply |
| **distressModeId** | Field on `SessionMode` referencing another `SessionMode` (with `isDistressMode = true`) by id. null = inherit `AppDefaults.defaultDistressModeId`. | `distressModeId` | SessionMode | distressModeId="aggressive-distress" selects the named distress mode |
| **sim_blocked** | Log status for actions blocked in simulation mode (SMS, calls, emergency call, audio recording). | `SessionLogEvent.deliveryStatus` | Session log, simulation | SMS not sent in simulation; logged as sim_blocked |
| **isGlobal** | Field on `ReminderTemplate`. true = from AppDefaults (global); false = mode-local (in ModeOverrides.localTemplates). | `ReminderTemplate.isGlobal` | Templates list | Global templates shown in all modes; local appended per-mode |
| **System Permissions** | OS-level access grants (SMS, calls, location, audio, camera, etc.). | `PermissionService` | Permission handling, session start | User grants CALL_PHONE permission during onboarding |
| **Feature Flag** | Toggle to enable/disable a feature without code changes. | Optional in settings | Feature rollout | "Enable real call detection" toggle |

---

## Error Handling & Recovery

| Term | Definition | Code Name | Used In | Example |
|---|---|---|---|---|
| **Non-Blocking Failure** | Action fails (e.g., SMS doesn't send) but chain continues. | `nonBlockingOnFailure`, step config | Event execution | SMS fails → logged as failure → grace continues → chain advances on time |
| **Watchdog** | Background alarm that detects app being killed by OS. | AlarmManager (Android), periodic task | App kill detection | Alarm fires every 3 min; if app dead, shows notification |
| **Fail Loud** | Design principle: errors cause escalation rather than silent failure. | Engine design, guards | Session engine | SMS service fails → log failure → continue to next step |

---

## Brand & Legal

| Term | Definition | Code Name | Used In | Example |
|---|---|---|---|---|
| **Ask for Angela** | UK safety campaign; inspiration for "Guardian Angela" name. | Trademark context | App branding, legal notes | Ask for Angela CIC should be contacted before commercial launch |
| **Guardian Angela** | App name; wordplay on "guardian angel" + "Ask for Angela". | `com.guardianangela.app` | App identity, branding | Official name for app store listings |
| **Pride Branding** | Permanent, mandatory visual identity using pride-flag gradient. | Logo, colors, theme | App identity, design | Angel logo with pride-flag gradient (non-negotiable) |
| **Disclaimer** | Legal notice that app is not a substitute for emergency services. | Privacy policy, onboarding | Legal compliance | "This app is a safety tool, not a replacement for calling 911." |
| **Locale-Aware Emergency Number** | 80+ country codes mapping to correct emergency number. | `emergencyNumberMap` | callEmergency step, settings | France → 112, US → 911, UK → 999 |

---

## Architecture & Design Patterns

| Term | Definition | Code Name | Used In | Example |
|---|---|---|---|---|
| **Pure Dart State Machine** | Engine with no Flutter dependencies; testable in isolation. | `SessionEngine` | Engine architecture | Engine logic tested without UI framework |
| **Strategy Pattern** | 9 step type implementations with common interface. | `EventStrategy` base class | Event execution | FakeCallStrategy, LoudAlarmStrategy, etc. |
| **Riverpod Provider** | Reactive dependency injection for services and controllers. | `Provider<T>`, `NotifierProvider` | State management | `audioServiceProvider`, `sessionControllerProvider` |
| **GoRouter** | Declarative routing with deep linking support. | `GoRouter`, `GoRoute` | Navigation | `/modes/edit?id=123` → ModeEditorScreen with ID |
| **Drift Table** | Typed SQL table with code-generated Dart data class via `@DataClassName('Name')`. Canonical persistence layer for relational data. | `@DataClassName('SessionMode')`, `appDatabase.sessionModesDao` | Data persistence | All session modes stored in the `session_modes` table |
| **JSON-backed Singleton/List Repository** | Encrypted JSON blob stored under the app documents directory; used for small singletons (`AppSettings`, `UserProfile`) and lightweight lists. | `JsonSingletonRepository`, `JsonListRepository` | Data persistence | `AppSettings` lives in `app_settings.json` |
| **Feature-First Architecture** | Code organized by feature (session, home, settings) not by type (models, views). | `lib/features/` folder | Project structure | `lib/features/session/`, `lib/features/home/`, etc. |

---

## Version & Compatibility

| Term | Definition | Code Name | Used In | Example |
|---|---|---|---|---|
| **Schema Version** | Version number for the Drift schema (`schemaVersion` on `GuardianAngelaDatabase`) plus the `_schemaVersion` integer written into JSON export blobs. | `schemaVersion`, `_schemaVersion` | Data migrations | Current schema: tracked in `AppConstants.currentSchemaVersion` |
| **MigrationStrategy** | Drift's mechanism for handling schema upgrades. Pre-alpha policy wipes-and-reseeds on mismatch rather than running stepwise migrations. | `MigrationStrategy.onUpgrade` | `lib/data/db/app_database.dart` | Schema mismatch → `nukeAndReseed()` |
| **Semantic Versioning** | Version format: MAJOR.MINOR.PATCH (e.g., 1.0.0). | `pubspec.yaml` | App versioning | 0.x.y pre-release; 1.0.0+ stable |
| **Minimum SDK** | Oldest OS version supported. | Android API 26, iOS 16.0 | Platform targets | App requires Android 8.0+ or iOS 16.0+ |

