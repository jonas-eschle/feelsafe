/// Tests for [WalkSession] named constructors.
///
/// Verifies that `WalkSession.startingReal` produces correct defaults
/// for a real session and that `WalkSession.startingSimulation` sets
/// the simulation flags correctly — including the `silent` parameter.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/models/walk_session.dart';

void main() {
  final start = DateTime.utc(2026, 5, 1, 12);

  group('WalkSession.startingReal', () {
    test('isSimulation is false', () {
      final s = WalkSession.startingReal(
        id: 'r1',
        modeId: 'm1',
        startedAt: start,
      );
      check(s.isSimulation).isFalse();
    });

    test('simulationSilent is false', () {
      final s = WalkSession.startingReal(
        id: 'r1',
        modeId: 'm1',
        startedAt: start,
      );
      check(s.simulationSilent).isFalse();
    });

    test('simulationSpeed is 1.0', () {
      final s = WalkSession.startingReal(
        id: 'r1',
        modeId: 'm1',
        startedAt: start,
      );
      check(s.simulationSpeed).equals(1.0);
    });

    test('phase starts as idle', () {
      final s = WalkSession.startingReal(
        id: 'r1',
        modeId: 'm1',
        startedAt: start,
      );
      check(s.phase).isA<SessionPhaseIdle>();
    });

    test('id and modeId are propagated', () {
      final s = WalkSession.startingReal(
        id: 'real-session-xyz',
        modeId: 'mode-abc',
        startedAt: start,
      );
      check(s.id).equals('real-session-xyz');
      check(s.modeId).equals('mode-abc');
    });

    test('isBackgroundAlert defaults to false', () {
      final s = WalkSession.startingReal(
        id: 'r1',
        modeId: 'm1',
        startedAt: start,
      );
      check(s.isBackgroundAlert).isFalse();
    });

    test('isBackgroundAlert can be set to true', () {
      final s = WalkSession.startingReal(
        id: 'r1',
        modeId: 'm1',
        startedAt: start,
        isBackgroundAlert: true,
      );
      check(s.isBackgroundAlert).isTrue();
    });
  });

  group('WalkSession.startingSimulation', () {
    test('isSimulation is true', () {
      final s = WalkSession.startingSimulation(
        id: 's1',
        modeId: 'm1',
        startedAt: start,
      );
      check(s.isSimulation).isTrue();
    });

    test('simulationSilent is false by default', () {
      final s = WalkSession.startingSimulation(
        id: 's1',
        modeId: 'm1',
        startedAt: start,
      );
      check(s.simulationSilent).isFalse();
    });

    test('silent=true sets simulationSilent to true', () {
      final s = WalkSession.startingSimulation(
        id: 's1',
        modeId: 'm1',
        startedAt: start,
        silent: true,
      );
      check(s.simulationSilent).isTrue();
    });

    test('silent=false keeps simulationSilent false', () {
      final s = WalkSession.startingSimulation(
        id: 's1',
        modeId: 'm1',
        startedAt: start,
        // ignore: avoid_redundant_argument_values
        silent: false,
      );
      check(s.simulationSilent).isFalse();
    });

    test('simulationSpeed defaults to 1.0', () {
      final s = WalkSession.startingSimulation(
        id: 's1',
        modeId: 'm1',
        startedAt: start,
      );
      check(s.simulationSpeed).equals(1.0);
    });

    test('custom simulationSpeed is preserved', () {
      final s = WalkSession.startingSimulation(
        id: 's1',
        modeId: 'm1',
        startedAt: start,
        simulationSpeed: 10.0,
      );
      check(s.simulationSpeed).equals(10.0);
    });

    test('phase starts as idle', () {
      final s = WalkSession.startingSimulation(
        id: 's1',
        modeId: 'm1',
        startedAt: start,
      );
      check(s.phase).isA<SessionPhaseIdle>();
    });
  });

  group('WalkSession — startingReal vs startingSimulation differ on flags', () {
    test('only startingSimulation has isSimulation=true', () {
      final real = WalkSession.startingReal(
        id: 'r',
        modeId: 'm',
        startedAt: start,
      );
      final sim = WalkSession.startingSimulation(
        id: 's',
        modeId: 'm',
        startedAt: start,
      );
      check(real.isSimulation).isFalse();
      check(sim.isSimulation).isTrue();
    });

    test('startingReal always has simulationSilent=false regardless of args',
        () {
      // Real sessions don't have a silent parameter — it's always false.
      final real = WalkSession.startingReal(
        id: 'r',
        modeId: 'm',
        startedAt: start,
      );
      check(real.simulationSilent).isFalse();
    });
  });
}
