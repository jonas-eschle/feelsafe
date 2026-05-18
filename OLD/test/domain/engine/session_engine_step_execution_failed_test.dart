/// Tests for `SessionEngine.emitStepExecutionFailed`.
///
/// Asserts that calling `emitStepExecutionFailed` emits a
/// `ChainEvent.stepExecutionFailed` event with the correct stepIndex
/// and stepType, and that the engine keeps running after the call
/// (D-STRATEGY-2: the chain is not interrupted by a strategy error).
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('emitStepExecutionFailed', () {
    test('emits stepExecutionFailed with the given stepIndex', () {
      final engine = SessionEngine(
        chainSteps: [smsStep(order: 0), smsStep(order: 1)],
        random: FixedRandom(),
      );
      addTearDown(engine.dispose);
      final events = <ChainEventData>[];
      engine.events.listen(events.add);
      engine.start();

      final targetStep = smsStep(order: 0);
      engine.emitStepExecutionFailed(stepIndex: 0, step: targetStep);

      final failed =
          events.where((e) => e.event == ChainEvent.stepExecutionFailed);
      check(failed.length).equals(1);
      check(failed.first.stepIndex).equals(0);
    });

    test('emits stepExecutionFailed with the correct stepType', () {
      final engine = SessionEngine(
        chainSteps: [smsStep(order: 0)],
        random: FixedRandom(),
      );
      addTearDown(engine.dispose);
      final events = <ChainEventData>[];
      engine.events.listen(events.add);
      engine.start();

      final sms = smsStep(order: 0);
      engine.emitStepExecutionFailed(stepIndex: 0, step: sms);

      final ev =
          events.firstWhere((e) => e.event == ChainEvent.stepExecutionFailed);
      check(ev.stepType).equals(ChainStepType.smsContact);
    });

    test('engine remains in EngineRunning after emitStepExecutionFailed', () {
      final engine = SessionEngine(
        chainSteps: [smsStep(order: 0)],
        random: FixedRandom(),
      );
      addTearDown(engine.dispose);
      engine.start();

      engine.emitStepExecutionFailed(
        stepIndex: 0,
        step: smsStep(order: 0),
      );

      check(engine.state).isA<EngineRunning>();
    });

    test('emits stepExecutionFailed for holdButton stepType', () {
      final engine = SessionEngine(
        chainSteps: [holdStep(order: 0)],
        random: FixedRandom(),
      );
      addTearDown(engine.dispose);
      final events = <ChainEventData>[];
      engine.events.listen(events.add);
      engine.start();

      final hold = holdStep(order: 0);
      engine.emitStepExecutionFailed(stepIndex: 0, step: hold);

      final ev =
          events.firstWhere((e) => e.event == ChainEvent.stepExecutionFailed);
      check(ev.stepType).equals(ChainStepType.holdButton);
      check(ev.stepIndex).equals(0);
    });

    test(
        'stepExecutionFailed can be emitted from idle engine without crashing',
        () {
      // The orchestrator may call this before the engine moves to the next
      // step if the strategy throws synchronously — the engine must not crash.
      final engine = SessionEngine(
        chainSteps: [smsStep(order: 0)],
        random: FixedRandom(),
      );
      addTearDown(engine.dispose);
      final events = <ChainEventData>[];
      engine.events.listen(events.add);

      // No start() — emitting from Idle must not throw.
      engine.emitStepExecutionFailed(stepIndex: 0, step: smsStep(order: 0));

      final failedCount =
          events.where((e) => e.event == ChainEvent.stepExecutionFailed).length;
      check(failedCount).equals(1);
      check(engine.state).isA<EngineIdle>();
    });
  });
}
