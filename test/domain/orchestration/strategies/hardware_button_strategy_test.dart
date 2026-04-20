/// Tests for [HardwareButtonStrategy].
///
/// Hardware-button detection lives in `TriggerManager`, so this
/// strategy is a deliberate no-op. The tests lock that in.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/orchestration/strategies/hardware_button_strategy.dart';

import '../../../helpers/test_helpers.dart';
import '_strategy_harness.dart';

void main() {
  group('HardwareButtonStrategy', () {
    late StrategyHarness harness;
    late HardwareButtonStrategy strategy;

    setUp(() {
      harness = StrategyHarness();
      strategy = const HardwareButtonStrategy();
    });
    tearDown(() => harness.dispose());

    test('executeReal touches no service', () async {
      await strategy.executeReal(
        step(type: ChainStepType.hardwareButton),
        harness.build(),
      );
      expect(harness.audio.calls, isEmpty);
      expect(harness.messaging.calls, isEmpty);
      expect(harness.phone.calls, isEmpty);
      expect(harness.notification.calls, isEmpty);
      expect(harness.vibration.calls, isEmpty);
    });

    test('executeReal is a no-op in simulation mode', () async {
      final h = StrategyHarness(isSimulation: true);
      addTearDown(h.dispose);
      await strategy.executeReal(
        step(type: ChainStepType.hardwareButton),
        h.build(),
      );
      expect(h.audio.calls, isEmpty);
    });

    test('simulationDescription is non-empty', () {
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.hardwareButton),
        harness.build(),
      );
      expect(desc, isNotEmpty);
    });

    test('simulationDescription mentions hardware', () {
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.hardwareButton),
        harness.build(),
      );
      expect(desc.toLowerCase(), contains('hardware'));
    });

    test('simulationDescription carries SIM prefix', () {
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.hardwareButton),
        harness.build(),
      );
      expect(desc.startsWith('[SIM]'), isTrue);
    });

    test('strategy is const', () {
      const a = HardwareButtonStrategy();
      const b = HardwareButtonStrategy();
      expect(identical(a, b), isTrue);
    });

    test('executeReal on multiple steps stays no-op', () async {
      for (var i = 0; i < 3; i++) {
        await strategy.executeReal(
          step(type: ChainStepType.hardwareButton, order: i),
          harness.build(),
        );
      }
      expect(harness.audio.calls, isEmpty);
    });

    test('executeReal does not register SMS work ids', () async {
      await strategy.executeReal(
        step(type: ChainStepType.hardwareButton),
        harness.build(),
      );
      expect(harness.registered, isEmpty);
    });

    test('simulationDescription stable across invocations', () {
      final a = strategy.simulationDescription(
        step(type: ChainStepType.hardwareButton),
        harness.build(),
      );
      final b = strategy.simulationDescription(
        step(type: ChainStepType.hardwareButton),
        harness.build(),
      );
      expect(a, b);
    });
  });
}
