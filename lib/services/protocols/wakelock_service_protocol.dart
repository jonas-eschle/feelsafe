/// Abstract interface for keeping the device screen awake during sessions.
///
/// See spec 05 §WakelockService. Phase 5 supplies the concrete
/// implementation; this file pins only the methods that the session
/// controller calls.
abstract interface class WakelockServiceProtocol {
  /// Prevents the device from sleeping (keeps screen on).
  ///
  /// No-op if the wakelock is already held. Used during
  /// `fakeLockScreen` hold-button phases and optional session-active
  /// indicator mode.
  Future<void> enable();

  /// Allows the device to sleep normally (screen can turn off).
  ///
  /// No-op if no wakelock is held. Should always be called when a
  /// session ends or the hold-button phase exits.
  Future<void> disable();

  /// Whether the wakelock is currently active.
  bool get isEnabled;
}
