import 'dart:async';
import 'dart:developer';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:guardianangela/services/protocols/recording_service_protocol.dart';

/// Maximum voice recording duration in seconds (Extra-39).
///
/// This is the single source of truth for the cap; [AudioRecorder] and
/// UI validation both reference this constant.
const int kMaxVoiceRecordingDurationSeconds = 120;

/// Validates that [duration] is acceptable for voice recordings.
///
/// Throws [ArgumentError] if [duration] is non-positive or exceeds
/// [kMaxVoiceRecordingDurationSeconds].
void validateVoiceRecordingDuration(Duration duration) {
  if (duration.inSeconds <= 0) {
    throw ArgumentError.value(
      duration,
      'duration',
      'Must be a positive duration',
    );
  }
  if (duration.inSeconds > kMaxVoiceRecordingDurationSeconds) {
    throw ArgumentError.value(
      duration,
      'duration',
      'Exceeds maximum voice recording duration of '
          '$kMaxVoiceRecordingDurationSeconds seconds',
    );
  }
}

/// Production [RecordingServiceProtocol] backed by `package:record`.
///
/// Recordings are saved as AAC-LC / M4A files in the app documents
/// directory. Filenames use timestamps to avoid revealing content.
///
/// Throws [StateError] if microphone permission is not granted when
/// [startRecording] is called (fail-loud per CLAUDE.md rule 8).
///
/// **Single constructor location rule:** no `RealRecordingService()`
/// call may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces).
class RealRecordingService implements RecordingServiceProtocol {
  /// Creates a [RealRecordingService].
  ///
  /// [recorder] may be injected for tests; defaults to a new [AudioRecorder].
  RealRecordingService({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  String? _currentPath;
  Timer? _capTimer;

  /// Whether a recording is currently in progress.
  bool get isRecording => _currentPath != null;

  /// The filesystem path of the active recording, or `null` if not recording.
  String? get currentPath => _currentPath;

  /// Starts recording to AAC-LC (M4A) in the app documents directory.
  ///
  /// [fileName] — optional base name without extension.
  /// Defaults to `recording_<epochMs>.m4a`.
  ///
  /// Returns the file path on success.
  /// Throws [StateError] if microphone permission is not granted.
  Future<String> startRecording({String? fileName}) async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw StateError(
        'Microphone permission is not granted. '
        'Request permission before calling startRecording().',
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final name =
        fileName ?? 'recording_${DateTime.now().millisecondsSinceEpoch}';
    final path = '${dir.path}/$name.m4a';

    await _recorder.start(const RecordConfig(), path: path);

    _currentPath = path;
    log('startRecording — $path', name: 'RecordingService');
    return path;
  }

  /// Stops an active recording and returns the file path.
  ///
  /// Returns `null` if no recording is in progress.
  Future<String?> stopRecording() async {
    if (!isRecording) return null;
    _capTimer?.cancel();
    _capTimer = null;

    final path = await _recorder.stop();
    _currentPath = null;
    log('stopRecording — saved: $path', name: 'RecordingService');
    return path;
  }

  /// Records for exactly [duration] then auto-stops.
  ///
  /// See [RecordingServiceProtocol.recordForDuration] for the Layer-3
  /// simulation guard contract.
  @override
  Future<String?> recordForDuration({
    required Duration duration,
    String? fileName,
    bool isSimulation = false,
  }) async {
    if (isSimulation) {
      log(
        '[SIM] recordForDuration — suppressed at Layer 3',
        name: 'RecordingService',
      );
      return null;
    }

    await startRecording(fileName: fileName);
    final completer = Completer<String?>();

    _capTimer = Timer(duration, () async {
      final saved = await stopRecording();
      if (!completer.isCompleted) completer.complete(saved);
    });

    return completer.future;
  }

  /// Starts a voice recording with a hard duration cap (Extra-39).
  ///
  /// [maxDuration] must be positive and ≤ [kMaxVoiceRecordingDurationSeconds].
  /// Throws [ArgumentError] on violation even in simulation (validation fires
  /// at dev time regardless of mode).
  ///
  /// When [isSimulation] is `true`, skips the actual recording but still
  /// validates the cap.
  Future<String?> startVoiceRecordingWithCap({
    required Duration maxDuration,
    String? fileName,
    bool isSimulation = false,
  }) async {
    validateVoiceRecordingDuration(maxDuration);

    if (isSimulation) {
      log(
        '[SIM] startVoiceRecordingWithCap — suppressed at Layer 3',
        name: 'RecordingService',
      );
      return null;
    }

    return recordForDuration(
      duration: maxDuration,
      fileName: fileName,
    );
  }

  /// Disposes the underlying [AudioRecorder].
  Future<void> dispose() async {
    _capTimer?.cancel();
    _capTimer = null;
    await _recorder.dispose();
    _currentPath = null;
  }
}
