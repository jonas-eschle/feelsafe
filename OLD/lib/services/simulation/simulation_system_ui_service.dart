/// Simulation implementation of [SystemUiServiceProtocol]. All
/// methods log via `dart:developer` and return a no-op.
library;

import 'dart:developer' as developer;

import 'package:guardianangela/services/protocols/system_ui_service_protocol.dart';

/// Simulation double for [SystemUiServiceProtocol].
final class SimulationSystemUiService implements SystemUiServiceProtocol {
  /// Creates the simulation system-ui service.
  SimulationSystemUiService();

  @override
  Future<void> quickExit() async {
    developer.log('[SIM] systemUi.quickExit');
  }

  @override
  Future<void> requestBatteryOptimizationExemption() async {
    developer.log('[SIM] systemUi.requestBatteryOptimizationExemption');
  }

  @override
  Future<bool> isBatteryOptimized() async {
    developer.log('[SIM] systemUi.isBatteryOptimized');
    return false;
  }
}
