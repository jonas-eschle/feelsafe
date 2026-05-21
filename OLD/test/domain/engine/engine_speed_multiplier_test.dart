/// Speed-multiplier × all step-type phase-duration tests.
///
/// Spec: scaled = (base_seconds × jitter_factor) / effectiveMultiplier.
/// With FixedRandom(0.5), jitter_factor = 1.0, so scaled = base/mult.
///
/// We verify 1.0, 0.01 (slow-down), 60.0 and 1000.0 multipliers
/// against wait, duration, and grace phases for representative step
/// types.
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/timer_phase.dart';
import '../../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SessionEngine _simEngine(
  double speed, {
  int waitSecs = 0,
  int durSecs = 60,
  int graceSecs = 30,
}) => SessionEngine(
  chainSteps: [
    smsStep(
      durationSeconds: durSecs,
      gracePeriodSeconds: graceSecs,
    ).copyWith(waitSeconds: waitSecs, randomize: 0.0),
  ],
  isSimulation: true,
  speedMultiplier: speed,
  random: FixedRandom(),
);

/// Expected microseconds for base [secs] at multiplier [mult].
int _us(int secs, double mult) =>
    ((secs / mult) * Duration.microsecondsPerSecond).round();

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Multiplier 1.0 (real-time baseline)
  // -------------------------------------------------------------------------
  group('speedMultiplier=1.0 (identity)', () {
    test('wait phase remaining = waitSeconds exactly', () {
      fakeAsync((async) {
        final e = _simEngine(1.0, waitSecs: 30, durSecs: 10);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.wait);
        check(s.remaining.inSeconds).equals(30);
        e.dispose();
      });
    });

    test('duration phase remaining = durationSeconds exactly', () {
      fakeAsync((async) {
        final e = _simEngine(1.0, waitSecs: 0, durSecs: 45);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        check(s.remaining.inSeconds).equals(45);
        e.dispose();
      });
    });

    test('grace phase remaining = gracePeriodSeconds exactly', () {
      fakeAsync((async) {
        final e = _simEngine(1.0, durSecs: 5, graceSecs: 20);
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.grace);
        check(s.remaining.inSeconds).equals(20);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Multiplier 0.01 (100× slower)
  // -------------------------------------------------------------------------
  group('speedMultiplier=0.01 (100× slower)', () {
    test('60s duration becomes 6000s (100×)', () {
      fakeAsync((async) {
        final e = _simEngine(0.01, durSecs: 60);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        check(s.remaining.inSeconds).equals(6000);
        e.dispose();
      });
    });

    test('10s wait becomes 1000s', () {
      fakeAsync((async) {
        final e = _simEngine(0.01, waitSecs: 10, durSecs: 5);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.wait);
        check(s.remaining.inSeconds).equals(1000);
        e.dispose();
      });
    });

    test('timer fires after 1000s of fake-async elapse (60s step / 0.01)', () {
      fakeAsync((async) {
        final e = _simEngine(0.01, durSecs: 60, graceSecs: 0);
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 6000));
        async.flushMicrotasks();
        // Duration exhausted, grace=0 → ends.
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Multiplier 60.0
  // -------------------------------------------------------------------------
  group('speedMultiplier=60.0 (1min → 1s)', () {
    test('60s duration becomes 1s', () {
      fakeAsync((async) {
        final e = _simEngine(60.0, durSecs: 60);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        check(s.remaining.inSeconds).equals(1);
        e.dispose();
      });
    });

    test('120s wait becomes 2s', () {
      fakeAsync((async) {
        final e = _simEngine(60.0, waitSecs: 120, durSecs: 10);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.remaining.inSeconds).equals(2);
        e.dispose();
      });
    });

    test('30s grace becomes 500ms', () {
      fakeAsync((async) {
        final e = _simEngine(60.0, durSecs: 1, graceSecs: 30);
        e.start();
        async.flushMicrotasks();
        // Elapse 1s/60 to pass duration.
        async.elapse(Duration(microseconds: _us(1, 60.0)));
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.grace);
        check(s.remaining.inMilliseconds).equals(500);
        e.dispose();
      });
    });

    test('full step (dur=60,grace=0) completes in 1s', () {
      fakeAsync((async) {
        final e = _simEngine(60.0, durSecs: 60, graceSecs: 0);
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Multiplier 1000.0
  // -------------------------------------------------------------------------
  group('speedMultiplier=1000.0', () {
    test('60s duration becomes 60ms', () {
      fakeAsync((async) {
        final e = _simEngine(1000.0, durSecs: 60);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        check(s.remaining.inMilliseconds).equals(60);
        e.dispose();
      });
    });

    test('1000s duration becomes exactly 1s', () {
      fakeAsync((async) {
        final e = _simEngine(1000.0, durSecs: 1000);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.remaining.inSeconds).equals(1);
        e.dispose();
      });
    });

    test('3600s duration (1h) becomes 3600ms (3.6s)', () {
      fakeAsync((async) {
        final e = _simEngine(1000.0, durSecs: 3600, graceSecs: 0);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.remaining.inMilliseconds).equals(3600);
        e.dispose();
      });
    });

    test('10s grace at 1000× = 10ms — timer fires after 10ms', () {
      fakeAsync((async) {
        final e = _simEngine(1000.0, durSecs: 1, graceSecs: 10);
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 1)); // dur.
        async.flushMicrotasks();
        final g = e.state as EngineRunning;
        check(g.phase).equals(TimerPhase.grace);
        async.elapse(const Duration(milliseconds: 10)); // grace.
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // setSpeedMultiplier mid-run
  // -------------------------------------------------------------------------
  group('setSpeedMultiplier changes apply to subsequent phases', () {
    test('change multiplier 1× → 60× shortens next phase', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(
              durationSeconds: 60,
              gracePeriodSeconds: 60,
            ).copyWith(waitSeconds: 60, randomize: 0.0),
            smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
          ],
          isSimulation: true,
          speedMultiplier: 1.0,
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        // Currently in wait phase at 1×.
        check((e.state as EngineRunning).phase).equals(TimerPhase.wait);
        check((e.state as EngineRunning).remaining.inSeconds).equals(60);
        // Change to 60× — already-scheduled timer keeps original deadline.
        e.setSpeedMultiplier(60.0);
        // Advance current wait phase to completion.
        async.elapse(const Duration(seconds: 60));
        async.flushMicrotasks();
        // Enters duration. At 60×, 60s dur = 1s.
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        check(s.remaining.inSeconds).equals(1);
        e.dispose();
      });
    });

    test('setSpeedMultiplier NaN throws ArgumentError in sim mode', () {
      final e = SessionEngine(
        chainSteps: [holdStep()],
        isSimulation: true,
        random: FixedRandom(),
      );
      check(() => e.setSpeedMultiplier(double.nan)).throws<ArgumentError>();
      e.dispose();
    });

    test('setSpeedMultiplier 0 throws ArgumentError in sim mode', () {
      final e = SessionEngine(
        chainSteps: [holdStep()],
        isSimulation: true,
        random: FixedRandom(),
      );
      check(() => e.setSpeedMultiplier(0)).throws<ArgumentError>();
      e.dispose();
    });

    test('setSpeedMultiplier -1 throws ArgumentError', () {
      final e = SessionEngine(
        chainSteps: [holdStep()],
        isSimulation: true,
        random: FixedRandom(),
      );
      check(() => e.setSpeedMultiplier(-1)).throws<ArgumentError>();
      e.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // Hold-button sensitivity phase scaled by multiplier
  // -------------------------------------------------------------------------
  group('holdButton sensitivity scaling', () {
    test('sensitivity=1.0s at 10× becomes 100ms', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [holdStep(releaseSensitivity: 1.0, durationSeconds: 10)],
          isSimulation: true,
          speedMultiplier: 10.0,
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.sensitivity);
        check(s.remaining.inMilliseconds).equals(100);
        e.dispose();
      });
    });

    test('sensitivity=2.0s at 4× becomes 500ms', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [holdStep(releaseSensitivity: 2.0, durationSeconds: 10)],
          isSimulation: true,
          speedMultiplier: 4.0,
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        final s = e.state as EngineRunning;
        check(s.remaining.inMilliseconds).equals(500);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Multi-step chain timing
  // -------------------------------------------------------------------------
  group('multi-step chain at 10× speed', () {
    test('two steps complete in expected wall-clock time at 10×', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(durationSeconds: 10, gracePeriodSeconds: 0),
            smsStep(order: 1, durationSeconds: 20, gracePeriodSeconds: 0),
          ],
          isSimulation: true,
          speedMultiplier: 10.0,
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        // Step 0: 10s / 10 = 1s.
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        check((e.state as EngineRunning).stepIndex).equals(1);
        // Step 1: 20s / 10 = 2s.
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Speed multiplier does not affect real sessions
  // -------------------------------------------------------------------------
  group('real session always uses 1.0× (no override)', () {
    test('real session rejects speedMultiplier != 1.0 at construction', () {
      check(
        () => SessionEngine(
          chainSteps: [holdStep()],
          speedMultiplier: 2.0,
          random: FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });

    test('real session effectiveSpeedMultiplier is always 1.0', () {
      final e = SessionEngine(chainSteps: [holdStep()], random: FixedRandom());
      check(e.effectiveSpeedMultiplier).equals(1.0);
      e.dispose();
    });
  });
}
