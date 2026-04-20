/// Deterministic fake implementation of [AudioServiceProtocol] for
/// tests. Every call is recorded to [calls].
library;

import 'package:guardianangela/services/protocols/audio_service_protocol.dart';

/// Test double for [AudioServiceProtocol].
final class FakeAudioService implements AudioServiceProtocol {
  /// Creates a fake audio service.
  FakeAudioService();

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

  @override
  Future<void> playAlarm({
    bool maxVolume = true,
    bool isSimulation = false,
  }) async {
    calls.add('playAlarm:maxVolume=$maxVolume');
  }

  @override
  Future<void> stopAlarm() async {
    calls.add('stopAlarm');
  }

  @override
  Future<void> playRingtone({
    String? assetPath,
    bool isSimulation = false,
  }) async {
    calls.add('playRingtone:${assetPath ?? ''}');
  }

  @override
  Future<void> stopRingtone() async {
    calls.add('stopRingtone');
  }

  @override
  Future<void> playVoiceRecording({
    required String assetPath,
    bool isSimulation = false,
  }) async {
    calls.add('playVoiceRecording:$assetPath');
  }

  @override
  Future<void> stopVoiceRecording() async {
    calls.add('stopVoiceRecording');
  }

  /// Tears down any held state (no-op here; provided for symmetry).
  void dispose() {}
}
