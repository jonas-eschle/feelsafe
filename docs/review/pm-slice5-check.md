# PM Checkpoint: Slices 1-5

**229 tests pass. 0 failures.** Issues only below.

---

## BUG: ContactFormScreen uses nonexistent API

`lib/features/contacts/contact_form_screen.dart:77` passes `initialValue:` to
`DropdownButtonFormField`. The correct parameter is `value:`. This will fail
at runtime (Flutter assertion error when building the widget).

## BUG: Session screen never navigates to FakeCallScreen

`FakeCallScreen` is registered in the router at `/fake-call`, but nothing in
`SessionScreen` or `SessionController` ever pushes to it. When the engine
fires a fakeCall step, the UI shows the generic "Step N: fakeCall" fallback
text. The `answerFakeCall`/`declineFakeCall`/`hangUp` controller methods are
wired but unreachable from the UI during a real session.

## BUG: Session timer display is static

`_TopBar._fmt()` calls `DateTime.now().difference(session.startTime)` inside
`build()`, but `SessionScreen` is a `ConsumerWidget` that only rebuilds when
`sessionControllerProvider` changes state. There is no periodic ticker, so the
elapsed-time display freezes at whatever value it had on the last state change.
Needs a `Timer.periodic` or `AnimationController` to tick.

## BUG: HoldButton fires both tap AND long-press callbacks

`HoldButton` registers `onTapDown`/`onTapUp` AND `onLongPressStart`/
`onLongPressEnd` on the same `GestureDetector`. A quick tap fires
`onTapDown` then `onTapUp` (holdStart+holdRelease). A long press fires
`onLongPressStart` then `onLongPressEnd` -- but the initial `onTapDown`
also fires first, causing a double `holdStart` call. The engine's
edge-trigger guard absorbs the duplicate, but `holdRelease` via `onTapUp`
will NOT fire for a long press (Flutter treats them as mutually exclusive
after the long-press recognizer wins). This means: short taps work, long
presses work, but the code path is fragile and depends on engine edge guards.

## ISSUE: 26 route names defined, only 7 registered in router

`route_names.dart` defines 26 constants. `app_router.dart` registers 7 routes
(home, session, contacts, contactEdit, onboarding, settings, fakeCall).
Routes like `/modes`, `/profile`, `/past-events`, `/settings/duress-chain`,
etc. are defined but have no GoRoute entry. Navigating to them would throw.

## ISSUE: ContactsController has no `updateContact` method

`contact_form_screen.dart` is add-only. There is no edit flow -- the route
`/contacts/edit?id=` is registered but the screen ignores the `id` query param
entirely. Existing contacts cannot be edited.

## ISSUE: ModesController has no test file

`lib/features/modes/modes_controller.dart` (saveMode, deleteMode) has zero
test coverage.

## ISSUE: SessionOrchestrator not wired into SessionController

`SessionOrchestrator` exists with strategy dispatch logic, but
`SessionController` never instantiates it. The engine's event stream is
consumed only for UI state updates -- no strategies are actually executed
(no SMS, no alarm, no phone call). This is expected for Slices 1-5 but
should be noted for Slice 6.

## PM PREVIOUS ISSUES: Status

- **endSession null-state**: FIXED. `endSession()` sets `state = null`,
  `SessionScreen` detects null and navigates home via `addPostFrameCallback`.
- **Session screen trap**: FIXED. `PopScope(canPop: false)` prevents back,
  `endSession` button is available, null-state redirect works.

## copyWith audit: no bugs found

`AppSettings.copyWith`, `UserProfile.copyWith`, `WalkSession.copyWith`,
`EngineRunning.copyWith` -- all preserve unset fields correctly. Clear-flag
pattern for nullable fields is correct. Tested.

## Summary

| Category | Count |
|----------|-------|
| Bugs (runtime failures) | 3 (DropdownButton API, no fake-call nav, frozen timer) |
| Design gaps | 4 (missing routes, no edit contact, no modes test, orchestrator unwired) |
| Previously reported fixed | 2/2 |
