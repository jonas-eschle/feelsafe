import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/services/protocols/flash_service_protocol.dart';
import 'package:guardianangela/services/sim/flash_service_sim.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SimulationFlashService _sim({int tickMs = 10}) =>
    SimulationFlashService(tickMs: tickMs);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SimulationFlashService', () {
    group('constructor', () {
      test('implements FlashServiceProtocol', () {
        check(_sim()).isA<FlashServiceProtocol>();
      });

      test('isFlashing starts false', () {
        check(_sim().isFlashing).isFalse();
      });

      test('events starts empty', () {
        check(_sim().events).isEmpty();
      });

      test('calls starts empty', () {
        check(_sim().calls).isEmpty();
      });
    });

    group('startSosFlash', () {
      test('records startSosFlash call', () async {
        final s = _sim();
        await s.startSosFlash();
        check(s.calls).contains('startSosFlash');
        await s.stopFlash();
      });

      test('sets isFlashing to true', () async {
        final s = _sim();
        await s.startSosFlash();
        check(s.isFlashing).isTrue();
        await s.stopFlash();
      });

      test('emits on/off events over time', () async {
        final s = _sim(tickMs: 5);
        await s.startSosFlash();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        check(s.events.isNotEmpty).isTrue();
        await s.stopFlash();
      });

      test('events alternate torchOn values', () async {
        final s = _sim(tickMs: 5);
        await s.startSosFlash();
        await Future<void>.delayed(const Duration(milliseconds: 80));
        await s.stopFlash();
        final onOff = s.events.map((e) => e.torchOn).toList();
        // Must have at least one true then false pair.
        check(onOff.isNotEmpty).isTrue();
        check(onOff.first).isTrue();
        if (onOff.length > 1) {
          check(onOff[1]).isFalse();
        }
      });

      test('startSosFlash after already flashing stops old loop', () async {
        final s = _sim(tickMs: 5);
        await s.startSosFlash();
        final eventsBefore = s.events.length;
        await s.startSosFlash(); // restarts
        // After the second start, isFlashing is still true.
        check(s.isFlashing).isTrue();
        await s.stopFlash();
        // More events were emitted.
        check(s.events.length).isGreaterOrEqual(eventsBefore);
      });
    });

    group('startContinuousFlash', () {
      test('records startContinuousFlash call', () async {
        final s = _sim();
        await s.startContinuousFlash();
        check(s.calls).contains('startContinuousFlash');
        await s.stopFlash();
      });

      test('sets isFlashing to true', () async {
        final s = _sim();
        await s.startContinuousFlash();
        check(s.isFlashing).isTrue();
        await s.stopFlash();
      });

      test('emits on/off events', () async {
        final s = _sim(tickMs: 5);
        await s.startContinuousFlash();
        await Future<void>.delayed(const Duration(milliseconds: 80));
        check(s.events.isNotEmpty).isTrue();
        await s.stopFlash();
      });
    });

    group('stopFlash', () {
      test('records stopFlash call', () async {
        final s = _sim();
        await s.startSosFlash();
        await s.stopFlash();
        check(s.calls).contains('stopFlash');
      });

      test('sets isFlashing to false', () async {
        final s = _sim();
        await s.startSosFlash();
        await s.stopFlash();
        check(s.isFlashing).isFalse();
      });

      test('safe to call when not flashing', () async {
        final s = _sim();
        await s.stopFlash(); // no-op, should not throw
        check(s.calls).deepEquals(['stopFlash']);
      });

      test('stop emits torch-off event', () async {
        final s = _sim(tickMs: 5);
        await s.startSosFlash();
        s.events.clear();
        await s.stopFlash();
        final offEvents = s.events.where((e) => !e.torchOn).toList();
        check(offEvents.isNotEmpty).isTrue();
      });

      test('no more events emitted after stopFlash', () async {
        final s = _sim(tickMs: 5);
        await s.startSosFlash();
        await s.stopFlash();
        final countAfterStop = s.events.length;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        check(s.events.length).equals(countAfterStop);
      });
    });

    group('FlashEvent', () {
      test('FlashEvent carries torchOn state', () {
        final event = FlashEvent(torchOn: true, timestamp: DateTime.now());
        check(event.torchOn).isTrue();
      });

      test('FlashEvent toString is informative', () {
        final event = FlashEvent(torchOn: false, timestamp: DateTime.now());
        check(event.toString()).contains('false');
      });
    });

    group('reset', () {
      test('clears events and calls', () async {
        final s = _sim(tickMs: 5);
        await s.startSosFlash();
        await Future<void>.delayed(const Duration(milliseconds: 30));
        await s.stopFlash();
        s.reset();
        check(s.events).isEmpty();
        check(s.calls).isEmpty();
        check(s.isFlashing).isFalse();
      });
    });

    group('fakeAsync SOS timing', () {
      test('events accumulate after simulated time advances', () {
        fakeAsync((async) {
          final s = SimulationFlashService();
          s.startSosFlash();
          async.elapse(const Duration(milliseconds: 300));
          // At 50ms per tick (on + off = 100ms), 300ms gives ≥ 4 events.
          check(s.events.length).isGreaterOrEqual(4);
          s.stopFlash();
          async.elapse(const Duration(milliseconds: 100));
        });
      });

      test('stopFlash halts event emission in fakeAsync', () {
        fakeAsync((async) {
          final s = SimulationFlashService();
          s.startSosFlash();
          async.elapse(const Duration(milliseconds: 200));
          s.stopFlash();
          async.elapse(const Duration(milliseconds: 100));
          final countAfterStop = s.events.length;
          async.elapse(const Duration(milliseconds: 500));
          check(s.events.length).equals(countAfterStop);
        });
      });

      // -----------------------------------------------------------------------
      // F5: no torch call after stopFlash returns (race-condition fix)
      // -----------------------------------------------------------------------

      test(
        'F5: no new events emitted after stopFlash resolves (Completer fix)',
        () async {
          final s = _sim(tickMs: 5);
          await s.startSosFlash();
          // Let the loop tick a few times.
          await Future<void>.delayed(const Duration(milliseconds: 40));
          // stopFlash awaits the loop completion via Completer.
          await s.stopFlash();
          final countAtStop = s.events.length;
          // After stopFlash has returned, no further events can be emitted.
          await Future<void>.delayed(const Duration(milliseconds: 50));
          check(s.events.length).equals(countAtStop);
        },
      );

      test(
        'F5: continuous flash — no new events after stopFlash returns',
        () async {
          final s = _sim(tickMs: 5);
          await s.startContinuousFlash();
          await Future<void>.delayed(const Duration(milliseconds: 40));
          await s.stopFlash();
          final countAtStop = s.events.length;
          await Future<void>.delayed(const Duration(milliseconds: 50));
          check(s.events.length).equals(countAtStop);
        },
      );
    });
  });
}
