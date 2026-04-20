> **Normative status:** This document is NORMATIVE for decisions recording.
> Supersedes `docs/decisions-round-2.md` and any inline spec decisions. In
> case of conflict with the contents of `docs/spec/*.md`, the spec remains
> the normative authority for HOW a behavior is implemented, while this
> document is authoritative for WHAT was decided and WHY. Key words "MUST",
> "SHOULD", "MAY" follow RFC 2119.

# Guardian Angela — Decisions Log

## Purpose

This is the single canonical record of every product, architectural,
safety, testing, and process decision made for Guardian Angela to date.
It consolidates (a) the 65 Round-2 decisions collected via structured
product-owner Q&A (originally in `docs/decisions-round-2.md`), (b) the
spec-vs-code audit open questions (`docs/audit-spec-vs-code.md`), (c) all
implicit decisions embedded in specs 00–11, (d) the most recent platform,
safety, UX, and test answers collected from the product owner, and (e) the
rewrite-scope decisions. It is the single source of truth that precedes
the next rewrite; no code, spec, or test change should be made without a
corresponding entry (or reference to an entry) in this document.

---

## Status legend

- **RESOLVED** — decision made; cited with a stable ID.
- **OPEN** — awaiting input before implementation can proceed.
- **REJECTED** — considered, not taken. Documented so we don't re-litigate.
- **SUPERSEDED** — replaced by a newer decision; old entry retained for
  traceability, with a pointer to the superseding ID.

## How to use this document

- **When implementing:** cite the decision ID inline in code comments,
  commit messages, PRs, and tests (e.g., "per D-SAFETY-3").
- **When changing a decision:** append a new entry superseding the old
  one (set the old entry's status to SUPERSEDED with a pointer to the
  new ID); do NOT rewrite history.
- **New decisions proposed via PR** MUST include an ID, context,
  alternatives considered, and rationale. A decision without a rationale
  is a guess.
- **ID format:** `D-<CATEGORY>-<N>` where CATEGORY ∈ {PLATFORM, SAFETY,
  UX, DATA, ENGINE, SERVICES, TEST, META, SEC, I18N, INFRA}. N is a
  monotonically increasing integer per category.
- **Legacy tags** (Round-2 A1-A6, B1-B8, C1-C7, D1-D5, Extras 7-65) are
  preserved inside each entry for cross-referencing, and appear in the
  index column "Legacy".

---

## Decision index

| ID | Title | Status | Legacy |
|---|---|---|---|
| D-PLATFORM-1 | Storage engine = Drift (SQLite) with sqlcipher | RESOLVED | — |
| D-PLATFORM-2 | iOS minimum = iOS 17+ | RESOLVED | supersedes spec00 iOS 16 |
| D-PLATFORM-3 | Launch all 14 languages at v1 | RESOLVED | — |
| D-PLATFORM-4 | Clean-slate rewrite, no v6→v7 data migration | RESOLVED | — |
| D-PLATFORM-5 | Keep app name "Guardian Angela" | RESOLVED | — |
| D-PLATFORM-6 | Telemetry opt-out, default ON | RESOLVED | overrides spec00 "no analytics" |
| D-PLATFORM-7 | Android SMS = direct SEND_SMS (silent) | RESOLVED | — |
| D-PLATFORM-8 | Flutter SDK pinned to latest stable, bump proactively | RESOLVED | Extra 16 |
| D-PLATFORM-9 | Android min API = 26 (Android 8.0) | RESOLVED | spec 00 |
| D-PLATFORM-10 | Android target API = 35 (Android 15) | RESOLVED | spec 00 |
| D-PLATFORM-11 | Platform scope = Android + iOS only (no web, no desktop) | RESOLVED | spec 08 |
| D-SAFETY-1 | Bundle comprehensive emergency-number database | RESOLVED | — |
| D-SAFETY-2 | Backup: user-selected categories + optional PIN encryption | RESOLVED | partially supersedes Extras 19, 34, 47 |
| D-SAFETY-3 | Battery alert: refuse enable with zero contacts | RESOLVED | — |
| D-SAFETY-4 | Stealth UI: quick toggle on /settings AND /settings/stealth | RESOLVED | resolves Q6 |
| D-SAFETY-5 | Simulation silent: always ON at start, no cross-session persistence | RESOLVED | Extra 49 |
| D-SAFETY-6 | Session-log retention: configurable; critical logs kept forever | RESOLVED | B8 |
| D-SAFETY-7 | Fake-call decline default = safe (resets chain) | RESOLVED | A1 |
| D-SAFETY-8 | Real call during countdown: pause, resume after | RESOLVED | A2 |
| D-SAFETY-9 | Wrong PIN in distress cancel: shake; threshold fires distress | RESOLVED | A3 |
| D-SAFETY-10 | Duress PIN during active distress: no-op | RESOLVED | A4 |
| D-SAFETY-11 | Disarm with queued SMS pending: cancel WorkManager | RESOLVED | A5 |
| D-SAFETY-12 | Max pause duration = unlimited, user controls | RESOLVED | A6 |
| D-SAFETY-13 | GPS denied + chain needs location: block session start | RESOLVED | Extra 12 |
| D-SAFETY-14 | Force-close mid-session: recovery dialog, no auto-resume | RESOLVED | Extra 13 |
| D-SAFETY-15 | WorkManager SMS retries exhausted: notify user | RESOLVED | Extra 14 |
| D-SAFETY-16 | Missing permission at session start: block with grant prompt | RESOLVED | Extra 44 |
| D-SAFETY-17 | Missing distressChainId: block start + warn on delete | RESOLVED | Extra 64 |
| D-SAFETY-18 | Emergency number change blocked during session | RESOLVED | Extra 20 |
| D-SAFETY-19 | Real call over FakeCallScreen: dismiss fake, show real | RESOLVED | Extra 29 |
| D-SAFETY-20 | Real call ends during fakeCall step: resume fake where paused | RESOLVED | Extra 30 |
| D-SAFETY-21 | Real call during holdButton: auto-pause, resume state | RESOLVED | Extra 31 |
| D-SAFETY-22 | Duress PIN at App PIN: unlock + fire distress silently | RESOLVED | Extra 53 |
| D-UX-1 | Hold button countdown on re-hold: cancel + restart | RESOLVED | D1 |
| D-UX-2 | Simulation Leap = 1s countdown to next event | RESOLVED | D2 |
| D-UX-3 | Rotation: session + fake-call locked portrait | RESOLVED | D3 |
| D-UX-4 | Disguised reminder early tap: configurable, default resets | RESOLVED | D4 |
| D-UX-5 | Stealth sub-options always visible when master OFF | RESOLVED | D5 |
| D-UX-6 | Fake stealth app name default = "Music" | RESOLVED | Extra 23 |
| D-UX-7 | Stealth notification icon default = music icon | RESOLVED | Extra 33 |
| D-UX-8 | Emergency call confirmation cancel = swipe slider | RESOLVED | Extra 56 |
| D-UX-9 | Auto theme switching = NO (user picks) | RESOLVED | Extra 58 |
| D-UX-10 | Unsaved edits preserved across backgrounding, warn on exit | RESOLVED | Extra 59 |
| D-UX-11 | FakeCall answered with no voice recording = silent "Calling..." | RESOLVED | Extra 60 |
| D-UX-12 | Safety Setup Checklist = collapsible banner on Home | RESOLVED | Extra 63 |
| D-UX-13 | End session from paused: PIN required if configured | RESOLVED | Extra 62 |
| D-UX-14 | Session Completed screen shown after normal end | RESOLVED | Extra 37 |
| D-UX-15 | Language switch mid-app = instant rebuild | RESOLVED | Extra 43 |
| D-UX-16 | Disguised reminder on locked device = full-screen wake | RESOLVED | Extra 35 |
| D-UX-17 | Reminder day/night = same behavior (no quiet hours v1) | RESOLVED | Extra 36 |
| D-UX-18 | fakeLockScreen wake = any touch | RESOLVED | Extra 40 |
| D-UX-19 | Reminder template icons mimic real apps | RESOLVED | Extra 57 |
| D-UX-20 | Strategy errors in log UI = user-visible red icon | RESOLVED | Extra 55 |
| D-UX-21 | Simulation chain exhausted = completion screen | RESOLVED | Extra 54 |
| D-UX-22 | Settings autosave (no save button) | RESOLVED | legacy notes |
| D-UX-23 | Info tooltips on non-obvious settings | RESOLVED | legacy notes |
| D-UX-24 | Session log search + filter chips | RESOLVED | Extra 50 |
| D-UX-25 | Session log soft delete + 7-day undo | RESOLVED | Extra 11 |
| D-UX-26 | App PIN wrong attempts: no consequence | RESOLVED | Extra 10 |
| D-UX-27 | Battery optimization prompt always shown in onboarding | RESOLVED | Extra 38 |
| D-UX-28 | Onboarding permission denial: skip allowed | RESOLVED | Extra 18 |
| D-UX-29 | Android 13 notification permission: onboarding + re-ask | RESOLVED | Extra 42 |
| D-UX-30 | Delete-all-modes: empty state + CTA, no auto-reseed | RESOLVED | C5 |
| D-UX-31 | Settings hub structure: /settings/defaults + /settings/modes-and-chains | RESOLVED | C6 |
| D-UX-32 | "Use my number" button in onboarding | RESOLVED | Extra 28 |
| D-UX-33 | App theme default = System (follow OS) | RESOLVED | B6 |
| D-DATA-1 | SessionMode.distressChainId references global DistressChain | RESOLVED | Extra 48 |
| D-DATA-2 | Multiple global distress chains; first = default | SUPERSEDED | Extra 48; see D-DATA-21 |
| D-DATA-3 | ModeOverrides: null field = inherit AppDefaults | RESOLVED | spec 03 |
| D-DATA-4 | Templates = global (AppDefaults) + mode-local (appended) | RESOLVED | C7 |
| D-DATA-5 | SessionLog.hadMedicalInfo flag persisted per log | RESOLVED | Extra 47 |
| D-DATA-6 | Per-contact SMS language + channels list (no preferredChannel) | RESOLVED | spec 03 |
| D-DATA-7 | Each SMS step = single channel; per-step contact picker | RESOLVED | Extra 15b |
| D-DATA-8 | Channel validation at save blocks mismatch | RESOLVED | Extra 15c |
| D-DATA-9 | Schema mismatch = nuke + reseed (no incremental migration) | RESOLVED | spec 03 |
| D-DATA-10 | Step 0 type rules: any type allowed | RESOLVED | Extra 24 |
| D-DATA-11 | Contact phone = free-form, warn if suspicious; import from device | RESOLVED | Extra 26-27 |
| D-DATA-12 | Emergency number = free-form, pattern-warn | RESOLVED | Extra 25 |
| D-DATA-13 | Multi-user profiles: no (single profile only) | RESOLVED | Extra 61 |
| D-DATA-14 | PIN length = 4-8, user picks at setup; same range for all three | RESOLVED | Extra 51-52 |
| D-DATA-15 | Lost Hive key: data-loss dialog (start fresh or restore) | RESOLVED | Extra 21 |
| D-DATA-16 | SMS queue persisted in Hive (encrypted) | RESOLVED | Extra 45 |
| D-DATA-17 | Backup export excludes media by default | RESOLVED | Extra 34 |
| D-DATA-18 | Export PII in session logs = toggle per export | RESOLVED | Extra 19 |
| D-DATA-19 | Every session start/end is logged (no trivial-session gate) | RESOLVED | Extra 65 |
| D-DATA-20 | SMS {name} fallback = "the owner of this phone" | RESOLVED | Extra 41 |
| D-DATA-21 | DistressChain extracted from AppDefaults into dedicated repo + editor UI | RESOLVED | supersedes D-DATA-2 |
| D-ENGINE-1 | Hardware panic pressCount default = 5 | RESOLVED | B1 |
| D-ENGINE-2 | Global disguisedReminder retryCount default = 1 | RESOLVED | B2 |
| D-ENGINE-3 | Global fakeCall retryCount default = 0 | RESOLVED | B3 |
| D-ENGINE-4 | LoudAlarm gradualVolume default = true | RESOLVED | B4 |
| D-ENGINE-5 | LoudAlarm flashSpeed = enum {fast, medium, slow} | RESOLVED | B5 |
| D-ENGINE-6 | Three-phase timing: wait → duration → grace | RESOLVED | spec 01 |
| D-ENGINE-7 | Engine is pure Dart, no Flutter imports | RESOLVED | spec 01 |
| D-ENGINE-8 | Jitter = ±20% via `0.8 + rand*0.4` | RESOLVED | spec 01 |
| D-ENGINE-9 | Speed multiplier rejected for real sessions | RESOLVED | spec 01 |
| D-ENGINE-10 | Distress chain REPLACES main chain (no return) | RESOLVED | spec 01 |
| D-ENGINE-11 | Universal retry rule: wait skipped on retries | RESOLVED | spec 01 |
| D-ENGINE-12 | Sealed EngineState hierarchy (Idle/Running/Paused/Ended) | RESOLVED | spec 01 |
| D-ENGINE-13 | 11 engine events emitted (including pauseExpired) | RESOLVED | audit Q-corrected |
| D-ENGINE-14 | Disarm during retryCount=0 grace: reset to step 0 | RESOLVED | Extra 46 |
| D-ENGINE-15 | GPS trigger mode without destination: prompt, skippable | RESOLVED | Extra 22 |
| D-ENGINE-16 | Distress triggers run parallel to chain (not as chain steps) | RESOLVED | spec 00 |
| D-ENGINE-17 | 5-second distress confirmation window | RESOLVED | spec 00 |
| D-ENGINE-18 | Battery alert = one-shot side-action, does not pause chain | RESOLVED | spec 00 |
| D-ENGINE-19 | Fake-call decline-with-distress = 5s hold | RESOLVED | spec 08 |
| D-ENGINE-20 | Include per-step DisguisedReminderConfig.templateIds | RESOLVED | C4 |
| D-ENGINE-21 | Include per-step SmsContactConfig.includeMedicalInfo | RESOLVED | C3 |
| D-SERVICES-1 | iOS headphone remote = audio_service | RESOLVED | C1 |
| D-SERVICES-2 | Built-in fake-call voice = all 14 languages | RESOLVED | C2 |
| D-SERVICES-3 | Default fakeCall voice path = built-in per-language | RESOLVED | Extra 32 |
| D-SERVICES-4 | Custom voice recording max = 2 minutes | RESOLVED | Extra 39 |
| D-SERVICES-5 | All Hive boxes encrypted (mandatory, not optional) | RESOLVED | spec 08 |
| D-SERVICES-6 | SMS retry = native Kotlin WorkManager (indefinite) | RESOLVED | spec 08 |
| D-SERVICES-7 | iOS SMS = opens Messages app; manual Send required | RESOLVED | spec 10 |
| D-SERVICES-8 | iOS phone call = always shows confirmation dialog | RESOLVED | spec 10 |
| D-SERVICES-9 | iOS hardware button = headphone remote only (no volume) | RESOLVED | spec 10 |
| D-SERVICES-10 | RecordingService merged into AudioService | RESOLVED | audit Q2 |
| D-SERVICES-11 | FlashService inlined in LoudAlarmStrategy | RESOLVED | audit Q2 |
| D-SERVICES-12 | ScreenFlashService = overlay widget (no service class) | RESOLVED | audit Q2 |
| D-SERVICES-13 | BackgroundSessionService split between Notification + Controller | RESOLVED | audit Q3 |
| D-SERVICES-14 | BackupService remains inline in backup_screen (extract later if needed) | RESOLVED | audit Q4 |
| D-SERVICES-15 | PermissionService = utility functions + per-screen calls | RESOLVED | audit Q5 |
| D-SERVICES-16 | WakelockService merged into DeviceStateService | RESOLVED | audit |
| D-SEC-1 | Three nullable PINs: App, Session End, Duress | RESOLVED | spec 00 |
| D-SEC-2 | pinTimeoutSeconds applies to App + Session End, NOT Duress | RESOLVED | B7 |
| D-SEC-3 | Biometric substitutes for Session End PIN only | RESOLVED | spec 00 |
| D-SEC-4 | Biometric fallback on cancel = fall back to PIN keypad | RESOLVED | Extra 17 |
| D-SEC-5 | Wrong-PIN threshold user-configurable (default 5) | RESOLVED | A3 |
| D-SEC-6 | Encryption key in flutter_secure_storage | RESOLVED | spec 00 |
| D-SEC-7 | PIN hashes stored, never plaintext | RESOLVED | spec 08 |
| D-SEC-8 | Panic wipe: NOT implemented (deferred) | REJECTED | spec 08 |
| D-SEC-9 | App identity concealment (fake label) = deferred | REJECTED | spec 08 |
| D-I18N-1 | 14 languages at launch | RESOLVED | D-PLATFORM-3 |
| D-I18N-2 | RTL languages: fa, ar, he | RESOLVED | spec 00 |
| D-I18N-3 | Auto-translate all ARBs on app_en.arb change | RESOLVED | CLAUDE.md |
| D-I18N-4 | CI fails if any non-English ARB missing keys | RESOLVED | rebuild-strategy L6 |
| D-TEST-1 | Coverage target = 99%+ per layer; justify exceptions in writing | RESOLVED | — |
| D-TEST-2 | E2E framework = patrol + Maestro + Appium | RESOLVED | — |
| D-TEST-3 | Full golden coverage for every widget | RESOLVED | — |
| D-TEST-4 | Engine tests use `_FixedRandom(0.5)` | RESOLVED | spec 07 |
| D-TEST-5 | fakeAsync mandatory for engine timing tests | RESOLVED | spec 07 |
| D-TEST-6 | Spec-to-test traceability: every normative paragraph → ≥1 test | RESOLVED | rebuild-strategy P8 |
| D-TEST-7 | Replace magic-number test-count assertions with spec-tag assertions | RESOLVED | test-strategy |
| D-TEST-8 | Hand-rolled fakes preferred; mocktail only where necessary | RESOLVED | CLAUDE.md |
| D-TEST-9 | Real-device smoke required before any native phase is "done" | RESOLVED | rebuild-strategy L10 |
| D-TEST-10 | Zero-tolerance flake policy: flakes get tracked issues, not retries | RESOLVED | test-strategy |
| D-TEST-11 | pytest-style arrange-act-assert convention | RESOLVED | CLAUDE.md |
| D-INFRA-1 | CI: format + import sort + build_runner + analyze + test | RESOLVED | CLAUDE.md |
| D-INFRA-2 | Pre-commit = format + import sort; pre-push = analyze + test | RESOLVED | CLAUDE.md |
| D-INFRA-3 | Strict analysis: strict-casts, strict-inference, strict-raw-types | RESOLVED | CLAUDE.md |
| D-INFRA-4 | Line length = 80 chars (dart format default) | RESOLVED | CLAUDE.md |
| D-INFRA-5 | Dependency additions require written justification + pin | RESOLVED | rebuild-strategy App-A |
| D-INFRA-6 | Legacy-identifier grep CI check (forbidden names list) | RESOLVED | rebuild-strategy L2 |
| D-INFRA-7 | docs/baseline.md is single source of truth for metrics | RESOLVED | rebuild-strategy L13 |
| D-INFRA-8 | docs/wiring-map.md as living wiring contract | RESOLVED | rebuild-strategy P9 |
| D-META-1 | Do NOT start the rewrite yet; complete planning docs first | RESOLVED | — |
| D-META-2 | Pre-alpha: no backwards-compatibility guarantees | RESOLVED | spec 00 |
| D-META-3 | Riverpod + GoRouter + Flutter state architecture | RESOLVED | spec 00 |
| D-META-4 | Feature-first directory layout with controller/screen/repository | RESOLVED | spec 00 |
| D-META-5 | Fail loud: raise errors, don't silently swallow | RESOLVED | CLAUDE.md |
| D-META-6 | Ownership manifest: one agent per file per phase | RESOLVED | rebuild-strategy L5 |
| D-META-7 | Spec-to-test matrix required; no orphan tests or paragraphs | RESOLVED | rebuild-strategy P8 |
| D-META-8 | Stubbed code MUST throw UnimplementedError (not return null) | RESOLVED | rebuild-strategy P6 |
| D-META-9 | Sealed switches over manual dispatch tables (exhaustive) | RESOLVED | rebuild-strategy L9 |
| D-META-10 | Default values in Dart via `arg ?? defaultValue` pattern | RESOLVED | CLAUDE.md |
| D-META-11 | DE-1 through DE-4 all ship in v1 (no v1.1 deferral) | RESOLVED | closes D-OPEN-5 |
| D-META-12 | DE-5 (home widget) = DONE; spec 11 status-updated | RESOLVED | closes DE-5 |
| D-META-13 | Release progression: GitHub → Internal/TestFlight → Open → Production | RESOLVED | — |
| D-SAFETY-23 | Fake-call voice = TTS-only in v1; human-recorded deferred | RESOLVED | closes D-OPEN-13 |
| D-SAFETY-24 | Stealth "forbidden word" list: NOT shipped; trust the user | RESOLVED | closes D-OPEN-9 |
| D-UX-34 | "This was a false alarm" feedback on past-event detail screen | RESOLVED | new feature |
| D-ENGINE-22 | Session recovery dialog = detailed; NO auto-resume ever | RESOLVED | closes D-OPEN-10 |
| D-SEC-10 | PIN hashing = Argon2id (64 MB / 3 iter / 4 lanes) | RESOLVED | closes D-OPEN-7 |
| D-SEC-11 | Wrong-PIN: 0.5s delay; default 30→5min lockout; opt-in 10→distress | RESOLVED | closes D-OPEN-8 |
| D-SERVICES-17 | Telemetry provider = Sentry (EU host option, not Firebase) | RESOLVED | closes D-OPEN-11 |
| D-SERVICES-18 | Emergency number DB = `emergency_numbers` package, quarterly audit | RESOLVED | closes D-OPEN-14 |
| D-SERVICES-19 | iOS Critical Alert entitlement applied at v1 launch | RESOLVED | closes D-OPEN-12 |
| D-INFRA-9 | Real-device CI = GitHub Actions per-PR + Firebase Test Lab on release | RESOLVED | closes D-OPEN-6 |
| D-TEST-12 | Golden-image review: strict pixel-match; `--update-goldens` = explicit | RESOLVED | closes D-OPEN-15 |
| D-TEST-13 | Test fixtures: factory functions for simple, JSON fixtures for complex | RESOLVED | — |
| D-TEST-14 | `mocktail` = only where fakes are impractical (platform boundaries) | RESOLVED | refines D-TEST-8 |
| D-DATA-21 | DistressChain extracted from AppDefaults into dedicated repo + editor UI | RESOLVED | supersedes D-DATA-2 |
| D-UX-35 | SMS step contact picker = per-contact buttons with channel-gated graying | RESOLVED | new feature |

**Status summary as of 2026-04-20 (Round 3 + D-OPEN-4 closed + DistressChain extraction + SMS picker rework):**

- RESOLVED: 183 (was 181, +2 from D-DATA-21 distress-chain extraction and D-UX-35 SMS contact buttons)
- REJECTED: 2 (detailed entries: D-SEC-8 panic wipe, D-SEC-9 app identity concealment)
- DEFERRED: 3 — D-OPEN-1 (beta cohort), D-OPEN-2 (Play/App Store account ownership),
  D-OPEN-3 (Ask for Angela outreach) — all deferred to rebuild Phase 9. Not engineering blockers.
- SUPERSEDED: 1 — D-DATA-2 (AppDefaults.distressChains list) superseded by D-DATA-21 (dedicated repo). Spec iOS-16 → iOS-17 and spec 00 "no analytics" line are inline-superseded without a numbered SUPERSEDED entry (old positions remain callable).
- Additional rejected alternatives (REJ-1 through REJ-28) documented in "Rejected options (with reasoning)" — these are not assigned D-IDs because they were never adopted.

**Grand total:** 185 decision entries + 3 deferred questions + 28 rejected alternatives = 216 items recorded.

---

## Detailed decisions

Entries are grouped alphabetically by category. Each entry provides
context, alternatives, rationale, implications, and references.

---

### Platform, storage, deployment (PLATFORM)

#### D-PLATFORM-1: Storage engine = Drift (SQLite) with encryption

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** The v6 codebase stored every model as a JSON string in an
  encrypted Hive `Box<String>`. Spec 03 described a Hive `@HiveType`
  adapter model that was never implemented (see audit Q1). We need a
  storage engine choice for the next rewrite.
- **Alternatives considered:**
  1. Hive CE (v6 direction). Maintenance risk (original Hive
     unmaintained; CE fork exists but uptake uneven).
  2. Isar. Faster, but +10MB binary cost, less transparent schema model.
  3. Sembast. Less mature, smaller ecosystem.
  4. Drift (SQLite) with `sqlcipher_flutter_libs` for encryption.
- **Decision:** Use **Drift (SQLite)** with encryption provided by
  `sqlcipher_flutter_libs`.
- **Rationale:** Typed SQL models, well-understood migrations,
  reactive streams, active maintenance, negligible speed cost for the
  expected 100–200 ops/day per user. Schema migrations are explicit,
  which is valuable for a safety-critical app.
- **Implications:**
  - Spec 03 ("Data Models"), spec 08 ("Decisions Consolidated"), the
    glossary, and any doc mentioning `@HiveType` MUST be rewritten.
  - Repositories change from `JsonListRepository<T>` to Drift DAOs.
  - The "nuke and reseed on schema mismatch" (D-DATA-9) remains, now
    implemented via dropping tables rather than clearing boxes.
- **References:** audit Q1; rebuild-strategy phase 2 ("Models &
  Repositories"); appendix A dependency list (replace hive_ce/hive_ce_flutter
  with drift + sqlcipher_flutter_libs).

#### D-PLATFORM-2: iOS minimum = iOS 17+

- **Status:** RESOLVED — supersedes spec 00 ("iOS 16.0+")
- **Date:** 2026-04-20
- **Context:** Spec 00 and spec 08 listed "iOS 16.0+" as the minimum
  target. iOS 17 unlocks full AppIntent-based interactive home widgets
  without a URL-scheme fallback.
- **Alternatives considered:** Keep iOS 16 (requires fallback UX for
  widget buttons via deep-link URL).
- **Decision:** Drop iOS 16 support. Minimum = **iOS 17+**.
- **Rationale:** Enables the widget story to be single-path (no iOS-16
  fallback code), simplifies QA, tracks 90%+ of active iOS devices at
  launch time (April 2026+).
- **Implications:**
  - Spec 00 "Platform Targets" table updated; spec 08
    "Minimum Versions" updated; appendix A `home_widget` pin rationale
    updated (AppIntent always available).
  - Removes the need for deep-link widget-button fallback (was called
    out in rebuild-strategy phase 9).
- **References:** rebuild-strategy section 8 question 2 (closes it).

#### D-PLATFORM-3: Launch all 14 languages at v1

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** rebuild-strategy question 5 asked whether v1 could launch
  with 5 languages (en, de, es, fr, zh) and add the other 9 in v1.1.
- **Alternatives considered:** 5-language launch; phased rollout.
- **Decision:** Launch **all 14 languages** simultaneously at v1 (en,
  de, es, fr, ru, zh, zh_TW, hi, fa, uk, pl, el, ar, he).
- **Rationale:** User accepts translation-lag risk. Safety app serving
  marginalised groups should not gate life-saving functionality on
  language. Translator-subagent pipeline is already built.
- **Implications:** CI MUST enforce ARB key parity (D-I18N-4). RTL
  goldens (fa, ar, he) are mandatory (D-TEST-3).
- **References:** D-I18N-1; rebuild-strategy phase 8.

#### D-PLATFORM-4: Clean-slate rewrite, no v6 → v7 data migration

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** rebuild-strategy question 1 — migrate v6 users' data on
  upgrade, or fresh install?
- **Alternatives considered:** Write a one-shot migration adapter from
  v6 JSON-in-Hive → v7 Drift. Estimated 20–30 engineer-hours of
  development + equal test time.
- **Decision:** **Fresh install. No migration code.**
- **Rationale:** App is pre-alpha, zero real users. Every migration
  engineering hour is unspent testing-safety hour. "Nuke on schema
  mismatch" is already the policy (D-DATA-9).
- **Implications:** No migration adapter; no legacy-field compat; spec
  on migration reduced to "schema change = drop + reseed".
- **References:** spec 11 DE-5; rebuild-strategy phase 2 step 6.

#### D-PLATFORM-5: Keep app name "Guardian Angela"

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** Medium trademark risk per spec 00 §"Trademark Risk
  Assessment" (Ask for Angela CIC; multiple existing "Guardian Angel"
  apps). rebuild-strategy question 7 asked whether the conversation
  with the Ask for Angela campaign has happened.
- **Alternatives considered:** Rename to avoid brand collision; dual
  name + disclaimer; contact Ask for Angela pre-launch.
- **Decision:** **Keep "Guardian Angela".** Trademark risk is accepted.
- **Rationale:** Name encodes the product's cultural intent (Ask for
  Angela signal). Defence plan: pre-launch outreach, partnership
  offer, or rebrand if demand letter arrives.
- **Implications:** Pre-launch legal outreach is an open task owned
  outside engineering. No code impact.
- **References:** spec 00 §"Trademark Risk"; D-META-1 (rewrite-not-
  started, so no rename-blocker).

#### D-PLATFORM-6: Telemetry = opt-out, default ON

- **Status:** RESOLVED — supersedes spec 00 "no analytics by default"
- **Date:** 2026-04-20
- **Context:** rebuild-strategy question 8 (no analytics vs opt-in
  telemetry). spec 00 §"Privacy by Default" said "no analytics,
  no telemetry, no server uploads without explicit user opt-in".
- **Alternatives considered:** No telemetry ever; opt-in telemetry.
- **Decision:** **Standard crash + usage metrics, default ON, user can
  disable in Settings → Privacy.**
- **Rationale:** Safety-critical app; crash data is essential for
  identifying regressions that could fail a user in distress.
  Opt-out, not opt-in, because a user who never opens Settings still
  contributes diagnostic value — and opt-out respects autonomy.
- **Implications:** Privacy policy MUST explain what is collected
  (non-PII crash dumps, feature-usage counts, no content). UI Settings
  → Privacy gains a telemetry toggle. No location, no session content,
  no contacts, no logs are ever transmitted.
- **References:** overrides spec 00 §"Privacy by Default" first bullet.

#### D-PLATFORM-7: Android SMS = direct SEND_SMS (silent auto-send)

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** rebuild-strategy question 3 (url_launcher fallback vs
  SEND_SMS). review-bugs CRITICAL-3 (the v5 code used `sms:` URI via
  url_launcher, which silently opened the SMS app and waited for a tap
  — a catastrophic safety regression).
- **Alternatives considered:** `sms:` URI fallback (pretends to send
  but waits for user tap — unacceptable safety failure); always direct
  SEND_SMS; hybrid with runtime permission check.
- **Decision:** **Direct SEND_SMS** on Android; no url_launcher
  fallback in the real path.
- **Rationale:** The app's value proposition fails if SMS is silently
  not sent. A Play Store policy review is required; that is a legal /
  admin problem, not an engineering one.
- **Implications:**
  - Android manifest declares SEND_SMS permission.
  - Play Console submission MUST include a Safety app declaration and
    reviewer notes + demo video describing the dead-man's-switch use.
  - If Google rejects SEND_SMS, we escalate to policy appeal, not code
    workaround.
- **References:** review-bugs CRITICAL-3; spec 10 "SMS Auto-Send" row.

#### D-PLATFORM-8: Flutter SDK = latest stable, bump proactively

- **Status:** RESOLVED (Extra 16)
- **Date:** 2026-04-17 (Round 2)
- **Decision:** Pin to latest Flutter stable in `pubspec.yaml`
  `environment:` and the CI `flutter-action`; bump on every stable
  release; update dependencies in the same PR.
- **Rationale:** Extra 16 ("Flutter SDK version: bump to latest,
  allow newest packages"). Lagging dependencies accumulate tech debt.
- **Implications:** CI bumps are normal; regression tests catch break.
- **References:** Round-2 Extra 16; rebuild-strategy appendix A.

#### D-PLATFORM-9: Android min API = 26

- **Status:** RESOLVED
- **Decision:** `minSdkVersion = 26`.
- **Rationale:** API 26 required for notification channels, which are
  a critical feature for stealth (innocuous channel names). spec 08.
- **References:** spec 08 §"Platform & Compatibility".

#### D-PLATFORM-10: Android target API = 35

- **Status:** RESOLVED
- **Decision:** `targetSdkVersion = 35`.
- **Rationale:** Google Play Store compliance; current target baseline.
- **References:** spec 08.

#### D-PLATFORM-11: Scope = Android + iOS only

- **Status:** RESOLVED
- **Decision:** No web, no desktop, no wear/TV.
- **Rationale:** Mobile-first safety app; 95%+ device coverage;
  web/desktop features (hardware button, CallKit, WorkManager) not
  applicable.
- **References:** spec 00 §"Platform Targets"; spec 08.

---

### Safety / behavioural (SAFETY)

#### D-SAFETY-1: Bundle comprehensive emergency-number database

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** rebuild-strategy question 11 (SIM vs bundled lookup vs
  manual). Emergency numbers vary by country and territory (112 EU,
  911 NA, 999 UK, 000 AU, and 80+ others).
- **Alternatives considered:** (a) SIM-based auto-detect (unreliable
  abroad, SIM country ≠ user location); (b) bundled lookup by current
  country code (requires geocoding); (c) user-configured per mode;
  (d) hybrid: bundled DB with per-country override.
- **Decision:** **Bundle a comprehensive emergency-number database**
  covering all countries + territories. Resolution at session time
  uses (i) user override if set, else (ii) current-country lookup from
  the bundled DB, else (iii) 112 as a global fallback.
- **Rationale:** Offline-first (no network dependency). Safest default
  when the user is travelling and doesn't think to update settings.
- **Implications:**
  - Add an `assets/emergency_numbers.json` (or equivalent) keyed by
    ISO 3166-1 alpha-2 code with entries like
    `"CH": {"police": "117", "ambulance": "144", "fire": "118",
    "general": "112"}`.
  - Data sourced from a public-domain reference (e.g., Wikipedia
    "List of emergency telephone numbers").
  - License & attribution noted in the About screen.
- **References:** spec 08 "Emergency Number Management" (stricter).

#### D-SAFETY-2: Backup = user content selector + optional PIN encryption

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** rebuild-strategy question 6 (backup format); test-strategy
  question 5 (PIN hashes in backup). Prior decisions: Extras 19 (PII
  toggle on export), 34 (exclude media by default), 47 (per-log
  medical flag).
- **Alternatives considered:** (a) always-full backup; (b) always-
  stripped backup (never PIN hashes); (c) user-selected categories.
- **Decision:** **User-controlled content selector** on Backup screen.
  Categories: contacts, profile/medical, session logs, app settings,
  reminder templates, modes, PIN hashes. Each category independently
  included/excluded. Optional backup password (separate from any in-app
  PIN) encrypts the entire archive.
- **Rationale:** One size does not fit all (sharing config with a
  partner ≠ transferring your entire identity to a new phone).
- **Implications:**
  - **Explicit warning** shown when a user includes PIN hashes AND does
    NOT set a backup password: "PIN hashes without a backup password
    are offline-brute-forceable. Set a password or exclude PIN hashes."
  - Backup file format: JSON wrapped in an encrypted envelope when
    password set; pure JSON otherwise.
  - `schemaVersion` top-level field (TEST-140).
- **References:** Round-2 Extras 19, 34, 47; test-strategy TEST-140..143;
  closes test-strategy Q5.

#### D-SAFETY-3: Battery alert with zero contacts = refuse to enable

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** rebuild-strategy question 13. Battery alert is a
  one-shot side-action that sends SMS when the battery crosses a
  threshold. If there are no contacts, "send SMS" is a no-op.
- **Alternatives considered:** (a) fire alert silently (degrades
  gracefully); (b) fire alert, show in-app toast; (c) hide toggle
  entirely; (d) disable toggle with a CTA.
- **Decision:** **Refuse to enable the toggle. Disable it in UI with a
  CTA to add a contact first.**
- **Rationale:** An "enabled" toggle that does nothing is a safety
  trap — the user believes they are covered when they are not.
- **Implications:**
  - Battery Alert settings screen checks contact count on render; if
    zero, the enable switch is disabled + a message "Add at least one
    emergency contact to enable battery alerts" with an "Add contact"
    button.
- **References:** spec 00 §9; spec 08.

#### D-SAFETY-4: Stealth UI = quick toggle inline + detailed /settings/stealth

- **Status:** RESOLVED (closes audit Q6)
- **Date:** 2026-04-20
- **Context:** Audit Q6 — spec 06 was self-contradictory (both
  collapsible inline card AND dedicated subroute). Code used the
  subroute only.
- **Alternatives considered:** (a) subroute only (code-matches); (b)
  inline collapsible only; (c) both.
- **Decision:** **Both.** A quick-toggle (enabled / disabled + fake
  name preview) inline on `/settings`, AND a dedicated
  `/settings/stealth` for full config.
- **Rationale:** Quick-toggle supports the common case ("I want to hide
  this now"); detailed screen is for setup. Small code cost, maximum
  UX. Matches the "defaults submenu + inline quick summary" pattern
  used elsewhere.
- **Implications:** Spec 06 updated to describe both. Stealth quick
  toggle must reflect state across both screens (shared provider).
- **References:** audit Q6.

#### D-SAFETY-5: Simulation silent = always ON at start, no cross-session persistence

- **Status:** RESOLVED
- **Date:** 2026-04-20 (reconfirms Extra 49)
- **Context:** Round-2 Extra 49 already set silent=ON at start; the
  rebuild-strategy question 14 asked for confirmation.
- **Decision:** **Silent toggle is ON at the start of every simulation
  session. Toggle state is not persisted between sessions.**
- **Rationale:** Default-silent respects shared environments (offices,
  public transit). Power users can toggle OFF each run.
- **Implications:** Code must re-initialise the toggle to ON at
  simulation start, not read from SharedPreferences/Drift.
- **References:** Round-2 Extra 49; spec 00 §"Simulation Mode".

#### D-SAFETY-6: Session-log retention = user-configurable; critical logs kept forever

- **Status:** RESOLVED (refines Round-2 B8)
- **Date:** 2026-04-20
- **Context:** B8 said "180 days default, unlimited if critical event";
  rebuild-strategy question 12 asked whether "unlimited" means "until
  user deletes" or "until device space low".
- **Decision:** **Default 180 days. User selects 30 / 90 / 180 / 365 /
  unlimited. Logs flagged as critical (triggered SMS, call, or distress
  chain) are ALWAYS kept regardless of the setting — smart retention.**
  "Unlimited" means until the user manually deletes the log.
- **Rationale:** Police reports or evidence may be needed years later.
  A routine "walked home, nothing happened" log holds less value.
- **Implications:**
  - `AppSettings.sessionLogRetentionDays` accepts enum-like values
    including sentinel 0 = unlimited.
  - `SessionLog` gains an `isCritical` flag (derived from events or
    persisted).
  - Purge job runs on session end; skips `isCritical=true` entries.
- **References:** Round-2 B8; test-strategy §4.5.

#### D-SAFETY-7: Fake-call decline default = safe (resets chain)

- **Status:** RESOLVED (A1)
- **Decision:** `FakeCallConfig.declineIsSafe = true` — declining the
  fake call resets the chain to step 0.
- **Rationale:** User who declines is implicitly saying "I'm not in
  trouble, this is fine." Safer UX than treating decline as a miss.
- **References:** Round-2 A1; spec 02.

#### D-SAFETY-8: Real call during emergency countdown = pause, resume after

- **Status:** RESOLVED (A2)
- **Decision:** Engine pauses when a real incoming call is detected;
  countdown resumes exactly from where it paused when the call ends.
- **Rationale:** Prevents double-attention conflict and lets the user
  take the real call (possibly from the contact being escalated to).
- **References:** Round-2 A2; spec 01.

#### D-SAFETY-9: Wrong PIN in distress cancel window = shake + threshold-fires-distress

- **Status:** RESOLVED (A3)
- **Decision:** Wrong PIN during the 5-second distress-cancel window
  shakes the keypad and shows a toast. After `wrongPinThreshold` wrong
  PINs (default 5, user-configurable), distress auto-confirms (fail-
  safe).
- **Rationale:** An attacker guessing PINs triggers distress faster,
  not delays it. Fail-closed.
- **References:** Round-2 A3; test-strategy TEST-025.

#### D-SAFETY-10: Duress PIN during active distress chain = no-op

- **Status:** RESOLVED (A4)
- **Decision:** Entering the duress PIN when a distress chain is
  already running is a no-op (idempotent).
- **Rationale:** Distress is already underway; no escalation path left.
- **References:** Round-2 A4.

#### D-SAFETY-11: Disarm with queued SMS = cancel WorkManager

- **Status:** RESOLVED (A5)
- **Decision:** On disarm, any pending `SmsWorker` WorkManager job that
  has NOT yet sent is cancelled.
- **Rationale:** The user ended the session because it was a false
  positive; do not flood their contacts with a stale alert.
- **Implications:** Already-delivered SMS cannot be unsent.
- **References:** Round-2 A5; test-strategy TEST-105.

#### D-SAFETY-12: Max pause duration = unlimited

- **Status:** RESOLVED (A6)
- **Decision:** No system-enforced cap on pause. User controls duration.
- **Rationale:** Legitimate long pauses (longer real call, emergency
  at restaurant) must not auto-resume and trigger escalation.
- **References:** Round-2 A6; D-ENGINE-12.

#### D-SAFETY-13: GPS denied + chain includes location = block session start

- **Status:** RESOLVED (Extra 12)
- **Decision:** If the mode's chain references `{location}` in an SMS
  template or uses `includeLocation`, and the user has denied location
  permission, real-session start is blocked with a "grant permission
  or edit chain" UI.
- **Rationale:** Silent no-location SMS is a safety lie.
- **References:** Round-2 Extra 12.

#### D-SAFETY-14: Force-close mid-session = recovery dialog, no resume

- **Status:** RESOLVED (Extra 13)
- **Decision:** On next launch after an abnormal session termination,
  show a recovery dialog summarising which step was active; do NOT
  resume the session.
- **Rationale:** Resuming a possibly-stale session is more dangerous
  than making the user start fresh.
- **References:** Round-2 Extra 13; test-strategy TEST-102.

#### D-SAFETY-15: WorkManager SMS retries exhausted = notify user

- **Status:** RESOLVED (Extra 14)
- **Decision:** When WorkManager gives up on an SMS (exponential
  backoff limit reached), post a system notification: "SMS to Alice
  never sent — tap to retry manually."
- **Rationale:** Silent failure = user believes a contact was notified.
- **References:** Round-2 Extra 14.

#### D-SAFETY-16: Missing permission at session start = block with grant prompt

- **Status:** RESOLVED (Extra 44)
- **Decision:** If the chain requires a permission that is not granted,
  block session start and display a list of missing permissions with
  per-permission grant buttons.
- **Rationale:** Safety-invariant: no silent-fail escalation.
- **References:** Round-2 Extra 44.

#### D-SAFETY-17: Missing distressChainId at session start = block + warn on delete

- **Status:** RESOLVED (Extra 64)
- **Decision:** If a mode's `distressChainId` points at a non-existent
  chain, block session start. When deleting a distress chain, warn if
  any mode still references it.
- **Rationale:** Distress chain is the safety-of-last-resort; a broken
  reference = no safety.
- **References:** Round-2 Extra 64; test-strategy TEST-045.

#### D-SAFETY-18: Emergency number change blocked during session

- **Status:** RESOLVED (Extra 20)
- **Decision:** Emergency number (and other session-affecting settings)
  cannot be changed while a session is running. UI disables the field.
- **Rationale:** Changing mid-session could route the next call to the
  wrong number.
- **References:** Round-2 Extra 20; spec 00 §"Session Locks".

#### D-SAFETY-19: Real call over FakeCallScreen = dismiss fake, show real

- **Status:** RESOLVED (Extra 29)
- **Decision:** Real incoming call during an active fake call UI
  dismisses the fake and lets the real system call UI take over.
- **Rationale:** Real calls must not be blocked by our fake UI.
- **References:** Round-2 Extra 29.

#### D-SAFETY-20: Real call ends during fakeCall step = resume where paused

- **Status:** RESOLVED (Extra 30)
- **Decision:** When a real call ends during the fakeCall step, the
  fake-call step resumes from the point it was paused at.
- **Rationale:** Preserves the rehearsed escalation flow.
- **References:** Round-2 Extra 30; D-SAFETY-8.

#### D-SAFETY-21: Real call during holdButton = auto-pause, resume exact state

- **Status:** RESOLVED (Extra 31)
- **Decision:** Real call auto-pauses the session; resuming restores
  the exact hold/grace remaining time.
- **References:** Round-2 Extra 31.

#### D-SAFETY-22: Duress PIN at App PIN = unlock + fire distress silently

- **Status:** RESOLVED (Extra 53)
- **Decision:** Entering the duress PIN at the App PIN prompt unlocks
  the app normally AND silently fires the distress chain in the
  background.
- **Rationale:** The attacker coerced the unlock; the user needs an
  invisible panic path.
- **References:** Round-2 Extra 53; D-SEC-1.

#### D-SAFETY-23: Fake-call voice = TTS-only in v1; human recording post-v1

- **Status:** RESOLVED (closes D-OPEN-13)
- **Date:** 2026-04-20
- **Context:** D-OPEN-13 flagged per-language voice asset
  (`assets/voice/angela_<lang>.m4a`) sourcing, talent licensing, and
  script recording as unresolved. `flutter_tts` is already wired.
- **Alternatives considered:**
  1. Ship v1 with bundled human recordings in all 14 languages
     (~$30-80k budget; 14 native talents; per-locale script review;
     licensing and re-recording cost on script changes).
  2. Ship v1 with TTS only; add human recording later as an
     enhancement if/when community-sourced or professionally-sourced
     talent becomes available per-locale.
  3. Ship v1 with English human recording + TTS fallback for the
     other 13 languages.
- **Decision:** **Option 2 — TTS only in v1.** `flutter_tts` generates
  per-locale phrase maps from a localised script. Per-locale fake
  call voice lines come from ARB keys (e.g., `fakeCallGreeting`,
  `fakeCallReassurance`).
- **Rationale:**
  - Zero licensing risk (no per-locale voice talent contracts).
  - Zero re-recording cost when a script edit happens — ARB update
    triggers the existing 13-language translator pipeline.
  - `flutter_tts` quality in 2026 is acceptable for the rehearsed-
    fake-call scenario (user knows the voice is synthesised — the
    goal is an external observer's perception, not the user's).
  - Human recording remains on the post-v1 enhancement roadmap; if
    volunteer or budget-funded talent appears, we add them as optional
    per-locale audio assets that override the TTS path.
- **Implications:**
  - Fake-call voice asset paths (`assets/voice/*.m4a`) remain in spec
    11 as deferred enhancements, but the v1 default voice pipeline is
    TTS.
  - Tests: `FakeCallStrategy` has a TTS-backed fake by default; the
    human-recording path remains testable via protocol injection.
  - No voice-talent open question remains for v1.
- **References:** D-SERVICES-2 (built-in voice per-language); spec 11
  DE-voice; `lib/services/implementations/text_to_speech_service.dart`.

#### D-SAFETY-24: Stealth "forbidden word" list = NOT shipped (trust the user)

- **Status:** RESOLVED (closes D-OPEN-9)
- **Date:** 2026-04-20
- **Context:** D-OPEN-9 asked whether a forbidden-word list for
  stealth fake-name validation lives in `lib/` (visible in the binary,
  attacker-discoverable) or test-only (guides tests without leaking
  vocabulary into the APK). TEST-252 needs the list regardless.
- **Alternatives considered:**
  1. Ship a curated list of "branding words" (e.g., "guardian",
     "angela", "safety", "disarm", "panic") in `lib/core/constants/`
     with a runtime validator refusing those fake names.
  2. Ship the list test-only (in `test/fixtures/stealth_forbidden.dart`)
     for TEST-252 + l10n stealth goldens, with no runtime enforcement.
  3. Do not ship a list at all. Trust the user to pick a mundane
     disguise name (Music, Calendar, Delivery). Document the guideline
     in the help tooltip next to the fake-name field.
- **Decision:** **Option 3 — no forbidden-word list anywhere.** Help
  text on the fake-name input field: "Pick a mundane name like Music,
  Calendar, or Delivery. Names with 'safety', 'panic', or the app
  brand defeat the purpose." No runtime validation. TEST-252 is
  dropped as an enforced test; replaced by a developer-facing golden-
  review checklist item ("any stealth UI change requires visual
  sign-off that no brand vocabulary is visible").
- **Rationale:**
  - Guardian Angela's security posture is "not afraid of attackers"
    (see D-SEC-11). A user hostile enough to attack a safety app by
    dumping the binary for a forbidden-word list already bypasses
    most of our stealth model.
  - A forbidden list can never be complete — users customise in 14
    languages, synonyms are infinite, and "forbidden" vs "allowed" is
    inherently fuzzy.
  - Trusting the user with guidance text matches the app's friendly-
    default philosophy (D-SEC-11).
- **Implications:**
  - TEST-252 (test-strategy §5.25) is replaced by a weaker
    documentary check: the stealth-golden review checklist. No
    automated assertion of forbidden vocabulary.
  - `app_en.arb` gains a `stealthFakeNameHelpText` key describing
    the guideline; translator pipeline localises it.
  - No change in code under `lib/core/constants/`.
- **References:** D-OPEN-9 (closed); test-strategy §5.25 TEST-252
  (superseded); D-SEC-11.

---

### UX / interaction (UX)

#### D-UX-1: Hold button countdown on re-hold = cancel + restart

- **Status:** RESOLVED (D1)
- **Decision:** Releasing the hold button starts a grace countdown;
  re-grabbing cancels and, on next release, starts a fresh countdown
  from `durationSeconds`.
- **References:** Round-2 D1.

#### D-UX-2: Simulation Leap = 1s countdown to next event

- **Status:** RESOLVED (D2)
- **Decision:** "Leap" replaces the active timer with a 1-second
  countdown (skip to 1s before next event).
- **References:** Round-2 D2; TEST-006.

#### D-UX-3: Rotation = portrait lock on session + fake call

- **Status:** RESOLVED (D3)
- **Decision:** `SessionScreen` and `FakeCallScreen` are locked to
  portrait. Other screens rotate freely.
- **Rationale:** Critical safety screens must not re-lay-out mid-
  emergency.
- **References:** Round-2 D3.

#### D-UX-4: Disguised reminder early tap = configurable per step

- **Status:** RESOLVED (D4)
- **Decision:** `DisguisedReminderConfig.resetOnEarlyCheckIn` (default
  `true`) controls whether tapping the notification during the wait
  phase counts as an early check-in and resets the timer.
- **References:** Round-2 D4.

#### D-UX-5: Stealth sub-options always visible when master OFF

- **Status:** RESOLVED (D5)
- **Decision:** Stealth sub-option controls stay visible and editable
  even when `StealthConfig.enabled = false`, so users can pre-configure.
- **References:** Round-2 D5.

#### D-UX-6: Fake stealth app name default = "Music"

- **Status:** RESOLVED (Extra 23)
- **Decision:** `StealthConfig.fakeName` default = "Music".
- **References:** Round-2 Extra 23.

#### D-UX-7: Stealth notification icon = music icon by default

- **Status:** RESOLVED (Extra 33)
- **Decision:** Default `StealthConfig.fakeIcon` = music-glyph icon.
  User-configurable.
- **References:** Round-2 Extra 33.

#### D-UX-8: Emergency call confirmation cancel = swipe slider

- **Status:** RESOLVED (Extra 56)
- **Decision:** Cancel-emergency-call control is a swipe slider (not a
  tap button) to prevent accidental cancellation.
- **References:** Round-2 Extra 56.

#### D-UX-9: Auto theme switching = NO

- **Status:** RESOLVED (Extra 58)
- **Decision:** User explicitly picks light / dark / system.
- **References:** Round-2 Extra 58; D-META-3.

#### D-UX-33: App theme default = System (follow OS)

- **Status:** RESOLVED (B6)
- **Decision:** `AppSettings.theme` defaults to `ThemeMode.system`
  (follow device OS preference).
- **Rationale:** Least-surprise default; respects user's OS-level
  accessibility / comfort choice.
- **References:** Round-2 B6.

#### D-UX-34: "This was a false alarm" feedback on past-event detail

- **Status:** RESOLVED (new feature)
- **Date:** 2026-04-20
- **Context:** Distress chains and escalations are sometimes
  false alarms (phone dropped mid-walk; hardware-button press
  misfire; user safe but chain fired). Currently a user has no
  structured way to tell the app "this one was a false alarm" so
  future engine-tuning work can reduce false positives.
- **Alternatives considered:**
  1. Do nothing; assume we learn from anonymised session logs via
     telemetry (D-SERVICES-17).
  2. Ship a dedicated feedback screen.
  3. Add a one-tap "This was a false alarm" button inline on the
     PastEventDetail screen that records `wasFalseAlarm=true` on
     the log + opens an optional free-text field for the reason.
- **Decision:** **Option 3.** Past-event detail screen gains a
  "This was a false alarm" button at the bottom. Tap flow:
  (a) marks the log with `wasFalseAlarm: true`, (b) prompts an
  optional "why?" free-text (no character limit, optional), (c)
  appends the reason to the log, (d) when telemetry is on
  (D-PLATFORM-6), also emits a Sentry custom event
  `false_alarm_reported` with the anonymised reason and the chain
  shape that led to the false alarm (event-type sequence, not
  contact names).
- **Rationale:**
  - Aligns with the app's core design principle "minimise false
    positives — err toward NOT escalating" (per `feedback_false_
    positives.md` user memory).
  - User signal is the highest-quality data we can get for tuning
    engine parameters (hold-button sensitivity, hardware-panic
    press count, grace periods).
  - Inline on past-event detail (not a separate feedback form) =
    lowest friction.
- **Implications:**
  - `SessionLog` gains a nullable `wasFalseAlarm` bool + a
    nullable `falseAlarmReason` string.
  - Drift migration (P11 rule) bumps schema version.
  - `PastEventDetailScreen` gains the button + the text-field
    sheet. New ARB keys: `falseAlarmButton`, `falseAlarmPromptTitle`,
    `falseAlarmPromptHint`, `falseAlarmThanks`.
  - Sentry integration (D-SERVICES-17) — custom event name fixed
    as `false_alarm_reported`; payload = anonymised reason +
    chain-shape digest, no PII.
  - Backup inclusion: false-alarm flag + reason travel with the
    SessionLog entity per existing Backup content selector rules
    (D-SAFETY-2).
- **References:** D-SERVICES-17 (Sentry channel); D-SAFETY-6
  (session-log retention); user memory "feedback_false_positives".

#### D-UX-35: SMS step contact picker = per-contact buttons with channel-gated graying

- **Status:** RESOLVED (new feature)
- **Date:** 2026-04-20
- **Context:** The SMS-step editor (inside `_SmsContactForm` in
  `lib/features/modes/widgets/event_specific_config.dart`) used a
  three-option dropdown — `{allContacts, firstContact, specificIds}` —
  to decide which contacts receive the step's SMS. User testing and
  review showed the dropdown was opaque: users had to mentally map
  "All / First / Specific" to concrete contacts, with no feedback about
  which contacts actually supported the step's `channel` (SMS vs
  WhatsApp vs Telegram per D-DATA-7). The greying that was supposed to
  happen "in the picker" (D-DATA-7) was not surfaced clearly by the
  dropdown, allowing mis-configuration where a user could pick a
  contact that lacked the selected channel.
- **Alternatives considered:**
  1. Keep the dropdown and only fix its labels / help text.
  2. Keep the dropdown but add a separate "select specific contacts"
     multi-select sheet that honours channel-gating.
  3. Replace the dropdown with a row of per-contact buttons that
     reflect channel support visually (enabled + ON by default if the
     contact has the step's channel; disabled + grayed otherwise) and
     infer the `contactSelection` enum at save time from the button
     states.
- **Decision:** **Option 3.** The `_SmsContactForm` editor replaces
  the dropdown with a row of per-contact buttons. Rules:
  - Contact's `channels` include the step's `channel` → button is
    enabled; ON by default; user may toggle off.
  - Contact's `channels` do NOT include the step's `channel` →
    button is disabled and rendered grayed out; cannot be toggled.
  - Save-time inference:
    - All channel-capable buttons on → persist as
      `contactSelection = allContacts`, `contactIds = null`.
    - Strict subset on → persist as
      `contactSelection = specificIds`, `contactIds = [selected ids]`.
    - The `firstContact` enum value is retained for backwards
      compatibility of the persisted model but is no longer reachable
      from the UI.
- **Rationale:**
  - Immediate visual feedback on which contacts will receive the
    step's SMS — no mental mapping from an abstract enum to concrete
    contacts.
  - Channel-gated graying enforces D-DATA-8 (channel validation at
    save) at the point of edit, not as a blocking dialog at save
    time — misconfiguration is prevented by construction.
  - Save-time inference keeps the persisted `SmsContactConfig` model
    unchanged (still `{contactSelection, contactIds}`), so there is
    no data-layer migration and no change to D-DATA-7.
- **Implications:**
  - `_SmsContactForm` inside `event_specific_config.dart` rebuilt to
    render a `Wrap` of `FilterChip`-style buttons (contact name label,
    selected/unselected/disabled visual states).
  - Channel-toggle on the step rebuilds the button row (enable/disable
    state flips per contact).
  - `firstContact` enum value kept in `SmsContactConfig` sealed config
    but no UI surface emits it; existing chains persisted with
    `firstContact` load and render (the first contact is shown as the
    only selected button) — no data migration.
  - Spec 03 / spec 05 (Modes editor UX) MUST be updated to describe
    the button row replacing the dropdown. Spec 07 (tests) MUST be
    updated with golden + widget tests for each button state.
  - New ARB keys are expected for tooltip text on disabled (grayed)
    buttons (e.g., "{contact} has no {channel} channel"). Localisation
    agent MUST translate per CLAUDE.md rules when strings land.
- **References:** D-DATA-7 (per-step channel); D-DATA-8 (channel
  validation at save); D-DATA-6 (contact channels list); spec 03
  §"SmsContactConfig"; review-bugs feedback that dropdown was opaque.

#### D-UX-10: Unsaved edits preserved across backgrounding, warn on exit

- **Status:** RESOLVED (Extra 59)
- **Decision:** Unsaved edits persist across app backgrounding; a
  dialog warns the user when they attempt to navigate away.
- **References:** Round-2 Extra 59.

#### D-UX-11: FakeCall answered with no voice recording = silent "Calling..."

- **Status:** RESOLVED (Extra 60)
- **Decision:** If `FakeCallConfig.voiceRecordingPath == null` AND no
  built-in language recording is available, show a silent "Calling..."
  screen until user hangs up.
- **References:** Round-2 Extra 60.

#### D-UX-12: Safety Setup Checklist on Home = collapsible banner

- **Status:** RESOLVED (Extra 63)
- **Decision:** Home screen shows a collapsible 6-item "Safety Setup"
  banner (dismissible) after onboarding.
- **References:** Round-2 Extra 63.

#### D-UX-13: End session from paused = PIN required if configured

- **Status:** RESOLVED (Extra 62)
- **Decision:** Ending the session from a paused state still requires
  the Session End PIN if one is configured. No special case.
- **References:** Round-2 Extra 62.

#### D-UX-14: Session Completed screen after normal end

- **Status:** RESOLVED (Extra 37)
- **Decision:** Normal session end shows `SessionCompletedScreen`
  ("Hope you're safe home") with "View Event Log" and "Return Home"
  buttons.
- **References:** Round-2 Extra 37; legacy notes.

#### D-UX-15: Language switch mid-app = instant rebuild

- **Status:** RESOLVED (Extra 43)
- **Decision:** Selecting a new language in Settings rebuilds the
  current screen immediately (no app restart).
- **References:** Round-2 Extra 43.

#### D-UX-16: Disguised reminder on locked device = full-screen wake

- **Status:** RESOLVED (Extra 35)
- **Decision:** Reminders fired while device is locked use full-screen
  intent / wake screen.
- **References:** Round-2 Extra 35.

#### D-UX-17: Reminder day/night = same behavior

- **Status:** RESOLVED (Extra 36)
- **Decision:** No quiet hours in v1; reminders fire the same way day
  or night.
- **References:** Round-2 Extra 36.

#### D-UX-18: fakeLockScreen wake = any touch

- **Status:** RESOLVED (Extra 40)
- **Decision:** Any touch anywhere on the `fakeLockScreen` counts as a
  hold / check-in.
- **References:** Round-2 Extra 40.

#### D-UX-19: Reminder template icons mimic real apps

- **Status:** RESOLVED (Extra 57)
- **Decision:** Each reminder template uses an icon mimicking the
  real app it impersonates (Calendar icon, Duolingo icon, etc.).
- **References:** Round-2 Extra 57.

#### D-UX-20: Strategy errors in log UI = user-visible red icon

- **Status:** RESOLVED (Extra 55)
- **Decision:** Strategy-level errors show as a red icon in the
  session log timeline with a human-readable summary.
- **References:** Round-2 Extra 55.

#### D-UX-21: Simulation chain exhausted = completion screen

- **Status:** RESOLVED (Extra 54)
- **Decision:** Simulation reaching `chainExhausted` shows the same
  completion screen as a real session.
- **References:** Round-2 Extra 54.

#### D-UX-22: Settings autosave

- **Status:** RESOLVED
- **Decision:** Settings changes autosave; no "Save" button.
- **References:** legacy notes (decisions-log v1).

#### D-UX-23: Info tooltips on non-obvious settings

- **Status:** RESOLVED
- **Decision:** All non-obvious settings have an "i" tooltip.
- **References:** legacy notes.

#### D-UX-24: Session log search + filter chips

- **Status:** RESOLVED (Extra 50)
- **Decision:** Past Events screen has full text search + filter chips
  (date, mode, outcome, simulation).
- **References:** Round-2 Extra 50.

#### D-UX-25: Session log soft delete + 7-day undo

- **Status:** RESOLVED (Extra 11)
- **Decision:** Deleting a session log moves it to a trash recoverable
  for 7 days; after that, purged.
- **References:** Round-2 Extra 11; test-strategy TEST-050..054.

#### D-UX-26: App PIN wrong attempts = no consequence

- **Status:** RESOLVED (Extra 10)
- **Decision:** Wrong App PIN entries have no penalty (unlike wrong
  Session End PIN which triggers distress). User may retry indefinitely.
- **Rationale:** App PIN is a convenience lock, not a safety lock.
- **References:** Round-2 Extra 10.

#### D-UX-27: Battery-optimisation prompt = always shown in onboarding

- **Status:** RESOLVED (Extra 38)
- **Decision:** Battery-optimisation exemption prompt is shown in
  onboarding regardless of device manufacturer.
- **References:** Round-2 Extra 38.

#### D-UX-28: Onboarding permission denial = skip allowed

- **Status:** RESOLVED (Extra 18)
- **Decision:** Onboarding permission prompts are skippable. Block at
  session start only if the session actually needs the missing
  permission. Explanations make the conditionality clear.
- **References:** Round-2 Extra 18; D-SAFETY-16.

#### D-UX-29: Android 13 notification permission = onboarding + re-ask on first session

- **Status:** RESOLVED (Extra 42)
- **Decision:** `POST_NOTIFICATIONS` is requested in onboarding; if
  denied, re-asked on first session start.
- **References:** Round-2 Extra 42.

#### D-UX-30: Delete-all-modes = empty state + CTA, no auto-reseed

- **Status:** RESOLVED (C5)
- **Decision:** When the user deletes all modes, show an empty state
  with a "Create from template" call-to-action. Do not auto-reseed.
- **Rationale:** Respects user intent to clear. They can re-create.
- **References:** Round-2 C5.

#### D-UX-31: Settings hub = /settings/defaults + /settings/modes-and-chains

- **Status:** RESOLVED (C6)
- **Decision:** Both a defaults hub and a modes-and-chains hub. Not
  one consolidated hub.
- **References:** Round-2 C6.

#### D-UX-32: "Use my number" button in onboarding

- **Status:** RESOLVED (Extra 28)
- **Decision:** Onboarding page 2 includes a "Use my number" button
  that reads the user's own phone number from SIM / device "Me" contact.
- **References:** Round-2 Extra 28.

---

### Data, models, persistence (DATA)

#### D-DATA-1: SessionMode.distressChainId references a global chain

- **Status:** RESOLVED (Extra 48 part 1)
- **Decision:** `SessionMode.distressChainId` is a nullable String. Null
  means "use first distress chain (default)". Non-null selects a global
  chain by ID.
- **References:** Round-2 Extra 48; spec 00 §9.

#### D-DATA-2: Multiple global distress chains; first = default

- **Status:** SUPERSEDED by D-DATA-21 (2026-04-20)
- **Decision (historical):** `AppDefaults.distressChains` is a list;
  first entry is the default when `distressChainId == null`.
- **Supersession note:** The list-in-AppDefaults storage model was
  replaced by a dedicated `JsonListRepository<DistressChain>` per
  D-DATA-21. The "first entry = default" semantics is retained, but
  now applies to the dedicated repository, not to an AppDefaults field.
- **References:** Round-2 Extra 48; D-DATA-21 (superseding entry).

#### D-DATA-3: ModeOverrides null field = inherit from AppDefaults

- **Status:** RESOLVED
- **Decision:** Every `ModeOverrides` field is nullable; null = inherit.
- **References:** spec 03; TEST-042.

#### D-DATA-4: Templates = global (AppDefaults) + mode-local (appended)

- **Status:** RESOLVED (C7)
- **Decision:** Reminder templates have two scopes: global (in
  `AppDefaults.templates`, available to every mode) and mode-local
  (in `ModeOverrides.localTemplates`, appended to globals). The existing
  `ReminderTemplate.isGlobal` flag distinguishes them.
- **References:** Round-2 C7.

#### D-DATA-5: SessionLog.hadMedicalInfo per-log flag

- **Status:** RESOLVED (Extra 47)
- **Decision:** Each `SessionLog` persists whether it was created with
  medical info. Exports follow the log's flag, not the current setting.
- **References:** Round-2 Extra 47.

#### D-DATA-6: Contacts: `channels` list + per-contact language; no preferredChannel

- **Status:** RESOLVED
- **Decision:** `EmergencyContact` has `List<MessageChannel> channels`
  plus `String? languageCode`, `String? relationship`. ALL enabled
  channels are used — no single "preferred channel".
- **References:** spec 03.

#### D-DATA-7: Each SMS step selects ONE channel; contacts without greyed out

- **Status:** RESOLVED (Extra 15 + 15b)
- **Decision:** `SmsContactConfig.channel` is a single `MessageChannel`.
  Contacts lacking that channel are greyed out in the picker.
- **References:** Round-2 Extras 15, 15b.

#### D-DATA-8: Channel validation at save

- **Status:** RESOLVED (Extra 15c)
- **Decision:** Saving a mode is blocked if the selected step channel
  is not supported by ANY selected contact. At runtime, a mismatched
  contact is logged and skipped (chain continues).
- **References:** Round-2 Extra 15c.

#### D-DATA-9: Schema mismatch = nuke + reseed

- **Status:** RESOLVED
- **Decision:** On schema mismatch, all data is dropped and reseeded
  from built-in defaults. No incremental migrations.
- **Rationale:** Pre-alpha simplicity; "atomic refactors" (rebuild-
  strategy L3).
- **References:** spec 03 §"Migration Strategy"; rebuild-strategy L3.

#### D-DATA-10: Step 0 type rules = any type allowed

- **Status:** RESOLVED (Extra 24)
- **Decision:** No constraint on what type the first chain step may be.
- **References:** Round-2 Extra 24.

#### D-DATA-11: Contact phone = free-form + warn + device import

- **Status:** RESOLVED (Extras 26 + 27)
- **Decision:** Phone field accepts any text; pattern-warn on
  suspicious input (non-digit, wrong length). E.164 (`+41...`) preferred.
  Users can import a contact from the device address book via a picker.
- **References:** Round-2 Extras 26, 27.

#### D-DATA-12: Emergency number = free-form + pattern-warn

- **Status:** RESOLVED (Extra 25)
- **Decision:** Emergency number free-form; pattern-warn if non-digit,
  too short, or too long. User can override.
- **References:** Round-2 Extra 25.

#### D-DATA-13: Multi-user profiles = single profile only

- **Status:** RESOLVED (Extra 61)
- **Decision:** One user profile per install. For multiple users,
  rely on OS user profiles (multi-user on Android, ScreenTime on iOS).
- **References:** Round-2 Extra 61.

#### D-DATA-14: PIN length = 4-8, same range for all three

- **Status:** RESOLVED (Extras 51 + 52)
- **Decision:** App, Session End, and Duress PINs each 4-8 digits; user
  picks length at setup time per PIN. Same range applies to all three.
- **References:** Round-2 Extras 51, 52.

#### D-DATA-15: Lost Hive key = data-loss dialog

- **Status:** RESOLVED (Extra 21)
- **Decision:** If the encryption key cannot be retrieved from secure
  storage, show a "Start fresh or restore from backup?" dialog.
- **References:** Round-2 Extra 21.

#### D-DATA-16: SMS queue persisted in Hive (encrypted)

- **Status:** RESOLVED (Extra 45) — now in Drift per D-PLATFORM-1
- **Decision:** The pending SMS queue is persisted in the encrypted
  local store (Drift per D-PLATFORM-1; was Hive previously) so it
  survives process restarts.
- **References:** Round-2 Extra 45; D-PLATFORM-1.

#### D-DATA-17: Backup export excludes media by default

- **Status:** RESOLVED (Extra 34)
- **Decision:** Audio recordings and other media are excluded from
  backup by default; user can opt in per D-SAFETY-2.
- **References:** Round-2 Extra 34.

#### D-DATA-18: Export PII in session logs = toggle per export

- **Status:** RESOLVED (Extra 19)
- **Decision:** A toggle at export time decides whether PII (contact
  names, numbers, precise locations) is included.
- **References:** Round-2 Extra 19.

#### D-DATA-19: Log every session start/end

- **Status:** RESOLVED (Extra 65)
- **Decision:** Every session start and end is logged, even trivial
  ones (walked home, nothing happened). Retention governs lifetime.
- **References:** Round-2 Extra 65; D-SAFETY-6.

#### D-DATA-20: SMS {name} fallback = "the owner of this phone"

- **Status:** RESOLVED (Extra 41)
- **Decision:** If user profile name is empty, `{name}` placeholder in
  SMS resolves to "the owner of this phone".
- **References:** Round-2 Extra 41.

#### D-DATA-21: DistressChain extracted from AppDefaults into dedicated repository + list/editor UI

- **Status:** RESOLVED (new feature; supersedes D-DATA-2)
- **Date:** 2026-04-20
- **Context:** D-DATA-2 defined `AppDefaults.distressChains` as a
  list field on the `AppDefaults` model, with the first entry serving
  as the default when `SessionMode.distressChainId == null`
  (D-DATA-1). In practice a distress chain is structurally identical
  to a `SessionMode`'s main chain (a `List<ChainStep>` with the same
  9 event types and same `StepConfig` sealed hierarchy). Nesting this
  kind of entity inside `AppDefaults` created a conceptual
  inconsistency: Modes are a top-level repository-backed entity with
  a list screen and per-entity editor, but distress chains — another
  list of named chain entities — were buried under "defaults" and
  had no dedicated list/editor. `AppDefaults` was also becoming an
  awkward super-entity mixing genuine cross-entity defaults (GPS
  logging, stealth, templates, event defaults) with first-class
  entities (distress chains).
- **Alternatives considered:**
  1. Keep `distressChains` inside `AppDefaults` and only improve
     the UI (add a better list/editor surface under
     `/settings/defaults/distress-chains`) without moving the data.
  2. Collapse the data model to a single distress chain per install
     (no list; just `AppDefaults.distressChain`). This would
     eliminate the inconsistency by removing multi-chain support
     entirely.
  3. Extract `distressChains` from `AppDefaults` into a dedicated
     `JsonListRepository<DistressChain>` backed by its own Hive box
     (`distress_chains.json`), mirroring the Modes pattern exactly.
     Add `DistressChainsScreen` (list) and `DistressChainEditorScreen`
     (full per-step config editor, same expansion-tile pattern as
     `ModeEditor`).
- **Decision:** **Option 3.** Distress chains become a first-class
  repository-backed entity:
  - New `JsonListRepository<DistressChain>` backed by a dedicated
    Hive box (`distress_chains.json`).
  - `AppDefaults.distressChains` field is REMOVED — no legacy field
    remains on `AppDefaults`.
  - `SessionMode.distressChainId` (unchanged per D-DATA-1) now
    references the dedicated repository. `null` = first chain in the
    dedicated repository (the default). Multi-chain semantics and
    "first = default" policy are retained from D-DATA-2, just moved.
  - New `DistressChainsScreen` lists all chains with add / rename /
    delete / reorder actions (first item is the default; reorder is
    how the default is chosen).
  - New `DistressChainEditorScreen` reuses the same expansion-tile
    per-step editor UI as `ModeEditor`, since the chain structure is
    identical.
  - Schema-mismatch policy per D-DATA-9 applies: on schema change
    the repository is dropped and reseeded from `seed_data.dart`.
    Pre-alpha nuke-and-reseed; no legacy shim, no migration code.
- **Rationale:**
  - Mirrors the Modes pattern (list screen + editor screen + typed
    repository), so a user learning one learns the other.
  - Keeps `AppDefaults` focused on true cross-entity defaults:
    `gpsLogging` (GpsLoggingConfig), `stealth` (StealthConfig),
    `templates`, `eventDefaults`. Distress chains are not a
    "default" — they are a named entity that modes reference.
  - Enables a better editor experience for distress chains — they
    deserve the same full per-step configuration UI that
    `SessionMode` chains get.
  - Alternative 1 rejected: leaves the conceptual inconsistency
    (why is one kind of chain nested under "defaults" and another
    kind lives in its own repo?) intact.
  - Alternative 2 rejected: multi-chain support already exists in
    the data model and mode-level distress override is a feature we
    ship in v1 (D-DATA-1, D-DATA-2).
- **Implications:**
  - `AppDefaults` model loses the `distressChains` field; JSON
    serialisation of `AppDefaults` changes → schema mismatch →
    nuke-and-reseed per D-DATA-9.
  - `AppSettings.defaults.distressChains` is no longer valid code;
    any reference MUST be replaced with a call to the new
    `DistressChainRepository`.
  - New route: `/settings/modes-and-chains/distress-chains` (list)
    and `/settings/modes-and-chains/distress-chains/:id` (editor);
    placed under the existing `/settings/modes-and-chains` hub per
    D-UX-31.
  - Seed data (`seed_data.dart`) gains a seeded default
    distress chain populated into the new repository on first run.
  - `SessionMode` continues to store `distressChainId` as a nullable
    String; the engine resolves it via the new repository (first
    entry when null).
  - D-DATA-2 marked SUPERSEDED (above); its "first = default"
    policy lives on in this entry.
  - Spec 03 ("Data Models"), spec 04 ("Modes"), spec 00 §9, spec
    08 ("Decisions Consolidated"), and CLAUDE.md's "Models & Hive"
    paragraph MUST be updated to remove
    `AppDefaults.distressChains` and describe the dedicated
    repository. These are cross-file edits outside this log and
    are tracked by the parallel spec-agent team (see report).
  - Tests: new widget tests for `DistressChainsScreen` + editor;
    engine tests already cover `distressChainId → chain` resolution
    and only need the repository-source swap.
- **References:** D-DATA-1 (SessionMode.distressChainId); D-DATA-2
  (SUPERSEDED); D-DATA-9 (nuke-and-reseed); D-UX-31 (settings hub
  structure); D-PLATFORM-1 (storage engine — Drift tables will host
  the repository post-rewrite); spec 03 §"AppDefaults".

---

### Engine, state machine (ENGINE)

#### D-ENGINE-1: Hardware panic pressCount default = 5

- **Status:** RESOLVED (B1)
- **Decision:** Default 5 presses; user-configurable 2-10.
- **Rationale:** High enough to avoid accidental panic from volume use,
  low enough to be fast under duress.
- **References:** Round-2 B1.

#### D-ENGINE-2: disguisedReminder retryCount default = 1

- **Status:** RESOLVED (B2)
- **Decision:** retryCount=1 → 2 total attempts.
- **References:** Round-2 B2.

#### D-ENGINE-3: fakeCall retryCount default = 0

- **Status:** RESOLVED (B3)
- **Decision:** retryCount=0 → 1 attempt.
- **References:** Round-2 B3.

#### D-ENGINE-4: LoudAlarm gradualVolume default = true

- **Status:** RESOLVED (B4)
- **Decision:** Linear volume ramp by default.
- **References:** Round-2 B4.

#### D-ENGINE-5: LoudAlarm flashSpeed = enum {fast, medium, slow}

- **Status:** RESOLVED (B5)
- **Decision:** Enum with three fixed speeds: fast (300ms), medium
  (500ms), slow (1000ms).
- **References:** Round-2 B5.

#### D-ENGINE-6: Three-phase timing = wait → duration → grace

- **Status:** RESOLVED
- **Decision:** Every step has three phases. `waitSeconds` (initial
  delay), `durationSeconds` (active event time), `gracePeriodSeconds`
  (dead time after event during which user can still disarm).
- **References:** spec 01; legacy notes.

#### D-ENGINE-7: Engine = pure Dart, no Flutter imports

- **Status:** RESOLVED
- **Decision:** `lib/domain/engine/` MUST NOT import `package:flutter/`.
  Enforced by CI grep.
- **References:** spec 01; rebuild-strategy P1.

#### D-ENGINE-8: Jitter = ±20% via `0.8 + rand*0.4`

- **Status:** RESOLVED
- **Decision:** All timer values scaled by `0.8 + random.nextDouble() *
  0.4`. `Random` injected for determinism.
- **References:** spec 01; TEST-001..002.

#### D-ENGINE-9: Speed multiplier rejected for real sessions

- **Status:** RESOLVED
- **Decision:** Speed > 1 is only allowed for simulation. Real sessions
  throw `ArgumentError` on `setSpeedMultiplier(>1)`.
- **References:** spec 01; TEST-005.

#### D-ENGINE-10: Distress chain REPLACES main chain

- **Status:** RESOLVED
- **Decision:** Distress execution discards the main chain. No going
  back. `EndReason.distressCompleted` on exhaustion.
- **Rationale:** A user in distress does not want to "resume" a routine
  hold-button check-in.
- **References:** spec 01; spec 08.

#### D-ENGINE-11: Universal retry rule = wait skipped on retries

- **Status:** RESOLVED
- **Decision:** On the retry cycle of a step, the wait phase is
  skipped. Retries go straight to duration → grace.
- **References:** spec 01.

#### D-ENGINE-12: Sealed EngineState hierarchy

- **Status:** RESOLVED
- **Decision:** `EngineState` is sealed: `EngineIdle`, `EngineRunning`,
  `EnginePaused`, `EngineEnded`. Each exposes only valid transitions.
- **References:** spec 01.

#### D-ENGINE-13: 11 engine events (including pauseExpired)

- **Status:** RESOLVED (corrects spec 01 "10 events" — now 11)
- **Decision:** Engine emits 11 events. The 11th is `pauseExpired`,
  fired right before auto-resume when `maxPauseDuration` expires.
- **References:** audit-spec-vs-code DRIFT-L8.

#### D-ENGINE-14: Disarm during retryCount=0 grace = reset to step 0

- **Status:** RESOLVED (Extra 46)
- **Decision:** Disarming during the grace of a non-retrying step
  resets to step 0 (standard disarm behaviour).
- **References:** Round-2 Extra 46.

#### D-ENGINE-15: GPS trigger without destination = prompt at start

- **Status:** RESOLVED (Extra 22)
- **Decision:** If a mode is configured with a GPS-arrival disarm
  trigger but no destination is set, prompt the user at session start.
  Skipping disables the trigger for that session only.
- **References:** Round-2 Extra 22.

#### D-ENGINE-16: Distress + disarm triggers run parallel to the chain

- **Status:** RESOLVED
- **Decision:** Triggers are not chain steps; they run in a separate
  manager alongside the chain and are confirmed before execution.
- **References:** spec 00 §9; spec 01.

#### D-ENGINE-17: 5-second distress confirmation window

- **Status:** RESOLVED
- **Decision:** When a distress trigger fires, a 5-second confirmation
  window with cancel option is shown. Cancel requires Session End PIN
  if configured.
- **References:** spec 00 §9; TEST-027..028.

#### D-ENGINE-18: Battery alert = one-shot side-action

- **Status:** RESOLVED
- **Decision:** Battery alert does NOT pause the chain or interrupt
  escalation. It fires once per session when the threshold is crossed
  and returns control.
- **References:** spec 00 §9.

#### D-ENGINE-19: Fake-call decline-with-distress = 5s hold

- **Status:** RESOLVED
- **Decision:** `FakeCallConfig.declineWithDistressHoldSeconds = 5`.
  Holding the Distress button for 5 seconds fires the distress chain.
  Progress ring appears at 1600ms.
- **References:** spec 08.

#### D-ENGINE-20: Per-step disguisedReminder templateIds (keep)

- **Status:** RESOLVED (C4)
- **Decision:** Keep the per-step template filter
  (`DisguisedReminderConfig.templateIds`).
- **References:** Round-2 C4.

#### D-ENGINE-21: Per-step SMS includeMedicalInfo (keep)

- **Status:** RESOLVED (C3)
- **Decision:** Keep the `SmsContactConfig.includeMedicalInfo` toggle.
- **References:** Round-2 C3.

#### D-ENGINE-22: Session recovery dialog = detailed; NO auto-resume ever

- **Status:** RESOLVED (closes D-OPEN-10; supersedes D-SAFETY-14 detail)
- **Date:** 2026-04-20
- **Context:** D-SAFETY-14 set the high-level rule "recovery dialog,
  no auto-resume." D-OPEN-10 asked for the exact UX of that dialog on
  next launch after a force-close or crash mid-session.
- **Alternatives considered:**
  1. Minimal: "Session interrupted. Start a new one?"
  2. Detailed: title + last-step name + elapsed duration + link to
     Past Events to inspect the partial log.
  3. Full event timeline up to the crash point shown in-dialog.
- **Decision:** **Option 2 — detailed dialog.** Shown once on next
  launch if `SessionLog.endReason == interrupted` exists with no user
  acknowledgement flag. Contents:
  - Title: "Previous session didn't end cleanly" (localised)
  - Body: "Your session in <mode name> was interrupted at step
    <step index/N> (<last-step-type friendly name>), after <human
    duration>."
  - Primary action: "See details" → navigates to the
    PastEventDetailScreen for that log.
  - Secondary action: "Start a new session" → Home.
  - Tertiary (text button): "Dismiss" → marks the log
    acknowledged; dialog never shown again for this log.
- **NO AUTO-RESUME EVER.** Auto-resume is forbidden on both platforms:
  iOS forbids it via process-lifecycle rules; Android reliability
  varies so much across OEM kills that resuming creates more risk
  (stale timers, ghost SMS jobs) than value.
- **Rationale:** The user deserves a precise description of what
  state they left. A one-line "Session interrupted" is patronising
  and gives zero diagnostic value. The full event timeline inline
  would bloat the dialog; Past Events already shows it.
- **Implications:**
  - `SessionLog` gains `EndReason.interrupted` (or similar) +
    `acknowledgedAt` timestamp field; Drift schema bump.
  - `HomeController` checks for un-acknowledged interrupted logs on
    start and shows the dialog via `AppRouter` redirect.
  - L10n keys: `sessionInterruptedTitle`, `sessionInterruptedBody`,
    `sessionInterruptedSeeDetails`, `sessionInterruptedStartNew`,
    `sessionInterruptedDismiss`.
  - Tests: TEST-102 (test-strategy §5.11) deepened — assert the
    dialog appears with the exact three fields; assert "See details"
    route param = the interrupted log's id.
- **References:** D-SAFETY-14; D-OPEN-10 (closed); test-strategy
  TEST-102.

---

### Services, platform integration (SERVICES)

#### D-SERVICES-1: iOS headphone remote via audio_service

- **Status:** RESOLVED (C1)
- **Decision:** iOS hardware button = headphone remote via
  `audio_service`. Volume buttons NOT supported (OS limitation).
- **References:** Round-2 C1; spec 10.

#### D-SERVICES-2: Built-in fake-call voice = all 14 languages

- **Status:** RESOLVED (C2)
- **Decision:** Bundle voice recordings for all 14 supported languages.
- **References:** Round-2 C2.

#### D-SERVICES-3: FakeCall voice default path = built-in per-language

- **Status:** RESOLVED (Extra 32)
- **Decision:** If `FakeCallConfig.voiceRecordingPath == null`, use
  the built-in recording for the user's language.
- **References:** Round-2 Extra 32.

#### D-SERVICES-4: Custom voice recording max = 2 minutes

- **Status:** RESOLVED (Extra 39)
- **Decision:** `kMaxVoiceRecordingDurationSeconds = 120` enforced at
  record time.
- **References:** Round-2 Extra 39.

#### D-SERVICES-5: All local data encrypted (mandatory)

- **Status:** RESOLVED
- **Decision:** Encryption is not optional. Drift uses
  `sqlcipher_flutter_libs`; key stored in `flutter_secure_storage`.
- **References:** spec 08 §"Always-Encrypt".

#### D-SERVICES-6: SMS retry = WorkManager, indefinite

- **Status:** RESOLVED
- **Decision:** Android SMS retries handled by WorkManager with
  exponential backoff, no retry cap (final user notification per
  D-SAFETY-15).
- **References:** spec 08.

#### D-SERVICES-7: iOS SMS = opens Messages app, manual Send

- **Status:** RESOLVED
- **Decision:** Documented platform limitation. Warn iOS users during
  setup.
- **References:** spec 10.

#### D-SERVICES-8: iOS phone call = always shows confirmation dialog

- **Status:** RESOLVED
- **Decision:** iOS cannot bypass the confirmation dialog. Documented.
- **References:** spec 10; spec 08.

#### D-SERVICES-9: iOS hardware button = headphone remote only

- **Status:** RESOLVED
- **Decision:** See D-SERVICES-1. Volume buttons greyed out in settings
  on iOS; headphone remote path only.
- **References:** spec 10.

#### D-SERVICES-10: RecordingService merged into AudioService

- **Status:** RESOLVED (closes audit Q2 part 1)
- **Decision:** No dedicated `RecordingService`. Recording lives in
  `AudioService.startVoiceRecordingWithCap()`.
- **Rationale:** Audio recording is a minor feature; extracting a
  service for it adds churn without value.
- **References:** audit Q2.

#### D-SERVICES-11: FlashService inlined in LoudAlarmStrategy

- **Status:** RESOLVED (closes audit Q2 part 2)
- **Decision:** Camera LED SOS is handled inline in
  `LoudAlarmStrategy` via `torch_light` / `flutter_torch`. No dedicated
  service class.
- **References:** audit Q2.

#### D-SERVICES-12: ScreenFlashService = overlay widget

- **Status:** RESOLVED (closes audit Q2 part 3)
- **Decision:** Screen-flash is a widget-layer overlay
  (`ScreenFlashOverlay`). Not a service.
- **References:** audit Q2.

#### D-SERVICES-13: BackgroundSessionService split

- **Status:** RESOLVED (closes audit Q3)
- **Decision:** No single `BackgroundSessionService` class. Foreground
  channels live in `NotificationService`; lifecycle in
  `SessionController`. Spec 05 updated accordingly.
- **References:** audit Q3.

#### D-SERVICES-14: BackupService inline in backup_screen

- **Status:** RESOLVED (closes audit Q4)
- **Decision:** Backup helpers remain inline in
  `lib/features/settings/backup_screen.dart`. Extract later only if a
  second consumer appears.
- **References:** audit Q4.

#### D-SERVICES-15: PermissionService = utilities + per-screen calls

- **Status:** RESOLVED (closes audit Q5)
- **Decision:** No single `PermissionService` class. Utilities in
  `lib/core/utils/permission_utils.dart` + inline per-screen calls.
- **References:** audit Q5.

#### D-SERVICES-16: WakelockService merged into DeviceStateService

- **Status:** RESOLVED
- **Decision:** `DeviceStateService` wraps both wakelock and keep-
  screen-on; no dedicated `WakelockService`.
- **References:** audit.

#### D-SERVICES-17: Telemetry provider = Sentry (EU host; not Firebase)

- **Status:** RESOLVED (closes D-OPEN-11)
- **Date:** 2026-04-20
- **Context:** D-OPEN-11 asked which SDK implements the opt-out
  telemetry policy (D-PLATFORM-6). Candidates: Sentry, Firebase
  Crashlytics, self-hosted custom.
- **Alternatives considered:**
  1. Firebase Crashlytics. Industry default, tight Google SDK
     dependency, US-hosted primarily, limited custom-event
     flexibility, adds Google Play Services requirement on Android.
  2. Sentry (SaaS on `sentry.io` with EU region option or
     self-hosted via Docker). Free tier covers 5k errors + 10k
     transactions / month, which fits our expected scale
     comfortably. First-class Flutter SDK (`sentry_flutter`),
     custom events, source maps / symbolication out of the box.
  3. Self-hosted only (GlitchTip or Sentry OSS). Zero vendor
     lock-in but requires operations budget; overkill for our
     scale.
- **Decision:** **Sentry (SaaS, EU region).** DSN lives in a build-
  time environment variable (`--dart-define=SENTRY_DSN=...`). No
  Google Play Services dependency introduced on Android.
- **Rationale:**
  - **EU hosting option** for GDPR compliance (user base includes
    EU). Sentry's EU region is at `de.sentry.io`.
  - **No Google SDK lock-in** — Android builds remain FOSS-clean.
  - **Custom events** support (we need `false_alarm_reported`,
    `session_started`, `session_ended` with a fixed taxonomy per
    D-UX-34).
  - Free-tier allocation (5k errors / 10k transactions per month)
    fits our expected user-base for v1 with room.
  - Opt-out (D-PLATFORM-6) is enforceable: the SDK initialisation
    is gated on `AppSettings.telemetryEnabled`. When false,
    `SentryFlutter.init` is never called, so zero HTTP calls
    (TEST-160 asserts this with a fake `HttpClient`).
- **Implications:**
  - Dependency: `sentry_flutter: ^9.0.0` in `pubspec.yaml`.
  - Settings → Privacy screen exposes the toggle (default ON).
  - Sentry project created before v1 launch; DSN committed to CI
    secrets only. No DSN in source.
  - Custom event schema documented in `lib/services/telemetry/
    sentry_events.dart`.
  - PII scrubber (TEST-163) removes phone numbers, contact names,
    PIN hashes, GPS coordinates, session body text before send.
- **References:** D-PLATFORM-6; D-UX-34; test-strategy
  TEST-160..165.

#### D-SERVICES-18: Emergency number DB = `emergency_numbers` package

- **Status:** RESOLVED (closes D-OPEN-14)
- **Date:** 2026-04-20
- **Context:** D-SAFETY-1 set the high-level rule "bundle a
  comprehensive emergency-number database." D-OPEN-14 asked for the
  specific source and update cadence.
- **Alternatives considered:**
  1. Hand-curated `assets/emergency_numbers.json` scraped from
     Wikipedia's "List of emergency telephone numbers" once.
     Maintenance burden on us.
  2. Community package `emergency_numbers` (or equivalent) on
     pub.dev — community-maintained, covers every ISO 3166-1 alpha-2
     country + recognised territories.
  3. Live API lookup (ITU, local government feeds). Network
     dependency violates offline-first principle.
- **Decision:** **Option 2 — use the `emergency_numbers` pub.dev
  package** (or an equivalent community-maintained Flutter
  package). If the current `emergency_numbers` package is stale at
  integration time, fork it and maintain internally.
- **Update cadence:** quarterly audit + whenever the upstream
  package ships a patch. CI job opens a pull request whenever a new
  upstream version exists (Dependabot-equivalent).
- **Rationale:**
  - Offloads the per-country maintenance burden onto a community
    project.
  - Package already covers 250+ countries/territories.
  - Fallback path (internal fork) preserves long-term control.
- **Implications:**
  - Add `emergency_numbers: <version>` to `pubspec.yaml` with
    pinned version per D-INFRA-5.
  - License / attribution on About screen (as per D-SAFETY-1).
  - TEST-190..194 (test-strategy §5.20) remain valid — they assert
    the resolution path, not the data source.
  - If the package exits maintenance, fork → internal maintenance
    is the documented fallback.
- **References:** D-SAFETY-1; D-INFRA-5 (dep justification);
  test-strategy §5.20.

#### D-SERVICES-19: iOS Critical Alert entitlement applied at v1 launch

- **Status:** RESOLVED (closes D-OPEN-12)
- **Date:** 2026-04-20
- **Context:** iOS Critical Alert entitlement allows
  `disguisedReminder` notifications (and distress-chain
  notifications) to bypass silent-mode and DND settings. Apple
  review cycle is 1-4 weeks. D-OPEN-12 asked whether we apply at
  launch or defer.
- **Alternatives considered:**
  1. Ship v1 without Critical Alert entitlement; disguised
     reminders fail silently on DND-enabled devices.
  2. Apply for the entitlement with Apple during rebuild phase 5
     (platform native); ship with it at v1.
- **Decision:** **Option 2 — apply at v1 launch.** Entitlement
  request filed during rebuild Phase 5 (see rebuild-strategy phase
  5 exit criteria). Apple review window (1-4 weeks) runs in
  parallel with Phase 5-6; entitlement approval gates v1 production
  release, not TestFlight.
- **Rationale:**
  - Disguised reminder is a primary check-in mechanism for the Date
    Mode. Without Critical Alert, a user with DND on could miss the
    reminder and trigger an escalation they never wanted.
  - Apple reviews safety apps favourably for Critical Alert when
    the use case is documented (our dead-man's-switch narrative
    fits their published approval criteria).
- **Implications:**
  - iOS entitlement request filed in Phase 5 of rebuild.
  - `ios/Runner/Runner.entitlements` gains the
    `com.apple.developer.usernotifications.critical-alerts` key.
  - Notification category for disguisedReminder marks
    `.criticalAlert` on the iOS side.
  - If Apple rejects, fallback: ship v1 without the entitlement;
    in-app explain banner on Date Mode.
  - TestFlight does NOT require the entitlement, so beta can start
    while review is pending.
- **References:** spec 08 §"iOS Notifications"; D-OPEN-12 (closed);
  rebuild-strategy phase 5.

---

### Security, privacy (SEC)

#### D-SEC-1: Three nullable PINs

- **Status:** RESOLVED
- **Decision:** `AppSettings.appPinHash`, `sessionEndPinHash`,
  `duressPinHash` — each independently nullable. Null = PIN disabled.
- **References:** spec 00 §8.

#### D-SEC-2: pinTimeoutSeconds applies to App + Session End, NOT Duress

- **Status:** RESOLVED (B7)
- **Decision:** Default `pinTimeoutSeconds = 15`. Applies to App PIN
  and Session End PIN. Duress PIN has no timeout (must always fire).
- **References:** Round-2 B7.

#### D-SEC-3: Biometric substitutes for Session End PIN only

- **Status:** RESOLVED
- **Decision:** Biometric auth MAY replace the Session End PIN. It
  MUST NOT replace App PIN (prevents coerced fingerprint unlock) or
  Duress PIN (would defeat its purpose).
- **References:** spec 00 §8.

#### D-SEC-4: Biometric fallback on cancel = PIN keypad

- **Status:** RESOLVED (Extra 17)
- **Decision:** If biometric is cancelled, fall back to the PIN keypad.
- **References:** Round-2 Extra 17.

#### D-SEC-5: Wrong-PIN threshold = user-configurable, default 5

- **Status:** RESOLVED
- **Decision:** `AppSettings.wrongPinThreshold = 5` by default; user
  can raise or lower. Reached count fires distress.
- **References:** Round-2 A3; D-SAFETY-9.

#### D-SEC-6: Encryption key in flutter_secure_storage

- **Status:** RESOLVED
- **Decision:** Database encryption key generated on first launch,
  stored in `flutter_secure_storage` (iOS Keychain / Android Keystore).
- **References:** spec 00 §7.

#### D-SEC-7: PIN hashes stored, never plaintext

- **Status:** RESOLVED
- **Decision:** PINs stored as hashes with a documented algorithm
  (Argon2id or PBKDF2-SHA256, selected at implementation time).
- **References:** test-strategy TEST-030, TEST-031.

#### D-SEC-8: Panic wipe = NOT implemented

- **Status:** REJECTED
- **Decision:** No explicit "wipe all data" panic button.
- **Rationale:** Low marginal value (user can uninstall). Adds risk
  of accidental catastrophic data loss.
- **References:** spec 08.

#### D-SEC-9: App identity concealment (fake app label) = deferred

- **Status:** REJECTED (deferred indefinitely)
- **Decision:** Renaming the app icon/label on home launcher is NOT
  implemented.
- **Rationale:** Complex platform APIs; marginal gain over stealth
  mode's notification disguise.
- **References:** spec 08.

#### D-SEC-10: PIN hashing = Argon2id (64 MB / 3 iterations / 4 lanes)

- **Status:** RESOLVED (closes D-OPEN-7; refines D-SEC-7)
- **Date:** 2026-04-20
- **Context:** D-SEC-7 established "PINs stored as hashes, never
  plaintext" but left the algorithm + parameters open (Argon2id or
  PBKDF2-SHA256). D-OPEN-7 asked for the exact algorithm, iteration
  count, and storage format.
- **Alternatives considered:**
  1. SHA-256 only (the v6 code path). Fails against offline
     brute-force because 4-8 digit PINs have only 10^4–10^8
     possibilities — trivial on a GPU.
  2. BCrypt, cost factor 10. The earlier architecture-sketch
     proposal. Good, but memory-hard algorithms are the modern
     standard.
  3. PBKDF2-SHA256, 600k iterations. Accepted by OWASP 2024 but not
     memory-hard.
  4. **Argon2id.** OWASP 2024 #1 recommendation. Memory-hard
     (resists GPU/ASIC brute force). Parameters per OWASP
     guidance: 64 MB memory, 3 iterations, 4 lanes (parallelism).
     ~150-200 ms per verify on a mid-range 2026 phone — acceptable
     UX for a PIN prompt.
- **Decision:** **Argon2id with m=65536 KiB (64 MB), t=3, p=4.**
  Dart implementation via `pointycastle` (Argon2 was added in
  pointycastle 3.9+) or a dedicated `argon2` package, whichever
  ships a stable pub.dev version at implementation time.
- **Storage format:** encoded hash blob with algorithm + parameters
  + salt + hash, as `$argon2id$v=19$m=65536,t=3,p=4$<salt>$<hash>`
  (PHC string format). Stored in `AppSettings.*PinHash` as the
  full PHC string, so we can upgrade parameters later without
  losing verification of old hashes.
- **Rationale:**
  - OWASP 2024 recommendation; memory-hard algorithms are the
    modern best-practice.
  - ~200 ms per verify is acceptable UX (user holds thumb on the
    final digit for a moment; UX rounds to "feels instant").
  - PHC string format allows future parameter bumps without
    breaking existing hashes (the format self-describes).
- **Implications:**
  - Dependency: `pointycastle` already in tree (see
    architecture-sketch Appendix A) OR new `argon2` package,
    justified per D-INFRA-5.
  - Earlier architecture-sketch line "BCrypt (`package:crypt`)
    cost factor 10" is SUPERSEDED. Architecture-sketch is updated
    to read "Argon2id via `pointycastle`".
  - Test TEST-030 (hash never plaintext) stands; TEST-031 (hash
    algorithm + iteration count documented + asserted) is refined:
    assert the stored hash starts with the literal prefix
    `$argon2id$v=19$m=65536,t=3,p=4$`.
- **References:** OWASP Password Storage Cheat Sheet (2024);
  D-SEC-7 (refines); architecture-sketch §11 (supersedes); D-OPEN-7
  (closed); test-strategy TEST-030/031.

#### D-SEC-11: Wrong-PIN handling = 0.5s delay, friendly default, strict opt-in

- **Status:** RESOLVED (closes D-OPEN-8; refines D-SEC-5, D-SAFETY-9)
- **Date:** 2026-04-20
- **Context:** D-SEC-5 set "wrong-PIN threshold user-configurable,
  default 5" and D-SAFETY-9 set "wrong PIN in distress cancel window
  shakes + threshold fires distress." D-OPEN-8 asked: does wrong-PIN
  entry delay exponentially between attempts, linearly, or not at
  all?
- **Design principle:** Guardian Angela's threat model is "not afraid
  of attackers" — the app's primary adversary is a bad UX, not a
  state-level attacker. Friendliness wins by default; paranoid users
  opt into strictness.
- **Alternatives considered:**
  1. Exponential backoff (0.5s, 1s, 2s, 4s, ...). Good against
     adversarial brute force, but a user who fat-fingers once has
     a long wait.
  2. Fixed 0.5 s per attempt. Minor friction; blocks casual
     shoulder-surfing brute force; no user-punishing curve.
  3. No delay at all. Fastest UX but trivial to brute-force 10k
     possibilities on a 4-digit PIN.
- **Decision:** **Fixed 0.5-second delay between each wrong-PIN
  attempt.** Two operating modes selectable in Settings →
  Security:
  1. **Default mode (no-distress lockout; opt-out).** After **30
     consecutive wrong attempts**, lock the PIN keypad for 5
     minutes. Countdown shown. User can keep trying after the
     cooldown. No distress fired.
  2. **Strict mode (opt-in).** After **10 consecutive wrong
     attempts**, silently fire the distress chain. Designed for
     users who actively expect duress scenarios.
- **Rationale:**
  - Friendly default wins — most users who see the PIN prompt are
    themselves and are not under duress.
  - Strict mode is available for users who have a real threat
    model (journalists, domestic-violence survivors, activists).
  - 0.5 s delay is minor friction but disrupts casual brute force.
  - The 30-attempt default is NOT a security parameter; it's a
    UX parameter protecting against "child hitting phone" vs a
    real attacker.
- **Implications:**
  - `AppSettings` gains `wrongPinMode: WrongPinMode.default |
    strict` (default = `default`) and `wrongPinCooldownSeconds`
    (default 300).
  - D-SEC-5's `wrongPinThreshold = 5` default is SUPERSEDED for
    the default mode (now 30). For strict mode, default = 10.
  - D-SAFETY-9 (wrong-PIN in distress-cancel window) remains
    orthogonal — that threshold applies inside the 5-second
    distress-cancel window and is independent of the per-session
    PIN-attempt counter.
  - Tests: TEST-025 / TEST-032 refactored to parametrise over
    both modes; new test "default mode locks keypad for 5 minutes
    after 30 wrongs; user can retry after".
- **References:** D-SEC-5 (refined); D-SAFETY-9; D-OPEN-8 (closed);
  test-strategy TEST-025/032.

---

### Internationalisation (I18N)

#### D-I18N-1: 14 languages at launch

- **Status:** RESOLVED
- **Decision:** en, de, es, fr, ru, zh, zh_TW, hi, fa, uk, pl, el, ar,
  he.
- **References:** D-PLATFORM-3; spec 00 §13.

#### D-I18N-2: RTL languages = fa, ar, he

- **Status:** RESOLVED
- **Decision:** Support right-to-left layout for these three locales.
  Use `EdgeInsetsDirectional`; mirror icons.
- **References:** spec 00 §13.

#### D-I18N-3: Auto-translate on app_en.arb change

- **Status:** RESOLVED
- **Decision:** Whenever `app_en.arb` changes, the 13 translation
  subagents are launched in parallel to update each `app_<lang>.arb`.
  This is encoded in CLAUDE.md.
- **References:** CLAUDE.md; rebuild-strategy L6.

#### D-I18N-4: CI fails on ARB key gaps

- **Status:** RESOLVED
- **Decision:** CI job compares key sets across all 14 ARB files;
  any gap fails the build.
- **References:** rebuild-strategy P5; test-strategy TEST-070.

---

### Testing (TEST)

#### D-TEST-1: Coverage target = 99%+ per layer

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** test-strategy question 1 asked 80% vs 90%. Answer
  raised the bar.
- **Decision:** **99%+ line + branch coverage per layer. Anything below
  99% requires a written justification in-code with a `// COVERAGE:`
  comment citing the reason. Strive for 100%. Test complexity is not a
  concern — unlimited time and resources are assumed for test quality.**
- **Rationale:** Safety app — "rather be safe than sorry." Missing
  coverage is hidden liability.
- **Implications:**
  - CI has per-directory lcov gates set to 99% minimum.
  - Code review checks every missing-coverage exception.
  - No "baseline test count" magic numbers (D-TEST-7).
- **References:** test-strategy §7.5; supersedes 80% recommendation.

#### D-TEST-2: E2E framework = patrol + Maestro + Appium

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** test-strategy question 3.
- **Decision:** **All three.** patrol for depth (permissions, native OS
  control, Flutter widgets via Dart); Maestro for declarative smoke
  flows (YAML + CI); Appium to fill any remaining hole.
- **Rationale:** "Rather be safe than sorry — it's a safety app."
- **Implications:**
  - Three E2E directories: `integration_test/` (patrol), `.maestro/`
    (flows), `e2e/appium/` (JS or Python).
  - CI runs patrol + Maestro on every PR; Appium nightly or on
    platform-related PRs.
- **References:** test-strategy §7, §10 phase 7.

#### D-TEST-3: Full golden coverage for every widget

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** test-strategy §2.3 "No golden/visual-regression tests".
- **Decision:** **Golden baseline for every widget.** All themes
  (light/dark/system), RTL variants where applicable, all locales for
  visual text verification.
- **Rationale:** Visual regressions in stealth UI (D-SAFETY-4) could
  silently leak safety branding. WCAG contrast checks automatable.
- **Implications:**
  - `golden_toolkit` adopted.
  - Baselines under `test/goldens/`; diffs require reviewer sign-off.
  - Goldens pinned CI image (font rendering varies).
- **References:** test-strategy §7.3.

#### D-TEST-4: Engine tests use `_FixedRandom(0.5)`

- **Status:** RESOLVED
- **Decision:** Test-only `Random` wrapper returning 0.5 eliminates
  jitter and makes durations deterministic.
- **References:** spec 07; TEST-001.

#### D-TEST-5: fakeAsync mandatory for engine timing tests

- **Status:** RESOLVED
- **Decision:** Any test that advances engine timers MUST wrap in
  `fakeAsync()`. No wall-clock waits. No `pumpAndSettle()` without
  bounded duration.
- **References:** spec 07; test-strategy §7.7.

#### D-TEST-6: Spec-to-test traceability

- **Status:** RESOLVED
- **Decision:** Every normative spec paragraph maps to ≥1 test. Tests
  carry `@Tags(['spec:XX-YY'])` markers. CI flags orphans both ways.
- **References:** rebuild-strategy P8.

#### D-TEST-7: Replace test-count magic numbers with spec-tag assertions

- **Status:** RESOLVED
- **Decision:** Delete assertions like "4789 tests exist". Replace with
  "every spec section has at least one tagged test".
- **References:** test-strategy §8 anti-pattern 1.

#### D-TEST-8: Hand-rolled fakes preferred

- **Status:** RESOLVED
- **Decision:** Use hand-rolled fakes in `lib/services/fakes/`. Use
  `mocktail` only when the collaborator is abstract and hand-rolling
  is impractical (e.g., complex argument capture).
- **References:** CLAUDE.md; rebuild-strategy.

#### D-TEST-9: Real-device smoke required before native "done"

- **Status:** RESOLVED
- **Decision:** No native phase may be declared complete without at
  least one real-device smoke log on Android + iOS.
- **References:** rebuild-strategy L10.

#### D-TEST-10: Zero-tolerance flake policy

- **Status:** RESOLVED
- **Decision:** A flaking test is a tracked GitHub issue, not a silent
  retry. `skip:` requires an open-issue comment.
- **References:** test-strategy §7.4.

#### D-TEST-11: Arrange-Act-Assert convention

- **Status:** RESOLVED
- **Decision:** All tests follow AAA (Given-When-Then is an acceptable
  alias).
- **References:** CLAUDE.md.

#### D-TEST-12: Golden-image review = strict pixel-match

- **Status:** RESOLVED (closes D-OPEN-15)
- **Date:** 2026-04-20
- **Context:** D-TEST-3 set "full golden coverage for every widget"
  and D-OPEN-15 asked for the exact review process (diff-threshold,
  auto-approval rules).
- **Alternatives considered:**
  1. **Strict pixel-match.** Any diff at all fails CI. Intentional
     changes require `flutter test --update-goldens` + an explicit
     commit with the new baselines.
  2. Percentage-threshold tolerance (e.g., 0.1% pixels allowed to
     differ). Catches rendering-engine drift but masks real
     regressions.
  3. Reviewer-visual-approval workflow with no numeric threshold.
     High human cost, subjective, doesn't scale.
- **Decision:** **Option 1 — strict pixel-match.** Any diff fails
  CI. Intentional UI changes require `flutter test
  --update-goldens` locally and a commit that includes the updated
  PNG baselines. PR review checks the PNG diff visually before
  merge.
- **Rationale:**
  - Stealth regressions (D-SAFETY-4) must not slip through. Any
    drift could leak brand vocabulary or visible UI differences
    that compromise the disguise.
  - CI image pinning (D-TEST-3) + `loadAppFonts()` removes
    rendering-engine variance as a source of false positives.
  - The "explicit re-baseline" step is a friction feature —
    forces the PR author to consciously decide "yes, this change
    is intentional."
- **Implications:**
  - CI goldens run on a single pinned image (Ubuntu 22.04 +
    Chromium font bundle).
  - Golden baselines live at `test/goldens/**/*.png`, one file
    per (widget × device × theme × direction × font-scale).
  - PR reviewers MUST visually inspect every golden-baseline
    commit hunk.
  - No percentage-tolerance config in `flutter_test_config.dart`.
- **References:** D-TEST-3; D-OPEN-15 (closed); test-strategy §7.3.

#### D-TEST-13: Test fixtures = factory functions AND JSON fixtures

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** Test authoring convention needs a clear rule for when
  to use programmatic factory functions (e.g., `step(...)`,
  `makeMode(...)`) versus static JSON fixtures under
  `test/fixtures/`.
- **Alternatives considered:**
  1. Factory functions only. Simple; every case readable; painful
     for large complex inputs (a 30-event session log).
  2. JSON fixtures only. Quick for complex inputs; opaque for
     simple cases; awkward for ad-hoc parameter tweaks.
  3. **Both, with a documented guideline.** Factory functions for
     small / parameter-varying cases; JSON fixtures for large
     canonical payloads.
- **Decision:** **Both, with a guideline.** Factory functions
  (`step(...)`, `makeMode(...)`, `makeContact(...)`) are the
  default. JSON fixtures under `test/fixtures/` are used when:
  - the input exceeds ~20 lines of Dart builder code, OR
  - the fixture represents a canonical real-world artefact (e.g.,
    a 30-event session log from a production incident), OR
  - the fixture is shared across many test files.
- **Rationale:** Readability and maintainability. Small cases are
  clearer inline with factories; complex / canonical inputs deserve
  the structural clarity of a separate JSON file.
- **Implications:**
  - `test/fixtures/` gains a README documenting the guideline.
  - `test_helpers/fixture(String name)` loads JSON payloads and
    deserialises to the named type.
  - Existing test files remain factory-heavy; no sweeping
    refactor required.
- **References:** D-TEST-8 (hand-rolled fakes); test-strategy §7.7;
  research on Dart test-fixture best practices (2024-2026).

#### D-TEST-14: `mocktail` usage = only where fakes are impractical

- **Status:** RESOLVED (refines D-TEST-8)
- **Date:** 2026-04-20
- **Context:** D-TEST-8 said "hand-rolled fakes preferred; mocktail
  only where necessary." This decision pins down the "where
  necessary" boundary.
- **Decision:** `mocktail` is used **only for platform boundaries
  we cannot fake cheaply.** Specifically:
  - `MethodChannel` bodies (direct bindings to native plugins with
    no intermediate protocol).
  - `HttpClient` in places where `http_mock_adapter` cannot be
    injected (vanishingly rare — Sentry SDK, native networking).
  - Abstract collaborators where argument capture is essential
    and writing a fake would duplicate 50+ lines.
- For everything else — repositories, services, engines,
  controllers — **hand-rolled fakes** under `lib/services/fakes/`
  (for production-useful fakes like `SimulationMessagingService`)
  or `test/fakes/` (for test-only fakes) are required.
- **Rationale:**
  - Fakes compile-check their protocol implementation, catching
    interface drift at refactor time.
  - Fakes are executable documentation: reading `FakeSms` tells
    you what the real service does.
  - `mocktail` verify-this-was-called style obscures behaviour
    when over-used; "test as much in reality as possible"
    (user's global CLAUDE.md).
- **Implications:**
  - Existing `mocktail` usages audited; anything outside the
    allow-list migrated to hand-rolled fakes during the rebuild.
  - CI lint: ban `when(mock.method()).thenReturn(...)` outside
    an allow-list of directories (`test/services/platform/`,
    `test/integration/network/`).
- **References:** D-TEST-8 (refines); CLAUDE.md; test-strategy
  §7.1.

---

### Infrastructure / tooling (INFRA)

#### D-INFRA-1: CI pipeline

- **Status:** RESOLVED
- **Decision:** format → import_sorter → build_runner freshness check →
  analyze --fatal-infos → test. Plus ARB parity + legacy-identifier
  grep + spec-tag parity + coverage gate.
- **References:** CLAUDE.md; rebuild-strategy phase 1.

#### D-INFRA-2: Pre-commit + pre-push hooks

- **Status:** RESOLVED
- **Decision:** lefthook pre-commit = format + import_sorter; pre-push
  = analyze + test.
- **References:** CLAUDE.md.

#### D-INFRA-3: Strict analyzer flags

- **Status:** RESOLVED
- **Decision:** `strict-casts`, `strict-inference`, `strict-raw-types`
  all enabled in `analysis_options.yaml`.
- **References:** CLAUDE.md.

#### D-INFRA-4: Line length = 80

- **Status:** RESOLVED
- **Decision:** `dart format` default 80-column width.
- **References:** CLAUDE.md.

#### D-INFRA-5: Dependencies = justified + pinned

- **Status:** RESOLVED
- **Decision:** Every dependency addition justifies its existence in a
  PR comment; version pinned in pubspec.yaml; reassessed on every
  `flutter pub upgrade`.
- **References:** rebuild-strategy appendix A.

#### D-INFRA-6: Legacy-identifier grep check

- **Status:** RESOLVED
- **Decision:** `scripts/verify_no_legacy_names.sh` fails CI if
  deprecated identifiers (e.g., `repeatCount`, `declineIsSafe`,
  `sendSms`) appear after a rename.
- **References:** rebuild-strategy L2.

#### D-INFRA-7: docs/baseline.md = single metrics source

- **Status:** RESOLVED
- **Decision:** One file tracks test count, analyze issues, l10n
  coverage, native smoke-test dates. Agents read it; agents do NOT
  compute their own counters.
- **References:** rebuild-strategy L13.

#### D-INFRA-8: docs/wiring-map.md as living doc

- **Status:** RESOLVED
- **Decision:** Table of (model field, constructor param, controller
  call site, UI source) maintained in `docs/wiring-map.md`. CI
  validates the map.
- **References:** rebuild-strategy L11, P9.

#### D-INFRA-9: Real-device CI = GitHub Actions + Firebase Test Lab

- **Status:** RESOLVED (closes D-OPEN-6)
- **Date:** 2026-04-20
- **Context:** D-OPEN-6 asked whether real-device CI is budgeted
  in, and which provider. test-strategy §7.5 mentioned "Firebase
  Test Lab for Android, BrowserStack for iOS, or self-hosted where
  feasible" without committing.
- **Alternatives considered:**
  1. **Manual QA only.** Zero CI cost; regression risk ships to
     users.
  2. **Self-hosted device lab.** Full control; 5-10k capital +
     ongoing operations.
  3. **BrowserStack App Live + App Automate.** Good coverage, ~$40-
     200/month. iOS + Android.
  4. **Firebase Test Lab (Android) + real-device-farm for iOS.**
     Firebase is free for up to 10 runs / day on physical devices;
     iOS requires a second provider.
  5. **GitHub Actions (emulator/simulator) per PR + Firebase Test
     Lab real-device on release tags.** Hybrid: cheap simulated CI
     on every PR, expensive real-device gated to the release tag.
- **Decision:** **Option 5 — GitHub Actions + Firebase Test Lab.**
  - **Per PR:** GitHub Actions runs Android emulator (API 26, 30,
    34, 35) + iOS simulator (latest). `patrol`, `Maestro`, and
    `integration_test` suites all run here. `Appium` runs against
    a GitHub Actions emulator for the Android side; iOS Appium
    runs on a macOS runner with the simulator.
  - **On release tags:** Firebase Test Lab executes the full E2E
    suite on a real-device matrix — 3 Android devices (Pixel + a
    Samsung + a low-end OEM) + 3 iPhones (15 Pro, 13, SE 3rd gen)
    via a real-device-farm provider for iOS.
  - **Estimated cost:** ~$0-50/month outside release weeks;
    ~$100-300 per release tag. Acceptable for a pre-alpha project.
- **Rationale:**
  - PR CI cost stays near zero (GitHub Actions minutes).
  - Real-device cost is bounded (release tags only).
  - Both Android and iOS have real-device coverage before
    production release.
  - Budget scales with release cadence, not contributor count.
- **Implications:**
  - `.github/workflows/ci.yml` runs emulator-based suites.
  - `.github/workflows/release.yml` runs real-device on Firebase
    Test Lab + `browserstack` (or equivalent) for iOS.
  - Phase 5 (platform native) + Phase 7 (integration tests) exit
    criteria gate on emulator green; release gates on real-device
    green.
  - D-TEST-9 ("real-device smoke required before native 'done'")
    is enforced on release tags.
- **References:** D-TEST-9; D-OPEN-6 (closed); test-strategy §7.4,
  §7.5.

---

### Process / meta (META)

#### D-META-1: Do not start rewrite; complete planning docs first

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Decision:** The rewrite is not authorised to begin. Instead, the
  following documents are produced and reviewed:
  1. `docs/rebuild-strategy.md` (HOW the rewrite will be executed)
  2. `docs/test-strategy.md` (test approach)
  3. Architectural implementation sketch (separate agent)
  4. `docs/decisions-log.md` (this document)
  Additional docs may be produced as needed.
- **Rationale:** Prior rewrites failed because planning was implicit.
  We close that loop before writing code.
- **References:** meta.

#### D-META-2: Pre-alpha stance; no backwards-compat guarantees

- **Status:** RESOLVED
- **Decision:** Pre-1.0 is pre-alpha; breaking changes allowed between
  any two commits.
- **References:** spec 00 §"Versioning".

#### D-META-3: State / nav / architecture stack

- **Status:** RESOLVED
- **Decision:** Flutter + Riverpod (state) + GoRouter (navigation).
- **References:** spec 00 §"Technical Stack".

#### D-META-4: Feature-first layout

- **Status:** RESOLVED
- **Decision:** `lib/features/<feature>/<feature>_controller.dart` +
  `<feature>_screen.dart`. Shared code in `lib/core/`, services in
  `lib/services/`, models in `lib/domain/models/`, engine in
  `lib/domain/engine/`, repositories in `lib/data/repositories/`.
- **References:** spec 00 §"Architecture".

#### D-META-5: Fail loud

- **Status:** RESOLVED
- **Decision:** Errors are raised, not swallowed. Invalid input raises
  `ArgumentError`/`StateError`. No silent `catch (_)`.
- **References:** CLAUDE.md; review-bugs HIGH-5.

#### D-META-6: Ownership manifest: one agent per file per phase

- **Status:** RESOLVED
- **Decision:** File-level ownership for every file; hotspots
  (`session_controller.dart`, `session_engine.dart`,
  `service_providers.dart`, `app_router.dart`, `step_config.dart`,
  `seed_data.dart`, `app_settings.dart`) are sequential-only.
- **References:** rebuild-strategy L5, appendix C.

#### D-META-7: Spec-to-test matrix required

- **Status:** RESOLVED
- **Decision:** No orphan tests (tests without spec reference) or
  orphan spec paragraphs (paragraphs without test ID).
- **References:** D-TEST-6.

#### D-META-8: Stubbed code throws UnimplementedError

- **Status:** RESOLVED
- **Decision:** Placeholder method bodies throw `UnimplementedError`
  with a specific message. No `return null;`.
- **References:** rebuild-strategy P6.

#### D-META-9: Exhaustive sealed switches

- **Status:** RESOLVED
- **Decision:** Dispatch tables indexed by an enum or sealed class
  MUST use `switch` expressions so the compiler enforces exhaustion.
  No manual registries (see L9).
- **References:** rebuild-strategy L9, P7.

#### D-META-10: Default values via `arg ?? default` pattern (Python-style)

- **Status:** RESOLVED
- **Decision:** In function signatures, default-value arguments use
  `null` as the sentinel and the body assigns the real default. The
  real default is documented in the doc comment.
- **Rationale:** From user's global CLAUDE.md; avoids shared mutable
  defaults and makes the default visible in one place.
- **References:** `/home/jonas/.claude/CLAUDE.md`.

#### D-META-11: DE-1 through DE-4 all ship in v1 (no v1.1 deferral)

- **Status:** RESOLVED (closes D-OPEN-5)
- **Date:** 2026-04-20
- **Context:** `docs/spec/11-deferred-enhancements.md` listed DE-1
  through DE-4 as "deferred to post-v1." D-OPEN-5 asked whether any
  of these are in-scope for v1. User position: "Everything should
  ship in v1. We want to have a complete app, we have no limit on
  time or resources. This can take YEARS."
- **Features in scope (all move from DE-* into the main specs):**
  - **DE-1 Logarithmic timer sliders** — in spec 06 (Settings) and
    spec 04 (Screens/EventDefaults).
  - **DE-2 Per-event GPS logging override** — in spec 02 (Event
    Types) per-step config.
  - **DE-3 Interval-based session tracking** — in spec 03 (Data
    Models) `SessionLog` schema and spec 01 (Engine) periodic
    tick.
  - **DE-4 "More settings" pattern for step config** — in spec 06
    (Settings) and spec 04 (ModeEditor / event editor screens).
- **Decision:** All four ship in v1. `docs/spec/11-deferred-
  enhancements.md` will be updated in a follow-up spec-edit pass
  (not by this PM agent — specs are out of scope for this
  consistency pass) to move DE-1..4 out of "deferred" and into
  "shipped-in-v1 — see spec N for normative text."
- **Rationale:** User directive; no resource ceiling. A complete
  v1 better serves the end user than a minimal v1 with follow-on
  iteration.
- **Implications:**
  - rebuild-strategy phases 2-6 scope expands to include DE-1..4.
  - Estimated incremental hours: DE-1 (~4h), DE-2 (~8h), DE-3
    (~12h), DE-4 (~16h). Added to rebuild-strategy Appendix D
    timeline.
  - test-strategy gains new TEST-### entries for each DE: a
    follow-up editing pass will add TEST-260..279 covering DE-1..4
    features.
  - spec 11 edit: DE-1..4 rows marked "MOVED TO SHIPPED, see spec
    Nxxxx" (spec-editor follow-up, not this agent).
- **References:** D-OPEN-5 (closed); spec 11 (pending update);
  user feedback in Round 3.

#### D-META-12: DE-5 (home widget) = DONE; status-update spec 11

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** DE-5 (home widget) has been implemented in the
  current code per earlier work (see audit-spec-vs-code.md spec 00
  row "Home-widget implemented"). Spec 11 still listed DE-5 as
  "deferred."
- **Decision:** Mark DE-5 DONE in spec 11 (pending spec-editor
  follow-up pass; not done by this PM agent).
- **Rationale:** Bringing the spec into line with shipped reality.
- **References:** audit-spec-vs-code.md spec 00; spec 11.

#### D-META-13: Release progression = GitHub → TestFlight/Internal → Open → Prod

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** rebuild-strategy phase 10 describes production
  release but does not prescribe the testing-track ladder. User
  provided the release progression in Round 3.
- **Decision:** Sequential 4-stage ladder. Each gate requires
  positive metrics + qualitative feedback from the previous stage
  before advancing:
  1. **GitHub Releases.** Sideloaded APK + IPA published to the
     project's GitHub Releases page. Early adopters install
     manually. No Play / App Store review yet.
  2. **Closed TestFlight + Google Play Internal Testing.** Invite-
     only cohort (size TBD, see D-OPEN-1). Real stores, real
     review pipeline, real crash reporting via Sentry (D-SERVICES-
     17).
  3. **Open TestFlight + Google Play Open Testing.** Public opt-in
     beta. Wider cohort, broader device coverage, real-world
     scenarios. Critical Alert entitlement (D-SERVICES-19) must
     be approved before this stage.
  4. **Production.** Google Play Production track + App Store
     general release.
- **Rationale:**
  - Each stage catches a different class of bug (install flow,
    store-specific metadata issues, device variety, scale).
  - GitHub Releases lets us ship to technical early adopters
    without store-review latency.
  - The `SEND_SMS` Play exemption (D-PLATFORM-7; D-OPEN-4) only
    blocks Stage 4 (production) — Stages 1-3 can run in parallel
    with the policy review.
- **Implications:**
  - rebuild-strategy phase 10 exit criteria expand to describe
    the 4-stage ladder.
  - D-INFRA-9 real-device CI is run on release tags, and each
    stage advancement creates a release tag.
  - D-OPEN-1 (beta cohort) is still open — affects Stage 2 and 3
    sizing.
- **References:** rebuild-strategy phase 10; D-PLATFORM-7;
  D-SERVICES-19; D-INFRA-9; D-OPEN-1 (remains open for cohort
  size).

---

#### D-META-NEW-4: SEND_SMS Play Store approval = product-owner handles submission + appeal

- **Status:** RESOLVED (closes D-OPEN-4)
- **Date:** 2026-04-20
- **Context:** D-PLATFORM-7 locked the `SEND_SMS` permission as
  mandatory for the Android silent-SMS path (AR-2). Google Play
  restricts SEND_SMS to apps whose core functionality is SMS-based;
  Guardian Angela must justify the permission via the Play Console
  Permissions Declaration form and handle any appeal. D-OPEN-4 asked
  who owns submission and how an appeal is prosecuted.
- **Decision:** The product owner handles the Play Permissions
  Declaration submission personally. No external store-review
  consultant. The justification framing is:
  "Guardian Angela is a personal safety app. On panic, wrong PIN,
  duress PIN, or user failure to check in, the app sends an
  emergency SMS containing the user's location to pre-configured
  emergency contacts. The user enables SMS per contact at setup;
  the app never auto-sends SMS outside an active safety session
  that the user started. Without SEND_SMS the app cannot send an
  emergency SMS silently in the background (on Android 6+ the
  `sms:` URI requires foreground user confirmation, which defeats
  the purpose during an incapacitated emergency)."
- **Appeal path:**
  1. Submit via Play Console with the above justification + a
     60-second demo video showing the exact emergency flow (panic
     trigger → SMS fires).
  2. If rejected, file appeal via the Play Console appeal form,
     referencing Section 4.3 of the Permissions Declaration policy
     (emergency / safety carve-out).
  3. If the appeal is denied, fall back to the `sms:` URI path for
     Play-distributed builds and route users to the GitHub-Release
     APK for the silent-SMS build, with a "why?" explanation.
- **Rationale:**
  - Safety apps have a documented carve-out in Play's SEND_SMS
    policy — the product owner has read-through of the exact policy
    text and can frame the request accurately.
  - External consultants charge $500-2k and only marginally improve
    acceptance rates for well-scoped safety use cases.
  - The fallback (sms: URI on Play builds, silent SMS on sideload)
    is shippable even if the appeal fails, so this decision does
    not block Stages 1-3 of D-META-13.
- **Implications:**
  - Phase 10 of rebuild-strategy: add submission checklist to
    "Play Console setup" deliverable.
  - A 60-second demo video becomes part of the Phase 10 deliverables.
- **References:** D-PLATFORM-7 (SEND_SMS requirement); AR-2
  (Android SMS risk); D-META-13 Stage 4 (production gate);
  D-OPEN-4 (closed).

---

---

#### D-SECURITY-1: SQLCipher passphrase = random-generated on first launch, stored in flutter_secure_storage

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** Drift opens the SQLite DB via SQLCipher (`sqlcipher_flutter_libs`). A 256-bit passphrase is required to key the encrypted file. Options: (A) derive from user PIN via Argon2id; (B) generate random on first launch, store in platform keystore.
- **Decision:** Option B. `EncryptionKey.load()` checks `flutter_secure_storage` for `ga_sqlcipher_passphrase`; generates a fresh 32-byte random base64-encoded passphrase if missing and persists it. Keystore/Keychain protects at-rest.
- **Rationale:**
  - PIN changes don't invalidate the DB — a derived key would force full re-encryption on every PIN change, an unacceptable UX cost for a safety app.
  - PIN is a UX gate, not a crypto boundary. Duress PIN + session-end PIN both need read access to the DB to function; keying the DB to the PIN would break duress paths.
  - Keystore/Keychain gives hardware-backed storage on both platforms.
- **Implications:**
  - Losing the secure storage (device reset) = losing the DB. User must re-onboard. Backup/restore (Phase 15) handles the disaster-recovery case.
  - The passphrase is per-installation. Not shareable across devices without backup export.
- **References:** `lib/data/db/encryption.dart`; plan Phase 6; D-SEC-10 (Argon2id is used for PIN hashing, not DB keying).

---

#### D-MODELS-2: Drift tables = (id PK, jsonPayload TEXT, scalar mirrors) not normalized

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** Domain models (per D-MODELS-1) are hand-rolled immutable classes with sealed hierarchies serialized to tagged JSON. A normalized schema would require expressing every sealed subtype as SQL tables/columns.
- **Decision:** One table per aggregate, shape `(id TEXT PRIMARY KEY, jsonPayload TEXT NOT NULL, + scalar mirror columns)`. Scalar mirrors exist ONLY for fields queries must access without parsing the blob: `ContactsTable.sortOrder`, `TemplatesTable.isGlobal`, `SessionLogsTable.startedAt`. All other fields read/write via the hand-rolled `Model.toJson()` / `Model.fromJson()`.
- **Rationale:**
  - Domain stays pure Dart; Drift is a persistence mechanism, not a domain layer.
  - Schema evolution is trivial: a new field appears in jsonPayload automatically. The nuke-and-reseed policy (pre-alpha) makes explicit schema migrations unnecessary.
  - The only queries we need are: list-all (for lists), get-by-id, save-upsert, delete-by-id, plus startedAt-ordered session logs. A jsonPayload column handles all of those; scalar mirrors cover the ones that need ORDER BY / WHERE.
- **Implications:**
  - The schema is not portable to non-JSON clients (acceptable — no such clients exist).
  - Queries on deeply nested fields (e.g., "find sessions where step count > 5") require loading + filtering in Dart. Safety app usage doesn't have that pattern.
  - Backup/restore (Phase 15) exports/imports JSON directly; no schema translation layer needed.
- **References:** `lib/data/db/schema/tables.dart`; plan Phase 6.

---

#### D-TEST-1: FixedRandom(0.5) + fakeAsync + injected clock — deterministic test canon

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** Engine uses randomized timing jitter (±20%) and a live `DateTime` clock. Tests need deterministic, fast-forward-capable execution.
- **Decision:** Three helpers, applied uniformly across every engine/strategy/controller test:
  - `class FixedRandom implements Random` (in `test/helpers/test_helpers.dart`) — always returns 0.5 from `nextDouble`, eliminating jitter variance.
  - `fake_async` package's `fakeAsync((async) { ... async.elapse(Duration); ... })` wrapper — fast-forward timers without real-time waits.
  - Engine accepts an injected `DateTime Function()? clock` parameter (default `DateTime.now`); tests pass `fixedClock(DateTime(2026))` for deterministic stamps.
- **Rationale:**
  - 0.5 is the midpoint; eliminates both ends of the jitter distribution so timing math matches nominal values exactly.
  - `fakeAsync` lets engine tests run in milliseconds even when simulating multi-minute sessions.
  - Injectable clock decouples tests from wall-clock drift.
- **Implications:**
  - All engine/strategy/controller test files use FixedRandom + injected clock.
  - Non-deterministic test failures (flakes) are diagnosable: the only sources of randomness are explicit unless `Random()` is used raw (CI lints against `Random()` without the `FixedRandom` alias — added in Phase 14).
- **References:** `test/helpers/test_helpers.dart`; plan Phase 5; `docs/test-strategy.md`.

---

#### D-MODELS-1: Domain models = hand-rolled immutable classes; sealed hierarchies use tagged JSON

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** 19 domain models under `lib/domain/models/` need serialization, equality, copyWith, and polymorphic subtypes. Options considered: (A) `freezed` + `json_serializable` code generation; (B) hand-rolled immutable classes with explicit `toJson` / `fromJson` / `copyWith` / `==` / `hashCode`.
- **Decision:** Option B. All models are hand-rolled immutable classes with explicit serialization, equality, copy. Sealed hierarchies (`StepConfig`, `Trigger`, `DistressTrigger`, `DisarmTrigger`, `HardwareTrigger`, `SessionPhase`) emit a `type` discriminator in their JSON; `fromJson` dispatches via sealed switch-expression with NO `default:` arm (throws `ArgumentError` on unknown tag — closes L9). `ActionDeliveryStatus` is a sealed class with `const` singleton instances rather than an enum (allows future per-status payload without breaking JSON shape).
- **Rationale:**
  - Removes code-gen dep (`freezed`, `json_serializable`), shortens `build_runner` time.
  - Makes models readable and diffable; no `.g.dart` artefacts.
  - Sealed classes + `final` subtypes + `switch` expressions give compile-time exhaustiveness.
  - Hand-rolled `toJson`/`fromJson` lets us tune per-field behaviour (e.g., `Duration` as ISO-8601 string, enum as camelCase name).
- **Implications:**
  - Every model gets a Phase 5 round-trip test (`toJson -> jsonEncode -> jsonDecode -> fromJson` == original).
  - Drift tables in Phase 6 use `TypeConverter<Model, String>` with the same `toJson`/`fromJson` pair.
  - Known spec-gap deviations (noted in WAL `phase-03.json`): `BatteryAlertConfig.enabled` default `true`, `GpsLoggingConfig.intervalSeconds=60`, `StealthConfig.fakeName='Calendar'`, 10 `AppSettings` fields dropped per current plan. Revisit if product owner requires.
- **References:** plan Phase 3; `docs/spec/03-data-models.md`; `docs/architecture-sketch.md` §4.4; `docs/rewrite-wal/phase-03.json`.

---

#### D-ENGINE-1: Sealed `EngineState` + nested enums `EndReason`, `PauseReason`

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** The engine's state transitions need compile-time exhaustiveness so unhandled variants are a static error, not a runtime surprise. Two options considered: (A) an enum-per-axis (`EngineStatus {idle,running,paused,ended}` plus orthogonal fields for step/phase/etc.) or (B) a sealed class hierarchy with concrete `final` subclasses carrying state-specific fields.
- **Decision:** Option B — sealed class `EngineState` with four concrete subclasses:
  - `EngineIdle` (no fields)
  - `EngineRunning({stepIndex, phase: TimerPhase, remaining: Duration, missCount, isHolding})`
  - `EnginePaused({snapshot: EngineRunning, reason: PauseReason})`
  - `EngineEnded({reason: EndReason})`
  Companion enums `PauseReason` and `EndReason` live in the same file (`lib/domain/engine/engine_state.dart`). `TimerPhase` lives in the adjacent `timer_phase.dart` since it's also referenced from chain step configs.
- **Rationale:**
  - State-specific fields are carried on the state type itself — no nullable fields on `EngineIdle` or `EngineEnded`. This eliminates a class of null-check bugs.
  - Dart 3 `switch` expressions enforce exhaustiveness at compile time; adding a new state surfaces every call site that needs updating. Closes L9 (registry missing strategies / missing switch arms).
  - `EnginePaused.snapshot` is an `EngineRunning` instance — pausing is a value-level snapshot, not a "pre-paused state" flag, so resuming is a simple reassign.
  - `PauseReason` values (`userRequested`, `incomingCall`, `fakeCallAnswered`, `bootRestart`) and `EndReason` values (`disarm`, `chainExhausted`, `hardwarePanic`, `duressPin`, `wrongPinExhausted`, `userQuit`, `appTermination`) expand the `docs/spec/01-chain-engine.md` originals to match the architecture-sketch inventory + the engine-logic review's `fakeCallAnswered` addition.
- **Implications:**
  - Closes failure mode L9 (registry missing strategies) for the engine's switch arms.
  - `lib/domain/**` cannot import `package:flutter/`; sealed-class + pure Dart satisfies this.
  - Test (Phase 5) `engine_state_test.dart` will pattern-match every subclass to prove exhaustiveness.
- **References:** `docs/spec/01-chain-engine.md` lines 706-729; `docs/architecture-sketch.md` §4.1 lines 274-295; `docs/review/engine-logic-review.md` (PauseReason.fakeCallAnswered addition); plan Phase 2.

---

#### D-PROCESS-1: Rewrite WAL checkpoint schema (JSON-per-phase)

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** The complete-rewrite plan (`/home/jonas/.claude/plans/spicy-enchanting-honey.md`) requires a write-ahead-log so a rate-limited or session-interrupted PM can resume cleanly without guessing. Historical L5 (parallel agent conflict, state lost on interruption) was the driver.
- **Decision:** `docs/rewrite-wal/phase-NN.json` per phase, overwritten on every PM update (not appended). Schema: `phase`, `title`, `step` (one of `design|code|review|fix|verify|exit`), `iteration` (0–3), `owner_agent`, `owned_files`, `decisions_added`, `gates_passed`, `gates_pending`, `next_action`, `last_update_iso`, `notes`. On resume, PM reads the WAL FIRST, then `git log --oneline -20`, then open TaskUpdate subtasks, then runs the universal gates before dispatching anything.
- **Rationale:**
  - Overwrite (not append) keeps each phase WAL small and scannable.
  - `next_action` as a single sentence forces PM discipline: the successor dispatches exactly this, no reinterpretation.
  - ISO-8601 timestamp lets successors detect stale WAL (e.g., if commit log shows newer activity than the WAL claims).
- **Implications:**
  - Closes L5 (parallel-agent seam failure on interruption).
  - `docs/rewrite-wal/README.md` documents the schema normatively.
  - Git commits become the coarse-grained checkpoint; WAL is the fine-grained in-phase state.
- **References:** `docs/interruption-resilience-strategy.md` §2-3; `docs/rewrite-wal/README.md`; plan §"Journal — the only cross-session truth".

---

#### D-PROCESS-2: Agent-prompt templates at `docs/agent-prompts/`

- **Status:** RESOLVED
- **Date:** 2026-04-20
- **Context:** Sub-agents (Design, Coding, Reviewer, Fixer, Verifier) need consistent prompt structure so rate-limit survival and scope discipline are guaranteed across invocations. Historical L11 (implicit wiring) and the PM's single-owner rule need codification in prompt form.
- **Decision:** Six Markdown templates under `docs/agent-prompts/`:
  - `pm-orchestrator.md` — PM identity, per-phase ritual, interruption preamble.
  - `design-agent.md` — proposal-only, required output format (Approach / Trade-offs / Risks / Failure-modes-mitigated / Files / Rejected-alternatives).
  - `coding-agent.md` — interruption preamble, scope rules, pre-alpha break-compat, pure-domain import guard, no-default-arm rule, round-trip-test requirement.
  - `reviewer.md` — JSON output format (verdict + findings), severity rules (Block / Warn / Note).
  - `fixer.md` — Block-only scope, iteration counting, gate re-run obligation.
  - `verifier.md` — read-only gate runner; PM's independent check.
  - All templates carry the standard interruption preamble: 30-use soft cap / 40-use hard cap / report-on-interrupt.
- **Rationale:**
  - Codified prompts prevent scope drift across agent invocations.
  - A Block → Fixer → re-review loop with `iteration` tracking bounds the review loop (max 3 iterations; 3rd-iter Block escalates to user — PM never self-overrides).
  - Verifier independence closes the "PM trusts a lying coding agent's self-report" failure mode.
- **Implications:**
  - Every phase's agent dispatch carries these templates.
  - PM keeps them up-to-date as patterns emerge.
- **References:** `docs/agent-prompts/*.md`; plan §"PM orchestration contract"; `docs/rebuild-strategy.md` §2 (L5, L11).

---

## Open questions still pending

The table below tracks every open question ever logged. 12 of the
original 15 are now closed by decisions; the remaining 3 are
deferred to rebuild Phase 9 (product-owner / business-side action,
not engineering blockers).

| ID | Title | Status | Resolution |
|---|---|---|---|
| D-OPEN-1 | Beta testing cohort size + recruitment | **DEFERRED → Phase 9** | Product-owner decision scheduled for rebuild Phase 9 when beta-readiness is imminent. Not a blocker for Phases 1-8. |
| D-OPEN-2 | Play Console / App Store Connect account ownership | **DEFERRED → Phase 9** | Product-owner decision scheduled for rebuild Phase 9. No engineering blocker; only gates store submission. |
| D-OPEN-3 | Ask for Angela outreach action items | **DEFERRED → Phase 9** | Product-owner decision scheduled for rebuild Phase 9. Contingency-rename plan per D-PLATFORM-5 remains the fallback. |
| D-OPEN-4 | SEND_SMS Play Store approval owner | CLOSED | **D-META-NEW-4** (2026-04-20) — product owner handles submission + appeal personally; no external consultant. |
| D-OPEN-5 | Deferred enhancements scope (DE-1..4) | CLOSED | **D-META-11** — all DE-1..4 ship in v1. |
| D-OPEN-6 | Real-device CI budget + provider | CLOSED | **D-INFRA-9** — GitHub Actions per-PR + Firebase Test Lab on release tags. |
| D-OPEN-7 | PIN hash algorithm + params + storage format | CLOSED | **D-SEC-10** — Argon2id m=65536, t=3, p=4; PHC string format. |
| D-OPEN-8 | Wrong-PIN exponential backoff | CLOSED | **D-SEC-11** — 0.5s fixed delay; default 30→5-min lockout; opt-in 10→distress strict mode. |
| D-OPEN-9 | Stealth forbidden-word list location | CLOSED | **D-SAFETY-24** — no list shipped anywhere; trust the user + help text guidance. |
| D-OPEN-10 | Session Recovery UX details | CLOSED | **D-ENGINE-22** — detailed dialog (mode + last-step + duration + Past Events link); no auto-resume ever. |
| D-OPEN-11 | Telemetry provider | CLOSED | **D-SERVICES-17** — Sentry (EU host, not Firebase). |
| D-OPEN-12 | iOS Critical Alert entitlement timing | CLOSED | **D-SERVICES-19** — apply at v1 launch during rebuild phase 5. |
| D-OPEN-13 | Fake-call voice recording licensing | CLOSED | **D-SAFETY-23** — TTS-only in v1; human recording post-v1. |
| D-OPEN-14 | Emergency number DB sourcing | CLOSED | **D-SERVICES-18** — `emergency_numbers` pub.dev package + quarterly audit. |
| D-OPEN-15 | Golden-image review workflow | CLOSED | **D-TEST-12** — strict pixel-match; `--update-goldens` + explicit commit for intentional changes. |

**Deferred items are business-side blockers, not engineering
blockers.** The rewrite CAN begin on every RESOLVED decision; the 3
deferred items will be decided at rebuild Phase 9 and gate specific
release stages (D-META-13), not code-production phases.

---

## Rejected options (with reasoning)

Tracked so we don't re-litigate. Each entry explains why the option was
considered and not taken.

1. **REJ-1: Shake-to-SOS (accelerometer-based emergency trigger).**
   Rejected due to false positive risk (pocket jostling, physical
   activity). See spec 11 REJ-1. ([D-ENGINE-16] triggers are explicit.)

2. **REJ-2: what3words integration.** Requires internet for lookup;
   poor fit for offline-first. spec 08.

3. **REJ-3: Live location sharing to contacts in real-time.** Requires
   backend; privacy liability. spec 08.

4. **REJ-4: Companion app for contacts.** Multi-platform engineering
   out of scope for v1. spec 08.

5. **REJ-5: Lock screen shortcut to start session.** Not feasible on
   Android 11+ or iOS. spec 08.

6. **REJ-6: Crash / accident detection via sensor fusion.** ML model
   + tuning outside scope. spec 08.

7. **REJ-7: In-app crisis hotline directory.** 195+ countries with
   constant updates; maintenance liability. spec 08.

8. **REJ-8: Telegram bot API for auto-send.** Security risk without
   backend. spec 08.

9. **REJ-9: Noonlight-style professional monitoring integration.**
   Requires backend + compliance + licensing. Deferred, not rejected
   outright — may return as premium tier later. spec 08.

10. **REJ-10: Web / desktop platforms.** Out of scope (D-PLATFORM-11).
    Core features (hardware button, CallKit, WorkManager) not
    applicable.

11. **REJ-11: iOS 16 support.** Dropped in favour of iOS 17+ widget
    story (D-PLATFORM-2).

12. **REJ-12: `sms:` URI via url_launcher as real SMS path.** Silent
    wait-for-user-tap = safety failure (D-PLATFORM-7).

13. **REJ-13: Panic wipe button.** Low value, accidental-deletion
    risk. (D-SEC-8)

14. **REJ-14: Fake app-label / home-launcher renaming.** Complex
    platform APIs; marginal gain. (D-SEC-9)

15. **REJ-15: Incremental Hive/Drift migrations.** All schema changes
    nuke-and-reseed. (D-DATA-9; rebuild-strategy L3)

16. **REJ-16: 5-language launch (en, de, es, fr, zh).** Full 14 chosen
    instead. (D-PLATFORM-3)

17. **REJ-17: ContentObserver approach for Android volume buttons.**
    Inferior to dispatchKeyEvent (no key-down/up distinction, no
    long-press). spec 08.

18. **REJ-18: Hive CE as storage engine.** Superseded by Drift.
    (D-PLATFORM-1)

19. **REJ-19: Isar as storage engine.** +10MB binary; rejected in
    favour of Drift. (D-PLATFORM-1)

20. **REJ-20: Sembast as storage engine.** Less mature; rejected.
    (D-PLATFORM-1)

21. **REJ-21: Auto-reseed on delete-all-modes.** Respect user intent;
    empty state + CTA instead. (D-UX-30)

22. **REJ-22: Global preferredChannel on EmergencyContact.** Replaced
    by `channels` list — all enabled channels used. (D-DATA-6)

23. **REJ-23: Sub-chain-returns-to-main model for distress.** Distress
    REPLACES, no return. (D-ENGINE-10)

24. **REJ-24: Implicit per-contact SMS channel fallback.** Replaced by
    explicit per-step channel selection. (D-DATA-7)

25. **REJ-25: Quiet hours for reminders in v1.** Day/night same
    behaviour. (D-UX-17)

26. **REJ-26: Keep distress chains inside `AppDefaults` and only
    improve the UI.** Rejected because the data model stays
    conceptually inconsistent — Modes are a top-level repository
    entity but distress chains (structurally identical) would remain
    nested under "defaults". Moving the data mirrors the Modes
    pattern and keeps `AppDefaults` focused on true cross-entity
    defaults. (D-DATA-21)

27. **REJ-27: Single-distress-chain model (no list).** Rejected
    because multi-chain support already exists in the data model
    (D-DATA-1, D-DATA-2) and mode-level distress override is a
    feature we ship in v1. Collapsing to one chain would remove
    user-facing capability to match the data model, which is the
    wrong direction. (D-DATA-21)

28. **REJ-28: Keep the `{allContacts, firstContact, specificIds}`
    dropdown for the SMS-step contact picker.** Rejected because the
    dropdown was opaque — users had to mentally map the abstract
    enum onto concrete contacts with no visual feedback about which
    contacts supported the step's channel. Per-contact buttons with
    channel-gated graying prevent mis-configuration by construction.
    (D-UX-35)

---

*End of Guardian Angela Decisions Log (2026-04-20 snapshot).*
