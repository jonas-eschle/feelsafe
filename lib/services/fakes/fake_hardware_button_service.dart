/// Deterministic fake implementation of
/// [HardwareButtonServiceProtocol] for tests. Every call is recorded
/// to [calls]; panic events are broadcast via a controller.
library;

import 'dart:async';

import 'package:guardianangela/services/protocols/hardware_button_service_protocol.dart';

/// Test double for [HardwareButtonServiceProtocol].
final class FakeHardwareButtonService
    implements HardwareButtonServiceProtocol {
  /// Creates a fake hardware-button service.
  FakeHardwareButtonService();

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

  bool _isListening = false;
  final StreamController<HardwarePanicEvent> _panicController =
      StreamController<HardwarePanicEvent>.broadcast();

  @override
  Stream<HardwarePanicEvent> get panicEvents => _panicController.stream;

  @override
  Future<void> start({
    required String buttonType,
    required String pattern,
    int pressCount = 5,
    int pressWindowMs = 500,
    double longPressDurationSeconds = 2.0,
  }) async {
    calls.add('start:$buttonType/$pattern');
    _isListening = true;
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
    _isListening = false;
  }

  @override
  bool get isListening => _isListening;

  /// Test helper: synthesize a panic event on the stream.
  void injectPanic(HardwarePanicEvent event) {
    _panicController.add(event);
  }

  /// Closes the panic stream controller.
  void dispose() {
    _panicController.close();
  }
}
