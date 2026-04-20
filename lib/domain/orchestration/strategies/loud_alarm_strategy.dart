/// `LoudAlarmStrategy` — strategy for `ChainStepType.loudAlarm`.
///
/// Plays the loud alarm tone + high-intensity vibration. Filled in
/// Phase 4b.
library;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Strategy for loud-alarm steps.
final class LoudAlarmStrategy extends EventStrategy {
  /// Const constructor.
  const LoudAlarmStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) {
    throw UnimplementedError();
  }

  @override
  String simulationDescription(ChainStep step, EventServices services) =>
      '[SIM] loudAlarm';
}
