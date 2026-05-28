/// Why a session ended.
///
/// See spec 03 §SessionLog and lessons §5.2. There is NO
/// [appTermination] value — app death means the session is gone
/// with no recovery code or resume-from-disk.
enum EndReason {
  /// User entered the correct Session End PIN (or biometric).
  disarm,

  /// All chain steps exhausted without user disarming.
  chainExhausted,

  /// Hardware panic button pressed the required number of times.
  hardwarePanic,

  /// User entered the duress PIN at a PIN prompt.
  duressPin,

  /// Wrong PIN entered more times than [AppSettings.wrongPinThreshold].
  wrongPinExhausted,

  /// User explicitly quit the session from the session screen.
  userQuit,

  /// Distress-confirmation PIN gate timed out (spec 04 §Distress
  /// Confirmation Window).
  ///
  /// Raised by the session screen's distress-cancel PIN prompt when the
  /// configured 15-second window elapses without a successful PIN
  /// entry — the distress chain fires immediately. Routed through
  /// `SessionController.confirmDistress(reason: distressConfirmTimeout)`.
  distressConfirmTimeout,
}
