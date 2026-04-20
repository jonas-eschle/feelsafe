/// `HardwareButtonStrategy` — strategy for
/// `ChainStepType.hardwareButton`.
///
/// No-op: hardware-button detection is handled by `TriggerManager`
/// via the `HardwareButtonServiceProtocol`, not by a chain step.
/// This strategy exists only so every step type has a registered
/// strategy.
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
  String simulationDescription(ChainStep step, EventServices services) =>
      '[SIM] hardwareButton';
}
