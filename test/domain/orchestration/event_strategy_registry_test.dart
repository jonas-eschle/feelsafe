/// Tests for `EventStrategyRegistry.forStep`.
///
/// Each of the nine `ChainStepType` values must map to a concrete
/// strategy subclass. The registry uses a sealed-switch expression
/// (no `default:` arm) so omitting a type is a compile-time error;
/// these runtime tests guard against accidental cross-wiring
/// (e.g., `holdButton` → `FakeCallStrategy`).
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';
import 'package:guardianangela/domain/orchestration/event_strategy_registry.dart';
import 'package:guardianangela/domain/orchestration/strategies/call_emergency_strategy.dart';
import 'package:guardianangela/domain/orchestration/strategies/countdown_warning_strategy.dart';
import 'package:guardianangela/domain/orchestration/strategies/disguised_reminder_strategy.dart';
import 'package:guardianangela/domain/orchestration/strategies/fake_call_strategy.dart';
import 'package:guardianangela/domain/orchestration/strategies/hardware_button_strategy.dart';
import 'package:guardianangela/domain/orchestration/strategies/hold_button_strategy.dart';
import 'package:guardianangela/domain/orchestration/strategies/loud_alarm_strategy.dart';
import 'package:guardianangela/domain/orchestration/strategies/phone_call_contact_strategy.dart';
import 'package:guardianangela/domain/orchestration/strategies/sms_contact_strategy.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('EventStrategyRegistry.forStep', () {
    test('holdButton maps to HoldButtonStrategy', () {
      final s = EventStrategyRegistry.forStep(
        step(type: ChainStepType.holdButton),
      );
      expect(s, isA<HoldButtonStrategy>());
    });

    test('disguisedReminder maps to DisguisedReminderStrategy', () {
      final s = EventStrategyRegistry.forStep(
        step(type: ChainStepType.disguisedReminder),
      );
      expect(s, isA<DisguisedReminderStrategy>());
    });

    test('countdownWarning maps to CountdownWarningStrategy', () {
      final s = EventStrategyRegistry.forStep(
        step(type: ChainStepType.countdownWarning),
      );
      expect(s, isA<CountdownWarningStrategy>());
    });

    test('fakeCall maps to FakeCallStrategy', () {
      final s = EventStrategyRegistry.forStep(
        step(type: ChainStepType.fakeCall),
      );
      expect(s, isA<FakeCallStrategy>());
    });

    test('smsContact maps to SmsContactStrategy', () {
      final s = EventStrategyRegistry.forStep(
        step(type: ChainStepType.smsContact),
      );
      expect(s, isA<SmsContactStrategy>());
    });

    test('phoneCallContact maps to PhoneCallContactStrategy', () {
      final s = EventStrategyRegistry.forStep(
        step(type: ChainStepType.phoneCallContact),
      );
      expect(s, isA<PhoneCallContactStrategy>());
    });

    test('loudAlarm maps to LoudAlarmStrategy', () {
      final s = EventStrategyRegistry.forStep(
        step(type: ChainStepType.loudAlarm),
      );
      expect(s, isA<LoudAlarmStrategy>());
    });

    test('callEmergency maps to CallEmergencyStrategy', () {
      final s = EventStrategyRegistry.forStep(
        step(type: ChainStepType.callEmergency),
      );
      expect(s, isA<CallEmergencyStrategy>());
    });

    test('hardwareButton maps to HardwareButtonStrategy', () {
      final s = EventStrategyRegistry.forStep(
        step(type: ChainStepType.hardwareButton),
      );
      expect(s, isA<HardwareButtonStrategy>());
    });

    test('every ChainStepType resolves to a non-null strategy', () {
      for (final type in ChainStepType.values) {
        final s = EventStrategyRegistry.forStep(step(type: type));
        expect(s, isNotNull, reason: 'no strategy for $type');
      }
    });

    test('every ChainStepType resolves to an EventStrategy subclass', () {
      for (final type in ChainStepType.values) {
        final s = EventStrategyRegistry.forStep(step(type: type));
        expect(s, isA<EventStrategy>(), reason: 'wrong type for $type');
      }
    });

    test('returned strategies are const / identical across calls', () {
      for (final type in ChainStepType.values) {
        final a = EventStrategyRegistry.forStep(step(type: type));
        final b = EventStrategyRegistry.forStep(step(type: type));
        expect(
          identical(a, b),
          isTrue,
          reason: 'strategy for $type must be const',
        );
      }
    });

    test('dispatch ignores step config — only `type` matters', () {
      final a = EventStrategyRegistry.forStep(
        step(type: ChainStepType.loudAlarm),
      );
      final b = EventStrategyRegistry.forStep(
        step(
          type: ChainStepType.loudAlarm,
          config: const LoudAlarmConfig(flashScreen: false),
        ),
      );
      expect(a.runtimeType, b.runtimeType);
    });

    test('dispatch is type-stable — returned runtimeType is fixed', () {
      final a = EventStrategyRegistry.forStep(
        step(type: ChainStepType.holdButton, order: 0),
      );
      final b = EventStrategyRegistry.forStep(
        step(type: ChainStepType.holdButton, order: 7),
      );
      expect(a.runtimeType, b.runtimeType);
    });

    test('non-trivial strategy subclass types all differ', () {
      final seen = <Type>{};
      for (final type in ChainStepType.values) {
        final s = EventStrategyRegistry.forStep(step(type: type));
        expect(
          seen.add(s.runtimeType),
          isTrue,
          reason: 'duplicate strategy type for $type',
        );
      }
    });

    test('strategies implement EventStrategy with both abstract methods', () {
      for (final type in ChainStepType.values) {
        final s = EventStrategyRegistry.forStep(step(type: type));
        // Just checking the two methods exist on every mapped
        // instance — a runtime surface guard in case someone
        // accidentally changes the base class shape.
        expect(s.simulationDescription, isA<Function>());
        expect(s.executeReal, isA<Function>());
      }
    });

    test('count of mapped types equals ChainStepType.values.length', () {
      final mapped = <Type>{
        for (final type in ChainStepType.values)
          EventStrategyRegistry.forStep(step(type: type)).runtimeType,
      };
      expect(mapped.length, ChainStepType.values.length);
    });

    test('dispatch on every step type works irrespective of order', () {
      for (final type in ChainStepType.values) {
        final s = EventStrategyRegistry.forStep(step(type: type, order: 99));
        expect(s, isA<EventStrategy>());
      }
    });
  });
}
