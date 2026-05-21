/// `LoudAlarmStrategy` — strategy for `ChainStepType.loudAlarm`.
///
/// Plays the loud alarm tone (optionally forcing max system volume)
/// and the high-intensity alarm vibration pattern. When configured
/// (`flashLight = true`) the strategy also strobes the camera LED
/// via the injected [FlashServiceProtocol] (audit Q2 extraction).
/// Screen-flashing remains UI-driven and is rendered in
/// `SessionScreen` — this strategy does not reach the display layer
/// from pure-Dart code.
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
      gradualVolumeRamp: services.context.alarmGradualVolumeRamp,
    );
    await services.vibration.alarmPattern(isSimulation: isSim);
    // Camera-LED strobe — Q2 extraction. The flash service is
    // optional on EventServices so older test wirings still work;
    // when missing we skip the leg silently. The simulation flash
    // service is a no-op so an isSimulation guard here would be
    // redundant.
    final flash = services.flash;
    if (flash != null && config.flashLight) {
      await flash.startStrobe(
        interval: Duration(milliseconds: config.flashSpeedMs),
      );
    }
    // Screen flashing is deliberately a UI concern — no service call
    // here. The config's `flashScreen` flag is surfaced in the sim
    // description so users can still observe the decision.
  }

  @override
  SimulationDescription simulationDescription(
    ChainStep step,
    EventServices services,
  ) {
    final config = _resolveConfig(step, services);
    return SimulationDescription('simLoudAlarm', {'flash': config.flashScreen});
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
