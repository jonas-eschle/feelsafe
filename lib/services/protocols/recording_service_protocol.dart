/// Abstract interface for audio recording used by event strategies.
///
/// Phase 5 supplies the concrete implementation. Only the methods that
/// strategies call are declared here.
abstract interface class RecordingServiceProtocol {
  /// Records audio for the given [duration] and returns the file path.
  ///
  /// Returns the path to the recorded M4A file on success, or `null`
  /// if permission was denied, the device has no microphone, or recording
  /// fails. Called fire-and-forget by [SmsContactStrategy] when
  /// `SmsContactConfig.autoRecordAudio` is true — the recording runs
  /// in parallel with the SMS sends.
  ///
  /// [fileName] is an optional base name (without extension). Null ⇒
  /// the service generates a timestamped default name.
  ///
  /// [isSimulation] suppresses the actual recording at the service level
  /// (Layer 3 defense). The strategy guards at Layer 2.
  Future<String?> recordForDuration({
    required Duration duration,
    String? fileName,
    bool isSimulation = false,
  });
}
