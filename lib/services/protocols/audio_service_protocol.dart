/// `AudioServiceProtocol` — abstract contract for playback of
/// alarms, ringtones, and voice recordings used by event strategies.
///
/// Pure Dart. The concrete implementation wraps platform audio
/// APIs in Phase 4b.
library;

/// Abstract contract for the session-audio service.
abstract class AudioServiceProtocol {
  /// Plays the loud-alarm tone.
  ///
  /// [maxVolume] — if true (default), raises system media volume to
  /// maximum for the duration of playback.
  /// [isSimulation] — if true, the implementation may short-circuit
  /// to a preview tone or no-op.
  Future<void> playAlarm({bool maxVolume = true, bool isSimulation = false});

  /// Stops the alarm (no-op if not playing).
  Future<void> stopAlarm();

  /// Plays a ringtone (used by fake-call steps).
  ///
  /// [assetPath] — optional bundled asset; null = platform default.
  /// [isSimulation] — if true, may short-circuit.
  Future<void> playRingtone({String? assetPath, bool isSimulation = false});

  /// Stops the ringtone (no-op if not playing).
  Future<void> stopRingtone();

  /// Plays a voice recording (e.g., fake-call pre-recorded clip).
  ///
  /// [assetPath] — bundled asset to play.
  /// [isSimulation] — if true, may short-circuit.
  Future<void> playVoiceRecording({
    required String assetPath,
    bool isSimulation = false,
  });

  /// Stops the voice recording (no-op if not playing).
  Future<void> stopVoiceRecording();
}
