/// Tests for [CountdownWarningStrategy].
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/strategies/countdown_warning_strategy.dart';

import '../../../helpers/test_helpers.dart';
import '_strategy_harness.dart';

void main() {
  group('CountdownWarningStrategy', () {
    late StrategyHarness harness;
    late CountdownWarningStrategy strategy;

    setUp(() {
      harness = StrategyHarness();
      strategy = const CountdownWarningStrategy();
    });
    tearDown(() => harness.dispose());

    test('executeReal plays warning vibration when vibrate=true', () async {
      await strategy.executeReal(
        step(
          type: ChainStepType.countdownWarning,
          config: const CountdownWarningConfig(vibrate: true),
        ),
        harness.build(),
      );
      expect(harness.vibration.calls, contains('warningPattern'));
    });

    test('executeReal skips vibration when vibrate=false', () async {
      await strategy.executeReal(
        step(
          type: ChainStepType.countdownWarning,
          config: const CountdownWarningConfig(vibrate: false),
        ),
        harness.build(),
      );
      expect(harness.vibration.calls, isEmpty);
    });

    test('executeReal plays soft alarm when playTone=true', () async {
      await strategy.executeReal(
        step(
          type: ChainStepType.countdownWarning,
          config: const CountdownWarningConfig(playTone: true),
        ),
        harness.build(),
      );
      expect(harness.audio.calls, contains('playAlarm:maxVolume=false'));
    });

    test('executeReal does not play alarm when playTone=false', () async {
      await strategy.executeReal(
        step(
          type: ChainStepType.countdownWarning,
          config: const CountdownWarningConfig(playTone: false),
        ),
        harness.build(),
      );
      expect(harness.audio.calls, isEmpty);
    });

    test('executeReal without config uses defaults (vibrate=true)', () async {
      await strategy.executeReal(
        step(type: ChainStepType.countdownWarning),
        harness.build(),
      );
      expect(harness.vibration.calls, contains('warningPattern'));
      expect(harness.audio.calls, isEmpty);
    });

    test('executeReal runs both warnings when both enabled', () async {
      await strategy.executeReal(
        step(
          type: ChainStepType.countdownWarning,
          config: const CountdownWarningConfig(vibrate: true, playTone: true),
        ),
        harness.build(),
      );
      expect(harness.vibration.calls, contains('warningPattern'));
      expect(harness.audio.calls, contains('playAlarm:maxVolume=false'));
    });

    test('executeReal does nothing when both disabled', () async {
      await strategy.executeReal(
        step(
          type: ChainStepType.countdownWarning,
          config: const CountdownWarningConfig(
            vibrate: false,
            playTone: false,
          ),
        ),
        harness.build(),
      );
      expect(harness.vibration.calls, isEmpty);
      expect(harness.audio.calls, isEmpty);
    });

    test('executeReal touches no non-audio/non-vibration service', () async {
      await strategy.executeReal(
        step(
          type: ChainStepType.countdownWarning,
          config: const CountdownWarningConfig(vibrate: true, playTone: true),
        ),
        harness.build(),
      );
      expect(harness.phone.calls, isEmpty);
      expect(harness.messaging.calls, isEmpty);
      expect(harness.notification.calls, isEmpty);
    });

    test('simulationDescription reports the duration', () {
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.countdownWarning, durationSeconds: 42),
        harness.build(),
      );
      expect(desc, contains('42'));
    });

    test('simulationDescription carries SIM prefix', () {
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.countdownWarning, durationSeconds: 10),
        harness.build(),
      );
      expect(desc.startsWith('[SIM]'), isTrue);
    });

    test('simulationDescription mentions countdown/warning', () {
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.countdownWarning, durationSeconds: 10),
        harness.build(),
      );
      expect(
        desc.toLowerCase(),
        anyOf(contains('countdown'), contains('warning')),
      );
    });

    test('executeReal on wrong config type still fires defaults', () async {
      await strategy.executeReal(
        step(
          type: ChainStepType.countdownWarning,
          config: const LoudAlarmConfig(),
        ),
        harness.build(),
      );
      expect(harness.vibration.calls, contains('warningPattern'));
    });
  });
}
