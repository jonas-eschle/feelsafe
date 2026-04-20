/// Simulation implementation of [DeviceStateServiceProtocol]. All
/// methods log via `dart:developer` and return a no-op.
library;

import 'dart:developer' as developer;

import 'package:guardianangela/services/protocols/device_state_service_protocol.dart';

/// Simulation double for [DeviceStateServiceProtocol].
final class SimulationDeviceStateService
    implements DeviceStateServiceProtocol {
  /// Creates the simulation device-state service.
  SimulationDeviceStateService();

  @override
  Future<bool> isDndOn() async {
    developer.log('[SIM] deviceState.isDndOn');
    return false;
  }

  @override
  Future<bool> isSilent() async {
    developer.log('[SIM] deviceState.isSilent');
    return false;
  }
}
