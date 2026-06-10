/// Abstract interface for the platform-side quick-exit action.
///
/// Quick Exit (spec 04:1020 §Quick Exit) immediately terminates the app
/// while leaving session data encrypted on disk for later recovery. The
/// trigger is the in-session app-bar gesture (long-press / PIN gate /
/// confirm dialog) or the home-screen widget button. Once the user has
/// confirmed, the Dart side finalises the session log via
/// `SessionLogRecorder` and then invokes this service to perform the
/// actual app termination.
///
/// **Platform contract:**
/// - **Android (spec 04:1020):** calls `finishAndRemoveTask()` via the
///   `com.guardianangela.app/quick_exit` MethodChannel. The native side
///   removes the activity from recents in addition to terminating it.
/// - **iOS (spec 04:1024):** calls `exit(0)` via the same MethodChannel
///   on the iOS side. iOS does not support removing the app from the
///   app-switcher; the next launch will look like a normal cold start.
/// - **Web / desktop:** no-op (Quick Exit is mobile-only per spec 10:148).
///
/// On builds without the native channel (web, desktop, tests) the Real
/// implementation falls back to `SystemNavigator.pop(animated: false)`
/// so the gesture still has a visible effect.
abstract interface class QuickExitServiceProtocol {
  /// Immediately terminates the app.
  ///
  /// Returns a future that completes once the platform side has been
  /// invoked — but in practice the process is gone before the future
  /// resolves on real devices. Callers should treat the call as
  /// fire-and-forget after persisting any data they need to keep.
  Future<void> quickExit();
}
