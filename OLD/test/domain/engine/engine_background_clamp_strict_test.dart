/// Strict background-clamp tests.
///
/// Spec: background clamp caps effectiveSpeedMultiplier at 60× without
/// mutating the stored speedMultiplier. Real sessions ignore the clamp.
/// Tests verify every state at the moment setBackgroundClamp is called.
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

SessionEngine _sim(double speed) => SessionEngine(
  chainSteps: [
    smsStep(durationSeconds: 60, gracePeriodSeconds: 30).copyWith(
      waitSeconds: 60,
      randomize: 0.0,
    ),
  ],
  isSimulation: true,
  speedMultiplier: speed,
  random: FixedRandom(),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // effectiveSpeedMultiplier logic
  // -------------------------------------------------------------------------
  group('effectiveSpeedMultiplier: no clamp', () {
    test('below 60× → effective = stored', () {
      final e = _sim(30.0);
      addTearDown(e.dispose);
      e.setBackgroundClamp(true);
      check(e.effectiveSpeedMultiplier).equals(30.0);
    });

    test('exactly 60× → effective = 60.0 (boundary, no clamp)', () {
      final e = _sim(60.0);
      addTearDown(e.dispose);
      e.setBackgroundClamp(true);
      check(e.effectiveSpeedMultiplier).equals(60.0);
    });

    test('clamp off → effective = stored even at 500×', () {
      final e = _sim(500.0);
      addTearDown(e.dispose);
      check(e.backgroundClamp).isFalse();
      check(e.effectiveSpeedMultiplier).equals(500.0);
    });
  });

  group('effectiveSpeedMultiplier: clamped', () {
    test('61× clamped → effective = 60.0', () {
      final e = _sim(61.0);
      addTearDown(e.dispose);
      e.setBackgroundClamp(true);
      check(e.effectiveSpeedMultiplier).equals(60.0);
    });

    test('1000× clamped → effective = 60.0', () {
      final e = _sim(1000.0);
      addTearDown(e.dispose);
      e.setBackgroundClamp(true);
      check(e.effectiveSpeedMultiplier).equals(60.0);
    });

    test('stored speedMultiplier unchanged after clamp', () {
      final e = _sim(500.0);
      addTearDown(e.dispose);
      e.setBackgroundClamp(true);
      check(e.speedMultiplier).equals(500.0);
    });

    test('toggle clamp off restores effective = stored', () {
      final e = _sim(200.0);
      addTearDown(e.dispose);
      e.setBackgroundClamp(true);
      check(e.effectiveSpeedMultiplier).equals(60.0);
      e.setBackgroundClamp(false);
      check(e.effectiveSpeedMultiplier).equals(200.0);
    });
  });

  // -------------------------------------------------------------------------
  // Real sessions ignore setBackgroundClamp
  // -------------------------------------------------------------------------
  group('real session: setBackgroundClamp is always a no-op', () {
    test('real session clamp stays false after setBackgroundClamp(true)', () {
      final e = SessionEngine(
        chainSteps: [holdStep()],
        random: FixedRandom(),
      );
      addTearDown(e.dispose);
      e.setBackgroundClamp(true);
      check(e.backgroundClamp).isFalse();
    });

    test('real session effective multiplier always 1.0', () {
      final e = SessionEngine(
        chainSteps: [holdStep()],
        random: FixedRandom(),
      );
      addTearDown(e.dispose);
      e.setBackgroundClamp(true);
      check(e.effectiveSpeedMultiplier).equals(1.0);
    });
  });

  // -------------------------------------------------------------------------
  // Clamp engaged at every state (idle, running, paused, ended)
  // -------------------------------------------------------------------------
  group('clamp engaged from every engine state', () {
    test('clamp from Idle: effectiveSpeedMultiplier reflects clamp', () {
      final e = _sim(200.0);
      addTearDown(e.dispose);
      check(e.state).isA<EngineIdle>();
      e.setBackgroundClamp(true);
      check(e.effectiveSpeedMultiplier).equals(60.0);
    });

    test('clamp from Running: next phase uses clamped value', () {
      fakeAsync((async) {
        final e = _sim(200.0);
        addTearDown(e.dispose);
        e.start();
        async.flushMicrotasks();
        check(e.state).isA<EngineRunning>();
        e.setBackgroundClamp(true);
        check(e.effectiveSpeedMultiplier).equals(60.0);
      });
    });

    test('clamp from Paused', () {
      fakeAsync((async) {
        final e = _sim(200.0);
        addTearDown(e.dispose);
        e.start();
        async.flushMicrotasks();
        e.pause();
        check(e.state).isA<EnginePaused>();
        e.setBackgroundClamp(true);
        check(e.effectiveSpeedMultiplier).equals(60.0);
      });
    });

    test('clamp from Ended', () {
      final e = _sim(200.0);
      addTearDown(e.dispose);
      e.endSession(reason: EndReason.userQuit);
      check(e.state).isA<EngineEnded>();
      e.setBackgroundClamp(true);
      // Even ended sessions track the flag (no harm).
      check(e.backgroundClamp).isTrue();
      check(e.effectiveSpeedMultiplier).equals(60.0);
    });
  });

  // -------------------------------------------------------------------------
  // Clamp affects phase duration scheduling
  // -------------------------------------------------------------------------
  group('clamp affects phase duration scheduling', () {
    test('200× unclamped: 60s duration → 300ms', () {
      fakeAsync((async) {
        final e = _sim(200.0);
        addTearDown(e.dispose);
        // skip wait (60s→0.3s) then check duration.
        e.start();
        async.flushMicrotasks();
        // In wait phase at 200×: 60s/200 = 300ms.
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.wait);
        check(s.remaining.inMilliseconds).equals(300);
      });
    });

    test('200× clamped to 60×: 60s duration → 1000ms', () {
      fakeAsync((async) {
        final e = _sim(200.0);
        addTearDown(e.dispose);
        e.setBackgroundClamp(true); // effective = 60.
        e.start();
        async.flushMicrotasks();
        // In wait phase at 60×: 60s/60 = 1s.
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.wait);
        check(s.remaining.inSeconds).equals(1);
      });
    });

    test('toggle clamp mid-session: effectiveSpeedMultiplier reflects clamp', () {
      fakeAsync((async) {
        // Start at 200×; verify clamp changes effective mult at any
        // point. Already-scheduled timers are NOT rescheduled (spec).
        final e = _sim(200.0);
        addTearDown(e.dispose);
        e.start();
        async.flushMicrotasks();
        check(e.effectiveSpeedMultiplier).equals(200.0);
        e.setBackgroundClamp(true);
        check(e.effectiveSpeedMultiplier).equals(60.0);
        e.setBackgroundClamp(false);
        check(e.effectiveSpeedMultiplier).equals(200.0);
      });
    });
  });

  // -------------------------------------------------------------------------
  // Repeated setBackgroundClamp calls
  // -------------------------------------------------------------------------
  group('repeated setBackgroundClamp calls are safe', () {
    test('enable then enable again: still clamped', () {
      final e = _sim(100.0);
      addTearDown(e.dispose);
      e.setBackgroundClamp(true);
      e.setBackgroundClamp(true);
      check(e.backgroundClamp).isTrue();
      check(e.effectiveSpeedMultiplier).equals(60.0);
    });

    test('disable then disable again: still unclamped', () {
      final e = _sim(100.0);
      addTearDown(e.dispose);
      e.setBackgroundClamp(true);
      e.setBackgroundClamp(false);
      e.setBackgroundClamp(false);
      check(e.backgroundClamp).isFalse();
      check(e.effectiveSpeedMultiplier).equals(100.0);
    });
  });

  // -------------------------------------------------------------------------
  // Boundary multiplier values
  // -------------------------------------------------------------------------
  group('boundary multiplier values with clamp', () {
    for (final speed in [61.0, 100.0, 600.0, 1000.0]) {
      test('speed=$speed clamped → effective=60.0', () {
        final e = _sim(speed);
        addTearDown(e.dispose);
        e.setBackgroundClamp(true);
        check(e.effectiveSpeedMultiplier).equals(60.0);
        check(e.speedMultiplier).equals(speed);
      });
    }

    for (final speed in [1.0, 10.0, 30.0, 59.9]) {
      test('speed=$speed clamped → effective=speed (below cap)', () {
        final e = _sim(speed);
        addTearDown(e.dispose);
        e.setBackgroundClamp(true);
        check(e.effectiveSpeedMultiplier).equals(speed);
      });
    }
  });
}
