/// Exhaustive ChainStepType × TimerPhase state-machine matrix tests.
///
/// Covers every step type's entry, phase transitions, and terminal
/// behaviour. Each test asserts SPEC-CORRECT behaviour; a failure
/// indicates a real engine bug.
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

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SessionEngine _engine(List<ChainStep> steps) =>
    SessionEngine(chainSteps: steps, random: FixedRandom());

ChainStep _nonHoldStep(ChainStepType type, {int waitSecs = 0}) => step(
  id: 'matrix-${type.name}',
  type: type,
  durationSeconds: 10,
  gracePeriodSeconds: 5,
  waitSeconds: waitSecs,
);

// All 9 step types.
const _allTypes = ChainStepType.values;

// Step types that follow wait → duration → grace (excludes holdButton
// and hardwareButton which have special phase paths).
const _standardTypes = [
  ChainStepType.disguisedReminder,
  ChainStepType.countdownWarning,
  ChainStepType.fakeCall,
  ChainStepType.smsContact,
  ChainStepType.phoneCallContact,
  ChainStepType.loudAlarm,
  ChainStepType.callEmergency,
];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // 1.  Entry state per step type
  // -------------------------------------------------------------------------
  group('step entry phase per type', () {
    test('holdButton enters holdWait immediately (no timer)', () {
      fakeAsync((async) {
        final e = _engine([holdStep(durationSeconds: 30)]);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.holdWait);
        check(s.stepIndex).equals(0);
        check(s.isHolding).isFalse();
        check(s.missCount).equals(0);
        e.dispose();
      });
    });

    test(
      'holdButton remaining is zero in holdWait (engine does not schedule)',
      () {
        fakeAsync((async) {
          final e = _engine([holdStep(durationSeconds: 30)]);
          e.start();
          async.flushMicrotasks();
          final s = e.state as EngineRunning;
          check(s.remaining).equals(Duration.zero);
          e.dispose();
        });
      },
    );

    for (final type in _standardTypes) {
      test('${type.name} with zero wait enters duration immediately', () {
        fakeAsync((async) {
          final e = _engine([_nonHoldStep(type)]);
          e.start();
          async.flushMicrotasks();
          final s = e.state as EngineRunning;
          check(s.phase).equals(TimerPhase.duration);
          check(s.stepIndex).equals(0);
          e.dispose();
        });
      });

      test('${type.name} with non-zero wait enters wait phase', () {
        fakeAsync((async) {
          final e = _engine([_nonHoldStep(type, waitSecs: 15)]);
          e.start();
          async.flushMicrotasks();
          final s = e.state as EngineRunning;
          check(s.phase).equals(TimerPhase.wait);
          check(s.remaining).equals(const Duration(seconds: 15));
          e.dispose();
        });
      });

      test('${type.name}: wait expires → duration phase starts', () {
        fakeAsync((async) {
          final e = _engine([_nonHoldStep(type, waitSecs: 5)]);
          e.start();
          async.flushMicrotasks();
          async.elapse(const Duration(seconds: 5));
          async.flushMicrotasks();
          final s = e.state as EngineRunning;
          check(s.phase).equals(TimerPhase.duration);
          e.dispose();
        });
      });

      test('${type.name}: duration expires → grace phase starts', () {
        fakeAsync((async) {
          final e = _engine([_nonHoldStep(type)]);
          e.start();
          async.flushMicrotasks();
          async.elapse(const Duration(seconds: 10));
          async.flushMicrotasks();
          final s = e.state as EngineRunning;
          check(s.phase).equals(TimerPhase.grace);
          check(s.remaining).equals(const Duration(seconds: 5));
          e.dispose();
        });
      });

      test('${type.name}: grace expires → engine ends (sole step)', () {
        fakeAsync((async) {
          final e = _engine([_nonHoldStep(type)]);
          e.start();
          async.flushMicrotasks();
          async.elapse(const Duration(seconds: 15)); // 10 dur + 5 grace
          async.flushMicrotasks();
          check(e.state).isA<EngineEnded>();
          check(
            (e.state as EngineEnded).reason,
          ).equals(EndReason.chainExhausted);
          e.dispose();
        });
      });

      test('${type.name}: stepStarted carries stepType=${type.name}', () {
        fakeAsync((async) {
          final e = _engine([_nonHoldStep(type)]);
          final evs = <ChainEventData>[];
          e.events.listen(evs.add);
          e.start();
          async.flushMicrotasks();
          final started = evs.firstWhere(
            (ev) => ev.event == ChainEvent.stepStarted,
          );
          check(started.stepType).equals(type);
          check(started.stepIndex).equals(0);
          e.dispose();
        });
      });
    }

    test('hardwareButton immediately advances without timer', () {
      fakeAsync((async) {
        final e = _engine([
          step(type: ChainStepType.hardwareButton, durationSeconds: 5),
          smsStep(order: 1),
        ]);
        final evs = <ChainEvent>[];
        e.events.listen((ev) => evs.add(ev.event));
        e.start();
        async.flushMicrotasks();
        check(evs).contains(ChainEvent.stepAdvancing);
        final s = e.state;
        check(s).anyOf([
          (it) => it.isA<EngineRunning>(),
          (it) => it.isA<EngineEnded>(),
        ]);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // 2.  Phase-duration correctness with FixedRandom(0.5) → factor 1.0
  // -------------------------------------------------------------------------
  group('phase duration values (randomize=0, FixedRandom)', () {
    test('wait remaining equals waitSeconds', () {
      fakeAsync((async) {
        final e = _engine([
          smsStep(durationSeconds: 10).copyWith(waitSeconds: 20),
        ]);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.remaining).equals(const Duration(seconds: 20));
        e.dispose();
      });
    });

    test('duration remaining equals durationSeconds', () {
      fakeAsync((async) {
        final e = _engine([smsStep(durationSeconds: 30)]);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.remaining).equals(const Duration(seconds: 30));
        e.dispose();
      });
    });

    test('grace remaining equals gracePeriodSeconds', () {
      fakeAsync((async) {
        final e = _engine([
          smsStep(durationSeconds: 5, gracePeriodSeconds: 12),
        ]);
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.grace);
        check(s.remaining).equals(const Duration(seconds: 12));
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // 3.  missCount tracking across phase transitions
  // -------------------------------------------------------------------------
  group('missCount lifecycle', () {
    test('missCount is 0 on step entry', () {
      fakeAsync((async) {
        final e = _engine([smsStep(durationSeconds: 10)]);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.missCount).equals(0);
        e.dispose();
      });
    });

    test('missCount remains 0 through duration phase', () {
      fakeAsync((async) {
        final e = _engine([
          smsStep(durationSeconds: 10, gracePeriodSeconds: 5),
        ]);
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.grace);
        check(s.missCount).equals(0);
        e.dispose();
      });
    });

    test('missCount becomes 1 on first grace expiry with retryCount=0', () {
      fakeAsync((async) {
        // Spec: after first grace expiry on a step with retryCount=0,
        // the engine advances without emitting repeatMissed. The final
        // graceExpired event carries missCount=1 in metadata.
        final e = _engine([
          smsStep(durationSeconds: 5, gracePeriodSeconds: 5),
          smsStep(order: 1, durationSeconds: 30, gracePeriodSeconds: 0),
        ]);
        final evs = <ChainEventData>[];
        e.events.listen(evs.add);
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();
        final ge = evs.firstWhere((ev) => ev.event == ChainEvent.graceExpired);
        check(ge.metadata['missCount']).equals(1);
        e.dispose();
      });
    });

    test('missCount resets to 0 on step advance', () {
      fakeAsync((async) {
        final e = _engine([
          step(
            type: ChainStepType.smsContact,
            durationSeconds: 1,
            gracePeriodSeconds: 1,
            retryCount: 1,
          ),
          smsStep(order: 1, durationSeconds: 30),
        ]);
        e.start();
        async.flushMicrotasks();
        // first miss
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        // second miss → advance
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        final s = e.state;
        if (s is EngineRunning) {
          check(s.stepIndex).equals(1);
          check(s.missCount).equals(0);
        }
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // 4.  stepAdvancing metadata
  // -------------------------------------------------------------------------
  group('stepAdvancing event metadata', () {
    test('stepAdvancing carries nextStepId when not last step', () {
      fakeAsync((async) {
        final step1 = smsStep(durationSeconds: 1, gracePeriodSeconds: 0);
        final step2 = smsStep(order: 1, durationSeconds: 5);
        final e = _engine([step1, step2]);
        final evs = <ChainEventData>[];
        e.events.listen(evs.add);
        e.start();
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        final adv = evs.firstWhere(
          (ev) => ev.event == ChainEvent.stepAdvancing,
        );
        check(adv.metadata.containsKey('nextStepId')).isTrue();
        check(adv.metadata['nextStepId']).equals(step2.id);
        e.dispose();
      });
    });

    test('stepAdvancing has null nextStep for last main-chain step', () {
      fakeAsync((async) {
        final e = _engine([smsStep(durationSeconds: 1, gracePeriodSeconds: 0)]);
        final evs = <ChainEventData>[];
        e.events.listen(evs.add);
        e.start();
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        final adv = evs.firstWhere(
          (ev) => ev.event == ChainEvent.stepAdvancing,
        );
        // No nextStep on last step.
        check(adv.metadata.containsKey('nextStepId')).isFalse();
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // 5.  Full multi-step chain traversal
  // -------------------------------------------------------------------------
  group('multi-step chain traversal', () {
    test('two-step chain traverses both steps and ends', () {
      fakeAsync((async) {
        final e = _engine([
          smsStep(durationSeconds: 2, gracePeriodSeconds: 0),
          smsStep(order: 1, durationSeconds: 2, gracePeriodSeconds: 0),
        ]);
        e.start();
        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        check((e.state as EngineEnded).reason).equals(EndReason.chainExhausted);
        e.dispose();
      });
    });

    test('five-step chain emits five stepStarted events', () {
      fakeAsync((async) {
        final steps = List.generate(
          5,
          (i) => smsStep(
            id: 'step-$i',
            order: i,
            durationSeconds: 1,
            gracePeriodSeconds: 0,
          ),
        );
        final e = _engine(steps);
        var count = 0;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.stepStarted) count++;
        });
        e.start();
        async.elapse(const Duration(seconds: 20));
        async.flushMicrotasks();
        check(count).equals(5);
        e.dispose();
      });
    });

    test('chain traversal order: step indices 0→1→2 emitted in order', () {
      fakeAsync((async) {
        final e = _engine([
          smsStep(durationSeconds: 1, gracePeriodSeconds: 0),
          smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
          smsStep(order: 2, durationSeconds: 1, gracePeriodSeconds: 0),
        ]);
        final indices = <int>[];
        e.events.listen((ev) {
          if (ev.event == ChainEvent.stepStarted && ev.stepIndex != null) {
            indices.add(ev.stepIndex!);
          }
        });
        e.start();
        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();
        check(indices).deepEquals([0, 1, 2]);
        e.dispose();
      });
    });

    test('heterogeneous chain: hold → sms → fakeCall traverses correctly', () {
      fakeAsync((async) {
        final e = _engine([
          holdStep(durationSeconds: 5, gracePeriodSeconds: 2),
          smsStep(order: 1, durationSeconds: 2, gracePeriodSeconds: 0),
          fakeCallStep(order: 2, durationSeconds: 2, gracePeriodSeconds: 0),
        ]);
        final evs = <ChainEventData>[];
        e.events.listen(evs.add);
        e.start();
        async.flushMicrotasks();
        // Step 0 (hold): start, release, wait sensitivity, wait grace.
        e.holdStart();
        e.holdRelease();
        // Sensitivity 1s + duration 5s + grace 2s.
        async.elapse(const Duration(seconds: 8));
        async.flushMicrotasks();
        // Step 1 (SMS): 2s duration + 0 grace.
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        // Step 2 (fakeCall): 2s duration + 0 grace.
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // 6.  graceExpired and repeatMissed event ordering
  // -------------------------------------------------------------------------
  group('graceExpired / repeatMissed ordering', () {
    test('graceExpired precedes repeatMissed in event stream', () {
      fakeAsync((async) {
        final e = _engine([
          step(
            type: ChainStepType.smsContact,
            durationSeconds: 1,
            gracePeriodSeconds: 1,
            retryCount: 1,
          ),
        ]);
        final evs = <ChainEvent>[];
        e.events.listen((ev) => evs.add(ev.event));
        e.start();
        async.elapse(const Duration(seconds: 2)); // dur+grace expiry.
        async.flushMicrotasks();
        final geIdx = evs.indexOf(ChainEvent.graceExpired);
        final rmIdx = evs.indexOf(ChainEvent.repeatMissed);
        check(geIdx).isGreaterOrEqual(0);
        check(rmIdx).isGreaterThan(geIdx);
        e.dispose();
      });
    });

    test('repeatMissed not emitted when retryCount=0', () {
      fakeAsync((async) {
        final e = _engine([smsStep(durationSeconds: 1, gracePeriodSeconds: 1)]);
        var missCount = 0;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.repeatMissed) missCount++;
        });
        e.start();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        check(missCount).equals(0);
        e.dispose();
      });
    });

    test('graceExpired metadata contains correct missCount', () {
      fakeAsync((async) {
        final e = _engine([
          step(
            type: ChainStepType.smsContact,
            durationSeconds: 1,
            gracePeriodSeconds: 1,
            retryCount: 2,
          ),
        ]);
        final misses = <int>[];
        e.events.listen((ev) {
          if (ev.event == ChainEvent.graceExpired) {
            misses.add(ev.metadata['missCount'] as int);
          }
        });
        e.start();
        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();
        // 3 misses total (initial + 2 retries).
        check(misses).deepEquals([1, 2, 3]);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // 7.  Zero-duration edge cases
  // -------------------------------------------------------------------------
  group('zero-duration phase edge cases', () {
    test('wait=0, duration=0, grace=0 → end immediately', () {
      fakeAsync((async) {
        final e = _engine([
          step(
            type: ChainStepType.smsContact,
            durationSeconds: 0,
            gracePeriodSeconds: 0,
          ),
        ]);
        e.start();
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });

    test('wait=0, duration=5, grace=0 → ends 5s after start', () {
      fakeAsync((async) {
        final e = _engine([
          step(
            type: ChainStepType.smsContact,
            durationSeconds: 5,
            gracePeriodSeconds: 0,
          ),
        ]);
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });

    test('wait=0, duration=0, grace=5 → grace immediately, then end', () {
      fakeAsync((async) {
        final e = _engine([
          step(
            type: ChainStepType.smsContact,
            durationSeconds: 0,
            gracePeriodSeconds: 5,
          ),
        ]);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.grace);
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });

    test('wait=10, duration=0, grace=0 → wait 10s then end immediately', () {
      fakeAsync((async) {
        final e = _engine([
          step(
            type: ChainStepType.smsContact,
            durationSeconds: 0,
            gracePeriodSeconds: 0,
          ).copyWith(waitSeconds: 10),
        ]);
        e.start();
        async.flushMicrotasks();
        // Should be in wait phase.
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.wait);
        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // 8.  currentStep getter accuracy
  // -------------------------------------------------------------------------
  group('currentStep getter', () {
    test('currentStep is null when Idle', () {
      final e = _engine([smsStep()]);
      check(e.currentStep).isNull();
      e.dispose();
    });

    test('currentStep reflects active stepIndex in Running', () {
      fakeAsync((async) {
        final s1 = smsStep(durationSeconds: 5, gracePeriodSeconds: 0);
        final s2 = smsStep(order: 1, durationSeconds: 30);
        final e = _engine([s1, s2]);
        e.start();
        async.flushMicrotasks();
        check(e.currentStep!.id).equals(s1.id);
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        check(e.currentStep!.id).equals(s2.id);
        e.dispose();
      });
    });

    test('currentStep reflects step index during Paused', () {
      fakeAsync((async) {
        final s1 = smsStep(durationSeconds: 30);
        final e = _engine([s1]);
        e.start();
        async.flushMicrotasks();
        e.pause();
        check(e.currentStep!.id).equals(s1.id);
        e.dispose();
      });
    });

    test('currentStep is null after session ends', () {
      fakeAsync((async) {
        final e = _engine([smsStep(durationSeconds: 1, gracePeriodSeconds: 0)]);
        e.start();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        check(e.currentStep).isNull();
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // 9.  Reminder-fired events for disguisedReminder
  // -------------------------------------------------------------------------
  group('disguisedReminder specific: reminderFired', () {
    test('reminderFired emitted after wait→duration transition', () {
      fakeAsync((async) {
        final e = _engine([
          step(
            type: ChainStepType.disguisedReminder,
            waitSeconds: 5,
            durationSeconds: 10,
            gracePeriodSeconds: 5,
          ),
        ]);
        final evs = <ChainEvent>[];
        e.events.listen((ev) => evs.add(ev.event));
        e.start();
        async.elapse(const Duration(seconds: 6));
        async.flushMicrotasks();
        check(evs).contains(ChainEvent.reminderFired);
        e.dispose();
      });
    });

    test('reminderFired has missCount=0 on first fire', () {
      fakeAsync((async) {
        final e = _engine([
          step(
            type: ChainStepType.disguisedReminder,
            durationSeconds: 5,
            gracePeriodSeconds: 5,
          ),
        ]);
        ChainEventData? fired;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.reminderFired) fired = ev;
        });
        e.start();
        async.flushMicrotasks();
        check(fired).isNotNull();
        check(fired!.metadata['missCount']).equals(0);
        e.dispose();
      });
    });

    test('reminderFired on retry has incremented missCount', () {
      fakeAsync((async) {
        final e = _engine([
          step(
            type: ChainStepType.disguisedReminder,
            durationSeconds: 2,
            gracePeriodSeconds: 1,
            retryCount: 1,
          ),
        ]);
        final mcs = <int>[];
        e.events.listen((ev) {
          if (ev.event == ChainEvent.reminderFired) {
            mcs.add(ev.metadata['missCount'] as int);
          }
        });
        e.start();
        async.elapse(const Duration(seconds: 3)); // first dur+grace.
        async.flushMicrotasks();
        // After retry, reminderFired fires again with missCount=1.
        check(mcs).deepEquals([0, 1]);
        e.dispose();
      });
    });

    test('reminderFired NOT emitted for non-disguisedReminder step', () {
      fakeAsync((async) {
        for (final type in const [
          ChainStepType.smsContact,
          ChainStepType.loudAlarm,
          ChainStepType.callEmergency,
          ChainStepType.countdownWarning,
          ChainStepType.fakeCall,
          ChainStepType.phoneCallContact,
        ]) {
          final e = _engine([
            step(type: type, durationSeconds: 2, gracePeriodSeconds: 0),
          ]);
          var fired = false;
          e.events.listen((ev) {
            if (ev.event == ChainEvent.reminderFired) fired = true;
          });
          e.start();
          async.elapse(const Duration(seconds: 5));
          async.flushMicrotasks();
          check(fired).isFalse();
          e.dispose();
        }
      });
    });
  });

  // -------------------------------------------------------------------------
  // 10. All step types iterate their stepType in events
  // -------------------------------------------------------------------------
  group('stepType in events for all types', () {
    for (final type in _allTypes) {
      test('${type.name} stepStarted event carries correct stepType', () {
        fakeAsync((async) {
          final steps = type == ChainStepType.hardwareButton
              ? <ChainStep>[
                  step(type: type),
                  smsStep(order: 1, durationSeconds: 1),
                ]
              : type == ChainStepType.holdButton
              ? [holdStep()]
              : [_nonHoldStep(type)];
          final e = _engine(steps);
          ChainStepType? captured;
          e.events.listen((ev) {
            if (ev.event == ChainEvent.stepStarted && ev.stepIndex == 0) {
              captured = ev.stepType;
            }
          });
          e.start();
          async.flushMicrotasks();
          check(captured).equals(type);
          e.dispose();
        });
      });
    }
  });
}
