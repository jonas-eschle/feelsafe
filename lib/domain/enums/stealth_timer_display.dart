/// Controls how the session timer is displayed when stealth mode is active.
///
/// See spec 03 §StealthConfig.
enum StealthTimerDisplay {
  /// Timer displayed normally.
  normal,

  /// Timer displayed in a smaller, less prominent format.
  small,

  /// Timer hidden entirely.
  none,
}
