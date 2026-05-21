> **Normative status:** This document is NORMATIVE. In case of conflict
> with any other document (decisions log, audits, reviews), this document
> takes precedence. Key words "MUST", "SHOULD", "MAY" follow RFC 2119.

# Guardian Angela - Complete Application Specification

## Overview

**Guardian Angela** is a personal safety app for Android and iOS that implements a configurable "dead man's switch" for people walking home alone or in potentially unsafe situations.

**Tagline:** "Your angel's got your back."

**Core idea:** The user starts a session with a chosen mode. The mode defines a chain of safety events. If the user fails to check in, the chain escalates automatically — from subtle reminders to fake calls to alerting emergency contacts to calling emergency services.

---

## App Identity

### Name & Origin

**Guardian Angela** — Wordplay on "guardian angel" + the ["Ask for Angela"](https://en.wikipedia.org/wiki/Ask_for_Angela) safety campaign, a UK-based initiative that provides a discreet way for people in unsafe situations to get help.

### Tagline

"Your angel's got your back."

### Application ID

`com.guardianangela.app`

### Logo & Visual Identity

**Design:** A pride-flag gradient angel with the following elements:
- Feathered wings extending left and right
- Shield body (with cutout gap between wings and shield)
- Golden halo above the head

**Widget reference:** `GuardianAngelaLogo` in `lib/core/theme/guardian_angela_logo.dart`
**Icon generator:** `tool/generate_icon.dart` (regenerates app icon PNGs from source)

### Pride Theme

The pride-flag gradient is **permanent and integral to the app's visual identity**. This reflects the app's commitment to LGBTQ+ safety — the community experiences disproportionately high rates of violence and harassment.

### Welcome Message

When users first launch the app after onboarding, they are greeted with:

> "Hi, I'm Angela."
>
> "I'm your personal guardian. I am a quiet companion who walks with you, watches over your evening out, and knows when to take action if something feels wrong. Start a session, and I'll check in with you. As long as you respond, I stay invisible. If you can't, I'll help you out, be it with a fake call, a message to a friend or alerting the emergency services — whatever the situation necessitates."

---

## Trademark & Legal Notes

### Trademark Risk Assessment

**No exact "Guardian Angela" trademark conflict found** in initial research.

**Medium risk:** "Ask for Angela" is a UK CIC (Community Interest Company) / charity. The app's association with this campaign may trigger trademark or brand association claims, especially if the app becomes commercially prominent.

**Medium-high risk:** Multiple existing "Guardian Angel" safety apps exist on app stores. There is potential for confusion or app store rejection based on similarity of purpose and naming.

### Recommendations

- **Before commercial launch:** Consider reaching out to the Ask for Angela campaign to discuss the app, clarify intent, and potentially negotiate partnership or licensing terms.
- **App store submission:** Prepare clear marketing materials that explain the connection to the "Ask for Angela" campaign and differentiate Guardian Angela's specific features.
- **Legal review:** Consult with app store legal teams and a trademark attorney in target markets (UK, US, EU) before any significant promotion.

---

## Target Users

### Primary Audience

Women walking home at night, on dates, or in unfamiliar situations. Anyone in potentially unsafe situations who wants a discreet, configurable safety companion.

### User Personas

#### 1. Walking Home

**Scenario:** Woman walking home late from work, social event, or night shift.

**Interaction pattern:**
- Opens the app and starts Walk Mode
- Holds the safety button on her phone while walking
- If she's grabbed, assaulted, or drops her phone, the chain escalates automatically
- If she makes it home safely, she confirms and the session ends

**Key needs:** Simple, one-hand operation. Fast escalation. Realistic fake calls to trick an attacker.

#### 2. On a Date

**Scenario:** Woman on a first date or meeting someone from an online app in an unfamiliar location.

**Interaction pattern:**
- Opens the app and starts Date Mode before the date
- Phone stays in her pocket/bag for the duration
- Every 30 minutes (configurable), a disguised reminder appears (looks like a calendar event, Duolingo notification, food delivery alert, etc.)
- She confirms she's OK by interacting with the reminder
- If she misses 2 reminders in a row, the chain escalates
- When the date ends safely, she confirms and the session ends

**Key needs:** Stealth. Disguised notifications that don't look like a safety app. Flexible timing. No visible alerts on lock screen.

#### 3. Power User

**Scenario:** Frequent solo traveler, outdoor enthusiast, or someone managing multiple safety contexts (walking, dating, road trip, late shift, etc.).

**Interaction pattern:**
- Creates custom modes with personalized chains
- May have a "Night Out" mode with 15-minute check-in intervals
- May have a "Road Trip" mode with 1-hour intervals and different emergency contacts
- May have a "Delivery Driver" mode that calls their boss after 2 missed check-ins
- Shares modes with friends or family who face similar risks
- Uses session logs to track patterns and adjust settings

**Key needs:** Full customization. Multiple modes. Import/export. Community sharing. Detailed analytics.

---

## Platform Targets

| Platform | Min Version | Target Version | Status |
|----------|-------------|----------------|--------|
| **Android** | API 26 (Android 8.0) | API 35 (Android 15) | Primary |
| **iOS** | iOS 16.0 | Latest | Primary |
| **Web** | — | — | Not planned |
| **Desktop** | — | — | Not planned |

---

## Core Features

### 1. Dead Man's Switch Engine

A state machine that manages a configurable chain of escalation steps. The engine runs inside the app (no server dependency) and emits events via a `Stream`. Supports:

- **Speed multipliers** for simulation (up to 1000x)
- **±20% timer jitter** to avoid predictable patterns
- **Distress chain replacement** — hardware panic, wrong PIN, or duress PIN stops the main chain permanently and starts the distress chain (no return)
- **Repeat cycles** on reminder steps
- **Graceful degradation** if a service fails (e.g., SMS can't send, escalate anyway)

### 2. Event Types (9 Total)

The app supports 9 distinct event types that can be chained in any order:

| Event Type | Purpose | User Action | Real Action |
|---|---|---|---|
| **holdButton** | Check-in via holding screen | Hold continuously | None (hold timeout triggers escalation) |
| **disguisedReminder** | Fake notification check-in | Interact with disguised notification | None (timeout triggers escalation) |
| **countdownWarning** | Urgent visual/audio warning | Observe and prepare | Visual/vibration/audio countdown |
| **fakeCall** | Fake incoming call to distract attacker | Answer or decline | No actual call (offline capable) |
| **smsContact** | Send SMS/WhatsApp/Telegram message to one or more contacts | App handles automatically | Send message(s) to selected contacts |
| **phoneCallContact** | Call a specific emergency contact | App handles automatically | Dial contact with optional pre-SMS |
| **loudAlarm** | Max-volume siren alarm | User can disarm | Audio alarm + optional camera/screen flash |
| **callEmergency** | Call emergency services (112/911) | App handles automatically | Dial emergency number + optional pre-SMS |
| **hardwareButton** | Panic trigger via physical button | Press volume button pattern | Jump to configured step or escalate |

### 3. Interactive Step Types (2 Primary + 1 Panic)

Each step type is on equal footing in the chain. The two *interactive* types let the user disarm by responding; nothing in the model labels a particular position as "the check-in".

#### Primary Interactive Steps

**Hold Button**
- User holds down a button on screen (typically in bottom third, one-hand accessible)
- Holding silently confirms the user is safe
- Releasing starts a configurable grace period (e.g., 5 seconds)
- If not held again within grace period, the chain advances
- **Configurable:** sensitivity, hold style (`largeButton` / `fullScreen` / `fakeLockScreen`), vibration feedback, sound feedback

**Disguised Reminders**
- Fake notifications styled as real apps: Calendar, Duolingo, food delivery services, etc.
- User must open the notification or swipe/interact within a grace period to disarm
- Full-screen or subtle display styles
- 8 built-in templates + user can create custom ones
- **Configurable:** frequency, templates, grace period, repeat behavior

#### Panic/Escalation Trigger

**Hardware Button** (Android & iOS)
- User can manually escalate the chain by pressing a physical device button
- Android: Volume button
- iOS: Headphone remote button or equivalent
- More discreet than touching the screen
- **Default trigger:** Minimum 5 rapid presses to activate (prevents accidental activation)
- **Configurable:** press pattern (rapid presses, long press, combination), target step

### 4. Simulation Mode

Practice mode for testing entire chains at configurable speed without triggering real actions.

**Simulation is NOT a demo or automated playback.** It is a practice mode where the user interacts with the app exactly as they would in a real session. The purpose is to let users experience the real session flow, practice responding to events (fake calls, disguised reminders, hold button), and verify their chain configuration — all in a safe, no-consequences environment.

- **User interaction required:** The user MUST interact with all user-driven steps exactly as in real mode. If a fake call appears, the user must answer or decline it. If a disguised reminder appears, the user must dismiss it. If the hold button is active, the user must hold it. The chain stalls exactly as in a real session if the user does not interact — there is no auto-advance or automated playback.
- **Speed range:** 1x to 1000x real-time. The speed multiplier allows fast-forwarding through long wait periods (e.g., Date Mode's 30-minute reminder interval) without changing interaction requirements. The "Leap" button skips to 1 second before the next scheduled event.
- **Visual indicator:** Orange border + [SIM] banner always visible on session screen
- **[SIM] badges:** Notifications carry a `[SIM]` suffix; the foreground service title shows "SIMULATION — [mode]"; the fake call screen shows a [SIM] marker in the caller name area.
- **Principle — identical UI for local actions:** Simulation renders the **actual UI** for all local-only events. Specifically: fake call shows the actual call screen with ringtone; countdown warning shows the actual countdown UI with vibration; disguised reminders show the actual full-screen or subtle reminder overlay (not a text toast). The simulation controls bar (speed slider, Leap button, Silent toggle) is overlaid separately at the bottom and never replaces step UI.
- **Silent toggle (per-session, not persisted):** An additional toggle in the simulation controls bar. When ON, all audio is suppressed — ringtones, voice recordings, alarm audio, countdown sounds. Vibration still fires (users can feel haptic feedback). When OFF, audio plays normally for local-only steps (e.g., the fake call ringtone plays). The toggle defaults to ON each session (Extra 49 — silent practice by default) and is never persisted to storage.
- **What fires normally (local-only, silent=OFF):** Fake call screen + ringtone, vibration, countdown warning vibration + UI, foreground notification ([SIM] prefix), disguised reminder overlays and notifications ([SIM] suffix), location/GPS tracking
- **What fires with silent=ON:** All of the above except audio — ringtone suppressed, voice recording suppressed, alarm suppressed, countdown audio suppressed. Vibration and all UI still fire.
- **What is blocked regardless of silent:** SMS / WhatsApp / Telegram messages, phone calls to contacts, emergency calls (911 etc.), audio recording (privacy). Blocked actions show a `[SIM]` informational card instead.
- **Loud alarm:** Always muted in simulation regardless of silent toggle (shown as `[SIM]` card: "Alarm would have sounded at full volume").
- **Defense-in-depth:** 4 layers of protection — engine flag, strategy guard, service parameter, and separate subclasses for real vs. simulated execution. Structurally impossible to reach real SMS/call code.
- **Session End PIN practice:** If Session End PIN is configured, a PIN prompt is shown when the simulation ends (with a "Skip" button). Wrong PINs show a shake animation but do not fire the distress chain or increment the failure counter. This lets the user practice the PIN flow safely.
- **No "Start Real Session" button:** The Simulation Summary screen has no way to convert to a real session. The user must return home and start a real session intentionally.
- **Lenient validation on simulation:** Simulation sessions warn but allow starting even with missing contacts or permissions, letting users test chains without full setup.
- **Smart validation on real sessions:** Real sessions block start only if the chain includes SMS, phone calls, or emergency steps AND zero emergency contacts are configured.
- **Use case:** Users can safely practice a new chain, rehearse their responses, and verify settings without accidentally contacting anyone

### 5. Session Logging & History

Every completed session is logged with:
- **Timestamp** (start and end time, local timezone)
- **Session mode** (which chain was used)
- **Event timeline** (which events were triggered and when)
- **GPS location** (if permission granted) — periodically recorded during session
- **Duration** and **completion status** (ended normally, interrupted, escalated)

The session log captures every event with timestamp, step type, delivery status, and (when enabled) GPS coordinates — the structured timeline replaces ad-hoc screenshot capture, which is explicitly out of scope (resolved as out-of-scope per spec audit G-016).

Users can:
- View past sessions from home screen
- Delete sessions by age or individually
- Share individual sessions via system share sheet (text summary, JSON export, or PDF report)
- Export session logs as JSON or PDF (with location maps)
- Use logs to adjust settings and review past incidents

### 6. Stealth Mode

Stealth mode is configured via `StealthConfig`, a structured set of options (not a flat boolean). Off by default. The global `StealthConfig` lives in `AppDefaults.stealth`; each mode can override via `ModeOverrides.stealth`.

`StealthConfig` fields:
- `enabled` — master toggle
- `fakeName` — fake app name shown in notifications/recents (String)
- `fakeIcon` — `StealthIconPreset` enum picking which generic icon to show
- `notificationDisguise` — `bool` toggling generic channel name/icon
- `timerDisplay` — `normal` / `small` / `none`
- `sessionScreenStealth` — no Guardian Angela branding on session screen

When stealth is active:
- Notifications are disguised (look like calendar events, music player, etc.)
- Session screen uses minimal visual indicators (no branding if `sessionScreenStealth`)
- Timer display governed by `timerDisplay` field

**Use case:** User wants the app on their phone but doesn't want their partner/family/peers to know they're using a safety app.

### 7. Encryption & Data Security

- **At-rest encryption:** Drift database (sqlite3mc) and JSON-backed singletons encrypted with AES-256
- **Encryption key management:** Key stored in platform-secure storage (`flutter_secure_storage`)
- **Backup:** Automatic (Android Auto Backup + iOS iCloud) with encrypted backup key
- **Manual export/import:** JSON format with optional encryption
- **No analytics by default** — local-only data, no tracking or server uploads without explicit user opt-in

### 8. PIN & Biometric Authentication

Three distinct PINs, each with a separate purpose:

- **App PIN** — unlocks the app on open
- **Session End PIN** — required to disarm or manually end a running session; 15-second timeout; biometric may substitute for this PIN only
- **Duress PIN** — entering this at ANY PIN prompt silently fires the selected distress chain and shows a fake "Session ended" to the attacker

All three PINs are configured in **Settings → Security**. Biometric may substitute for the Session End PIN only — NOT for App PIN.

### 9. Distress Modes & Condition-Triggered Events

The engine supports condition-triggered chains. A **distress mode** is a regular `SessionMode` with `isDistressMode = true`; its `chainSteps` are the distress chain. Each regular mode selects one by id (`distressModeId`; `null` = inherit `AppDefaults.defaultDistressModeId`):

- **Distress chain (hardware panic / duress PIN / wrong PIN):** When triggered, enters a 5-second configurable confirmation window. If the user has a PIN configured for cancellation, a PIN prompt is shown; entering the wrong PIN shows a shake but does not cancel. After confirmation completes or the window expires, the engine calls `replaceWithDistressChain(steps, triggerReason: ...)` — the main chain is discarded permanently and the distress mode's chain runs from step 0. When it exhausts, the session ends with the matching `EndReason` (`hardwarePanic` / `duressPin` / `wrongPinExhausted`). The duress-PIN path also shows a fake "Session ended" to the attacker.
- **Triggers (parallel to chain):** Distress and disarm triggers operate independently alongside the main chain, not as chain steps. Per-mode configuration via `distressTriggers` and `disarmTriggers`. Distress triggers: `HardwareButtonDistressTrigger` (≥5 presses). Disarm triggers: `GpsArrivalDisarmTrigger` (geofence arrival), `TimerDisarmTrigger` (explicit expiration). All triggers require confirmation before execution.
- **Disarm during distress is configurable per mode (G-014):** When a distress mode runs (i.e., the engine entered it via `replaceWithDistressChain`), the engine consults `SessionMode.allowDisarmAsDistress` (default `true`) to decide whether `disarmTriggers` still fire. Default `true` honours the user's configured escape conditions (GPS arrival, timer). Setting `false` on a distress mode locks disarm — only chain exhaustion or app/device shutdown stops the session. The trade is recovery convenience vs. coercion resistance. This supersedes the earlier "Disarm during duress: hard-coded IGNORE" invariant.
- **Low battery alert (G-020):** Optionally triggered at configurable battery threshold (e.g., 15%). Fires once per session as a **one-shot side-action** — does NOT pause or interrupt the main chain. Runs on a **separate `SessionEngine` instance** with its own `BatteryAlertController`; both engines register with the **same `SessionLogRecorder`** so the timeline stays unified. Sends alert to emergency contacts while the main chain continues running. Configured via `BatteryAlertConfig` (enabled toggle + thresholdPercent + chain).

### 10. Session End & Quick Exit

Users can end a running session in two ways:

1. **Disarm via Session Screen:** Enter the Session End PIN (if configured) to disarm and end the session. Session data is preserved in encrypted storage for review and police reports.

2. **Quick Exit Button:** Swiftly end the session via home screen widget or home screen button without navigating into the app. Requires Session End PIN (if configured). Session data is preserved in encrypted storage and recoverable when the app is reopened.

Session data is **never deleted** when ending a session early — it remains encrypted on device and can be exported as evidence.

### 11. Home Screen Widget

**Status:** Implemented — Android AppWidget + iOS 17 WidgetExtension with AppIntent-based interactive buttons.

Shipped scope:
- Fake Call button (deep-links to `/fake-call` via GoRouter)
- Current session status (`Idle`, `Session active`, `Simulation active`, `Battery alert` plus `mm:ss` timer)
- Quick Exit button — PIN-gated via the Session End PIN; Duress PIN still fires the distress chain.

Implementation: `home_widget` package (0.9.x) + Android `AppWidgetProvider` (`GuardianAngelaAppWidget.kt`) + iOS WidgetKit extension (`ios/GuardianAngelaWidget/`). On iOS 17+ the buttons use `AppIntent`; on iOS 16 and below the buttons fall back to deep-link URLs. Dart integration lives in `lib/services/implementations/home_widget_service.dart`. See `docs/spec/10-platform-matrix.md` → "Home widget interactivity" for the per-platform capability matrix.

### 12. Session Modes (Presets + Custom)

**Seed Templates (for mode creation only, not stored as modes):**
1. **Walk Mode** — Designed for walking home: hold button check-in, short grace period (Walk Mode seed overrides the default `0s` with `1s`), escalates to fake call (1 attempt) → SMS → phone call to contact → emergency call
2. **Date Mode** — Designed for dating: disguised reminder check-in every 30 min, grace period (2 min), 2 total attempts before escalating to fake call (1 attempt) → SMS → phone call to contact → emergency call

All modes, including those created from seed templates, are equally deletable. Deleted modes can be re-created from their templates at any time.

**User-Created Modes:**
- Created from a seed template ("From Template") or from scratch
- Any combination of the 9 event types
- Fully customizable timing, grace periods, event parameters
- Each mode selects a distress mode by id (`distressModeId`; null = inherit `AppDefaults.defaultDistressModeId`)
- Each mode can override global defaults via `ModeOverrides` (GPS logging, stealth, templates, event defaults)
- Can be shared with friends/family (export/import)

### 13. Internationalization

**14 languages:** English, German, French, Spanish, Russian, Chinese Simplified, Chinese Traditional, Hindi, Farsi, Ukrainian, Polish, Greek, Arabic, Hebrew.

- **ARB format:** Source strings in `lib/l10n/l10n/app_en.arb`; one `app_<lang>.arb` per language
- **Build:** `flutter gen-l10n` generates localization classes
- **Access:** `AppLocalizations.of(context).messageKey`
- **RTL languages:** Farsi (fa), Arabic (ar), Hebrew (he) — use `EdgeInsetsDirectional` and mirrored icons

### 14. Accessibility

- **Text contrast:** ≥ 4.5:1 for normal text, ≥ 3:1 for large text (WCAG 2.1 AA)
- **Font scaling:** UI remains usable under system-level font scaling
- **Semantics labels:** All non-text interactive elements have descriptive Semantics labels
- **Screen reader support:** Tested with TalkBack (Android) and VoiceOver (iOS)
- **One-hand operation:** All critical buttons in reachable bottom third of screen

### 15. Session Locks

During an active session, the following operations are blocked to prevent data corruption or loss of safety context:
- Contact deletion
- Backup import
- Language change
- Schema migration

Users are prompted to end the current session before attempting these operations.

---

## Design Principles

### 1. Safety First

Every design decision prioritizes user safety. This manifests in:
- Real actions (SMS, calls) are **never** simulated — defense-in-depth guards prevent accidental escalation
- Offline-first operation — no dependency on internet or external servers
- Fail loud — if something goes wrong, err on the side of escalating

### 2. Configurable Everything

Users have full control over:
- Chain order and parameters for every event
- Timing, grace periods, and delays
- Which interactive step types to include and how often they fire
- Which contacts receive alerts
- Which event types are enabled
- Simulation speed for testing

Global defaults in Settings; all can be overridden per-chain instance.

### 3. Stealth When Needed

The app must be invisible to others when required:
- Disguised reminders look like real notifications from other apps
- Stealth mode hides all safety indicators
- No app name on notifications
- Fake call screen mimics platform default exactly
- Session can be paused (disguised as "music player")

### 4. One-Hand Operation

Critical interactions work with one hand:
- Hold button in bottom third of screen
- Large tap targets (48 dp minimum)
- Minimal cognitive load under stress
- Haptic feedback for confirmation
- Audio cues for important state changes

### 5. Fail Loud

If the user cannot respond, the app escalates aggressively:
- Grace periods are tight but fair
- Escalation is deterministic — no "maybe this will send an SMS"
- If a service fails (e.g., SMS fails), escalate to the next step anyway
- Session logs record all failures for user review

### 6. Offline-First

The app works completely offline:
- No server dependency for core features
- Fake calls and notifications work without internet
- GPS logging is local (optional upload later)
- Drift (sqlite3mc) database is local
- SMS/calls use platform APIs (require cellular/data)

### 7. Privacy by Default

- **No tracking:** No analytics, no telemetry, no server uploads without explicit opt-in
- **Encrypted storage:** All data encrypted at rest
- **No sharing:** User data is not shared with 3rd parties (except emergency contacts when escalation fires)
- **Transparent:** Clear explanations of what data is collected and why

---

## Technical Stack

### Framework & Language

- **Flutter** 3.41+
- **Dart** 3.11+

### State Management

- **Riverpod** — Provider-based state management with NotifierProvider and AsyncNotifier
  - Controllers manage business logic
  - Providers expose state to screens
  - Testable without widget context

### Navigation

- **GoRouter** — Declarative, deep-linkable routing
  - All routes defined in `lib/router/app_router.dart`
  - Route names in `lib/core/constants/route_names.dart`
  - Query parameter support for dynamic data (e.g., `/contacts/edit?id=123`)
  - First-launch detection routes to onboarding

### Local Storage

- **Drift + sqlite3mc** — Typed SQL on top of encrypted SQLite
  - Always-encrypted via `sqlite3mc` (AES-256, key from `flutter_secure_storage`)
  - Drift data classes generated via `build_runner` (`@DataClassName('Name')` → `*.drift.dart`)
  - Schema versioning handled by Drift's `MigrationStrategy`; pre-alpha policy wipes and re-seeds on mismatch (see 03-data-models.md)
- **JSON-backed singleton/list repositories** — for small blobs (`AppSettings`, `UserProfile`, `BatteryAlertConfig`) outside the relational store; same AES-256 envelope

### Encryption & Security

- **flutter_secure_storage** — Secure key storage (platform-native secure storage)
- **local_auth** — PIN and biometric authentication
- **crypto (Dart)** — For JSON encryption on export

### Internationalization

- **ARB (Application Resource Bundle)** — Flutter's official i18n format
- **intl package** — Runtime translation lookup
- 14 languages: en, de, fr, es, ru, zh, zh_TW, hi, fa, uk, pl, el, ar, he

### Services (Wrappers for Platform APIs)

Exposed as Riverpod `Provider<T>` via `lib/services/service_providers.dart`:

| Service | Purpose | Platforms | Simulation |
|---|---|---|---|
| **AudioService** | Play alarm, fake call audio | Both | Alarm always MUTED (notification shown); ringtone fires normally unless Silent toggle is ON |
| **LocationService** | Periodically log GPS during session | Both | Fires normally (mock data in tests) |
| **MessagingService** | Send SMS / WhatsApp / Telegram | Both | BLOCKED → logged as `sim_blocked` |
| **PhoneService** | Initiate phone calls, emergency calls | Both | BLOCKED → logged as `sim_blocked` |
| **NotificationService** | Send platform notifications | Both | Fires normally ([SIM] / SIMULATION prefix) |
| **VibrationService** | Haptic feedback | Both | Fires normally |
| **WakeLockService** | Keep device awake during session | Both | Fires normally |
| **PermissionService** | Check/request permissions | Both | Real only |

Each service has:
- `executeReal()` — Performs actual platform action
- `simulationDescription()` — Returns string for simulation toast (for blocked actions)

### Testing

- **Unit tests:** `package:test` with `package:checks` for assertions
- **Widget tests:** `package:flutter_test`
- **Integration tests:** `package:integration_test`
- **Test doubles:** Prefer fakes/stubs over mocks; `mocktail` for necessary mocks
- **Timer testing:** `fake_async` with `fakeAsync()` wrapper
- **Determinism:** `_FixedRandom` (returns 0.5) for reproducible SessionEngine tests

### Package Management

- **Package manager:** `flutter pub` / `dart pub`
- **Installation:** `flutter pub add <package>`
- **Lock file:** `pubspec.lock` (version-pinned)
- **Updates:** `flutter pub upgrade`

---

## Architecture Overview

### Logical Layers

```
lib/
├── features/                    # Presentation + Domain
│   ├── session/                # Session management
│   │   ├── session_engine.dart # Pure Dart state machine (no Flutter)
│   │   ├── session_controller.dart # Riverpod controller
│   │   ├── session_screen.dart  # UI
│   │   └── event_strategies/   # Strategy pattern for event types
│   ├── home/                   # Home screen
│   ├── onboarding/             # First-launch flow
│   ├── settings/               # Configuration UI
│   └── ...
├── domain/
│   └── models/                 # Plain Dart classes (Drift data classes + JSON-backed value types)
├── data/                        # Drift database + repositories
│   ├── db/                     # Drift database, DAOs, table definitions
│   ├── repositories/           # Drift-backed repositories + JSON singleton/list repositories
│   └── seed_data.dart          # Built-in modes and defaults
├── services/                    # Platform API wrappers
│   ├── audio_service.dart
│   ├── location_service.dart
│   ├── sms_service.dart
│   └── service_providers.dart  # Riverpod exports
├── router/                      # Navigation
│   └── app_router.dart
├── core/                        # Shared utilities
│   ├── constants/
│   ├── theme/
│   ├── widgets/
│   └── utils/
└── main.dart                    # App entry, initialization
```

### Key Models

| Model | Purpose |
|---|---|
| `SessionMode` | Defines a chain + `distressModeId` + triggers + ModeOverrides. Every step in `chainSteps` is on equal footing; the first step simply runs first. Distress modes are SessionModes with `isDistressMode = true` (Pivot 3). |
| `ChainStep` | One escalation step (9 types). |
| `EmergencyContact` | Contact + messaging channels + per-contact language. |
| `EventDefaults` | Per-step-type default configuration (part of AppDefaults). |
| `SessionLog` | Persisted record of completed sessions; `hadMedicalInfo` flag stamped at session start. |
| `AppDefaults` | Master defaults: gpsLogging, stealth, templates, eventDefaults, `defaultDistressModeId`. |
| `AppSettings` | Three PIN hashes, pinTimeoutSeconds, theme, language, emergencyNumber, alarmDndOverride, biometric / launch-auth / telemetry toggles, alarm gradual-volume settings, AppDefaults. |
| `BatteryAlertConfig` | Low-battery one-shot alert config (enabled toggle + thresholdPercent + chain). |
| `UserProfile` | Identity (name, age, phoneNumber, photoPath, physicalDescription) + free-form medical fields (each `String?`). |
| `WalkSession` | Ephemeral session state (not persisted). Named ctors: `startingReal`, `startingSimulation`. |

### SessionEngine

Pure Dart state machine with no Flutter dependencies:
- Manages timer-driven escalation
- Emits `ChainEventData` via `Stream`
- Supports speed multipliers and jitter
- No side effects (services called by controller)

**Data flow:**
```
HomeScreen → SessionController (Riverpod)
           → SessionEngine (pure Dart)
           → emits ChainEventData Stream
           → SessionController updates WalkSession
           → SessionScreen rebuilds
```

### Event Strategies

Strategy pattern for the 9 step types:
- `EventStrategy` base interface
- 9 implementations (HoldButtonStrategy, DisguisedReminderStrategy, etc.)
- Each has `executeReal()` and `simulationDescription()`
- Registered via `EventStrategyRegistry`

---

## Spec Document Index

| # | Document | Scope |
|---|----------|-------|
| **00** | **Overview** (this file) | App concept, identity, user personas, feature summary, design principles, tech stack |
| **01** | [Chain Engine](01-chain-engine.md) | State machine spec, timing logic, event types, state diagrams, distress chain replacement |
| **02** | [Event Types](02-event-types.md) | Detailed spec for each of the 9 step types |
| **03** | [Data Models](03-data-models.md) | All persistent and ephemeral models, Drift schema, JSON-backed singletons, migrations |
| **04** | [Screens & Navigation](04-screens-navigation.md) | Every screen, user flows, navigation map, routing setup |
| **05** | [Services](05-services.md) | Platform services, real vs simulated execution, permission handling |
| **06** | [Settings & Configuration](06-settings.md) | All configurable options, defaults, stealth mode, export/import |
| **07** | [Test Plan](07-test-plan.md) | Test strategy, test cases, acceptance criteria, coverage targets |
| **08** | [Design Decisions](08-decisions-consolidated.md) | Design decisions log, rationale, trade-offs, alternatives considered |
| **09** | [Glossary](09-glossary.md) | Terminology reference for terms, fields, and concepts used across the spec set |
| **10** | [Platform Matrix](10-platform-matrix.md) | Per-feature Android / iOS capability matrix, permissions, and workarounds |
| **11** | [Enhancement History](11-deferred-enhancements.md) | Historical pointer file — promotion log for former optional add-ons (all now part of normative spec) + rejected enhancements (REJ-1). Zero post-GA features remain. |

---

## Versioning & Compatibility

### Semantic Versioning

- Format: `MAJOR.MINOR.PATCH`
- Starting version: `0.x.y` (pre-alpha, no backwards compatibility guarantees)
- Once `1.0.0` is reached: strict semantic versioning with migration guides for breaking changes

### Data Persistence

- Drift schema versioning via `MigrationStrategy` (current `currentSchemaVersion` tracked in `AppConstants`)
- Migrations handled via Drift's `MigrationStrategy.onUpgrade` callback (pre-alpha policy wipes and re-seeds on mismatch)
- Export/import always available for user data portability

### Platform Support

- Android API 26+ (8.0) supported; target API 35 (15)
- iOS 16.0+ supported
- New Flutter versions tested within 2 weeks of release
- Deprecated dependencies replaced proactively

---

## Legal & Compliance

### Disclaimers

The app **must include prominent disclaimers:**

1. **Not a substitute for emergency services** — This app is a safety tool, not a replacement for calling emergency services. Always call 112 (EU/UK) or 911 (US) if you are in immediate danger.

2. **Recording laws** — Some jurisdictions prohibit recording without consent. Users are solely responsible for compliance with local laws. The app does not provide legal advice.

3. **Privacy & data** — All data is stored locally on device. By using this app, users consent to the automatic backup of encrypted session logs (iOS iCloud, Android Auto Backup) which may be subject to platform policies.

### Before Launch

The following must be completed before app store submission:

- **Privacy Policy** — Clearly state what data is collected, how it's used, and how it's protected
- **Terms of Service** — Standard terms including liability limitations
- **App Store Compliance** — Review both Apple and Google guidelines for safety apps
- **Regional Laws** — Consult with legal in target markets (UK, US, EU) regarding:
  - Recording and wiretapping laws
  - Emergency services integration regulations
  - GDPR/CCPA data protection
  - Accessibility compliance (WCAG 2.1 AA)

### Trademark & Brand

- Reach out to the Ask for Angela campaign before commercial launch
- Do not claim official partnership without explicit agreement
- Be transparent about the app's purpose and limitations

---

## Development & Contribution

### Build Commands

```bash
# Install dependencies
flutter pub get

# Generate Drift companions / *.drift.dart files
flutter pub run build_runner build

# Generate localization files
flutter gen-l10n

# Run app
flutter run

# Run all tests
flutter test

# Strict analysis
flutter analyze --fatal-infos

# Format code
dart format .

# Auto-fix lint issues
dart fix --apply

# Sort imports
dart run import_sorter:main --no-comments
```

### Code Quality

- **Strict linting:** `strict-casts`, `strict-inference`, `strict-raw-types` enabled
- **Git hooks:** `lefthook` runs format + import sort on pre-commit; analyze + test on pre-push
- **CI/CD:** `.github/workflows/ci.yml` enforces format, imports, analysis, tests

### Dependency Policy

- **No EOL or discontinued packages.** A package marked `+eol`,
  `discontinued`, or otherwise officially abandoned by its
  maintainers MUST NOT be a direct or transitive runtime dependency
  of the app. When `flutter pub outdated` flags an EOL package, the
  next reasonable maintenance pass MUST migrate to the upstream
  replacement (or remove the package if unused).
- **Why:** EOL packages stop receiving security fixes, cease
  shipping platform-binary updates, and silently rot the build —
  e.g., the `sqlcipher_flutter_libs 0.7.0+eol` migration to
  `package:sqlite3 ^3.x` with the SQLite3MultipleCiphers build hook
  was driven by this rule.
- **How to enforce:** `flutter pub outdated` is reviewed during
  every dependency upgrade pass; any line tagged `+eol` or marked
  `discontinued` is treated as a release-blocker for the next
  maintenance commit, not a "later" item.

### Documentation

- Add `///` doc comments to all public APIs
- First sentence: concise, user-centric summary
- Comment **why**, not **what**
- Use backtick fences with language identifier for code samples

---

## Seed Data

`lib/data/seed_data.dart` provides:

1. **2 built-in modes:**
   - Walk Mode (hold button, 1-sec grace as a Walk Mode seed override of the default `0s`, escalates to fake call → SMS → phone contact → emergency call)
   - Date Mode (disguised reminders, 30-min intervals, 2-min grace, 2 attempts, escalates to fake call → SMS → phone contact → emergency call)

2. **8 built-in reminder templates** (canonical names per spec 03 §ReminderTemplate):
   - Calendar Event, Language Lesson, Delivery Update, Weather Alert, Fitness Reminder, Message Preview, App Update, Battery Warning

3. **1 default distress mode:**
   - Default distress mode: a `SessionMode` with `isDistressMode = true` whose chain is Step 1 — `smsContact` with `contactSelection: firstContact` (location SMS to the first emergency contact) → Step 2 — `callEmergency` (call emergency services with `sendLocationSmsFirst = true`). Its id is stored in `AppDefaults.defaultDistressModeId` and used whenever `SessionMode.distressModeId` is null.

4. **Per-step-type event defaults:**
   - Default grace periods
   - Default timing
   - Default contact selection
   - Default message templates

All defaults live in `AppDefaults` (Settings → Defaults). Each mode can override any individual default via `ModeOverrides`. Mode-local reminder templates are appended to global templates (not replacing them).

---

## Success Criteria

The Guardian Angela app is considered complete and production-ready when:

- **API coverage:** 100% of spec documented
- **Code coverage:** ≥ 85% unit test coverage, all critical paths covered
- **Integration tests:** All major user flows (onboarding, start session, escalate, end session) pass
- **Performance:** App launch < 3 seconds, session engine latency < 500 ms
- **Accessibility:** WCAG 2.1 AA compliance verified
- **Localization:** All 14 languages translated and reviewed by native speakers
- **Security:** Penetration test passed, encryption verified
- **User feedback:** ≥ 4.5/5 star rating in app store reviews
- **Documentation:** All code documented, spec complete, runbook for maintainers

---

## Next Steps

1. **Finalize trademark:** Reach out to Ask for Angela campaign
2. **Legal review:** Consult with app store legal teams and trademark attorney
3. **Accessibility audit:** Test with accessibility tools and real users
4. **Beta testing:** Recruit 50+ beta testers from target demographics
5. **App store submission:** Follow Apple and Google review processes
6. **Launch:** Market to safety organizations, women's groups, LGBTQ+ communities

---

**Document generated:** 2026-04-02  
**Status:** Complete specification ready for implementation
