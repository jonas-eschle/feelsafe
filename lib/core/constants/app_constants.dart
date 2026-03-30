/// App-wide timing and limit constants.
abstract final class AppConstants {
  /// Default hold-button release countdown (Walk Mode).
  static const Duration walkModeCountdown = Duration(seconds: 10);

  /// Default date mode check-in interval.
  static const Duration dateModeInterval = Duration(minutes: 30);

  /// Default missed tolerance for date mode.
  static const int dateModeTolerance = 2;

  /// Default fake call ring duration.
  static const Duration fakeCallRingDuration = Duration(seconds: 30);

  /// Default SMS escalation step timeout.
  static const Duration smsStepTimeout = Duration(seconds: 15);

  /// Default alarm step timeout.
  static const Duration alarmStepTimeout = Duration(seconds: 30);

  /// Default emergency call step timeout.
  static const Duration emergencyCallTimeout = Duration(seconds: 10);

  /// Maximum number of emergency contacts.
  static const int maxContacts = 10;

  /// GPS update interval during session.
  static const Duration gpsUpdateInterval = Duration(seconds: 30);
}
