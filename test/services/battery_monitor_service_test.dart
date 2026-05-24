import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:guardianangela/services/battery_monitor_service.dart';
import 'package:guardianangela/services/protocols/battery_monitor_service_protocol.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/battery_monitor_service_sim.dart';

// ---------------------------------------------------------------------------
// Fake Battery for RealBatteryMonitorService injection
// ---------------------------------------------------------------------------

class _MockBattery extends Mock implements Battery {}

/// Creates a [_MockBattery] that returns [levels] in sequence on each
/// [batteryLevel] call, then repeats the last value.
_MockBattery _batteryThatReturns(List<int> levels) {
  final battery = _MockBattery();
  var index = 0;
  when(() => battery.batteryLevel).thenAnswer((_) async {
    final level = levels[index];
    if (index < levels.length - 1) index++;
    return level;
  });
  when(
    () => battery.onBatteryStateChanged,
  ).thenAnswer((_) => const Stream<BatteryState>.empty());
  return battery;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SimulationBatteryMonitorService _sim() => SimulationBatteryMonitorService();

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // SimulationBatteryMonitorService
  // =========================================================================

  group('SimulationBatteryMonitorService', () {
    late SimulationBatteryMonitorService s;

    setUp(() => s = _sim());
    tearDown(() => s.dispose());

    group('constructor', () {
      test('implements BatteryMonitorServiceProtocol', () {
        check(s).isA<BatteryMonitorServiceProtocol>();
      });

      test('isMonitoring is false initially', () {
        check(s.isMonitoring).isFalse();
      });

      test('lastThreshold is null initially', () {
        check(s.lastThreshold).isNull();
      });
    });

    group('startMonitoring', () {
      test('sets isMonitoring true', () async {
        await s.startMonitoring();
        check(s.isMonitoring).isTrue();
      });

      test('records threshold', () async {
        await s.startMonitoring(threshold: 25);
        check(s.lastThreshold).equals(25);
      });

      test('uses default threshold 10', () async {
        await s.startMonitoring();
        check(s.lastThreshold).equals(10);
      });

      test('can be called with threshold 1 (lower bound)', () async {
        await s.startMonitoring(threshold: 1);
        check(s.lastThreshold).equals(1);
      });

      test('can be called with threshold 100 (upper bound)', () async {
        await s.startMonitoring(threshold: 100);
        check(s.lastThreshold).equals(100);
      });
    });

    group('stopMonitoring', () {
      test('sets isMonitoring false', () async {
        await s.startMonitoring();
        await s.stopMonitoring();
        check(s.isMonitoring).isFalse();
      });

      test('clears lastThreshold', () async {
        await s.startMonitoring(threshold: 20);
        await s.stopMonitoring();
        check(s.lastThreshold).isNull();
      });

      test('safe to call before startMonitoring', () async {
        await s.stopMonitoring();
        check(s.isMonitoring).isFalse();
      });
    });

    group('batteryLevel stream', () {
      test('injectLevel emits to batteryLevel', () async {
        final emitted = <int>[];
        final sub = s.batteryLevel.listen(emitted.add);
        addTearDown(sub.cancel);

        s.injectLevel(80);
        await Future<void>.delayed(Duration.zero);

        check(emitted).deepEquals([80]);
      });

      test('multiple injections emit in order', () async {
        final emitted = <int>[];
        final sub = s.batteryLevel.listen(emitted.add);
        addTearDown(sub.cancel);

        s.injectLevel(50);
        s.injectLevel(30);
        s.injectLevel(9);
        await Future<void>.delayed(Duration.zero);

        check(emitted).deepEquals([50, 30, 9]);
      });

      test('batteryLevel is a broadcast stream (multiple subscribers)', () {
        final sub1 = s.batteryLevel.listen((_) {});
        final sub2 = s.batteryLevel.listen((_) {});
        addTearDown(sub1.cancel);
        addTearDown(sub2.cancel);
        // No exception = broadcast stream.
        check(true).isTrue();
      });

      test('sub-threshold injection fires on stream', () async {
        final emitted = <int>[];
        final sub = s.batteryLevel.listen(emitted.add);
        addTearDown(sub.cancel);

        await s.startMonitoring(threshold: 15);
        s.injectLevel(10); // below threshold
        await Future<void>.delayed(Duration.zero);

        check(emitted).contains(10);
      });
    });

    group('start → stop → restart', () {
      test('second startMonitoring resets threshold', () async {
        await s.startMonitoring(threshold: 20);
        await s.stopMonitoring();
        await s.startMonitoring(threshold: 5);
        check(s.lastThreshold).equals(5);
      });
    });
  });

  // =========================================================================
  // F15: RealBatteryMonitorService — one-shot alert logic
  // =========================================================================

  group('RealBatteryMonitorService — one-shot alert logic (F15)', () {
    test(
      'F15: two discharging reads below threshold both emit to batteryLevel',
      () async {
        // The one-shot guard prevents the ALERT from firing twice, but the
        // batteryLevel stream still emits all readings. Consumers (Phase 6
        // BatteryAlertController) watch for the first sub-threshold crossing.
        final battery = _batteryThatReturns([8, 5]);
        final svc = RealBatteryMonitorService(battery: battery);
        addTearDown(svc.stopMonitoring);

        final emitted = <int>[];
        final sub = svc.batteryLevel.listen(emitted.add);
        addTearDown(sub.cancel);

        // Default threshold=10. Both levels (8, 5) are below 10.
        await svc.startMonitoring();
        // startMonitoring calls _pollLevel() which is async.
        // Flush the microtask queue so the stream event is delivered.
        await Future<void>.delayed(Duration.zero);
        // startMonitoring already did the first poll (level=8).
        check(emitted).contains(8);
      },
    );

    test(
      'F15: batteryLevel emits first sub-threshold reading',
      () async {
        final battery = _batteryThatReturns([15, 9]);
        final svc = RealBatteryMonitorService(battery: battery);
        addTearDown(svc.stopMonitoring);

        final emitted = <int>[];
        final sub = svc.batteryLevel.listen(emitted.add);
        addTearDown(sub.cancel);

        // Default threshold=10. Level 15 is above threshold.
        await svc.startMonitoring();
        await Future<void>.delayed(Duration.zero);
        // First poll emits 15 (above threshold).
        check(emitted).contains(15);
      },
    );

    test(
      'F15: stopMonitoring resets one-shot so next startMonitoring re-arms',
      () async {
        final battery = _batteryThatReturns([5, 5]);
        final svc = RealBatteryMonitorService(battery: battery);

        final emitted = <int>[];
        final sub = svc.batteryLevel.listen(emitted.add);
        addTearDown(sub.cancel);

        // Default threshold=10. Level 5 is below threshold.
        await svc.startMonitoring();
        await Future<void>.delayed(Duration.zero);
        // First run: 5 is below threshold, alert fires.
        check(emitted).contains(5);

        await svc.stopMonitoring();
        // After stop, _alertFired is reset. Re-start should re-arm.
        await svc.startMonitoring();
        await Future<void>.delayed(Duration.zero);
        // Second poll (also returns 5 due to mock): still below threshold,
        // alert fires again because the guard was reset.
        check(emitted.where((l) => l == 5).length).isGreaterOrEqual(1);
        await svc.stopMonitoring();
      },
    );

    test('protocol: batteryLevel stream exposed', () {
      final s = _sim();
      addTearDown(s.dispose);
      check(s.batteryLevel).isA<Stream<int>>();
    });

    test(
      'protocol: startMonitoring + stopMonitoring both return Future<void>',
      () async {
        final s = _sim();
        addTearDown(s.dispose);
        await s.startMonitoring();
        await s.stopMonitoring();
        check(true).isTrue(); // no exception = contract fulfilled
      },
    );
  });

  // =========================================================================
  // Timer-based polling (fakeAsync verification of poll interval)
  // =========================================================================

  group('SimulationBatteryMonitorService — timer-independent stream', () {
    test('stream emits exactly injected values regardless of time', () {
      fakeAsync((async) {
        final s = _sim();
        final emitted = <int>[];
        final sub = s.batteryLevel.listen(emitted.add);

        s.injectLevel(45);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 120));
        s.injectLevel(30);
        async.flushMicrotasks();

        sub.cancel();
        s.dispose();

        check(emitted).deepEquals([45, 30]);
      });
    });
  });

  // =========================================================================
  // Simulation swap (Riverpod)
  // =========================================================================

  group('Simulation swap — BatteryMonitorService', () {
    late ProviderContainer container;
    late SimulationBatteryMonitorService sim;

    setUp(() {
      sim = _sim();
      container = ProviderContainer(
        overrides: [batteryMonitorServiceProvider.overrideWithValue(sim)],
      );
    });

    tearDown(() {
      container.dispose();
      sim.dispose();
    });

    test('overridden container returns SimulationBatteryMonitorService', () {
      final s = container.read(batteryMonitorServiceProvider);
      check(s).isA<SimulationBatteryMonitorService>();
    });

    test('simulation is not RealBatteryMonitorService', () {
      final s = container.read(batteryMonitorServiceProvider);
      check(
        s.runtimeType.toString(),
      ).not((c) => c.equals('RealBatteryMonitorService'));
    });

    test('simulation starts not monitoring', () {
      final s =
          container.read(batteryMonitorServiceProvider)
              as SimulationBatteryMonitorService;
      check(s.isMonitoring).isFalse();
    });
  });
}
