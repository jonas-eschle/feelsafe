/// Real system-ui-service implementation stub. Phase 9 fills bodies.
library;

import 'package:guardianangela/services/protocols/system_ui_service_protocol.dart';

/// Real platform-backed implementation of [SystemUiServiceProtocol].
final class SystemUiService implements SystemUiServiceProtocol {
  /// Creates the real system-ui service.
  SystemUiService();

  @override
  Future<void> quickExit() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> requestBatteryOptimizationExemption() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<bool> isBatteryOptimized() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');
}
