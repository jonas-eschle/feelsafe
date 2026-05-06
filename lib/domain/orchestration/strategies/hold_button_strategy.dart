/// `HoldButtonStrategy` — strategy for `ChainStepType.holdButton`.
///
/// Hold detection is UI-side: the user physically holds a button on
/// `HomeScreen` / `SessionScreen`, and the engine responds via the
/// `holdStart()` / `holdRelease()` control calls, **not** via a
/// side-effect produced by this strategy. The strategy exists only
/// so every step type routes through [EventStrategyRegistry]
/// uniformly. Both [executeReal] and [simulationDescription] are
/// intentional no-ops / pure strings.
library;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// No-op strategy for hold-button steps.
final class HoldButtonStrategy extends EventStrategy {
  /// Const constructor.
  const HoldButtonStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) async {
    // Intentional no-op: hold detection is UI-side and dispatched to
    // the engine via holdStart() / holdRelease(). See class doc.
  }

  @override
  SimulationDescription simulationDescription(
    ChainStep step,
    EventServices services,
  ) => const SimulationDescription('simHoldButton');
}
