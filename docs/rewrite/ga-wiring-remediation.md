# GA Wiring Remediation Plan

**Created:** 2026-06-04 (Phase 9 completeness audit).
**Status:** DRAFT for user review. No code changed yet.
**Supersedes:** the framing of `rippling-weaving-puffin.md §Phase 9` as
"just write integration tests." Phase 9's spec-coverage work surfaced
that the integration layer was never built; this plan closes that gap
and folds the original Phase 9 test work into its final milestone.

---

## 1. Corrected project status (the honest version)

Phases 0–8 delivered an **excellent, thoroughly unit-tested core** —
and an **app that does not actually work end-to-end** for most of its
safety features. The two facts are both true and not in tension:

- **Solid + tested (real):** the `SessionEngine` state machine, all 9
  event **strategies**, the Drift/sqlite3mc data layer, every model /
  enum / sealed type, the service **protocol implementations**
  (`Real*Service` + `*ServiceSim`), routing, the PIN auto-submit
  ladder, the simulation real/sim swap, and l10n (558 keys × 14
  locales). The **3744 passing tests are genuine** — they exercise
  these units in isolation.

- **Not wired (the gap):** the layer that connects **screens →
  controllers → services → engine** is pervasively incomplete. Methods
  exist and are tested; **nobody calls them**. Settings are stored and
  toggled; **nothing consumes them**. Strategies are correct; the
  **screens that should drive them don't**. Assets are referenced;
  they **don't exist on disk**.

**Why 3744 green tests hid this:** unit/widget tests build a widget or
call a method in isolation with fakes. None drive a *wired* flow
(real screen → real controller → real service → real engine → back to
the screen). Integration tests are the only thing that catches a
missing wire — and they were deferred to the very last phase. Phase 9
is therefore doing exactly its job: it found the hole.

This matches the documented v2 postmortem (*wiring failures;
test-before-code; no parallel agents for connected code*). The v3
rewrite reproduced the same failure mode one layer up: the units are
better and tested, but the wiring between them was treated as
"done" without an integration test ever proving it.

**New verification standard (the core lesson):** every fix in this
plan is proven by an **emulator integration test that drives the wired
flow**, so "green" finally means "works." A headless Android emulator
(`Pixel_9_Pro`, API 36) is confirmed working in this environment with
KVM acceleration and **collects on-device coverage** (validated by
`integration_test/app_boot_smoke_test.dart`).

---

## 2. GA-blocker inventory (from the 6-agent completeness audit)

Tracked as tasks #8–#23. Severity: 🔴 GA-blocker · 🟠 important ·
🟡 minor/descope. "✓" = I spot-verified the absence myself.

### Tier A — Core escalation is silent / doesn't disarm
| # | Gap | Spec | Sev |
|---|---|---|---|
| 21 | **Audio assets missing** — `siren.ogg`/`ringtone_default.ogg`/`countdown_warning.ogg` absent; only `alarm.mp3`+`ringtone.wav` exist → alarm/ring/countdown **silent** ✓ | 05:79-82,163,243 | 🔴 |
| 17 | **fakeCall hang-up/decline never call engine** (`context.pop()` only) → fake call **never disarms**; voice clip never plays ✓ | 02:236,251-254,242-247 | 🔴 |
| 18 | **disguisedReminder** renders no template/disguise/confirmation-types; hard-coded "Check in now"; `earlyCheckIn()` never called | 02:89-135 | 🔴 |
| 19 | **loudAlarm gradual-volume + DND-override unwired**; DND default **inverted** vs spec opt-in | 02:438, 06:277-279 | 🔴 |

### Tier B — Safety subsystems dead at runtime
| # | Gap | Spec | Sev |
|---|---|---|---|
| 11 | **Real incoming-call detection unwired** — `callStateServiceProvider` has no consumer; `PauseReason.incomingCall` dead. A2 (pause/resume), Extra-24/25 (cancel fakeCall), Extra-30/31 (hold pause) | 01:407-432,651-655 | 🔴 |
| 22 | **Battery alert never fires** (`startMonitoring` no caller) ✓ **+ GPS logging never tracks** (`startTracking` no caller) ✓ | 06:208-233,549-569 | 🔴 |
| 12 | Background speed-clamp lifecycle (`setBackgroundClamp` never called) — sim-only | 01:700-703 | 🟡 |

### Tier C — Can't configure the app
| # | Gap | Spec | Sev |
|---|---|---|---|
| 13 | **Mode Editor** can't set per-step event config (no `StepConfigPanel`/`EventSpecificConfig`) **nor Safety Options** (distress picker, distress/disarm trigger editing, GPS/stealth tri-states, `allowDisarmAsDistress`) | 04:1473-1655 | 🔴 |
| 14 | **SMS contact-selection grid** missing (every smsContact step) | 04:1664-1727 | 🔴 |
| 23 | **Alarm settings section** missing (DND-override / gradual / ramp toggles) | 06:271-296 | 🔴 |
| 20 | iOS SMS+callEmergency warning strings; SMS message-template editor; channel-validation-on-save; trigger save-validation (audit03) | 02:304,313-325,478; 03:648-685 | 🟠 |

### Tier D — Stealth non-functional
| # | Gap | Spec | Sev |
|---|---|---|---|
| 15 | **Stealth session UI** (fake music player + timer-display modes) unwired; 5 granular stealth fields (`fakeName`, `notificationDisguise`, `timerDisplay`, `sessionScreenStealth`) have no runtime effect | 04:893-931, 06:71-102 | 🔴 |

### Tier E — Known gaps (originally authorized) + polish
| # | Gap | Spec | Sev |
|---|---|---|---|
| 10 | **R-8** emergency-number 80+ country `emergencyNumbers` map + first-launch locale seeding | 02:454,06:245 | 🟠 |
| 9 | **R-32** distress-cancel biometric **+ session-end biometric** (same pattern) | 01:1020,06:160 | 🟠 |
| 8 | **R-29** "Start same mode" button on interrupted prompt | 04:965 | 🟡 |
| 16 | Notification-permission re-ask + Active-Triggers-Summary at session start | 04:456-461 | 🟠 |

### Tier F — Descope decisions needed (likely cut, confirm)
- 🟡 System Volume Override (Android) — STREAM_ALARM already bypasses silent (05:96-98)
- 🟡 AlarmManager watchdog — tension with "no restore from disk" policy (10:174)
- 🟡 Call-style-specific ringtones (05:67-75)
- 🟡 `requireLaunchAuth`/`launchAuthBiometric` dead fields — redundant w/ App-PIN gate (carried item #6)
- 🟡 Post-session feedback prompt (spec marks **[Optional]**)

---

## 3. Execution method (per your decision: serial + verifier cohorts)

For **each** fix (or tightly-coupled group):
1. **Verify the gap** myself first (don't trust the audit blindly).
2. **Implement** with full context (serial — these are connected).
3. **Prove it** with an emulator integration test driving the wired
   flow (`integration_test/<feature>_test.dart`, run on `Pixel_9_Pro`).
   Add focused unit/widget tests where cheaper.
4. **l10n:** any new user-facing string → English ARB + spawn the
   language agent for all 13 non-English locales (per project rule).
5. **Verifier cohort** (spec-vs-code architect-reviewer + spec-vs-tests
   qa-expert) per milestone; re-engage on `FIX_REQUIRED`.
6. **Gate suite** (analyze --fatal-infos, format, import_sorter, full
   `flutter test`, S-NN stub greps, Phase-X/OLD greps) green.
7. **Commit** per milestone. **Push needs explicit authorization.**

Connected work stays serial (real-call, mode editor, stealth, fakeCall,
reminder). Only genuinely disjoint, self-contained fixes (audio assets,
emergency-number map, iOS warning strings) may fan out to parallel
agents.

---

## 4. Milestones (safety-critical first)

**M0 — Make core escalation actually work** (highest safety value,
mostly self-contained)
- #21 audio assets (+ CI asset-existence gate)
- #17 fakeCall hang-up/decline/voice wiring
- #19 loudAlarm gradual/DND gating
- #18 disguisedReminder template rendering + confirmation types +
  earlyCheckIn

**M1 — Safety subsystems live** (SessionController lifecycle wiring)
- #11 real incoming-call detection (pause/resume, fakeCall cancel,
  hold pause)
- #22 GPS logging start/stop + battery-alert firing
- #12 background clamp (fold in)

**M2 — Configuration UIs** (the big build; `StepConfigPanel` /
`EventSpecificConfig` is the spine)
- #13 mode-editor per-step config + Safety Options + trigger
  save-validation
- #14 SMS contact-selection grid
- #23 alarm settings section
- #20 channel-validation-on-save, SMS template editor, iOS warnings

**M3 — Stealth** — #15 stealth session UI + granular-field consumption

**M4 — Known gaps + polish + descope** — #10 R-8, #8 R-29, #9 R-32 +
session-end biometric, #16 notification permission/triggers summary,
Tier-F descope confirmations

**M5 — Phase 9 proper (now meaningful)**
- INT-001..010 host integration scenarios (spec 07)
- Device e2e flows on emulator (now they pass through wired features)
- Finalize `test/spec_coverage_test.dart` (every R-NN + spec section →
  a passing test; flip the assertions on)
- Coverage: merge host+device lcov, exclude generated files, set CI
  floor; add an emulator-backed integration-test CI job so wiring
  can't regress
- Final GA-readiness re-assessment + verifier cohort

---

## 5. Scale & honesty

This is **large** — ~13 GA-blockers, several (mode editor, real-call,
stealth, reminder rendering) are multi-file features, not one-line
wires. Expect **multiple sessions**. M0 alone restores the app's
reason for existing (it can make noise and disarm). Each milestone is
independently committable and leaves the app strictly more functional.

`flutter test` baseline at plan time: **3744 passing**, analyzer clean,
emulator validated. Nothing in this plan is committed until you approve
the plan and then authorize each push.

---

## 6. Open questions for you
1. Approve this plan / milestone order? Anything to re-prioritize?
2. Tier-F descope: cut System-Volume-Override, AlarmManager watchdog,
   call-style ringtones, `requireLaunchAuth`, optional feedback prompt?
   (Each cut also needs a spec note so the spec stops mandating it.)
3. R-8 emergency-number data: OK for me to source the 80+ country map
   from a citable public reference (e.g. ITU / Wikipedia emergency
   numbers) and flag it for your review?
