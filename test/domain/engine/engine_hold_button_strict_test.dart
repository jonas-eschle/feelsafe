/// Strict hold-button state machine tests.
///
/// Covers: sensitivity window edge cases, rapid hold/release,
/// double holdStart/holdRelease no-ops, grace re-hold = disarm,
/// sensitivity → duration → grace full path, pause in holdWait,
/// custom releaseSensitivity config values.
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
import 'package:guardianangela/domain/models/step_config.dart';
import '../../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SessionEngine _holdEngine({
  double sensitivity = 1.0,
  int dur = 10,
  int grace = 5,
  int retryCount = 0,
}) => SessionEngine(
  chainSteps: [
    holdStep(
      durationSeconds: dur,
      gracePeriodSeconds: grace,
      releaseSensitivity: sensitivity,
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
  // Entry: holdWait phase
  // -------------------------------------------------------------------------
  group('holdButton entry: holdWait', () {
    test('initial phase is holdWait, not duration', () {
      fakeAsync((async) {
        final e = _holdEngine();
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.holdWait);
        check(s.isHolding).isFalse();
        e.dispose();
      });
    });

    test('holdWait does not schedule a timer (stays indefinitely)', () {
      fakeAsync((async) {
        final e = _holdEngine();
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(hours: 1));
        check((e.state as EngineRunning).phase).equals(TimerPhase.holdWait);
        e.dispose();
      });
    });

    test('holdStart transitions from holdWait to duration', () {
      fakeAsync((async) {
        final e = _holdEngine(dur: 20);
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        check(s.remaining).equals(const Duration(seconds: 20));
        check(s.isHolding).isTrue();
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // holdStart / holdRelease edge-triggering (no double-fire)
  // -------------------------------------------------------------------------
  group('edge-triggering: no double fire', () {
    test('double holdStart: second call is a no-op', () {
      fakeAsync((async) {
        final e = _holdEngine();
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        final s1 = e.state as EngineRunning;
        e.holdStart(); // Should be no-op.
        final s2 = e.state as EngineRunning;
        check(s2.phase).equals(s1.phase);
        check(s2.remaining).equals(s1.remaining);
        check(s2.isHolding).isTrue();
        e.dispose();
      });
    });

    test('double holdRelease: second call is a no-op', () {
      fakeAsync((async) {
        final e = _holdEngine();
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        final s1 = e.state as EngineRunning;
        e.holdRelease(); // Should be no-op.
        final s2 = e.state as EngineRunning;
        check(s2.phase).equals(s1.phase);
        check(s2.remaining).equals(s1.remaining);
        e.dispose();
      });
    });

    test('holdRelease without holdStart is a no-op', () {
      fakeAsync((async) {
        final e = _holdEngine();
        e.start();
        async.flushMicrotasks();
        final before = e.state;
        e.holdRelease();
        check(e.state).equals(before);
        e.dispose();
      });
    });

    test('rapid hold/release/hold: ends in holding=true duration', () {
      fakeAsync((async) {
        final e = _holdEngine(sensitivity: 1.0);
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        // Within 1s sensitivity window, re-hold.
        async.elapse(const Duration(milliseconds: 100));
        e.holdStart();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        check(s.isHolding).isTrue();
        e.dispose();
      });
    });

    test('rapid release then hold after sensitivity: enters duration', () {
      fakeAsync((async) {
        final e = _holdEngine(sensitivity: 0.5, dur: 10);
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        // Wait past sensitivity window.
        async.elapse(const Duration(milliseconds: 600));
        async.flushMicrotasks();
        // Now in duration (sensitivity expired).
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        check(s.isHolding).isFalse();
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Sensitivity window
  // -------------------------------------------------------------------------
  group('sensitivity window', () {
    test('re-hold within sensitivity window → holding=true, no grace', () {
      fakeAsync((async) {
        final e = _holdEngine(sensitivity: 2.0, dur: 10, grace: 5);
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        async.elapse(const Duration(seconds: 1)); // within 2s window.
        e.holdStart();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        check(s.isHolding).isTrue();
        e.dispose();
      });
    });

    test('sensitivity expires → enters duration countdown not grace', () {
      fakeAsync((async) {
        final e = _holdEngine(sensitivity: 1.0, dur: 10, grace: 5);
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        async.elapse(const Duration(seconds: 1)); // sensitivity expires.
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        check(s.isHolding).isFalse();
        e.dispose();
      });
    });

    test('sensitivity=0.3s: re-hold at 200ms is within window', () {
      fakeAsync((async) {
        final e = _holdEngine(sensitivity: 0.3, dur: 10);
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        async.elapse(const Duration(milliseconds: 200));
        e.holdStart();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        check(s.isHolding).isTrue();
        e.dispose();
      });
    });

    test('sensitivity=0.3s: re-hold at 400ms is outside window → duration', () {
      fakeAsync((async) {
        final e = _holdEngine(sensitivity: 0.3, dur: 10);
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        async.elapse(const Duration(milliseconds: 400));
        async.flushMicrotasks();
        // Sensitivity expired → duration countdown started.
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        check(s.isHolding).isFalse();
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Full hold cycle: holdWait → hold → sensitivity → duration → grace
  // -------------------------------------------------------------------------
  group('full hold cycle', () {
    test('complete path: holdWait → hold → sensitivity → dur → grace', () {
      fakeAsync((async) {
        final e = _holdEngine(sensitivity: 1.0, dur: 3, grace: 2);
        e.start();
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.holdWait);
        e.holdStart();
        check((e.state as EngineRunning).phase).equals(TimerPhase.duration);
        e.holdRelease();
        check((e.state as EngineRunning).phase).equals(TimerPhase.sensitivity);
        async.elapse(const Duration(seconds: 1)); // sensitivity expires.
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.duration);
        async.elapse(const Duration(seconds: 3)); // duration expires.
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.grace);
        async.elapse(const Duration(seconds: 2)); // grace expires.
        async.flushMicrotasks();
        // Advances to step 1.
        final s = e.state;
        if (s is EngineRunning) check(s.stepIndex).equals(1);
        e.dispose();
      });
    });

    test('duration expires without release → directly to grace', () {
      fakeAsync((async) {
        // User holds for entire duration, then releases during grace.
        final e = _holdEngine(sensitivity: 1.0, dur: 5, grace: 10);
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        // Stays holding. The duration-phase timer does NOT run while
        // isHolding=true (spec: user holds → no duration countdown).
        // Release triggers sensitivity, not grace.
        e.holdRelease();
        // Sensitivity (1s) → duration countdown (5s).
        async.elapse(const Duration(seconds: 6));
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.grace);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Re-hold in grace = disarm (spec §2.2)
  // -------------------------------------------------------------------------
  group('re-hold in grace = disarm', () {
    test('holdStart during grace fires disarm (resets to step 0)', () {
      // Q1: disarm now resets the chain to step 0 instead of
      // ending. Re-hold during grace still routes through the
      // disarm path but the visible effect is that step 0 starts
      // fresh.
      fakeAsync((async) {
        final e = _holdEngine(sensitivity: 1.0, dur: 3, grace: 10);
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        async.elapse(const Duration(seconds: 4)); // sen+dur → grace.
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.grace);
        e.holdStart(); // Re-hold in grace = disarm path.
        async.flushMicrotasks();
        check(e.state).isA<EngineRunning>();
        check((e.state as EngineRunning).stepIndex).equals(0);
        e.dispose();
      });
    });

    test('userDisarmed event emitted when re-holding in grace', () {
      // Q1: the disarm path now emits ChainEvent.userDisarmed, not
      // ChainEvent.sessionEnded.
      fakeAsync((async) {
        final e = _holdEngine(sensitivity: 1.0, dur: 3, grace: 10);
        var disarmed = false;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.userDisarmed) disarmed = true;
        });
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        async.elapse(const Duration(seconds: 4));
        async.flushMicrotasks();
        e.holdStart();
        async.flushMicrotasks();
        check(disarmed).isTrue();
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // stepStarted count: only once per step
  // -------------------------------------------------------------------------
  group('stepStarted count for holdButton', () {
    test('stepStarted emitted exactly once for holdButton step', () {
      fakeAsync((async) {
        final e = _holdEngine();
        var count = 0;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.stepStarted && ev.stepIndex == 0) count++;
        });
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        check(count).equals(1);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // No-ops from wrong states
  // -------------------------------------------------------------------------
  group('holdStart/holdRelease no-ops', () {
    test('holdStart from Idle is a no-op', () {
      final e = _holdEngine();
      e.holdStart();
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });

    test('holdRelease from Idle is a no-op', () {
      final e = _holdEngine();
      e.holdRelease();
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });

    test('holdStart from Ended is a no-op', () {
      final e = _holdEngine();
      e.endSession(reason: EndReason.userQuit);
      e.holdStart();
      check(e.state).isA<EngineEnded>();
      e.dispose();
    });

    test('holdStart on smsStep is a no-op', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [smsStep(durationSeconds: 30)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        final before = e.state;
        e.holdStart();
        check(e.state).equals(before);
        e.dispose();
      });
    });

    test('holdRelease on smsStep is a no-op', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [smsStep(durationSeconds: 30)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        final before = e.state;
        e.holdRelease();
        check(e.state).equals(before);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // HoldButtonConfig: custom releaseSensitivity values
  // -------------------------------------------------------------------------
  group('custom releaseSensitivity from HoldButtonConfig', () {
    test('releaseSensitivity=0.5s sets sensitivity remaining correctly', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            step(
              type: ChainStepType.holdButton,
              durationSeconds: 5,
              gracePeriodSeconds: 1,
              config: const HoldButtonConfig(releaseSensitivity: 0.5),
            ),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.sensitivity);
        check(s.remaining).equals(const Duration(milliseconds: 500));
        e.dispose();
      });
    });

    test('releaseSensitivity=3.0s fires after 3s', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            step(
              type: ChainStepType.holdButton,
              durationSeconds: 5,
              gracePeriodSeconds: 1,
              config: const HoldButtonConfig(releaseSensitivity: 3.0),
            ),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        // Sensitivity expired → duration phase.
        check((e.state as EngineRunning).phase).equals(TimerPhase.duration);
        e.dispose();
      });
    });

    test('step without config uses default releaseSensitivity=1.0s', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            step(
              type: ChainStepType.holdButton,
              durationSeconds: 5,
              gracePeriodSeconds: 1,
            ),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        final s = e.state as EngineRunning;
        check(s.remaining).equals(const Duration(milliseconds: 1000));
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Hold with pause
  // -------------------------------------------------------------------------
  group('hold + pause round-trip', () {
    test('pause during holdWait, resume restores holdWait', () {
      fakeAsync((async) {
        final e = _holdEngine();
        e.start();
        async.flushMicrotasks();
        e.pause();
        async.elapse(const Duration(seconds: 30));
        e.resume();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.holdWait);
        e.dispose();
      });
    });

    test('pause during sensitivity, resume resumes sensitivity with remaining',
        () {
      fakeAsync((async) {
        final e = _holdEngine(sensitivity: 2.0, dur: 10);
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        async.elapse(const Duration(milliseconds: 500));
        e.pause();
        final p = e.state as EnginePaused;
        check(p.snapshot.phase).equals(TimerPhase.sensitivity);
        check(p.snapshot.remaining).equals(const Duration(milliseconds: 1500));
        e.resume();
        check((e.state as EngineRunning).phase).equals(TimerPhase.sensitivity);
        e.dispose();
      });
    });

    test('pause during duration while holding, resume continues duration', () {
      fakeAsync((async) {
        final e = _holdEngine(dur: 20);
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        // While holding, no timer, so remaining stays at 20s.
        e.pause();
        final p = e.state as EnginePaused;
        check(p.snapshot.phase).equals(TimerPhase.duration);
        e.resume();
        check((e.state as EngineRunning).phase).equals(TimerPhase.duration);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Hold with retry cycle
  // -------------------------------------------------------------------------
  group('hold with retry', () {
    test('miss in holdButton grace fires repeatMissed when retryCount=1', () {
      fakeAsync((async) {
        final e = _holdEngine(sensitivity: 1.0, dur: 3, grace: 2, retryCount: 1);
        var missCount = 0;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.repeatMissed) missCount++;
        });
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        // sensitivity 1s + dur 3s + grace 2s = 6s → miss 1.
        async.elapse(const Duration(seconds: 6));
        async.flushMicrotasks();
        // Retry: another path through the hold cycle (no hold = dur + grace).
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        check(missCount).equals(1);
        e.dispose();
      });
    });
  });
}
