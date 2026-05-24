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
  ///
  /// [alarmDndOverride] enables Do Not Disturb bypass via STREAM_ALARM routing
  /// on Android (spec 05:81). Default `true` per spec. Phase-6 controller
  /// plumbs [AppSettings.alarmDndOverride] here at session start.
  Future<void> playAlarm({bool alarmDndOverride = true});

  /// Plays an alarm sound with the given parameters.
  ///
  /// [soundChoice] is `'siren'` (default) or `'custom'`. [customSoundPath]
  /// is required when [soundChoice] is `'custom'`. [volume] is 0.0–1.0
  /// (clamped). [isSimulation] suppresses playback at the service level
  /// (Layer 3 defense — strategies also guard at Layer 2).
  ///
  /// When gradual ramp is enabled in settings, volume ramps linearly from 0
  /// to [volume] over [rampSeconds] seconds using `Timer.periodic(100ms)`.
  ///
  /// [alarmDndOverride] mirrors [AppSettings.alarmDndOverride] — when `true`
  /// the audio session is configured with [AndroidAudioUsage.alarm] to route
  /// through STREAM_ALARM, bypassing silent/vibrate modes (spec 05:81).
  /// Default `true`. Phase-6 controller plumbs the setting value here.
  Future<void> playAlarmWithConfig({
    String soundChoice = 'siren',
    String? customSoundPath,
    double volume = 1.0,
    bool isSimulation = false,
    int rampSeconds = kDefaultAlarmRampSeconds,
    bool alarmDndOverride = true,
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
