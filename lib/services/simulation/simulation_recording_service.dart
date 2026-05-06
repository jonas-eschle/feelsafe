/// Simulation implementation of [RecordingServiceProtocol]. All
/// methods log via `dart:developer` and return a deterministic fake
/// path so simulation runs do not touch the microphone.
library;

import 'dart:developer' as developer;

import 'package:guardianangela/services/protocols/recording_service_protocol.dart';

/// Simulation double for [RecordingServiceProtocol].
final class SimulationRecordingService implements RecordingServiceProtocol {
  /// Creates the simulation recording service.
  SimulationRecordingService();

  bool _isRecording = false;
  int _seq = 0;

  @override
  bool get isRecording => _isRecording;

  @override
  Future<RecordingHandle> startAudioRecording({
    Duration cap = kDefaultRecordingCap,
  }) async {
    if (_isRecording) {
      throw StateError(
        'SimulationRecordingService.startAudioRecording: a recording '
        'is already in progress; call stopAudioRecording first.',
      );
    }
    _isRecording = true;
    final filePath = '/sim/recordings/recording_${_seq++}.m4a';
    developer.log(
      '[SIM] recording.startAudioRecording cap=${cap.inSeconds}s '
      'path=$filePath',
    );
    return RecordingHandle(filePath: filePath, cap: cap);
  }

  @override
  Future<void> stopAudioRecording() async {
    if (!_isRecording) return;
    _isRecording = false;
    developer.log('[SIM] recording.stopAudioRecording');
  }
}
