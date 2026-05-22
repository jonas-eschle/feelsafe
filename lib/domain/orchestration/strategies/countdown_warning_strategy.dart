import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Default asset path for the countdown warning sound.
const _kCountdownWarningSoundAsset = 'assets/audio/countdown_warning.ogg';

/// Strategy for [ChainStepType.countdownWarning] steps.
///
/// Fires [VibrationServiceProtocol.warningPattern] (with [isSimulation]
/// forwarded) and optionally [AudioServiceProtocol.playSound] based on
/// [CountdownWarningConfig].
///
/// **No Layer 2 sim short-circuit.** Per spec 02 §4 (lines 207-208) and
/// §Simulation Behavior Summary (lines 573-576): countdown is a local-only
/// action — vibration and audio fire identically in simulation. The services
/// receive the [EventServices.isSimulation] flag via their own parameters so
/// hardware-level muting (Layer 3/4) is respected without blocking the call.
///
/// [simulationDescription] returns `null` — no `[SIM]` toast substitution is
/// needed because the countdown UI fires normally.
///
/// See spec 02 §4 countdownWarning.
final class CountdownWarningStrategy implements EventStrategy {
  /// Creates a [CountdownWarningStrategy].
  const CountdownWarningStrategy();

  /// Fires vibration and optional audio for the countdown warning.
  ///
  /// Both calls forward [EventServices.isSimulation] so lower-level service
  /// layers can apply hardware muting if appropriate. No sim short-circuit at
  /// this layer — countdown is local-only per spec 02 §Simulation behavior
  /// summary.
  @override
  Future<void> executeReal(ChainStep step, EventServices services) async {
    final config = step.config is CountdownWarningConfig
        ? step.config! as CountdownWarningConfig
        : const CountdownWarningConfig();

    if (config.vibrate) {
      await services.vibration.warningPattern(
        isSimulation: services.isSimulation,
      );
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
