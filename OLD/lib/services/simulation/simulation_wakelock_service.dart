/// Simulation implementation of [WakelockServiceProtocol]. All
/// methods log via `dart:developer` and return a no-op.
library;

import 'dart:developer' as developer;

import 'package:guardianangela/services/protocols/wakelock_service_protocol.dart';

/// Simulation double for [WakelockServiceProtocol].
final class SimulationWakelockService implements WakelockServiceProtocol {
  /// Creates the simulation wakelock service.
  SimulationWakelockService();

  bool _enabled = false;

  @override
  Future<void> enable() async {
    developer.log('[SIM] wakelock.enable');
    _enabled = true;
  }

  @override
  Future<void> disable() async {
    developer.log('[SIM] wakelock.disable');
    _enabled = false;
  }

  @override
  Future<bool> get isEnabled async {
    developer.log('[SIM] wakelock.isEnabled');
    return _enabled;
  }
}
