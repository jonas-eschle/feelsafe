/// Abstract interface for audio playback used by event strategies.
///
/// Phase 5 supplies the concrete implementation. This file pins only
/// the methods that the 9 strategies actually call; the full audio API
/// lives in `lib/services/audio_service.dart` (Phase 5).
abstract interface class AudioServiceProtocol {
  /// Plays an alarm sound with the given parameters.
  ///
  /// [soundChoice] is `'siren'` (default) or `'custom'`. [customSoundPath]
  /// is required when [soundChoice] is `'custom'`. [volume] is 0.0–1.0
  /// (clamped). [isSimulation] suppresses playback at the service level
  /// (Layer 3 defense — strategies also guard at Layer 2).
  Future<void> playAlarmWithConfig({
    String soundChoice = 'siren',
    String? customSoundPath,
    double volume = 1.0,
    bool isSimulation = false,
  });

  /// Plays an audio asset at the given path.
  ///
  /// Used by [CountdownWarningStrategy] for the optional countdown sound.
  /// [assetPath] must be a Flutter asset path (e.g.,
  /// `'assets/audio/countdown_warning.ogg'`).
  Future<void> playSound(String assetPath);

  /// Stops any currently playing audio.
  ///
  /// Safe to call multiple times. Used by [LoudAlarmStrategy] cleanup
  /// when the step is cancelled.
  Future<void> stop();
}
