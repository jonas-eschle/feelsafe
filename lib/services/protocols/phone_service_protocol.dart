/// Abstract interface for phone call initiation used by event strategies.
///
/// Only the methods that strategies call are declared here.
abstract interface class PhoneServiceProtocol {
  /// Dials a regular phone number via `tel:` URI.
  ///
  /// On Android with CALL_PHONE permission, auto-dials without a dialog.
  /// On iOS, always shows a system confirmation dialog (documented
  /// limitation — see spec 02 §phoneCallContact §Permissions).
  ///
  /// Returns `true` if the call was successfully initiated. [isSimulation]
  /// MUST be `false` when called from a strategy; the service applies an
  /// additional Layer 3 no-op for simulation.
  Future<bool> call(String phoneNumber, {bool isSimulation = false});

  /// Dials an emergency number (e.g., `'112'`, `'911'`) via `tel:` URI.
  ///
  /// Behaviour mirrors [call] but uses `ACTION_CALL` on Android for the
  /// emergency-services path. On iOS, a system confirmation dialog appears
  /// (warn user during mode setup — see spec 02 §callEmergency §iOS
  /// limitation warning).
  ///
  /// Returns `true` if the call was successfully initiated. [isSimulation]
  /// MUST be `false` when called from a strategy.
  Future<bool> callEmergency(
    String emergencyNumber, {
    bool isSimulation = false,
  });
}
