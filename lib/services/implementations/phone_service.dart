/// Real phone-service implementation stub. Phase 9 fills bodies.
library;

import 'package:guardianangela/services/protocols/phone_service_protocol.dart';

/// Real platform-backed implementation of [PhoneServiceProtocol].
final class PhoneService implements PhoneServiceProtocol {
  /// Creates the real phone service.
  PhoneService();

  @override
  Future<void> call(String number, {bool isSimulation = false}) async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> callEmergency(
    String number, {
    bool isSimulation = false,
  }) async => throw UnimplementedError('TODO: Phase 9 real impl');
}
