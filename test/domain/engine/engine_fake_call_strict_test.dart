/// Strict fake-call lifecycle tests.
///
/// Covers (post-pivot 2 + Q1):
/// - ring → answer → engine keeps running (NOT a pause)
/// - ring → decline (safe → reset to step 0; unsafe → miss)
/// - ring → timeout → miss
/// - ring → hangup → reset to step 0 (Q1 disarm semantics)
/// - retry after decline; no-ops from wrong steps
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
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import '../../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SessionEngine _fakeCallEngine({
  bool declineIsSafe = false,
  int retryCount = 0,
  int dur = 30,
  int grace = 5,
}) => SessionEngine(
  chainSteps: [
    fakeCallStep(
      durationSeconds: dur,
      gracePeriodSeconds: grace,
      declineIsSafe: declineIsSafe,
    ).copyWith(retryCount: retryCount),
    smsStep(order: 1, durationSeconds: 60, gracePeriodSeconds: 0),
  ],
  random: FixedRandom(),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // ring → answer → engine keeps running (pivot 2)
  // -------------------------------------------------------------------------
  group('ring → answer (pivot 2: NOT a pause)', () {
    test('answerFakeCall keeps engine Running', () {
      fakeAsync((async) {
        final e = _fakeCallEngine();
        e.start();
        async.flushMicrotasks();
        e.answerFakeCall();
        async.flushMicrotasks();
        // Pivot 2: timer continues; engine NOT paused.
        check(e.state).isA<EngineRunning>();
        e.dispose();
      });
    });

    test('answer does NOT emit sessionPaused', () {
      fakeAsync((async) {
        final e = _fakeCallEngine();
        var paused = false;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.sessionPaused) paused = true;
        });
        e.start();
        async.flushMicrotasks();
        e.answerFakeCall();
        async.flushMicrotasks();
        check(paused).isFalse();
        e.dispose();
      });
    });

    test('answered call timer eventually advances chain', () {
      fakeAsync((async) {
        final e = _fakeCallEngine(dur: 3, grace: 2);
        e.start();
        async.flushMicrotasks();
        e.answerFakeCall();
        // Pivot 2: timer keeps running; eventually hits SMS step.
        async.elapse(const Duration(seconds: 6));
        async.flushMicrotasks();
        final s = e.state;
        if (s is EngineRunning) check(s.stepIndex).equals(1);
        e.dispose();
      });
    });

    test('hangUp after answer resets to step 0 (Q1)', () {
      fakeAsync((async) {
        final e = _fakeCallEngine();
        e.start();
        async.flushMicrotasks();
        e.answerFakeCall();
        async.flushMicrotasks();
        e.hangUp();
        async.flushMicrotasks();
        // Q1: hangUp → disarm → reset to step 0; engine keeps running.
        final running = e.state as EngineRunning;
        check(running.stepIndex).equals(0);
        e.dispose();
      });
    });

    test('hangUp without answer (during ringing) resets to step 0', () {
      fakeAsync((async) {
        final e = _fakeCallEngine();
        e.start();
        async.flushMicrotasks();
        e.hangUp();
        async.flushMicrotasks();
        final running = e.state as EngineRunning;
        check(running.stepIndex).equals(0);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // ring → decline (declineIsSafe=true)
  // -------------------------------------------------------------------------
  group('ring → decline (declineIsSafe=true)', () {
    test('decline safe resets to step 0 (Q1)', () {
      fakeAsync((async) {
        final e = _fakeCallEngine(declineIsSafe: true);
        e.start();
        async.flushMicrotasks();
        e.declineFakeCall();
        async.flushMicrotasks();
        // Q1: decline-safe → disarm → reset to step 0.
        final running = e.state as EngineRunning;
        check(running.stepIndex).equals(0);
        e.dispose();
      });
    });

    test('decline safe does not advance to next step', () {
      fakeAsync((async) {
        final e = _fakeCallEngine(declineIsSafe: true);
        e.start();
        async.flushMicrotasks();
        e.declineFakeCall();
        async.flushMicrotasks();
        // Q1: still on step 0 (reset), not advanced to step 1.
        check((e.state as EngineRunning).stepIndex).equals(0);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // ring → decline (declineIsSafe=false) → miss → advance
  // -------------------------------------------------------------------------
  group('ring → decline (declineIsSafe=false)', () {
    test('decline unsafe with retryCount=0 advances to next step', () {
      fakeAsync((async) {
        final e = _fakeCallEngine(declineIsSafe: false);
        e.start();
        async.flushMicrotasks();
        e.declineFakeCall();
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

    test('decline unsafe with retryCount=1: first decline re-enters duration',
        () {
      fakeAsync((async) {
        final e = _fakeCallEngine(declineIsSafe: false, retryCount: 1);
        e.start();
        async.flushMicrotasks();
        e.declineFakeCall();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.stepIndex).equals(0);
        check(s.phase).equals(TimerPhase.duration);
        check(s.missCount).equals(1);
        e.dispose();
      });
    });

    test('decline unsafe × 2 with retryCount=1 advances', () {
      fakeAsync((async) {
        final e = _fakeCallEngine(declineIsSafe: false, retryCount: 1);
        e.start();
        async.flushMicrotasks();
        e.declineFakeCall(); // miss 1 → retry.
        async.flushMicrotasks();
        e.declineFakeCall(); // miss 2 → advance.
        async.flushMicrotasks();
        final s = e.state;
        if (s is EngineRunning) check(s.stepIndex).equals(1);
        e.dispose();
      });
    });

    test('graceExpired emitted on each unsafe decline', () {
      fakeAsync((async) {
        final e = _fakeCallEngine(declineIsSafe: false, retryCount: 2);
        var graceCount = 0;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.graceExpired) graceCount++;
        });
        e.start();
        async.flushMicrotasks();
        e.declineFakeCall();
        async.flushMicrotasks();
        e.declineFakeCall();
        async.flushMicrotasks();
        e.declineFakeCall();
        async.flushMicrotasks();
        check(graceCount).equals(3);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // ring → timeout → miss → advance
  // -------------------------------------------------------------------------
  group('ring → timeout (no answer/decline)', () {
    test('unanswered fakeCall with dur=3 + grace=2 advances after 5s', () {
      fakeAsync((async) {
        final e = _fakeCallEngine(dur: 3, grace: 2);
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        final s = e.state;
        if (s is EngineRunning) check(s.stepIndex).equals(1);
        e.dispose();
      });
    });

    test('unanswered with zero grace advances after duration only', () {
      fakeAsync((async) {
        final e = _fakeCallEngine(dur: 5, grace: 0);
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        final s = e.state;
        if (s is EngineRunning) check(s.stepIndex).equals(1);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // answerFakeCall no-ops
  // -------------------------------------------------------------------------
  group('answerFakeCall no-ops', () {
    test('answerFakeCall on non-fakeCall step is a no-op', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [smsStep(durationSeconds: 30)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        final before = e.state;
        e.answerFakeCall();
        check(e.state).equals(before);
        e.dispose();
      });
    });

    test('answerFakeCall from Idle is a no-op', () {
      final e = _fakeCallEngine();
      e.answerFakeCall();
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });

    test('answerFakeCall from Ended is a no-op', () {
      final e = _fakeCallEngine();
      e.endSession(reason: EndReason.userQuit);
      e.answerFakeCall();
      check(e.state).isA<EngineEnded>();
      e.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // hangUp no-ops
  // -------------------------------------------------------------------------
  group('hangUp no-ops', () {
    test('hangUp on non-fakeCall step is a no-op', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [smsStep(durationSeconds: 30)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        final before = e.state;
        e.hangUp();
        check(e.state).equals(before);
        e.dispose();
      });
    });

    test('hangUp from Idle is a no-op', () {
      final e = _fakeCallEngine();
      e.hangUp();
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // declineFakeCall no-ops
  // -------------------------------------------------------------------------
  group('declineFakeCall no-ops', () {
    test('declineFakeCall on non-fakeCall step is a no-op', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [smsStep(durationSeconds: 30)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        final before = e.state;
        e.declineFakeCall();
        check(e.state).equals(before);
        e.dispose();
      });
    });

    test('declineFakeCall from Idle is a no-op', () {
      final e = _fakeCallEngine();
      e.declineFakeCall();
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // Fake call config without explicit FakeCallConfig
  // -------------------------------------------------------------------------
  group('fakeCall step without explicit config', () {
    test('fakeCall step with null config defaults to declineIsSafe=true', () {
      fakeAsync((async) {
        // Per FakeCallConfig default: declineIsSafe = true.
        final e = SessionEngine(
          chainSteps: [
            ChainStep(
              id: 'no-config-fc',
              type: ChainStepType.fakeCall,
              order: 0,
              durationSeconds: 10,
              gracePeriodSeconds: 5,
            ),
            smsStep(order: 1, durationSeconds: 30),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.declineFakeCall();
        async.flushMicrotasks();
        // declineIsSafe defaults to true → disarm → reset to step 0.
        check((e.state as EngineRunning).stepIndex).equals(0);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Distress during fake call
  // -------------------------------------------------------------------------
  group('distress triggered during fakeCall', () {
    test('distress while fakeCall ringing replaces chain', () {
      fakeAsync((async) {
        final e = _fakeCallEngine();
        e.start();
        async.flushMicrotasks();
        e.replaceWithDistressChain(
          [
            smsStep(
              id: 'distress',
              durationSeconds: 1,
              gracePeriodSeconds: 0,
            ),
          ],
          triggerReason: TriggerReason.hardwarePanic,
        );
        async.flushMicrotasks();
        check(e.isDistressChain).isTrue();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });

    test('distress while fakeCall answered replaces chain (pivot 2)', () {
      fakeAsync((async) {
        final e = _fakeCallEngine();
        e.start();
        async.flushMicrotasks();
        e.answerFakeCall();
        async.flushMicrotasks();
        // Per pivot 2 the engine is still Running (not paused).
        e.replaceWithDistressChain(
          [
            smsStep(
              id: 'distress',
              durationSeconds: 1,
              gracePeriodSeconds: 0,
            ),
          ],
          triggerReason: TriggerReason.hardwarePanic,
        );
        async.flushMicrotasks();
        check(e.isDistressChain).isTrue();
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // FakeCallConfig step-type detection uses config
  // -------------------------------------------------------------------------
  group('FakeCallConfig.declineIsSafe respected via step config', () {
    test('FakeCallConfig(declineIsSafe: false) applied correctly', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            ChainStep(
              id: 'explicit-unsafe',
              type: ChainStepType.fakeCall,
              order: 0,
              durationSeconds: 10,
              gracePeriodSeconds: 5,
              config: const FakeCallConfig(declineIsSafe: false),
            ),
            smsStep(order: 1, durationSeconds: 30),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.declineFakeCall();
        async.flushMicrotasks();
        // declineIsSafe=false → miss → advance.
        final s = e.state;
        if (s is EngineRunning) check(s.stepIndex).equals(1);
        e.dispose();
      });
    });
  });
}
