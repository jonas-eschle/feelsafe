# Final Correctness Audit -- Guardian Angela Codebase

Auditor: Claude Opus 4.6 (1M context)
Date: 2026-04-10
Scope: Every file in `lib/` and `test/`
Files reviewed: 120+ Dart source files, 6 Kotlin native files

---

## CRITICAL Severity

### C-1. Missing AppLocalizations delegate -- app will crash on any l10n call

**File:** `lib/app.dart`, lines 32-35
**What:** The `localizationsDelegates` list includes `GlobalMaterialLocalizations.delegate`,
`GlobalWidgetsLocalizations.delegate`, and `GlobalCupertinoLocalizations.delegate` but does
NOT include `AppLocalizations.delegate` from the generated l10n. Any call to
`AppLocalizations.of(context)` will return `null` and the `!` assertion on line 82 of
`app_localizations.dart` will throw a null assertion error at runtime.
**Impact:** If any screen ever calls `AppLocalizations.of(context)`, the app crashes. The
generated localizations class has a `delegate` static constant that must be registered.
**Fix:** Add `AppLocalizations.delegate` to the `localizationsDelegates` list in `app.dart`:
```dart
import 'l10n/l10n/app_localizations.dart';
// ...
localizationsDelegates: const [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
```

### C-2. Compile error: DropdownButtonFormField uses non-existent `initialValue` parameter

**File:** `lib/features/contacts/contact_form_screen.dart`, line 68
**What:** `DropdownButtonFormField` does not have an `initialValue` named parameter. The correct
parameter is `value`. This is a compile error -- the app cannot build as-is.
**Fix:** Change `initialValue: _channel` to `value: _channel`.

### C-3. Incoming call auto-resume never fires -- Kotlin emits "idle" but Dart expects "ended"

**File:** `lib/services/implementations/incoming_call_service.dart`, line 35 vs
`android/.../CallStateChannel.kt`, line 70
**What:** The Kotlin native side maps `CALL_STATE_IDLE` to the string `"idle"`. However, the
Dart `IncomingCallService` maps `"idle"` to `CallState.idle`, and `"ended"` to `CallState.ended`.
The `SessionController` (line 219) only resumes the engine when `callState == CallState.ended`.
Since the Kotlin side never emits `"ended"`, the engine will auto-pause on an incoming call
but NEVER auto-resume when the call ends. The session becomes permanently stuck in paused state.
**Impact:** After any real incoming phone call, the safety session is permanently paused --
the user's dead-man's-switch stops working silently.
**Fix:** Either:
- (A) Map `"idle"` to `CallState.ended` in Dart (since TelephonyManager transitions
  back to IDLE after a call), or
- (B) Have `SessionController` resume on `CallState.idle` as well, or
- (C) Emit `"ended"` from Kotlin when transitioning from non-idle to idle.

### C-4. Engine resume() does not restore `_awaitingFirstTouch` from snapshot

**File:** `lib/domain/engine/session_engine.dart`, lines 296-310
**What:** The `resume()` method restores `_stepIndex`, `_missCount`, `_isHolding`, and `_phase`
from the pause snapshot, but does NOT restore `_awaitingFirstTouch`. If the engine was paused
while waiting for the user's first touch on a hold-button step, resuming will leave
`_awaitingFirstTouch` as `false` (its default after any disarm/advance), causing the engine
to skip the "awaiting first touch" state and behave incorrectly.
**Fix:** Add `_awaitingFirstTouch = snapshot.isAwaitingFirstTouch;` after line 302.

---

## HIGH Severity

### H-1. Session controller `_onEvent` does not await orchestrator's async `handleEvent`

**File:** `lib/features/session/session_controller.dart`, line 285
**What:** `_orchestrator?.handleEvent(event)` is called without `await`, but `handleEvent` is
`Future<void>`. The event handler `_onEvent` is a synchronous `void` callback passed to
`stream.listen()`. Since the orchestrator's `handleEvent` is async (it awaits strategy
execution like sending SMS, making calls), all real-world strategy execution is fire-and-forget.
Exceptions from strategies will become unhandled Future errors that crash the app (or are
silently lost depending on zone error handling).
**Impact:** Strategy execution errors (SMS failures, call failures) will not be caught by the
orchestrator's try-catch because the Future is dropped. In production, this could cause
unhandled async errors.
**Fix:** The orchestrator's try-catch already wraps the `executeReal` call, so exceptions
within the Future are handled. However, if the orchestrator's `handleEvent` itself throws
before reaching the try-catch, those errors are lost. Consider wrapping the call:
```dart
_orchestrator?.handleEvent(event).catchError((e) {
  log('Orchestrator error: $e');
});
```

### H-2. `reorderContacts` does not update `sortOrder` field -- order lost on restart

**File:** `lib/features/contacts/contacts_controller.dart`, lines 75-85
**What:** `reorderContacts` reorders the in-memory list and persists all contacts, but each
`EmergencyContact` retains its original `sortOrder` value. When the app restarts and loads
contacts from Hive, `JsonListRepository.getAll()` iterates `box.values` (Hive insertion order),
but Hive `Box.values` order is by key (ID), not insertion order. The contacts will appear in
arbitrary order on restart.
**Fix:** Create new `EmergencyContact` objects with updated `sortOrder` values before persisting:
```dart
state = [
  for (var i = 0; i < list.length; i++)
    EmergencyContact(
      id: list[i].id,
      name: list[i].name,
      phoneNumber: list[i].phoneNumber,
      // ... all fields ...
      sortOrder: i,
    ),
];
```
Also add sorting by `sortOrder` in the `_loadFromRepo` method.

### H-3. Constant-time PIN comparison is defeated by early length check

**File:** `lib/core/utils/pin_utils.dart`, lines 36-37
**What:** `_constantTimeEquals` returns `false` immediately if string lengths differ (line 37).
This leaks hash length information via timing, partially defeating the constant-time guarantee.
In practice, `hashPin` produces fixed-length SHA-256 output, so the salt+hash string length
is always `24 (base64 salt) + 1 (colon) + 64 (hex SHA-256)` = 89 characters. So both inputs
to `_constantTimeEquals` should always have equal length in the `verifyPin` flow. However,
if `storedHash` is corrupted or from a different version, the timing leak applies.
**Impact:** Low practical impact since hash lengths are fixed, but violates the stated security
guarantee. If schema changes alter hash format, a timing side-channel appears.
**Fix:** Pad shorter string to match longer string length before comparison, or hash both
inputs to a fixed length before comparing.

### H-4. `endSession` on `EngineIdle` emits events and closes stream with invalid state

**File:** `lib/domain/engine/session_engine.dart`, lines 109-119
**What:** `endSession()` only checks for `EngineEnded` before proceeding. If the engine is in
`EngineIdle` state (not started yet), it will: cancel timers (no-op), clear sub-chain state
(no-op), transition to `EngineEnded`, emit `sessionEnded` event with `currentStep == null`,
and close the stream controller. This means calling `endSession` before `start()` works but
emits a spurious `sessionEnded` event with no meaningful data, and permanently closes the
stream, making the engine unusable.
**Fix:** Add an `EngineIdle` guard: `if (_state is EngineEnded || _state is EngineIdle) return;`

### H-5. `NotificationService.scheduleNotification` uses unawaited `Future.delayed` -- fire-and-forget with no cancellation

**File:** `lib/services/implementations/notification_service.dart`, lines 109-128
**What:** `scheduleNotification` starts a `Future.delayed` but does not store the Future or
provide any way to cancel it. The returned notification ID only allows cancelling the
notification *after* it appears, not the pending scheduled show. If the session ends before
the delay completes, the notification still fires. Also, the `Future.delayed` runs in the
main isolate and will not survive process death.
**Impact:** Scheduled notifications may appear after a session has ended, confusing users.
**Fix:** Use `flutter_local_notifications` `zonedSchedule` API for proper scheduling, or
store the Timer/Completer for cancellation.

### H-6. Multiple sub-chain queue entries not size-bounded

**File:** `lib/domain/engine/session_engine.dart`, line 64
**What:** `_subChainQueue` has no size limit. If triggers fire repeatedly (e.g., battery
low fires multiple times despite the `_fired` guard, or wrong-PIN sub-chains are triggered
repeatedly), the queue grows unbounded.
**Impact:** Memory leak under repeated trigger conditions. Unlikely in practice but
architecturally incorrect.
**Fix:** Add a maximum queue size (e.g., 10) and drop oldest entries, or prevent duplicate
sub-chain types from being queued.

---

## MEDIUM Severity

### M-1. `FakeCallScreen` does not use `isSimulation` from session state

**File:** `lib/features/fake_call/fake_call_screen.dart`, lines 17-18
**What:** `FakeCallScreen` has `callerName` and `isSimulation` constructor parameters with
defaults, but neither is passed from the router. The `isSimulation` is always `false` (default),
and `callerName` is always `'Angela'`. The actual session's simulation state and the
configured caller name from `FakeCallConfig` are not read.
**Fix:** Read simulation state from `sessionControllerProvider` and caller name from the
current step's `FakeCallConfig` inside the `build` method.

### M-2. `SessionScreen` pushes to fake call screen every frame rebuild during fakeCall step

**File:** `lib/features/session/session_screen.dart`, lines 47-52
**What:** When a fakeCall step is active, the `build` method schedules a `context.push` via
`addPostFrameCallback`. But `build` is called on every state change, and since the session
state still shows `stepActive + fakeCall` after the push, each rebuild schedules another push.
This will push the fake call screen multiple times onto the navigation stack.
**Fix:** Add a guard flag or use `ref.listenManual` to navigate only once when the step
first becomes active, not on every rebuild.

### M-3. `GoRouter.redirect` creates infinite onboarding redirect

**File:** `lib/router/app_router.dart`, lines 36-39
**What:** The redirect checks `state.matchedLocation != RouteNames.onboarding` but
`isFirstLaunch` is captured at app startup and never updated. After the user completes
onboarding and `markOnboardingComplete()` sets `isFirstLaunch = false` in settings, the
router still holds the original `isFirstLaunch = true` value. Every navigation to any
non-onboarding route will redirect back to onboarding until the app is restarted.
**Fix:** Make the router reactive to settings changes, or rebuild the router after onboarding
completes by using a `ref.watch` pattern, or at minimum re-read the setting in the redirect.

### M-4. `_TopBar._ticker` stream is never cancelled on widget disposal

**File:** `lib/features/session/session_screen.dart`, line 229
**What:** `Stream<void>.periodic(...)` creates a stream that emits events indefinitely.
While `StreamBuilder` manages its own subscription, the underlying periodic timer within
the stream factory continues to exist as long as the `_TopBarState` exists. The `_TopBar`
is a `StatefulWidget` so the timer lives with the state. This is technically fine because
`StreamBuilder.dispose()` cancels the subscription, and `Stream.periodic` only creates
events when listened to. No actual leak.
**Verdict:** FALSE POSITIVE -- `Stream.periodic` is lazy; no leak.

### M-5. `HiveBoxes.initForTesting` is not `@visibleForTesting`

**File:** `lib/data/hive_boxes.dart`, lines 56-60
**What:** The method has a comment `// ignore: invalid_use_of_visible_for_testing_member`
but the method itself is NOT annotated with `@visibleForTesting`. It is public API accessible
from production code. Any code could call `initForTesting` and replace the encryption key
with a hardcoded test key, breaking encryption.
**Fix:** Add `@visibleForTesting` annotation to `initForTesting`.

### M-6. `SmsContactConfig.contactIds` filtering silently drops to all contacts

**File:** `lib/domain/orchestration/strategies/sms_contact_strategy.dart`, lines 44-46
**What:** When `config.contactIds` is set, the strategy filters contacts by ID. If ALL
referenced contacts have been deleted, `targets` becomes empty and the method returns early
(line 48). This means the SMS step silently does nothing -- no contacts are notified. The
`SessionValidator` only warns about this, not errors.
**Impact:** If a user configures specific contacts for an SMS step, then deletes those
contacts, the step silently skips during a real emergency. The session log would show the
step started but no messages were sent.
**Fix:** Either fall back to all contacts when filtered list is empty, or make the validator
treat this as an error (not warning).

### M-7. Seed data generates new UUIDs on every call -- built-in modes get new step IDs each launch

**File:** `lib/data/seed_data.dart`, lines 13-68
**What:** `seedWalkMode()` and `seedDateMode()` use `_uuid.v4()` to generate chain step IDs.
These functions are called in `ModesController.build()` (line 17) as the initial state, and
also in `_loadFromRepo()` when the repo is empty. Since `build()` creates new UUIDs for the
default state, and `_loadFromRepo()` creates DIFFERENT UUIDs when seeding the repo, the
in-memory modes and persisted modes have different step IDs. This causes the `indexWhere`
in `saveMode` to potentially not match modes correctly.
**Impact:** Generally low -- the mode IDs are fixed strings, and step IDs are only used for
internal tracking. But it creates unnecessary inconsistency.
**Fix:** Use deterministic UUIDs (e.g., `uuid.v5(Uuid.NAMESPACE_URL, 'walk-step-0')`) for
built-in modes.

### M-8. `SettingsController.build()` returns default `AppSettings` before async load completes

**File:** `lib/features/settings/settings_controller.dart`, lines 13-18
**What:** `build()` synchronously returns `const AppSettings()` and then calls `_loadFromRepo()`
async. Between `build()` returning and the async load completing, the app renders with default
settings (e.g., `isFirstLaunch: true`, `languageCode: 'en'`). This causes a brief flash of
incorrect state on app startup. The same pattern exists in `ContactsController`,
`ProfileController`, `ModesController`, and all sub-chain controllers.
**Impact:** Flicker on startup; theme may flash from dark to whatever is saved. Also,
`main.dart` creates a SEPARATE `JsonSingletonRepository` to read settings (line 23-30),
creating a second Hive box instance for the same data.
**Fix:** Consider using `AsyncNotifierProvider` or `FutureProvider` for the initial load, or
await the load before creating the router.

### M-9. `SessionContext.locationUrl` is captured once at session start and never updated

**File:** `lib/features/session/session_controller.dart`, line 93
**What:** `locationUrl: location.getLastLocationUrl()` captures the location URL at session
start time. All SMS messages throughout the session will include this initial location, not
the user's current location at the time the SMS is actually sent. For Walk Mode where the
user is moving, the emergency contacts receive stale location data.
**Fix:** Make `SessionContext.locationUrl` a getter that reads from the location service, or
update the context before each strategy execution.

### M-10. `_handleRepeatPress` removes current press after adding it

**File:** `lib/services/implementations/hardware_button_service.dart`, lines 84-99
**What:** `_handleRepeatPress` adds `now` to `_pressTimes` (line 84), then immediately removes
all entries where `now.difference(t).inMilliseconds > _windowMs` (lines 87-90). Since the
difference between `now` and `now` is 0ms, the current press survives. However, the removal
check uses `>` (strict), so if exactly `_windowMs` milliseconds have passed, the press
survives. This means the detection window is actually `_windowMs + 1ms` in the worst case.
**Verdict:** Negligible impact -- 1ms timing difference is irrelevant.

### M-11. `StepConfig.toJson` uses `runtimeType.toString()` which can differ across obfuscation

**File:** `lib/domain/models/step_config.dart`, line 13
**What:** `runtimeType.toString()` is used as the type discriminator in JSON serialization.
If Dart tree-shaking or obfuscation (e.g., in release builds with `--obfuscate`) renames
classes, `runtimeType.toString()` will return the obfuscated name, making serialized JSON
unreadable. Backup/restore would break across obfuscated and non-obfuscated builds.
**Fix:** Use explicit string constants for each subclass type name instead of `runtimeType`.

---

## LOW Severity

### L-1. `HiveTypeIds` registry is unused -- all boxes use JSON strings

**File:** `lib/data/adapters/hive_type_ids.dart`
**What:** The file defines Hive type IDs 0-19, but no TypeAdapters are registered
(`register_adapters.dart` is empty). All boxes use `Box<String>` with JSON serialization.
The type ID file is dead code that could mislead developers into thinking custom adapters
exist.
**Fix:** Remove `hive_type_ids.dart` or add a comment that it is reserved for future use.

### L-2. `ListRepository` and `SingletonRepository` are unused

**Files:** `lib/data/repositories/list_repository.dart`, `lib/data/repositories/singleton_repository.dart`
**What:** These generic `Box<T>` repositories are defined but never used. All actual
repositories use `JsonListRepository` and `JsonSingletonRepository` (which use `Box<String>`).
**Fix:** Remove the unused files.

### L-3. `registerHiveAdapters()` is defined but never called

**File:** `lib/data/adapters/register_adapters.dart`
**What:** The function exists as a no-op placeholder but is never imported or called anywhere,
including `main.dart`.
**Fix:** Remove, or call it from `main.dart` if it will be needed later.

### L-4. `json_adapter.dart` utility functions are unused

**File:** `lib/data/adapters/json_adapter.dart`
**What:** `toJsonString()` and `fromJsonString()` functions are defined but never imported
or used. All JSON encoding/decoding is done directly with `jsonEncode`/`jsonDecode` in the
repository classes.
**Fix:** Remove the file.

### L-5. `EventDefaultsScreen` navigation does nothing

**File:** `lib/features/settings/event_defaults_screen.dart`, line 20
**What:** The `onTap` callback for each step type's `ListTile` is empty -- no navigation
occurs when tapped.
**Fix:** Wire up navigation to the detail editor route.

### L-6. `PastEventsScreen` does not load from repository

**File:** `lib/features/history/past_events_screen.dart`
**What:** Shows a static "No past sessions yet" message. No `ref.watch` on the session logs
repository. The completion screen records logs via `SessionLogRecorder` but never persists
them to the `sessionLogsRepoProvider`.
**Fix:** Add a controller that loads/saves session logs.

### L-7. Missing `const` on `ChainStep` constructor

**File:** `lib/domain/models/chain_step.dart`, line 42
**What:** `ChainStep` constructor is not `const`, even though all fields are `final`. Since
`config` is nullable and `StepConfig` subclasses have `const` constructors, `ChainStep` could
be `const`. This prevents const chain steps in seed data (currently constructs new objects
each call).
**Fix:** Add `const` to the constructor.

### L-8. `onboarding_screen.dart` permission buttons are no-ops

**File:** `lib/features/onboarding/onboarding_screen.dart`, lines 216-218
**What:** The "Grant" buttons in the permissions page do nothing -- the `onPressed` callback
is empty with a comment "Permission requests wired in Slice 6."
**Fix:** Wire up `permission_handler` calls.

### L-9. `_TopBar._fmt` only shows minutes and seconds, drops hours

**File:** `lib/features/session/session_screen.dart`, lines 257-261
**What:** The elapsed time formatter uses `d.inMinutes.remainder(60)` and
`d.inSeconds.remainder(60)`, displaying only MM:SS. For sessions longer than 60 minutes
(very possible in Date Mode with 30-minute intervals), the display wraps around, showing
"00:30" again after 60 minutes.
**Fix:** Include hours: `'${d.inHours}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'`

### L-10. `_DecoyScreen` shows hardcoded "Calculator" text

**File:** `lib/core/utils/quick_exit.dart`, line 51
**What:** The decoy screen always shows "Calculator" regardless of locale or stealth settings.
**Fix:** Read stealth configuration for the decoy text, or at minimum localize it.

### L-11. Kotlin `MainActivity` doc comment says `volume_buttons` but code uses `hardware_buttons`

**File:** `android/.../MainActivity.kt`, line 14
**What:** The KDoc says the EventChannel is `com.guardianangela.app/volume_buttons` but the
companion object on line 133 defines it as `com.guardianangela.app/hardware_buttons`. The
Dart side also uses `hardware_buttons`. The code works correctly; only the comment is wrong.
**Fix:** Update the comment to match the actual channel name.

### L-12. `FakeBatteryMonitorService` never closes its `StreamController`

**File:** `lib/services/fakes/fake_battery_monitor_service.dart`
**What:** The `dispose()` method closes the controller, but it's never called by the test
infrastructure. The `reset()` method does not close it. While this is a test-only class,
it can cause "Stream was used after being closed" errors if tests dispose and recreate.
**Fix:** Ensure `dispose()` is called in test tearDown.

### L-13. `geolocator` v14 `Position.timestamp` may be nullable

**File:** `lib/services/implementations/location_service.dart`, line 90
**What:** In geolocator 14.x, `Position.timestamp` type may be `DateTime?` (nullable) depending
on the exact minor version. The code assigns it to `LocationPoint.timestamp` which requires
non-nullable `DateTime`. If the installed version has nullable timestamps, this is a compile
error.
**Fix:** Use `p.timestamp ?? DateTime.now()` as a fallback.

---

## Summary

| Severity | Count | Description |
|----------|-------|-------------|
| CRITICAL | 4     | Compile error, missing l10n delegate, call-resume bug, pause/resume state loss |
| HIGH     | 6     | Unawaited futures, contact reorder persistence, PIN timing, endSession on idle, notification schedule, queue unbounded |
| MEDIUM   | 11    | Fake call config not read, multiple push, onboarding redirect loop, stale location, runtimeType serialization |
| LOW      | 13    | Dead code, missing features, minor UI issues, doc comment mismatches |

### Top 5 Must-Fix Before Release

1. **C-2** -- `DropdownButtonFormField(initialValue:)` compile error. App cannot build.
2. **C-1** -- Missing `AppLocalizations.delegate`. Any l10n use crashes.
3. **C-3** -- Incoming call auto-resume never fires. Session stuck paused permanently.
4. **M-3** -- Onboarding redirect loop. Users trapped in onboarding after completing it.
5. **C-4** -- `_awaitingFirstTouch` not restored on resume. Hold-button state corrupted.
