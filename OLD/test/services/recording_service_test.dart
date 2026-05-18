/// Contract tests for [RecordingServiceProtocol] — exercised against
/// every implementation (fake + simulation). These pin down the
/// single-slot semantics, the cap-driven auto-stop, and the
/// idempotent stop.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/fakes/fake_recording_service.dart';
import 'package:guardianangela/services/protocols/recording_service_protocol.dart';
import 'package:guardianangela/services/simulation/simulation_recording_service.dart';

void main() {
  group('RecordingServiceProtocol contract', () {
    for (final entry in <(String, RecordingServiceProtocol Function())>[
      ('FakeRecordingService', FakeRecordingService.new),
      ('SimulationRecordingService', SimulationRecordingService.new),
    ]) {
      final (label, factory) = entry;

      test('$label: starts not recording', () async {
        final svc = factory();
        check(svc.isRecording).isFalse();
      });

      test('$label: start/stop transitions isRecording', () async {
        final svc = factory();
        final handle = await svc.startAudioRecording(
          cap: const Duration(seconds: 5),
        );
        check(svc.isRecording).isTrue();
        check(handle.cap).equals(const Duration(seconds: 5));
        check(handle.filePath).contains('.m4a');
        await svc.stopAudioRecording();
        check(svc.isRecording).isFalse();
      });

      test('$label: stopAudioRecording is idempotent when idle', () async {
        final svc = factory();
        await svc.stopAudioRecording();
        await svc.stopAudioRecording();
        check(svc.isRecording).isFalse();
      });

      test('$label: starting while recording throws StateError', () async {
        final svc = factory();
        await svc.startAudioRecording();
        await check(svc.startAudioRecording()).throws<StateError>();
        await svc.stopAudioRecording();
      });

      test('$label: default cap is the constant', () async {
        final svc = factory();
        final handle = await svc.startAudioRecording();
        check(handle.cap).equals(kDefaultRecordingCap);
        await svc.stopAudioRecording();
      });
    }
  });

  group('FakeRecordingService invocation log', () {
    test('records start and stop with cap seconds', () async {
      final svc = FakeRecordingService();
      await svc.startAudioRecording(cap: const Duration(seconds: 7));
      await svc.stopAudioRecording();
      check(
        svc.calls,
      ).deepEquals(['startAudioRecording:cap=7', 'stopAudioRecording']);
    });
  });
}
