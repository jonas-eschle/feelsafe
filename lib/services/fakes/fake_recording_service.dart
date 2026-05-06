/// Deterministic fake implementation of [RecordingServiceProtocol]
/// for tests. Every call is recorded to [calls]; no platform plugin
/// is touched.
library;

import 'package:guardianangela/services/protocols/recording_service_protocol.dart';

/// Test double for [RecordingServiceProtocol].
final class FakeRecordingService implements RecordingServiceProtocol {
  /// Creates a fake recording service.
  FakeRecordingService();

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

  bool _isRecording = false;
  int _seq = 0;

  @override
  bool get isRecording => _isRecording;

  @override
  Future<RecordingHandle> startAudioRecording({
    Duration cap = kDefaultRecordingCap,
  }) async {
    calls.add('startAudioRecording:cap=${cap.inSeconds}');
    if (_isRecording) {
      throw StateError(
        'FakeRecordingService.startAudioRecording: a recording is '
        'already in progress; call stopAudioRecording first.',
      );
    }
    _isRecording = true;
    final filePath = '/fake/recordings/recording_${_seq++}.m4a';
    return RecordingHandle(filePath: filePath, cap: cap);
  }

  @override
  Future<void> stopAudioRecording() async {
    calls.add('stopAudioRecording');
    _isRecording = false;
  }
}
