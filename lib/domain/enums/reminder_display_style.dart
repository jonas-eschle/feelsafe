/// Controls how a disguised reminder is presented to the user.
///
/// See spec 03 §ReminderDisplayStyle.
enum ReminderDisplayStyle {
  /// Takes over the entire screen, like a calendar event full-screen
  /// notification.
  fullScreen,

  /// An overlay notification card that does not fill the screen.
  subtle,
}
