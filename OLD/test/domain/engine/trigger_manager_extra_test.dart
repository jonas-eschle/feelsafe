/// Additional tests for [TriggerManager] covering branches not
/// exercised by the existing `trigger_manager_test.dart`:
///
/// * `TimerDisarmTrigger` fires after the configured duration.
/// * `TimerDisarmTrigger` calls `engine.disarm()` when
///   `onDisarmRequested` is null.
/// * Timer-fired disarm respects the cooldown.
/// * Panic with an empty `engine.steps` fallback is a no-op.
library;

import 'dart:async';

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/trigger_manager.dart';
import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/models/trigger.dart';
import 'package:guardianangela/services/protocols/battery_monitor_service_protocol.dart';
import 'package:guardianangela/services/protocols/geofence_service_protocol.dart';
import 'package:guardianangela/services/protocols/hardware_button_service_protocol.dart';

import '../../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Fakes (mirrors from trigger_manager_test.dart — needed in a separate file)
// ---------------------------------------------------------------------------

class _FakeHardwareButton implements HardwareButtonServiceProtocol {
  final StreamController<HardwarePanicEvent> _ctrl =
      StreamController<HardwarePanicEvent>.broadcast(sync: true);
  bool _listening = false;

  @override
  Stream<HardwarePanicEvent> get panicEvents => _ctrl.stream;

  @override
  bool get isListening => _listening;

  @override
  Future<void> start({
    required String buttonType,
    required String pattern,
    int pressCount = 5,
    int pressWindowMs = 1500,
    double longPressDurationSeconds = 2.0,
    bool softMode = false,
  }) async {
    _listening = true;
  }

  @override
  Future<void> stop() async {
    _listening = false;
  }

  void emit(HardwarePanicEvent ev) => _ctrl.add(ev);

  void close() => _ctrl.close();
}

class _FakeGeofence implements GeofenceServiceProtocol {
  final StreamController<LocationPoint> _ctrl =
      StreamController<LocationPoint>.broadcast(sync: true);

  @override
  Stream<LocationPoint> get arrivals => _ctrl.stream;

  @override
  Future<void> registerGeofence({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {}

  @override
  Future<void> removeGeofence() async {}

  void emit(LocationPoint p) => _ctrl.add(p);

  void close() => _ctrl.close();
}

class _FakeBatteryMonitor implements BatteryMonitorServiceProtocol {
  final StreamController<int> _ctrl =
      StreamController<int>.broadcast(sync: true);
  bool _active = false;

  @override
  Stream<int> get onLowBattery => _ctrl.stream;

  @override
  bool get isActive => _active;

  @override
  Future<void> startMonitoring({required int thresholdPercent}) async {
    _active = true;
  }

  @override
  Future<void> stopMonitoring() async {
    _active = false;
  }

  void close() => _ctrl.close();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

HardwarePanicEvent _panic() => HardwarePanicEvent(
  buttonType: 'volume',
  pattern: '5x_press',
  timestamp: DateTime.utc(2026, 4, 1),
);

/// Mode with no distress triggers and one [TimerDisarmTrigger].
SessionMode _timerMode(int durationSeconds) => SessionMode(
  id: 'mode-timer',
  name: 'Timer',
  chainSteps: [holdStep()],
  distressTriggers: const [],
  disarmTriggers: [TimerDisarmTrigger(durationSeconds: durationSeconds)],
);

/// Mode with distress triggers and no disarm triggers.
SessionMode _distressMode() => SessionMode(
  id: 'mode-distress',
  name: 'Distress',
  chainSteps: [holdStep(), smsStep(order: 1)],
  distressTriggers: const [
    HardwareButtonDistressTrigger(
      buttonType: ButtonType.volumeUp,
      trigger: RepeatPressTrigger(),
    ),
  ],
  disarmTriggers: const [],
);

void main() {
  group('TriggerManager — TimerDisarmTrigger', () {
    test('timer fires onDisarmRequested after the configured duration', () {
      fakeAsync((async) {
        final hw = _FakeHardwareButton();
        final gf = _FakeGeofence();
        final bm = _FakeBatteryMonitor();
        final e = SessionEngine(chainSteps: [holdStep()], random: FixedRandom());
        var disarmCount = 0;
        final mgr = TriggerManager(
          engine: e,
          mode: _timerMode(10),
          hardwareButtonService: hw,
          geofenceService: gf,
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        e.start();
        async.flushMicrotasks();

        // Not yet.
        async.elapse(const Duration(seconds: 9));
        check(disarmCount).equals(0);

        // Now.
        async.elapse(const Duration(seconds: 2));
        check(disarmCount).equals(1);

        mgr.dispose();
        hw.close();
        gf.close();
        bm.close();
        e.dispose();
      });
    });

    test('timer without onDisarmRequested calls engine.disarm()', () {
      fakeAsync((async) {
        final hw = _FakeHardwareButton();
        final gf = _FakeGeofence();
        final bm = _FakeBatteryMonitor();
        final e = SessionEngine(chainSteps: [holdStep()], random: FixedRandom());
        final mgr = TriggerManager(
          engine: e,
          mode: _timerMode(5),
          hardwareButtonService: hw,
          geofenceService: gf,
        );
        mgr.start();
        e.start();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 6));

        check(e.state).isA<EngineEnded>();
        // Spec engine_state.dart §EndReason.disarm: timer disarm is a
        // user-initiated disarm path → EndReason.disarm.
        check((e.state as EngineEnded).reason).equals(EndReason.disarm);

        mgr.dispose();
        hw.close();
        gf.close();
        bm.close();
        e.dispose();
      });
    });

    test('timer does not fire after dispose', () {
      fakeAsync((async) {
        final hw = _FakeHardwareButton();
        final gf = _FakeGeofence();
        final bm = _FakeBatteryMonitor();
        final e = SessionEngine(chainSteps: [holdStep()], random: FixedRandom());
        var disarmCount = 0;
        final mgr = TriggerManager(
          engine: e,
          mode: _timerMode(10),
          hardwareButtonService: hw,
          geofenceService: gf,
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        e.start();
        async.flushMicrotasks();

        // Dispose before the timer fires.
        mgr.dispose();
        async.elapse(const Duration(seconds: 20));

        check(disarmCount).equals(0);

        hw.close();
        gf.close();
        bm.close();
        e.dispose();
      });
    });

    test('timer cooldown suppresses a double-fire from duplicate triggers',
        () {
      fakeAsync((async) {
        final hw = _FakeHardwareButton();
        final gf = _FakeGeofence();
        final bm = _FakeBatteryMonitor();
        final e = SessionEngine(chainSteps: [holdStep()], random: FixedRandom());
        var disarmCount = 0;
        // Two identical timer triggers — both fire at t=5 s.
        final mode = SessionMode(
          id: 'mode-two-timers',
          name: 'TwoTimers',
          chainSteps: [holdStep()],
          distressTriggers: const [],
          disarmTriggers: const [
            TimerDisarmTrigger(durationSeconds: 5),
            TimerDisarmTrigger(durationSeconds: 5),
          ],
        );
        final mgr = TriggerManager(
          engine: e,
          mode: mode,
          hardwareButtonService: hw,
          geofenceService: gf,
          onDisarmRequested: () => disarmCount++,
          // Freeze the clock so both callbacks run at the exact same
          // instant — forcing the cooldown to kick in for the second.
          clock: () => DateTime.utc(2026, 4, 1, 12),
        );
        mgr.start();
        e.start();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 6));

        // Both timers fire but the second is within the 500 ms cooldown.
        check(disarmCount).equals(1);

        mgr.dispose();
        hw.close();
        gf.close();
        bm.close();
        e.dispose();
      });
    });
  });

  group('TriggerManager — panic with empty steps fallback', () {
    test('panic with no steps resolver and empty engine.steps is a no-op',
        () {
      fakeAsync((async) {
        final hw = _FakeHardwareButton();
        final gf = _FakeGeofence();
        final bm = _FakeBatteryMonitor();
        // Engine with NO chain steps → engine.steps fallback will be empty.
        final e = SessionEngine(chainSteps: [], random: FixedRandom());
        final mgr = TriggerManager(
          engine: e,
          mode: _distressMode(),
          hardwareButtonService: hw,
          geofenceService: gf,
          // No distressStepsResolver; engine.steps is empty.
        );
        mgr.start();
        // Do NOT start the engine — it would throw on an empty chain.
        async.flushMicrotasks();
        hw.emit(_panic());
        async.flushMicrotasks();
        // With empty steps the manager must not crash — isDistressChain
        // stays false because replaceWithDistressChain is never called.
        check(e.isDistressChain).isFalse();
        mgr.dispose();
        hw.close();
        gf.close();
        bm.close();
        e.dispose();
      });
    });
  });

  group('TriggerManager — isStarted reflects timer subscriptions', () {
    test('isStarted is true when only a timer trigger is configured', () {
      fakeAsync((async) {
        final hw = _FakeHardwareButton();
        final gf = _FakeGeofence();
        final bm = _FakeBatteryMonitor();
        final e = SessionEngine(chainSteps: [holdStep()], random: FixedRandom());
        final mgr = TriggerManager(
          engine: e,
          mode: _timerMode(30),
          hardwareButtonService: hw,
          geofenceService: gf,
        );
        mgr.start();
        async.flushMicrotasks();
        check(mgr.isStarted).isTrue();
        mgr.dispose();
        hw.close();
        gf.close();
        bm.close();
        e.dispose();
      });
    });
  });
}
