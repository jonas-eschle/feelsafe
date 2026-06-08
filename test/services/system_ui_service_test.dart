import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/enums/stealth_icon_preset.dart';
import 'package:guardianangela/services/protocols/system_ui_service_protocol.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/system_ui_service_sim.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SimulationSystemUiService _sim() => SimulationSystemUiService();

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // SimulationSystemUiService — construction
  // =========================================================================

  group('SimulationSystemUiService', () {
    late SimulationSystemUiService s;

    setUp(() => s = _sim());
    tearDown(() => s.reset());

    group('constructor', () {
      test('implements SystemUiServiceProtocol', () {
        check(s).isA<SystemUiServiceProtocol>();
      });

      test('calls list is empty initially', () {
        check(s.calls).isEmpty();
      });
    });

    // =========================================================================
    // setStealthIcon
    // =========================================================================

    group('setStealthIcon', () {
      test('records a StealthIconCall with the music preset', () async {
        await s.setStealthIcon(StealthIconPreset.music);

        check(s.calls).length.equals(1);
        final call = s.calls.first;
        check(call).isA<StealthIconCall>();
        check((call as StealthIconCall).preset).equals(StealthIconPreset.music);
      });

      test('records a StealthIconCall with the none preset', () async {
        await s.setStealthIcon(StealthIconPreset.none);

        check(s.calls).length.equals(1);
        final call = s.calls.first;
        check(call).isA<StealthIconCall>();
        check((call as StealthIconCall).preset).equals(StealthIconPreset.none);
      });

      test('multiple calls are all recorded', () async {
        await s.setStealthIcon(StealthIconPreset.music);
        await s.setStealthIcon(StealthIconPreset.calendar);
        await s.setStealthIcon(StealthIconPreset.none);

        check(s.calls).length.equals(3);
        check(s.calls[0]).isA<StealthIconCall>();
        check(s.calls[1]).isA<StealthIconCall>();
        check(s.calls[2]).isA<StealthIconCall>();
      });

      test('preset values preserved in order', () async {
        await s.setStealthIcon(StealthIconPreset.fitness);
        await s.setStealthIcon(StealthIconPreset.podcast);

        check(
          (s.calls[0] as StealthIconCall).preset,
        ).equals(StealthIconPreset.fitness);
        check(
          (s.calls[1] as StealthIconCall).preset,
        ).equals(StealthIconPreset.podcast);
      });
    });

    // =========================================================================
    // toggleLockTaskMode
    // =========================================================================

    group('toggleLockTaskMode', () {
      test('records a LockTaskCall with enabled=true', () async {
        await s.toggleLockTaskMode(true);

        check(s.calls).length.equals(1);
        final call = s.calls.first;
        check(call).isA<LockTaskCall>();
        check((call as LockTaskCall).enabled).isTrue();
      });

      test('records a LockTaskCall with enabled=false', () async {
        await s.toggleLockTaskMode(false);

        check(s.calls).length.equals(1);
        final call = s.calls.first;
        check(call).isA<LockTaskCall>();
        check((call as LockTaskCall).enabled).isFalse();
      });

      test('multiple calls are all recorded', () async {
        await s.toggleLockTaskMode(true);
        await s.toggleLockTaskMode(false);

        check(s.calls).length.equals(2);
        check(s.calls[0]).isA<LockTaskCall>();
        check(s.calls[1]).isA<LockTaskCall>();
      });

      test('enabled values preserved in order', () async {
        await s.toggleLockTaskMode(true);
        await s.toggleLockTaskMode(false);

        check((s.calls[0] as LockTaskCall).enabled).isTrue();
        check((s.calls[1] as LockTaskCall).enabled).isFalse();
      });
    });

    // =========================================================================
    // Mixed calls
    // =========================================================================

    group('mixed calls', () {
      test('stealth icon and lock task recorded together in order', () async {
        await s.setStealthIcon(StealthIconPreset.music);
        await s.toggleLockTaskMode(true);
        await s.setStealthIcon(StealthIconPreset.none);

        check(s.calls).length.equals(3);
        check(s.calls[0]).isA<StealthIconCall>();
        check(s.calls[1]).isA<LockTaskCall>();
        check(s.calls[2]).isA<StealthIconCall>();
      });

      test('can distinguish call types via sealed switch', () async {
        await s.setStealthIcon(StealthIconPreset.music);
        await s.toggleLockTaskMode(false);

        final types = s.calls.map((c) {
          return switch (c) {
            StealthIconCall() => 'stealth',
            LockTaskCall() => 'lockTask',
          };
        }).toList();

        check(types).deepEquals(['stealth', 'lockTask']);
      });
    });

    // =========================================================================
    // reset
    // =========================================================================

    group('reset', () {
      test('clears the call log', () async {
        await s.setStealthIcon(StealthIconPreset.music);
        await s.toggleLockTaskMode(true);
        check(s.calls).length.equals(2);

        s.reset();
        check(s.calls).isEmpty();
      });

      test('safe to call on empty list', () {
        s.reset();
        check(s.calls).isEmpty();
      });

      test('subsequent calls are recorded after reset', () async {
        await s.setStealthIcon(StealthIconPreset.music);
        s.reset();
        await s.toggleLockTaskMode(false);

        check(s.calls).length.equals(1);
        final call = s.calls.first;
        check(call).isA<LockTaskCall>();
        check((call as LockTaskCall).enabled).isFalse();
      });
    });

    // =========================================================================
    // calls list is unmodifiable
    // =========================================================================

    group('calls list', () {
      test('is unmodifiable', () async {
        await s.setStealthIcon(StealthIconPreset.music);
        check(
          () => s.calls.add(
            const StealthIconCall(preset: StealthIconPreset.none),
          ),
        ).throws<UnsupportedError>();
      });
    });
  });

  // =========================================================================
  // Simulation swap (Riverpod)
  // =========================================================================

  group('Simulation swap — SystemUiService', () {
    late ProviderContainer container;
    late SimulationSystemUiService sim;

    setUp(() {
      sim = _sim();
      container = ProviderContainer(
        overrides: [systemUiServiceProvider.overrideWithValue(sim)],
      );
    });

    tearDown(() {
      container.dispose();
      sim.reset();
    });

    test('overridden container returns SimulationSystemUiService', () {
      final s = container.read(systemUiServiceProvider);
      check(s).isA<SimulationSystemUiService>();
    });

    test('simulation is not RealSystemUiService', () {
      final s = container.read(systemUiServiceProvider);
      check(
        s.runtimeType.toString(),
      ).not((c) => c.equals('RealSystemUiService'));
    });

    test('can record calls via container-resolved service', () async {
      final s =
          container.read(systemUiServiceProvider) as SimulationSystemUiService;
      await s.setStealthIcon(StealthIconPreset.music);

      check(s.calls).length.equals(1);
      check(s.calls.first).isA<StealthIconCall>();
    });
  });

  // =========================================================================
  // SystemUiCall sealed hierarchy
  // =========================================================================

  group('SystemUiCall sealed hierarchy', () {
    test('StealthIconCall.preset is preserved', () {
      const call = StealthIconCall(preset: StealthIconPreset.calendar);
      check(call.preset).equals(StealthIconPreset.calendar);
    });

    test('LockTaskCall.enabled is preserved', () {
      const call = LockTaskCall(enabled: false);
      check(call.enabled).isFalse();
    });

    test('StealthIconCall and LockTaskCall are distinct types', () {
      const a = StealthIconCall(preset: StealthIconPreset.music);
      const b = LockTaskCall(enabled: true);
      check(a.runtimeType).not((c) => c.equals(b.runtimeType));
    });

    test(
      'factory constructor SystemUiCall.stealthIcon creates StealthIconCall',
      () {
        const call = SystemUiCall.stealthIcon(preset: StealthIconPreset.music);
        check(call).isA<StealthIconCall>();
      },
    );

    test('factory constructor SystemUiCall.lockTask creates LockTaskCall', () {
      const call = SystemUiCall.lockTask(enabled: false);
      check(call).isA<LockTaskCall>();
    });
  });
}
