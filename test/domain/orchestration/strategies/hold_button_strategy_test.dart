/// Tests for [HoldButtonStrategy].
///
/// This strategy is a deliberate no-op: hold detection lives UI-side
/// and the engine responds via `holdStart()` / `holdRelease()`. The
/// tests just assert that the strategy touches nothing and returns
/// a non-empty sim description.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/orchestration/strategies/hold_button_strategy.dart';
import '../../../helpers/test_helpers.dart';
import '_strategy_harness.dart';

void main() {
  group('HoldButtonStrategy', () {
    late StrategyHarness harness;
    late HoldButtonStrategy strategy;

    setUp(() {
      harness = StrategyHarness();
      strategy = const HoldButtonStrategy();
    });
    tearDown(() => harness.dispose());

    test('executeReal touches no service', () async {
      await strategy.executeReal(
        step(type: ChainStepType.holdButton),
        harness.build(),
      );
      expect(harness.audio.calls, isEmpty);
      expect(harness.messaging.calls, isEmpty);
      expect(harness.phone.calls, isEmpty);
      expect(harness.notification.calls, isEmpty);
      expect(harness.vibration.calls, isEmpty);
    });

    test('simulationDescription is non-empty', () {
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.holdButton),
        harness.build(),
      );
      expect(desc, isNotEmpty);
    });

    test('simulationDescription uses simHoldButton template key', () {
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.holdButton),
        harness.build(),
      );
      expect(desc.templateKey, 'simHoldButton');
    });

    test('simulationDescription carries no args', () {
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.holdButton),
        harness.build(),
      );
      expect(desc.args, isEmpty);
    });

    test('executeReal works with isSimulation=true as well', () async {
      final h = StrategyHarness(isSimulation: true);
      addTearDown(h.dispose);
      await strategy.executeReal(
        step(type: ChainStepType.holdButton),
        h.build(),
      );
      expect(h.audio.calls, isEmpty);
      expect(h.messaging.calls, isEmpty);
      expect(h.phone.calls, isEmpty);
      expect(h.notification.calls, isEmpty);
      expect(h.vibration.calls, isEmpty);
    });

    test('executeReal does not register SMS work ids', () async {
      await strategy.executeReal(
        step(type: ChainStepType.holdButton),
        harness.build(),
      );
      expect(harness.registered, isEmpty);
    });

    test('strategy is const', () {
      const a = HoldButtonStrategy();
      const b = HoldButtonStrategy();
      expect(identical(a, b), isTrue);
    });

    test('executeReal on multiple steps stays no-op', () async {
      for (var i = 0; i < 5; i++) {
        await strategy.executeReal(
          step(type: ChainStepType.holdButton, order: i),
          harness.build(),
        );
      }
      expect(harness.audio.calls, isEmpty);
      expect(harness.vibration.calls, isEmpty);
    });

    test('simulationDescription stable across invocations', () {
      final a = strategy.simulationDescription(
        step(type: ChainStepType.holdButton),
        harness.build(),
      );
      final b = strategy.simulationDescription(
        step(type: ChainStepType.holdButton),
        harness.build(),
      );
      expect(a, b);
    });

    test('executeReal ignores step config shape', () async {
      await strategy.executeReal(
        holdStep(releaseSensitivity: 0.9),
        harness.build(),
      );
      expect(harness.audio.calls, isEmpty);
    });
  });
}
