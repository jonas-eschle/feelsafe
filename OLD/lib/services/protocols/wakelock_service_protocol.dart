/// `WakelockServiceProtocol` — abstract contract for keeping the
/// screen awake during a session.
///
/// Pure Dart. The concrete implementation wraps `wakelock_plus` in
/// Phase 9.
library;

/// Abstract contract for the wake-lock service.
abstract class WakelockServiceProtocol {
  /// Enables the wake-lock (screen stays on).
  Future<void> enable();

  /// Disables the wake-lock (screen may sleep again).
  Future<void> disable();

  /// True iff the wake-lock is currently enabled.
  Future<bool> get isEnabled;
}
