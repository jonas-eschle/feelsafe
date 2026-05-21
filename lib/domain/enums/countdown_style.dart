/// Visual presentation of a countdown-warning step.
///
/// See spec 03 §CountdownWarningConfig and G-004. Controls how the
/// countdown is surfaced to the user.
enum CountdownStyle {
  /// The countdown takes over the entire screen.
  fullScreen,

  /// The countdown appears as a system notification.
  notification,

  /// A minimal indicator (e.g., a small overlay or persistent notification).
  minimal,
}
