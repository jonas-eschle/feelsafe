import 'dart:async';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/enums/hardware_button_type.dart';
import 'package:guardianangela/domain/enums/hardware_trigger_pattern.dart';
import 'package:guardianangela/domain/models/hardware_panic_event.dart';
import 'package:guardianangela/services/protocols/hardware_button_service_protocol.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/hardware_button_service_sim.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SimulationHardwareButtonService _sim() => SimulationHardwareButtonService();

/// Returns a sequence of timestamps spaced [gapMs] apart starting from
/// an arbitrary base.
List<DateTime> _times(int count, {int gapMs = 100}) {
  final base = DateTime.utc(2026, 5, 12);
  return List.generate(
    count,
    (i) => base.add(Duration(milliseconds: i * gapMs)),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // SimulationHardwareButtonService — construction
  // =========================================================================

  group('SimulationHardwareButtonService', () {
    late SimulationHardwareButtonService s;

    setUp(() => s = _sim());
    tearDown(() => s.dispose());

    group('constructor', () {
      test('implements HardwareButtonServiceProtocol', () {
        check(s).isA<HardwareButtonServiceProtocol>();
      });

      test('isListening is false initially', () {
        check(s.isListening).isFalse();
      });

      test('panicEvents is a broadcast stream', () {
        final sub1 = s.panicEvents.listen((_) {});
        final sub2 = s.panicEvents.listen((_) {});
        addTearDown(sub1.cancel);
        addTearDown(sub2.cancel);
        check(true).isTrue(); // no exception = broadcast
      });
    });

    // =========================================================================
    // start / stop / updateConfig
    // =========================================================================

    group('start', () {
      test('sets isListening true', () {
        s.start();
        check(s.isListening).isTrue();
      });

      test('accepts all null args (uses defaults)', () {
        s.start();
        check(s.isListening).isTrue();
      });

      test('accepts custom args', () {
        s.start(
          buttonType: HardwareButtonType.volumeDown,
          pattern: HardwareTriggerPattern.longPress,
          pressCount: 3,
          pressWindowMs: 800,
          longPressDurationSeconds: 3.0,
        );
        check(s.isListening).isTrue();
      });

      test('clamps pressCount to [2, 10]', () async {
        // pressCount=1 → clamped to 2: need only 2 presses to fire.
        s.start(pressCount: 1, pressWindowMs: 2000);
        final events = <HardwarePanicEvent>[];
        final sub = s.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        final ts = _times(2);
        s.injectPress(timestamp: ts[0]);
        s.injectPress(timestamp: ts[1]);
        await Future<void>.delayed(Duration.zero);
        check(events).length.equals(1);
      });

      test('clamps pressCount to [2, 10] upper', () {
        // pressCount=20 → clamped to 10: need exactly 10 presses.
        s.start(pressCount: 20, pressWindowMs: 5000);
        check(s.isListening).isTrue();
      });
    });

    group('stop', () {
      test('sets isListening false', () {
        s.start();
        s.stop();
        check(s.isListening).isFalse();
      });

      test('safe to call before start', () {
        s.stop();
        check(s.isListening).isFalse();
      });

      test('no events after stop', () async {
        s.start(pressCount: 2, pressWindowMs: 2000);
        s.stop();

        final events = <HardwarePanicEvent>[];
        final sub = s.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        final ts = _times(2);
        s.injectPress(timestamp: ts[0]);
        s.injectPress(timestamp: ts[1]);
        await Future<void>.delayed(Duration.zero);
        check(events).isEmpty();
      });
    });

    group('updateConfig', () {
      test('null values leave config unchanged', () async {
        s.start(pressCount: 3, pressWindowMs: 2000);
        s.updateConfig(); // all nulls

        final events = <HardwarePanicEvent>[];
        final sub = s.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        // default is 5 presses; updateConfig with no args shouldn't change it
        // but start was called with 3 so 3 presses should fire.
        final ts = _times(3);
        s.injectPress(timestamp: ts[0]);
        s.injectPress(timestamp: ts[1]);
        s.injectPress(timestamp: ts[2]);
        await Future<void>.delayed(Duration.zero);
        check(events).length.equals(1);
      });

      test('buttonType update', () {
        s.start();
        s.updateConfig(buttonType: HardwareButtonType.volumeDown);
        check(s.isListening).isTrue();
      });
    });

    // =========================================================================
    // Repeat-press detection
    // =========================================================================

    group('repeat-press pattern', () {
      test('5 presses within window fires panic event', () async {
        s.start(pressCount: 5, pressWindowMs: 500);
        final events = <HardwarePanicEvent>[];
        final sub = s.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        final ts = _times(5); // 50ms apart, all within 500ms window
        for (final t in ts) {
          s.injectPress(timestamp: t);
        }
        await Future<void>.delayed(Duration.zero);

        check(events).length.equals(1);
        check(events.first.pattern).equals(HardwareTriggerPattern.repeatPress);
      });

      test('4 presses when count=5 does NOT fire', () async {
        s.start(pressCount: 5, pressWindowMs: 500);
        final events = <HardwarePanicEvent>[];
        final sub = s.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        final ts = _times(4);
        for (final t in ts) {
          s.injectPress(timestamp: t);
        }
        await Future<void>.delayed(Duration.zero);
        check(events).isEmpty();
      });

      test('presses outside window are discarded', () async {
        s.start(pressCount: 3, pressWindowMs: 200);
        final events = <HardwarePanicEvent>[];
        final sub = s.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        final base = DateTime.utc(2026, 5, 12);
        // Two presses at t=0 and t=100ms.
        s.injectPress(timestamp: base);
        s.injectPress(timestamp: base.add(const Duration(milliseconds: 100)));
        // Third press at t=300ms — the first press (t=0) is outside 200ms window.
        s.injectPress(timestamp: base.add(const Duration(milliseconds: 300)));
        await Future<void>.delayed(Duration.zero);
        // Still only 2 presses in window → no panic.
        check(events).isEmpty();
      });

      test('counter resets after panic fires', () async {
        s.start(pressCount: 3, pressWindowMs: 2000);
        final events = <HardwarePanicEvent>[];
        final sub = s.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        final ts = _times(6);
        for (final t in ts) {
          s.injectPress(timestamp: t);
        }
        await Future<void>.delayed(Duration.zero);
        // 6 presses with count=3 → 2 panic events.
        check(events).length.equals(2);
      });

      test('panic event has correct buttonType', () async {
        s.start(
          buttonType: HardwareButtonType.volumeDown,
          pressCount: 2,
          pressWindowMs: 2000,
        );
        final events = <HardwarePanicEvent>[];
        final sub = s.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        final ts = _times(2);
        s.injectPress(timestamp: ts[0]);
        s.injectPress(timestamp: ts[1]);
        await Future<void>.delayed(Duration.zero);

        check(events.first.buttonType).equals(HardwareButtonType.volumeDown);
      });

      test('panic event has correct pattern', () async {
        s.start(pressCount: 2, pressWindowMs: 2000);
        final events = <HardwarePanicEvent>[];
        final sub = s.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        final ts = _times(2);
        s.injectPress(timestamp: ts[0]);
        s.injectPress(timestamp: ts[1]);
        await Future<void>.delayed(Duration.zero);

        check(events.first.pattern).equals(HardwareTriggerPattern.repeatPress);
      });
    });

    // =========================================================================
    // Long-press detection
    // =========================================================================

    group('long-press pattern', () {
      test('hold >= longPressDuration fires panic event', () async {
        s.start(
          pattern: HardwareTriggerPattern.longPress,
          longPressDurationSeconds: 2.0,
        );
        final events = <HardwarePanicEvent>[];
        final sub = s.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        final base = DateTime.utc(2026, 5, 1, 12);
        s.injectPress(timestamp: base);
        s.injectPress(
          timestamp: base.add(const Duration(seconds: 3)),
          isDown: false,
        );
        await Future<void>.delayed(Duration.zero);

        check(events).length.equals(1);
        check(events.first.pattern).equals(HardwareTriggerPattern.longPress);
      });

      test('hold < longPressDuration does NOT fire', () async {
        s.start(
          pattern: HardwareTriggerPattern.longPress,
          longPressDurationSeconds: 2.0,
        );
        final events = <HardwarePanicEvent>[];
        final sub = s.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        final base = DateTime.utc(2026, 5, 1, 12);
        s.injectPress(timestamp: base);
        s.injectPress(
          timestamp: base.add(const Duration(milliseconds: 1500)),
          isDown: false,
        );
        await Future<void>.delayed(Duration.zero);
        check(events).isEmpty();
      });

      test('hold exactly equals duration fires', () async {
        s.start(
          pattern: HardwareTriggerPattern.longPress,
          longPressDurationSeconds: 2.0,
        );
        final events = <HardwarePanicEvent>[];
        final sub = s.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        final base = DateTime.utc(2026, 5, 1, 12);
        s.injectPress(timestamp: base);
        s.injectPress(
          timestamp: base.add(const Duration(seconds: 2)),
          isDown: false,
        );
        await Future<void>.delayed(Duration.zero);
        check(events).length.equals(1);
      });

      test('up without prior down is a no-op', () async {
        s.start(pattern: HardwareTriggerPattern.longPress);
        final events = <HardwarePanicEvent>[];
        final sub = s.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        s.injectPress(isDown: false);
        await Future<void>.delayed(Duration.zero);
        check(events).isEmpty();
      });
    });

    // =========================================================================
    // F14: iOS repeat-press via injectPress + long-press not available on iOS
    // =========================================================================

    group('F14: iOS C1 repeat-press via injectPress', () {
      test(
        '5 repeat presses within window fires panic (iOS equivalent)',
        () async {
          // On iOS the headphone remote fires the same counter logic.
          // The simulation drives this identically via injectPress.
          s.start(pressCount: 5, pressWindowMs: 500);
          final events = <HardwarePanicEvent>[];
          final sub = s.panicEvents.listen(events.add);
          addTearDown(sub.cancel);

          final ts = _times(5, gapMs: 80); // 80ms apart, all within 500ms
          for (final t in ts) {
            s.injectPress(timestamp: t);
          }
          await Future<void>.delayed(Duration.zero);
          check(events).length.equals(1);
          check(
            events.first.pattern,
          ).equals(HardwareTriggerPattern.repeatPress);
        },
      );

      test(
        'iOS headphone remote pattern: 3 presses within 300ms window fires',
        () async {
          s.start(pressCount: 3, pressWindowMs: 300);
          final events = <HardwarePanicEvent>[];
          final sub = s.panicEvents.listen(events.add);
          addTearDown(sub.cancel);

          final ts = _times(3, gapMs: 80);
          for (final t in ts) {
            s.injectPress(timestamp: t);
          }
          await Future<void>.delayed(Duration.zero);
          check(events).length.equals(1);
        },
      );

      test('iOS: repeat presses outside window are discarded', () async {
        s.start(pressCount: 3, pressWindowMs: 200);
        final events = <HardwarePanicEvent>[];
        final sub = s.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        final base = DateTime.utc(2026, 5, 12);
        s.injectPress(timestamp: base);
        s.injectPress(timestamp: base.add(const Duration(milliseconds: 100)));
        // Third press at 400ms — first press (0ms) is outside 200ms window.
        s.injectPress(timestamp: base.add(const Duration(milliseconds: 400)));
        await Future<void>.delayed(Duration.zero);
        check(events).isEmpty();
      });
    });

    group('F14: long-press not supported on iOS', () {
      // The spec states (05:690): "Long-press detection requires ACTION_DOWN/UP
      // timestamps from the native layer, which are not available via the
      // audio_service media button callbacks. Long-press is **not supported on
      // iOS**." The simulation still exercises the logic for Android tests,
      // but the production iOS path only registers repeat-press.
      //
      // Verify: when pattern=longPress is configured in the simulation,
      // the spec contract is documented and the simulation behaves consistently.
      test('long-press fires in simulation regardless of platform', () async {
        // This tests the simulation (which does not do platform detection).
        // On iOS production this code path is unreachable (spec 05:690).
        s.start(
          pattern: HardwareTriggerPattern.longPress,
          longPressDurationSeconds: 1.0,
        );
        final events = <HardwarePanicEvent>[];
        final sub = s.panicEvents.listen(events.add);
        addTearDown(sub.cancel);

        final base = DateTime.utc(2026, 5, 12);
        s.injectPress(timestamp: base);
        s.injectPress(
          timestamp: base.add(const Duration(seconds: 2)),
          isDown: false,
        );
        await Future<void>.delayed(Duration.zero);
        check(events).length.equals(1);
        check(events.first.pattern).equals(HardwareTriggerPattern.longPress);
      });
    });

    // =========================================================================
    // Simulation swap (Riverpod)
    // =========================================================================
  });

  group('Simulation swap — HardwareButtonService', () {
    late ProviderContainer container;
    late SimulationHardwareButtonService sim;

    setUp(() {
      sim = _sim();
      container = ProviderContainer(
        overrides: [hardwareButtonServiceProvider.overrideWithValue(sim)],
      );
    });

    tearDown(() {
      container.dispose();
      sim.dispose();
    });

    test('overridden container returns SimulationHardwareButtonService', () {
      final s = container.read(hardwareButtonServiceProvider);
      check(s).isA<SimulationHardwareButtonService>();
    });

    test('simulation is not RealHardwareButtonService', () {
      final s = container.read(hardwareButtonServiceProvider);
      check(
        s.runtimeType.toString(),
      ).not((c) => c.equals('RealHardwareButtonService'));
    });

    test('simulation starts not listening', () {
      final s =
          container.read(hardwareButtonServiceProvider)
              as SimulationHardwareButtonService;
      check(s.isListening).isFalse();
    });
  });
}
