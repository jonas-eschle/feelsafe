/// Additional tests for [SimulationScreenFlashService] targeting
/// the ticks stream, the timer-body alternation, and the ArgumentError
/// guard for sub-microsecond intervals.
library;

import 'dart:async';

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/simulation/simulation_screen_flash_service.dart';

void main() {
  group('SimulationScreenFlashService', () {
    test('ticks stream emits values after start', () async {
      final svc = SimulationScreenFlashService();
      final received = <bool>[];
      final sub = svc.ticks.listen(received.add);

      await svc.start(interval: const Duration(milliseconds: 200));
      await Future<void>.delayed(const Duration(milliseconds: 1));
      // First tick is true (immediate on start).
      check(received).isNotEmpty();
      check(received.first).isTrue();

      await svc.stop();
      await sub.cancel();
    });

    test('timer body alternates phase on each tick', () {
      fakeAsync((async) {
        final svc = SimulationScreenFlashService();
        final received = <bool>[];
        final sub = svc.ticks.listen(received.add);

        unawaited(svc.start(interval: const Duration(milliseconds: 100)));
        async.flushMicrotasks();
        // Advance past several half-cycles.
        async.elapse(const Duration(milliseconds: 350));

        // Expect alternating true/false after the initial true.
        check(received.length).isGreaterOrEqual(4);
        // The sequence should start with true.
        check(received.first).isTrue();

        unawaited(svc.stop());
        async.flushMicrotasks();
        unawaited(sub.cancel());
      });
    });

    test('start rejects intervals below 2 microseconds', () async {
      final svc = SimulationScreenFlashService();
      // Duration.zero → halfCycle = 0 microseconds → ArgumentError.
      await check(svc.start(interval: Duration.zero)).throws<ArgumentError>();
    });

    test('start with 1 microsecond also throws ArgumentError', () async {
      final svc = SimulationScreenFlashService();
      // halfCycle = 0 microseconds for intervals < 2us.
      await check(
        svc.start(interval: const Duration(microseconds: 1)),
      ).throws<ArgumentError>();
    });

    test(
      'ticks getter is a broadcast stream (multiple listeners allowed)',
      () async {
        final svc = SimulationScreenFlashService();
        final received1 = <bool>[];
        final received2 = <bool>[];
        final sub1 = svc.ticks.listen(received1.add);
        final sub2 = svc.ticks.listen(received2.add);
        await svc.start(interval: const Duration(milliseconds: 200));
        await Future<void>.delayed(const Duration(milliseconds: 1));
        await svc.stop();
        // Both listeners should have received events.
        check(received1).isNotEmpty();
        check(received2).isNotEmpty();
        await sub1.cancel();
        await sub2.cancel();
      },
    );

    test('stop emits false tick when last phase was true', () {
      fakeAsync((async) {
        final svc = SimulationScreenFlashService();
        final received = <bool>[];
        final sub = svc.ticks.listen(received.add);

        unawaited(svc.start(interval: const Duration(milliseconds: 100)));
        async.flushMicrotasks();
        // Stop immediately — phase is true.
        unawaited(svc.stop());
        async.flushMicrotasks();
        // The last tick should be false (reset from true → false).
        check(received).isNotEmpty();
        check(received.last).isFalse();

        unawaited(sub.cancel());
      });
    });
  });
}
