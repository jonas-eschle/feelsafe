# Guardian Angela v3 — Session Hand-off

**Snapshot:** 2026-05-24 — **Phase 5 formally closed** (3-agent verifier cohort: PM PASS / Architect PASS / qa-expert PASS after 3-4 rounds each). Phase 6 is the next stop.
**HEAD:** `36d30cf` (`phase-5-fix-r3: NEW-1 + NEW-2 — stealth pause and resume-restore tests`).
**Tests passing:** `2447/2447` (`flutter test --concurrency=6`).
**Analyzer:** `0 issues` (`flutter analyze --fatal-infos`).
**Branch:** `main`. **Not pushed.** **OLD/ is INERT** (restored once mid-session after a lefthook accident).

---

## How to resume

After `/clear`, say "Continue from handoff.md" and start from §"Next actions". The plan files in `~/.claude/plans/` (`make-sure-that-there-typed-tulip.md` + `rippling-weaving-puffin.md`) and `docs/rewrite/v3-plan.md` remain the source of truth.

---

## Hard rules (unchanged — applies to every stage going forward)

1. **OLD/ is INERT.** Never read/list/glob/grep/import anything under `OLD/`. If a hook touches it, restore with `git checkout <prior-commit> -- OLD/` — *do not browse the files*. (Happened once mid-Phase-5C; restored cleanly.)
2. **NO STUBS at GA.** All 12 S-NN categories in `~/.claude/plans/make-sure-that-there-typed-tulip.md §NO-STUBS` are CI hard fails.
3. **NO INVENTED DEFERRALS.** "Phase X" comments are legitimate ONLY if the named phase's plan actually scopes the work. The user reinforced this in Phase 5: "Implement EVERYTHING. No bootstrap or similar." See `feedback_no_invented_deferrals.md` in user memory. Grep `lib/` for `"Phase 9 file-picker\|will be available in a future\|coming in Phase\|deferred to Phase"` before every commit; MUST be empty.
4. **DO NOT guess.** Use `AskUserQuestion` for spec ambiguity.
5. **Pre-alpha = break compatibility freely.**
6. **Verify after EVERY fix or stage.** Analyzer + tests + grep gates. Re-engage the same verifier on `FIX_REQUIRED`.
7. **Write/update HANDOFF.md after each phase if tokens exceed 200k.**
8. **Serial default; parallel only at sanctioned points.** Phase 5 was solo per the plan. Verifier cohorts (architect + qa + nostubs/PM) ran in parallel (disjoint write surfaces). Phase 6 has a parallel widget+golden test cohort AFTER the screens land.
9. **Co-Authored-By footer:** `Claude Opus 4.7 <noreply@anthropic.com>`.
10. **Pure Dart in `lib/domain/`, `lib/services/protocols/`, `lib/data/`.**

---

## Current state at a glance

| Phase | Status | Tests | Commits |
|---|---|---|---|
| Pre-flight (spec rework + 20 gaps + DE-N + Hive→Drift) | ✅ Done | — | `40d9add` + 6 fix commits |
| Phase 0 (flutter create + CI + day-1 Sentry + OLD/ extractions) | ✅ Done | 9 | `ca4343a`, `5608102`, `7f63e73` |
| Phase 1a/1b (domain models + 994 tests) | ✅ Done | 1003 | `d797697`–`7157883` |
| Phase 2 (pure-Dart SessionEngine) | ✅ Done | 1161 | `fb4ce10`–`c7e8774` |
| Phase 3 (Event Strategies + 9 protocols) | ✅ Done | 1581 | `f9bc996`–`03287d1` |
| Phase 4 (Repositories + Drift schema + seed data) | ✅ Done | 1711 | `4969161`–`8cedc2c` |
| **Phase 5 (services + Sentry + wiring map)** | ✅ **Done — 3-agent cohort PASS** | **2447** | `5b0bd02`..`36d30cf` (18 commits) |
| Phase 6..11 | Pending |  |  |

---

## What Phase 5 delivered (commits `5b0bd02..36d30cf`, 18 commits)

### Service layer

- **21 service triplets** under `lib/services/`: protocol + Real impl + Simulation impl + tests for each. Real impls wrap pub plugins (`just_audio`, `geolocator`, `vibration`, `wakelock_plus`, `torch_light`, `record`, `flutter_contacts`, `flutter_local_notifications`, `battery_plus`, `flutter_background_service`, `sentry_flutter`, `url_launcher`, `share_plus`, `permission_handler`, `local_auth`) and custom Guardian Angela `com.guardianangela.app/*` MethodChannels for SMS/CallState/SystemUi/HardwareButton/DeviceState (Phase 7 native side pending).
- **Single wiring owner** at `lib/services/service_providers.dart`. CI grep gate enforces no `Real*Service(` constructor calls outside the file (+ declaring class).
- **Wiring map** at `docs/wiring-map.md` with one row per Riverpod provider; bidirectional consistency tested by `test/wiring/wiring_map_coverage_test.dart`.
- **Pre-flight contract test** `test/wiring/simulation_swap_test.dart`: every provider can be overridden with its Simulation impl. The smoking-gun test v2 lacked.

### Bootstrap pipeline

- `lib/main.dart` 7-step pipeline (extracted into `runBootstrap(container, runner)` for testability): open encrypted DB → load AppSettings → init Sentry per `AppSettings.sentryEnabled` (D2 — opt-in, EU host enforced via `endsWith('.ingest.de.sentry.io')`) → purge expired session logs per `AppSettings.sessionLogRetentionDays` → init notification channels → kick off TTS voice bootstrap (unawaited) → `runApp`.
- `JsonRecoveryApp` for Extra-21 (spec 10:206): "Start fresh" deletes `json_store/`; "Restore from backup" uses `file_picker` + `BackupService.importFromJson`.
- `databaseProvider` is a `FutureProvider` that opens the encrypted Drift DB via `EncryptionService.openEncryptedDatabase` (sqlite3mc PRAGMA key derived from `flutter_secure_storage`).

### Strategy wiring (Phase-5 round-2 fix updates Phase-3 strategies)

- `DisguisedReminderStrategy.executeReal` now invokes `notification.showDisguisedReminder` (was no-op).
- `FakeCallStrategy.executeReal` calls `audio.playRingtone` + `vibration.fakeCallPattern` + `notification.showAlarmEscalation`.
- `LoudAlarmStrategy.executeReal` calls `notification.showAlarmEscalation`.
- `CallEmergencyStrategy.executeReal` calls `notification.showAlarmEscalation`.

### Platform manifest / entitlements

- `android/app/src/main/AndroidManifest.xml`: added `USE_FULL_SCREEN_INTENT` permission + `<queries>` block for WhatsApp + Telegram URI scheme checks.
- `ios/Runner/Runner.entitlements` (new): `com.apple.developer.usernotifications.critical-alerts = true` wired into project.pbxproj Debug + Release.

### Verifier round summary

- Round 1 (initial impl) returned PM:FIX (1) + architect:FIX (14) + qa:FIX (13). Closed in `phase-5-fix-round1` commit (`8bf5adc`).
- Round 2 returned PM:PASS + architect:FIX (5) + qa:FIX (6 + 3 side-checks). Closed across 6 commits ending at `d5f22d0`.
- Round 3 returned architect:PASS (advisory spec patch only) + qa:FIX (3 test-only). Closed across 3 commits ending at `36d30cf`.
- Round 4 (qa-only) returned PASS. Phase 5 closed.

---

## Open issues / known drift (non-blocking, pre-accepted)

The Phase 4 known-drift list 1–13 carries forward. New Phase 5 items:

14. **`file_picker: any` pin** in `pubspec.yaml`. Resolved to `3.0.4` (2021). Transitive constraints block newer majors; re-pin once permission_handler etc support `file_picker ^10.x`.
15. **`_AppShell` placeholder splash in `lib/main.dart`** — Phase 6 GoRouter + 24 screens replaces. CI re-checks NO-STUBS after Phase 6 commit.
16. **`_builtInVoicePrompts` hardcoded map** in `lib/services/audio_service.dart` — has the 14 real translated strings; Phase 8 ARB scrum migrates to `AppLocalizations.fakeCallVoicePromptDefault`. Functional now.
17. **`VibrationServiceProtocol.confirmPulse`** — wired by Phase 6 confirm-action UI per plan §Phase 6 (one-line comment in protocol).
18. **Phase 7 native counterparts pending:** `com.guardianangela.app/sms`, `.../call_state`, `.../system_ui`, `.../hardware_button`, `.../device_state`. Dart side calls them; Kotlin/Swift land in Phase 7.

---

## Next actions (resume here)

**Phase 6 — Screens, routing, deceptive PIN dialog (SOLO, SEQUENTIAL → then parallel test cohort).**

Per `~/.claude/plans/rippling-weaving-puffin.md` §Phase 6 (line ~161):

- **Agent:** `voltagent-lang:flutter-expert` (single owner for `app_router.dart`, controller reads, ARB keys).
- **Scope:** 24 screens per `docs/spec/04-screens-navigation.md`. `GoRouter` with named routes (route names enum already exists at `lib/core/constants/route_names.dart` — Phase 0). First-launch detection. Deceptive "Old PIN entered" dialog per D3 (R-42 restoration). `EmergencyConfirmScreen` with countdown. Session-Interrupted prompt per Extra-13. 3-screen onboarding with `ContactFormScreen` on page 2. Replace `_AppShell` placeholder in `lib/main.dart` with the real `GuardianAngelaApp` shell.
- **Test cohort (parallel, AFTER screens land):**
  - 24 widget-test agents (one per screen, `test/features/<screen>/<screen>_screen_test.dart`, ≥ 25 tests per file).
  - 6 golden-test agents for visual-critical screens (home, session, fake_call, distress_confirmation, onboarding, settings) × 3 variants (light, dark, RTL).
  - Pre-flight contract: ARB keys finalized, controller method signatures stable, route names enum frozen BEFORE test fan-out.
- **Verification target:** `lib/features/**` coverage ≥ 99% (D6 strict gate).
- **Commits:** `phase-6: screens + routing + R-42 deceptive PIN`; then `phase-6-tests: 24 widget tests + 6 goldens`.
- **3-agent verification cohort** after the test commit.

### Reading list for Phase 6 dispatch

- `docs/spec/04-screens-navigation.md` — 24 screens + routes.
- `docs/spec/06-settings.md` — per-setting spec, Sentry gate UI, AppSettings field semantics.
- `lib/core/constants/route_names.dart` — pre-existing route names enum.
- `lib/router/app_router.dart` — does NOT yet exist; Phase 6 creates.
- `lib/services/service_providers.dart` — the wiring graph the screens consume.
- `lib/main.dart` — `_AppShell` is the placeholder Phase 6 replaces.

---

## Quick verification commands (run after every fix or stage — per Rule 6)

```bash
flutter analyze --fatal-infos                          # 0 issues
flutter test --concurrency=6                           # all pass (currently 2447)
grep -r 'package:flutter' lib/domain/                  # must be empty (S-7)
grep -r 'package:flutter' lib/services/protocols/      # must be empty (S-7)
grep -r 'package:flutter' lib/data/                    # must be empty (S-7)
grep -rEn 'UnimplementedError|throw .TODO|TODO|FIXME|XXX|HACK|Container\(\)|Placeholder\(\)' lib/    # only ProviderContainer() in main.dart (Riverpod, allowed)
grep -rn "Phase 9 file-picker\|will be available in a future\|coming in Phase\|deferred to Phase" lib/    # 0 (NEW gate after user reinforcement)
grep -rEn 'class DistressChain|repeatCount|leapToNextEvent|LoudAlarmSound\.(beep|whistle|scream|whoop)|SmsRecipient|flashSpeed\b|maxVolume\b|Hive\b|@HiveType|@HiveField|PauseReason\.bootRestart|EndReason\.appTermination|fakeCallAnswered' lib/ test/ integration_test/   # 0 (S-4)
grep -rn "import.*['\"].*OLD/" lib/ test/ integration_test/   # 0 (S-5)
git diff-tree -r --name-only HEAD -- OLD/              # empty (OLD/ untouched)
grep -rn 'Real.*Service(' lib/ | grep -v service_providers.dart | grep -v 'lib/services/[^/]*_service\.dart:.*class Real'  # only class-declaration lines
```

**All currently pass at HEAD `36d30cf`.**

---

## Files / paths for the resumer

- **Plans:** `~/.claude/plans/make-sure-that-there-typed-tulip.md`, `~/.claude/plans/rippling-weaving-puffin.md`, `docs/rewrite/v3-plan.md`, `docs/rewrite/lessons-learned.md`.
- **Spec (12 files):** `docs/spec/00-overview.md` … `docs/spec/11-deferred-enhancements.md`. Phase 5 patched `05:81` (Q19 alarmDndOverride default false) and `03:254` (Phase 4 built-in template list).
- **Phase 5 service layer:**
  - `lib/services/service_providers.dart` — SINGLE wiring owner; 21+ Riverpod providers.
  - `lib/services/protocols/*.dart × 22` — abstract interfaces.
  - `lib/services/<service>.dart × 21` — Real impls.
  - `lib/services/sim/<service>_sim.dart × 21` — Simulation impls.
  - `lib/services/_phone_number_utils.dart` — shared sanitiser.
  - `docs/wiring-map.md` — provider inventory.
  - Tests: `test/services/*.dart × 21`, `test/wiring/{simulation_swap,wiring_map_coverage}_test.dart`, `test/main_bootstrap_test.dart`.
- **Phase 5 main.dart:** `lib/main.dart` — 7-step `runBootstrap` + `_AppShell` placeholder + `JsonRecoveryApp`.

End of hand-off. Resume from §"Next actions".
