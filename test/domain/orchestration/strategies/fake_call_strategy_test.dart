/// Tests for [FakeCallStrategy].
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/strategies/fake_call_strategy.dart';
import '../../../helpers/test_helpers.dart';
import '_strategy_harness.dart';

void main() {
  group('FakeCallStrategy', () {
    late StrategyHarness harness;
    late FakeCallStrategy strategy;

    setUp(() {
      harness = StrategyHarness();
      strategy = const FakeCallStrategy();
    });
    tearDown(() => harness.dispose());

    test('executeReal plays ringtone with given asset', () async {
      await strategy.executeReal(
        step(
          type: ChainStepType.fakeCall,
          config: const FakeCallConfig(ringtoneAsset: 'assets/ring.mp3'),
        ),
        harness.build(),
      );
      expect(harness.audio.calls, contains('playRingtone:assets/ring.mp3'));
    });

    test('executeReal plays ringtone with empty asset when null', () async {
      await strategy.executeReal(
        step(type: ChainStepType.fakeCall),
        harness.build(),
      );
      expect(harness.audio.calls, contains('playRingtone:'));
    });

    test('executeReal triggers fakeCallPattern vibration', () async {
      await strategy.executeReal(
        step(type: ChainStepType.fakeCall),
        harness.build(),
      );
      expect(harness.vibration.calls, contains('fakeCallPattern'));
    });

    test('executeReal does not touch other services', () async {
      await strategy.executeReal(
        step(type: ChainStepType.fakeCall),
        harness.build(),
      );
      expect(harness.phone.calls, isEmpty);
      expect(harness.messaging.calls, isEmpty);
      expect(harness.notification.calls, isEmpty);
    });

    test('simulationDescription mentions caller name from config', () {
      final desc = strategy.simulationDescription(
        step(
          type: ChainStepType.fakeCall,
          config: const FakeCallConfig(callerName: 'Alice'),
        ),
        harness.build(),
      );
      expect(desc, contains('Alice'));
    });

    test('simulationDescription defaults to Angela when name null', () {
      // Fix for bugs.json Bug #4: default caller name is "Angela".
      final desc = strategy.simulationDescription(
        step(
          type: ChainStepType.fakeCall,
          config: const FakeCallConfig(callerName: null),
        ),
        harness.build(),
      );
      expect(desc, contains('Angela'));
    });

    test('simulationDescription defaults to Angela with no config', () {
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.fakeCall),
        harness.build(),
      );
      expect(desc, contains('Angela'));
    });

    test('simulationDescription starts with SIM prefix', () {
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.fakeCall),
        harness.build(),
      );
      expect(desc.startsWith('[SIM]'), isTrue);
    });

    test('executeReal does not register any SMS work id', () async {
      await strategy.executeReal(
        step(type: ChainStepType.fakeCall),
        harness.build(),
      );
      expect(harness.registered, isEmpty);
    });

    test('executeReal with wrong config type uses defaults', () async {
      await strategy.executeReal(
        step(type: ChainStepType.fakeCall, config: const LoudAlarmConfig()),
        harness.build(),
      );
      expect(harness.audio.calls, contains('playRingtone:'));
      expect(harness.vibration.calls, contains('fakeCallPattern'));
    });

    test('simulationDescription with wrong config type uses default', () {
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.fakeCall, config: const LoudAlarmConfig()),
        harness.build(),
      );
      expect(desc, contains('Angela'));
    });

    test('executeReal is order-stable: ringtone before vibration', () async {
      await strategy.executeReal(
        step(type: ChainStepType.fakeCall),
        harness.build(),
      );
      final audioIdx = harness.audio.calls.indexOf('playRingtone:');
      final vibrIdx = harness.vibration.calls.indexOf('fakeCallPattern');
      expect(audioIdx, 0);
      expect(vibrIdx, 0);
    });
  });
}
