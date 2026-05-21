/// Visual presentation of the hold-button check-in step.
///
/// See spec 03 §HoldButtonConfig. Controls how the session screen renders
/// the hold target for the user.
enum HoldStyle {
  /// A standard large button in the lower portion of the screen.
  largeButton,

  /// The hold target fills the entire screen surface.
  fullScreen,

  /// A fake lock-screen overlay that mimics the platform lock screen.
  fakeLockScreen,
}
