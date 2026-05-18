/// Unit tests for `ChainStep` — field defaults, copyWith, equality,
/// JSON round-trip across every [StepConfig] subtype, and ordering.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('ChainStep', () {
    test('construct with required fields yields defaults', () {
      final s = const ChainStep(
        id: 's1',
        type: ChainStepType.holdButton,
        order: 0,
        durationSeconds: 30,
        gracePeriodSeconds: 5,
      );
      check(s.id).equals('s1');
      check(s.type).equals(ChainStepType.holdButton);
      check(s.order).equals(0);
      check(s.durationSeconds).equals(30);
      check(s.gracePeriodSeconds).equals(5);
      check(s.waitSeconds).equals(0);
      check(s.retryCount).equals(0);
      check(s.randomize).equals(0.0);
      check(s.config).isNull();
    });

    test('waitDuration, activeDuration, graceDuration', () {
      final s = step(
        waitSeconds: 10,
        durationSeconds: 20,
        gracePeriodSeconds: 3,
      );
      check(s.waitDuration).equals(const Duration(seconds: 10));
      check(s.activeDuration).equals(const Duration(seconds: 20));
      check(s.graceDuration).equals(const Duration(seconds: 3));
    });

    test('totalCycleSeconds sums all three phases', () {
      final s = step(
        waitSeconds: 5,
        durationSeconds: 30,
        gracePeriodSeconds: 7,
      );
      check(s.totalCycleSeconds).equals(42);
    });

    test('copyWith replaces targeted field and keeps others', () {
      final s = holdStep(durationSeconds: 10);
      final s2 = s.copyWith(durationSeconds: 20);
      check(s2.durationSeconds).equals(20);
      check(s2.gracePeriodSeconds).equals(s.gracePeriodSeconds);
      check(s2.id).equals(s.id);
      check(s2.config).equals(s.config);
    });

    test('equality and hashCode', () {
      final a = holdStep();
      final b = holdStep();
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });

    test('inequality when a field differs', () {
      check(
        holdStep(durationSeconds: 10),
      ).not((it) => it.equals(holdStep(durationSeconds: 20)));
    });

    test('ordering via order field', () {
      final steps = [step(order: 2), step(order: 0), step(order: 1)]
        ..sort((a, b) => a.order.compareTo(b.order));
      check(steps.map((s) => s.order).toList()).deepEquals([0, 1, 2]);
    });

    test('JSON round-trip with null config', () {
      final s = step();
      check(ChainStep.fromJson(s.toJson())).equals(s);
    });

    test('JSON round-trip with HoldButtonConfig', () {
      final s = holdStep(releaseSensitivity: 0.5);
      check(ChainStep.fromJson(s.toJson())).equals(s);
    });

    test('JSON round-trip with DisguisedReminderConfig', () {
      final s = step(
        type: ChainStepType.disguisedReminder,
        config: const DisguisedReminderConfig(
          templateId: 't1',
          intervalSeconds: 45,
        ),
      );
      check(ChainStep.fromJson(s.toJson())).equals(s);
    });

    test('JSON round-trip with HardwareButtonConfig', () {
      final s = step(
        type: ChainStepType.hardwareButton,
        config: const HardwareButtonConfig(
          buttonType: ButtonType.power,
          pattern: HardwarePattern.longPress,
          pressCount: 3,
          pressWindowMs: 300,
          longPressDurationSeconds: 3.0,
        ),
      );
      check(ChainStep.fromJson(s.toJson())).equals(s);
    });

    test('JSON round-trip with CountdownWarningConfig', () {
      final s = step(
        type: ChainStepType.countdownWarning,
        config: const CountdownWarningConfig(vibrate: false, playTone: true),
      );
      check(ChainStep.fromJson(s.toJson())).equals(s);
    });

    test('JSON round-trip with FakeCallConfig', () {
      final s = fakeCallStep(declineIsSafe: true);
      check(ChainStep.fromJson(s.toJson())).equals(s);
    });

    test('JSON round-trip with SmsContactConfig', () {
      final s = smsStep(message: 'help', contactIds: ['c1', 'c2']);
      check(ChainStep.fromJson(s.toJson())).equals(s);
    });

    test('JSON round-trip with PhoneCallContactConfig', () {
      final s = step(
        type: ChainStepType.phoneCallContact,
        config: const PhoneCallContactConfig(
          contactId: 'c1',
          alternativeContactIds: ['c2', 'c3'],
        ),
      );
      check(ChainStep.fromJson(s.toJson())).equals(s);
    });

    test('JSON round-trip with LoudAlarmConfig', () {
      final s = step(
        type: ChainStepType.loudAlarm,
        config: const LoudAlarmConfig(
          flashScreen: false,
          flashSpeed: 0.25,
          maxVolume: false,
        ),
      );
      check(ChainStep.fromJson(s.toJson())).equals(s);
    });

    test('JSON round-trip with CallEmergencyConfig', () {
      final s = step(
        type: ChainStepType.callEmergency,
        config: const CallEmergencyConfig(
          emergencyNumber: '911',
          showConfirmation: true,
        ),
      );
      check(ChainStep.fromJson(s.toJson())).equals(s);
    });

    test('JSON round-trip with waitSeconds/retryCount/randomize set', () {
      final s = step(
        waitSeconds: 10,
        retryCount: 2,
        randomize: 0.5,
        durationSeconds: 60,
      );
      check(ChainStep.fromJson(s.toJson())).equals(s);
    });

    test('fromJson throws for unknown type', () {
      check(
        () => ChainStep.fromJson(const {
          'id': 'x',
          'type': 'bogus',
          'order': 0,
          'durationSeconds': 1,
          'gracePeriodSeconds': 1,
        }),
      ).throws<ArgumentError>();
    });

    test('toJson contains all serialized fields', () {
      final s = holdStep();
      final json = s.toJson();
      check(json).containsKey('id');
      check(json).containsKey('type');
      check(json).containsKey('order');
      check(json).containsKey('durationSeconds');
      check(json).containsKey('gracePeriodSeconds');
      check(json).containsKey('waitSeconds');
      check(json).containsKey('retryCount');
      check(json).containsKey('randomize');
      check(json).containsKey('config');
    });

    test('toString includes identifying fields', () {
      final s = holdStep();
      final str = s.toString();
      check(str).contains(s.id);
      check(str).contains('holdButton');
    });

    test('fromJson tolerates missing optional fields', () {
      final s = ChainStep.fromJson(const {
        'id': 'x',
        'type': 'holdButton',
        'order': 0,
        'durationSeconds': 1,
        'gracePeriodSeconds': 1,
      });
      check(s.waitSeconds).equals(0);
      check(s.retryCount).equals(0);
      check(s.randomize).equals(0.0);
      check(s.config).isNull();
    });

    test('round-trip preserves order across many steps', () {
      final steps = List.generate(5, (i) => step(order: i));
      for (final s in steps) {
        check(ChainStep.fromJson(s.toJson())).equals(s);
      }
    });
  });
}
