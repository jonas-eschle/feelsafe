> **Normative status:** This document is NORMATIVE. In case of conflict
> with any other document (decisions log, audits, reviews), this document
> takes precedence. Key words "MUST", "SHOULD", "MAY" follow RFC 2119.

# 04 - Screens & Navigation Specification

## Overview

This document specifies every screen in Guardian Angela, navigation flows between screens, route definitions, and detailed UI/UX design for each screen. The app supports deep linking via query parameters and implements first-launch detection to route users to onboarding.

### Settings navigation convention

The `/settings` hub shows only the two most-changed controls — **Theme** and **Language**. Every other setting is a tappable subcategory row that navigates to its own dedicated screen (no inline accordions, no second-level hubs). This replaces the former `/settings/defaults` and `/settings/modes-and-chains` sub-hubs with a flat list of per-category routes. See `06-settings.md` for the full subcategory list and the detailed UI of each screen.

---

## Navigation Map

```
┌─────────────────────────────────────────────────────────────┐
│                    App Launch                               │
│                         │                                   │
│                         v                                   │
│                  ┌──────────────┐                           │
│                  │ First Launch? │                           │
│                  └──────┬───────┘                            │
│                         │                                   │
│              ┌──────────┴──────────┐                        │
│              │                     │                        │
│              v                     v                        │
│          Onboarding (3 screens)  Home Screen               │
│              │                     │                        │
│              └──────────┬──────────┘                        │
│                         │                                   │
│                         v                                   │
│                   ┌─────────────────────────────────────┐   │
│                   │          Home Screen (/)            │   │
│                   │  - Mode Selector                    │   │
│                   │  - Contact Chips                    │   │
│                   │  - Start Session / Simulate         │   │
│                   │  - AppBar: Contacts, History, Sett │   │
│                   └─┬──────────────┬──────────┬────────┘   │
│                     │              │          │             │
│          ┌──────────┴──┐  ┌────────┴──┐  ┌───┴──────┐     │
│          │             │  │           │  │          │     │
│          v             v  v           v  v          v     │
│      Session        Fake Call   Contacts History  Settings│
│       Screen        Screen      Screen   Screen    Screen │
│         │             │           │       │          │    │
│         │             │           │       │    ┌─────┴────┤
│         │             │           │       │    │          │
│    ┌────┴───────┐     │      ┌────┴───┐   │    │    ┌─────┴─────┐
│    │            │     │      │        │   │    │    │           │
│    v            v     │      v        v   v    v    v           v
│  Chain      Simulation │   Contact  Session Profile Event      Settings
│ Exhausted   Summary   │   Form     Log     Editor Defaults     Hub
│ Screen      Screen    │   Screen   Detail  Screen Screen       Screen
│             │         │   Screen   Screen        │             │
│             └──────┬──┘           │             ┌┴──────────┐  │
│                    │              │             │           │  │
│                    v              v             v           v  v
│                 Home           Home        Event Default   About
│                              Defaults/    Detail Config    Screen
│                              Date        Screen
│                              ───────────────────────────────────
│                                                │           │
│                                                v           v
│                                        Modes Screen  Feedback
│                                              │        Screen
│                                              │
│                                       ┌──────┴──────┐
│                                       │             │
│                                       v             v
│                                    Mode          Template
│                                   Editor         List/Edit
│                                   Screen
│
└─────────────────────────────────────────────────────────────┘
```

---

## Route Map

Complete list of all routes with full paths and query parameters:

```
/                                      Home Screen
/onboarding                            Onboarding (3-screen flow)
/session                               Active Session Screen
/fake-call                             Fake Call Screen (modal overlay)
/session/completed                     Chain Exhausted Screen (with duration param)
/session/simulation-summary            Simulation Summary Screen

/contacts                              Emergency Contacts List
/contacts/edit?id=...                  Contact Form (create or edit)

/modes                                 Modes List (Settings → Session → Modes)
/modes/edit?id=...                     Mode Editor (create or edit)

/distress-modes                        Distress Modes List (Settings → Session → Distress Modes)
/distress-modes/edit?id=...            Distress Mode Editor (uses ModeEditorScreen with isDistress=true)

/settings                              Settings hub (Theme, Language, Emergency Number, Redo Onboarding)
/settings/security                     Security submenu (App PIN, Session End PIN, Duress PIN)
/settings/stealth                      Stealth settings (fake name, icon picker, ...)
/settings/pin-setup?type=...           PIN Setup screen (type: app|sessionEnd|duress)
/settings/event-defaults               Event Defaults (per-step-type timing + config defaults)
/settings/gps-logging                  GPS Logging config
/settings/reminder-templates           Global reminder templates list
/settings/templates/edit?id=...        Template Editor
/settings/notifications                Notification permission re-ask
/settings/history-retention            Session-log retention settings
/settings/battery-alert                Battery Alert config
/profile                               Profile Editor
/settings/about                        About Screen
/settings/feedback                     Feedback Form
/settings/backup                       Backup & Restore

# REMOVED routes (replaced):
#   /settings/modes-and-chains (replaced by direct links to /modes, /distress-modes, /settings/battery-alert)
#   /settings/distress-chain   (replaced by /distress-modes list + /distress-modes/edit editor; the editor is ModeEditorScreen with isDistress=true)
#   /distress-chains, /distress-chains/edit (Pivot 3 — distress is a Mode; superseded by /distress-modes routes above)
#   /settings/defaults          (replaced by individual dedicated screens per category)
#   /settings/defaults/*        (flattened to /settings/<category> — see list above)

/past-events                           Session History (Real & Simulated)
/past-events/detail?id=...             Session Log Detail View
/past-events/evidence?id=...           Evidence Export (share session log as text/JSON)
```

---

## Onboarding Flow (`/onboarding`) — 3 Screens

Minimal onboarding optimized for speed-to-first-session. Collects only what is necessary for the first safety session, defers everything else to a post-onboarding setup checklist on the home screen.

Onboarding pages are **private widget classes** within `lib/features/onboarding/onboarding_screen.dart` (not separate files). Users navigate with **Next/Back buttons** and a `PridePageIndicator`. A "Skip" link (top-right) jumps to the next page; "Skip all" jumps directly to home.

**Page widget classes (private, within `onboarding_screen.dart`):**
- `_WelcomePage` — intro and trust-building
- `_ProfileContactPage` — name, phone number, and one emergency contact (combined)
- `_PermissionsPage` — location, notifications, SMS permissions

### Screen 1: Welcome

**Purpose:** Introduce the app and build trust. Single tap to continue.

**Layout:**
```
┌─────────────────────────────────┐
│  (No app bar)                   │
│                                 │
│    [Guardian Angela Logo]       │ (120x120px)
│                                 │
│   "Hi, I'm Angela"              │
│   (large heading, pride colors) │
│                                 │
│  "I'm your personal guardian.   │
│  I walk with you, watch over    │
│  your evening out, and take     │
│  action if something feels      │
│  wrong."                        │
│  (body text, centered)          │
│                                 │
│  "Your angel's got your back."  │
│  (tagline, italics, smaller)    │
│                                 │
│  [Get Started]                  │
│                                 │
└─────────────────────────────────┘
```

---

### Screen 2: Profile + Emergency Contact

**Purpose:** Collect user identity (name, phone) and prompt to add one emergency contact. The contact form is NOT embedded — tapping the "Add Emergency Contact" button navigates to the full `ContactFormScreen`, identical to adding a contact from Settings.

**Layout:**
```
┌─────────────────────────────────┐
│  [Back]  "About You"     [Skip] │
│                                 │
│  "What's your name?"            │
│  (heading)                      │
│                                 │
│  ┌──────────────────────────┐   │
│  │ Name                     │   │
│  │ [Text field] (autofocus) │   │
│  └──────────────────────────┘   │
│                                 │
│  ┌──────────────────────────┐   │
│  │ Phone Number             │   │
│  │ [Text field]             │   │
│  └──────────────────────────┘   │
│                                 │
│  "Included in emergency         │
│  messages."                     │
│  (helper text, muted)           │
│                                 │
│  ─── Emergency Contact ───      │
│  (section divider)              │
│                                 │
│  "Who should we contact if      │
│  something goes wrong?"         │
│  (sub-heading)                  │
│                                 │
│  ┌──────────────────────────┐   │
│  │  No contact added yet    │   │
│  │  [+ Add Emergency Contact│   │  ← navigates to ContactFormScreen
│  │   ]                      │   │
│  └──────────────────────────┘   │
│  (or, if contact already added:)│
│  ┌──────────────────────────┐   │
│  │ [Avatar] Alice           │   │
│  │ 555-1234 · SMS · WA      │   │
│  │ [Edit] [Remove]          │   │
│  └──────────────────────────┘   │
│                                 │
│  [Back] [Next]                  │
│                                 │
└─────────────────────────────────┘
```

**"Use my number" button (Extra 28):** Rendered below the "Your Name"
field on onboarding page 2. On tap, calls `readDeviceNumber()` in
`lib/core/utils/device_number.dart` which invokes a method channel
(`com.guardianangela.app/device_info → getSimPhoneNumber`) on
Android to read the SIM's own phone number. Outcomes:

| Outcome | UI message | Android | iOS | Web |
|---|---|---|---|---|
| `success` | number shown below button in safe-color | read SIM | — | — |
| `iosUnsupported` | SnackBar "Not available on iOS; please enter manually" | — | always | — |
| `permissionDenied` | SnackBar "Permission denied — cannot read SIM number" | READ_PHONE_STATE / READ_PHONE_NUMBERS denied | — | — |
| `unavailable` | SnackBar "Couldn't read number from device. Please enter manually." | API restricted (Android 10+) or SIM absent | — | always |

The button is disabled on iOS and web. On success the detected number is displayed as a read-only hint — the user manually enters it into the contact form on the following screen so that no implicit form state crosses screens.

**"Add Emergency Contact" button behavior:**
- Navigates to the full `ContactFormScreen` (`/contacts/edit`) using `Navigator.push`.
- On save, returns to page 2 with the contact shown as a card.
- The form is identical to adding a contact from Settings — all fields present: name, phone, relationship, channel toggles (SMS/WhatsApp/Telegram/Phone Call), per-contact SMS language, iOS SMS warning.

**Validation:** Profile fields optional (trim whitespace). Next is always enabled — having no contact is allowed (the home screen checklist prompts for it afterwards). If a contact was started but not saved, it is discarded.

**Rationale:** Navigating to the full `ContactFormScreen` ensures the onboarding contact looks and behaves exactly as in Settings — no stripped-down variant. Separating the contact form from the profile page avoids a scrollable wall of form fields on one screen.

**Note:** All enabled messaging channels are used; there is no "preferred channel" setting. Each contact's messaging preferences are configured via toggles for SMS, WhatsApp, Telegram, and phone call.

---

### Screen 3: Permissions

**Purpose:** Request permissions needed for core functionality. Last onboarding screen. Functions as an interactive checklist — the user can grant permissions individually or all at once.

**Layout:**
```
┌─────────────────────────────────┐
│  [Back]  "Permissions"          │
│                                 │
│  "These permissions keep you    │
│   safe during sessions."        │
│                                 │
│  ┌──────────────────────────┐   │
│  │ Notifications       REQUIRED │
│  │ "Required for session    │   │
│  │  alerts and reminders."  │   │
│  │              [Grant] [✓] │   │
│  └──────────────────────────┘   │
│                                 │
│  ┌──────────────────────────┐   │
│  │ SMS               REQUIRED*  │
│  │ "Required to send        │   │
│  │  emergency text alerts." │   │
│  │              [Grant] [✗] │   │
│  └──────────────────────────┘   │
│                                 │
│  ┌──────────────────────────┐   │
│  │ Phone             REQUIRED*  │
│  │ "Required to make        │   │
│  │  emergency and fake      │   │
│  │  calls."                 │   │
│  │              [Grant] [✗] │   │
│  └──────────────────────────┘   │
│                                 │
│  ┌──────────────────────────┐   │
│  │ Location          REQUIRED*  │
│  │ "Included in your        │   │
│  │  emergency messages when │   │
│  │  GPS logging is on."     │   │
│  │              [Grant] [✗] │   │
│  └──────────────────────────┘   │
│                                 │
│  ┌──────────────────────────┐   │
│  │ Microphone        OPTIONAL   │
│  │ "Used for audio recording│   │
│  │  during distress."       │   │
│  │              [Grant] [✗] │   │
│  └──────────────────────────┘   │
│                                 │
│  ┌──────────────────────────┐   │
│  │ Camera            OPTIONAL   │
│  │ "Used for flash SOS      │   │
│  │  signaling."             │   │
│  │              [Grant] [✗] │   │
│  └──────────────────────────┘   │
│                                 │
│  [Grant All]                    │
│  (requests all ungranted)       │
│                                 │
│  [Back]         [Get Started]   │
│                                 │
└─────────────────────────────────┘
```

**Permission tiles — each tile shows:**
- Permission name (e.g., "Notifications", "SMS", "Phone")
- One-sentence explanation of why it is needed
- Required / Optional badge (see classification below)
- Status indicator: granted (✓, green), denied (✗, red), or not yet asked (✗, gray)
- Individual "Grant" button — taps the platform permission dialog for that permission only; hidden once the permission is already granted

**"Grant All" button:**
- Appears below all tiles
- Requests all ungranted permissions sequentially
- Button label updates to "All Granted" and becomes disabled once every permission is granted

**Permission classification:**

| Permission | Classification | Condition |
|---|---|---|
| Notifications | **REQUIRED** | Always — session cannot run without notification support |
| SMS | **REQUIRED*** | Conditionally required: if the selected mode's chain contains any `smsContact` step |
| Phone | **REQUIRED*** | Conditionally required: if the chain contains `phoneCallContact` or `callEmergency` steps |
| Location | **REQUIRED*** | Conditionally required: if GPS logging is enabled in the mode or global defaults |
| Microphone | **OPTIONAL** | Session works without it; audio recording during distress unavailable |
| Camera | **OPTIONAL** | Session works without it; flash SOS unavailable |

`*` = conditionally required based on the current mode's chain configuration. The badge reads "REQUIRED" when the condition applies and "OPTIONAL" when it does not. During onboarding, the default Walk Mode is assumed for classification.

**Status indicator states:**
- Granted (✓, green) — platform granted; "Grant" button hidden
- Denied (✗, red) — platform denied; show "Open Settings" link in place of "Grant" button
- Not yet asked (✗, gray) — not yet requested; "Grant" button visible

**"Get Started" availability:**
- Always enabled — the user can proceed even with denied permissions. A home-screen checklist item prompts for missing required permissions after onboarding.

**On "Get Started":**
1. Save profile + contact
2. Mark onboarding complete in `AppSettings.isFirstLaunch = false`
3. Route to home screen
4. Safety Setup checklist card is visible on home screen

---

## Home Screen (`/`)

The main dashboard and entry point after onboarding. Displays mode selector, quick-access contacts, and session controls.

**Layout:**
```
┌──────────────────────────────────┐
│  Guardian Angela               │ │ (AppBar title, left)
│  [Contacts] [History] [Settings]│ │ (AppBar actions, right)
│  ────────── pride gradient line  │ (PrideAppBarBottom)
├──────────────────────────────────┤
│                                  │
│       [Guardian Angela Logo]     │ (96x96px)
│            Guardian Angela       │
│                                  │
│  ┌────────────────────────────┐  │
│  │ Mode Selector (ChoiceChips)│  │
│  │ [Walk Mode] [Date Mode]    │  │
│  │ [Custom 1] [Custom 2]  ... │  │
│  └────────────────────────────┘  │
│  Selected = teal highlight       │
│                                  │
│  ┌────────────────────────────┐  │
│  │ Chain Summary:             │  │
│  │ [Hold] → [Fake] → [SMS]    │  │
│  │ → [Call] → [Alarm] → [112] │  │
│  │ (horizontal row, pills,    │  │
│  │  tap for timing details)   │  │
│  └────────────────────────────┘  │
│                                  │
│  Contact Chips (up to 5):        │
│  [Alice]  [Bob]  [Carol]  [+3]   │
│  (circle avatars, initials)      │
│                                  │
│  ┌────────────────────────────┐  │
│  │  🛡️  Start Session         │  │
│  │  (64px tall, full width)   │  │
│  │  Glowing pulse if ready    │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │     Simulate               │  │
│  │  (outlined, less prominent)│  │
│  └────────────────────────────┘  │
│                                  │
│                                  │
└──────────────────────────────────┘
```

**Components:**

### AppBar
- **Title:** "Guardian Angela"
- **Actions (right):**
  - Contacts icon → `/contacts`
  - History icon → `/past-events`
  - Settings gear icon → `/settings`
- **Bottom:** `PrideAppBarBottom` (2px gradient line)

### Logo & Title
- Guardian Angela logo (96x96px, centered)
- Text "Guardian Angela" below logo

### Mode Selector
- **Widget:** ChoiceChips with mode icon + name
- **Selection:** Persists to AppSettings
- **Behavior:** Tap to select, shows teal highlight
- **If many modes:** Shrink to icon-only to save space
- **If selected mode deleted:** Auto-select another mode (stable sorting)

### Chain Summary
- **Display:** Horizontal row of step icons + labels
- **Format:** `[Step icon] Label → [Step icon] Label → ...`
- **Pills:** Teal background, white text, small padding
- **Interaction:** Tap any step → shows detailed timing breakdown in a modal:
  ```
  Step: Fake Call
  Grace period: 5 seconds after release
  Ring duration: 30 seconds
  Next step if no answer: SMS
  ```

### Contact Chips
- **Display:** Up to 5 contacts as circle avatars (initials inside)
- **Interaction:** Tap to edit → `/contacts/edit?id={id}`
- **Overflow:** If > 5: show "+N more" button → `/contacts`
- **Empty state:** Show "Add Contact" button → `/contacts/edit`

### Start Session Button
- **Style:** Filled, 64px tall, full width
- **Icon:** Shield
- **Animation:** Glowing pulse (only if mode selected)
- **Pre-start Validation:**
  - **Simulation sessions:** Lenient — warn but allow starting with missing contacts or permissions. Useful during onboarding.
  - **Real sessions:** Block starting ONLY if the selected mode's chain contains SMS, phone call, or emergency call steps AND zero contacts are configured. A mode with only holdButton + loudAlarm is allowed without contacts. Missing permissions for steps in the chain also block real session start.
  - Mode has steps? (warn if empty)
  - Missing required permissions? (location, phone, SMS for relevant steps) → permission prompt
- **On tap:**
  1. Show Active Triggers Summary:
     - Display configured triggers (distress trigger, disarm trigger) with brief configuration details
     - If GPS disarm trigger is configured: Prompt for GPS destination (can be skipped; skipping disables trigger for this session only)
  2. Create WalkSession with selected mode
  3. Validate permissions — includes **notification permission re-ask (Extra 42)**:
     call `ensureNotificationPermission(context)` from
     `lib/core/utils/permission_utils.dart`. If the user previously
     denied Android 13+ `POST_NOTIFICATIONS`, this shows a
     rationale dialog and re-requests; if permanently denied, it
     offers to deep-link to app settings. If the call returns
     `false` for a chain that contains disguised-reminder or
     session-notification steps, block the start with an inline
     warning.
  4. Start SessionEngine
  5. Navigate to `/session`

### Simulate Button
- **Style:** Outlined, TextButton, less prominent
- **On tap:** Same validation as real session, then:
  1. Create WalkSession with `isSimulation: true`
  2. Navigate to `/session/simulation-loading` (1.5s loading screen)
  3. Then `/session` with simulation overlay

### Safety Setup Checklist (Post-Onboarding)

A collapsible banner card at the top of the home screen (below the app bar, above the logo). Visible after onboarding until all items are completed or the card is manually dismissed. Uses a progress bar showing completion percentage.

**Layout:**
```
┌──────────────────────────────────────────┐
│  Safety Setup                 ▼    [×]   │ (collapsible header + progress bar)
│  ━━━━━━━━━━━━━━━━░░░░░ 40%              │
├──────────────────────────────────────────┤
│  ✓ Add an emergency contact         ℹ   │ (completed, muted)
│  ☐ Set a session-end PIN            ℹ   │ → /settings/pin-setup?type=session
│  ☐ Configure stealth mode           ℹ   │ → tutorial → /settings/defaults
│  ☐ Test a simulation                ℹ   │ → tutorial → "Got it"
│  ☐ Customize a safety mode          ℹ   │ → tutorial → /modes
│  ☐ Grant required permissions       ℹ   │ → ensureNotificationPermission()
└──────────────────────────────────────────┘
```

**Checklist items (each is tappable):**
1. **Add an emergency contact** — direct link: `/contacts/edit` (new contact). Completes when at least one contact exists.
2. **Set a session-end PIN** — direct link: `/settings/pin-setup?type=session`. Completes when `AppSettings.sessionEndPinHash` is non-null.
3. **Configure stealth mode** — opens a tutorial bottom sheet explaining what stealth does; the "Go there" button navigates to `/settings/defaults`. Completes when `AppSettings.defaults.stealth.enabled` is true.
4. **Test a simulation** — opens a tutorial bottom sheet explaining simulation; the confirm button simply closes the sheet so the user can press the Simulate button on the home screen. Completes after the first simulation session (flag persisted in `SharedPreferences`, fallback to `isSimulation` logs).
5. **Customize a safety mode** — opens a tutorial bottom sheet explaining modes; the "Go there" button navigates to `/modes`. Completes when any non-template mode exists.
6. **Grant required permissions** — calls `ensureNotificationPermission(context)` inline (rationale dialog, OS prompt, or deep-link into system settings for permanently-denied). Completes when `Permission.notification.status.isGranted`.

**Info icons:**
Each row has a trailing info icon (ℹ) that opens a separate "why this matters" bottom sheet (kept under 80 words per screen). The info sheet always dismisses to "Got it". Tutorials and info sheets share a single layout widget (`_ChecklistSheetContent`) and reuse localized strings under the `checklistInfo*` and `checklistTutorial*` prefixes.

**Behavior:**
- Card is collapsible (expanded by default on first visit, collapsed on subsequent).
- Progress bar fills as items are checked.
- Card disappears when all items checked, or after manual dismiss.
- Dismissed state persisted via `SharedPreferences` (key `home_checklist_dismissed`).
- Items are independently completable in any order.
- Tapping a completed (checked) row is a no-op; only unchecked rows drive navigation/tutorials.

---

## Session Screen (`/session`)

Dynamic UI based on current escalation step type. Shows mode-specific UI for check-in, progress tracking, and escalation status. Supports simulation mode with orange border and speed multiplier.

### Orientation Lock (D3)

The `SessionScreen` and `FakeCallScreen` lock device orientation to portrait-up only (`SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])`). Rotation during a live session would remount widgets, risk state/timer loss, and increases the chance of mis-taps on critical controls. On dispose the screens restore the system default (all orientations allowed), so every other screen continues to rotate freely.

### GPS Destination Prompt (Extra 22)

If the active mode has a `GpsArrivalDisarmTrigger` whose `destinationSource == GpsDestinationSource.promptAtStart`, the session controller emits `needsGpsDestinationPrompt = true` on start. The session screen responds by opening a modal `_DestinationSheet` (`lib/features/session/widgets/gps_destination_sheet.dart`). The sheet accepts lat/lng input (or a "use current location" shortcut) and exposes two actions: confirm feeds coordinates back to `controller.setGpsDestination()`; skip calls `controller.skipGpsDestination()`, which disables the GPS arrival trigger for this session only. Dismissing the sheet without a choice is treated as skip to avoid deadlocking the session.

### Simulation Silent Default (Extra 49)

Every simulation session starts with `simulationSilent = true`. The toggle in the simulation controls bar remains live-editable, but because the flag is stored on `WalkSession` (ephemeral state) it is never persisted, so the next simulation once again begins silent.

### Shared Session UI

**Top Bar:**
- Session timer (elapsed): `HH:MM:SS` (always visible unless hidden in stealth settings)
- End Session button (right) → swipe confirmation dialog
  - "Swipe to confirm you want to end the session"
  - Slider: left-to-right
  - If PIN required: prompt for PIN after swipe
  - Wrong PIN 5x: fires the mode's selected distress chain (replaces main chain)
  - **Simulation:** PIN prompt shown if configured (lets user practice the flow), but includes a "Skip" button to bypass. Wrong PIN 5x during simulation shows a toast describing what would happen ("Distress chain would fire") but does NOT actually fire the distress chain.

**Progress Bar:**
- Pride gradient, top of screen (2px height)
- Fills linearly from 0–100% for current step
- Resets at each step transition
- Optional hide in stealth mode

**Simulation Overlay (if active):**
```
┌────────────────────────────────┐
│ ╔════════════════════════════╗ │ (orange 4px border)
│ ║  [SIM]  PRACTICE MODE     ║ │
│ ║                            ║ │
│ ║  Sim: 05:30               ║ │ (simulated elapsed time MM:SS)
│ ║                            ║ │
│ ║  Speed: [1x ======> 1000x] ║ │ (logarithmic slider)
│ ║  Presets: 1 2 5 10 20 50   ║ │ (tap for preset speeds)
│ ║          100 500 1000      ║ │
│ ║  Leap >>   🔇 Silent       ║ │ (Leap: skip to 1s before next event;
│ ║                            ║ │  Silent toggle: suppresses all audio)
│ ╚════════════════════════════╝ │
│                                │
│  (Normal session UI below)     │
│                                │
└────────────────────────────────┘
```

**Sim Time display:**
- Shows total simulated time elapsed (not wall-clock time): `"Sim: MM:SS"`
- At speed 10×, advances 10 simulated seconds per 1 real second
- Allows the user to understand where they are in the chain timing during fast-forward simulation
- Updated every real-time second tick in `SessionController`

**Silent Mode toggle (in simulation controls bar):**
- A toggle button labelled "Silent" (with a muted speaker icon) within the simulation controls bar.
- **When ON:** All audio is suppressed — ringtone, voice recording, alarm audio, countdown sounds. Vibration still fires. Useful when testing in public or when audio would be intrusive.
- **When OFF (default):** Audio plays normally for local-only steps (e.g., the fake call ringtone plays at normal volume).
- The loud alarm is ALWAYS muted in simulation regardless of this toggle.
- The toggle is **per-session only** — it is not persisted to storage and defaults to OFF at the start of every simulation session.

**Leap button:**
- Skips simulated time forward to 1 second before the next scheduled engine event. Useful for bypassing long wait phases (e.g., the 30-minute wait in Date Mode) without requiring the user to crank the speed slider.
- Does not skip past user-driven interaction requirements — if a fake call is already ringing, the user must still interact with it.

### Simulation Must Render Actual Step UIs — and Requires User Interaction

**This is the primary behavioral requirement for simulation mode.** Simulation is a **practice mode** — the user experiences the exact same session flow as a real session and MUST interact with every user-driven step. The purpose is to let users rehearse their responses, verify their chain configuration, and experience what a real session looks and feels like before they need it.

- **Simulation MUST render the exact same step UI as real mode for every step type.**
- The simulation controls bar (speed slider, Sim Time, Leap button, Silent toggle) is **overlaid at the bottom** of the session screen; it does not replace any session UI.
- Blocked actions (SMS, calls, loud alarm) show a non-intrusive **"[SIM] Would send SMS to 3 contacts"** informational card instead of executing, but this card appears IN ADDITION to any visual step UI — it never replaces the step UI.
- **The user MUST interact with every user-driven step.** If the user does not hold the button, the hold step times out and escalates exactly as in real mode. If the user does not answer or decline the fake call, it rings until timeout and escalates. If the user does not dismiss the disguised reminder, the retry count is consumed and escalation proceeds. The chain only stalls if the user doesn't act — there is no auto-advance.

**Per-step requirements:**
- **holdButton:** Identical hold UI — color transitions, circular countdown, timer-driven ticking number. The user must hold the button. If released, the grace period timer runs exactly as in real mode.
- **fakeCall:** The `FakeCallScreen` MUST appear in full — with ringtone (unless Silent is ON), answer/decline slider, caller avatar, voice recording. "[SIM]" appears in the caller name area. The user must answer or decline. If no interaction, the call times out and the chain escalates.
- **disguisedReminder:** The actual full-screen overlay or notification MUST appear with `[SIM]` prefix. NOT a toast. The user must interact to disarm. If no interaction, the step is missed and retry/escalation logic runs exactly as in real mode.
- **countdownWarning:** The actual countdown widget with vibration (and audio if Silent is OFF) MUST fire. NOT a toast.
- **smsContact / phoneCallContact / callEmergency:** These are blocked actions — instead of executing, a `[SIM]` card appears describing what would have been sent/called. No user interaction required; the engine advances automatically after the step duration.
- **loudAlarm:** Always muted in simulation; a `[SIM]` card shows "Alarm would have sounded at full volume". Vibration still fires.
- **hardwareButton:** Native hardware button detection fires normally in simulation — the user can press the hardware button to trigger the step.

**What simulation must NOT do:**
- Replace step UIs with text toasts or description overlays.
- Skip showing the FakeCallScreen because "it's only simulation."
- Auto-hold the hold button, auto-answer fake calls, or auto-dismiss reminders on behalf of the user.
- Show a summary card instead of the actual step UI.

### Distress Confirmation Window

When any distress trigger fires (hardware panic button, wrong PIN threshold reached, or duress PIN entered), a 5-second configurable confirmation window appears before the distress chain replaces the main chain.

**Layout:**
```
┌─────────────────────────────────────────┐
│         ⚠️  DISTRESS ACTIVATED          │
│                                         │
│  "Tap to cancel — you have 5 seconds"   │
│                                         │
│  [Circular Progress / Countdown: 5s]    │
│                                         │
│  [TAP TO CANCEL]                        │
│  (large button, center)                 │
│                                         │
│  "If not canceled, distress chain will" │
│  "begin immediately."                   │
│                                         │
└─────────────────────────────────────────┘
```

**Behavior:**
- Window appears modal, blocking all other session interaction
- Countdown timer visible (circular progress or numeric display)
- Tap [TAP TO CANCEL] to dismiss and return to current session state
- If Session End PIN is configured: After tapping cancel, PIN prompt appears (15s timeout)
  - Correct PIN: confirmation succeeds, dismiss window, continue session
  - Wrong PIN: shake, "Incorrect PIN" toast, return to distress confirmation window
  - Timeout: distress chain fires
- If no PIN configured: Cancel immediately dismisses window
- After countdown expires OR confirmation completes: Distress chain replaces the main chain and begins immediately
- **Simulation:** Window appears and counts down, but tapping [TAP TO CANCEL] or timeout shows a toast: "Distress chain would fire" instead of actually firing

---

### Step-Specific UI

#### 1. Hold Button (Walk Mode Primary)

**Four style options:**

**Style: discreteButton**
```
┌─────────────────────────────┐
│ [Pride bar] [Elapsed] [End] │
├─────────────────────────────┤
│                             │
│   "Session Active"          │
│                             │
│   "Hold button to stay safe"│
│                             │
│  ┌─────────────────────┐    │
│  │  HOLD TO STAY SAFE  │    │ (small button, 80x40)
│  │  (teal=safe)        │    │
│  └─────────────────────┘    │
│                             │
│  "Release to start grace    │
│   period (5s)"              │
│                             │
│                             │
└─────────────────────────────┘
```

**Style: largeButton**
```
┌─────────────────────────────┐
│ [Pride bar] [Elapsed] [End] │
├─────────────────────────────┤
│                             │
│         ┌─────────┐         │
│         │         │         │ (200x200px circle, center)
│         │ HOLD    │         │ (teal=safe, amber=released)
│         │         │         │
│         └─────────┘         │
│                             │
│  "Touch to begin" (on start)│
│  "Hold again to stay safe"  │ (after release)
│  "Countdown: 5s" (grace)    │
│                             │
│                             │
└─────────────────────────────┘
```

**Style: fullScreen**
```
┌─────────────────────────────┐
│ [Pride bar] [Elapsed] [End] │
├─────────────────────────────┤
│                             │
│ Entire screen is touch tgt  │
│ (teal=safe, red=danger)     │
│                             │
│ [HOLD TO STAY SAFE]         │
│ (center text)               │
│                             │
│ "Release starts countdown:  │
│  5 seconds"                 │
│                             │
│                             │
└─────────────────────────────┘
```

**Style: fakeLockScreen**
```
┌─────────────────────────────┐
│ [Black screen, brightness] │
│ [near zero]                │
│                             │
│ Entire screen is touch tgt  │
│ (pitch black, minimal UI)   │
│                             │
│ "Touch anywhere to hold"    │
│ (faint text, white/gray)    │
│                             │
│                             │
└─────────────────────────────┘
```

**Color Coding:**
- **Teal:** Safe (button held)
- **Amber:** Warning (button released, grace period active)
- **Red:** Danger (escalating)

**Behavior:**
- On step start: show "Touch to begin" prompt
- On first touch: start session timer, transition button to held state
- While held: teal color, show "Hold to stay safe"
- On release: sensitivity window starts (1s default); if not re-held within sensitivity window:
  1. **Large countdown number appears centered** on the button/screen area, showing `durationSeconds` (e.g., "10")
  2. A **circular progress indicator surrounds the number**, draining from full to empty over `durationSeconds`
  3. The number **ticks every second** (`"10" → "9" → "8" → ... → "1"`), driven by `Timer.periodic(Duration(seconds: 1), ...)` in `SessionController` — NOT derived solely from engine phase-transition events
  4. **Color transitions to amber** for the entire session UI area during countdown
  5. The countdown occupies the primary area of the session screen for maximum visibility — this is the user's clear visual warning that escalation is approaching
  6. If re-held during countdown: countdown cancels, `Timer` is disposed, returns to safe (teal) state
  7. If countdown reaches 0: grace period begins (last chance to re-hold before escalation fires)
- On grace period timeout without re-hold: play escalation sound, show "Escalating..." and transition to next step

---

#### 2. Disguised Reminder (Date Mode Primary)

**Layout:**
```
┌─────────────────────────────┐
│ [Pride bar] [Elapsed] [End] │
├─────────────────────────────┤
│                             │
│     Session Active          │
│     (🛡️ icon, optional)    │
│                             │
│  Next check-in in: 28m 45s  │
│  (countdown, updates live)  │
│                             │
│  Missed: 0                  │
│  (hidden in stealth mode)   │
│                             │
│  (Elapsed time in corner)   │
│                             │
│  (Notification may appear   │
│   as overlay on top)        │
│                             │
└─────────────────────────────┘
```

**Reminder Overlay (when fired):**
```
┌─────────────────────────────┐
│                             │ (full screen modal)
│  ┌─────────────────────────┐│
│  │  [Reminder template]    ││
│  │                         ││ (Calendar, Duolingo, etc.)
│  │  [Interaction required] ││ (tap, swipe, button)
│  │                         ││
│  │  Grace period: 2m 00s   ││
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

**Behavior:**
- Show countdown "Next check-in in: MM:SS"
- Periodically (every 30 min by default) fire disguised reminder
- Reminder appears as full-screen modal or notification
- User must interact (tap, swipe) within grace period
- If missed: increment "Missed" counter, re-fire in 5 min
- If 3 missed in a row: escalate to next step

---

#### 3. Countdown Warning

**Layout:**
```
┌─────────────────────────────┐
│ [Pride bar] [Elapsed] [End] │
├─────────────────────────────┤
│                             │
│  ⚠️  WARNING                │
│  (large icon, yellow/red)   │
│                             │
│  "Next escalation step in   │
│   30 seconds"               │
│                             │
│  [30] [29] [28] ... [1]     │
│  (large countdown numbers)  │
│                             │
│  Visual pulse + audio tone  │
│  (every 5 seconds)          │
│                             │
│  (Optional flash, vibration)│
│                             │
│                             │
└─────────────────────────────┘
```

**Behavior:**
- Show large countdown timer
- Flash screen (optional, configurable)
- Vibrate (optional, configurable)
- Beep tone every 5 seconds (configurable volume)
- After countdown: transition to next step

---

#### 4. Escalation Steps (SMS, Fake Call, Phone Call, Alarm, Emergency)

**During Escalation:**
```
┌─────────────────────────────┐
│ [Pride bar] [Elapsed] [End] │
├─────────────────────────────┤
│                             │
│  [Step Icon]  (64px)        │
│                             │
│  "Sending SMS to          │
│   Alice, Bob, Carol"        │
│  (step description)         │
│                             │
│  ┌─────────────────────────┐│
│  │ I'm Safe ✓ Swipe        ││
│  │ ◄─────────────────────►  ││ (left-to-right slider)
│  └─────────────────────────┘│
│                             │
│  "Grace period: 2m 15s"     │
│  (countdown)                │
│                             │
│ (In stealth: slider says   │
│  "No Angela needed")        │
│                             │
│                             │
└─────────────────────────────┘
```

**Grace Period Slider ("I'm Safe"):**
- **Trigger:** Appears immediately when step starts
- **Direction:** Left-to-right swipe
- **Threshold:** Requires 0.85 full swipe (85% of slider width)
- **Feedback:** Spring animation on incomplete release
- **Success:** On full swipe: disarm chain, show "Session Ended" → `/session/completed`
- **Stealth variant:** Slider text says "No Angela needed" (configurable per step)

**Emergency Call Step Confirmation:**
When the escalation step is `callEmergency` (emergency services call), and the user disarms during the grace period, a confirmation dialog is shown:
```
┌────────────────────────────────┐
│  ⚠️  Are you sure?             │
│                                │
│  "The emergency call will NOT  │
│   be made if you disarm now."  │
│                                │
│  [Cancel (keep disarming)]     │
│  [Go back (keep session)]      │
└────────────────────────────────┘
```
- Tapping [Cancel] completes the disarm and ends the session successfully
- Tapping [Go back] cancels the disarm slider action and returns to the emergency call countdown
- This prevents accidental disarms during the final critical step

**Behavior:**
- Show step icon + description
- Perform real action (if not simulation)
- Show "I'm Safe" slider during grace period
- Show countdown "Grace period: MM:SS"
- On slider complete: end session successfully (with emergency call confirmation if applicable)
- On timeout: escalate to next step

---

### Stealth Mode UI

**StealthConfig:** The session screen resolves all stealth visibility flags via the `StealthConfig` model (in `lib/core/constants/app_constants.dart` or `lib/data/models/`), not by reading individual `AppSettings.stealth*` booleans inline. The effective `StealthConfig` for a session is resolved by merging `AppDefaults.stealth` with `SessionMode.overrides?.stealth` (mode override wins).

```dart
/// Resolved stealth configuration for the session screen.
/// Fields: enabled, fakeName, fakeIcon, notificationDisguise,
///         timerDisplay, sessionScreenStealth.
/// The session controller resolves and passes this to the session screen.
StealthConfig effectiveStealth = mode.overrides?.stealth ?? appDefaults.stealth;
```

When stealth mode is enabled in settings, the session screen transforms:

**Fake Music Player:**
```
┌─────────────────────────────┐
│ ◄  Spotify / Apple Music    │ │ (minimalist header)
│                             │
│  [Album Art - 200x200px]    │
│                             │
│  "Track Title"              │
│  "Artist Name"              │
│                             │
│  ◄  ⏸  ►                   │
│  (standard music controls)  │
│                             │
│  Progress:  ━━━●━━━  2:35   │
│  Total:     5:00            │
│                             │
│  (Swipe left on progress = │
│   "I feel fine" disarm)     │
│                             │
│  ═══════════════════════════│
│  (toggle) Stealth Mode: ON  │
│  (hidden if off)            │
│                             │
└─────────────────────────────┘
```

**Behavior:**
- Shows as standard music player (Spotify, Apple Music, YouTube Music UI)
- Play/pause controls work (pause = pause session, resume = resume)
- Swipe on progress bar left-to-right = "I feel fine" disarm
- Toggle switch for stealth mode on/off
- Timer shows as music playback time (corner, if configured)

**Timer Display Options (configurable per user):**
1. **Normal:** Full timer at top
2. **Small (corner):** "2:35" in corner, looks like playback time
3. **None:** No timer visible

**Stealth Mode and PIN (Orthogonal):**
Stealth mode is orthogonal to PIN configuration. If a PIN is required to disarm or end a session, PIN screens appear with stealth appearance modifications:
- PIN screen hides app branding (no "Guardian Angela" logo/title)
- Keypad UI appears minimal (matches stealth aesthetic)
- PIN entry appears as standard numeric input with no safety-app indicators
- This allows users to practice PIN entry discreetly without revealing app identity

---

### Background Behavior

**Foreground Service:**
- Session runs in foreground service on Android
- On iOS: app closure creates local notification with pause/play buttons
- Session state preserved if app backgrounded

**Resume on Return:**
- Session screen resumes exactly where it was
- Timer continues accurately
- Current step UI shown

**Fake Call While Backgrounded:**
- Wakes screen
- Shows full-screen call UI (Android native style or iOS style)
- All decline/answer logic applies

**Disguised Reminder While Backgrounded:**
- Full-screen notification (or platform notification depending on style)
- Tap = check-in or opens session overlay
- Timeout handled by engine

---

### Quick Exit

Quick Exit allows users to immediately exit the app while preserving all session data encrypted in storage. Session data is recoverable when the app is reopened, essential for police reports and evidence preservation.

**Flow:**
1. Long-press home button (or platform-specific gesture) while session is active
2. Quick Exit PIN prompt appears (15-second timeout)
3. Enter correct PIN to proceed, or timeout to dismiss
4. Confirm exit: "Session data will be preserved and encrypted. You can recover it by reopening the app."
5. Exit app

**Android:**
- Calls `finishAndRemoveTask()` to immediately exit and remove from recents
- Session data persisted to encrypted storage before exit

**iOS:**
- Shows decoy screenshot (looks like a generic notification or system screen)
- Calls `exit(0)` to immediately terminate app
- Session data persisted to encrypted storage before exit

**Data Preservation:**
- Session data NEVER wiped or deleted on exit
- Data encrypted at rest in `Hive` boxes
- Encrypted file system automatically locks data when app closes
- User can reopen app anytime to recover encrypted session data
- Data includes full event timeline for emergency responders

**Reopening App:**
- If session was running and exited via Quick Exit: session state recoverable
- App offers: "Recover session data" / "Start new session"
- Recovered session shows: timing, GPS data, event timeline, contacts contacted
- User can export recovered data as text/JSON for police

---

## Fake Call Screen (`/fake-call`)

Full-screen incoming call UI with 5 platform styles. Appears during session when fakeCall step triggers.

**5 Visual Styles:**

1. **Android (native):** Material Design call UI
2. **iOS (native):** iOS call UI (Apple gray, rounded)
3. **WhatsApp:** WhatsApp call UI
4. **Telegram:** Telegram call UI
5. **Signal:** Signal call UI

**Incoming State:**
```
┌─────────────────────────────┐
│                             │
│  [Caller avatar] (96x96)    │
│                             │
│  "Angela" (or configured)   │
│  (caller name)              │
│                             │
│                             │
│  ┌─────────────────────────┐│
│  │  Slide to answer        ││
│  │  ◄─────●────────────────││ (slider, left-to-right)
│  └─────────────────────────┘│
│                             │
│                             │
│  [Decline] (red button)     │
│  (label: dynamic)           │
│  • If declineIsSafe: "Decline (I'm Safe)"
│  • If not: "Decline (Stay on alert)"
│                             │
│  🔴 (hold 5s for distress)  │
│  (progress ring visible     │
│   during hold, fills 0–5s)  │
│                             │
│                             │
│  PopScope prevents back     │
│  Ringtone plays             │
│  Vibration pattern matches  │
│  phone OS default           │
│                             │
└─────────────────────────────┘
```

**Active Call State:**
```
┌─────────────────────────────┐
│  "Angela"                   │
│  00:12 (elapsed)            │
│                             │
│  [Caller avatar] (96x96)    │
│                             │
│  (Voice recording plays     │
│   if configured — earpiece  │
│   or speaker)               │
│                             │
│  ◄  ⏸  ►                   │
│  (call controls)            │
│                             │
│  [Hang Up] (red, full width)│
│                             │
│  PopScope prevents back     │
│                             │
└─────────────────────────────┘
```

**Behavior:**

**Slide to Answer:**
- Threshold: 0.85 (full slider width)
- Spring feedback on incomplete release
- On complete: transition to "Active Call" state
- **Disarms the chain** (user is safe by accepting fake call)
- Next step doesn't fire until hang-up + grace period

**Decline Button:**
- **Does NOT disarm**
- Re-fires grace period countdown
- Returns to session screen
- Chain continues escalating

**Decline with Distress (hold 5s):**
- Hold decline button for 5 seconds
- Show progress ring (fills 0–5s)
- At 800ms into hold: haptic feedback
- At 5s: fire the mode's selected distress chain (replaces main chain)
- Prevent accidental distress via confirmation

**Voice Recording:**
- Plays automatically when call active (if configured)
- Default: earpiece (low volume)
- Optional: speaker (loud)
- Language: matches user's locale
- Max: 2 minutes
- Can be pre-recorded or use built-in voice

**Hang-Up:**
- Ends active call
- Returns to session screen
- **Does NOT disarm** — next step waits for grace period
- Shows "Call ended" toast

**Ringtone & Vibration:**
- Respects phone ringer settings (silent, vibrate, volume)
- Ringtone matches call style (Android, iOS, WhatsApp, Telegram, Signal)
- Vibration pattern matches OS default call pattern

**Background Behavior:**
- Call screen wakes device on both platforms
- Screen on at max brightness
- Foreground service ensures app stays alive

---

## Chain Exhausted Screen (`/session/completed`)

Shown when session completes successfully (all steps disarmed before escalation).

**Layout:**
```
┌─────────────────────────────┐
│                             │
│      ✅ (check circle)      │
│      96x96px, teal          │
│                             │
│   Session Completed         │
│   Stay Safe                 │
│                             │
│   Duration: 5m 23s          │
│                             │
│   ┌───────────────────────┐ │
│   │ View Event Log        │ │ (button)
│   └───────────────────────┘ │
│                             │
│   ┌───────────────────────┐ │
│   │ Return Home           │ │ (button)
│   └───────────────────────┘ │
│                             │
│   "Thanks for using Angela" │
│   (encouragement)           │
│                             │
│   [Optional: Feedback prompt]
│   "How was your experience?"
│   [Send Feedback] [Skip]    │
│                             │
└─────────────────────────────┘
```

**Behavior:**
- **Stealth Mode:** This screen is NOT shown. App silently exits to home.
- "View Event Log" → `/past-events/detail?id={lastLogId}`
- "Return Home" → `/`
- Feedback prompt (optional, appears after 3 successful sessions): → `/settings/feedback`

---

## Simulation Summary Screen (`/session/simulation-summary`)

Shown after simulation completes. If Session End PIN is configured, a PIN prompt is shown first (see below), then the summary.

### Simulation PIN Prompt (conditional)

Shown only when `sessionEndPinHash` is set. Lets the user practice the PIN flow. Includes a **"Skip" button** so the PIN is never blocking in simulation.

```
┌─────────────────────────────┐
│                             │
│   🔒 Enter PIN              │
│                             │
│   "Practice entering your   │
│   Session End PIN"          │
│   (helper text, muted)      │
│                             │
│   ┌─────────────────────┐   │
│   │ [• • • •]           │   │ (PIN dots)
│   └─────────────────────┘   │
│                             │
│   [PinKeypad]               │
│                             │
│   [Skip]                    │ (text button, muted)
│                             │
└─────────────────────────────┘
```

**Behavior:**
- Correct PIN or "Skip" → proceed to simulation summary
- Wrong PIN: shake animation + "Incorrect PIN" (no counter, no distress chain — this is simulation)
- No timeout — user can retry or skip at any time
- Biometric is NOT shown (simulation is for practicing the manual PIN flow)

### Summary

Displays what would have happened if session escalated fully.

**Layout:**
```
┌─────────────────────────────┐
│   🎬 (play circle, orange)  │
│   96x96px                   │
│                             │
│  Simulation Summary         │
│  Here's what your mode      │
│  would do...                │
│                             │
│  Duration: 5m 23s           │
│                             │
│  ┌───────────────────────┐  │
│  │ Event Timeline:       │  │
│  │                       │  │
│  │ 0:05 - Hold Button    │  │
│  │ 0:10 - Grace Period   │  │
│  │ 0:15 - Fake Call      │  │
│  │      (would have      │  │
│  │       called Angela)  │  │
│  │ 0:45 - SMS Alert      │  │
│  │      (would have      │  │
│  │       messaged Alice) │  │
│  │ 1:45 - Emergency Call │  │
│  │      (would have      │  │
│  │       called 112)     │  │
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │ Share (export as text)│  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │ Done                  │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**Behavior:**
- List all steps with timing
- Color-code by step type (teal, amber, red)
- "Share" button exports as plain text to share with friend
- "Done" → `/`
- **No "Start Real Session" button.** A simulation cannot convert to a real session. The user must return home and start a real session intentionally.

---

## Contacts Screen (`/contacts`)

List of emergency contacts with add/edit/delete functionality.

**Layout:**
```
┌──────────────────────────────┐
│  Contacts              [+]    │ (FAB)
│  [Contacts] [History] [Sett] │ (AppBar actions)
├──────────────────────────────┤
│                              │
│  "Import from Contacts"      │ (button)
│  (phone address book)        │
│                              │
│  ┌──────────────────────────┐│
│  │ Reorderable list:        ││
│  │                          ││
│  │ [Avatar] Alice           ││ (drag to reorder)
│  │          555-1234        ││
│  │          [SMS] [WA] [Tg] ││ (channel icons)
│  │          ★ Primary       ││ (if set)
│  │          [Edit] [Delete] ││ (swipe to delete)
│  │                          ││
│  │ [Avatar] Bob             ││
│  │          555-5678        ││
│  │          [Phone]         ││
│  │                          ││
│  │ [Avatar] Carol           ││
│  │          555-9999        ││
│  │          [SMS] [Tg]      ││
│  │                          ││
│  │ ...                      ││
│  │                          ││
│  └──────────────────────────┘│
│                              │
│  (Empty state, if no        │
│   contacts)                  │
│  "No contacts yet"           │
│  "Add Contact" button        │
│                              │
│  (Swipe actions:)           │
│  [Delete] (with confirm)    │
│                              │
│  [Overflow menu]            │
│  "Delete all"               │
│  "Delete older than..." (N/A│
│   — contacts don't age)      │
│                              │
└──────────────────────────────┘
```

**Behavior:**

- **Reorderable:** Drag contacts to reorder (persists to repository)
- **Swipe to delete:** Shows confirmation dialog. **Blocked during active session:** Show prompt: "End your session first."
- **FAB:** `+` button → `/contacts/edit` (no ID = create new)
- **Import from Contacts:** Shows phone contact picker, creates contact record
- **Send Test Message:** (optional) Pre-fill message, send via SMS/WhatsApp/Telegram
- **Edit:** Tap contact or [Edit] button → `/contacts/edit?id={id}`
- **Delete All (overflow menu):** Blocked during active session with prompt: "End your session first."

---

## Contact Form (`/contacts/edit`)

Create or edit a single emergency contact. This same screen is navigated to from onboarding page 2 when the user taps "Add Emergency Contact".

**Layout:**
```
┌──────────────────────────────┐
│  [Back] "Contact"            │
├──────────────────────────────┤
│                              │
│  ┌──────────────────────────┐│
│  │ Name (required)          ││
│  │ [Text field]             ││ (min 2 chars)
│  │                          ││
│  │ Phone Number (required)  ││
│  │ [Text field]             ││ (validated)
│  │                          ││
│  │ Relationship (optional)  ││
│  │ [Text field]             ││ ("Mom", "Friend", etc.)
│  │                          ││
│  │ Channels (≥1 required):  ││
│  │ ☐ SMS                    ││ (ℹ info icon)
│  │ ☐ WhatsApp               ││ (ℹ info icon)
│  │ ☐ Telegram               ││ (ℹ info icon)
│  │ ☐ Phone Call             ││ (ℹ info icon)
│  │                          ││
│  │ Language for this contact││
│  │ [Dropdown] (default: app)││ (per-contact SMS language)
│  │                          ││
│  │ (iOS SMS warning:)       ││
│  │ "On iOS, SMS opens the   ││
│  │  Messages app. You must  ││
│  │  tap Send manually."     ││
│  │                          ││
│  └──────────────────────────┘│
│                              │
│  [Cancel] [Save]             │
│  (bottom)                    │
│                              │
└──────────────────────────────┘
```

**Validation:**
- Name: required, min 2 chars, max 50 chars
- Phone: required, validated for user's locale
- At least one channel selected

**Note:** All enabled messaging channels are used for each contact. Each contact can be configured with multiple channels (SMS, WhatsApp, Telegram, phone call), and during an escalation step that requires contacting this person, all enabled channels are triggered simultaneously.

**Info buttons (ℹ):** Every channel toggle has an info button that opens a bottom sheet explaining how that channel works and when to use it (e.g., "SMS — auto-sends on Android, requires manual Send on iOS").

**Behavior:**
- **Create mode:** All fields empty
- **Edit mode:** Pre-fill from contact record
- **Import from device (Extra 27):** Outlined button at the top of the form. On tap, requests `PermissionType.read` from `flutter_contacts` and opens the native contact picker. If the user selects a contact, the form pre-fills the name and the first phone number. Denied permission shows a SnackBar with a "open Settings" hint.
- **Unsaved-changes guard (Extra 59):** A dirty flag flips when any field is edited. Attempting to leave without saving (system back, app-bar back, or gesture pop) opens a confirmation dialog: "Discard unsaved changes?" with [Keep editing] and [Discard] buttons. The save path clears the flag so leaving after save proceeds silently.
- **Language dropdown:** Selects which language to use for SMS messages to this specific contact. Overrides the app language. Null = use app language.
- **Save:** Creates or updates contact, returns to `/contacts`
- **Cancel:** Returns to `/contacts` without saving

---

## Modes & Chains Screen (`/settings/modes-and-chains`)

Hub screen with three sections: Session Modes, Distress Chains, and Battery Alert. Accessible via Settings → "Modes & Chains".

**Layout:**
```
┌──────────────────────────────┐
│  [Back] Modes & Chains       │
├──────────────────────────────┤
│                              │
│  SESSION MODES               │
│  ┌──────────────────────────┐│
│  │ [icon] Night Out Mode    ││ (→ /modes; shows user-created modes)
│  │ [icon] My Walk Mode      ││
│  │ ...                      ││
│  │ > View All Modes     [+] ││
│  └──────────────────────────┘│
│                              │
│  DISTRESS CHAINS             │
│  ┌──────────────────────────┐│
│  │ ★ Default Distress Chain ││ (★ = default, first in list)
│  │   SMS → Call Emergency   ││ (subtitle: smsContact → callEmergency)
│  │ ...                      ││
│  │ > View All Chains    [+] ││
│  └──────────────────────────┘│
│                              │
│  BATTERY ALERT               │
│  ┌──────────────────────────┐│
│  │ > Battery Alert          ││ (→ /settings/battery-alert)
│  │   Alert at 10%, SMS on   ││ (summary of current config)
│  └──────────────────────────┘│
│                              │
└──────────────────────────────┘
```

**Behavior:**
- Tapping "View All Modes" → `/modes`
- Tapping "View All Distress Modes" → `/distress-modes`
- Tapping "Battery Alert" → `/settings/battery-alert`
- The first mode in the list has a "Default" badge (used when no mode is selected)
- The distress mode whose id is `AppDefaults.defaultDistressModeId` carries a ★ marker indicating it is the default used when `SessionMode.distressModeId` is null

---

## Modes Screen (`/modes`)

List of all session modes (built-in and custom). Accessible via Settings → Modes & Chains → Modes.

**Layout:**
```
┌──────────────────────────────┐
│  [Back] Modes            [+]  │ (FAB)
├──────────────────────────────┤
│                              │
│  List of all modes:          │
│                              │
│  ┌──────────────────────────┐│
│  │ [Walk icon] Walk Mode    ││
│  │ Hold → Fake Call → SMS   ││ (subtitle: first step + count)
│  │ [Edit] [Duplicate] [Del] ││
│  │                          ││
│  │ [Date icon] Date Mode    ││
│  │ Reminder → SMS → Alarm   ││
│  │ [Edit] [Duplicate] [Del] ││
│  │                          ││
│  │ [Custom icon] Night Out  ││
│  │ Reminder → Phone Call    ││
│  │ [Edit] [Duplicate] [Del] ││
│  │                          ││
│  │ ...                      ││
│  │                          ││
│  └──────────────────────────┘│
│                              │
│  (Empty state:)             │
│  "No custom modes yet"       │
│  "Create one below"          │
│                              │
│  [FAB]                       │
│  "Create Mode"               │
│                              │
│  On tap:                     │
│  ┌──────────────────────────┐│
│  │ "From template"          ││ (Walk Mode / Date Mode)
│  │ "From scratch"           ││ (custom mode)
│  └──────────────────────────┘│
│                              │
└──────────────────────────────┘
```

**Behavior:**

- **Edit mode:** Tap mode or [Edit] button → `/modes/edit?id={id}`
- **Delete mode:** [Delete] button → confirmation → deletes the mode. Works for all modes including those created from Walk Mode or Date Mode templates. A mode created from a template and then deleted does not reappear automatically; the user can re-create it from the template again.
- **Duplicate mode:** [Duplicate] button on each tile → immediately creates a copy named "Copy of {name}" and opens it in the mode editor for further customization.
- **FAB:** Create mode bottom sheet with two options:
  1. "From template" → shows exactly 2 choices: **Walk Mode** template and **Date Mode** template. Selecting one creates a new mode pre-populated with that template's chain; the new mode gets `isFromTemplate: true` and a "From template" badge.
  2. "From scratch" → empty chain; immediately asks "How do you want to check in?" (Hold Button / Disguised Reminder) before opening the mode editor.

---

## Mode Editor (`/modes/edit`)

Create or edit a session mode with custom escalation chain.

**Layout:**
```
┌──────────────────────────────┐
│  [Back] Mode Editor      [✓]  │ (save)
├──────────────────────────────┤
│                              │
│  ┌──────────────────────────┐│
│  │ Mode Name                ││
│  │ [Text field]             ││
│  │                          ││
│  │ Icon Selector            ││
│  │ [Shield] [Heart] [Lock]  ││ (choose icon)
│  │                          ││
│  └──────────────────────────┘│
│                              │
│  ┌──────────────────────────┐│
│  │ Escalation Chain:        ││
│  │ [Reorderable list]       ││ (drag to reorder)
│  │                          ││
│  │ [1] [Hold] (icon)        ││ (ExpansionTile)
│  │     Hold Button          ││
│  │     Grace: 5s            ││ (summary, always visible)
│  │ ▼ (tap to expand inline) ││
│  │   ┌────────────────────┐ ││ (config fields expand below tile)
│  │   │ Hold Style: Large  │ ││
│  │   │ [Timing section]   │ ││
│  │   │ [Reset to Defaults]│ ││
│  │   │ [▶ Advanced]       │ ││ (nested collapsible)
│  │   │ [Duplicate Step]   │ ││
│  │   └────────────────────┘ ││
│  │                          ││
│  │ [2] [Phone] (icon)       ││ (ExpansionTile, collapsed)
│  │     Fake Call            ││
│  │     Ring: 30s            ││
│  │ ▶ (tap to expand)        ││
│  │                          ││
│  │ [3] [Msg] (icon)         ││ (ExpansionTile, collapsed)
│  │     SMS Alert            ││
│  │     Contacts: Alice, Bob ││
│  │ ▶ (tap to expand)        ││
│  │                          ││
│  │ [+] Add Step             ││ (button, categorized picker)
│  │                          ││
│  └──────────────────────────┘│
│                              │
│  [Cancel] [Save]             │
│  (if no save: warn on back)  │
│                              │
└──────────────────────────────┘
```

**New Mode Flow:**

1. Dialog: "How do you want to check in?"
   - [Hold Button] → chain starts with holdButton step
   - [Disguised Reminder] → chain starts with disguisedReminder step
   - [More Options] → shows all 9 step types

2. Empty mode editor opens with chosen first step

**Step Expansion — Inline Three-Group ExpansionTile Layout (ITEM 7):**

Each step in the chain is an `ExpansionTile`. Tapping a step **expands it inline** directly below the tile header — no modal dialog or separate screen. Tapping again collapses it. Multiple steps can be expanded simultaneously.

The expanded body is built by `StepConfigPanel` and stacks three collapsible subsections:

1. **Timing** (initially expanded) — `waitSeconds`, `durationSeconds`, `gracePeriodSeconds`. Shared across all step types.
2. **Event configuration** (initially expanded) — fields specific to the step type, rendered by `EventSpecificConfig` in `lib/features/modes/widgets/event_specific_config.dart`. Every field has a small info-icon button that opens a bottom sheet with a plain-language explanation. Three step types (`fakeCall`, `smsContact`, `loudAlarm`) render a preview card so users can see the effect of their settings at a glance.
3. **Retry & Advanced** (initially collapsed) — `retryCount`, ±20% randomisation jitter, black-screen mode.

Default values come from `AppDefaults.eventDefaults`. When a step's `config` is null, the form seeds itself with the matching `EventDefaults` entry; editing any field materialises a concrete per-step config.

**Tier 1 — Summary header (always visible, the ExpansionTile header):**
- Step type icon + name
- One-sentence preview of what this step does (e.g., "Calls Angela — decline = chain continues")
- Key timing summary (e.g., "30s ring, 5s grace" for fakeCall; "30 min interval, 3 retries" for disguisedReminder)
- Drag handle (left) for reordering

**Tier 2 — Common settings (expands inline on tap):**
- Collapsible "Timing" section: waitSeconds, durationSeconds, gracePeriodSeconds, retryCount
- The 2–3 most important type-specific settings per step type (see list below)
- "Duplicate Step" button: copies step with all current settings, inserts right after
- "Advanced" collapsible nested inside the expanded step (see Tier 3)

**Tier 3 — Advanced settings (nested collapsible inside expanded step):**
- Recording options (autoRecordAudio, recordDurationSeconds)
- Non-blocking failure toggle (if SMS fails, continue chain)
- Per-field randomization toggles (randomizeInterval, randomizeRingDuration, etc.)
- Custom sound paths (customSoundPath, voiceRecordingPath)
- Sensitivity for hold button (releaseSensitivity)
- blackScreenMode toggle (for holdButton, disguisedReminder, hardwareButton)

**Step Type Preview (shown in every step tile header, in both Mode Editor and Event Defaults):**

Each step tile always shows:
1. **Icon** representing the step type
2. **Name** (e.g., "Fake Call")
3. **One-sentence description** of what the step does (sourced from `step_helpers.dart` descriptions):
   - holdButton: "Hold to stay safe — releasing starts a grace countdown"
   - disguisedReminder: "Sends a disguised notification — you must respond to confirm safety"
   - fakeCall: "Simulates an incoming call — answer or decline to show you're safe"
   - smsContact: "Sends an SMS with your location to emergency contacts"
   - countdownWarning: "Shows a countdown with sound and flash as a last warning"
   - loudAlarm: "Plays a max-volume alarm with flash to attract attention"
   - callEmergency: "Calls emergency services (112/911) automatically"
   - phoneCallContact: "Calls an emergency contact directly"
   - hardwareButton: "Watches a hardware button for a panic press pattern"
4. **Key config summary** (e.g., "30s ring, 5s grace" or "Contacts: Alice, Bob") — updates live as settings change

**Common settings per step type:**
- **holdButton:** Hold style (discreteButton/largeButton/fullScreen/fakeLockScreen), vibration feedback, sound feedback
- **disguisedReminder:** Interval (waitSeconds), template choice (Calendar/Duolingo/etc.), retryCount. Below the templateIds field the form renders a "Manage reminder templates" ListTile (leading `collections_outlined`, chevron trailing) that navigates to `/settings/reminder-templates` so the user can manage the global template pool without leaving the mode editor flow. An InfoIconButton above the link explains what templates are.
- **fakeCall:** Ring duration, ring style (Android/iOS/WhatsApp/Telegram/Signal), caller name
- **smsContact:** Contact selection (grid of one toggle button per contact — see **SMS Contact Selection** below), message template (editable with placeholders)
- **countdownWarning:** Duration, flash (on/off), sound (on/off)
- **loudAlarm:** Volume, sound choice (siren/beep/custom), flash (on/off)
- **callEmergency:** Emergency number, pre-SMS toggle
- **phoneCallContact:** Contact selection, pre-SMS toggle
- **hardwareButton:** Button type (volumeUp/Down), press pattern (repeat/long), press count or hold duration

**Config Defaults:**

Each step shows values from `EventDefaults` (global config in Settings). User can override per step. "Reset to Defaults" button restores step to defaults.

**Save Validation:**

- Mode name: required, min 2 chars
- Chain: must have at least 1 step
- Warn on unsaved changes when navigating away

**Mode — Safety Options section:**

At the bottom of the mode editor, a collapsible "Safety Options" section includes:

- **Distress Mode:** dropdown showing all distress modes (`SessionMode`s with `isDistressMode = true`); the picker stores the selected mode's id in `SessionMode.distressModeId` (null = use `AppDefaults.defaultDistressModeId`). Below the dropdown a "Manage distress modes →" ListTile navigates to `/distress-modes`. ℹ info button explains what fires the distress chain.
- **Distress Triggers:** lists active distress triggers for this mode (e.g., "Hardware panic button: 5× volume"). ℹ info button explains each trigger type.
- **Disarm Triggers:** per-mode automatic disarm conditions (stored in `SessionMode.disarmTriggers`). Parallel to the distress triggers section. Includes:
  - **GPS Arrival Disarm:** Toggle on/off. When enabled: radius slider (50 m–5 km, default 200 m) + "Set destination at session start" toggle. ℹ info button: "Session ends automatically when you arrive within the configured radius of your destination. You set the destination when starting a session."
  - **Timer Disarm:** Toggle on/off. When enabled: duration slider (5 min–8 h). ℹ info button: "Session ends automatically after the configured time, regardless of whether escalation has started."
  Both disarm triggers require the standard disarm confirmation (PIN if configured) when they fire.
- **GPS Logging:** three-state selector (Inherit from Defaults / Custom / Off). Selecting "Custom" opens `GpsLoggingConfig` inline. ℹ info button.
- **Stealth:** three-state (Inherit / Custom / Off). Selecting "Custom" opens all `StealthConfig` fields inline (same fields as the collapsible Stealth section in main Settings). ℹ info button.
- **Local Templates:** list of mode-local templates (appended to global); [+ Add Template]. ℹ info button.
- **Event Defaults:** three-state (Inherit / Custom). "Custom" opens per-type overrides. ℹ info button.

---

## Distress Modes Screen (`/distress-modes`)

List of all distress modes — i.e. `SessionMode`s with `isDistressMode = true`. Route name: `distress_modes`; screen class: `DistressModesScreen`. Accessible via **Settings → Session → Distress modes**.

A distress mode is a regular `SessionMode` whose `chainSteps` are used as the distress chain when a trigger (duress PIN, hardware panic, wrong-PIN threshold) replaces the main chain. Distress modes are filtered into this dedicated screen so they don't clutter the regular `/modes` list.

**Entry points:**
- Settings → Session → "Distress modes" row
- From a mode editor's Safety Options, via the "Manage distress modes →" link next to the distress-mode picker
- From the Duress PIN setup flow's final step as a deep link

**Layout:** Same as Modes screen — a list of tiles with [Edit] / [Duplicate] / [Delete] per row, plus a FAB to create a new distress mode. The mode whose id is `AppDefaults.defaultDistressModeId` carries a ★ "Default" badge.

**Primary actions:**
- **Tap tile or [Edit]:** → `/distress-modes/edit?id={id}` — opens `ModeEditorScreen` with `isDistress: true`. The editor is the same widget used for regular modes; the `isDistress` flag tweaks the heading and removes the check-in step row.
- **[Duplicate]:** Creates a copy named "Copy of {name}" with a fresh id and `isDistressMode = true`.
- **[Delete]:** Confirmation dialog. Refuses to delete the mode currently set as `AppDefaults.defaultDistressModeId` until another distress mode is promoted. Modes referenced by `SessionMode.distressModeId` from any regular mode also block deletion until the references are cleared.
- **Set Default:** Each tile has a "Set as default" action — writes the tile's id into `AppDefaults.defaultDistressModeId`.
- **FAB [+]:** → `/distress-modes/edit` (no `id`), creating a new empty distress mode.

**State:**
- Backed by the regular `modesRepository` via a `distressModesProvider` that filters `where (m.isDistressMode == true)`.
- The referenced `SessionMode.distressModeId` for each mode is validated when a session starts; missing id is a hard validation error.

---

## Distress Mode Editor (`/distress-modes/edit`)

Create or edit a distress mode. Route name: `distress_mode_editor`; the screen is **`ModeEditorScreen` rendered with `isDistress: true`** — i.e. the exact same widget used by the regular Mode Editor, with an `isDistress` parameter that:

- Replaces the screen title with "Distress mode" / "Edit distress mode".
- Hides the check-in step (distress chains don't have a `holdButton` / `disguisedReminder` first step).
- Sets `SessionMode.isDistressMode = true` on save.
- Hides the "Distress mode" picker in the Safety Options section (a distress mode doesn't reference another distress mode).

All other behavior — step list, drag-to-reorder, expansion tiles, dirty-flag guard, save validation — matches the regular Mode Editor.

**Save validation:**
- Mode name: required, min 2 chars.
- Chain: must have at least 1 step.
- Warn (non-blocking) if there's no SMS / call action step (pure countdown chains leave no outbound trail).

---

## SMS Contact Selection (shared step-editor widget)

Used inside any `smsContact` step config panel — i.e. in the Mode
Editor, the Distress Chain Editor, and the Battery Alert chain
editor. Replaces the former "All / First only / Specific" dropdown
with an **always-visible grid of one button per emergency contact**.
This puts the full list of contacts one tap away and makes the
current selection readable at a glance.

**Layout:**
```
Contacts to message:
┌──────────────────────────────┐
│ [✓ Alice]  [✓ Bob]  [✗ Carol]│ (enabled buttons — tap to toggle)
│ [  Dave ]  [  Eve ]          │ (grayed = channel not configured)
│ [✓ Frank]                    │
└──────────────────────────────┘
ℹ "Grayed contacts don't have SMS enabled on their profile.
   Edit the contact to add SMS as a channel."
```

**Rendering rules:**
- Every contact in the contacts repo renders as one button (a
  FilterChip-style widget) in a `Wrap`, labelled with the contact
  name and a leading check/cross icon reflecting selection state.
- A contact whose `messageChannels` **includes the step's
  configured channel** (SMS for `smsContact`) is **enabled** and
  starts in the ON state by default for a newly-created step. An
  editable step preserves whatever selection was saved.
- A contact whose `messageChannels` **does not include** the
  step's channel is rendered **disabled and visually grayed out**
  — reduced opacity, no ripple, no tap effect. Its selection state
  is always OFF and cannot be toggled; the tooltip reads
  "SMS not enabled for this contact — edit the contact to enable."
- No "All / First only / Specific" dropdown is shown. No "Select
  all" / "Select none" shortcuts in v0.x — the full grid keeps the
  mental model simple.
- The control shows a small summary line above the grid when
  collapsed (inside the ExpansionTile header): "To: Alice, Bob
  (+3 more)" or "To: all enabled contacts" when every
  channel-capable contact is selected.
- When the contacts repo is empty, the grid is replaced by a
  "No contacts yet — add one in Contacts" ListTile that deep-links
  to `/contacts`.

**Selection semantics (cross-reference to `03-data-models.md`):**
- The model field is still a `SmsRecipient` sealed type. Save-time
  inference maps the grid selection back to:
  - **All channel-capable contacts selected** → `SmsRecipient.allContacts`
  - **Strict subset selected** → `SmsRecipient.specificIds(ids)`
- The legacy `firstOnly` case is no longer producible from this
  UI and is migrated away on first edit (spec change only; see
  `03-data-models.md` for the model-level contract).
- Grayed (channel-incapable) contacts are never part of the saved
  selection regardless of UI state.

**Extensibility:** The same widget renders for any channel-scoped
step. `phoneCallContact` uses it with the "Phone" channel (future
work; currently uses single-contact pickers). Each step type
passes its channel filter into the shared widget.

---

## Battery Alert (`/settings/battery-alert`)

Configure the low-battery side-action. ITEM 8: the alert is now a
**configurable chain**, not a single SMS toggle. The screen is a thin
wrapper around a chain editor identical in look-and-feel to the mode
editor's step list.

**Layout:**
```
┌──────────────────────────────┐
│  [Back] Battery Alert        │
├──────────────────────────────┤
│  ☐ Enable battery alert      │ (SwitchListTile)
│                              │
│  Battery threshold           │
│  [slider 5% ────────── 50%]  │ (int percent)
│                              │
│  Alert chain          [Reset]│ (header)
│  "Runs when battery drops    │
│   below the threshold.       │
│   Fires once per session."   │
│                              │
│  [1] [Msg] SMS Contacts   ▼  │ (ExpansionTile)
│      wait 0s • dur 15s       │
│  ┌────────────────────────┐  │
│  │ Timing                 │  │
│  │ Event configuration    │  │
│  │ Retry & Advanced       │  │
│  └────────────────────────┘  │
│                              │
│  [+] Add Step                │ (bottom sheet — action steps only)
└──────────────────────────────┘
```

**Allowed step types:** only action steps
(`smsContact`, `phoneCallContact`, `callEmergency`, `loudAlarm`,
`countdownWarning`, `fakeCall`). Check-in types (`holdButton`,
`disguisedReminder`, `hardwareButton`) are not offered — the alert
is triggered by an OS battery event, not by user interaction.

**Chain editor:** reuses `StepConfigPanel` (same widget as the mode
editor) so timing, event-specific fields, and advanced options are
identical to normal mode steps.

**Reset button:** restores the chain to the seed default (single
`smsContact` step to all contacts).

**Semantics:** the chain runs exactly once per session. Main session
continues uninterrupted. See `lib/domain/models/battery_alert_config.dart`.

**TODO:** `lib/features/session/session_controller.dart`
(`_startBatteryMonitor`) and the `BatteryMonitorService`
implementation must be updated to drive the full chain via the
session engine. For now, the session controller falls back to the
legacy `sendSms` derived getter (true when any chain step is
`smsContact`), preserving pre-ITEM-8 behaviour.

---

## Security Submenu (`/settings/security`)

All three PINs in one place.

**Layout:**
```
┌──────────────────────────────┐
│  [Back] Security             │
├──────────────────────────────┤
│                              │
│  APP PIN                     │
│  ┌──────────────────────────┐│
│  │ App PIN                  ││
│  │ Locks app on open        ││
│  │ [Set PIN / Change / Off] ││ (button)
│  │ ℹ What is this?          ││
│  └──────────────────────────┘│
│                              │
│  SESSION END PIN             │
│  ┌──────────────────────────┐│
│  │ Session End PIN          ││
│  │ Required to disarm or    ││
│  │ end a running session    ││
│  │ [Set PIN / Change / Off] ││
│  │ Timeout: [15s slider]    ││
│  │ ☐ Allow biometric        ││ (fingerprint/face as substitute)
│  │ ℹ What is this?          ││
│  └──────────────────────────┘│
│                              │
│  DURESS PIN                  │
│  ┌──────────────────────────┐│
│  │ Duress PIN               ││
│  │ Entered at any prompt →  ││
│  │ fires distress chain     ││
│  │ silently                 ││
│  │ [Set PIN / Change / Off] ││
│  │ ℹ What is this?          ││
│  └──────────────────────────┘│
│                              │
└──────────────────────────────┘
```

**Behavior:**
- Each PIN has a dedicated setup flow (→ `/settings/pin-setup?type=app|sessionEnd|duress`)
- Duress PIN must differ from App PIN and Session End PIN (validated on save)
- Biometric substitute is available for Session End PIN only
- Info buttons (ℹ) open bottom sheets explaining each PIN's role

---

## Defaults Submenu (`/settings/defaults`)

Master source for all configurable defaults inherited by modes.

**Layout:**
```
┌──────────────────────────────┐
│  [Back] Defaults             │
├──────────────────────────────┤
│                              │
│  ┌──────────────────────────┐│
│  │ > GPS Logging            ││ (→ /settings/defaults/gps-logging)
│  │   Interval, accuracy,    ││
│  │   format, retention      ││
│  │                          ││
│  │ > Default Distress Chain ││ (dropdown; reorder in Distress Chains)
│  │   [Default Distress ▾]   ││
│  │                          ││
│  │ > Event Defaults         ││ (→ /settings/event-defaults)
│  │   Per-step-type defaults ││
│  │                          ││
│  │ > Reminder Templates     ││ (→ /settings/reminder-templates)
│  │   Disguised check-in     ││
│  │   notification templates ││
│  │                          ││
│  └──────────────────────────┘│
│                              │
└──────────────────────────────┘
```

**Note:** Each sub-item has an ℹ info button explaining what inheriting modes get from this setting.

---

## Settings Screen (`/settings`)

Central hub for app configuration.

**Layout:**
```
┌──────────────────────────────┐
│  [Back] Settings             │
├──────────────────────────────┤
│                              │
│  GENERAL                      │
│  ┌──────────────────────────┐│
│  │ Theme                    ││
│  │ ◉ Light ○ Dark ○ System ││ (radio)
│  │                          ││
│  │ Language                 ││
│  │ [Dropdown] English       ││ (14 languages)
│  │                          ││
│  └──────────────────────────┘│
│                              │
│  ───── pride divider ──────  │
│                              │
│  STEALTH MODE                │
│  ┌──────────────────────────┐│
│  │ Stealth: OFF          ▼  ││ (collapsed; tap to expand)
│  │ (or "Stealth: ON (3      ││
│  │  options configured)")   ││
│  │                          ││
│  │ When expanded:           ││
│  │ ☐ Enable Stealth         ││ (toggle)
│  │ Fake App Name: [field]   ││ (shown when enabled)
│  │ ☐ Fake Icon              ││ (shown when enabled)
│  │ ☐ Notification Disguise  ││ (shown when enabled)
│  │ Timer: Normal/Small/None ││ (shown when enabled)
│  │ ☐ Session Screen Stealth ││ (shown when enabled)
│  └──────────────────────────┘│
│                              │
│  ───── pride divider ──────  │
│                              │
│  SECURITY                    │
│  ┌──────────────────────────┐│
│  │ > Security               ││ (→ /settings/security)
│  │   App PIN, Session End   ││
│  │   PIN, Duress PIN        ││
│  │                          ││
│  └──────────────────────────┘│
│                              │
│  ───── pride divider ──────  │
│                              │
│  CONFIGURATION               │
│  ┌──────────────────────────┐│
│  │ > Profile                ││ (→ /profile)
│  │ > Modes & Chains         ││ (→ /settings/modes-and-chains)
│  │   Modes, Distress Chains,││
│  │   Battery Alert          ││
│  │ > Defaults               ││ (→ /settings/defaults)
│  │   GPS, Event Defaults,   ││
│  │   Templates              ││
│  │                          ││
│  └──────────────────────────┘│
│                              │
│  ───── pride divider ──────  │
│                              │
│  APP                         │
│  ┌──────────────────────────┐│
│  │ > About                  ││ (→ /settings/about)
│  │ > Send Feedback          ││ (→ /settings/feedback)
│  │ > Redo Onboarding        ││ (button, confirm)
│  │                          ││
│  │ Export / Import          ││
│  │ [Export Settings]        ││ (button)
│  │ [Import Settings]        ││ (button)
│  │                          ││
│  │ > Open Source Licenses   ││ (Flutter LicensePage)
│  │                          ││
│  └──────────────────────────┘│
│                              │
│  (Autosave for toggles, etc) │
│                              │
└──────────────────────────────┘
```

**Behavior:**

- **Theme:** Auto-saves on selection
- **Language:** Auto-saves, rebuilds localization. **Blocked during active session:** If user tries to change language while a session is running, show prompt: "End your session first."
- **Security:** → `/settings/security` (Security submenu: App PIN, Session End PIN, Duress PIN)
- **Modes & Chains:** → `/settings/modes-and-chains` (three sections: Session Modes, Distress Chains, Battery Alert)
- **Defaults:** → `/settings/defaults` (GPS Logging, Event Defaults + Templates)
- **Navigation items:** Tap → navigate to sub-screen
- **Export:** → JSON backup file. **Blocked during active session:** Show prompt: "End your session first."
- **Import:** → file picker, restore from JSON. **Blocked during active session:** Show prompt: "End your session first."
- **Redo Onboarding:** → confirmation dialog → launches `/onboarding`. **Blocked during active session:** Show prompt: "End your session first."
- **Licenses:** → Flutter's `LicensePage()` widget

**Session Locks:**
The following operations are BLOCKED during an active session and display the prompt "End your session first.":
- Contact deletion (Contacts screen swipe-to-delete, delete all)
- Backup import (Settings → Export/Import → Import Settings)
- Language change (Settings → Language dropdown)
- Profile/Redo Onboarding (Settings → Redo Onboarding)
This prevents accidental configuration changes during an active safety session.

---

## Profile Editor (`/profile`)

Edit user profile information.

**Layout:**
```
┌──────────────────────────────┐
│  [Back] Profile              │
├──────────────────────────────┤
│                              │
│  ┌──────────────────────────┐│
│  │ Photo (optional)         ││
│  │ [Circular picker, 96x96] ││ (tap to pick from camera/gallery)
│  │ (max 512x512)            ││
│  │                          ││
│  │ Name                     ││
│  │ [Text field]             ││ (auto-save on blur)
│  │                          ││
│  │ Phone Number             ││
│  │ [Text field]             ││
│  │                          ││
│  │ Physical Description     ││
│  │ [Multi-line text]        ││
│  │                          ││
│  └──────────────────────────┘│
│                              │
│  (Explicit Save button:      │
│  Not needed, auto-saves)     │
│                              │
└──────────────────────────────┘
```

**Behavior:**
- All fields auto-save on blur
- Photo picker: camera or gallery
- No explicit save button (inline feedback)

---

## Event Defaults Screen (`/settings/event-defaults`)

Global defaults for all 9 step types only. Accessible via Settings → Event Defaults.

Reminder templates are NOT part of this screen — they live at their
own route (`/settings/reminder-templates`, `TemplatesScreen`). Access
templates either from the top-level Settings entry or from the
"Manage reminder templates" link inside the DisguisedReminder event
form in the mode editor.

### Step Defaults

Each step type is an `ExpansionTile`. Tapping a step type expands it **inline** to reveal its default configuration fields (identical two-tier layout to the mode editor: timing, type-specific options, nested Advanced section). Tapping again collapses it. No navigation to a separate detail screen.

**Layout:**
```
┌──────────────────────────────┐
│  [Back] Event Defaults       │
│  [Step Defaults] [Templates] │ (tabs)
├──────────────────────────────┤
│                              │
│  CHECK-IN METHODS            │
│  ┌──────────────────────────┐│
│  │ [Hold icon]              ││ (ExpansionTile)
│  │ Hold Button              ││
│  │ Keep a button held down  ││ (description preview)
│  │ ▶ (tap to expand)        ││
│  │   ┌──────────────────┐   ││ (expands inline)
│  │   │ Hold Style       │   ││
│  │   │ [Timing section] │   ││
│  │   │ [▶ Advanced]     │   ││
│  │   └──────────────────┘   ││
│  │                          ││
│  │ [Reminder icon]          ││ (ExpansionTile, collapsed)
│  │ Disguised Reminder       ││
│  │ Respond to fake notifs   ││
│  │ ▶ (tap to expand)        ││
│  │                          ││
│  └──────────────────────────┘│
│                              │
│  ───── pride divider ──────  │
│                              │
│  ESCALATION STEPS            │
│  ┌──────────────────────────┐│
│  │ [Countdown icon]         ││ (ExpansionTile, collapsed)
│  │ Countdown Warning        ││
│  │ Visual/audio warning     ││
│  │ ▶                        ││
│  │                          ││
│  │ [Phone icon]             ││
│  │ Fake Call                ││
│  │ Incoming call to distract││
│  │ ▶                        ││
│  │                          ││
│  │ [Message icon]           ││
│  │ SMS Alert                ││
│  │ Send message to contacts ││
│  │ ▶                        ││
│  │                          ││
│  │ [Phone icon]             ││
│  │ Phone Call Contact       ││
│  │ Call emergency contact   ││
│  │ ▶                        ││
│  │                          ││
│  │ [Alarm icon]             ││
│  │ Loud Alarm               ││
│  │ Max-volume siren + flash ││
│  │ ▶                        ││
│  │                          ││
│  │ [Emergency icon]         ││
│  │ Call Emergency Services  ││
│  │ Dial 112/911 etc.        ││
│  │ ▶                        ││
│  │                          ││
│  └──────────────────────────┘│
│                              │
│  ───── pride divider ──────  │
│                              │
│  PANIC TRIGGER               │
│  ┌──────────────────────────┐│
│  │ [Button icon]            ││ (ExpansionTile, collapsed)
│  │ Hardware Button Panic    ││
│  │ Press volume/headphone   ││
│  │ button to escalate       ││
│  │ ▶                        ││
│  │                          ││
│  └──────────────────────────┘│
│                              │
└──────────────────────────────┘
```

**Behavior:**
- Tap any step type → expands inline (ExpansionTile), showing the same two-tier config layout as mode editor steps
- All 9 step types shown; multiple can be open simultaneously
- Changes auto-save on collapse

## Templates Screen (`/settings/reminder-templates`)

Standalone screen listing all reminder templates (built-in + custom)
as a single unified list. Accessed via **Settings → Reminder Templates**
at the top level, and from the "Manage reminder templates" link inside
the DisguisedReminder event form in the mode editor. The list UX
mirrors the Modes screen.

**Layout:**
```
┌──────────────────────────────┐
│  [Back] Reminder Templates   │
├──────────────────────────────┤
│                              │
│  ┌──────────────────────────┐│
│  │ [Cal icon] Calendar      ││
│  │  "Meeting in 15 min"     ││
│  │  "Conference Room B"  [⋮]││ (popup: Edit/Duplicate/Delete)
│  │                          ││
│  │ [Duo icon] Duolingo      ││
│  │  "Time for your lesson!" ││
│  │  "Don't break your       ││
│  │   streak!"           [⋮] ││
│  │  ... (8 built-ins + any  ││
│  │       custom templates)  ││
│  └──────────────────────────┘│
│                              │
│  [FAB +]  Create template    │
│                              │
└──────────────────────────────┘
```

**Create flow:** FAB opens a bottom sheet with two options:

- **From template** — sub-sheet listing the 8 built-in templates. Tap
  one → creates a new custom template pre-filled with its fields
  (name suffixed " (Copy)") via
  `TemplatesController.createFromTemplate()`, then opens the editor.
- **From scratch** — opens the blank template editor directly
  (`/settings/templates/edit`).

**Per-tile popup menu (Edit / Duplicate / Delete):**

- **Edit** — opens the template editor on the existing ID.
- **Duplicate** — `TemplatesController.duplicate(id)` creates a copy
  with a fresh UUID, name suffixed " (Copy)", then opens the editor on
  the new copy.
- **Delete** — custom templates: confirmation dialog
  ("Delete \"{name}\"?") → removed. Built-in templates: menu item is
  disabled with tooltip "Built-in templates cannot be deleted".

**Empty state** (no templates at all): icon + "No templates yet" +
short body + a FilledButton that triggers the create sheet. Mirrors
the `ModesScreen` empty state (decision C5 style).

**Info:** "Templates are randomly rotated during disguised reminder
steps (if randomizeTemplateOrder is enabled)"

---

**Event Default Inline Config (within ExpansionTile):**

The config fields shown when a step type is expanded in Event Defaults are the same fields previously described for the detail screen, now rendered inline. The LogarithmicSlider requirement applies here:

All time-based sliders MUST display the actual current value next to the slider (e.g., "30s", "2m 15s"). The Randomize toggle shows the resulting jitter range: "30s ± 6s (24–36s)". Changes auto-save on collapse.

A [Preview] button inside the expanded section simulates the step locally (shows the actual step UI, as in simulation mode).

---

## Template Editor (`/settings/defaults/event-defaults/templates/edit`)

Create or edit a reminder template with live preview.

**Layout:**
```
┌──────────────────────────────┐
│  [Back] Template Editor      │
├──────────────────────────────┤
│                              │
│  [Live Preview (55% scale)]  │
│  ┌──────────────────────────┐│
│  │  [Calendar] 2:35pm      ││
│  │  Meeting in 15 min      ││
│  │  Do you want to open    ││
│  │  the event?             ││
│  │  [Open] [Dismiss]       ││
│  │                          ││
│  │  (Scales & updates live)││
│  └──────────────────────────┘│
│                              │
│  Form:                       │
│  ┌──────────────────────────┐│
│  │ Name                     ││
│  │ [Text field]             ││ (e.g., "Calendar Reminder")
│  │                          ││
│  │ Icon                     ││
│  │ [Icon picker] (dropdown) ││ (Calendar, Duolingo, etc.)
│  │                          ││
│  │ Title                    ││
│  │ [Text field]             ││ (e.g., "Meeting in 15 min")
│  │                          ││
│  │ Subtitle                 ││
│  │ [Text field] (optional)  ││
│  │                          ││
│  │ Body                     ││
│  │ [Multi-line field]       ││ (optional)
│  │                          ││
│  │ Image                    ││
│  │ [Image picker]           ││ (optional, tap to pick)
│  │                          ││
│  │ Confirmation Type        ││
│  │ ◉ Tap Title              ││ (radio)
│  │ ○ Tap Button             ││
│  │ ○ Swipe                  ││
│  │                          ││
│  │ Button Label (if tap)    ││
│  │ [Text field]             ││ (e.g., "Open")
│  │                          ││
│  │ Keyword (what user taps) ││
│  │ [Text field]             ││ (internal, for logging)
│  │                          ││
│  │ Display Style            ││
│  │ ◉ Full Screen            ││ (radio)
│  │ ○ Subtle (notification)  ││
│  │                          ││
│  └──────────────────────────┘│
│                              │
│  [Cancel] [Save]             │
│                              │
└──────────────────────────────┘
```

**Behavior:**

- **Live Preview:** Scales to 55% width, updates as user types
- **Icon picker:** Shows icons for Calendar, Duolingo, Delivery, Weather, Email, Chat, Bank, Social Media
- **Image picker:** Optional, tap to select from gallery
- **Confirmation type:** Determines how reminder closes (tap, button, swipe)
- **All fields update preview instantly**
- **Save:** Creates or updates template
- **Cancel:** Discards changes

---

## About Screen (`/settings/about`)

App information and links.

**Layout:**
```
┌──────────────────────────────┐
│  [Back] About                │
├──────────────────────────────┤
│                              │
│  [Guardian Angela Logo]      │ (96x96)
│  Guardian Angela             │
│                              │
│  Version: 0.1.0              │
│                              │
│  "Your angel's got your back"│
│  (tagline)                   │
│                              │
│  ───── pride divider ──────  │
│                              │
│  Author: Jonas Eschle        │
│  Email: guardian.angela.app  │
│          @gmail.com          │
│                              │
│  ───── pride divider ──────  │
│                              │
│  Technical Information       │
│  Bundle ID: com.guardianangela.app
│  Platforms: Android, iOS     │
│                              │
│  ───── pride divider ──────  │
│                              │
│  Resources                   │
│  [Privacy Policy]            │ (external link)
│  [Terms of Service]          │ (external link)
│  [Source Code]               │ (GitHub link)
│  [Open Source Licenses]      │ (Flutter LicensePage)
│                              │
│  ───── pride divider ──────  │
│                              │
│  "Made with love for LGBTQ+  │
│   safety."                   │
│  (statement)                 │
│                              │
└──────────────────────────────┘
```

**Behavior:**
- Show version from `package_info_plus`
- Links open in external browser (privacy policy, terms, GitHub)
- Open Source Licenses → Flutter's `LicensePage()` widget

---

## Feedback Screen (`/settings/feedback`)

In-app feedback form, also shown post-session.

**Layout:**
```
┌──────────────────────────────┐
│  [Back] Feedback             │
├──────────────────────────────┤
│                              │
│  "We'd love to hear from you"│
│  (heading)                   │
│                              │
│  Category                    │
│  [Dropdown]                  │ (bug, feature, other)
│  - Bug Report                │
│  - Feature Request           │
│  - Other                     │
│                              │
│  Email (optional)            │
│  [Text field]                │
│  (for follow-up)             │
│                              │
│  Message                     │
│  [Multi-line text field]     │
│  (required)                  │
│                              │
│  Attach Session Log          │
│  ☐ Include last session      │ (checkbox)
│                              │
│  [Cancel] [Send]             │
│                              │
└──────────────────────────────┘
```

**Behavior:**
- Category dropdown: Bug, Feature, Other
- Email: optional (can be empty)
- Message: required, min 10 chars
- Session log: optional checkbox
- On send:
  1. Validate message
  2. Build feedback object (email, category, message, optional log)
  3. Save to local history or send to backend (TBD)
  4. Show toast: "Thanks for your feedback!"
  5. Return to previous screen

---

## Backup & Restore Screen (`/settings/backup`)

Export and import all app data. Accessible via Settings → APP section → Export/Import buttons, or directly from Settings.

**Layout:**
```
┌──────────────────────────────┐
│  [Back] Backup & Restore     │
├──────────────────────────────┤
│                              │
│  EXPORT                      │
│  ┌──────────────────────────┐│
│  │ ☑ Include session logs   ││ (toggle, default ON)
│  │   Session history with   ││
│  │   timestamps and events  ││
│  │   (may include location) ││
│  │                          ││
│  │ ☑ Include media          ││ (toggle, default ON)
│  │   Audio recordings,      ││
│  │   profile photo          ││
│  │                          ││
│  │ [Export Settings]        ││ (button, triggers share sheet)
│  └──────────────────────────┘│
│                              │
│  ───── pride divider ──────  │
│                              │
│  IMPORT                      │
│  ┌──────────────────────────┐│
│  │ [Import Settings]        ││ (button, file picker)
│  │ ⚠ Overwrites all data   ││
│  └──────────────────────────┘│
│                              │
└──────────────────────────────┘
```

**Behavior:**

- **Include session logs toggle (default ON):** When enabled, the JSON export includes the full `sessionLogs` array (timestamps, events, GPS coordinates). When disabled, `sessionLogs` is omitted — producing a smaller, location-free backup containing only settings, contacts, modes, templates, and profile.
- **Include media toggle (default ON):** When enabled, audio recordings and profile photos are embedded in the export.
- **Export:** Triggers `BackupService.exportToJson()` with the selected options, then shares via `share_plus` OS share sheet.
- **Import:** Opens file picker. Shows confirmation dialog ("This will overwrite all current data") before proceeding. **Blocked during active session:** Shows prompt "End your session first."
- All buttons are **blocked during active session**.

---

## Past Events Screen (`/past-events`)

History of completed sessions (real and simulated).

**Layout:**
```
┌──────────────────────────────┐
│  [Back] History              │
│  [Real Sessions] [Simulated] │ (tabs)
├──────────────────────────────┤
│  Sorted newest first         │
│                              │
│  ┌──────────────────────────┐│
│  │ Mode: Walk Mode          ││
│  │ Apr 02, 9:45 PM → 9:50 PM││ (relative time)
│  │ Duration: 5m 23s         ││
│  │                          ││
│  │ (SIM badge, if simulated)││
│  │ [Swipe to delete]        ││
│  │                          ││
│  │ [Tap for details]        ││
│  └──────────────────────────┘│
│                              │
│  ┌──────────────────────────┐│
│  │ Mode: Date Mode          ││
│  │ Apr 01, 7:30 PM → 10:15 PM
│  │ Duration: 2h 45m         ││
│  │                          ││
│  │ (no SIM badge)           ││
│  │ [Swipe to delete]        ││
│  │                          ││
│  │ [Tap for details]        ││
│  └──────────────────────────┘│
│                              │
│  (Empty state:)             │
│  "No sessions yet"           │
│  "Start a session to see     │
│   history"                   │
│                              │
│  [Overflow menu]            │
│  "Delete all"               │
│  "Delete older than..."     │ (1d, 1w, 1m, 3m, 6m, 1y)
│  "Auto-delete after:"       │ (30d, 90d, 1y, never)
│                              │
└──────────────────────────────┘
```

**Behavior:**

- **Search bar:** filters by mode name (Extra 50).
- **Filter chips (Extra 50):** Wrap-layout chips for type (all / real / simulation), date range, mode, and outcome (disarmed / completed / distress-fired / session-ended). All active chips are ANDed together.
- **Sorting:** Newest first
- **Swipe or trash icon:** triggers a *soft-delete* (Extra 11). A SnackBar appears with a 5-second UNDO action; dismissing the SnackBar finalises the soft-delete by keeping the log in the repository for 7 days.
- **Tap:** → `/past-events/detail?id={logId}`
- **App bar actions:** Trash (opens the Trash screen) and Clear All (hard-delete everything with confirmation).
- **Trash screen (Extra 11):** Shows all soft-deleted logs with a retention note. Per-entry actions are Restore and Delete Permanently. On screen open and again on [`HistoryController.build`], any tombstone older than 7 days is hard-deleted via the repository.
- **Auto-delete:** After 7 days in Trash, the log is permanently removed from the repository. This is in addition to any user-configured retention policy.

---

## Session Log Detail (`/past-events/detail?id=...`)

Detailed view of a completed session with event timeline.

**Layout:**
```
┌──────────────────────────────┐
│  [Back] Session Log          │
├──────────────────────────────┤
│                              │
│  Mode: Walk Mode             │
│  (SIM badge, if simulated)   │
│                              │
│  Start: Apr 02, 9:45:20 PM   │
│  End: Apr 02, 9:50:43 PM     │
│  Duration: 5m 23s            │
│                              │
│  Location: Home (last GPS)   │
│  (if GPS logging enabled)    │
│                              │
│  ───── pride divider ──────  │
│                              │
│  Event Timeline:             │
│  ┌──────────────────────────┐│
│  │ 9:45:20 PM               ││
│  │ [Hold] Hold Button       ││
│  │ Session started          ││
│  │ (teal pill)              ││
│  │                          ││
│  │ 9:45:25 PM (+5s)         ││
│  │ [Hold] Hold Button       ││
│  │ User held button         ││
│  │                          ││
│  │ 9:45:30 PM (+5s)         ││
│  │ [Hold] Hold Button       ││
│  │ User released            ││
│  │                          ││
│  │ 9:45:35 PM (+5s)         ││
│  │ [Grace] Grace Period     ││
│  │ Countdown started        ││
│  │                          ││
│  │ 9:45:38 PM (+3s)         ││
│  │ [Hold] Hold Button       ││
│  │ User re-held button      ││
│  │ (success, green)         ││
│  │                          ││
│  │ 9:50:43 PM (+5m 5s)      ││
│  │ [X] Session Ended        ││
│  │ User confirmed safe      ││
│  │ (green check)            ││
│  │                          ││
│  │ (Click event for details)││
│  │ [Details Modal]          ││
│  │ "Fake Call               ││
│  │  Ring: 30 seconds        ││
│  │  Decline: Yes (at 15s)"  ││
│  │                          ││
│  └──────────────────────────┘│
│                              │
│  [Share as PDF]              │ (export)
│  [Delete]                    │
│                              │
└──────────────────────────────┘
```

**Behavior:**

- **Header:** Mode name, SIM badge, start/end time, duration, GPS location (if available)
- **Timeline:** Color-coded events (teal = safe, amber = warning, red = escalation, green = success)
- **Event format:** Each event shows two time values:
  1. **Absolute timestamp** — e.g., "9:45:25 PM" (local time)
  2. **Diff to previous event** — e.g., "+5s" or "+3m 20s" (how long since the previous event). The first event (session start) shows no diff.
  - Format: `9:45:25 PM (+5s) [Step icon] Event description`
- **Tap event:** Shows expanded details modal
  - Event type
  - Absolute timestamp
  - Diff to previous event
  - What happened (success/failure)
  - Any error messages or details
- **Share:** Share button in app bar opens system share sheet with options:
  - **Text summary:** Plain text with mode name, timestamps, duration, and event list (for messaging apps)
  - **JSON export:** Machine-readable session log (for backup/import)
  - **PDF report:** Formatted timeline with location map if GPS available (for documentation)
  - Uses `share_plus` package for native share sheet integration
- **Delete:** Confirmation dialog → remove from history

---

## Shared Widgets

### PinKeypad (`lib/core/widgets/pin_keypad.dart`)

Shared numeric keypad widget used by both `PinEntryScreen` and `PinSetupScreen`. Extracted to avoid code duplication.

```dart
/// Numeric keypad for PIN entry. Renders a 4×3 grid of digit buttons
/// (1-9, action, 0, backspace) with consistent styling.
class PinKeypad extends StatelessWidget {
  final ValueChanged<int> onDigit;      // Called with 0-9
  final VoidCallback onBackspace;
  final VoidCallback? onAction;         // Optional bottom-left action
  final Widget? actionIcon;             // Icon for action button
  final bool biometricAvailable;        // Show biometric icon
}
```

**Layout:** 4 rows × 3 columns. Digits 1-9 in rows 1-3, bottom row: [action/biometric] [0] [backspace]. Each key is a circular ripple button with haptic feedback.

**Used by:**
- `PinEntryScreen` — action = biometric icon (if available)
- `PinSetupScreen` — action = none (hidden)

---

## Navigation & Deep Linking

All routes support deep linking via GoRouter. Query parameters are supported:

```
context.go('/contacts/edit?id=123')
context.go('/modes/edit?id=abc')
context.go('/past-events/detail?id=xyz')
context.go('/settings/event-defaults/detail?type=fakeCall')
context.go('/session/completed?duration=323')
```

Handled in `lib/router/app_router.dart` via `state.uri.queryParameters`.

---

## State Management & Navigation Patterns

### Riverpod Providers

All screens are managed by Riverpod controllers:

- **HomeScreen:** `homeScreenController` (mode selection)
- **SessionScreen:** `sessionController` (session state)
- **ContactsScreen:** `contactsController` (contacts list)
- **ModesScreen:** `modesController` (modes list)
- **SettingsScreen:** `settingsController` (app settings)
- Etc.

Controllers expose state as providers that screens listen to.

### GoRouter Navigation

All navigation uses `context.go()` or `context.push()`:

```dart
context.go('/session');  // Replace entire stack
context.push('/contacts/edit?id=123');  // Push on stack
```

PopScope prevents accidental back navigation on critical screens (e.g., fake call, active session).

---

## Validation & Error Handling

### Form Validation

All forms validate on blur and on save:

- **Name fields:** Min 2 chars, max 50 chars, trim whitespace
- **Phone fields:** Locale-specific validation (E.164 format)
- **Numeric fields:** Range checks (e.g., 0–100% for volume)
- **Enums:** Radio/dropdown enforce single selection
- **Passwords/PINs:** 4–6 digits, no spaces

Error messages appear inline below fields.

### Permission Requests

Permission requests show user-friendly explanations:

- "Notifications: Alerts and reminders"
- "Location: Included in emergency messages"
- "Phone: Required to make calls and send SMS"
- "SMS: Required to send messages to contacts"

If permission denied, show "Open Settings" link to platform settings.

### Session Validation

Before starting session:

1. Mode selected? → Require selection
2. Mode has steps? → Warn if empty
3. Required contacts available? → Warn if missing
4. Permissions granted? → Request if needed
5. Battery optimization whitelisted? → Show guidance on first session

---

## Loading & Loading States

- **Session loading:** 1.5s "Starting simulated/real session..." screen with progress bar
- **Onboarding submit:** Show spinner on Next button
- **Settings save:** Show spinner on Save button
- **Long operations:** Show progress dialog with cancel button (where appropriate)

---

## Accessibility (WCAG 2.1 AA)

All screens include:

- **Text contrast:** ≥ 4.5:1 normal text, ≥ 3:1 large text
- **Semantics labels:** All interactive elements have Semantics labels
- **Font scaling:** UI usable under system font scaling (up to 200%)
- **Screen readers:** TalkBack (Android) and VoiceOver (iOS) fully functional
- **One-hand operation:** Critical buttons in bottom third of screen (reachable with thumb)
- **Touch targets:** ≥ 48dp minimum for interactive elements

---

## Animation & Transitions

- **Page transitions:** Standard Flutter route animations (fade/slide)
- **Button feedback:** Ripple on tap (Material)
- **Hold button:** Color transition on hold/release (teal/amber)
- **Progress bar:** Linear fill over step duration
- **Countdown:** Numeric digits with smooth updates
- **Simulation speed slider:** Real-time speed multiplier feedback
- **Slider validation:** Spring bounce on incomplete swipe

---

## Summary

This specification covers 25+ distinct screens organized into logical flows:

1. **Onboarding:** 9-page guided setup
2. **Home & Core:** Home, Session, Fake Call, Chain Exhausted, Simulation
3. **Contacts:** List, Form
4. **Modes:** List, Editor
5. **Settings Hub:** Profile, Event Defaults (Detail), Templates (Editor), About, Feedback
6. **History:** List, Detail

Each screen includes layout, behavior, validation, and accessibility notes. Navigation between screens is fully mapped via GoRouter with query parameter support for dynamic data passing.

All screens follow Guardian Angela's design principles: safety first, configurable everything, stealth when needed, one-hand operation, and offline-first capability.
