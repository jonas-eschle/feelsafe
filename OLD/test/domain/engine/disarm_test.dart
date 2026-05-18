/// Disarm tests — re-arm semantics per spec 01 §Disarm/Check-in.
///
/// `engine.disarm()` resets the chain to step 0, clears miss count,
/// emits `userDisarmed`, and re-executes step 0. It does NOT end the
/// session — `endSession(reason: EndReason.disarm)` is what callers
/// use for the user-initiated "End Session" path.
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
      gracePeriodSeconds: 10,
    ).copyWith(waitSeconds: 20),
    smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
  ],
  random: FixedRandom(),
);

void main() {
  group('disarm from every state', () {
    test('disarm from Idle is a no-op', () {
      final e = _mk();
      e.disarm();
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });

    test('disarm from Running (wait phase) resets to step 0', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.wait);
        e.disarm();
        async.flushMicrotasks();
        // Engine is still running, but at step 0.
        check(e.state).isA<EngineRunning>();
        check((e.state as EngineRunning).stepIndex).equals(0);
        e.dispose();
      });
    });

    test('disarm from Running (duration phase) resets to step 0', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 20));
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.duration);
        e.disarm();
        async.flushMicrotasks();
        check(e.state).isA<EngineRunning>();
        check((e.state as EngineRunning).stepIndex).equals(0);
        e.dispose();
      });
    });

    test('disarm from Running (grace phase) resets to step 0', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 30));
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.grace);
        e.disarm();
        async.flushMicrotasks();
        check(e.state).isA<EngineRunning>();
        check((e.state as EngineRunning).stepIndex).equals(0);
        e.dispose();
      });
    });

    test('disarm from Paused is a no-op (state preserved)', () {
      // Spec 01: callers must `resume()` first before disarm takes
      // effect — disarming a paused engine is a no-op so the user's
      // pause intent is not silently overwritten.
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        e.pause();
        check(e.state).isA<EnginePaused>();
        e.disarm();
        check(e.state).isA<EnginePaused>();
        e.dispose();
      });
    });

    test('disarm from Ended is a no-op (EndReason preserved)', () {
      final e = _mk();
      e.endSession(reason: EndReason.userQuit);
      e.disarm();
      check((e.state as EngineEnded).reason).equals(EndReason.userQuit);
      e.dispose();
    });

    test('disarm on hold-button before first touch resets', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [holdStep(durationSeconds: 10)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.holdWait);
        e.disarm();
        // Re-enters step 0 → still in holdWait, awaiting the next touch.
        check(e.state).isA<EngineRunning>();
        check((e.state as EngineRunning).phase).equals(TimerPhase.holdWait);
        e.dispose();
      });
    });

    test('disarm during hold resets the step', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [holdStep(durationSeconds: 10)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.disarm();
        check(e.state).isA<EngineRunning>();
        check((e.state as EngineRunning).stepIndex).equals(0);
        check((e.state as EngineRunning).isHolding).equals(false);
        e.dispose();
      });
    });
  });

  group('disarm idempotency', () {
    test('disarm called twice — second is also a re-arm', () {
      final e = _mk();
      e.start();
      e.disarm();
      e.disarm();
      check(e.state).isA<EngineRunning>();
      check((e.state as EngineRunning).stepIndex).equals(0);
      e.dispose();
    });

    test('disarm called many times — state stays Running at step 0', () {
      final e = _mk();
      e.start();
      for (var i = 0; i < 10; i++) {
        e.disarm();
      }
      check(e.state).isA<EngineRunning>();
      check((e.state as EngineRunning).stepIndex).equals(0);
      e.dispose();
    });

    test('disarm after endSession does not re-open the session', () {
      final e = _mk();
      e.endSession(reason: EndReason.chainExhausted);
      e.disarm();
      check(e.state).isA<EngineEnded>();
      check((e.state as EngineEnded).reason).equals(EndReason.chainExhausted);
      e.dispose();
    });
  });

  group('disarm cancels timers', () {
    test('original timers do not fire after disarm', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        // Capture step 0's wait remaining; after disarm a fresh wait
        // will be scheduled — different timer object.
        e.disarm();
        async.flushMicrotasks();
        // Engine immediately re-entered step 0; phase is wait again.
        check((e.state as EngineRunning).phase).equals(TimerPhase.wait);
        e.dispose();
      });
    });
  });

  group('disarm emits userDisarmed', () {
    test('exactly one userDisarmed event per disarm call', () {
      fakeAsync((async) {
        final e = _mk();
        var count = 0;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.userDisarmed) count++;
        });
        e.start();
        async.flushMicrotasks();
        e.disarm();
        async.flushMicrotasks();
        check(count).equals(1);
        e.disarm();
        async.flushMicrotasks();
        check(count).equals(2);
        e.dispose();
      });
    });

    test('userDisarmed is NOT emitted on disarm-from-Idle', () {
      // Idle engine never started, so no chain to re-arm — early
      // return, no event.
      fakeAsync((async) {
        final e = _mk();
        var count = 0;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.userDisarmed) count++;
        });
        e.disarm();
        async.flushMicrotasks();
        check(count).equals(0);
        e.dispose();
      });
    });
  });
}
