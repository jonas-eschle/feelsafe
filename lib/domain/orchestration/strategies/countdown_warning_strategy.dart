/// `CountdownWarningStrategy` — strategy for
/// `ChainStepType.countdownWarning`.
///
/// Plays the warning vibration pattern. If the step config opts in
/// via `playTone`, also plays the alarm audio in a soft / pre-alarm
/// mode (non-max-volume). The visible countdown is rendered UI-side
/// on `SessionScreen`; this strategy's side-effects are purely
/// haptic + audio cues.
library;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Strategy for countdown-warning steps.
final class CountdownWarningStrategy extends EventStrategy {
  /// Const constructor.
  const CountdownWarningStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) async {
    final config = _resolveConfig(step);
    final isSim = services.context.isSimulation;
    if (config.vibrate) {
      await services.vibration.warningPattern(isSimulation: isSim);
    }
    if (config.playTone) {
      await services.audio.playAlarm(maxVolume: false, isSimulation: isSim);
    }
  }

  @override
  String simulationDescription(ChainStep step, EventServices services) =>
      '[SIM] ${step.durationSeconds}s countdown warning';

  /// Resolves the step's config, falling back to a default-shaped
  /// [CountdownWarningConfig] when the step does not carry one.
  CountdownWarningConfig _resolveConfig(ChainStep step) {
    final raw = step.config;
    if (raw is CountdownWarningConfig) return raw;
    return const CountdownWarningConfig();
  }
}
