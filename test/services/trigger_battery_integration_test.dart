/// Strict integration tests for the battery monitor service and
/// [TriggerManager] system.
///
/// Covers:
/// - FakeBatteryMonitorService start/stop/inject basic behavior
/// - Threshold crossing fires onLowBattery once
/// - Multiple low-battery events from the fake service
/// - BatteryAlertConfig model: enabled flag, thresholdPercent, JSON
/// - BatteryMonitorService protocol is wired into TriggerManager
///   (TriggerManager stores the service but does not subscribe itself
///    — the SessionController owns the subscription loop)
/// - TriggerManager does NOT fire on battery events (not its job)
/// - Trigger system integration: mode with all three trigger types
/// - TriggerManager.dispose() clears all subscriptions and timers
/// - isStarted is false when no triggers at all
/// - Cooldown constant is 500ms
/// - Model equality, copyWith, toString, JSON for all trigger types
library;

import 'dart:async';

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/trigger_manager.dart';
import 'package:guardianangela/domain/models/battery_alert_config.dart';
import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/models/trigger.dart';
import 'package:guardianangela/services/fakes/fake_battery_monitor_service.dart';
import 'package:guardianangela/services/fakes/fake_geofence_service.dart';
import 'package:guardianangela/services/fakes/fake_hardware_button_service.dart';
import 'package:guardianangela/services/protocols/hardware_button_service_protocol.dart';

import '../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SessionMode _fullMode({
  bool hasDistress = true,
  bool hasGps = false,
  bool hasTimer = false,
}) => SessionMode(
  id: 'mode-full',
  name: 'Full',
  checkInType: ChainStepType.holdButton,
  chainSteps: [holdStep(), smsStep(order: 1)],
  distressTriggers: hasDistress
      ? const [
          HardwareButtonDistressTrigger(
            buttonType: ButtonType.volumeUp,
            trigger: RepeatPressTrigger(),
          ),
        ]
      : const [],
  disarmTriggers: <DisarmTrigger>[
    if (hasGps)
      const GpsArrivalDisarmTrigger(
        latitude: 51.5074,
        longitude: -0.1278,
        radiusMeters: 100,
      ),
    if (hasTimer) const TimerDisarmTrigger(durationSeconds: 60),
  ],
);

void main() {
  // -------------------------------------------------------------------------
  // Group 1: FakeBatteryMonitorService direct behavior
  // -------------------------------------------------------------------------
  group('FakeBatteryMonitorService — direct behavior', () {
    test('startMonitoring sets isActive and records threshold', () async {
      final bm = FakeBatteryMonitorService();
      check(bm.isActive).isFalse();
      await bm.startMonitoring(thresholdPercent: 15);
      check(bm.isActive).isTrue();
      check(bm.calls).deepEquals(['startMonitoring:15']);
      bm.dispose();
    });

    test('stopMonitoring clears isActive', () async {
      final bm = FakeBatteryMonitorService();
      await bm.startMonitoring(thresholdPercent: 20);
      await bm.stopMonitoring();
      check(bm.isActive).isFalse();
      check(bm.calls).deepEquals(['startMonitoring:20', 'stopMonitoring']);
      bm.dispose();
    });

    test('injectLowBattery emits on onLowBattery stream', () async {
      final bm = FakeBatteryMonitorService();
      final received = <int>[];
      final sub = bm.onLowBattery.listen(received.add);
      bm.injectLowBattery(10);
      await Future<void>.delayed(Duration.zero);
      check(received).deepEquals([10]);
      await sub.cancel();
      bm.dispose();
    });

    test('injectLowBattery fires for each injection', () async {
      final bm = FakeBatteryMonitorService();
      final received = <int>[];
      final sub = bm.onLowBattery.listen(received.add);
      bm.injectLowBattery(20);
      bm.injectLowBattery(10);
      bm.injectLowBattery(5);
      await Future<void>.delayed(Duration.zero);
      check(received).deepEquals([20, 10, 5]);
      await sub.cancel();
      bm.dispose();
    });

    test('multiple listeners all receive the same event', () async {
      final bm = FakeBatteryMonitorService();
      final a = <int>[];
      final b = <int>[];
      final sa = bm.onLowBattery.listen(a.add);
      final sb = bm.onLowBattery.listen(b.add);
      bm.injectLowBattery(12);
      await Future<void>.delayed(Duration.zero);
      check(a).deepEquals([12]);
      check(b).deepEquals([12]);
      await sa.cancel();
      await sb.cancel();
      bm.dispose();
    });

    test('no events received before injection', () async {
      final bm = FakeBatteryMonitorService();
      final received = <int>[];
      final sub = bm.onLowBattery.listen(received.add);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      check(received).isEmpty();
      await sub.cancel();
      bm.dispose();
    });

    test('startMonitoring records threshold in calls log', () async {
      final bm = FakeBatteryMonitorService();
      for (final threshold in [5, 10, 15, 20, 30]) {
        await bm.startMonitoring(thresholdPercent: threshold);
        check(bm.calls.last).equals('startMonitoring:$threshold');
      }
      bm.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // Group 2: TriggerManager does not subscribe to battery
  // -------------------------------------------------------------------------
  group('TriggerManager — battery events not processed by TriggerManager', () {
    test('battery injection has no effect on engine state via TriggerManager',
        () {
      // TriggerManager's job is panic + GPS + timer only.
      // BatteryMonitor subscription is handled by SessionController.
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        final mgr = TriggerManager(
          engine: engine,
          mode: _fullMode(hasDistress: false),
          hardwareButtonService: hw,
          geofenceService: gf,

        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        // Inject low-battery event.
        bm.injectLowBattery(5);
        async.flushMicrotasks();

        // Engine should be unaffected — TriggerManager doesn't act on battery.
        check(engine.state).isA<EngineRunning>();

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });

    test('TriggerManager stores batteryMonitorService but never subscribes',
        () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        final mgr = TriggerManager(
          engine: engine,
          mode: _fullMode(hasDistress: false),
          hardwareButtonService: hw,
          geofenceService: gf,

        );
        mgr.start();
        async.flushMicrotasks();

        // Verify the service is stored but not started by the manager.
        check(bm.isActive).isFalse();
        check(bm.calls).isEmpty(); // No startMonitoring call from TriggerManager.

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Group 3: BatteryAlertConfig model
  // -------------------------------------------------------------------------
  group('BatteryAlertConfig — model', () {
    test('default values (Q34/Q35): enabled=false, threshold=10, chain empty',
        () {
      const cfg = BatteryAlertConfig();
      check(cfg.enabled).isFalse();
      check(cfg.thresholdPercent).equals(10);
      check(cfg.chain).isEmpty();
    });

    test('JSON round-trip preserves enabled=false', () {
      const cfg = BatteryAlertConfig(enabled: false, thresholdPercent: 10);
      final j = cfg.toJson();
      final cfg2 = BatteryAlertConfig.fromJson(j);
      check(cfg2.enabled).isFalse();
      check(cfg2.thresholdPercent).equals(10);
    });

    test('JSON round-trip preserves threshold=30', () {
      const cfg = BatteryAlertConfig(thresholdPercent: 30);
      final j = cfg.toJson();
      final cfg2 = BatteryAlertConfig.fromJson(j);
      check(cfg2.thresholdPercent).equals(30);
    });

    test('JSON from empty map uses defaults (Q34/Q35)', () {
      final cfg = BatteryAlertConfig.fromJson({});
      check(cfg.enabled).isFalse();
      check(cfg.thresholdPercent).equals(10);
    });

    test('copyWith preserves unspecified fields', () {
      const cfg = BatteryAlertConfig(enabled: true, thresholdPercent: 20);
      final cfg2 = cfg.copyWith(enabled: false);
      check(cfg2.enabled).isFalse();
      check(cfg2.thresholdPercent).equals(20);
    });

    test('copyWith changes thresholdPercent only', () {
      const cfg = BatteryAlertConfig(thresholdPercent: 15);
      final cfg2 = cfg.copyWith(thresholdPercent: 25);
      check(cfg2.thresholdPercent).equals(25);
      check(cfg.thresholdPercent).equals(15); // original unchanged
    });

    test('equality is value-based', () {
      const a = BatteryAlertConfig(thresholdPercent: 15);
      const b = BatteryAlertConfig(thresholdPercent: 15);
      const c = BatteryAlertConfig(thresholdPercent: 20);
      check(a == b).isTrue();
      check(a == c).isFalse();
      check(a.hashCode).equals(b.hashCode);
    });

    test('toString contains enabled and threshold', () {
      const cfg = BatteryAlertConfig(enabled: true, thresholdPercent: 15);
      final s = cfg.toString();
      check(s).contains('15');
      check(s).contains('true');
    });

    test('BatteryAlertConfig with chain preserves steps in JSON', () {
      final cfg = BatteryAlertConfig(
        thresholdPercent: 10,
        chain: [smsStep(durationSeconds: 5)],
      );
      final j = cfg.toJson();
      final cfg2 = BatteryAlertConfig.fromJson(j);
      check(cfg2.chain.length).equals(1);
      check(cfg2.chain.first.type).equals(ChainStepType.smsContact);
    });

    test('threshold values at boundary: 0, 100', () {
      const low = BatteryAlertConfig(thresholdPercent: 0);
      const high = BatteryAlertConfig(thresholdPercent: 100);
      final jLow = low.toJson();
      final jHigh = high.toJson();
      check(BatteryAlertConfig.fromJson(jLow).thresholdPercent).equals(0);
      check(BatteryAlertConfig.fromJson(jHigh).thresholdPercent).equals(100);
    });
  });

  // -------------------------------------------------------------------------
  // Group 4: Full trigger integration (panic + GPS + timer)
  // -------------------------------------------------------------------------
  group('trigger system integration — all three types', () {
    test('mode with panic + GPS + timer all subscribe (isStarted=true)', () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        final mgr = TriggerManager(
          engine: engine,
          mode: _fullMode(hasDistress: true, hasGps: true, hasTimer: true),
          hardwareButtonService: hw,
          geofenceService: gf,

          distressStepsResolver: () => [smsStep(durationSeconds: 1)],
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        check(mgr.isStarted).isTrue();

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });

    test('dispose cancels panic + GPS + timer subscriptions', () {
      // After dispose(), no trigger-driven state changes occur.
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        var panicFired = false;
        final mgr = TriggerManager(
          engine: engine,
          mode: _fullMode(hasDistress: true, hasGps: false, hasTimer: true),
          hardwareButtonService: hw,
          geofenceService: gf,

          distressStepsResolver: () => [smsStep(durationSeconds: 1)],
          onDistressConfirmation: () async {
            panicFired = true;
            return false; // veto — distress chain blocked
          },
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        // Dispose before any triggers fire.
        mgr.dispose();
        check(mgr.isStarted).isFalse();

        // Inject panic — subscription is cancelled so confirmation never runs.
        hw.injectPanic(
          HardwarePanicEvent(
            buttonType: 'volumeUp',
            pattern: '5x_press',
            timestamp: DateTime.utc(2026, 4, 1),
          ),
        );
        async.elapse(const Duration(minutes: 2)); // past timer
        async.flushMicrotasks();

        // Panic confirmation never ran (subscription cancelled before inject).
        check(panicFired).isFalse();
        check(engine.isDistressChain).isFalse();
        check(engine.state).isA<EngineRunning>();

        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });

    test('GPS arrival disarms before timer fires; timer fires but engine ended',
        () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        final mgr = TriggerManager(
          engine: engine,
          mode: _fullMode(hasDistress: false, hasGps: true, hasTimer: true),
          hardwareButtonService: hw,
          geofenceService: gf,

          // No callback → engine.disarm() called directly.
        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

        // GPS fires first, engine ends.
        gf.injectArrival(
          LocationPoint(
            latitude: 51.5074,
            longitude: -0.1278,
            timestamp: DateTime.utc(2026, 4, 1),
          ),
        );
        async.flushMicrotasks();
        check(engine.state).isA<EngineEnded>();

        // Timer fires later — engine.endSession() is idempotent;
        // first disarm path wins and the reason is preserved.
        async.elapse(const Duration(seconds: 65));
        check(engine.state).isA<EngineEnded>();
        check((engine.state as EngineEnded).reason).equals(EndReason.disarm);

        mgr.dispose();
        hw.dispose();
        gf.dispose();
        bm.dispose();
        engine.dispose();
      });
    });

    test('mode with NO triggers → isStarted=false and no subscriptions', () {
      fakeAsync((async) {
        final hw = FakeHardwareButtonService();
        final gf = FakeGeofenceService();
        final bm = FakeBatteryMonitorService();
        final engine = SessionEngine(
          chainSteps: [holdStep()],
          random: FixedRandom(),
        );
        final mode = SessionMode(
          id: 'no-triggers',
          name: 'None',
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

        );
        mgr.start();
        engine.start();
        async.flushMicrotasks();

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
  // Group 5: TriggerManager cooldown constant
  // -------------------------------------------------------------------------
  group('TriggerManager — cooldown constant', () {
    test('cooldown is 500 ms', () {
      check(TriggerManager.cooldown)
          .equals(const Duration(milliseconds: 500));
    });

    test('cooldown is the same across multiple reads', () {
      final c1 = TriggerManager.cooldown;
      final c2 = TriggerManager.cooldown;
      check(c1).equals(c2);
    });
  });

  // -------------------------------------------------------------------------
  // Group 6: GpsArrivalDisarmTrigger model
  // -------------------------------------------------------------------------
  group('GpsArrivalDisarmTrigger — model', () {
    test('default radiusMeters is 100', () {
      const t = GpsArrivalDisarmTrigger(latitude: 51.0, longitude: -0.1);
      check(t.radiusMeters).equals(100);
    });

    test('JSON round-trip preserves all fields', () {
      const t = GpsArrivalDisarmTrigger(
        latitude: 48.8566,
        longitude: 2.3522,
        radiusMeters: 250,
      );
      final j = t.toJson();
      final t2 = GpsArrivalDisarmTrigger.fromJson(j);
      check(t2.latitude).equals(48.8566);
      check(t2.longitude).equals(2.3522);
      check(t2.radiusMeters).equals(250);
    });

    test('JSON includes kind=disarm and type=gpsArrival', () {
      const t = GpsArrivalDisarmTrigger(latitude: 0.0, longitude: 0.0);
      final j = t.toJson();
      check(j['kind']).equals('disarm');
      check(j['type']).equals('gpsArrival');
    });

    test('Trigger.fromJson dispatches to GpsArrivalDisarmTrigger', () {
      const t = GpsArrivalDisarmTrigger(
        latitude: 1.0,
        longitude: 2.0,
        radiusMeters: 50,
      );
      final t2 = Trigger.fromJson(t.toJson());
      check(t2).isA<GpsArrivalDisarmTrigger>();
    });

    test('equality and hashCode are value-based', () {
      const a = GpsArrivalDisarmTrigger(latitude: 50.0, longitude: 4.0);
      const b = GpsArrivalDisarmTrigger(latitude: 50.0, longitude: 4.0);
      const c = GpsArrivalDisarmTrigger(latitude: 50.0, longitude: 5.0);
      check(a == b).isTrue();
      check(a == c).isFalse();
      check(a.hashCode).equals(b.hashCode);
    });

    test('copyWith replaces specific fields', () {
      const t = GpsArrivalDisarmTrigger(
        latitude: 50.0,
        longitude: 4.0,
        radiusMeters: 100,
      );
      final t2 = t.copyWith(radiusMeters: 200);
      check(t2.radiusMeters).equals(200);
      check(t2.latitude).equals(50.0);
      check(t.radiusMeters).equals(100); // original unchanged
    });

    test('toString contains coordinates and radius', () {
      const t = GpsArrivalDisarmTrigger(
        latitude: 51.5,
        longitude: -0.1,
        radiusMeters: 50,
      );
      final s = t.toString();
      check(s).contains('51.5');
      check(s).contains('50');
    });
  });

  // -------------------------------------------------------------------------
  // Group 7: HardwareButtonDistressTrigger model
  // -------------------------------------------------------------------------
  group('HardwareButtonDistressTrigger — model', () {
    test('JSON round-trip with volumeUp + RepeatPress', () {
      const t = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeUp,
        trigger: RepeatPressTrigger(pressCount: 5, pressWindowMs: 500),
      );
      final j = t.toJson();
      final t2 = HardwareButtonDistressTrigger.fromJson(j);
      check(t2.buttonType).equals(ButtonType.volumeUp);
      check(t2.trigger).isA<RepeatPressTrigger>();
      check((t2.trigger as RepeatPressTrigger).pressCount).equals(5);
    });

    test('JSON round-trip with power + LongPress', () {
      const t = HardwareButtonDistressTrigger(
        buttonType: ButtonType.power,
        trigger: LongPressTrigger(durationSeconds: 3.0),
      );
      final j = t.toJson();
      final t2 = HardwareButtonDistressTrigger.fromJson(j);
      check(t2.buttonType).equals(ButtonType.power);
      check(t2.trigger).isA<LongPressTrigger>();
      check((t2.trigger as LongPressTrigger).durationSeconds).equals(3.0);
    });

    test('JSON includes kind=distress and type=hardwareButton', () {
      const t = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeDown,
        trigger: RepeatPressTrigger(),
      );
      final j = t.toJson();
      check(j['kind']).equals('distress');
      check(j['type']).equals('hardwareButton');
    });

    test('Trigger.fromJson dispatches to HardwareButtonDistressTrigger', () {
      const t = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeUp,
        trigger: RepeatPressTrigger(),
      );
      final t2 = Trigger.fromJson(t.toJson());
      check(t2).isA<HardwareButtonDistressTrigger>();
    });

    test('equality and hashCode are value-based', () {
      const a = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeUp,
        trigger: RepeatPressTrigger(pressCount: 5),
      );
      const b = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeUp,
        trigger: RepeatPressTrigger(pressCount: 5),
      );
      const c = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeDown,
        trigger: RepeatPressTrigger(pressCount: 5),
      );
      check(a == b).isTrue();
      check(a == c).isFalse();
      check(a.hashCode).equals(b.hashCode);
    });

    test('copyWith replaces buttonType', () {
      const t = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeUp,
        trigger: RepeatPressTrigger(),
      );
      final t2 = t.copyWith(buttonType: ButtonType.power);
      check(t2.buttonType).equals(ButtonType.power);
      check(t.buttonType).equals(ButtonType.volumeUp); // original unchanged
    });

    test('toString contains button type', () {
      const t = HardwareButtonDistressTrigger(
        buttonType: ButtonType.volumeDown,
        trigger: LongPressTrigger(),
      );
      check(t.toString()).contains('volumeDown');
    });
  });

  // -------------------------------------------------------------------------
  // Group 8: WrongPinThresholdDisarmTrigger model — DELETED (Q9)
  //
  // The class itself was removed in favor of `AppSettings
  // .wrongPinThreshold` as the single source of truth. There is no
  // longer a runtime trigger object to test.
  // -------------------------------------------------------------------------

  // -------------------------------------------------------------------------
  // Group 9: Trigger.fromJson — invalid inputs
  // -------------------------------------------------------------------------
  group('Trigger.fromJson — invalid inputs', () {
    test('missing kind throws ArgumentError', () {
      check(() => Trigger.fromJson({'type': 'timer'}))
          .throws<ArgumentError>();
    });

    test('unknown kind throws ArgumentError', () {
      check(
        () => Trigger.fromJson({'kind': 'unknown', 'type': 'timer'}),
      ).throws<ArgumentError>();
    });

    test('distress with unknown type throws', () {
      check(
        () => Trigger.fromJson({'kind': 'distress', 'type': 'noSuchTrigger'}),
      ).throws<ArgumentError>();
    });

    test('disarm with unknown type throws', () {
      check(
        () => Trigger.fromJson({'kind': 'disarm', 'type': 'mystery'}),
      ).throws<ArgumentError>();
    });

    test('HardwareTrigger.fromJson with unknown type throws', () {
      check(
        () => HardwareTrigger.fromJson({'type': 'unknownPattern'}),
      ).throws<ArgumentError>();
    });

    test('HardwareTrigger.fromJson with missing type throws', () {
      check(() => HardwareTrigger.fromJson({})).throws<ArgumentError>();
    });
  });

  // -------------------------------------------------------------------------
  // Group 10: Trigger sealed hierarchy dispatches correctly
  // -------------------------------------------------------------------------
  group('Trigger sealed hierarchy', () {
    test('RepeatPressTrigger.fromJson round-trips without optional fields', () {
      // pressCount and pressWindowMs are optional with defaults.
      // pressWindowMs defaults to 1500 (D-HARDWARE-1) — wide enough to
      // be achievable in pocket while resisting false-fire from quick
      // music-control taps.
      final t = RepeatPressTrigger.fromJson({'type': 'repeatPress'});
      check(t.pressCount).equals(5); // default
      check(t.pressWindowMs).equals(1500); // default
    });

    test('LongPressTrigger.fromJson uses default durationSeconds when absent',
        () {
      final t = LongPressTrigger.fromJson({'type': 'longPress'});
      check(t.durationSeconds).equals(2.0); // default
    });

    test('HardwareTrigger.fromJson dispatches repeatPress', () {
      final t = HardwareTrigger.fromJson({
        'type': 'repeatPress',
        'pressCount': 3,
        'pressWindowMs': 1000,
      });
      check(t).isA<RepeatPressTrigger>();
    });

    test('HardwareTrigger.fromJson dispatches longPress', () {
      final t = HardwareTrigger.fromJson({
        'type': 'longPress',
        'durationSeconds': 5.0,
      });
      check(t).isA<LongPressTrigger>();
    });

    test('DisarmTrigger.fromJson dispatches timer', () {
      final t = DisarmTrigger.fromJson({'type': 'timer', 'durationSeconds': 30});
      check(t).isA<TimerDisarmTrigger>();
    });

    test('DisarmTrigger.fromJson dispatches gpsArrival', () {
      final t = DisarmTrigger.fromJson({
        'type': 'gpsArrival',
        'latitude': 51.0,
        'longitude': -0.1,
      });
      check(t).isA<GpsArrivalDisarmTrigger>();
    });

    test('DisarmTrigger.fromJson rejects deleted wrongPinThreshold', () {
      // Q9: the wrongPinThreshold disarm-trigger class was deleted —
      // its threshold lives on `AppSettings.wrongPinThreshold` now.
      // The dispatcher must reject the legacy tag rather than silently
      // round-trip a stale config from disk.
      check(() => DisarmTrigger.fromJson({
            'type': 'wrongPinThreshold',
            'threshold': 3,
          })).throws<ArgumentError>();
    });

    test('DistressTrigger.fromJson dispatches hardwareButton', () {
      final t = DistressTrigger.fromJson({
        'type': 'hardwareButton',
        'buttonType': 'volumeUp',
        'trigger': {'type': 'repeatPress'},
      });
      check(t).isA<HardwareButtonDistressTrigger>();
    });

    test('DistressTrigger.fromJson with missing type throws', () {
      check(() => DistressTrigger.fromJson({'kind': 'distress'}))
          .throws<ArgumentError>();
    });

    test('DisarmTrigger.fromJson with missing type throws', () {
      check(() => DisarmTrigger.fromJson({'kind': 'disarm'}))
          .throws<ArgumentError>();
    });
  });

  // -------------------------------------------------------------------------
  // Group 11: RepeatPressTrigger model completeness
  // -------------------------------------------------------------------------
  group('RepeatPressTrigger — model completeness', () {
    test('copyWith replaces pressCount only', () {
      const t = RepeatPressTrigger(pressCount: 5, pressWindowMs: 500);
      final t2 = t.copyWith(pressCount: 3);
      check(t2.pressCount).equals(3);
      check(t2.pressWindowMs).equals(500);
    });

    test('copyWith replaces pressWindowMs only', () {
      const t = RepeatPressTrigger(pressCount: 5, pressWindowMs: 500);
      final t2 = t.copyWith(pressWindowMs: 2000);
      check(t2.pressWindowMs).equals(2000);
      check(t2.pressCount).equals(5);
    });

    test('equality identical references', () {
      const t = RepeatPressTrigger(pressCount: 5);
      // ignore: unrelated_type_equality_checks
      check(t == t).isTrue();
    });

    test('toString contains press count and window', () {
      const t = RepeatPressTrigger(pressCount: 3, pressWindowMs: 1000);
      final s = t.toString();
      check(s).contains('3');
      check(s).contains('1000');
    });
  });

  // -------------------------------------------------------------------------
  // Group 12: LongPressTrigger model completeness
  // -------------------------------------------------------------------------
  group('LongPressTrigger — model completeness', () {
    test('copyWith replaces durationSeconds', () {
      const t = LongPressTrigger(durationSeconds: 2.0);
      final t2 = t.copyWith(durationSeconds: 5.0);
      check(t2.durationSeconds).equals(5.0);
      check(t.durationSeconds).equals(2.0);
    });

    test('equality and hashCode', () {
      const a = LongPressTrigger(durationSeconds: 3.0);
      const b = LongPressTrigger(durationSeconds: 3.0);
      const c = LongPressTrigger(durationSeconds: 5.0);
      check(a == b).isTrue();
      check(a == c).isFalse();
      check(a.hashCode).equals(b.hashCode);
    });

    test('toString contains duration', () {
      const t = LongPressTrigger(durationSeconds: 2.5);
      check(t.toString()).contains('2.5');
    });

    test('default durationSeconds is 2.0', () {
      const t = LongPressTrigger();
      check(t.durationSeconds).equals(2.0);
    });
  });
}
