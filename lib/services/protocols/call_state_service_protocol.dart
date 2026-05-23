import 'package:guardianangela/domain/enums/call_state.dart';

/// Abstract interface for real incoming-call detection.
///
/// See spec 05 §PhoneService and spec 10 §Phone Call Features
/// ("Real Incoming Call Detection"). When an incoming real call is
/// detected during a session, the session controller pauses the
/// engine timers until the call ends.
///
/// - Android: `CallStateChannel.kt` — `READ_PHONE_STATE` permission,
///   `PhoneStateListener`.
/// - iOS: `CallStatePlugin.swift` — `CXCallObserver` (only reliable
///   when audio is active; see spec 10 §iOS Limitations).
abstract interface class CallStateServiceProtocol {
  /// Broadcast stream of telephony state changes.
  ///
  /// Emits [CallState.ringing] when an incoming call arrives,
  /// [CallState.offhook] when a call is answered or outgoing,
  /// and [CallState.idle] when the phone returns to idle.
  Stream<CallState> get callState;

  /// Begins listening to telephony state changes via the native
  /// platform channel.
  ///
  /// Must be called before subscribing to [callState].
  Future<void> start();

  /// Stops listening and closes the underlying event-channel
  /// subscription.
  ///
  /// Safe to call even if [start] was never called.
  Future<void> stop();
}
