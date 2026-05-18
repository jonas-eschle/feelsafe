/// `RecordingServiceProtocol` — abstract contract for capping
/// microphone-backed audio recordings (used by the auto-record-audio
/// step config and the fake-call voice-recording flow).
///
/// **Audio-only.** No video capture is supported, by design: the
/// emergency-evidence model in spec 11 §DE-2 records only audio so
/// the file size stays manageable and the privacy/storage tradeoff
/// is bounded.
///
/// Pure Dart. Wraps the platform-side `record` package in
/// `lib/services/implementations/recording_service.dart`.
library;

/// Default upper bound for a single recording. Hard cap so the
/// auto-record-audio step cannot fill the user's storage. Strategies
/// that need a longer window must call [RecordingServiceProtocol]
/// multiple times or pass a custom [Duration] to `startAudioRecording`.
const Duration kDefaultRecordingCap = Duration(seconds: 60);

/// Handle returned by [RecordingServiceProtocol.startAudioRecording].
///
/// Carries the absolute filesystem path the recording is being
/// written to so callers can reference it after the recording stops
/// (e.g., for inclusion in an emergency SMS or session log).
final class RecordingHandle {
  /// Creates a handle.
  const RecordingHandle({required this.filePath, required this.cap});

  /// Absolute path to the file the recording is being written to.
  final String filePath;

  /// The cap that was applied to this recording. The implementation
  /// auto-stops at this duration even if `stopAudioRecording` is never
  /// called.
  final Duration cap;
}

/// Abstract contract for the audio-recording service.
///
/// Sole responsibility: start/stop a single capped microphone capture.
/// The service is single-slot — calling `startAudioRecording` while a
/// recording is already in flight throws [StateError].
abstract class RecordingServiceProtocol {
  /// Begins recording the microphone to a fresh AAC-LC `.m4a` file in
  /// the app documents directory. Auto-stops after [cap].
  ///
  /// [cap] defaults to [kDefaultRecordingCap] (60s).
  ///
  /// Throws [StateError] if a recording is already in progress.
  Future<RecordingHandle> startAudioRecording({
    Duration cap = kDefaultRecordingCap,
  });

  /// Stops the in-flight recording, if any. No-op when nothing is
  /// recording. Idempotent.
  Future<void> stopAudioRecording();

  /// True iff a recording is currently in progress.
  bool get isRecording;
}
