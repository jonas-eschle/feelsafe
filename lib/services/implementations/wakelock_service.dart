/// Real wakelock-service implementation stub. Phase 9 fills bodies.
library;

import 'package:guardianangela/services/protocols/wakelock_service_protocol.dart';

/// Real platform-backed implementation of [WakelockServiceProtocol].
final class WakelockService implements WakelockServiceProtocol {
  /// Creates the real wakelock service.
  WakelockService();

  @override
  Future<void> enable() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> disable() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<bool> get isEnabled async =>
      throw UnimplementedError('TODO: Phase 9 real impl');
}
