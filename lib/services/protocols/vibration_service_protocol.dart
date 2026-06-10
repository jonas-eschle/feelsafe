/// Abstract interface for haptic feedback used by event strategies.
///
/// Only the methods that strategies call are declared here.
abstract interface class VibrationServiceProtocol {
  /// Plays the three-pulse countdown warning pattern.
  ///
  /// Used by [CountdownWarningStrategy] when `CountdownWarningConfig.vibrate`
  /// is true. [isSimulation] is passed through; the service may choose to
  /// fire normally (vibration fires in simulation per spec 02 §Simulation
  /// behavior summary).
  Future<void> warningPattern({bool isSimulation = false});

  /// Plays a single 100 ms confirmation pulse.
  ///
  /// Used on button release or overlay dismiss to confirm the user action.
  /// Per spec 05:200.
  Future<void> confirmPulse();

  /// Plays the sustained alarm vibration pattern.
  ///
  /// Used by [LoudAlarmStrategy]. Always fires even in silent mode (alarm
  /// exception per spec 05 §VibrationService §Ringer Mode Respect).
  /// [isSimulation] is passed through for service-level logging.
  Future<void> alarmPattern({bool isSimulation = false});

  /// Plays a realistic phone-call incoming ring vibration pattern.
  ///
  /// Used by [FakeCallStrategy] to simulate an incoming call vibration.
  /// Per spec 05:208-210.
  Future<void> fakeCallPattern();

  /// Plays a single short pulse imitating a real notification vibration.
  ///
  /// Used by [DisguisedReminderStrategy] when the disguised reminder fires.
  /// Per spec 05:211-213.
  Future<void> reminderPattern();

  /// Cancels all active vibration immediately.
  ///
  /// Used by [LoudAlarmStrategy] cleanup.
  Future<void> cancel();
}
