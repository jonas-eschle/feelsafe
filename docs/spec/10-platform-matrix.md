> **Normative status:** This document is INFORMATIVE. It provides a complete
> platform capability matrix documenting which features work on each platform.
> For normative requirements, see spec documents 00-07.

# 10 - Platform Capability Matrix

Complete feature-by-platform support matrix for Guardian Angela, documenting Android and iOS capabilities, limitations, and permission requirements.

---

## Legend

- **YES**: Feature fully supported, auto-executed
- **PARTIAL**: Feature supported with limitations (documented)
- **NO**: Feature not supported on this platform
- **WARN**: Feature supported but with user-facing warnings
- **Permission**: Required OS permission (blank if none needed)
- **Notes**: Additional context or workaround details

---

## Core Session Features

| Feature | Android | iOS | Permission | Notes |
|---|---|---|---|---|
| Session timer | YES | YES | — | Timers run even when app backgrounded |
| Pause/resume session | YES | YES | — | Preserves exact remaining time |
| Chain | YES | YES | — | All 9 step types supported identically on both |
| Disarm (check-in) | YES | YES | — | Reset chain to step 0 |
| Speed multiplier | YES | YES | — | Simulation: 1–1000x |
| Jitter (±20%) | YES | YES | — | Randomization on timing values |
| Distress chains (hardware panic, duress PIN, wrong PIN) | YES | YES | — | All triggers fire the mode's resolved distress mode (`SessionMode.distressModeId` → `AppDefaults.defaultDistressModeId`) |

---

## Messaging Features

| Feature | Android | iOS | Permission | Notes |
|---|---|---|---|---|
| **SMS Auto-Send** | YES | NO (opens Messages) | SEND_SMS, CALL_PHONE | Android: SmsManager auto-sends. iOS: user must press Send button. Warn iOS users during setup. |
| **SMS Delivery Retry Queue** | YES | NO | SEND_SMS | Android: WorkManager persists retries. iOS: no background retry capability. |
| **WhatsApp/Telegram Deep Link** | PARTIAL | PARTIAL | — | Opens app with pre-filled message. User must press Send. Greyed out if app not installed. |
| **Signal Voice Call Deep Link** | NO | NO | — | Removed: deep links cannot initiate calls, only open chats |
| **SMS Location Link** | YES | YES | — | Google Maps URL embedded in message text |

---

## Phone Call Features

| Feature | Android | iOS | Permission | Notes |
|---|---|---|---|---|
| **Emergency Auto-Dial** | YES | WARN | CALL_PHONE | Android: dials automatically if permission granted. iOS: shows confirmation dialog (tap required). Document as platform limitation. |
| **Phone Call Contact Auto-Dial** | YES | WARN | CALL_PHONE | Same as emergency. Android: automatic. iOS: requires tap. |
| **Phone Call Confirmation Countdown** | YES | YES | — | Optional 5s countdown before dialing (configurable, default ON) |
| **Pre-SMS Before Call** | YES | YES | SEND_SMS | Send brief SMS to contact before calling (configurable, default ON) |
| **Real Incoming Call Detection** | YES | PARTIAL | READ_PHONE_STATE | Android: PhoneStateListener detects and pauses session. iOS: CXCallObserver (only when audio active). |
| **Call Answer Detection** | NO | NO | — | Platform limitation: neither OS provides reliable "did user answer" detection |

---

## Fake Call Features

| Feature | Android | iOS | Permission | Notes |
|---|---|---|---|---|
| **Fake Call Screen** | YES | YES | — | Full-screen call UI matching native style |
| **Ringtone** | YES | YES | — | Platform default ringtone (configurable via callStyle) |
| **Call Styles** | YES | YES | — | android, ios, whatsapp, telegram, signal (all available on both) |
| **Voice Recording Playback** | YES | YES | RECORD_AUDIO | Pre-recorded message plays when "answered" |
| **Vibration During Ring** | YES | YES | — | Realistic phone call vibration pattern |
| **Answer Pauses Escalation** | YES | YES | — | Chain waits for hang-up to trigger disarm |
| **Decline Counts as Miss** | YES | YES | — | Decline increments miss count toward retryCount |
| **Wake Screen on Ring** | YES | YES | — | Full-screen intent (Android), audio session (iOS) |

---

## Notification Features

| Feature | Android | iOS | Permission | Notes |
|---|---|---|---|---|
| **Foreground Service Notification** | YES | — | FOREGROUND_SERVICE | Persistent notification while session active. iOS uses different approach (no persistent foreground service). |
| **Session Notification** | YES | YES | — | "Guardian Angela is active" (or stealth disguised text) |
| **Pause Button on Notification** | YES | PARTIAL | — | Android: full action button support. iOS: requires notification extension (low priority). |
| **I'm Safe Button** | YES | YES | — | Disarm action on notification |
| **Disguised Reminder Notification** | YES | YES | — | Fake notification styled as real app (Calendar, Duolingo, etc.) |
| **Full-Screen Overlay** | YES | YES | — | Fake reminder shows full-screen when app in foreground |
| **Full-Screen Wake on Locked Device (Extra 35)** | YES | YES | USE_FULL_SCREEN_INTENT (Android 14+) | Android: `fullScreenIntent=true` + `Importance.max` + `category=alarm`. iOS: `InterruptionLevel.timeSensitive` on the disguised-reminder notification. Guarantees the reminder surfaces when the device is locked. |
| **Background Notification** | YES | YES | — | System notification shown when app backgrounded |
| **Critical Alerts (Bypass DND)** | YES | YES | Apple entitlement | Android: IMPORTANCE_HIGH channel. iOS: requires special entitlement + Apple approval. Warn users. |
| **SMS Retry Exhausted Notification (Extra 14)** | YES | YES | — | Posted when WorkManager's SMS retry budget is exhausted. "SMS to X never sent — tap to retry manually." |
| **Notification Permission Re-Ask (Extra 42)** | YES | — | POST_NOTIFICATIONS (Android 13+) | Checked during onboarding and again at session start via `ensureNotificationPermission(context)` in `lib/core/utils/permission_utils.dart`. If denied but not permanent, shows a rationale dialog and re-requests. If permanently denied, offers to deep-link to app settings. iOS grants at install time, no re-ask needed. |

---

## Audio Features

| Feature | Android | iOS | Permission | Notes |
|---|---|---|---|---|
| **Loud Alarm** | YES | YES | — | Max-volume siren sound |
| **Gradual Volume Increase** | YES | YES | — | Linear ramp from 0 to target (default 5s per Q33) |
| **System Volume Override** | YES | PARTIAL | — | Android: can set media stream to max. iOS: limited (respects system volume). |
| **Alarm Override Silent Mode** | YES | YES | — | Loud alarm plays even if phone on silent (iOS entitlement). |
| **Custom Alarm Sound** | YES | YES | — | User-recorded audio file or built-in siren (Q9 — `siren`/`custom` only) |
| **Voice Recording Playback** | YES | YES | RECORD_AUDIO | For fake call voice message |
| **Ringtone Style** | YES | YES | — | Platform default or custom asset |
| **Speaker vs. Earpiece** | YES | YES | — | Configurable output routing for fake call voice |

---

## Vibration & Haptics

| Feature | Android | iOS | Permission | Notes |
|---|---|---|---|---|
| **Vibration Pattern** | YES | YES | VIBRATE | Repeating pulses for alarm, continuous for alert |
| **Release Sensitivity Vibration** | YES | YES | VIBRATE | Haptic feedback when hold button release countdown starts |
| **Countdown Warning Vibration** | YES | YES | VIBRATE | Alert vibration during visual countdown |
| **Realistic Call Vibration** | YES | YES | VIBRATE | Matches OS phone call pattern |
| **Haptic Feedback (Advanced)** | YES | PARTIAL | — | Android: simple vibrate. iOS: Engine (haptic patterns) available in iOS 13+, more nuanced control. |

---

## Location Features

| Feature | Android | iOS | Permission | Notes |
|---|---|---|---|---|
| **GPS Recording During Session** | YES | YES | ACCESS_FINE_LOCATION | Periodically log lat/long during session |
| **GPS in SMS Messages** | YES | YES | ACCESS_FINE_LOCATION | Embed Google Maps URL in message |
| **Stale Location Handling** | YES | YES | — | If no fresh GPS: "Last known location at [time]" + accuracy info |
| **No GPS Fallback** | YES | YES | — | If permission denied or no signal: "Location unavailable" in message |
| **Background GPS** | YES | PARTIAL | ACCESS_FINE_LOCATION | Android: full background support. iOS: limited (requires specific permission, only while actively using app or with always-allow). |
| **Location on App Resume** | YES | YES | — | Re-request fresh location when app brought to foreground |

---

## Camera & Flash

| Feature | Android | iOS | Permission | Notes |
|---|---|---|---|---|
| **Camera Flash SOS Pattern** | YES | YES | CAMERA | Strobe camera flashlight in SOS morse (··· −−− ···). Configurable toggle. |
| **Screen Flash** | YES | YES | — | White/red alternating, configurable speed (fast 500ms, slow 1000ms). |
| **Photosensitivity Warning** | YES | YES | — | Warning shown when enabling screen flash. Safe default: slow (1000ms). |

---

## Home Screen Widget

| Feature | Android | iOS | Permission | Notes |
|---|---|---|---|---|
| **Home widget interactivity** | YES | YES (iOS 17+) / PARTIAL (iOS 16) | — | Android: full interactive AppWidget (Quick Exit broadcasts to a Dart interactivity callback, Fake Call deep-links to `/fake-call`). iOS 17+: SwiftUI WidgetKit extension with `AppIntent`-based interactive buttons (`QuickExitIntent`, `FakeCallIntent`). iOS 16 fallback: same widget surface but buttons rendered as `Link(destination:)` deep-links (`guardianangela://quick-exit`, `guardianangela://fake-call`); tapping launches the host app at the appropriate route and the app completes the action. Both platforms ship at v3 GA per spec audit D14. |
| **Status line (live)** | YES | YES | — | `"Idle"`, `"Session active"`, `"Simulation active"` plus an `mm:ss` elapsed timer. Updated on every engine event from `SessionController`. |
| **Quick Exit button** | YES | YES | — | PIN-gated via Session End PIN. Duress PIN fires the distress chain. Widget writes a pending marker; Flutter drains it on next foreground. |
| **Fake Call button** | YES | YES | — | Deep-links to `/fake-call` (GoRouter). On widget→app launch the URI is read via `HomeWidget.initiallyLaunchedFromHomeWidget()`. |

---

## Hardware Buttons

| Feature | Android | iOS | Permission | Notes |
|---|---|---|---|---|
| **Volume Button Detection** | YES | NO | READ_PHONE_STATE | Android: Volume up/down key events intercepted via `dispatchKeyEvent`. iOS: volume buttons not interceptable; greyed out in settings. |
| **Rapid Press Pattern (Android)** | YES | N/A | — | 2–10 presses within window (default 5 presses, 500ms) |
| **Long Press Pattern (Android)** | YES | N/A | — | 1–10 seconds sustained hold (default 2s) |
| **Headphone Remote Button (iOS C1)** | NO | PARTIAL | — | iOS: central play/pause button via `audio_service` `BaseAudioHandler`. Only repeat-press pattern supported (not long-press). Requires wired or Bluetooth headphones with media button. Android headphone remote not implemented (volume buttons preferred). |
| **Headphone Remote — Rapid Press** | N/A | YES | — | iOS only: 2–10 presses of headphone remote within configured window |
| **Headphone Remote — Long Press** | N/A | NO | — | iOS: not supported via `audio_service` media button callbacks (no ACTION_DOWN/UP timing available) |

---

## Background Execution

| Feature | Android | iOS | Permission | Notes |
|---|---|---|---|---|
| **Foreground Service** | YES | Limited | START_STICKY, FOREGROUND_SERVICE | Android: persistent service with notification, auto-restart after kill. iOS: no direct equivalent; uses background modes (audio, location, voip). |
| **Wakelock** | YES | YES | WAKE_LOCK | Keep device awake during session (no screen sleep) |
| **Alarm Manager Watchdog** | DESCOPED | DESCOPED | — | **DESCOPED for GA (M4 C5, 2026-06-09).** A watchdog alarm could only *notify*, never escalate, and a force-stop cancels the app's alarms anyway — so it cannot survive the force-stop it targets. `SCHEDULE_EXACT_ALARM` is no longer declared. Both platforms now detect an interrupted session **only at next launch** via the Session-Interrupted prompt (spec 04 §Extra 13). |
| **Background Timer** | YES | PARTIAL | — | Android: in-process timers kept alive by the foreground service (no AlarmManager). iOS: approximate timers only (OS may delay up to 10 min if device asleep). |
| **App Kill Recovery** | NO (launch-only) | NO (launch-only) | — | **No process resurrection on either platform** — app-death = session gone (session state is in-memory only, lessons-learned §5.2). The foreground service reduces the chance of a kill while backgrounded; once killed, the session is detected only at next launch and surfaced via the Session-Interrupted prompt (spec 04 §Extra 13). |

---

## Biometric & Security

| Feature | Android | iOS | Permission | Notes |
|---|---|---|---|---|
| **Biometric Auth (Fingerprint)** | YES | YES | USE_BIOMETRIC | Unlock app or end session with fingerprint. Fallback to PIN. |
| **Biometric Auth (Face ID)** | NO | YES | USE_BIOMETRIC | Not available on Android (no reliable face recognition API). iOS: full Face ID support. |
| **App PIN** | YES | YES | — | 4–8 digit PIN (length chosen at setup per-PIN; `AppSettings.pinLength` removed) to unlock app at launch. No biometric. |
| **Session End PIN** | YES | YES | — | PIN required to disarm or end active session. Biometric may substitute. 15s timeout. |
| **Duress PIN** | YES | YES | — | Third PIN: enters at any prompt → silently fires the mode's resolved distress mode (`SessionMode.distressModeId` → `AppDefaults.defaultDistressModeId`). No error message shown. |
| **Simulation Mode (SMS/calls blocked)** | YES | YES | — | SMS, phone calls, emergency calls, loud alarm audio, audio recording all blocked / muted (logged as `sim_blocked`). Fake call, vibration, reminders fire normally. |
| **Encryption at Rest** | YES | YES | — | AES-256 via `sqlite3mc` (Drift DB) + AES-256 envelope on JSON-backed singleton/list repositories; encryption key generated on first launch and stored in `flutter_secure_storage` (Android Keystore / iOS Keychain). |

---

## Data Storage & Backup

| Feature | Android | iOS | Permission | Notes |
|---|---|---|---|---|
| **Drift DB (Local Storage)** | YES | YES | — | Typed SQL on top of `sqlite3mc`-encrypted SQLite. Relational data (modes, contacts, templates, session logs). |
| **JSON-backed Repositories (Local Storage)** | YES | YES | — | `JsonSingletonRepository` / `JsonListRepository` for singleton blobs (`AppSettings`, `UserProfile`); always encrypted at rest. |
| **flutter_secure_storage** | YES | YES | — | Secure key storage (Android Keystore / iOS Keychain) |
| **Google Auto Backup** | YES | — | — | Android system backup to Google Drive (encrypted, no code needed) |
| **iCloud Backup** | — | YES | — | iOS system backup to iCloud (user opt-in, automatic) |
| **Manual JSON Export** | YES | YES | — | User-initiated export with optional encryption & media |
| **Manual JSON Import** | YES | YES | — | User-initiated import with merge or replace options |
| **Backup Schema Versioning** | YES | YES | — | Export includes `_schemaVersion`; import validates compatibility |
| **JSON Repository Corruption Recovery (Extra 21)** | YES | YES | — | If `JsonRepositories.init()` throws (e.g., malformed JSON or unreadable encryption envelope), `main()` runs the minimal `JsonRecoveryApp` widget offering "Start fresh" (deletes the JSON directory and re-seeds) or "Restore from backup" (stages a backup file for next launch). After either action, the user relaunches the app to boot into a healthy storage state. |

---

## Accessibility

| Feature | Android | iOS | Permission | Notes |
|---|---|---|---|---|
| **Text Contrast (WCAG AA)** | YES | YES | — | ≥ 4.5:1 (normal), ≥ 3:1 (large text) |
| **System Font Scaling** | YES | YES | — | UI remains usable under system-level text scaling |
| **Semantics Labels** | YES | YES | — | All non-text interactive elements have descriptive labels |
| **Screen Reader (TalkBack)** | YES | — | — | Android screen reader fully supported |
| **Screen Reader (VoiceOver)** | — | YES | — | iOS screen reader fully supported |
| **One-Hand Operation** | YES | YES | — | All critical buttons in reachable bottom third |
| **High Contrast Mode** | YES | YES | — | Support for system high-contrast preference |
| **Reduced Motion** | YES | YES | — | Respect system reduced motion setting (disable animations) |

---

## Internationalization

| Feature | Android | iOS | Permission | Notes |
|---|---|---|---|---|
| **14 Languages** | YES | YES | — | en, de, fr, es, ru, zh_CN, zh_TW, hi, fa, uk, pl, el, ar, he (ARB-based) |
| **RTL Language Support** | YES | YES | — | fa, ar, he supported with `EdgeInsetsDirectional`, mirrored icons |
| **Locale-Aware Emergency Numbers** | YES | YES | — | 80+ country codes mapping; auto-detect from system locale |
| **Locale number / date / time formatting** | YES | YES | — | `intl` package handles locale-aware formatting for the elapsed-time clock and session-log timestamps; currency-symbol formatting is not applicable (the app has no monetary fields). |

---

## Platform-Specific Limitations & Workarounds

### Android Advantages
1. **SMS auto-send**: SmsManager sends directly without user interaction
2. **Full background execution**: AlarmManager, StartSticky service, exact timers
3. **App kill recovery**: Watchdog detects and recovers
4. **Volume button detection**: Fully supported
5. **System volume override**: Can force media stream to max

### iOS Limitations (Documented)
1. **SMS**: Opens Messages app; user must press Send button
2. **Emergency call**: Confirmation dialog required (user must tap)
3. **Volume button detection**: Not supported (volume buttons not interceptable on iOS; greyed out in settings)
4. **Headphone remote**: Partial — only the central play/pause button, only repeat-press pattern, only when headphones are connected (C1)
5. **Background timers**: Approximate only (OS may delay up to 10 min)
6. **App kill detection**: Launch-time only (no background restoration)
7. **No resume after force-close**: Session prompts user on next launch; does not auto-resume (Extra-13)
8. **Foreground service**: No persistent background notification
9. **App permissions**: Cannot be granted programmatically (user goes to Settings)

### Workarounds & Mitigations
1. **iOS SMS limitation**: Educate users during onboarding; show warning before SMS step
2. **iOS call limitation**: Make confirmation countdown prominent; pre-call SMS alerts contact
3. **iOS volume button**: Disable and grey out in settings; document as unsupported
4. **iOS headphone remote (C1)**: Presented as alternative check-in for iOS; requires headphones; warn users in settings
5. **iOS background timers**: Accept approximate timers; avoid long sleep durations
6. **Critical alerts**: Require Apple entitlement request; warn users (may be rejected)

---

## Permission Summary by Platform

### Android Permissions
```
CALL_PHONE              — Make phone calls (auto-dial)
SEND_SMS                — Send SMS messages
READ_PHONE_STATE        — Detect incoming calls, real call detection
RECORD_AUDIO            — Record audio (fake call voice, user recording)
ACCESS_FINE_LOCATION    — GPS recording during session
CAMERA                  — Camera flash SOS pattern
VIBRATE                 — Haptic feedback
WAKE_LOCK               — Keep device awake
FOREGROUND_SERVICE      — Persistent background notification
```

> **Reconciliation note (M4 C5, 2026-06-09): `SCHEDULE_EXACT_ALARM` removed.**
> The AlarmManager watchdog is **DESCOPED** for GA, so this permission is no
> longer declared in `AndroidManifest.xml`. Rationale: a periodic watchdog
> alarm can only *notify* the user — it cannot escalate (send SMS, place
> calls) — and it is itself defeated by the very force-stop it targets (a
> force-stopped app's alarms are cancelled until the user next opens it). The
> foreground service (the persistent session notification) plus the
> Session-Interrupted prompt (detected at next launch, spec 04 §Extra 13)
> cover the realistic kill cases. The design posture is **app-death = session
> gone** (session state is in-memory only, lessons-learned §5.2). Shipping a
> declared-but-unused exact-alarm permission is a Google-Play-review
> liability, so it was removed entirely.

### iOS Permissions
```
Contacts                — Access emergency contact phone numbers
CallKit                 — Real incoming call detection (CXCallObserver)
CoreLocation            — GPS recording
AVFoundation            — Audio (ringtone, alarm, voice recording)
CoreHaptics             — Vibration patterns
UserNotifications       — Local notifications
MediaPlayer             — Audio session management
```

### Permission Handling
- **At app launch**: Request notification permission (required)
- **Before session start**: Request specific permissions for chain steps
- **User can delay**: Some permissions are requested lazily — the OS prompt fires only when the relevant step executes for the first time, not at app launch
- **Settings access**: User can re-grant in app settings or OS settings
- **Battery optimization**: Warn user (don't block) if app not whitelisted

---

## Testing Across Platforms

| Aspect | Testing Approach | Notes |
|---|---|---|
| **Session timers** | Both platforms identically | Same logic, same behavior |
| **Fake calls** | Visual verification | Screenshots for Android and iOS |
| **SMS/calls** | iOS: manual confirmation | Android: auto-send verification |
| **Notifications** | Both platforms | System notification behavior |
| **Background execution** | Android: watchdog only | iOS: launch-time detection |
| **Location** | Both: mock GPS in tests | Real GPS in field testing |
| **Biometric** | Both: biometric mock in tests | Real unlock in manual testing |
| **Camera flash** | Visual inspection | Video record for SOS pattern |

---

## Non-target platforms

v3 GA targets Android (API 26+) and iOS (16.0+) only. The following platforms are explicitly **non-targets**; no code, build configuration, or feature parity is maintained for them in v3.

- **Web.** No SMS / phone-call APIs in browsers; offline-first invariant ill-fits browser sandbox; not a v3 target.
- **macOS / Windows / Linux desktop.** No platform support for the safety-channel features (SMS, phone calls, hardware-button panic, foreground service); not a v3 target.
- **Android Wear / watchOS.** Smartwatch companion check-ins are not part of v3 GA. Reconsider only after v3 GA based on user feedback.

---

## Version Compatibility

| Platform | Minimum Version | Target Version | Notes |
|---|---|---|---|
| **Android** | API 26 (8.0) | API 35 (15) | Google Play compliance; older versions lack notification channels |
| **iOS** | 16.0 | Latest (17+) | Modern notification APIs; older versions lack necessary frameworks |
| **Flutter** | 3.41+ | Latest | Keep within 2 weeks of Flutter release |

---

## Verification Checklist

Before release, verify on both platforms:

- [ ] Session timers run on both platforms
- [ ] Fake call displays full-screen with correct style
- [ ] Alarm plays at max volume
- [ ] Notifications show foreground service (Android) or notification extension (iOS)
- [ ] Biometric unlock works (when set up)
- [ ] GPS records during session
- [ ] Camera flash SOS pattern works
- [ ] Volume button detection works (Android only)
- [ ] App kill detection prompt shows (iOS launch-time)
- [ ] SMS/calls open correct apps
- [ ] All text translates correctly in 14 languages (including RTL: fa, ar, he)
- [ ] Accessibility tested with TalkBack (Android) and VoiceOver (iOS)
- [ ] One-hand operation verified (all critical buttons in bottom third)
- [ ] Emoji and symbols display correctly across platforms

