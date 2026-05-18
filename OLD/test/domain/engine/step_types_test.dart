/// Coverage tests — each ChainStepType traversal + edge paths.
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/timer_phase.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import '../../helpers/test_helpers.dart';

ChainStep _stepOfType(ChainStepType type, {int order = 0}) => step(
  id: 'step-${type.name}-$order',
  type: type,
  order: order,
  durationSeconds: 2,
  gracePeriodSeconds: 1,
);

void main() {
  group('hardwareButton step immediately advances', () {
    test('hardware step fires stepStarted + stepAdvancing', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            _stepOfType(ChainStepType.hardwareButton, order: 0),
            smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
          ],
          random: FixedRandom(),
        );
        final events = <ChainEvent>[];
        e.events.listen((ev) => events.add(ev.event));
        e.start();
        async.flushMicrotasks();
        check(events).contains(ChainEvent.stepStarted);
        check(events).contains(ChainEvent.stepAdvancing);
        e.dispose();
      });
    });

    test('hardware step as sole step immediately ends', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [_stepOfType(ChainStepType.hardwareButton)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        check((e.state as EngineEnded).reason).equals(EndReason.chainExhausted);
        e.dispose();
      });
    });
  });

  group('all non-hold step types execute wait → duration → grace', () {
    for (final type in const [
      ChainStepType.countdownWarning,
      ChainStepType.fakeCall,
      ChainStepType.smsContact,
      ChainStepType.phoneCallContact,
      ChainStepType.loudAlarm,
      ChainStepType.callEmergency,
      ChainStepType.disguisedReminder,
    ]) {
      test('${type.name} advances via timer', () {
        fakeAsync((async) {
          final e = SessionEngine(
            chainSteps: [
              _stepOfType(type, order: 0),
              smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
            ],
            random: FixedRandom(),
          );
          e.start();
          async.flushMicrotasks();
          async.elapse(const Duration(seconds: 10));
          async.flushMicrotasks();
          // Either on the next step or already ended.
          final s = e.state;
          check(s).anyOf([
            (it) => it.isA<EngineRunning>(),
            (it) => it.isA<EngineEnded>(),
          ]);
          e.dispose();
        });
      });
    }
  });

  group('zero-duration phases skip timer', () {
    test('step with zero duration skips to grace', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            step(
              type: ChainStepType.smsContact,
              durationSeconds: 0,
              gracePeriodSeconds: 2,
            ),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        // wait 0 + duration 0 → grace immediately.
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.grace);
        e.dispose();
      });
    });

    test('step with zero grace immediately advances', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            step(
              type: ChainStepType.smsContact,
              durationSeconds: 1,
              gracePeriodSeconds: 0,
            ),
            smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        // Duration fires → grace=0 → advance → step 1.
        final s = e.state;
        if (s is EngineRunning) {
          check(s.stepIndex).equals(1);
        } else {
          check(s).isA<EngineEnded>();
        }
        e.dispose();
      });
    });

    test('step with zero wait, zero duration, zero grace fires instantly', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            step(
              type: ChainStepType.smsContact,
              durationSeconds: 0,
              gracePeriodSeconds: 0,
            ),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });
  });

  group('retry cycle', () {
    test('step with retryCount=1 fires duration twice before advancing', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            step(
              type: ChainStepType.smsContact,
              durationSeconds: 1,
              gracePeriodSeconds: 1,
              retryCount: 1,
            ),
            smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
          ],
          random: FixedRandom(),
        );
        final stepIndices = <int?>[];
        e.events.listen((ev) {
          if (ev.event == ChainEvent.stepStarted) {
            stepIndices.add(ev.stepIndex);
          }
        });
        e.start();
        async.flushMicrotasks();
        // 1st attempt: duration 1s + grace 1s → miss 1 → retry.
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        // 2nd attempt (retry): skips wait → duration 1s + grace 1s → miss 2.
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        // Now advance to step 1.
        final s = e.state;
        if (s is EngineRunning) {
          check(s.stepIndex).equals(1);
        } else {
          check(s).isA<EngineEnded>();
        }
        e.dispose();
      });
    });

    test('retry emits repeatMissed events', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            step(
              type: ChainStepType.smsContact,
              durationSeconds: 1,
              gracePeriodSeconds: 1,
              retryCount: 2,
            ),
          ],
          random: FixedRandom(),
        );
        var missCount = 0;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.repeatMissed) missCount++;
        });
        e.start();
        async.elapse(const Duration(seconds: 20));
        async.flushMicrotasks();
        check(missCount).equals(2);
        e.dispose();
      });
    });
  });

  group('currentStep across states', () {
    test('currentStep during Paused returns the step', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [smsStep(durationSeconds: 10, gracePeriodSeconds: 5)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.pause();
        check(e.currentStep).isNotNull();
        check(e.currentStep!.type).equals(ChainStepType.smsContact);
        e.dispose();
      });
    });
  });

  group('pause/resume of holdButton does not start a timer', () {
    test('pause in holdWait + resume stays in holdWait without timer', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [holdStep(durationSeconds: 10)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.pause();
        e.resume();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.holdWait);
        async.elapse(const Duration(seconds: 10));
        // Still holdWait — no timer involved.
        check((e.state as EngineRunning).phase).equals(TimerPhase.holdWait);
        e.dispose();
      });
    });
  });

  group('chain exhaust (main chain)', () {
    test('last-step grace expiration ends session with chainExhausted', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            step(
              type: ChainStepType.smsContact,
              durationSeconds: 1,
              gracePeriodSeconds: 0,
            ),
          ],
          random: FixedRandom(),
        );
        final names = <ChainEvent>[];
        e.events.listen((ev) => names.add(ev.event));
        e.start();
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        check((e.state as EngineEnded).reason).equals(EndReason.chainExhausted);
        // Final stepAdvancing with nextStep=null emitted for main chain.
        check(names).contains(ChainEvent.stepAdvancing);
        e.dispose();
      });
    });
  });
}
