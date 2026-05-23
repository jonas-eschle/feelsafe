/// Abstract interface for Android system-UI operations.
///
/// See spec 05 §BackgroundSessionService §Stealth Mode and
/// `CLAUDE.md §Native Platform Channels` (`SystemUiChannel.kt`,
/// `StealthIconChannel.kt`). iOS exposes no-op stubs because these
/// operations have no iOS equivalent (spec 10 §Platform-Specific
/// Limitations).
///
/// All methods are invoked through their respective MethodChannels
/// (`com.guardianangela.app/system_ui`,
/// `com.guardianangela.app/sms` stealth-icon side) in the Real
/// implementation; the Simulation implementation is a no-op that
/// logs the call.
abstract interface class SystemUiServiceProtocol {
  /// Shows or hides the app launcher icon.
  ///
  /// When [enabled] is `false` the package manager disables the
  /// main activity component alias so the app no longer appears in
  /// the device launcher or recent-apps list (Android
  /// `StealthIconChannel.kt` — package-manager component toggling).
  ///
  /// iOS: no-op (component toggling is not available on iOS).
  Future<void> setStealthIconEnabled(bool enabled);

  /// Enables or disables Android Task Locking (lock-task / pinned-app
  /// mode) for session stealth.
  ///
  /// When [enabled] is `true` the activity is pinned so the user
  /// cannot leave the session screen via the Recent-Apps or Home
  /// buttons (Android `SystemUiChannel.kt`). Requires
  /// `PACKAGE_USAGE_STATS` permission and the device policy allowing
  /// lock-task mode.
  ///
  /// iOS: no-op (guided access is a user-initiated system feature and
  /// cannot be programmatically toggled).
  Future<void> toggleLockTaskMode(bool enabled);
}
