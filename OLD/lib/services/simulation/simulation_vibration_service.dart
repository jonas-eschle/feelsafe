/// Simulation implementation of [VibrationServiceProtocol]. All
/// methods log via `dart:developer` and return a no-op.
library;

import 'dart:developer' as developer;

import 'package:guardianangela/services/protocols/vibration_service_protocol.dart';

/// Simulation double for [VibrationServiceProtocol].
final class SimulationVibrationService implements VibrationServiceProtocol {
  /// Creates the simulation vibration service.
  SimulationVibrationService();

  @override
  Future<void> alarmPattern({bool isSimulation = false}) async {
    developer.log('[SIM] vibration.alarmPattern');
  }

  @override
  Future<void> warningPattern({bool isSimulation = false}) async {
    developer.log('[SIM] vibration.warningPattern');
  }

  @override
  Future<void> fakeCallPattern({bool isSimulation = false}) async {
    developer.log('[SIM] vibration.fakeCallPattern');
  }

  @override
  Future<void> stop() async {
    developer.log('[SIM] vibration.stop');
  }
}
