/// Abstract interface for haptic feedback used by event strategies.
///
/// Phase 5 supplies the concrete implementation. Only the methods that
/// strategies call are declared here.
abstract interface class VibrationServiceProtocol {
  /// Plays the three-pulse countdown warning pattern.
  ///
  /// Used by [CountdownWarningStrategy] when `CountdownWarningConfig.vibrate`
  /// is true. [isSimulation] is passed through; the service may choose to
  /// fire normally (vibration fires in simulation per spec 02 §Simulation
  /// behavior summary).
  Future<void> warningPattern({bool isSimulation = false});

  /// Plays the sustained alarm vibration pattern.
  ///
  /// Used by [LoudAlarmStrategy]. Always fires even in silent mode (alarm
  /// exception per spec 05 §VibrationService §Ringer Mode Respect).
  /// [isSimulation] is passed through for service-level logging.
  Future<void> alarmPattern({bool isSimulation = false});

  /// Cancels all active vibration immediately.
  ///
  /// Used by [LoudAlarmStrategy] cleanup.
  Future<void> cancel();
}
