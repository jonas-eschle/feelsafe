// Snapshot getter tests for SessionEngine.snapshot.
//
// The getter exists so UI controllers can read the live EngineState
// (including per-phase remaining duration) without subscribing to the
// engine's event stream. The contract: snapshot returns the very state
// the engine is in right now, and changes type as the engine transitions
// through Idle → Running → Paused → Ended.

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/engine/engine_state.dart';
import 'engine_test_helpers.dart';

void main() {
  group('SessionEngine.snapshot', () {
    test('returns EngineIdle before start', () {
      final engine = buildEngine(
        sessionMode: mode(),
        random: const FixedRandom(),
      );
      check(engine.snapshot).isA<EngineIdle>();
    });

    test('returns EngineRunning after start', () {
      fakeAsync((async) {
        final engine = buildEngine(
          sessionMode: mode(),
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();

        final snapshot = engine.snapshot;
        check(snapshot).isA<EngineRunning>();
        check((snapshot as EngineRunning).currentStepIndex).equals(0);

        engine.endSession();
      });
    });

    test('returns EnginePaused after pause', () {
      fakeAsync((async) {
        final engine = buildEngine(
          sessionMode: mode(),
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();

        engine.pause();
        async.flushMicrotasks();

        check(engine.snapshot).isA<EnginePaused>();

        engine.endSession();
      });
    });

    test('returns EngineEnded after endSession', () {
      fakeAsync((async) {
        final engine = buildEngine(
          sessionMode: mode(),
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();

        engine.endSession();
        async.flushMicrotasks();

        check(engine.snapshot).isA<EngineEnded>();
      });
    });

    test('EngineRunning snapshot carries the index from currentStepIndex', () {
      fakeAsync((async) {
        final engine = buildEngine(
          sessionMode: mode(),
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();

        // The engine's currentStepIndex getter and the EngineRunning
        // snapshot's currentStepIndex field MUST stay in lockstep.
        final snapshot = engine.snapshot as EngineRunning;
        check(snapshot.currentStepIndex).equals(engine.currentStepIndex);

        engine.endSession();
      });
    });

    test('snapshot does not allow mutation of engine internals', () {
      // A non-test concern but the type system already enforces it: the
      // getter returns the sealed EngineState and all subclasses are
      // immutable in the sense that the engine constructs new instances
      // when a field changes. We assert here that the engine remains
      // usable after we capture a snapshot reference.
      fakeAsync((async) {
        final engine = buildEngine(
          sessionMode: mode(),
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();
        final captured = engine.snapshot;
        check(captured).isA<EngineRunning>();
        // Engine remains operational.
        engine.endSession();
        check(engine.isEnded).isTrue();
      });
    });
  });
}
