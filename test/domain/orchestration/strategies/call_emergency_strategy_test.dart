/// Tests for [CallEmergencyStrategy].
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/strategies/call_emergency_strategy.dart';
import '../../../helpers/test_helpers.dart';
import '_strategy_harness.dart';

void main() {
  group('CallEmergencyStrategy', () {
    late StrategyHarness harness;
    late CallEmergencyStrategy strategy;

    setUp(() {
      harness = StrategyHarness();
      strategy = const CallEmergencyStrategy();
    });
    tearDown(() => harness.dispose());

    test('executeReal dials per-step emergencyNumber when set', () async {
      await strategy.executeReal(
        step(
          type: ChainStepType.callEmergency,
          config: const CallEmergencyConfig(emergencyNumber: '911'),
        ),
        harness.build(),
      );
      expect(harness.phone.calls, contains('callEmergency:911'));
    });

    test('executeReal dials 112 fallback when config null', () async {
      await strategy.executeReal(
        step(type: ChainStepType.callEmergency),
        harness.build(),
      );
      expect(harness.phone.calls, contains('callEmergency:112'));
    });

    test('executeReal dials 112 when emergencyNumber is empty', () async {
      await strategy.executeReal(
        step(
          type: ChainStepType.callEmergency,
          config: const CallEmergencyConfig(emergencyNumber: ''),
        ),
        harness.build(),
      );
      expect(harness.phone.calls, contains('callEmergency:112'));
    });

    test('executeReal dials 112 when wrong config type provided', () async {
      await strategy.executeReal(
        step(
          type: ChainStepType.callEmergency,
          config: const LoudAlarmConfig(),
        ),
        harness.build(),
      );
      expect(harness.phone.calls, contains('callEmergency:112'));
    });

    test('executeReal uses callEmergency, not call', () async {
      await strategy.executeReal(
        step(type: ChainStepType.callEmergency),
        harness.build(),
      );
      final isEmergency = harness.phone.calls.every(
        (c) => c.startsWith('callEmergency:'),
      );
      expect(isEmergency, isTrue);
    });

    test('executeReal does not touch other services', () async {
      await strategy.executeReal(
        step(type: ChainStepType.callEmergency),
        harness.build(),
      );
      expect(harness.audio.calls, isEmpty);
      expect(harness.messaging.calls, isEmpty);
      expect(harness.notification.calls, isEmpty);
      expect(harness.vibration.calls, isEmpty);
    });

    test('simulationDescription includes resolved number', () {
      final desc = strategy.simulationDescription(
        step(
          type: ChainStepType.callEmergency,
          config: const CallEmergencyConfig(emergencyNumber: '911'),
        ),
        harness.build(),
      );
      expect(desc, contains('911'));
    });

    test('simulationDescription includes 112 default', () {
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.callEmergency),
        harness.build(),
      );
      expect(desc, contains('112'));
    });

    test('simulationDescription starts with SIM prefix', () {
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.callEmergency),
        harness.build(),
      );
      expect(desc.startsWith('[SIM]'), isTrue);
    });

    test('simulationDescription mentions "dial"', () {
      final desc = strategy.simulationDescription(
        step(type: ChainStepType.callEmergency),
        harness.build(),
      );
      expect(desc.toLowerCase(), contains('dial'));
    });

    test('executeReal does not register SMS work ids', () async {
      await strategy.executeReal(
        step(type: ChainStepType.callEmergency),
        harness.build(),
      );
      expect(harness.registered, isEmpty);
    });
  });
}
