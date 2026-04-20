# Guardian Angela - Rebuild Strategy

> **Status:** ADVISORY. This document describes HOW a future full rewrite of
> Guardian Angela SHOULD be executed, and WHY each decision matters, based on
> lessons from five prior rewrite attempts (`old/`, `old2/`, `old3/`, `old4/`,
> `old5/`) and the current v6 codebase. Key words MUST, SHOULD, MAY follow
> RFC 2119.

---

## 1. Executive Summary

Guardian Angela is a safety-critical dead-man's-switch application. The
current codebase is the sixth iteration; each previous iteration reached a
functional state but accumulated enough drift, wiring bugs, and ownership
confusion that a clean restart became easier than incremental repair.

This document is written for the person who starts rewrite number seven. It
collects the failure modes observed across prior rewrites (see
`docs/review/postmortem-v2-rewrite-bugs.md`, `docs/REWRITE_REVIEW.md`,
`docs/review/pm-final-all-phases.md`, `docs/review-bugs.md`,
`docs/review/remaining-gaps.md`) and prescribes a phased, test-first,
ownership-explicit approach that MUST be followed to avoid the same traps.

**Time budget (single engineer, or orchestrator + 2-3 specialized agents):**
approximately 180-240 engineering hours from empty folder to beta-ready
build, distributed across 10 phases. The budget was revised upward by
~20h from the original 160-220h estimate to cover Drift schema
scaffolding, migration harness, and schema-dump CI gating (see Phase 2
and principle P11). Aggressive parallelism can compress this to roughly
100-130 wall-clock hours, but only where the phase plan explicitly
authorizes it.

**Readiness gate:** Do not begin coding until every question in section 8
has a written answer, every phase has an agreed-upon exit checklist, and
the file-ownership manifest in section 9 has been assigned to named
owners (human or agent identifiers).

---

## 2. Lessons Learned from the Current Codebase

Each lesson states the failure, the root cause, and the concrete rule the
rewrite MUST adopt. Citations point to the source files or review reports
where the failure is documented.

### L1. Layers compiled in isolation; connections between them did not

**Failure.** In v2 (`docs/review/postmortem-v2-rewrite-bugs.md` section 1),
`SimulationPhoneService` was created, `simulationPhoneProvider` was created,
and tests for each passed -- but no code ever injected the simulation phone
service into `SessionController.startSession()`. Battery alert SMS read
`messagingServiceProvider` directly instead of the `_messaging` field
already plumbed through. `TimerDisarmTrigger` serialised correctly but
`TriggerManager.start()` never iterated disarm triggers.

**Root cause.** Parallel agents each owned one layer. Nobody owned the
SEAMS. Unit tests verified components; zero integration tests verified
wiring.

**Rule.** Every new model field, provider, or service MUST land together
with one integration test that exercises the full path from user action
through controller through engine through service. See L11 for the
concrete enforcement mechanism (wiring map).

### L2. Spec drift: models renamed but old constants and tests linger

**Failure.** `repeatCount` was renamed to `retryCount` (documented in
`docs/SPEC_INDEX.md` "Key Changes"), but references lingered and had to be
scrubbed across multiple agent passes. Similar drift occurred with
`declineIsSafe` (introduced, removed, reintroduced per decision A1 in
`docs/decisions-round-2.md`).

**Root cause.** The spec evolved during implementation. Agents coded
against one revision; reviewers read another. There was no single commit
where spec + code + tests all referred to the same identifier.

**Rule.** The rewrite MUST adopt a **spec-lock protocol**: rename
operations happen in one commit that touches the spec, all code, all
tests, and all ARB files simultaneously. CI MUST have a grep-based check
(`scripts/verify_no_legacy_names.sh`) that fails the build on a list of
forbidden legacy identifiers.

### L3. Defaults churn produced orphan legacy fields

**Failure.** `BatteryAlertConfig` was refactored at least three times --
once as fields on `AppSettings` (old2), once as a dedicated Hive model
(TypeId 18 in v3), once as a sub-chain style config (current). Each
iteration left behind a compatibility shim such as the `sendSms` getter
on `BatteryAlertConfig`. By v6 the shim was finally removed but only
after an audit.

**Root cause.** Each refactor was treated as "add the new thing, remove
the old later." The later never came.

**Rule.** Refactors MUST be atomic: no PR that introduces a new shape may
leave the old shape in source. If migration is needed for persisted data,
the migration MUST run in the same commit that removes the old shape. See
also decision 13 (`docs/decisions-round-2.md`): on schema mismatch, nuke
and re-seed; do NOT carry incremental migrations.

### L4. Copy-paste adaptations missed one critical line

**Failure.** `fake_call_screen.dart` was copied from `old4/` with a
`_decline()` handler in the decline-with-distress timer callback. The v2
spec added a distress chain trigger; the adapter updated the button but
forgot the timer callback (`postmortem-v2-rewrite-bugs.md` section 2).

**Root cause.** Copy-paste creates the illusion of completeness. The file
exists, compiles, looks right in diff. But a single buried callback is
wrong and neither linters nor unit tests catch it.

**Rule.** The rewrite MUST NOT copy files wholesale from any `old*/`
directory. Each feature is RE-IMPLEMENTED from the current spec, even if
the pseudocode looks identical. The `old*/` directories are reference
material for discussion, not source of truth.

### L5. Agents conflicted on shared hotspot files

**Failure.** `session_controller.dart`, `event_specific_config.dart`
(now `step_config.dart`), and `service_providers.dart` were each edited
by 3+ agents in parallel during the v2 and v3 rewrites, producing merge
conflicts, duplicated logic, and logic loss. `session_controller.dart`
accumulated two `startSession()` method bodies that had to be
reconciled manually.

**Root cause.** No file-level ownership manifest. Parallelisation was
decided by topic ("you do models, you do services") but topics overlap at
hotspot files.

**Rule.** Section 9 of this document is the file-ownership manifest. A
file MUST have exactly one agent owner at any given phase. Cross-cutting
edits are scheduled sequentially OR routed through the owner.

### L6. Translations lagged behind feature work

**Failure.** The codebase repeatedly reached a state where
`app_en.arb` had new keys that 13 other ARB files lacked. `flutter gen-l10n`
still compiled because missing keys fall back to English, but the user-
visible result was an app that silently switched languages mid-screen.
Adversarial review (`docs/review/adversarial-user-review.md`) caught this
in v4 and v5.

**Root cause.** Translations were queued as "do at the end." Every feature
added 2-8 new strings; by the end there were hundreds of untranslated
keys.

**Rule.** The rewrite MUST treat translation as part of "done" for any
feature. The CI MUST fail if any non-English ARB file is missing a key
present in `app_en.arb`. The orchestrator MUST launch the 13 translation
subagents automatically at the end of every PR that touches `app_en.arb`
(this is already encoded in `CLAUDE.md` but was not always followed).

### L7. Late verification meant fixes cascaded

**Failure.** The v2 rewrite ran `flutter analyze` + `flutter test` at each
phase, but deferred compliance verification ("does this match the spec?")
to a single large audit at the end. That audit found 2 critical, 5 high,
10 medium spec violations (`v2-final-spec-compliance.md`). Some fixes
required changes to five phases' worth of code.

**Root cause.** Verification timing. By the end, fixing a Phase 1 error
means re-visiting Phases 2-8.

**Rule.** Every phase MUST end with a spec-compliance check scoped to
that phase's artifacts only. The final audit MUST find nothing new; if it
does, the responsible phase is reopened and the earlier verifier's report
is reviewed.

### L8. No PIN hashing despite UI claiming PIN support

**Failure.** `REWRITE_REVIEW.md` documents the v3 rewrite shipping with
`PinEntryScreen` and `PinSetupScreen` in source but `AppSettings` lacking
`appPinHash`, `duressPinHash`, `sessionEndPinHash` fields. `AuthGate` was
a no-op pass-through. PIN support LOOKED complete but the backing store
did not exist.

**Root cause.** Feature work was split: one agent built PIN UI, another
updated AppSettings. The wiring between them was nobody's job.

**Rule.** No UI that captures a user-visible value may land without a
persistence path that is covered by a round-trip test. See phase 2 exit
criteria in section 3.

### L9. EventStrategyRegistry missing 3 of 9 strategies

**Failure.** `REWRITE_REVIEW.md` section 1.2 documents that
`EventStrategyRegistry._map` registered only 6 strategies despite 9
`ChainStepType` values and 9 strategy files existing. Calling
`forStep()` on `phoneCallContact`, `holdButton`, or `hardwareButton`
threw `ArgumentError` at runtime.

**Root cause.** The registry was populated manually; the enum was not.
There was no exhaustiveness check.

**Rule.** Every dispatch table indexed by an enum MUST have a test that
iterates the enum values and asserts each is handled. Better: use a Dart
sealed class or switch expression that the compiler verifies exhaustive.

### L10. WorkManager / background service wiring worked in fake mode only

**Failure.** `SmsWorker` existed, Kotlin channel code existed, but the
Dart side only ever used fakes in unit tests. Real device testing
discovered that `NotificationService.init()` was never called from
`main.dart` (`remaining-gaps.md` GAP-13). SMS retry queue used SMS
intents via `url_launcher` rather than direct platform SMS, so automatic
escalation silently opened the SMS app and waited for a human tap (see
`review-bugs.md` CRITICAL 3).

**Root cause.** Platform channels were built but never exercised on a
real device by the agent team. The Flutter-side wiring that would have
called them was missing.

**Rule.** No service MAY be declared "done" until one end-to-end test
(integration test or manual smoke) runs it on a real Android device AND
a real iOS device (or platform simulator where acceptable). See phase 5.

### L11. The wiring map was implicit, not explicit

**Failure.** `maxPauseDuration` existed as a field on `SessionMode` and
as a parameter on `SessionEngine`, but the line in `session_controller.dart`
that passes it was missing (`postmortem-v2-rewrite-bugs.md` section 1).
This kind of bug appeared in eight different places across three
rewrites.

**Root cause.** The agent that built the engine did not know which
controller line passed the field. The agent that built the controller
did not check every model field for threading.

**Rule.** Before coding begins, the orchestrator MUST produce a wiring
map: for every model field and every provider, a table with columns
(model field, constructor parameter, controller call site, UI source).
Empty cells are forbidden. The map is living documentation; it MUST be
updated with every PR that adds a field or provider.

### L12. iOS and Android platform work was deferred and then underestimated

**Failure.** The MainActivity.kt file was deleted during the v6 rewrite
(see current `git status`) because the Kotlin platform channels no
longer compiled after Flutter dependency bumps. iOS Xcode target setup
for the widget extension is effectively impractical from an agent-only
workflow: it requires a human to open Xcode, add targets, sign identifiers,
and wire URL schemes.

**Root cause.** Agent-land cannot drive Xcode UI. The team attempted to
script it via `xcodegen` and `xcodeproj`, but missed at least two
manual steps that only surfaced on device.

**Rule.** The rewrite MUST budget a human-in-the-loop window for each
native platform (phase 5 and phase 9). These windows are scheduled, not
reactive. Agents prepare the manifest, entitlements, Swift/Kotlin
sources; a human runs Xcode/Android Studio once per phase to verify.

### L13. Test-count confusion across branches

**Failure.** During the v5 rewrite, two verification agents reported
different test totals for the same commit (4789 vs 4818 in internal
notes). The cause was that one agent counted test cases via `--reporter
expanded` and the other counted file-level `test()` declarations via
grep; they diverged because of `parameterized` tests.

**Root cause.** No canonical baseline file.

**Rule.** The repo MUST contain `docs/baseline.md` (one line per metric:
test count, analyze issues, locale coverage) updated by CI on every
green build. All verification agents read this file; none compute their
own numbers.

### L14. Controllers hardcoded fakes instead of reading providers

**Failure.** `pm-final-all-phases.md` item 11 documents
`SessionController` lines 59-96 creating `FakeMessagingService`,
`FakePhoneService`, etc. directly, rather than reading from the Riverpod
service providers that the service team had carefully set up. Real
sessions therefore would never send SMS, call contacts, or play alarms.

**Root cause.** The session-controller agent built its own fakes while
waiting for the service agent. When the service agent finished, nobody
revisited the controller to swap the fakes for providers.

**Rule.** A TODO marker alone is insufficient. Stubbed dependencies MUST
raise `UnimplementedError` with a specific message, OR the stub MUST be
gated behind a test-only constructor that production code cannot reach.
See phase 4 and section 4 principle P6.

---

## 3. Proposed Rewrite Phasing

The rewrite is organised into 10 phases. Each phase has an objective, a
strict entry gate, a concrete exit checklist, and a time estimate. Phase
order is enforced: starting phase N requires N-1's exit checklist to be
green.

```
   P1        P2        P3        P4        P5        P6
Scaffold -> Models -> Engine -> Services -> Platform -> Screens
                                              |
                                              v
   P7        P8        P9        P10
Integration -> l10n -> Widget -> Release
```

### Phase 1 - Scaffold and Tooling

**Goal.** An empty Flutter app that builds, analyses with zero issues,
runs one smoke test, and has strict-mode CI green.

**Entry criteria.**
- Section 8 questions are answered in writing.
- File-ownership manifest (section 9) is reviewed and assigned.

**Steps.**
1. `flutter create` with explicit platforms android + ios.
   *Why:* establishes canonical folder layout; avoids later surprise
   when adding platform code.
2. Add dependencies pinned to current latest minors: `flutter_riverpod`,
   `go_router`, `drift` + `drift_dev` + `sqlcipher_flutter_libs` +
   `sqlite3_flutter_libs`, `flutter_secure_storage`, `intl`,
   `package:checks`, `fake_async`, `mocktail`, `sentry_flutter` (opt-out
   telemetry). See appendix A.
   *Why:* version pinning now prevents reproducibility rot later; see
   decision 16 in `docs/decisions-round-2.md`. Storage is Drift (SQLite
   with code-gen + migration APIs) encrypted via SQLCipher; see
   D-PLATFORM-1 in `docs/decisions-log.md`.
3. Set up `analysis_options.yaml` with `strict-casts`, `strict-inference`,
   `strict-raw-types`, `very_good_analysis` or equivalent.
   *Why:* L2 shows drift starts when lint is lenient.
4. Write `.github/workflows/ci.yml` covering format, import_sorter,
   `build_runner` (fails if stale), analyse, test, plus an l10n-parity
   check (see L6) and a legacy-identifier grep (see L2).
5. Configure `lefthook.yml` (pre-commit: format + import_sorter;
   pre-push: analyse + test).
6. Create `docs/baseline.md` with `tests: 0`, `analyze: 0 issues`,
   `l10n: 0/14 covered` (see L13).
7. Write one trivial widget test (`expect(find.text('Guardian Angela'),
   findsOneWidget)`) and make it pass.

**Exit criteria.**
- CI green on a clean clone.
- `flutter analyze --fatal-infos` passes.
- `flutter test` passes with at least one real test.
- `docs/baseline.md` exists and reflects reality.

**Risks + mitigations.**
- Risk: Flutter/Dart SDK upgrade breaks a dependency.
  Mitigation: pin SDK in `pubspec.yaml` `environment:` AND in the CI
  flutter-action `channel: stable` + `flutter-version: <pinned>`.

**Estimate.** 6-10 hours.

### Phase 2 - Models and Repositories

**Goal.** All persistent domain models exist, round-trip to/from JSON,
and persist through Drift (SQLite) repositories encrypted with
SQLCipher.

**Entry criteria.** Phase 1 exit green.

**Steps.**
1. Define every model in `lib/domain/models/` (sealed `ChainStep`,
   `StepConfig`, `SessionMode`, `EmergencyContact`, `UserProfile`,
   `AppSettings`, `AppDefaults`, `DistressChain`, `BatteryAlertConfig`,
   `SessionLog`, `ReminderTemplate`, triggers). Each model is immutable,
   has `toJson`/`fromJson`, `copyWith`, and uses sealed classes where
   configuration varies by type. Models remain pure Dart; Drift tables
   are a separate layer in `lib/data/db/`.
   *Why:* L8 shows that UI without a model backing is a common drift.
2. Write round-trip tests FIRST for every model (`json -> object ->
   json` must be idempotent).
   *Why:* L3 shows that legacy fields hide inside serialization if the
   test only goes one way.
3. Define Drift tables (`@DataClassName`) under `lib/data/db/tables/`,
   a single `AppDatabase` in `lib/data/db/app_database.dart`, and
   per-aggregate repositories in `lib/data/repositories/` that translate
   between domain models and Drift rows. Encrypt with
   `sqlcipher_flutter_libs`; derive the SQLCipher key via
   `flutter_secure_storage` (key generated on first launch and cached
   under Android Keystore / iOS Keychain). No ad-hoc DB access anywhere
   else.
   *Why:* Drift provides compile-time schema-safety, generated typed
   queries, and a first-class migration API. See D-PLATFORM-1.
4. Implement seed data in `lib/data/seed_data.dart` once; tests seed
   via `initForTesting()` using an in-memory SQLite `NativeDatabase.memory()`
   so suites never touch disk.
5. Lock the schema: `docs/spec/03-data-models.md` is the ONLY source of
   truth for table names, columns, and schema version; any change to
   either a Drift table or the schema version requires a spec edit and a
   migration step in the same commit.
6. Schema-migration policy: this is a pre-alpha rewrite. No production
   data exists; no migration from v6 to the new schema is written.
   From v1.0 onward, every schema-version bump MUST ship a forward
   migration with a dedicated migration test. On corruption or schema
   mismatch with no migration path, nuke-and-reseed (per decision 13).
   Write a migration test that:
   (a) opens a DB at version N-1 with fixture rows,
   (b) runs the app's migration,
   (c) asserts every row is readable and lossless under version N.

**Exit criteria.**
- `flutter test test/domain/models/` passes with round-trip coverage
  for every model.
- `flutter test test/data/db/` passes with at least one encrypted
  read/write per repo and one migration test per versioned schema.
- Drift schema dump checked in at `lib/data/db/schema/`; CI asserts the
  dump matches what `drift_dev schema dump` produces from source.
- `docs/baseline.md` updated.

**Risks + mitigations.**
- Risk: Drift schema drift between source and shipped schema.
  Mitigation: CI step `dart run drift_dev schema dump` + `diff`; fails
  the build on mismatch.
- Risk: SQLCipher key loss (user wipes secure-storage entry manually).
  Mitigation: fail loud on decrypt-failure; route the user to the
  backup-restore flow; do NOT silently recreate an empty DB.

**Estimate.** 16-24 hours (was 12-16; +4-8 for Drift scaffolding,
migration harness, and schema-dump CI gate).

### Phase 3 - Engine and Orchestration (pure Dart)

**Goal.** `SessionEngine` in pure Dart (no Flutter imports), all 9 event
strategies in an exhaustive registry, `SessionOrchestrator` binding
them.

**Entry criteria.** Phase 2 exit green; models ready.

**Steps.**
1. Create `lib/domain/engine/` with a static analysis rule that forbids
   `package:flutter/` imports under this directory. Enforce via a CI
   grep (see L1 principle).
2. Build the state machine using sealed `EngineState`
   (`EngineIdle`, `EngineRunning`, `EnginePaused`, `EngineSubChainActive`,
   `EngineEnded`). Each state exposes only the transitions it admits.
3. Three-phase timer (wait -> duration -> grace) with jitter factor
   `0.8 + random.nextDouble() * 0.4`. Inject `Random` so tests can pin
   it to `_FixedRandom(0.5)`.
4. Write engine tests FIRST, one per spec section in
   `docs/spec/01-chain-engine.md`. Use `fakeAsync` for determinism.
   *Why:* L7 says the final audit should find nothing new; this is
   only possible if each spec paragraph has a test at the time of
   writing.
5. Strategies live in `lib/domain/orchestration/strategies/`. The
   registry uses `switch (ChainStepType)` with exhaustive-match enforcement
   (Dart 3 switch expression). No `ArgumentError` fallback (see L9).
6. Strategies depend on **protocol** abstractions from
   `lib/services/protocols/`, not concrete implementations. Phase 3 uses
   in-memory fakes; phase 4 will wire real implementations.

**Exit criteria.**
- Every sealed `EngineState` has at least one test.
- Every `ChainStepType` has a strategy test covering both `executeReal`
  and `simulationDescription`.
- Engine directory contains zero Flutter imports (grep-verified).
- Test count in `docs/baseline.md` reflects the new total.

**Risks + mitigations.**
- Risk: sub-chain snapshot/restore gets complex and hard to test.
  Mitigation: strictly replace-and-no-return distress chain per decision
  (section 00 overview; see also `docs/review/spec-compliance-final.md`).

**Estimate.** 28-36 hours.

### Phase 4 - Services (Protocols + Fakes + Real Dart)

**Goal.** Every service has a protocol, a deterministic fake, and a real
Dart implementation. Service provider wiring is complete; session
controller reads from providers only.

**Entry criteria.** Phase 3 green. Wiring map complete for all services.

**Steps.**
1. For each service listed in `docs/spec/05-services.md`, define:
   - `lib/services/protocols/<name>_protocol.dart` - the abstract
     interface.
   - `lib/services/fakes/fake_<name>.dart` - deterministic fake for
     tests.
   - `lib/services/implementations/<name>_impl.dart` - real Dart
     implementation (NOT platform channels yet; those are phase 5).
2. Wire providers in `lib/services/service_providers.dart`. Each
   provider returns the real impl by default; tests override with fakes
   via `ProviderContainer.overrides`.
3. Write one integration test per service: "given a minimal chain that
   uses service X, when the step fires, X's fake records the call."
   *Why:* L1, L14 - verify connections, not just components.
4. Session controller MUST read all services from providers. No
   inline fakes in production code. Enforce via a grep test:
   `grep -r "Fake" lib/features/` yields zero matches.

**Exit criteria.**
- Every service has a passing fake-based integration test.
- `lib/features/**` contains no `Fake*` references.
- Simulation mode integration test passes: real session
  uses real impl, simulation session uses simulation subclass (per spec
  00 "Defense-in-depth - 4 layers").

**Risks + mitigations.**
- Risk: Defense-in-depth layer count diverges from spec.
  Mitigation: concrete assertion in a test:
  `expect(controller.messagingService, isA<SimulationMessagingService>())`.

**Estimate.** 20-28 hours.

### Phase 5 - Platform Native (Android Kotlin + iOS Swift)

**Goal.** Real SMS, real hardware volume button, real call state, real
home widget foundation, real foreground service.

**Entry criteria.** Phase 4 green. Human reviewer available for Xcode /
Android Studio sessions.

**Steps.**
1. Android: `MainActivity.kt`, `SmsChannel.kt`, `SmsWorker.kt` with
   WorkManager + exponential backoff, `CallStateChannel.kt`,
   `SystemUiChannel.kt`, `PhoneCallHelper.kt`, `BootReceiver.kt`.
   Channel namespaces: `com.guardianangela.app/<name>`.
2. Android manifest: permissions (FOREGROUND_SERVICE, SEND_SMS,
   CALL_PHONE, POST_NOTIFICATIONS, USE_EXACT_ALARM per decision 38),
   BootReceiver intent filter, service declaration.
3. iOS: `CallStatePlugin.swift` with CXCallObserver, `SystemUiPlugin.swift`
   (no-op stubs for Android-only operations per spec 10).
4. Wire each Dart protocol impl to its channel.
5. Run real-device smoke tests per phase-5 checklist (see appendix C).
   *Why:* L10 - platform channels without real-device verification
   remain broken.
6. Document each native limitation in `docs/spec/10-platform-matrix.md`
   with specific workaround code paths.

**Exit criteria.**
- All phase-5 smoke tests pass on at least one real Android device
  (API 26+) and one real iOS device (iOS 17+).
- `SmsWorker` exponential backoff verified by fake-device SMS deliverer.
- Hardware volume press count (5x, per decision B1) triggers distress.
- No `sms:` URI path exists; direct `SEND_SMS` path only (fix for
  `review-bugs.md` CRITICAL 3). Android users with SEND_SMS denied
  see a blocking pre-flight dialog; there is no silent `sms:` fallback.

**Risks + mitigations.**
- Risk: SEND_SMS policy rejection on Play Store.
  Mitigation: apply for the Play Console SMS-policy exemption in
  parallel with Phase 5 implementation (see Phase 10). Application
  package includes: justification document, demo video, privacy policy
  excerpt, emergency-use-case explanation. Prepare before submission,
  not after rejection.
- Risk: iOS 17 floor excludes older devices.
  Mitigation: accepted trade-off (see Accepted Risks). iOS 17 is
  required for AppIntent-based interactive widgets; dropping iOS 16
  removes a second UI path and ~30% of the widget test matrix.

**Estimate.** 24-32 hours (including human time).

### Phase 6 - Feature Screens and Riverpod Controllers

**Goal.** All 24 screens exist, all Riverpod controllers bind
user-visible state to models, every route in `app_router.dart` is
reachable and renders.

**Entry criteria.** Phase 5 green; native services callable.

**Steps.**
1. Build screens in order of user criticality: Home -> Session ->
   FakeCall -> SessionCompleted -> Onboarding -> Settings hub ->
   Security submenu -> Defaults submenu -> per-mode editors -> history.
   *Why:* if time runs out, users still get the core safety flow.
2. Each screen uses private widget classes (never helper methods
   returning Widget), follows the 80-column rule, and has at least one
   widget test per critical state.
3. Route names in `lib/core/constants/route_names.dart`; routes in
   `lib/router/app_router.dart`. CI runs a route-parity check: every
   `RouteNames.X` MUST appear in a `GoRoute(name: ...)` entry.
   *Why:* `remaining-gaps.md` GAP-1 through GAP-7 show this fails
   repeatedly.
4. Every controller uses `ProviderContainer.overrides` in tests to
   inject fakes; never instantiated directly.

**Exit criteria.**
- All 24 routes render without exception on test harness navigation.
- Controller test coverage for each critical controller
  (session, settings, modes, contacts, templates, profile, pin).
- `flutter analyze --fatal-infos` remains green.
- No unlocalised strings in any Widget `build()` method (lint rule
  enforced).

**Risks + mitigations.**
- Risk: hotspot file conflicts in `session_controller.dart`.
  Mitigation: enforce L5 - single owner per phase for this file.

**Estimate.** 36-48 hours.

### Phase 7 - Integration Tests and Simulation Mode

**Goal.** End-to-end integration tests for every user persona in section
00 overview; simulation mode defense-in-depth verified.

**Entry criteria.** Phase 6 green.

**Steps.**
1. Use `package:integration_test` for: onboarding -> profile -> start
   session -> hold -> disarm; date mode -> disguised reminder ->
   respond; distress flow (hardware panic -> confirmation -> chain
   replacement); duress PIN silently fires distress.
2. Run simulation mode tests at 1000x speed (per decision 00 overview).
   Each blocked action (SMS, call, emergency) MUST produce a `[SIM]`
   card and MUST NOT invoke the real service. Assert both.
3. Add a specific anti-regression test per bug fixed in prior
   rewrites: PIN sub-chain trigger on wrong-PIN threshold, battery alert
   uses injected messaging not the global provider, disarm cancels
   pending WorkManager jobs (decision A5).

**Exit criteria.**
- All integration tests pass on emulator CI.
- Coverage report shows no regression from earlier baselines.
- Spec-to-test matrix in `docs/spec/07-test-plan.md` shows every normative
  requirement mapped to at least one passing test.

**Risks + mitigations.**
- Risk: flaky integration tests due to real timers.
  Mitigation: all domain-layer tests use `fakeAsync`; integration tests
  use speed multipliers to keep wall-clock time bounded.

**Estimate.** 20-28 hours.

### Phase 8 - Localisation (14 Languages)

**Goal.** Every user-visible string is localised in all 14 languages at
v1 launch: en, de, es, fr, ru, zh, zh_TW, hi, fa, uk, pl, el, ar, he.
RTL layout verified for fa, ar, he. No "launch with a subset, add the
rest later" path — all 14 are ship-blocking for v1.

**Entry criteria.** Phase 7 green. No string literals in Widget source.

**Steps.**
1. Audit `lib/l10n/l10n/app_en.arb` for completeness. Every key has a
   `@key` metadata entry describing context for translators.
2. Launch 13 translator subagents in parallel, one per non-English
   language. Each produces `app_<lang>.arb` with all keys translated
   and placeholders preserved.
3. Run `flutter gen-l10n`. CI asserts `grep -c '"' app_*.arb` is equal
   across all files (same key count).
4. RTL verification: golden tests for three representative screens in
   `fa`, `ar`, `he`.

**Exit criteria.**
- All 14 ARB files have identical key sets.
- `flutter gen-l10n` produces zero warnings.
- RTL golden tests pass.
- Language switching test: change language at runtime, verify rebuild
  within one frame (decision 43).

**Risks + mitigations.**
- Risk: translator subagent hallucinates plurals/placeholders.
  Mitigation: CI runs a placeholder-parity check:
  `{name}` in en MUST appear in every translation.

**Estimate.** 14-18 hours (wall-clock; much compressed by parallel
subagents).

### Phase 9 - Home Widget (Android + iOS)

**Goal.** Android AppWidget and iOS 17 WidgetKit extension with fake-call
button, session status text, quick exit button. Full interactive parity
on both platforms — iOS 16 dual-path code is explicitly out of scope
because the iOS minimum is 17 (see Phase 5 / Accepted Risks).

**Entry criteria.** Phase 8 green. Human reviewer available for Xcode.

**Steps.**
1. Dart side: `lib/services/implementations/home_widget_service.dart`
   using the `home_widget` package.
2. Android: `GuardianAngelaAppWidget.kt` with RemoteViews.
3. iOS: new Xcode target `GuardianAngelaWidget`, WidgetKit Swift
   source, AppIntent for button taps (iOS 17+, native support, no
   URL-scheme fallback).
4. Test on real devices: widget updates when session starts; widget
   button deep-links correctly; quick-exit prompts for PIN when
   configured (decision 62).

**Exit criteria.**
- Widget renders correctly on Android and iOS devices.
- Tap-through navigation works on both platforms.
- Quick Exit PIN gating verified end-to-end.

**Risks + mitigations.**
- Risk: iOS code signing / provisioning for widget target.
  Mitigation: budget human time; document exact Xcode menu path in
  `docs/ios-setup.md`.

**Estimate.** 16-22 hours (including human time).

### Phase 10 - Release Hardening

**Goal.** Debug + release builds on both platforms, manual smoke test on
three devices, privacy policy + legal disclaimers reviewed, store
submission artifacts prepared.

**Entry criteria.** Phase 9 green.

**Steps.**
1. Obfuscation + tree shaking: `flutter build apk --release
   --obfuscate --split-debug-info=<dir>`; same for iOS.
2. Performance check: cold start under 3 seconds, session start
   latency under 500 ms (spec 00 success criteria).
3. Accessibility audit: WCAG 2.1 AA contrast checks, font scaling at
   200%, TalkBack/VoiceOver smoke test.
4. Manual regression: one session per mode per platform, verify SMS
   delivery, verify emergency call confirmation slider.
5. Store-ready artifacts: icons, screenshots, privacy policy, terms,
   Play Console / App Store Connect listings.
6. **Google Play SMS-policy exemption application.** File the SMS /
   Call Log Permissions Declaration in Play Console before the first
   internal-testing upload. The application package (prepared during
   Phase 5) includes: feature justification ("automated emergency
   alerts from a dead-man's-switch safety chain"), demo video
   showing the full escalation flow, privacy policy link, and the
   explicit statement that the app is a "default SMS handler
   alternative: no — safety-critical automated messaging." Track
   the review ticket. Exemption status blocks production release but
   does NOT block internal / closed testing tracks.
7. **Telemetry wiring.** Sentry (or equivalent) is initialised with
   opt-OUT defaults: crash + basic usage metrics on by default, user
   toggle in Settings → Privacy that flips to `telemetryEnabled =
   false` at runtime. No PII in events. No network call at all when
   disabled (assert via integration test).

**Exit criteria.**
- Both release builds install and run on target devices.
- All success-criteria metrics in spec 00 section 15 are met.
- Privacy policy published at public URL (includes telemetry
  disclosure + opt-out instructions).
- Google Play SMS-policy exemption application submitted; internal
  testing track live while review is pending.

**Risks + mitigations.**
- Risk: review rejection due to SMS / emergency-call permissions.
  Mitigation: exemption application filed proactively with demo
  video, safety-case narrative, and privacy-policy excerpt. If
  rejected, appeal once; do NOT regress to `url_launcher` SMS —
  that path is permanently removed.

**Estimate.** 14-20 hours (exemption drafting overlaps with Phase 5).

---

## 4. Architectural Principles

Every principle below is enforced by a concrete mechanism. A principle
without enforcement is a wish.

### P1. The engine is pure Dart, always

*Why.* L1 shows that the engine is the single most-reviewed component
and must remain testable via `fakeAsync` without a widget tree.

*Enforcement.* CI step: `! grep -r "package:flutter/" lib/domain/engine/
lib/domain/orchestration/` returns non-zero. The pre-commit hook runs
the same grep.

### P2. Every strategy calls its service via a protocol, not a concrete type

*Why.* L14 - controllers reading concrete fakes broke simulation-vs-real
separation.

*Enforcement.* Integration test:
`expect(container.read(messagingServiceProvider), isA<MessagingServiceProtocol>())`.
Static analyzer custom rule (optional, via `custom_lint`): no
`Fake*` import under `lib/features/`.

### P3. Every spec change updates spec + code + tests + l10n together

*Why.* L2 - identifier drift compounds quickly.

*Enforcement.* PR template has four checkboxes. CI fails if
`docs/spec/` changed without `lib/` or `test/` changing, and vice
versa.

### P4. Refactors are atomic - no legacy fields survive

*Why.* L3 - three iterations of battery alert, each leaving shims.

*Enforcement.* Regression-test script `scripts/verify_no_legacy_names.sh`
has an explicit deny-list of identifiers that MUST NOT appear after a
rename (`repeatCount`, `declineIsSafe`, `sendSms`, ...).

### P5. Translation parity is a build gate

*Why.* L6 - translations always lag.

*Enforcement.* CI job: Python/Dart script compares key sets across all
`app_*.arb` files. Non-zero diff fails the build.

### P6. Stubbed code fails loud, not silent

*Why.* L14 - quiet fakes in production.

*Enforcement.* Every method body that is not yet implemented MUST
contain `throw UnimplementedError('<specific message>')`. No
placeholder `return null;` or empty method bodies. A grep test
enumerates all methods that return early without doing anything and
flags them.

### P7. Routes and enum switches are exhaustive

*Why.* L9 - missing registry entries.

*Enforcement.* Dart 3 switch expressions. The CI lints flag any
non-exhaustive switch on a sealed class or enum.

### P8. Spec-to-test traceability is mandatory

*Why.* L7 - late verification misses things.

*Enforcement.* `docs/spec/07-test-plan.md` contains a table mapping
every normative spec paragraph to at least one test ID. CI greps for
orphan tests (tests with no spec reference) and orphan spec
paragraphs (paragraphs with no test ID).

### P9. Wiring map is the source of truth

*Why.* L11 - implicit wiring always loses.

*Enforcement.* `docs/wiring-map.md` (living doc). A CI check parses the
map and asserts: every row's model field appears in a model file;
every constructor parameter appears in an engine/controller constructor;
every controller call-site line exists at the declared file:line. Map
is updated in the same PR as the field it describes.

### P10. Native platform code is reviewed with the Dart PR that calls it

*Why.* L10 - native code merged without Dart callers, or Dart callers
merged without native code.

*Enforcement.* PR template requires a "native changes" section listing
all files under `android/` and `ios/` touched. PR reviewer MUST verify
at least one smoke-test log excerpt per platform.

### P11. Persistence uses Drift with encrypted SQLite and versioned migrations

*Why.* Prior Hive-based revisions silently dropped fields on schema
changes (L3) and offered no compile-time safety on schema evolution.
Drift provides code-generated typed queries, a first-class migration
API (`MigrationStrategy`), a schema-dump command, and clean
integration with SQLCipher for AES-256 at-rest encryption. See
D-PLATFORM-1 in `docs/decisions-log.md` and Phase 2.

*Enforcement.*
- No direct `package:sqflite` or `package:hive*` import anywhere in
  `lib/`. CI grep fails the build on violations.
- Every bump to `AppDatabase.schemaVersion` MUST ship with a
  migration step in `onUpgrade` AND a migration test under
  `test/data/db/migrations/`. CI enumerates the versions Drift knows
  about and asserts there is a matching test file.
- `dart run drift_dev schema dump` output is committed under
  `lib/data/db/schema/`. CI re-runs the dump and fails on diff.

### P12. Platform floor is fixed at iOS 17+ and Android API 26+

*Why.* iOS 17 unlocks AppIntent-based widget interactivity, removing
the need to maintain two widget code paths. Android API 26 (Oreo) is
needed for NotificationChannels and `SCHEDULE_EXACT_ALARM` semantics.

*Enforcement.*
- `ios/Podfile` pins `platform :ios, '17.0'`; CI fails if lowered.
- `android/app/build.gradle.kts` pins `minSdk = 26`; CI fails if
  lowered.
- Any PR proposing to widen support (lower the floor) requires a
  decision-log entry superseding D-PLATFORM (iOS floor).

### P13. Telemetry is opt-out, off-network when disabled

*Why.* Prior rewrites had "no analytics" as an unverified claim.
D-TELEMETRY-1 sets opt-OUT crash + usage metrics with a user toggle.
Opt-out MUST prevent any network call, not merely drop server-side.

*Enforcement.*
- Integration test: with `telemetryEnabled=false`, a fake
  `HttpClient` records zero outbound requests across a full session
  run (including crash).
- Telemetry payloads MUST NOT include phone numbers, contact names,
  session bodies, location coordinates, or PIN hashes. Unit test
  asserts the scrubber drops these fields.

---

## 5. Process Conventions

### Work decomposition

Work is decomposed along the phase axis first, then along the
file-ownership manifest (section 9). Within a phase, agents work on
disjoint file sets. Cross-phase dependencies are blocking: an agent
cannot start phase 6 work while phase 5 is still open.

### Parallelism rules

- **Safe to parallelise:** model definitions (Phase 2), engine tests
  vs engine code (Phase 3 test-writing phase), per-language ARB
  translations (Phase 8), per-feature screens (Phase 6, different
  screens).
- **Unsafe to parallelise:** `session_controller.dart`, `session_engine.dart`,
  `service_providers.dart`, `app_router.dart`, `step_config.dart`,
  `seed_data.dart`, `app_settings.dart`. These are sequential-only.
- **Conflict resolution:** if two agents must touch a hotspot, one
  agent finishes, commits, and the other rebases. No concurrent edits.

### Verification cadence

- After every PR: run CI (format + imports + analyse + test +
  parity checks).
- After every phase: run a phase-scoped compliance agent that reads
  only that phase's exit criteria and reports deltas.
- After phases 3, 5, 7: run integration tests in addition to unit
  tests.
- After phases 8, 9, 10: run platform-specific manual smoke tests.

### Cross-cutting concerns

- **Localisation.** Every PR that edits `app_en.arb` auto-triggers the
  13 translator subagents (already encoded in `CLAUDE.md`). If the
  PR author disables this, CI fails.
- **Schema migrations.** Per decision 13: schema mismatch nukes and
  reseeds for corrupted state with no defined migration path. From v1.0
  onward, every schema-version bump MUST ship a forward migration +
  migration test (see P11). No PR touches `AppDatabase.schemaVersion`
  without a corresponding spec update in `docs/spec/03-data-models.md`.
- **Permissions.** Every new permission in `AndroidManifest.xml` or
  `Info.plist` requires a review note explaining why and a spec 10
  entry.

### Test-before-code vs code-before-test

**Spec-to-test wins.** Tests are written from the spec before the
production code. This inverts the v2 approach (code first, tests
to match) and catches missing features (L7). Exceptions: refactoring
existing green code, where tests come with the refactor.

### Baseline tracking

`docs/baseline.md` contains:

```
tests: <count>          # updated by CI on every green main build
analyze_issues: <count>
l10n_coverage: 14/14
native_smoke_android: <YYYY-MM-DD last passed>
native_smoke_ios: <YYYY-MM-DD last passed>
```

Agents read this file; agents do NOT compute their own counters
(L13).

---

## 6. Anti-Patterns to Avoid

Each item recalls a real prior mistake.

- **Parallel agents on `session_controller.dart`.** L5. Use
  file-ownership manifest.
- **Shipping PIN screens without PIN hashes in AppSettings.** L8. UI
  must land with storage.
- **Populating a registry/dispatch table manually.** L9. Use sealed
  switch expressions.
- **`catch (_) { /* silently fail */ }` in any service.** See
  `review-bugs.md` HIGH 5. Fail loud, log at minimum.
- **`sms:` URI for emergency SMS.** See `review-bugs.md` CRITICAL 3.
  Direct `SEND_SMS` only. No `url_launcher` fallback — see AR-2.
- **Importing `package:hive*` anywhere under `lib/`.** Hive is removed
  (see D-PLATFORM-1). Persistence goes through Drift (P11).
- **Copying entire files from `old*/`.** L4. Re-implement per spec.
- **Deferring translations to "the end."** L6. Every PR localises.
- **Computing test counts via grep.** L13. Read `docs/baseline.md`.
- **TODO comments as wiring placeholders.** L14. Throw
  `UnimplementedError`.
- **Widgets with hard-coded string literals.** L6. All text via
  `AppLocalizations`.
- **Sub-chain snapshots without a corresponding disarm test.**
  Distress replacement per spec 00 section 9 MUST NOT be reversible.
- **Running release builds on emulator only.** L10, L12. Real devices
  required before declaring a native phase complete.
- **Growing `lib/features/` without per-feature tests.** Every feature
  PR includes at least one widget test.
- **Adding a package dependency without a pin and rationale.** See
  appendix A.

---

## 7. Success Metrics

The rewrite is done when ALL of the following are true:

| Metric | Target | Measurement |
|---|---|---|
| Spec behaviours covered by tests | 100% of normative paragraphs | Spec-to-test matrix |
| Static analysis | 0 issues, `--fatal-infos` | CI |
| l10n coverage | 14 / 14 ARB files, key parity | CI script |
| Android debug build | passes | CI + real device |
| Android release build | passes, obfuscated | `flutter build apk --release` |
| iOS debug build | passes | CI + real device |
| iOS release build | passes, archived | `xcodebuild archive` |
| Manual smoke test | 1 full walk-mode + 1 date-mode + 1 distress per platform | Tester log |
| Cold start | < 3 s on mid-range device | `flutter run --profile` trace |
| Session start latency | < 500 ms from tap to first event | Integration test timing |
| Test count | baseline + incremental per phase | `docs/baseline.md` |
| Coverage | >= 85% line, 100% of critical paths | `lcov` |
| Accessibility | WCAG 2.1 AA for all screens | Manual audit |

---

## 8. Questions for the Product Owner

Most previously-open questions have now been resolved in the most
recent product Q&A rounds; the resolutions are recorded here (and in
`docs/decisions-log.md`) rather than kept as open items.

**Resolved (reference):**
- **Schema continuity** — No migration. Rewrite is pre-alpha; existing
  v6 users will re-onboard. From v1.0 onward, every schema-version
  bump ships a forward migration + test (see P11).
- **iOS minimum version** — iOS 17+. Drops iOS 16, unlocks AppIntent
  widgets (see P12, Phase 9).
- **SMS channel** — Direct `SEND_SMS` only. Ship the Play Console
  SMS-policy exemption application in parallel; no `url_launcher`
  fallback (see Phase 5, Phase 10, Accepted Risks).
- **Translations** — All 14 languages at v1 launch. No "ship with a
  subset" path (see Phase 8).
- **Ask for Angela licensing** — Keep the "Guardian Angela" name;
  trademark risk accepted (see Accepted Risks).
- **Telemetry** — Opt-out crash + basic usage metrics via
  `sentry_flutter` or equivalent; user toggle in Settings; no
  network calls when disabled (see P13, Phase 10).
- **Emergency-number data source** — Bundle a comprehensive
  emergency-number database covering all countries + territories.
  SIM-country detection picks the default; user may override per
  session or globally.
- **Session-log retention cap** — Default 180 days; configurable
  30 / 90 / 180 / 365 / unlimited. Smart retention preserves
  critical events (distress fired, chain exhausted) independently of
  the normal retention cutoff.
- **Battery-alert contact policy** — When zero emergency contacts are
  configured, the battery-alert toggle is refused (disabled in
  Settings UI with a CTA to "Add at least one contact first").
- **Simulation silent default** — Silent = ON at every session start,
  including for power users. Each new simulation re-arms the flag;
  there is no persistent "remember my choice."
- **Stealth UI** — Both quick inline toggle on the home/session screen
  AND a detailed `/settings/stealth` screen (two entry points, same
  underlying `StealthConfig`).
- **Backup** — User-controlled content selector (pick modes, contacts,
  templates, profile, PIN hashes, session logs individually).
  Optional PIN-encryption with a user-supplied password (never the
  app PIN). Explicit warning shown if PIN hashes are included without
  encryption.

**Still open — require product-owner input before coding begins:**

1. **Widget parity timing.** Is the home widget (phase 9) in scope for
   the initial v1 release, or can it ship as v1.1?

2. **Backup format stability.** Once v1 ships, is backward
   compatibility of the exported backup JSON a goal for future
   major versions, or will each major have its own format? (Telemetry
   and PIN-encryption envelope schema are separate sub-questions.)

3. **Play Console / App Store Connect accounts.** Who owns the
   developer accounts? What is the budget for screenshots, app icon
   refinement, review videos? Who files and tracks the SMS-policy
   exemption?

4. **Beta testing cohort.** How many testers, recruited from where?
   When does the beta window open relative to phase 10 exit?

5. **Deferred features.** `docs/spec/11-deferred-enhancements.md`
   lists DE-1 through DE-4. Are any of these in scope for the
   rewrite, or are they all post-v1?

---

## 8a. Accepted Risks

The following risks have been reviewed and explicitly ACCEPTED by the
product owner. Each is documented here so a future reviewer does not
reopen the discussion without new information.

### AR-1. "Ask for Angela" trademark collision

**Risk.** The "Ask for Angela" safety campaign (UK-originated, now
widely adopted) is a recognised public-safety initiative. The app name
"Guardian Angela" is a deliberate wordplay on the campaign plus
"guardian angel." A trademark holder MAY object.

**Decision.** Accepted. The name ships as "Guardian Angela." If a
takedown request arrives, a contingency renaming plan is drafted in
`docs/spec/00-overview.md` branding section but NOT implemented
pre-emptively.

**Trigger for reopening.** Formal cease-and-desist or
Play-Console/App-Store-Connect takedown.

### AR-2. Google Play SMS-policy review

**Risk.** `SEND_SMS` Android permission requires a policy-review
exemption for apps that are not the default SMS handler. Review can
reject, delay, or require further information.

**Decision.** Accepted; mitigated by filing the exemption application
in parallel with Phase 5 (see Phase 10, step 6). Internal and closed
testing tracks do not require the exemption; production release is
gated on approval. No `url_launcher` fallback will be added.

**Trigger for reopening.** Second rejection after one appeal.

### AR-3. Non-English translation lag

**Risk.** Shipping all 14 languages at v1 means that a string change
post-launch forces an immediate 13-language re-translation. Agent-
driven translations may introduce subtle quality issues.

**Decision.** Accepted. The 14-language policy is ship-blocking for
v1 and for every subsequent release. The `CLAUDE.md` rule that any
`app_en.arb` edit auto-triggers 13 translator subagents and that CI
fails on a missing key stands. Native-speaker review of the initial
v1 translations is scheduled during Phase 8 exit.

**Trigger for reopening.** Native-speaker review identifies
unrecoverable quality in any locale; the decision to drop that
locale (not to delay launch) would re-open the policy.

### AR-4. iOS 17 floor excludes older devices

**Risk.** iOS 17 dropped iPhone 8 / iPhone X and earlier. A user
cohort on these devices cannot install Guardian Angela v1.

**Decision.** Accepted. The gain (single interactive-widget code path,
modern SwiftUI APIs, simpler CallKit semantics) outweighs the loss.
Spec 00 and the App Store Connect minimum-iOS field are both set to
17.0 (see P12).

**Trigger for reopening.** Beta telemetry shows > 10% of requests
originate from iOS 16 devices that could not install.

---

## 9. Appendices

### Appendix A - Dependency List with Version Pin Reasoning

| Package | Version | Why this pin |
|---|---|---|
| `flutter_riverpod` | ^3.0.0 | v3 introduces new Notifier API; v2 migration path painful. Pin major. |
| `go_router` | ^17.1.0 | Latest stable; v17 has stable query-param APIs. |
| `drift` | ^2.20.0 | Primary persistence layer — code-generated typed queries, migration API, stream support. See D-PLATFORM-1. |
| `drift_dev` | ^2.20.0 (dev) | Matches runtime; code-gen for Drift tables and schema dumps. |
| `sqlcipher_flutter_libs` | ^0.6.0 | SQLCipher AES-256 encryption for SQLite; pairs with Drift. |
| `sqlite3_flutter_libs` | ^0.5.0 | Bundled SQLite runtime (transitive via sqlcipher, but pinned for iOS build determinism). |
| `flutter_secure_storage` | ^10.0.0 | v10 unifies iOS Keychain + Android Keystore API. Used to store the SQLCipher key. |
| `sentry_flutter` | ^8.10.0 | Opt-out crash + basic usage telemetry per D-TELEMETRY-1. Runtime toggle disables network entirely. |
| `fake_async` | ^1.3.3 | Stable; breaking changes rare. |
| `package:checks` | ^0.3.1 | Experimental; pin minor to avoid assertion-API churn. |
| `just_audio` | ^0.10.5 | Needed for iOS ducking; ^0.10 required. |
| `audio_service` | ^0.18.17 | iOS headphone-remote C1 decision. |
| `record` | ^6.0.0 | v6 API change; migration guide handled once, pin major. |
| `flutter_local_notifications` | ^21.0.0 | Android 13+ notification permission handling. |
| `battery_plus` | ^7.0.0 | Battery-alert threshold monitoring. |
| `home_widget` | ^0.9.1 | iOS 17 AppIntent support in 0.9+. |
| `flutter_contacts` | ^2.0.2 | Device contact picker (decision 27). |
| `flutter_tts` | ^4.2.5 | Fallback when no built-in voice asset. |
| `patrol` | ^3.11.0 | Native UI automation for integration tests (permissions, panic triggers). See test-strategy §7. |

**Removed from the v6 dependency set:**
- `hive_ce`, `hive_ce_flutter` — superseded by Drift. Any import of
  these packages anywhere under `lib/` is a CI failure (see P11).

Rules for future additions:
- Every new dependency MUST justify its existence in a PR comment.
- Reassess the pin on every `flutter pub upgrade` round.
- Reject packages with fewer than 50 pub likes unless vetted by
  maintainer review.

### Appendix B - Sample Spec Template for New Features

```markdown
# <feature name>

**Status:** DRAFT | REVIEW | NORMATIVE
**Author:** <name>
**Date:** YYYY-MM-DD
**Supersedes:** <prior spec section, if any>

## 1. User-facing description
<One paragraph, persona-oriented.>

## 2. Models affected
<List model classes and the fields added/changed. Include Drift table
name, column, and schema-version bump if the change is persisted.>

## 3. Engine / controller interactions
<Which engine events fire. Which controllers consume them.>

## 4. Services required
<Protocols used. New protocol needed? New native channel?>

## 5. Screens / routes
<Route name, URL, query params, navigation source.>

## 6. Localisation keys
<List the new ARB keys with example values.>

## 7. Permissions
<Any new Android/iOS permission? Why?>

## 8. Tests required
<Unit, widget, integration. Map each test ID to the spec paragraph
it verifies.>

## 9. Risks / open questions
<One section per risk; owner named.>
```

### Appendix C - File Ownership Manifest

Ownership is phase-scoped. A single agent (human or AI) owns a file for
the duration of one phase; subsequent phases may reassign.

| File / directory | Phase-1 owner | Phase-3 owner | Phase-6 owner |
|---|---|---|---|
| `lib/main.dart`, `lib/app.dart` | Scaffold | - | Screens |
| `lib/domain/engine/` | - | Engine | - |
| `lib/domain/orchestration/` | - | Engine | - |
| `lib/domain/models/` | Models | Models | - |
| `lib/data/repositories/` | Models | Models | - |
| `lib/services/protocols/` | - | Engine | - |
| `lib/services/fakes/` | - | Engine | Services |
| `lib/services/implementations/` | - | - | Services |
| `lib/services/service_providers.dart` | - | Wiring | Wiring |
| `lib/features/session/session_controller.dart` | - | - | **Single owner** |
| `lib/features/session/session_screen.dart` | - | - | Session screen |
| `lib/features/home/` | - | - | Home |
| `lib/features/settings/` | - | - | Settings |
| `lib/features/modes/` | - | - | Modes |
| `lib/features/contacts/` | - | - | Contacts |
| `lib/features/templates/` | - | - | Templates |
| `lib/features/onboarding/` | - | - | Onboarding |
| `lib/router/app_router.dart` | Scaffold | - | Routing |
| `lib/core/constants/route_names.dart` | Scaffold | - | Routing |
| `lib/l10n/l10n/app_en.arb` | - | - | l10n owner |
| `lib/l10n/l10n/app_<lang>.arb` | - | - | per-language translator |
| `android/app/src/main/kotlin/...` | - | - | Native (phase 5) |
| `ios/Runner/` | - | - | Native (phase 5) |
| `docs/spec/*.md` | Spec steward | Spec steward | Spec steward |
| `docs/baseline.md` | CI (auto) | CI (auto) | CI (auto) |
| `docs/wiring-map.md` | Wiring owner | Wiring owner | Wiring owner |

**"Wiring owner"** is a cross-phase role. The wiring owner does not
write features; they audit every PR for field/provider threading and
maintain `docs/wiring-map.md`.

### Appendix D - Architecture Layers (diagram)

```
+----------------------------------------------------------+
|                     UI (Flutter)                         |
|   lib/features/<feature>/<feature>_screen.dart           |
|                                                          |
|                   watches providers                      |
|                          |                               |
|                          v                               |
+----------------------------------------------------------+
|              Controllers (Riverpod)                      |
|   lib/features/<feature>/<feature>_controller.dart       |
|                                                          |
|          reads repositories + services                   |
|                          |                               |
|                          v                               |
+----------------------------------------------------------+
|          Domain (pure Dart, no Flutter)                  |
|   lib/domain/engine/session_engine.dart                  |
|   lib/domain/orchestration/strategies/*.dart             |
|   lib/domain/models/*.dart                               |
|                                                          |
|          uses protocols, never impls                     |
|                          |                               |
|                          v                               |
+----------------------------------------------------------+
|              Services (Protocols)                        |
|   lib/services/protocols/<name>_protocol.dart            |
|                          |                               |
|                          v                               |
+----------------------------------------------------------+
|  Fakes (for tests)     |     Real (for production)       |
|  lib/services/fakes/   |     lib/services/               |
|                        |     implementations/            |
|                        |            |                    |
|                        |            v                    |
+----------------------------------------------------------+
|                 Native Platform Channels                 |
|   android/app/src/main/kotlin/...  |  ios/Runner/...     |
+----------------------------------------------------------+

INVARIANT: lib/domain/** MUST NOT import package:flutter.
INVARIANT: lib/features/** MUST NOT import Fake* services.
INVARIANT: lib/services/implementations/** MAY import platform channels.
```

### Appendix E - Phase Flow Timeline (diagram)

```
P1 Scaffold  [===]  (6-10h)
                 \
P2 Models         [=========]  (16-24h)
                           \
P3 Engine                   [===============]  (28-36h)
                                             \
P4 Services                                   [==========]  (20-28h)
                                                          \
P5 Platform (HUMAN IN LOOP)                                [============]  (24-32h)
                                                                         \
P6 Screens                                                                [==================]  (36-48h)
                                                                                               \
P7 Integration tests                                                                            [==========]  (20-28h)
                                                                                                            \
P8 Localisation (13 agents in parallel)                                                                      [======]  (14-18h)
                                                                                                                     \
P9 Home Widget (HUMAN IN LOOP)                                                                                        [=======]  (16-22h)
                                                                                                                               \
P10 Release                                                                                                                     [======]  (14-20h)


SERIAL GATES:  Every ">" is a hard gate: prior phase's exit criteria must be green.
HUMAN IN LOOP: Phases 5 and 9 require a human to drive Xcode / Android Studio once.
PARALLEL OK:   Within P2 (models), P3 (strategies), P6 (screens), P8 (translations).
```

### Appendix F - Wiring Map Fragment (example row format)

```
| Model field          | Constructor param    | Controller line              | UI source                           |
|----------------------|----------------------|------------------------------|-------------------------------------|
| SessionMode.maxPause | SessionEngine(maxP:) | session_controller.dart:104  | mode_editor_screen.dart: slider    |
| SessionMode.distress | engine.replaceChain  | session_controller.dart:449  | distress_chain_screen.dart: list   |
| AppSettings.pinTimeoutSeconds | PinDialog(timeout:) | session_screen.dart:207 | security_submenu.dart: slider    |
| AppSettings.appPinHash | AuthGate.verify    | auth_gate.dart:34            | pin_setup_screen.dart               |
| BatteryAlertConfig.thresholdPercent | BatteryMonitor(threshold:) | session_controller.dart:235 | battery_alert_screen.dart: slider |
```

Every row MUST have all four columns filled. An empty cell is a bug
backlog item.

---

*End of Guardian Angela Rebuild Strategy.*
