/// `HomeWidgetServiceProtocol` — abstract contract for the home-
/// screen widget that can arm / trigger the app and expose the
/// current session status.
///
/// Pure Dart. The concrete implementation wraps the `home_widget`
/// package in Phase 9.
library;

/// Abstract contract for the home-screen-widget service.
abstract class HomeWidgetServiceProtocol {
  /// Registers a background callback the widget invokes when the
  /// user interacts with it while the app is not foregrounded.
  ///
  /// [callback] must be a top-level or static Dart function
  /// compatible with the `home_widget` package's
  /// `registerInteractivityCallback` requirement.
  Future<void> registerInteractivity(Function callback);

  /// Broadcast stream of widget-initiated URIs while the app is in
  /// the foreground.
  Stream<Uri?> get widgetClicked;

  /// Returns the URI the app was initially launched with from the
  /// widget, or null if it was launched normally.
  Future<Uri?> initiallyLaunchedUri();

  /// Updates the widget's visible status label.
  ///
  /// [status] — localized status text (e.g., "Running", "Idle").
  /// [modeName] — currently selected session mode name.
  /// [isRunning] — true if a session is currently active.
  Future<void> updateStatus({
    required String status,
    required String modeName,
    required bool isRunning,
  });

  /// Writes a "last known marker" so background widget code can
  /// surface context even if the Dart VM has been killed.
  Future<void> writeLastMarker(String marker);

  /// Returns and clears the most recent widget-written marker, or
  /// null if none is pending. Invariant: returning non-null MUST
  /// atomically clear the stored value so the same marker is never
  /// delivered twice.
  Future<String?> consumePendingMarker();
}
