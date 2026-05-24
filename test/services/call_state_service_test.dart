import 'dart:async';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/enums/call_state.dart';
import 'package:guardianangela/services/protocols/call_state_service_protocol.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/call_state_service_sim.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SimulationCallStateService _sim() => SimulationCallStateService();

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // SimulationCallStateService — construction
  // =========================================================================

  group('SimulationCallStateService', () {
    late SimulationCallStateService s;

    setUp(() => s = _sim());
    tearDown(() => s.dispose());

    group('constructor', () {
      test('implements CallStateServiceProtocol', () {
        check(s).isA<CallStateServiceProtocol>();
      });

      test('isStarted is false initially', () {
        check(s.isStarted).isFalse();
      });

      test('callState is a broadcast stream', () {
        final sub1 = s.callState.listen((_) {});
        final sub2 = s.callState.listen((_) {});
        addTearDown(sub1.cancel);
        addTearDown(sub2.cancel);
        check(true).isTrue(); // no exception = broadcast
      });
    });

    // =========================================================================
    // start / stop
    // =========================================================================

    group('start', () {
      test('sets isStarted true', () async {
        await s.start();
        check(s.isStarted).isTrue();
      });

      test('calling start twice is safe', () async {
        await s.start();
        await s.start();
        check(s.isStarted).isTrue();
      });
    });

    group('stop', () {
      test('sets isStarted false', () async {
        await s.start();
        await s.stop();
        check(s.isStarted).isFalse();
      });

      test('safe to call before start', () async {
        await s.stop();
        check(s.isStarted).isFalse();
      });
    });

    // =========================================================================
    // setState — stream injection
    // =========================================================================

    group('setState', () {
      test('emits ringing after start', () async {
        await s.start();
        final events = <CallState>[];
        final sub = s.callState.listen(events.add);
        addTearDown(sub.cancel);

        s.setState(CallState.ringing);
        await Future<void>.delayed(Duration.zero);

        check(events).length.equals(1);
        check(events.first).equals(CallState.ringing);
      });

      test('emits offhook after start', () async {
        await s.start();
        final events = <CallState>[];
        final sub = s.callState.listen(events.add);
        addTearDown(sub.cancel);

        s.setState(CallState.offhook);
        await Future<void>.delayed(Duration.zero);

        check(events).length.equals(1);
        check(events.first).equals(CallState.offhook);
      });

      test('emits idle after start', () async {
        await s.start();
        final events = <CallState>[];
        final sub = s.callState.listen(events.add);
        addTearDown(sub.cancel);

        s.setState(CallState.idle);
        await Future<void>.delayed(Duration.zero);

        check(events).length.equals(1);
        check(events.first).equals(CallState.idle);
      });

      test('does NOT emit before start', () async {
        final events = <CallState>[];
        final sub = s.callState.listen(events.add);
        addTearDown(sub.cancel);

        s.setState(CallState.ringing);
        await Future<void>.delayed(Duration.zero);

        check(events).isEmpty();
      });

      test('does NOT emit after stop', () async {
        await s.start();
        await s.stop();
        final events = <CallState>[];
        final sub = s.callState.listen(events.add);
        addTearDown(sub.cancel);

        s.setState(CallState.ringing);
        await Future<void>.delayed(Duration.zero);

        check(events).isEmpty();
      });

      test('emits multiple state transitions in order', () async {
        await s.start();
        final events = <CallState>[];
        final sub = s.callState.listen(events.add);
        addTearDown(sub.cancel);

        s.setState(CallState.ringing);
        s.setState(CallState.offhook);
        s.setState(CallState.idle);
        await Future<void>.delayed(Duration.zero);

        check(events).length.equals(3);
        check(events[0]).equals(CallState.ringing);
        check(events[1]).equals(CallState.offhook);
        check(events[2]).equals(CallState.idle);
      });

      test('multiple listeners all receive events', () async {
        await s.start();
        final a = <CallState>[];
        final b = <CallState>[];
        final sub1 = s.callState.listen(a.add);
        final sub2 = s.callState.listen(b.add);
        addTearDown(sub1.cancel);
        addTearDown(sub2.cancel);

        s.setState(CallState.ringing);
        await Future<void>.delayed(Duration.zero);

        check(a).length.equals(1);
        check(b).length.equals(1);
      });

      test('restart after stop resumes emission', () async {
        await s.start();
        await s.stop();
        await s.start();

        final events = <CallState>[];
        final sub = s.callState.listen(events.add);
        addTearDown(sub.cancel);

        s.setState(CallState.offhook);
        await Future<void>.delayed(Duration.zero);

        check(events).length.equals(1);
        check(events.first).equals(CallState.offhook);
      });

      test('same state emitted twice produces two events', () async {
        await s.start();
        final events = <CallState>[];
        final sub = s.callState.listen(events.add);
        addTearDown(sub.cancel);

        s.setState(CallState.idle);
        s.setState(CallState.idle);
        await Future<void>.delayed(Duration.zero);

        check(events).length.equals(2);
      });
    });

    // =========================================================================
    // dispose
    // =========================================================================

    group('dispose', () {
      test('setState after dispose is a no-op (no throw)', () async {
        await s.start();
        s.dispose();

        // Must not throw.
        s.setState(CallState.ringing);
        check(true).isTrue();
      });
    });
  });

  // =========================================================================
  // Simulation swap (Riverpod)
  // =========================================================================

  group('Simulation swap — CallStateService', () {
    late ProviderContainer container;
    late SimulationCallStateService sim;

    setUp(() {
      sim = _sim();
      container = ProviderContainer(
        overrides: [callStateServiceProvider.overrideWithValue(sim)],
      );
    });

    tearDown(() {
      container.dispose();
      sim.dispose();
    });

    test('overridden container returns SimulationCallStateService', () {
      final s = container.read(callStateServiceProvider);
      check(s).isA<SimulationCallStateService>();
    });

    test('simulation is not RealCallStateService', () {
      final s = container.read(callStateServiceProvider);
      check(
        s.runtimeType.toString(),
      ).not((c) => c.equals('RealCallStateService'));
    });

    test('simulation starts not started', () {
      final s =
          container.read(callStateServiceProvider)
              as SimulationCallStateService;
      check(s.isStarted).isFalse();
    });

    test('can start and inject via container-resolved service', () async {
      final s =
          container.read(callStateServiceProvider)
              as SimulationCallStateService;
      await s.start();

      final events = <CallState>[];
      final sub = s.callState.listen(events.add);
      addTearDown(sub.cancel);

      s.setState(CallState.ringing);
      await Future<void>.delayed(Duration.zero);

      check(events).length.equals(1);
    });
  });

  // =========================================================================
  // CallState enum
  // =========================================================================

  group('CallState enum', () {
    test('has idle value', () {
      check(CallState.idle).equals(CallState.idle);
    });

    test('has ringing value', () {
      check(CallState.ringing).equals(CallState.ringing);
    });

    test('has offhook value', () {
      check(CallState.offhook).equals(CallState.offhook);
    });

    test('all values are distinct', () {
      const values = CallState.values;
      check(values.toSet().length).equals(values.length);
    });
  });
}
