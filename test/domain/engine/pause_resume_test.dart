/// Pause / resume determinism tests.
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
    smsStep(
      durationSeconds: 10,
      gracePeriodSeconds: 5,
    ).copyWith(waitSeconds: 20),
    smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
  ],
  random: FixedRandom(),
);

void main() {
  group('pause', () {
    test('pause from Running transitions to Paused', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        e.pause();
        check(e.state).isA<EnginePaused>();
        e.dispose();
      });
    });

    test('pause captures snapshot with exact remaining', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));
        e.pause();
        final p = e.state as EnginePaused;
        check(p.snapshot.phase).equals(TimerPhase.wait);
        check(p.snapshot.remaining).equals(const Duration(seconds: 15));
        e.dispose();
      });
    });

    test('pause with custom reason', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        e.pause(reason: PauseReason.incomingCall);
        final p = e.state as EnginePaused;
        check(p.reason).equals(PauseReason.incomingCall);
        e.dispose();
      });
    });

    test('pause default reason is userRequested', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        e.pause();
        final p = e.state as EnginePaused;
        check(p.reason).equals(PauseReason.userRequested);
        e.dispose();
      });
    });

    test('pause from Idle is a no-op', () {
      final e = _mk();
      e.pause();
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });

    test('pause from Paused is a no-op', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        e.pause();
        final firstPause = e.state as EnginePaused;
        e.pause();
        check(e.state).equals(firstPause);
        e.dispose();
      });
    });

    test('pause from Ended is a no-op', () {
      final e = _mk();
      e.disarm();
      e.pause();
      check(e.state).isA<EngineEnded>();
      e.dispose();
    });

    test('pause emits sessionPaused event', () {
      fakeAsync((async) {
        final e = _mk();
        final events = <ChainEvent>[];
        e.events.listen((ev) => events.add(ev.event));
        e.start();
        async.flushMicrotasks();
        e.pause();
        async.flushMicrotasks();
        check(events).contains(ChainEvent.sessionPaused);
        e.dispose();
      });
    });

    test('pause cancels timer — elapsing does not advance', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));
        e.pause();
        async.elapse(const Duration(minutes: 10));
        check(e.state).isA<EnginePaused>();
        e.dispose();
      });
    });
  });

  group('resume', () {
    test(
      'resume from Paused transitions back to Running with same remaining',
      () {
        fakeAsync((async) {
          final e = _mk();
          e.start();
          async.flushMicrotasks();
          async.elapse(const Duration(seconds: 5));
          e.pause();
          final beforePaused = (e.state as EnginePaused).snapshot.remaining;
          e.resume();
          final resumed = e.state as EngineRunning;
          check(resumed.remaining).equals(beforePaused);
          check(resumed.phase).equals(TimerPhase.wait);
          e.dispose();
        });
      },
    );

    test('resume continues countdown from exact remaining', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));
        e.pause();
        async.elapse(const Duration(seconds: 30));
        e.resume();
        async.elapse(const Duration(seconds: 15));
        async.flushMicrotasks();
        // Wait 20s - 5s elapsed = 15s remaining. After 15 more s
        // timer fires → duration phase (10s).
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        e.dispose();
      });
    });

    test('resume emits sessionResumed event', () {
      fakeAsync((async) {
        final e = _mk();
        final events = <ChainEvent>[];
        e.events.listen((ev) => events.add(ev.event));
        e.start();
        async.flushMicrotasks();
        e.pause();
        async.flushMicrotasks();
        e.resume();
        async.flushMicrotasks();
        check(events).contains(ChainEvent.sessionResumed);
        e.dispose();
      });
    });

    test('resume from Running is a no-op', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        final before = e.state;
        e.resume();
        check(e.state).equals(before);
        e.dispose();
      });
    });

    test('resume from Idle is a no-op', () {
      final e = _mk();
      e.resume();
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });

    test('resume from Ended is a no-op', () {
      final e = _mk();
      e.endSession(reason: EndReason.userQuit);
      e.resume();
      check(e.state).isA<EngineEnded>();
      e.dispose();
    });
  });

  group('pause / resume round-trip determinism', () {
    test('multiple pause/resume cycles preserve total elapsed time', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 3));
        e.pause();
        async.elapse(const Duration(seconds: 100));
        e.resume();
        async.elapse(const Duration(seconds: 7));
        e.pause();
        async.elapse(const Duration(seconds: 50));
        e.resume();
        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        e.dispose();
      });
    });

    test('pause during grace preserves grace remaining', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [smsStep(durationSeconds: 5, gracePeriodSeconds: 10)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        // Duration fires → grace phase begins.
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        final r0 = e.state as EngineRunning;
        check(r0.phase).equals(TimerPhase.grace);
        async.elapse(const Duration(seconds: 2));
        e.pause();
        final p = e.state as EnginePaused;
        check(p.snapshot.phase).equals(TimerPhase.grace);
        check(p.snapshot.remaining).equals(const Duration(seconds: 8));
        e.dispose();
      });
    });
  });
}
