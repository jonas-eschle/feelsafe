/// Which physical button the panic detection listens on.
///
/// See spec 05 §HardwareButtonService §Platform Support and
/// spec 10 §Hardware Buttons.
///
/// - Android: volume up or volume down via `dispatchKeyEvent`.
/// - iOS: only the headphone remote (central play/pause button); the
///   OS does not allow intercepting the volume keys.
enum HardwareButtonType {
  /// The device volume-up button (Android) or headphone remote
  /// central button (iOS).
  volumeUp,

  /// The device volume-down button (Android only; iOS volume buttons
  /// cannot be intercepted — see spec 10 §iOS Limitations).
  volumeDown,
}
