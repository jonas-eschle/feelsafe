import 'dart:async';

import 'package:guardianangela/domain/enums/call_state.dart';
import 'package:guardianangela/services/protocols/call_state_service_protocol.dart';

/// Simulation [CallStateServiceProtocol] for tests.
///
/// Exposes [setState] to inject telephony state changes without any
/// platform channels. The service only emits after [start] has been
/// called; injections while stopped are silently dropped.
class SimulationCallStateService implements CallStateServiceProtocol {
  /// Creates a [SimulationCallStateService].
  SimulationCallStateService();

  final StreamController<CallState> _controller =
      StreamController<CallState>.broadcast();

  bool _started = false;

  // ---------------------------------------------------------------------------
  // CallStateServiceProtocol implementation
  // ---------------------------------------------------------------------------

  @override
  Stream<CallState> get callState => _controller.stream;

  @override
  Future<void> start() async {
    _started = true;
  }

  @override
  Future<void> stop() async {
    _started = false;
  }

  // ---------------------------------------------------------------------------
  // Test helpers
  // ---------------------------------------------------------------------------

  /// Whether [start] has been called and [stop] has not been called
  /// since.
  bool get isStarted => _started;

  /// Injects [state] into the [callState] stream.
  ///
  /// No-op when the service has not been started or has been stopped.
  void setState(CallState state) {
    if (!_started || _controller.isClosed) return;
    _controller.add(state);
  }

  /// Closes the underlying [StreamController].
  ///
  /// Call in test [tearDown] to avoid resource leaks.
  void dispose() {
    _controller.close();
  }
}
