import 'package:vibration/vibration.dart';

class VibrationService {
  /// Short warning pattern: three quick pulses.
  Future<void> warningPattern() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (!hasVibrator) return;

    // Pattern: vibrate 200ms, pause 100ms, vibrate 200ms, pause 100ms, vibrate 200ms
    await Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 200]);
  }

  /// Single short pulse for check-in confirmation feedback.
  Future<void> confirmPulse() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (!hasVibrator) return;

    await Vibration.vibrate(duration: 100);
  }

  /// Urgent continuous vibration for alarm state.
  Future<void> alarmPattern() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (!hasVibrator) return;

    await Vibration.vibrate(
      pattern: [0, 500, 200, 500, 200, 500, 200, 500],
    );
  }

  Future<void> cancel() async {
    await Vibration.cancel();
  }
}
