# Event Type Lifecycles

Each event type's state machine showing phases, transitions, and user interactions.

---

## 1. holdButton (Check-in)

```mermaid
stateDiagram-v2
    [*] --> HoldWait: start()
    HoldWait --> Holding: holdStart()
    HoldWait --> HoldWait: (waiting for touch)

    Holding --> Holding: (user holds continuously)
    Holding --> SensitivityDelay: holdRelease()

    SensitivityDelay --> Holding: holdStart()\n(brief lift ignored)
    SensitivityDelay --> GraceCountdown: sensitivity expires\n(default 1.0s)

    GraceCountdown --> Disarmed: holdStart()\n(re-hold = disarm)
    GraceCountdown --> Advance: grace expires\n(default 5s)

    Disarmed --> HoldWait: reset to step 0
    Advance --> [*]: advance to next step

    note right of SensitivityDelay
        Ignores releases shorter
        than releaseSensitivity
        (0.3-3.0s, default 1.0s)
    end note

    note right of GraceCountdown
        UI: countdown timer visible
        Haptic feedback on release
        Sound optional (default off)
    end note
```

**Timing:** wait=0, duration=10s (countdown), grace=5s | **Disarm:** re-hold | **Real action:** none (UI-only)

---

## 2. disguisedReminder (Check-in)

```mermaid
stateDiagram-v2
    [*] --> WaitInterval: start()

    WaitInterval --> ReminderVisible: wait expires\n(default 30min)\nemit reminderFired
    
    ReminderVisible --> Disarmed: user interacts\n(tapButton/tapWord/\nswipe/dismiss)
    ReminderVisible --> GracePeriod: duration expires\n(default 60s)

    GracePeriod --> Disarmed: user interacts
    GracePeriod --> MissCheck: grace expires\n(default 5s)

    MissCheck --> RetryImmediate: missCount <= retryCount\nemit repeatMissed
    MissCheck --> Advance: missCount > retryCount\nemit stepAdvancing

    RetryImmediate --> ReminderVisible: IMMEDIATE retry\n(skip wait!)\nemit reminderFired

    Disarmed --> WaitInterval: reset to step 0\n(full wait restarts)

    Advance --> [*]: advance to next step

    note right of RetryImmediate
        CRITICAL FIX:
        After miss, retry fires
        IMMEDIATELY (no 30min wait).
        Full wait only between
        CONFIRMED check-ins.
    end note

    note left of WaitInterval
        ±20% jitter if
        randomize=true
    end note
```

**Timing:** wait=1800s (30min), duration=60s, grace=5s, retry=3 | **Disarm:** interact with overlay | **Real action:** none (UI-only)

---

## 3. hardwareButton (Panic Trigger)

```mermaid
stateDiagram-v2
    [*] --> Listening: start()

    Listening --> PatternDetected: volume button\npattern matched

    PatternDetected --> JumpToTarget: targetStepIndex >= 0
    PatternDetected --> AdvanceNext: targetStepIndex == -1

    JumpToTarget --> [*]: jumpToStep(target)\n(NOT disarm — escalates)
    AdvanceNext --> [*]: advanceFromHardwarePanic()\n(NOT disarm — escalates)

    note right of Listening
        Android only (iOS greyed out)
        Patterns:
        - repeatPress: 3 presses in 500ms
        - longPress: 2s sustained hold
        Volume HUD suppressed
    end note

    note right of PatternDetected
        Does NOT trigger disarm().
        Escalates instead of
        confirming safety.
    end note
```

**Timing:** wait=0, duration=0, grace=0 | **No disarm** — this is an escalation trigger | **Real action:** none (platform key detection)

---

## 4. countdownWarning

```mermaid
stateDiagram-v2
    [*] --> Duration: start()\n(wait=0, fires immediately)

    Duration --> Disarmed: user swipes\n"I'm Safe" slider
    Duration --> GracePeriod: countdown expires\n(default 10s)

    GracePeriod --> Disarmed: user swipes
    GracePeriod --> Advance: grace expires\n(default 3s)

    Disarmed --> [*]: reset to step 0
    Advance --> [*]: advance to next step

    note right of Duration
        UI: fullScreen/notification/discrete
        Vibration pattern (default on)
        Warning sound (default off)
    end note
```

**Timing:** wait=0, duration=10s, grace=3s | **Disarm:** swipe slider | **Real action:** vibration + optional sound

---

## 5. fakeCall

```mermaid
stateDiagram-v2
    [*] --> Ringing: start()\nemit stepStarted\n(wake screen, show call UI)

    Ringing --> Answered: user taps Answer
    Ringing --> Declined: user taps Decline\nor ring timer expires

    Answered --> InCall: voice plays\n(earpiece default)
    InCall --> Disarmed: user hangs up\nemit userDisarmed

    Declined --> GracePeriod: declineIsSafe=true:\ncount as disarm
    Declined --> MissCheck: declineIsSafe=false:\ncount as miss

    GracePeriod --> Disarmed: (disarm fires)
    MissCheck --> RetryOrAdvance: check retryCount

    Disarmed --> [*]: reset to step 0

    RetryOrAdvance --> Ringing: retry available\n(rings again)
    RetryOrAdvance --> Advance: retries exhausted

    Advance --> [*]: advance to next step

    note right of Ringing
        Call styles: android/ios/
        whatsapp/telegram/signal
        Caller: "Angela" (default)
        Ring: 30s default
        Vibration: matches OS
    end note

    note left of Answered
        Disarm on HANG UP,
        not on answer.
        Chain pauses while
        user is "on the call".
    end note
```

**Timing:** wait=0, duration=30s (ring), grace=5s, retry=2 | **Disarm:** answer then hang up (or decline if declineIsSafe=true) | **Real action:** none (UI-only fake call screen)

---

## 6. smsContact

```mermaid
stateDiagram-v2
    [*] --> Executing: start()\n(wait=0, fires immediately)

    Executing --> SendToContacts: strategy.executeReal()

    SendToContacts --> Sent: all contacts attempted
    SendToContacts --> Queued: no signal\n(WorkManager retry)
    SendToContacts --> Failed: permission denied\nor invalid number

    Sent --> GracePeriod: duration timer runs\n(default 15s)
    Queued --> GracePeriod: non-blocking\nchain continues
    Failed --> GracePeriod: logged, chain continues

    GracePeriod --> Disarmed: user swipes\n"I'm Safe"
    GracePeriod --> Advance: grace expires\n(default 5s)

    Disarmed --> [*]: reset to step 0
    Advance --> [*]: advance to next step

    note right of SendToContacts
        Message template with placeholders:
        {name}, {location}, {time}, {description}
        
        Channels: SMS / WhatsApp / Telegram
        Android SMS: auto-send
        iOS SMS: user must press Send!
        
        Auto-record audio: optional
    end note

    note right of Queued
        Android: WorkManager retry queue
        iOS: NO retry (documented gap)
        Log: "sms_queued" vs "sms_sent"
    end note
```

**Timing:** wait=0, duration=15s, grace=5s | **Disarm:** swipe slider | **Real action:** MessagingService.sendToAll()

---

## 7. phoneCallContact

```mermaid
stateDiagram-v2
    [*] --> PreSMS: start()\npreSendSms=true (default)

    PreSMS --> Dialing: SMS sent\n(or skipped if false)
    PreSMS --> Dialing: SMS failed\n(call proceeds anyway)

    Dialing --> CallActive: PhoneService.call()
    CallActive --> WaitForAnswer: duration timer runs\n(default 60s)

    WaitForAnswer --> GracePeriod: duration expires\n(can't detect answer)
    WaitForAnswer --> Disarmed: user swipes\n"I'm Safe"

    GracePeriod --> RetryCheck: grace expires (5s)
    GracePeriod --> Disarmed: user swipes

    RetryCheck --> Dialing: retry available\n(try same or alt contact)
    RetryCheck --> Advance: all retries +\nalternatives exhausted

    Disarmed --> [*]: reset to step 0
    Advance --> [*]: advance to next step

    note right of Dialing
        Primary contact first,
        then alternativeContactIds
        in order.
        
        Can't detect if answered
        (platform limitation).
    end note
```

**Timing:** wait=0, duration=60s, grace=5s, retry=1 | **Disarm:** swipe slider | **Real action:** PhoneService.call() + optional pre-SMS

---

## 8. loudAlarm

```mermaid
stateDiagram-v2
    [*] --> AlarmPlaying: start()\n(wait=0, fires immediately)

    AlarmPlaying --> AlarmPlaying: volume ramping\n(0→max over 10s)
    AlarmPlaying --> GracePeriod: duration expires\n(default 30s)

    GracePeriod --> Disarmed: user swipes\n"I'm Safe"
    GracePeriod --> Advance: grace expires\n(default 5s)

    AlarmPlaying --> Disarmed: user swipes\n"I'm Safe"\n(always disarmable)

    Disarmed --> [*]: reset to step 0\nstop audio + vibration
    Advance --> [*]: advance to next step

    note right of AlarmPlaying
        Audio: siren/beep/custom
        Volume: gradual ramp (default 10s)
        Vibration: continuous strong pulsing
        Override silent mode: YES
        
        Optional:
        - Camera flash (SOS morse)
        - Screen flash (white/red)
        - Photosensitivity warning
    end note
```

**Timing:** wait=0, duration=30s, grace=5s | **Disarm:** always disarmable (swipe slider) | **Real action:** AudioService + VibrationService + optional FlashService

---

## 9. callEmergency

```mermaid
stateDiagram-v2
    [*] --> Confirmation: start()\nshowConfirmation=true (default)

    Confirmation --> PreSMS: countdown expires (5s)\nor user confirms
    Confirmation --> Disarmed: user cancels

    PreSMS --> Dialing: sendLocationSmsFirst\n(SMS with location to contacts)
    PreSMS --> Dialing: SMS skipped or failed

    Dialing --> CallActive: PhoneService.callEmergency()\n(112/911/locale)

    CallActive --> Done: duration expires\n(default 5s)

    Done --> Advance: grace=0\nadvance immediately

    Disarmed --> [*]: reset to step 0
    Advance --> [*]: advance to next step\nor chainExhausted

    note right of Confirmation
        Configurable (default ON):
        5s countdown before dialing
        Last chance to cancel
        
        Android: auto-dial (CALL_PHONE)
        iOS: confirmation dialog required
    end note

    note right of Dialing
        NOT necessarily terminal.
        Steps can follow callEmergency.
        "I'm okay" disarm still works.
    end note
```

**Timing:** wait=0, duration=5s, grace=0 | **Disarm:** cancel during confirmation | **Real action:** PhoneService.callEmergency() + optional pre-SMS

---

## Universal Phase Model

All steps share this three-phase timing model:

```mermaid
flowchart LR
    W["Wait Phase\n(waitSeconds)"] --> D["Duration Phase\n(durationSeconds)"]
    D --> G["Grace Phase\n(gracePeriodSeconds)"]
    G --> Check{miss ≤\nretryCount?}
    Check -->|yes, confirmed| W2["Reset to Wait\n(full interval)"]
    Check -->|yes, missed| R["IMMEDIATE Retry\n(skip wait!)"]
    Check -->|no, exceeded| A["Advance to\nnext step"]
    R --> D
    
    style R fill:#ff6b6b,color:#fff
    style A fill:#ff6b6b,color:#fff
    style W2 fill:#4ecdc4,color:#fff
```
