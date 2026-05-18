/// `PinResult` — the discriminated outcome of a single PIN prompt.
///
/// Returned by the PIN-entry dialog and consumed by
/// `SessionController.handlePinResult`. Duress and exhausted
/// wrong-pin attempts both route to the distress chain; cancel /
/// timeout leave the session untouched.
library;

/// Possible outcomes of a single PIN prompt.
enum PinResult {
  /// The user entered the correct PIN.
  correct,

  /// The user entered an incorrect PIN but still has attempts left.
  wrong,

  /// The user entered the duress PIN. Fires the distress chain.
  duress,

  /// The user exhausted their wrong-PIN attempts. Fires the distress
  /// chain per spec (L9: exhausted attempts = threat model).
  wrongPinThreshold,

  /// The user did not enter a PIN within the timeout window.
  timeout,

  /// The user cancelled the prompt (e.g., tapped outside the dialog).
  cancelled,
}
