/// Real incoming-call-service implementation.
///
/// Dart-side only. Subscribes to the native event channel
/// (`com.guardianangela.app/call_state`). The Android side wraps
/// `TelephonyCallback` and the iOS side wraps `CXCallObserver`;
/// both land in Phase 10. String payloads: "idle", "ringing",
/// "active", "ended" map to [CallState] enum values.
library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';

import 'package:guardianangela/services/protocols/incoming_call_service_protocol.dart';

/// Real platform-backed implementation of
/// [IncomingCallServiceProtocol].
final class IncomingCallService implements IncomingCallServiceProtocol {
  /// Creates the real incoming-call service.
  IncomingCallService();

  /// Method-channel for start/stop control.
  static const MethodChannel _methodChannel = MethodChannel(
    'com.guardianangela.app/call_state',
  );

  /// Event-channel for state transitions.
  static const EventChannel _eventChannel = EventChannel(
    'com.guardianangela.app/call_state_events',
  );

  final StreamController<CallState> _controller =
      StreamController<CallState>.broadcast();

  StreamSubscription<Object?>? _nativeSub;
  bool _listening = false;

  @override
  Stream<CallState> get callState => _controller.stream;

  @override
  Future<void> startListening() async {
    if (_listening) return;
    try {
      await _methodChannel.invokeMethod<void>('start');
    } on MissingPluginException {
      return Future.error('Not wired — Phase 10');
    } on PlatformException catch (e, s) {
      developer.log('call_state.start platform error', error: e, stackTrace: s);
      rethrow;
    }
    _nativeSub = _eventChannel.receiveBroadcastStream().listen(
      (Object? raw) {
        final state = _parseState(raw);
        if (state != null) _controller.add(state);
      },
      onError: (Object e, StackTrace s) {
        developer.log('call_state event error', error: e, stackTrace: s);
      },
    );
    _listening = true;
  }

  @override
  Future<void> stopListening() async {
    await _nativeSub?.cancel();
    _nativeSub = null;
    _listening = false;
    try {
      await _methodChannel.invokeMethod<void>('stop');
    } on MissingPluginException {
      // Phase 10 not wired — nothing to stop.
    } on PlatformException catch (e, s) {
      developer.log('call_state.stop platform error', error: e, stackTrace: s);
    }
  }

  CallState? _parseState(Object? raw) => switch (raw) {
    'idle' => CallState.idle,
    'ringing' => CallState.ringing,
    'active' => CallState.active,
    'ended' => CallState.ended,
    _ => null,
  };
}
