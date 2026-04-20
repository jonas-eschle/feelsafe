/// Tests for [TriggerManager] — hardware panic + GPS arrival wiring.
library;

import 'dart:async';

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
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
    int pressWindowMs = 500,
    double longPressDurationSeconds = 2.0,
  }) async {
    _listening = true;
  }

  @override
  Future<void> stop() async {
    _listening = false;
  }

  void emit(HardwarePanicEvent ev) => _ctrl.add(ev);

  void dispose() => _ctrl.close();
}

class _FakeGeofence implements GeofenceServiceProtocol {
  final StreamController<LocationPoint> _ctrl =
      StreamController<LocationPoint>.broadcast(sync: true);
  bool _registered = false;

  @override
  Stream<LocationPoint> get arrivals => _ctrl.stream;

  @override
  Future<void> registerGeofence({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    _registered = true;
  }

  @override
  Future<void> removeGeofence() async {
    _registered = false;
  }

  bool get isRegistered => _registered;

  void emit(LocationPoint p) => _ctrl.add(p);

  void dispose() => _ctrl.close();
}

class _FakeBatteryMonitor implements BatteryMonitorServiceProtocol {
  final StreamController<int> _ctrl = StreamController<int>.broadcast(
    sync: true,
  );
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

  void dispose() => _ctrl.close();
}

HardwarePanicEvent _panic({DateTime? at}) => HardwarePanicEvent(
  buttonType: 'volume',
  pattern: '5x_press',
  timestamp: at ?? DateTime.utc(2026, 4, 1),
);

SessionMode _mode({
  List<DistressTrigger>? distress,
  List<DisarmTrigger>? disarm,
}) => SessionMode(
  id: 'mode-1',
  name: 'Walk',
  checkInType: ChainStepType.holdButton,
  chainSteps: [holdStep()],
  distressTriggers: distress ??
      [
        const HardwareButtonDistressTrigger(
          buttonType: ButtonType.volumeUp,
          trigger: RepeatPressTrigger(),
        ),
      ],
  disarmTriggers: disarm ?? const [],
);

void main() {
  group('TriggerManager lifecycle', () {
    test('start subscribes when distressTriggers is non-empty', () async {
      final hw = _FakeHardwareButton();
      final gf = _FakeGeofence();
      final bm = _FakeBatteryMonitor();
      final e = SessionEngine(
        chainSteps: [holdStep(), smsStep(order: 1)],
        random: FixedRandom(),
      );
      final mgr = TriggerManager(
        engine: e,
        mode: _mode(),
        hardwareButtonService: hw,
        geofenceService: gf,
        batteryMonitorService: bm,
      );
      await mgr.start();
      check(mgr.isStarted).isTrue();
      await mgr.dispose();
      hw.dispose();
      gf.dispose();
      bm.dispose();
      e.dispose();
    });

    test('start is idempotent', () async {
      final hw = _FakeHardwareButton();
      final gf = _FakeGeofence();
      final bm = _FakeBatteryMonitor();
      final e = SessionEngine(
        chainSteps: [holdStep()],
        random: FixedRandom(),
      );
      final mgr = TriggerManager(
        engine: e,
        mode: _mode(),
        hardwareButtonService: hw,
        geofenceService: gf,
        batteryMonitorService: bm,
      );
      await mgr.start();
      await mgr.start();
      check(mgr.isStarted).isTrue();
      await mgr.dispose();
      hw.dispose();
      gf.dispose();
      bm.dispose();
      e.dispose();
    });

    test('start does not subscribe if no triggers', () async {
      final hw = _FakeHardwareButton();
      final gf = _FakeGeofence();
      final bm = _FakeBatteryMonitor();
      final e = SessionEngine(
        chainSteps: [holdStep()],
        random: FixedRandom(),
      );
      final mgr = TriggerManager(
        engine: e,
        mode: _mode(distress: const [], disarm: const []),
        hardwareButtonService: hw,
        geofenceService: gf,
        batteryMonitorService: bm,
      );
      await mgr.start();
      check(mgr.isStarted).isFalse();
      await mgr.dispose();
      hw.dispose();
      gf.dispose();
      bm.dispose();
      e.dispose();
    });

    test('dispose cancels subscriptions', () async {
      final hw = _FakeHardwareButton();
      final gf = _FakeGeofence();
      final bm = _FakeBatteryMonitor();
      final e = SessionEngine(
        chainSteps: [holdStep()],
        random: FixedRandom(),
      );
      final mgr = TriggerManager(
        engine: e,
        mode: _mode(),
        hardwareButtonService: hw,
        geofenceService: gf,
        batteryMonitorService: bm,
      );
      await mgr.start();
      await mgr.dispose();
      check(mgr.isStarted).isFalse();
      hw.dispose();
      gf.dispose();
      bm.dispose();
      e.dispose();
    });

    test('dispose cancels both panic and arrival subscriptions', () async {
      final hw = _FakeHardwareButton();
      final gf = _FakeGeofence();
      final bm = _FakeBatteryMonitor();
      final e = SessionEngine(
        chainSteps: [holdStep()],
        random: FixedRandom(),
      );
      final mgr = TriggerManager(
        engine: e,
        mode: _mode(
          disarm: const [
            GpsArrivalDisarmTrigger(
              latitude: 50.0,
              longitude: 4.0,
              radiusMeters: 100,
            ),
          ],
        ),
        hardwareButtonService: hw,
        geofenceService: gf,
        batteryMonitorService: bm,
      );
      await mgr.start();
      check(mgr.isStarted).isTrue();
      await mgr.dispose();
      check(mgr.isStarted).isFalse();
      hw.dispose();
      gf.dispose();
      bm.dispose();
      e.dispose();
    });
  });

  group('hardware panic → distress chain', () {
    test('panic fires replaceWithDistressChain via resolver', () {
      fakeAsync((async) {
        final hw = _FakeHardwareButton();
        final gf = _FakeGeofence();
        final bm = _FakeBatteryMonitor();
        final e = SessionEngine(
          chainSteps: [holdStep(), smsStep(order: 1)],
          random: FixedRandom(),
        );
        final distressSteps = [
          smsStep(id: 'distress-0', durationSeconds: 1, gracePeriodSeconds: 0),
        ];
        final mgr = TriggerManager(
          engine: e,
          mode: _mode(),
          hardwareButtonService: hw,
          geofenceService: gf,
          batteryMonitorService: bm,
          distressStepsResolver: () => distressSteps,
        );
        mgr.start();
        async.flushMicrotasks();
        e.start();
        async.flushMicrotasks();
        hw.emit(_panic());
        async.flushMicrotasks();
        check(e.isDistressChain).isTrue();
        check(e.steps.length).equals(1);
        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        e.dispose();
      });
    });

    test('panic within cooldown is dropped', () {
      fakeAsync((async) {
        final hw = _FakeHardwareButton();
        final gf = _FakeGeofence();
        final bm = _FakeBatteryMonitor();
        final e = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        final distressSteps = [smsStep(durationSeconds: 1)];
        var confirmCount = 0;
        final mgr = TriggerManager(
          engine: e,
          mode: _mode(),
          hardwareButtonService: hw,
          geofenceService: gf,
          batteryMonitorService: bm,
          distressStepsResolver: () => distressSteps,
          onDistressConfirmation: () async {
            confirmCount++;
            return true;
          },
          clock: () => DateTime.utc(2026, 4, 1, 12, 0, 0),
        );
        mgr.start();
        e.start();
        async.flushMicrotasks();
        hw.emit(_panic());
        async.flushMicrotasks();
        hw.emit(_panic()); // within cooldown — dropped.
        async.flushMicrotasks();
        check(confirmCount).equals(1);
        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        e.dispose();
      });
    });

    test('panic outside cooldown fires confirmation again', () async {
      final hw = _FakeHardwareButton();
      final gf = _FakeGeofence();
      final bm = _FakeBatteryMonitor();
      final e = SessionEngine(
        chainSteps: [holdStep()],
        random: FixedRandom(),
      );
      var t = DateTime.utc(2026, 4, 1, 12, 0, 0);
      var confirmCount = 0;
      final mgr = TriggerManager(
        engine: e,
        mode: _mode(),
        hardwareButtonService: hw,
        geofenceService: gf,
        batteryMonitorService: bm,
        distressStepsResolver: () => [smsStep(durationSeconds: 1)],
        onDistressConfirmation: () async {
          confirmCount++;
          return true;
        },
        clock: () => t,
      );
      await mgr.start();
      e.start();
      hw.emit(_panic());
      // Advance beyond cooldown (>500 ms).
      t = t.add(const Duration(seconds: 1));
      hw.emit(_panic());
      await Future<void>.delayed(Duration.zero);
      // Second call passes cooldown → confirmation runs, but
      // engine.replaceWithDistressChain is no-op (D-SAFETY-17).
      check(confirmCount).equals(2);
      check(e.isDistressChain).isTrue();
      await mgr.dispose();
      hw.dispose();
      gf.dispose();
      bm.dispose();
      e.dispose();
    });

    test('onDistressConfirmation can veto firing', () {
      fakeAsync((async) {
        final hw = _FakeHardwareButton();
        final gf = _FakeGeofence();
        final bm = _FakeBatteryMonitor();
        final e = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        final mgr = TriggerManager(
          engine: e,
          mode: _mode(),
          hardwareButtonService: hw,
          geofenceService: gf,
          batteryMonitorService: bm,
          distressStepsResolver: () => [smsStep(durationSeconds: 1)],
          onDistressConfirmation: () async => false,
        );
        mgr.start();
        e.start();
        async.flushMicrotasks();
        hw.emit(_panic());
        async.elapse(const Duration(milliseconds: 10));
        async.flushMicrotasks();
        check(e.isDistressChain).isFalse();
        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        e.dispose();
      });
    });

    test('without resolver uses engine.steps fallback', () {
      fakeAsync((async) {
        final hw = _FakeHardwareButton();
        final gf = _FakeGeofence();
        final bm = _FakeBatteryMonitor();
        final engineSteps = [
          holdStep(),
          smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
        ];
        final e = SessionEngine(
          chainSteps: engineSteps,
          random: FixedRandom(),
        );
        final mgr = TriggerManager(
          engine: e,
          mode: _mode(),
          hardwareButtonService: hw,
          geofenceService: gf,
          batteryMonitorService: bm,
        );
        mgr.start();
        e.start();
        async.flushMicrotasks();
        hw.emit(_panic());
        async.flushMicrotasks();
        check(e.isDistressChain).isTrue();
        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        e.dispose();
      });
    });
  });

  group('GPS arrival → disarm', () {
    test('arrival inside geofence calls onDisarmRequested', () {
      fakeAsync((async) {
        final hw = _FakeHardwareButton();
        final gf = _FakeGeofence();
        final bm = _FakeBatteryMonitor();
        final e = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        final mgr = TriggerManager(
          engine: e,
          mode: _mode(
            distress: const [],
            disarm: const [
              GpsArrivalDisarmTrigger(
                latitude: 50.0,
                longitude: 4.0,
                radiusMeters: 100,
              ),
            ],
          ),
          hardwareButtonService: hw,
          geofenceService: gf,
          batteryMonitorService: bm,
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        e.start();
        async.flushMicrotasks();
        gf.emit(
          LocationPoint(
            latitude: 50.0001,
            longitude: 4.0001,
            timestamp: DateTime.utc(2026, 4, 1),
          ),
        );
        async.flushMicrotasks();
        check(disarmCount).equals(1);
        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        e.dispose();
      });
    });

    test('arrival outside geofence is dropped', () {
      fakeAsync((async) {
        final hw = _FakeHardwareButton();
        final gf = _FakeGeofence();
        final bm = _FakeBatteryMonitor();
        final e = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        final mgr = TriggerManager(
          engine: e,
          mode: _mode(
            distress: const [],
            disarm: const [
              GpsArrivalDisarmTrigger(
                latitude: 50.0,
                longitude: 4.0,
                radiusMeters: 100,
              ),
            ],
          ),
          hardwareButtonService: hw,
          geofenceService: gf,
          batteryMonitorService: bm,
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        e.start();
        async.flushMicrotasks();
        gf.emit(
          LocationPoint(
            latitude: 51.0,
            longitude: 5.0,
            timestamp: DateTime.utc(2026, 4, 1),
          ),
        );
        async.flushMicrotasks();
        check(disarmCount).equals(0);
        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        e.dispose();
      });
    });

    test('arrival without onDisarmRequested calls engine.disarm', () {
      fakeAsync((async) {
        final hw = _FakeHardwareButton();
        final gf = _FakeGeofence();
        final bm = _FakeBatteryMonitor();
        final e = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        final mgr = TriggerManager(
          engine: e,
          mode: _mode(
            distress: const [],
            disarm: const [
              GpsArrivalDisarmTrigger(
                latitude: 50.0,
                longitude: 4.0,
                radiusMeters: 100,
              ),
            ],
          ),
          hardwareButtonService: hw,
          geofenceService: gf,
          batteryMonitorService: bm,
        );
        mgr.start();
        e.start();
        async.flushMicrotasks();
        gf.emit(
          LocationPoint(
            latitude: 50.0,
            longitude: 4.0,
            timestamp: DateTime.utc(2026, 4, 1),
          ),
        );
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        check((e.state as EngineEnded).reason).equals(EndReason.disarm);
        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        e.dispose();
      });
    });

    test('arrival cooldown drops repeated events', () {
      fakeAsync((async) {
        final hw = _FakeHardwareButton();
        final gf = _FakeGeofence();
        final bm = _FakeBatteryMonitor();
        final e = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        final mgr = TriggerManager(
          engine: e,
          mode: _mode(
            distress: const [],
            disarm: const [
              GpsArrivalDisarmTrigger(
                latitude: 50.0,
                longitude: 4.0,
                radiusMeters: 100,
              ),
            ],
          ),
          hardwareButtonService: hw,
          geofenceService: gf,
          batteryMonitorService: bm,
          onDisarmRequested: () => disarmCount++,
          clock: () => DateTime.utc(2026, 4, 1, 12),
        );
        mgr.start();
        e.start();
        async.flushMicrotasks();
        gf.emit(
          LocationPoint(
            latitude: 50.0,
            longitude: 4.0,
            timestamp: DateTime.utc(2026, 4, 1),
          ),
        );
        gf.emit(
          LocationPoint(
            latitude: 50.0,
            longitude: 4.0,
            timestamp: DateTime.utc(2026, 4, 1),
          ),
        );
        async.flushMicrotasks();
        check(disarmCount).equals(1);
        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        e.dispose();
      });
    });
  });
}
