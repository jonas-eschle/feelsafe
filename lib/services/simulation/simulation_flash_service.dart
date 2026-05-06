/// Simulation implementation of [FlashServiceProtocol]. All methods
/// log via `dart:developer` and return a no-op so simulation runs
/// never touch the camera flashlight.
library;

import 'dart:developer' as developer;

import 'package:guardianangela/services/protocols/flash_service_protocol.dart';

/// Simulation double for [FlashServiceProtocol].
final class SimulationFlashService implements FlashServiceProtocol {
  /// Creates the simulation flash service.
  SimulationFlashService();

  bool _isStrobing = false;

  @override
  bool get isStrobing => _isStrobing;

  @override
  Future<void> startStrobe({
    Duration interval = kDefaultFlashStrobeInterval,
  }) async {
    _isStrobing = true;
    developer.log(
      '[SIM] flash.startStrobe interval=${interval.inMilliseconds}ms',
    );
  }

  @override
  Future<void> stopStrobe() async {
    if (!_isStrobing) return;
    _isStrobing = false;
    developer.log('[SIM] flash.stopStrobe');
  }
}
