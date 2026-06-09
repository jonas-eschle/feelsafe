// Host tests for the REAL RealRecordingService.
//
// Drives the genuine production logic — the permission gate, the file-path
// construction, the auto-stop cap Timer (under fakeAsync), and the Extra-39
// duration validation — against a mocked [AudioRecorder] (record 6.x) and a
// mocked path_provider channel. NOT the SimulationRecordingService (that is
// covered in recording_service_test.dart). Voice recording is a safety-
// critical evidence path, so the real start/stop/cap lifecycle is exercised.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:record/record.dart';

import 'package:guardianangela/services/recording_service.dart';

// ---------------------------------------------------------------------------
// Mock seams
// ---------------------------------------------------------------------------

/// Mock [AudioRecorder] so no real microphone / platform channel is touched.
class _MockRecorder extends Mock implements AudioRecorder {}

class _FakeRecordConfig extends Fake implements RecordConfig {}

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

late Directory _tmpDir;

void _installPathProvider() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async {
          if (call.method == 'getApplicationDocumentsDirectory') {
            return _tmpDir.path;
          }
          return null;
        },
      );
}

void _removePathProvider() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      );
}

/// Builds a [RealRecordingService] over a mock recorder pre-stubbed for the
/// happy path ([hasPermission] → true, [start]/[stop]/[dispose] resolve).
(_MockRecorder, RealRecordingService) _build({
  bool hasPermission = true,
  String? stopPath = '/docs/saved.m4a',
}) {
  final rec = _MockRecorder();
  when(rec.hasPermission).thenAnswer((_) async => hasPermission);
  when(
    () => rec.start(any(), path: any(named: 'path')),
  ).thenAnswer((_) async {});
  when(rec.stop).thenAnswer((_) async => stopPath);
  when(rec.dispose).thenAnswer((_) async {});
  return (rec, RealRecordingService(recorder: rec));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(_FakeRecordConfig());
  });

  setUp(() async {
    _tmpDir = await Directory.systemTemp.createTemp('ga_rec_');
    _installPathProvider();
  });

  tearDown(() async {
    _removePathProvider();
    await _tmpDir.delete(recursive: true);
  });

  // -------------------------------------------------------------------------
  // startRecording — permission gate + path construction
  // -------------------------------------------------------------------------
  group('RealRecordingService.startRecording', () {
    test('throws StateError when microphone permission is denied', () async {
      final (_, svc) = _build(hasPermission: false);
      await check(svc.startRecording()).throws<StateError>();
    });

    test('does NOT start the recorder when permission is denied', () async {
      final (rec, svc) = _build(hasPermission: false);
      await svc.startRecording().onError((_, _) => '');
      verifyNever(() => rec.start(any(), path: any(named: 'path')));
    });

    test('returns a path under the documents dir ending with the name '
        'and .m4a', () async {
      final (_, svc) = _build();
      final path = await svc.startRecording(fileName: 'clip_a');
      check(path).startsWith(_tmpDir.path);
      check(path).endsWith('clip_a.m4a');
    });

    test('default file name is recording_<epochMs>.m4a', () async {
      final (_, svc) = _build();
      final path = await svc.startRecording();
      check(RegExp(r'recording_\d+\.m4a$').hasMatch(path)).isTrue();
    });

    test('passes the resolved path to recorder.start', () async {
      final (rec, svc) = _build();
      final path = await svc.startRecording(fileName: 'evidence');
      final captured = verify(
        () => rec.start(any(), path: captureAny(named: 'path')),
      ).captured.single;
      check(captured as String).equals(path);
    });

    test('isRecording flips true and currentPath is set after start', () async {
      final (_, svc) = _build();
      check(svc.isRecording).isFalse();
      check(svc.currentPath).isNull();
      final path = await svc.startRecording();
      check(svc.isRecording).isTrue();
      check(svc.currentPath).equals(path);
    });
  });

  // -------------------------------------------------------------------------
  // stopRecording
  // -------------------------------------------------------------------------
  group('RealRecordingService.stopRecording', () {
    test('returns null when no recording is in progress', () async {
      final (rec, svc) = _build();
      final result = await svc.stopRecording();
      check(result).isNull();
      verifyNever(rec.stop);
    });

    test('stops the recorder and returns the saved path', () async {
      final (_, svc) = _build(stopPath: '/docs/final.m4a');
      await svc.startRecording();
      final result = await svc.stopRecording();
      check(result).equals('/docs/final.m4a');
    });

    test('clears isRecording / currentPath after stop', () async {
      final (_, svc) = _build();
      await svc.startRecording();
      await svc.stopRecording();
      check(svc.isRecording).isFalse();
      check(svc.currentPath).isNull();
    });
  });

  // -------------------------------------------------------------------------
  // recordForDuration — Layer-3 guard + the auto-stop cap Timer
  // -------------------------------------------------------------------------
  group('RealRecordingService.recordForDuration', () {
    test('isSimulation=true is a no-op that returns null and never '
        'touches the recorder', () async {
      final (rec, svc) = _build();
      final result = await svc.recordForDuration(
        duration: const Duration(seconds: 10),
        isSimulation: true,
      );
      check(result).isNull();
      verifyNever(rec.hasPermission);
      verifyNever(() => rec.start(any(), path: any(named: 'path')));
    });

    test('auto-stops after exactly the requested duration (fakeAsync) and '
        'completes with the saved path', () {
      fakeAsync((async) {
        final rec = _MockRecorder();
        when(rec.hasPermission).thenAnswer((_) async => true);
        when(
          () => rec.start(any(), path: any(named: 'path')),
        ).thenAnswer((_) async {});
        when(rec.stop).thenAnswer((_) async => '/docs/capped.m4a');
        final svc = RealRecordingService(recorder: rec);

        String? captured;
        var completed = false;
        svc.recordForDuration(duration: const Duration(seconds: 30)).then((p) {
          captured = p;
          completed = true;
        });

        // Let startRecording's awaits resolve.
        async.flushMicrotasks();
        check(svc.isRecording).isTrue();

        // Not yet elapsed — still recording, future not completed.
        async.elapse(const Duration(seconds: 29));
        check(completed).isFalse();
        check(svc.isRecording).isTrue();

        // Cross the boundary — the cap Timer fires stopRecording.
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        check(completed).isTrue();
        check(captured).equals('/docs/capped.m4a');
        check(svc.isRecording).isFalse();
        verify(rec.stop).called(1);
      });
    });
  });

  // -------------------------------------------------------------------------
  // startVoiceRecordingWithCap — Extra-39 validation always fires
  // -------------------------------------------------------------------------
  group('RealRecordingService.startVoiceRecordingWithCap', () {
    test(
      'throws ArgumentError on a zero duration even in simulation',
      () async {
        final (_, svc) = _build();
        await check(
          svc.startVoiceRecordingWithCap(
            maxDuration: Duration.zero,
            isSimulation: true,
          ),
        ).throws<ArgumentError>();
      },
    );

    test('throws ArgumentError above the 120s cap before recording', () async {
      final (rec, svc) = _build();
      await check(
        svc.startVoiceRecordingWithCap(
          maxDuration: const Duration(seconds: 121),
        ),
      ).throws<ArgumentError>();
      verifyNever(() => rec.start(any(), path: any(named: 'path')));
    });

    test('isSimulation=true returns null after passing validation', () async {
      final (rec, svc) = _build();
      final result = await svc.startVoiceRecordingWithCap(
        maxDuration: const Duration(seconds: 60),
        isSimulation: true,
      );
      check(result).isNull();
      verifyNever(() => rec.start(any(), path: any(named: 'path')));
    });

    test('valid duration delegates to recordForDuration and starts '
        'the recorder', () {
      fakeAsync((async) {
        final rec = _MockRecorder();
        when(rec.hasPermission).thenAnswer((_) async => true);
        when(
          () => rec.start(any(), path: any(named: 'path')),
        ).thenAnswer((_) async {});
        when(rec.stop).thenAnswer((_) async => '/docs/voice.m4a');
        final svc = RealRecordingService(recorder: rec);

        svc.startVoiceRecordingWithCap(
          maxDuration: const Duration(seconds: 5),
          fileName: 'voice',
        );
        async.flushMicrotasks();
        verify(() => rec.start(any(), path: any(named: 'path'))).called(1);

        // The cap Timer auto-stops at 5s.
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        verify(rec.stop).called(1);
      });
    });
  });

  // -------------------------------------------------------------------------
  // dispose
  // -------------------------------------------------------------------------
  group('RealRecordingService.dispose', () {
    test('disposes the recorder and clears state', () async {
      final (rec, svc) = _build();
      await svc.startRecording();
      await svc.dispose();
      verify(rec.dispose).called(1);
      check(svc.currentPath).isNull();
    });
  });
}
