/// Simulation implementation of [AudioServiceProtocol]. All methods
/// log via `dart:developer` and return a no-op.
library;

import 'dart:developer' as developer;

import 'package:guardianangela/services/protocols/audio_service_protocol.dart';

/// Simulation double for [AudioServiceProtocol].
final class SimulationAudioService implements AudioServiceProtocol {
  /// Creates the simulation audio service.
  SimulationAudioService();

  @override
  Future<void> playAlarm({
    bool maxVolume = true,
    bool isSimulation = false,
    Duration? gradualVolumeRamp,
  }) async {
    developer.log(
      '[SIM] audio.playAlarm maxVolume=$maxVolume '
      'ramp=${gradualVolumeRamp?.inSeconds}s',
    );
  }

  @override
  Future<void> stopAlarm() async {
    developer.log('[SIM] audio.stopAlarm');
  }

  @override
  Future<void> playRingtone({
    String? assetPath,
    bool isSimulation = false,
  }) async {
    developer.log('[SIM] audio.playRingtone ${assetPath ?? ''}');
  }

  @override
  Future<void> stopRingtone() async {
    developer.log('[SIM] audio.stopRingtone');
  }

  @override
  Future<void> playVoiceRecording({
    required String assetPath,
    bool isSimulation = false,
    String? ttsFallbackPhrase,
  }) async {
    developer.log(
      '[SIM] audio.playVoiceRecording $assetPath '
      'tts=${ttsFallbackPhrase ?? '<null>'}',
    );
  }

  @override
  Future<void> stopVoiceRecording() async {
    developer.log('[SIM] audio.stopVoiceRecording');
  }
}
