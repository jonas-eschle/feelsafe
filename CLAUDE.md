# CLAUDE.md

v3 in progress. OLD/ is INERT — do not read. Spec is the architecture.

Zero stubs at GA. Every stub category in
`~/.claude/plans/make-sure-that-there-typed-tulip.md` §NO-STUBS is a
hard CI fail. No exceptions.

This file provides guidance to Claude Code (claude.ai/code) when
working with code in this repository.

---

## Build & Development Commands

```bash
flutter pub get                              # Install dependencies
dart run build_runner build                  # Generate Drift adapters (*.g.dart)
flutter gen-l10n                             # Generate localization files
flutter run                                  # Run app
flutter test                                 # Run all tests
flutter test path/to/test.dart               # Run a single test file
flutter analyze --fatal-infos                # Lint / static analysis (strict)
dart format .                                # Format code
dart fix --apply                             # Auto-fix common lint issues
dart run import_sorter:main --no-comments    # Sort imports (enforced by hooks)
flutter pub run flutter_launcher_icons       # Generate platform launcher icons
```

After modifying any `@DataClassName` Drift model, re-run
`build_runner build` to regenerate the `.g.dart` files. Use
`--delete-conflicting-outputs` if there are stale generated files.

### Package Management

- Add dependency: `flutter pub add <package_name>`
- Add dev dependency: `flutter pub add dev:<package_name>`
- Remove dependency: `dart pub remove <package_name>`
- When suggesting a new dependency from pub.dev, explain its benefit.
- Run `flutter pub outdated` before any PR touching `pubspec.yaml`.
  Bumping major versions of direct deps is preferred over staying
  behind; document any major bump blocked by a transitive constraint.

---

## Architecture

See `docs/spec/00-overview.md` for the canonical architecture
description.

**Stack:** Flutter + Riverpod 3 (state) + GoRouter (navigation) +
Drift + sqlite3mc (local encrypted storage).

**Feature-first layout** — each feature in `lib/features/<feature>/`:
- **Controller** (Riverpod Notifier) — business logic and state
- **Screen** — UI consuming the controller

**Logical layers:**
- `lib/features/` — Presentation (screens) + Domain (controllers)
- `lib/domain/` — Pure-Dart engine, models, enums, triggers, sealed
  hierarchies
- `lib/data/` — Drift database, DAOs, repositories, seed data
- `lib/services/` — Platform API wrappers exposed as Riverpod
  providers via `lib/services/service_providers.dart`
- `lib/router/` — GoRouter configuration
- `lib/core/` — Shared constants, theme, utilities, shared widgets

### Core domain: SessionEngine

See `docs/spec/01-chain-engine.md` for the full specification.

`lib/domain/engine/session_engine.dart` is a **pure Dart state
machine** (no Flutter dependency). It drives safety sessions via the
sealed `EngineState` hierarchy and emits `ChainEventData` via a
`Stream`.

### Event Strategies

See `docs/spec/02-event-types.md` for the 9 step types.

`lib/features/session/event_strategies/` uses a Strategy pattern.
Each `EventStrategy` implements `executeReal()` and
`simulationDescription()`. Registry uses a sealed switch over
`ChainStepType` — omissions are compile errors.

### Models

See `docs/spec/03-data-models.md` for all model definitions,
persistence schema, and enums.

No `@HiveType` — all persistence via Drift + sqlite3mc.

### Routing & Screens

See `docs/spec/04-screens-navigation.md` for the 24 screens and all
routes.

All routes in `lib/router/app_router.dart`; route names in
`lib/core/constants/route_names.dart`.

### Services

See `docs/spec/05-services.md` for all service contracts and the
Real/Simulation triplet pattern.

`lib/services/service_providers.dart` is the single owner of all
service instantiation. No `Real*Service` constructor may be called
outside that file (CI grep enforces).

### Native Platform Channels

See `docs/spec/05-services.md §Native channels` and
`docs/spec/10-platform-matrix.md` for the full per-platform capability
matrix.

**Android** (`android/app/src/main/kotlin/com/guardianangela/app/`):
- `MainActivity.kt` — Registers all platform channels
- `SmsChannel.kt` — `com.guardianangela.app/sms`
- `SmsWorker.kt` — WorkManager CoroutineWorker for background SMS
- `CallStateChannel.kt` — `com.guardianangela.app/call_state`
- `SystemUiChannel.kt` — `com.guardianangela.app/system_ui`
- `HardwareButtonChannel.kt` — volume distress trigger
- `DeviceInfoChannel.kt` — `com.guardianangela.app/device_info` (SIM number)
- `StealthIconChannel.kt` — package manager component toggling
- `GuardianAngelaAppWidget.kt` — home widget RemoteViews
- `BootReceiver.kt` — WorkManager re-init after reboot

**iOS** (`ios/Runner/`):
- `AppDelegate.swift`, `SceneDelegate.swift`
- `CallStatePlugin.swift` — CXCallObserver
- `SystemUiPlugin.swift` — no-op stubs (not applicable on iOS)
- `AlarmAudioPlugin.swift` — audio session

---

## Dart Style

- Follow the official [Effective Dart](https://dart.dev/effective-dart) guidelines.
- **Line length:** 80 characters (enforced by `dart format`).
- **Naming:** `PascalCase` for classes/enums, `camelCase` for
  members/variables/functions, `snake_case` for files.
- **Immutability:** Prefer immutable data structures. `StatelessWidget`
  subclasses must be immutable.
- **`const` constructors:** Use on classes wherever possible; use
  `const` in widget trees to reduce rebuilds.
- **Arrow syntax:** Use `=>` for single-expression functions/getters.
- **Null safety:** Avoid the `!` null-assertion operator unless the
  value is provably non-null. Prefer `?.`, `??`, or early returns.
- **Switch:** Prefer exhaustive `switch` expressions over if/else
  chains on enums and sealed types.
- **Pattern matching & records:** Use where they simplify code.
- **Async:** `Future`/`async`/`await` for single operations; `Stream`
  for sequences. Always handle errors.
- **Functions:** Keep functions short and single-purpose (< 20 lines).
- **Composition over inheritance:** Favor composition for widgets.
- **Logging:** Use `dart:developer` `log()` — never `print()`.

---

## Flutter Widget Patterns

- **Private widget classes over helper methods:** Break large
  `build()` methods into small private `Widget` classes, not helper
  methods returning `Widget`.
- **Lazy lists:** Use `ListView.builder` / `GridView.builder` for
  dynamic or long lists — never build all items eagerly.
- **No heavy work in `build()`:** Do not perform network calls, heavy
  computation, or I/O inside `build()`.
- **Isolates:** Use `compute()` for expensive work to keep the UI
  thread free.

### Layout & Responsiveness

- Use `LayoutBuilder` or `MediaQuery` for responsive layouts.
- In `Row`/`Column`, use `Expanded` **or** `Flexible` — do not mix
  both in the same parent.
- Use `Wrap` when children might overflow horizontally.
- Use `SingleChildScrollView` for fixed-size content larger than the
  viewport.

### Theming

- Use `Theme.of(context).textTheme` / `colorScheme` — avoid
  hard-coded colors and font sizes in widgets.
- Use `ThemeExtension<T>` for project-specific design tokens.
- Use `ColorScheme.fromSeed()` for harmonious palettes.
- Support light and dark themes (`ThemeMode.system`).

### Accessibility

- Text contrast ratio ≥ 4.5:1 (normal) / 3:1 (large) per WCAG 2.1.
- UI must remain usable under system-level font scaling.
- Provide `Semantics` labels on non-text interactive elements.

---

## Testing

See `docs/spec/07-test-plan.md` for the full test plan and all
test-ID to spec-ref mappings.

- **Unit tests:** `package:test` — domain logic, data layer, state.
- **Widget tests:** `package:flutter_test` — UI components.
- **Integration tests:** `package:integration_test` + Patrol —
  end-to-end flows.
- **Assertions:** `package:checks` for expressive assertions.
- **Test doubles:** Prefer fakes or stubs over mocks. Use `mocktail`
  only when mocking is necessary.
- **Convention:** Arrange-Act-Assert (Given-When-Then).
- **Timer testing:** `fake_async` with `fakeAsync()`.
- **SessionEngine tests:** Use `_FixedRandom` (returns 0.5,
  eliminating jitter) from `test/helpers/test_helpers.dart`.
- **Test files** in `test/` mirror the `lib/` structure.
- **Helper pattern:** `_step()` factory function in
  `test/helpers/test_helpers.dart`.
- **Concurrency:** Default `--concurrency=6`; drop to serial when
  other agents are also running `flutter test`.

---

## Documentation

- Add `///` doc comments to all public APIs.
- First sentence: concise, user-centric summary ending with a period.
- Comment **why**, not **what** — the code should be self-explanatory.
- Do not add documentation that merely restates the name or signature.
- Place doc comments before annotations.
- Use backtick fences with language identifier for code samples.

---

## Code Quality

- **Strict analysis:** `strict-casts`, `strict-inference`,
  `strict-raw-types` all enabled in `analysis_options.yaml`.
- **Git hooks** (lefthook): pre-commit runs `dart format` +
  `import_sorter`; pre-push runs `flutter analyze --fatal-infos` +
  `flutter test --concurrency=6`.
- **CI** (`.github/workflows/ci.yml`): format, import-sorter,
  build_runner, analyze, test + coverage gate, dep-audit,
  l10n-parity, legacy-id-grep, old-import-gate, no-stubs (S-1..S-12).
- **Coverage gate:** 0% in Phase 0; ratchets to 99% by Phase 9 (D6).

---

## Dependency Policy

Pre-alpha rules:

- No backwards compatibility. Replace any direct dependency whose
  pub.dev `isDiscontinued` flag is `true` in the same cycle the flag
  is detected. CI `dep-audit` enforces with a hard fail.
- Run `flutter pub outdated` before opening any PR that touches
  `pubspec.yaml`. Bumping major versions of direct deps is preferred
  over staying behind a major release; document any major bump blocked
  by a transitive constraint.
- **No `hive_ce`** — Drift + sqlite3mc replaces Hive entirely (all
  persistence is in `lib/data/db/`).

Migrations history:
- `e67f082` (May 2026): dropped `sqlcipher_flutter_libs` (EOL),
  moved to `sqlite3 3.x` + `sqlite3mc` via Dart 3.11 build hooks.
- Phase-deps (May 2026): swapped `golden_toolkit` (discontinued)
  for `alchemist`. Goldens in `test/goldens/goldens/`.

---

## Seed Data

`lib/data/seed_data.dart` — two built-in modes (Walk Mode and Date
Mode), default distress mode, 8 reminder templates, per-step-type
event defaults. See `docs/spec/03-data-models.md §Seed`.

---

## App Identity

- **Name:** Guardian Angela (wordplay on "guardian angel" + "Ask for
  Angela" safety campaign)
- **Application ID:** `com.guardianangela.app`
- **Logo:** `GuardianAngelaLogo` in `lib/core/theme/guardian_angela_logo.dart`
  — Pride-flag gradient angel with feathered wings, shield body, halo.
- **Icon:** `assets/icon/app_icon.png` + `app_icon_foreground.png`;
  adaptive icon background `#131118`.

---

## OLD/ — INERT ARCHIVE

`OLD/` contains the v2 implementation as a read-only archive.
**Do not read, browse, grep, or import anything from OLD/** except for
the surgical one-time extractions enumerated in
`docs/rewrite/v3-plan.md §5`. Those extractions are complete as of
the Phase 0 commit. OLD/ is now sealed.

If behaviour is unclear, read the spec (`docs/spec/`). If the spec is
unclear, fix the spec. OLD/ never clarifies anything.
