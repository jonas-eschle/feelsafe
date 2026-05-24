import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/services/protocols/wakelock_service_protocol.dart';
import 'package:guardianangela/services/sim/wakelock_service_sim.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SimulationWakelockService _sim({bool initialEnabled = false}) =>
    SimulationWakelockService(initialEnabled: initialEnabled);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SimulationWakelockService', () {
    group('constructor', () {
      test('implements WakelockServiceProtocol', () {
        check(_sim()).isA<WakelockServiceProtocol>();
      });

      test('isEnabled defaults to false', () {
        check(_sim().isEnabled).isFalse();
      });

      test('isEnabled can be initialised to true', () {
        check(_sim(initialEnabled: true).isEnabled).isTrue();
      });

      test('calls list starts empty', () {
        check(_sim().calls).isEmpty();
      });
    });

    group('enable', () {
      test('sets isEnabled to true', () async {
        final s = _sim();
        await s.enable();
        check(s.isEnabled).isTrue();
      });

      test('records enable call', () async {
        final s = _sim();
        await s.enable();
        check(s.calls).deepEquals(['enable']);
      });

      test('multiple enables each recorded', () async {
        final s = _sim();
        await s.enable();
        await s.enable();
        check(s.calls).deepEquals(['enable', 'enable']);
        check(s.isEnabled).isTrue();
      });
    });

    group('disable', () {
      test('sets isEnabled to false', () async {
        final s = _sim(initialEnabled: true);
        await s.disable();
        check(s.isEnabled).isFalse();
      });

      test('records disable call', () async {
        final s = _sim();
        await s.disable();
        check(s.calls).deepEquals(['disable']);
      });

      test('disable after enable sets isEnabled false', () async {
        final s = _sim();
        await s.enable();
        await s.disable();
        check(s.isEnabled).isFalse();
      });

      test('enable → disable → enable: isEnabled ends true', () async {
        final s = _sim();
        await s.enable();
        await s.disable();
        await s.enable();
        check(s.isEnabled).isTrue();
        check(s.calls).deepEquals(['enable', 'disable', 'enable']);
      });
    });

    group('reset', () {
      test('clears calls list', () async {
        final s = _sim();
        await s.enable();
        await s.disable();
        s.reset();
        check(s.calls).isEmpty();
      });

      test('reset restores isEnabled to false by default', () async {
        final s = _sim(initialEnabled: true);
        await s.disable();
        s.reset();
        check(s.isEnabled).isFalse();
      });

      test('reset can restore isEnabled to true', () async {
        final s = _sim();
        await s.enable();
        s.reset(initialEnabled: true);
        check(s.isEnabled).isTrue();
        check(s.calls).isEmpty();
      });
    });

    group('state toggle', () {
      test('isEnabled tracks enable/disable sequence', () async {
        final s = _sim();
        check(s.isEnabled).isFalse();
        await s.enable();
        check(s.isEnabled).isTrue();
        await s.disable();
        check(s.isEnabled).isFalse();
      });

      test('five enable calls all recorded', () async {
        final s = _sim();
        for (var i = 0; i < 5; i++) {
          await s.enable();
        }
        check(s.calls.length).equals(5);
        check(s.calls.every((c) => c == 'enable')).isTrue();
      });
    });
  });
}
