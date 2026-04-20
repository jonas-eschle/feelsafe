/// `DisguisedReminderStrategy` — strategy for
/// `ChainStepType.disguisedReminder`.
///
/// Displays a disguised reminder from the configured template and
/// awaits the user's confirmation. Filled in Phase 4b.
library;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Strategy for disguised-reminder steps.
final class DisguisedReminderStrategy extends EventStrategy {
  /// Const constructor.
  const DisguisedReminderStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) {
    throw UnimplementedError();
  }

  @override
  String simulationDescription(ChainStep step, EventServices services) =>
      '[SIM] disguisedReminder';
}
