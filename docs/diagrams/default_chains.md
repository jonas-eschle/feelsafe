# Default Escalation Chains

## Walk Mode — Hold Button Check-in

```mermaid
flowchart TD
    Start([Session Start]) --> S0

    subgraph S0["Step 0: holdButton"]
        direction TB
        H0[User holds screen] --> R0{Released?}
        R0 -->|< 1s| H0
        R0 -->|≥ 1s| G0[Grace: 5s countdown]
        G0 -->|re-hold| H0
    end

    S0 -->|grace expires| S1

    subgraph S1["Step 1: fakeCall (retry=2, 3 rings max)"]
        direction TB
        Ring1["Ring 1: 30s\n(caller: Angela)"] --> Miss1{Answered?}
        Miss1 -->|answer + hangup| Disarm1[Disarm → step 0]
        Miss1 -->|no answer| Ring2["Ring 2: 30s\n(immediate retry)"]
        Ring2 --> Miss2{Answered?}
        Miss2 -->|answer + hangup| Disarm1
        Miss2 -->|no answer| Ring3["Ring 3: 30s\n(immediate retry)"]
        Ring3 --> Miss3{Answered?}
        Miss3 -->|answer + hangup| Disarm1
        Miss3 -->|no answer| Advance1[3 misses → advance]
    end

    S1 -->|3 misses| S2

    subgraph S2["Step 2: smsContact"]
        direction TB
        SMS["Send SMS to ALL contacts\nwith GPS location\n(15s send window)"] --> G2[Grace: 5s]
    end

    S2 -->|grace expires| S3

    subgraph S3["Step 3: callEmergency"]
        direction TB
        Confirm["Confirmation: 5s countdown\n(cancel = disarm)"] --> Call["Call 112/911\n(auto-dial on Android)"]
    end

    S3 -->|complete| End([Chain Exhausted\n→ Session Ended])

    style S0 fill:#4ecdc4,color:#000
    style S1 fill:#ffb74d,color:#000
    style S2 fill:#ff7043,color:#fff
    style S3 fill:#ef5350,color:#fff
    style End fill:#b71c1c,color:#fff
```

### Walk Mode Timeline (worst case, no user response)

```
T+0s      User releases phone
T+1s      Sensitivity delay (1s)
T+6s      Grace expires (5s)  ─── ESCALATION BEGINS ───
T+6s      Fake call #1 starts ringing (30s)
T+41s     Fake call #1 missed (30s ring + 5s grace)
T+41s     Fake call #2 starts immediately
T+76s     Fake call #2 missed
T+76s     Fake call #3 starts immediately
T+111s    Fake call #3 missed → advance to SMS
T+111s    SMS sends to all contacts with GPS
T+131s    SMS step completes (15s + 5s grace)
T+131s    Emergency call confirmation (5s)
T+136s    112/911 dialed

Total: ~2 minutes 16 seconds from phone drop to emergency call
```

---

## Date Mode — Disguised Reminder Check-in

```mermaid
flowchart TD
    Start([Session Start]) --> S0

    subgraph S0["Step 0: disguisedReminder (retry=3)"]
        direction TB
        Wait["Wait 30 min\n(±20% jitter: 24-36 min)"] --> Fire["reminderFired\n(disguised notification)"]
        Fire --> Vis["Visible 60s\n(Calendar/Duolingo/etc)"]
        Vis -->|user interacts| Safe["✓ Disarm\n→ restart 30min wait"]
        Vis -->|no interaction| Grace["Grace: 5s"]
        Grace -->|user interacts| Safe
        Grace -->|expires| Miss["Miss #N\nemit repeatMissed"]
        Miss -->|miss ≤ 3| Retry["IMMEDIATE retry\n(no 30min wait!)"]
        Retry --> Fire
        Miss -->|miss > 3| Advance["4 total misses\n→ advance"]
        Safe --> Wait
    end

    S0 -->|4 misses| S1

    subgraph S1["Step 1: fakeCall (retry=2)"]
        direction TB
        Ring1B["Ring: 30s"] --> Miss1B{Response?}
        Miss1B -->|answer| Disarm1B[Disarm → step 0]
        Miss1B -->|miss| Ring2B["Retry ring: 30s"]
        Ring2B --> Miss2B{Response?}
        Miss2B -->|answer| Disarm1B
        Miss2B -->|miss| Ring3B["Retry ring: 30s"]
        Ring3B --> AdvB[3 misses → advance]
    end

    S1 -->|3 misses| S2

    subgraph S2["Step 2: smsContact"]
        direction TB
        SMSB["Send SMS to ALL contacts\n+ GPS location"] --> G2B[Grace: 5s]
    end

    S2 -->|grace expires| S3

    subgraph S3["Step 3: callEmergency"]
        direction TB
        ConfirmB["5s confirmation"] --> CallB["Call 112/911"]
    end

    S3 -->|complete| End([Chain Exhausted])

    style S0 fill:#4ecdc4,color:#000
    style S1 fill:#ffb74d,color:#000
    style S2 fill:#ff7043,color:#fff
    style S3 fill:#ef5350,color:#fff
```

### Date Mode Timeline (user stops responding after T+30min)

```
T+0min     Session starts, 30min wait begins
T+30min    Reminder #1 fires (user confirms) → restart wait
T+60min    Reminder #2 fires (user confirms) → restart wait
T+90min    Reminder #3 fires ─── USER INCAPACITATED ───
T+91min    Reminder #3 missed (60s duration + 5s grace)

           ┌─── NEW BEHAVIOR: retries fire IMMEDIATELY ───┐
T+91min    Retry #1 fires immediately (no 30min wait!)
T+92min    Retry #1 missed (65s)
T+93min    Retry #2 fires immediately
T+94min    Retry #2 missed (65s)
T+95min    Retry #3 fires immediately
T+96min    Retry #3 missed → 4 total misses → ADVANCE
           └──────────────────────────────────────────────┘

T+96min    Fake call #1 starts ringing
T+97.5min  Fake call #1 missed (30s + 5s)
T+97.5min  Fake call #2 immediately
T+99min    Fake call #2 missed
T+99min    Fake call #3 immediately
T+100.5min Fake call #3 missed → advance to SMS
T+100.5min SMS sends to all contacts with GPS
T+101min   SMS completes → advance to emergency
T+101min   Emergency call confirmation (5s)
T+101.1min 112/911 dialed

From incapacitation (T+91min) to emergency call: ~10 minutes
OLD BEHAVIOR would have been: ~93 minutes (!)
```

---

## Sub-Chains

### Duress Chain (triggered by duress PIN)

```mermaid
flowchart LR
    Trigger["Duress PIN\nentered"] --> Pause["Pause main\nchain"]
    Pause --> Fake["Show fake\n'Session ended'\nscreen"]
    Fake --> SMS["SMS to ALL\ncontacts\n(15s)"]
    SMS --> Call["Call emergency\nservices\n(5s)"]
    Call --> Resume["Resume main\nchain silently"]

    style Trigger fill:#9c27b0,color:#fff
    style Fake fill:#ff9800,color:#000
    style SMS fill:#ff7043,color:#fff
    style Call fill:#ef5350,color:#fff
```

### Battery Alert Chain (triggered at threshold %)

```mermaid
flowchart LR
    Trigger["Battery drops\nbelow threshold\n(default 10%)"] --> Pause["Pause main\nchain"]
    Pause --> SMS["SMS to contacts:\n'Battery low at N%,\nlast location: ...'"]
    SMS --> Resume["Resume main\nchain"]

    style Trigger fill:#ff9800,color:#000
    style SMS fill:#ff7043,color:#fff
```

### Wrong PIN Chain (triggered after N wrong attempts)

```mermaid
flowchart LR
    Trigger["5 wrong PIN\nattempts"] --> Dialog["Deceptive dialog:\n'Old pin entered —\nare you sure?'"]
    Dialog --> Fire["Chain fires\nSILENTLY\n(regardless of\nbutton pressed)"]
    Fire --> Vibrate["Vibration\nalert"]
    Vibrate --> SMS["SMS to\ncontacts"]
    SMS --> Reset["Reset wrong\nPIN counter"]

    style Trigger fill:#f44336,color:#fff
    style Dialog fill:#ff9800,color:#000
    style Fire fill:#ff7043,color:#fff
```

---

## Chain Comparison

```
                    Walk Mode                     Date Mode
                    ─────────                     ─────────
Check-in:           Hold screen                   Respond to notification
Interval:           Continuous                    Every 30 min
Misses to escalate: 1 (immediate)                 4 (with immediate retries)
First escalation:   ~6s after release             ~5min after first miss
Emergency call:     ~2min 16s                     ~10min from incapacitation
Best for:           Walking home alone            On a date, at a bar
Hands:              One hand on phone             Phone in pocket/bag
```
