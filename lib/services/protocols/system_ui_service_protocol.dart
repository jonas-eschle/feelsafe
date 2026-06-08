import 'package:guardianangela/domain/enums/stealth_icon_preset.dart';

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
/// `com.guardianangela.app/stealth_icon`) in the Real implementation;
/// the Simulation implementation is a no-op that logs the call.
abstract interface class SystemUiServiceProtocol {
  /// Applies a per-preset launcher-icon disguise.
  ///
  /// The Android `StealthIconChannel.kt` enables exactly one
  /// `<activity-alias>` (and disables the others) so the home-screen
  /// icon and label match [preset]. [StealthIconPreset.none] restores
  /// the real Guardian Angela launcher icon; every other value swaps in
  /// a neutral disguise (music, calendar, …).
  ///
  /// Apply this at stealth-config-save time only, never during an
  /// active session: the alias swap can kill the process, and stealth
  /// settings are immutable while a session runs.
  ///
  /// iOS: no-op (component/launcher toggling is not available on iOS).
  Future<void> setStealthIcon(StealthIconPreset preset);

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
