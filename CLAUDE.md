# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
flutter pub get                              # Install dependencies
flutter pub run build_runner build           # Generate Hive adapters (*.g.dart)
flutter gen-l10n                             # Generate localization files
flutter run                                  # Run app
flutter test                                 # Run all tests
flutter test path/to/test.dart               # Run a single test file
flutter analyze --fatal-infos                # Lint / static analysis (strict)
dart format .                                # Format code
dart fix --apply                             # Auto-fix common lint issues
dart run import_sorter:main --no-comments    # Sort imports (enforced by hooks)
flutter test tool/generate_icon.dart         # Regenerate app icon PNGs
flutter pub run flutter_launcher_icons       # Generate platform launcher icons from PNGs
```

After modifying any `@HiveType` model, re-run `build_runner build` to regenerate the `.g.dart` files. Use `--delete-conflicting-outputs` if there are stale generated files.

### Package Management

- Add dependency: `flutter pub add <package_name>`
- Add dev dependency: `flutter pub add dev:<package_name>`
- Remove dependency: `dart pub remove <package_name>`
- When suggesting a new dependency from pub.dev, explain its benefit.

## Architecture

**Stack:** Flutter + Riverpod (state) + GoRouter (navigation) + Hive (local NoSQL storage).

**Feature-first layout** — organized by feature, each in `lib/features/`:
- **Controller** (Riverpod Notifier) — business logic and state
- **Screen** — UI consuming the controller
- **Repository** (in `lib/data/repositories/`) — Hive box CRUD

**Logical layers:**
- `lib/features/` — Presentation (screens) + Domain (controllers)
- `lib/data/` — Models and repositories
- `lib/services/` — Platform API wrappers (audio, location, SMS/WhatsApp/Telegram, vibration, wakelock, notifications), exposed as Riverpod `Provider<T>` via `lib/services/service_providers.dart`
- `lib/core/` — Shared constants, theme, utilities, shared widgets (`PinKeypad`, `LogarithmicSlider`), `StealthConfig` helper

### Core domain: SessionEngine

`lib/domain/session_engine.dart` is a **pure Dart state machine** (no Flutter dependency) that drives the safety session via sealed `EngineState` hierarchy (`EngineIdle`, `EngineRunning`, `EnginePaused`, `EngineEnded`). It emits `ChainEventData` via a `Stream` and manages timer-driven escalation with three-phase timing per step: wait -> duration -> grace.

Two check-in modes:
1. **Walk Mode** — user holds a button; releasing starts a grace period
2. **Date Mode** — periodic disguised reminders; user must respond within grace period

The engine supports speed multipliers (simulation only, rejected for real sessions), ±20% timer jitter, and retry cycles. Distress chain **replaces** the main chain (no sub-chains, no going back). Three distress triggers: hardware panic (5x volume), wrong PIN threshold, duress PIN.

**Data flow:** `HomeScreen -> SessionController (Riverpod) -> SessionEngine (pure Dart) -> emits events -> SessionController updates WalkSession -> SessionScreen`.

### Event Strategies

`lib/features/session/event_strategies/` uses a **Strategy pattern** for the 9 escalation step types. Each `EventStrategy` has `executeReal()` (performs the actual action) and `simulationDescription()` (returns toast text for simulation mode). Registered via `EventStrategyRegistry`.

### Models & Hive

All persistent models live in `lib/domain/models/` with JSON serialization (`toJson`/`fromJson`). Key models:
- `SessionMode` — defines check-in mechanism + main escalation chain of `ChainStep`s + `distressChainId` (references a global `DistressChain` by ID; null = use default) + triggers (distress + disarm) + optional `ModeOverrides`
- `ChainStep` — one escalation step; 9 types with typed `StepConfig` sealed class hierarchy (compile-time safe)
- `EmergencyContact` — contact + messaging channels (List<MessageChannel>) + per-contact SMS language (no `preferredChannel` — all enabled channels are used)
- `DistressChain` — globally-managed named distress chain (id, name, List<ChainStep>); stored in `AppDefaults.distressChains`; first = default
- `AppDefaults` — master defaults for all configurable options modes can inherit and override: `distressChains`, `gpsLogging` (GpsLoggingConfig), `stealth` (StealthConfig), `templates`, `eventDefaults`
- `ModeOverrides` — per-mode optional overrides of `AppDefaults`; null field = inherit from AppDefaults; `localTemplates` are APPENDED to global templates (not replacing)
- `GpsLoggingConfig` — GPS logging settings: enabled, intervalSeconds, accuracy, format, includeInSms, historyRetentionDays
- `StealthConfig` — stealth appearance settings: enabled, fakeName, fakeIcon, notificationDisguise, timerDisplay, sessionScreenStealth
- `EventDefaults` — global per-step-type configuration defaults
- `SessionLog` — persisted record of completed sessions (shareable as text/JSON)
- `BatteryAlertConfig` — low-battery one-shot alert config (threshold + SMS toggle)
- `AppSettings` — three PIN hashes (`appPinHash`, `sessionEndPinHash`, `duressPinHash`; any may be null = disabled), `pinTimeoutSeconds` (default 15), theme, language, emergency number, alarm DND override, and `AppDefaults defaults`
- `UserProfile` — user identity + medical information (included in emergency SMS)
- `ReminderTemplate` — disguised notification templates; `isGlobal=true` → from AppDefaults; `isGlobal=false` → mode-local
- `WalkSession` — ephemeral, tracks active session state (sealed `SessionPhase`)
- `Trigger` — sealed hierarchy: `DistressTrigger` (hardware button) and `DisarmTrigger` (GPS arrival, timer)

Storage: JSON-backed repositories (`JsonSingletonRepository`, `JsonListRepository`) in `lib/data/repositories/`. No backwards compatibility — on schema mismatch, all data is nuked and re-seeded.

### Routing & Screens

All routes in `lib/router/app_router.dart` with names in `lib/core/constants/route_names.dart`. GoRouter with query parameter support. First-launch detection routes to onboarding.

**Screens (24 total):**
- Home, Onboarding, Session, SessionCompleted, SimulationSummary
- FakeCall, Contacts, ContactForm, Modes, ModeEditor
- Templates, TemplateEditor, Profile, Settings
- PinSetup, DistressChain, BatteryAlert, EventDefaults
- PastEvents, PastEventDetail, EvidenceExport
- About, Feedback, Backup

Use `Navigator.push`/`pop` only for short-lived screens that don't need deep linking (e.g., dialogs).

### Onboarding (3 pages)

Minimal onboarding: Welcome → Profile+Contact → Permissions. All advanced setup (PIN, duress PIN, mode customization, additional contacts) deferred to Settings. Onboarding pages are private widget classes within `lib/features/onboarding/onboarding_screen.dart`.

The contact form on page 2 uses the **full `ContactFormScreen` component** — same as adding a contact from Settings. All fields are shown (name, phone, relationship, channel toggles, per-contact language). No stripped-down onboarding-only form.

### Shared Widgets

- `PinKeypad` (`lib/core/widgets/pin_keypad.dart`) — shared numeric keypad used by `PinEntryScreen` and `PinSetupScreen`

**Security settings:** Settings → Security submenu contains all three PIN configurations (App PIN, Session End PIN, Duress PIN) in one place. The Duress PIN silently fires the distress chain when entered at any PIN prompt.

**Defaults submenu:** Settings → Defaults is the master source for GPS logging config, stealth config, global reminder templates, default distress chain, and event step defaults. Each mode can override any individual default via `ModeOverrides`.

### Localization

14 languages: en, de, es, fr, ru, zh, zh_TW, hi, fa, uk, pl, el, ar, he. ARB source files in `lib/l10n/l10n/`. Config in `l10n.yaml`. Access via `AppLocalizations.of(context)`. ~335 localized string keys covering all user-facing text.

RTL languages supported: fa (Farsi), ar (Arabic), he (Hebrew).

**IMPORTANT:** Whenever user-facing messages are added or changed in any ARB file (typically `app_en.arb`), you MUST launch a group of subagents in parallel — one per non-English language — to translate the new/changed messages into the corresponding `app_<lang>.arb` files. Then run `flutter gen-l10n` to regenerate the Dart localization classes. Do not wait for the user to ask; do this automatically after every message change.

## Dart Style

- Follow the official [Effective Dart](https://dart.dev/effective-dart) guidelines.
- **Line length:** 80 characters (enforced by `dart format`).
- **Naming:** `PascalCase` for classes/enums, `camelCase` for members/variables/functions, `snake_case` for files.
- **Immutability:** Prefer immutable data structures. Widget classes (especially `StatelessWidget`) must be immutable.
- **`const` constructors:** Use on classes wherever possible; use `const` in widget trees to reduce rebuilds.
- **Arrow syntax:** Use `=>` for single-expression functions and getters.
- **Null safety:** Avoid the `!` null-assertion operator unless the value is provably non-null. Prefer null-aware operators (`?.`, `??`) or early returns.
- **Switch:** Prefer exhaustive `switch` expressions (no `break` needed) over if/else chains on enums and sealed types.
- **Pattern matching & records:** Use where they simplify code.
- **Async:** Use `Future`/`async`/`await` for single async operations; `Stream` for sequences of async events. Always handle errors.
- **Functions:** Keep functions short and single-purpose — strive for < 20 lines.
- **Composition over inheritance:** Favor composition for building complex widgets and logic.
- **Logging:** Use `dart:developer` `log()` — never `print()`.

## Flutter Widget Patterns

- **Private widget classes over helper methods:** Break large `build()` methods into small private `Widget` classes, not helper methods returning `Widget`.
- **Lazy lists:** Use `ListView.builder` / `GridView.builder` for dynamic or long lists — never build all items eagerly.
- **No heavy work in `build()`:** Do not perform network calls, heavy computation, or I/O inside `build()`.
- **Isolates:** Use `compute()` for expensive work (JSON parsing, image processing) to keep the UI thread free.

### Layout & Responsiveness

- Use `LayoutBuilder` or `MediaQuery` for responsive layouts.
- In `Row`/`Column`, use `Expanded` **or** `Flexible` — do not mix both in the same parent.
- Use `Wrap` when children might overflow horizontally.
- Use `SingleChildScrollView` for fixed-size content larger than the viewport.
- Use `FittedBox` to scale a single child within its parent.

### Theming

- Use `Theme.of(context).textTheme` / `colorScheme` — avoid hard-coded colors and font sizes in widgets.
- For project-specific design tokens not in `ThemeData`, use `ThemeExtension<T>` with `copyWith` and `lerp`.
- Use `ColorScheme.fromSeed()` for harmonious palettes.
- Support both light and dark themes (`ThemeMode.light`, `ThemeMode.dark`, `ThemeMode.system`).
- Use `WidgetStateProperty.resolveWith` for state-dependent component styles.

### Accessibility

- Text contrast ratio ≥ 4.5:1 (normal text) / 3:1 (large text) per WCAG 2.1.
- UI must remain usable under system-level font scaling.
- Provide `Semantics` labels on non-text interactive elements.
- Test with TalkBack (Android) and VoiceOver (iOS).

## Testing

- **Unit tests:** `package:test` — for domain logic, data layer, state management.
- **Widget tests:** `package:flutter_test` — for UI components.
- **Integration tests:** `package:integration_test` (from Flutter SDK) — for end-to-end flows.
- **Assertions:** Prefer `package:checks` for expressive, readable assertions over default matchers.
- **Test doubles:** Prefer fakes or stubs over mocks. Use `mocktail` only when mocking is necessary.
- **Convention:** Follow Arrange-Act-Assert (Given-When-Then).
- **Timer testing:** `fake_async` with `fakeAsync()` wrapper.
- **SessionEngine tests:** Use `_FixedRandom` for deterministic randomization (returns 0.5, eliminating jitter).
- **Test files** in `test/` mirror the `lib/` structure.
- **Helper pattern:** `_step()` factory function for creating `ChainStep` with minimal boilerplate.

## Documentation

- Add `///` doc comments to all public APIs (classes, constructors, methods, top-level functions).
- First sentence: concise, user-centric summary ending with a period. Separate from body with a blank line.
- Comment **why**, not **what** — the code should be self-explanatory.
- Don't add documentation that merely restates the name or signature.
- Place doc comments before annotations.
- Use backtick fences with language identifier for code samples.

## Code Quality

- **Strict analysis**: `strict-casts`, `strict-inference`, `strict-raw-types` all enabled
- **Git hooks** (lefthook): pre-commit runs `dart format` + `import_sorter`; pre-push runs `flutter analyze` + `flutter test`
- **CI** (.github/workflows/ci.yml): format check, import sort, build_runner, analyze, test, **dep audit (no discontinued direct deps)**

## Dependency policy

Pre-alpha rules:

- No backwards compatibility. Replace any direct dependency whose
  pub.dev `isDiscontinued` flag is `true` in the **same cycle** the
  flag is detected — don't carry an EOL package across releases.
  CI's "Audit for discontinued packages" step in `ci.yml` enforces
  this with a hard fail.
- Run `flutter pub outdated` before opening any PR that touches
  `pubspec.yaml`. Bumping major versions of direct deps is preferred
  over staying on a behind-by-major release; document any major bump
  blocked by a transitive constraint (e.g. `flutter_secure_storage_windows`
  pinning `win32 ^5.5.4` blocks `share_plus 13` / `package_info_plus 10`
  / `device_info_plus 13` until a newer `flutter_secure_storage`
  releases).
- Migrations history (so future-you remembers what bit us last):
  - `e67f082` (May 2026): dropped `sqlcipher_flutter_libs` (EOL),
    moved to `sqlite3 3.x` + `sqlite3mc` via Dart 3.11 build hooks.
  - Phase-deps (May 2026): swapped `golden_toolkit` (discontinued)
    for `alchemist`. Goldens regenerated under `test/goldens/goldens/`.

## Native Platform Channels

**Android** (`android/app/src/main/kotlin/com/guardianangela/app/`):
- `MainActivity.kt` — Registers all platform channels: SMS, volume buttons, session control, phone call, call state, system UI
- `SmsChannel.kt` — `com.guardianangela.app/sms` — SMS sending (direct + WorkManager enqueue)
- `SmsWorker.kt` — WorkManager CoroutineWorker for background SMS with exponential backoff retry
- `CallStateChannel.kt` — `com.guardianangela.app/call_state` — TelephonyCallback for incoming call detection (idle/ringing/active)
- `SystemUiChannel.kt` — `com.guardianangela.app/system_ui` — Quick Exit via finishAndRemoveTask, battery optimization exemption
- `PhoneCallHelper.kt` — `com.guardianangela.app/phone` — Auto-dial with CALL_PHONE permission, fallback to ACTION_DIAL
- `BootReceiver.kt` — WorkManager re-init after reboot for pending SMS

**iOS** (`ios/Runner/`):
- `CallStatePlugin.swift` — CXCallObserver for call detection (idle/ringing/active/ended)
- `SystemUiPlugin.swift` — No-op stubs for clearRecentsAndExit and batteryExemption (not applicable on iOS)

## Seed Data

`lib/data/seed_data.dart` defines two built-in modes (Walk Mode and Date Mode) with preset escalation chains, plus 8 built-in reminder templates (Calendar, Duolingo, Delivery, etc.), plus per-step-type event defaults.

## App Identity

- **Name:** Guardian Angela (wordplay on "guardian angel" + "Ask for Angela" safety campaign)
- **Application ID:** `com.guardianangela.app`
- **Logo:** Pride-flag gradient angel with feathered wings, shield body (cutout gap between wings and shield), and halo. Widget: `GuardianAngelaLogo` in `lib/core/theme/guardian_angela_logo.dart`. Icon generator: `tool/generate_icon.dart`.
