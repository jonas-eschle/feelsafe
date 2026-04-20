/// Real audio-service implementation stub. Phase 9 fills bodies.
library;

import 'package:guardianangela/services/protocols/audio_service_protocol.dart';

/// Real platform-backed implementation of [AudioServiceProtocol].
final class AudioService implements AudioServiceProtocol {
  /// Creates the real audio service.
  AudioService();

  @override
  Future<void> playAlarm({
    bool maxVolume = true,
    bool isSimulation = false,
  }) async => throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> stopAlarm() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> playRingtone({
    String? assetPath,
    bool isSimulation = false,
  }) async => throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> stopRingtone() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> playVoiceRecording({
    required String assetPath,
    bool isSimulation = false,
  }) async => throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> stopVoiceRecording() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');
}
