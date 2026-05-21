/// How a user confirms they are safe during a disguised reminder step.
///
/// See spec 03 §ConfirmationType. Each [ReminderTemplate] specifies one
/// confirmation type; the session screen renders the matching interaction.
enum ConfirmationType {
  /// User taps a labeled button (e.g., "I'm safe").
  tapButton,

  /// User taps the correct word from a grid of decoy words.
  tapWord,

  /// User swipes in a specific direction.
  swipe,

  /// User taps anywhere to dismiss (no active confirmation required).
  dismiss,
}
