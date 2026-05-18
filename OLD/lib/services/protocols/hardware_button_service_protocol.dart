/// `HardwareButtonServiceProtocol` — abstract contract for the
/// platform hardware-panic-button service.
///
/// Pure Dart. The concrete implementation bridges to native code in
/// Phase 4b and emits [HardwarePanicEvent] when a configured panic
/// pattern (e.g., volume up pressed 5 times within 500 ms) is
/// detected.
library;

/// A single detected hardware panic event.
final class HardwarePanicEvent {
  /// Creates a hardware panic event.
  ///
  /// [buttonType] — which hardware button fired (e.g., "volume",
  /// "power", "headset").
  /// [pattern] — the pattern id that matched (e.g., "5x_press").
  /// [timestamp] — when the final press completing the pattern was
  /// observed.
  const HardwarePanicEvent({
    required this.buttonType,
    required this.pattern,
    required this.timestamp,
  });

  /// Which hardware button type fired.
  final String buttonType;

  /// The pattern id that matched.
  final String pattern;

  /// When the matching press was observed.
  final DateTime timestamp;
}

/// Abstract contract for the hardware-panic-button service.
abstract class HardwareButtonServiceProtocol {
  /// Broadcast stream of completed panic detections.
  Stream<HardwarePanicEvent> get panicEvents;

  /// Starts listening for the configured panic pattern.
  ///
  /// [buttonType] — which hardware button to monitor (e.g.,
  /// "volume"). [pattern] — pattern id to match. [pressCount] —
  /// number of presses required, default 5. [pressWindowMs] —
  /// window in ms within which all presses must occur, default 500.
  /// [longPressDurationSeconds] — long-press threshold in seconds,
  /// default 2.0.
  Future<void> start({
    required String buttonType,
    required String pattern,
    int pressCount = 5,
    int pressWindowMs = 500,
    double longPressDurationSeconds = 2.0,
  });

  /// Stops listening.
  Future<void> stop();

  /// True iff the service is currently listening.
  bool get isListening;
}
