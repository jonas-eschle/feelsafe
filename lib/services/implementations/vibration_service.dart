/// Real vibration-service implementation.
///
/// Wraps the `vibration` package to play alarm, warning, and fake-call
/// haptic patterns. Respects `isSimulation` — in simulation mode all
/// methods log and no-op (4-layer defense, layer 2).
library;

import 'dart:developer' as developer;

import 'package:guardianangela/services/protocols/vibration_service_protocol.dart';
import 'package:vibration/vibration.dart';

/// Real platform-backed implementation of [VibrationServiceProtocol].
final class VibrationService implements VibrationServiceProtocol {
  /// Creates the real vibration service.
  VibrationService();

  /// Strong repeating alarm pattern: 500ms on, 200ms off, repeated.
  static const List<int> _alarmPattern = [
    0, 500, 200, 500, 200, 500, 200, 500, 200, 500,
  ];

  /// Short warning pulses: 100ms on, 300ms off, 100ms on.
  static const List<int> _warningPattern = [0, 100, 300, 100];

  /// Fake incoming-call pattern: classic 1s on, 2s off ring cadence.
  static const List<int> _fakeCallPattern = [
    0, 1000, 2000, 1000, 2000, 1000,
  ];

  @override
  Future<void> alarmPattern({bool isSimulation = false}) async {
    if (isSimulation) {
      developer.log('[SIM-BLOCK] vibration.alarmPattern');
      return;
    }
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(pattern: _alarmPattern, repeat: 0);
    }
  }

  @override
  Future<void> warningPattern({bool isSimulation = false}) async {
    if (isSimulation) {
      developer.log('[SIM-BLOCK] vibration.warningPattern');
      return;
    }
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(pattern: _warningPattern);
    }
  }

  @override
  Future<void> fakeCallPattern({bool isSimulation = false}) async {
    if (isSimulation) {
      developer.log('[SIM-BLOCK] vibration.fakeCallPattern');
      return;
    }
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(pattern: _fakeCallPattern, repeat: 0);
    }
  }

  @override
  Future<void> stop() async => Vibration.cancel();
}
