/// Simulation implementation of [IncomingCallServiceProtocol]. All
/// methods log via `dart:developer` and return a no-op.
library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:guardianangela/services/protocols/incoming_call_service_protocol.dart';

/// Simulation double for [IncomingCallServiceProtocol].
final class SimulationIncomingCallService
    implements IncomingCallServiceProtocol {
  /// Creates the simulation incoming-call service.
  SimulationIncomingCallService();

  final StreamController<CallState> _stateController =
      StreamController<CallState>.broadcast();

  @override
  Stream<CallState> get callState => _stateController.stream;

  @override
  Future<void> startListening() async {
    developer.log('[SIM] incomingCall.startListening');
  }

  @override
  Future<void> stopListening() async {
    developer.log('[SIM] incomingCall.stopListening');
  }

  /// Closes the call-state stream controller.
  void dispose() {
    _stateController.close();
  }
}
