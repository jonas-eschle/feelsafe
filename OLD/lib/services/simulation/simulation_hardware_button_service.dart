/// Simulation implementation of [HardwareButtonServiceProtocol]. All
/// methods log via `dart:developer` and return a no-op.
library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:guardianangela/services/protocols/hardware_button_service_protocol.dart';

/// Simulation double for [HardwareButtonServiceProtocol].
final class SimulationHardwareButtonService
    implements HardwareButtonServiceProtocol {
  /// Creates the simulation hardware-button service.
  SimulationHardwareButtonService();

  bool _listening = false;
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
    developer.log(
      '[SIM] hardwareButton.start $buttonType/$pattern '
      'pressCount=$pressCount',
    );
    _listening = true;
  }

  @override
  Future<void> stop() async {
    developer.log('[SIM] hardwareButton.stop');
    _listening = false;
  }

  @override
  bool get isListening => _listening;

  /// Closes the panic stream controller.
  void dispose() {
    _panicController.close();
  }
}
