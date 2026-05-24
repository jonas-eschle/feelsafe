import 'package:guardianangela/services/protocols/audio_service_protocol.dart';

/// Recorded call entry for [SimulationAudioService].
final class AudioCall {
  /// Creates an [AudioCall].
  const AudioCall({
    required this.method,
    this.soundChoice,
    this.customSoundPath,
    this.volume,
    this.assetPath,
    this.filePath,
    this.useSpeaker,
    this.isSimulation = false,
  });

  /// Method name: one of `'playAlarmWithConfig'`, `'playSound'`, `'stop'`,
  /// `'playVoiceRecording'`.
  final String method;

  /// [soundChoice] from [playAlarmWithConfig], or `null`.
  final String? soundChoice;

  /// [customSoundPath] from [playAlarmWithConfig], or `null`.
  final String? customSoundPath;

  /// [volume] from [playAlarmWithConfig], or `null`.
  final double? volume;

  /// [assetPath] from [playSound], or `null`.
  final String? assetPath;

  /// [filePath] from [playVoiceRecording], or `null`.
  final String? filePath;

  /// [useSpeaker] from [playVoiceRecording], or `null`.
  final bool? useSpeaker;

  /// Whether [isSimulation] was `true` when this call was made.
  final bool isSimulation;

  @override
  String toString() => 'AudioCall(method: $method)';
}

/// Simulation [AudioServiceProtocol] for tests and simulation isolates.
///
/// Records every method invocation into [calls]. Respects the Layer-3
/// simulation guard: when [isSimulation] is `true`, [playAlarmWithConfig]
/// and [playVoiceRecording] are no-ops and the call is recorded with
/// [AudioCall.isSimulation] set.
///
/// Never calls `just_audio` or any native audio API.
class SimulationAudioService implements AudioServiceProtocol {
  /// Creates a [SimulationAudioService].
  SimulationAudioService();

  /// All method invocations since construction or last [reset].
  final List<AudioCall> calls = [];

  /// Whether [stop] has been called at least once.
  bool get wasStopped => calls.any((c) => c.method == 'stop');

  /// Clears [calls].
  void reset() => calls.clear();

  @override
  Future<void> playAlarmWithConfig({
    String soundChoice = 'siren',
    String? customSoundPath,
    double volume = 1.0,
    bool isSimulation = false,
  }) async {
    calls.add(
      AudioCall(
        method: 'playAlarmWithConfig',
        soundChoice: soundChoice,
        customSoundPath: customSoundPath,
        volume: volume,
        isSimulation: isSimulation,
      ),
    );
    // Layer-3 guard: no-op when isSimulation is true.
    if (isSimulation) return;
    // Real simulation: no audio output, just record.
  }

  @override
  Future<void> playSound(String assetPath) async {
    calls.add(AudioCall(method: 'playSound', assetPath: assetPath));
  }

  @override
  Future<void> stop() async {
    calls.add(const AudioCall(method: 'stop'));
  }

  /// Records a [playVoiceRecording] invocation. Layer-3 guard applies when
  /// [isSimulation] is `true`.
  Future<void> playVoiceRecording(
    String? filePath, {
    bool useSpeaker = false,
    bool isSimulation = false,
  }) async {
    calls.add(
      AudioCall(
        method: 'playVoiceRecording',
        filePath: filePath,
        useSpeaker: useSpeaker,
        isSimulation: isSimulation,
      ),
    );
    // Layer-3 guard: no-op when isSimulation is true.
    if (isSimulation) return;
  }
}
