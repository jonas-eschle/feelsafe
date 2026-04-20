/// Simulation implementation of [StealthIconServiceProtocol]. All
/// methods log via `dart:developer` and return a no-op.
library;

import 'dart:developer' as developer;

import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/services/protocols/stealth_icon_service_protocol.dart';

/// Simulation double for [StealthIconServiceProtocol].
final class SimulationStealthIconService
    implements StealthIconServiceProtocol {
  /// Creates the simulation stealth-icon service.
  SimulationStealthIconService();

  StealthIconPreset _current = StealthIconPreset.calendar;

  @override
  Future<void> setPreset(StealthIconPreset preset) async {
    developer.log('[SIM] stealthIcon.setPreset ${preset.name}');
    _current = preset;
  }

  @override
  Future<StealthIconPreset> getCurrentPreset() async {
    developer.log('[SIM] stealthIcon.getCurrentPreset');
    return _current;
  }
}
