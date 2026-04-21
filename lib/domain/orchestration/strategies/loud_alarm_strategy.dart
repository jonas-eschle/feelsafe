/// `LoudAlarmStrategy` — strategy for `ChainStepType.loudAlarm`.
///
/// Plays the loud alarm tone (optionally forcing max system volume)
/// and the high-intensity alarm vibration pattern. Screen-flashing
/// is UI-driven and rendered in `SessionScreen`; this strategy does
/// not reach the display layer from pure-Dart code.
library;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Strategy for loud-alarm steps.
final class LoudAlarmStrategy extends EventStrategy {
  /// Const constructor.
  const LoudAlarmStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) async {
    final config = _resolveConfig(step, services);
    final isSim = services.context.isSimulation;
    await services.audio.playAlarm(
      maxVolume: config.maxVolume,
      isSimulation: isSim,
    );
    await services.vibration.alarmPattern(isSimulation: isSim);
    // Screen flashing is deliberately a UI concern — no service call
    // here. The config's `flashScreen` flag is surfaced in the sim
    // description so users can still observe the decision.
  }

  @override
  String simulationDescription(ChainStep step, EventServices services) {
    final config = _resolveConfig(step, services);
    final tail = config.flashScreen ? 'flash' : 'vibrate';
    return '[SIM] Loud alarm + $tail';
  }

  /// Resolves the step config.
  ///
  /// Fix for bugs.json Warn (strategies never fall back to
  /// EventDefaults): prefer step.config, then session eventDefaults,
  /// then the local const fallback.
  LoudAlarmConfig _resolveConfig(ChainStep step, EventServices services) {
    final raw = step.config;
    if (raw is LoudAlarmConfig) return raw;
    try {
      final fromDefaults = services.context.configFor(step);
      if (fromDefaults is LoudAlarmConfig) return fromDefaults;
    } on StateError {
      // No eventDefaults — fall through.
    }
    return const LoudAlarmConfig();
  }
}
