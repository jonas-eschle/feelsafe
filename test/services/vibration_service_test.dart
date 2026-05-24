// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter/services.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/protocols/vibration_service_protocol.dart';
import 'package:guardianangela/services/sim/vibration_service_sim.dart';
import 'package:guardianangela/services/vibration_service.dart';

// ---------------------------------------------------------------------------
// G11: MethodChannel mock for vibration timing pin tests
// ---------------------------------------------------------------------------

/// Captures all MethodCalls sent to the 'vibration' platform channel.
///
/// Use [register] / [unregister] in setUp/tearDown.
class _VibrationChannelMock {
  final List<MethodCall> calls = [];

  void register() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('vibration'), _handle);
  }

  void unregister() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('vibration'), null);
  }

  Future<dynamic> _handle(MethodCall call) async {
    calls.add(call);
    return null;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SimulationVibrationService _sim() => SimulationVibrationService();

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Initialize Flutter binding once so MethodChannel mocks work.
  TestWidgetsFlutterBinding.ensureInitialized();

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
        check(s.calls).deepEquals([
          'warningPattern',
          'alarmPattern',
          'warningPattern',
          'cancel',
        ]);
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

    // -------------------------------------------------------------------------
    // F2: confirmPulse, fakeCallPattern, reminderPattern
    // -------------------------------------------------------------------------

    group('confirmPulse', () {
      test('records call tag', () async {
        final s = _sim();
        await s.confirmPulse();
        check(s.calls).deepEquals(['confirmPulse']);
      });

      test('accumulates with warningPattern', () async {
        final s = _sim();
        await s.warningPattern();
        await s.confirmPulse();
        check(s.calls).deepEquals(['warningPattern', 'confirmPulse']);
      });

      test('multiple calls accumulate', () async {
        final s = _sim();
        await s.confirmPulse();
        await s.confirmPulse();
        check(s.calls).deepEquals(['confirmPulse', 'confirmPulse']);
      });
    });

    group('fakeCallPattern', () {
      test('records call tag', () async {
        final s = _sim();
        await s.fakeCallPattern();
        check(s.calls).deepEquals(['fakeCallPattern']);
      });

      test('accumulates in sequence', () async {
        final s = _sim();
        await s.confirmPulse();
        await s.fakeCallPattern();
        await s.cancel();
        check(
          s.calls,
        ).deepEquals(['confirmPulse', 'fakeCallPattern', 'cancel']);
      });
    });

    group('reminderPattern', () {
      test('records call tag', () async {
        final s = _sim();
        await s.reminderPattern();
        check(s.calls).deepEquals(['reminderPattern']);
      });

      test('accumulates with alarmPattern', () async {
        final s = _sim();
        await s.reminderPattern();
        await s.alarmPattern();
        check(s.calls).deepEquals(['reminderPattern', 'alarmPattern']);
      });
    });

    group('reset clears new patterns', () {
      test('reset after confirmPulse clears it', () async {
        final s = _sim();
        await s.confirmPulse();
        s.reset();
        check(s.calls).isEmpty();
      });

      test('reset after fakeCallPattern clears it', () async {
        final s = _sim();
        await s.fakeCallPattern();
        s.reset();
        check(s.calls).isEmpty();
      });

      test('reset after reminderPattern clears it', () async {
        final s = _sim();
        await s.reminderPattern();
        s.reset();
        check(s.calls).isEmpty();
      });
    });
  });

  // -----------------------------------------------------------------------
  // G11: RealVibrationService — timing pin tests
  //
  // Mocks the 'vibration' MethodChannel and bypasses hasVibrator() via the
  // overrideHasVibrator=true seam so the real service reaches the channel.
  // -----------------------------------------------------------------------
  group('G11: RealVibrationService — pattern timing pins', () {
    late _VibrationChannelMock vibMock;

    setUp(() {
      vibMock = _VibrationChannelMock()..register();
    });

    tearDown(() {
      vibMock.unregister();
    });

    test(
      'warningPattern sends [0,200,100,200,100,200] to vibration channel',
      () async {
        final svc = RealVibrationService(overrideHasVibrator: true);
        await svc.warningPattern();
        final vibrateCall = vibMock.calls.firstWhere(
          (c) => c.method == 'vibrate',
        );
        check(
          (vibrateCall.arguments as Map)['pattern'] as List,
        ).deepEquals([0, 200, 100, 200, 100, 200]);
      },
    );

    test('confirmPulse sends duration=100 to vibration channel', () async {
      final svc = RealVibrationService(overrideHasVibrator: true);
      await svc.confirmPulse();
      final vibrateCall = vibMock.calls.firstWhere(
        (c) => c.method == 'vibrate',
      );
      check((vibrateCall.arguments as Map)['duration']).equals(100);
    });

    test('alarmPattern sends [0,500,200,500,200,500,200,500] to vibration '
        'channel', () async {
      final svc = RealVibrationService(overrideHasVibrator: true);
      await svc.alarmPattern();
      final vibrateCall = vibMock.calls.firstWhere(
        (c) => c.method == 'vibrate',
      );
      check(
        (vibrateCall.arguments as Map)['pattern'] as List,
      ).deepEquals([0, 500, 200, 500, 200, 500, 200, 500]);
    });

    test(
      'fakeCallPattern sends [0,1000,500,1000,500] to vibration channel',
      () async {
        final svc = RealVibrationService(overrideHasVibrator: true);
        await svc.fakeCallPattern();
        final vibrateCall = vibMock.calls.firstWhere(
          (c) => c.method == 'vibrate',
        );
        check(
          (vibrateCall.arguments as Map)['pattern'] as List,
        ).deepEquals([0, 1000, 500, 1000, 500]);
      },
    );

    test('reminderPattern sends duration=200 to vibration channel', () async {
      final svc = RealVibrationService(overrideHasVibrator: true);
      await svc.reminderPattern();
      final vibrateCall = vibMock.calls.firstWhere(
        (c) => c.method == 'vibrate',
      );
      check((vibrateCall.arguments as Map)['duration']).equals(200);
    });
  });
}
