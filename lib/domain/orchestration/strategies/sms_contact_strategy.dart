/// `SmsContactStrategy` — strategy for `ChainStepType.smsContact`.
///
/// Sends an SMS (and/or WhatsApp / Telegram) to the configured
/// emergency contact(s). Filled in Phase 4b.
library;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Strategy for SMS-to-contact steps.
final class SmsContactStrategy extends EventStrategy {
  /// Const constructor.
  const SmsContactStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) {
    throw UnimplementedError();
  }

  @override
  String simulationDescription(ChainStep step, EventServices services) =>
      '[SIM] smsContact';
}
