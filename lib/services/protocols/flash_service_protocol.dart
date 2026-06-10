/// Abstract interface for camera flashlight control used by event strategies.
///
/// Only the methods that strategies call are declared here.
abstract interface class FlashServiceProtocol {
  /// Starts the SOS morse-code strobe pattern on the camera flash.
  ///
  /// Pattern: `··· −−− ···` (SOS). Used by [LoudAlarmStrategy] when
  /// `LoudAlarmConfig.flashLight` is true. Falls back gracefully if no
  /// flashlight is available.
  Future<void> startSosFlash();

  /// Stops any active camera flash pattern.
  ///
  /// Safe to call multiple times. Used by [LoudAlarmStrategy] cleanup.
  Future<void> stopFlash();
}
