import 'dart:developer';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Default asset path for the countdown warning sound.
const _kCountdownWarningSoundAsset = 'assets/audio/countdown_warning.ogg';

/// Strategy for [ChainStepType.countdownWarning] steps.
///
/// Real mode: fires [VibrationServiceProtocol.warningPattern] and optionally
/// [AudioServiceProtocol.playSound] based on [CountdownWarningConfig].
///
/// Simulation: the actual countdown UI and vibration fire normally
/// (local-only action per spec 02 §Simulation behavior summary). No `[SIM]`
/// card substitution. This strategy returns `null` from
/// [simulationDescription].
///
/// See spec 02 §4 countdownWarning.
final class CountdownWarningStrategy implements EventStrategy {
  /// Creates a [CountdownWarningStrategy].
  const CountdownWarningStrategy();

  /// Fires vibration and optional audio for the countdown warning.
  ///
  /// Short-circuits when [services.isSimulation] is `true` (Layer 2
  /// defense). Note: the actual countdown UI and vibration fire normally
  /// even in simulation — this guard only prevents the service call path
  /// from being exercised unexpectedly if the layer-1 engine guard fails.
  @override
  Future<void> executeReal(ChainStep step, EventServices services) async {
    if (services.isSimulation) {
      log('countdownWarning blocked in simulation', name: 'sim_blocked');
      return;
    }

    final config = step.config is CountdownWarningConfig
        ? step.config! as CountdownWarningConfig
        : const CountdownWarningConfig();

    if (config.vibrate) {
      await services.vibration.warningPattern();
    }

    if (config.sound) {
      await services.audio.playSound(_kCountdownWarningSoundAsset);
    }
  }

  /// Returns `null` — the actual countdown UI and vibration fire normally
  /// in simulation (identical to real mode); no `[SIM]` toast is needed.
  ///
  /// See spec 02 §4 countdownWarning "Simulation: Actual countdown UI
  /// fires — identical to real mode. No toast substitution."
  @override
  String? simulationDescription(ChainStep step, EventServices services) => null;
}
