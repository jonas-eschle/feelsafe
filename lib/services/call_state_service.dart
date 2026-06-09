// Native channel handlers:
// - Android: CallStateChannel.kt — READ_PHONE_STATE + PhoneStateListener,
//   MethodChannel + EventChannel 'com.guardianangela.app/call_state'.
// - iOS: CallStatePlugin.swift — CXCallObserver.

import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';

import 'package:guardianangela/domain/enums/call_state.dart';
import 'package:guardianangela/services/protocols/call_state_service_protocol.dart';

// ---------------------------------------------------------------------------
// Channel identifiers
// ---------------------------------------------------------------------------

const MethodChannel _kMethodChannel = MethodChannel(
  'com.guardianangela.app/call_state',
);
const EventChannel _kEventChannel = EventChannel(
  'com.guardianangela.app/call_state',
);

/// Production [CallStateServiceProtocol].
///
/// On [start] the service subscribes to the native EventChannel which
/// delivers telephony state strings (`'idle'`, `'ringing'`, `'offhook'`).
/// The Dart side parses the string and emits typed [CallState] values.
///
/// **Android:** `CallStateChannel.kt` uses `PhoneStateListener` (or
/// `TelephonyCallback` on API 31+) and requires `READ_PHONE_STATE` permission.
///
/// **iOS:** `CallStatePlugin.swift` uses `CXCallObserver`. Only reliable when
/// audio is active (spec 10 §iOS Limitations).
///
/// Host tests drive the EventChannel directly through
/// `TestDefaultBinaryMessengerBinding` mock handlers (see
/// `test/services/call_state_service_real_test.dart`); the live native path is
/// device-proven by the M5 C4 telephony e2e.
///
/// **Single constructor location rule:** no `RealCallStateService()`
/// call may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces).
class RealCallStateService implements CallStateServiceProtocol {
  /// Creates a [RealCallStateService].
  RealCallStateService();

  final StreamController<CallState> _stateController =
      StreamController<CallState>.broadcast();

  StreamSubscription<dynamic>? _sub;

  // ---------------------------------------------------------------------------
  // CallStateServiceProtocol implementation
  // ---------------------------------------------------------------------------

  @override
  Stream<CallState> get callState => _stateController.stream;

  @override
  Future<void> start() async {
    if (_sub != null) {
      log('start called while already listening', name: 'CallStateService');
      return;
    }

    log('start — subscribing to EventChannel', name: 'CallStateService');

    try {
      _sub = _kEventChannel.receiveBroadcastStream().listen(
        _onNativeEvent,
        onError: (Object e) {
          log('EventChannel error: $e', name: 'CallStateService');
        },
        onDone: () {
          log('EventChannel done', name: 'CallStateService');
        },
      );

      // Request the native side to start listening.
      await _kMethodChannel.invokeMethod<void>('startListening');
    } catch (e) {
      log('start error: $e', name: 'CallStateService');
    }
  }

  @override
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;

    try {
      await _kMethodChannel.invokeMethod<void>('stopListening');
    } catch (e) {
      log('stop error: $e', name: 'CallStateService');
    }

    log('stop', name: 'CallStateService');
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _onNativeEvent(dynamic event) {
    if (event is! String) {
      log('unexpected event type: $event', name: 'CallStateService');
      return;
    }

    final state = _parseCallState(event);
    if (state != null) {
      _stateController.add(state);
      log('callState: $state', name: 'CallStateService');
    } else {
      log('unknown call state string: $event', name: 'CallStateService');
    }
  }

  static CallState? _parseCallState(String raw) => switch (raw) {
    'idle' => CallState.idle,
    'ringing' => CallState.ringing,
    'offhook' => CallState.offhook,
    _ => null,
  };
}
