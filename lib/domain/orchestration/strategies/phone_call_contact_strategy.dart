/// `PhoneCallContactStrategy` — strategy for
/// `ChainStepType.phoneCallContact`.
///
/// Places a voice call to the configured emergency contact.
/// Filled in Phase 4b.
library;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Strategy for phone-call-to-contact steps.
final class PhoneCallContactStrategy extends EventStrategy {
  /// Const constructor.
  const PhoneCallContactStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) {
    throw UnimplementedError();
  }

  @override
  String simulationDescription(ChainStep step, EventServices services) =>
      '[SIM] phoneCallContact';
}
