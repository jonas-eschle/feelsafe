# Code Review: Bugs & Error Handling

Review scope: `session_engine.dart`, `session_controller.dart`, `fake_call_screen.dart`,
`background_service.dart`, `hardware_button_service.dart`, `messaging_service.dart`,
`phone_service.dart`, `audio_service.dart`, `recording_service.dart`, `flash_service.dart`.

---

## CRITICAL

### 1. SessionController._toastController is never closed — stream leak across app lifetime
**File:** `lib/features/session/session_controller.dart:45,490`
**Type:** Resource leak

`_toastController` is a `StreamController<String>.broadcast()` created once per `SessionController` instance. The `_dispose()` method explicitly comments "don't close _toastController here — it's reused across sessions." However, `SessionController` is a Riverpod `Notifier` whose lifecycle is managed by the framework. If the provider is ever disposed (e.g. via `autoDispose`, or if the provider container is destroyed), `_toastController` is never closed. This is a permanent stream leak.

Additionally, `simulationToastProvider` is `autoDispose`, meaning it re-subscribes on every session. If someone holds a reference to `simulationToasts` after the controller is rebuilt, listeners on the old broadcast controller accumulate.

**Fix:** Close `_toastController` when the Notifier is truly disposed. Alternatively, recreate it per session in `startSession()` and close the old one.

---

### 2. CallEmergencyStrategy delays independently of the engine's duration timer — double-delay
**File:** `lib/features/session/event_strategies/call_emergency_strategy.dart:17-20`
**Type:** State inconsistency / logic bug

When `showConfirmation` is true, `executeReal()` awaits `Future.delayed(Duration(seconds: step.durationSeconds))`. But `_executeStepAction` is called from `_onEvent(ChainEvent.stepStarted)`, and the engine simultaneously starts its own wait/duration/grace timer cycle via `_startGenericStep()`. The strategy's `Future.delayed` and the engine's `_durationTimer` run in parallel — they are not coordinated.

If the engine advances to grace or the next step while the strategy is still awaiting its delay, the `isCancelled` check after the delay may return `true` and the call is skipped. But if the engine's duration is shorter than `step.durationSeconds` (e.g. due to randomization), the engine may advance while the strategy is still blocking — meaning the emergency call never fires even though the chain moved past it.

Conversely, if randomization makes the engine's duration longer, the emergency call fires before the engine's duration phase ends, creating a confusing UX where the call happens mid-countdown.

**Fix:** The strategy should not independently delay. It should either rely solely on the engine's timer phases, or the engine should provide a callback/signal for "duration phase ended" that the strategy can await. Alternatively, remove the `showConfirmation` delay from the strategy and let the engine's existing duration phase handle it — the strategy should only fire the call when the engine advances past the duration phase.

---

### 3. MessagingService uses URL launcher, not direct SMS — user must manually send each message
**File:** `lib/services/messaging_service.dart:34-40,76-81`
**Type:** Critical UX / safety bug

`_sendSms()` builds an `sms:` URI and launches it via `url_launcher`. This opens the default SMS app with a pre-filled message but **does not actually send it** — the user must tap "Send" in their SMS app for each contact. `sendToAll()` loops through contacts sequentially, each opening the SMS app.

In an emergency escalation scenario (the user is unresponsive), the SMS step fires automatically, but the messages are never actually sent because no one taps "Send" in the SMS app. This completely defeats the purpose of the automatic escalation chain.

Same issue applies to WhatsApp and Telegram — the URI schemes open the app but do not auto-send.

**Fix:** Use a direct SMS sending plugin (e.g. `flutter_sms`, `telephony`, or platform channels) that can send SMS programmatically without user interaction. For WhatsApp/Telegram, there may not be a way to auto-send, so document this limitation and consider falling back to SMS for automated emergency messaging.

---

### 4. PhoneCallContactStrategy retry loop blocks with 30s delays, no cancellation check
**File:** `lib/features/session/event_strategies/phone_call_contact_strategy.dart:45-52`
**Type:** Race condition / unresponsive behavior

The retry loop in `executeReal()` does `await Future.delayed(const Duration(seconds: 30))` between retries, then calls `callViaChannel` again. During these 30-second delays, the engine may have already advanced to the next step (or the user may have disarmed), but the strategy continues blocking and retrying. There is no `isCancelled` check inside the retry loop.

With `retryCount` potentially > 1 and then the alternative contacts loop, this can block for minutes. Since `executeReal` is fire-and-forget from `_executeStepAction`, the zombie async execution continues even after the engine has moved on, potentially launching phone calls during the wrong escalation step.

**Fix:** Check `services.isCancelled?.call() == true` before each retry delay and before each call attempt. Return early if cancelled.

---

## HIGH

### 5. AudioService: silent catch-all swallows all errors — no logging, no fallback
**File:** `lib/services/audio_service.dart:15,29,62,75,86`
**Type:** Silent failure

Every method in `AudioService` has a `catch (_) { /* silently fail */ }` pattern. In a safety app, a silent audio failure during the alarm step means the user gets no audible alert. There is no logging, no fallback notification, and no way for the caller to know the alarm failed.

The comment says "Asset may not exist yet" — this is a development convenience that should not ship in production. In production, if the alarm asset is missing, that is a critical configuration error that should be surfaced.

**Fix:** At minimum, log the exception with `dart:developer.log()`. Ideally, rethrow after logging so the caller (LoudAlarmStrategy) can implement a fallback (e.g. vibration-only alarm). For `playAlarm()` / `playAlarmWithConfig()`, consider a `Future<bool>` return to signal success/failure.

---

### 6. FlashService._runSosLoop can use a disposed CameraController
**File:** `lib/services/flash_service.dart:72-98,101-107`
**Type:** Race condition / crash

`_runSosLoop()` is an async method that runs in a `while (_isFlashing)` loop with `Future.delayed` awaits. `stopFlash()` sets `_isFlashing = false`, then disposes the controller and sets it to null.

Race scenario: `_pulse()` calls `await _controller?.setFlashMode(FlashMode.torch)`, then awaits `Future.delayed(duration)`. During that delay, `stopFlash()` runs — sets `_isFlashing = false`, disposes `_controller`, sets it to `null`. When `_pulse` resumes after the delay, it calls `_controller?.setFlashMode(FlashMode.off)` — `_controller` is now `null`, so the null-aware operator skips it. This is safe.

But there is a subtler race: `_pulse` stores a reference to `_controller` implicitly via the method call chain. If `stopFlash()` disposes the controller between the `setFlashMode(torch)` and `setFlashMode(off)` calls (before `_controller` is set to null but after `dispose()`), calling `setFlashMode` on a disposed controller will throw. The `catch (_) {}` in `_pulse` catches this, but see finding #5 — silent failure.

Additionally: `stopFlash` does not `await _runSosLoop()` to finish. The loop continues executing after `stopFlash` returns, though it will exit on the next `_isFlashing` check. If `startSosFlash()` is called immediately after `stopFlash()`, two `_runSosLoop` instances could run concurrently.

**Fix:** Use a `Completer` or track the loop `Future` so `stopFlash` can await its completion before releasing the controller. Alternatively, capture the controller reference locally in `_runSosLoop` and check it hasn't been replaced before each use.

---

### 7. SessionController.endSession does not await _stopServices
**File:** `lib/features/session/session_controller.dart:200-208`
**Type:** Resource leak / race condition

`endSession()` calls `_engine?.endSession()`, then `_stopServices()` (which is async and returns a Future), then `_dispose()`, then sets `state = null`. But `_stopServices()` is not awaited — it runs fire-and-forget. This means `_dispose()` runs while services are still shutting down, and `state` is set to `null` while async cleanup is in progress.

If `startSession()` is called before `_stopServices()` completes, the new session and the old shutdown can interleave — e.g. the old `stopSession()` on `BackgroundSessionService` arrives after the new `startSession()` has started the foreground service, killing the new session's notification.

**Fix:** Make `endSession()` async and `await _stopServices()` before calling `_dispose()`.

---

### 8. SessionEngine.endSession emits sessionEnded then closes the stream — listeners may miss it
**File:** `lib/features/session/session_engine.dart:164-169`
**Type:** Race condition

`endSession()` adds `ChainEvent.sessionEnded` directly to `_eventController` (bypassing `_emit`'s `_ended` check since `_ended` was just set to `true`... wait, actually `_ended` is set to `true` before adding the event). Let me re-read:

```dart
void endSession() {
    if (_ended) return;
    _ended = true;                    // (1) set ended
    _cancelAllTimers();
    _eventController.add(...)         // (2) emit — but _emit() would check _ended and skip!
    _eventController.close();         // (3) close
}
```

The code correctly bypasses `_emit` here by calling `_eventController.add()` directly. But `_eventController.close()` is called immediately after. Since this is a `sync: true` broadcast controller, the event is delivered synchronously to listeners before `close()`. This is fine in practice.

However, `_onEvent` in `SessionController` handles `sessionEnded` by calling `_saveSessionLog()`, which is async (calls `ref.read(sessionLogRepositoryProvider).save(log)`). If the stream closes before the listener completes its async work, subsequent events on the stream will throw. This is acceptable here since `sessionEnded` is the last event.

**Revised assessment:** This is actually correct for the sync broadcast case, but fragile. Downgrading to MEDIUM.

**Severity: MEDIUM**

**Fix:** Consider closing the stream controller in a microtask (`Future.microtask(() => _eventController.close())`) to allow listeners to finish processing, or don't close it at all (let it be GC'd with the engine).

---

### 9. RecordingService.recordForDuration is not cancellable — blocks for the full duration
**File:** `lib/services/recording_service.dart:53-61`
**Type:** Uninterruptible blocking

`recordForDuration` uses `await Future.delayed(duration)` then calls `stopRecording()`. If the session ends or the step advances during recording, there is no way to cancel the recording early. The `SmsContactStrategy` calls this with a default of 30 seconds, during which the engine may advance to the next step.

The returned `Future<String>` is awaited by `SmsContactStrategy`, which means the SMS is not actually sent until the recording finishes. In a 30-second recording scenario, the SMS contacts don't receive the message for 30 seconds after the step fires.

**Fix:** Accept a cancellation token or `isCancelled` callback. Use a `Timer` + `Completer` instead of `Future.delayed` so the recording can be stopped early. Also consider sending the SMS first, then recording, then sending a follow-up with the recording attachment.

---

### 10. SmsContactStrategy sends recording file path in SMS, not the actual file
**File:** `lib/features/session/event_strategies/sms_contact_strategy.dart:67-68`
**Type:** Logic bug

When audio recording is enabled, the strategy appends `Recording: $recordingPath` to the SMS message. But `recordingPath` is a local filesystem path (e.g. `/data/data/.../recording_123.m4a`). The recipient receives an SMS containing a path that is meaningless to them — they cannot access the file.

**Fix:** Either upload the recording to a cloud storage service and include the URL, or attach the recording as an MMS, or remove the recording path from the SMS and handle it separately (e.g. share via a file sharing service).

---

## MEDIUM

### 11. BackgroundSessionService stream listeners are never cancelled
**File:** `lib/services/background_service.dart:132-134`
**Type:** Resource leak

In `configure()`, `_service.on(_kMethodImSafe).listen((_) { ... })` creates a subscription that is never stored or cancelled. Since `configure()` has a `_configured` guard, it only runs once, so there's no duplicate subscription risk. But the subscription lives forever — it can never be cancelled even if the service is no longer needed.

**Fix:** Store the subscription and cancel it in `dispose()`.

---

### 12. FakeCallScreen._startRinging has no error handling
**File:** `lib/features/fake_call/fake_call_screen.dart:35-38`
**Type:** Unhandled exception

`_startRinging()` calls `audio.playRingtone(null)`. While `AudioService.playRingtone` has a `catch (_)` internally, the `await` in `_startRinging` is called from `initState()` which doesn't handle errors. If `ref.read(audioServiceProvider)` throws (unlikely but possible if the provider tree is in a bad state), the exception is unhandled.

More importantly, `_startRinging()` is called in `initState()` which does not await it. The returned `Future` is dropped — if it throws asynchronously, it becomes an unhandled future error.

**Fix:** Add `.catchError((_) {})` or wrap in try-catch. Or better, handle the error to show a visual indication that the ringtone failed.

---

### 13. FakeCallScreen uses Platform.isIOS on web — will crash
**File:** `lib/features/fake_call/fake_call_screen.dart:93`
**Type:** Platform exception

`_resolveCallStyle` calls `Platform.isIOS` directly. On web platforms, `dart:io`'s `Platform` class is not available and will throw. While this is a mobile app, the code imports `dart:io` unconditionally at line 1.

**Fix:** Use `kIsWeb` check from `foundation.dart` before accessing `Platform`, or use `defaultTargetPlatform` from Flutter which works on all platforms.

---

### 14. HardwareButtonService._handleLongPress does not cancel timer on release
**File:** `lib/services/hardware_button_service.dart:170-183`
**Type:** Logic bug

The long-press detection starts a timer on the first volume button event. If the user releases the button, the timer continues running and will eventually fire, triggering a false panic.

The comment says "Volume_keydown fires repeatedly when held" — if this is true, then the approach works because repeated events keep arriving and the `if (_longPressTimer?.isActive == true) return;` skips them. But if the user releases the button and presses again quickly, the existing timer is still running from the first press and the new press is ignored. The timer fires based on the first press timing, not the second.

More critically, there is no mechanism to cancel the long-press timer on button release. The `FlutterAndroidVolumeKeydown` plugin only provides key-down events, not key-up events. So if the user presses and releases quickly (not a long press), the timer still fires after `_longPressDuration`.

**Fix:** Implement a "keep-alive" mechanism: reset the timer on each repeated key-down event. If no key-down event arrives within a short window (e.g. 300ms), the button was released, so cancel the timer. This requires restructuring the long-press detection to track inter-event timing.

---

### 15. SessionController.holdStart guards on wrong condition
**File:** `lib/features/session/session_controller.dart:144-147`
**Type:** Logic bug

```dart
void holdStart() {
    final step = _engine?.currentStep;
    if (step != null && step.type != ChainStepType.holdButton) return;
    _engine?.holdStart();
```

The guard says: if `step` is non-null AND it's not a `holdButton`, return early. But if `step` is `null` (no engine or engine not started), the condition is false, and we fall through to call `_engine?.holdStart()`. This means `holdStart()` is called when `step` is null (no active step), which is wasteful but harmless because `SessionEngine.holdStart()` has its own null guard.

However, the intent seems backward — it should probably be:
```dart
if (step == null || step.type != ChainStepType.holdButton) return;
```

With the current logic, if `_engine` is null, `_engine?.holdStart()` is a no-op (null-aware), so no crash. But `state` is still updated below even if the engine doesn't exist. This could set state when there's no active session.

**Fix:** Change to `if (step == null || step.type != ChainStepType.holdButton) return;`

---

### 16. BackgroundSessionService._onStart stream listeners are never cancelled
**File:** `lib/services/background_service.dart:336-357`
**Type:** Resource leak (minor)

The `_onStart` callback in the service isolate creates `.listen()` calls on `service.on(...)` streams. These subscriptions are never stored or cancelled. Since this is a service isolate that runs until `stopSelf()`, the leak persists for the service's lifetime but is cleaned up on process termination. Low impact since the isolate is short-lived.

**Fix:** Store subscriptions and cancel them before `stopSelf()`.

---

### 17. SessionController._saveSessionLog is fire-and-forget with no error handling
**File:** `lib/features/session/session_controller.dart:327-348`
**Type:** Silent failure

`_saveSessionLog()` calls `ref.read(sessionLogRepositoryProvider).save(log)` without awaiting or catching errors. The comment says "fire and forget; session is already ending." If the save fails (Hive box error, disk full, etc.), the session log is silently lost with no user indication.

**Fix:** At minimum, log the error. Consider showing a notification if the log save fails, since session logs may be important for safety incident review.

---

### 18. SessionEngine._adjusted returns zero-length duration if speedMultiplier is very large
**File:** `lib/features/session/session_engine.dart:88-95`
**Type:** Edge case

If `speedMultiplier` is extremely large, `_adjusted` can return `Duration(milliseconds: 0)`, which is handled in most places by using `Timer(Duration.zero, ...)`. But it means all timers fire nearly simultaneously in a microtask cascade, which could lead to rapid-fire events overwhelming the listener.

There is no upper bound on `speedMultiplier`. The `toggleSimulationSpeed` method only switches between 1x and 5x, but `setSpeedMultiplier` accepts any `double`.

**Fix:** Clamp `speedMultiplier` to a reasonable range (e.g. 0.1 to 100) in `setSpeedMultiplier()` and enforce a minimum duration in `_adjusted()` (e.g. 10ms).

---

## LOW

### 19. MessagingService._sendTelegram fallback does not include message text
**File:** `lib/services/messaging_service.dart:66-68`
**Type:** Minor logic issue

When the `tg://` deep link fails and the service falls back to `https://t.me/$tgNumber`, the message text is dropped. The `t.me` URL only opens the user profile — it doesn't pre-fill a message. The user would need to manually type and send the emergency message.

**Fix:** Use `https://t.me/$tgNumber?text=$encodedMessage` if supported, or document this limitation.

---

### 20. FakeCallScreen does not stop ringtone on dispose
**File:** `lib/features/fake_call/fake_call_screen.dart:40-43`
**Type:** Resource leak

The `dispose()` method disposes the animation controller but does not stop the audio. If the screen is popped by the system (e.g. back gesture on Android, or process killed), the ringtone could continue playing. The `_answer`, `_decline`, and `_hangUp` methods all call `audio.stop()`, but there is no safety net in `dispose()`.

**Fix:** Call `ref.read(audioServiceProvider).stop()` in `dispose()` as a safety net. Note: `ref` may not be available in `dispose()` of a `ConsumerState` — use a stored reference or `WidgetsBindingObserver`.

---

### 21. PhoneService.callEmergency does not use LaunchMode.externalApplication
**File:** `lib/services/phone_service.dart:9`
**Type:** Minor inconsistency

`callEmergency` uses `launchUrl(uri)` without specifying `LaunchMode.externalApplication`, while `callWhatsApp` and `callTelegram` explicitly specify it. For emergency calls, ensuring external application mode is important to guarantee the call goes through the system dialer.

**Fix:** Add `mode: LaunchMode.externalApplication` to `callEmergency` and `call`.

---

### 22. SessionEngine does not validate chainSteps for duplicate orders or empty lists
**File:** `lib/features/session/session_engine.dart:76-81`
**Type:** Missing validation

The engine accepts `chainSteps` as-is. The `SessionController.startSession` sorts by `order`, but if two steps have the same order, the sort is unstable and behavior is nondeterministic. If `chainSteps` is empty, `start()` returns early, which is safe.

**Fix:** Assert or validate that orders are unique, or use a stable sort.

---

### 23. BackgroundSessionService is a singleton with mutable state — test unfriendly
**File:** `lib/services/background_service.dart:38-41`
**Type:** Design issue

`BackgroundSessionService` uses a private constructor + static `_instance` pattern. The `_configured` flag prevents re-initialization, which makes it difficult to reset state in tests. The `_imSafeController` is created once and never recreated.

**Fix:** Accept dependencies via constructor injection for testability. Consider using Riverpod's provider lifecycle to manage the singleton instead of a static field.

---

### 24. RecordingService does not dispose recorder on error in startRecording
**File:** `lib/services/recording_service.dart:15-37`
**Type:** Resource leak (minor)

If `_recorder!.start(...)` throws (e.g. permission revoked between the `hasPermission` check and the actual start), `_recorder` is left in an initialized-but-not-recording state. `_isRecording` remains `false`, so `stopRecording()` will return early without disposing the recorder.

**Fix:** Add a try-catch around the start call; on error, dispose the recorder and set it to null.
