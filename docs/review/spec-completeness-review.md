# Spec 13 (v2 Rewrite) -- Completeness Review

**Reviewer:** Architecture/PM review  
**Date:** 2026-04-11  
**Document under review:** `docs/spec/13-rewrite-v2-spec.md`  
**Severity scale:** CRITICAL (blocks implementation), HIGH (will cause rework), MEDIUM (ambiguous, needs clarification), LOW (nice-to-have)

---

## 0. Meta-Problem: Scope and Authority of This Spec

**Severity: CRITICAL**

The spec opens with "NORMATIVE and SUPERSEDES all previous specs (00-12)." But specs 00-12 contain thousands of lines of detail that spec 13 does not reproduce: full screen layouts with ASCII wireframes, complete data model Dart code, service API signatures, notification channel definitions, Hive encryption setup, accessibility requirements, session validation checklists, export format schemas, and more.

Spec 13 is 680 lines. Spec 04 (Screens & Navigation) alone is 2100+ lines. Spec 03 (Data Models) is 900+ lines. Spec 05 (Services) is 1000+ lines.

**The problem:** If spec 13 truly supersedes specs 00-12, then everything NOT mentioned in spec 13 is undefined. But spec 13 omits the vast majority of implementation detail. If spec 13 does NOT truly supersede them, then there are conflicts (3-page vs 4-page onboarding, 5 vs 14 languages, etc.) with no clear resolution.

**Decision needed:**
1. Spec 13 is a high-level design document that SUPPLEMENTS specs 00-12 (which remain normative for detail), OR
2. Spec 13 supersedes only WHERE IT EXPLICITLY ADDRESSES a topic, with specs 00-12 remaining normative for everything else, OR
3. Spec 13 is the only normative document (requires massive expansion to be implementable)

This must be resolved before engineering begins. The rest of this review assumes interpretation (2).

---

## 1. Screen Inventory

**Severity: HIGH**

Spec 13 mentions the following screens by name or description: home (section 10.3), session (section 10.4), onboarding (section 9.1), fake call (section 3.4 behavior only). That is 4 screens out of ~25 defined in spec 04.

### Screens not mentioned at all in spec 13:

| Screen | Route (from spec 04) | Gap |
|--------|---------------------|-----|
| Mode Editor | `/modes/edit?id=...` | Not mentioned. Spec 13 defines `SessionMode` fields but no UI for editing them. |
| Chain Step Editor | inline in mode editor | Not mentioned. 9 step types with different config -- how does the user configure them? |
| Contacts List | `/contacts` | Not mentioned. |
| Contact Form | `/contacts/edit?id=...` | Not mentioned. |
| Profile Editor | `/profile` | Not mentioned. UserProfile model defined in section 7.4 but no screen. |
| Settings Hub | `/settings` | Section 8 defines settings BEHAVIOR but no screen layout or navigation. |
| Event Defaults | `/settings/event-defaults` | Not mentioned. |
| Template Editor | `/settings/templates/edit?id=...` | Not mentioned. Reminder templates not discussed at all. |
| Template List | `/settings/templates` | Not mentioned. |
| Past Events (History) | `/past-events` | Not mentioned. |
| Session Log Detail | `/past-events/detail?id=...` | Not mentioned. |
| Chain Exhausted Screen | `/session/completed` | Mentioned obliquely ("UI shows fake session ended" for distress) but no spec for normal completion. |
| Simulation Summary | `/session/simulation-summary` | Not mentioned. Section 11 defines simulation controls but not the post-simulation summary screen. |
| PIN Setup | dialog | Not a dedicated screen spec. Section 1.3 defines PIN behavior but not the setup flow. |
| PIN Entry | dialog/screen | Same. |
| Modes List | `/modes` | Not mentioned. |
| About Screen | `/settings/about` | Not mentioned. |
| Feedback Screen | `/settings/feedback` | Not mentioned. |
| Backup & Restore | `/settings/backup` | Not mentioned. |
| Wrong PIN Chain Editor | `/settings/wrong-pin-chain` | Not mentioned. Wrong PIN threshold is mentioned as a distress trigger in section 4.2 but no editor. |
| Duress Chain Editor | `/settings/duress-chain` | Not mentioned. Duress PIN is mentioned as a trigger but no configuration UI. |
| Battery Alert Chain Editor | `/settings/battery-alert-chain` | Not mentioned. Battery alert defined in section 4.3 but no editor. |

**Impact:** An engineer reading only spec 13 would implement ~4 screens and have no guidance for the other ~21. Even with spec 04 as fallback, spec 13 introduces new concepts (triggers, disarm triggers, distress triggers) that have no screen counterparts in spec 04.

---

## 2. Data Persistence

**Severity: HIGH**

### 2.1 Save timing -- unspecified

Spec 13 defines models (sections 7.1-7.6) but never states WHEN data is persisted:
- On every field mutation? (expensive)
- On screen exit? (risk of data loss on crash)
- On explicit save? (which actions trigger save?)
- Auto-save with debounce?

Spec 03 implies immediate persistence via Hive box operations, but spec 13 says nothing.

### 2.2 Hive encryption key management -- unspecified

Spec 13 says "Hive CE (encrypted local NoSQL, JSON serialization via Box<String>)" in section 15.1. But:
- How is the encryption key generated?
- Where is it stored? (flutter_secure_storage? Android Keystore?)
- What happens if the key is lost (e.g., factory reset, new device)?
- What happens if flutter_secure_storage is cleared but Hive data remains?

Spec 03 covers this in detail (AES-256, flutter_secure_storage, per-platform keystore). If spec 13 supersedes spec 03, this information is lost.

### 2.3 First launch and seed data -- partially specified

Spec 13 section 13 defines Walk Mode and Date Mode seed data with step tables. But:
- What about reminder templates? (spec 03 defines 8 built-in templates; spec 13 mentions none)
- What about EventDefaults? (spec 03 defines per-step-type defaults; spec 13 does not)
- What about AppSettings initial values? (only some mentioned in section 7.5)
- What about UserProfile? (created empty? created with placeholder?)

### 2.4 Schema migration -- unspecified

Spec 13 does not discuss what happens when the data schema changes between app versions. CLAUDE.md says "no backwards compatibility -- on schema mismatch, all boxes are nuked and re-seeded." This nuclear approach is not mentioned in spec 13. If an engineer does not read CLAUDE.md, they might implement migration logic or, worse, ignore the problem entirely.

### 2.5 JSON serialization strategy -- contradictory

Section 15.1 says "JSON serialization via Box<String>". This contradicts spec 03 which uses `@HiveType`/`@HiveField` annotations with generated adapters (binary serialization). These are fundamentally different approaches. Which one?

---

## 3. Notification Behavior

**Severity: HIGH**

### 3.1 Foreground service notification -- underspecified

Section 6.2 says simulation shows foreground notification with title "SIMULATION -- [mode]". Section 6.4 mentions orange border and "SIMULATION" banner. But for REAL sessions:
- What does the foreground notification say?
- What notification channel is used?
- What happens when the user taps the notification?
- Does tapping bring the app to foreground? Navigate to session screen?

Spec 05 defines 4 notification channels (`session_service`, `reminders`, `alarm`, `updates`) with importance levels. Spec 13 does not mention channels at all.

### 3.2 DND mode -- one line

Section 8.5 says "Alarm DND override, configurable toggle, default ON, uses STREAM_ALARM." But:
- Does this apply to all notifications or only alarm steps?
- What about fake call notifications in DND? Do they break through?
- What about disguised reminder notifications in DND?
- On iOS, critical alerts require a special entitlement. Is this in scope for v2?

Spec 05 covers iOS critical alerts and Android DND override in detail. Spec 13 mentions DND in passing.

### 3.3 Lock screen visibility -- unspecified

Spec 13 says nothing about lock screen notification behavior:
- Are notifications visible on lock screen?
- Does the fake call use full-screen intent to appear over lock screen?
- Section 14.1 mentions `USE_FULL_SCREEN_INTENT` for fake call -- but what about other notifications?
- What about lock screen sensitivity (hiding notification content)?

### 3.4 Disguised reminder notifications -- underspecified

Section 10.4 mentions disguised reminders but spec 13 does not define:
- What do they look like? (spec 02 defines template-based appearance)
- How does the user respond? (tap? swipe? word puzzle?)
- What happens if the user taps the notification but doesn't complete the check-in?
- Reminder templates are not mentioned in spec 13 at all

---

## 4. Session Completion

**Severity: HIGH**

### 4.1 Chain exhausted -- what happens?

Section 3.13 defines `chainExhausted` as an engine event and section 3.12 defines `EndReason.chainExhausted`. But:
- What screen is shown when the chain exhausts and the user NEVER disarmed? (All escalation steps fired, including 911 call -- now what?)
- Is this the same screen as when the user successfully disarms? Spec 04 has a single "Chain Exhausted Screen" but the spec 13 name for the route (`/session/completed`) says "completed" which implies success.
- What data is saved to SessionLog?
- Is there a distinction between "user disarmed at step 0" vs "chain fully exhausted with 911 call made"?

### 4.2 Distress chain completion -- contradictory implications

Section 4.2 says: "After distress chain completes: UI shows fake 'session ended' to fool an attacker." But:
- What does "fake session ended" look like? Is it the normal Chain Exhausted Screen? A new screen?
- If the attacker sees "Session Ended" and the user is in danger, what happens next? The chain has exhausted -- there is no more escalation.
- Does the app continue running silently? (GPS tracking, recording?)
- Can the user start a new session after distress chain completes?
- If the app shows a fake "session ended" screen, pressing the back button or home button should not reveal any distress activity. What happens?

### 4.3 EndReason semantics -- ambiguous

Section 3.12 defines three end reasons: `userTerminated`, `chainExhausted`, `distressCompleted`. But:
- `userTerminated` -- does this include both "disarm" and "end session"? Or only explicit end?
- `chainExhausted` -- is this only when steps run out, or also when user disarms after all steps?
- What is the UI behavior for each EndReason?

### 4.4 Session log persistence timing -- unspecified

When is the SessionLog saved?
- Created at session start and updated incrementally? (safe against crash)
- Created at session end? (all data lost on crash, which is fine per section 2.1's "no crash recovery" stance)
- If created at start: events must be appended in real-time, which means Hive writes on every engine event.

---

## 5. Evidence and Logging

**Severity: MEDIUM**

### 5.1 What is recorded in SessionLog

Section 7.5 mentions "GPS logging" setting. Spec 03 defines `SessionLogEvent` with latitude/longitude fields. Spec 13 does not define `SessionLogEvent` at all -- it defines `SessionLog` as part of WalkSession (ephemeral) but never mentions persistent logging fields.

Missing from spec 13:
- What event types are logged? (spec 03 defines: started, step_fired, disarmed, missed, escalated, completed, error)
- Is GPS tracked continuously or only at event boundaries?
- Is audio recorded? (spec 13 mentions audio recording only in context of simulation blocking, section 6.2)
- Are SMS/call outcomes logged? (sent successfully? failed? which contact?)

### 5.2 Export formats -- unspecified

Spec 13 does not mention session log export at all. Spec 04 defines three export formats:
- Text summary (plain text for messaging)
- JSON export (machine-readable)
- PDF report (formatted timeline with location map)

Is this in scope for v2? If so, spec 13 should say so. If not, it should be listed as deferred.

### 5.3 Evidence collection during session -- unspecified

Spec 13 does not address:
- Is audio recording a feature? (spec 02 mentions `autoRecordAudio` on `SmsContactConfig` and `CallEmergencyConfig`)
- Is video/photo evidence collection a feature?
- Where are audio files stored?
- How long are recordings kept?
- Are recordings encrypted?
- Are recordings exportable?

---

## 6. Permissions Flow

**Severity: HIGH**

### 6.1 When are permissions requested?

Section 9.1 says onboarding page 3 requests "notification, location, phone, SMS." Section 14.1 says:
- `POST_NOTIFICATIONS` requested FIRST
- Two-step location: `whenInUse` then `always` at session start
- Battery optimization exemption at first session start

But spec 13 does not define:
- What if the user skips onboarding permissions? (section 9.1 says pages are "all skippable")
- When are permissions re-requested?
- What is the pre-session validation flow? (spec 04 defines a detailed validation checklist; spec 13 section 5.4 only mentions GPS destination prompt)

### 6.2 Permission denied -- degraded experience

What happens if the user denies:
- **Location:** Section mentions location in SMS. What does the SMS say without location? spec 05 says "Location unavailable" but spec 13 is silent.
- **SMS (Android):** Can the app send SMS at all? Falls back to what?
- **Phone:** Can fake calls still work? (they are local -- should not need phone permission)
- **Notifications:** Can sessions still run? (foreground service requires notification channel)
- **Camera/Microphone:** When are these requested? For what features?

### 6.3 Permission revoked mid-session

What if the user revokes location permission while a session is active?
- Does the engine pause?
- Does the next SMS step skip location silently?
- Is the user warned?
- What if notification permission is revoked mid-session? (Android kills the foreground service)

### 6.4 Permanent denial

After the user permanently denies a permission (taps "Don't ask again"), the OS will not show the dialog again. The app must open Settings. Spec 13 does not address this flow.

---

## 7. Accessibility

**Severity: HIGH**

Spec 13 contains zero mentions of accessibility. No references to:
- WCAG compliance level
- Text contrast ratios
- Font scaling behavior
- Screen reader (TalkBack/VoiceOver) support
- Semantics labels
- Touch target sizes
- One-hand operation requirements
- Reduced motion preferences
- High contrast mode

Spec 04 has a dedicated accessibility section (section at end) with specific requirements. CLAUDE.md mentions WCAG 2.1 AA. The IMPLEMENTATION_CHECKLIST has Phase 8 dedicated to accessibility.

If spec 13 supersedes everything, accessibility is undefined. This is a significant omission for a safety app whose users may be in high-stress situations with impaired motor control.

---

## 8. Error Handling

**Severity: MEDIUM**

### 8.1 SMS send failure

Spec 13 section 3.14 says "already-dispatched SMS/calls in WorkManager still deliver." Section 14.1 says "SmsWorker via WorkManager (no network constraint -- SMS uses cellular)." But:
- What if the SMS fails? (no signal, invalid number, carrier rejection)
- Is there a retry? How many times? What interval?
- Is the failure logged?
- Does the engine advance to the next step regardless?
- Does the user see a failure notification?

### 8.2 Platform channel failure

What if a method channel call to native code fails? (e.g., audio playback, phone dialer, vibration)
- Silent skip and continue chain?
- Retry?
- Log error and show notification?

Section 3.13 defines `stepExecutionFailed` as an engine event, implying errors are at least emitted. But the spec does not define what the UI does with this event.

### 8.3 Hive corruption

What if the Hive database is corrupted?
- Delete and re-seed? (CLAUDE.md approach)
- Show error and crash?
- Attempt recovery?

### 8.4 Audio playback failure

During a fake call, if the voice recording cannot play:
- Does the call screen still show?
- Does the timer still run?
- Is there a fallback sound?

---

## 9. First Launch vs Returning User

**Severity: MEDIUM**

### 9.1 Onboarding page count -- contradictory

Spec 13 section 9.1 says THREE pages: Welcome, Profile+Contact (combined), Permissions.  
Spec 04 says FOUR pages: Welcome, Identity, First Contact, Permissions.  
CLAUDE.md says FOUR pages.

Which is correct? The difference matters: combining profile and contact on one page requires different layout and validation logic.

### 9.2 Seed data completeness

Spec 13 section 13 defines seed data for Walk Mode and Date Mode. But:
- Are built-in modes editable? Deletable?
- If a user edits Walk Mode, is there a "restore defaults" option?
- What are the seed reminder templates? (spec 03 defines 8: Calendar, Duolingo, Delivery, Fitness, Banking, Social Media, Weather, News)
- What are the seed EventDefaults values for each of the 9 step types?
- Is there a seed UserProfile or does it start empty?
- What is the default emergency number? (locale-based? hardcoded?)

### 9.3 Safety Setup checklist -- partially specified

Section 9.1 mentions "Safety Setup checklist banner on home screen" after onboarding. But spec 13 does not define:
- What checklist items?
- Completion criteria for each?
- Can the banner be dismissed? Permanently?
- Does it reappear if the user deletes their only contact?

Spec 04 defines 6 checklist items with detailed completion criteria. Spec 13 defers to it implicitly.

---

## 10. Conflicts Between Spec 13 and Specs 00-12

**Severity: CRITICAL**

### 10.1 Onboarding: 3 pages vs 4 pages

- Spec 13 section 9.1: THREE pages (Welcome, Profile+Contact combined, Permissions)
- Spec 04: FOUR pages (Welcome, Identity, First Contact, Permissions)
- CLAUDE.md: FOUR pages

### 10.2 Languages: 14 vs 5

- Spec 13 section 12.1: 14 languages (en, de, es, fr, ru, zh_CN, zh_TW, hi, fa, uk, pl, el, ar, he)
- CLAUDE.md: 5 languages (en, de, es, fr, ru)
- Spec 06: 5 languages with "planned expansion"
- IMPLEMENTATION_CHECKLIST Phase 7: 5 languages

### 10.3 Step types: 9 vs 8+3

- Spec 13 section 7.1: "9 concrete subclasses (one per step type)"
- Spec 02 (Event Types): "8 escalation steps + 3 check-in methods"
- CLAUDE.md: "9 escalation step types" with "9 types" in `ChainStepType`
- Are check-in methods also step types? Or are they separate? The count varies.

### 10.4 Engine state: sealed class vs current implementation

Spec 13 section 3.12 defines a sealed `EngineState` hierarchy. CLAUDE.md describes `ChainEventData` via a `Stream`. These are different patterns. Which is the API contract?

### 10.5 Trigger system: new concept

Spec 13 sections 5.1-5.4 introduce a trigger system (distress triggers, disarm triggers) that does not exist in specs 00-12. The old specs handle distress via sub-chains (DuressChainConfig, WrongPinChainConfig). These are architecturally different:
- Old: sub-chains are separate Hive models (typeId 17, 19) with their own editors
- New: triggers are parallel listeners configured per SessionMode

Which architecture? Spec 13 does not acknowledge the old sub-chain models or explain the migration.

### 10.6 Hive serialization: JSON vs binary

- Spec 13 section 15.1: "JSON serialization via Box<String>"
- Spec 03: `@HiveType`/`@HiveField` annotations with `.g.dart` generated adapters (binary)
- CLAUDE.md: `@HiveType` annotations, `build_runner build` for `.g.dart` files

### 10.7 Feature-first vs domain-separated layout

- Spec 13 section 15.2: Separates `domain/` from `features/` (engine and models in `domain/`)
- CLAUDE.md: Engine in `lib/features/session/session_engine.dart`, models in `lib/data/models/`
- Spec 04: Controllers in `features/`, models in `data/`

---

## 11. Trigger System -- Underspecified New Concept

**Severity: HIGH**

Sections 5.1-5.4 introduce triggers as a parallel system to chains. This is architecturally significant but underspecified:

### 11.1 Trigger registration and lifecycle

- When are triggers activated? At session start?
- When are they deactivated? At session end?
- Do triggers persist across pause/resume?
- Do triggers work when the app is in background?

### 11.2 GpsArrivalDisarmTrigger

- What geofence radius?
- How is the destination specified? (address entry? map pin? coordinates?)
- What if GPS accuracy is poor? (100m accuracy vs 10m geofence)
- What if the user walks past the destination and comes back?
- Battery impact of continuous GPS monitoring?

### 11.3 TimerDisarmTrigger

- Where is the timer duration configured?
- Is this different from the chain's normal timing?
- Can it fire during any step? Including the emergency call countdown?

### 11.4 HardwareButtonDistressTrigger

- Section 3.3 says "NOT both in the same mode -- it's either a chain step OR an escalation tool." But how is this validated? At mode edit time? At session start?
- What volume button? Up? Down? Either?
- What about Bluetooth headphone buttons?
- What if the user has a case that accidentally presses volume buttons?

### 11.5 Trigger confirmation flow

Section 5.3 says disarm triggers "ALWAYS require confirmation (notification). PIN required if configured." But:
- What does the confirmation notification look like?
- How long does the user have to confirm?
- What if the user doesn't confirm? Does the trigger re-fire?
- Can the user dismiss the confirmation?

---

## 12. Fake Call -- Details Missing from Spec 13

**Severity: MEDIUM**

Section 3.4 defines the fake call lifecycle (ring/answer/decline/timeout). But:
- What does the fake call screen look like? (spec 04 has a detailed wireframe)
- What caller name is shown? Configurable?
- What ringtone plays? Configurable?
- What voice recording plays after answer? Where do recordings come from?
- What is the default ring duration? (spec 13 seed data says 30s for Walk Mode)
- Decline-with-distress: "5s hold, configurable, advanced setting" -- where is this setting? Under what screen?
- What does `declineIsSafe` look like in the UI? Where is it configured?

---

## 13. PIN System -- Details Missing

**Severity: MEDIUM**

Section 1.3 defines PIN behavior (15s timeout, biometric option). But:
- How does the user SET a PIN? (spec 04 mentions "PIN setup dialog" but spec 13 is silent)
- How does the user CHANGE a PIN?
- How does the user REMOVE a PIN?
- How does the user SET a duress PIN? (only mentioned as a distress trigger)
- What is the PIN length? (spec 04 says 4-6 digits)
- Is the PIN hashed? How? (spec 04 mentions "PIN hashes" in AppSettings)
- What happens on wrong PIN entry? (delay? lockout? distress trigger?)
- The wrong PIN threshold triggers distress (section 4.2), but: What is the threshold? Where is it configured? What is the default? Is it configurable per session or globally?

---

## 14. Simulation -- Gaps

**Severity: MEDIUM**

### 14.1 Simulation entry and exit

- How does the user start a simulation? (spec 13 says nothing about the button/flow)
- Section 6.5 says no "GO LIVE" button. But how does a simulation end? Timer? Manual? Chain exhaustion?
- What screen shows after simulation ends? (spec 04 defines a Simulation Summary Screen; spec 13 does not)

### 14.2 Speed slider behavior in background

Section 6.3 says "Background: 1x-60x." But:
- What happens when the user switches to another app during simulation at 100x?
- Does the speed automatically drop to 60x?
- Does the simulation pause?
- Is there a notification telling the user the speed was capped?

### 14.3 Simulation session log

- Are simulation sessions saved to SessionLog?
- Are they distinguishable from real sessions? (spec 03's `isSimulation` field says yes, but spec 13 does not mention this)
- Can the user view past simulations?

---

## 15. Stealth Mode -- Partially Specified

**Severity: MEDIUM**

Section 8.3 says stealth hides app identity (fake name, generic notification channels). But:
- What is the fake app name? Where is it configured?
- What does the app icon change to?
- What do notification channels change their names to?
- What does the app launcher show?
- Can stealth mode be activated from the session screen? (would be needed if someone grabs the phone)
- Section 10.4 mentions "timer display configurable (normal/small/none)" -- where is this setting?

Spec 06 defines extensive stealth mode configuration (12+ individual toggles). Spec 13 reduces this to one sentence.

---

## 16. Battery Alert -- Underspecified

**Severity: LOW**

Section 4.3 defines battery alert as "one-shot side action" that "does NOT interrupt or replace the main chain." But:
- What threshold? (spec 03 says configurable percent; spec 13 says nothing)
- What does the notification look like?
- What does the optional SMS say?
- Where is this configured? (spec 04 has a dedicated screen at `/settings/battery-alert-chain`; spec 13 does not mention it)
- "Default: OFF" -- confirmed. But the setting screen is undefined.

---

## 17. Platform-Specific Gaps

**Severity: MEDIUM**

Section 14 mentions platform notes but several critical details are missing:

### 17.1 iOS volume button limitation

Section 14.2 says "No volume button interception (documented limitation)." But:
- This means HardwareButtonDistressTrigger is Android-only
- What is the iOS alternative for distress trigger? Is there one?
- Is this communicated to the user?

### 17.2 iOS SMS limitation

Section 14.2 does not mention that iOS cannot auto-send SMS (requires user to tap Send in Messages app). This is critical for a dead man's switch app. Spec 05 and 10 document this limitation extensively.

### 17.3 Background execution

Section 14.2 says "Silent audio loop for background session continuity" on iOS. But:
- What is the battery impact?
- What happens if iOS kills the audio session?
- Is there a watchdog or recovery mechanism? (spec 13 section 2.1 says no crash recovery)

---

## 18. Missing Behavioral Specifications

**Severity: MEDIUM**

### 18.1 What happens when the user presses the back button during a session?

- Does it navigate away? (dangerous -- session lost)
- Is it blocked? (PopScope, mentioned in spec 04 but not spec 13)
- Does it show a confirmation dialog?

### 18.2 What happens when the user switches apps during a session?

- Does the session continue in background? (yes, foreground service)
- Is there a notification to return?
- What if the user force-kills the app?

### 18.3 What happens when the phone runs out of battery during a session?

- No crash recovery (section 2.1), so the session is simply lost
- But the battery alert (section 4.3) could warn before this happens
- Should the app send a "low battery, session may end" SMS? This is exactly what section 2.3 removed. Is the battery alert SMS sufficient?

### 18.4 Multiple sessions

- Can the user start two sessions simultaneously? (section 3.8 says `start()` throws on already-running engine -- so no)
- But what about simulation while a real session is running?

### 18.5 App update during session

- What happens if the app auto-updates while a session is running?
- On Android, the foreground service survives app updates
- On iOS, the app is killed and restarted

---

## 19. Testing Gaps

**Severity: LOW**

Spec 13 section 15.4 mentions testing approach (unit, widget, checks, fakes). But:
- No test cases are defined
- No coverage requirements
- No test matrix
- Spec 07 (Test Plan) has 168+ test cases with P1/P2/P3 prioritization. If superseded, all test guidance is lost.

---

## Summary: Top 10 Items Requiring Resolution Before Engineering

1. **Meta: Normative authority** -- Resolve whether spec 13 supersedes or supplements specs 00-12 (section 0)
2. **Onboarding page count** -- 3 vs 4 pages (section 10.1)
3. **Language count** -- 14 vs 5 (section 10.2)
4. **Hive serialization** -- JSON Box<String> vs binary @HiveType (section 10.6)
5. **Directory layout** -- domain/ separation vs current feature-first (section 10.7)
6. **Trigger system vs sub-chains** -- New architecture vs old Hive models (section 10.5)
7. **Screen inventory** -- 4 screens specified vs ~25 needed (section 1)
8. **Accessibility** -- Zero coverage in a safety-critical app (section 7)
9. **Permission flow and degradation** -- Critical for a permissions-heavy app (section 6)
10. **Session completion and distress chain end state** -- Undefined UI for most important moments (section 4)
