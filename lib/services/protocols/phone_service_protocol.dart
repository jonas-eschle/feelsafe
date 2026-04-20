/// `PhoneServiceProtocol` — abstract contract for placing outbound
/// phone calls (emergency number + emergency contacts).
///
/// Pure Dart. The concrete implementation bridges to the platform
/// call API (auto-dial on Android with `CALL_PHONE`, `ACTION_DIAL`
/// fallback; iOS `tel:` URL) in Phase 4b.
library;

/// Abstract contract for the phone-call service.
abstract class PhoneServiceProtocol {
  /// Places a voice call to [number]. Non-emergency path.
  ///
  /// [isSimulation] — if true, logs the intent without dialing.
  Future<void> call(String number, {bool isSimulation = false});

  /// Places a voice call to an emergency number.
  ///
  /// Semantically separate from [call] so the implementation can
  /// route through a different API path and so simulation-mode
  /// guards are unambiguous.
  Future<void> callEmergency(String number, {bool isSimulation = false});
}
