# Guardian Angela v3 — Session Hand-off

**Snapshot:** 2026-06-03 — **Phase 7 COMPLETE, committed, and PUSHED.** Native platform channels (Android Kotlin + iOS Swift/WidgetKit) + **strategy dispatch wired** (the v2-killer: real sessions now actually invoke `executeReal`, so SMS/calls/alarms finally dispatch) + **full home-screen widget stack** (Android RemoteViews + iOS WidgetKit) + a **`file_picker`→`file_selector` dependency fix** (which unblocked a *pre-existing, latent broken Android build*) + **two new CI build jobs** (Android APK on ubuntu, iOS on macOS). The post-phase verification cohort ran (PM + architect = FIX_REQUIRED → all fixed; QA = PASS). **The branch is now pushed and the first-ever CI run on the v3 tree is in progress — CI TRIAGE is the immediate next work (see §CI Triage).**
**HEAD:** `bde5047` (`phase-7-fix`) on top of `b670049` (`phase-7`).
**Tests passing:** `3692 / 3692` (`flutter test --concurrency=6`).
**Analyzer:** `0 issues` (`flutter analyze --fatal-infos`).
**Android build:** `flutter build apk --debug` **succeeds** (verified locally, no stub hacks).
**iOS build:** written but **NOT build-verified locally** (Linux host, no Xcode) — the new `build-ios` macOS CI job is the gate.
**Branch:** `main`, **PUSHED to `origin/main` (`bde5047`)**. CI run **`26867384330`** in progress (`gh run view 26867384330`). **OLD/ is INERT.**

---

## How to resume

After `/clear`, paste:

> Continue from HANDOFF.md

Start from §"CI Triage" (the immediate next work — the first CI run on v3 will have failures to fix), then §"Next actions". Plan files in `~/.claude/plans/` (`make-sure-that-there-typed-tulip.md` + `rippling-weaving-puffin.md`) and `docs/rewrite/v3-plan.md` remain the source of truth.

---

## Hard rules (unchanged — apply to every stage going forward)

1. **OLD/ is INERT.** Never read/list/glob/grep/import anything under `OLD/`. If a tool dirties it, restore with `git checkout HEAD -- OLD/` — *do not browse the files*.
2. **NO STUBS at GA.** All 12 S-NN categories in `~/.claude/plans/make-sure-that-there-typed-tulip.md §NO-STUBS` are CI hard fails.
3. **NO INVENTED DEFERRALS.** "Phase X" comments are legitimate ONLY if that phase's plan actually scopes the work. Grep `lib/features/` for `"Phase 8\|Phase 9\|Phase 10\|Phase 11"` before every commit; MUST be empty.
4. **DO NOT guess.** Use `AskUserQuestion` for spec ambiguity / values-laden decisions. (Used 4× this session — Phase-7 scope, home-widget scope, file-dependency strategy was decided without asking once validated, and the SMS `NetworkType` safety call.)
5. **Pre-alpha = break compatibility freely.** Bump major dep versions over staying behind; document any bump blocked by a transitive constraint.
6. **Verify after EVERY fix or stage.** Analyzer + tests + build + grep gates. Re-engage the same verifier on `FIX_REQUIRED`.
7. **Write/update HANDOFF.md before the session ends** (see §"End-of-session ritual").
8. **Serial default; parallel only when truly orthogonal** (disjoint files, no shared mutable state). Verifier cohorts MAY run in parallel (read-only).
9. **Co-Authored-By footer:** `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>` (the model running the session).
10. **Pure Dart in `lib/domain/`, `lib/services/protocols/`, `lib/data/`.** No `package:flutter` imports.
11. **lefthook re-stages auto-fixes** (`stage_fixed: true`) and is **OLD/-safe** (format scoped to `lib/ test/ integration_test/`; import_sorter excludes `^/OLD/` via pubspec config). **NEVER run `dart format .` or `dart run import_sorter:main` REPO-WIDE** — they ignore those excludes and rewrite OLD/. Scope them to changed files (pass paths). Do NOT bypass hooks.

---

## Current state at a glance

| Phase | Status | Tests | Commits |
|---|---|---|---|
| Pre-flight + Phase 0..5 | ✅ Done | 2447 | `40d9add..36d30cf` |
| Phase 6 (screens + routing + tests + goldens) | ✅ Done | 3538 | `ee73b62..cedaecf` |
| Phase 6 fix-passes C/D/E | ✅ Done | 3661 | `5bd1486..64cd14a` |
| i18n backfill (355 keys × 13 locales) | ✅ Done | 3661 | `fdb85c7` |
| **Phase 7 (native channels + dispatch + widget + dep fix + CI jobs)** | ✅ **Done** | **3692** | **`b670049`** |
| **Phase 7 fix (cohort fixes)** | ✅ **Done** | **3692** | **`bde5047`** |
| Phase 8..11 | Pending |  |  |

---

## What THIS session delivered (`b670049`, `bde5047`)

### `phase-7` (`b670049`)
- **Android native channels (Kotlin)** — `MainActivity` registers all 7 channels + `dispatchKeyEvent` volume-button capture (suppresses HUD); `SmsChannel`+`SmsWorker` (WorkManager, 30s×10 backoff, `smsRetryExhausted` callback); `CallStateChannel` (`TelephonyCallback`→`idle/ringing/offhook`); `HardwareButtonChannel`; `SystemUiChannel` (`startLockTask`, no `PACKAGE_USAGE_STATS`); `StealthIconChannel` (toggles a launcher `<activity-alias>`, not MainActivity); `DeviceInfoChannel` (`getSimPhoneNumber`, `permissionDenied`/`unavailable` codes); `BootReceiver`; `GuardianAngelaAppWidget` RemoteViews. AndroidManifest: all perms/queries/receivers/foreground-service/activity-alias.
- **iOS native channels (Swift)** — `CallStatePlugin` (CXCallObserver); `quick_exit` (`exit 0`) in AppDelegate; `SystemUiPlugin` no-op stubs; `AlarmAudioPlugin`; `GuardianAngelaWidget` WidgetKit extension (iOS17 AppIntents + iOS16 `Link` fallback) + App Group `group.com.guardianangela.shared`; Info.plist usage descriptions + `UIBackgroundModes` (audio/location/fetch/processing, no voip); critical-alerts + App-Group entitlements.
- **Strategy dispatch** — `SessionController._onEngineEvent` now resolves `EventStrategyRegistry.forStep` and runs `executeReal` on `stepStarted` (and `reminderFired` for `disguisedReminder`), **only for real (non-sim) sessions**; failures isolated via `notifyStepExecutionFailed`. One `EventServices` bundle built per session in `startSession`. (Previously NO production session dispatched anything.)
- **Home-screen widget (full stack)** — `home_widget` 0.6.0→0.9.2; `HomeWidgetService` triplet + `homeWidgetServiceProvider`; `publishStatus` on every transition; `HomeScreen` registers the interactivity callback + routes `guardianangela://quick-exit|fake-call`. 6 EN ARB keys translated into all 13 non-EN locales (parity 0 missing).
- **Dependency fix** — `file_picker 3.0.4` used Flutter's removed v1-embedding API → the Android build was already broken (latent because CI never built an APK). Replaced with `file_selector ^1.0.0` (Flutter-team, no `win32` dep) → resolves the `file_picker↔device_info_plus↔win32` conflict. 2 lib call sites + 2 test mocks migrated; no production behaviour change.
- **CI** — added `build-android` (ubuntu, Java 17, `flutter build apk --debug`) + `build-ios` (`macos-latest`, `flutter build ios --no-codesign`).

### `phase-7-fix` (`bde5047`) — verification-cohort fixes
- **Widget Quick Exit now ENDS the session** (was: only routed to `/session`). `guardianangela://quick-exit` → `/session?quickExit=true` (only when active) → `SessionScreen` auto-runs the existing PIN-gated `_endSessionFlow` once (guarded post-frame).
- **Widget elapsed timer** — `_publishWidgetStatus` now passes a snapshot `elapsed` (was always `""`). Documented as an OS-throttled snapshot (not a live tick).
- **SMS `NetworkType.NOT_REQUIRED`** (user-approved) — was `CONNECTED`, which could strand a distress SMS on a cellular-but-no-data device. Spec 05 §SMS Retry Queue corrected.
- **Cleanups** — `file_selector_platform_interface ^2.7.0` dev-dep (drops a `// ignore`); new `device_info_service_test.dart` (7 tests) + `home_widget_routing_test.dart` (6 tests).

---

## CI Triage (DO THIS FIRST on resume)

The push triggered CI run **`26867384330`** (`gh run view 26867384330` / `gh run view 26867384330 --log-failed`). This is the first CI run on the v3 tree; expect first-run failures. KNOWN issues + fixes:

1. **`legacy-id-grep` job WILL FAIL** — `test/domain/configs/loud_alarm_config_test.dart` contains the literals `flashSpeed`/`maxVolume` (it asserts those legacy keys are ABSENT — a legit regression guard), but the blunt CI grep flags them. **Benign false-positive, not a defect.** Fix: rewrite that test to assert the exact `toJson` key-set (no forbidden-token literals) OR scope the gate's `flashSpeed`/`maxVolume` checks to `lib/` only (the intent is "no legacy IDs in code", and tests asserting removal are fine). One small `ci-fix:`/`phase-7-fix:` commit.
2. **`build-ios` (macOS) job — iOS is build-UNVERIFIED locally.** Watch for the iOS agent's flagged risks: (a) `project.pbxproj` GA-prefixed 24-char IDs (`G` is not hex — may need real `uuidgen` IDs); (b) "Embed Foundation Extensions" phase ordering vs Thin Binary; (c) **iOS-17 `AppIntent openAppWhenRun=true` does NOT deliver the `guardianangela://` URL → widget-button deep-link won't route on iOS17** (iOS16 `Link` path works) — known limitation; proper fix = publish a pending-action to the App Group + read on foreground; (d) `FlutterImplicitEngineBridge.pluginRegistry` API vs pinned Flutter 3.41 (original AppDelegate used the same delegate, so likely OK). Triage from the macOS job log; fix iteratively (can only verify via re-push → CI).
3. **`test` (coverage) job — `COVERAGE_FLOOR` is still `0`** (`ci.yml:130`; never ratcheted through phases 1-6; the plan wants 90% by Phase 7). It PASSES at floor 0. **Decision deferred:** measure actual coverage (`flutter test --coverage` + `lcov --summary`), then ratchet the floor to ≤ actual (plan target 90%). If actual < 90%, add tests or set floor=actual with a note. Not a failure — a deliberate gate to raise.
4. **Other never-run-on-v3 jobs** (format / import-sorter / analyze / build-runner / dep-audit / l10n-parity / no-stubs / old-import-gate) — all pass locally; watch the first CI run for environment diffs (esp. `build-runner` stale-`.g.dart` check and `dep-audit` after the `file_selector` swap + the `win32`-free tree).

There are older `failure` CI runs on `origin` from 2026-05-17 (a "V2" push + an ImgBot PR) — unrelated to v3; ignore.

---

## Out-of-scope / carried items

1. 🟡 **iOS-17 widget AppIntent deep-link gap** (CI Triage #2c) — known limitation; fix via App-Group pending-action handoff.
2. 🟡 **Home-widget elapsed timer is a snapshot, not live** — OS-widget constraint; future: publish a start-epoch + native live timer (Android `Chronometer`, iOS `Text(.timer)`).
3. 🟡 **Dead model fields `requireLaunchAuth` + `launchAuthBiometric`** (`AppSettings`) — superseded by `appPinHash`/`appPinBiometricEnabled`; remove in a schema-cleanup pass. Verify first: `grep -rn "requireLaunchAuth\|launchAuthBiometric" lib/ test/`.
4. 🟡 **QA gap-4: Real-side native-channel Dart tests** (`call_state`/`system_ui`/`hardware_button` services have sim-only coverage) — deferred to Phase 9 (Patrol integration on emulator/simulator).
5. 🟡 **Spec doc drifts** (architect-noted, minor): spec 04:2639/2651 reference `lib/services/implementations/home_widget_service.dart` + `guardian_angela_widget.xml`; actual is `lib/services/home_widget_service.dart` + `guardian_angela_app_widget.xml`. Fix the spec when convenient.

---

## Next actions (after CI triage)

**Phase 8 — Localization fan-out.** Per the plan this is the 13-language ARB fan-out — but i18n was **already backfilled** (the 355-key campaign, `fdb85c7`) and this session translated the 6 new widget keys into all 13 locales (parity = 0 missing). So Phase 8 is likely **largely already satisfied**; confirm scope vs `~/.claude/plans/rippling-weaving-puffin.md §Phase 8` (dead-key audit per R-13/14/15/42, parity CI step — already present as `l10n-parity`). May reduce to a verification pass.

Then per the plan: **Phase 9** (integration tests + spec-coverage matrix; close QA gap-4 here), **Phase 10** (manual real-device smoke — this is where the **iOS widget + channels get verified on actual hardware**, incl. the iOS-17 deep-link gap), **Phase 11** (cut-over / GA tag).

---

## Quick verification commands (run after every fix or stage — per Rule 6)

```bash
dart format --output=none --set-exit-if-changed lib/ test/ integration_test/      # 0 changed (CI format gate)
dart run import_sorter:main --no-comments --exit-if-changed                       # Sorted 0 files (excludes OLD/ via pubspec)
flutter analyze --fatal-infos                                                     # 0 issues
flutter test --concurrency=6                                                      # all pass (currently 3692)
flutter build apk --debug                                                         # SUCCESS (Phase-7 native gate; ~40s incremental)
grep -rn 'package:flutter' lib/domain/ lib/services/protocols/ lib/data/          # empty (S-7)
grep -rnE "(Phase 8|Phase 9|Phase 10|Phase 11)" lib/features/                     # 0 (legit refs live in lib/services/)
grep -rn "import.*OLD/" lib/ test/ integration_test/                              # 0 (S-5)
git status --porcelain -- OLD/                                                    # empty (OLD/ untouched)
# S-12 native-channel parity (every lib/ invokeMethod name appears verbatim in a .kt / ios/Runner/*.swift):
python3 - <<'PY'
import re,glob
calls={m.group(1) for p in glob.glob('lib/**/*.dart',recursive=True) for m in re.finditer(r"invokeMethod(?:<[^>]*>)?\(\s*['\"]([^'\"]+)['\"]",open(p).read())}
nat=''.join(open(p).read() for p in glob.glob('android/app/src/main/kotlin/**/*.kt',recursive=True)+glob.glob('ios/Runner/*.swift'))
print('S-12 MISSING:', [c for c in sorted(calls) if c not in nat] or 'NONE')
PY
# ARB parity MISSING check (CI l10n-parity gate). Currently 0/locale:
python3 -c "import json; from pathlib import Path; en={k for k in json.loads(Path('lib/l10n/l10n/app_en.arb').read_text()) if not k.startswith('@')}; [print(a.name,'missing',len(en-{k for k in json.loads(a.read_text()) if not k.startswith('@')})) for a in sorted(Path('lib/l10n/l10n').glob('app_*.arb')) if a.name!='app_en.arb']"
# CI status:
gh run view 26867384330 --log-failed
```

After any `flutter gen-l10n`, re-run `import_sorter` + `dart format` **scoped to `lib/l10n/l10n/`** (gen-l10n emits a different blank-line/import layout; lefthook normalises it on commit anyway).

---

## End-of-session ritual (do this before stopping, every session)

When the user is about to stop — or context fills up — **always run this ritual before the conversation ends**:

1. **Update HANDOFF.md.** Rewrite the snapshot (date, HEAD sha, tests, analyzer, build, push/CI status), refresh the state table, summarise every commit landed this session, refresh "CI Triage" + "Next actions" + the verification-command expectations (test count). Drop obsolete sections. Keep the hard rules + this ritual.
2. **Commit the HANDOFF.md update** (`phase-N-...-handoff: …` + the Co-Authored-By footer).
3. **Tell the user the resume prompt**, printed exactly: `Continue from HANDOFF.md`, including the new HEAD sha.

Don't skip it because "the session went short."

---

End of hand-off. Resume from §"CI Triage", then §"Next actions".
