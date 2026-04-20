# Guardian Angela — Test Strategy

## 1. Executive summary

This document defines the test strategy for Guardian Angela, a
safety-critical Flutter dead-man's-switch app. It (a) inventories the
current suite, (b) defines the target test pyramid for the rebuilt
Riverpod + GoRouter + Drift (encrypted SQLite) app, (c) catalogs
required test categories and why each mitigates a concrete safety
risk, (d) lists concrete `TEST-###` scenarios to add, and (e) proposes
tooling, CI policy, and coverage targets. Sections 2–4 describe
current state, 5–7 drive implementation, and 8–11 capture policy and
open decisions. The coverage policy has been ratcheted to
**99%+ per layer, strive for 100%** (see §9); end-to-end uses
**patrol + Maestro + Appium combined** (see §7.4); and golden tests
are **full-coverage for every widget** (see §7.3).

Guiding principle: **the suite exists to prove the engine never fails a
user in distress, and never escalates a user who is safe.** Everything
else is secondary.

---

## 2. Current test inventory

Snapshot of `/home/jonas/Documents/software/android/safetyapp1/safewayhome/test/`:

- **Test files:** 180 `*_test.dart` files
- **Individual test cases:** ~3,405 `test(...)` calls + ~426 `testWidgets(...)` calls ≈ 3,830 cases

### 2.1 Distribution by directory

| Directory | Files | Primary layer | Strength |
|---|---|---|---|
| `test/domain/engine/` | 13 | Unit (pure Dart engine) | **Very strong** — state machine + timing fully covered with `fakeAsync` |
| `test/domain/engine/scenarios/` | 9 | Unit (scenario-level) | Strong — per-mode and per-feature scenario coverage |
| `test/domain/models/` | 16 | Unit (model) | Very strong — round-trip, copyWith, immutability |
| `test/domain/models/matrix/` | 10 | Unit (matrix combinatorics) | Strong — per-step-type config matrices |
| `test/domain/models/combinations/` | 8 | Unit (cross-model) | Strong — nested overrides, full-snapshot |
| `test/domain/models/edge_cases/` | 9 | Unit (boundary) | Strong |
| `test/domain/orchestration/strategies/` | 9 | Unit (strategy pattern, one per step type) | Strong — real vs simulation branches both tested |
| `test/data/` | 6 | Unit (JSON repositories) | Adequate |
| `test/integration/` | 21 | Integration (engine + orchestrator + fakes) | Strong — `INT-001…INT-010` end-to-end flows |
| `test/integration/scenarios/` | 7 | Integration (feature-level flows) | Adequate |
| `test/features/settings/` | 15 | Widget + controller | **Weakest widget area** — many brittle on provider scope |
| `test/features/session/` | 8 | Widget + controller | Controller-heavy, widget coverage thin |
| `test/features/history/` | 6 | Widget + controller | Adequate (session_log bug was found *after* users reported it) |
| `test/features/modes/`, `contacts/`, `onboarding/`, `templates/`, `profile/`, `home/`, `fake_call/` | 16 total | Widget + controller | Uneven; onboarding and home particularly thin |
| `test/core/widgets/` | 6 | Widget (shared) | Good for `PinKeypad`, `SwipeSlider`, `LogarithmicSlider` |
| `test/core/accessibility_test.dart`, `rtl_layout_test.dart` | 2 | Widget (a11y) | **Limited** — only spot checks |
| `test/property/` | 4 | Property/fuzz | Present but narrow |
| `test/regression/` | 4 | Regression + spec-compliance | `spec_compliance_test.dart` and `spec_defaults_test.dart` anchor normative spec |
| `test/services/` | 5 + `simulation/` | Unit (service protocols) | Adequate |
| `test/wiring/wiring_contract_test.dart` | 1 | Integration (DI graph) | **Critical** — ensures every provider + every strategy resolves |
| `test/router/app_router_test.dart` | 1 | Widget (routing) | Basic — only smoke |
| `test/helpers/` | 2 | Shared fixtures (`FixedRandom`, `step()`, harness builders) | Excellent pattern |

### 2.2 Strengths

- `SessionEngine` is pure Dart, driven by `fakeAsync`, and tested with
  `FixedRandom` (returns 0.5, cancels ±20% jitter). Timing is reproducible.
- `EventStrategy` pattern is exhaustively covered per step type with both
  `executeReal` and `simulationDescription` branches.
- Wiring contract (`test/wiring/wiring_contract_test.dart`) catches missing
  providers at compile/resolve time.
- Property tests exist for JSON round-trip, chain ordering, contact
  validation, and timing bounds — rare for a Flutter app.

### 2.3 Weaknesses (historical misses)

- **Widget tests requiring live Hive or full `ProviderScope`** repeatedly
  break when models or providers change (Team B rewrite should bias toward
  fake-backed controllers rather than real repositories in widget tests).
- **Session log filtering + trash bug** (reported by users) — controller
  and repository tests were green but no scenario covered the exact query
  path. This is a **false-negative gap**.
- **Emergency-number override bug** — `AppDefaults` vs `ModeOverrides`
  resolution path had tests for each in isolation but no end-to-end check
  "session uses the override I configured".
- No golden/visual-regression tests. Stealth UI (fake lock screen, fake
  music player) must *not* leak safety branding; a single text label change
  could defeat stealth silently.
- No CI-enforced localization completeness: missing keys surface as
  `app_en.arb` fallback at runtime, not at build time.
- No load / performance tests; no crash-recovery smoke test (Extra 13 in
  the spec).
- Accessibility is covered only by `test/core/accessibility_test.dart` and
  `test/core/rtl_layout_test.dart`; neither sweeps all screens at font
  scale 2.0 or in RTL.
- `spec_compliance_test.dart` hard-codes `4789` baseline counts that drift
  with every feature — reviewed below as an anti-pattern.

---

## 3. Test pyramid for this app

The coverage target is **99%+ per layer** (see §9). At that target the
unit base grows substantially relative to higher-cost layers, because
99% line coverage on engine + models + strategies + controllers is
only reachable through deep unit-level case splits. E2E still stays
proportionally small in count (integration tests are the most
expensive per scenario) but **every flow** must have end-to-end
coverage — nothing optional. Golden tests expand from
"critical-only" to **full coverage for every widget** (see §7.3).

```
              ┌───────────────────────┐
              │  Platform / E2E       │  ~3%  (every flow, real device,
              │  (patrol + Maestro +  │         patrol + Maestro + Appium)
              │   Appium, combined)   │
              ├───────────────────────┤
              │  Integration (engine  │  ~10%
              │  + orchestrator +     │
              │  fake services +      │
              │  Drift in-memory)     │
              ├───────────────────────┤
              │   UI flow / widget    │  ~12%
              ├───────────────────────┤
              │  Controller (Riverpod │  ~10%
              │  with fake services)  │
              ├───────────────────────┤
              │    Unit (engine,      │  ~55%
              │    models, strategies,│
              │    services-protocol, │
              │    Drift repos)       │
              ├───────────────────────┤
              │  Property + Golden    │  ~10%  (golden is FULL widget
              │  (golden = every      │          coverage, not spot-checks)
              │  widget)              │
              └───────────────────────┘
```

| Layer | Scope | Examples | Tools | Proportion | Target |
|---|---|---|---|---|---|
| **Unit — Engine** | `SessionEngine` state transitions, timing, jitter, distress replacement | `test/domain/engine/engine_timing_test.dart`, `session_engine_test.dart` | `package:test`, `fake_async`, `FixedRandom`, `checks` | ~14% | 100% |
| **Unit — Models** | `toJson`/`fromJson`, `copyWith`, equality, defaults, sealed-class exhaustiveness | `test/domain/models/chain_step_test.dart`, `step_config_test.dart` | `package:test`, `checks` | ~14% | 100% |
| **Unit — Strategies** | Each `EventStrategy.executeReal`/`simulationDescription`; MessageChannel fan-out | `test/domain/orchestration/strategies/sms_contact_strategy_test.dart` | `package:test`, fake services | ~13% | 100% |
| **Unit — Services (protocol)** | `*_service_protocol.dart` fakes obey contracts; retry/fallback logic | `test/services/sms_retry_exhausted_test.dart`, `audio_service_tts_fallback_test.dart` | `package:test`, `mocktail` only where needed | ~9% | 99% |
| **Unit — Drift repositories** | Typed query correctness, migration steps (each version bump), encryption at rest | `test/data/db/session_log_dao_test.dart`, `test/data/db/migrations/` | `package:test`, `NativeDatabase.memory()`, SQLCipher test vector | ~5% | 99% |
| **Controller** | Riverpod `Notifier`s with fake services and fake repos | `test/features/session/session_controller_test.dart` | `flutter_test`, `ProviderContainer`, `overrideWith` | ~10% | 99% |
| **Widget** | Single screens/widgets with controller overrides | `test/features/settings/pin_setup_screen_test.dart`, `test/core/widgets/pin_keypad_test.dart` | `flutter_test`, `WidgetTester` | ~12% | 99% |
| **Integration** | Engine + orchestrator + fakes; persistence through Drift in-memory | `test/integration/end_to_end_flows_test.dart` (INT-001…INT-010) | `flutter_test`, `fake_async`, Drift `NativeDatabase.memory()` | ~10% | — (scenario coverage, not line-coverage) |
| **Platform / E2E** | Real device smoke (SMS permissions, foreground service, CallKit, boot persistence, panic triggers, widget taps) | `integration_test/` + `test_driver/maestro/*.yaml` + `test_driver/appium/*.py` | `patrol`, `Maestro`, `Appium` — combined | ~3% | every documented flow |
| **Golden** | **Every widget** in `lib/features/**` and `lib/core/widgets/**`, across light/dark/RTL/font-scale on pinned device sizes | `test/goldens/**` | `golden_toolkit` | ~10% | every widget |
| **Property / fuzz** | JSON round-trip on generated models, chain ordering invariants, timing bounds, Drift schema fuzz | `test/property/json_round_trip_property_test.dart` | `package:test`, hand-rolled generators | ~2% | — |
| **Performance** | Engine event loop under speed multiplier 1000x; session-log write throughput; Drift query latency | *missing* | `benchmark_harness` or custom `Stopwatch` tests | <1% | — |

**Where does each test live?** Mirror the `lib/` tree exactly. Existing
convention in the repo is already correct; keep it.

---

## 4. Categories of required tests (with WHY)

Every "why" below maps to a concrete risk of user harm, data loss, or
regulatory/UX failure. The coverage policy (§9) requires **99%+ per
layer**, and for a safety-critical app test complexity is explicitly
not a concern — unlimited time and resources are assumed. Each
category below is therefore written to the standard of "what does it
take to reach 99% on this surface," not "what's a reasonable subset."

### 4.1 Engine timing
**WHY:** Every bug is a missed or premature escalation. A 1-second
off-by-one on a 5-second grace is the difference between "user had time
to re-hold" and "distress fired while they unlocked the phone". Required:
three-phase timing per step type, jitter bounds ±20%, `FixedRandom(0.5)`
identity, pause/resume remaining-time exactness, `leapToNextEvent`
compression.

### 4.2 State-machine transitions & distress replacement
**WHY:** Distress chain **replaces** the main chain. A bug that reverts
to the main chain silently cancels escalation — the worst failure mode.
`EngineIdle → Running → Paused → Running → Ended` must be exhaustive
over the sealed hierarchy.

### 4.3 Strategy execution — real AND simulation
**WHY:** The 4-layer simulation defense must hold. A leak sends real SMS
to real contacts during simulation. Each strategy needs two tests:
`executeReal()` side-effects on the fake; `simulationDescription()`
returns non-empty localized text.

### 4.4 JSON round-trip per model
**WHY:** On schema mismatch the app nukes and reseeds. A silent `fromJson`
bug that drops a field (e.g., `duressPinHash`) means the user's panic PIN
disappears on upgrade. One test per model plus the aggregate snapshot.

### 4.5 Repository CRUD + query filters
**WHY:** The user-reported session-log trash bug — writes correct, reads
filtered wrong. Required: list, add, update, delete, trash-filter,
restore, persisted-filter-query round-trip, pagination stability.

### 4.6 Distress trigger paths
**WHY:** Three independent triggers (hardware panic 5× volume, duress
PIN, wrong-PIN threshold). A coerced user may only try one. Any single
failure = silent non-escalation. Each path tested; idempotent under
concurrent activation.

### 4.7 PIN flows
**WHY:** Three independently nullable PINs (App, Session End, Duress).
Failure modes: can't end session (distraction), duress shown as "wrong"
(attacker sees failure), lockout in public. Cover setup, change, remove,
biometric fallback (session-end only), timeout.

### 4.8 Localization completeness (14 languages)
**WHY:** Non-English users have historically received English fallbacks
at the most stressful moment. Automate: every key in `app_en.arb` present
and non-empty in the 13 other ARBs; RTL layout test for `fa`, `ar`, `he`.

### 4.9 Permission handling
**WHY:** Silent field failures. Denied SMS permission during escalation
is the single most dangerous runtime state — user thinks they have SMS
backup, doesn't. Cover granted / denied / permanently-denied for SMS,
phone, location, contacts, POST_NOTIFICATIONS (Android 13+), FGS
exemption, battery optimization.

### 4.10 Platform-specific behaviors
**WHY:** Flutter hides platform differences until they bite.
- Android: FGS survives activity destruction; WorkManager retry on boot
  (`BootReceiver.kt`); system volume restore after alarm.
- iOS: CallKit incoming-call pause/resume; background task budget.

### 4.11 Accessibility
**WHY:** The user base includes low-vision and motor-impaired users.
Cover: TalkBack/VoiceOver labels, font scale 1.5× and 2.0× without
overflow, contrast ≥ 4.5:1, RTL doesn't truncate hold/panic buttons.

### 4.12 Crash recovery
**WHY:** Spec Extra 13. If the app crashes mid-session, next launch MUST
signal recovery. Silent "nothing happened" is a safety bug.

### 4.13 Backup + restore round-trip
**WHY:** Users lose phones. Export → wipe → import must reproduce
`SessionMode`, contacts, `AppDefaults`, and PIN hashes — or explicitly
document the stripped fields.

### 4.14 Simulation isolation (4-layer defense)
**WHY:** A developer toggling simulation on a real device must never
place a real call. Per-layer tests: orchestrator rejects speedMultiplier
outside simulation; fake services assert "not called"; strategies
short-circuit on `SessionContext.isSimulation`; UI shows banner.

### 4.15 Non-blocking event execution
**WHY:** A failed SMS must not stall the chain. If step 3 throws, step 4
must still fire. Assert advancement under each exception type.

### 4.16 Stealth integrity
**WHY:** A single label like "Guardian Angela is tracking you" in a
notification defeats stealth. Required: golden snapshots of all
notification strings under `stealthConfig.enabled`; a11y-label sweep.

### 4.17 Engine + service timing fidelity
**WHY:** `timing_fidelity_test.dart` exists; extend to assert service
side-effects land *after* `stepStarted` and *before* `stepAdvancing`.

---

## 5. Specific test scenarios to add

Organized by category. Each `TEST-###` is a concrete scenario **not
currently covered** (to the best of analysis) or covered shallowly.

### 5.1 Engine & timing (P0)

| ID | Title | Precondition | Action | Expected | Priority | Why |
|---|---|---|---|---|---|---|
| TEST-001 | Jitter disabled when `FixedRandom` passed | Engine constructed with `FixedRandom()` | Run all step phases | All durations == configured (no ±20%) | P0 | Guards test determinism; regression would make suite flaky |
| TEST-002 | Jitter applied ±20% bounds with real `Random` | Engine with `Random()`, step duration=1000s | Run N=100 trials | All durations ∈ [800s, 1200s] inclusive | P0 | Prevents drift outside bounds — would violate spec |
| TEST-003 | Pause during wait phase preserves wait remaining | Step at 7s into 30s wait | `pause()`, `resume()` after real 60s | Remaining wait = 23s | P0 | User took call mid-wait; off-by-one = premature escalation |
| TEST-004 | Pause during grace phase preserves grace remaining | Step at 2s into 5s grace | `pause()`, `resume()` | Remaining grace = 3s | P0 | Spec INT-007 variant |
| TEST-005 | Distress chain does not inherit `speedMultiplier` from simulation | Simulation 1000x, distress fired | Check distress timers | Distress uses real time (rejects speed > 1) | P0 | Real SMS timing must never be accelerated |
| TEST-006 | `leapToNextEvent` fires exactly one timer | Simulation, 3 pending timers | Call `leapToNextEvent()` | Only nearest timer fires within 1s | P1 | Leap compresses remaining time; not "fast-forward to end" |
| TEST-007 | Idempotent `endSession()` | Session ended | Call `endSession()` again | No duplicate `sessionEnded`, no crash | P1 | Prevents double-save of session log |
| TEST-008 | Chain exhaust emits terminal event exactly once | Chain of 3 steps all fail | Run to end | `chainExhausted` emitted exactly once | P0 | Double-emit would double-log |

### 5.2 Strategy / simulation defense (P0)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-010 | `SmsContactStrategy.executeReal` in simulation logs `sim_blocked`, calls zero real services | P0 | Core safety invariant |
| TEST-011 | `PhoneCallContactStrategy.executeReal` in simulation does not invoke `PhoneService` | P0 | Same |
| TEST-012 | `CallEmergencyStrategy.executeReal` in simulation does not dial 911/112/… regardless of locale | P0 | Locale bug could still dial real number |
| TEST-013 | `LoudAlarmStrategy` respects `simulationSilent=true` — audio suppressed, vibration fires | P1 | Stealth test — developers running sim in public |
| TEST-014 | Every `EventStrategy.simulationDescription()` returns non-empty, localized text | P1 | Missing localization → empty toast |
| TEST-015 | `DisguisedReminderStrategy` in simulation still shows notification (reminder is check-in, not escalation) | P1 | Ensures sim still exercises check-in UI |
| TEST-016 | Strategy fan-out respects `EmergencyContact.messageChannels` — all enabled channels used | P0 | Regression from old `preferredChannel` model |

### 5.3 Distress & triggers (P0)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-020 | Hardware panic (5× volume in ≤3s) fires distress | P0 | Primary panic path |
| TEST-021 | 4× volume in 3s does NOT fire distress | P0 | False-positive guard |
| TEST-022 | Volume presses spread over >3s do NOT accumulate | P0 | Timer reset semantics |
| TEST-023 | Duress PIN at disarm prompt fires distress silently (no "wrong PIN" shake) | P0 | Attacker-visible failure leaks duress |
| TEST-024 | Duress PIN at App PIN prompt also fires distress | P0 | Any prompt, per spec |
| TEST-025 | 5 consecutive wrong PIN attempts at Session End fires distress | P0 | Third trigger path |
| TEST-026 | Correct PIN after 4 wrong attempts resets counter to 0 | P1 | Prevent perma-lockout false positive |
| TEST-027 | Distress activation 5s confirmation window; cancel button works | P1 | False-positive recovery |
| TEST-028 | Cancel confirmation requires Session End PIN if configured | P1 | Attacker cannot cancel user's distress |
| TEST-029 | Concurrent triggers (hardware + duress PIN within 100ms) fire distress once | P0 | Idempotency |

### 5.4 PIN flows (P0/P1)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-030 | PIN setup stores hash, never plaintext | P0 | Security invariant |
| TEST-031 | Hash algorithm + iteration count documented + asserted | P0 | Upgrade-safety |
| TEST-032 | Wrong PIN delay increases exponentially (if spec) | P1 | Brute-force guard |
| TEST-033 | Biometric fallback invokes only for Session End PIN | P0 | Spec constraint |
| TEST-034 | PIN timeout (default 15s) locks UI; next entry starts fresh | P1 | UX |
| TEST-035 | Remove PIN clears hash AND clears failure counter | P1 | State cleanliness |

### 5.5 Model / JSON (P1)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-040 | Every JSON-serializable domain model round-trips lossless (parametrized over model list) | P0 | Upgrade safety |
| TEST-041 | Unknown fields in incoming JSON are ignored (forward-compat within version) | P1 | Backport compat |
| TEST-042 | `ModeOverrides.stealth=null` inherits from `AppDefaults.stealth` (and same for every nullable field — parametrized) | P0 | Override resolution |
| TEST-043 | Empty contacts list in mode with smsContact step fails validation for real session | P0 | Pre-flight |
| TEST-044 | Empty contacts list is allowed for simulation | P1 | Lenient sim |
| TEST-045 | `distressChainId` pointing at non-existent chain falls back to first chain with warning log | P1 | Broken state tolerance |

### 5.6 Repository (P0)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-050 | Session log list filter `deleted=false` excludes trashed entries | P0 | Specific bug users reported |
| TEST-051 | Restore from trash moves entry back into filtered list | P1 | Same bug family |
| TEST-052 | Concurrent writes during session serialize correctly (no corruption) | P1 | Real-world race |
| TEST-053 | Repository recovers from malformed JSON on disk (rename + reseed) | P0 | Crash-recovery |
| TEST-054 | Drift DAO `wipe()` leaves a timestamped SQLite backup alongside the main DB for the recovery dialog | P1 | Extra 13 |

### 5.7 Platform & permissions (P1)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-060 | SMS permission denied surfaces blocking dialog before real session start | P0 | Silent failure today |
| TEST-061 | SMS permission denied allowed for simulation start (with toast) | P1 | Dev ergonomics |
| TEST-062 | Foreground service notification never shows "Guardian Angela" when stealth enabled | P0 | Stealth invariant |
| TEST-063 | Reboot → `BootReceiver` re-enqueues pending SMS | P1 | Spec requirement |
| TEST-064 | iOS CallKit incoming call during session pauses engine | P1 | INT-008 variant |
| TEST-065 | Battery optimization dialog shown once per device + per install | P2 | UX |
| TEST-066 | Android 13+ POST_NOTIFICATIONS denied still allows session (with warning) | P1 | Graceful degrade |

### 5.8 Localization (P1)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-070 | Every key in `app_en.arb` exists and is non-empty in each of the 13 other locales (parametrized) | P0 | CI gate |
| TEST-071 | ICU plural cases for `reminderMissedCount` exist in every locale | P1 | Common omission |
| TEST-072 | RTL screen: `HomeScreen` renders with panic button in the same logical position (start-aligned) | P1 | RTL UX |
| TEST-073 | No hard-coded English strings in `lib/features/**/*.dart` (static analysis) | P1 | Catch drift |

### 5.9 UI / widget (P1)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-080 | `PinKeypad` renders localized backspace label in all 14 locales | P1 | Snapshot |
| TEST-081 | `SessionScreen` hold button shows held state within 150ms of tap-down | P1 | Perceived responsiveness |
| TEST-082 | `FakeMusicPlayerScreen` "I feel fine" slider fires disarm at exactly threshold 1.0, not 0.99 | P0 | Boundary |
| TEST-083 | `FakeLockScreen` system back gesture is intercepted (no-op) | P1 | Stealth |
| TEST-084 | `HomeScreen` chain summary updates when user switches mode via pull-to-refresh or tab | P1 | UI consistency |

### 5.10 Accessibility (P1)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-090 | All interactive elements on every primary screen expose a `Semantics` label (parametrized screen list) | P1 | TalkBack UX |
| TEST-091 | Font scale 2.0: `HomeScreen`, `SessionScreen`, `SettingsScreen` have no overflow warnings | P1 | Low-vision users |
| TEST-092 | Contrast ≥ 4.5:1 for primary body text in light + dark themes | P2 | WCAG |
| TEST-093 | Stealth mode semantic labels contain none of: "guardian", "angela", "safety", "disarm", "panic" | P0 | Stealth integrity |

### 5.11 Integration / scenarios (P0)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-100 | Walk Mode — phone dropped mid-walk → chainExhausts → SessionLog persisted with all events | P0 | Primary use case |
| TEST-101 | Date Mode — 3 missed reminders → escalation → user disarms with biometric → chain resets | P0 | Primary use case |
| TEST-102 | Crash during active session → next launch shows recovery dialog with session details | P0 | Extra 13 |
| TEST-103 | Backup → uninstall → reinstall → restore → all modes + contacts + AppDefaults + PIN (if policy allows) restored | P0 | Upgrade |
| TEST-104 | Incoming real call during `fakeCall` step pauses engine until call ends | P0 | INT-008 |
| TEST-105 | Disarm during active SMS WorkManager job cancels pending enqueues | P0 | INT-010 |
| TEST-106 | Mode switch while session is paused is blocked (session lock) | P1 | Safety invariant |
| TEST-107 | Language change during session is blocked | P1 | Spec |
| TEST-108 | Contact deletion during session is blocked | P1 | Spec |

### 5.12 Stealth (P0)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-110 | Notification channel title = `stealthConfig.notificationDisguise` when stealth on | P0 | Stealth leak |
| TEST-111 | Session screen in stealth mode shows configured `sessionScreenStealth` (lock or music) | P0 | Primary stealth UX |
| TEST-112 | `chainExhausted` in stealth mode does not show "Session Ended" screen | P0 | Silent exit |
| TEST-113 | Missed-reminder badge hidden in stealth | P0 | Same |
| TEST-114 | Golden snapshot of fake-lock-screen in 14 locales (no English vocabulary leak) | P1 | CI visual gate |

### 5.13 Property / fuzz (P2)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-120 | Generate N=200 random valid `SessionMode` instances → all round-trip through JSON losslessly | P1 | Broad schema |
| TEST-121 | Generate random contact phone numbers → validator accepts E.164 and rejects non-E.164 | P2 | Contact validation |
| TEST-122 | Chain of random step permutations always preserves order invariant after `copyWith(order: ...)` | P2 | |
| TEST-123 | Fuzz timing fields (0..86400) — engine never throws, `chainExhausted` always eventually reached | P1 | Robustness |

### 5.14 Performance (P2)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-130 | Engine event loop throughput at speedMultiplier=1000 ≥ 10k events/second on reference hardware | P2 | Sim UX |
| TEST-131 | Session log write latency < 20ms p95 on debug build | P2 | No UI jank |
| TEST-132 | Memory after 100 simulated sessions doesn't exceed baseline + 50MB | P2 | Leak guard |

### 5.15 Backup + recovery (P0)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-140 | Export JSON has top-level `schemaVersion` field | P0 | Upgrade |
| TEST-141 | Import JSON with higher `schemaVersion` rejected with descriptive error | P0 | Forward incompat |
| TEST-142 | Import JSON with lower `schemaVersion` migrates or rejects (not partial-load) | P1 | Data integrity |
| TEST-143 | Malformed JSON (truncated) rejected without mutating store | P0 | No partial import |
| TEST-144 | Backup content selector: exporting with PIN hashes deselected produces a file with zero hash bytes | P0 | User privacy |
| TEST-145 | Backup with PIN-encryption enabled: file begins with documented magic bytes + KDF params; ciphertext is not the plaintext | P0 | Encryption correctness |
| TEST-146 | Backup with PIN-encryption enabled: restore with correct password round-trips every selected entity | P0 | Encryption correctness |
| TEST-147 | Backup with PIN-encryption enabled: restore with wrong password rejects without mutating store | P0 | Attack surface |
| TEST-148 | Backup without encryption but WITH PIN hashes shows a blocking confirmation dialog with an explicit warning | P0 | Fail-loud UX (§ D-BACKUP) |
| TEST-149 | Content selector remembers the last-used selection per device (not across backups) | P2 | UX |

### 5.16 Drift persistence + migrations (P0)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-150 | Every Drift table round-trips through DAO: insert → select → assert equality (parametrized over all tables) | P0 | Persistence correctness |
| TEST-151 | SQLCipher key missing from secure storage: app fails loud with a recovery dialog, does NOT silently create an empty DB | P0 | Data-loss guard (see P11 "fail loud") |
| TEST-152 | SQLCipher key present but wrong: decrypt error propagates; same recovery dialog | P0 | Corruption guard |
| TEST-153 | Migration N-1 → N: fixture DB at schema N-1 reads losslessly after migration (parametrized over every historical version once v1.0 ships) | P0 | Upgrade safety (P11) |
| TEST-154 | Schema dump committed at `lib/data/db/schema/` matches `drift_dev schema dump` output exactly | P0 | Drift-source vs artifact parity |
| TEST-155 | `AppDatabase.schemaVersion` bump without an accompanying migration step fails the build (meta-test / CI lint) | P0 | Prevent silent schema drift |
| TEST-156 | Concurrent transactions from two isolates (foreground UI + SmsWorker) serialize correctly, no "database locked" crashes | P1 | Real-world race (supersedes TEST-052) |
| TEST-157 | DB file on disk is unreadable without the SQLCipher key (integration test opens with wrong key, expects error) | P0 | Encryption at rest |
| TEST-158 | `NativeDatabase.memory()` test harness exposes identical API to file-backed DB (fixture verification) | P1 | Test reliability |

### 5.17 Telemetry (P0)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-160 | `telemetryEnabled=false`: a full simulated session (including an injected crash) produces zero HTTP requests (fake HttpClient records nothing) | P0 | Opt-out MUST prevent network, not merely drop server-side |
| TEST-161 | `telemetryEnabled=true` default on fresh install | P0 | Policy is opt-OUT |
| TEST-162 | Settings → Privacy toggle flips the runtime flag within the same frame (no app restart) | P0 | UX |
| TEST-163 | Crash report scrubber removes phone numbers, contact names, PIN hashes, session body text, GPS coordinates before upload | P0 | PII leakage |
| TEST-164 | Usage event names are in an allowlist; unknown names are dropped at the sender | P1 | Leak guard |
| TEST-165 | Opt-out persists across reboot and app update | P1 | Policy integrity |

### 5.18 Stealth UI configuration (P1)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-170 | Inline quick toggle on home screen flips `StealthConfig.enabled` | P1 | UX (two entry points, one source) |
| TEST-171 | `/settings/stealth` detailed screen exposes every `StealthConfig` field | P1 | Parity |
| TEST-172 | Inline toggle and detailed screen share state (change in one reflects in the other immediately) | P1 | Consistency |
| TEST-173 | Inline toggle is disabled if user has never configured stealth appearance (CTA routes to detailed screen) | P2 | First-run UX |

### 5.19 Battery-alert gating (P0)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-180 | Zero emergency contacts: "Enable battery alert" toggle in Settings is disabled and shows a CTA "Add at least one contact first" | P0 | Decision — refuse to enable (prevents a silent no-op alert) |
| TEST-181 | Adding the first contact re-enables the toggle without app restart | P1 | UX |
| TEST-182 | Deleting the last contact while battery alert is ON disables the feature and notifies the user | P0 | State integrity |

### 5.20 Emergency-number database (P1)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-190 | Bundled DB contains an entry for every ISO 3166-1 alpha-2 country code + all recognised territories | P1 | Coverage claim |
| TEST-191 | SIM country detection selects the correct default from the DB | P1 | Auto-detect path |
| TEST-192 | User override at runtime takes precedence over SIM detection for the session | P1 | Override semantics |
| TEST-193 | DB lookup by country code returns a non-empty list of numbers for every country (parametrized) | P0 | Data-quality gate |
| TEST-194 | Airplane mode / no SIM falls back to the user's manually-configured default with no crash | P1 | Graceful degrade |

### 5.21 Session log retention (P1)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-200 | Default retention is 180 days | P0 | Decision default |
| TEST-201 | Changing retention to 30/90/365/unlimited persists and takes effect on next prune pass | P1 | Policy |
| TEST-202 | Smart retention preserves logs tagged as critical (distress fired, chain exhausted) regardless of age | P0 | Data-preservation guarantee |
| TEST-203 | `unlimited` retention never prunes; `30d` prunes a 31-day-old non-critical log | P1 | Boundary |
| TEST-204 | Prune pass on 100k-entry log completes within a single-digit-second budget on reference hardware | P2 | Performance |

### 5.22 Simulation silent re-arm (P0)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-210 | Starting a simulation always sets `simulationSilent=true`, regardless of prior value | P0 | Decision — each sim re-arms |
| TEST-211 | Ending a simulation does NOT persist `simulationSilent` to `AppSettings` (no sticky override) | P0 | Re-arm invariant |
| TEST-212 | UI cannot expose a "remember this" option for simulation-silent | P1 | Enforced in Settings + integration test |

### 5.23 iOS 17 widget + platform floor (P1)

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-220 | `ios/Podfile` pins `platform :ios, '17.0'` (meta/lint test) | P0 | Platform floor (P12) |
| TEST-221 | `android/app/build.gradle.kts` pins `minSdk = 26` (meta/lint test) | P0 | Platform floor (P12) |
| TEST-222 | Widget AppIntent "fake call" tap deep-links into `/fake-call` with the session context preserved | P1 | Widget parity |
| TEST-223 | Widget AppIntent "quick exit" invokes PIN prompt when Session End PIN is configured | P1 | Decision 62 |
| TEST-224 | Widget updates within 1 frame of `sessionStarted` event (integration test with fake WidgetKit bridge) | P1 | Perceived responsiveness |

### 5.24 E2E primary flows (P0)

One scenario per documented user flow. These are the **patrol +
Maestro + Appium** cases (see §7); every flow MUST have a real-device
run. Each ID below is implemented on **all three** frameworks to
provide defense-in-depth — patrol for permission + Dart-side state
assertions, Maestro for flow declaration + CI YAML scripting, Appium
for cross-platform device-matrix automation.

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-230 | Fresh install → Onboarding → first Walk Mode session → hold → disarm → session logged | P0 | First-run journey |
| TEST-231 | Fresh install → Onboarding → Date Mode → reminder → respond → chain resets | P0 | Primary check-in |
| TEST-232 | Grant SMS permission flow (patrol controls OS dialog) | P0 | Permission path |
| TEST-233 | Deny SMS permission flow: blocking pre-flight dialog before real session start | P0 | Silent-failure guard |
| TEST-234 | Hardware volume panic (5× in 3s) → distress confirmation → chain replacement | P0 | Panic path |
| TEST-235 | Duress PIN at disarm prompt silently fires distress with no shake animation | P0 | Coercion path |
| TEST-236 | Reboot → BootReceiver re-enqueues pending SMS → delivery completes | P0 | Persistence across reboot |
| TEST-237 | Incoming CallKit call during active session pauses engine; engine resumes on call end | P0 | iOS platform integration |
| TEST-238 | Backup → uninstall → reinstall → restore → full app state identical | P0 | Upgrade integrity |
| TEST-239 | Home widget fake-call button deep-link works from cold start and warm start | P0 | Widget integration |
| TEST-240 | Quick Exit from widget wipes recents (Android) and returns to home (iOS no-op) | P0 | Safety exit |

### 5.25 Golden coverage (per-widget) (P1)

Per §7.3, golden coverage is now **every widget** (not just critical
ones). The list below is the explicit policy, not an exhaustive
enumeration — each newly-added widget MUST land with matching
goldens across the device matrix.

| ID | Title | Priority | Why |
|---|---|---|---|
| TEST-250 | Every screen under `lib/features/**/screen.dart` has a golden in {light, dark} × {LTR, RTL} × {1.0x, 1.5x, 2.0x font} on device matrix {iPhone 15 Pro, Pixel 8, iPad Pro 12.9", Pixel Fold (folded + unfolded)} | P1 | Full visual-regression surface |
| TEST-251 | Every shared widget under `lib/core/widgets/**` has a golden across the same matrix | P1 | Component-level regression |
| TEST-252 | Stealth mode: every notification string + every screen rendered with `stealthConfig.enabled=true` has a golden that contains NONE of a forbidden-word list | P0 | Stealth leak guard (supersedes TEST-114) |
| TEST-253 | RTL golden for `HomeScreen`, `SessionScreen`, `OnboardingScreen` in fa, ar, he | P1 | RTL-specific |
| TEST-254 | Font-scale 2.0 renders every screen without overflow markers | P1 | Low-vision users |

---

## 6. What NOT to test (and why)

- **Flutter framework internals.** `TextField` rendering, animation curves,
  `Material` theming. These are Flutter's responsibility.
- **Trivial getters/setters without logic.** A `get name => _name` adds no
  information; testing it wastes maintenance. Focus on methods with
  branches.
- **External services' actual behavior.** SMS delivery by the carrier, real
  Firebase push — we mock/fake these. End-to-end real delivery tests are
  done manually during QA, not in CI.
- **Non-deterministic code paths the spec says are unreliable.** E.g., don't
  assert a specific timer firing at exactly T+500ms on a real device where
  the OS scheduler varies; instead, use `fakeAsync`.
- **Golden snapshots of screens with dynamic clock / date text.** Mock the
  clock.

---

## 7. Testing infrastructure recommendations

### 7.1 Mandatory tooling
- `fake_async` for any engine-timing test. Non-negotiable.
- `FixedRandom` (in `test/helpers/test_helpers.dart`, returns 0.5) for
  any test that exercises jitter. Default in helpers; opt out when
  testing jitter bounds with real `Random`.
- `package:checks` for assertions — already adopted.
- `ProviderContainer` with `overrideWith` for controllers. `mocktail`
  only when hand-rolled fakes are impractical.

### 7.2 Helpers
- `step(...)` factory — in use.
- Promote `_buildHarness` from `end_to_end_flows_test.dart` to
  `test/helpers/engine_harness.dart`.
- Add `pumpWithProviders(widget, overrides: [...])` to centralize
  `ProviderScope` + `MaterialApp` + localization setup for widget tests.

### 7.3 Golden snapshots — FULL coverage for every widget

Policy (not negotiable): **every widget** under `lib/features/**`
and `lib/core/widgets/**` ships with golden tests across the full
device + theme + RTL + font-scale matrix below. This is a change
from the prior "critical-only" policy; for a safety-critical app we
treat every rendered pixel as a potential stealth leak or
accessibility regression.

**Tooling.** `golden_toolkit` for device sizes, font loading,
multi-scenario builders, and `multiScreenGolden`.

**Setup.**
1. `dart pub add dev:golden_toolkit`
2. `flutter_test_config.dart` loads fonts via
   `loadAppFonts()` to eliminate CI-image font drift.
3. Baselines under `test/goldens/**`. Mirror the feature/widget path
   so a widget at `lib/features/home/home_screen.dart` has goldens at
   `test/goldens/features/home/home_screen/<device>_<theme>_<dir>_<scale>.png`.
4. Updates via `flutter test --update-goldens`; reviewer signs off
   on the PNG diff in the PR.

**Pinned device matrix.** CI runs goldens on a fixed list to
eliminate "works on my machine" drift. Sizes are defined as
`Device` records in `test/goldens/device_matrix.dart`:

| Device | Size (logical px) | Purpose |
|---|---|---|
| iPhone 15 Pro | 393 × 852, DPR 3.0 | iOS reference phone |
| Pixel 8 | 412 × 915, DPR 2.625 | Android reference phone |
| iPad Pro 12.9" | 1024 × 1366, DPR 2.0 | Large tablet / iPad |
| Pixel Fold (folded) | 320 × 800, DPR 2.75 | Narrow foldable, closed |
| Pixel Fold (unfolded) | 674 × 841, DPR 2.75 | Wide foldable, open |

**Combinatorics per widget.** 5 devices × {light, dark} × {LTR, RTL}
× {1.0x, 1.5x, 2.0x} = 60 snapshots per widget. Yes, this is a lot;
the coverage policy assumes unlimited time and resources (§4).
`golden_toolkit`'s `multiScreenGolden` collapses the device axis
into a single test case, so the per-widget test file writes one
`testGoldens(...)` per theme/dir/scale × per-device grid.

### 7.4 End-to-end: patrol + Maestro + Appium (all three)

Policy: **rather be safe than sorry**. Every E2E flow listed in
§5.24 is implemented on all three frameworks. Each framework closes
a different coverage gap; together they give defense-in-depth.

**`patrol`**
- Closes: OS-level permission dialogs, dark-pattern notification
  dialogs, hardware-button simulation on Android, intent inspection.
- Lives in: `integration_test/patrol/*.dart`.
- Invoked via: `patrol test --target integration_test/patrol/`.

**Maestro**
- Closes: declarative flow scripting, cheap CI execution, parallel
  device lab runs, flakiness-resistant retry semantics.
- Lives in: `test_driver/maestro/*.yaml` (flow YAMLs).
- Invoked via: `maestro test test_driver/maestro/`.

**Appium**
- Closes: cross-device matrix automation on a real-device cloud
  (BrowserStack / Sauce Labs), platform-specific gesture
  edge-cases (long-press, 3-finger, volume chord), iOS CallKit
  harness.
- Lives in: `test_driver/appium/*.py` (pytest + Appium-Python-Client).
- Invoked via: `pytest test_driver/appium/ -n auto`.

Any E2E flow (TEST-230..240) missing an implementation in any of
the three frameworks is a P0 coverage gap. The rebuild-strategy
Phase 5 and Phase 7 both gate on E2E-triple completeness.

### 7.5 CI integration
- `flutter test -j 6`, `flutter analyze --fatal-infos`, and
  `dart format --set-exit-if-changed` must pass.
- Localization completeness script runs as a dedicated job.
- Golden job runs on a pinned CI image (font rendering varies) across
  the device matrix above.
- patrol, Maestro, and Appium jobs each run the E2E suite on a real
  device (Firebase Test Lab for Android, BrowserStack for iOS; or
  self-hosted where budget allows).
- **Coverage gate (strict):** CI fails if ANY layer drops below 99%
  OR if ANY source file in `lib/` has zero associated tests. The
  zero-test gate is enforced by a script that parses `lcov.info` and
  flags files with no `DA:` lines at all. Exceptions require a
  written justification (see §9 "Justification for exceptions").
- Zero-tolerance for flakes: flakes get a tracked issue AND a pinned
  quarantine tag; they do not get a blanket retry.

### 7.6 Coverage targets

See §9. Summary: **99%+ line coverage per layer, targeting 100%;
every file has at least one test.**

Enforce via `flutter test --coverage` + a custom `lcov` threshold
script in CI that iterates the per-layer targets and fails on any
drop below 99%.

### 7.7 Test-data policy
- **Seed data (`lib/data/seed_data.dart`)** is the source of truth for
  Walk/Date modes, default templates, event defaults. Tests should not
  duplicate this; import from seed.
- **Explicit fixtures** in `test/fixtures/` for edge cases (e.g., a mode
  with all 9 step types in one chain).
- Avoid "ambient" fixtures defined mid-file — prefer named const
  builders.

### 7.8 Anti-flake
- No `await Future.delayed`; always use `async.elapse` inside `fakeAsync`.
- No `WidgetTester.pumpAndSettle()` without a fixed duration cap.
- No dependencies on the wall clock: inject `DateTime.now` as a function.
- No network calls.

---

## 8. Anti-patterns seen in the existing tests

1. **Baseline pass-count assertions.** `spec_compliance_test.dart` and
   `spec_defaults_test.dart` encode magic numbers like "4789 tests exist".
   Every feature forces a mechanical bump. **Fix:** assert properties
   (every spec section has ≥1 test referencing it by tag), not counts.

2. **Hive-backed widget tests.** Some settings tests initialize a real
   Hive box, then test a widget that uses a Riverpod controller that
   uses a repository that uses Hive. Brittle and slow. **Fix:** override
   the repository provider with a fake; the repository layer has its
   own unit tests.

3. **Mocking the thing you're testing.** Occasionally a controller test
   mocks the controller's own methods to verify the UI called them —
   tautology. **Fix:** test the Notifier's observable state via
   `ProviderContainer.read`, not via method call recording.

4. **Tests passing after a bug is introduced (false negatives).** The
   session-log trash bug passed CI because no test queried the list in
   the exact way the UI did. **Fix:** controllers should define
   user-facing query methods (`visibleLogs`, `trashedLogs`) and those
   methods get tested, not the underlying repository calls.

5. **Widget tests asserting presence of `Text('Some label')`.** Breaks
   on localization change. **Fix:** either use a `Key` on the widget or
   assert via the localization lookup: `l10n.someLabel`.

6. **Mixed real + simulation assertions in one test.** Violates the
   defense-in-depth principle — a test that toggles `isSimulation`
   mid-run obscures which layer actually blocked the real SMS. **Fix:**
   one test, one mode.

7. **Skipped tests without a linked issue.** A `skip: 'flaky on CI'`
   comment is a lie by omission. **Fix:** every `skip` references an
   open GitHub issue.

---

## 9. Proposed coverage matrix for the rewrite

**Line-coverage target: 99%+ for every layer, strive for 100%.**
Test complexity is explicitly not a concern for a safety-critical
app; unlimited time and resources are assumed. Any file under `lib/`
with zero tests fails CI.

### 9.1 Per-layer numeric targets

| Layer | Line target | Justification for anything below 100% |
|---|---|---|
| `lib/domain/engine/` | 100% | No excuse; pure Dart, `fakeAsync`-driven. |
| `lib/domain/orchestration/` (registry + strategies) | 100% | Sealed exhaustiveness MUST cover every step type. |
| `lib/domain/models/` | 100% | `toJson`/`fromJson`/`copyWith` are mechanical; round-trip tests are parametrized over the full model list. |
| `lib/data/db/` (Drift tables, DAOs, migrations) | 99% | Target 100%; the 1% slack covers purely generated `*.drift.dart` boilerplate that has no behaviour (documented per file). |
| `lib/services/protocols/**` + `lib/services/implementations/**` | 99% | Platform-channel shims (MethodChannel bodies that can't run in unit tests) documented per method. |
| `lib/features/**/*_controller.dart` | 99% | All Riverpod Notifiers have fake-provider tests. |
| `lib/features/**/*_screen.dart` + other widgets | 99% | Widget + golden combined. Exceptions: `StatelessWidget`s that are trivial composition of already-tested widgets (documented per widget). |
| `lib/core/**` | 99% | Constants + tiny utilities. Trivial getters excluded with justification. |
| `lib/router/app_router.dart` | 100% | Every route resolves + every redirect branch has a test. |
| `lib/l10n/**` (generated) | N/A | Parity check replaces line coverage (every en key present in every other locale). |
| `lib/main.dart`, `lib/app.dart` | 99% | Boot path hits Riverpod overrides in widget tests. |
| **Overall** | **99%+** | CI asserts the aggregate and each per-layer bucket independently. |

### 9.2 Justification for exceptions (policy)

Any file under 100% MUST carry an inline comment:

```dart
// COVERAGE: 98% — 2 lines are `assert()` in release-only constructor
// that cannot execute under test (see test/data/db/schema_test.dart for
// the compile-time check that supersedes runtime coverage here).
```

CI parses these comments and cross-checks them against `lcov.info`.
A file under 100% WITHOUT a justification comment fails the build.

### 9.3 Feature × layer matrix

Features (rows) × layers (columns). ✓ = required; — = optional; · = not
applicable.

| Feature | Unit (engine) | Unit (model) | Unit (strategy) | Unit (Drift) | Controller | Widget | Integration | E2E | Golden |
|---|---|---|---|---|---|---|---|---|---|
| SessionEngine | ✓ | · | · | · | · | · | ✓ | ✓ | · |
| Hold button step | ✓ | ✓ | ✓ | · | ✓ | ✓ | ✓ | ✓ | ✓ |
| Fake call step | ✓ | ✓ | ✓ | · | ✓ | ✓ | ✓ | ✓ | ✓ |
| Disguised reminder | ✓ | ✓ | ✓ | · | ✓ | ✓ | ✓ | ✓ | ✓ |
| Loud alarm | ✓ | ✓ | ✓ | · | · | · | ✓ | ✓ | · |
| SMS contact | ✓ | ✓ | ✓ | · | · | · | ✓ | ✓ | · |
| Phone call contact | ✓ | ✓ | ✓ | · | · | · | ✓ | ✓ | · |
| Call emergency | ✓ | ✓ | ✓ | · | ✓ | ✓ | ✓ | ✓ | ✓ |
| Countdown warning | ✓ | ✓ | ✓ | · | · | ✓ | ✓ | ✓ | ✓ |
| Hardware button (panic) | · | ✓ | ✓ | · | ✓ | · | ✓ | ✓ | · |
| Distress chain (global) | ✓ | ✓ | · | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Duress PIN | · | ✓ | · | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Session End PIN | · | ✓ | · | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| App PIN | · | ✓ | · | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Stealth: fake lock | · | ✓ | · | · | ✓ | ✓ | ✓ | ✓ | ✓ |
| Stealth: fake music | · | ✓ | · | · | ✓ | ✓ | ✓ | ✓ | ✓ |
| Stealth: notifications | · | ✓ | · | · | · | ✓ | ✓ | ✓ | ✓ |
| Contacts (CRUD, channels) | · | ✓ | · | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Modes (CRUD, overrides) | · | ✓ | · | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Templates (global + local) | · | ✓ | · | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Profile / medical info | · | ✓ | · | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Session log + trash + retention | · | ✓ | · | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Backup / restore (PIN-enc) | · | ✓ | · | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| GPS logging | · | ✓ | · | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| Battery alert (gated) | · | ✓ | · | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Onboarding | · | · | · | · | ✓ | ✓ | ✓ | ✓ | ✓ |
| Emergency-number DB | · | ✓ | · | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| Telemetry (opt-out) | · | ✓ | · | · | ✓ | ✓ | ✓ | ✓ | — |
| Localization (14 langs) | · | · | · | · | · | ✓ | — | — | ✓ |
| Accessibility | · | · | · | · | · | ✓ | — | — | ✓ |
| Router | · | · | · | · | · | ✓ | ✓ | ✓ | · |
| Wiring / DI | · | · | ✓ | · | · | · | ✓ | — | · |
| Home widget (Android + iOS 17) | · | ✓ | · | · | ✓ | ✓ | ✓ | ✓ | ✓ |

**Tradeoffs under the 99% policy:**
- No widget is exempt from golden coverage (§7.3). Even "trivial"
  StatelessWidgets get golden regression protection — a label change
  or accidental overflow can defeat stealth or accessibility.
- E2E is implemented on **all three frameworks** (patrol + Maestro +
  Appium) per §7.4. The prior "real device tests are expensive,
  keep sparse" tradeoff is explicitly overridden by the "rather be
  safe than sorry" directive.
- Line-coverage exceptions are file-scoped and require written
  justification (§9.2).

---

## 10. Implementation plan (parallel to the rewrite)

The rebuild runs in 10 phases (see `docs/rebuild-strategy.md`).
Tests land in the **same PR** as the code they cover; there is no
"write tests at the end" phase. The coverage gate starts strict and
stays strict — 99% from Phase 2 onward, per the policy in §9.

| Rebuild phase | Test work landing in that phase |
|---|---|
| **P1 — Scaffold** | Adopt `golden_toolkit`, set up `test/goldens/device_matrix.dart` with the 5-device matrix (§7.3), install `patrol` CLI, provision Maestro + Appium harnesses, wire coverage-gate script (99% threshold active from day 1), l10n-parity check script. |
| **P2 — Models + Drift** | TEST-040..045 (model round-trip), TEST-050..054 (repo CRUD), TEST-150..158 (Drift + migrations), TEST-140..149 (backup + PIN-encryption schema skeleton). Coverage gate enforced. |
| **P3 — Engine (pure Dart)** | TEST-001..008 (timing), TEST-210..212 (simulation silent re-arm at the engine level). |
| **P4 — Services (protocols + fakes + impls)** | TEST-010..016 (strategy simulation defense), TEST-160..165 (telemetry opt-out), TEST-190..194 (emergency-number DB). |
| **P5 — Platform native** | TEST-060..066 (permissions), TEST-220..224 (iOS 17 floor + widget), TEST-236..237 (reboot + CallKit). patrol + Maestro + Appium harness operational on real devices. |
| **P6 — Screens + controllers** | TEST-020..035 (distress, PIN flows), TEST-080..084 (widget behaviour), TEST-170..173 (stealth toggles), TEST-180..182 (battery-alert gating), TEST-200..204 (session log retention). Golden coverage begins for every widget as it's built. |
| **P7 — Integration scenarios** | TEST-100..108 (primary flows), TEST-110..114 (stealth integrity), TEST-230..240 (E2E primary flows on all three frameworks). |
| **P8 — Localisation** | TEST-070..073 (completeness + no hard-coded English), TEST-253 (RTL goldens). |
| **P9 — Home widget** | TEST-222..224 deepened with real-device widget taps on iOS 17 + Android. |
| **P10 — Release** | TEST-090..093 (a11y sweep), TEST-120..132 (property + perf), final coverage audit, goldens refreshed across the pinned CI image. |

Each phase's exit gate includes "coverage for this phase's new code
is ≥ 99% and every file in this phase has at least one test" (see
§7.5).

---

## 11. Open questions

Most previously-open policy questions have been resolved; the
resolutions are now encoded in §3, §7, §9, or in
`docs/decisions-log.md`. The items below remain.

**Resolved (reference, do not re-litigate):**
- **Coverage target** — 99%+ per layer, strive for 100%, per-file
  zero-test gate (§9).
- **E2E framework choice** — patrol + Maestro + Appium, combined
  (§7.4). No single-framework fallback.
- **Golden scope** — full coverage for every widget across the
  pinned 5-device matrix (§7.3, §9.3).
- **PIN hashes in backup** — user-selectable via content selector,
  optional PIN-encryption with user-supplied password, explicit
  warning if included without encryption (TEST-144..149).
- **Real-device CI** — budgeted in; all three E2E frameworks run
  on real devices (Firebase Test Lab for Android, BrowserStack for
  iOS; self-hosted where feasible).

**Still open:**

1. **Flakiness policy.** Zero-tolerance is the stated direction
   (§7.5), but a concrete quarantine workflow is not defined. Open:
   does a flaky E2E test block merges after first flake, or after
   N flakes in a rolling window? Proposed: first flake → issue +
   quarantine tag; second flake in 7 days → merge block on that
   suite until root-caused.
2. **Golden device-size pinning vs real-device parity.** Goldens
   run on a synthesized 5-device matrix (§7.3). Open: do we
   additionally capture reference goldens from real devices in the
   Appium cloud once per release, to detect platform rendering
   drift? Trade-off: adds ~1 hour per release but catches iOS
   SwiftUI version skew.
3. **Replace baseline pass-count tests.** Recommendation stands:
   replace `spec_compliance_test.dart` with `@Tags(['spec:INT-007'])`
   plus a lint rule that every spec section has ≥1 tagged test.
   Open only on timing: land this during P1 (new strict CI) or P2
   (once first features exist).
4. **`mocktail` usage rule.** Proposed: hand-rolled fakes by default;
   `mocktail` only when the collaborator is abstract, argument
   capture is unavoidable, or a platform-channel stub is required.
   Awaiting sign-off.
5. **Test fixtures vs production seed.** Recommendation stands:
   tests use production seed + targeted overrides; never fork
   fixtures that parallel production data. Awaiting sign-off.
6. **Stealth forbidden-word list location.** `lib/` (shipped in
   binary, attacker-discoverable) vs test-only constant. The
   threat-model trade-off is still undecided; the forbidden list
   is needed for TEST-252 regardless.

---
