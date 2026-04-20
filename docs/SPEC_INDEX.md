# Guardian Angela Specification Index

Complete index of all specification documents. Last updated: 2026-04-02

---

## Normative Specifications (00-07)

These documents define the authoritative specification for Guardian Angela. In case of conflict, these take precedence over all other documentation.

### [00 - Overview](spec/00-overview.md)
Comprehensive application specification covering:
- App concept, identity, and vision ("Your angel's got your back")
- Target users (women walking home, dating, power users)
- Core features (dead man's switch, 8 event types, stealth mode, encryption)
- Design principles (Safety First, Configurable Everything, Offline-First)
- Technical stack (Flutter 3.41+, Riverpod, GoRouter, Hive CE)
- Platform targets (Android 8.0+, iOS 16.0+)
- Legal disclaimers and trademark considerations
- Success criteria and versioning strategy

**Status:** NORMATIVE — Read this first for overall app direction

---

### [01 - Chain Engine Specification](spec/01-chain-engine.md)
Pure Dart state machine specification covering:
- 3-phase timing model (wait → duration → grace)
- ChainStep data model with retryCount field
- Hold button state machine (sensitivity, duration, grace)
- Disguised reminder cycling (waitSeconds as interval)
- General step execution (timer-driven escalation)
- Fake call decline behavior (counts as miss)
- Real phone call detection (auto-pause session)
- Timing configuration (all steps support waitSeconds)
- Engine API (start, endSession, holdStart/Release, disarm, pause/resume)
- Events emitted (stepStarted, repeatMissed, stepAdvancing, userDisarmed, chainExhausted)
- Sub-chains (duress PIN, low battery)
- Pause/resume mechanics (preserve exact remaining time)
- Example chains (Walk Mode, Date Mode)
- Testing & simulation strategies

**Status:** NORMATIVE — Defines session engine behavior and timing logic

**Key Changes (Spec Conflicts Resolved):**
- Renamed `repeatCount` → `retryCount` throughout
- Fixed fake call decline: "Ignore DOES count as a miss"
- Fixed fake call disarm: "disarm fires on hang-up, not on answer"
- Added real phone call detection (auto-pause)
- Added timing configuration section: "All steps support waitSeconds"

---

### [02 - Event Types Specification](spec/02-event-types.md)
Detailed specification for 8 escalation steps + 3 check-in methods:

**Check-in Methods:**
1. **holdButton** — User holds screen; releasing starts grace period
2. **disguisedReminder** — Fake notification styled as Calendar/Duolingo/etc.
3. **hardwareButton** — Volume button press (Android only)

**Escalation Steps:**
1. **countdownWarning** — Visual/audio countdown before escalation
2. **fakeCall** — Realistic incoming call screen
3. **smsContact** — Send SMS/WhatsApp/Telegram to contacts
4. **phoneCallContact** — Auto-dial emergency contact
5. **loudAlarm** — Max-volume siren with optional flash
6. **callEmergency** — Call 911/112 with confirmation countdown

Plus:
- Configuration defaults (global + per-step overrides)
- Event execution via Strategy pattern
- Real vs. simulation mode behavior
- Platform-specific considerations

**Status:** NORMATIVE — Defines all user-facing event types

**Key Changes:**
- Renamed `repeatCount` → `retryCount` throughout
- Fixed fake call decline: "DOES count as a miss toward retryCount"
- Clarified fake call disarm: "On hang-up, not on answer"
- Added Mode Editor features: duplicate step button, collapsible timing sections
- Removed `declineIsSafe` config flag (was overcomplicating)

---

### [03 - Data Models Specification](spec/03-data-models.md)
Persistent and ephemeral data models:
- Hive CE storage architecture (always-encrypted AES-256)
- ChainStep model with retryCount field
- SessionMode, EmergencyContact, EventDefaults, SessionLog
- Schema versioning and migrations (typeId 0–16)
- Backup strategies (Android Auto Backup, iOS iCloud, manual export/import)
- Seed data (Walk Mode, Date Mode, 8 reminder templates)
- Two example modes with proper timing fields

**Status:** NORMATIVE — Defines all data structures

**Key Changes:**
- Renamed all `repeatCount` → `retryCount`
- Updated timing defaults table with correct grace period for holdButton (5s)

---

### [04 - Screens & Navigation Specification](spec/04-screens-navigation.md)
Complete UI specification covering:
- Every screen (Home, Session, Fake Call, Contacts, Modes, Settings, etc.)
- Navigation map (all routes and query parameters)
- GoRouter integration
- First-launch onboarding (9-page flow)
- Layout and UX for each screen
- Accessibility and one-hand operation

**Status:** NORMATIVE — Defines all user interfaces

**Key Changes:**
- Added note: Mode editor step timing shown as collapsible "Timing" section
- Added: "Duplicate step" button on each step in chain editor

---

### [05 - Services Specification](spec/05-services.md)
Platform service wrappers covering:
- AudioService (ringtones, alarms, voice recordings)
- LocationService (GPS logging during session)
- MessagingService (SMS, WhatsApp, Telegram)
- PhoneService (calls and fake calls)
- NotificationService (foreground service, local notifications)
- VibrationService (haptic feedback patterns)
- WakeLockService (prevent device sleep)
- PermissionService (request/check OS permissions)

**Status:** NORMATIVE — Defines service layer interfaces

---

### [06 - Settings & Configuration Specification](spec/06-settings.md)
Comprehensive settings system covering:
- General section (theme, language, GPS logging)
- Stealth Mode section (master toggle + 5 feature toggles)
- Event Defaults selector (per-step-type global configuration)
- PIN/Biometric authentication (app lock, session end, duress PIN)
- Emergency contacts and messaging channels
- Reminder templates (built-in + custom)
- Backup & restore (export/import)
- Accessibility and feedback

**Status:** NORMATIVE — Defines all configurable options

---

### [07 - Test Plan](spec/07-test-plan.md)
Comprehensive testing strategy covering:
- 168+ test cases across unit, widget, and integration layers
- Test infrastructure and tools (package:test, package:checks, fake_async, _FixedRandom)
- Arrangement pattern (Arrange-Act-Assert)
- Test layers (unit, widget, integration)
- Priority levels (P1 safety-critical, P2 important, P3 nice-to-have, P4 backlog)
- Test categories:
  - SessionEngine core (37 cases)
  - Event types (26 cases)
  - Realistic scenarios (13 cases)
  - Model & data (8 cases)
  - Session logs (7 cases)
  - New features (105 cases)
  - Integration tests (end-to-end)
  - Platform-specific (Android, iOS)
- **NEW: Spec-to-Test Contract Table** — Maps 70+ critical spec requirements to test cases for traceability

**Status:** NORMATIVE — Defines testing requirements

---

## Informative Documentation (08-10)

These documents provide context, history, and supporting information. In case of conflict with specs 00-07, the specs take precedence.

### [08 - Consolidated Design Decisions](spec/08-decisions-consolidated.md)
Historical design decisions organized by topic:
- App identity (name, branding, pride theme)
- Platform & compatibility (target versions, limitations)
- Engine architecture (state machine design, timing model)
- Sub-chains (duress, low battery)
- Disarm mechanism (hold button, fake call, disguised reminder)
- Session screen (timer display, disarm controls)
- Stealth mode (hiding safety indicators)
- And 20+ more sections

**Status:** INFORMATIVE — Explains *why* design decisions were made

**New Section Added:** "Recent Decisions (Spec Conflicts Resolved)"
- Real phone call detection
- Timing configuration grouping
- Duplicate step button
- Fake call answer behavior clarification

---

### [09 - Glossary & Terminology Reference](spec/09-glossary.md)
Complete glossary of all terms used throughout specs:
- Core concepts (check-in, disarm, miss, escalation, retryCount, grace period, etc.)
- Check-in methods (hold button, disguised reminder, hardware button)
- Event types (countdown, fake call, SMS, phone call, alarm, emergency)
- Data models (SessionMode, ChainStep, EmergencyContact, SessionLog, etc.)
- Messaging & contacts (SMS queue, priority contact, message template, channel)
- Audio & vibration (ringtone, alarm, voice recording, vibration pattern)
- Location & logging (GPS, location recording, maps URL, session timeline)
- UI & UX (disarm slider, grace visual, progress bar, missed counter)
- Platform-specific (full-screen intent, foreground service, wake lock, etc.)
- Localization (ARB format, locale, placeholder, native speaker review)
- Testing (simulation mode, speed bar, leap button, test case, deterministic random)
- Settings & configuration (global defaults, per-step override, duress PIN, etc.)
- Error handling (non-blocking failure, crash recovery, watchdog, fail loud)
- Brand & legal (Ask for Angela, Guardian Angela, pride branding, disclaimer)
- Architecture & design patterns (pure Dart, strategy pattern, Riverpod, GoRouter, etc.)
- Version & compatibility (schema version, migration, semantic versioning, minimum SDK)

**Status:** INFORMATIVE — Define all terminology for consistency

---

### [10 - Platform Capability Matrix](spec/10-platform-matrix.md)
Complete feature-by-platform support matrix:
- 11 core session features
- 7 messaging features
- 6 phone call features
- 8 fake call features
- 11 notification features
- 8 audio features
- 6 vibration features
- 7 location features
- 5 camera/flash features
- 4 hardware button features
- 9 background execution features
- 6 biometric & security features
- 6 data storage features
- 8 accessibility features
- 2 internationalization features

Plus:
- Platform-specific limitations (iOS SMS, calls, hardware, etc.)
- Workarounds and mitigations
- Permission summary by platform
- Testing approaches per platform
- Version compatibility matrix
- Verification checklist before release

**Status:** INFORMATIVE — Documents platform-specific capabilities and workarounds

---

### [11 - Deferred Enhancements](spec/11-deferred-enhancements.md)
Future enhancements specified but not yet implemented:
- **DE-1:** Timer sliders — minimum 0, extended range (up to 1 year),
  logarithmic snap stops (0, 1, 2, 5, 10, 20, 30s, 1m, 2m, 5m, ...),
  direct numeric entry field
- **DE-2:** Per-event GPS logging — tri-state config key per step
  (default / on / off) with global default fallback, "More settings"
  collapsible section in step editor
- **DE-3:** Session tracking — interval-based GPS recording with
  circular buffer, used as "last known position" in SMS templates,
  configurable per-mode with tracking section in mode editor
- **DE-4:** "More settings" pattern — two-tier config layout splitting
  common settings (always visible) from advanced settings (collapsible),
  with badge showing customized count

**Status:** DEFERRED — Implement later, independently of current release

---

### [12 - Rewrite Design Decisions](spec/12-rewrite-decisions.md)
All design decisions from the April 2025 complete rewrite:
- Core philosophy: "User is always in control, but critical actions require PIN"
- Removed features: crash recovery, shake-to-SOS, battery bypass
- Engine amendments: sealed EngineState, fake call lifecycle, retry timing
- NEW trigger system: distress triggers + disarm triggers per mode
- Redesigned simulation: background sim, defense-in-depth (4 layers)
- Data model amendments: sealed StepConfig, medical profile, trigger models
- Settings amendments: stealth hardening, session locks, Quick Exit
- Redesigned seed data (Walk Mode, Date Mode)
- Language expansion (14 languages, 3 RTL)
- Platform-specific notes (Android 14+, iOS limitations)

**Status:** NORMATIVE — SUPERSEDES conflicting statements in specs 00–11

---

## Key Metrics

- **Spec Documents:** 11 (00-10)
- **Total Pages:** ~600+
- **Normative Specs:** 8 (00-07)
- **Informative Docs:** 3 (08-10)
- **Test Cases:** 168+ with P1/P2/P3/P4 prioritization
- **Spec-to-Test Coverage:** 70+ critical requirements mapped to test cases
- **Glossary Terms:** 100+
- **Platform Matrix Entries:** 70+ feature combinations
- **Code Examples:** Throughout (Dart, SQL patterns, API usage)

---

## How to Use This Index

### For Implementation
1. Read **00 - Overview** for context
2. Start with **01 - Chain Engine** for core logic
3. Reference **02 - Event Types** for each step implementation
4. Use **03 - Data Models** for persistence layer
5. Build UI from **04 - Screens & Navigation**
6. Implement services from **05 - Services**
7. Add configuration from **06 - Settings**
8. Test against **07 - Test Plan** (use spec-to-test table)

### For Testing
1. Use **07 - Test Plan** as primary guide
2. Cross-reference **Spec-to-Test Contract Table** to ensure coverage
3. Verify platform-specific tests with **10 - Platform Capability Matrix**
4. Consult **09 - Glossary** for terminology consistency

### For Specification Conflicts
1. Check **01-07** (normative) first
2. If not found, check **08** (design decisions)
3. Use **09** (glossary) and **10** (platform matrix) for clarification
4. In case of conflict, normative specs (00-07) take precedence

### For Platform-Specific Behavior
1. Read **10 - Platform Capability Matrix** for feature availability
2. Check **05 - Services** for implementation details
3. Reference **07 - Test Plan** platform-specific tests
4. See **08 - Decisions** for platform limitations

---

## Document Status

All specifications are **COMPLETE and READY FOR IMPLEMENTATION**.

- [x] All 11 spec documents written and reviewed
- [x] Normative headers added to specs 00-07
- [x] Informative headers added to specs 08-10
- [x] All conflicts resolved (repeatCount → retryCount, fake call behavior, etc.)
- [x] Spec-to-test traceability established (70+ requirements mapped)
- [x] Complete glossary (100+ terms)
- [x] Platform capability matrix (70+ feature combinations)
- [x] Example chains and test scenarios included
- [x] All code examples and diagrams in place

---

## Version History

| Date | Event |
|------|-------|
| 2026-04-02 | Spec conflict resolution complete: retryCount finalized, fake call behavior clarified, real phone call detection added, timing grouping defined, duplicate step button specified, test-to-spec traceability established, glossary and platform matrix created |
| Earlier | Initial spec documents 00-07 drafted |

---

## Next Steps

1. **Immediate:** Share spec bundle with team for final review
2. **Week 1:** Begin Phase 1 (P1) implementation based on 01-chain-engine.md
3. **Week 2:** Implement data models from 03-data-models.md
4. **Week 3:** Build UI from 04-screens-navigation.md
5. **Week 4:** Integrate services from 05-services.md
6. **Week 5:** Run Phase 1 (P1) test suite (TC-1 through TC-90)
7. **Week 6:** Add settings from 06-settings.md
8. **Week 7:** Run full test suite (all 168+ tests)
9. **Week 8:** Platform-specific testing (Android, iOS)
10. **Week 9:** Beta testing and user feedback
11. **Week 10:** Final refinements and app store submission

---

**Specification Author:** Documentation Engineering Team  
**Last Updated:** 2026-04-02  
**Status:** COMPLETE & READY FOR IMPLEMENTATION
