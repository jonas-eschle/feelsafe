/// `IncomingCallServiceProtocol` — abstract contract for observing
/// incoming phone call state, used by event strategies that want to
/// react when the user answers a real call.
///
/// Pure Dart. The concrete implementation bridges to the Android
/// `TelephonyCallback` and iOS `CXCallObserver` in Phase 9.
library;

/// Call lifecycle states emitted by [IncomingCallServiceProtocol].
enum CallState {
  /// No active call; device is idle.
  idle,

  /// Phone is ringing (incoming call not yet answered).
  ringing,

  /// Call is connected and in progress.
  active,

  /// Call just ended (back to idle on the next tick).
  ended,
}

/// Abstract contract for the incoming-call observer.
abstract class IncomingCallServiceProtocol {
  /// Broadcast stream of [CallState] transitions.
  Stream<CallState> get callState;

  /// Starts observing native call state.
  Future<void> startListening();

  /// Stops observing native call state.
  Future<void> stopListening();
}
