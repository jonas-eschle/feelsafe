# Audit decisions — answered (2026-04-26)

Companion to `2026-04-25-audit-decisions.md`. The 57 numbered questions
were walked through interactively. Each entry below records the decision
+ the motivation the user gave (or the implicit reasoning where the
default was accepted).

This is the authoritative answer log that drives the spec rewrite.

---

## Cross-cutting design pivots

These emerged during the walkthrough and override several individual
question answers:

1. **No session restore from disk EVER.** Session state is in-memory
   only; SessionLog is one atomic write at sessionEnded. App-death
   mid-session = session is gone. Eliminates `bootRestart`, `appRestored`,
   `appTermination` from the engine state machine.
2. **fakeCall is an event, not a pause.** Engine timer keeps running
   during FakeCallScreen. Removes `fakeCallAnswered` PauseReason.
3. **Distress chains and modes are the same model.** Delete the
   `DistressChain` class. `Mode.distressModeId` references another
   `Mode`. ModeOverrides does NOT carry `distressModeId` (it's
   intrinsic to a mode, not an override of a global default).
4. **Layered defaults preserved.** Override resolution for ChainStep
   config:
     1. `step.config` (innermost)
     2. `mode.modeOverrides.eventDefaults[step.type]` (mode-level
        override)
     3. `AppDefaults.eventDefaults[step.type]` (global default)
5. **Always include motivation.** Every spec entry MUST/SHOULD line
   gets a "Why:" annotation; every option in a decision question
   explains its trade-off.

---

## §1. Engine semantics

| Q | Answer |
|---|--------|
| Q1 | **Reset to step 0**. Disarm = false-alarm reset. Re-emit `userDisarmed`. The "I'm Safe" slider becomes a separate end-session action (`endSession(reason: userQuit)` or new `imSafe`). Two distinct user intents, two distinct paths. |
| Q2 | **All 13 events canonical**. Promote sessionStarted, graceExpired, distressTriggered, distressCompleted, pauseExpired, stepExecutionFailed. Spec event API gets richer. |
| Q3 | **6 EndReasons**: chainExhausted, hardwarePanic, duressPin, wrongPinExhausted, userQuit, pauseExpired. Drop `disarm` (Q1: disarm doesn't end). Drop `appTermination` (no disk restore = no termination marker). |
| Q4 | **2 PauseReasons**: userRequested, incomingCall. Drop `fakeCallAnswered` (fakeCall isn't a pause) and `bootRestart` (no disk restore). |
| Q5 | **End on expiry; engine emits pauseExpired**. Single source of truth. Controller-side timeout removed. |
| Q6 | **Both notification action + in-app button**. Disguised reminder's primary notification action calls `engine.checkIn()`; SessionScreen also shows an in-app "I checked in" button for Date Mode. |

## §2. Triggers

| Q | Answer |
|---|--------|
| Q7 | **Yes invoke HardwareButtonService.start()** per configured DistressTrigger from TriggerManager.start(). |
| Q8 | **Yes filter panic events** by buttonType + pattern + pressCount + windowMs against the configured trigger. Eliminates false fires from volume-music adjustment, pocket presses, leftover events, mode-mismatch. |
| Q9 | **AppSettings.wrongPinThreshold canonical**. Delete the hardcoded const and the WrongPinThresholdDisarmTrigger.threshold field. Slider 2–10 in Security settings. |
| Q10 | **Expose disarmTriggers in mode editor**. Add a section for GPS arrival + auto-disarm timer. |
| Q11 | **Expose pauseAllowed + maxPauseMinutes in mode editor**. Range 5 min – 6000 min (100 hours). Allows multi-day events (camping trip, festival). |

## §3. PIN

| Q | Answer |
|---|--------|
| Q12 | **Add a Submit button** to the PIN dialog. Explicit confirm; no auto-emit on length-match. |
| Q13 | **Reject collision** at setDuressPinHash if equal to sessionEndPinHash or appPinHash. Validation at setter. |
| Q14 | **Optional launch gate**, default OFF. Toggle in Security settings. When enabled, PIN OR biometric unlocks. Biometric substitutes for PIN. |
| Q15 | **Per-prompt counter** (current). Trades security (~3.6h offline brute force for 10k 4-digit PINs) for usability (no accidental lockout). User accepts the trade-off. |
| Q16 | **Argon2id m=32 MiB, t=3, p=4**. Universal device support; ~0.65s/attempt. Document in spec 06. |
| Q17 | **Editable wrong-PIN dialog title** under StealthConfig. `StealthConfig.angelaDialogTitle: String?` (default null = locale's "Old PIN from Angela"). |

## §4. Duress

| Q | Answer |
|---|--------|
| Q18 | **Neither**. No engine-side silence grace, no editor validation. User responsible for designing silent-first distress chain. (NOTE: Q31 default chain starts with smsContact which IS silent on Android.) |
| Q19 | **Propagate triggerReason** to sessionEnded.endReason. duressPin / wrongPinExhausted / hardwarePanic each appear distinctly in SessionLog. Consistent with Q3. |

## §5. Fake call / Disguised reminder

| Q | Answer |
|---|--------|
| Q20 | **Auto-push /fake-call** on stepStarted(fakeCall). SessionScreen calls context.go(RouteNames.fakeCall). Returns to Session on hangup. |
| Q21 | **5s hold for declineWithDistress; add to spec**. Model field default raises 2.0 → 5.0; UI honors model. |
| Q22 | Covered by Q6 (both notification action + in-app button). |
| Q23 | **Fix to chain.length; always visible**. Add `WalkSession.totalSteps` field; engine populates from chain.length at session start. The +2 was a typo with no design rationale. |

## §6. Stealth

| Q | Answer |
|---|--------|
| Q24 | **Multiple disguise variants**. Music + Podcast + Calendar full UIs, switch by StealthConfig.fakeIcon. Substantial UI work; matches the rest of the stealth promise. |
| Q25 | **Spec defaults; stealth disabled by default**. `stealth.enabled=false`; presets ready when user enables. fakeName default 'Music'; notificationDisguise/sessionScreenStealth default false. |
| Q26 | **Three-state enum: normal / small / none** for timerDisplay. 'small' is integer-only display. |
| Q27 | **All "Angela" strings editable** under StealthConfig. Wrong-PIN dialog (Q17), emergency-confirm banner, distress SMS templates, disguised reminder copy — each becomes a per-user override with locale-default fallback. |

## §7. Onboarding & home

| Q | Answer |
|---|--------|
| Q28 | **Reuse full ContactFormScreen** in onboarding page 2. All fields: name, phone, relationship, channel toggles (SMS/WhatsApp/Telegram), language. |

## §8. Mode editor & seed data

| Q | Answer |
|---|--------|
| Q29 | **Restore 5-step Walk Mode**: holdButton (3min) → fakeCall → smsContact → phoneCallContact → callEmergency. Spec wins. |
| Q30 | **Restore 5-step Date Mode + waitSeconds:1800** (30 min between reminders). Spec wins. |
| Q31 | **Keep 3-step distress** (smsContact + countdownWarning + callEmergency); update spec to match. SMS first (silent), then audible countdown, then emergency call. |
| Q32 | **randomize: double in [0,1]** (current code). Per-step jitter factor; powerful for evading observer pattern detection. |
| Q33 | **Defer to spec values** for the ~10 default mismatches. gradualVolume:true, flashLight:false, randomizeInterval:true, preSendSms:true, recordDurationSeconds:30. |

## §9. Battery alert

| Q | Answer |
|---|--------|
| Q34 | **OFF by default**. User must opt-in in Settings. Privacy-first; battery-alert SMS is auto-fired, requires explicit consent. |
| Q35 | **10% threshold** (spec). Closer to actual emergency; fewer false fires. |
| Q36 | **Re-arm on toggle**. ref.listen on batteryAlertController; settings change takes immediate effect. |

## §10. Storage layer

| Q | Answer |
|---|--------|
| Q37 | **DEFERRED**. User wants deep research: compare Drift+SQLCipher vs Hive CE+HiveAesCipher in this app's context, including binary size, query patterns (full-text search? joins?), encryption strength, web/desktop support, native dep cost, code complexity. Build a small benchmark, return with results, then decide. CLAUDE.md rewrite (Q53) gates on this answer. |

## §11. Security & privacy

| Q | Answer |
|---|--------|
| Q38 | **Enable encryptedSharedPreferences** for flutter_secure_storage. AndroidOptions(encryptedSharedPreferences: true). One-line change. |
| Q39 | **allowBackup=true**. User backup allowed. (Combined with Q39b below.) |
| Q39b | **Per-element user-configurable backup**. In-app Backup feature lets user pick what to back up. Spec must define the granular control. |
| Q40 | **No FLAG_SECURE**. Nothing at the screen level is inherently sensitive once stealth disguise applied; user can screenshot session for evidence. |
| Q41 | **Accept workdb plaintext exposure**. Distress SMS body + recipient may sit in WorkManager workdb up to 10 retries. Forensic-acceptable in user's threat model. |
| Q42 | **Sentry opt-IN, default OFF**. GDPR-compliant. User explicitly enables in Settings. |
| Q43 | **Sentry DSN via --dart-define**. Build-time constant; not in source. |
| Q44 | Covered by Q19 + Q3 (propagate exact endReason). |
| Q45 | **Add NSFaceIDUsageDescription** to iOS Info.plist. Apple policy requires it for biometric prompts. |
| Q46 | **Plumb actual GPS to {location}** placeholder. Resolve from services.context.lastLocation. Recipient gets coordinates (or maps URL — TBD spec detail). |
| Q47 | **Remove Quick Exit code** to match spec. SystemUiService.quickExit + finishAndRemoveTask deleted. |

## §12. Architecture refactors

| Q | Answer |
|---|--------|
| Q48 | **Split SessionController into 4** controllers: SessionLifecycleController, PinGateController, DistressOrchestrationController, BatteryAlertController. |
| Q49 | **Move enums.dart to lib/domain/models/**. Fixes the layer inversion. |
| Q50 | **Add ref.onDispose** for BatteryMonitorService. 2-line fix. |
| Q51 | **Split step_config.dart per subtype** (9 files). Diff-friendly review. |
| Q52 | **DESIGN PIVOT — Mode unifies SessionMode + DistressChain.** Delete DistressChain class entirely. `Mode.distressModeId: String?` references another Mode. AppDefaults.defaultDistressModeId is the global default (single id). ModeOverrides keeps eventDefaults/gpsLogging/stealth/templates only — distressModeId is intrinsic to Mode, not an override of a global default. |

## §13. Documentation

| Q | Answer |
|---|--------|
| Q53 | **Rewrite CLAUDE.md after Q37 decision**. Then update Hive→Drift (or keep Hive), 24→32 screens, actual file paths. |
| Q54 | **Import all 9 decision IDs into 08-decisions-consolidated.md** (D-SEC-5, D-SAFETY-6/7/11/17, D-UX-4, D-DATA-7, D-DATA-21, D-SEC-10). decisions-log.md becomes archived. |
| Q55 | **Default 'Angela' callerName** in seed_data.dart. User-editable per Q27. Spec 03's "Mom" line gets fixed to "Angela". |
| Q56 | **Update links** from the phantom rewrite-decisions filename → `08-decisions-consolidated.md`. |
| Q57 | **Replace phase tags with decision IDs** in TODO comments (e.g., TODO(D-SEC-13)). ~50 occurrences. |

## §14. Bugs (no decision needed; clear fixes during rewrite)

- **B1.** session_engine.dart:344 declineIsSafe fallback. Fix: use `(cfg is FakeCallConfig ? cfg : const FakeCallConfig()).declineIsSafe`.
- **B2.** SessionController._runtime not cleared after sessionEnded. Fix: call `_disposeRuntime()` in the sessionEnded handler.
- **B3.** _fireDistressBecauseOfPin missing try/catch around `onAngelaDeceptiveDialog!()`. Fix: wrap and swallow exceptions; safety-critical path must not be gated on UI.
- **B4.** PIN dialog 8-digit cap (Q12 makes this go away when Submit button is added).
- **B5.** TriggerManager.batteryMonitorService unused parameter. Fix: remove from constructor (battery-alert pipeline lives in BatteryAlertController per Q48).

---

## Next steps

1. **Q37 research** — Drift vs Hive deep dive (parallel; spawn now). Compare:
   - Binary size impact
   - Query patterns this app needs (joins? full-text search? streaming?)
   - Encryption strength (SQLCipher vs HiveAesCipher)
   - Web / desktop / mobile support matrix
   - Native dependency cost
   - Code complexity for the actual schema
   - Migration effort either direction
2. **Spec rewrite** — once Q37 settled, rewrite spec files 00, 01, 03, 04, 05, 06, 08; CLAUDE.md (Q53). Build the unified Mode model (Q52) into spec 03; flatten distress chains.
3. **Code rewrite** — drive code changes from the rewritten spec, not the other way around.
4. **Bug fixes B1–B5** — fold into the code rewrite.
