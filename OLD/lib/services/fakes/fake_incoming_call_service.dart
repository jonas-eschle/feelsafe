/// Deterministic fake implementation of
/// [IncomingCallServiceProtocol] for tests. Every call is recorded
/// to [calls]; call state is broadcast via a controller.
library;

import 'dart:async';

import 'package:guardianangela/services/protocols/incoming_call_service_protocol.dart';

/// Test double for [IncomingCallServiceProtocol].
final class FakeIncomingCallService implements IncomingCallServiceProtocol {
  /// Creates a fake incoming-call service.
  FakeIncomingCallService();

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

  final StreamController<CallState> _stateController =
      StreamController<CallState>.broadcast();

  @override
  Stream<CallState> get callState => _stateController.stream;

  @override
  Future<void> startListening() async {
    calls.add('startListening');
  }

  @override
  Future<void> stopListening() async {
    calls.add('stopListening');
  }

  /// Test helper: synthesize a [CallState] transition on the stream.
  void injectState(CallState state) {
    _stateController.add(state);
  }

  /// Closes the call-state stream controller.
  void dispose() {
    _stateController.close();
  }
}
