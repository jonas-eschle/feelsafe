/// Covers the `hasVibrator()==true` branch of every method in
/// `VibrationService`.
///
/// On a Linux test host, `Vibration.hasVibrator()` always returns
/// `false` (the plugin's default implementation short-circuits on
/// `Platform.isAndroid == false`). To reach the inner
/// `Vibration.vibrate(...)` / `Vibration.cancel()` calls that would
/// otherwise show as uncovered, we swap in a test-double
/// `VibrationPlatform` that reports `hasVibrator: true` and records
/// every call.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:vibration_platform_interface/vibration_platform_interface.dart';

import 'package:guardianangela/services/implementations/vibration_service.dart';

/// Records every call routed through `Vibration.*` static methods.
final class _FakeVibrationPlatform extends VibrationPlatform {
  final List<String> calls = [];

  @override
  Future<bool> hasVibrator() async {
    calls.add('hasVibrator');
    return true;
  }

  @override
  Future<void> vibrate({
    int duration = 500,
    List<int> pattern = const [],
    int repeat = -1,
    List<int> intensities = const [],
    int amplitude = -1,
    double sharpness = 0.5,
  }) async {
    calls.add('vibrate:pattern=${pattern.join("/")},repeat=$repeat');
  }

  @override
  Future<void> cancel() async {
    calls.add('cancel');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeVibrationPlatform fake;
  late VibrationPlatform original;

  setUp(() {
    original = VibrationPlatform.instance;
    fake = _FakeVibrationPlatform();
    VibrationPlatform.instance = fake;
  });

  tearDown(() {
    VibrationPlatform.instance = original;
  });

  group('VibrationService hasVibrator=true branch', () {
    test(
      'alarmPattern invokes Vibration.vibrate with the alarm pattern',
      () async {
        final s = VibrationService();
        await s.alarmPattern();
        check(fake.calls).contains('hasVibrator');
        check(fake.calls.any((c) => c.startsWith('vibrate:pattern='))).isTrue();
        // repeat=0 for the alarm pattern (loops).
        check(fake.calls.any((c) => c.contains('repeat=0'))).isTrue();
      },
    );

    test('warningPattern invokes Vibration.vibrate without repeat', () async {
      final s = VibrationService();
      await s.warningPattern();
      check(fake.calls.any((c) => c.contains('repeat=-1'))).isTrue();
    });

    test('fakeCallPattern invokes Vibration.vibrate with repeat=0', () async {
      final s = VibrationService();
      await s.fakeCallPattern();
      check(fake.calls.any((c) => c.contains('repeat=0'))).isTrue();
    });

    test('stop invokes Vibration.cancel directly', () async {
      final s = VibrationService();
      await s.stop();
      check(fake.calls).contains('cancel');
    });
  });
}
