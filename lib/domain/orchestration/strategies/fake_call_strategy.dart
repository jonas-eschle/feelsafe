/// `FakeCallStrategy` — strategy for `ChainStepType.fakeCall`.
///
/// Plays the fake-incoming-call audio + vibration cue. The fake
/// call UI (lock-screen-style call screen with answer/decline) is
/// rendered UI-side by `FakeCallScreen`; this strategy's job is the
/// ringtone + ring-vibration sensory layer.
library;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Strategy for fake-call steps.
final class FakeCallStrategy extends EventStrategy {
  /// Const constructor.
  const FakeCallStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) async {
    final config = _resolveConfig(step);
    final isSim = services.context.isSimulation;
    await services.audio.playRingtone(
      assetPath: config.ringtoneAsset,
      isSimulation: isSim,
    );
    await services.vibration.fakeCallPattern(isSimulation: isSim);
  }

  @override
  String simulationDescription(ChainStep step, EventServices services) {
    final config = _resolveConfig(step);
    return '[SIM] Incoming call from ${config.callerName ?? 'Mom'}';
  }

  /// Resolves the step's config, falling back to a default.
  FakeCallConfig _resolveConfig(ChainStep step) {
    final raw = step.config;
    if (raw is FakeCallConfig) return raw;
    return const FakeCallConfig();
  }
}
