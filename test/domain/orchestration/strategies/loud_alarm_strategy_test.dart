/// Tests for [LoudAlarmStrategy].
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/strategies/loud_alarm_strategy.dart';
import '../../../helpers/test_helpers.dart';
import '_strategy_harness.dart';

void main() {
  group('LoudAlarmStrategy', () {
    late StrategyHarness harness;
    late LoudAlarmStrategy strategy;

    setUp(() {
      harness = StrategyHarness();
      strategy = const LoudAlarmStrategy();
    });
    tearDown(() => harness.dispose());

    test('executeReal plays alarm with maxVolume=true by default', () async {
      await strategy.executeReal(
        step(type: ChainStepType.loudAlarm),
        harness.build(),
      );
      expect(harness.audio.calls, contains('playAlarm:maxVolume=true'));
    });

    test('executeReal respects maxVolume=false when set', () async {
      await strategy.executeReal(
        step(
          type: ChainStepType.loudAlarm,
          config: const LoudAlarmConfig(maxVolume: false),
        ),
        harness.build(),
      );
      expect(harness.audio.calls, contains('playAlarm:maxVolume=false'));
    });

    test('executeReal triggers alarmPattern vibration', () async {
      await strategy.executeReal(
        step(type: ChainStepType.loudAlarm),
        harness.build(),
      );
      expect(harness.vibration.calls, contains('alarmPattern'));
    });

    test('executeReal does not touch phone/messaging/notification', () async {
      await strategy.executeReal(
        step(type: ChainStepType.loudAlarm),
        harness.build(),
      );
      expect(harness.phone.calls, isEmpty);
      expect(harness.messaging.calls, isEmpty);
      expect(harness.notification.calls, isEmpty);
    });

    test('simulationDescription mentions flash when flashScreen=true', () {
      final desc = strategy.simulationDescription(
        step(
          type: ChainStepType.loudAlarm,
          config: const LoudAlarmConfig(flashScreen: true),
        ),
        harness.build(),
      );
      expect(desc, contains('flash'));
    });

    test('simulationDescription mentions vibrate when flashScreen=false', () {
      final desc = strategy.simulationDescription(
        step(
          type: ChainStepType.loudAlarm,
          config: const LoudAlarmConfig(flashScreen: false),
        ),
        harness.build(),
      );
      expect(desc, contains('vibrate'));
    });

    test('simulationDescription starts with SIM prefix', () {
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.loudAlarm),
        harness.build(),
      );
      expect(desc.startsWith('[SIM]'), isTrue);
    });

    test('simulationDescription mentions alarm', () {
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.loudAlarm),
        harness.build(),
      );
      expect(desc.toLowerCase(), contains('alarm'));
    });

    test('executeReal with wrong config type uses defaults', () async {
      await strategy.executeReal(
        step(type: ChainStepType.loudAlarm, config: const FakeCallConfig()),
        harness.build(),
      );
      expect(harness.audio.calls, contains('playAlarm:maxVolume=true'));
      expect(harness.vibration.calls, contains('alarmPattern'));
    });

    test('executeReal does not register SMS work ids', () async {
      await strategy.executeReal(
        step(type: ChainStepType.loudAlarm),
        harness.build(),
      );
      expect(harness.registered, isEmpty);
    });

    test('executeReal is order-stable: audio before vibration', () async {
      await strategy.executeReal(
        step(type: ChainStepType.loudAlarm),
        harness.build(),
      );
      expect(harness.audio.calls.first, 'playAlarm:maxVolume=true');
      expect(harness.vibration.calls.first, 'alarmPattern');
    });
  });
}
