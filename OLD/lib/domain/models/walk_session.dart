/// `WalkSession` — ephemeral UI-layer snapshot of the active
/// session.
///
/// Derived from `EngineState` by the `SessionController`; not
/// persisted.
library;

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// The lifecycle phase of an ephemeral `WalkSession`.
sealed class SessionPhase {
  /// Const base constructor.
  const SessionPhase();

  /// Tag for JSON round-tripping / debugging.
  String get tag;

  @override
  String toString() => 'SessionPhase.$tag';
}

/// No session running.
final class SessionPhaseIdle extends SessionPhase {
  /// Creates an idle phase.
  const SessionPhaseIdle();

  @override
  String get tag => 'idle';

  @override
  bool operator ==(Object other) => other is SessionPhaseIdle;

  @override
  int get hashCode => 'idle'.hashCode;
}

/// Session is active and ticking.
final class SessionPhaseActive extends SessionPhase {
  /// Creates an active phase.
  const SessionPhaseActive();

  @override
  String get tag => 'active';

  @override
  bool operator ==(Object other) => other is SessionPhaseActive;

  @override
  int get hashCode => 'active'.hashCode;
}

/// Session paused.
final class SessionPhasePaused extends SessionPhase {
  /// Creates a paused phase.
  const SessionPhasePaused();

  @override
  String get tag => 'paused';

  @override
  bool operator ==(Object other) => other is SessionPhasePaused;

  @override
  int get hashCode => 'paused'.hashCode;
}

/// Session ended.
final class SessionPhaseEnded extends SessionPhase {
  /// Creates an ended phase.
  const SessionPhaseEnded();

  @override
  String get tag => 'ended';

  @override
  bool operator ==(Object other) => other is SessionPhaseEnded;

  @override
  int get hashCode => 'ended'.hashCode;
}

/// Ephemeral UI-side snapshot of the active session.
final class WalkSession {
  /// Creates a walk session.
  ///
  /// [id] — ephemeral session id.
  /// [modeId] — id of the active mode.
  /// [isSimulation] — true if this is a simulation run.
  /// [startedAt] — when the session started.
  /// [phase] — current session phase.
  /// [simulationSpeed] — speed multiplier for simulations; defaults
  /// to 1.0.
  /// [currentStepIndex] — zero-based active step index; defaults to
  /// 0.
  /// [currentStepType] — current step type, if known.
  /// [missCount] — accumulated miss count on the current step;
  /// defaults to 0.
  /// [remainingSeconds] — remaining seconds on the current phase, if
  /// known.
  /// [simulatedElapsed] — simulated elapsed time; defaults to zero.
  /// [firedStepDescriptions] — human-readable log of fired steps;
  /// defaults to empty.
  /// [lastSimulationDescription] — most-recent simulation toast
  /// string.
  /// [isBackgroundAlert] — true when showing a background alert;
  /// defaults to false.
  /// [totalSteps] — total step count of the active chain; used by
  /// the session screen step counter. Defaults to 0.
  /// [simulationSilent] — when true, audible/visible simulation
  /// output (beeps, toasts) is suppressed; used by the simulation
  /// summary screen. Defaults to false.
  const WalkSession({
    required this.id,
    required this.modeId,
    required this.isSimulation,
    required this.startedAt,
    required this.phase,
    this.simulationSpeed = 1.0,
    this.currentStepIndex = 0,
    this.currentStepType,
    this.missCount = 0,
    this.remainingSeconds,
    this.simulatedElapsed = Duration.zero,
    this.firedStepDescriptions = const [],
    this.lastSimulationDescription,
    this.isBackgroundAlert = false,
    this.totalSteps = 0,
    this.simulationSilent = false,
  });

  /// Creates a [WalkSession] for a real (non-simulation) session.
  ///
  /// Sets [isSimulation] to `false` and [simulationSilent] to `false`
  /// because there is no simulation output to suppress in a real run.
  /// [simulationSpeed] is fixed at 1.0 — the engine rejects speed
  /// multipliers for real sessions.
  WalkSession.startingReal({
    required String id,
    required String modeId,
    required DateTime startedAt,
    bool isBackgroundAlert = false,
  }) : this(
         id: id,
         modeId: modeId,
         isSimulation: false,
         startedAt: startedAt,
         phase: const SessionPhaseIdle(),
         simulationSpeed: 1.0,
         isBackgroundAlert: isBackgroundAlert,
         simulationSilent: false,
       );

  /// Creates a [WalkSession] for a simulation run.
  ///
  /// [simulationSilent] defaults to `false` so the normal simulation
  /// experience (beeps, toasts) is preserved; pass `true` when the
  /// simulation summary screen drives a silent replay.
  /// [simulationSpeed] must be ≥ 1.0; the engine enforces this but
  /// the UI should pre-validate before constructing the session.
  WalkSession.startingSimulation({
    required String id,
    required String modeId,
    required DateTime startedAt,
    double simulationSpeed = 1.0,
    bool silent = false,
  }) : this(
         id: id,
         modeId: modeId,
         isSimulation: true,
         startedAt: startedAt,
         phase: const SessionPhaseIdle(),
         simulationSpeed: simulationSpeed,
         simulationSilent: silent,
       );

  /// Session id.
  final String id;

  /// Active mode id.
  final String modeId;

  /// True if this is a simulation run.
  final bool isSimulation;

  /// When the session started.
  final DateTime startedAt;

  /// Speed multiplier for simulations. Defaults to 1.0.
  final double simulationSpeed;

  /// Current phase.
  final SessionPhase phase;

  /// Zero-based index of the current step. Defaults to 0.
  final int currentStepIndex;

  /// Current step type, if known.
  final ChainStepType? currentStepType;

  /// Miss count on the current step. Defaults to 0.
  final int missCount;

  /// Remaining seconds on the current phase, if known.
  final int? remainingSeconds;

  /// Simulated elapsed time. Defaults to `Duration.zero`.
  final Duration simulatedElapsed;

  /// Symbolic log of fired-step descriptions. Defaults to empty.
  /// Each entry carries a template key + args; the UI layer resolves
  /// it against `AppLocalizations` at render time.
  /// Fix for bugs.json Warn 5.
  final List<SimulationDescription> firedStepDescriptions;

  /// Most-recent simulation-toast description (symbolic).
  final SimulationDescription? lastSimulationDescription;

  /// True when the session is showing a background alert. Defaults
  /// to false.
  final bool isBackgroundAlert;

  /// Total step count in the active chain. Defaults to 0.
  final int totalSteps;

  /// When true, audible and visible simulation output (beeps, toasts)
  /// is suppressed. Used by the simulation summary screen to run a
  /// silent replay. Always `false` for real sessions. Defaults to
  /// false.
  final bool simulationSilent;

  /// Derives the correct [SessionPhase] from an [EngineState].
  static SessionPhase phaseFromEngine(EngineState state) => switch (state) {
    EngineIdle() => const SessionPhaseIdle(),
    EngineRunning() => const SessionPhaseActive(),
    EnginePaused() => const SessionPhasePaused(),
    EngineEnded() => const SessionPhaseEnded(),
  };

  /// Returns a new session with the given fields replaced.
  WalkSession copyWith({
    String? id,
    String? modeId,
    bool? isSimulation,
    DateTime? startedAt,
    double? simulationSpeed,
    SessionPhase? phase,
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
    simulationSpeed: simulationSpeed ?? this.simulationSpeed,
    phase: phase ?? this.phase,
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

  /// Serializes to JSON (debug-only — `WalkSession` is ephemeral).
  Map<String, Object?> toJson() => {
    'id': id,
    'modeId': modeId,
    'isSimulation': isSimulation,
    'startedAt': startedAt.toIso8601String(),
    'simulationSpeed': simulationSpeed,
    'phase': phase.tag,
    'currentStepIndex': currentStepIndex,
    'currentStepType': currentStepType?.name,
    'missCount': missCount,
    'remainingSeconds': remainingSeconds,
    'simulatedElapsedMicros': simulatedElapsed.inMicroseconds,
    'firedStepDescriptions': [
      for (final d in firedStepDescriptions) _simDescToJson(d),
    ],
    'lastSimulationDescription': lastSimulationDescription == null
        ? null
        : _simDescToJson(lastSimulationDescription!),
    'isBackgroundAlert': isBackgroundAlert,
    'simulationSilent': simulationSilent,
  };

  /// Deserializes a `WalkSession` from JSON (debug-only).
  factory WalkSession.fromJson(Map<String, Object?> json) {
    final raw = json['firedStepDescriptions'];
    final stepTypeRaw = json['currentStepType'];
    return WalkSession(
      id: json['id']! as String,
      modeId: json['modeId']! as String,
      isSimulation: json['isSimulation']! as bool,
      startedAt: DateTime.parse(json['startedAt']! as String),
      simulationSpeed: (json['simulationSpeed'] as num?)?.toDouble() ?? 1.0,
      phase: _phaseFromTag(json['phase']),
      currentStepIndex: (json['currentStepIndex'] as num?)?.toInt() ?? 0,
      currentStepType: stepTypeRaw == null
          ? null
          : _stepTypeFromJson(stepTypeRaw as String),
      missCount: (json['missCount'] as num?)?.toInt() ?? 0,
      remainingSeconds: (json['remainingSeconds'] as num?)?.toInt(),
      simulatedElapsed: Duration(
        microseconds: (json['simulatedElapsedMicros'] as num?)?.toInt() ?? 0,
      ),
      firedStepDescriptions: raw is List
          ? List<SimulationDescription>.unmodifiable(
              raw.map(
                (e) => _simDescFromJson(e as Map<String, Object?>),
              ),
            )
          : const [],
      lastSimulationDescription: json['lastSimulationDescription'] == null
          ? null
          : _simDescFromJson(
              json['lastSimulationDescription']! as Map<String, Object?>,
            ),
      isBackgroundAlert: json['isBackgroundAlert'] as bool? ?? false,
      simulationSilent: json['simulationSilent'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WalkSession) return false;
    if (other.id != id) return false;
    if (other.modeId != modeId) return false;
    if (other.isSimulation != isSimulation) return false;
    if (other.startedAt != startedAt) return false;
    if (other.simulationSpeed != simulationSpeed) return false;
    if (other.phase != phase) return false;
    if (other.currentStepIndex != currentStepIndex) return false;
    if (other.currentStepType != currentStepType) return false;
    if (other.missCount != missCount) return false;
    if (other.remainingSeconds != remainingSeconds) return false;
    if (other.simulatedElapsed != simulatedElapsed) return false;
    if (other.lastSimulationDescription != lastSimulationDescription) {
      return false;
    }
    if (other.isBackgroundAlert != isBackgroundAlert) return false;
    if (other.simulationSilent != simulationSilent) return false;
    if (other.firedStepDescriptions.length != firedStepDescriptions.length) {
      return false;
    }
    for (var i = 0; i < firedStepDescriptions.length; i++) {
      if (other.firedStepDescriptions[i] != firedStepDescriptions[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    id,
    modeId,
    isSimulation,
    startedAt,
    simulationSpeed,
    phase,
    currentStepIndex,
    currentStepType,
    missCount,
    remainingSeconds,
    simulatedElapsed,
    Object.hashAll(firedStepDescriptions),
    lastSimulationDescription,
    isBackgroundAlert,
    simulationSilent,
  );

  @override
  String toString() =>
      'WalkSession(id: $id, modeId: $modeId, '
      'phase: $phase, step: $currentStepIndex)';
}

SessionPhase _phaseFromTag(Object? raw) => switch (raw) {
  'idle' => const SessionPhaseIdle(),
  'active' => const SessionPhaseActive(),
  'paused' => const SessionPhasePaused(),
  'ended' => const SessionPhaseEnded(),
  _ => throw ArgumentError.value(raw, 'phase', 'unknown SessionPhase'),
};

ChainStepType _stepTypeFromJson(String raw) => switch (raw) {
  'holdButton' => ChainStepType.holdButton,
  'disguisedReminder' => ChainStepType.disguisedReminder,
  'countdownWarning' => ChainStepType.countdownWarning,
  'fakeCall' => ChainStepType.fakeCall,
  'smsContact' => ChainStepType.smsContact,
  'phoneCallContact' => ChainStepType.phoneCallContact,
  'loudAlarm' => ChainStepType.loudAlarm,
  'callEmergency' => ChainStepType.callEmergency,
  'hardwareButton' => ChainStepType.hardwareButton,
  _ => throw ArgumentError.value(raw, 'stepType', 'unknown ChainStepType'),
};

Map<String, Object?> _simDescToJson(SimulationDescription d) => {
  'templateKey': d.templateKey,
  'args': d.args,
};

SimulationDescription _simDescFromJson(Map<String, Object?> json) {
  final args = json['args'];
  final argsMap = args is Map<String, Object?>
      ? Map<String, Object?>.unmodifiable(args)
      : args is Map
          ? Map<String, Object?>.unmodifiable(
              args.cast<String, Object?>(),
            )
          : const <String, Object?>{};
  return SimulationDescription(
    json['templateKey']! as String,
    argsMap,
  );
}
