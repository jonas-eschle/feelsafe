import 'package:guardianangela/domain/enums/chain_step_type.dart';
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

/// Maps every [ChainStepType] to its [EventStrategy] via an exhaustive
/// sealed switch.
///
/// The exhaustive switch is a compile-time guarantee: omitting any
/// [ChainStepType] value makes the switch non-exhaustive, which is a
/// fatal analyzer error (strict mode). This catches the v2 bug where
/// only 6 of 9 types had strategies registered.
///
/// All strategy instances are `const` singletons — they carry no state.
/// The registry itself is `const` and safe to share freely.
final class EventStrategyRegistry {
  /// Creates a constant [EventStrategyRegistry].
  const EventStrategyRegistry();

  /// Returns the [EventStrategy] for the given [ChainStepType].
  ///
  /// The exhaustive switch guarantees every type maps to a strategy at
  /// compile time. No runtime fallback is needed.
  EventStrategy forType(ChainStepType type) => switch (type) {
    ChainStepType.holdButton => const HoldButtonStrategy(),
    ChainStepType.disguisedReminder => const DisguisedReminderStrategy(),
    ChainStepType.hardwareButton => const HardwareButtonStrategy(),
    ChainStepType.countdownWarning => const CountdownWarningStrategy(),
    ChainStepType.fakeCall => const FakeCallStrategy(),
    ChainStepType.smsContact => const SmsContactStrategy(),
    ChainStepType.phoneCallContact => const PhoneCallContactStrategy(),
    ChainStepType.loudAlarm => const LoudAlarmStrategy(),
    ChainStepType.callEmergency => const CallEmergencyStrategy(),
  };

  /// Convenience shorthand: looks up the strategy for [step.type].
  EventStrategy forStep(ChainStep step) => forType(step.type);
}
