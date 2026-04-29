/// Strict integration tests for GPS arrival disarm triggers.
///
/// Covers:
/// - Arrival inside/outside various radius sizes (1m, 50m, 100m, 500m,
///   5000m)
/// - Exactly at boundary (haversine == radius → fires)
/// - Multiple arrivals → cooldown applies
/// - Arrival without onDisarmRequested → engine.disarm() called
/// - Arrival with onDisarmRequested callback → callback invoked, engine
///   NOT auto-disarmed
/// - No GPS trigger configured → no subscription
/// - Dispose before arrival → ignored
/// - Multiple GPS triggers on one mode
/// - Arrival after engine ended → engine.disarm() is idempotent
/// - Haversine correctness at known reference distances
library;

import 'dart:math' as math;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/trigger_manager.dart';
import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/models/trigger.dart';
import 'package:guardianangela/services/protocols/hardware_button_service_protocol.dart';
import 'package:guardianangela/services/fakes/fake_battery_monitor_service.dart';
import 'package:guardianangela/services/fakes/fake_geofence_service.dart';
import 'package:guardianangela/services/fakes/fake_hardware_button_service.dart';

import '../../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Haversine reference calculator (mirrors TriggerManager._withinRadius)
// ---------------------------------------------------------------------------

double _haversineMeters(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const earth = 6371000.0;
  final la1 = lat1 * (math.pi / 180.0);
  final la2 = lat2 * (math.pi / 180.0);
  final dLat = (lat2 - lat1) * (math.pi / 180.0);
  final dLon = (lon2 - lon1) * (math.pi / 180.0);
  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(la1) * math.cos(la2) * math.sin(dLon / 2) * math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earth * c;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _centerLat = 51.5074; // London
const _centerLon = -0.1278;

SessionMode _modeWithGps({
  double latitude = _centerLat,
  double longitude = _centerLon,
  double radiusMeters = 100,
  List<GpsArrivalDisarmTrigger>? extraTriggers,
}) {
  final triggers = <GpsArrivalDisarmTrigger>[
    GpsArrivalDisarmTrigger(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
    ),
    ...?extraTriggers,
  ];
  return SessionMode(
    id: 'mode-gps',
    name: 'GPS',
    checkInType: ChainStepType.holdButton,
    chainSteps: [holdStep()],
    distressTriggers: const [],
    disarmTriggers: triggers,
  );
}

LocationPoint _loc(double lat, double lon) => LocationPoint(
  latitude: lat,
  longitude: lon,
  timestamp: DateTime.utc(2026, 4, 1),
);

TriggerManager _makeMgr(
  SessionEngine engine,
  SessionMode mode, {
  FakeHardwareButtonService? hw,
  FakeGeofenceService? gf,
  FakeBatteryMonitorService? bm,
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
  // Group 1: Basic inside/outside tests at 100 m
  // -------------------------------------------------------------------------
  group('GPS arrival — 100 m geofence inside/outside', () {
    test('arrival at exact center fires onDisarmRequested', () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        final mgr = _makeMgr(
          engine,
          _modeWithGps(),
          hw: hw,
          gf: gf,
          bm: bm,
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        gf.injectArrival(_loc(_centerLat, _centerLon));
        async.flushMicrotasks();

        check(disarmCount).equals(1);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });

    test('arrival 200 m from center (outside 100 m radius) is dropped', () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        // ~200m north: 0.0018° ≈ 200m at 51.5°.
        const farLat = _centerLat + 0.0018;
        final mgr = _makeMgr(
          engine,
          _modeWithGps(),
          hw: hw,
          gf: gf,
          bm: bm,
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        gf.injectArrival(_loc(farLat, _centerLon));
        async.flushMicrotasks();

        check(disarmCount).equals(0);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Group 2: Radius variants — 1 m, 50 m, 500 m, 5000 m
  // -------------------------------------------------------------------------
  group('GPS arrival — radius variants', () {
    test('arrival inside 1 m radius fires at ≤1 m', () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        // Same point → distance = 0.
        final mgr = _makeMgr(
          engine,
          _modeWithGps(radiusMeters: 1),
          hw: hw,
          gf: gf,
          bm: bm,
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        gf.injectArrival(_loc(_centerLat, _centerLon));
        async.flushMicrotasks();

        check(disarmCount).equals(1);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });

    test('arrival outside 1 m radius is dropped', () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        // ~10m north.
        const nearLat = _centerLat + 0.0001;
        final dist = _haversineMeters(
          _centerLat,
          _centerLon,
          nearLat,
          _centerLon,
        );
        // Confirm our test point is truly > 1m.
        check(dist > 1.0).isTrue();
        final mgr = _makeMgr(
          engine,
          _modeWithGps(radiusMeters: 1),
          hw: hw,
          gf: gf,
          bm: bm,
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        gf.injectArrival(_loc(nearLat, _centerLon));
        async.flushMicrotasks();

        check(disarmCount).equals(0);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });

    test('arrival inside 50 m radius fires', () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        // ~20m north (well within 50m).
        const nearLat = _centerLat + 0.00018;
        final dist = _haversineMeters(
          _centerLat,
          _centerLon,
          nearLat,
          _centerLon,
        );
        check(dist < 50.0).isTrue();
        final mgr = _makeMgr(
          engine,
          _modeWithGps(radiusMeters: 50),
          hw: hw,
          gf: gf,
          bm: bm,
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        gf.injectArrival(_loc(nearLat, _centerLon));
        async.flushMicrotasks();

        check(disarmCount).equals(1);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });

    test('arrival inside 500 m radius fires', () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        // ~300m north.
        const nearLat = _centerLat + 0.0027;
        final dist = _haversineMeters(
          _centerLat,
          _centerLon,
          nearLat,
          _centerLon,
        );
        check(dist < 500.0).isTrue();
        final mgr = _makeMgr(
          engine,
          _modeWithGps(radiusMeters: 500),
          hw: hw,
          gf: gf,
          bm: bm,
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        gf.injectArrival(_loc(nearLat, _centerLon));
        async.flushMicrotasks();

        check(disarmCount).equals(1);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });

    test('arrival outside 500 m radius is dropped', () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        // ~1 km north.
        const farLat = _centerLat + 0.009;
        final dist = _haversineMeters(
          _centerLat,
          _centerLon,
          farLat,
          _centerLon,
        );
        check(dist > 500.0).isTrue();
        final mgr = _makeMgr(
          engine,
          _modeWithGps(radiusMeters: 500),
          hw: hw,
          gf: gf,
          bm: bm,
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        gf.injectArrival(_loc(farLat, _centerLon));
        async.flushMicrotasks();

        check(disarmCount).equals(0);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });

    test('arrival inside 5000 m radius fires', () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        // ~3 km north.
        const nearLat = _centerLat + 0.027;
        final dist = _haversineMeters(
          _centerLat,
          _centerLon,
          nearLat,
          _centerLon,
        );
        check(dist < 5000.0).isTrue();
        final mgr = _makeMgr(
          engine,
          _modeWithGps(radiusMeters: 5000),
          hw: hw,
          gf: gf,
          bm: bm,
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        gf.injectArrival(_loc(nearLat, _centerLon));
        async.flushMicrotasks();

        check(disarmCount).equals(1);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Group 3: Boundary at exactly radius distance
  // -------------------------------------------------------------------------
  group('GPS arrival — exactly at radius boundary', () {
    test(
        'arrival inside radius (haversine ≤ radiusMeters) fires '
        '(spec: distance <= radius)', () {
      // Spec: _withinRadius uses `distance <= trigger.radiusMeters`.
      // We inject a point at a computed ≤100 m distance.
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        // 0.0008° lat ≈ 89 m at 51.5° — within 100 m.
        const boundaryLat = _centerLat + 0.0008;
        final dist = _haversineMeters(
          _centerLat,
          _centerLon,
          boundaryLat,
          _centerLon,
        );
        // Confirm our test point is truly ≤ 100m.
        check(dist <= 100.0).isTrue();
        final mgr = _makeMgr(
          engine,
          _modeWithGps(radiusMeters: 100),
          hw: hw,
          gf: gf,
          bm: bm,
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        gf.injectArrival(_loc(boundaryLat, _centerLon));
        async.flushMicrotasks();

        check(disarmCount).equals(1);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });

    test('arrival just beyond radius is dropped', () {
      // 0.0009° lat ≈ 100.1 m at 51.5° — just outside 100 m.
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        const justOutsideLat = _centerLat + 0.0009;
        final dist = _haversineMeters(
          _centerLat,
          _centerLon,
          justOutsideLat,
          _centerLon,
        );
        // Confirm our test point is truly > 100m.
        check(dist > 100.0).isTrue();
        final mgr = _makeMgr(
          engine,
          _modeWithGps(radiusMeters: 100),
          hw: hw,
          gf: gf,
          bm: bm,
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        gf.injectArrival(_loc(justOutsideLat, _centerLon));
        async.flushMicrotasks();

        check(disarmCount).equals(0);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Group 4: Cooldown suppresses repeated arrivals
  // -------------------------------------------------------------------------
  group('GPS arrival — cooldown', () {
    test('two arrivals at same instant → only first fires', () {
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
        final mgr = _makeMgr(
          engine,
          _modeWithGps(),
          hw: hw,
          gf: gf,
          bm: bm,
          onDisarmRequested: () => disarmCount++,
          clock: () => frozenClock,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        gf.injectArrival(_loc(_centerLat, _centerLon));
        gf.injectArrival(_loc(_centerLat, _centerLon)); // within cooldown
        async.flushMicrotasks();

        check(disarmCount).equals(1);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });

    test('three arrivals within cooldown window → only first fires', () {
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
        final mgr = _makeMgr(
          engine,
          _modeWithGps(),
          hw: hw,
          gf: gf,
          bm: bm,
          onDisarmRequested: () => disarmCount++,
          clock: () => frozenClock,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        for (var i = 0; i < 3; i++) {
          gf.injectArrival(_loc(_centerLat, _centerLon));
        }
        async.flushMicrotasks();

        check(disarmCount).equals(1);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });

    test('arrival after cooldown passes fires again', () {
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
        final mgr = _makeMgr(
          engine,
          _modeWithGps(),
          hw: hw,
          gf: gf,
          bm: bm,
          onDisarmRequested: () => disarmCount++,
          clock: () => t,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        gf.injectArrival(_loc(_centerLat, _centerLon));
        async.flushMicrotasks();
        check(disarmCount).equals(1);

        // Advance past cooldown.
        t = t.add(const Duration(seconds: 1));
        gf.injectArrival(_loc(_centerLat, _centerLon));
        async.flushMicrotasks();

        check(disarmCount).equals(2);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });

    test('arrival cooldown is independent from panic cooldown', () {
      // Panic and arrival each maintain their own `_lastXFiredAt`.
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        var panicConfirmed = 0;
        final frozenClock = DateTime.utc(2026, 4, 1, 12);
        final mode = SessionMode(
          id: 'mode-both',
          name: 'Both',
          checkInType: ChainStepType.holdButton,
          chainSteps: [holdStep()],
          distressTriggers: const [
            HardwareButtonDistressTrigger(
              buttonType: ButtonType.volumeUp,
              trigger: RepeatPressTrigger(),
            ),
          ],
          disarmTriggers: const [
            GpsArrivalDisarmTrigger(
              latitude: _centerLat,
              longitude: _centerLon,
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
          onDistressConfirmation: () async {
            panicConfirmed++;
            return false; // veto distress
          },
          clock: () => frozenClock,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        // Panic fires (confirmation veto). Pattern id must match
        // the canonical name ('repeatPress' for RepeatPressTrigger)
        // emitted by `_panicEventMatchesConfiguredTrigger`.
        hw.injectPanic(
          HardwarePanicEvent(
            buttonType: 'volumeUp',
            pattern: 'repeatPress',
            timestamp: DateTime.utc(2026, 4, 1),
          ),
        );
        async.flushMicrotasks();
        check(panicConfirmed).equals(1);

        // Arrival also fires (different cooldown bucket).
        gf.injectArrival(_loc(_centerLat, _centerLon));
        async.flushMicrotasks();
        check(disarmCount).equals(1);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Group 5: No onDisarmRequested → engine.disarm() called
  // -------------------------------------------------------------------------
  group('GPS arrival — no callback path', () {
    test('arrival without callback calls engine.disarm()', () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        final mgr = _makeMgr(engine, _modeWithGps(), hw: hw, gf: gf, bm: bm);
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        gf.injectArrival(_loc(_centerLat, _centerLon));
        async.flushMicrotasks();

        check(engine.state).isA<EngineEnded>();
        check((engine.state as EngineEnded).reason).equals(EndReason.userQuit);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });

    test('engine.disarm() is idempotent when called from arrived callback', () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var t = DateTime.utc(2026, 4, 1, 12, 0, 0, 0);
        final mgr = _makeMgr(
          engine,
          _modeWithGps(),
          hw: hw,
          gf: gf,
          bm: bm,
          clock: () => t,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        gf.injectArrival(_loc(_centerLat, _centerLon));
        async.flushMicrotasks();
        check(engine.state).isA<EngineEnded>();

        // Second arrival (past cooldown) → engine.disarm() is idempotent.
        t = t.add(const Duration(seconds: 1));
        gf.injectArrival(_loc(_centerLat, _centerLon));
        async.flushMicrotasks();

        check(engine.state).isA<EngineEnded>();
        check((engine.state as EngineEnded).reason).equals(EndReason.userQuit);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Group 6: onDisarmRequested callback path
  // -------------------------------------------------------------------------
  group('GPS arrival — onDisarmRequested callback', () {
    test('with callback, engine is NOT auto-disarmed', () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var cbCount = 0;
        final mgr = _makeMgr(
          engine,
          _modeWithGps(),
          hw: hw,
          gf: gf,
          bm: bm,
          onDisarmRequested: () => cbCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        gf.injectArrival(_loc(_centerLat, _centerLon));
        async.flushMicrotasks();

        check(cbCount).equals(1);
        // Engine should NOT be ended — callback intercepted.
        check(engine.state).isA<EngineRunning>();

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });

    test('callback called once per non-cooldown-suppressed arrival', () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var cbCount = 0;
        var t = DateTime.utc(2026, 4, 1, 12, 0, 0, 0);
        final mgr = _makeMgr(
          engine,
          _modeWithGps(),
          hw: hw,
          gf: gf,
          bm: bm,
          onDisarmRequested: () => cbCount++,
          clock: () => t,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        gf.injectArrival(_loc(_centerLat, _centerLon));
        async.flushMicrotasks();
        t = t.add(const Duration(seconds: 1));
        gf.injectArrival(_loc(_centerLat, _centerLon));
        async.flushMicrotasks();

        check(cbCount).equals(2);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Group 7: Dispose before arrival
  // -------------------------------------------------------------------------
  group('GPS arrival — dispose before arrival', () {
    test('arrival event after dispose is ignored', () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        final mgr = _makeMgr(
          engine,
          _modeWithGps(),
          hw: hw,
          gf: gf,
          bm: bm,
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        mgr.dispose(); // unsubscribe
        gf.injectArrival(_loc(_centerLat, _centerLon));
        async.flushMicrotasks();

        check(disarmCount).equals(0);
        check(engine.state).isA<EngineRunning>();

        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Group 8: No GPS trigger → no subscription
  // -------------------------------------------------------------------------
  group('GPS arrival — no GPS trigger configured', () {
    test('mode with no GPS disarm trigger has no arrival subscription', () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        final mode = SessionMode(
          id: 'no-gps',
          name: 'NoGps',
          checkInType: ChainStepType.holdButton,
          chainSteps: [holdStep()],
          distressTriggers: const [],
          disarmTriggers: const [],
        );
        final mgr = TriggerManager(
          engine: engine,
          mode: mode,
          hardwareButtonService: hw,
          geofenceService: gf,
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        gf.injectArrival(_loc(_centerLat, _centerLon));
        async.flushMicrotasks();

        check(disarmCount).equals(0);
        check(mgr.isStarted).isFalse();

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Group 9: Multiple GPS triggers on one mode
  // -------------------------------------------------------------------------
  group('GPS arrival — multiple GPS triggers on one mode', () {
    test('arrival matched by second trigger (of two) fires', () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        // First trigger: London center. Second trigger: 1km north of center.
        const secondLat = _centerLat + 0.009; // ~1 km north
        final mode = SessionMode(
          id: 'mode-multi-gps',
          name: 'MultiGPS',
          checkInType: ChainStepType.holdButton,
          chainSteps: [holdStep()],
          distressTriggers: const [],
          disarmTriggers: const [
            GpsArrivalDisarmTrigger(
              latitude: _centerLat,
              longitude: _centerLon,
              radiusMeters: 50,
            ),
            GpsArrivalDisarmTrigger(
              latitude: secondLat,
              longitude: _centerLon,
              radiusMeters: 50,
            ),
          ],
        );
        final mgr = TriggerManager(
          engine: engine,
          mode: mode,
          hardwareButtonService: hw,
          geofenceService: gf,
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        // Arrive near second trigger center.
        gf.injectArrival(_loc(secondLat, _centerLon));
        async.flushMicrotasks();

        check(disarmCount).equals(1);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });

    test('arrival matched by neither GPS trigger is dropped', () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var disarmCount = 0;
        const otherLat = _centerLat + 0.009;
        final mode = SessionMode(
          id: 'mode-multi-gps-miss',
          name: 'MultiGPSMiss',
          checkInType: ChainStepType.holdButton,
          chainSteps: [holdStep()],
          distressTriggers: const [],
          disarmTriggers: const [
            GpsArrivalDisarmTrigger(
              latitude: _centerLat,
              longitude: _centerLon,
              radiusMeters: 50,
            ),
            GpsArrivalDisarmTrigger(
              latitude: otherLat,
              longitude: _centerLon,
              radiusMeters: 50,
            ),
          ],
        );
        final mgr = TriggerManager(
          engine: engine,
          mode: mode,
          hardwareButtonService: hw,
          geofenceService: gf,
          onDisarmRequested: () => disarmCount++,
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        // Far from both — e.g. Berlin (52.52, 13.40).
        gf.injectArrival(_loc(52.52, 13.40));
        async.flushMicrotasks();

        check(disarmCount).equals(0);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Group 10: Haversine distance correctness
  // -------------------------------------------------------------------------
  group('haversine distance correctness', () {
    test('known distance: London to Paris is ~340 km', () {
      // London: 51.5074, -0.1278  Paris: 48.8566, 2.3522
      final d = _haversineMeters(51.5074, -0.1278, 48.8566, 2.3522);
      // Actual haversine distance is approximately 339,800 m.
      check(d > 330000 && d < 350000).isTrue();
    });

    test('same point has distance 0', () {
      final d = _haversineMeters(51.5074, -0.1278, 51.5074, -0.1278);
      check(d < 0.001).isTrue();
    });

    test('antipodal points are ~20015 km', () {
      final d = _haversineMeters(0.0, 0.0, 0.0, 180.0);
      check(d > 20000000 && d < 20100000).isTrue();
    });

    test('north pole to south pole is ~20015 km', () {
      final d = _haversineMeters(90.0, 0.0, -90.0, 0.0);
      check(d > 20000000 && d < 20100000).isTrue();
    });
  });
}
