/// `VibrationServiceProtocol` — abstract contract for haptic /
/// vibration patterns used by alarm, warning, and fake-call steps.
///
/// Pure Dart. The concrete implementation wraps platform haptic
/// APIs in Phase 4b.
library;

/// Abstract contract for the vibration service.
abstract class VibrationServiceProtocol {
  /// Plays the loud-alarm vibration pattern (high-intensity,
  /// repeating).
  Future<void> alarmPattern({bool isSimulation = false});

  /// Plays the countdown-warning vibration pattern (short pulses).
  Future<void> warningPattern({bool isSimulation = false});

  /// Plays the fake-call incoming-ring vibration pattern.
  Future<void> fakeCallPattern({bool isSimulation = false});

  /// Stops any currently playing vibration pattern.
  Future<void> stop();
}
