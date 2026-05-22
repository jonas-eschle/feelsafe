import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
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

// ─── Local helper ─────────────────────────────────────────────────────────────

/// Builds a minimal [ChainStep] for delegation tests.
///
/// Only [type] matters for registry tests. All timing fields are zero except
/// [durationSeconds] which is 1. [config] is always null, exercising the
/// null-config path and confirming [forStep] ignores config.
ChainStep _step({required ChainStepType type, String? id}) => ChainStep(
  id: id ?? 'step-${type.name}',
  type: type,
  order: 0,
  waitSeconds: 0,
  durationSeconds: 1,
  gracePeriodSeconds: 0,
  retryCount: 0,
  randomize: false,
);

void main() {
  // ─── 1. Guard: spec-mandated step-type count ──────────────────────────────
  group('Guard: ChainStepType.values.length == 9', () {
    test('exactly 9 ChainStepType values exist', () {
      check(ChainStepType.values.length).equals(9);
    });
  });

  // ─── 2. Exhaustiveness: every type returns a non-null strategy ────────────
  group('Exhaustiveness: forType returns non-null for every ChainStepType', () {
    for (final type in ChainStepType.values) {
      test('forType($type) returns a non-null EventStrategy', () {
        final strategy = const EventStrategyRegistry().forType(type);
        // isNotNull check via isA<EventStrategy> — all concrete strategies
        // implement EventStrategy, so the type check covers non-null.
        check(strategy).isA<EventStrategy>();
      });
    }
  });

  // ─── 3. Type-specific dispatch: each type maps to the correct class ───────
  group(
    'Type-specific dispatch: forType returns the correct concrete type',
    () {
      test('holdButton → HoldButtonStrategy', () {
        final strategy = const EventStrategyRegistry().forType(
          ChainStepType.holdButton,
        );
        check(strategy).isA<HoldButtonStrategy>();
      });

      test('disguisedReminder → DisguisedReminderStrategy', () {
        final strategy = const EventStrategyRegistry().forType(
          ChainStepType.disguisedReminder,
        );
        check(strategy).isA<DisguisedReminderStrategy>();
      });

      test('hardwareButton → HardwareButtonStrategy', () {
        final strategy = const EventStrategyRegistry().forType(
          ChainStepType.hardwareButton,
        );
        check(strategy).isA<HardwareButtonStrategy>();
      });

      test('countdownWarning → CountdownWarningStrategy', () {
        final strategy = const EventStrategyRegistry().forType(
          ChainStepType.countdownWarning,
        );
        check(strategy).isA<CountdownWarningStrategy>();
      });

      test('fakeCall → FakeCallStrategy', () {
        final strategy = const EventStrategyRegistry().forType(
          ChainStepType.fakeCall,
        );
        check(strategy).isA<FakeCallStrategy>();
      });

      test('smsContact → SmsContactStrategy', () {
        final strategy = const EventStrategyRegistry().forType(
          ChainStepType.smsContact,
        );
        check(strategy).isA<SmsContactStrategy>();
      });

      test('phoneCallContact → PhoneCallContactStrategy', () {
        final strategy = const EventStrategyRegistry().forType(
          ChainStepType.phoneCallContact,
        );
        check(strategy).isA<PhoneCallContactStrategy>();
      });

      test('loudAlarm → LoudAlarmStrategy', () {
        final strategy = const EventStrategyRegistry().forType(
          ChainStepType.loudAlarm,
        );
        check(strategy).isA<LoudAlarmStrategy>();
      });

      test('callEmergency → CallEmergencyStrategy', () {
        final strategy = const EventStrategyRegistry().forType(
          ChainStepType.callEmergency,
        );
        check(strategy).isA<CallEmergencyStrategy>();
      });
    },
  );

  // ─── 4. forStep delegation: forStep(step) == forType(step.type) ──────────
  group('forStep delegation: forStep returns the same strategy as forType', () {
    test('holdButton step delegates to forType(holdButton)', () {
      const registry = EventStrategyRegistry();
      final viaStep = registry.forStep(_step(type: ChainStepType.holdButton));
      final viaType = registry.forType(ChainStepType.holdButton);
      check(identical(viaStep, viaType)).isTrue();
    });

    test('fakeCall step delegates to forType(fakeCall)', () {
      const registry = EventStrategyRegistry();
      final viaStep = registry.forStep(_step(type: ChainStepType.fakeCall));
      final viaType = registry.forType(ChainStepType.fakeCall);
      check(identical(viaStep, viaType)).isTrue();
    });

    test('callEmergency step delegates to forType(callEmergency)', () {
      const registry = EventStrategyRegistry();
      final viaStep = registry.forStep(
        _step(type: ChainStepType.callEmergency),
      );
      final viaType = registry.forType(ChainStepType.callEmergency);
      check(identical(viaStep, viaType)).isTrue();
    });

    test('smsContact step delegates to forType(smsContact)', () {
      const registry = EventStrategyRegistry();
      final viaStep = registry.forStep(_step(type: ChainStepType.smsContact));
      final viaType = registry.forType(ChainStepType.smsContact);
      check(identical(viaStep, viaType)).isTrue();
    });

    test(
      'forStep does not require step.config — holdButton with null config',
      () {
        const registry = EventStrategyRegistry();
        // _step() always passes config: null; this is explicit proof the
        // dispatch works without a typed config present.
        final strategy = registry.forStep(
          _step(type: ChainStepType.holdButton),
        );
        check(strategy).isA<HoldButtonStrategy>();
      },
    );
  });

  // ─── 5. Registry invariants: const, stateless, identical returns ─────────
  group('Registry invariants', () {
    test(
      'EventStrategyRegistry() is const-constructible (identical instances)',
      () {
        const a = EventStrategyRegistry();
        const b = EventStrategyRegistry();
        check(identical(a, b)).isTrue();
      },
    );

    test(
      'forType called twice for holdButton returns identical strategies',
      () {
        const registry = EventStrategyRegistry();
        final first = registry.forType(ChainStepType.holdButton);
        final second = registry.forType(ChainStepType.holdButton);
        check(identical(first, second)).isTrue();
      },
    );

    test(
      'forType called twice for smsContact returns identical strategies',
      () {
        const registry = EventStrategyRegistry();
        final first = registry.forType(ChainStepType.smsContact);
        final second = registry.forType(ChainStepType.smsContact);
        check(identical(first, second)).isTrue();
      },
    );

    test('forType called twice for loudAlarm returns identical strategies', () {
      const registry = EventStrategyRegistry();
      final first = registry.forType(ChainStepType.loudAlarm);
      final second = registry.forType(ChainStepType.loudAlarm);
      check(identical(first, second)).isTrue();
    });

    test('different registries return identical strategies for same type', () {
      const registryA = EventStrategyRegistry();
      const registryB = EventStrategyRegistry();
      final stratA = registryA.forType(ChainStepType.countdownWarning);
      final stratB = registryB.forType(ChainStepType.countdownWarning);
      check(identical(stratA, stratB)).isTrue();
    });

    test(
      'no two distinct ChainStepTypes map to the same strategy instance',
      () {
        const registry = EventStrategyRegistry();
        final strategies = ChainStepType.values.map(registry.forType).toList();
        // All 9 strategy instances must be pairwise non-identical:
        // strategies are type-keyed const singletons, so each type has its own.
        final identitySet = strategies.map(identityHashCode).toSet();
        check(identitySet.length).equals(ChainStepType.values.length);
      },
    );
  });
}
