/// `FlashServiceProtocol` — abstract contract for the camera-LED
/// flashlight strobe used by `LoudAlarmStrategy` (audit Q2).
///
/// Pure Dart. The real implementation wraps the native torch APIs
/// (Android `CameraManager.setTorchMode`, iOS `AVCaptureDevice`).
/// When the platform reports no flashlight, the real implementation
/// silently no-ops — the loud-alarm step degrades to audio + vibration
/// only, matching the existing UX promise that strategies are best
/// effort.
library;

/// Default strobe interval — half on, half off — when the caller
/// passes nothing. Matches `LoudAlarmConfig.flashSpeedMs = 500`.
const Duration kDefaultFlashStrobeInterval = Duration(milliseconds: 500);

/// Abstract contract for the camera-flashlight strobe service.
///
/// Single-slot — calling [startStrobe] while a strobe is already
/// running rebases the schedule with the new interval (the previous
/// timer is cancelled). [stopStrobe] is idempotent.
abstract class FlashServiceProtocol {
  /// Begins strobing the camera flashlight at [interval] (half on,
  /// half off). On platforms without a flashlight, this is a no-op.
  ///
  /// [interval] defaults to [kDefaultFlashStrobeInterval] (500ms).
  Future<void> startStrobe({Duration interval = kDefaultFlashStrobeInterval});

  /// Stops the strobe. No-op if not currently strobing. Idempotent.
  Future<void> stopStrobe();

  /// True iff the flashlight is currently being strobed by this
  /// service.
  bool get isStrobing;
}
