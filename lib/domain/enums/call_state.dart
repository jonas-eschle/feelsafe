/// The current telephony call state as observed by the call-state
/// monitor.
///
/// Used by [CallStateServiceProtocol] to surface real incoming-call
/// detection to the session controller. See spec 05 §PhoneService and
/// spec 10 §Phone Call Features ("Real Incoming Call Detection").
///
/// - Android: detected via `PhoneStateListener` /
///   `READ_PHONE_STATE` permission.
/// - iOS: detected via `CXCallObserver` (only when audio active).
enum CallState {
  /// No call in progress.
  idle,

  /// A call is incoming (ringing).
  ringing,

  /// A call is active or on hold (off-hook).
  offhook,
}
