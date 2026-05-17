# Guardian Angela — Pre-Rewrite Preservation Manifest

This manifest enumerates everything that must survive the upcoming
ground-up rewrite. Items are classified as:

- **SOURCE-OF-TRUTH** — human-authored. Copy verbatim to the new repo.
- **DERIVED** — regenerable from a source-of-truth. Do NOT copy; re-run
  the generator in the new tree.

Every path below has been verified to exist in the current repo. Anything
the legacy CLAUDE.md referenced but that does NOT exist in the tree is
called out explicitly in §3.1 ("Discrepancies vs CLAUDE.md").

---

## 0. Top-Priority Preserve (the "if these are lost, the user is angry" list)

1. **Logo widget source** —
   `lib/core/theme/guardian_angela_logo.dart`
   (`GuardianAngelaLogo` + `_LogoPainter`). The branded shield + halo
   drawn in pure Dart `CustomPainter`. All launcher icons derive from
   this concept; the dart source is the only human creative artifact.
2. **App identity & launcher source PNGs** —
   `assets/icon/app_icon.png` and `assets/icon/app_icon_foreground.png`
   (consumed by `flutter_launcher_icons`, configured in `pubspec.yaml`
   under the `flutter_launcher_icons:` block).
3. **14 ARB localization files** (English template + 13 translations) —
   `lib/l10n/l10n/app_<lang>.arb` (en, de, es, fr, ru, zh, zh_TW, hi,
   fa, uk, pl, el, ar, he). ~1,053 key occurrences in `app_en.arb`.
4. **Spec corpus** — `docs/spec/00-overview.md` through
   `docs/spec/11-deferred-enhancements.md` (12 normative files).
5. **Android native channel code** —
   `android/app/src/main/kotlin/com/guardianangela/app/*.kt`
   (11 Kotlin files; full list in §3).
6. **AndroidManifest.xml** —
   `android/app/src/main/AndroidManifest.xml` (permissions,
   `activity-alias` stealth icons, BootReceiver, home-widget receiver,
   intent queries).
7. **iOS native plugins & Info.plist** —
   `ios/Runner/CallStatePlugin.swift`, `ios/Runner/SystemUiPlugin.swift`,
   `ios/Runner/AlarmAudioPlugin.swift`, `ios/Runner/AppDelegate.swift`,
   `ios/Runner/SceneDelegate.swift`, `ios/Runner/Info.plist` (contains
   the human-written `NSLocationWhenInUseUsageDescription` /
   `NSMicrophoneUsageDescription` strings reviewed by App Review).
8. **Diagrams (mermaid source)** — `docs/diagrams/mmd/*.mmd`
   (15 mermaid files). The PNGs under `docs/diagrams/rendered/` are
   DERIVED.
9. **Spec-aligned seed content** — `lib/data/seed_data.dart`
   (Walk Mode, Date Mode, default distress mode, 8 templates,
   per-step event defaults). The file structure will be regenerable
   under the new schema, but the CONTENT DECISIONS (chain shapes,
   timings, copy keys) must be ported step-by-step.
10. **CI + pre-commit/pre-push contract** —
    `.github/workflows/ci.yml`, `lefthook.yml`, `analysis_options.yaml`
    (strict-casts / strict-inference / strict-raw-types). These encode
    the project's quality bar and the discontinued-dep audit.

---

## 1. App Identity

| Item | Path | Kind | Verify by |
|---|---|---|---|
| Application name "Guardian Angela" | `pubspec.yaml` (line 1-2), `android/app/src/main/AndroidManifest.xml` (`android:label`), `android/app/src/main/res/values/strings.xml`, `ios/Runner/Info.plist` (`CFBundleDisplayName`, `CFBundleName`) | SOURCE-OF-TRUTH | `grep -r "Guardian Angela"` in new repo finds the same four locations. |
| Application ID `com.guardianangela.app` | `android/app/build.gradle.kts` (`namespace`, `applicationId`), `android/app/src/main/kotlin/com/guardianangela/app/` (package path on every `.kt` file) | SOURCE-OF-TRUTH | `./gradlew :app:dependencies` reports the same applicationId; package directory tree matches. |
| Logo widget | `lib/core/theme/guardian_angela_logo.dart` | SOURCE-OF-TRUTH | Renders identically on About screen golden test. |
| Launcher icon source PNGs | `assets/icon/app_icon.png`, `assets/icon/app_icon_foreground.png` | SOURCE-OF-TRUTH | `flutter pub run flutter_launcher_icons` succeeds and produces identical mipmap/AppIcon output. |
| Launcher icon generator config | `pubspec.yaml` `flutter_launcher_icons:` block (lines 126-134; includes `adaptive_icon_background: "#131118"`) | SOURCE-OF-TRUTH | Re-running the generator overwrites the same mipmap paths. |
| Android adaptive icon background color | `android/app/src/main/res/values/colors.xml` (`#131118`) | SOURCE-OF-TRUTH | Matches the value in `pubspec.yaml`. |
| Generated launcher PNGs (Android) | `android/app/src/main/res/mipmap-{m,h,xh,xxh,xxxh}dpi/ic_launcher.png` | DERIVED | Bit-identical re-emit from generator. |
| Generated launcher PNGs (iOS) | `ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png` (21 sizes) + `Contents.json` | DERIVED | Same. |
| iOS launch storyboard | `ios/Runner/Base.lproj/LaunchScreen.storyboard`, `Main.storyboard`, plus `ios/Runner/Assets.xcassets/LaunchImage.imageset/` | SOURCE-OF-TRUTH | Splash renders the legacy launch image. |

**Discrepancy:** Legacy CLAUDE.md references `tool/generate_icon.dart`
and `flutter test tool/generate_icon.dart`. **There is no `tool/`
directory in the current repo.** The launcher icons are produced
exclusively by `flutter_launcher_icons` from
`assets/icon/app_icon*.png`. If the icon-generator script is wanted in
the rewrite it has to be written fresh (it's not in the legacy tree to
copy).

---

## 2. Localization Corpus

| Item | Path | Kind | Verify by |
|---|---|---|---|
| ARB source files (14 languages) | `lib/l10n/l10n/app_{en,de,es,fr,ru,zh,zh_TW,hi,fa,uk,pl,el,ar,he}.arb` | SOURCE-OF-TRUTH | Run `flutter gen-l10n`; resulting Dart classes contain every key from the new tree's `app_en.arb`. |
| l10n config | `l10n.yaml` (declares `arb-dir`, `template-arb-file: app_en.arb`, `output-class: AppLocalizations`, `nullable-getter: false`) | SOURCE-OF-TRUTH | `flutter gen-l10n` writes to `lib/l10n/l10n/app_localizations*.dart`. |
| Generated localization classes | `lib/l10n/l10n/app_localizations.dart` and `app_localizations_<lang>.dart` (15 files) | DERIVED | Regenerated via `flutter gen-l10n`. |
| Per-contact SMS language enum strings, etc. | Referenced from the ARB files; no extra source | n/a | — |
| Native Android strings (widget-only) | `android/app/src/main/res/values/strings.xml` (only the home-widget RemoteViews labels — see comment block in file) | SOURCE-OF-TRUTH | Home-widget shows "Quick Exit" / "Fake Call" on the home screen. |
| Voice prompt audio | `assets/voice/angela_<lang>.m4a` (14 files; **silent 1-second placeholders** per `assets/voice/README.md`) + `assets/voice/README.md` | SOURCE-OF-TRUTH (the README and the asset bundle wiring); the audio is itself a placeholder so re-generation is acceptable | Asset-exists check in `AudioService.playVoiceRecording` passes for every locale. |
| Alarm audio | `assets/audio/alarm.mp3`, `assets/audio/ringtone.wav` | SOURCE-OF-TRUTH | Plays during loud-alarm step. |

**Translation effort warning:** The 13 non-English ARB files represent
real translation work done by language sub-agents. Re-doing them is
expensive and lossy (re-translation will not produce byte-identical
strings, breaking visual review).

---

## 3. Native Platform Code

### 3.1 Android (Kotlin, package `com.guardianangela.app`)

Path prefix: `android/app/src/main/kotlin/com/guardianangela/app/`.
All files are SOURCE-OF-TRUTH. Verify by: feature parity (SMS sends,
volume buttons trigger distress, fake-call full-screen intent fires,
home widget appears, stealth alias activates).

| File | Channel name | Purpose |
|---|---|---|
| `MainActivity.kt` | — | Channel registration entry point |
| `SmsChannel.kt` | `com.guardianangela.app/sms` | Direct send + WorkManager enqueue |
| `SmsWorker.kt` | (no MethodChannel) | `CoroutineWorker` with exponential backoff |
| `CallStateChannel.kt` | `com.guardianangela.app/call_state` | TelephonyCallback for incoming-call detection |
| `SystemUiChannel.kt` | `com.guardianangela.app/system_ui` | Quick Exit, battery-optimization exemption |
| `PhoneChannel.kt` | `com.guardianangela.app/phone` | Auto-dial with `CALL_PHONE` fallback to `ACTION_DIAL` |
| `BootReceiver.kt` | — | WorkManager re-init after reboot |
| `HardwareButtonChannel.kt` | (volume button distress trigger) | 5x volume-press detection |
| `DeviceStateChannel.kt` | (battery + device info) | Native battery/state reads |
| `StealthIconChannel.kt` | (activity-alias toggle) | Calls `PackageManager.setComponentEnabledSetting` for the 3 stealth aliases declared in `AndroidManifest.xml` |
| `GuardianAngelaAppWidget.kt` | — | Home-screen widget RemoteViews provider |

**Discrepancy vs CLAUDE.md:** CLAUDE.md lists 7 Kotlin files; the repo
contains **11**. The four extras (`HardwareButtonChannel`,
`DeviceStateChannel`, `StealthIconChannel`, `GuardianAngelaAppWidget`)
are real and must be preserved.

| Item | Path | Kind | Verify by |
|---|---|---|---|
| AndroidManifest | `android/app/src/main/AndroidManifest.xml` | SOURCE-OF-TRUTH | All 14 `<uses-permission>` declarations present in new build's manifest dump (`./gradlew :app:processDebugManifest`). Verify the 3 `<activity-alias>` stealth entries (`StealthAlias_music`, `_podcast`, `_calendar`) are present. |
| App Gradle | `android/app/build.gradle.kts` (declares `coreLibraryDesugaring`, `androidx.work:work-runtime-ktx:2.9.1`) | SOURCE-OF-TRUTH | `flutter build apk --debug` succeeds. |
| Root Gradle | `android/build.gradle.kts`, `android/settings.gradle.kts`, `android/gradle.properties`, `android/gradle/` | SOURCE-OF-TRUTH | Wrapper version + plugin pins reproduce. |
| Resources (non-icon) | `android/app/src/main/res/values/strings.xml`, `values/colors.xml`, `values/styles.xml`, `values-night/styles.xml`, `drawable/launch_background.xml`, `drawable-v21/launch_background.xml`, `xml/backup_rules.xml`, `xml/data_extraction_rules.xml`, `xml/guardian_angela_widget_info.xml`, `layout/guardian_angela_widget.xml` | SOURCE-OF-TRUTH | Splash, dark theme, and home widget render correctly. |

### 3.2 iOS

All under `ios/`. SOURCE-OF-TRUTH unless noted.

| File | Purpose |
|---|---|
| `ios/Runner/AppDelegate.swift` | Flutter app delegate |
| `ios/Runner/SceneDelegate.swift` | Scene lifecycle |
| `ios/Runner/CallStatePlugin.swift` | `CXCallObserver` for call detection |
| `ios/Runner/SystemUiPlugin.swift` | Stubs for clear-recents/battery exemption (no-op on iOS) |
| `ios/Runner/AlarmAudioPlugin.swift` | Loud-alarm audio session handling |
| `ios/Runner/Info.plist` | App identity + permission strings (App-Review-vetted copy) |
| `ios/Runner/Base.lproj/LaunchScreen.storyboard`, `Main.storyboard` | Splash + storyboard scaffolding |
| `ios/Runner/Assets.xcassets/LaunchImage.imageset/*.png` + `Contents.json` + `README.md` | Splash image set |
| `ios/Runner.xcodeproj/project.pbxproj` | Xcode project (signing, build phases) |
| `ios/Runner.xcodeproj/project.xcworkspace/contents.xcworkspacedata`, `xcshareddata/` | Workspace + shared schemes |
| `ios/Runner.xcworkspace/contents.xcworkspacedata`, `xcshareddata/` | Workspace pointer used by `flutter run` |
| `ios/Flutter/AppFrameworkInfo.plist`, `Debug.xcconfig`, `Release.xcconfig` | xcconfig anchors (NOT `Generated.xcconfig`, NOT `ephemeral/`, NOT `flutter_export_environment.sh`) |
| `ios/Runner/GeneratedPluginRegistrant.{h,m}` | **DERIVED** by `flutter` build — do not copy. |
| `ios/Runner/Runner-Bridging-Header.h` | SOURCE-OF-TRUTH (Swift/ObjC bridge) |
| `ios/RunnerTests/` | SOURCE-OF-TRUTH (Xcode unit test target) |

**No Podfile present** — current iOS build uses Flutter's
non-CocoaPods integration path; do not invent one in the new repo
unless the rewrite adds Pods.

**No `.entitlements` file present** — the legacy CLAUDE.md mentioned
entitlements but none exist on disk today. If push notifications,
background modes, or capability-gated features land in the rewrite,
the entitlements file must be created fresh.

---

## 4. Build & CI Infrastructure

| Item | Path | Kind | Verify by |
|---|---|---|---|
| GitHub Actions CI | `.github/workflows/ci.yml` (format check, import sort, build_runner, analyze, test, **discontinued-deps audit**, e2e Patrol gated on `v*` tags, signed release builds for Android/iOS) | SOURCE-OF-TRUTH | Re-run the workflow on the new repo's first PR; all green steps reproduce. |
| Git hooks | `lefthook.yml` (pre-commit: `dart format` + `import_sorter`; pre-push: `flutter analyze` + `flutter test`) | SOURCE-OF-TRUTH | `lefthook install && git commit` triggers both formatters; `git push` triggers analyze + test. |
| Lint config | `analysis_options.yaml` (strict-casts, strict-inference, strict-raw-types; excludes `**/*.g.dart`, `**/*.freezed.dart`, `lib/l10n/**`, `old{,2,3,4,5}/**`; disables `directives_ordering` to coexist with `import_sorter`) | SOURCE-OF-TRUTH | `flutter analyze --fatal-infos` matches behavior. |
| Editor config | `.editorconfig` | SOURCE-OF-TRUTH | Editors honor 2-space indents etc. |
| Dart test tags | `dart_test.yaml` (declares the `golden` tag used by Alchemist) | SOURCE-OF-TRUTH | `dart test` stops warning about undeclared tags. |
| Pubspec | `pubspec.yaml` (all pinned versions, `flutter_launcher_icons:` block, `import_sorter:` block, asset declarations for `assets/audio/` + `assets/voice/`, **`hooks:` block selecting `sqlite3mc` source** for SQLCipher-compatible builds without `sqlcipher_flutter_libs`) | SOURCE-OF-TRUTH | `flutter pub get` resolves to the same lock. |
| Pubspec lock | `pubspec.lock` | SOURCE-OF-TRUTH (reproducibility) — but it's acceptable to regenerate if the rewrite intentionally bumps deps | `flutter pub get` produces a similarly-shaped tree. |
| README + AGENTS | `README.md`, `AGENTS.md`, `CLAUDE.md` (root) | SOURCE-OF-TRUTH | Onboarding docs reference the same conventions. |
| `.gitignore`, `.metadata` | `.gitignore`, `.metadata` | SOURCE-OF-TRUTH | Standard Flutter project hygiene. |

---

## 5. Specs & Design Documentation

### 5.1 Spec corpus (normative — drives the rewrite)

`docs/spec/` (12 files, ALL SOURCE-OF-TRUTH):
- `00-overview.md`
- `01-chain-engine.md`
- `02-event-types.md`
- `03-data-models.md`
- `04-screens-navigation.md`
- `05-services.md`
- `06-settings.md`
- `07-test-plan.md`
- `08-decisions-consolidated.md`
- `09-glossary.md`
- `10-platform-matrix.md`
- `11-deferred-enhancements.md`

Verify by: every spec ID referenced by tests in the new repo resolves
to text in these files.

### 5.2 Diagrams (SOURCE-OF-TRUTH = mermaid source; PNG = derived)

`docs/diagrams/mmd/*.mmd` (15 files: 10 numbered event lifecycles +
2 chain diagrams + 3 sub-chain diagrams). Companion narratives in
`docs/diagrams/default_chains.md` and `docs/diagrams/event_lifecycles.md`.

DERIVED: `docs/diagrams/rendered/*.png` (15 PNGs).

### 5.3 Review history (KEEP — institutional memory)

`docs/review/` (25 markdown files: audit decisions, postmortems, PM
phase reports, spec-completeness review, v2 final compliance reports,
adversarial-user review). These document WHY current decisions were
made — invaluable when the rewrite re-litigates a question.

### 5.4 Other docs (KEEP — useful but not normative)

- `docs/PROGRESS.md`, `docs/REWRITE_REVIEW.md`, `docs/SPEC_INDEX.md`
- `docs/strategy-index.md`, `docs/test-strategy.md`, `docs/test-plan.md`,
  `docs/test-failure-analysis.md`
- `docs/rebuild-strategy.md`, `docs/implementation-guide.md`,
  `docs/architecture-sketch.md`
- `docs/audit-engine.md`, `docs/audit-spec-vs-code.md`,
  `docs/audit-tests.md`, `docs/audit-ui.md`
- `docs/engine-analysis.md`, `docs/wiring-map.md`,
  `docs/issues-v4.md`, `docs/decisions-log.md`,
  `docs/decisions-round-2.md`
- `docs/manual-device-test-checklist.md`
- `docs/interruption-resilience-strategy.md`
- `docs/review-bugs.md`, `docs/review-edge-cases.md`,
  `docs/review-spec-compliance.md`, `docs/remaining-gaps.md`
- `docs/agent-prompts/` (6 files: coding-agent, design-agent, fixer,
  pm-orchestrator, reviewer, verifier)
- `docs/verification/*.json` (8 verification cache files; SOURCE-OF-TRUTH
  if the rewrite reuses the same verification harness, otherwise DERIVED)
- `docs/rewrite-wal/` (16 phase WAL JSONs + README — checkpoint journal
  for the long multi-agent run, per the project's
  "interruption resilience via tasks" memory)

---

## 6. Test Fixtures & Helpers Worth Carrying Over

| Item | Path | Notes |
|---|---|---|
| Engine/model factory helpers | `test/helpers/test_helpers.dart` | Contains `step()`, `holdStep()`, `smsStep()`, `makeMode()` **and `FixedRandom`** (the deterministic-random class used by every SessionEngine test — confirmed at `test_helpers.dart:30`). |
| Widget test scaffold | `test/features/widget_test_helpers.dart` | `hostScreen()` etc. |
| Riverpod provider override fakes | `test/features/fake_repositories.dart` | Fake repository implementations. |
| In-memory Drift setup | `test/data/db/dao_test_support.dart` | Drives `app_database_*_test.dart` files. |
| Drift schema regression test | `test/data/db/schema/tables_direct_test.dart` | Verifies the static schema doesn't drift silently. |
| Golden image baselines | `test/goldens/goldens/*.png` (32 images) + `test/goldens/goldens/ci/*.png` (4 CI-tier images) + `test/goldens/goldens_setup.dart` | Renderer output for home / session (idle, fakeCall, holdButton, loudAlarm) / settings / onboarding (welcome, profile, permissions) / distress confirmation, in light + dark variants. |
| Golden test specs | `test/goldens/{home,session,settings,onboarding,fake_call,distress_confirmation}_screen_golden_test.dart` | Stay in sync with the baselines above. |
| Engine test suite | `test/domain/engine/*.dart` (10 files including `engine_jitter_test.dart`, `engine_speed_multiplier_test.dart`, `pause_resume_test.dart`, `trigger_gps_arrival_test.dart`, `hold_button_test.dart`, `engine_background_clamp_strict_test.dart`, etc.) | These pin engine semantics — port them BEFORE rewriting the engine. |
| Wiring contract tests | `test/wiring/wiring_contract_test.dart`, `wiring_map_coverage_test.dart` | Pin the provider graph shape against `docs/wiring-map.md`. |
| Integration / Patrol tests | `integration_test/app_test.dart`, `date_mode_flow_test.dart`, `distress_flow_test.dart`, `walk_mode_flow_test.dart` | Run from CI's `e2e` job on tagged builds. |
| Property tests | `test/property/json_round_trip_property_test.dart` | Round-trip invariant for persisted models. |
| Smoke + locale tests | `test/smoke_test.dart`, `test/app_locale_test.dart`, `test/main_seed_wiring_test.dart` | First-launch / locale routing sanity. |

**Golden failures cache:** `test/goldens/failures/` is regenerated on
every failing golden run — DO NOT preserve.

---

## 7. Seed Data

**File:** `lib/data/seed_data.dart`

The Dart file structure is regenerable under the new schema (the
rewrite will own its own Drift tables / Hive boxes), but the CONTENT
DECISIONS in this file are the result of multiple PM rounds with the
spec and must be ported step-by-step:

- Walk Mode chain (steps, timings, copy keys)
- Date Mode chain
- Default distress mode (the `isDistressMode=true` SessionMode that
  replaces the legacy `DistressChain` per the
  "Distress = mode (unified model)" memory)
- 8 disguised-reminder templates (Calendar, Duolingo, Delivery, etc.)
- Per-step-type event defaults

Regression check: `test/data/seed_data_test.dart` builds a real
in-memory Drift database and asserts the seeded shape — port both the
seed and this test together.

---

## 8. Anything Else Load-Bearing

| Item | Path | Why |
|---|---|---|
| `dart_test.yaml` | root | Declares the `golden` tag for Alchemist. |
| `assets/audio/alarm.mp3`, `assets/audio/ringtone.wav` | root | Required for the loud-alarm and fake-call rings. |
| Adaptive icon background color `#131118` | `pubspec.yaml` + `android/app/src/main/res/values/colors.xml` | Brand color; must stay in sync if changed. |
| Permission strings on iOS (`NSLocationWhenInUseUsageDescription`, `NSMicrophoneUsageDescription`) | `ios/Runner/Info.plist` | App Review vets these. |
| 14 `<uses-permission>` declarations on Android | `AndroidManifest.xml` | Loss = silent feature breakage. |
| 3 stealth `<activity-alias>` declarations | `AndroidManifest.xml` | `StealthIconChannel` depends on these existing. |
| Home-screen widget assets | `android/app/src/main/res/layout/guardian_angela_widget.xml`, `xml/guardian_angela_widget_info.xml`, `values/strings.xml` (widget labels) | Widget renders without a Flutter engine — strings must live in Android resources. |

---

## DO NOT PRESERVE (anti-list)

These are auto-generated. The rewrite should regenerate them cleanly
in the new tree. Copying them across leaks stale state.

- **Build artifacts:** `build/`, `.dart_tool/`, `coverage/`,
  `.sentry-native/`
- **IDE state:** `.idea/`, `guardianangela.iml`,
  `android/guardianangela_android.iml`, `android/local.properties`,
  `android/build/` (Gradle build dir)
- **Flutter ephemeral:** `.flutter-plugins-dependencies`, `.metadata`
  (let `flutter create` regenerate; the project's `.metadata` is
  optional but harmless to keep)
- **iOS ephemeral:** `ios/Flutter/Generated.xcconfig`,
  `ios/Flutter/ephemeral/`, `ios/Flutter/flutter_export_environment.sh`,
  `ios/Runner/GeneratedPluginRegistrant.{h,m}`
- **Drift generated:** all `lib/data/db/**/*.g.dart`
  (`app_database.g.dart`, every DAO's `*.g.dart`) — regenerate with
  `dart run build_runner build --delete-conflicting-outputs`
- **Hive generated:** any `*.g.dart` produced by `hive_ce_generator`
  (the legacy app is migrating away from Hive, but if any persist —
  regenerate)
- **Localization generated:** `lib/l10n/l10n/app_localizations.dart`
  and all `app_localizations_<lang>.dart` (15 files) — regenerate with
  `flutter gen-l10n`
- **Launcher icons (PNG outputs):** every file under
  `android/app/src/main/res/mipmap-*/ic_launcher.png` and the entire
  `ios/Runner/Assets.xcassets/AppIcon.appiconset/` set — regenerate with
  `flutter pub run flutter_launcher_icons`
- **Diagram PNGs:** `docs/diagrams/rendered/*.png` — regenerate from
  the mermaid `.mmd` sources
- **Golden test failure dumps:** `test/goldens/failures/`
- **Legacy code parking lots:** `old/`, `old2/`, `old3/`, `old4/`,
  `old5/` (excluded by `analysis_options.yaml`; do not carry over)
- **`pubspec.lock`:** acceptable to regenerate if the rewrite bumps
  deps. Otherwise preserve.

---

## Migration Recipe

A short ordered checklist for the rewrite owner.

**Step 1 — Bootstrap the new tree.**
1. `flutter create --org com.guardianangela --project-name guardianangela --platforms=android,ios new_repo/`
2. Replace the generated `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist` with the legacy ones.
3. Overwrite `pubspec.yaml`, `analysis_options.yaml`, `l10n.yaml`,
   `lefthook.yml`, `dart_test.yaml`, `.editorconfig` with the legacy
   versions. Re-run `flutter pub get`.

**Step 2 — Copy the irreplaceables.**
4. Copy the **logo widget**: `lib/core/theme/guardian_angela_logo.dart`.
5. Copy the **icon source PNGs**: `assets/icon/` (whole dir) and
   `assets/audio/`, `assets/voice/`.
6. Copy **all 14 ARB source files**:
   `lib/l10n/l10n/app_<lang>.arb` (do NOT copy
   `app_localizations*.dart`).
7. Copy **all Kotlin native code** (11 files) and Android resources
   (`android/app/src/main/res/`, EXCLUDING `mipmap-*/ic_launcher.png`
   which will be regenerated).
8. Copy **all iOS native code** (`ios/Runner/*.swift`,
   `Info.plist`, storyboards, `Runner-Bridging-Header.h`,
   `RunnerTests/`, `Assets.xcassets/LaunchImage.imageset/`), but
   EXCLUDE `Assets.xcassets/AppIcon.appiconset/`, `Flutter/Generated.xcconfig`,
   `Flutter/ephemeral/`, and `GeneratedPluginRegistrant.{h,m}`.
9. Copy **spec corpus** (`docs/spec/`), **mermaid sources**
   (`docs/diagrams/mmd/`), and the **review history** (`docs/review/`).
   Optionally copy the rest of `docs/` if the rewrite team wants the
   audit trail.
10. Copy **test fixtures & golden baselines**:
    `test/helpers/test_helpers.dart`,
    `test/features/widget_test_helpers.dart`,
    `test/features/fake_repositories.dart`,
    `test/data/db/dao_test_support.dart`,
    `test/goldens/goldens/`, `test/goldens/goldens_setup.dart`,
    plus all `test/domain/engine/*.dart` and
    `test/wiring/*.dart` as a starting test suite.
11. Copy `lib/data/seed_data.dart` (content reference) — expect to
    rewrite the surrounding scaffolding to match the new schema.
12. Copy `.github/workflows/ci.yml`, `README.md`, `AGENTS.md`,
    `CLAUDE.md`.

**Step 3 — Regenerate the derived layer.**
13. `flutter pub get`
14. `flutter gen-l10n` — produces `lib/l10n/l10n/app_localizations*.dart`.
15. `dart run build_runner build --delete-conflicting-outputs` —
    produces all `*.g.dart` for Drift (and Hive if still used).
16. `flutter pub run flutter_launcher_icons` — produces all mipmap
    PNGs and the iOS AppIcon set.
17. (Optional) Re-render mermaid diagrams to `docs/diagrams/rendered/`.

**Step 4 — Verify.**
18. `dart format --output=none --set-exit-if-changed .` → clean.
19. `dart run import_sorter:main --no-comments --exit-if-changed` → clean.
20. `flutter analyze --fatal-infos` → clean.
21. `flutter test` → all engine tests, wiring contracts, seed-data
    test, and golden baselines pass.
22. `flutter pub outdated --json` → no `isDiscontinued` direct deps.
23. `flutter build apk --debug` and `flutter build ios --no-codesign`
    → both succeed.
24. Visual spot-check: app launches with the **Guardian Angela**
    label and the pride-gradient launcher icon. About screen renders
    the `GuardianAngelaLogo`. Switching system locale through all 14
    supported languages does not produce any "missing translation"
    fallbacks to English.

If any of steps 18-24 fail, the regeneration was incomplete or a
preservation item was missed — return to the relevant copy step.
