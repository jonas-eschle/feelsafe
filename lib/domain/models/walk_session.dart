import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/pause_reason.dart';

/// Ephemeral UI-layer snapshot of the active session.
///
/// **Not persisted** — derived from engine events by [SessionController].
/// App death = session is gone (no resume-from-disk per lessons §5.2).
/// Named constructors enforce correct initialisation for real vs.
/// simulation sessions. See spec 03 §WalkSession.
final class WalkSession {
  /// Creates a [WalkSession] directly.
  ///
  /// Prefer [WalkSession.startingReal] or [WalkSession.startingSimulation]
  /// when kicking off a new session.
  const WalkSession({
    required this.id,
    required this.modeId,
    required this.isSimulation,
    required this.startedAt,
    required this.phase,
    this.simulationSpeed = 1.0,
    required this.currentStepIndex,
    this.currentStepType,
    required this.missCount,
    this.remainingSeconds,
    required this.simulatedElapsed,
    required this.firedStepDescriptions,
    this.lastSimulationDescription,
    required this.isBackgroundAlert,
    required this.totalSteps,
    required this.simulationSilent,
  });

  /// Initialises a real (non-simulation) session.
  factory WalkSession.startingReal({
    required String id,
    required String modeId,
    required DateTime startedAt,
    required int totalSteps,
  }) => WalkSession(
    id: id,
    modeId: modeId,
    isSimulation: false,
    startedAt: startedAt,
    phase: const SessionPhaseActive(),
    currentStepIndex: 0,
    missCount: 0,
    simulatedElapsed: Duration.zero,
    firedStepDescriptions: const [],
    isBackgroundAlert: false,
    totalSteps: totalSteps,
    simulationSilent: false,
  );

  /// Initialises a simulation session.
  ///
  /// [silent] defaults to true per Extra 49 (silent practice by default).
  factory WalkSession.startingSimulation({
    required String id,
    required String modeId,
    required DateTime startedAt,
    required int totalSteps,
    bool silent = true,
  }) => WalkSession(
    id: id,
    modeId: modeId,
    isSimulation: true,
    startedAt: startedAt,
    phase: const SessionPhaseActive(),
    currentStepIndex: 0,
    missCount: 0,
    simulatedElapsed: Duration.zero,
    firedStepDescriptions: const [],
    isBackgroundAlert: false,
    totalSteps: totalSteps,
    simulationSilent: silent,
  );

  /// UUID identifying this session run.
  final String id;

  /// UUID of the [SessionMode] running in this session.
  final String modeId;

  /// Whether this is a simulation (practice) session.
  final bool isSimulation;

  /// UTC timestamp when the session started.
  final DateTime startedAt;

  /// Current phase of the session lifecycle.
  final SessionPhase phase;

  /// Speed multiplier for simulation (1x–1000x in foreground). Default 1.0.
  final double simulationSpeed;

  /// 0-based index of the currently executing chain step.
  final int currentStepIndex;

  /// Type of the currently executing step (null if session is idle/ended).
  final ChainStepType? currentStepType;

  /// Number of missed check-ins so far.
  final int missCount;

  /// Seconds remaining in the current phase window (null if not applicable).
  final int? remainingSeconds;

  /// Simulated time elapsed, accounting for the speed multiplier.
  final Duration simulatedElapsed;

  /// Descriptions of all steps that have fired, for the simulation summary.
  final List<SimulationDescription> firedStepDescriptions;

  /// Description of the most recently fired step (for simulation toasts).
  final SimulationDescription? lastSimulationDescription;

  /// Whether this snapshot is from the background battery-alert engine.
  final bool isBackgroundAlert;

  /// Total number of steps in the chain.
  final int totalSteps;

  /// Whether audio is suppressed in this simulation session.
  ///
  /// Defaults to true per Extra 49. Never persisted — resets each session.
  final bool simulationSilent;

  /// Returns a copy with the specified fields replaced.
  WalkSession copyWith({
    String? id,
    String? modeId,
    bool? isSimulation,
    DateTime? startedAt,
    SessionPhase? phase,
    double? simulationSpeed,
    int? currentStepIndex,
    ChainStepType? currentStepType,
    int? missCount,
    int? remainingSeconds,
    Duration? simulatedElapsed,
    List<SimulationDescription>? firedStepDescriptions,
    SimulationDescription? lastSimulationDescription,
    bool? isBackgroundAlert,
    int? totalSteps,
    bool? simulationSilent,
  }) => WalkSession(
    id: id ?? this.id,
    modeId: modeId ?? this.modeId,
    isSimulation: isSimulation ?? this.isSimulation,
    startedAt: startedAt ?? this.startedAt,
    phase: phase ?? this.phase,
    simulationSpeed: simulationSpeed ?? this.simulationSpeed,
    currentStepIndex: currentStepIndex ?? this.currentStepIndex,
    currentStepType: currentStepType ?? this.currentStepType,
    missCount: missCount ?? this.missCount,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    simulatedElapsed: simulatedElapsed ?? this.simulatedElapsed,
    firedStepDescriptions: firedStepDescriptions ?? this.firedStepDescriptions,
    lastSimulationDescription:
        lastSimulationDescription ?? this.lastSimulationDescription,
    isBackgroundAlert: isBackgroundAlert ?? this.isBackgroundAlert,
    totalSteps: totalSteps ?? this.totalSteps,
    simulationSilent: simulationSilent ?? this.simulationSilent,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! WalkSession) {
      return false;
    }
    if (firedStepDescriptions.length != other.firedStepDescriptions.length) {
      return false;
    }
    for (var i = 0; i < firedStepDescriptions.length; i++) {
      if (firedStepDescriptions[i] != other.firedStepDescriptions[i]) {
        return false;
      }
    }
    return id == other.id &&
        modeId == other.modeId &&
        isSimulation == other.isSimulation &&
        startedAt == other.startedAt &&
        phase == other.phase &&
        simulationSpeed == other.simulationSpeed &&
        currentStepIndex == other.currentStepIndex &&
        currentStepType == other.currentStepType &&
        missCount == other.missCount &&
        remainingSeconds == other.remainingSeconds &&
        simulatedElapsed == other.simulatedElapsed &&
        lastSimulationDescription == other.lastSimulationDescription &&
        isBackgroundAlert == other.isBackgroundAlert &&
        totalSteps == other.totalSteps &&
        simulationSilent == other.simulationSilent;
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    modeId,
    isSimulation,
    startedAt,
    phase,
    simulationSpeed,
    currentStepIndex,
    currentStepType,
    missCount,
    remainingSeconds,
    simulatedElapsed,
    Object.hashAll(firedStepDescriptions),
    lastSimulationDescription,
    isBackgroundAlert,
    totalSteps,
    simulationSilent,
  ]);
}

// ─── SessionPhase ─────────────────────────────────────────────────────────

/// Sealed lifecycle state of a [WalkSession].
///
/// There is no `bootRestart` variant — session state is in-memory only
/// (lessons §5.2).
sealed class SessionPhase {
  const SessionPhase();
}

/// Session is running and the engine is processing events.
final class SessionPhaseActive extends SessionPhase {
  const SessionPhaseActive();

  @override
  bool operator ==(Object other) => other is SessionPhaseActive;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Session is paused.
final class SessionPhasePaused extends SessionPhase {
  /// Creates a paused-session phase.
  const SessionPhasePaused({required this.reason});

  /// Why the session is paused.
  final PauseReason reason;

  @override
  bool operator ==(Object other) =>
      other is SessionPhasePaused && reason == other.reason;

  @override
  int get hashCode => Object.hash(runtimeType, reason);
}

/// Session has ended.
final class SessionPhaseEnded extends SessionPhase {
  const SessionPhaseEnded();

  @override
  bool operator ==(Object other) => other is SessionPhaseEnded;

  @override
  int get hashCode => runtimeType.hashCode;
}

// ─── SimulationDescription ────────────────────────────────────────────────

/// Human-readable description of a step that fired during simulation.
///
/// Shown as a toast or in the simulation summary screen.
final class SimulationDescription {
  /// Creates a simulation description.
  const SimulationDescription({
    required this.stepIndex,
    required this.stepType,
    required this.text,
  });

  /// 0-based index of the step that fired.
  final int stepIndex;

  /// The step type that fired.
  final ChainStepType stepType;

  /// Human-readable description returned by the strategy.
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SimulationDescription &&
          stepIndex == other.stepIndex &&
          stepType == other.stepType &&
          text == other.text);

  @override
  int get hashCode => Object.hash(stepIndex, stepType, text);
}
