# Guardian Angela — v3 Implementation Plan

> **Audience:** The rewrite owner + any agents they dispatch. This plan
> sequences a ground-up rewrite of Guardian Angela using the freshly
> reconciled spec (`docs/spec/00-overview.md` through
> `docs/spec/11-deferred-enhancements.md`), the v2 postmortem
> (`docs/rewrite/lessons-learned.md`), and the carry-over manifest
> (`docs/rewrite/preservation-manifest.md`).
>
> **Scope:** This file is sequencing and process. It is NOT new
> architecture. The spec is the architecture. The lessons file is the
> process. This file orders the work.
>
> **Pre-alpha mode (per `project_prealpha_break_compat.md`):** no
> migrations, no shims, no CHANGELOG, no on-disk backward compat.

---

## 1. Goals & non-goals

### Goals

- **Spec → test → code, no exceptions.** Every normative requirement
  (every R-### from `docs/rewrite/spec-audit.md`, every numbered spec
  section) starts life as a failing integration test (per
  `lessons-learned.md §4.1` / `feedback_rewrite_process.md` rule 1).
  An undelivered feature MUST fail a test, not silently ship as a stub.
- **Zero-warning baseline from day 1.** `flutter analyze --fatal-infos`
  → 0 warnings 0 errors on every commit, enforced via lefthook pre-push
  + CI (per `lessons-learned.md §3` "What worked in v2").
- **No stub-ships-as-feature regression.** Every empty method body
  throws `UnimplementedError('TODO: …')` until wired (per
  `lessons-learned.md §4.6`, `feedback_rewrite_process.md` rule 5).
- **Wiring map continuously green.** `docs/wiring-map.md` and
  `test/wiring/wiring_map_coverage_test.dart` updated in lockstep with
  every controller, provider, model field, route, and strategy added
  (per `lessons-learned.md §4.2`, v2 §2.1 failure catalog).
- **Spec coverage matrix is checked-in code.** `test/spec_coverage_test.dart`
  asserts every R-### + every spec section ID maps to a real test (per
  `lessons-learned.md §4.5`).

### Non-goals

- **Backward compat with v2 on-disk data.** Pre-alpha. Nuke and reseed.
  No `fromJson` legacy branches (per
  `project_prealpha_break_compat.md`).
- **Parallel old-and-new running.** No "GO LIVE" mid-simulation, no
  feature-flag switch between v2 and v3 services. Rewrite happens on a
  clean orphan branch; cut-over is atomic (per
  `lessons-learned.md §5.8`).
- **Dual-rendering UI during transition.** No "old screen vs new screen"
  toggles. Each screen flips owner exactly once when its phase ships.
- **CHANGELOG.md / migration notes / "@Deprecated" shims.** Forbidden
  in pre-alpha (per `lessons-learned.md §4.10` and §6.1).
- **Resume-from-disk for sessions.** App-death = session is gone. No
  `bootRestart`, no on-launch scan for open sessions (per
  `feedback_no_session_restore.md`, `lessons-learned.md §5.2`).

---

## 2. Repo strategy

**Recommendation: `git checkout --orphan v3`** on the existing
`guardianangela` repository, with the v2 commit hash recorded in the
plan and v2 archived under a `v2-archive` tag before the orphan branch
is created.

### Why orphan branch (over sibling dir or in-place)

The orphan branch keeps the full v2 history accessible (`git log
v2-archive`) without dragging dirty code into v3's `flutter analyze`
runs, while keeping issue tracking, hooks, CI secrets, and the GitHub
remote unchanged. A sibling `guardianangela_v3/` directory would
fragment the issue tracker and CI; in-place rewrite on a branch fights
git status noise from 250+ deleted `.dart` files and risks accidental
revert via a stray `git checkout main -- lib/`. The orphan keeps the
new tree clean, the old tree intact, and the merge story trivial
(replace main with v3 at cut-over).

### Mechanics

1. `git tag v2-archive HEAD` on `main` (preserves the hash and
   commit chain).
2. `git checkout --orphan v3`
3. `git rm -rf .` (clears the working tree; orphan branch starts
   empty).
4. Bootstrap commits, IN ORDER, each as its own commit:
   - `chore: .gitignore` (Flutter standard, plus `.dart_tool/`,
     `build/`, `coverage/`, golden failures dir).
   - `chore: pubspec.yaml` (copied verbatim from manifest §4 row
     "Pubspec"; the `flutter_launcher_icons:` block and the
     `hooks:` block for sqlite3mc must come over).
   - `chore: analysis_options.yaml` (strict-casts /
     strict-inference / strict-raw-types per manifest §4).
   - `chore: lefthook.yml` (pre-commit format + import sort;
     pre-push analyze + test).
   - `chore: .github/workflows/ci.yml` (format / sort / analyze /
     test / dep audit / e2e gated on `v*` tags).
   - `chore: l10n.yaml`, `dart_test.yaml`, `.editorconfig`.
   - `chore: README + AGENTS + CLAUDE` (root docs).

After these 7 commits the repo lints clean against an empty `lib/`.
Phase 0 starts here.

---

## 3. Phase ladder

Each phase ends with: (a) a green `flutter analyze --fatal-infos`,
(b) all tests added in the phase passing, (c) a phase-checkpoint git
commit `phase-NN/<topic>`, (d) the wiring map updated (per
`lessons-learned.md §3`).

Per `feedback_rewrite_process.md` rule 1 and `lessons-learned.md §4.1`:
every phase begins by writing the failing tests for its spec section,
runs them red, then implements until they pass.

### Phase 0 — Repo skeleton (orphan + bootstrap + preservation copy)

- **What:** Land the 7 bootstrap commits from §2 plus the
  preservation copies from `preservation-manifest.md` Migration Recipe
  steps 4–12 — logo widget, icon PNGs, audio assets, 14 ARB files,
  spec corpus, all native Kotlin/Swift code, AndroidManifest, iOS
  Info.plist, golden baselines, test helpers (`test_helpers.dart`
  including `FixedRandom`), `dart_test.yaml`.
- **Why:** A working CI + the irreplaceables in place means every
  subsequent phase is incremental, not a copy-then-fix exercise.
- **Inputs:** `preservation-manifest.md` §0–§7.
- **Outputs:** Compilable empty-ish app shell (`flutter build apk
  --debug` succeeds with a placeholder MaterialApp), `flutter
  gen-l10n` clean against all 14 ARBs, `flutter pub get` resolves to
  the same lock as v2.
- **Verification gate:** Steps 18–24 of the preservation manifest
  Migration Recipe (format / sort / analyze / test / dep audit / two
  builds / locale visual check). The first `phase-coverage` test asserts
  the preservation manifest's "Top-Priority Preserve" list (10 items)
  exists on disk.

### Phase 1 — Domain models & enums

- **What:** Implement all spec 03 enums, sealed hierarchies, and data
  classes — **enums first, then sealed types, then classes that hold
  them** so JSON tests have something to round-trip against. Add the
  enums that R-21 (`LogGpsOverride`), R-22 (`CountdownStyle`),
  R-23 (`DistressTrigger` / `DisarmTrigger` sealed hierarchies), R-24
  (`GpsDestinationSource`) say were missing.
- **Why:** Models are the lingua franca every later phase imports.
  Get them right and tested or every later phase ships breakage.
- **Inputs:** `docs/spec/03-data-models.md` (entire file); audit
  recommendations R-2, R-5, R-6, R-7, R-10, R-11, R-13, R-14, R-17,
  R-21–R-24, R-37, R-40.
- **Outputs:** `lib/domain/models/*.dart` + `lib/domain/enums/*.dart`;
  JSON round-trip property tests in `test/property/` for every model
  (carry over from `test/property/json_round_trip_property_test.dart`).
- **Verification gate:** Property tests pass for all models; a
  spec-coverage test iterates every enum value and asserts it
  round-trips. Per `lessons-learned.md §4.13` (exhaustiveness gaps),
  every `switch` on an enum must be exhaustive (Dart switch expression
  on sealed enum compiles → compiler enforces).

### Phase 2 — Pure-Dart SessionEngine

- **What:** Implement the state machine from spec 01: sealed
  `EngineState` (`EngineIdle`, `EngineRunning`, `EnginePaused`,
  `EngineEnded`), `ChainEventData` event stream, three-phase
  per-step timing (wait / duration / grace), ±20% jitter,
  speed multipliers (foreground 1–1000x, background 1–60x; per
  audit X-22/R-20 the API method is `leap()`).
- **Why:** Engine is the heart of every safety guarantee. Pure Dart
  (no Flutter import) means deterministic tests with `fakeAsync` +
  `FixedRandom` — the survivor pattern from `lessons-learned.md §3`.
- **Inputs:** `docs/spec/01-chain-engine.md` (entire file);
  preserved `test/domain/engine/*.dart` (10 files) as the starter
  failing-test suite; audit R-1 (fakeCall is event-not-pause per Pivot
  2), R-9 (`retryCount` not `repeatCount`), R-20 (`leap` not
  `leapToNextEvent`).
- **Outputs:** `lib/domain/session_engine.dart` + sealed event /
  state classes; engine test suite all green; no Flutter import in
  the engine file (CI grep guard).
- **Verification gate:** Spec invariants from
  `01-chain-engine.md §Invariants` all asserted by tests; every state
  transition in the spec has at least one test; `engine_jitter_test.dart`
  uses `FixedRandom` (returns 0.5) for determinism.

### Phase 3 — Event Strategies

- **What:** Implement the 9 `EventStrategy` classes from spec 02 (one
  per `ChainStepType`) with `executeReal()` and
  `simulationDescription()`. Register via `EventStrategyRegistry` that
  uses a sealed switch over the enum so a missing strategy is a
  COMPILE error (per `lessons-learned.md §3` caveat: v2 registered
  6 of 9; v3 makes that impossible).
- **Why:** Strategy pattern is the survivor that prevents scattered
  switch-on-step-type in controllers. The compile-time exhaustiveness
  bar prevents the v2 "ArgumentError when step type fires" regression.
- **Inputs:** `docs/spec/02-event-types.md` (all 9 types); audit
  R-3 (siren+custom only — purge beep/whistle/scream), R-22
  (`CountdownStyle`), R-30 (gradual volume per-step × global
  interaction).
- **Outputs:** `lib/features/session/event_strategies/*.dart` (10
  files: 9 strategies + registry); one widget-free unit test per
  strategy verifying both `executeReal()` (against a fake service
  triplet) and `simulationDescription()` returns localized
  `SimulationDescription` value type (carry-over from
  `phase-C.2a` in v2 history).
- **Verification gate:** A test that iterates `ChainStepType.values`
  and asserts each maps to a non-null strategy. A separate test
  asserts simulation strategies never call real services.

### Phase 4 — Repositories + seed data

- **What:** Drift schema (per `preservation-manifest.md` notes that
  v2 moved off Hive to `sqlite3 + sqlite3mc` via Dart build hooks);
  repository classes (`JsonSingletonRepository`,
  `JsonListRepository` if still chosen, or Drift DAOs); seed data
  port from `lib/data/seed_data.dart` content decisions (Walk Mode,
  Date Mode, default distress mode per pivot 3, 8 templates, event
  defaults).
- **Why:** Without seeded defaults the app shell launches into an
  empty state and no integration test can exercise a mode. Per
  `preservation-manifest.md §7` the content decisions are
  multi-round-PM artifacts that must be ported step-by-step.
- **Inputs:** `docs/spec/03-data-models.md §Persistence` and
  §Seed; preserved `lib/data/seed_data.dart` (content reference);
  preserved `test/data/seed_data_test.dart` (regression check);
  audit R-39 (no "Spec 11 §DE-3" dead refs).
- **Outputs:** `lib/data/db/app_database.dart` + DAOs + generated
  `.g.dart` (under build_runner); `lib/data/seed_data.dart` (new);
  in-memory test DB helper (carry over
  `test/data/db/dao_test_support.dart`).
- **Verification gate:** Seed-data test asserts seeded shape matches
  the spec; `currentSchemaVersion` is one number in one place (per
  audit X-?, `03:1194`); schema-mismatch path nukes-and-reseeds with
  a single Drift-level assertion (per `lessons-learned.md §4.10`).

### Phase 5 — Services layer

- **What:** Service triplet for each service in spec 05 — protocol /
  Real / Simulation — registered as Riverpod providers. Add the
  missing `SessionLogRecorder` per audit R-25. Add the normative
  permission audit subsection per audit R-28. Wire the **simulation
  swap** so that `isSimulation=true` selects `SimulationFooService`
  for ALL services that touch the outside world (messaging, phone,
  audio, location, vibration, flash, screen-flash, notifications).
- **Why:** This phase is where v2 catastrophically failed (per
  `lessons-learned.md §2.1` — every wiring bug above). The simulation
  swap is the highest-stakes seam in the codebase.
- **Inputs:** `docs/spec/05-services.md` (entire file); audit R-25
  (`SessionLogRecorder`), R-28 (permission audit), R-41
  (`BatteryAlertConfig.sendSms` deletion).
- **Outputs:** `lib/services/*.dart` (one file per service triplet);
  `lib/services/service_providers.dart` (single owner of provider
  registration per `lessons-learned.md §2.7`); integration test:
  "starting a session with `isSimulation=true` injects every
  `Simulation*Service` and never reaches `Real*Service`" — this test
  alone would have caught the v2 phone bug.
- **Verification gate:** Wiring-map row exists for every provider;
  the simulation-swap integration test is green; the "stubs never
  silently succeed" lint passes (`UnimplementedError` grep CI
  check). **This is the single-wiring-owner phase** per
  `lessons-learned.md §4.7` — one agent owns all of `service_providers.dart`.

### Phase 6 — Screens & routing

- **What:** 24 screens per `docs/spec/04-screens-navigation.md`,
  GoRouter setup, route name enum (audit R-36 fixed the missing enum
  in the spec). First-launch detection routing to onboarding.
- **Why:** UI screens are the user-visible product. Independently
  test each as a widget test (Alchemist goldens from preservation
  manifest §6) once the underlying provider graph is wired.
- **Inputs:** `docs/spec/04-screens-navigation.md`; audit R-13
  (delete `/settings/modes-and-chains` hub), R-14 (3 hold styles
  only), R-15 (`/settings/templates/edit` route), R-16 (3-screen
  onboarding), R-17 (`SmsContactSelection` enum), R-33
  (empty-distress-modes invariant), R-36 (route name enum), R-42
  (deceptive PIN dialog — decide ship or drop).
- **Outputs:** `lib/features/<feature>/*_screen.dart` × 24,
  `lib/router/app_router.dart`,
  `lib/core/constants/route_names.dart`, per-screen widget tests +
  golden baselines (carry over).
- **Verification gate:** Every route name in the enum resolves to a
  screen; every screen widget test is green; golden images bit-match
  the preserved baselines (or new baselines accepted in a single
  documented commit if intentional).

### Phase 7 — Native channels

- **What:** Wire the preserved Android Kotlin (11 files per
  preservation manifest §3.1) and iOS Swift (per §3.2) into the new
  Dart side. The native code is copied verbatim; this phase writes
  the Dart `MethodChannel` callers + the integration tests that
  exercise them. Real-device smoke runs in Phase 10.
- **Why:** Per `lessons-learned.md §2.6`, v2 had native code that
  was exercised only by fakes — production paths never ran on
  device. This phase forces every channel to have at least one Dart
  integration test that goes through `MethodChannel.invokeMethod`.
- **Inputs:** Preserved native code (no rewrites unless a Dart-side
  contract changed); `docs/spec/10-platform-matrix.md` for the
  per-platform capability table.
- **Outputs:** `lib/services/<service>/native_<service>_bridge.dart`
  files; `integration_test/native_channels_test.dart` covering
  SMS, phone, call state, system UI, hardware button,
  device state, stealth icon, home widget.
- **Verification gate:** `flutter build apk --debug` and
  `flutter build ios --no-codesign` both succeed; integration tests
  pass against Patrol-driven emulator runs in CI's `e2e` job.

### Phase 8 — Localization

- **What:** Carry the 14 ARB files; verify all 1,000+ keys resolve;
  `flutter gen-l10n` clean. Wire the `AppLocalizations.of(context)`
  consumer into every screen built in Phase 6. Add the CI l10n parity
  check (per `lessons-learned.md §4.13`: hard fail if any non-English
  ARB lacks a key from `app_en.arb`).
- **Why:** Translation drift was a recurring v2 burn (per
  `lessons-learned.md §2.8`). Closing the parity gap in this phase
  and gating CI on it means every future string change forces the
  language fan-out.
- **Inputs:** Preserved 14 ARB files; audit R-9 ("repeatCount" →
  "retryCount" rename also lives in ARB keys if any) — none expected
  but verify.
- **Outputs:** Wired `AppLocalizations` everywhere; CI `l10n_parity`
  step green; placeholder docs cleaned up
  (no `<MISSING TRANSLATION>` strings).
- **Verification gate:** `flutter gen-l10n` reports zero
  untranslated-message warnings; the parity CI step is green; visual
  spot check (preservation manifest step 24) — switch locale through
  all 14, no English fallback mid-screen.

### Phase 9 — Integration tests + goldens

- **What:** Carry the golden baselines from preservation manifest §6
  (32 images + 4 CI-tier); implement every spec-07 test scenario as
  an `integration_test/` file. Add a `test/spec_coverage_test.dart`
  that asserts each R-### (45 of them per
  `docs/rewrite/spec-audit.md`) and each numbered spec section ID
  resolves to an existing test.
- **Why:** Per `lessons-learned.md §4.5`, "integration tests at EACH
  phase, not at the end". This phase formalizes the spec-coverage
  matrix that makes "did we cover R-23?" answerable by `flutter test`,
  not by hand-audit.
- **Inputs:** `docs/spec/07-test-plan.md`; preserved golden
  baselines; preserved integration tests
  (`integration_test/app_test.dart`, `date_mode_flow_test.dart`,
  `distress_flow_test.dart`, `walk_mode_flow_test.dart`); audit R-?
  (all spec-07 test IDs).
- **Outputs:** Full `integration_test/` suite; `test/spec_coverage_test.dart`;
  `test/wiring/wiring_map_coverage_test.dart` green over the now-full
  provider graph.
- **Verification gate:** `flutter test` reports 100% pass; the
  spec-coverage test asserts every R-### and every spec section ID
  has at least one associated test.

### Phase 10 — Real-device smoke

- **What:** Manual smoke run on a physical Android device covering:
  Quick Exit, hardware-button distress trigger (5× volume), all 3
  PIN flows (App PIN entry, Session End PIN, Duress PIN replaces
  with distress chain), simulation flow (start → 10× speed → SMS
  step blocked → toast), real Walk Mode session start → hold release
  → grace → SMS sent. Fill the manual checklist
  (preserved `docs/manual-device-test-checklist.md`).
- **Why:** Per `lessons-learned.md §2.6`, "Done" requires one
  real-device end-to-end run. The unit + integration test stacks
  cannot catch "NotificationService.init() was never called from
  main.dart" or "SMS retry uses url_launcher instead of platform
  channel".
- **Inputs:** Phase 9 green build; the preserved manual checklist.
- **Outputs:** Filled checklist; bug list (if any) opens GitHub
  issues; no `phase-10` commit lands until all sev-1 issues from the
  smoke run are fixed.
- **Verification gate:** Checklist 100% complete; each "FAIL" cell
  links to a fixed and re-tested commit.

### Phase 11 — Cut-over

- **What:** Replace `main` with the `v3` orphan branch as the new
  primary. Update README. Delete the `old*/` and v2-style review
  docs that are now obsolete (preservation manifest §5.3 review
  history stays — it's institutional memory). Tag the cut-over
  commit `v3-ga` (general availability of the rewrite, not the
  product). Record the v2 archive tag hash in `docs/rewrite/v3-plan.md`
  for posterity.
- **Why:** A clean cut-over with one tag is auditable. Leaving the
  v3 branch alive alongside main invites drift.
- **Inputs:** Phase 10 sign-off.
- **Outputs:** `main` = v3; `v2-archive` tag preserved; root
  `README.md` updated; cut-over commit; deleted preserved-but-obsolete
  docs.
- **Verification gate:** `git log main --oneline | head -1` shows
  the cut-over commit; CI green on `main`.

---

## 4. Process rules baked in

Mapping each `lessons-learned.md §4` rule to the phases where it
bites hardest. "All" = every phase verifies this rule continuously.

| Rule (lessons-learned §) | Phases where it bites |
|---|---|
| §4.1 spec → test → code | All (every phase starts test-red) |
| §4.2 wiring map mandatory | 2, 3, 4, 5, 6, 7 (every phase that adds a provider/field/route) |
| §4.3 sequential by default | All (no parallel agents unless triple-disjoint per §5 below) |
| §4.4 connected code = sequential | 5 (services), 6 (screens), 7 (native channels) |
| §4.5 integration tests EACH phase | All (every phase ends with an integration test that exercises new seams) |
| §4.6 stub detection (`UnimplementedError`) | All; CI grep guard added in Phase 0 |
| §4.7 single wiring owner | 5 (the wiring-owner agent owns `service_providers.dart` end-to-end) |
| §4.8 ARB fan-out | 8, and any prior phase that adds an ARB key |
| §4.9 flutter test concurrency | All (`--concurrency=6` default; drop flag when other agents running tests) |
| §4.10 nuke-and-reseed pre-alpha | 4 (schema mismatch path), 11 (cut-over deletes v2 disk) |
| §4.11 task ledger checkpoints | All (use TaskCreate/TaskUpdate per `feedback_interruption_resilience.md`) |
| §4.12 motivation in specs | Already satisfied in current spec; rule applies if new spec text is added |
| §4.13 hard fail on legacy IDs / l10n drift / exhaustiveness | All; CI guards land in Phase 0 |

---

## 5. What NOT to delegate to parallel agents

Per `lessons-learned.md §4.3` + `feedback_parallelism_default_sequential.md`,
parallel only when files are fully disjoint, no shared mutable state,
no shared artifact. The following are NEVER parallel:

- **`lib/domain/session_engine.dart`** — single file, single owner
  per phase. Splitting the engine across agents is what produced two
  `startSession()` bodies in v2 (per `lessons-learned.md §2.7`).
- **`lib/router/app_router.dart`** + `lib/core/constants/route_names.dart`
  — every new screen adds a row; merging from two agents = merge
  conflict.
- **`lib/services/service_providers.dart`** — the single wiring-owner
  file (per `lessons-learned.md §4.7`).
- **Drift schema migrations** — every `@HiveType` / `@DataClassName`
  change must serialize through one agent or the generated `.g.dart`
  files fight each other.
- **`docs/wiring-map.md`** + `test/wiring/wiring_map_coverage_test.dart`
  — same artifact, two readers means two diffs of the same table.
- **Anything that edits `pubspec.yaml`** — dep additions are serial.
- **`lib/main.dart`** — the bootstrap path; mis-merge = app won't
  start.

---

## 6. What CAN be parallelized

The legal-parallel batches per `lessons-learned.md §4.8` and §3:

- **13 non-English ARB files** (one agent per locale, the canonical
  example). Phase 8, and any prior phase that adds a key.
- **Per-screen golden image generation** once Phase 6's screens
  compile (each golden test file is disjoint).
- **Per-screen widget tests** once the underlying screen files exist
  AND each test owns its `screen_<feature>_widget_test.dart` file.
- **Per-model JSON round-trip tests** in Phase 1 (each
  `test/property/json_round_trip_<model>_test.dart` is disjoint).
- **Android native ∥ iOS native** in Phase 7 (disjoint trees).
- **Spec-coverage matrix generation** — read-only on the spec
  files, write-only to `test/spec_coverage_test.dart` from a single
  generator agent.

---

## 7. Verification gates (continuous across all phases)

Three gates that MUST be green at the tip of every phase commit:

1. **`flutter analyze --fatal-infos` → 0 warnings, 0 errors.**
   Enforced by lefthook pre-push + CI `analyze` step. Day-1 commit
   in Phase 0.
2. **`flutter test` → 100% pass.** Enforced by lefthook pre-push +
   CI `test` step. Concurrency `--concurrency=6` by default; drop
   when other agents are running tests (per `lessons-learned.md §4.9`).
3. **Spec coverage matrix → all 45 R-### + every spec section ID
   has at least one associated test.** Enforced by
   `test/spec_coverage_test.dart`. The test iterates a checked-in
   mapping `Map<String, List<String>>` (R-ID → list of test names)
   and uses `dart:mirrors`-free reflection over test names
   (alternatively, a build-time codegen that scans
   `@TestOn('vm') void main() { test('R-23 …', …); }` annotations).
   Day-1 stub in Phase 0; populated as phases land.

Additional CI guards (per `lessons-learned.md §4.13`):

- **Discontinued-deps audit** (hard fail) — preserved CI step.
- **L10n parity** (hard fail) — every non-English ARB has every key
  from `app_en.arb`. New CI step landing in Phase 0.
- **Legacy-identifier grep** (hard fail) — forbidden list:
  `DistressChain` (as a class name, not a noun in prose),
  `repeatCount` (replaced by `retryCount`), `SmsRecipient` (replaced
  by `SmsContactSelection`), `leapToNextEvent` (replaced by `leap`),
  `beep`/`whistle`/`scream` as enum identifiers,
  `notificationDisguise` as a `String?` (must be `bool`),
  `fakeIcon` as a `String?` (must be `StealthIconPreset`).
- **`UnimplementedError` grep** (warn, not fail) — every grep hit is
  a known-broken seam; CI prints the count so it cannot drift up
  silently.

---

## 8. Risk register

Risks pulled from `lessons-learned.md` (the v2 risks that bit). Each
has a mitigation that the v3 process enforces structurally, not by
discipline.

| # | Risk (v2 source) | Mitigation in v3 |
|---|---|---|
| R1 | **Wiring bugs at seams** — components correct, connections missing (§2.1). Caused every sev-1 in v2. | Wiring-map artifact + coverage test (Phase 0 day-1); single wiring-owner agent for `service_providers.dart` (Phase 5). |
| R2 | **Copy-paste adaptation drift** — old4 fake-call decline bug (§2.2). | Forbidden to copy from `old*/`. Re-implement from spec. Preservation manifest enumerates what IS copyable (native code, ARBs, assets) — everything else is fresh. |
| R3 | **Spec gaps become code gaps** — implementer guesses (§2.3). | Spec is now reconciled (spec-audit.md). Where spec is silent, write a question in §10 "Open questions" rather than guessing. |
| R4 | **Parallel-agent seam misses** — `SimulationPhoneService` not injected (§2.4). | Default-sequential. Wiring map is the explicit seam. The 7 illegal-parallel files in §5 are off-limits. |
| R5 | **End-only verification** — sev-1 caught in final audit after 8 phases (§2.5). | Spec-coverage matrix + integration test gate at every phase. |
| R6 | **Native code "done" in Dart, broken on device** — `NotificationService.init()` never called (§2.6). | Phase 10 real-device smoke is a hard gate; Phase 7 forces a `MethodChannel.invokeMethod` integration test per channel. |
| R7 | **Hot-spot file conflicts** — two `startSession()` bodies (§2.7). | §5 file-ownership rules; phase commits serialize through the wiring-owner agent. |
| R8 | **Translations as "do at end"** — backlog ballooning, silent English fallback (§2.8). | L10n parity CI step (hard fail) lands in Phase 0; ARB fan-out (13 parallel agents) is the canonical legal-parallel batch. |

---

## 9. Calendar estimate

Reference: the v2 phase commits (`git log --oneline | grep '^phase-'`)
span ~113 commits over ~120 days, with explicit "phase-NN" landmarks
from phase-1 through phase-15. The v2 effort was burned heavily on
wiring fixes (phase-5, phase-13, phase-14 are all spec-vs-code
reconciliation). v3 reuses the engine tests, golden baselines, ARB
corpus, and native code, so the per-phase cost is lower for early
phases and concentrated in Phases 5–6 (services + screens).

| Phase | Estimate (working days) | Notes |
|---|---|---|
| 0 — Repo skeleton | 1 | Bootstrap + preservation copies are mechanical. |
| 1 — Domain models & enums | 2 | Mostly transcription from spec 03; add 4 missing enums (R-21–R-24). |
| 2 — Pure-Dart SessionEngine | 4 | Tests are preserved (10 files); engine implementation is the bulk. |
| 3 — Event Strategies | 2 | Strategy registry is the pattern; 9 thin classes. |
| 4 — Repositories + seed | 2 | Drift schema + DAOs + seed port. |
| 5 — Services layer | 4 | The wiring catastrophe of v2 — invest here. Single wiring-owner agent. |
| 6 — Screens & routing | 5 | 24 screens; widget tests + goldens at each. The longest phase. |
| 7 — Native channels | 2 | Native code is copied verbatim; Dart bridges + integration tests are new. |
| 8 — Localization | 1 | Mostly verification + l10n parity CI. |
| 9 — Integration tests + goldens | 3 | Spec-coverage matrix is the heavy part. |
| 10 — Real-device smoke | 1 | Plus 1 buffer day per sev-1 found. |
| 11 — Cut-over | 0.5 | Mechanical. |
| **Total** | **~28 working days** | ≈ 6 calendar weeks at 5 days/week, allowing slack for interruptions per `feedback_interruption_resilience.md`. |

This is ~25% of v2's calendar (120 days) by reusing the spec,
preserved tests, golden baselines, ARBs, and native code, and by
front-loading wiring discipline.

---

## 10. Open questions for the user

Short list. Each carries a default — say "yes go" to accept all
defaults.

1. **Confirm the orphan-branch repo strategy?**
   Default: yes, `git tag v2-archive` then `git checkout --orphan v3`
   per §2. Alternative considered + rejected: sibling directory (CI +
   issues fragmentation), in-place (status noise risk).

2. **For audit R-42 (deceptive "Old PIN entered" dialog at 06:170-175,
   currently floating with no implementation hooks): ship it or drop
   it?** Default: **drop**. It's the only floating UX in the spec and
   has no screen mock, no engine event, no test. Dropping it is
   cleaner; we can revisit when there's user demand.

3. **For audit R-12 (soft-delete + 7-day trash for session logs vs
   hard delete): ship soft-delete in v3 or defer to post-v3?**
   Default: **defer to post-v3** as a `docs/spec/11-deferred-enhancements.md`
   entry. Hard delete is simpler, matches the rewrite scope. Saves
   ~0.5 day in Phase 4.

---

## 11. Where to look next

- `docs/rewrite/lessons-learned.md` — every rule cited above.
- `docs/rewrite/preservation-manifest.md` — what to copy in Phase 0.
- `docs/rewrite/spec-audit.md` — the 45 R-### the spec-coverage
  matrix must enforce.
- `docs/spec/00-overview.md` through `11-deferred-enhancements.md` —
  the normative architecture.
- `CLAUDE.md` — project conventions (linter, hooks, style, native
  channel inventory).
- `~/.claude/projects/-home-jonas-Documents-software-android-safetyapp1-guardianangela/memory/`
  — `feedback_*.md` + `project_*.md` source files for every cited
  rule.
