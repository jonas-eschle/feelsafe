/// Tests for [SessionEngine.setBackgroundClamp] and
/// [SessionEngine.effectiveSpeedMultiplier].
///
/// Spec 01 §Speed Multiplier (D-UX-2026-04-23 #4): background clamp
/// caps the effective multiplier at 60× without mutating the stored
/// [speedMultiplier]. Real sessions are always 1× so the no-op path
/// is also verified here.
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

SessionEngine _simEngine(double speed) => SessionEngine(
  chainSteps: [smsStep(durationSeconds: 10)],
  isSimulation: true,
  speedMultiplier: speed,
  random: FixedRandom(),
);

SessionEngine _realEngine() => SessionEngine(
  chainSteps: [smsStep(durationSeconds: 10)],
  random: FixedRandom(),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('backgroundClamp default', () {
    test('default backgroundClamp is false', () {
      // Arrange
      final e = _simEngine(500.0);
      addTearDown(e.dispose);
      // Assert
      check(e.backgroundClamp).isFalse();
    });

    test('effectiveSpeedMultiplier equals speedMultiplier when clamp is off',
        () {
      // Arrange
      final e = _simEngine(500.0);
      addTearDown(e.dispose);
      // Assert — stored and effective are identical without clamp.
      check(e.speedMultiplier).equals(500.0);
      check(e.effectiveSpeedMultiplier).equals(500.0);
    });
  });

  group('setBackgroundClamp(true) caps at 60×', () {
    test('speed 500 → effectiveSpeedMultiplier becomes 60.0 when clamped', () {
      // Arrange
      final e = _simEngine(500.0);
      addTearDown(e.dispose);
      // Act
      e.setBackgroundClamp(true);
      // Assert
      check(e.backgroundClamp).isTrue();
      check(e.speedMultiplier).equals(500.0); // stored value unchanged
      check(e.effectiveSpeedMultiplier).equals(60.0);
    });

    test('speed 30 → effectiveSpeedMultiplier stays 30 (below cap)', () {
      // Arrange
      final e = _simEngine(30.0);
      addTearDown(e.dispose);
      // Act
      e.setBackgroundClamp(true);
      // Assert — 30 ≤ 60 so no clamp applied.
      check(e.effectiveSpeedMultiplier).equals(30.0);
    });

    test('speed exactly 60 → no clamp (boundary)', () {
      // Arrange
      final e = _simEngine(60.0);
      addTearDown(e.dispose);
      // Act
      e.setBackgroundClamp(true);
      // Assert — exactly at the boundary, not above it.
      check(e.effectiveSpeedMultiplier).equals(60.0);
    });
  });

  group('setBackgroundClamp(false) restores pre-clamp value', () {
    test('toggle off restores stored speedMultiplier', () {
      // Arrange
      final e = _simEngine(200.0);
      addTearDown(e.dispose);
      e.setBackgroundClamp(true);
      check(e.effectiveSpeedMultiplier).equals(60.0); // sanity check
      // Act
      e.setBackgroundClamp(false);
      // Assert
      check(e.backgroundClamp).isFalse();
      check(e.effectiveSpeedMultiplier).equals(200.0);
    });
  });

  group('real session: setBackgroundClamp is a no-op', () {
    test('real engine ignores setBackgroundClamp(true)', () {
      // Arrange
      final e = _realEngine();
      addTearDown(e.dispose);
      // Act
      e.setBackgroundClamp(true);
      // Assert — real sessions are never simulation, clamp stays false.
      check(e.backgroundClamp).isFalse();
      check(e.effectiveSpeedMultiplier).equals(1.0);
    });
  });

  group('timer fires faster when clamp is engaged', () {
    // A 10-second duration step at 600× without clamp → timer in
    // ~16.666ms (10 000 ms / 600). With clamp engaged (effective=60)
    // the same step fires in ~166.666ms (10 000 ms / 60).
    // We verify the ordering by checking which duration is still pending
    // after a partial elapse.

    test('600× unclamped: duration phase scheduled at ~16.7ms', () {
      fakeAsync((async) {
        // Arrange
        final e = SessionEngine(
          chainSteps: [smsStep(durationSeconds: 10)],
          isSimulation: true,
          speedMultiplier: 600.0,
          random: FixedRandom(),
        );
        addTearDown(e.dispose);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        // At 600×, 10 s = 10 000 000 µs / 600 ≈ 16 666 µs ≈ 16ms.
        check(s.phase).equals(TimerPhase.duration);
        // Duration should be close to 16 666 µs.
        final micros = s.remaining.inMicroseconds;
        check(micros).isGreaterOrEqual(15000);
        check(micros).isLessOrEqual(18000);
      });
    });

    test('600× clamped to 60×: duration phase scheduled at ~167ms', () {
      fakeAsync((async) {
        // Arrange
        final e = SessionEngine(
          chainSteps: [smsStep(durationSeconds: 10)],
          isSimulation: true,
          speedMultiplier: 600.0,
          random: FixedRandom(),
        );
        addTearDown(e.dispose);
        e.setBackgroundClamp(true); // effective = 60
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        // At 60×, 10 s = 10 000 000 µs / 60 ≈ 166 666 µs ≈ 167ms.
        check(s.phase).equals(TimerPhase.duration);
        final micros = s.remaining.inMicroseconds;
        check(micros).isGreaterOrEqual(160000);
        check(micros).isLessOrEqual(175000);
      });
    });

    test('clamped effective multiplier scales phase durations', () {
      // Build two simulation engines with identical high speed (600×);
      // one clamped, one not. The clamped engine's
      // effectiveSpeedMultiplier must equal 60.0 (the ceiling) while
      // the unclamped engine's matches the stored value.
      final unclamped = SessionEngine(
        chainSteps: [smsStep(durationSeconds: 10, gracePeriodSeconds: 60)],
        isSimulation: true,
        speedMultiplier: 600.0,
        random: FixedRandom(),
      );
      final clamped = SessionEngine(
        chainSteps: [smsStep(durationSeconds: 10, gracePeriodSeconds: 60)],
        isSimulation: true,
        speedMultiplier: 600.0,
        random: FixedRandom(),
      );
      addTearDown(unclamped.dispose);
      addTearDown(clamped.dispose);

      clamped.setBackgroundClamp(true);

      check(unclamped.effectiveSpeedMultiplier).equals(600.0);
      check(clamped.effectiveSpeedMultiplier).equals(60.0);
      // Stored multiplier is NOT mutated — only the effective value
      // reflects the clamp.
      check(clamped.speedMultiplier).equals(600.0);
    });
  });
}
