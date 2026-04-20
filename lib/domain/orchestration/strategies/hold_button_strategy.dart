/// `HoldButtonStrategy` — strategy for `ChainStepType.holdButton`.
///
/// Hold detection is UI-side (the user holds a button on
/// `HomeScreen`); this strategy intentionally has no side-effect.
/// It exists so every step type routes through the strategy
/// registry uniformly.
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
    // Intentional no-op: hold detection is UI-side.
  }

  @override
  String simulationDescription(ChainStep step, EventServices services) =>
      '[SIM] holdButton';
}
