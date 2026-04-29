/// Full end-to-end session scenarios — realistic multi-step walks
/// combining hold, SMS, distress, pause, and fake-call steps.
///
/// Each test simulates a complete session from start to an explicit
/// terminal state, asserting the spec-correct outcome at each stage.
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/timer_phase.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import '../../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Scenario 1: Walk mode — user holds safely for all steps
  // -------------------------------------------------------------------------
  group('Scenario: user holds all steps (walk mode)', () {
    test('hold → SMS → alarm → reset to step 0 via disarm', () {
      // Q1: disarm now resets to step 0 instead of ending the
      // session. Use endSession(userQuit) to terminate.
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            holdStep(durationSeconds: 5, gracePeriodSeconds: 2),
            smsStep(
              order: 1,
              durationSeconds: 3,
              gracePeriodSeconds: 0,
            ),
            step(
              type: ChainStepType.loudAlarm,
              order: 2,
              durationSeconds: 2,
              gracePeriodSeconds: 0,
            ),
          ],
          random: FixedRandom(),
        );
        final evs = <ChainEvent>[];
        e.events.listen((ev) => evs.add(ev.event));
        e.start();
        async.flushMicrotasks();
        // Step 0: hold.
        check((e.state as EngineRunning).stepIndex).equals(0);
        e.holdStart();
        e.holdRelease();
        // Sensitivity 1s + duration 5s + grace 2s.
        async.elapse(const Duration(seconds: 8));
        async.flushMicrotasks();
        // Step 1: SMS.
        check((e.state as EngineRunning).stepIndex).equals(1);
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        // Step 2: loudAlarm.
        check((e.state as EngineRunning).stepIndex).equals(2);
        e.disarm();
        async.flushMicrotasks();
        // Q1: disarm resets to step 0, doesn't end.
        check(e.state).isA<EngineRunning>();
        check((e.state as EngineRunning).stepIndex).equals(0);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Scenario 2: User misses steps, full chain exhausted
  // -------------------------------------------------------------------------
  group('Scenario: user misses all steps → chain exhausted', () {
    test('all steps time out → chainExhausted', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(durationSeconds: 2, gracePeriodSeconds: 1),
            step(
              type: ChainStepType.countdownWarning,
              order: 1,
              durationSeconds: 2,
              gracePeriodSeconds: 1,
            ),
            step(
              type: ChainStepType.loudAlarm,
              order: 2,
              durationSeconds: 2,
              gracePeriodSeconds: 0,
            ),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.elapse(const Duration(seconds: 20));
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        check((e.state as EngineEnded).reason).equals(EndReason.chainExhausted);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Scenario 3: Fake call disarms session
  // -------------------------------------------------------------------------
  group('Scenario: fake call → user answers → hangs up → disarm', () {
    test('ring → answer → hangup → resets to step 0', () {
      // Pivot 2: answerFakeCall is now a no-op at the engine level
      // (timer keeps running while voice plays). hangUp calls
      // disarm() which (Q1) resets to step 0 instead of ending.
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(durationSeconds: 2, gracePeriodSeconds: 0),
            fakeCallStep(order: 1, durationSeconds: 30, gracePeriodSeconds: 5),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        // Now on fakeCall step.
        check((e.state as EngineRunning).stepIndex).equals(1);
        e.answerFakeCall();
        async.flushMicrotasks();
        // Pivot 2: no pause — engine keeps running.
        check(e.state).isA<EngineRunning>();
        e.hangUp();
        async.flushMicrotasks();
        // Q1: hangUp → disarm → reset to step 0.
        check(e.state).isA<EngineRunning>();
        check((e.state as EngineRunning).stepIndex).equals(0);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Scenario 4: Distress triggered mid-session
  // -------------------------------------------------------------------------
  group('Scenario: mid-session distress → completes', () {
    test('SMS step → distress triggered → distress SMS → chainExhausted', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(durationSeconds: 30, gracePeriodSeconds: 30),
          ],
          random: FixedRandom(),
        );
        final evs = <ChainEvent>[];
        e.events.listen((ev) => evs.add(ev.event));
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));
        e.replaceWithDistressChain(
          [
            smsStep(id: 'distress', durationSeconds: 2, gracePeriodSeconds: 0),
          ],
          triggerReason: TriggerReason.hardwarePanic,
        );
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        // Q19: distress triggered by hardwarePanic → endReason
        // propagates to hardwarePanic.
        check((e.state as EngineEnded).reason).equals(EndReason.hardwarePanic);
        check(evs.contains(ChainEvent.distressTriggered)).isTrue();
        check(evs.contains(ChainEvent.distressCompleted)).isTrue();
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Scenario 5: Pause / resume mid-session preserves progress
  // -------------------------------------------------------------------------
  group('Scenario: pause mid-step, resume, continue to end', () {
    test('sms step: pause after 5s, resume, step fires after total 15s', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(durationSeconds: 15, gracePeriodSeconds: 0),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));
        e.pause();
        // 10s remain.
        async.elapse(const Duration(hours: 1));
        e.resume();
        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Scenario 6: Hold-only mode (continuous hold for duration)
  // -------------------------------------------------------------------------
  group('Scenario: hold-only session — hold throughout, then disarm', () {
    test('holdStart once, never release, then disarm resets', () {
      // Q1: disarm now resets to step 0; the chain re-enters the
      // wait phase and is no longer holding.
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            holdStep(durationSeconds: 20, gracePeriodSeconds: 10),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        // While holding, duration timer is NOT running.
        async.elapse(const Duration(minutes: 10));
        check((e.state as EngineRunning).isHolding).isTrue();
        check((e.state as EngineRunning).phase).equals(TimerPhase.duration);
        // Disarm.
        e.disarm();
        async.flushMicrotasks();
        check(e.state).isA<EngineRunning>();
        check((e.state as EngineRunning).stepIndex).equals(0);
        check((e.state as EngineRunning).isHolding).isFalse();
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Scenario 7: Multiple retries, then chain exhausted
  // -------------------------------------------------------------------------
  group('Scenario: retries on reminder step, then alarm, exhausted', () {
    test('reminder × 2 misses + alarm miss → chainExhausted', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            step(
              type: ChainStepType.disguisedReminder,
              durationSeconds: 2,
              gracePeriodSeconds: 1,
              retryCount: 2,
            ),
            step(
              type: ChainStepType.loudAlarm,
              order: 1,
              durationSeconds: 2,
              gracePeriodSeconds: 0,
            ),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.elapse(const Duration(seconds: 20));
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        check((e.state as EngineEnded).reason).equals(EndReason.chainExhausted);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Scenario 8: User checks in early during disguised reminder
  // -------------------------------------------------------------------------
  group('Scenario: earlyCheckIn resets to step 0 (Q6)', () {
    test('checkIn on reminder step resets to step 0 (false-alarm reset)', () {
      // Q6: checkIn on a disguisedReminder step is a false-alarm
      // reset — the chain restarts at step 0 with a fresh wait
      // phase. Advancing past the reminder would skip ahead to
      // escalation even though the user IS safe.
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            step(
              type: ChainStepType.disguisedReminder,
              durationSeconds: 30,
              gracePeriodSeconds: 10,
            ),
            smsStep(order: 1, durationSeconds: 60),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        check((e.state as EngineRunning).stepIndex).equals(0);
        e.earlyCheckIn();
        async.flushMicrotasks();
        check((e.state as EngineRunning).stepIndex).equals(0);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Scenario 9: Simulation leap through chain
  // -------------------------------------------------------------------------
  group('Scenario: simulation leap through all phases', () {
    test('leap 3 times through sms step (wait→dur→grace→advance)', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(durationSeconds: 30, gracePeriodSeconds: 10).copyWith(
              waitSeconds: 60,
            ),
            smsStep(order: 1, durationSeconds: 60),
          ],
          isSimulation: true,
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.wait);
        e.leap(); // wait → duration.
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.duration);
        e.leap(); // duration → grace.
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.grace);
        e.leap(); // grace → step 1.
        async.flushMicrotasks();
        final s = e.state;
        if (s is EngineRunning) check(s.stepIndex).equals(1);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Scenario 10: jumpToStep then disarm
  // -------------------------------------------------------------------------
  group('Scenario: simulation jumpToStep', () {
    test('jumpToStep(2) then disarm resets to step 0', () {
      // Q1: disarm now resets to step 0 — even from a step the user
      // jumped to via the simulation jump button.
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(durationSeconds: 30),
            smsStep(order: 1, durationSeconds: 30),
            step(
              type: ChainStepType.loudAlarm,
              order: 2,
              durationSeconds: 30,
            ),
          ],
          isSimulation: true,
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.jumpToStep(2);
        async.flushMicrotasks();
        check((e.state as EngineRunning).stepIndex).equals(2);
        e.disarm();
        async.flushMicrotasks();
        check(e.state).isA<EngineRunning>();
        check((e.state as EngineRunning).stepIndex).equals(0);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Scenario 11: Hardware button as first step
  // -------------------------------------------------------------------------
  group('Scenario: hardwareButton immediately advances', () {
    test('hardwareButton sole step → chainExhausted immediately', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            step(
              type: ChainStepType.hardwareButton,
              durationSeconds: 5,
            ),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        check((e.state as EngineEnded).reason).equals(EndReason.chainExhausted);
        e.dispose();
      });
    });

    test('hardwareButton first step → advances to SMS step', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            step(
              type: ChainStepType.hardwareButton,
              durationSeconds: 5,
            ),
            smsStep(order: 1, durationSeconds: 30),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        final s = e.state;
        if (s is EngineRunning) check(s.stepIndex).equals(1);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Scenario 12: restartCurrentStep
  // -------------------------------------------------------------------------
  group('Scenario: restartCurrentStep resets step', () {
    test('restart mid-duration resets missCount and re-enters wait', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(durationSeconds: 20, gracePeriodSeconds: 5).copyWith(
              waitSeconds: 10,
            ),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.elapse(const Duration(seconds: 15)); // wait(10) + 5s dur.
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.duration);
        e.restartCurrentStep();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        // Should be back in wait phase (step restarted).
        check(s.phase).equals(TimerPhase.wait);
        check(s.missCount).equals(0);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Scenario 13: long pause then distress triggers
  // -------------------------------------------------------------------------
  group('Scenario: pause, then distress while paused', () {
    test('distress while paused → resumes running on distress chain', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [smsStep(durationSeconds: 300)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.pause(reason: PauseReason.userRequested);
        check(e.state).isA<EnginePaused>();
        e.replaceWithDistressChain(
          [
            smsStep(id: 'distress', durationSeconds: 1, gracePeriodSeconds: 0),
          ],
          triggerReason: TriggerReason.hardwarePanic,
        );
        async.flushMicrotasks();
        check(e.state).isA<EngineRunning>();
        check(e.isDistressChain).isTrue();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Scenario 14: Disarm during grace period
  // -------------------------------------------------------------------------
  group('Scenario: disarm during grace', () {
    test('disarm while grace timer is running resets to step 0', () {
      // Q1: disarm during grace resets the chain to step 0 with a
      // fresh wait phase rather than ending the session.
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [smsStep(durationSeconds: 5, gracePeriodSeconds: 30)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5)); // enter grace.
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.grace);
        e.disarm();
        async.flushMicrotasks();
        check(e.state).isA<EngineRunning>();
        check((e.state as EngineRunning).stepIndex).equals(0);
        // Step is back to step 0; phase is whichever first non-zero
        // phase the step has (wait when waitSeconds>0, otherwise
        // duration). We just check missCount was reset.
        check((e.state as EngineRunning).missCount).equals(0);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Scenario 15: Session exhausted via zero-duration chain
  // -------------------------------------------------------------------------
  group('Scenario: zero-duration all-steps chain', () {
    test('five zero-duration steps end immediately', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: List.generate(
            5,
            (i) => step(
              id: 'z-$i',
              type: ChainStepType.smsContact,
              order: i,
              durationSeconds: 0,
              gracePeriodSeconds: 0,
            ),
          ),
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
}
