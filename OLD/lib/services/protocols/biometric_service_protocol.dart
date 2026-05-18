/// Protocol for biometric (fingerprint / face) authentication.
///
/// Wraps `package:local_auth` so the rest of the app does not depend
/// directly on the plugin and tests can substitute a fake.
library;

/// Outcome of a biometric authentication attempt.
enum BiometricResult {
  /// The user authenticated successfully.
  success,

  /// Biometric is not available on this device / not enrolled /
  /// hardware missing. Callers should fall back to PIN.
  unavailable,

  /// The user cancelled the prompt or authentication failed.
  /// Callers should fall back to PIN.
  cancelled,
}

/// Abstraction over the platform biometric API.
abstract class BiometricServiceProtocol {
  /// Returns true when the device has enrolled biometrics and the
  /// OS can present a biometric prompt.
  Future<bool> isAvailable();

  /// Prompts the user to authenticate. [reason] is shown inside the
  /// platform dialog to explain why biometric is required.
  Future<BiometricResult> authenticate({required String reason});
}
