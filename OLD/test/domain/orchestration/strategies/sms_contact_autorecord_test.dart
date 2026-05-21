/// Supplemental tests for [SmsContactStrategy] covering the
/// `developer.log` path that fires when `autoRecordAudio` or
/// `autoRecordVideo` is true in a real (non-simulation) session.
///
/// The code path only logs — it does NOT touch any service — so the
/// test just verifies that `executeReal` completes without error when
/// the auto-record flags are set.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/strategies/sms_contact_strategy.dart';

import '../../../helpers/test_helpers.dart';
import '_strategy_harness.dart';

void main() {
  group('SmsContactStrategy — auto-record log branch', () {
    late SmsContactStrategy strategy;

    setUp(() => strategy = const SmsContactStrategy());

    test('executeReal completes without error when autoRecordAudio=true '
        'in a real session', () async {
      final harness = StrategyHarness(
        contacts: [makeContact(id: 'c1')],
        isSimulation: false,
      );
      addTearDown(harness.dispose);

      // This exercises the !isSim && autoRecordAudio branch which
      // calls developer.log (no service side-effect yet — TODO).
      await check(
        strategy.executeReal(
          step(
            type: ChainStepType.smsContact,
            config: const SmsContactConfig(
              autoRecordAudio: true,
              contactSelection: SmsContactSelection.allContacts,
            ),
          ),
          harness.build(),
        ),
      ).completes();

      // The strategy still sends the SMS to the contact.
      final sends = harness.messaging.calls
          .where((c) => c.startsWith('sendMessage:'))
          .length;
      check(sends).equals(1);
    });

    test('executeReal completes without error when autoRecordVideo=true '
        'in a real session', () async {
      final harness = StrategyHarness(
        contacts: [makeContact(id: 'c1')],
        isSimulation: false,
      );
      addTearDown(harness.dispose);

      await check(
        strategy.executeReal(
          step(
            type: ChainStepType.smsContact,
            config: const SmsContactConfig(
              autoRecordVideo: true,
              contactSelection: SmsContactSelection.allContacts,
            ),
          ),
          harness.build(),
        ),
      ).completes();
    });

    test('auto-record branch is skipped in simulation mode '
        '(no log, but still sends SMS)', () async {
      final harness = StrategyHarness(
        contacts: [makeContact(id: 'c1')],
        isSimulation: true,
      );
      addTearDown(harness.dispose);

      await strategy.executeReal(
        step(
          type: ChainStepType.smsContact,
          config: const SmsContactConfig(
            autoRecordAudio: true,
            contactSelection: SmsContactSelection.allContacts,
          ),
        ),
        harness.build(),
      );

      // In simulation, sendMessage is still called (simulation branch
      // sends to all contacts).
      final sends = harness.messaging.calls
          .where((c) => c.startsWith('sendMessage:'))
          .length;
      check(sends).equals(1);
    });
  });
}
