/// `FakeCallStrategy` — strategy for `ChainStepType.fakeCall`.
///
/// Plays a simulated incoming-call UI (ringtone + vibration) with
/// answer / decline / hang-up actions. Filled in Phase 4b.
library;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Strategy for fake-call steps.
final class FakeCallStrategy extends EventStrategy {
  /// Const constructor.
  const FakeCallStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) {
    throw UnimplementedError();
  }

  @override
  String simulationDescription(ChainStep step, EventServices services) =>
      '[SIM] fakeCall';
}
