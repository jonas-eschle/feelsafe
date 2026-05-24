/// Default duration in seconds for the gradual volume ramp on alarm playback.
///
/// Per spec 05:91-94 (Q33). Configurable via
/// `AppSettings.alarmGradualVolumeDurationSeconds`; this constant is the
/// fallback when settings are unavailable.
const int kDefaultAlarmRampSeconds = 5;

/// Abstract interface for audio playback used by event strategies.
///
/// Phase 5 supplies the concrete implementation. This file pins only
/// the methods that the 9 strategies actually call; the full audio API
/// lives in `lib/services/audio_service.dart` (Phase 5).
abstract interface class AudioServiceProtocol {
  /// Plays a ringtone sound, looping indefinitely until [stop] is called.
  ///
  /// [assetPath] is a Flutter asset path or file path to the ringtone audio.
  /// When `null`, the call-style default for the current configuration is used
  /// (per spec 05:65-75). Used by [FakeCallStrategy].
  Future<void> playRingtone(String? assetPath);

  /// Plays the default alarm (siren) at maximum volume.
  ///
  /// Delegates to [playAlarmWithConfig] with `soundChoice: 'siren'` and
  /// `volume: 1.0`. Per spec 05:79-82.
  Future<void> playAlarm();

  /// Plays an alarm sound with the given parameters.
  ///
  /// [soundChoice] is `'siren'` (default) or `'custom'`. [customSoundPath]
  /// is required when [soundChoice] is `'custom'`. [volume] is 0.0–1.0
  /// (clamped). [isSimulation] suppresses playback at the service level
  /// (Layer 3 defense — strategies also guard at Layer 2).
  ///
  /// When gradual ramp is enabled in settings, volume ramps linearly from 0
  /// to [volume] over [rampSeconds] seconds using `Timer.periodic(100ms)`.
  Future<void> playAlarmWithConfig({
    String soundChoice = 'siren',
    String? customSoundPath,
    double volume = 1.0,
    bool isSimulation = false,
    int rampSeconds = kDefaultAlarmRampSeconds,
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
