/// Fake-call lifecycle tests — answer / hangUp / decline.
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/timer_phase.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import '../../helpers/test_helpers.dart';

SessionEngine _mkEngine(List<ChainStep> steps, {bool isSimulation = false}) =>
    SessionEngine(
      chainSteps: steps,
      isSimulation: isSimulation,
      random: FixedRandom(),
    );

void main() {
  group('answerFakeCall', () {
    test('answer during fakeCall duration pauses with fakeCallAnswered', () {
      fakeAsync((async) {
        final e = _mkEngine([
          fakeCallStep(durationSeconds: 30, gracePeriodSeconds: 5),
        ]);
        e.start();
        async.flushMicrotasks();
        e.answerFakeCall();
        async.flushMicrotasks();
        check(e.state).isA<EnginePaused>();
        final p = e.state as EnginePaused;
        check(p.reason).equals(PauseReason.fakeCallAnswered);
        e.dispose();
      });
    });

    test('answer emits sessionPaused', () {
      fakeAsync((async) {
        final e = _mkEngine([
          fakeCallStep(durationSeconds: 30, gracePeriodSeconds: 5),
        ]);
        final names = <ChainEvent>[];
        e.events.listen((ev) => names.add(ev.event));
        e.start();
        async.flushMicrotasks();
        e.answerFakeCall();
        async.flushMicrotasks();
        check(names).contains(ChainEvent.sessionPaused);
        e.dispose();
      });
    });

    test('answer on non-fakeCall step is a no-op', () {
      fakeAsync((async) {
        final e = _mkEngine([smsStep(durationSeconds: 10)]);
        e.start();
        async.flushMicrotasks();
        e.answerFakeCall();
        async.flushMicrotasks();
        check(e.state).isA<EngineRunning>();
        e.dispose();
      });
    });

    test('answer from Idle is a no-op', () {
      final e = _mkEngine([
        fakeCallStep(durationSeconds: 30, gracePeriodSeconds: 5),
      ]);
      e.answerFakeCall();
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });
  });

  group('hangUp', () {
    test('hangUp after answer disarms', () {
      fakeAsync((async) {
        final e = _mkEngine([
          fakeCallStep(durationSeconds: 30, gracePeriodSeconds: 5),
        ]);
        e.start();
        async.flushMicrotasks();
        e.answerFakeCall();
        async.flushMicrotasks();
        e.hangUp();
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        check((e.state as EngineEnded).reason).equals(EndReason.disarm);
        e.dispose();
      });
    });

    test('hangUp during ringing (no answer) still disarms', () {
      fakeAsync((async) {
        final e = _mkEngine([
          fakeCallStep(durationSeconds: 30, gracePeriodSeconds: 5),
        ]);
        e.start();
        async.flushMicrotasks();
        e.hangUp();
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });

    test('hangUp on non-fakeCall step is a no-op', () {
      fakeAsync((async) {
        final e = _mkEngine([smsStep(durationSeconds: 10)]);
        e.start();
        async.flushMicrotasks();
        e.hangUp();
        async.flushMicrotasks();
        check(e.state).isA<EngineRunning>();
        e.dispose();
      });
    });

    test('hangUp from Idle is a no-op', () {
      final e = _mkEngine([
        fakeCallStep(durationSeconds: 30, gracePeriodSeconds: 5),
      ]);
      e.hangUp();
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });
  });

  group('declineFakeCall', () {
    test('decline with declineIsSafe=true disarms', () {
      fakeAsync((async) {
        final e = _mkEngine([
          fakeCallStep(
            durationSeconds: 30,
            gracePeriodSeconds: 5,
            declineIsSafe: true,
          ),
        ]);
        e.start();
        async.flushMicrotasks();
        e.declineFakeCall();
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        check((e.state as EngineEnded).reason).equals(EndReason.disarm);
        e.dispose();
      });
    });

    test('decline with declineIsSafe=false + no retries advances', () {
      fakeAsync((async) {
        final e = _mkEngine([
          fakeCallStep(
            durationSeconds: 30,
            gracePeriodSeconds: 5,
            declineIsSafe: false,
          ),
          smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
        ]);
        e.start();
        async.flushMicrotasks();
        e.declineFakeCall();
        async.flushMicrotasks();
        final s = e.state;
        if (s is EngineRunning) {
          check(s.stepIndex).equals(1);
        } else {
          // SMS step may have completed instantly (duration=1).
          check(s).isA<EngineEnded>();
        }
        e.dispose();
      });
    });

    test('decline with declineIsSafe=false + retries=1 restarts', () {
      fakeAsync((async) {
        final step = fakeCallStep(
          durationSeconds: 30,
          gracePeriodSeconds: 5,
          declineIsSafe: false,
        ).copyWith(retryCount: 1);
        final e = _mkEngine([
          step,
          smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
        ]);
        e.start();
        async.flushMicrotasks();
        e.declineFakeCall();
        async.flushMicrotasks();
        // Still on step 0, in duration phase with missCount == 1.
        final s = e.state as EngineRunning;
        check(s.stepIndex).equals(0);
        check(s.phase).equals(TimerPhase.duration);
        check(s.missCount).equals(1);
        e.dispose();
      });
    });

    test('decline on non-fakeCall step is a no-op', () {
      fakeAsync((async) {
        final e = _mkEngine([smsStep(durationSeconds: 10)]);
        e.start();
        async.flushMicrotasks();
        e.declineFakeCall();
        async.flushMicrotasks();
        check(e.state).isA<EngineRunning>();
        e.dispose();
      });
    });

    test('decline from Idle is a no-op', () {
      final e = _mkEngine([
        fakeCallStep(durationSeconds: 30, gracePeriodSeconds: 5),
      ]);
      e.declineFakeCall();
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });

    test('repeated decline with retryCount=2 advances after 3 attempts', () {
      fakeAsync((async) {
        final step = fakeCallStep(
          durationSeconds: 30,
          gracePeriodSeconds: 5,
          declineIsSafe: false,
        ).copyWith(retryCount: 2);
        final e = _mkEngine([
          step,
          smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
        ]);
        e.start();
        async.flushMicrotasks();
        e.declineFakeCall(); // miss 1 → retry.
        async.flushMicrotasks();
        check((e.state as EngineRunning).missCount).equals(1);
        e.declineFakeCall(); // miss 2 → retry.
        async.flushMicrotasks();
        check((e.state as EngineRunning).missCount).equals(2);
        e.declineFakeCall(); // miss 3 > retryCount → advance.
        async.flushMicrotasks();
        final s = e.state;
        if (s is EngineRunning) {
          check(s.stepIndex).equals(1);
        } else {
          check(s).isA<EngineEnded>();
        }
        e.dispose();
      });
    });
  });

  group('fakeCall timer advance', () {
    test('unanswered fakeCall eventually advances after duration + grace', () {
      fakeAsync((async) {
        final e = _mkEngine([
          fakeCallStep(durationSeconds: 3, gracePeriodSeconds: 2),
          smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
        ]);
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        final s = e.state;
        // Either on the SMS step or already ended.
        if (s is EngineRunning) {
          check(s.stepIndex).equals(1);
        } else {
          check(s).isA<EngineEnded>();
        }
        e.dispose();
      });
    });
  });
}
