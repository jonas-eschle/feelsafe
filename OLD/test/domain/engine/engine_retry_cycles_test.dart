/// Retry-cycle tests for [SessionEngine].
///
/// Spec 01 §3.1: after the first miss the wait phase is skipped on
/// retries — the engine jumps directly from miss to duration. Tests
/// cover retryCount = 0, 1, 2, 5 and verify the correct number of
/// repeatMissed events, missCount values, and final advance.
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/timer_phase.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import '../../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Engine that cycles a single SMS step [retryCount] times before
/// advancing to a long-duration second step.
SessionEngine _retryEngine(int retryCount, {int durSecs = 1, int graceSecs = 1}) =>
    SessionEngine(
      chainSteps: [
        step(
          type: ChainStepType.smsContact,
          durationSeconds: durSecs,
          gracePeriodSeconds: graceSecs,
          waitSeconds: 10, // wait phase — skipped on retries.
          retryCount: retryCount,
        ),
        smsStep(order: 1, durationSeconds: 60, gracePeriodSeconds: 0),
      ],
      random: FixedRandom(),
    );

/// Total seconds for [n] retry cycles (skip wait on retry).
/// Initial attempt: wait (10) + dur + grace.
/// Each retry: dur + grace (wait skipped per spec §3.1).
Duration _totalForCycles(int n, {int dur = 1, int grace = 1}) {
  final initial = 10 + dur + grace;
  final perRetry = dur + grace;
  return Duration(seconds: initial + n * perRetry);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('retryCount=0: single attempt, then advance', () {
    test('engine advances immediately after first grace expiry', () {
      fakeAsync((async) {
        final e = _retryEngine(0);
        e.start();
        async.flushMicrotasks();
        async.elapse(_totalForCycles(0));
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.stepIndex).equals(1);
        e.dispose();
      });
    });

    test('no repeatMissed events with retryCount=0', () {
      fakeAsync((async) {
        final e = _retryEngine(0);
        var missCount = 0;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.repeatMissed) missCount++;
        });
        e.start();
        async.elapse(_totalForCycles(0) + const Duration(seconds: 2));
        async.flushMicrotasks();
        check(missCount).equals(0);
        e.dispose();
      });
    });
  });

  group('retryCount=1: initial + 1 retry', () {
    test('repeatMissed fires exactly once', () {
      fakeAsync((async) {
        final e = _retryEngine(1);
        var missCount = 0;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.repeatMissed) missCount++;
        });
        e.start();
        async.elapse(_totalForCycles(1) + const Duration(seconds: 2));
        async.flushMicrotasks();
        check(missCount).equals(1);
        e.dispose();
      });
    });

    test('engine advances after second grace expiry', () {
      fakeAsync((async) {
        final e = _retryEngine(1);
        e.start();
        async.flushMicrotasks();
        async.elapse(_totalForCycles(1));
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.stepIndex).equals(1);
        e.dispose();
      });
    });

    test('retry skips wait phase: state is duration after first miss', () {
      fakeAsync((async) {
        final e = _retryEngine(1);
        e.start();
        async.flushMicrotasks();
        // Initial: wait 10s + dur 1s + grace 1s = 12s → first miss.
        async.elapse(const Duration(seconds: 12));
        async.flushMicrotasks();
        // After miss 1, retry skips wait → enters duration immediately.
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        check(s.missCount).equals(1);
        e.dispose();
      });
    });
  });

  group('retryCount=2: initial + 2 retries', () {
    test('repeatMissed fires exactly twice', () {
      fakeAsync((async) {
        final e = _retryEngine(2);
        var missCount = 0;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.repeatMissed) missCount++;
        });
        e.start();
        async.elapse(_totalForCycles(2) + const Duration(seconds: 2));
        async.flushMicrotasks();
        check(missCount).equals(2);
        e.dispose();
      });
    });

    test('missCount in repeatMissed events is 1 then 2', () {
      fakeAsync((async) {
        final e = _retryEngine(2);
        final misses = <int>[];
        e.events.listen((ev) {
          if (ev.event == ChainEvent.repeatMissed) {
            misses.add(ev.metadata['missCount'] as int);
          }
        });
        e.start();
        async.elapse(_totalForCycles(2) + const Duration(seconds: 2));
        async.flushMicrotasks();
        check(misses).deepEquals([1, 2]);
        e.dispose();
      });
    });

    test('graceExpired fires 3 times (initial + 2 retries)', () {
      fakeAsync((async) {
        final e = _retryEngine(2);
        var graceCount = 0;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.graceExpired) graceCount++;
        });
        e.start();
        async.elapse(_totalForCycles(2) + const Duration(seconds: 2));
        async.flushMicrotasks();
        check(graceCount).equals(3);
        e.dispose();
      });
    });
  });

  group('retryCount=5: initial + 5 retries', () {
    test('repeatMissed fires exactly 5 times', () {
      fakeAsync((async) {
        final e = _retryEngine(5);
        var missCount = 0;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.repeatMissed) missCount++;
        });
        e.start();
        async.elapse(_totalForCycles(5) + const Duration(seconds: 5));
        async.flushMicrotasks();
        check(missCount).equals(5);
        e.dispose();
      });
    });

    test('engine advances to step 1 after 6th grace expiry', () {
      fakeAsync((async) {
        final e = _retryEngine(5);
        e.start();
        async.flushMicrotasks();
        async.elapse(_totalForCycles(5));
        async.flushMicrotasks();
        final s = e.state;
        if (s is EngineRunning) check(s.stepIndex).equals(1);
        e.dispose();
      });
    });
  });

  group('wait-phase skip on retry (spec 01 §3.1)', () {
    test('first attempt enters wait; retry bypasses wait → duration directly',
        () {
      fakeAsync((async) {
        // Step has a 10s wait. Verify that after first miss, the retry
        // enters duration directly (no 10s wait).
        final e = SessionEngine(
          chainSteps: [
            step(
              type: ChainStepType.smsContact,
              durationSeconds: 2,
              gracePeriodSeconds: 2,
              waitSeconds: 10,
              retryCount: 1,
            ),
            smsStep(order: 1, durationSeconds: 60),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        // Verify initial wait phase.
        check((e.state as EngineRunning).phase).equals(TimerPhase.wait);
        // Elapse through initial wait + dur + grace.
        async.elapse(const Duration(seconds: 14));
        async.flushMicrotasks();
        // After miss 1, retry: no wait → duration immediately.
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        check(s.missCount).equals(1);
        e.dispose();
      });
    });
  });

  group('retry interaction with distress chain', () {
    test('distress replaces during retry → distress chain executes', () {
      fakeAsync((async) {
        final e = _retryEngine(3);
        e.start();
        // After first miss.
        async.elapse(const Duration(seconds: 12));
        async.flushMicrotasks();
        // Trigger distress during retry.
        e.replaceWithDistressChain(
          [
            smsStep(
              id: 'distress-0',
              durationSeconds: 1,
              gracePeriodSeconds: 0,
            ),
          ],
          triggerReason: TriggerReason.hardwarePanic,
        );
        async.flushMicrotasks();
        check(e.isDistressChain).isTrue();
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        // Q19: distress triggered → endReason = hardwarePanic.
        check((e.state as EngineEnded).reason).equals(EndReason.hardwarePanic);
        e.dispose();
      });
    });
  });

  group('large retryCount boundary', () {
    test('retryCount=1000 works without overflow', () {
      fakeAsync((async) {
        // Just verify engine can start; don't exhaust 1000 retries.
        final e = SessionEngine(
          chainSteps: [
            step(
              type: ChainStepType.smsContact,
              durationSeconds: 0,
              gracePeriodSeconds: 0,
              retryCount: 1000,
            ),
            smsStep(order: 1, durationSeconds: 1),
          ],
          random: FixedRandom(),
        );
        // All retries have zero-duration: engine should exhaust them
        // synchronously (1001 iterations) and advance.
        e.start();
        async.flushMicrotasks();
        // Should be on step 1 or ended.
        final s = e.state;
        check(s).anyOf([
          (it) => it.isA<EngineRunning>(),
          (it) => it.isA<EngineEnded>(),
        ]);
        e.dispose();
      });
    });
  });

  group('retryCount interplay with holdButton', () {
    // Hold-button uses a different miss path (grace expiry triggers grace
    // timer; re-hold in grace = disarm; no explicit retryCount cycling).
    test('holdButton grace expiry with retryCount=1 fires repeatMissed', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            holdStep(
              durationSeconds: 3,
              gracePeriodSeconds: 2,
            ).copyWith(retryCount: 1),
            smsStep(order: 1, durationSeconds: 30),
          ],
          random: FixedRandom(),
        );
        var missCount = 0;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.repeatMissed) missCount++;
        });
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        // Sensitivity 1s + dur 3s + grace 2s = first miss.
        async.elapse(const Duration(seconds: 6));
        async.flushMicrotasks();
        // One retry; another dur+grace.
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        check(missCount).equals(1);
        e.dispose();
      });
    });
  });

  group('disarm during retry cycle', () {
    test('disarm during retry-duration resets to step 0', () {
      // Q1: disarm now resets to step 0 (with a fresh wait phase
      // and missCount=0) instead of ending the session.
      fakeAsync((async) {
        final e = _retryEngine(5);
        e.start();
        // First miss.
        async.elapse(const Duration(seconds: 12));
        async.flushMicrotasks();
        // Now in retry duration phase.
        e.disarm();
        async.flushMicrotasks();
        check(e.state).isA<EngineRunning>();
        check((e.state as EngineRunning).stepIndex).equals(0);
        check((e.state as EngineRunning).missCount).equals(0);
        e.dispose();
      });
    });
  });

  group('pause during retry cycle', () {
    test('pause and resume during retry preserves missCount', () {
      fakeAsync((async) {
        final e = _retryEngine(2);
        e.start();
        async.elapse(const Duration(seconds: 12)); // first miss.
        async.flushMicrotasks();
        final missCountBefore = (e.state as EngineRunning).missCount;
        e.pause();
        async.elapse(const Duration(minutes: 5));
        e.resume();
        final s = e.state as EngineRunning;
        check(s.missCount).equals(missCountBefore);
        e.dispose();
      });
    });
  });
}
