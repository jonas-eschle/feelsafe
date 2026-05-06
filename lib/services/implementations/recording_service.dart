/// Real platform-backed implementation of
/// [RecordingServiceProtocol].
///
/// Wraps the `record` package's `AudioRecorder` and writes capped
/// AAC-LC `.m4a` files to the app documents directory. Auto-stop is
/// driven by a Dart [Timer] keyed off the cap so cancellation is
/// deterministic without relying on the platform side.
///
/// Single-slot — only one recording at a time is supported.
library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:guardianangela/services/protocols/recording_service_protocol.dart';

/// Factory that builds a fresh [AudioRecorder]. Injected for tests so
/// the platform-channel dependency can be substituted with a fake.
typedef AudioRecorderFactory = AudioRecorder Function();

/// Resolves the directory recordings are written into. Injected for
/// tests so the `path_provider` plugin call can be stubbed.
typedef RecordingDirectoryResolver = Future<String> Function();

/// Real platform-backed implementation of
/// [RecordingServiceProtocol].
final class RecordingService implements RecordingServiceProtocol {
  /// Creates the recording service.
  ///
  /// [recorderFactory] defaults to building a fresh [AudioRecorder];
  /// tests inject a fake to exercise the plugin-boundary branches.
  /// [directoryResolver] defaults to [getApplicationDocumentsDirectory]
  /// to keep recordings in the app's private storage.
  RecordingService({
    AudioRecorderFactory? recorderFactory,
    RecordingDirectoryResolver? directoryResolver,
  }) : _recorderFactory = recorderFactory ?? AudioRecorder.new,
       _directoryResolver = directoryResolver ?? _defaultDirectoryResolver;

  static Future<String> _defaultDirectoryResolver() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  final AudioRecorderFactory _recorderFactory;
  final RecordingDirectoryResolver _directoryResolver;

  AudioRecorder? _recorder;
  Timer? _capTimer;

  @override
  bool get isRecording => _recorder != null;

  @override
  Future<RecordingHandle> startAudioRecording({
    Duration cap = kDefaultRecordingCap,
  }) async {
    if (_recorder != null) {
      throw StateError(
        'RecordingService.startAudioRecording: a recording is already '
        'in progress; call stopAudioRecording first.',
      );
    }
    final dir = await _directoryResolver();
    final filePath = p.join(
      dir,
      'recording_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
    final recorder = _recorderFactory();
    await recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: filePath,
    );
    _recorder = recorder;
    _capTimer = Timer(cap, () {
      developer.log(
        '[RecordingService] cap=${cap.inSeconds}s reached; auto-stopping',
      );
      // Fire-and-forget the auto-stop. The future settles before any
      // overlapping `startAudioRecording` because [_capTimer] is the
      // sole owner of the cap-timeout schedule.
      unawaited(stopAudioRecording());
    });
    return RecordingHandle(filePath: filePath, cap: cap);
  }

  @override
  Future<void> stopAudioRecording() async {
    final recorder = _recorder;
    final timer = _capTimer;
    _recorder = null;
    _capTimer = null;
    timer?.cancel();
    if (recorder == null) return;
    await recorder.stop();
    await recorder.dispose();
  }
}
