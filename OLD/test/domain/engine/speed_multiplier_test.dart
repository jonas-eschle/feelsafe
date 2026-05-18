/// Tests for [SessionEngine] speed-multiplier validation and jitter
/// behaviour.
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/timer_phase.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('speedMultiplier validation', () {
    test('real session accepts 1.0', () {
      final e = SessionEngine(chainSteps: [holdStep()], random: FixedRandom());
      check(e.speedMultiplier).equals(1.0);
      e.dispose();
    });

    test('real session rejects 2.0', () {
      check(
        () => SessionEngine(
          chainSteps: [holdStep()],
          speedMultiplier: 2.0,
          random: FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });

    test('real session rejects 0.5', () {
      check(
        () => SessionEngine(
          chainSteps: [holdStep()],
          speedMultiplier: 0.5,
          random: FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });

    test('rejects NaN', () {
      check(
        () => SessionEngine(
          chainSteps: [holdStep()],
          speedMultiplier: double.nan,
          random: FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });

    test('rejects positive infinity', () {
      check(
        () => SessionEngine(
          chainSteps: [holdStep()],
          speedMultiplier: double.infinity,
          random: FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });

    test('rejects negative infinity', () {
      check(
        () => SessionEngine(
          chainSteps: [holdStep()],
          speedMultiplier: double.negativeInfinity,
          random: FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });

    test('rejects zero', () {
      check(
        () => SessionEngine(
          chainSteps: [holdStep()],
          speedMultiplier: 0.0,
          random: FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });

    test('rejects negative value', () {
      check(
        () => SessionEngine(
          chainSteps: [holdStep()],
          speedMultiplier: -1.5,
          random: FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });

    test('simulation allows 1.0', () {
      final e = SessionEngine(
        chainSteps: [holdStep()],
        isSimulation: true,
        random: FixedRandom(),
      );
      check(e.speedMultiplier).equals(1.0);
      e.dispose();
    });

    test('simulation allows 5.0', () {
      final e = SessionEngine(
        chainSteps: [holdStep()],
        isSimulation: true,
        speedMultiplier: 5.0,
        random: FixedRandom(),
      );
      check(e.speedMultiplier).equals(5.0);
      e.dispose();
    });

    test('simulation allows 0.5', () {
      final e = SessionEngine(
        chainSteps: [holdStep()],
        isSimulation: true,
        speedMultiplier: 0.5,
        random: FixedRandom(),
      );
      check(e.speedMultiplier).equals(0.5);
      e.dispose();
    });

    test('simulation allows 1000.0', () {
      final e = SessionEngine(
        chainSteps: [holdStep()],
        isSimulation: true,
        speedMultiplier: 1000.0,
        random: FixedRandom(),
      );
      check(e.speedMultiplier).equals(1000.0);
      e.dispose();
    });

    test('simulation rejects NaN', () {
      check(
        () => SessionEngine(
          chainSteps: [holdStep()],
          isSimulation: true,
          speedMultiplier: double.nan,
          random: FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });

    test('simulation rejects zero', () {
      check(
        () => SessionEngine(
          chainSteps: [holdStep()],
          isSimulation: true,
          speedMultiplier: 0.0,
          random: FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });

    test('simulation rejects negative', () {
      check(
        () => SessionEngine(
          chainSteps: [holdStep()],
          isSimulation: true,
          speedMultiplier: -1.0,
          random: FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });

    test('simulation rejects infinity', () {
      check(
        () => SessionEngine(
          chainSteps: [holdStep()],
          isSimulation: true,
          speedMultiplier: double.infinity,
          random: FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });
  });

  group('speed multiplier effect on timing', () {
    test('simulation 10x cuts wait duration by 10', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [smsStep(durationSeconds: 10).copyWith(waitSeconds: 10)],
          isSimulation: true,
          speedMultiplier: 10.0,
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.wait);
        check(s.remaining).equals(const Duration(seconds: 1));
        e.dispose();
      });
    });

    test('simulation 0.5x doubles wait duration', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [smsStep(durationSeconds: 10).copyWith(waitSeconds: 10)],
          isSimulation: true,
          speedMultiplier: 0.5,
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.remaining).equals(const Duration(seconds: 20));
        e.dispose();
      });
    });

    test('real session timing matches nominal values', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [smsStep(durationSeconds: 3)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.remaining).equals(const Duration(seconds: 3));
        e.dispose();
      });
    });
  });

  group('jitter with FixedRandom(0.5)', () {
    test('jitter factor is exactly 1.0 when randomize=1.0', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(
              durationSeconds: 10,
            ).copyWith(waitSeconds: 20, randomize: 1.0),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        // (1 + 0.2 * 1.0 * 0) = 1.0
        check(s.remaining).equals(const Duration(seconds: 20));
        e.dispose();
      });
    });

    test('jitter factor is 1.0 when randomize=0.0', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(
              durationSeconds: 10,
            ).copyWith(waitSeconds: 20, randomize: 0.0),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.remaining).equals(const Duration(seconds: 20));
        e.dispose();
      });
    });

    test('jitter with random=0.0 → factor 0.8 when randomize=1.0', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(
              durationSeconds: 10,
            ).copyWith(waitSeconds: 100, randomize: 1.0),
          ],
          random: FixedRandom(0.0),
        );
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        // factor = 1 + 0.2 * 1 * (0 * 2 - 1) = 0.8 → 80s.
        check(s.remaining).equals(const Duration(seconds: 80));
        e.dispose();
      });
    });

    test('jitter with random=1.0 → factor 1.2 when randomize=1.0', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(
              durationSeconds: 10,
            ).copyWith(waitSeconds: 100, randomize: 1.0),
          ],
          random: FixedRandom(1.0),
        );
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        // factor = 1 + 0.2 * 1 * (1 * 2 - 1) = 1.2 → 120s.
        check(s.remaining).equals(const Duration(seconds: 120));
        e.dispose();
      });
    });

    test('fractional randomize scales jitter amplitude', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(
              durationSeconds: 10,
            ).copyWith(waitSeconds: 100, randomize: 0.5),
          ],
          random: FixedRandom(0.0),
        );
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        // factor = 1 + 0.2 * 0.5 * (-1) = 0.9 → 90s.
        check(s.remaining).equals(const Duration(seconds: 90));
        e.dispose();
      });
    });

    test('randomize clamps above 1.0', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(
              durationSeconds: 10,
            ).copyWith(waitSeconds: 100, randomize: 5.0),
          ],
          random: FixedRandom(1.0),
        );
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        // randomize clamped to 1.0 → factor 1.2 → 120s.
        check(s.remaining).equals(const Duration(seconds: 120));
        e.dispose();
      });
    });
  });

  group('stream sync: events ordered', () {
    test('events emit synchronously (no microtask deferral)', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [smsStep(durationSeconds: 1)],
          random: FixedRandom(),
        );
        final names = <ChainEvent>[];
        e.events.listen((ev) => names.add(ev.event));
        e.start();
        // Even before flushMicrotasks, with sync:true, events have
        // already been delivered synchronously to listeners.
        check(names).isNotEmpty();
        e.dispose();
      });
    });
  });
}
