import 'dart:developer';

import 'package:vibration/vibration.dart';

import 'package:guardianangela/services/protocols/vibration_service_protocol.dart';

/// Production [VibrationServiceProtocol] backed by `package:vibration`.
///
/// All patterns respect the device's silent/vibrate settings with one
/// exception: [alarmPattern] ALWAYS vibrates even in silent mode (spec 05
/// §VibrationService §Ringer Mode Respect).
///
/// If the device has no vibrator (e.g., some tablets or simulators), all
/// pattern methods silently become no-ops per spec 05 §Hardware Support.
///
/// **Single constructor location rule:** no `RealVibrationService()`
/// call may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces).
class RealVibrationService implements VibrationServiceProtocol {
  /// Creates a [RealVibrationService].
  ///
  /// [overrideHasVibrator] — when non-null, replaces the [Vibration.hasVibrator]
  /// call with the given value. Use `true` in tests to bypass the platform guard
  /// so the vibration MethodChannel mock receives pattern/duration arguments.
  RealVibrationService({bool? overrideHasVibrator})
    : _overrideHasVibrator = overrideHasVibrator;

  final bool? _overrideHasVibrator;

  @override
  Future<void> warningPattern({bool isSimulation = false}) async {
    log(
      isSimulation
          ? '[SIM] warningPattern — vibration fires normally in simulation'
          : 'warningPattern — three-pulse countdown',
      name: 'VibrationService',
    );
    // Three quick pulses: 200ms on, 100ms gap, 200ms on, 100ms gap, 200ms on.
    // Pattern: [delay, on, off, on, off, on] where delay is 0.
    if (!await _hasVibrator()) return;
    await Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 200]);
  }

  @override
  Future<void> confirmPulse() async {
    log('confirmPulse — single 100ms pulse', name: 'VibrationService');
    if (!await _hasVibrator()) return;
    await Vibration.vibrate(duration: 100);
  }

  @override
  Future<void> alarmPattern({bool isSimulation = false}) async {
    log(
      isSimulation
          ? '[SIM] alarmPattern — vibration fires normally in simulation'
          : 'alarmPattern — sustained four-pulse alarm',
      name: 'VibrationService',
    );
    // Four sustained pulses: 500ms on, 200ms gap (repeats 4 times).
    // Pattern: [delay, on, off, on, off, on, off, on] — 4 pulses.
    if (!await _hasVibrator()) return;
    await Vibration.vibrate(pattern: [0, 500, 200, 500, 200, 500, 200, 500]);
  }

  @override
  Future<void> fakeCallPattern() async {
    log(
      'fakeCallPattern — realistic incoming call vibration',
      name: 'VibrationService',
    );
    // Realistic phone-call pattern: 1000ms on, 500ms off (repeating).
    // Two cycles match the typical device incoming-call feel.
    if (!await _hasVibrator()) return;
    await Vibration.vibrate(pattern: [0, 1000, 500, 1000, 500]);
  }

  @override
  Future<void> reminderPattern() async {
    log(
      'reminderPattern — single short notification pulse',
      name: 'VibrationService',
    );
    // Single 200ms pulse imitating a typical notification vibration.
    if (!await _hasVibrator()) return;
    await Vibration.vibrate(duration: 200);
  }

  @override
  Future<void> cancel() async {
    log('cancel — stopping all vibration', name: 'VibrationService');
    await Vibration.cancel();
  }

  Future<bool> _hasVibrator() async =>
      _overrideHasVibrator ?? await Vibration.hasVibrator();
}
