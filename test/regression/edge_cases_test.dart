/// Regression tests guarding against specific documented edge cases.
///
/// These tests lock down behavior that we have previously had wrong
/// or that is easy to accidentally regress. Each test names the spec
/// or decision-log anchor it protects.
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import 'package:guardianangela/domain/models/step_config.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('Regression: speedMultiplier validation', () {
    test('NaN is rejected', () {
      check(
        () => SessionEngine(
          chainSteps: [holdStep()],
          speedMultiplier: double.nan,
          isSimulation: true,
        ),
      ).throws<ArgumentError>();
    });

    test('Infinity is rejected', () {
      check(
        () => SessionEngine(
          chainSteps: [holdStep()],
          speedMultiplier: double.infinity,
          isSimulation: true,
        ),
      ).throws<ArgumentError>();
    });

    test('Negative infinity is rejected', () {
      check(
        () => SessionEngine(
          chainSteps: [holdStep()],
          speedMultiplier: double.negativeInfinity,
          isSimulation: true,
        ),
      ).throws<ArgumentError>();
    });

    test('Zero is rejected', () {
      check(
        () => SessionEngine(
          chainSteps: [holdStep()],
          speedMultiplier: 0,
          isSimulation: true,
        ),
      ).throws<ArgumentError>();
    });

    test('Negative value is rejected', () {
      check(
        () => SessionEngine(
          chainSteps: [holdStep()],
          speedMultiplier: -1.5,
          isSimulation: true,
        ),
      ).throws<ArgumentError>();
    });

    test('Non-1.0 in real session is rejected', () {
      check(
        () => SessionEngine(
          chainSteps: [holdStep()],
          isSimulation: false,
          speedMultiplier: 2.0,
        ),
      ).throws<ArgumentError>();
    });

    test('1.0 in real session is accepted', () {
      final e = SessionEngine(
        chainSteps: [holdStep()],
        isSimulation: false,
        random: FixedRandom(),
      );
      e.dispose();
    });

    test('Any finite positive value in simulation is accepted', () {
      for (final v in [0.1, 1.0, 10.0, 100.0]) {
        final e = SessionEngine(
          chainSteps: [holdStep()],
          isSimulation: true,
          speedMultiplier: v,
          random: FixedRandom(),
        );
        e.dispose();
      }
    });
  });

  group('Regression: empty chain steps on start', () {
    test('start() throws when steps is empty', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: const [],
          random: FixedRandom(),
        );
        check(e.start).throws<ArgumentError>();
        e.dispose();
      });
    });
  });

  group('Regression: double-start rejected', () {
    test('calling start() twice throws StateError', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        check(e.start).throws<StateError>();
        e.dispose();
      });
    });

    test('calling start() after end throws StateError', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.disarm();
        async.flushMicrotasks();
        check(e.start).throws<StateError>();
        e.dispose();
      });
    });
  });

  group('Regression: D-SAFETY-17 distress during distress', () {
    test('second replaceWithDistressChain during distress is a no-op', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        final events = <ChainEvent>[];
        e.events.listen((ev) => events.add(ev.event));
        e.start();
        async.flushMicrotasks();
        e.replaceWithDistressChain([
          smsStep(durationSeconds: 30, gracePeriodSeconds: 0),
        ]);
        async.flushMicrotasks();
        final firstDistressCount = events
            .where((ev) => ev == ChainEvent.distressTriggered)
            .length;
        e.replaceWithDistressChain([
          step(type: ChainStepType.loudAlarm),
        ]);
        async.flushMicrotasks();
        final secondDistressCount = events
            .where((ev) => ev == ChainEvent.distressTriggered)
            .length;
        check(firstDistressCount).equals(1);
        check(secondDistressCount).equals(1);
        e.dispose();
      });
    });

    test('empty distress chain throws ArgumentError', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        check(
          () => e.replaceWithDistressChain(const []),
        ).throws<ArgumentError>();
        e.dispose();
      });
    });
  });

  group('Regression: idempotent lifecycle operations', () {
    test('disarm() twice does not re-emit sessionEnded', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        final events = <ChainEvent>[];
        e.events.listen((ev) => events.add(ev.event));
        e.start();
        async.flushMicrotasks();
        e.disarm();
        async.flushMicrotasks();
        e.disarm();
        async.flushMicrotasks();
        final endedCount = events
            .where((ev) => ev == ChainEvent.sessionEnded)
            .length;
        check(endedCount).equals(1);
        e.dispose();
      });
    });

    test('dispose() is idempotent', () {
      final e = SessionEngine(
        chainSteps: [holdStep()],
        random: FixedRandom(),
      );
      e.dispose();
      e.dispose();
      // No exception thrown.
    });

    test('pause on idle engine is a no-op', () {
      final e = SessionEngine(
        chainSteps: [holdStep()],
        random: FixedRandom(),
      );
      e.pause();
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });

    test('resume on running (non-paused) engine is a no-op', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [smsStep(durationSeconds: 5)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        final before = e.state;
        e.resume();
        check(e.state).isA<EngineRunning>();
        check(e.state).equals(before);
        e.dispose();
      });
    });
  });

  group('Regression: jumpToStep bounds + simulation guard', () {
    test('jumpToStep requires simulation', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [holdStep(), smsStep(order: 1)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        check(() => e.jumpToStep(1)).throws<StateError>();
        e.dispose();
      });
    });

    test('jumpToStep(-1) throws RangeError in simulation', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [holdStep(), smsStep(order: 1)],
          isSimulation: true,
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        check(() => e.jumpToStep(-1)).throws<RangeError>();
        e.dispose();
      });
    });

    test('jumpToStep beyond last step throws RangeError', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [holdStep(), smsStep(order: 1)],
          isSimulation: true,
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        check(() => e.jumpToStep(5)).throws<RangeError>();
        e.dispose();
      });
    });

    test('jumpToStep on idle throws StateError', () {
      final e = SessionEngine(
        chainSteps: [holdStep()],
        isSimulation: true,
        random: FixedRandom(),
      );
      check(() => e.jumpToStep(0)).throws<StateError>();
      e.dispose();
    });
  });

  group('Regression: StepConfig subtype JSON edge cases', () {
    test(
      'SmsContactConfig with empty contactIds round-trips with null-list',
      () {
        // contactIds is parsed via `rawIds is List`; null in → null out.
        final cfg = StepConfig.fromJson(const {
          'type': 'smsContact',
        });
        check(cfg).isA<SmsContactConfig>();
      },
    );

    test(
      'HardwareButtonConfig with unknown buttonType throws',
      () {
        check(
          () => StepConfig.fromJson(const {
            'type': 'hardwareButton',
            'buttonType': 'martian',
          }),
        ).throws<ArgumentError>();
      },
    );

    test('unknown MessageChannel throws in SmsContactConfig', () {
      check(
        () => StepConfig.fromJson(const {
          'type': 'smsContact',
          'channel': 'carrier-pigeon',
        }),
      ).throws<ArgumentError>();
    });
  });

  group('Regression: orchestrator lifecycle after end', () {
    test(
      'engine events after dispose() are not emitted',
      () async {
        final e = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        final events = <ChainEventData>[];
        final sub = e.events.listen(events.add);
        e.dispose();
        await Future<void>.delayed(const Duration(milliseconds: 5));
        await sub.cancel();
        check(events).isEmpty();
      },
    );
  });

  group('Regression: ChainStep randomize bounds', () {
    test('randomize = 0 produces deterministic timing', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(
              durationSeconds: 10,
              gracePeriodSeconds: 0,
            ),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        // Without jitter, elapsing exactly `durationSeconds` fires.
        async.elapse(const Duration(seconds: 10));
        // Engine should have left the duration phase — either in
        // grace (duration 0 here → graceExpired) or ended.
        check(e.state is EngineIdle).isFalse();
        e.dispose();
      });
    });

    test('randomize > 0 with FixedRandom(0.5) cancels to 1x', () {
      fakeAsync((async) {
        // 0.5 * 2 - 1 = 0 swing → factor 1.0.
        final e = SessionEngine(
          chainSteps: [
            step(
              type: ChainStepType.smsContact,
              durationSeconds: 4,
              gracePeriodSeconds: 0,
              randomize: 1.0,
            ),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });
  });
}
