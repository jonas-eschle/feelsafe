# Phase C+D Review: PIN Dialog & Session Logging -- ISSUES ONLY

## BUGS

### B1: No navigation to SessionCompletedScreen (CRITICAL)
Route `/session/completed` is registered in `app_router.dart` but nothing
navigates to it. When `endSession()` sets state to null, `SessionScreen`
redirects to `/home`, skipping the completion screen entirely. The log
summary is never shown to the user.
- Files: `lib/features/session/session_screen.dart:27-29`, `lib/features/session/session_controller.dart:233-238`

### B2: endSession() nulls state, then _cleanup() already ran -- log accessor race
`endSession()` calls `_logRecorder?.close()`, then `_cleanup()` (which
preserves `_logRecorder`), then sets `state = null`. But setting state to
null triggers the `SessionScreen` watcher which navigates to `/home`.
Even if B1 were fixed, any code trying to read `lastSessionLog` after
navigation would need to do so before the controller is potentially
disposed by Riverpod garbage collection.

### B3: PIN dots hardcoded to 4, but dialog accepts up to 6 digits
`_addDigit` caps at 6 chars, `_checkPin` fires at length >= 4, but the
dot row renders exactly 4 dots (`List.generate(4, ...)`). A 5- or 6-digit
PIN will validate correctly but the UI shows no visual feedback for
digits 5 and 6.
- File: `lib/core/widgets/pin_entry_dialog.dart:193-209`

### B4: SessionLog never persisted to Hive
No `SessionLogRepository` exists. The log lives only in memory on
`_logRecorder`. If the app is killed or the controller is GC'd, the log
is lost permanently.

## MISSING FUNCTIONALITY (TODOs in code)

### M1: Duress PIN result is a no-op
`session_screen.dart:140` -- `PinResult.duress` case has a TODO and does
nothing. User enters duress PIN, dialog closes, no sub-chain fires.

### M2: Wrong-PIN threshold result is a no-op
`session_screen.dart:143` -- `PinResult.wrongPinThreshold` case has a
TODO and does nothing.

## DESIGN CONCERNS

### D1: GPS setting ignored by controller
`AppSettings.logGpsWithEvents` exists but `startSession()` always creates
`SessionLogRecorder` with `logGps: false` (default). GPS coordinates are
never captured.

### D2: Constant-time comparison defeated by early length check
`PinUtils._constantTimeEquals` returns `false` immediately when lengths
differ, leaking length info. In practice the hash format is fixed-length
so this is not exploitable, but worth noting.

### D3: Shake animation is a single static offset, not an oscillation
`_shaking` sets `translationRaw(8, 0, 0)` for 500ms then resets. This
produces a static rightward shift, not the expected shake effect. Needs
an `AnimationController` with a sine/spring curve.
