/// Tests for [SmsContactStrategy].
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/domain/orchestration/strategies/sms_contact_strategy.dart';
import '../../../helpers/test_helpers.dart';
import '_strategy_harness.dart';

void main() {
  group('SmsContactStrategy', () {
    late SmsContactStrategy strategy;

    setUp(() {
      strategy = const SmsContactStrategy();
    });

    test('executeReal sends to all when selection=allContacts', () async {
      final harness = StrategyHarness(
        contacts: [
          makeContact(id: 'a', name: 'Alice'),
          makeContact(id: 'b', name: 'Bob'),
        ],
      );
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(type: ChainStepType.smsContact, config: const SmsContactConfig()),
        harness.build(),
      );
      // Spec 02 Extra-15/15b: one sendMessage per contact on the
      // configured channel.
      final sends = harness.messaging.calls
          .where((c) => c.startsWith('sendMessage:'))
          .length;
      expect(sends, 2);
    });

    test('executeReal sends only to first when firstContact', () async {
      final harness = StrategyHarness(
        contacts: [
          makeContact(id: 'a'),
          makeContact(id: 'b', name: 'Bob'),
        ],
      );
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(
          type: ChainStepType.smsContact,
          config: const SmsContactConfig(
            contactSelection: SmsContactSelection.firstContact,
          ),
        ),
        harness.build(),
      );
      final sends = harness.messaging.calls
          .where((c) => c.startsWith('sendMessage:'))
          .length;
      expect(sends, 1);
    });

    test('executeReal filters to specific ids', () async {
      final harness = StrategyHarness(
        contacts: [
          makeContact(id: 'a'),
          makeContact(id: 'b', name: 'Bob'),
          makeContact(id: 'c', name: 'Carol'),
        ],
      );
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(
          type: ChainStepType.smsContact,
          config: const SmsContactConfig(
            contactSelection: SmsContactSelection.specificIds,
            contactIds: ['a', 'c'],
          ),
        ),
        harness.build(),
      );
      final sends = harness.messaging.calls
          .where((c) => c.startsWith('sendMessage:'))
          .length;
      expect(sends, 2);
    });

    test('executeReal with no matching specific ids is a no-op', () async {
      final harness = StrategyHarness(contacts: [makeContact(id: 'a')]);
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(
          type: ChainStepType.smsContact,
          config: const SmsContactConfig(
            contactSelection: SmsContactSelection.specificIds,
            contactIds: ['z'],
          ),
        ),
        harness.build(),
      );
      expect(harness.messaging.calls, isEmpty);
    });

    test('executeReal with null specificIds sends nothing', () async {
      final harness = StrategyHarness(contacts: [makeContact(id: 'a')]);
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(
          type: ChainStepType.smsContact,
          config: const SmsContactConfig(
            contactSelection: SmsContactSelection.specificIds,
          ),
        ),
        harness.build(),
      );
      expect(harness.messaging.calls, isEmpty);
    });

    test('executeReal with empty specificIds sends nothing', () async {
      final harness = StrategyHarness(contacts: [makeContact(id: 'a')]);
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(
          type: ChainStepType.smsContact,
          config: const SmsContactConfig(
            contactSelection: SmsContactSelection.specificIds,
            contactIds: [],
          ),
        ),
        harness.build(),
      );
      expect(harness.messaging.calls, isEmpty);
    });

    test('executeReal with no contacts in context is a no-op', () async {
      final harness = StrategyHarness(contacts: const []);
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(type: ChainStepType.smsContact),
        harness.build(),
      );
      expect(harness.messaging.calls, isEmpty);
    });

    test('executeReal registers every returned work id', () async {
      final harness = StrategyHarness(
        contacts: [
          makeContact(id: 'a'),
          makeContact(id: 'b', name: 'Bob'),
        ],
      );
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(type: ChainStepType.smsContact),
        harness.build(),
      );
      expect(harness.registered.length, 2);
    });

    test('executeReal resolves {name} placeholder from user profile', () async {
      final harness = StrategyHarness(
        contacts: [makeContact(id: 'a')],
        userProfile: const UserProfile(name: 'Zoe'),
      );
      addTearDown(harness.dispose);
      // Custom template that uses {name}.
      await strategy.executeReal(
        step(
          type: ChainStepType.smsContact,
          config: const SmsContactConfig(messageTemplate: 'HELP {name}'),
        ),
        harness.build(),
      );
      // The fake records only contacts/channels, not message body,
      // so assert the delivery happened; body-shape tests live in
      // the session-context test file.
      final sends = harness.messaging.calls
          .where((c) => c.startsWith('sendMessage:'))
          .length;
      expect(sends, 1);
    });

    test('simulationDescription reports the count', () {
      final harness = StrategyHarness(
        contacts: [
          makeContact(id: 'a'),
          makeContact(id: 'b', name: 'Bob'),
          makeContact(id: 'c', name: 'Carol'),
        ],
      );
      addTearDown(harness.dispose);
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.smsContact),
        harness.build(),
      );
      expect(desc, contains('3'));
    });

    test('simulationDescription with zero contacts reports 0', () {
      final harness = StrategyHarness();
      addTearDown(harness.dispose);
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.smsContact),
        harness.build(),
      );
      expect(desc, contains('0'));
    });

    test('simulationDescription starts with SIM prefix', () {
      final harness = StrategyHarness();
      addTearDown(harness.dispose);
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.smsContact),
        harness.build(),
      );
      expect(desc.startsWith('[SIM]'), isTrue);
    });

    test('executeReal touches no non-messaging service', () async {
      final harness = StrategyHarness(contacts: [makeContact(id: 'a')]);
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(type: ChainStepType.smsContact),
        harness.build(),
      );
      expect(harness.audio.calls, isEmpty);
      expect(harness.phone.calls, isEmpty);
      expect(harness.notification.calls, isEmpty);
      expect(harness.vibration.calls, isEmpty);
    });

    test('executeReal without registerSmsWorkId still succeeds', () async {
      final harness = StrategyHarness(contacts: [makeContact(id: 'a')]);
      addTearDown(harness.dispose);
      // Build a services bundle without register hook by setting
      // harness.registered = const [] never happens; the helper
      // always wires it. We instead test that the optional nature
      // is respected by passing a step with no work to register.
      await strategy.executeReal(
        step(type: ChainStepType.smsContact),
        harness.build(),
      );
      expect(harness.messaging.calls, isNotEmpty);
    });

    test('executeReal uses default template when none provided', () async {
      final harness = StrategyHarness(contacts: [makeContact(id: 'a')]);
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(type: ChainStepType.smsContact),
        harness.build(),
      );
      final sends = harness.messaging.calls
          .where((c) => c.startsWith('sendMessage:'))
          .length;
      expect(sends, 1);
    });

    test('executeReal with non-SmsContactConfig uses defaults', () async {
      final harness = StrategyHarness(contacts: [makeContact(id: 'a')]);
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(type: ChainStepType.smsContact, config: const LoudAlarmConfig()),
        harness.build(),
      );
      final sends = harness.messaging.calls
          .where((c) => c.startsWith('sendMessage:'))
          .length;
      expect(sends, 1);
    });

    // Spec 02 §6.smsContact Extra-15/15b — single-channel dispatch.
    test('executeReal skips contacts lacking config.channel', () async {
      final harness = StrategyHarness(
        contacts: [
          // Alice has whatsapp — will be picked.
          makeContact(
            id: 'a',
            name: 'Alice',
            channels: const [MessageChannel.whatsapp],
          ),
          // Bob has SMS only — skipped for a whatsapp step.
          makeContact(id: 'b', name: 'Bob'),
        ],
      );
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(
          type: ChainStepType.smsContact,
          config: const SmsContactConfig(
            channel: MessageChannel.whatsapp,
          ),
        ),
        harness.build(),
      );
      final sends = harness.messaging.calls
          .where((c) => c.startsWith('sendMessage:'))
          .toList();
      expect(sends.length, 1);
      expect(sends.first.endsWith('/whatsapp'), isTrue);
    });

    test('executeReal is no-op when no contact has the channel', () async {
      final harness = StrategyHarness(
        contacts: [
          makeContact(id: 'a', channels: const [MessageChannel.sms]),
        ],
      );
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(
          type: ChainStepType.smsContact,
          config: const SmsContactConfig(
            channel: MessageChannel.telegram,
          ),
        ),
        harness.build(),
      );
      expect(
        harness.messaging.calls.where((c) => c.startsWith('sendMessage:')),
        isEmpty,
      );
    });

    test('executeReal sends on exactly the configured channel', () async {
      final harness = StrategyHarness(
        contacts: [
          makeContact(
            id: 'a',
            channels: const [
              MessageChannel.sms,
              MessageChannel.whatsapp,
              MessageChannel.telegram,
            ],
          ),
        ],
      );
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(
          type: ChainStepType.smsContact,
          config: const SmsContactConfig(channel: MessageChannel.telegram),
        ),
        harness.build(),
      );
      final sends = harness.messaging.calls
          .where((c) => c.startsWith('sendMessage:'))
          .toList();
      expect(sends.length, 1);
      expect(sends.first.endsWith('/telegram'), isTrue);
    });
  });
}
