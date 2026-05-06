/// Strict integration tests for [TimerDisarmTrigger] and
/// [TriggerManager] timer behavior.
///
/// Covers:
/// - durationSeconds=1 fires after 1s
/// - durationSeconds=60 fires after 60s
/// - durationSeconds=0 fires immediately (Duration.zero timer)
/// - Multiple timer triggers independently
/// - Timer fires after dispose → no-op
/// - Timer cooldown with two identical timers
/// - onDisarmRequested callback path
/// - No onDisarmRequested → engine.disarm() called
/// - isStarted reflects timer presence
/// - start() idempotent
/// - durationSeconds verified via JSON round-trip
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/trigger_manager.dart';
import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/trigger.dart';
import 'package:guardianangela/services/fakes/fake_battery_monitor_service.dart';
import 'package:guardianangela/services/fakes/fake_geofence_service.dart';
import 'package:guardianangela/services/fakes/fake_hardware_button_service.dart';

import '../../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SessionMode _timerMode(
  int durationSeconds, {
  List<int> extraDurations = const [],
}) {
  final triggers = <TimerDisarmTrigger>[
    TimerDisarmTrigger(durationSeconds: durationSeconds),
    for (final d in extraDurations) TimerDisarmTrigger(durationSeconds: d),
  ];
  return SessionMode(
    id: 'mode-timer',
    name: 'Timer',
    checkInType: ChainStepType.holdButton,
    chainSteps: [holdStep()],
    distressTriggers: const [],
    disarmTriggers: triggers,
  );
}

TriggerManager _makeMgr(
  SessionEngine engine,
  SessionMode mode, {
  FakeHardwareButtonService? hw,
  FakeGeofenceService? gf,
  void Function()? onDisarmRequested,
  DateTime Function()? clock,
}) => TriggerManager(
  engine: engine,
  mode: mode,
  hardwareButtonService: hw ?? FakeHardwareButtonService(),
  geofenceService: gf ?? FakeGeofenceService(),
  onDisarmRequested: onDisarmRequested,
  clock: clock,
);

void main() {
  // -------------------------------------------------------------------------
  // Group 1: Basic timer fires
  // -------------------------------------------------------------------------
  group('TimerDisarmTrigger — fires after duration', () {
    test('durationSeconds=1 fires onDisarmRequested after exactly 1s', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        final mgr = _makeMgr(
          engine,
          _timerMode(1),
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        async.elapse(const Duration(milliseconds: 999));
        check(disarmCount).equals(0); // not yet

        async.elapse(const Duration(milliseconds: 2)); // 1001 ms total
        check(disarmCount).equals(1);

        mgr.dispose();
        engine.dispose();
      });
    });

    test('durationSeconds=60 fires after 60s', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        final mgr = _makeMgr(
          engine,
          _timerMode(60),
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 59));
        check(disarmCount).equals(0);

        async.elapse(const Duration(seconds: 2));
        check(disarmCount).equals(1);

        mgr.dispose();
        engine.dispose();
      });
    });

    test('durationSeconds=0 fires immediately (zero-duration timer)', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        final mgr = _makeMgr(
          engine,
          _timerMode(0),
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        // A zero-duration timer fires on the next event loop turn.
        async.elapse(Duration.zero);
        async.flushMicrotasks();

        check(disarmCount).equals(1);

        mgr.dispose();
        engine.dispose();
      });
    });

    test('durationSeconds=5 fires after 5s', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        final mgr = _makeMgr(
          engine,
          _timerMode(5),
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 4));
        check(disarmCount).equals(0);

        async.elapse(const Duration(seconds: 2));
        check(disarmCount).equals(1);

        mgr.dispose();
        engine.dispose();
      });
    });

    test('durationSeconds=3600 fires after 1 hour', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        final mgr = _makeMgr(
          engine,
          _timerMode(3600),
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        async.elapse(const Duration(minutes: 59));
        check(disarmCount).equals(0);

        async.elapse(const Duration(minutes: 2));
        check(disarmCount).equals(1);

        mgr.dispose();
        engine.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Group 2: No callback → engine.disarm()
  // -------------------------------------------------------------------------
  group('TimerDisarmTrigger — no callback → engine.disarm()', () {
    test('fires engine.disarm() when onDisarmRequested is null', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        final mgr = _makeMgr(engine, _timerMode(5));
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 6));

        check(engine.state).isA<EngineEnded>();
        // Spec engine_state.dart §EndReason.disarm — timer disarm is
        // a user-initiated disarm path (the user pre-configured the
        // timeout), so EndReason is `disarm`.
        check((engine.state as EngineEnded).reason).equals(EndReason.disarm);

        mgr.dispose();
        engine.dispose();
      });
    });

    test('engine.disarm() is idempotent on second timer fire', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        // Two timers at 5s and 10s; first disarms engine, second is no-op.
        final mgr = _makeMgr(engine, _timerMode(5, extraDurations: [10]));
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 6)); // first fires
        check(engine.state).isA<EngineEnded>();

        async.elapse(const Duration(seconds: 5)); // second fires; no-op
        // State should still be EngineEnded with original reason.
        check(engine.state).isA<EngineEnded>();
        // Spec engine_state.dart §EndReason.disarm — timer disarm is
        // a user-initiated disarm path (the user pre-configured the
        // timeout), so EndReason is `disarm`.
        check((engine.state as EngineEnded).reason).equals(EndReason.disarm);

        mgr.dispose();
        engine.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Group 3: Timer fires after dispose → no-op
  // -------------------------------------------------------------------------
  group('TimerDisarmTrigger — after dispose is no-op', () {
    test('dispose before timer fires → timer callback is cancelled', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        final mgr = _makeMgr(
          engine,
          _timerMode(10),
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        // Dispose at t=5s, before the t=10s timer.
        async.elapse(const Duration(seconds: 5));
        mgr.dispose();

        // Timer would have fired at t=10s.
        async.elapse(const Duration(seconds: 6));

        check(disarmCount).equals(0);
        check(engine.state).isA<EngineRunning>();

        engine.dispose();
      });
    });

    test('dispose at t=0 before any timer fires', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        final mgr = _makeMgr(
          engine,
          _timerMode(30),
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        mgr.dispose(); // immediate dispose
        async.elapse(const Duration(minutes: 2));

        check(disarmCount).equals(0);

        engine.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Group 4: Multiple timers fire independently
  // -------------------------------------------------------------------------
  group('TimerDisarmTrigger — multiple timers', () {
    test('two timers at different durations both fire (callback counted twice)',
        () {
      fakeAsync((async) {
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        var t = DateTime.utc(2026, 4, 1, 12, 0, 0, 0);
        // Advance clock between fires so both pass cooldown.
        final mgr = TriggerManager(
          engine: engine,
          mode: _timerMode(5, extraDurations: [10]),
          hardwareButtonService: FakeHardwareButtonService(),
          geofenceService: FakeGeofenceService(),
          onDisarmRequested: () {
            disarmCount++;
            t = t.add(const Duration(seconds: 5));
          },
          clock: () => t,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 6)); // first timer fires
        async.flushMicrotasks();
        check(disarmCount).equals(1);

        async.elapse(const Duration(seconds: 5)); // second timer fires
        async.flushMicrotasks();
        check(disarmCount).equals(2);

        mgr.dispose();
        engine.dispose();
      });
    });

    test('two identical timers at same time → cooldown drops second', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        final frozenClock = DateTime.utc(2026, 4, 1, 12);
        final mgr = _makeMgr(
          engine,
          _timerMode(5, extraDurations: [5]), // two timers at t=5s
          onDisarmRequested: () => disarmCount++,
          clock: () => frozenClock,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 6));

        check(disarmCount).equals(1); // second suppressed by cooldown

        mgr.dispose();
        engine.dispose();
      });
    });

    test('three timers at 2s, 5s, 10s with advancing clock all fire', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        var t = DateTime.utc(2026, 4, 1, 12, 0, 0, 0);
        final mgr = TriggerManager(
          engine: engine,
          mode: _timerMode(2, extraDurations: [5, 10]),
          hardwareButtonService: FakeHardwareButtonService(),
          geofenceService: FakeGeofenceService(),
          onDisarmRequested: () {
            disarmCount++;
            // Advance 5s on each fire to clear cooldown for next timer.
            t = t.add(const Duration(seconds: 5));
          },
          clock: () => t,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 3)); // 2s timer fires
        async.flushMicrotasks();
        check(disarmCount).equals(1);

        async.elapse(const Duration(seconds: 3)); // 5s timer fires
        async.flushMicrotasks();
        check(disarmCount).equals(2);

        async.elapse(const Duration(seconds: 5)); // 10s timer fires
        async.flushMicrotasks();
        check(disarmCount).equals(3);

        mgr.dispose();
        engine.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Group 5: isStarted reflects timer presence
  // -------------------------------------------------------------------------
  group('TimerDisarmTrigger — isStarted', () {
    test('isStarted is true when mode has a timer trigger', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        final mgr = _makeMgr(engine, _timerMode(30));
        mgr.start();
        async.flushMicrotasks();

        check(mgr.isStarted).isTrue();

        mgr.dispose();
        engine.dispose();
      });
    });

    test('isStarted is false after dispose when only timer was active', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        final mgr = _makeMgr(engine, _timerMode(30));
        mgr.start();
        async.flushMicrotasks();
        mgr.dispose();

        check(mgr.isStarted).isFalse();

        engine.dispose();
      });
    });

    test('start() twice is idempotent — only one timer set created', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        final mgr = _makeMgr(
          engine,
          _timerMode(5),
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        mgr.start(); // second call is no-op
        engine.start();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 6));

        check(disarmCount).equals(1); // not 2 (idempotent start)

        mgr.dispose();
        engine.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Group 6: Cooldown between timer fires
  // -------------------------------------------------------------------------
  group('TimerDisarmTrigger — cooldown', () {
    test('timer cooldown is 500ms as per TriggerManager.cooldown constant', () {
      check(TriggerManager.cooldown).equals(const Duration(milliseconds: 500));
    });

    test('timer cooldown is separate from arrival cooldown state', () {
      // Verify that timer cooldown state (_lastTimerFiredAt) is not shared
      // with arrival state (_lastArrivalFiredAt).
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        final frozenClock = DateTime.utc(2026, 4, 1, 12);
        final mode = SessionMode(
          id: 'mode-timer-gps',
          name: 'TimerAndGPS',
          checkInType: ChainStepType.holdButton,
          chainSteps: [holdStep()],
          distressTriggers: const [],
          disarmTriggers: const [
            TimerDisarmTrigger(durationSeconds: 5),
            GpsArrivalDisarmTrigger(
              latitude: 51.5074,
              longitude: -0.1278,
              radiusMeters: 100,
            ),
          ],
        );
        final mgr = TriggerManager(
          engine: engine,
          mode: mode,
          hardwareButtonService: hw,
          geofenceService: gf,
          onDisarmRequested: () => disarmCount++,
          clock: () => frozenClock,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        // GPS arrival fires first.
        gf.injectArrival(
          LocationPoint(
            latitude: 51.5074,
            longitude: -0.1278,
            timestamp: DateTime.utc(2026, 4, 1),
          ),
        );
        async.flushMicrotasks();
        check(disarmCount).equals(1); // arrival fired

        // Timer fires at t=5s; clock is frozen so cooldown check uses same
        // time. Timer has its own bucket (_lastTimerFiredAt is null), so it
        // fires independently.
        async.elapse(const Duration(seconds: 6));
        check(disarmCount).equals(2); // timer fired (own cooldown state)

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Group 7: TimerDisarmTrigger JSON round-trip
  // -------------------------------------------------------------------------
  group('TimerDisarmTrigger — model', () {
    test('JSON round-trip preserves durationSeconds=1', () {
      const t = TimerDisarmTrigger(durationSeconds: 1);
      final j = t.toJson();
      final t2 = TimerDisarmTrigger.fromJson(j);
      check(t2.durationSeconds).equals(1);
    });

    test('JSON round-trip preserves durationSeconds=3600', () {
      const t = TimerDisarmTrigger(durationSeconds: 3600);
      final j = t.toJson();
      final t2 = TimerDisarmTrigger.fromJson(j);
      check(t2.durationSeconds).equals(3600);
    });

    test('JSON includes kind=disarm and type=timer', () {
      const t = TimerDisarmTrigger(durationSeconds: 60);
      final j = t.toJson();
      check(j['kind']).equals('disarm');
      check(j['type']).equals('timer');
      check(j['durationSeconds']).equals(60);
    });

    test('Trigger.fromJson dispatches to TimerDisarmTrigger', () {
      const t = TimerDisarmTrigger(durationSeconds: 30);
      final j = t.toJson();
      final t2 = Trigger.fromJson(j);
      check(t2).isA<TimerDisarmTrigger>();
      check((t2 as TimerDisarmTrigger).durationSeconds).equals(30);
    });

    test('equality and hashCode are value-based', () {
      const a = TimerDisarmTrigger(durationSeconds: 60);
      const b = TimerDisarmTrigger(durationSeconds: 60);
      const c = TimerDisarmTrigger(durationSeconds: 61);
      check(a == b).isTrue();
      check(a == c).isFalse();
      check(a.hashCode).equals(b.hashCode);
    });

    test('copyWith replaces durationSeconds', () {
      const t = TimerDisarmTrigger(durationSeconds: 60);
      final t2 = t.copyWith(durationSeconds: 120);
      check(t2.durationSeconds).equals(120);
      check(t.durationSeconds).equals(60); // original unchanged
    });

    test('toString includes durationSeconds', () {
      const t = TimerDisarmTrigger(durationSeconds: 42);
      check(t.toString()).contains('42');
    });
  });

  // -------------------------------------------------------------------------
  // Group 8: Mixed trigger mode (GPS + Timer)
  // -------------------------------------------------------------------------
  group('TimerDisarmTrigger — with GPS trigger on same mode', () {
    test('GPS arrival fires before timer, timer still fires after', () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        var t = DateTime.utc(2026, 4, 1, 12, 0, 0, 0);
        final mode = SessionMode(
          id: 'mode-mixed',
          name: 'Mixed',
          checkInType: ChainStepType.holdButton,
          chainSteps: [holdStep()],
          distressTriggers: const [],
          disarmTriggers: const [
            TimerDisarmTrigger(durationSeconds: 10),
            GpsArrivalDisarmTrigger(
              latitude: 51.5074,
              longitude: -0.1278,
              radiusMeters: 100,
            ),
          ],
        );
        final mgr = TriggerManager(
          engine: engine,
          mode: mode,
          hardwareButtonService: hw,
          geofenceService: gf,
          onDisarmRequested: () {
            disarmCount++;
            t = t.add(const Duration(seconds: 5));
          },
          clock: () => t,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        // GPS arrival fires at t=3s (before timer).
        async.elapse(const Duration(seconds: 3));
        gf.injectArrival(
          LocationPoint(
            latitude: 51.5074,
            longitude: -0.1278,
            timestamp: DateTime.utc(2026, 4, 1),
          ),
        );
        async.flushMicrotasks();
        check(disarmCount).equals(1);

        // Timer fires at t=10s (7 more seconds; clock already advanced 5s).
        async.elapse(const Duration(seconds: 8));
        async.flushMicrotasks();
        check(disarmCount).equals(2);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });
  });
}
