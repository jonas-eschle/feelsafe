/// Disarm tests — universal; works from every non-ended state.
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/timer_phase.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import '../../helpers/test_helpers.dart';

SessionEngine _mk() => SessionEngine(
  chainSteps: [
    smsStep(durationSeconds: 10, gracePeriodSeconds: 10)
        .copyWith(waitSeconds: 20),
    smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
  ],
  random: FixedRandom(),
);

void main() {
  group('disarm from every state', () {
    test('disarm from Idle', () {
      final e = _mk();
      e.disarm();
      check(e.state).isA<EngineEnded>();
      check((e.state as EngineEnded).reason).equals(EndReason.disarm);
      e.dispose();
    });

    test('disarm from Running (wait phase)', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.wait);
        e.disarm();
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        check((e.state as EngineEnded).reason).equals(EndReason.disarm);
        e.dispose();
      });
    });

    test('disarm from Running (duration phase)', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 20));
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.duration);
        e.disarm();
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });

    test('disarm from Running (grace phase)', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 30));
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.grace);
        e.disarm();
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });

    test('disarm from Paused', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        e.pause();
        check(e.state).isA<EnginePaused>();
        e.disarm();
        check(e.state).isA<EngineEnded>();
        check((e.state as EngineEnded).reason).equals(EndReason.disarm);
        e.dispose();
      });
    });

    test('disarm from already-Ended keeps original EndReason', () {
      final e = _mk();
      e.endSession(reason: EndReason.userQuit);
      e.disarm();
      check((e.state as EngineEnded).reason).equals(EndReason.userQuit);
      e.dispose();
    });

    test('disarm on hold-button before first touch', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [holdStep(durationSeconds: 10)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.holdWait);
        e.disarm();
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });

    test('disarm during hold', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [holdStep(durationSeconds: 10)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.disarm();
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });
  });

  group('disarm idempotency', () {
    test('disarm called twice — second is no-op', () {
      final e = _mk();
      e.disarm();
      e.disarm();
      check(e.state).isA<EngineEnded>();
      check((e.state as EngineEnded).reason).equals(EndReason.disarm);
      e.dispose();
    });

    test('disarm called many times — state stays Ended', () {
      final e = _mk();
      for (var i = 0; i < 10; i++) {
        e.disarm();
      }
      check(e.state).isA<EngineEnded>();
      e.dispose();
    });

    test('disarm after endSession does not override reason', () {
      final e = _mk();
      e.endSession(reason: EndReason.chainExhausted);
      e.disarm();
      check((e.state as EngineEnded).reason).equals(EndReason.chainExhausted);
      e.dispose();
    });
  });

  group('disarm cancels timers', () {
    test('timers do not fire after disarm', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        e.disarm();
        async.elapse(const Duration(hours: 1));
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });
  });

  group('disarm emits sessionEnded', () {
    test('exactly one sessionEnded event', () {
      fakeAsync((async) {
        final e = _mk();
        var endedCount = 0;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.sessionEnded) endedCount++;
        });
        e.start();
        async.flushMicrotasks();
        e.disarm();
        async.flushMicrotasks();
        check(endedCount).equals(1);
        e.disarm();
        async.flushMicrotasks();
        check(endedCount).equals(1);
        e.dispose();
      });
    });
  });
}
