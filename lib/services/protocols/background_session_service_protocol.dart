/// `BackgroundSessionServiceProtocol` — abstract contract for the
/// foreground-service / persistent-notification surface that keeps a
/// safety session visible while the app is backgrounded (audit Q3).
///
/// Pure Dart. The real implementation wraps
/// `NotificationServiceProtocol`'s session-channel methods plus the
/// existing action-tap stream; it does NOT replace the Android
/// foreground-service plumbing already in `MainActivity.kt` — that
/// stays where it is.
library;

/// Action surfaced from a tap on the persistent session
/// notification. The session controller listens to
/// [BackgroundSessionServiceProtocol.actions] and dispatches.
enum BackgroundAction {
  /// "I'm safe" / end-session action.
  imSafe,

  /// "Pause" action.
  pause,

  /// "Resume" action.
  resume,
}

/// Abstract contract for the background session service.
///
/// The service is a thin wrapper. Lifecycle:
/// * [start] — post the persistent session notification and arm the
///   action-tap subscription.
/// * [updateStatus] — re-render the notification (e.g. step changed,
///   GPS quality changed).
/// * [stop] — cancel the notification and tear down the action
///   subscription.
abstract class BackgroundSessionServiceProtocol {
  /// Posts the persistent session notification with [title] and
  /// [body]. If a session is already running, this is equivalent to
  /// [updateStatus].
  ///
  /// [isSimulation] forwards to the underlying notification service
  /// so simulation runs route to a toast instead of the live
  /// foreground channel.
  Future<void> start({
    required String title,
    required String body,
    bool isSimulation = false,
  });

  /// Updates the persistent notification with new [title] / [body].
  /// No-op when the session has not been started.
  Future<void> updateStatus({
    required String title,
    required String body,
    bool isSimulation = false,
  });

  /// Cancels the persistent notification and ends the action
  /// subscription. Idempotent.
  Future<void> stop();

  /// Stream of action taps the user performed on the persistent
  /// notification. Each event is a [BackgroundAction]. Broadcast.
  Stream<BackgroundAction> get actions;

  /// True iff the service has been started and not stopped.
  bool get isRunning;
}
