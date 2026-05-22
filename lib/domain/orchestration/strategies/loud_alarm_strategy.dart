import 'dart:developer';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Strategy for [ChainStepType.loudAlarm] steps.
///
/// Fires the alarm sound via [AudioServiceProtocol.playAlarmWithConfig],
/// always fires the alarm vibration pattern, and optionally starts camera
/// flash and/or screen flash based on [LoudAlarmConfig].
///
/// **Gradual volume ramp:** The linear volume ramp (spec 02 §8 loudAlarm
/// §Gradual Volume Increase) is handled at the service level by
/// [AudioService], not in this strategy. The ramp fires only when BOTH
/// `AppSettings.alarmGradualVolume` and `LoudAlarmConfig.gradualVolume`
/// are `true`. The strategy passes the config to the service; the service
/// decides whether to ramp.
///
/// Simulation: muted. Strategy logs `sim_blocked` and returns.
/// The UI / notification layer (Phase 6) shows the `[SIM]` card:
/// "Alarm would have sounded at full volume".
///
/// See spec 02 §8 loudAlarm.
final class LoudAlarmStrategy implements EventStrategy {
  /// Creates a [LoudAlarmStrategy].
  const LoudAlarmStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) async {
    if (services.isSimulation) {
      log('loudAlarm blocked in simulation', name: 'sim_blocked');
      return;
    }

    final config = step.config is LoudAlarmConfig
        ? step.config! as LoudAlarmConfig
        : const LoudAlarmConfig();

    // Vibration: always fires the alarm pattern (overrides silent mode).
    await services.vibration.alarmPattern();

    // Audio: pass sound choice and volume to the service.
    await services.audio.playAlarmWithConfig(
      soundChoice: config.soundChoice.name,
      volume: config.volume,
    );

    // Optional camera flash: SOS morse pattern.
    if (config.flashLight) {
      await services.flash.startSosFlash();
    }

    // Optional screen flash: white/red alternating strobe.
    if (config.flashScreen) {
      // Derive speed string from flashSpeedMs:
      //   ≥ 1000 ms cycle → 'slow' (photosensitivity-safe default).
      //   < 1000 ms cycle → 'fast' (more attention-grabbing).
      final speed = config.flashSpeedMs >= 1000 ? 'slow' : 'fast';
      await services.screenFlash.startScreenFlash(speed: speed);
    }
  }

  /// Returns the simulation card text.
  ///
  /// Spec 02 §Simulation behavior summary: "Muted: Loud alarm (silent with
  /// notification indicator showing 'Alarm would have sounded at full
  /// volume')."
  @override
  String? simulationDescription(ChainStep step, EventServices services) =>
      'Alarm would have sounded at full volume';
}
