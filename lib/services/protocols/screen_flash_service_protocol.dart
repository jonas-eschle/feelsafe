/// Abstract interface for screen flash control used by event strategies.
///
/// Only the methods that strategies call are declared here.
abstract interface class ScreenFlashServiceProtocol {
  /// Starts a white/red alternating screen flash at the given speed.
  ///
  /// [speed] must be either `'slow'` (1000 ms cycle, default for
  /// photosensitive users) or `'fast'` (500 ms cycle). Used by
  /// [LoudAlarmStrategy] when `LoudAlarmConfig.flashScreen` is true.
  ///
  /// A photosensitivity warning MUST be shown in the mode editor before
  /// the user can enable screen flash (spec 02 §loudAlarm §Screen Flash).
  Future<void> startScreenFlash({String speed = 'slow'});

  /// Stops any active screen flash immediately.
  ///
  /// Safe to call multiple times. Used by [LoudAlarmStrategy] cleanup.
  Future<void> stopScreenFlash();
}
