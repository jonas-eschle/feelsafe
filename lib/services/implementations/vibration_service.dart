/// Real vibration-service implementation stub. Phase 9 fills bodies.
library;

import 'package:guardianangela/services/protocols/vibration_service_protocol.dart';

/// Real platform-backed implementation of [VibrationServiceProtocol].
final class VibrationService implements VibrationServiceProtocol {
  /// Creates the real vibration service.
  VibrationService();

  @override
  Future<void> alarmPattern({bool isSimulation = false}) async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> warningPattern({bool isSimulation = false}) async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> fakeCallPattern({bool isSimulation = false}) async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> stop() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');
}
