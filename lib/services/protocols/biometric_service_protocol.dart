/// Abstract interface for biometric (fingerprint / Face ID) authentication.
///
/// Powers the App-lock launch gate's optional biometric unlock. The
/// biometric path is opt-in per spec 06 §App PIN
/// (`AppSettings.appPinBiometricEnabled`); when enabled and available the
/// gate tries biometrics first and falls back to the PIN keypad on any
/// failure. The app's own PIN — never the device passcode — is the
/// fallback, so this service is biometric-only.
abstract interface class BiometricServiceProtocol {
  /// Whether the device has usable, enrolled biometrics.
  ///
  /// Returns false when no hardware is present, none is enrolled, or the
  /// platform cannot check — the caller then shows the PIN keypad only and
  /// never surfaces a biometric affordance.
  Future<bool> isAvailable();

  /// Prompts for biometric authentication with [reason] shown to the user.
  ///
  /// Returns true only on a successful match. Any cancel, failure, lockout,
  /// or platform error returns false so the caller can fall back to the PIN
  /// keypad — it never throws.
  Future<bool> authenticate({required String reason});
}
