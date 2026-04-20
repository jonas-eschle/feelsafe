/// Real hardware-button-service implementation stub. Phase 9 fills
/// bodies.
library;

import 'package:guardianangela/services/protocols/hardware_button_service_protocol.dart';

/// Real platform-backed implementation of
/// [HardwareButtonServiceProtocol].
final class HardwareButtonService implements HardwareButtonServiceProtocol {
  /// Creates the real hardware-button service.
  HardwareButtonService();

  @override
  Stream<HardwarePanicEvent> get panicEvents =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> start({
    required String buttonType,
    required String pattern,
    int pressCount = 5,
    int pressWindowMs = 500,
    double longPressDurationSeconds = 2.0,
  }) async => throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> stop() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  bool get isListening =>
      throw UnimplementedError('TODO: Phase 9 real impl');
}
