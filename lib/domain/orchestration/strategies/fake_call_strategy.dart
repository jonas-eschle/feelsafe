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
    final config = _resolveConfig(step, services);
    final isSim = services.context.isSimulation;
    await services.audio.playRingtone(
      assetPath: config.ringtoneAsset,
      isSimulation: isSim,
    );
    await services.vibration.fakeCallPattern(isSimulation: isSim);
  }

  @override
  String simulationDescription(ChainStep step, EventServices services) {
    final config = _resolveConfig(step, services);
    // Fix for bugs.json Bug #4 (FakeCallConfig semantics): default
    // caller name is "Angela". Null callerName uses the same
    // fallback since the UI shows the same display.
    return '[SIM] Incoming call from ${config.callerName ?? 'Angela'}';
  }

  /// Resolves the step's config.
  ///
  /// Fix for bugs.json Warn (strategies never fall back to
  /// EventDefaults): uses the 3-tier resolution — step.config, then
  /// the session's eventDefaults, then the local const fallback.
  FakeCallConfig _resolveConfig(ChainStep step, EventServices services) {
    final raw = step.config;
    if (raw is FakeCallConfig) return raw;
    try {
      final fromDefaults = services.context.configFor(step);
      if (fromDefaults is FakeCallConfig) return fromDefaults;
    } on StateError {
      // No eventDefaults available — fall through to the const default.
    }
    return const FakeCallConfig();
  }
}
