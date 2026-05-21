import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/pause_reason.dart';
import 'package:guardianangela/domain/models/walk_session.dart';

WalkSession _bare({
  String id = 'session-1',
  String modeId = 'mode-walk',
  bool isSimulation = false,
  DateTime? startedAt,
  SessionPhase phase = const SessionPhaseActive(),
  double simulationSpeed = 1.0,
  int currentStepIndex = 0,
  ChainStepType? currentStepType,
  int missCount = 0,
  int? remainingSeconds,
  Duration simulatedElapsed = Duration.zero,
  List<SimulationDescription>? firedStepDescriptions,
  SimulationDescription? lastSimulationDescription,
  bool isBackgroundAlert = false,
  int totalSteps = 5,
  bool simulationSilent = false,
}) => WalkSession(
  id: id,
  modeId: modeId,
  isSimulation: isSimulation,
  startedAt: startedAt ?? DateTime.utc(2026, 5, 21, 10),
  phase: phase,
  simulationSpeed: simulationSpeed,
  currentStepIndex: currentStepIndex,
  currentStepType: currentStepType,
  missCount: missCount,
  remainingSeconds: remainingSeconds,
  simulatedElapsed: simulatedElapsed,
  firedStepDescriptions: firedStepDescriptions ?? const [],
  lastSimulationDescription: lastSimulationDescription,
  isBackgroundAlert: isBackgroundAlert,
  totalSteps: totalSteps,
  simulationSilent: simulationSilent,
);

void main() {
  group('WalkSession', () {
    group('startingReal named constructor (Q16)', () {
      test('sets isSimulation = false', () {
        // Given: a real session being kicked off by SessionController.
        // When: WalkSession.startingReal(...) is called.
        // Then: isSimulation is false — destructive actions are armed.
        final session = WalkSession.startingReal(
          id: 's1',
          modeId: 'walk',
          startedAt: DateTime.utc(2026, 5, 21),
          totalSteps: 5,
        );
        check(session.isSimulation).isFalse();
      });

      test('sets simulationSilent = false for real sessions', () {
        // Given: a real session.
        // When: startingReal is called.
        // Then: simulationSilent is false (the alarm/audio is live).
        final session = WalkSession.startingReal(
          id: 's1',
          modeId: 'walk',
          startedAt: DateTime.utc(2026, 5, 21),
          totalSteps: 5,
        );
        check(session.simulationSilent).isFalse();
      });

      test('initial phase is SessionPhaseActive', () {
        // Given: a brand-new real session.
        // When: startingReal.
        // Then: phase is Active (engine starts running immediately).
        final session = WalkSession.startingReal(
          id: 's1',
          modeId: 'walk',
          startedAt: DateTime.utc(2026, 5, 21),
          totalSteps: 5,
        );
        check(session.phase).isA<SessionPhaseActive>();
      });

      test('initial counters start at zero', () {
        // Given: a real session.
        // When: just started.
        // Then: currentStepIndex, missCount, simulatedElapsed are zero.
        final session = WalkSession.startingReal(
          id: 's1',
          modeId: 'walk',
          startedAt: DateTime.utc(2026, 5, 21),
          totalSteps: 5,
        );
        check(session.currentStepIndex).equals(0);
        check(session.missCount).equals(0);
        check(session.simulatedElapsed).equals(Duration.zero);
        check(session.firedStepDescriptions).isEmpty();
      });

      test('isBackgroundAlert defaults to false (foreground real session)', () {
        final session = WalkSession.startingReal(
          id: 's1',
          modeId: 'walk',
          startedAt: DateTime.utc(2026, 5, 21),
          totalSteps: 5,
        );
        check(session.isBackgroundAlert).isFalse();
      });

      test(
        'simulationSpeed defaults to 1.0 (no speed-up in real sessions)',
        () {
          final session = WalkSession.startingReal(
            id: 's1',
            modeId: 'walk',
            startedAt: DateTime.utc(2026, 5, 21),
            totalSteps: 5,
          );
          check(session.simulationSpeed).equals(1.0);
        },
      );

      test('totalSteps reflects the chain length passed in', () {
        final session = WalkSession.startingReal(
          id: 's1',
          modeId: 'walk',
          startedAt: DateTime.utc(2026, 5, 21),
          totalSteps: 9,
        );
        check(session.totalSteps).equals(9);
      });
    });

    group('startingSimulation named constructor (Q16)', () {
      test('sets isSimulation = true', () {
        // Given: a simulation session (practice).
        // When: startingSimulation is called.
        // Then: isSimulation is true — destructive actions are blocked.
        final session = WalkSession.startingSimulation(
          id: 's1',
          modeId: 'walk',
          startedAt: DateTime.utc(2026, 5, 21),
          totalSteps: 5,
        );
        check(session.isSimulation).isTrue();
      });

      test('simulationSilent defaults to true (Extra 49)', () {
        // Given: a simulation session.
        // When: startingSimulation is called WITHOUT silent argument.
        // Then: simulationSilent defaults to true — practice is silent.
        final session = WalkSession.startingSimulation(
          id: 's1',
          modeId: 'walk',
          startedAt: DateTime.utc(2026, 5, 21),
          totalSteps: 5,
        );
        check(session.simulationSilent).isTrue();
      });

      test('caller can opt into audible simulation with silent: false', () {
        // Given: a simulation with silent: false override.
        // When: startingSimulation called.
        // Then: simulationSilent is false — audio plays during practice.
        final session = WalkSession.startingSimulation(
          id: 's1',
          modeId: 'walk',
          startedAt: DateTime.utc(2026, 5, 21),
          totalSteps: 5,
          silent: false,
        );
        check(session.simulationSilent).isFalse();
      });

      test('initial phase is SessionPhaseActive', () {
        final session = WalkSession.startingSimulation(
          id: 's1',
          modeId: 'walk',
          startedAt: DateTime.utc(2026, 5, 21),
          totalSteps: 5,
        );
        check(session.phase).isA<SessionPhaseActive>();
      });

      test('startingSimulation has counters at zero', () {
        final session = WalkSession.startingSimulation(
          id: 's1',
          modeId: 'walk',
          startedAt: DateTime.utc(2026, 5, 21),
          totalSteps: 5,
        );
        check(session.currentStepIndex).equals(0);
        check(session.missCount).equals(0);
        check(session.simulatedElapsed).equals(Duration.zero);
        check(session.firedStepDescriptions).isEmpty();
      });
    });

    group('SessionPhase sealed hierarchy', () {
      test('SessionPhase has exactly three concrete subtypes', () {
        // Given: the sealed SessionPhase hierarchy.
        // When: instantiated.
        // Then: Active / Paused / Ended all match the parent type.
        const SessionPhase active = SessionPhaseActive();
        const SessionPhase paused = SessionPhasePaused(
          reason: PauseReason.userRequested,
        );
        const SessionPhase ended = SessionPhaseEnded();
        check(active).isA<SessionPhase>();
        check(paused).isA<SessionPhase>();
        check(ended).isA<SessionPhase>();
      });

      test('SessionPhaseActive instances are equal (no fields)', () {
        // Given: two Active phases.
        // When: compared.
        // Then: equal and share hashCode.
        const a = SessionPhaseActive();
        const b = SessionPhaseActive();
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('SessionPhaseEnded instances are equal (no fields)', () {
        const a = SessionPhaseEnded();
        const b = SessionPhaseEnded();
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('SessionPhasePaused equality depends on PauseReason', () {
        // Given: two paused phases with the same reason.
        // When: compared.
        // Then: equal; differing reason breaks equality.
        const a = SessionPhasePaused(reason: PauseReason.userRequested);
        const b = SessionPhasePaused(reason: PauseReason.userRequested);
        const c = SessionPhasePaused(reason: PauseReason.incomingCall);
        check(a).equals(b);
        check(a).not((it) => it.equals(c));
      });

      test('SessionPhaseActive != SessionPhaseEnded', () {
        // Given: two different phase variants.
        // When: compared.
        // Then: not equal.
        const SessionPhase a = SessionPhaseActive();
        const SessionPhase b = SessionPhaseEnded();
        check(a).not((it) => it.equals(b));
      });

      test('SessionPhaseActive != SessionPhasePaused', () {
        const SessionPhase a = SessionPhaseActive();
        const SessionPhase b = SessionPhasePaused(
          reason: PauseReason.userRequested,
        );
        check(a).not((it) => it.equals(b));
      });

      test('PauseReason has no bootRestart (lessons §5.2)', () {
        // Given: the PauseReason enum.
        // When: querying for 'bootRestart'.
        // Then: throws — session state never resumes from disk.
        check(
          () => PauseReason.values.byName('bootRestart'),
        ).throws<ArgumentError>();
      });

      test('PauseReason has no fakeCallAnswered (lessons §5.3)', () {
        // Given: fake call is an event, not a pause.
        // When: querying for 'fakeCallAnswered'.
        // Then: throws — engine keeps ticking through the fake call.
        check(
          () => PauseReason.values.byName('fakeCallAnswered'),
        ).throws<ArgumentError>();
      });

      test('PauseReason has exactly two spec-defined values', () {
        final names = PauseReason.values.map((e) => e.name).toSet();
        check(names).deepEquals({'userRequested', 'incomingCall'});
      });
    });

    group('persistence — no toJson/fromJson (ephemeral, spec 03)', () {
      test('WalkSession instance has no toJson method (ephemeral)', () {
        // Given: WalkSession is documented as ephemeral / not persisted
        //       (spec 03 §WalkSession; lessons §5.2 no resume-from-disk).
        // When: introspected for a `toJson` method.
        // Then: no such method exists on the type.
        final session = _bare();
        check(session.toString()).isNotNull();
        // Verify the symbol does not exist via dynamic dispatch — calling
        // toJson on a WalkSession must fail at runtime.
        // ignore: avoid_dynamic_calls
        check(() => (session as dynamic).toJson()).throws<NoSuchMethodError>();
      });
    });

    group('equality and hashCode', () {
      test('two identical WalkSessions are equal', () {
        // Given: two sessions built with identical fields.
        // When: compared.
        // Then: equal AND share a hashCode.
        final a = _bare();
        final b = _bare();
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('differing id breaks equality', () {
        final a = _bare();
        final b = _bare(id: 'other');
        check(a).not((it) => it.equals(b));
      });

      test('differing modeId breaks equality', () {
        final a = _bare();
        final b = _bare(modeId: 'other-mode');
        check(a).not((it) => it.equals(b));
      });

      test('differing phase variant breaks equality', () {
        final a = _bare();
        final b = _bare(phase: const SessionPhaseEnded());
        check(a).not((it) => it.equals(b));
      });

      test('differing currentStepIndex breaks equality', () {
        final a = _bare();
        final b = _bare(currentStepIndex: 2);
        check(a).not((it) => it.equals(b));
      });

      test('differing currentStepType breaks equality', () {
        final a = _bare(currentStepType: ChainStepType.holdButton);
        final b = _bare(currentStepType: ChainStepType.fakeCall);
        check(a).not((it) => it.equals(b));
      });

      test('differing missCount breaks equality', () {
        final a = _bare();
        final b = _bare(missCount: 1);
        check(a).not((it) => it.equals(b));
      });

      test('differing remainingSeconds breaks equality', () {
        final a = _bare();
        final b = _bare(remainingSeconds: 5);
        check(a).not((it) => it.equals(b));
      });

      test('differing simulatedElapsed breaks equality', () {
        final a = _bare();
        final b = _bare(simulatedElapsed: const Duration(seconds: 30));
        check(a).not((it) => it.equals(b));
      });

      test('differing isBackgroundAlert breaks equality', () {
        final a = _bare();
        final b = _bare(isBackgroundAlert: true);
        check(a).not((it) => it.equals(b));
      });

      test('differing totalSteps breaks equality', () {
        final a = _bare();
        final b = _bare(totalSteps: 6);
        check(a).not((it) => it.equals(b));
      });

      test('differing simulationSilent breaks equality', () {
        final a = _bare();
        final b = _bare(simulationSilent: true);
        check(a).not((it) => it.equals(b));
      });

      test('differing simulationSpeed breaks equality', () {
        final a = _bare();
        final b = _bare(simulationSpeed: 10.0);
        check(a).not((it) => it.equals(b));
      });

      test('differing firedStepDescriptions length breaks equality', () {
        final a = _bare();
        final b = _bare(
          firedStepDescriptions: const [
            SimulationDescription(
              stepIndex: 0,
              stepType: ChainStepType.holdButton,
              text: 'fired',
            ),
          ],
        );
        check(a).not((it) => it.equals(b));
      });

      test('differing firedStepDescriptions element breaks equality', () {
        const a = SimulationDescription(
          stepIndex: 0,
          stepType: ChainStepType.holdButton,
          text: 'A',
        );
        const b = SimulationDescription(
          stepIndex: 0,
          stepType: ChainStepType.holdButton,
          text: 'B',
        );
        final s1 = _bare(firedStepDescriptions: const [a]);
        final s2 = _bare(firedStepDescriptions: const [b]);
        check(s1).not((it) => it.equals(s2));
      });

      test('not equal to unrelated type', () {
        final WalkSession s = _bare();
        const Object notASession = 'not a session';
        check(s == notASession).isFalse();
      });
    });

    group('copyWith', () {
      test('copyWith without args returns equal session', () {
        final original = _bare();
        final copy = original.copyWith();
        check(copy).equals(original);
      });

      test('copyWith advances currentStepIndex without touching others', () {
        final original = _bare();
        final copy = original.copyWith(currentStepIndex: 1);
        check(copy.currentStepIndex).equals(1);
        check(copy.id).equals(original.id);
        check(copy.modeId).equals(original.modeId);
      });

      test('copyWith transitions phase to Paused', () {
        final original = _bare();
        final copy = original.copyWith(
          phase: const SessionPhasePaused(reason: PauseReason.incomingCall),
        );
        check(copy.phase).isA<SessionPhasePaused>();
        // ignore: cast_nullable_to_non_nullable
        final paused = copy.phase as SessionPhasePaused;
        check(paused.reason).equals(PauseReason.incomingCall);
      });

      test('copyWith transitions phase to Ended', () {
        final original = _bare();
        final copy = original.copyWith(phase: const SessionPhaseEnded());
        check(copy.phase).isA<SessionPhaseEnded>();
      });
    });

    group('SimulationDescription', () {
      test('two identical SimulationDescriptions are equal', () {
        const a = SimulationDescription(
          stepIndex: 1,
          stepType: ChainStepType.fakeCall,
          text: 'Fake call rings',
        );
        const b = SimulationDescription(
          stepIndex: 1,
          stepType: ChainStepType.fakeCall,
          text: 'Fake call rings',
        );
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('differing stepIndex breaks equality', () {
        const a = SimulationDescription(
          stepIndex: 0,
          stepType: ChainStepType.fakeCall,
          text: 'text',
        );
        const b = SimulationDescription(
          stepIndex: 1,
          stepType: ChainStepType.fakeCall,
          text: 'text',
        );
        check(a).not((it) => it.equals(b));
      });

      test('differing stepType breaks equality', () {
        const a = SimulationDescription(
          stepIndex: 0,
          stepType: ChainStepType.holdButton,
          text: 'text',
        );
        const b = SimulationDescription(
          stepIndex: 0,
          stepType: ChainStepType.fakeCall,
          text: 'text',
        );
        check(a).not((it) => it.equals(b));
      });

      test('differing text breaks equality', () {
        const a = SimulationDescription(
          stepIndex: 0,
          stepType: ChainStepType.holdButton,
          text: 'A',
        );
        const b = SimulationDescription(
          stepIndex: 0,
          stepType: ChainStepType.holdButton,
          text: 'B',
        );
        check(a).not((it) => it.equals(b));
      });
    });
  });
}
