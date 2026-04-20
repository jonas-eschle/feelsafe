/// `EventStrategyRegistry` — resolves a [ChainStep] to its matching
/// [EventStrategy].
///
/// The dispatch is a compile-time exhaustive `switch` on
/// `ChainStepType` — no `default:` arm. Every strategy is a `const`
/// singleton so the registry never allocates per lookup.
library;

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';
import 'package:guardianangela/domain/orchestration/strategies/call_emergency_strategy.dart';
import 'package:guardianangela/domain/orchestration/strategies/countdown_warning_strategy.dart';
import 'package:guardianangela/domain/orchestration/strategies/disguised_reminder_strategy.dart';
import 'package:guardianangela/domain/orchestration/strategies/fake_call_strategy.dart';
import 'package:guardianangela/domain/orchestration/strategies/hardware_button_strategy.dart';
import 'package:guardianangela/domain/orchestration/strategies/hold_button_strategy.dart';
import 'package:guardianangela/domain/orchestration/strategies/loud_alarm_strategy.dart';
import 'package:guardianangela/domain/orchestration/strategies/phone_call_contact_strategy.dart';
import 'package:guardianangela/domain/orchestration/strategies/sms_contact_strategy.dart';

/// Static registry mapping `ChainStepType` → `EventStrategy`.
final class EventStrategyRegistry {
  const EventStrategyRegistry._();

  /// Returns the [EventStrategy] for [step].
  static EventStrategy forStep(ChainStep step) => switch (step.type) {
    ChainStepType.holdButton => const HoldButtonStrategy(),
    ChainStepType.disguisedReminder => const DisguisedReminderStrategy(),
    ChainStepType.countdownWarning => const CountdownWarningStrategy(),
    ChainStepType.fakeCall => const FakeCallStrategy(),
    ChainStepType.smsContact => const SmsContactStrategy(),
    ChainStepType.phoneCallContact => const PhoneCallContactStrategy(),
    ChainStepType.loudAlarm => const LoudAlarmStrategy(),
    ChainStepType.callEmergency => const CallEmergencyStrategy(),
    ChainStepType.hardwareButton => const HardwareButtonStrategy(),
  };
}
