# Guardian Angela — v3 Implementation Plan (Wipe-and-Start)

> **Audience:** The rewrite owner + any agents they dispatch. This plan
> sequences a ground-up rewrite of Guardian Angela using the freshly
> reconciled spec set (`docs/spec/00-overview.md` …
> `docs/spec/11-deferred-enhancements.md`), the v2 postmortem
> (`docs/rewrite/lessons-learned.md`), and the per-artefact carry-over
> map (`docs/rewrite/preservation-manifest.md`).
>
> **Supersedes:** the prior orphan-branch + preservation-manifest plan
> in this same file (commit `0ffbd17` era). The strategy has changed:
> we are wiping the working tree in place and rebuilding from a fresh
> `flutter create`, with the v2 implementation parked under `OLD/` as a
> reference snapshot only (NOT a sync source).
>
> **Pre-alpha mode** (per `project_prealpha_break_compat.md`): no
> migrations, no shims, no CHANGELOG, no on-disk backward compatibility.
> Every `@HiveType` or `@DataClassName` change nukes and reseeds.

---

## 0. Resolved decisions (user, 2026-05-18)

The four open questions from §11 of the earlier draft are now resolved.
The plan body below reflects these choices; §11 is preserved as
historical context only.

| # | Question | Decision |
|---|---|---|
| D1 | Approve migration checklist | **Yes — but PAUSE after Phase −1 commit** for user review before Phase 0 begins. |
| D2 | Sentry from day 1 or defer | **Day 1.** `sentry_flutter` enters `pubspec.yaml` in Phase 0; service triplet wired in Phase 5; opt-out default, EU host. |
| D3 | R-42 deceptive "Old PIN entered" dialog | **SHIP.** Spec restored with screen mock (spec 04 §DeceptiveOldPinDialog), engine event (`ChainEvent.deceptiveOldPinShown`), policy (spec 06 §"Deceptive 'Old PIN entered' Dialog (R-42)"), tests 74b/74c/74d. Implementation in Phase 6. |
| D4 | Fate of `OLD/` at Phase 11 | **Keep — but NEVER use as reference during build.** OLD/ is an inert archive. The only reads permitted are the one-time extractions in §5 below (ARBs, logo, golden baselines, audio fixtures, iOS Info.plist, `test_helpers.dart`). After each extraction commit, OLD/ is sealed for the duration of that phase. **No agent or human consults OLD/ as a "how did v2 do this" reference** — the spec is the architecture. Risk R8 (accidental imports) accordingly upgrades from Medium to High. |

---

## 1. Strategy & rationale

**Move v2's `lib/` and `test/` into `OLD/`, delete EVERYTHING else
authored as part of v2, then bootstrap a fresh tree with
`flutter create`.** The previous "orphan branch + preservation
manifest" approach copied 30+ items across (pubspec, analysis options,
native code, ARBs, CI config, golden baselines, test helpers,
lefthook, l10n.yaml, ...) and bet that "carry verbatim" would compose
cleanly. In practice it carries v2's accumulated drift along with the
artefacts: stale CLAUDE.md references to a non-existent `tool/` dir,
discontinued-dep workarounds, a `lib/l10n/l10n/` path that diverges
from `flutter create`'s default `lib/l10n/`, the
`sqlite3mc` build hook block, `import_sorter` config, half a dozen
`old{,2,3,4,5}/` analyzer excludes. Wipe-and-start gives us one
opportunity to re-derive every artefact from the current spec and the
current Flutter SDK and prove each one fresh against the test suite,
with `OLD/` available for line-level reference whenever the spec is
ambiguous. The git history of v2 stays accessible through `git log
v2-archive`; the new tree never sees v2's drift.

---

## 2. Phase −1: Wipe & migrate

This is the one phase that runs against the existing `main` working
tree before any rewrite begins. Two commits land:

1. `git mv` of `lib/` and `test/` into `OLD/`, plus any other
   reference material we want to keep readable from inside the new
   tree.
2. `git rm -rf` of everything that constitutes v2 implementation
   (pubspec, native platform dirs, build configs, CI, lints).

After both commits land the working tree contains ONLY `docs/`,
`.git/`, `.gitignore`, `CLAUDE.md`, `README.md`, and `OLD/`.

### Pre-flight (BEFORE any move/delete)

```bash
git tag v2-archive HEAD                    # Preserve v2 hash, always recoverable.
git push origin v2-archive 2>/dev/null     # If a remote exists.
git status --porcelain                     # MUST print nothing.
test ! -e OLD || { echo "abort"; exit 1; } # OLD/ must not already exist.
```

### 2.1 MOVE to `OLD/` (via `git mv`, preserves history)

```bash
mkdir OLD
git mv lib OLD/lib
git mv test OLD/test
git mv integration_test OLD/integration_test
git mv assets OLD/assets
git mv android OLD/android
git mv ios OLD/ios
# `tool/` does NOT exist in this repo (verified — CLAUDE.md drift).
# `web/` exists from `flutter create` defaults but is NOT a target
# platform; treat as delete-only (see §2.2). If a future phase wants
# desktop/web, restore from OLD/ if needed.
git mv linux OLD/linux           # MOVE for reference; v3 ships android+ios only.
git commit -m "phase--1a: move v2 lib/test/native/assets into OLD/ for reference"
```

**Why these go to OLD/ rather than delete (one line each):**

| OLD/ subtree | Files | Size | Why kept as reference |
|---|---|---|---|
| `OLD/lib/` | 258 | 3.1 MB | Every controller/screen/service/model — the spec→code location reference the spec itself is silent on. |
| `OLD/test/` | 359 | 3.6 MB | Survivor patterns (`FixedRandom`, `_step()` factory, `package:checks`, `fake_async`), 48 golden PNGs, wiring-contract harness, property round-trip generator. Spec → test starts from these patterns. |
| `OLD/integration_test/` | 4 | — | The 4 end-to-end flows Phase 9 re-authors. |
| `OLD/assets/` | 20 | — | 14 voice clips (silent placeholders), 2 audio, 2 icon PNGs. Some literally copied back in Phase 0 (§5). |
| `OLD/android/` | 35 | 66 MB | 11 Kotlin files, AndroidManifest (14 permissions + 3 stealth aliases + home widget receiver + boot receiver), 4 XML resources. Phase 7 re-authors against these. NOTE: most of the 66 MB is `.gradle/`, `.kotlin/`, `build/` — gitignore'd in Phase 0, but the source tree is what matters. |
| `OLD/ios/` | 49 | 364 KB | 5 Swift plugins, Info.plist (App-Review-vetted permission strings), launch storyboards. |
| `OLD/linux/` | 10 | — | `sqlite3mc` desktop preload fix (commit `29b7c88`); reference even though v3 targets android+ios only. |

### 2.2 DELETE (via `git rm -rf`)

```bash
# Build / dep config — v3 re-authors these from scratch in Phase 0.
git rm -f pubspec.yaml pubspec.lock
git rm -f analysis_options.yaml
git rm -f lefthook.yml
git rm -f l10n.yaml
git rm -f dart_test.yaml
git rm -f .editorconfig
git rm -f .metadata
git rm -f guardianangela.iml
git rm -rf .github         # Re-authored in Phase 0.

# Desktop / web platforms — v3 ships android + ios only.
# (If desktop becomes a goal later, OLD/linux/ is the reference.)
git rm -rf macos windows web   # `macos`/`windows` already empty per dir count; web has 7 files.

# Coverage / cache / IDE state — `.gitignore` already excludes these
# but kill any tracked stragglers.
git rm -rf coverage
git rm -rf .sentry-native

# AGENTS.md — superseded by CLAUDE.md (which we keep). The current
# AGENTS.md (commit-frozen at `April 19 14:16`) references stale
# Hive/url_launcher stack from v1.
git rm -f AGENTS.md

git commit -m "phase--1b: nuke v2 build config / CI / desktop targets"
```

**Why deletion is OK** (one line per item):

| Item | Why deletion is OK |
|---|---|
| `pubspec.yaml` / `.lock` | Re-derived in Phase 0 from `flutter create` + dep list informed by `OLD/pubspec.yaml`; latest compatible versions chosen fresh. |
| `analysis_options.yaml` | Re-authored in Phase 0 with same strict-{casts,inference,raw-types}; the `old*/**` excludes vanish (no longer needed). |
| `lefthook.yml` | Re-authored in Phase 0 mirroring pre-commit fmt+sort, pre-push analyze+test. |
| `l10n.yaml` | Re-authored in Phase 0; ARB output path may change to `lib/l10n/` per `flutter create` defaults. |
| `dart_test.yaml` | Re-authored in Phase 0; only declares the `golden` tag for Alchemist. |
| `.editorconfig` | Re-authored in Phase 0; trivial 2-space/utf-8 declaration. |
| `.metadata` | `flutter create` regenerates. |
| `guardianangela.iml` | IDE-private. `.gitignore` should be excluding this; remove the tracked copy. |
| `.github/` | Re-authored in Phase 0 from current CI requirements; the existing workflow has TODO secrets, Sentry symbol upload stubs, and an e2e job gated on `v*` that we want to re-decide. |
| `macos/` / `windows/` | Empty / unused. v3 ships android+ios only. |
| `web/` | 7 files; not a target platform. |
| `coverage/` | Generated artefact. |
| `.sentry-native/` | Generated cache. |
| `AGENTS.md` | Drift: references v1 Hive stack, predates Pivot 3 distress-mode unification, predates Drift migration. CLAUDE.md is the canonical agent guide and is rewritten in Phase 0. |

### 2.3 KEEP at root (no action needed)

| Item | Why kept |
|---|---|
| `docs/` (128 tracked files) | Spec corpus (12 files in `docs/spec/`), v2 review history (25 files in `docs/review/`), rewrite kit (4 files in `docs/rewrite/`), diagrams, audits, wiring-map, decisions log. Pure documentation — drives everything. |
| `.git/` | Git history. v2-archive tag preserves the v2 tree hash. |
| `.gitignore` | Standard Flutter ignore set; still valid against the new tree. |
| `CLAUDE.md` | UPDATED in Phase 0 (rewritten from scratch). Stays at root throughout. |
| `README.md` | UPDATED in Phase 0 (current is `flutter create` default boilerplate — 16 lines). |
| `OLD/` | Created by §2.1; never modified again. Read-only reference. |
| `.claude/`, `.idea/` | Local IDE / Claude Code state. Untracked and ignored. |

### 2.4 Verification after Phase −1

```bash
ls -la                                       # .git .gitignore CLAUDE.md README.md docs/ OLD/
ls OLD/                                      # lib test integration_test assets android ios linux
git status                                   # clean; 2 commits ahead of v2-archive
git log v2-archive --oneline | head -5       # v2 commits still readable
du -sh OLD/ docs/                            # OLD ≈ 73 MB; docs ≈ 5 MB
find . -maxdepth 2 -name '*.dart' \
  -not -path './OLD/*' -not -path './docs/*' # zero output
```

On failure: `git reset --hard v2-archive` reverts the wipe.

**PAUSE checkpoint (D1):** After Phase −1's commit lands, halt for user
review before Phase 0 begins. The user verifies the empty root layout
matches `ls -la` expectations and the OLD/ archive is well-formed.
Phase 0 starts only on explicit "continue" signal.

---

## 3. Phase 0 — Fresh skeleton via `flutter create`

Goal: a Flutter app shell that builds, lints clean, runs an empty
`MaterialApp` on Android, has CI / lefthook / strict analyzer set up,
and `flutter pub get` succeeds against the new pubspec. **Zero
implementation code yet.**

### 3.1 Generate the skeleton

```bash
# Run from project root. flutter create populates the cwd in place.
flutter create \
  --org com.guardianangela \
  --project-name guardianangela \
  --platforms=android,ios \
  --description "Guardian Angela - Personal safety app with dead man's switch" \
  .

# flutter create writes: pubspec.yaml, android/, ios/, lib/main.dart,
# test/widget_test.dart, .metadata, analysis_options.yaml (basic),
# .gitignore (overwrites — re-check ours stayed correct).
```

**After running**, sanity-check what `flutter create` produced:

```bash
ls -la                  # Expect new: pubspec.yaml android/ ios/ lib/ test/ .metadata analysis_options.yaml
ls lib/                 # Expect: main.dart only.
ls test/                # Expect: widget_test.dart only.
```

### 3.2 Re-author build / lint / CI config

Each of these files gets WRITTEN FRESH (not copied from OLD/). Use
OLD's contents as the reference; pick latest compatible versions and
drop dead clauses.

#### `pubspec.yaml`

Use `OLD/pubspec.yaml` (156 lines, full inventory at the top of
this plan's investigation log) as the dep catalog. Bring forward
each block, picking the LATEST compatible version (e.g.,
`flutter_riverpod ^3.x`, `go_router ^17.x`, `drift ^2.32+`):

- **State / nav / storage / crypto:** flutter_riverpod, go_router,
  drift, sqlite3, crypt, argon2, crypto.
- **`hive_ce` is NOT carried.** OLD/pubspec.yaml still lists it
  alongside Drift; per the spec corpus and commit `29b7c88` the
  migration to Drift is complete. **DO NOT add `hive_ce` to v3's
  pubspec.** Any Hive ref in a ported test is a port bug.
- **Services:** geolocator, permission_handler, url_launcher,
  just_audio, audio_service, flutter_tts, vibration, wakelock_plus,
  record, torch_light, flutter_local_notifications,
  flutter_background_service[_android], battery_plus,
  flutter_secure_storage, local_auth, share_plus, package_info_plus,
  device_info_plus, flutter_contacts, home_widget, image_picker.
- **Utils:** uuid, path, path_provider, clock, meta, intl,
  shared_preferences.
- **Telemetry:** §11.Q1; default = include `sentry_flutter ^9.x`.
- **Dev deps:** flutter_test, flutter_lints, drift_dev, build_runner,
  mocktail, fake_async, flutter_launcher_icons, import_sorter, checks,
  test, alchemist, integration_test (SDK), patrol.
- **Asset blocks:** `assets/audio/`, `assets/voice/`.
- **Launcher icons block:** copy from OLD verbatim
  (image_path, adaptive_icon_background `#131118`,
  adaptive_icon_foreground).
- **`import_sorter:` block:** `comments: false`, `emojis: false`.
- **`hooks:` block (verbatim from OLD):**
  ```yaml
  hooks:
    user_defines:
      sqlite3:
        source: sqlite3mc
  ```
  The SQLCipher-compatible sqlite3 build path that replaces the
  discontinued `sqlcipher_flutter_libs`. Encryption at rest depends
  on this.

After writing: `flutter pub get`, then `flutter pub outdated --json`
checked for any `isDiscontinued: true` (must be empty).

#### `analysis_options.yaml`

Re-author from `OLD/analysis_options.yaml` verbatim except collapse
the five `old{,2,3,4,5}/**` excludes into a single `OLD/**` entry.
Keep `strict-{casts,inference,raw-types}: true`, the `**/*.g.dart` +
`**/*.freezed.dart` + `lib/l10n/**` excludes, and `directives_ordering:
false` (conflicts with `import_sorter`).

#### `lefthook.yml`

Re-author from `OLD/lefthook.yml`. Two changes: add `--fatal-infos` to
the `analyze` command and `--concurrency=6` to the `test` command
(per `feedback_test_concurrency.md`). After writing: `lefthook install`.

#### `.github/workflows/ci.yml`

Re-author from `OLD/.github/workflows/ci.yml` (209 lines) with these
changes:

- Keep: `format`, `import-sorter`, `build_runner` regen, stale-files
  check, `flutter analyze --fatal-infos`, `flutter test`, discontinued
  deps audit (the python3 block from OLD).
- **Add (per `lessons-learned.md §4.13`):** `l10n_parity` step
  (every key in `app_en.arb` exists in every other `app_<lang>.arb`,
  hard fail) and `legacy_id_grep` step (rejects `DistressChain` class
  name, `repeatCount`, `SmsRecipient`, `leapToNextEvent`,
  `beep`/`whistle`/`scream` sound enums).
- **Add (per `lessons-learned.md §4.6`):** `unimplemented_error_count`
  step (warn-only).
- Keep the Phase 16 Patrol `e2e` job gated on `v*` tags. Preserve all
  existing secret names verbatim (`ANDROID_KEYSTORE_BASE64`,
  `SENTRY_AUTH_TOKEN`, etc.) — they live in GitHub repo settings, not
  in the YAML; renaming breaks tagged builds silently.

#### `l10n.yaml`

Copy from `OLD/l10n.yaml` verbatim (`arb-dir: lib/l10n/l10n`, template
`app_en.arb`, output class `AppLocalizations`, `nullable-getter:
false`). Keep the unusual `lib/l10n/l10n/` path — the 14 preserved
ARB files live there and re-pathing would invalidate Phase 8.

#### `dart_test.yaml`

```yaml
tags:
  golden:
    skip: false
```

Identical to OLD (declares the `golden` tag used by Alchemist).

#### `.editorconfig`

```ini
root = true

[*]
indent_style = space
indent_size = 2
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false
```

#### `.gitignore`

The `flutter create` step writes a Flutter-standard `.gitignore`. Add
to it (after generation):

```
# v3 additions
/OLD/build/
/OLD/.dart_tool/
/OLD/.flutter-plugins-dependencies
/coverage/
/.sentry-native/
```

(`OLD/` build artefacts can accumulate if anyone accidentally `cd OLD
&& flutter build`s — gitignore prevents tracking those.)

### 3.3 Rewrite root docs from scratch

#### `CLAUDE.md` (fresh)

The current CLAUDE.md (16 KB, 6 sections) has drifted past spec
reconciliation: it references `tool/generate_icon.dart` (doesn't
exist), `lib/data/seed_data.dart` (about to be re-authored), and uses
the legacy "DistressChain" term that Pivot 3 removed. Rewrite from
scratch, citing the spec, not code paths:

- Build & dev commands (the existing top section is correct, keep
  verbatim).
- Architecture: cite `docs/spec/00-overview.md` for the stack, NOT
  code paths.
- Models: cite `docs/spec/03-data-models.md` section names; do NOT
  re-list every model in CLAUDE.md (that's the spec's job).
- Routing: cite `docs/spec/04-screens-navigation.md`.
- Dart style + Flutter widget patterns + Testing + Documentation:
  keep verbatim from OLD.
- Native platform channels: cite `docs/spec/05-services.md` for the
  contract; list the file paths in the new tree (NOT OLD's paths).
- Dependency policy: keep verbatim (the migrations history note
  about `sqlcipher_flutter_libs` and `golden_toolkit` is institutional
  memory).

#### `README.md`

Rewrite from scratch (current is `flutter create` boilerplate). New
contents: project name + one-line description + "Pre-alpha, v3 rewrite
in progress, see `docs/rewrite/v3-plan.md`" + quick-start commands +
pointer to `docs/spec/00-overview.md` for architecture + note that
`OLD/` is read-only v2 reference (not built, not linted, not tested).

### 3.4 Verification gate (Phase 0)

```bash
dart format --output=none --set-exit-if-changed .
dart run import_sorter:main --no-comments --exit-if-changed
flutter analyze --fatal-infos        # 0 issues
flutter test                         # 1 test (widget_test.dart) passing
flutter build apk --debug            # success
flutter build ios --no-codesign      # success (on macOS)
```

Push a branch, open a draft PR; all CI jobs green. Commit:
`phase-0: bootstrap fresh tree (flutter create + configs)`.

---

## 4. Phase ladder (1–11)

Each phase is **spec → test → code**. Per phase: read cited spec
sections, write failing tests (run red), implement until green, run
`flutter analyze --fatal-infos` (0) and `flutter test` (100%),
commit `phase-NN: <topic>`, update `docs/wiring-map.md` +
`test/wiring/wiring_map_coverage_test.dart` if a provider / route /
model field / strategy landed.

### Phase 1 — Domain models & enums

- **Spec:** `docs/spec/03-data-models.md` (entire, 65 KB). Cover
  enums (`LogGpsOverride`, `CountdownStyle`, `GpsDestinationSource`,
  `StealthIconPreset`, `SmsContactSelection`, `LoudAlarmSound`,
  `HoldButtonStyle`, `MessageChannel`, `CheckInMechanism`,
  `SessionStartTrigger`), sealed hierarchies (`ChainStepConfig`,
  `DistressTrigger`, `DisarmTrigger`, `EngineState`, `SessionPhase`),
  20+ data classes.
- **Tests (first):**
  `test/property/json_round_trip_property_test.dart` (every model:
  random instance → `toJson` → `fromJson` → equals);
  `test/domain/enums/exhaustiveness_test.dart` (switch over
  `Enum.values`, every variant maps);
  `test/domain/models/<model>_test.dart` × N (defaults, validation,
  JSON shape).
- **Code:** `lib/domain/enums/*.dart` (~15), `lib/domain/models/*.dart`
  (~20), `lib/domain/triggers/*.dart` (sealed hierarchies).
- **OLD ref:** `OLD/lib/domain/models/` for class layouts;
  `OLD/test/property/json_round_trip_property_test.dart` for the
  reflection-free pattern. Re-author against spec — OLD shows shape,
  spec dictates fields. Do NOT copy verbatim.
- **Gate:** property + exhaustiveness tests green; no `@HiveType`
  anywhere in `lib/`; no legacy identifiers (CI grep catches).

### Phase 2 — Pure-Dart SessionEngine

- **Spec:** `docs/spec/01-chain-engine.md` (entire, 56 KB).
  Three-phase per-step timing (wait/duration/grace), sealed
  `EngineState` (Idle/Running/Paused/Ended), event stream
  `ChainEventData`, ±20% jitter, speed multipliers (foreground
  1–1000x, background 1–60x, single API `leap()` per R-20), fakeCall
  is event-not-pause (R-1), `replaceWithDistressChain(steps,
  triggerReason:)` signature, retry count semantics (R-9),
  invariants block.
- **Tests (first):** `test/domain/engine/state_machine_test.dart`
  (every transition); `three_phase_timing_test.dart`;
  `jitter_test.dart` (`FixedRandom(0.5)` eliminates jitter; extreme
  values for ±20% window); `speed_multiplier_test.dart` (fg/bg caps,
  `leap()`); `distress_replacement_test.dart` (replaces main, NO
  going back); `fake_call_is_event_test.dart` (answering does NOT
  pause timer); `triggers_test.dart` (hw button 5×, wrong-PIN
  threshold, duress PIN, GPS arrival disarm, timer disarm);
  `invariants_test.dart` (every invariant from spec 01).
- **Code:** `lib/domain/engine/session_engine.dart` (pure Dart, CI
  grep guard rejects `package:flutter` imports);
  `engine_state.dart`; `chain_event_data.dart`; `trigger_manager.dart`.
- **OLD ref:** `OLD/lib/domain/` for engine layout (file location
  may be `session_engine.dart` at top of `lib/domain/`);
  `OLD/test/domain/engine/*.dart` — the 10+ engine tests are the
  best spec→implementation bridge in v2.
- **Gate:** all engine tests green; `grep -rn 'package:flutter'
  lib/domain/engine/` returns empty.

### Phase 3 — Event Strategies

- **Spec:** `docs/spec/02-event-types.md` (entire, 33 KB). 9 step
  types: `holdButton`, `disguisedReminder`, `hardwareButton`,
  `countdownWarning`, `phoneCallContact`, `smsContact`, `loudAlarm`,
  `fakeCall`, `vibrationOnly`. Audit R-3 (siren+custom only), R-22
  (CountdownStyle enum), R-30 (per-step × global gradual volume).
- **Tests (first):** `test/features/session/event_strategies/<step>_strategy_test.dart`
  × 9 — `executeReal()` against fake triplet + `simulationDescription()`
  value match. `registry_exhaustiveness_test.dart` — iterate
  `ChainStepType.values`, every variant maps to a non-null strategy
  (would have caught v2's `ArgumentError` per `lessons-learned.md
  §2.1`).
- **Code:** `lib/features/session/event_strategies/event_strategy.dart`
  (abstract); `<step>_strategy.dart` × 9; `registry.dart` (sealed
  switch over `ChainStepType` — omission is a COMPILE error).
- **OLD ref:** `OLD/lib/features/session/event_strategies/` for
  class layouts. `SimulationDescription` value type was introduced
  in OLD commit `216d0c7` (phase-C.2a).
- **Gate:** 9 strategy tests + registry exhaustiveness test green;
  no strategy file imports `package:flutter/widgets`.

### Phase 4 — Repositories + seed data (Drift)

- **Spec:** `docs/spec/03-data-models.md §Persistence`
  (`currentSchemaVersion` + Drift schema) + spec 03 §Seed (Walk
  Mode, Date Mode, default distress mode per Pivot 3, 8 templates,
  event defaults).
- **Tests (first):** `test/data/db/schema/tables_direct_test.dart`
  (static column regression); `dao_<table>_test.dart` × N (in-memory
  Drift); `test/data/seed_data_test.dart` (seeded shape matches spec);
  `schema_mismatch_nukes_test.dart` (flip version, restart repo,
  assert nuke+reseed per `lessons-learned.md §4.10`).
- **Code:** `lib/data/db/app_database.dart` (`@DriftDatabase`);
  `tables/*.dart`; `daos/*.dart`; `lib/data/repositories/*.dart`
  (DAO wrappers exposing domain models, NOT Drift row types);
  `lib/data/seed_data.dart`.
- **OLD ref:** `OLD/lib/data/db/app_database.dart` +
  `OLD/lib/data/seed_data.dart`. Seed content (chain shapes, timings,
  template button copy) = multi-PM-round artefact. Port content
  step-by-step, do not invent.
- **Gate:** schema + seed + nuke-and-reseed tests green;
  `currentSchemaVersion` is one literal in one file.

### Phase 5 — Services layer

**Most dangerous phase.** v2 lost every wiring fight here
(`lessons-learned.md §2.1`). One agent owns
`lib/services/service_providers.dart` end-to-end. **No parallel
work.** No exceptions.

- **Spec:** `docs/spec/05-services.md` (52 KB, entire). Includes
  `SessionLogRecorder` (R-25) and permission audit (R-28).
- **Tests (first):** `test/services/<service>_test.dart` — one per
  triplet, testing `Real*Service` (mocked native channels) and
  `Simulation*Service` (asserts NO native side-effects).
  **SMOKING-GUN test:** `test/wiring/simulation_swap_test.dart` —
  start session with `isSimulation=true` → every `Simulation*Service`
  injected, NEVER reaches `Real*Service`. The one test that would
  have caught every v2 simulation bug.
  `test/wiring/wiring_map_coverage_test.dart` — bidirectional
  provider ↔ wiring-map check.
- **Code:** per service triplet —
  `lib/services/<service>/<service>_service.dart` (protocol),
  `real_<service>_service.dart`, `simulation_<service>_service.dart`.
  Plus `lib/services/service_providers.dart` (single owner) and
  `lib/services/session_log_recorder.dart` (engine→recorder
  subscription per R-25).
- **Services:** Messaging (SMS/WhatsApp/Telegram), Phone, Audio
  (TTS+alarm), Location, Vibration, Flash, ScreenFlash, Notification,
  Wakelock, Battery, HardwareButton, CallState, SystemUi, StealthIcon,
  HomeWidget, Contacts, Recording, Permission, SessionLogRecorder,
  Sentry.
- **OLD ref:** `OLD/lib/services/` + `OLD/lib/services/service_providers.dart`.
  Protocol+real+sim triplet pattern was the survivor — keep it.
- **Gate:** simulation-swap + wiring-map coverage tests green;
  no `Real*Service` constructor referenced outside
  `service_providers.dart` (CI grep).

### Phase 6 — Screens & routing

- **Spec:** `docs/spec/04-screens-navigation.md` (138 KB, the
  largest spec). 24 screens, GoRouter, first-launch detection.
  Audit recs R-13 (delete `/settings/modes-and-chains`), R-14 (3
  hold styles), R-15 (template editor route), R-16 (3-screen
  onboarding), R-17 (SmsContactSelection), R-33 (empty-distress-modes
  invariant), R-36 (route name enum), R-42 (deceptive PIN dialog —
  **SHIP per D3**: implement `DeceptiveOldPinDialog` (spec 04
  §DeceptiveOldPinDialog) gated on `AppSettings.deceptivePinDialogEnabled`
  (default `true`); call site fires `ChainEvent.deceptiveOldPinShown`
  before showing the dialog; tests 74b/74c/74d from spec 07).
- **Tests (first):** `test/router/route_resolution_test.dart`
  (every name → real builder); `test/features/<feature>/<feature>_screen_test.dart`
  × 24; `test/goldens/<screen>_golden_test.dart` for visual-critical
  screens (home, session, fake_call, distress_confirmation,
  onboarding, settings).
- **Code:** `lib/router/app_router.dart`;
  `lib/core/constants/route_names.dart` (the enum);
  `lib/features/<feature>/<feature>_screen.dart` × 24;
  `<feature>_controller.dart` (Riverpod Notifier) where stateful.
- **OLD ref:** `OLD/lib/features/` for layouts;
  `OLD/lib/router/app_router.dart` for routes; UI primitives
  (`PinKeypad`, `LogarithmicSlider`) at `OLD/lib/core/widgets/`.
- **Gate:** every route resolves; every widget test green; key
  goldens match (intentional diffs → explicit
  `phase-6: update <screen> golden (intentional)` commit).

### Phase 7 — Native channels

- **Spec input:** `docs/spec/05-services.md §Native channels` +
  `docs/spec/10-platform-matrix.md` for per-platform capability
  matrix.
- **Test list (write FIRST):**
  - `integration_test/native_<channel>_test.dart` × N — for each
    channel, a Patrol-driven test that invokes the method and
    asserts the native side responded. This is the gate that would
    have caught `NotificationService.init()` never being called in
    v2 (`lessons-learned.md §2.6`).
- **Code list (Android):** `android/app/src/main/kotlin/com/guardianangela/app/`
  — 11 Kotlin files re-authored against latest APIs. OLD references
  all live under `OLD/android/app/src/main/kotlin/com/guardianangela/app/`:
  `MainActivity.kt` (channel registration entry), `SmsChannel.kt`
  (`com.guardianangela.app/sms`), `SmsWorker.kt` (CoroutineWorker +
  exponential backoff), `BootReceiver.kt`, `CallStateChannel.kt`
  (`/call_state`, TelephonyCallback), `PhoneChannel.kt` (`/phone`),
  `SystemUiChannel.kt` (`/system_ui`), `HardwareButtonChannel.kt`
  (volume distress trigger), `DeviceStateChannel.kt` (battery + state),
  `StealthIconChannel.kt` (`PackageManager.setComponentEnabledSetting`
  for stealth aliases), `GuardianAngelaAppWidget.kt` (home-widget
  RemoteViews provider).
- **`AndroidManifest.xml`** (re-author from
  `OLD/android/app/src/main/AndroidManifest.xml`): 14
  `<uses-permission>` declarations, 3 `<activity-alias>` stealth
  entries (`StealthAlias_music`/`_podcast`/`_calendar`), BootReceiver,
  home-widget receiver, intent queries.
- **Resources** (re-author from `OLD/android/app/src/main/res/`):
  `values/strings.xml`, `values/colors.xml` (adaptive icon background
  `#131118`), `values/styles.xml`, `values-night/styles.xml`,
  `drawable[/-v21]/launch_background.xml`, `xml/backup_rules.xml`,
  `xml/data_extraction_rules.xml`, `xml/guardian_angela_widget_info.xml`,
  `layout/guardian_angela_widget.xml`.
- **Code list (iOS):** 5 Swift files re-authored from
  `OLD/ios/Runner/`: `AppDelegate.swift`, `SceneDelegate.swift`,
  `CallStatePlugin.swift` (`CXCallObserver`), `SystemUiPlugin.swift`
  (no-op stubs on iOS), `AlarmAudioPlugin.swift` (audio session).
- **`Info.plist` is the one verbatim copy** from
  `OLD/ios/Runner/Info.plist` — Apple has approved the exact
  permission strings (`NSLocationWhenInUseUsageDescription`,
  `NSMicrophoneUsageDescription`, etc.).
- **Launch storyboard** copied from `OLD/ios/Runner/`:
  `LaunchScreen.storyboard`, `Main.storyboard`,
  `Assets.xcassets/LaunchImage.imageset/`.
- **Verification gate:** `flutter build apk --debug` succeeds,
  `flutter build ios --no-codesign` succeeds, every channel
  integration test passes against a Patrol Android-14 emulator.

### Phase 8 — Localization

- **Spec:** `docs/spec/00-overview.md §Localization` (14 languages).
- **Tests (first):** `test/l10n/parity_test.dart` (every `app_en.arb`
  key exists in every other ARB; hard fail; mirrors CI step);
  `test/l10n/locale_smoke_test.dart` (home screen renders in every
  locale without a `<MISSING TRANSLATION>` token).
- **Code:** `lib/l10n/l10n/app_en.arb` re-authored as new keys
  emerge (initial port lifts all keys from `OLD/lib/l10n/l10n/app_en.arb`);
  13 non-EN ARBs copied verbatim from `OLD/lib/l10n/l10n/` (most
  expensive preserved artefacts — see §5).
- **OLD ref:** all 14 ARBs are LITERAL COPIES (§5). Dead keys
  from spec-audit R-13/R-14/R-15 deletions get pruned per locale by
  a sub-agent (per `feedback_language_agent_on_change.md`).
- **Gate:** `flutter gen-l10n` reports zero untranslated-message
  warnings; parity CI step green; visual spot check through 14
  locales — no English fallback.

### Phase 9 — Integration tests + spec coverage

- **Spec:** `docs/spec/07-test-plan.md` (75 KB) for scenarios;
  `docs/rewrite/spec-audit.md` for the 45 R-NN list.
- **Tests (first):** `integration_test/walk_mode_flow_test.dart`
  (start → hold → release → grace → escalation);
  `date_mode_flow_test.dart` (periodic reminder, response in grace,
  miss-then-escalate); `distress_flow_test.dart` (hw button →
  distress chain replaces main → SMS sent);
  `duress_pin_flow_test.dart` (duress PIN fires distress silently);
  `quick_exit_flow_test.dart`; `simulation_mode_flow_test.dart`
  (all real services blocked).
  **`test/spec_coverage_test.dart`** — checked-in
  `Map<String, List<String>>` of R-NN → test names; iterates and
  asserts every R-NN + every numbered spec section ID maps to ≥ 1
  test.
- **Code:** test infrastructure (Patrol helpers, app-under-test
  boot helper). No new product code.
- **OLD ref:** `OLD/integration_test/` for the 4 existing flows
  (re-author); `OLD/test/helpers/test_helpers.dart` for `_step()`,
  `holdStep()`, `smsStep()`, `makeMode()`, `FixedRandom`. (Already
  ported in Phase 1.)
- **Gate:** `flutter test` 100% pass; spec_coverage_test green
  over all 45 R-NN + numbered spec section IDs.

### Phase 10 — Real-device smoke

- **Spec:** `docs/spec/10-platform-matrix.md` for capability claims.
- **Tests:** manual checklist (re-author from
  `docs/manual-device-test-checklist.md`, kept from v2 in `docs/`).
- **Code:** none, unless bugs are found.
- **Gate:** checklist 100% complete; every FAIL has a fixed +
  re-tested follow-up commit before phase 10 commit lands.

### Phase 11 — Cut-over & cleanup

- **What:** Decide `OLD/`. Default (§11.Q3): **delete `OLD/`
  entirely.** v2-archive tag preserves the tree for forensics
  (`git checkout v2-archive`); keeping a 73 MB shadow tree in `main`
  invites drift, accidental imports, contributor confusion.
- **Code:** `git rm -rf OLD/`; remove `OLD/**` exclude from
  `analysis_options.yaml`; remove `/OLD/...` entries from
  `.gitignore`; drop the "Reference: v2 implementation" section
  from `README.md`; tag the cut-over `v3-ga`.
- **Gate:** `git log main --oneline | head -1` shows cut-over
  commit; CI green on `main`; `du -sh .` significantly smaller.

---

## 5. Preserved-from-OLD list (one-time extractions)

The wipe-and-start strategy re-authors most artefacts. The following
are LITERAL COPIES (not re-authored) because the human / translator /
designer hours behind them are non-trivial to redo. Each item names
the phase that pulls it across.

**D4 invariant:** Each row below is a **one-time extraction**. The
`git cp` (or `cp` + `git add`) happens inside the named phase, gets
committed in that phase, and OLD/ is then sealed again for the
remainder of the build. No "look up how v2 did X" reads of OLD/ are
permitted — those are forbidden per D4. If a behaviour is unclear,
read the spec; if the spec is unclear, fix the spec. OLD/ never
clarifies anything.

| Item | OLD path | New path | Phase | Why literal copy |
|---|---|---|---|---|
| 13 non-English ARB files | `OLD/lib/l10n/l10n/app_{de,es,fr,ru,zh,zh_TW,hi,fa,uk,pl,el,ar,he}.arb` | `lib/l10n/l10n/app_<lang>.arb` | 8 | ~1,053 keys × 13 locales of translator effort. Re-translation would not produce byte-identical strings, breaking visual review across locales. |
| English ARB | `OLD/lib/l10n/l10n/app_en.arb` | `lib/l10n/l10n/app_en.arb` | 8 | The canonical source; cheaper to delete dead keys than re-author all live keys. |
| Logo widget | `OLD/lib/core/theme/guardian_angela_logo.dart` | `lib/core/theme/guardian_angela_logo.dart` | 6 (when the About screen lands) | The only human creative artefact (`CustomPainter` shield+halo). Re-drawing is a designer round-trip. |
| Icon source PNGs | `OLD/assets/icon/app_icon.png`, `app_icon_foreground.png` | `assets/icon/...` | 0 (asset bundle present from day 1) | Hand-tuned at 1024×1024 with adaptive-icon-foreground inset. `flutter_launcher_icons` derives the mipmap set from these. |
| Audio fixtures | `OLD/assets/audio/alarm.mp3`, `ringtone.wav` | `assets/audio/...` | 0 | License-cleared audio. |
| Voice clips (silent placeholders) | `OLD/assets/voice/angela_<lang>.m4a` × 14 + README | `assets/voice/...` | 0 | Per `OLD/assets/voice/README.md` these are 1-second silent placeholders. Copy now; replace with real recordings post-v3 (matches spec 11 §"Voice Recording Assets"). |
| Golden image baselines | `OLD/test/goldens/goldens/*.png` (32) + `goldens/ci/*.png` (4) | `test/goldens/goldens/...` | 6 (alongside the screen tests they back) | Pixel-baseline regression detection. Re-deriving from a re-authored UI risks pixel drift on the first commit that should "look the same." |
| iOS Info.plist | `OLD/ios/Runner/Info.plist` | `ios/Runner/Info.plist` | 7 | App Review has approved this exact copy (NS*UsageDescription strings, capability declarations). Literal copy avoids a re-review trip. |
| `test_helpers.dart` factory | `OLD/test/helpers/test_helpers.dart` (`step()`, `holdStep()`, `smsStep()`, `makeMode()`, `FixedRandom`) | `test/helpers/test_helpers.dart` | 1 | The deterministic random pattern + minimal-boilerplate factories were the test productivity multiplier in v2. Re-deriving = wasted hours. |
| Voice asset README | `OLD/assets/voice/README.md` | `assets/voice/README.md` | 0 | Documents the placeholder status of the .m4a files. |

**Total literal copies: ~64 files.** Every other source file is
re-authored against the spec.

---

## 6. Native code rebuild detail (Phase 7)

The wipe step deletes both `android/` and `ios/`. `flutter create`
produces stubs in Phase 0 (`MainActivity.kt` with no plugins
registered, `AppDelegate.swift` with the default Flutter delegate,
empty AndroidManifest with only `INTERNET`). Phase 7 re-authors
against spec + uses OLD as algorithm reference.

### Android — channels to rebuild

(Confirmed inventory at the prompt-investigation step.)

| Dart Bridge | Channel name | Native impl (re-author against OLD) |
|---|---|---|
| `lib/services/messaging/native_sms_bridge.dart` | `com.guardianangela.app/sms` | `OLD/android/app/src/main/kotlin/com/guardianangela/app/SmsChannel.kt` + `SmsWorker.kt` + `BootReceiver.kt` |
| `lib/services/phone/native_phone_bridge.dart` | `com.guardianangela.app/phone` | `OLD/.../PhoneChannel.kt` |
| `lib/services/call_state/native_call_state_bridge.dart` | `com.guardianangela.app/call_state` | `OLD/.../CallStateChannel.kt` |
| `lib/services/system_ui/native_system_ui_bridge.dart` | `com.guardianangela.app/system_ui` | `OLD/.../SystemUiChannel.kt` |
| `lib/services/hardware_button/native_hw_button_bridge.dart` | (configured in `HardwareButtonChannel`) | `OLD/.../HardwareButtonChannel.kt` |
| `lib/services/device_state/native_device_state_bridge.dart` | (configured in `DeviceStateChannel`) | `OLD/.../DeviceStateChannel.kt` |
| `lib/services/stealth/native_stealth_icon_bridge.dart` | (configured in `StealthIconChannel`) | `OLD/.../StealthIconChannel.kt` |
| `lib/services/home_widget/native_home_widget_bridge.dart` | (`home_widget` plugin + custom receiver) | `OLD/.../GuardianAngelaAppWidget.kt` |

Plus: `MainActivity.kt` registers all channels and the home-widget
receiver.

### iOS — plugins to rebuild

| Dart Bridge | Plugin (re-author against OLD) |
|---|---|
| `lib/services/call_state/native_call_state_bridge.dart` (iOS impl) | `OLD/ios/Runner/CallStatePlugin.swift` (`CXCallObserver`) |
| `lib/services/system_ui/native_system_ui_bridge.dart` (iOS impl) | `OLD/ios/Runner/SystemUiPlugin.swift` (no-op stubs) |
| `lib/services/audio/native_alarm_audio_bridge.dart` | `OLD/ios/Runner/AlarmAudioPlugin.swift` |

Plus: `AppDelegate.swift`, `SceneDelegate.swift`, the launch
storyboard.

---

## 7. Spec → test → code matrix (excerpt)

The full matrix lives as a checked-in
`Map<String, List<String>>` in `test/spec_coverage_test.dart` (added
in Phase 9). Excerpt below shows the shape — every R-NN from
`spec-audit.md` and every numbered spec section ID must have ≥ 1
test row.

| Spec ref | Phase | Test file | Code file |
|---|---|---|---|
| `01:Invariant 1` (state machine progression) | 2 | `test/domain/engine/state_machine_test.dart` | `lib/domain/engine/session_engine.dart` |
| `01:Pivot 2` / R-1 (fakeCall is event) | 2 | `test/domain/engine/fake_call_is_event_test.dart` | `lib/domain/engine/session_engine.dart` |
| `01:464` / R-20 (`leap()` API) | 2 | `test/domain/engine/speed_multiplier_test.dart` | `lib/domain/engine/session_engine.dart` |
| `02:9 step types` × R-3 (alarm enum) | 3 | `test/features/session/event_strategies/loud_alarm_strategy_test.dart` | `lib/features/session/event_strategies/loud_alarm_strategy.dart` |
| `02:CountdownStyle` / R-22 | 1, 3 | `test/domain/enums/exhaustiveness_test.dart` + `..._countdown_warning_strategy_test.dart` | `lib/domain/enums/countdown_style.dart` |
| `03:LogGpsOverride` / R-21 | 1 | `test/domain/enums/exhaustiveness_test.dart` | `lib/domain/enums/log_gps_override.dart` |
| `03:Distress/Disarm triggers` / R-23 | 1, 2 | `test/property/triggers_round_trip_test.dart` + `test/domain/engine/triggers_test.dart` | `lib/domain/triggers/*.dart` |
| `03:Persistence` (schema version) | 4 | `test/data/db/schema_mismatch_nukes_test.dart` | `lib/data/db/app_database.dart` |
| `04:24 routes` / R-36 | 6 | `test/router/route_resolution_test.dart` | `lib/router/app_router.dart` + `lib/core/constants/route_names.dart` |
| `04:R-13` (delete modes-and-chains hub) | 6 | `test/router/route_resolution_test.dart` (negative assertion: route name absent) | `lib/router/app_router.dart` |
| `04:R-14` (3 hold styles) | 1, 6 | `test/domain/enums/exhaustiveness_test.dart` (enum has 3 variants) + screen test | `lib/domain/enums/hold_button_style.dart` |
| `05:Services` (every provider) | 5 | `test/wiring/wiring_map_coverage_test.dart` + `test/wiring/simulation_swap_test.dart` | `lib/services/service_providers.dart` |
| `05:SessionLogRecorder` / R-25 | 5 | `test/services/session_log_recorder_test.dart` | `lib/services/session_log_recorder.dart` |
| `05:Permission audit` / R-28 | 5 | `test/services/permission_service_test.dart` | `lib/services/permission/...` |
| `06:Security` (3 PINs) | 5, 6 | `test/services/pin_service_test.dart` + `test/features/settings/pin_screens_test.dart` | `lib/services/pin/...` + `lib/features/settings/pin_*_screen.dart` |
| `07:Walk Mode flow` | 9 | `integration_test/walk_mode_flow_test.dart` | (whole stack) |
| `10:Per-platform matrix` | 7, 10 | `integration_test/native_<channel>_test.dart` + manual checklist | `android/.../*.kt` + `ios/Runner/*.swift` |
| `11:DE-5 Android widget` | 7 | `integration_test/native_home_widget_test.dart` | `android/.../GuardianAngelaAppWidget.kt` |

---

## 8. Verification gates (continuous)

Hard gates that must pass at every phase commit:

1. **`flutter analyze --fatal-infos` → 0 issues.** lefthook pre-push +
   CI `analyze`.
2. **`flutter test` → 100% pass.** lefthook pre-push + CI `test`.
   Default `--concurrency=6`; drop to serial when other agents are
   running tests (per `feedback_test_concurrency.md`).
3. **`flutter pub outdated --json` → no discontinued direct deps.**
   CI `dep audit` step.
4. **L10n parity:** every key in `app_en.arb` is present in every
   other `app_<lang>.arb`. CI `l10n_parity` step.
5. **Legacy-identifier grep:** forbidden list, CI `legacy_id_grep`
   step (hard fail). Forbidden tokens:
   - `class DistressChain` (the class is gone; the noun in prose is
     fine).
   - `repeatCount` (replaced by `retryCount` per R-9).
   - `SmsRecipient` (replaced by `SmsContactSelection` per R-17).
   - `leapToNextEvent` (replaced by `leap` per R-20).
   - `LoudAlarmSound.beep|whistle|scream` (R-3 settled at
     `{siren, custom}`).
   - `notificationDisguise` typed as `String?` (must be `bool` per
     R-5).
   - `fakeIcon` typed as `String?` (must be `StealthIconPreset` per
     R-6).
6. **Spec coverage matrix:** every R-NN + every numbered spec section
   ID maps to ≥ 1 test. `test/spec_coverage_test.dart` (Phase 9).
7. **`UnimplementedError` grep (warn-only).** CI prints the count so
   it can't drift up silently.

---

## 9. Risk register (wipe-and-start–specific)

The previous orphan-branch + preservation-manifest plan had risks
around "preservation list incompleteness." Wipe-and-start has
different risks; this register replaces v2's register.

| # | Risk | Likelihood | Mitigation |
|---|---|---|---|
| R1 | **Losing a non-spec'd pattern.** Some valuable v2 patterns aren't in the spec — e.g., the `SimulationDescription` value type (commit `216d0c7`), the deterministic-random helper, the wiring-map artefact. If the rewrite team can't see them they'll re-invent worse. | High | `OLD/` is on-tree and grep-able from inside the new repo; phase plans cite specific OLD paths to read; CLAUDE.md (Phase 0 rewrite) lists known survivor patterns under a "Patterns to keep" section. |
| R2 | **Native channel re-author breaks `flutter create` defaults.** `flutter create` writes a basic `MainActivity.kt` / `AppDelegate.swift`. Channels need to register on top of those — wrong order = crash on launch. | Medium | Phase 7 is preceded by Phase 0 which leaves the stubs untouched until 7; channel registration is the FIRST edit to those files in Phase 7. Integration test `app_launches_without_crash_test.dart` runs on every CI build. |
| R3 | **Dep version drift between OLD and new.** Latest-version pulls in Phase 0 may have breaking changes (riverpod 3→3.x, drift 2.32→2.x). | Med | Phase 0 sanity step runs `flutter pub outdated` + empty widget test; incompatibility surfaces before real code. |
| R4 | **Golden image drift on first commit.** Phase 6 copies 32 golden PNGs from OLD; re-authored screens may diff (font hinting, anti-aliasing). | High | Phase 6 "first compare = baseline": intentional diffs commit baseline updates in a dedicated `phase-6: update <screen> golden (intentional)` commit. Never silent. |
| R5 | **ARB key drift.** Phase 8 copies 13 non-EN ARBs verbatim; spec-audit R-13/R-14/R-15 deletions make some keys dead. | Med | Phase 8 starts with a dead-key diff per locale; sub-agent per locale prunes + translates new keys. |
| R6 | **Schema-mismatch path untested on first install.** | Low | `test/data/db/schema_mismatch_nukes_test.dart` exercises the path against a synthetic mismatched DB in Phase 4. |
| R7 | **CI secrets drift.** Re-authored YAML may rename a secret. | Low | Phase 0 preserves existing secret names verbatim (`ANDROID_KEYSTORE_BASE64`, `SENTRY_AUTH_TOKEN`, etc.). |
| R8 | **OLD/ accidentally imported.** Editor path-completes `import 'package:guardianangela/../OLD/...'`. | Low | `analysis_options.yaml` excludes `OLD/**`; CI grep guard rejects `import.*OLD/` paths. |
| R9 | **OLD/android/build/ cache gets tracked.** OLD ships with built Android artefacts (66 MB total). | Med | `.gitignore` extended in Phase 0 excludes `/OLD/build/`, `/OLD/.dart_tool/`, `/OLD/android/build/`, `/OLD/android/.gradle/`, `/OLD/android/.kotlin/`. Phase −1 verification asserts `git ls-files OLD | grep -E '\.dart_tool|/build/'` is empty. |
| R10 | **`flutter create` scaffold drift.** Newer Flutter SDK versions reorganized `android/`. | Med | OLD already uses Gradle KTS. Phase 0 pins Flutter `stable` channel, records SDK version in CLAUDE.md. |

---

## 10. Calendar estimate

v2 spanned ~120 days across `phase-1`→`phase-15` commits. v3 reuses
spec + 14 ARBs + golden baselines + icon PNGs + `test_helpers.dart`
patterns + native algorithm logic via OLD. Estimate assumes 1 lead
(+ on-demand sub-agents) ~5 days/week.

| Phase | Days | Notes |
|---|---|---|
| −1 — Wipe & migrate | 0.5 | Mechanical. |
| 0 — Fresh skeleton | 1.5 | `flutter create` + configs + CLAUDE/README rewrite. |
| 1 — Domain models & enums | 2 | 20+ models, 15+ enums, sealed hierarchies. |
| 2 — Pure-Dart SessionEngine | 4 | Hardest pure-logic phase. |
| 3 — Event Strategies | 2 | 9 thin strategies + registry. |
| 4 — Repositories + seed | 2 | Drift schema + DAOs + seed port. |
| 5 — Services layer | 4 | Single-owner, sequential — wiring catastrophe of v2. |
| 6 — Screens & routing | 5 | 24 screens + widget tests + golden ports. Longest phase. |
| 7 — Native channels | 3 | Algorithm port + Patrol integration tests. |
| 8 — Localization | 1 | ARB ports + parity CI + spot check. |
| 9 — Integration tests + spec coverage | 3 | Spec-coverage matrix is the heavy part. |
| 10 — Real-device smoke | 1 | +1 buffer day per sev-1 found. |
| 11 — Cut-over & cleanup | 0.5 | Delete OLD/, retag, update docs. |
| **Total** | **~29 days** | ≈ 6 calendar weeks at 5 days/wk, with slack. |

≈ 25% of v2's calendar by reusing spec + ARBs + assets + goldens +
algorithm reference and front-loading wiring discipline (Phase 5).

---

## 11. Open questions (RESOLVED — see §0)

The three open questions below were resolved on 2026-05-18 and folded
into §0. The original text is preserved for context.

### Q1. Sentry from day 1 or defer to Phase 11? — RESOLVED: Day 1 (D2)

**Default: include from day 1, opt-out by default, EU host.** OLD
already has `sentry_flutter ^9` in pubspec, `D-TELEMETRY-1` decision
recorded, and a `SentryService` placeholder. Including from day 1
means crash data for the rewrite itself, which is when we'd most
benefit. Cost: one extra service triplet to wire in Phase 5.

### Q2. R-42 deceptive "Old PIN entered" dialog: ship or drop? — RESOLVED: SHIP (D3)

**Original default was drop.** User decision: SHIP. The spec was
restored with screen mock (spec 04 §DeceptiveOldPinDialog), engine
event (spec 01 §Events Emitted → `deceptiveOldPinShown`), policy
(spec 06 §Deceptive "Old PIN entered" Dialog (R-42)), and tests
74b/74c/74d (spec 07 §PIN/Biometric Authentication). Phase 6
implements.

### Q3. Phase 11 fate of `OLD/` — RESOLVED: Keep, never reference (D4)

**Original default was delete.** User decision: **keep, but NEVER
USE as reference during build.** OLD/ remains in `main` after Phase
11, but its only reads during the build are the one-time §5
extractions. No "how did v2 do X" lookups are permitted; no agent
or human consults OLD/ to inform v3 design. The spec is the
architecture. Risk R8 (accidental imports) consequently upgrades
from Medium to High and gets the `.gitignore`-style enforcement
described in §9.

---

## 12. Where to look next

- `docs/rewrite/lessons-learned.md` — every process rule cited above.
- `docs/rewrite/spec-audit.md` — the 45 R-NN the spec-coverage matrix
  must enforce.
- `docs/rewrite/preservation-manifest.md` — informed §5 of this plan;
  now historical, do NOT use as the migration sequence.
- `docs/spec/00-overview.md` … `11-deferred-enhancements.md` —
  normative architecture.
- `OLD/` (after Phase −1) — **inert archive only (D4).** The
  one-time extractions in §5 are the sole reads permitted during the
  v3 build. Do NOT browse OLD/ as a "how did v2 do this" reference.
  If the spec is unclear, fix the spec rather than reading OLD/.
- `~/.claude/projects/.../memory/` — `feedback_*.md` + `project_*.md`
  source for every cited memory rule.
