/// Contract tests for [ScreenFlashServiceProtocol] — exercised
/// against every implementation (fake + simulation + real). These
/// pin down isFlashing, idempotent stop, the alternating-tick
/// stream, and the stop-tick fallback.
library;

import 'dart:async';

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/fakes/fake_screen_flash_service.dart';
import 'package:guardianangela/services/implementations/screen_flash_service.dart';
import 'package:guardianangela/services/protocols/screen_flash_service_protocol.dart';
import 'package:guardianangela/services/simulation/simulation_screen_flash_service.dart';

void main() {
  group('ScreenFlashServiceProtocol contract', () {
    for (final entry in <(String, ScreenFlashServiceProtocol Function())>[
      ('FakeScreenFlashService', FakeScreenFlashService.new),
      ('SimulationScreenFlashService', SimulationScreenFlashService.new),
      ('ScreenFlashService', ScreenFlashService.new),
    ]) {
      final (label, factory) = entry;

      test('$label: starts not flashing', () async {
        final svc = factory();
        check(svc.isFlashing).isFalse();
      });

      test('$label: start flips isFlashing, stop clears it', () async {
        final svc = factory();
        await svc.start(interval: const Duration(milliseconds: 200));
        check(svc.isFlashing).isTrue();
        await svc.stop();
        check(svc.isFlashing).isFalse();
      });

      test('$label: stop is idempotent when idle', () async {
        final svc = factory();
        await svc.stop();
        await svc.stop();
        check(svc.isFlashing).isFalse();
      });
    }
  });

  group('FakeScreenFlashService invocation log', () {
    test('records start interval and stop', () async {
      final svc = FakeScreenFlashService();
      await svc.start(interval: const Duration(milliseconds: 750));
      await svc.stop();
      check(svc.calls).deepEquals(['start:750', 'stop']);
      svc.dispose();
    });

    test('emit pushes a tick onto the stream', () async {
      final svc = FakeScreenFlashService();
      final received = <bool>[];
      final sub = svc.ticks.listen(received.add);
      svc.emit(true);
      svc.emit(false);
      await Future<void>.delayed(Duration.zero);
      check(received).deepEquals([true, false]);
      await sub.cancel();
      svc.dispose();
    });
  });

  group('ScreenFlashService (real impl)', () {
    test('emits alternating ticks on each half-cycle', () {
      fakeAsync((async) {
        final svc = ScreenFlashService();
        final received = <bool>[];
        final sub = svc.ticks.listen(received.add);
        unawaited(svc.start(interval: const Duration(milliseconds: 100)));
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 250));
        // First tick is fired immediately on start, then alternates
        // every half-cycle (50 ms here). Expect at least 4 ticks in
        // 250 ms.
        check(received.length).isGreaterOrEqual(4);
        check(received.first).equals(true);
        unawaited(svc.stop());
        async.flushMicrotasks();
        unawaited(sub.cancel());
        unawaited(svc.dispose());
      });
    });

    test('stop emits a final off tick when last phase was on', () {
      fakeAsync((async) {
        final svc = ScreenFlashService();
        final received = <bool>[];
        final sub = svc.ticks.listen(received.add);
        unawaited(svc.start(interval: const Duration(milliseconds: 100)));
        async.flushMicrotasks();
        unawaited(svc.stop());
        async.flushMicrotasks();
        check(received.last).equals(false);
        unawaited(sub.cancel());
        unawaited(svc.dispose());
      });
    });

    test('start rejects sub-microsecond intervals', () async {
      final svc = ScreenFlashService();
      await check(svc.start(interval: Duration.zero)).throws<ArgumentError>();
      await svc.dispose();
    });

    test('dispose closes the broadcast stream', () async {
      final svc = ScreenFlashService();
      await svc.dispose();
      // Subsequent stop is still safe and does not throw.
      await svc.stop();
    });
  });
}
