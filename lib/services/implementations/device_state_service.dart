/// Real device-state-service implementation stub. Phase 9 fills bodies.
library;

import 'package:guardianangela/services/protocols/device_state_service_protocol.dart';

/// Real platform-backed implementation of
/// [DeviceStateServiceProtocol].
final class DeviceStateService implements DeviceStateServiceProtocol {
  /// Creates the real device-state service.
  DeviceStateService();

  @override
  Future<bool> isDndOn() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<bool> isSilent() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');
}
