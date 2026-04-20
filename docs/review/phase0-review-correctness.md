# Phase 0 Review: 12-rewrite-decisions.md

Reviewed against specs 00-overview through 06-settings.

---

## 1. CORRECTNESS -- Internal Contradictions

### C1. PIN timeout semantics are backwards

Lines 17-20: "Correct PIN -> action cancelled. Timeout -> action continues
(dead-man's-switch principle applied to UI itself)."

Line 116: "Correct PIN -> disarm. Timeout -> action continues."

The phrase "action cancelled" on correct PIN is confusing because the
"action" being cancelled is the disarm/end-session, not the escalation.
The dead-man's-switch framing says "timeout means the user is
incapacitated, so proceed with the protective action." But the
protective action here IS the disarm. If the user enters the correct
PIN to disarm, they are proving they are safe -- that should EXECUTE
the disarm, not "cancel" it. The wording on line 18 reads as if
entering the correct PIN cancels the disarm and lets escalation
continue, which contradicts line 116 where correct PIN triggers disarm.

Recommendation: Reword line 18 to "Correct PIN -> action executes"
or "Correct PIN -> requested action proceeds (disarm/end/exit)."

### C2. Retry timing rule contradicts itself across the document

Lines 63-66 (Retry Timing -- CLARIFIED): "The `wait` phase only
executes on the FIRST execution of a step (when advancing to it),
NOT on retries."

This is stated as a universal rule for all step types. However,
01-chain-engine.md lines 88-93 only specifies this skip-wait behavior
for `disguisedReminder` retries. For general steps (01-chain-engine
lines 326-329), the retry cycle is described as "restart step (same
wait -> duration -> grace cycle)" -- explicitly including wait.

The decision document generalizes the skip-wait rule to ALL step types
but does not acknowledge or explicitly override the general-step retry
behavior in 01. If intended to be universal, this needs to explicitly
state it supersedes the general step retry cycle in 01, not just the
disguised reminder case.

### C3. Sub-chain architecture contradicts 01-chain-engine

Line 151: "Internal to the engine (not a separate engine instance)."

01-chain-engine.md line 759: "Sub-chain is a separate `SessionEngine`
instance with its own chain of steps."

Spec 12 explicitly supersedes, but the `EngineSubChainActive` sealed
state (line 186) embeds `subChainState: EngineRunning` which implies
the sub-chain state is tracked within the same engine. This is
architecturally significant and 12 should flag it as a deliberate
reversal, not just a passing mention.

### C4. endSession during sub-chain contradicts "user always in control"

Line 153: "`endSession()` during sub-chain: sub-chain completes first,
then ends."

Line 15: "Disarm is ALWAYS possible from any state, any step,
including during duress/sub-chains."

If endSession blocks until the sub-chain completes, the user is NOT in
control during that interval. A duress sub-chain could run for minutes
(SMS + emergency call). This contradicts the "no hard-coded blocking of
user actions" principle on line 16.

### C5. Fake call: answer semantics inconsistent with 04-screens

Spec 12 line 91-92: "`answerFakeCall()` -- pauses chain timers, does
NOT disarm." Line 93: "`hangUp()` -- fires disarm (reset to step 0)."

04-screens-navigation.md line 877 (Hang-Up section): "Does NOT disarm
-- next step waits for grace period." Line 900: "Does NOT disarm."

Spec 12 says hang-up fires disarm. Spec 04 says hang-up does NOT
disarm. These directly contradict. Since 12 is normative, 04 must be
annotated, but the document does not list 04-screens in its "Spec
sections to annotate" anywhere for this change.

### C6. Fake call decline in 04-screens contradicts spec 12

04-screens-navigation.md line 876-879 says decline "Does NOT disarm"
and "Re-fires grace period countdown" unconditionally. But spec 12
lines 104-108 makes this conditional on `declineIsSafe`. When
`declineIsSafe=true` (the default), decline IS a disarm. Spec 12 does
not list 04-screens as needing annotation for this change.

### C7. start() behavior contradicts 01-chain-engine

Line 126: "Calling `start()` on an already-running engine throws an
error. Not a no-op."

01-chain-engine.md line 424: "Idempotent -- calling multiple times
is a no-op."

Spec 12 supersedes, but does not list this in "Spec sections to
annotate." A developer reading 01 alone would get the opposite
behavior.

---

## 2. COMPLETENESS -- Missing Decisions

### M1. No decision on biometric for session termination

06-settings.md line 162: "Session termination always requires PIN (not
biometric) to prevent attacker from using unconscious user's
fingerprint."

Spec 12 discusses PIN as safety speed bump for critical actions but
never addresses whether biometric can substitute for PIN in the new
dead-man's-switch PIN model. The 10-second timeout + dead-man's-switch
pattern changes the threat model -- if timeout means "proceed," then
biometric is less critical. This needs an explicit decision.

### M2. No decision on stealth fake music player

06-settings.md line 127-131 describes a fake music player shown during
stealth sessions. 04-screens-navigation.md lines 737-767 provides
detailed UI spec for this feature.

Spec 12 line 371 says "Fake music player: remove stealth toggle
entirely" but this is ambiguous. Does it mean:
(a) Remove the music player feature entirely, or
(b) Remove just the toggle and make it always-on during stealth?

The phrase "remove stealth toggle" suggests (b), but the broader
context of simplification could mean (a). A developer cannot determine
which is intended.

### M3. No decision on session log auto-delete retention

03-data-models.md line 644: "Auto-delete: default 90 days,
configurable."

Spec 12 adds session log fields (deliveryStatus) and evidence package
export but never addresses retention policy. For an evidence-oriented
feature, the default auto-delete at 90 days could destroy evidence.
This warrants an explicit decision.

### M4. No decision on export encryption

03-data-models.md line 70: "Optional encryption of JSON export (not
implemented yet, future enhancement)."

Spec 12 adds "Evidence Package Export (Phase 1): GPS track + audio +
session logs as encrypted ZIP." The evidence package is encrypted, but
the existing manual JSON export remains unaddressed. Are there now two
export paths? Does the evidence package replace the JSON export?

### M5. No decision on non-blocking event execution

01-chain-engine.md lines 688-698 specifies a configurable per-step
`nonBlockingOnFailure` toggle (default true) and a 30-second timeout
wrapper around `executeReal()`. Spec 12 does not mention this. Should
it be kept, removed, or modified? This interacts with the sub-chain
changes.

### M6. No decision on session start validation changes

01-chain-engine.md lines 663-684 specifies detailed pre-session
validation (permissions, contacts, installed apps, emergency number,
battery optimization). Spec 12 adds triggers (GPS disarm, hardware
distress) and medical profile but does not update the validation
checklist. GPS disarm needs location permission. Trigger configuration
needs validation.

### M7. No decision on network status indicator

01-chain-engine.md lines 714-715 specifies: "The session screen SHOULD
show a network status indicator." Spec 12 does not address this. Keep
or remove?

### M8. No decision on session log privacy defaults for export

03-data-models.md lines 648-652 specifies that location data is
excluded by default from exports, contact names included by default
with optional anonymization, and export requires PIN. The new evidence
package feature (which includes GPS tracks) needs explicit privacy
defaults.

### M9. No decision on disguised reminder retry interval

01-chain-engine.md lines 88-93 and 288-300 describe two different
retry behaviors for disguised reminders: line 88 says retries fire
IMMEDIATELY (skip wait), but the state machine diagram on lines
288-300 shows retries going through the full wait -> duration -> grace
cycle. Spec 12 line 63-66 clarifies wait is skipped on retry but
only in a general section that does not specifically mention
disguised reminders or reconcile these two conflicting descriptions
in 01.

### M10. No decision on voice command activation

00-overview.md line 274: Modes "Can be activated by voice command or
automation trigger (e.g., 'Hey Siri, Safety Mode')." Spec 12 does not
address this. Keep, defer, or remove?

### M11. No decision on Siri Shortcuts / Android automation

Related to M10 but distinct. 00-overview lists this as a core feature
of custom modes. If deferred, it should be in the deferred features
list.

### M12. No decision on max pause duration default vs. 01-chain-engine

Spec 12 line 141: "Configurable maximum pause duration per mode.
Default: unlimited."

01-chain-engine.md line 523: "No maximum pause duration -- session
can pause indefinitely."

These agree, but spec 12 introduces the concept of a configurable max
that didn't exist before. It also says (line 143) "After 30 minutes
of pause: show notification." This 30-minute notification is new
behavior not in any other spec and should be flagged as an addition.

### M13. Walk Mode seed data discrepancy: missing phoneCallContact

Spec 12 Walk Mode (lines 402-410) has 5 steps including
`phoneCallContact`. 03-data-models.md seed data (lines 770-796) has
only 4 steps (holdButton, fakeCall, smsContact, callEmergency) with
no phoneCallContact step. The Date Mode in spec 12 (lines 412-421)
also adds phoneCallContact. This is a deliberate change but not
flagged as an amendment to 03-data-models seed data.

### M14. Date Mode grace period change not flagged

Spec 12 Date Mode step 0 (line 416): `grace=120s`. 03-data-models
seed data (line 805): `gracePeriodSeconds: 5`. This is a 24x increase
and changes user experience significantly. Not flagged as an explicit
decision.

---

## 3. CLARITY -- Ambiguous Decisions

### A1. "Chains are chains" but distress chain is never defined as a model

Line 21-23: "Main chain, distress chain, duress chain, battery chain
-- all are just chains."

The duress chain has `DuressChainConfig` (typeId 17). The battery
chain has `BatteryAlertConfig` (typeId 18). The wrong-pin chain has
`WrongPinChainConfig` (typeId 19). But the "distress chain" (triggered
by hardware button at last step, or by 3-second decline hold) has no
model definition anywhere. Where is it stored? Is it a field on
`SessionMode`? A separate Hive object? This is unspecified.

### A2. "Advance by 1 step" vs "trigger distress chain" -- which takes priority?

Line 74-75: Hardware button "Advances chain by 1. If at last step,
executes the mode's distress chain (if configured)."

Line 214-215: `HardwareButtonDistressTrigger` -- "Advance by 1 step
(or jump to specific step)."

These describe two different mechanisms (engine method vs trigger
system) that do the same thing. Which one fires? Both? What if a mode
has both a hardwareButton chain step AND a
HardwareButtonDistressTrigger? The precedence is unclear.

### A3. "Sensitivity" phase in sealed EngineState but undefined in timing model

Line 184: `EngineRunning { stepIndex, phase, remaining, missCount,
isHolding, isAwaitingFirstTouch }` -- includes "phase" which
presumably can be wait/duration/grace/sensitivity.

The three-phase timing model in 01-chain-engine is wait/duration/grace.
Sensitivity is specific to holdButton. The sealed state should
document what valid phase values are, or the Phase enum should be
defined. A developer cannot implement this without guessing.

### A4. Sub-chain allowed step types vs duress chain spec

Line 155: "Only allowed step types in sub-chains: smsContact,
phoneCallContact, loudAlarm, callEmergency, countdownWarning."

06-settings.md line 192: Duress chain editor "Can only include real
actions (SMS, calls, alarms); no UI-driven steps like holdButton."

These mostly agree but spec 12 adds `countdownWarning` to the allowed
list. Is countdownWarning a "real action"? It is primarily UI-driven
(visual countdown + vibration). This should be explicit.

### A5. "Configurable" PIN timeout without specifying where

Lines 18-19: "10-second configurable timeout." But where is this
configured? Per-mode? Global setting? Per-action? Not specified.

### A6. Trigger 500ms cooldown scope unclear

Line 245: "500ms cooldown between distress triggers to prevent
double-advancement." Does this apply per-trigger-type or globally
across all distress triggers? If two different triggers fire within
500ms (e.g., hardware button + NFC in a future phase), does the
cooldown block the second?

### A7. Simulation "stealth simulation" vs simulation SIM indicators

Lines 291-293: "Stealth simulation: SIM watermark (not orange border).
Tests stealth appearance. `[SIM]` only in notifications."

This mode is described nowhere else. How is it activated? Is it a
separate toggle from the normal simulate button? How does it interact
with the "SIM indicators cannot be hidden" rule on line 288?

### A8. Evidence Package Export format undefined

Line 474: "GPS track + audio + session logs as encrypted ZIP. Archive
package." No encryption scheme specified (what key? user-provided
password? device key?). No file format for GPS track (GPX? GeoJSON?).
No specification of which audio files are included.

### A9. Home Screen Widget scope undefined

Line 476-477: "OS-level widget: one-tap fake call, session status,
'I'm OK' button." No mention of which platforms (Android only? both?),
widget framework, size constraints, or update frequency. 00-overview
mentions `home_widget` package but spec 12 does not confirm or change
this.

### A10. "Decline with Distress" confirmation unclear

Lines 99-100: "Holding the Decline button for 3 seconds triggers the
mode's distress chain."

04-screens-navigation.md line 887: "Prevent accidental distress via
confirmation."

Spec 12 does not mention any confirmation dialog after the 3-second
hold. Does the distress chain fire immediately, or is there a
confirmation step? The existing 04-screens spec says confirmation is
required, but 12 is silent.

---

## Summary

| Category | Count |
|----------|-------|
| Internal contradictions | 7 |
| Missing decisions | 14 |
| Ambiguous decisions | 10 |
