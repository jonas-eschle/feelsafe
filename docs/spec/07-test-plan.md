> **Normative status:** This document is NORMATIVE. In case of conflict
> with any other document (decisions log, audits, reviews), this document
> takes precedence. Key words "MUST", "SHOULD", "MAY" follow RFC 2119.

# 07 - Test Plan

## Overview

This document describes the comprehensive test strategy for Guardian Angela, covering unit tests, widget tests, and integration tests. The test plan is organized into layers (pure Dart engine, controller, UI components) and prioritized by safety-criticality.

**Total target: 180+ test cases across all layers** (comprehensive coverage of session engine, controllers, UI, and integration flows).

---

## Test Strategy & Infrastructure

### Test Layers

1. **Unit Tests** (`package:test`) — Pure Dart logic (engine, models, repositories, helpers)
   - No Flutter dependencies
   - Fast execution, suitable for CI/CD
   - Cover state machines, timers, randomization, data models

2. **Widget Tests** (`package:flutter_test`) — UI components in isolation
   - Use `WidgetTester` to build and interact with widgets
   - Mock controllers and services via `Riverpod` overrides
   - Verify visual behavior, layout, accessibility

3. **Integration Tests** (`package:integration_test`) — End-to-end flows
   - Real app lifecycle, navigation, state persistence
   - Verify complete user journeys (onboarding → session → log)

### Test Infrastructure & Tools

| Tool | Purpose | Usage |
|------|---------|-------|
| `package:test` | Unit test framework | Pure Dart tests |
| `package:flutter_test` | Widget/integration test framework | UI and flows |
| `package:checks` | Expressive assertions | `check(...).isNotNull()`, `check(...).isA<T>()` |
| `fake_async` | Deterministic timer control | `fakeAsync((async) { ... async.elapse(...) })` |
| `_FixedRandom(0.5)` | Deterministic randomization | Eliminates jitter (factor = 1.0) |
| `mocktail` | Mocking for Riverpod providers | Mock services (audio, SMS, location) |
| `_step()` factory | ChainStep creation helper | Minimal boilerplate for test steps |

### Arrangement Pattern

Follow **Arrange-Act-Assert** (AAA) for all tests:

```dart
test('holdButton: release cancels duration, grace allows re-hold', () {
  fakeAsync((async) {
    // Arrange
    final engine = SessionEngine(
      chainSteps: [_step(type: ChainStepType.holdButton)],
      random: _FixedRandom(),
    );
    final events = <ChainEventData>[];
    engine.events.listen(events.add);

    // Act
    engine.start();
    async.flushMicrotasks();
    engine.holdStart();
    engine.holdRelease();
    async.elapse(const Duration(seconds: 1));  // sensitivity fires
    async.elapse(const Duration(seconds: 10)); // duration countdown fires
    async.elapse(const Duration(seconds: 5));  // grace fires
    engine.holdStart();                        // re-hold during grace

    // Assert
    check(events)
        .deepEquals(
          predicate<ChainEventData>((e) => e.event == ChainEvent.userDisarmed),
        );
  });
});
```

### Test File Structure

Test files mirror the `lib/` directory structure:

```
test/
├── features/
│   ├── session/
│   │   ├── session_engine_test.dart       # Core engine tests
│   │   ├── session_controller_test.dart   # Controller logic
│   │   └── event_strategies_test.dart     # Strategy pattern
│   ├── home/
│   │   └── home_screen_test.dart
│   └── ...
├── data/
│   ├── models/
│   │   ├── chain_step_test.dart
│   │   ├── session_mode_test.dart
│   │   └── ...
│   └── repositories/
│       └── session_log_repository_test.dart
├── services/
│   ├── audio_service_test.dart
│   └── ...
└── helpers/
    └── test_helpers.dart                 # _step(), _FixedRandom, etc.
```

### Test Execution

```bash
# Run all tests
flutter test

# Run tests in parallel
pytest -s -n auto

# Run single test file
flutter test test/features/session/session_engine_test.dart

# Run tests matching pattern
flutter test --name "hold button"

# Integration tests (real device or emulator)
flutter test integration_test/app_test.dart
```

---

## SessionEngine Tests (31 Cases)

### Hold Button Tests (8)

The hold button is a user-driven check-in method: user holds to confirm safety, release starts grace period.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 1 | Start session with holdButton, no timer fires until user acts | Engine starts, step 0 = holdButton | `engine.start()`, wait | stepStarted emitted, no other events |
| 2 | Full lifecycle: holdStart → holdRelease → sensitivity → duration → grace → advance | Step 0 = holdButton (10s duration, 5s grace), Step 1 = loudAlarm | holdStart, release, wait 1s, wait 10s, wait 5s | Advances to step 1 after grace |
| 3 | Brief release (< 1s sensitivity) ignored, no countdown | holdButton with 1s sensitivity threshold | holdStart, holdRelease, holdStart within 1s | No countdown timer started, holding state restored |
| 4 | Release → countdown → re-hold cancels countdown | holdButton with 10s duration | holdStart, release (sensitivity fires), wait 5s, holdStart | Countdown cancelled, duration timer restarted |
| 5 | Release → countdown → grace expires → re-hold during grace disarms | holdButton with 10s duration, 5s grace | holdStart, release, wait 15s, holdStart | userDisarmed emitted, reset to step 0 |
| 6 | holdStart on non-holdButton step (e.g., fakeCall) is no-op | Step 0 = fakeCall | holdStart() called | No-op, no state change |
| 7 | holdRelease on non-holdButton step is no-op | Step 0 = fakeCall | holdRelease() called | No-op, no state change |
| 8 | holdRelease without holdStart is no-op | Step 0 = holdButton | holdRelease() called | No-op, sensitivity timer not started |

### Disguised Reminder Tests (7)

The disguised reminder is a timer-driven check-in method: periodic fake notifications prompt user to check in.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 9 | Start → wait interval fires → reminderFired event emitted | Step 0 = disguisedReminder (30s wait) | engine.start(), elapse 30s | reminderFired event emitted |
| 10 | reminderFired → user disarms within duration | Step 0 = disguisedReminder (30s wait, 60s duration) | start, elapse 30s, disarm | userDisarmed emitted, reset to step 0 |
| 11 | reminderFired → duration expires → grace expires → miss counted | Step 0 = disguisedReminder (30s wait, 60s duration, 5s grace) | start, elapse 95s | repeatMissed emitted with missCount = 1 |
| 12 | 3 misses → advance to next step | Step 0 = disguisedReminder (repeatCount=2), Step 1 = loudAlarm | start, elapse wait/duration/grace 3 times | stepAdvancing emitted, advance to step 1 after 3rd miss |
| 13 | Disarm resets miss count | Step 0 = disguisedReminder, miss once | start, elapse 95s (1 miss), disarm | missCount = 0 after disarm |
| 14 | Randomize ±20% applies to waitSeconds | Step 0 = disguisedReminder (waitSeconds=1000, randomize=true) | With _FixedRandom(0.5): factor=1.0, no jitter; test with Random() | Timer duration within [800, 1200] ms range (with Random) or exactly 1000 (with _FixedRandom) |
| 15 | No premature reminderFired before interval | Step 0 = disguisedReminder (30s wait) | start, elapse 25s | No reminderFired event yet, only stepStarted |

### General Step Lifecycle Tests (5)

All non-holdButton, non-disguisedReminder steps follow the same three-phase pattern.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 16 | Step with wait > 0 | Step 0 = countdownWarning (10s wait, 5s duration, 3s grace) | start, elapse phases | stepStarted → wait fires → duration fires → grace fires → advance |
| 17 | Step with wait = 0 (immediate) | Step 0 = loudAlarm (0s wait, 15s duration, 5s grace) | start | duration phase begins immediately, no wait |
| 18 | Step with duration = 0, grace = 0 | Step 0 = smsContact (0s wait, 0s duration, 0s grace) | start | Immediately advance to next step |
| 19 | Step with repeats: full repeat cycle | Step 0 = fakeCall (0s wait, 5s duration, 2s grace, repeatCount=1) | start, elapse 7s (miss 1), elapse 7s (miss 2) | grace expires → repeat cycle → second grace → advance |
| 20 | Disarm at any phase resets to step 0 | Step 0 = loudAlarm, Step 1 = fakeCall, at any phase | start at step 1, disarm | Reset to step 0, miss count cleared |

### Disarm Tests (4)

Disarm resets the chain to step 0 and clears miss count, regardless of current state.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 21 | Disarm at step 0 | Step 0 = holdButton, step 1 = fakeCall | start, disarm immediately | userDisarmed emitted, step 0 re-executed |
| 22 | Disarm at step 2 | Steps: holdButton, fakeCall, loudAlarm | start, advance to step 2, disarm | userDisarmed emitted, reset to step 0 |
| 23 | Disarm during loudAlarm (always disarmable) | Step 0 = loudAlarm (30s) | start, elapse 10s, disarm | userDisarmed emitted, alarm stopped |
| 24 | Disarm during callEmergency (always disarmable) | Step 0 = callEmergency (5s countdown) | start, elapse 2s, disarm | userDisarmed emitted, emergency call not placed |

### Fake Call Decline Tests (3)

Declining (not answering) a fake call does NOT disarm; it repeats the call with grace period.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 25 | Decline → grace → re-fire same step | Step 0 = fakeCall (10s duration, 2s grace, repeatCount=1) | start, elapse 10s (decline), elapse 2s (grace) | Grace expires, same step re-fires (2 total attempts) |
| 26 | Decline preserves miss count | Step 0 = fakeCall (repeatCount=2), decline twice | start, decline at 10s, decline at 22s | Miss count = 2 after 2 declines, advance on 3rd |
| 27 | Multiple declines → repeat limit → advance | Step 0 = fakeCall (repeatCount=1), Step 1 = loudAlarm | start, decline, wait grace, decline, wait grace | After 2 declines, advance to step 1 |

### Simulation Tests (7)

Simulation mode allows speed control and fast-forward for testing without real consequences.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 28 | Speed multiplier 5x: timers fire 5× faster | Engine with isSimulation=true, speedMultiplier=5.0, Step 0 = fakeCall (10s duration) | start, elapse 2s | Timer fires (10s / 5 = 2s) |
| 29 | leapToNextEvent: skip to 1s before next fire | isSimulation=true, Step 0 = loudAlarm (30s wait) | start, leapToNextEvent | Active timer replaced with 1s countdown |
| 30 | SMS blocked in simulation: logged as sim_blocked, not sent | isSimulation=true, Step 0 = smsContact | strategy.executeReal() called | SMS not sent, SessionLogEvent has status=sim_blocked |
| 30a | Simulation end shows PIN prompt when configured | isSimulation=true, sessionEndPinHash set | Simulation ends (disarm or chain exhaust) | PIN prompt shown with "Skip" button visible |
| 30b | Simulation end skips PIN prompt when not configured | isSimulation=true, sessionEndPinHash=null | Simulation ends | No PIN prompt; goes directly to Simulation Summary |
| 30c | Simulation PIN "Skip" button bypasses PIN | isSimulation=true, sessionEndPinHash set, PIN prompt shown | Tap "Skip" | Simulation Summary screen shown without entering PIN |
| 30d | Simulation wrong PIN does NOT fire distress chain | isSimulation=true, sessionEndPinHash set | Enter wrong PIN 5+ times | Shake animation shown; no distress chain fired; no failure counter increment |
| 30e | Simulation Summary has no "Start Real Session" button | isSimulation=true | Simulation ends, summary shown | Only "Share" and "Done" buttons present; no way to convert to real session |

### Edge Cases Tests (6+)

Boundary conditions and unusual scenarios.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 31 | Empty chain → start | chainSteps = [] | engine.start() | No-op or throws (depends on validation) |
| 32 | Single step → exhaust | chainSteps = [fakeCall with 0 repeats] | start, elapse duration + grace | chainExhausted emitted |
| 33 | Duplicate step types in chain | chainSteps = [loudAlarm, loudAlarm] | start, advance to step 1 | Both fire in order (different instances) |
| 34 | endSession during any phase | Multiple phases tested | Call endSession() mid-phase | sessionEnded emitted, all timers cancelled |
| 35 | endSession is idempotent | Session already ended | Call endSession() twice | Second call is no-op, no duplicate events |
| 36 | Rapid disarm cycling | Step 0 = holdButton, rapid holdStart/Release calls | Rapid calls (< 100ms apart) | No crash, state consistent |
| 37 | All 9 step types in sequence | chainSteps = [all 9 types] | start, advance through all | Each step fires correctly in order |

---

## Realistic Scenario Tests (13 Cases)

### Walk Home Scenarios (5)

User walking home with continuous hold button check-in.

| # | Scenario | Setup | Steps | Expected |
|---|----------|-------|-------|----------|
| 38 | Normal walk: hold sustained for 5 min, release, re-hold, hold 10 min, end | Walk Mode chain | holdStart → hold 5min → holdRelease → 3s grace → holdStart (re-hold) → hold 10min → endSession | No escalation, session ends cleanly |
| 39 | Phone drops: hold → unintentional release → full chain to exhaustion | Walk Mode chain with 2 escalation steps (fakeCall, loudAlarm) | holdStart → holdRelease → sensitivity → duration → grace (no re-hold) → fakeCall fires → decline → loudAlarm fires | All steps executed, session exhausted |
| 40 | False alarm: release → user notices → re-hold within grace | holdButton (10s duration, 5s grace) | holdStart → holdRelease → sensitivity → 2s grace remaining → holdStart | Re-hold during grace triggers disarm, chain resets |
| 41 | Caught during fake call: answer → disarm | Walk Mode, at fakeCall step | fakeCall rings → user answers → after call, disarm action | userDisarmed emitted, chain resets to step 0 |
| 42 | Grip adjustments: multiple brief releases < sensitivity threshold | holdButton with 1s sensitivity | holdStart, release 0.5s, holdStart, release 0.3s, holdStart | Brief releases ignored, holding continues, no escalation |

### Date Mode Scenarios (4)

User on date with periodic disguised reminder check-ins.

| # | Scenario | Setup | Steps | Expected |
|---|----------|-------|-------|----------|
| 43 | Safe date: all reminders confirmed | Date Mode (disguisedReminder every 10 min, 3 cycles) | start, elapse 10m → disarm, elapse 10m → disarm, elapse 10m → disarm | 3 successful check-ins, no escalation |
| 44 | Distracted: miss 1, confirm next 2 | disguisedReminder (10m interval, repeatCount=1) over 3 cycles | start, elapse 10m → miss grace, elapse 10m → disarm, elapse 10m → disarm | 1 miss triggers repeat, confirm on 2nd attempt, then 2 clean confirmations |
| 45 | Dangerous: 3 misses → escalation to fakeCall | disguisedReminder (10m, repeatCount=2), then fakeCall | start, elapse 3× full cycle (10m+duration+grace each) without disarm | 3 misses → advance to fakeCall step |
| 46 | Background: reminders fire while app backgrounded | Date Mode with background execution | start, app moves to background, elapse 10m | reminderFired event emitted even when backgrounded (foreground service keeps timers alive) |

### Fake Call Scenarios (4)

User interaction with fake incoming calls.

| # | Scenario | Setup | Steps | Expected |
|---|----------|-------|-------|----------|
| 47 | Answer: disarm, back to step 0 | fakeCall (30s ring) | start, ring fires, user answers | answerFakeCall() → disarm triggers, reset to step 0 |
| 48 | Decline: grace → rings again | fakeCall (30s ring, 2s grace, repeatCount=1) | start, ring fires, user declines, wait 2s grace | restartCurrentStep() → grace expires → re-ring |
| 49 | Decline twice: 2 misses → advance | fakeCall (30s ring, 2s grace, repeatCount=1), then loudAlarm | start, decline, wait grace, decline, wait grace | 2 declines, miss count = 2, advance to loudAlarm |
| 50 | Unanswered: grace expires → advance | fakeCall (10s ring, 5s grace, repeatCount=0), then loudAlarm | start, ring fires, no user action, wait 15s | Grace expires → advance to loudAlarm |

### Stealth Mode Scenarios (3)

User in stealth mode (disguised escalation).

| # | Scenario | Setup | Steps | Expected |
|---|----------|-------|-------|----------|
| 51 | Chain exhausts in stealth: no end screen, silent exit | Stealth mode enabled, chain exhausts | start, advance through all steps | chainExhausted → no end screen displayed, return to home silently |
| 52 | Missed indicator hidden in stealth | Stealth mode, missed reminder | reminderFired → grace expires → miss counted | UI does not show missed indicator badge |
| 53 | Notification disguised in stealth | Stealth mode, foreground notification | start session | Notification title disguised (e.g., "Music playing"), not "Guardian Angela" |

---

## Model & Data Tests (8 Cases)

### Data Model Tests

Verify immutability, correctness, and serialization of persistent models.

| # | Test | Expected |
|---|------|----------|
| 54 | ChainStep: 3-phase timing values (wait, duration, grace) | Constructors, getters, and Duration conversions work correctly |
| 55 | ChainStep: randomize flag and per-field config | Randomization applied when flags set to true |
| 56 | ChainStep: copyWith all fields | copyWith() creates new instance, original unchanged |
| 57 | SessionMode: chainSteps ordered by order field | chainSteps sorted correctly, order preserved |
| 58 | AppSettings: three PIN fields default to null (disabled) | appPinHash, sessionEndPinHash, duressPinHash all null by default |
| 59 | EventDefaults: all 9 step types mapped | All 9 types have default configs |
| 60 | Seed data Walk vs Date modes differ | Walk mode first step ≠ Date mode first step (hold vs reminder) |
| 61 | Hive typeIds: all unique across models | No collisions in typeId allocation (0–19) |
| 61a | AppDefaults: mode inherits all defaults when ModeOverrides is null | SessionMode with overrides=null, AppDefaults with GPS enabled | Resolve effective GPS config | Returns AppDefaults.gpsLogging |
| 61b | ModeOverrides: non-null field overrides AppDefaults | SessionMode with overrides.stealth set, AppDefaults.stealth differs | Resolve effective stealth config | Returns overrides.stealth |
| 61c | ModeOverrides: null field inherits from AppDefaults | SessionMode with overrides.gpsLogging=null | Resolve effective GPS config | Returns AppDefaults.gpsLogging |
| 61d | Distress mode: mode selects target by distressModeId | Two distress modes (id="a", id="b"), SessionMode.distressModeId="b" | Resolve distress mode | Returns mode with id="b" |
| 61e | Distress mode: null distressModeId → uses AppDefaults.defaultDistressModeId | SessionMode.distressModeId=null, AppDefaults.defaultDistressModeId="a" | Resolve distress mode | Returns mode with id="a" |
| 61f | EmergencyContact: all enabled channels used (no preferredChannel) | EmergencyContact with sms=true, whatsapp=true, telegram=false | List active channels | Returns [sms, whatsapp]; telegram excluded |

---

## Session Log Tests (7 Cases)

### Logging & Persistence

Verify session logs capture all relevant event data and persist correctly.

| # | Test | Expected |
|---|------|----------|
| 62 | Session log created on chainExhausted | SessionLog saved to Hive with all events |
| 63 | Session log created on manual endSession | SessionLog saved when user ends early |
| 64 | All events timestamped | Every SessionLogEvent has non-null timestamp |
| 65 | Step type + event type mapped correctly | SessionLogEvent.eventType matches ChainEvent, stepType matches ChainStepType |
| 66 | Location logged when configured | GPS coordinates present in log when location permission granted and enabled |
| 67 | Location NOT logged when disabled | No GPS data in log when location logging disabled in settings |
| 68 | Simulation sessions marked in log | SessionLog.isSimulation = true for simulation mode sessions |
| 68a | Simulation: blocked events logged as sim_blocked | isSimulation=true, smsContact step fires | SessionLogEvent.deliveryStatus = sim_blocked; no real SMS sent |
| 68b | Simulation: phoneCallContact blocked, logged | isSimulation=true, phoneCallContact step fires | SessionLogEvent.deliveryStatus = sim_blocked; no real call made |
| 68c | Simulation: emergency call blocked, logged | isSimulation=true, callEmergency step fires | SessionLogEvent.deliveryStatus = sim_blocked; no call placed |

---

## NEW Feature Tests (105 Cases)

### PIN/Biometric Authentication (6)

Three distinct PINs: App PIN (app lock), Session End PIN (disarm/end session), Duress PIN (any
prompt → fires distress chain silently). Each is independently nullable (disabled when null).

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 69 | Correct Session End PIN disarms immediately | sessionEndPinHash set, session active | User enters correct PIN at PIN prompt | disarm() called, chain resets to step 0 |
| 70 | Wrong Session End PIN increments failure counter | sessionEndPinHash set | Enter wrong PIN | PIN failure count = 1 |
| 71 | 5 wrong Session End PINs trigger distress chain | sessionEndPinHash set, 5-attempt threshold | Enter wrong PIN 5 times | Distress chain fired (mode's resolved distress mode) |
| 72 | Wrong PIN count resets after correct PIN | PIN failure counter = 4 | Enter correct PIN | Counter reset to 0 |
| 73 | Biometric fallback for Session End PIN only | sessionEndPinHash set, biometric available | Biometric succeeds | disarm() called; biometric NOT available for App PIN or Duress PIN |
| 74a | Duress PIN fires distress chain silently at any prompt | duressPinHash set, session active | Enter duress PIN at disarm prompt | Distress chain fires; no "wrong PIN" message shown |

### Pause/Resume Session (4)

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 75 | Remaining duration preserved exactly across pause/resume | Step with 10s duration, paused after 3s (7s remaining) | pause(), resume() | Re-started timer has exactly 7s remaining |
| 76 | Notification "Pause" action triggers engine.pause() | Foreground service notification displayed | Tap "Pause" button | engine.pause() called, timers suspended |
| 77 | Notification "Resume" action triggers engine.resume() | Session paused, "Resume" button visible | Tap "Resume" button | engine.resume() called, timers restored |
| 78 | Multiple pause/resume cycles accumulate correctly | Step with 20s total, pause after 5s, resume, pause after 3s more, resume | Multiple pause/resume cycles | Total elapsed = 8s, remaining = 12s (accurate) |

### Fake Lock Screen (5)

Disguised UI that looks like lock screen but is actually a hold button check-in.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 79 | Black screen renders with no app UI visible | Fake lock screen enabled, session active | Screen displayed | No app branding, toolbar, or navigation visible |
| 80 | Tap anywhere fires check-in (holdStart) | Fake lock screen, user taps | Tap | holdStart() triggered, holding state activated |
| 81 | Long press opens PIN entry (if configured) | Fake lock screen with PIN required, long press instead of tap | Long press (500ms+) | PIN entry screen appears (not immediate disarm) |
| 82 | System back gesture blocked | Fake lock screen active | Press system back button | No-op, back navigation blocked |
| 83 | Hold-release sensitivity works on fake lock screen | Fake lock screen, hold 0.5s then release | holdStart, holdRelease at 0.5s, holdStart again | Brief release ignored (< 1s sensitivity) |

### Fake Music Player (5)

Disguised UI that looks like music player but is actually a check-in mechanism.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 84 | Renders track title and controls, no branding visible | Fake music player enabled | Screen displayed | Music player UI (track, artist, controls) visible, no safety app branding |
| 85 | "I feel fine" slider at max position fires disarm | Slider at threshold 1.0 (max) | Slide to max | disarm() triggered |
| 86 | Slider below threshold does not disarm | Slider threshold = 0.8, slider at 0.7 | Slide to 0.7 | disarm() not triggered |
| 87 | Threshold boundary value tested (0.99 vs 1.0) | Slider threshold = 0.99 | Slide to 0.99, then slide to 1.0 | 0.99 does not trigger, 1.0 triggers |
| 88 | No accessibility labels contain safety-related words | Screen reader running | Read all semantic labels | No "safety", "guardian", "angela", "disarm" in labels |

### Distress Hold on Decline (5)

User can hold decline button for 5 seconds to trigger distress signal instead of normal repeat.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 89 | Decline tap (normal) | fakeCall step, decline button tapped | Tap once (< 500ms) | restartCurrentStep() called (normal behavior) |
| 90 | Hold 5s triggers distress signal | Decline button, hold 5s | Hold continuously for 5s | Distress chain triggered |
| 91 | Hold 4.9s does not trigger distress | Decline button, hold 4.9s | Hold for 4.9s then release | Normal decline behavior (not distress) |
| 92 | Visual feedback during hold | Decline button, hold pressed | Hold button | Visual feedback appears (color change, progress indicator) |
| 93 | Distress works while engine paused | Engine paused, decline button displayed | Hold decline 5s | Distress chain executes even while main chain paused |

### Non-Blocking Event Execution (4)

Service failures don't block chain advancement.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 94 | SMS failure does not block chain | Step: smsContact (15s), next step: loudAlarm | SMS service fails, grace expires | Chain advances to loudAlarm despite SMS failure |
| 95 | Phone call failure does not block chain | Step: phoneCallContact (15s), next step: callEmergency | Call service fails, grace expires | Chain advances despite call failure |
| 96 | Multiple consecutive failures still exhaust chain | 3 steps: smsContact (fail), phoneCallContact (fail), loudAlarm (success) | All 3 steps execute, first 2 fail | Chain advances through failures, no hang |
| 97 | Event errors captured in session log | SMS fails during escalation | start, advance to SMS step (fails) | SessionLogEvent records failure status and error message |

### SMS Retry Queue (5)

Failed SMS messages are queued and retried when connectivity returns.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 97 | SMS enqueued when sending fails (no signal) | Network unavailable, SMS triggered | smsContact step executes, send fails | SMS added to retry queue |
| 98 | SMS sent when signal returns | SMS in queue, network unavailable then becomes available | Network becomes available, background process detects | SMS sent from queue |
| 99 | Queue persists across app restart | SMS in queue (app running), app closed and restarted | Close app, reopen | Queue reloaded, SMS still pending |
| 100 | Multiple messages sent in FIFO order | 3 SMS in queue (1, 2, 3 order) | Network available, background sends | SMS sent in order: 1, 2, 3 |
| 101 | Already-sent messages not re-sent after restart | SMS sent successfully, app restarts | Close and reopen app | SMS not in queue, not re-sent |

### Gradual Alarm Volume (5)

Alarm volume ramps from 0 to max over configurable duration.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 102 | Volume starts at 0 when alarm begins | loudAlarm step (10s ramp duration) | start loudAlarm | Initial volume = 0 |
| 103 | Volume reaches maximum at exactly configured duration | loudAlarm (10s ramp) | measure volume at 10s | Volume = max (e.g., 1.0 in normalized scale) |
| 104 | Volume is linear: midpoint is 0.5 | loudAlarm (10s ramp) | measure volume at 5s | Volume ≈ 0.5 (linear interpolation) |
| 105 | Ramp cancelled when session ends early | loudAlarm with 10s ramp, endSession at 3s | endSession() called during ramp | Volume ramp cancelled, alarm stops |
| 106 | Volume stays at max after ramp (no overshoot) | loudAlarm (10s ramp) | Wait 15s (past ramp end) | Volume stays at max (1.0), no overshoot |

### Volume Button Detection (5)

Volume buttons detected during session, reverted after.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 107 | Volume captured before session starts | System volume at 50% | start session | Pre-session volume saved = 50% |
| 108 | Volume press during session detected and reverted | Session active, press volume up button | Detect volume button press | Volume button press handled, pre-session level restored |
| 109 | Volume restored to pre-session level on session end | Pre-session volume 30%, session modifies to 70%, endSession | endSession() called | System volume restored to 30% |
| 110 | Volume restored after app kill | Volume modified during session, app killed | Relaunch app | System volume restored to pre-session level |
| 111 | ContentObserver inactive after session ends | ContentObserver listening during session | endSession() called | ContentObserver unregistered, no further volume detection |

### Emergency Call Confirmation (5)

Countdown before placing emergency call, user can cancel.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 112 | Confirmation countdown shown when enabled | callEmergency with confirmationDuration=5s | callEmergency step starts | 5s countdown visible (e.g., "Emergency in 5...") |
| 113 | Call placed after countdown expires | callEmergency (5s countdown) | countdown completes naturally | Call placed to emergency number |
| 114 | User can cancel within window (disarm) | callEmergency (5s countdown) | disarm() called during countdown | Call not placed, chain resets |
| 115 | Boundary: 1s countdown fires at exactly 1s | callEmergency (1s countdown), timer precision test | elapse exactly 1000ms | Call placed at exactly 1s |
| 116 | Confirmation disabled → call placed immediately | callEmergency with confirmationDuration=0s | callEmergency step starts | Call placed immediately, no countdown |

### Session Start Validation (5)

Pre-flight checks before session starts.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 122 | Validation fails: no contacts configured | Chain includes smsContact, no contacts added | Try to start session | Error dialog shown: "No emergency contact..." |
| 123 | Validation fails: required permission denied | Chain includes SMS, SMS permission denied | Try to start session | Error dialog shown: "SMS permission required..." |
| 124 | Validation fails: required app not installed | Chain uses WhatsApp, app not installed | Try to start session | Error dialog shown: "WhatsApp not installed..." |
| 125 | Validation passes: all requirements met | All contacts configured, permissions granted, required apps installed | start session | Session starts cleanly, no errors |
| 126 | Validation errors shown before session start (blocking) | Validation fails on smsContact, phoneCallContact, missing contacts | UI displays all 3 errors | User cannot start session until all fixed |

### Location Recording (5)

Session logs capture location data when configured.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 127 | Location recorded on escalation step (escalation mode) | Location mode = escalation, step 1 = loudAlarm | advance to loudAlarm | Coordinates recorded in SessionLogEvent |
| 128 | Location NOT recorded for non-escalation events (escalation mode) | Location mode = escalation, step 0 = holdButton | start session, use holdButton | No coordinates in holdButton event |
| 129 | Location recorded for every event (all-events mode) | Location mode = all events | start and advance through steps | Coordinates in every SessionLogEvent |
| 130 | Location permission denied doesn't crash execution | Location enabled in settings, permission denied | Request location during session | Session continues, location fields null (no crash) |
| 131 | Coordinates stored in SessionLogEvent | Location captured | Check stored log entry | lat, lng, accuracy, timestamp present and valid |

### Contact Import (4)

Import contacts from device contacts app.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 132 | Imported contact stored with correct data | Contact: "Alice +1 555-0123, email alice@example.com" | Import contact | EmergencyContact created with correct phone, email, name |
| 133 | Duplicate import handled | "Alice" imported, import again | Import same contact twice | Only one "Alice" in contacts list (or explicitly merged) |
| 134 | Contacts permission denied shows error | Contacts permission not granted | Try to import contacts | Error dialog shown: "Contacts permission required..." |
| 135 | Contact without phone number rejected | Contact: "Alice, email only, no phone" | Import contact | Contact rejected or phone field required |

### Mode Templates (4)

Create modes from built-in templates or from scratch.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 136 | Create from template preserves all steps | Template: Walk Mode (5 steps) | Create mode from template | New mode has all 5 steps with same config |
| 137 | Duplicate creates independent copy | Original Walk Mode modified (step 0 duration changed) | Duplicate mode | Duplicate unaffected by changes to original |
| 138 | Create from scratch produces empty chain | Create custom mode with no template | start() without adding steps | Chain empty or validation fails |
| 139 | Built-in templates available for re-creation | Built-in Walk Mode used, then deleted | Re-create from template | Built-in template still available |

### JSON Backup (5)

Export/import session logs and modes as JSON.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 140 | Export produces valid JSON with all data | Session log with 5 events, 2 contacts, custom mode | Export as JSON | JSON parses, contains all data |
| 141 | Import restores original data | Export all data, clear app, import JSON | Import JSON | All data restored exactly as exported |
| 142 | Malformed JSON throws descriptive error | Invalid JSON (missing closing brace) | Try to import | Error shown: "Invalid JSON format at line 3" |
| 143 | Wrong schema version rejected | JSON with version="v1" exported, app version="v2" | Try to import | Error shown: "Incompatible schema version..." |
| 144 | Export includes schema version | Export all data | Check JSON | Field "schemaVersion" = current version |

### Battery Optimization (3)

Device-specific battery optimization warnings.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 145 | Xiaomi shows Xiaomi-specific instructions | Device: Xiaomi, first session | start session | "Xiaomi Battery Saver: open Settings > Battery..." shown |
| 146 | Unknown manufacturer falls back to generic | Device: Unknown brand | start session | Generic battery optimization dialog shown |
| 147 | Dialog shown on first session start (once per device) | First session on device | start session | Battery dialog shown; subsequent sessions don't show it |

### Session Locks (3)

Prevent critical operations while session is active.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 148 | Contact deletion blocked during session | Session active, one emergency contact added | Try to delete contact | Deletion prevented; error dialog shown: "Cannot modify contacts during session" |
| 149 | Backup/restore import blocked during session | Session active, backup JSON prepared | Try to import backup | Import blocked; error shown: "Cannot import during active session" |
| 150 | Language change blocked during session | Session active, language set to en | Try to change to es (Spanish) | Language change prevented; error shown: "Cannot change language during session" |

### Chain Summary UI (3)

Home screen displays chain overview.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 151 | Home screen shows all steps in selected mode | Walk Mode selected (5 steps) | View home screen | All 5 steps listed with names |
| 152 | Step timing shown | Step 0: 10s duration; Step 1: wait 30 min | View summary | Timing displayed (e.g., "10 seconds", "30 minutes") |
| 153 | Summary updates when mode changes | View Walk Mode summary, switch to Date Mode | Change mode selection | Summary refreshes to show Date Mode steps |

### Session Start Flow (3)

Prepare user for session with summary and destination options.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 154 | Trigger summary shown before session begins | Tap "Start Real Session" or "Start Simulation" | Session start button tapped | Full escalation chain displayed (all steps, timings, actions) |
| 155 | GPS destination prompt shown (skippable) | Session ready to start, GPS tracking enabled in AppDefaults | Session start flow shown | "Set destination?" dialog appears with "Skip" and "Set" buttons |
| 156 | Skipping destination does not block session start | GPS destination prompt shown | Tap "Skip" | Session starts immediately without destination set |

### Distress Trigger Confirmation (3)

5-second confirmation window on distress activation.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 157 | Distress trigger shows 5s confirmation window | Distress trigger activated (hardware panic or duress PIN) | Confirmation prompt shown | "Distress activated" with 5s countdown visible; "Cancel" button present |
| 158 | Cancel confirmation aborts distress chain | During 5s confirmation window | Tap "Cancel" button | Distress chain not fired, session continues at current step |
| 159 | Cancel requires PIN if configured | Distress trigger confirmed, sessionEndPinHash set | Tap "Cancel" in distress window | PIN prompt shown; cancellation requires correct PIN entry |

### Lenient vs Smart Validation (2)

Simulation allows missing resources; real sessions enforce validation.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 160 | Simulation starts despite missing contacts | isSimulation=true, chain has smsContact step, no contacts added | Start simulation | Simulation begins; SMS step logs as sim_blocked (no error) |
| 161 | Real session blocked when SMS/call steps AND zero contacts | isSimulation=false, chain has smsContact step, no contacts added | Try to start real session | Validation error shown: "SMS requires at least one emergency contact" |

### Simulation Loading (3)

Transition from home to simulation with smooth visual feedback.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 162 | Loading screen shown for exactly 1.5s | Start simulation | start → loading screen | Duration = 1500ms ± 50ms tolerance |
| 163 | Cannot be dismissed early by tap | Loading screen displayed | Tap screen | No-op, loading continues |
| 164 | Shows branding/simulation indicator | Loading screen | View loading screen | "SIMULATION" text or icon visible |

### Simulation Speed Bar (5)

User controls simulation speed via slider (1x–1000x).

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 165 | Speed bar updates engine speedMultiplier in real time | Speed slider at 1x | Drag to 5x | engine.speedMultiplier = 5.0 immediately |
| 166 | Maximum capped at 1000x | Speed bar, attempt to drag beyond max | Drag to 1500x | Capped at 1000x |
| 167 | 1000x: 1000s timer completes in 1s | speedMultiplier = 1000, 1000s wait timer | elapse 1s real time | Timer fires (1000s / 1000 = 1s) |
| 168 | Speed change mid-step applies to remaining time only | 10s duration, at 5s (5s remaining), speed changes from 1x → 5x | Change speed at 5s mark | Remaining 5s now takes 1s (5s / 5x) |
| 169 | Speed preserved across pause/resume | Speed 5x, session paused, resumed | pause, resume | Speed still 5x |

---

## Cross-Feature Interaction Tests (8 Cases)

Complex scenarios involving multiple features interacting.

| # | Test Case | Setup | Act | Assert |
|---|-----------|-------|-----|--------|
| 170 | **Stealth + Session End PIN**: 5 wrong Session End PINs trigger distress chain without revealing session screen (fake music player stays) | Stealth mode enabled, fake music player UI, sessionEndPinHash set, 5-attempt threshold | Enter 5 wrong PINs | Distress chain triggered, music player stays visible (no session screen shown), escalation happens invisibly |
| 171 | **Session End PIN + SMS retry**: wrong Session End PINs trigger distress chain while SMS queue drains — no race condition | sessionEndPinHash set, SMS queue pending | Enter wrong PIN (5th triggering distress chain), SMS sends simultaneously | Distress chain fires cleanly, SMS dequeued, no state corruption |
| 172 | **Fake lock screen + volume**: volume press suppressed, lock screen stays visible | Fake lock screen active, volume button detection enabled | Press volume button | Volume press handled, screen stays locked (no volume overlay) |
| 173 | **Speed bar + pause/resume**: speed change while paused applies on resume | Simulation, speed 1x, paused at step with 10s timer | Change speed to 5x while paused, resume | Remaining time reduced by new multiplier (paused duration / 5) |
| 174 | **Emergency countdown + pause**: countdown freezes during pause, exact remaining time preserved | callEmergency with 5s countdown, paused at 2s remaining | pause, wait 5s, resume | Countdown resumes with 2s remaining (not affected by pause duration) |
| 175 | **Validation + backup import**: importing contacts satisfies validation | Import JSON with 2 contacts, chain requires contacts, validation blocked | Import contacts via JSON, try start session again | Validation passes, session starts |
| 176 | **Distress hold + stealth notification**: distress fires, escalation uses stealth text | Stealth mode enabled, distress hold configured, decline button held 5s | Hold decline 5s during fakeCall in stealth mode | Distress chain fires, notifications use stealth disguised text (not "Guardian Angela") |
| 177 | **Non-blocking + session log**: failed events logged with failure status, not omitted | SMS fails, phoneCall succeeds, chain advances | Session log reviewed | Both events logged; SMS has status=failed, phoneCall has status=success |

---

## Priority Ordering & Implementation Phases

### Phase 1: P1 Safety-Critical Tests (Implement First)

Tests that verify core safety functionality and prevent catastrophic failures.

| Priority | Test # | Test Case | Rationale |
|----------|--------|-----------|-----------|
| P1 | 71 | 5 wrong Session End PINs trigger distress chain | Prevents lockout without escalation |
| P1 | 74a | Duress PIN silently fires distress chain | Core duress PIN safety guarantee |
| P1 | 89-90 | Distress hold boundary (5s vs 4.9s) | Prevents accidental distress triggers |
| P1 | 113-115 | Emergency countdown timing & boundary | Ensures emergency calls placed reliably |
| P1 | 174 | Emergency countdown + pause interaction | Ensures pause doesn't affect emergency timing |
| P1 | 61d-61e | Distress mode resolution (`distressModeId` → `AppDefaults.defaultDistressModeId`) | Correct distress chain must fire |

### Phase 2: P2 Data Integrity Tests

Tests that verify data is correctly captured, stored, and not corrupted.

| Priority | Test # | Test Case | Rationale |
|----------|--------|-----------|-----------|
| P2 | 99 | SMS queue persists across restart | Prevents duplicate or lost SMS |
| P2 | 142-144 | Backup import validation (malformed JSON, version check) | Prevents data corruption from bad imports |
| P2 | 62-68 | Session log creation and recording | Core audit trail for incidents |

### Phase 3: P3 Stealth/UX Tests

Tests for disguised UI features that prevent app detection.

| Priority | Test # | Test Case | Rationale |
|----------|--------|-----------|-----------|
| P3 | 79-83 | Fake lock screen behavior | Stealth mode usability |
| P3 | 84-88 | Fake music player behavior | Stealth mode usability |
| P3 | 170, 176 | Stealth + PIN/distress interactions | Complex stealth scenarios |
| P3 | 51-53 | Stealth mode notification/UI hiding | Prevents app detection in stealth |

### Phase 4: P4 All Remaining Tests

Comprehensive coverage of features, edge cases, and integration scenarios.

| Priority | Test # | Count | Categories |
|----------|--------|-------|------------|
| P4 | 1–50 | 50 | Core engine, realistic scenarios |
| P4 | 54–61f | 14+ | Data models (incl. distress modes, AppDefaults, ModeOverrides, EmergencyContact) |
| P4 | 69–74a, 75–78 | 8+ | PIN authentication (three-PIN model), pause/resume |
| P4 | 91–98, 100–158 | 60+ | Volume detection, alarm ramp, contact import, JSON backup, simulation, UI, etc. |

---

## Test Metrics & Coverage Goals

### Target Coverage

| Layer | Coverage Target | Tool | Measurement |
|-------|-----------------|------|-------------|
| **Unit (SessionEngine)** | ≥ 95% | `coverage` package | Line coverage of engine.dart |
| **Unit (Models)** | ≥ 90% | `coverage` package | Line coverage of models/ |
| **Unit (Repositories)** | ≥ 85% | `coverage` package | Line coverage of repositories/ |
| **Widget (Screens)** | ≥ 80% | Manual review | All critical UI paths tested |
| **Integration** | ≥ 70% | Manual review | All major user flows tested |
| **Overall** | ≥ 85% | `coverage` package | Whole codebase |

### Success Criteria

- **All P1 tests pass** (safety-critical)
- **≥ 95% of P1 + P2 tests pass** (data integrity)
- **All test categories have representative coverage** (unit, widget, integration)
- **No flaky tests** — all tests pass consistently without timing issues
- **Test performance**: full test suite runs in < 5 minutes on CI
- **No regression**: existing passing tests remain passing after code changes

---

## Test Execution & CI/CD Integration

### Local Test Execution

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/session/session_engine_test.dart

# Run with coverage
flutter test --coverage
lcov --list coverage/lcov.info

# Run tests matching pattern
flutter test --name "disarm"

# Run integration tests on emulator/device
flutter test integration_test/app_test.dart

# Run tests in parallel
pytest -s -n auto
```

### CI/CD Pipeline

**GitHub Actions workflow** (`.github/workflows/ci.yml`):

```yaml
test:
  name: Tests
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v2
    - uses: subosito/flutter-action@v2
    - run: flutter pub get
    - run: flutter pub run build_runner build
    - run: flutter test --coverage
    - uses: codecov/codecov-action@v3
      with:
        files: coverage/lcov.info
```

### Test Failure Triage

1. **Flaky test**: Rerun 3 times; if passes ≥ 2, investigate timing issues
2. **Real failure**: Identify root cause, fix code or test
3. **Environment issue**: Debug CI environment, dependencies, permissions
4. **Document**: Add comment to test explaining workaround or known issue

---

## Test Helpers & Utilities

### _FixedRandom Deterministic Randomizer

```dart
/// Fixed random for deterministic test: always returns 0.5.
class _FixedRandom extends Random {
  @override
  double nextDouble() => 0.5;

  @override
  int nextInt(int max) => max ~/ 2;
}
```

**Usage**: Pass to `SessionEngine` to eliminate jitter variation:
```dart
final engine = SessionEngine(
  chainSteps: testSteps,
  random: _FixedRandom(),
);
// Jitter factor: 0.8 + 0.5 * 0.4 = 1.0 (no jitter)
```

### _step() Factory Function

```dart
/// Create ChainStep with sensible test defaults.
ChainStep _step({
  required ChainStepType type,
  int waitSeconds = 0,
  int durationSeconds = 10,
  int gracePeriodSeconds = 5,
  int repeatCount = 0,
  bool randomize = false,
  Map<String, String>? config,
}) {
  return ChainStep(
    id: const Uuid().v4(),
    type: type,
    order: 0,
    waitSeconds: waitSeconds,
    durationSeconds: durationSeconds,
    gracePeriodSeconds: gracePeriodSeconds,
    repeatCount: repeatCount,
    randomize: randomize,
    config: config,
  );
}
```

**Usage**: Minimal test setup:
```dart
_step(type: ChainStepType.holdButton, durationSeconds: 10)
```

### Test Event Listener

```dart
/// Collect all events from engine for assertion.
final events = <ChainEventData>[];
engine.events.listen(events.add);
```

### fakeAsync Wrapper

```dart
test('duration countdown fires', () {
  fakeAsync((async) {
    final engine = SessionEngine(
      chainSteps: [_step(type: ChainStepType.loudAlarm)],
      random: _FixedRandom(),
    );

    engine.start();
    async.flushMicrotasks();

    async.elapse(const Duration(seconds: 10)); // duration
    async.elapse(const Duration(seconds: 5));  // grace

    // assertions...
  });
});
```

---

## Approaches & Methodology

### Test-Driven Development (TDD)

1. **Write test first** — describe expected behavior
2. **Test fails** — implementation not yet complete
3. **Implement code** — make test pass
4. **Refactor** — improve code quality, tests still pass
5. **Repeat** — next test

### AAA Pattern (Arrange-Act-Assert)

Every test follows this structure:

```dart
test('description', () {
  // Arrange: set up test data and engine
  final engine = SessionEngine(...);
  
  // Act: perform the action
  engine.start();
  async.elapse(...);
  
  // Assert: verify result
  expect(engine.currentStepIndex, 1);
});
```

### Tests as Documentation

Well-written tests serve as executable documentation. Test names describe *what* is being tested; comments explain *why* behavior is important.

```dart
test('holdButton: re-hold during grace resets to step 0', () {
  // During grace period (after countdown), user can re-hold and disarm.
  // This prevents escalation if user realizes they need to hold.
  // ...
});
```

### When Tests Fail

- **Red**: Test fails (code not yet implemented)
- **Green**: Test passes (code implemented)
- **Refactor**: Improve code while tests stay green
- **Investigate**: If test fails unexpectedly, understand root cause:
  - Is the test wrong (incorrect expectation)?
  - Is the code wrong (implementation bug)?
  - Is the spec unclear (both need updating)?

---

## Test Review Checklist

Before committing tests, verify:

- [ ] Test name clearly describes what is being tested
- [ ] Test is isolated (no dependencies on other tests)
- [ ] Arrange, Act, Assert sections clearly separated
- [ ] Assertions use descriptive matchers (from `package:checks`)
- [ ] No hardcoded delays (use `fakeAsync` for timers)
- [ ] No platform-specific code in unit tests
- [ ] Test passes consistently (run 3 times)
- [ ] Test fails when code is wrong (verify by breaking implementation)
- [ ] Comments explain *why*, not *what*
- [ ] Helper functions used for common setup

---

## Future Considerations

### Test Expansion

As new features are added:
- Add corresponding test cases to the test plan
- Maintain ≥ 85% overall coverage
- Update priority tiers if safety criticality changes
- Document rationale for any deferred tests

### Continuous Improvement

- **Test analytics**: Track which tests fail most often (signals fragile code)
- **Mutation testing**: Verify tests actually catch bugs (use `mutant` or similar)
- **Performance monitoring**: Track test suite duration and flag slowdowns
- **Code review**: Ensure all new code has test coverage before merge

---

## Summary

This test plan provides a comprehensive roadmap for validating Guardian Angela across all layers: pure engine logic, UI components, and end-to-end flows. Tests are prioritized by safety criticality and organized for efficient development.

**Key principles:**
- Safety first: P1 tests prevent catastrophic failures
- Data integrity: P2 tests ensure logs and backups are correct
- Usability: P3 & P4 tests cover UI, stealth, and advanced features
- Determinism: `_FixedRandom` and `fakeAsync` eliminate flakiness
- Documentation: Tests explain *why* behavior matters

**Target: 177 test cases with ≥ 85% code coverage, all P1 tests passing, no flaky tests.**

---

## Spec-to-Test Contract Table

This table maps all critical spec requirements to their corresponding test cases, ensuring comprehensive traceability and 100% coverage of safety-critical features.

### Session Engine Core (P1 - Safety Critical)

| Spec Requirement | Test Case | Test File | Priority |
|---|---|---|---|
| Hold button: brief release ignored (< sensitivity threshold) | TC-42 | session_engine_test.dart | P1 |
| Hold button: re-hold during grace triggers disarm | TC-15 | session_engine_test.dart | P1 |
| Disarm resets chain to step 0 and clears miss count | TC-7, TC-8 | session_engine_test.dart | P1 |
| Grace period expires without disarm: advance to next step | TC-5, TC-6 | session_engine_test.dart | P1 |
| Miss count increments on grace expiry | TC-12, TC-13 | session_engine_test.dart | P1 |
| retryCount: N retries = N+1 total attempts | TC-9, TC-10, TC-11 | session_engine_test.dart | P1 |
| Pause/resume preserves exact remaining time | TC-74 | session_engine_test.dart | P1 |
| Speed multiplier divides all durations | TC-18, TC-19 | session_engine_test.dart | P1 |
| Jitter: ±20% randomization on timing | TC-22, TC-23 | session_engine_test.dart | P1 |
| Fake call decline counts as miss | TC-49, TC-50 | fake_call_scenarios_test.dart | P1 |
| Fake call answer: chain pauses, disarm on hang-up | TC-47, TC-48 | fake_call_scenarios_test.dart | P1 |
| Real phone call detection auto-pauses session | TC-25 | session_engine_test.dart | P1 |
| chainExhausted emitted when last step grace expires | TC-4 | session_engine_test.dart | P1 |
| sessionEnded idempotent (safe to call multiple times) | TC-34, TC-35 | session_engine_test.dart | P1 |
| All 9 step types fire in order | TC-37 | integration_test.dart | P1 |

### Disguised Reminders (P1 - Safety Critical)

| Spec Requirement | Test Case | Test File | Priority |
|---|---|---|---|
| Disguised reminder: fires after waitSeconds | TC-9 | disguised_reminder_test.dart | P1 |
| Reminder fires again after grace if user misses | TC-10, TC-44 | disguised_reminder_test.dart | P1 |
| User confirms reminder during duration or grace: disarm | TC-8 | disguised_reminder_test.dart | P1 |
| retryCount misses trigger advance to next step | TC-11, TC-45 | disguised_reminder_test.dart | P1 |
| Template rotation avoids same template twice in a row | TC-58 | reminder_template_test.dart | P2 |

### Fake Call (P1 - Safety Critical)

| Spec Requirement | Test Case | Test File | Priority |
|---|---|---|---|
| Fake call: decline counts as miss toward retryCount | TC-49 | fake_call_scenarios_test.dart | P1 |
| Fake call decline: grace → re-ring | TC-48, TC-50 | fake_call_scenarios_test.dart | P1 |
| Fake call answer: chain pauses, disarm on hang-up | TC-47 | fake_call_scenarios_test.dart | P1 |
| Fake call: max retryCount rings before advancing | TC-49, TC-50, TC-51 | fake_call_scenarios_test.dart | P1 |

### Email/SMS Contact (P1 - Safety Critical)

| Spec Requirement | Test Case | Test File | Priority |
|---|---|---|---|
| SMS sends to all selected contacts | TC-52 | sms_contact_test.dart | P1 |
| SMS includes location when available | TC-53 | sms_contact_test.dart | P1 |
| SMS delivery retries indefinitely when offline | TC-54 | messaging_service_test.dart | P1 |
| Empty contact list: message says "owner of this phone" | TC-55 | sms_contact_test.dart | P2 |

### Phone Call Contact (P1 - Safety Critical)

| Spec Requirement | Test Case | Test File | Priority |
|---|---|---|---|
| Phone call contact auto-dials (Android) or shows dialog (iOS) | TC-56 | phone_call_test.dart | P1 |
| Pre-SMS before calling enabled by default | TC-57 | phone_call_test.dart | P1 |
| retryCount respects retry attempts | TC-58 | phone_call_test.dart | P1 |

### Emergency Call (P1 - Safety Critical)

| Spec Requirement | Test Case | Test File | Priority |
|---|---|---|---|
| Emergency call dials 112/911 (locale-aware) | TC-59 | emergency_call_test.dart | P1 |
| Emergency call shows 5s confirmation countdown (default) | TC-60 | emergency_call_test.dart | P1 |
| Emergency call confirmation can be disabled | TC-61 | emergency_call_test.dart | P2 |
| Emergency number: 80+ countries mapped | TC-62 | locale_test.dart | P2 |

### Loud Alarm (P1 - Safety Critical)

| Spec Requirement | Test Case | Test File | Priority |
|---|---|---|---|
| Loud alarm plays at max volume | TC-63 | loud_alarm_test.dart | P1 |
| Loud alarm always disarmable (no canDisarm=false option) | TC-64 | loud_alarm_test.dart | P1 |
| Gradual volume increase: linear ramp (configurable duration) | TC-65 | loud_alarm_test.dart | P2 |
| Camera flash SOS pattern plays (if enabled) | TC-66 | flash_service_test.dart | P2 |
| Screen flash: slow (1000ms, default) or fast (500ms) | TC-67 | screen_flash_test.dart | P2 |

### Countdown Warning (P1 - Safety Critical)

| Spec Requirement | Test Case | Test File | Priority |
|---|---|---|---|
| Countdown warning displays before escalation | TC-68 | countdown_warning_test.dart | P2 |
| Countdown warning vibration and optional sound | TC-69 | countdown_warning_test.dart | P2 |

### Session Modes & Chain Defaults (P1 - Safety Critical)

| Spec Requirement | Test Case | Test File | Priority |
|---|---|---|---|
| Walk Mode: holdButton check-in, escalates via fakeCall → alarm | TC-38 | walk_mode_integration_test.dart | P1 |
| Date Mode: disguisedReminder check-in, escalates via fakeCall → alarm | TC-43, TC-45 | date_mode_integration_test.dart | P1 |
| All steps have waitSeconds, durationSeconds, gracePeriodSeconds, retryCount | TC-56 | chain_step_test.dart | P1 |
| Timing defaults table: correct per event type | TC-54, TC-55 | event_defaults_test.dart | P1 |

### Mode Editor UI (P1 - User-Facing)

| Spec Requirement | Test Case | Test File | Priority |
|---|---|---|---|
| Duplicate step button copies step with all config | TC-70 | mode_editor_test.dart | P1 |
| Timing section collapsible in step editor | TC-71 | mode_editor_test.dart | P1 |
| Each step can be reordered by drag-and-drop | TC-72 | mode_editor_test.dart | P2 |

### Settings & Global Defaults (P2 - Configuration)

| Spec Requirement | Test Case | Test File | Priority |
|---|---|---|---|
| Event Defaults screen shows all 9 step types | TC-73 | settings_event_defaults_test.dart | P2 |
| Stealth mode hides progress bar, missed indicators, grace visuals | TC-51, TC-52, TC-53 | stealth_mode_test.dart | P2 |
| Stealth mode: exit silently on chain exhaustion | TC-51 | stealth_mode_test.dart | P2 |
| Stealth notification disguised (e.g., "Music playing") | TC-53 | stealth_mode_test.dart | P2 |

### Data Models (P2 - Persistence)

| Spec Requirement | Test Case | Test File | Priority |
|---|---|---|---|
| ChainStep field: retryCount (not repeatCount) | TC-54, TC-55, TC-56 | chain_step_test.dart | P1 |
| SessionMode: chainSteps ordered by order field | TC-74 | session_mode_test.dart | P2 |
| SessionLog: all events timestamped and categorized | TC-62, TC-63, TC-64, TC-65 | session_log_test.dart | P2 |
| Hive encryption always-on (no opt-out) | TC-75 | encryption_test.dart | P1 |
| Hive typeIds: 0–19 allocated, all unique | TC-61 | hive_schema_test.dart | P1 |

### Localization (P2 - User-Facing)

| Spec Requirement | Test Case | Test File | Priority |
|---|---|---|---|
| 14 languages: en, de, es, fr, ru, zh_CN, zh_TW, hi, fa, uk, pl, el, ar, he | TC-77 | localization_test.dart | P2 |
| Locale-aware emergency numbers: 80+ countries | TC-62 | locale_test.dart | P2 |
| ARB format strings correctly translated | TC-78 | translation_test.dart | P2 |
| Native speaker review completed per language | (manual verification) | (QA signoff) | P2 |

### Accessibility (P2 - Compliance)

| Spec Requirement | Test Case | Test File | Priority |
|---|---|---|---|
| Text contrast ≥ 4.5:1 (normal), ≥ 3:1 (large) | TC-79 | contrast_test.dart | P2 |
| Semantics labels on all interactive elements | TC-80 | semantics_test.dart | P2 |
| One-hand operation: all critical buttons in bottom third | TC-81 | button_position_test.dart | P2 |
| Font scaling: UI remains usable under 200% scaling | TC-82 | font_scaling_test.dart | P2 |

### Real Phone Call Detection (P1 - Safety Critical)

| Spec Requirement | Test Case | Test File | Priority |
|---|---|---|---|
| Real phone call pauses session automatically | TC-25 | real_call_detection_test.dart | P1 |
| Session resumes from exact point on call end | TC-26 | real_call_detection_test.dart | P1 |
| Android: PhoneStateListener implementation | TC-25 (Android) | platform_specific_test.dart | P1 |
| iOS: CXCallObserver implementation | TC-25 (iOS) | platform_specific_test.dart | P1 |

### Permissions & Onboarding (P1 - Critical)

| Spec Requirement | Test Case | Test File | Priority |
|---|---|---|---|
| Notification permission required upfront | TC-83 | onboarding_test.dart | P1 |
| SMS/call permissions checked before smsContact/callEmergency | TC-84, TC-85 | session_start_validation_test.dart | P1 |
| No emergency contacts → error dialog with "Add Contact" button | TC-86 | session_start_validation_test.dart | P1 |
| Whatsapp/Telegram not installed → error dialog | TC-87 | session_start_validation_test.dart | P1 |

### Integration Tests (P1 - End-to-End)

| Spec Requirement | Test Case | Test File | Priority |
|---|---|---|---|
| Onboarding → home → start session → escalate → end | TC-88 | onboarding_to_session_integration_test.dart | P1 |
| Walk mode: hold 5min, release, re-hold, hold 10min, end | TC-38 | walk_mode_integration_test.dart | P1 |
| Date mode: 3 reminders all confirmed → end clean | TC-43 | date_mode_integration_test.dart | P1 |
| Fake call: answer → disarm → reset to step 0 | TC-47 | fake_call_integration_test.dart | P1 |
| Simulation: 10x speed, leap button, summary shown | TC-89 | simulation_integration_test.dart | P1 |

### Platform-Specific (P1 - Critical)

| Spec Requirement | Test Case | Test File | Priority |
|---|---|---|---|
| Android: SMS auto-send via SmsManager | TC-52 (Android) | sms_service_test.dart | P1 |
| iOS: SMS opens Messages app (user taps Send) | TC-52 (iOS) | sms_service_test.dart | P1 |
| Android: Call auto-dials without confirmation | TC-56 (Android) | phone_call_test.dart | P1 |
| iOS: Call shows confirmation dialog (user taps) | TC-56 (iOS) | phone_call_test.dart | P1 |
| Android: Volume button detection | TC-90 | volume_button_test.dart | P1 (Android only) |

---

## Integration Test Scenarios

This section enumerates integration-level scenarios that exercise the
engine together with the orchestrator, fake services, and (where
relevant) Riverpod controllers. Unlike the unit tests that cover the
surface of individual classes, these scenarios drive a session from
`start()` through to a terminal state using `fakeAsync` to advance
time deterministically. Each scenario is identified by a stable
`INT-###` tag and lists the spec section / decision it exercises.

The existing `test/integration/**` tree is heavy on *structural*
coverage (API no-ops, JSON round-trips, phase mappings) but light on
end-to-end timer-driven flows. These scenarios close that gap.

### INT-001 — Walk Mode happy path (hold to completion)

- **Preconditions:** A Walk Mode chain with two steps
  (`holdButton(duration=5s, grace=3s)` → `smsContact(duration=5s,
  grace=3s)`). Real (non-simulation) engine with deterministic
  `FixedRandom`. Orchestrator wired with recording fakes for all
  services.
- **Actions (fakeAsync):**
  1. `engine.start()`.
  2. `engine.holdStart()` immediately after start.
  3. `async.elapse(Duration(seconds: 1))` (simulate user holding).
  4. `engine.disarm()` to check in.
- **Expected outcomes:**
  - Event stream contains `stepStarted` (for step 0), `userDisarmed`,
    then another `stepStarted` (for step 0 again — disarm resets).
  - `engine.currentStepIndex == 0` after disarm.
  - `FakeMessagingService.sentMessages` is empty (no SMS fired).
  - Orchestrator `cleanDisarm` is invoked exactly once.
- **Reference:** `01-chain-engine.md` §Hold button lifecycle;
  decision A5 (disarm cancels pending SMS).

### INT-002 — Walk Mode worst case (all check-ins missed → chain exhausted)

- **Preconditions:** A Walk Mode chain with `retryCount=0` on every
  step: `holdButton(dur=5s, grace=3s)` → `smsContact(dur=2s,
  grace=0s)` → `callEmergency(dur=2s, grace=0s)`. Real engine,
  `FixedRandom`.
- **Actions (fakeAsync):**
  1. `engine.start()` — user never holds the button.
  2. `async.elapse(Duration(seconds: 30))` — long enough that the
     hold-wait times out, all grace periods expire, and every step
     advances.
- **Expected outcomes:**
  - `repeatMissed` emitted for each missed check-in (step 0 then 1
    then 2).
  - `stepAdvancing` emitted twice (0→1, 1→2).
  - Terminal event is `chainExhausted`.
  - `engine.state is EngineEnded` with `reason == chainExhausted`.
  - Orchestrator attempted to execute the smsContact and
    callEmergency strategies (recording fakes show a call).
- **Reference:** `01-chain-engine.md` §Chain exhaustion;
  `02-event-types.md` §retry / grace semantics.

### INT-003 — Date Mode happy path (reminder confirmed each cycle)

- **Preconditions:** A Date Mode chain with a single
  `disguisedReminder(wait=10s, duration=5s, grace=5s, retryCount=2)`
  step followed by `smsContact`. Real engine, `FixedRandom`.
- **Actions (fakeAsync):**
  1. `engine.start()`.
  2. `async.elapse(Duration(seconds: 11))` — wait phase ends,
     `reminderFired` emitted.
  3. `engine.checkIn()` before grace expires.
  4. Repeat elapse + checkIn for two more cycles.
  5. Eventually `engine.endSession()` to finish cleanly.
- **Expected outcomes:**
  - `reminderFired` event observed once per cycle.
  - `userDisarmed` observed once per checkIn.
  - Chain never advances past step 0 (smsContact never fires).
  - `FakeMessagingService.sentMessages` is empty.
  - Terminal event is `sessionEnded` with `userTerminated` reason.
- **Reference:** `01-chain-engine.md` §Disguised reminder;
  decision D4 (early check-in behaviour).

### INT-004 — Date Mode worst case (all reminders missed → distress SMS)

- **Preconditions:** Date Mode chain
  `disguisedReminder(retryCount=1, wait=5s, dur=3s, grace=3s)` →
  `smsContact(dur=2s, grace=0s)` → `callEmergency(dur=2s, grace=0s)`.
  Real engine, `FixedRandom`.
- **Actions (fakeAsync):**
  1. `engine.start()`.
  2. `async.elapse(Duration(seconds: 40))` — user never checks in.
- **Expected outcomes:**
  - `reminderFired` emitted twice (initial + retry).
  - `repeatMissed` emitted twice on step 0.
  - Chain advances through both smsContact and callEmergency.
  - Terminal event is `chainExhausted`.
  - `FakePhoneService.calls` contains a `callEmergency` entry.
- **Reference:** `01-chain-engine.md` §Reminder retry;
  `02-event-types.md` §disguisedReminder.

### INT-005 — Distress fired via hardware panic (5× volume button)

- **Preconditions:** Engine running a Walk Mode chain. A
  `FakeHardwareButtonService` listening with
  `HardwareButtonDistressTrigger(RepeatPressTrigger(pressCount: 5))`.
  A distress chain of `smsContact → callEmergency`.
- **Actions:**
  1. `engine.start()`; user holds button (so the session is
     active).
  2. Subscribe controller-equivalent handler: on panic,
     `engine.replaceWithDistressChain(distressChain())`.
  3. `hw.simulatePanic()`.
  4. `async.elapse(Duration(seconds: 15))`.
- **Expected outcomes:**
  - `engine.isDistressChain == true` immediately after panic.
  - `engine.steps` is now the distress chain (smsContact first).
  - Terminal state is `EngineEnded(reason: hardwarePanic)`.
  - Stream emits `distressTriggered` (when the chain is replaced),
    later `distressCompleted`, and finally `sessionEnded` carrying
    `endReason: hardwarePanic`.
  - `FakeMessagingService` recorded one `sendToAll` or `sendMessage`.
  - `FakePhoneService` recorded one `callEmergency` with the
    configured number.
- **Reference:** decisions A3, B1, 64;
  `01-chain-engine.md` §Distress replacement.

### INT-006 — Duress PIN during active distress chain is a no-op (A4)

- **Preconditions:** Engine with the distress chain already running
  (via `replaceWithDistressChain`). `FakeMessagingService` +
  `FakePhoneService` recording calls.
- **Actions (fakeAsync):**
  1. Replace with distress chain + `async.elapse(Duration(seconds: 1))`
     so the first step is executing.
  2. Invoke `engine.replaceWithDistressChain(sameOrOtherDistressChain)`
     a second time (simulating duress PIN fire while distress is
     already active).
- **Expected outcomes:**
  - The engine's `isDistressChain` stays `true`.
  - No duplicate `sendToAll` / `callEmergency` is observed (the
    orchestrator must debounce re-entry).
  - Subsequent chain progression continues from the original
    distress chain.
- **Reference:** decision A4.

### INT-007 — Real call during countdown pauses & resumes exact remaining

- **Preconditions:** Walk Mode chain, step index 1 is a `smsContact`
  with `durationSeconds=30`. Real engine, `FixedRandom`. Wire
  `FakeIncomingCallService` or drive `engine.pause(incomingCall)` +
  `engine.resume()` directly.
- **Actions (fakeAsync):**
  1. Start + advance into step 1 duration phase.
  2. `async.elapse(Duration(seconds: 10))` (20s of duration remain).
  3. `engine.pause(reason: PauseReason.incomingCall)`.
  4. `async.elapse(Duration(seconds: 60))` (simulate a long call).
  5. `engine.resume()`.
  6. `async.elapse(Duration(seconds: 19))` — 1s should still be left.
- **Expected outcomes:**
  - `sessionPaused` event emitted with `incomingCall` reason.
  - `sessionResumed` emitted once after resume.
  - Chain has NOT advanced during pause (stepIndex unchanged).
  - After elapsing 19s, state is still `EngineRunning` for the same
    step (with `remaining` close to 1s).
  - After another 1s, the timer fires and the step either advances
    or enters grace, proving the remaining time was preserved.
- **Reference:** decisions A2, 31.

### INT-008 — Real call over fakeCall screen dismisses fake, resumes after

- **Preconditions:** Chain `holdButton → fakeCall(dur=30s,
  declineIsSafe=false)`. Controller-equivalent wiring:
  `engine.answerFakeCall()` on answer.
- **Actions (fakeAsync):**
  1. Progress to the fakeCall step.
  2. Before the user answers, fire a real-call signal:
     `engine.pause(reason: PauseReason.incomingCall)`.
  3. `async.elapse(Duration(seconds: 5))`.
  4. `engine.resume()`.
- **Expected outcomes:**
  - `sessionPaused` emitted with `incomingCall` reason.
  - After `resume()`, engine is back in `EngineRunning` on the
    fakeCall step.
  - `engine.isHolding == false` (hold state cleared).
  - `FakeMessagingService.sentMessages` is empty.
- **Reference:** decisions 29, 30.

### INT-009 — Simulation "Leap" compresses remaining time to ~1s

- **Preconditions:** Simulation engine with
  `smsContact(dur=30s, grace=10s)`. `speedMultiplier=1.0` (leap is
  the only time-compression).
- **Actions (fakeAsync):**
  1. `engine.start()`.
  2. `async.elapse(Duration(milliseconds: 100))` to ensure the
     duration phase has started.
  3. `engine.leapToNextEvent()`.
  4. `async.elapse(Duration(seconds: 2))`.
- **Expected outcomes:**
  - The duration phase's timer fires within ~1s real time.
  - Engine transitions to grace (or advances if grace=0).
  - No stale "30s remaining" leaks through `engine.state`.
- **Reference:** decision D2.

### INT-010 — SMS WorkManager IDs cancelled on disarm (A5)

- **Preconditions:** Chain that queues an SMS: `smsContact → callEmergency`.
  Real engine. Orchestrator wired with `FakeMessagingService`.
  `FakeMessagingService.sendMessage` returns a `MessageWorkId` which
  the orchestrator registers via `registerSmsWorkId`.
- **Actions (fakeAsync):**
  1. `engine.start()`.
  2. `async.elapse(Duration(seconds: 6))` so the smsContact strategy
     executes and returns a work ID.
  3. `engine.disarm()`.
  4. `await` orchestrator.cleanDisarm().
- **Expected outcomes:**
  - `FakeMessagingService.calls` contains at least one
    `sendMessage:*` entry.
  - After `cleanDisarm`, `calls` also contains
    `cancelPending:<n>` with the expected count.
- **Reference:** decision A5.

### Coverage matrix (scope list → existing vs. new)

| Scope scenario | Covered today? | New INT-### |
|---|---|---|
| Walk Mode happy path (hold → release → grace → SMS) | Partial (API no-ops) | **INT-001** |
| Walk Mode worst case (all miss) | Partial (sim lifecycle only) | **INT-002** |
| Date Mode happy path | No | **INT-003** |
| Date Mode worst case | No | **INT-004** |
| Distress via hardware panic (5× vol) | Structural only | **INT-005** |
| Duress PIN no-op during distress (A4) | No | **INT-006** |
| Real call → pause → resume (A2) | No | **INT-007** |
| Real call over fakeCall (29, 30) | No | **INT-008** |
| Simulation leap to next event (D2) | Partial | **INT-009** |
| Disarm cancels queued SMS (A5) | Partial (orchestrator cleanDisarm no-op) | **INT-010** |
| Distress via wrongPinThreshold (A3) | Settings round-trip only | (future) |
| Crash recovery dialog (Extra 13) | No | (future, requires Hive) |
| Smart retention (B8) | No | (future) |
| Soft-delete log (Extra 11) | No | (future) |
| Onboarding full flow | No | (future, widget-level) |
| Language switch instant rebuild (43) | No | (future, widget-level) |

---

**Document Status:** Complete test plan with comprehensive traceability ready for implementation  
**Last Updated:** 2026-04-14  
**Next Steps:** Implement Phase 1 (P1) tests first, then Phase 2–4 in parallel
