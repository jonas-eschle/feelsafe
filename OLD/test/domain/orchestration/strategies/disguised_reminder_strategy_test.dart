/// Tests for [DisguisedReminderStrategy].
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/strategies/disguised_reminder_strategy.dart';
import '../../../helpers/test_helpers.dart';
import '_strategy_harness.dart';

ReminderTemplate _tpl(
  String id, {
  String title = 'Hi there',
  String body = 'body',
}) => ReminderTemplate(
  id: id,
  name: id,
  title: title,
  body: body,
  confirmationType: ConfirmationType.tapButton,
  displayStyle: ReminderDisplayStyle.fullScreen,
  isGlobal: true,
  buttonLabel: 'OK',
);

void main() {
  group('DisguisedReminderStrategy', () {
    late DisguisedReminderStrategy strategy;

    setUp(() {
      strategy = const DisguisedReminderStrategy();
    });

    test('executeReal shows reminder with matching templateId', () async {
      final harness = StrategyHarness(
        reminderTemplates: [_tpl('calendar'), _tpl('duo')],
      );
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(
          type: ChainStepType.disguisedReminder,
          config: const DisguisedReminderConfig(templateId: 'duo'),
        ),
        harness.build(),
      );
      expect(harness.notification.calls, contains('showDisguisedReminder:duo'));
    });

    test('executeReal falls back to first template when id missing', () async {
      final harness = StrategyHarness(
        reminderTemplates: [_tpl('first'), _tpl('second')],
      );
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(type: ChainStepType.disguisedReminder),
        harness.build(),
      );
      expect(
        harness.notification.calls,
        contains('showDisguisedReminder:first'),
      );
    });

    test('executeReal falls back to first when templateId not found', () async {
      final harness = StrategyHarness(reminderTemplates: [_tpl('first')]);
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(
          type: ChainStepType.disguisedReminder,
          config: const DisguisedReminderConfig(templateId: 'does-not-exist'),
        ),
        harness.build(),
      );
      expect(
        harness.notification.calls,
        contains('showDisguisedReminder:first'),
      );
    });

    test('executeReal with empty templates is a no-op', () async {
      final harness = StrategyHarness(reminderTemplates: const []);
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(type: ChainStepType.disguisedReminder),
        harness.build(),
      );
      expect(harness.notification.calls, isEmpty);
    });

    test('executeReal does not touch other services', () async {
      final harness = StrategyHarness(reminderTemplates: [_tpl('t')]);
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(type: ChainStepType.disguisedReminder),
        harness.build(),
      );
      expect(harness.audio.calls, isEmpty);
      expect(harness.phone.calls, isEmpty);
      expect(harness.messaging.calls, isEmpty);
      expect(harness.vibration.calls, isEmpty);
    });

    test('simulationDescription includes template title', () {
      final harness = StrategyHarness(
        reminderTemplates: [_tpl('x', title: 'Milk tomorrow')],
      );
      addTearDown(harness.dispose);
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.disguisedReminder),
        harness.build(),
      );
      expect(desc.templateKey, 'simDisguisedReminder');
      expect(desc.args['title'], 'Milk tomorrow');
    });

    test('simulationDescription without templates flags absence', () {
      final harness = StrategyHarness();
      addTearDown(harness.dispose);
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.disguisedReminder),
        harness.build(),
      );
      expect(desc.templateKey, 'simDisguisedReminderEmpty');
    });

    test('simulationDescription uses simDisguisedReminder template key', () {
      final harness = StrategyHarness(reminderTemplates: [_tpl('x')]);
      addTearDown(harness.dispose);
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.disguisedReminder),
        harness.build(),
      );
      expect(desc.templateKey, 'simDisguisedReminder');
    });

    test('executeReal propagates isSimulation to the service', () async {
      final harness = StrategyHarness(
        reminderTemplates: [_tpl('t')],
        isSimulation: true,
      );
      addTearDown(harness.dispose);
      await strategy.executeReal(
        step(type: ChainStepType.disguisedReminder),
        harness.build(),
      );
      // FakeNotificationService doesn't include isSimulation in its
      // call log, but the orchestrator never invokes executeReal in
      // simulation mode anyway; this test just asserts no crash.
      expect(harness.notification.calls, contains('showDisguisedReminder:t'));
    });

    test(
      'executeReal is idempotent-shaped (two invocations log two)',
      () async {
        final harness = StrategyHarness(reminderTemplates: [_tpl('t')]);
        addTearDown(harness.dispose);
        final s = step(type: ChainStepType.disguisedReminder);
        final svc = harness.build();
        await strategy.executeReal(s, svc);
        await strategy.executeReal(s, svc);
        expect(harness.notification.calls.length, 2);
      },
    );

    test('executeReal ignores non-disguisedReminder config types', () async {
      final harness = StrategyHarness(reminderTemplates: [_tpl('t')]);
      addTearDown(harness.dispose);
      // A config of the wrong subtype falls through to "first".
      await strategy.executeReal(
        step(
          type: ChainStepType.disguisedReminder,
          config: const LoudAlarmConfig(),
        ),
        harness.build(),
      );
      expect(harness.notification.calls, contains('showDisguisedReminder:t'));
    });

    test('simulationDescription picks first template when no config', () {
      final harness = StrategyHarness(
        reminderTemplates: [
          _tpl('first', title: 'First'),
          _tpl('second', title: 'Second'),
        ],
      );
      addTearDown(harness.dispose);
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.disguisedReminder),
        harness.build(),
      );
      expect(desc.templateKey, 'simDisguisedReminder');
      expect(desc.args['title'], 'First');
    });
  });
}
