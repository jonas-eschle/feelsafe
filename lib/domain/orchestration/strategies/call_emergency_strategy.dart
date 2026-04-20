/// `CallEmergencyStrategy` — strategy for
/// `ChainStepType.callEmergency`.
///
/// Dials the configured emergency number. Filled in Phase 4b.
library;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Strategy for emergency-call steps.
final class CallEmergencyStrategy extends EventStrategy {
  /// Const constructor.
  const CallEmergencyStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) {
    throw UnimplementedError();
  }

  @override
  String simulationDescription(ChainStep step, EventServices services) =>
      '[SIM] callEmergency';
}
