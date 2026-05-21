/// Jitter tests for SessionEngine.
///
/// Spec: jitterFactor = 1 + 0.2 × r × swing, where r = randomize ∈ [0,1]
/// and swing = nextDouble() × 2 − 1.
///
/// With FixedRandom(0.0): swing = −1 → factor = 1 − 0.2r
/// With FixedRandom(0.5): swing =  0 → factor = 1.0 (identity)
/// With FixedRandom(1.0): swing = +1 → factor = 1 + 0.2r
///
/// Randomize > 1.0 is clamped to 1.0 per spec.
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

SessionEngine _jitterEngine(
  double randomizeFactor,
  FixedRandom random, {
  int waitSecs = 0,
  int durSecs = 100,
  int graceSecs = 0,
}) => SessionEngine(
  chainSteps: [
    smsStep(
      durationSeconds: durSecs,
      gracePeriodSeconds: graceSecs,
    ).copyWith(waitSeconds: waitSecs, randomize: randomizeFactor),
  ],
  random: random,
);

/// Expected µs: (base × factor) / mult, rounded.
int _expectedUs(int secs, double factor) =>
    (secs * factor * Duration.microsecondsPerSecond).round();

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // randomize = 0.0: no jitter regardless of Random value
  // -------------------------------------------------------------------------
  group('randomize=0.0: jitter disabled', () {
    for (final rv in [0.0, 0.5, 1.0]) {
      test('randomize=0 with FixedRandom($rv) → exact base duration', () {
        fakeAsync((async) {
          final e = _jitterEngine(0.0, FixedRandom(rv), durSecs: 100);
          e.start();
          async.flushMicrotasks();
          final s = e.state as EngineRunning;
          check(s.remaining.inSeconds).equals(100);
          e.dispose();
        });
      });
    }

    test('randomize=0 in wait phase also applies no jitter', () {
      fakeAsync((async) {
        final e = _jitterEngine(0.0, FixedRandom(0.0), waitSecs: 50, durSecs: 1);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.remaining.inSeconds).equals(50);
        e.dispose();
      });
    });

    test('randomize=0 in grace phase also applies no jitter', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(durationSeconds: 5, gracePeriodSeconds: 30).copyWith(
              randomize: 0.0,
            ),
          ],
          random: FixedRandom(1.0),
        );
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.grace);
        check(s.remaining.inSeconds).equals(30);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // randomize = 0.5: swing halved
  // -------------------------------------------------------------------------
  group('randomize=0.5', () {
    test('FixedRandom(0.5) → swing=0 → factor=1.0 → unchanged duration', () {
      fakeAsync((async) {
        final e = _jitterEngine(0.5, FixedRandom(0.5), durSecs: 200);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        // factor = 1 + 0.2 * 0.5 * 0 = 1.0
        check(s.remaining.inSeconds).equals(200);
        e.dispose();
      });
    });

    test('FixedRandom(0.0) → swing=−1 → factor=0.9 → 0.9×dur', () {
      fakeAsync((async) {
        final e = _jitterEngine(0.5, FixedRandom(0.0), durSecs: 100);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        // factor = 1 + 0.2 * 0.5 * (0*2-1) = 1 - 0.1 = 0.9
        check(s.remaining.inSeconds).equals(90);
        e.dispose();
      });
    });

    test('FixedRandom(1.0) → swing=+1 → factor=1.1 → 1.1×dur', () {
      fakeAsync((async) {
        final e = _jitterEngine(0.5, FixedRandom(1.0), durSecs: 100);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        // factor = 1 + 0.2 * 0.5 * 1 = 1.1
        check(s.remaining.inSeconds).equals(110);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // randomize = 1.0: full ±20% range
  // -------------------------------------------------------------------------
  group('randomize=1.0: full range', () {
    test('FixedRandom(0.5) → factor=1.0 → exact base duration', () {
      fakeAsync((async) {
        final e = _jitterEngine(1.0, FixedRandom(0.5), durSecs: 100);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.remaining.inSeconds).equals(100);
        e.dispose();
      });
    });

    test('FixedRandom(0.0) → factor=0.8 → 80s for 100s base', () {
      fakeAsync((async) {
        final e = _jitterEngine(1.0, FixedRandom(0.0), durSecs: 100);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.remaining.inSeconds).equals(80);
        e.dispose();
      });
    });

    test('FixedRandom(1.0) → factor=1.2 → 120s for 100s base', () {
      fakeAsync((async) {
        final e = _jitterEngine(1.0, FixedRandom(1.0), durSecs: 100);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.remaining.inSeconds).equals(120);
        e.dispose();
      });
    });

    test('FixedRandom(0.0) with wait phase: factor=0.8 → 80s for 100s wait',
        () {
      fakeAsync((async) {
        final e = _jitterEngine(1.0, FixedRandom(0.0), waitSecs: 100, durSecs: 1);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.remaining.inSeconds).equals(80);
        e.dispose();
      });
    });

    test('FixedRandom(1.0) with grace phase: factor=1.2 → 120s for 100s grace',
        () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(durationSeconds: 5, gracePeriodSeconds: 100).copyWith(
              randomize: 1.0,
            ),
          ],
          random: FixedRandom(1.0),
        );
        e.start();
        async.flushMicrotasks();
        async.elapse(
          Duration(microseconds: _expectedUs(5, 1.2)),
        ); // dur × 1.2.
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.grace);
        // Grace: 100 × 1.2 = 120s.
        check(s.remaining.inSeconds).equals(120);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // randomize clamping above 1.0
  // -------------------------------------------------------------------------
  group('randomize clamped to 1.0', () {
    test('randomize=2.0 treated as 1.0: FixedRandom(1.0) → factor=1.2', () {
      fakeAsync((async) {
        final e = _jitterEngine(2.0, FixedRandom(1.0), durSecs: 100);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        // Clamped to 1.0 → factor = 1.2.
        check(s.remaining.inSeconds).equals(120);
        e.dispose();
      });
    });

    test('randomize=5.0 clamped: FixedRandom(0.0) → factor=0.8', () {
      fakeAsync((async) {
        final e = _jitterEngine(5.0, FixedRandom(0.0), durSecs: 100);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.remaining.inSeconds).equals(80);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Jitter applied independently per phase (separate Random draws)
  // -------------------------------------------------------------------------
  group('jitter applied independently to each phase', () {
    test('wait and duration phases each draw from Random independently', () {
      fakeAsync((async) {
        // FixedRandom always returns the same value, so both phases
        // will use the same factor — but the key is they both use jitter.
        final e = SessionEngine(
          chainSteps: [
            smsStep(durationSeconds: 100, gracePeriodSeconds: 0).copyWith(
              waitSeconds: 100,
              randomize: 1.0,
            ),
          ],
          random: FixedRandom(1.0), // factor 1.2 for every draw.
        );
        e.start();
        async.flushMicrotasks();
        // Wait phase: 100s × 1.2 = 120s.
        check((e.state as EngineRunning).remaining.inSeconds).equals(120);
        async.elapse(const Duration(seconds: 120));
        async.flushMicrotasks();
        // Duration phase: also 100s × 1.2 = 120s.
        check((e.state as EngineRunning).remaining.inSeconds).equals(120);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Jitter with speed multiplier combined
  // -------------------------------------------------------------------------
  group('jitter + speed multiplier combined', () {
    test('randomize=1, random=1.0, mult=2: (100s × 1.2) / 2 = 60s', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(durationSeconds: 100, gracePeriodSeconds: 0).copyWith(
              randomize: 1.0,
            ),
          ],
          isSimulation: true,
          speedMultiplier: 2.0,
          random: FixedRandom(1.0),
        );
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.remaining.inSeconds).equals(60);
        e.dispose();
      });
    });

    test('randomize=1, random=0.0, mult=2: (100s × 0.8) / 2 = 40s', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(durationSeconds: 100, gracePeriodSeconds: 0).copyWith(
              randomize: 1.0,
            ),
          ],
          isSimulation: true,
          speedMultiplier: 2.0,
          random: FixedRandom(0.0),
        );
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.remaining.inSeconds).equals(40);
        e.dispose();
      });
    });
  });
}
