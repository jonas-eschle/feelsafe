/// `HardwareButtonStrategy` — strategy for
/// `ChainStepType.hardwareButton`.
///
/// Hardware-button detection is handled by `TriggerManager` via the
/// `HardwareButtonServiceProtocol`, **not** by a chain step. This
/// strategy exists only so every step type routes through
/// [EventStrategyRegistry] uniformly. Both [executeReal] and
/// [simulationDescription] are intentional no-ops / pure strings.
library;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// No-op strategy for hardware-button steps.
final class HardwareButtonStrategy extends EventStrategy {
  /// Const constructor.
  const HardwareButtonStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) async {
    // Intentional no-op: detection lives in TriggerManager.
  }

  @override
  SimulationDescription simulationDescription(
    ChainStep step,
    EventServices services,
  ) => const SimulationDescription('simHardwareButton');
}
