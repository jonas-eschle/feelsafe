# PM Slice 2 Checkpoint

**Date:** 2026-04-10 | **Tests:** 173 passing | **Lib files:** 102 | **TODOs in lib:** 1

---

## 1. Slice Completion Status

**Slice 1 (Core Session):** COMPLETE. Engine, controller, session screen,
hold button, slider, home screen, modes controller, settings controller
all wired. No stubs, no TODOs.

**Slice 2 (Contacts + SMS Strategy):** MOSTLY COMPLETE. Three gaps:

- **No edit flow.** `ContactFormScreen` is add-only. No `updateContact()`
  method on `ContactsController`. Route is `/contacts/edit` but there is
  no query-param `id` handling to load an existing contact.
- **Home screen does not display contacts.** The previous PM report
  cited "contact preview" on the home screen as functional, but the
  current `HomeScreen` only has a navigation icon to the contacts list.
  No contact count badge, no "0 contacts" warning, no preview cards.
  A user can start a real session with zero contacts and get no warning
  from the UI (the `SessionValidator` catches it, but nothing calls
  `validate()` before `startSession`).
- **SMS strategy not wired to contacts.** The `SmsContactStrategy`
  exists in `lib/domain/orchestration/strategies/` but the
  `SessionController` does not use the orchestrator. The controller
  forwards engine methods but never invokes strategy execution on
  step events. SMS "sending to contacts" does not happen even in
  simulation mode.

## 2. SessionController State Sync

- **endSession does not null state.** After `endSession()`, `state`
  remains a non-null `WalkSession` with `phase == completed`. The
  engine and subscription are disposed, but the UI still sees a session.
  Next `startSession()` overwrites it, so no crash -- but stale state
  leaks into anything that reads `sessionControllerProvider`.
- **Session screen traps user.** `PopScope(canPop: false)` prevents
  back-navigation. After "End Session", the screen shows "Session
  Complete" with no way to return home. No `context.go(RouteNames.home)`
  on end.
- **_syncState is good.** Hold/release/fakeCall actions correctly
  push state to UI outside the event stream. No issues found there.

## 3. Tests Quality (173 cases)

All 173 are meaningful -- no placeholders, no `expect(true, isTrue)`.
Breakdown of new tests since last PM report (41 new cases):

| File | Cases | Quality |
|------|-------|---------|
| contacts_controller_test | 5 | Good: CRUD + reorder |
| session_controller_test | 9 | Good: lifecycle + phase transitions via fakeAsync |
| session_validator_test | 7 | Good: error/warning/simulation leniency |
| event_strategy_registry_test | 3 | Good: lookup + missing + exhaustive |
| session_context_test | 3 | Good: placeholder resolution + fallbacks |
| user_profile_test | 6 | Good: medical info + copyWith + clear flags |
| location_point_test | 2 | OK: toMapsUrl only |
| country_detector_test | 8 | Good: countries + case + fallback |
| pin_utils_test | 7 | Good: hash + verify + salt + malformed |

**Gap:** No test for `ContactFormScreen` widget (form validation,
save-and-pop behavior). No test for `ContactsScreen` (tap-delete,
FAB navigation).

## 4. Prior Bugs Status (BUG-1 through BUG-10)

| Bug | Status | Notes |
|-----|--------|-------|
| BUG-1 (P0) SMS channel mismatch | UNFIXED | Kotlin: `guardianangela/sms`, no Dart file references it (service_providers.dart removed) |
| BUG-2 (P0) HW button channel mismatch | UNFIXED | Kotlin: `volume_buttons`, no Dart file references it |
| BUG-3 (P1) Validator severity | FIXED | Now correctly uses `IssueSeverity.error` for real sessions |
| BUG-4 (P1) SmsWorker NetworkType | UNFIXED | `NetworkType.CONNECTED` still present in SmsWorker.kt:59 |
| BUG-5 (P1) Unused packages | NOT CHECKED | pubspec not reviewed this pass |
| BUG-6 (P2) Sub-chain no-op | UNFIXED | Still `// TODO: Execute sub-chain steps sequentially.` at engine:311 |
| BUG-7 (P2) FakeCall buttons | N/A | FakeCallScreen removed from router (Slice 5 scope) |
| BUG-8 (P2) Localization not wired | PARTIALLY FIXED | app.dart has GlobalMaterial delegates, but NOT AppLocalizations delegates. Only `en` supported. No screen uses l10n strings. |
| BUG-9 (P2) main.dart hardcodes isFirstLaunch | FIXED | main.dart now simply boots, no hardcoded flag |
| BUG-10 (P3) Fakes only | EXPECTED | Per CONTRACT.md Rule 4: fakes until Slice 6 |

## 5. Architecture Issues

- **No orchestrator integration.** `SessionController` owns the engine
  but does NOT create or use `SessionOrchestrator`. Engine events fire
  but no strategy executes. The strategy layer is dead code.
- **No validator call before session start.** `HomeScreen.startSession`
  goes straight to `controller.startSession(mode)` without validation.
  User can start a real session with 0 contacts and 0 permissions.
- **service_providers.dart deleted.** The previous codebase had 11
  Riverpod providers for services. Now gone. No service injection
  mechanism exists. This is fine for Slice 1-2 (no services needed)
  but means Slice 6 has more wiring work than anticipated.

## 6. Slice 3 (Onboarding) Watch-outs

1. **isFirstLaunch detection.** Currently no persistence. Onboarding
   requires `SettingsController` to persist `isFirstLaunch: false` --
   but persistence is Slice 4. Either add minimal Hive init in Slice 3
   or use in-memory flag (onboarding shows every cold launch).
2. **Profile controller missing.** Onboarding page 2 needs to save
   user name + first contact. `ProfileController` does not exist yet.
   `ContactsController` exists and works.
3. **Permissions page.** No `PermissionServiceProtocol` exists.
   Onboarding page 3 needs to request POST_NOTIFICATIONS, location,
   phone, SMS. Either add a minimal permission wrapper or stub the
   page with "grant later" messaging.
4. **Router redirect.** `app_router.dart` currently has no first-launch
   redirect. Need to add `redirect:` that checks settings and routes to
   `/onboarding` on first launch.
5. **Localization.** Onboarding strings will be hardcoded English per
   current pattern. That's fine -- l10n wiring is Slice 9.

## 7. Action Items (Priority Order)

1. **Wire navigation out of session screen** after end/exhaust (P0 UX)
2. **Add validate-before-start** on home screen start button (P1 safety)
3. **Add `updateContact()` to ContactsController** + edit flow (P1 Slice 2 gap)
4. **Fix SmsWorker NetworkType.CONNECTED** (P1 one-line fix, pre-existing)
5. **Null out `state` in endSession** or handle stale session in home (P2)
6. **Add contact summary to home screen** -- at minimum "N contacts" (P2)
