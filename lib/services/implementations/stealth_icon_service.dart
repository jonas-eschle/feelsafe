/// Real stealth-icon-service implementation stub. Phase 9 fills bodies.
library;

import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/services/protocols/stealth_icon_service_protocol.dart';

/// Real platform-backed implementation of
/// [StealthIconServiceProtocol].
final class StealthIconService implements StealthIconServiceProtocol {
  /// Creates the real stealth-icon service.
  StealthIconService();

  @override
  Future<void> setPreset(StealthIconPreset preset) async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<StealthIconPreset> getCurrentPreset() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');
}
