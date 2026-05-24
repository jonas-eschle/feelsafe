import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:guardianangela/services/protocols/recording_service_protocol.dart';
import 'package:guardianangela/services/recording_service.dart';

/// Recorded call entry for [SimulationRecordingService].
final class RecordingCall {
  /// Creates a [RecordingCall].
  const RecordingCall({
    required this.method,
    this.duration,
    this.fileName,
    this.isSimulation = false,
  });

  /// Method name: `'recordForDuration'`.
  final String method;

  /// The duration passed to [RecordingServiceProtocol.recordForDuration].
  final Duration? duration;

  /// The filename override, if any.
  final String? fileName;

  /// Whether [isSimulation] was `true` for this call.
  final bool isSimulation;
}

/// Simulation [RecordingServiceProtocol] for tests and simulation isolates.
///
/// Writes a zero-byte sentinel file at the requested path so callers see a
/// real [File] object. Never calls the native microphone.
///
/// Records every call in [calls] so tests can assert invocation details.
class SimulationRecordingService implements RecordingServiceProtocol {
  /// Creates a [SimulationRecordingService].
  ///
  /// [useRealDirectory] controls whether the sentinel file is written to the
  /// real documents directory (`true`, default) or skipped for pure-Dart
  /// unit tests (`false`, returns a virtual path only).
  SimulationRecordingService({bool useRealDirectory = false})
    : _useRealDirectory = useRealDirectory;

  final bool _useRealDirectory;

  /// All calls to [recordForDuration] (the only protocol method).
  final List<RecordingCall> calls = [];

  /// Paths of all sentinel files created during this service's lifetime.
  final List<String> createdPaths = [];

  @override
  Future<String?> recordForDuration({
    required Duration duration,
    String? fileName,
    bool isSimulation = false,
  }) async {
    calls.add(
      RecordingCall(
        method: 'recordForDuration',
        duration: duration,
        fileName: fileName,
        isSimulation: isSimulation,
      ),
    );

    if (isSimulation) {
      log(
        '[SIM] recordForDuration — Layer 3 guard fires; no recording',
        name: 'SimulationRecordingService',
      );
      return null;
    }

    final path = await _buildPath(fileName);
    await _writeEmptySentinel(path);
    createdPaths.add(path);
    return path;
  }

  /// Validates the cap and records the call — mirrors [RealRecordingService]
  /// behaviour for dev-time validation.
  Future<String?> startVoiceRecordingWithCap({
    required Duration maxDuration,
    String? fileName,
    bool isSimulation = false,
  }) async {
    // Validation fires even in simulation (Extra-39 spec contract).
    validateVoiceRecordingDuration(maxDuration);

    return recordForDuration(
      duration: maxDuration,
      fileName: fileName,
      isSimulation: isSimulation,
    );
  }

  /// Clears [calls] and [createdPaths].
  void reset() {
    calls.clear();
    createdPaths.clear();
  }

  Future<String> _buildPath(String? fileName) async {
    if (_useRealDirectory) {
      final dir = await getApplicationDocumentsDirectory();
      final name =
          fileName ?? 'sim_recording_${DateTime.now().millisecondsSinceEpoch}';
      return '${dir.path}/$name.m4a';
    } else {
      final name =
          fileName ?? 'sim_recording_${DateTime.now().millisecondsSinceEpoch}';
      return '/tmp/$name.m4a';
    }
  }

  Future<void> _writeEmptySentinel(String path) async {
    try {
      await File(path).create(recursive: true);
    } catch (_) {
      // Best-effort: if the directory is not writable in tests, skip.
    }
  }
}
