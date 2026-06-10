/// Abstract interface for managing background / foreground-service
/// execution during an active session.
///
/// See spec 05 §BackgroundSessionService (Foreground Service). All
/// methods are pure-Dart and delegate to `flutter_background_service`
/// via the concrete class.
abstract interface class BackgroundSessionServiceProtocol {
  /// Performs one-time setup at app startup.
  ///
  /// Must be called once in `main()` before the `ProviderScope` is
  /// created. Registers notification channels and initialises the
  /// background isolate.
  Future<void> configure();

  /// Starts the foreground service (Android) / background task (iOS).
  ///
  /// [title] and [body] are the initial notification strings. [stealth]
  /// activates the disguised notification appearance (spec 05
  /// §BackgroundSessionService §Stealth Mode). [fakeName] is the resolved
  /// disguise app name; the service reuses it for derived self-updates such as
  /// the `"<name> paused"` text shown when the user taps the Pause action while
  /// the app is backgrounded.
  Future<void> startService({
    required String title,
    required String body,
    bool stealth = false,
    String? fakeName,
  });

  /// Updates the foreground-service notification text in place.
  ///
  /// Call on every engine event to reflect the current session state.
  /// [stealth] controls whether the update uses disguised strings. [fakeName]
  /// refreshes the disguise app name used for derived self-updates.
  Future<void> updateNotification({
    required String title,
    required String body,
    bool stealth = false,
    String? fakeName,
  });

  /// Stops the foreground service and removes the persistent
  /// notification.
  ///
  /// Safe to call even if the service is not running.
  Future<void> stopService();

  /// Fires when the user taps the "I'm Safe" action button on the
  /// foreground-service notification.
  ///
  /// The session controller subscribes and triggers a check-in disarm.
  Stream<void> get onImSafe;

  /// Fires when the user taps the "Pause" action button on the
  /// foreground-service notification.
  Stream<void> get onPause;

  /// Fires when the user taps the "Play/Resume" action button on the
  /// foreground-service notification.
  Stream<void> get onResume;
}
