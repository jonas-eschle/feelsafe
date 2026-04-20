# Decisions Round 2 — Spec Clarifications (2026-04-17)

60 design decisions collected from user via structured Q&A.
Applied to specs 00-11 and implementation thereafter.

---

## Group A — Safety-critical behavior

| # | Decision | Rule |
|---|---|---|
| A1 | Fake call decline default | `declineIsSafe=true` — decline resets chain to step 0 |
| A2 | Real call during emergency countdown | Engine pauses; countdown resumes after real call ends |
| A3 | Wrong PIN in distress cancel window | Shake + toast; after **`wrongPinThreshold` wrong PINs (default 5), auto-confirm distress** (fail-safe). Threshold is user-configurable in Settings → Security. |
| A4 | Duress PIN during active distress chain | No-op (idempotent) |
| A5 | Disarm with queued SMS pending | Cancel WorkManager job if still pending |
| A6 | Max pause duration safety cap | Unlimited; user controls |

---

## Group B — Default values

| # | Decision | Value |
|---|---|---|
| B1 | Hardware panic pressCount | **5** |
| B2 | Global disguisedReminder retryCount | **1** (2 attempts) |
| B3 | Global fakeCall retryCount | **0** (1 attempt) |
| B4 | LoudAlarm gradualVolume | **true** (ramp up) |
| B5 | LoudAlarm flashSpeed | **Enum 3 options**: fast (300ms) / medium (500ms) / slow (1000ms) |
| B6 | App theme default | **System** (follow OS) |
| B7 | pinTimeoutSeconds scope | App PIN + Session End PIN; **Duress PIN has no timeout** |
| B8 | Session log retention | **Configurable, default 180 days**. Smart retention: logs that triggered a critical event (SMS, call, distress) kept unlimited |

---

## Group C — Scope & features

| # | Decision | Rule |
|---|---|---|
| C1 | iOS headphone remote hardware button | **Yes** — implement via `audio_service` |
| C2 | Built-in fake-call voice recordings | **All 14 languages** |
| C3 | SmsContactConfig.includeMedicalInfo | **Keep** per-step toggle |
| C4 | DisguisedReminderConfig.templateIds | **Keep** per-step template filter |
| C5 | If user deletes ALL modes | **Empty state + CTA**. No auto-reseed |
| C6 | Settings hub structure | **Both hubs**: `/settings/defaults` AND `/settings/modes-and-chains` |
| C7 | Templates scope | **Two scopes**: global templates (from Event Defaults, available to all modes) + mode-local templates (created within a mode, flag = "generally available" default). Uses existing `ReminderTemplate.isGlobal` |

---

## Group D — UI behavior

| # | Decision | Rule |
|---|---|---|
| D1 | Hold button countdown on re-hold | **Cancel + restart**: next release starts fresh countdown from `durationSeconds` |
| D2 | Simulation "Leap" behavior | Replaces active timer with **1s countdown** (skip to 1s before next event) |
| D3 | Device rotation during session | **Lock critical screens to portrait** (SessionScreen, FakeCallScreen). Others rotate |
| D4 | Notification tap during disguisedReminder wait phase | **Configurable** per step: new `DisguisedReminderConfig.resetOnEarlyCheckIn` field (default true — early tap resets timer) |
| D5 | Stealth sub-options when master OFF | **Always visible** (user can pre-configure) |

---

## Extras (misc design)

| # | Decision | Rule |
|---|---|---|
| E | Missing UI to implement | Battery Alert link, wrongPinThreshold slider, Biometric toggle, PIN timeout slider, Alarm gradual-volume sliders, Redo Onboarding action, App version display, DisguisedReminder uses real templates |
| 10 | App PIN wrong attempts | **No consequence** (always retry; not safety-critical) |
| 11 | Session log deletion | **Soft delete + undo** — 'trash' recoverable for 7 days, then purged |
| 12 | GPS denied + chain has includeLocation | **Block session start** |
| 13 | Force-close during session | Show recovery dialog on next launch; **no resume** — inform user which step crashed, end cleanly |
| 14 | WorkManager SMS retries exhausted | **Notification**: "SMS to Alice never sent — tap to retry manually" |
| 15 | Channel priority per step | **Each event has ONE channel** (channel chosen per-step in mode editor) |
| 15b | Channel selection | **Per-step**: `SmsContactConfig.channel` field. Contacts without that channel are **greyed out** in the contact picker |
| 15c | Channel fails | **Validation blocks save** when selected contacts lack the channel. Runtime: log failure, move on |
| 16 | Flutter SDK version | **Bump to latest** — allow newest packages. Update CI |
| 17 | Biometric fallback on cancel | **Fall back to PIN** keypad |
| 18 | Onboarding permission denial | **Skip allowed**; block later only if real session needs the missing permission. Permission explanations make conditionality clear (e.g., "Location only needed if your chain includes GPS") |
| 19 | Session log PII in export | **Toggle** per export |
| 20 | Emergency number change during session | **Blocked** by session lock |
| 21 | Lost Hive encryption key | **Show data-loss dialog**: "Start fresh or restore from backup?" |
| 22 | GPS trigger mode without destination | **Prompt at start** (skippable; skipping disables trigger for that session) |
| 23 | Stealth fake app name default | **'Music'** |
| 24 | Step 0 type rules | **Any type allowed at step 0** (not restricted to check-in types) |
| 25 | Emergency number format validation | **Free-form**, but validate pattern and warn if suspicious (non-digit, too short/long) |
| 26 | Contact phone validation | **Free-form**, warn if suspicious. **+41**-style preferred. Add **contact import** (device picker) |
| 27 | Contact import (new feature) | **Simple picker**: user selects one from device contacts. App fills name + phone |
| 28 | Import user's own number | Onboarding has **'Use my number'** button (from SIM / device 'Me' contact) |
| 29 | Real call over FakeCallScreen | **Dismiss fake, show real** |
| 30 | After real call ends (during fakeCall step) | **Resume where paused** (fake call step resumes) |
| 31 | Real call during holdButton | **Auto-pause session**; resume exact state when call ends |
| 32 | Default FakeCallConfig.voiceRecordingPath | **Built-in per-language** recording |
| 33 | Stealth notification icon | **Configurable**, default = **music icon** |
| 34 | Backup export size | **Exclude media by default** |
| 35 | Disguised reminder on locked device | **Full-screen wake** |
| 36 | Reminder day/night behavior | **Same behavior** (no quiet hours for v1) |
| 37 | After normal session end | **Show completion screen** (SessionCompletedScreen) |
| 38 | Battery optimization prompt | **Always prompt** during onboarding |
| 39 | Custom voice recording max | **2 minutes** |
| 40 | fakeLockScreen wake | **Any touch** |
| 41 | SMS {name} with no profile name | **'the owner of this phone'** |
| 42 | Android 13 notif permission | **Both**: onboarding + re-ask on first session if denied |
| 43 | Language switch mid-app | **Instant rebuild** |
| 44 | Missing permission at session start | **Block start, list missing permissions** with grant buttons |
| 45 | SMS queue persistence | **Hive** (already encrypted) |
| 46 | Disarm during retryCount=0 grace | **Reset to step 0** (standard disarm behavior) |
| 47 | Export: medical in logs | **Follow log's flag** (each log remembers whether it had medical info) |
| 48 | Multiple distress chains | **Support multiple** global chains; first = default. Mode picks by `distressChainId` |
| 49 | Simulation silent toggle persistence | **Simulation defaults to silent=ON** (no persistence across sessions; each sim starts silent) |
| 50 | Session log search/filter | **Full search + filter chips** (date, mode, outcome, simulation) |
| 51 | App PIN length | **4-8 configurable** (user picks at setup) |
| 52 | PIN length per PIN | **Same range for all 3 PINs** |
| 53 | Duress PIN at App PIN prompt | **Unlock app + fire distress silently** |
| 54 | Simulation chain exhausted | **Completion screen** (same as real mode) |
| 55 | Strategy errors in log UI | **User-visible summary** (red icon in timeline) |
| 56 | Emergency call confirmation cancel | **Swipe slider** (prevents accidental cancel) |
| 57 | Reminder template icons | **Real-app mimicking icons** per template (Calendar icon for Calendar template, etc.) |
| 58 | Auto theme switching | **No** — user picks |
| 59 | Unsaved edits across backgrounding | **Preserved**; warn on exit |
| 60 | FakeCall answered with no voice recording | **Silent 'Calling...' screen** until user hangs up |
| 61 | Multi-user profiles | **No** — single profile. Use OS user profiles if needed |
| 62 | End session from paused state | **PIN required** if Session End PIN is set (no special case) |
| 63 | Safety Setup Checklist on home | **Yes** — collapsible banner, 6 items, dismissible |
| 64 | Missing distressChainId at session start | **Block start**. Also **warn when deleting** a distress chain used by any mode |
| 65 | Trivial session logging | **Always log** every session start/end |
