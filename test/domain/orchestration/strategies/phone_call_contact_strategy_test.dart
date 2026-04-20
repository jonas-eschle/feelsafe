/// Tests for [PhoneCallContactStrategy].
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/strategies/phone_call_contact_strategy.dart';

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
      expect(
        harness.phone.calls.any((c) => c.contains('0000000000')),
        isFalse,
      );
    });

    test('executeReal sends pre-SMS when preSendSms=true', () async {
      final harness = StrategyHarness(
        contacts: [makeContact(id: 'a', phoneNumber: '+111')],
      );
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(
          type: ChainStepType.phoneCallContact,
          config: const PhoneCallContactConfig(preSendSms: true),
        ),
        harness.build(),
      );
      expect(harness.messaging.calls, contains('sendToAll:1'));
    });

    test('executeReal skips pre-SMS when preSendSms=false', () async {
      final harness = StrategyHarness(
        contacts: [makeContact(id: 'a', phoneNumber: '+111')],
      );
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(type: ChainStepType.phoneCallContact),
        harness.build(),
      );
      expect(harness.messaging.calls, isEmpty);
    });

    test('executeReal registers pre-SMS work ids', () async {
      final harness = StrategyHarness(
        contacts: [makeContact(id: 'a', phoneNumber: '+111')],
      );
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(
          type: ChainStepType.phoneCallContact,
          config: const PhoneCallContactConfig(preSendSms: true),
        ),
        harness.build(),
      );
      expect(harness.registered.length, 1);
    });

    test('executeReal sends pre-SMS before placing the call', () async {
      final harness = StrategyHarness(
        contacts: [makeContact(id: 'a', phoneNumber: '+111')],
      );
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(
          type: ChainStepType.phoneCallContact,
          config: const PhoneCallContactConfig(preSendSms: true),
        ),
        harness.build(),
      );
      expect(harness.messaging.calls.isNotEmpty, isTrue);
      expect(harness.phone.calls, contains('call:+111'));
    });

    test('executeReal does not touch audio/vibration/notification', () async {
      final harness = StrategyHarness(
        contacts: [makeContact(id: 'a')],
      );
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
      expect(desc, contains('Alice'));
    });

    test('simulationDescription states "no contact" when empty', () {
      final harness = StrategyHarness();
      addTearDown(harness.dispose);
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.phoneCallContact),
        harness.build(),
      );
      expect(desc.toLowerCase(), contains('no contact'));
    });

    test('simulationDescription starts with SIM prefix', () {
      final harness = StrategyHarness();
      addTearDown(harness.dispose);
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.phoneCallContact),
        harness.build(),
      );
      expect(desc.startsWith('[SIM]'), isTrue);
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

    test('executeReal preSendSms without contacts is still no-op', () async {
      final harness = StrategyHarness();
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(
          type: ChainStepType.phoneCallContact,
          config: const PhoneCallContactConfig(preSendSms: true),
        ),
        harness.build(),
      );
      expect(harness.messaging.calls, isEmpty);
      expect(harness.phone.calls, isEmpty);
    });
  });
}
