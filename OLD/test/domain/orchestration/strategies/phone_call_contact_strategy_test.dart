/// Tests for [PhoneCallContactStrategy].
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/strategies/phone_call_contact_strategy.dart';
import 'package:guardianangela/services/protocols/phone_service_protocol.dart';
import '../../../helpers/test_helpers.dart';
import '_strategy_harness.dart';

void main() {
  group('PhoneCallContactStrategy', () {
    late PhoneCallContactStrategy strategy;

    setUp(() {
      strategy = const PhoneCallContactStrategy();
    });

    test('executeReal calls the specified contact by id', () async {
      final harness = StrategyHarness(
        contacts: [
          makeContact(id: 'a', phoneNumber: '+111'),
          makeContact(id: 'b', name: 'Bob', phoneNumber: '+222'),
        ],
      );
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(
          type: ChainStepType.phoneCallContact,
          config: const PhoneCallContactConfig(contactId: 'b'),
        ),
        harness.build(),
      );
      expect(harness.phone.calls, contains('call:+222'));
    });

    test('executeReal calls first contact when contactId=null', () async {
      final harness = StrategyHarness(
        contacts: [
          makeContact(id: 'a', phoneNumber: '+111'),
          makeContact(id: 'b', name: 'Bob', phoneNumber: '+222'),
        ],
      );
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(type: ChainStepType.phoneCallContact),
        harness.build(),
      );
      expect(harness.phone.calls, contains('call:+111'));
    });

    test('executeReal is no-op when no contact matches id', () async {
      final harness = StrategyHarness(
        contacts: [makeContact(id: 'a', phoneNumber: '+111')],
      );
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(
          type: ChainStepType.phoneCallContact,
          config: const PhoneCallContactConfig(contactId: 'does-not-exist'),
        ),
        harness.build(),
      );
      expect(harness.phone.calls, isEmpty);
    });

    test('executeReal is no-op when contact list is empty', () async {
      final harness = StrategyHarness();
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(type: ChainStepType.phoneCallContact),
        harness.build(),
      );
      expect(harness.phone.calls, isEmpty);
    });

    test('executeReal does NOT use hardcoded fallback number', () async {
      // Regression: AUDIT-BUG-3.
      final harness = StrategyHarness();
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(type: ChainStepType.phoneCallContact),
        harness.build(),
      );
      expect(harness.phone.calls.any((c) => c.contains('0000000000')), isFalse);
    });

    // Q12: preSendSms / preSmsIncludeLocation / preSmsMessage removed from
    // PhoneCallContactConfig. Pre-call SMS is no longer supported for
    // personal-contact calls. Tests for that branch are deleted.

    test('executeReal does not touch audio/vibration/notification', () async {
      final harness = StrategyHarness(contacts: [makeContact(id: 'a')]);
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(type: ChainStepType.phoneCallContact),
        harness.build(),
      );
      expect(harness.audio.calls, isEmpty);
      expect(harness.vibration.calls, isEmpty);
      expect(harness.notification.calls, isEmpty);
    });

    test('simulationDescription mentions contact name when found', () {
      final harness = StrategyHarness(
        contacts: [makeContact(id: 'a', name: 'Alice')],
      );
      addTearDown(harness.dispose);
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.phoneCallContact),
        harness.build(),
      );
      expect(desc.templateKey, 'simPhoneCall');
      expect(desc.args['name'], 'Alice');
    });

    test('simulationDescription emits simNoContactToCall when empty', () {
      final harness = StrategyHarness();
      addTearDown(harness.dispose);
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.phoneCallContact),
        harness.build(),
      );
      expect(desc.templateKey, 'simNoContactToCall');
    });

    test('executeReal with wrong config type defaults to first', () async {
      final harness = StrategyHarness(
        contacts: [makeContact(id: 'a', phoneNumber: '+111')],
      );
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(
          type: ChainStepType.phoneCallContact,
          config: const LoudAlarmConfig(),
        ),
        harness.build(),
      );
      expect(harness.phone.calls, contains('call:+111'));
    });

    // Spec 02 §7.phoneCallContact Retry Logic + alternatives.
    test('alternativeContactIds tried after primary succeeds is no-op', () async {
      final harness = StrategyHarness(
        contacts: [
          makeContact(id: 'a', phoneNumber: '+111'),
          makeContact(id: 'b', phoneNumber: '+222'),
        ],
      );
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(
          type: ChainStepType.phoneCallContact,
          config: const PhoneCallContactConfig(
            contactId: 'a',
            alternativeContactIds: ['b'],
          ),
        ),
        harness.build(),
      );
      // Primary succeeded (no retry) → no call to alternate.
      expect(harness.phone.calls, contains('call:+111'));
      expect(harness.phone.calls.contains('call:+222'), isFalse);
    });

    test('retryCount triggers multiple attempts when phone throws', () async {
      final explodingPhone = _ExplodingPhone(failures: 99);
      final harness = StrategyHarness(
        contacts: [makeContact(id: 'a', phoneNumber: '+111')],
      );
      addTearDown(harness.dispose);
      final services = EventServices(
        audio: harness.audio,
        messaging: harness.messaging,
        phone: explodingPhone,
        notification: harness.notification,
        vibration: harness.vibration,
        context: harness.context,
        isCancelled: () => false,
        registerSmsWorkId: harness.registered.add,
      );
      await strategy.executeReal(
        step(
          type: ChainStepType.phoneCallContact,
          retryCount: 2,
          config: const PhoneCallContactConfig(contactId: 'a'),
        ),
        services,
      );
      // retryCount=2 → 3 attempts on the same contact.
      expect(explodingPhone.attempts, 3);
    });

    test('falls through to alternate when primary keeps failing', () async {
      final explodingPhone = _ExplodingPhone(failures: 2);
      final harness = StrategyHarness(
        contacts: [
          makeContact(id: 'a', phoneNumber: '+111'),
          makeContact(id: 'b', phoneNumber: '+222'),
        ],
      );
      addTearDown(harness.dispose);
      final services = EventServices(
        audio: harness.audio,
        messaging: harness.messaging,
        phone: explodingPhone,
        notification: harness.notification,
        vibration: harness.vibration,
        context: harness.context,
        isCancelled: () => false,
        registerSmsWorkId: harness.registered.add,
      );
      await strategy.executeReal(
        step(
          type: ChainStepType.phoneCallContact,
          retryCount: 1,
          config: const PhoneCallContactConfig(
            contactId: 'a',
            alternativeContactIds: ['b'],
          ),
        ),
        services,
      );
      // Primary failed both attempts (retryCount=1 → 2 calls), then
      // alt succeeded on first attempt = 3 total.
      expect(explodingPhone.attempts, 3);
      expect(explodingPhone.numbers.first, '+111');
      expect(explodingPhone.numbers.last, '+222');
    });
  });
}

/// Test double that throws [failures] times before succeeding.
final class _ExplodingPhone implements PhoneServiceProtocol {
  _ExplodingPhone({required this.failures});

  final int failures;
  int attempts = 0;
  final List<String> numbers = [];

  @override
  Future<void> call(String number, {bool isSimulation = false}) async {
    attempts++;
    numbers.add(number);
    if (attempts <= failures) {
      throw StateError('simulated call failure #$attempts');
    }
  }

  @override
  Future<void> callEmergency(String number, {bool isSimulation = false}) async {
    throw UnimplementedError();
  }
}
