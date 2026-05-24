// ignore_for_file: avoid_relative_lib_imports
import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/services/protocols/vibration_service_protocol.dart';
import 'package:guardianangela/services/sim/vibration_service_sim.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SimulationVibrationService _sim() => SimulationVibrationService();

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -----------------------------------------------------------------------
  // SimulationVibrationService — complete coverage
  // -----------------------------------------------------------------------
  group('SimulationVibrationService', () {
    group('constructor', () {
      test('implements VibrationServiceProtocol', () {
        check(_sim()).isA<VibrationServiceProtocol>();
      });

      test('starts with empty calls list', () {
        check(_sim().calls).isEmpty();
      });

      test('wasCancelled is false initially', () {
        check(_sim().wasCancelled).isFalse();
      });
    });

    group('warningPattern', () {
      test('records call tag', () async {
        final s = _sim();
        await s.warningPattern();
        check(s.calls).deepEquals(['warningPattern']);
      });

      test('records call tag when isSimulation=true', () async {
        final s = _sim();
        await s.warningPattern(isSimulation: true);
        check(s.calls).deepEquals(['warningPattern']);
      });

      test('multiple calls accumulate in order', () async {
        final s = _sim();
        await s.warningPattern();
        await s.warningPattern();
        check(s.calls).deepEquals(['warningPattern', 'warningPattern']);
      });
    });

    group('alarmPattern', () {
      test('records call tag', () async {
        final s = _sim();
        await s.alarmPattern();
        check(s.calls).deepEquals(['alarmPattern']);
      });

      test('records call tag when isSimulation=true', () async {
        final s = _sim();
        await s.alarmPattern(isSimulation: true);
        check(s.calls).deepEquals(['alarmPattern']);
      });

      test('accumulates after warningPattern', () async {
        final s = _sim();
        await s.warningPattern();
        await s.alarmPattern();
        check(s.calls).deepEquals(['warningPattern', 'alarmPattern']);
      });
    });

    group('cancel', () {
      test('records cancel tag', () async {
        final s = _sim();
        await s.cancel();
        check(s.calls).deepEquals(['cancel']);
      });

      test('wasCancelled becomes true after cancel', () async {
        final s = _sim();
        await s.cancel();
        check(s.wasCancelled).isTrue();
      });

      test('cancel after pattern recorded in order', () async {
        final s = _sim();
        await s.warningPattern();
        await s.cancel();
        check(s.calls).deepEquals(['warningPattern', 'cancel']);
      });

      test('multiple cancel calls each appear in calls list', () async {
        final s = _sim();
        await s.cancel();
        await s.cancel();
        check(s.calls.where((e) => e == 'cancel').length).equals(2);
      });
    });

    group('reset', () {
      test('clears calls list', () async {
        final s = _sim();
        await s.warningPattern();
        await s.alarmPattern();
        s.reset();
        check(s.calls).isEmpty();
      });

      test('wasCancelled is false after reset', () async {
        final s = _sim();
        await s.cancel();
        s.reset();
        check(s.wasCancelled).isFalse();
      });

      test('calls can be recorded again after reset', () async {
        final s = _sim();
        await s.cancel();
        s.reset();
        await s.warningPattern();
        check(s.calls).deepEquals(['warningPattern']);
      });
    });

    group('sequence recording', () {
      test('full pattern sequence recorded correctly', () async {
        final s = _sim();
        await s.warningPattern();
        await s.alarmPattern();
        await s.warningPattern();
        await s.cancel();
        check(
          s.calls,
        ).deepEquals(['warningPattern', 'alarmPattern', 'warningPattern', 'cancel']);
      });

      test('isSimulation flag does not change recorded tag', () async {
        final s = _sim();
        await s.warningPattern(isSimulation: true);
        await s.alarmPattern();
        check(s.calls).deepEquals(['warningPattern', 'alarmPattern']);
      });
    });

    group('call counts', () {
      test('five warning calls recorded', () async {
        final s = _sim();
        for (var i = 0; i < 5; i++) {
          await s.warningPattern();
        }
        check(s.calls.length).equals(5);
        check(s.calls.every((c) => c == 'warningPattern')).isTrue();
      });
    });
  });
}
