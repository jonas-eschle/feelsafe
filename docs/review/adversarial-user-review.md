# Adversarial User Review -- Guardian Angela v2 Spec

Reviewer: Claude Opus 4.6 (1M context)
Date: 2026-04-11
Scope: Spec 13 (normative v2 rewrite spec) + supporting specs 01, 02
Method: Adversarial persona-based analysis (attacker, panicking user, naive user, edge case user, misconfigured user)

---

## Category A: Attacker Scenarios

### A-1. Force-stop via Android Settings kills session with no recovery

**Scenario:** Attacker grabs phone, goes to Settings > Apps > Guardian Angela > Force Stop. The foreground service is killed. No crash recovery exists (section 2.1).

**What the spec says:** Section 2.1 explicitly removes crash recovery. "If the app is killed, the session is lost." Rationale: foreground service prevents process death "in most cases."

**Verdict: CRITICAL GAP.** Force Stop is not "most cases" -- it is a deliberate kill that Android always honors, foreground service or not. Any attacker who recognizes the app (or any app with a persistent notification) can kill it in under 10 seconds via Settings. The spec's rationale ("just restart the session") assumes the user is conscious and in control, which contradicts the entire threat model of the dead man's switch.

**Suggested fix:** At minimum, spec should acknowledge this attack vector explicitly and document it as a known limitation. Better: implement a companion watchdog (WorkManager periodic task, or a second lightweight service) that detects the primary service death and fires a last-resort SMS. This does not require full crash recovery -- just a dead-letter trigger. Alternatively, use Android's `setForegroundServiceBehavior` with `FOREGROUND_SERVICE_IMMEDIATE` and a BroadcastReceiver for `ACTION_PACKAGE_RESTARTED` registered in the manifest (not in code). Even a "the app was killed" SMS sent 60 seconds later via WorkManager is better than silent death.

---

### A-2. Clear from Recents kills app on many Android OEMs

**Scenario:** Attacker swipes app from recent apps tray. On stock Android with a foreground service, the service survives. On Samsung, Xiaomi, Huawei, OnePlus, and other OEMs with aggressive task killers, swiping from recents kills the foreground service.

**What the spec says:** Nothing. Section 14.1 mentions foreground service and battery optimization exemption but does not address OEM-specific task killers.

**Verdict: GAP.** This is a well-documented Android fragmentation issue. dontkillmyapp.com catalogs dozens of OEMs that kill foreground services on swipe. The spec should address this.

**Suggested fix:** Add to onboarding or first-session-start: OEM-specific instructions to disable battery optimization, auto-start restrictions, and task killer features. Link to dontkillmyapp.com per device manufacturer. Document this as a known platform limitation in the spec.

---

### A-3. Attacker declines fake call repeatedly to exhaust retries, then waits

**Scenario:** In a mode with `declineIsSafe=false`, the fake call has `retryCount=2`. Attacker declines 3 times. The step advances. But if the next step is `smsContact`, the attacker can see the SMS being composed (on iOS where it opens Messages app) and cancel it.

**What the spec says:** Section 3.4 correctly handles decline as miss when `declineIsSafe=false`. Section 02 spec notes iOS SMS limitation: "user must manually press Send in the Messages app."

**Verdict: GAP (iOS-specific).** On iOS, the entire SMS escalation chain is defeated by an attacker who simply does not press Send in the Messages app. The spec acknowledges this limitation in section 02 but does not address what happens when the escalation chain relies on actions that require user cooperation on iOS. A determined attacker on iOS can block every SMS and phone call step (calls show a confirmation dialog on iOS too).

**Suggested fix:** The spec should mandate that on iOS, mode validation warns users that SMS and call steps require manual confirmation. The mode editor should surface a prominent warning: "On iOS, escalation steps that send messages or make calls require you to confirm. If someone else has your phone, these steps will not execute automatically. Consider prioritizing alarm and location-sharing steps." Additionally, consider a WhatsApp/Telegram API that can send without user interaction (if technically feasible via share extensions or accessibility services).

---

### A-4. Attacker puts phone in airplane mode to prevent SMS/calls

**Scenario:** Attacker enables airplane mode. All SMS, call, and data-dependent steps fail silently.

**What the spec says:** Section 02 mentions "SMS Retry: Indefinite retry queue via native Kotlin WorkManager. Queues SMS when no signal, retries until delivered or session ends." But the session may end (attacker force-stops app) before signal returns. Also, phone calls and emergency calls simply fail with no retry queue mentioned.

**Verdict: GAP.** The SMS retry queue is good but insufficient. Phone calls have no retry mechanism for connectivity loss. Emergency calls are the most critical step and have zero resilience against airplane mode. The WorkManager retry survives process death but the spec says sessions are lost on process death (section 2.1), creating a contradiction: does WorkManager keep retrying SMS after the session is lost?

**Suggested fix:** Clarify the WorkManager SMS retry behavior: does it survive session loss? It should -- once an SMS is queued in WorkManager, it should retry regardless of session state. For phone calls, document that airplane mode blocks them entirely and that this is a known limitation. Consider: if airplane mode is detected during an active session, fire an immediate local alarm (loudAlarm) since that requires no connectivity. Add an "airplane mode detected" event that can trigger a loud alarm as a fallback.

---

### A-5. Attacker knows the duress PIN

**Scenario:** In an abusive relationship, the attacker has observed the user entering the duress PIN, or the user was forced to reveal it. The attacker enters the duress PIN, which triggers the distress chain -- but the attacker expects this and has already taken the phone to airplane mode. The distress chain fires but all external steps fail.

**What the spec says:** Section 4.2 says distress chain fires and shows fake "session ended" to fool attacker. But if the attacker already knows the duress PIN exists, they are not fooled.

**Verdict: ACCEPTABLE but should be documented.** No system can defend against an attacker with full knowledge of the system and physical control of the device. This is a known limitation of any duress system. However, the spec should explicitly state this threat model boundary.

**Suggested fix:** Add a "Threat Model Limitations" section stating: "If an attacker has full knowledge of the app's configuration (including duress PIN, chain steps, and triggers), physical control of the device, and the ability to block network connectivity, the app cannot guarantee escalation delivery. The app's security model assumes information asymmetry -- the attacker does not know the app exists (stealth) or does not know its configuration (PIN)."

---

### A-6. PIN timeout is observable by attacker

**Scenario:** Attacker grabs phone, sees PIN entry screen. They wait 15 seconds. The timeout fires, action is BLOCKED. But now the attacker knows: (a) this is a safety app, (b) it has a PIN, (c) 15 seconds is the timeout. On next attempt, they know to try common PINs within 15 seconds.

**What the spec says:** Section 1.3 describes PIN timeout. Stealth mode (section 8.3) hides app identity. But the PIN screen itself reveals the app's true nature.

**Verdict: GAP.** If stealth mode is active and the attacker triggers a PIN prompt (e.g., trying to end the session), the PIN screen should maintain the stealth cover story. If the app is disguised as a calculator, the PIN screen should look like a calculator lock, not "Enter your Guardian Angela PIN."

**Suggested fix:** Specify that the PIN entry screen respects stealth mode. In stealth mode, the PIN screen should match the cover app's aesthetic (e.g., "Enter passcode" with no app branding). The timeout behavior (blocking the action) should show a generic error ("Incorrect passcode") rather than revealing that escalation continues.

---

### A-7. Volume button panic is detectable by attacker

**Scenario:** The user tries to press volume 5 times to trigger distress. The attacker notices the frantic button pressing and the volume HUD appearing.

**What the spec says:** Section 3.3 specifies 5x minimum presses. Section 02 says Android implementation "returns true (consumed) for volume key events" and "suppresses both the volume change and the volume HUD."

**Verdict: ACCEPTABLE.** The spec correctly suppresses the volume HUD on Android. However, the physical act of pressing a button 5 times rapidly is still observable. This is inherent to any physical trigger and cannot be fully mitigated in software.

**No fix needed** -- the spec handles this correctly for software. The physical observability is a documented limitation of hardware triggers.

---

## Category B: Panicking User Scenarios

### B-1. Accidental distress trigger -- no confirmation, no undo

**Scenario:** User accidentally presses volume button 5 times (adjusting volume, phone in pocket). Distress chain fires immediately. Main chain is "stopped and discarded" (section 4.2). User cannot go back to main chain.

**What the spec says:** Section 4.2: "The distress chain becomes THE active chain. No going back to the main chain." Section 5.2: "500ms cooldown between triggers."

**Verdict: CRITICAL GAP.** The 500ms cooldown prevents double-trigger but does nothing to prevent accidental single trigger. There is no confirmation step, no grace period, and no undo. This directly violates the core philosophy of section 1.1 ("minimize false positives"). An accidental distress trigger is the most severe false positive possible -- it fires the nuclear option (SMS all contacts, call 911) with no way to abort except disarming with PIN, which requires the user to realize what happened, find the PIN screen, and enter the PIN before the first distress step executes.

**Suggested fix:** Add a configurable confirmation window (default 3-5 seconds) after distress trigger before the distress chain begins executing. During this window, show "Distress activated -- tap to cancel" (or a more stealth-appropriate message). If no cancel within the window, proceed. This adds minimal delay to a real emergency while dramatically reducing false positives. The confirmation should be skippable in settings for users who want immediate distress execution.

---

### B-2. User forgets PIN under extreme stress

**Scenario:** User is in genuine danger, panicking, and cannot remember their PIN. They need to disarm to change strategy (e.g., they realized the escalation will make things worse). The 15-second timeout locks them out.

**What the spec says:** Section 1.3: "Timeout -> action BLOCKED, escalation continues." There is no PIN recovery mechanism mentioned.

**Verdict: GAP.** The spec provides no escape hatch for a user who forgets their PIN. Biometric is allowed for disarm (section 1.3) but "MUST NOT substitute for Quick Exit." If the user has biometric configured, they can disarm. If not, they are locked out of their own safety app during the moment they need it most.

**Suggested fix:** Add a "panic override" mechanism: after N consecutive failed PIN attempts (configurable, default 5), show an option to disarm with a longer confirmation (e.g., hold a button for 10 seconds). This is slow enough that an attacker is unlikely to discover and use it under time pressure, but accessible to a panicking user who has 10 seconds of privacy. Alternatively, always enable biometric for disarm (even if the user hasn't explicitly configured it) as a fallback when PIN entry fails.

---

### B-3. User sets declineIsSafe=false and doesn't understand it

**Scenario:** During mode setup, user enables `declineIsSafe=false` (maybe they read "high alert" and thought it sounded safer). Later, they're on a date, the fake call rings, they decline it thinking "I'm fine" -- but the chain treats it as a miss and keeps escalating.

**What the spec says:** Section 3.5: "This should be chosen deliberately." But the spec does not describe any warning or confirmation when enabling this setting.

**Verdict: GAP.** The spec relies on the user understanding the implications of a boolean flag buried in per-mode fake call configuration. Most users will not understand "declineIsSafe=false" without explicit explanation at the point of configuration.

**Suggested fix:** When enabling `declineIsSafe=false`, show an inline explanation: "When enabled: declining the fake call will NOT stop the safety check. The call will ring again. This is for situations where someone else might grab your phone and decline the call. If YOU decline the call, it will keep ringing." Include a brief simulation of the behavior.

---

### B-4. Real phone call during fake call -- loss of cover story

**Scenario:** User is pretending to be on a fake call (answered, voice playing). A real phone call comes in. Android/iOS shows the real incoming call UI, potentially revealing that the previous "call" was fake.

**What the spec says:** Section 3.10 says pause stops all audio on pause. Section 3.11 says resume with exact remaining time. But neither addresses the UX of a real call interrupting a fake call specifically.

**Verdict: GAP.** The fake call screen is a cover story. If a real call interrupts and the fake call screen disappears or the audio stops, an observer may realize the first call was fake. When the real call ends and the fake call resumes, the observer sees "another call?" which is suspicious.

**Suggested fix:** Specify the fake call behavior when interrupted by a real call: (a) The fake call should auto-disarm when a real call is answered (the user now has a real excuse to be on the phone -- mission accomplished). (b) Alternatively, after the real call ends, the fake call should NOT visually resume -- instead, just disarm silently. The cover story has been disrupted; resuming it makes things worse.

---

### B-5. Quick Exit destroys evidence the user might need later

**Scenario:** User triggers Quick Exit during an active distress situation. The app disappears completely. Later, they need evidence of the session (GPS logs, SMS timestamps) for a police report or restraining order.

**What the spec says:** Section 8.2: "Kill everything. App disappears." Section 3.14 says "Already-dispatched SMS/calls in WorkManager still deliver." But there is no mention of preserving session logs or GPS data after Quick Exit.

**Verdict: GAP.** Quick Exit prioritizes immediate safety (hiding the app from an observer) but destroys forensic evidence. For users in abusive situations, this evidence may be critical for legal proceedings.

**Suggested fix:** Before Quick Exit destroys the UI, persist the current SessionLog and GPS data to encrypted local storage (or queue a background upload to a configured cloud endpoint). Quick Exit should hide the app but not erase session data. The data should be recoverable when the app is reopened. Alternatively, add a "send session log to email" action that fires as part of Quick Exit before the app closes.

---

## Category C: First-Time User Scenarios

### C-1. Starting a session without any contacts configured

**Scenario:** User completes onboarding (which only asks for one contact on page 2, and all pages are skippable per section 9.1). They skip the contact page. They tap "Start Session" with Walk Mode, which has `smsContact` at step 2 and `phoneCallContact` at step 3.

**What the spec says:** Section 6.6 says simulation allows missing contacts with a warning. But no equivalent is specified for real sessions. Section 02 says `contactIds` empty = all contacts, but "all contacts" when there are zero contacts means zero recipients.

**Verdict: CRITICAL GAP.** The spec does not specify what happens when a real session is started with zero contacts configured. The smsContact step would fire with zero recipients, effectively turning steps 2, 3, and possibly 4 into no-ops. The user believes they are protected; they are not. The dead man's switch is armed but cannot actually reach anyone.

**Suggested fix:** Require at least one contact before starting a real (non-simulation) session. Show a blocking dialog: "You haven't added any emergency contacts. Your safety chain cannot send messages or make calls. Add a contact before starting a real session." Allow simulation without contacts (as section 6.6 specifies).

---

### C-2. Starting a session without SMS permission

**Scenario:** User denies SMS permission during onboarding (page 3 is skippable). They start a real session. The smsContact step fires and fails silently.

**What the spec says:** Section 14.1 mentions requesting permissions. Section 02 mentions "Non-Blocking on Failure: Advanced per-step toggle. If SMS fails, log and continue chain." But the spec does not specify pre-session validation of required permissions.

**Verdict: GAP.** The spec says permissions are requested during onboarding but does not specify what happens if they are denied and a session is started. The "Non-Blocking on Failure" toggle defaults to continuing the chain, which means the user silently loses their SMS safety net.

**Suggested fix:** Before starting a real session, validate that all permissions required by the configured chain steps are granted. If SMS permission is missing and the chain contains smsContact, show a warning: "SMS permission is not granted. Step 'Send SMS to contacts' will fail. Grant permission or remove this step." For simulation, warn but allow (consistent with section 6.6).

---

### C-3. User doesn't understand "hold" in Walk Mode

**Scenario:** User starts Walk Mode session. The screen shows "Touch to begin" (per section 02). The user taps once and lifts. The `releaseSensitivity` of 1.0s ignores the brief lift. But the user thinks they have started and puts the phone in their pocket. The hold button never registers a sustained hold, so the engine never starts the active timer. The user walks for 30 minutes believing they are protected.

**What the spec says:** Section 02: "Engine waits for first holdStart(). Does NOT assume user is holding. UI shows 'Touch to begin' prompt. Session timer starts on first touch." Section 3.7: "holdStart() is no-op if already holding. holdRelease() is no-op if not holding."

**Verdict: GAP.** The spec describes a state where the session is "started" (engine.start() called) but the hold button has never been held. The engine is in `EngineRunning` with `isAwaitingFirstTouch=true`. This state can persist indefinitely. The user sees no countdown, no escalation, no feedback -- the app appears to be running but is doing nothing. This is effectively the same as not having the app at all.

**Suggested fix:** Add a "first touch timeout": if the user does not hold the button within N seconds (configurable, default 60s) after starting the session, show a persistent notification: "Your session is waiting for you to hold the button. Tap to open." If the timeout is much longer (e.g., 5 minutes), treat it as a missed check-in and begin escalation. This prevents the "phantom protection" scenario.

---

### C-4. User starts Date Mode but doesn't understand disguised reminders

**Scenario:** User starts Date Mode. 30 minutes later, a "Duolingo" notification appears. They dismiss it as spam/real notification. It was actually the check-in reminder. They missed it. After 3 misses, the chain escalates to fake call.

**What the spec says:** Section 02 describes disguised reminders with various confirmation types (tapButton, tapWord, swipe, dismiss). The disguise is the entire point.

**Verdict: ACCEPTABLE but needs mitigation.** This is by design -- the disguised reminder IS supposed to look like a real notification to maintain cover. However, a first-time user who has never seen a disguised reminder in action may not recognize it.

**Suggested fix:** During onboarding or first-session-start for Date Mode, show a brief tutorial: "During your session, you'll receive notifications that look like real app notifications. These are your safety check-ins. Here's what they look like: [show example]. Responding confirms you're safe. Missing them triggers escalation." Additionally, the simulation mode (section 6) should be prominently recommended before a first real Date Mode session.

---

## Category D: Edge Case Scenarios

### D-1. Battery dies mid-session

**Scenario:** Phone battery reaches 0% during an active session. The app dies. No crash recovery (section 2.1). All pending steps, GPS tracking, and retry queues are lost.

**What the spec says:** Section 4.3 describes battery alert as a one-shot side action (notification + optional SMS) when battery drops below threshold. Default: OFF.

**Verdict: GAP.** Even with battery alert enabled, it fires at a configurable threshold (e.g., 15%). Between the alert and 0%, there may not be enough time or battery for the SMS to actually send (especially if WorkManager is involved). More critically, the battery alert is OFF by default, so most users will have no protection against battery death.

**Suggested fix:** (1) Default battery alert to ON at 15% for any mode that contains SMS or call steps. The current default of OFF means users must opt-in to a critical safety feature. (2) When battery reaches critical level (5%), fire a mandatory last-resort SMS regardless of battery alert configuration: "My phone is about to die. Last known location: {location}." (3) If this violates section 2.3 ("No special critical battery override"), then at minimum change the default to ON and make the threshold configurable with a sensible default.

---

### D-2. Two distress triggers fire simultaneously

**Scenario:** User presses volume button 5 times (hardware panic) and enters the wrong PIN 3 times (wrong PIN threshold) in rapid succession. Both triggers want to fire the distress chain.

**What the spec says:** Section 4.2 lists three triggers. Section 5.2 specifies "500ms cooldown between triggers." But the cooldown is described for repeated activations of the same trigger, not for two different triggers firing simultaneously.

**Verdict: MINOR GAP.** The 500ms cooldown should apply to ALL distress triggers (any trigger resets the cooldown), but the spec is ambiguous about whether it applies across trigger types.

**Suggested fix:** Clarify: "500ms cooldown applies to all distress triggers collectively. If any distress trigger fires, all other distress triggers are suppressed for 500ms. Once the distress chain is active, further distress triggers are no-ops (the distress chain is already running)."

---

### D-3. Fake call arrives while phone is actively in a real call

**Scenario:** User is on a real phone call when the fake call step fires.

**What the spec says:** Section 3.10 describes pause behavior for incoming real calls. But this is the reverse: the ENGINE wants to fire a fake call while the user is already on a real call.

**Verdict: GAP.** The spec does not address outbound fake calls when the phone is already in a call. On Android, showing a full-screen call UI while a real call is active is confusing and may interfere with the real call. The fake call ringtone would play over the real call audio.

**Suggested fix:** Specify: "If the phone is currently in a real call when a fakeCall step fires, the fake call is deferred until the real call ends. The step timer pauses. When the real call ends, the fake call fires normally." Alternatively, skip the fake call and treat it as a disarm (the user IS on a real call -- they are demonstrably conscious and able to use their phone).

---

### D-4. GPS is unavailable (indoor, underground, airplane mode)

**Scenario:** The smsContact step fires with `includeLocation=true`, but GPS has no fix. The SMS sends "Location unavailable."

**What the spec says:** Section 02: "If no GPS: 'Location unavailable'. If only stale location: 'Last known location at {timestamp}: {url}' with accuracy info."

**Verdict: ACCEPTABLE.** The spec correctly handles this case with graceful degradation. The SMS still sends, just without useful location data.

**No fix needed** -- the spec handles this correctly.

---

### D-5. Session runs for 8+ hours (overnight)

**Scenario:** User starts Walk Mode before a long walk, falls asleep at destination without ending session. The hold button is released. The chain escalates through all steps. Eventually reaches chainExhausted. After 8 hours, what is the state?

**What the spec says:** Section 3.12: `EngineEnded { reason: chainExhausted }`. The chain exhausts and the engine stops.

**Verdict: ACCEPTABLE but with a concern.** Chain exhaustion is the correct behavior. However, if the user fell asleep safely and the chain has `callEmergency` as the final step, emergency services are called for a sleeping user. This is a false positive. The spec's core philosophy (section 1.1) says to minimize false positives.

**Suggested fix:** Consider a maximum session duration setting (per mode, default: none/unlimited). Walk Mode might reasonably have a 4-hour max. When max duration is reached, show a prominent notification: "Your session has been running for 4 hours. Are you still out? [Extend] [End Session]." This is a check-in at the session level, not the step level.

---

### D-6. App update kills running session

**Scenario:** Google Play auto-updates the app while a session is active. The app process is killed and restarted with the new version.

**What the spec says:** Section 2.1: "No crash recovery. If the app is killed, the session is lost."

**Verdict: GAP.** Auto-updates are a realistic scenario that kills the app process. The user may not realize the session was terminated. Combined with the no-crash-recovery decision, this means an app update silently disables the user's safety net.

**Suggested fix:** (1) During an active session, suppress auto-updates (Android allows this via Play Core API). (2) If the app is restarted after an update during what would have been an active session, show a notification: "Your session was interrupted by an app update. Start a new session." (3) Document this as a known limitation if suppressing updates is not feasible.

---

### D-7. Timezone change during session (travel, DST)

**Scenario:** User starts a session, flies across timezones. All timers are based on Dart's Duration/Timer which use monotonic clock, so this is fine. But displayed timestamps in SMS messages could be confusing.

**What the spec says:** Nothing explicitly about timezones.

**Verdict: MINOR.** Dart Timer uses monotonic clock, so timing is unaffected. SMS timestamps should use UTC or the user's current timezone at time of sending. This is a minor display issue, not a safety issue.

**Suggested fix:** Specify that SMS timestamps use the device's current local time at the moment of sending, with timezone offset included (e.g., "2026-04-11 22:30 UTC+2").

---

## Category E: Misconfiguration Scenarios

### E-1. Distress chain with zero steps

**Scenario:** User configures a distress chain but removes all steps from it. They trigger hardware panic (5x volume). The distress chain replaces the main chain. The distress chain has zero steps. It immediately reaches chainExhausted.

**What the spec says:** Section 4.2: "The distress chain becomes THE active chain." No mention of validation for empty chains. Section 3.12: chainExhausted is a valid end reason.

**Verdict: CRITICAL GAP.** An empty distress chain means the distress trigger effectively ends the session silently. The user pressed the panic button expecting help; instead, their protection was removed entirely. The main chain was discarded, and the distress chain did nothing.

**Suggested fix:** Validate at session start: if distress triggers are configured, the distress chain MUST have at least one step. If the distress chain is empty, either (a) disable distress triggers for this session with a warning, or (b) block session start with an error: "Your distress chain has no steps. Add at least one step or disable distress triggers."

---

### E-2. Mode with no chain steps at all

**Scenario:** User creates a custom mode and removes all chain steps. They start a session.

**What the spec says:** Section 3.8: "start() on an already-running engine throws." But nothing about starting an engine with zero steps.

**Verdict: GAP.** An empty chain would immediately reach chainExhausted on start (or throw, depending on implementation). Neither behavior is useful. The user thinks they started a safety session; it ended instantly.

**Suggested fix:** Validate at session start: chain MUST have at least one step. Block start with: "Your mode has no steps configured. Add at least one step before starting a session."

---

### E-3. Wrong emergency number configured

**Scenario:** User manually overrides the emergency number to a non-emergency number (e.g., a friend's number, or a typo like "91" instead of "911"). The callEmergency step dials a wrong number.

**What the spec says:** Section 02: "emergencyNumber: string (locale) -- Emergency number to dial." The number is configurable per-step and has a locale-aware default.

**Verdict: MINOR GAP.** The spec allows free-form string entry for emergency numbers. A validation step could catch obvious errors.

**Suggested fix:** Validate emergency numbers against a known list of valid emergency numbers per country. If the user enters a number not in the list, show a warning: "This does not match a known emergency number for your region. Are you sure?" Allow override but require confirmation.

---

### E-4. All contacts deleted after mode configuration

**Scenario:** User configures Walk Mode with `smsContact` targeting "all contacts." Later, they delete all contacts from the app. They start a session. The smsContact step fires with zero recipients.

**What the spec says:** Section 8.1: "During active session: block settings that would affect the running session (contact deletion...)." But contacts can be deleted BEFORE a session starts.

**Verdict: GAP.** The session lock (section 8.1) protects running sessions but not the gap between configuration and session start. A user could configure their chain, delete all contacts, and start a session that cannot reach anyone.

**Suggested fix:** At session start, validate that all steps referencing contacts have at least one valid recipient. If smsContact or phoneCallContact steps have zero reachable contacts, block session start: "Step 'Send SMS' has no contacts to message. Add a contact or remove this step."

---

### E-5. PIN set to same value as duress PIN

**Scenario:** User sets their session PIN to "1234" and their duress PIN to "1234." Entering the PIN to disarm now triggers the distress chain instead of disarming.

**What the spec says:** Section 7.5 mentions "PIN hashes (app, duress, session-end)" but does not specify that they must be distinct.

**Verdict: CRITICAL GAP.** If the real PIN and duress PIN are identical, every PIN entry triggers distress. The user cannot disarm normally. This is a catastrophic misconfiguration.

**Suggested fix:** Validate at PIN setup: duress PIN MUST differ from the session PIN and the app PIN. Block save with: "Your duress PIN cannot be the same as your session PIN." Also validate that the session-end PIN differs from the duress PIN.

---

### E-6. PhoneCallContact step with a contact who has no phone number

**Scenario:** User adds a contact with only a name and no phone number (or a WhatsApp-only contact). They configure a phoneCallContact step targeting this contact.

**What the spec says:** Section 02: "contactId: string (REQUIRED) -- Primary contact to call." Section 7.3: EmergencyContact has phoneNumber as a field. Section 02 also says "Only contacts with valid channels for the selected send method appear."

**Verdict: MINOR GAP.** The spec says contacts without valid channels should not appear in the selector, which would prevent this. But if a contact's phone number is deleted after step configuration, the step has an invalid reference.

**Suggested fix:** At session start, validate all step-contact references. If a phoneCallContact step references a contact without a phone number, warn or block.

---

### E-7. User configures extremely short timers

**Scenario:** User sets `gracePeriodSeconds=1`, `durationSeconds=1`, `releaseSensitivity=0.3s`. They start Walk Mode. They release the button, and within 1.3 seconds (sensitivity) + 1 second (duration) + 1 second (grace), the chain advances. They have approximately 2 seconds to respond. Under any real-world conditions (phone in pocket, need to unlock, etc.), this is impossible.

**What the spec says:** Section 02 specifies ranges (e.g., releaseSensitivity 0.3-3.0s) but no minimum for grace or duration beyond what's configurable.

**Verdict: GAP.** The spec allows configurations that are functionally unusable. A 1-second grace period is a false-positive generator.

**Suggested fix:** Add minimum timer recommendations (not hard limits, but warnings): "Grace period under 5 seconds may cause false escalations. Are you sure?" Similarly for duration under 5 seconds. Alternatively, set hard minimums: grace >= 3s, duration >= 3s.

---

## Category F: Spec Contradictions and Ambiguities

### F-1. Disarm "resets to step 0" vs "user controls everything"

**Scenario:** User is at step 3 (smsContact has already fired, SMS sent). User disarms. Section 3.6 says disarm "resets to step 0 and clears miss count." But the SMS was already sent (section 3.14: "Already-dispatched SMS/calls in WorkManager still deliver").

**What the spec says:** Both sections are consistent: disarm resets the ENGINE but does not unsend external actions. However, this means "reset to step 0" restarts the hold button check-in, which may confuse the user who thinks "disarm" means "session over."

**Verdict: AMBIGUITY.** Is disarm a "pause and restart" or a "I'm safe, stop everything"? The spec says it "resets to step 0" which is "pause and restart." But the user mental model is "I'm safe." The spec should distinguish between "I'm safe (disarm)" and "End session (endSession)."

**Suggested fix:** Clarify the UX language: disarm = "I'm safe, reset my check-in timer" (session continues from step 0). End session = "I'm done, stop everything." Make it clear in the UI that disarming does NOT end the session -- it resets the escalation chain while keeping the session active. Many users will want "end session" when they think "disarm."

---

### F-2. declineIsSafe default varies between Walk and Date Mode but spec says "default: true"

**Scenario:** Section 3.5 says `declineIsSafe` default is true. Section 13.1 (Walk Mode seed data) and 13.2 (Date Mode seed data) both show `declineIsSafe=true`. This is consistent. But should Date Mode default to false? If the user is on a date with a potential threat, the threat could decline the call.

**Verdict: DESIGN QUESTION, not a bug.** The spec is internally consistent. However, the default of true for Date Mode may not match the threat model (date with a potentially dangerous person).

**Suggested fix:** Consider defaulting Date Mode's fakeCall to `declineIsSafe=false` since the primary threat model involves another person who might interact with the phone. At minimum, during Date Mode setup, prompt: "If someone else might decline calls on your phone, set 'Decline is Safe' to off."

---

### F-3. "Fake session ended" after distress chain -- but what if user reopens app?

**Scenario:** Distress chain completes. UI shows fake "session ended" (section 4.2). Attacker sees this, believes session is over, returns phone. User reopens app. What state is the app in?

**What the spec says:** Section 3.12: `EngineEnded { reason: distressCompleted }`. The engine is in EngineEnded state.

**Verdict: AMBIGUITY.** The spec says the UI shows fake "session ended" but does not specify what the app shows if reopened. Is it the home screen? Does it show a session summary? Does it look like no session ever ran?

**Suggested fix:** Specify: "After distress chain completes and fake 'session ended' is displayed, the app state returns to the home screen. Session logs are preserved but not prominently displayed. If the attacker reopens the app, it should look like a normal app that is not running a session."

---

### F-4. Quick Exit requires PIN but the purpose is emergency escape

**Scenario:** User is in danger. Attacker is watching. User tries Quick Exit. PIN screen appears. User must enter PIN within 15 seconds while being watched. If they fail, Quick Exit is BLOCKED and escalation continues -- but the attacker now sees the app is doing something.

**What the spec says:** Section 8.2: "Requires PIN if configured (15s timeout)." Section 1.3: "Biometric MUST NOT substitute for Quick Exit."

**Verdict: CRITICAL CONTRADICTION.** Quick Exit is for "someone is looking at my phone RIGHT NOW" (section 8.2). But requiring PIN while someone is watching defeats the purpose -- the observer sees the PIN screen and knows the app is not what it claims to be. AND biometric is explicitly forbidden for Quick Exit (which makes sense -- forced fingerprint). This creates a paradox: the feature designed for maximum urgency has the highest authentication barrier.

**Suggested fix:** Rethink Quick Exit authentication. Options: (1) Quick Exit does NOT require PIN -- it always works. The rationale "PIN prevents attacker from using it to destroy evidence" is weaker than the rationale "user needs to escape NOW." If the attacker wants to destroy evidence, they can just force-stop the app (see A-1). (2) Quick Exit has a SHORTER timeout (5 seconds) and a SIMPLER authentication (e.g., swipe pattern instead of PIN). (3) If PIN is required, the PIN screen must perfectly maintain stealth cover (see A-6).

---

### F-5. "Chains are just chains" but distress chain has special behavior

**Scenario:** Section 1.4 says "no special architecture" for chains. But section 4.2 says distress chain "replaces" main chain, shows "fake session ended" on completion, and is triggered by special triggers. This IS special behavior.

**What the spec says:** Section 1.4: "A chain is a chain is a chain." Section 4.2: Distress chain has unique behaviors (replace semantics, fake UI on completion, irreversible).

**Verdict: MINOR CONTRADICTION.** The engine may indeed treat all chains identically at the execution level. But the SESSION CONTROLLER has distress-specific logic (replacing main chain, fake ended UI). The spec's claim that there's "no special architecture" is aspirational but not entirely accurate.

**Suggested fix:** Reword section 1.4: "The engine executes all chains identically -- same step types, same timing, same retry logic. The orchestration layer (SessionController) handles chain switching and UI behavior, but the engine itself has no concept of 'main' vs 'distress.'"

---

### F-6. Section 3.10 pause stops audio but section 3.11 resumes with exact time -- what about alarm mid-play?

**Scenario:** Loud alarm is playing (step 8, duration 30s, 15s remaining). Real phone call comes in. Pause fires, alarm stops. Call lasts 2 minutes. Resume fires. Alarm resumes with 15s remaining. But the gradual volume increase (section 02: "linear ramp over configurable duration, default 10s") already completed before the pause -- does it restart from zero or resume at full volume?

**What the spec says:** Section 3.10: "Pause stops ALL active audio." Section 3.11: "Resume from exact remaining duration." Section 02: "Gradual Volume Increase: Linear ramp over configurable duration."

**Verdict: AMBIGUITY.** The spec does not address whether the gradual volume ramp state is preserved across pause/resume. Resuming at full volume is correct (the ramp already completed). Restarting the ramp from zero after a 2-minute pause means the alarm is quiet again, which may be wrong.

**Suggested fix:** Specify: "On resume, audio effects (volume ramp, alarm) resume at the volume level they had reached before pause, not from the beginning of the ramp."

---

## Summary

| Severity | Count | IDs |
|----------|-------|-----|
| CRITICAL | 5 | A-1, B-1, C-1, E-1, E-5, F-4 |
| GAP | 12 | A-2, A-3, A-4, B-2, B-3, B-4, B-5, C-2, C-3, D-1, D-6, E-4 |
| MINOR | 5 | D-2, D-7, E-3, E-6, E-7 |
| AMBIGUITY | 4 | F-1, F-3, F-5, F-6 |
| ACCEPTABLE | 4 | A-5, A-7, C-4, D-4, D-5 |
| DESIGN QUESTION | 1 | F-2 |

### Top 5 Fixes by Impact

1. **Session-start validation** (fixes C-1, C-2, E-1, E-2, E-4, E-6): Validate contacts, permissions, chain steps, and distress chain before allowing a real session to start. Single validation pass, maximum safety improvement.

2. **Distress trigger confirmation window** (fixes B-1): 3-5 second cancelable window before distress chain executes. Prevents the worst false positive scenario.

3. **PIN == Duress PIN guard** (fixes E-5): Simple validation at setup time. Prevents catastrophic misconfiguration.

4. **Force-stop / process death resilience** (fixes A-1, A-2, D-6): WorkManager-based dead-letter SMS that fires if the main service dies unexpectedly. Does not require full crash recovery.

5. **Quick Exit authentication rethink** (fixes F-4): Either remove PIN from Quick Exit, shorten timeout, or ensure perfect stealth integration. Current design contradicts its own purpose.
