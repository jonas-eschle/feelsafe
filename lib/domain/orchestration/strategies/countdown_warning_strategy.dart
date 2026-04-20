/// `CountdownWarningStrategy` — strategy for
/// `ChainStepType.countdownWarning`.
///
/// Displays a visible countdown and plays the warning vibration /
/// pre-alarm audio. Filled in Phase 4b.
library;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Strategy for countdown-warning steps.
final class CountdownWarningStrategy extends EventStrategy {
  /// Const constructor.
  const CountdownWarningStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) {
    throw UnimplementedError();
  }

  @override
  String simulationDescription(ChainStep step, EventServices services) =>
      '[SIM] countdownWarning';
}
