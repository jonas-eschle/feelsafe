import 'package:guardianangela/domain/enums/chain_step_type.dart';

/// Every observable event the [SessionEngine] emits on its event stream.
///
/// Consumers subscribe via [SessionEngine.events] and react to events (the
/// future `SessionController` logs them and drives UI updates). The stream
/// is broadcast and synchronous — listeners see events in emission order
/// without microtask latency. See spec 01 §Events Emitted for the canonical
/// list.
enum ChainEvent {
  /// A new session was started via [SessionEngine.start].
  sessionStarted,

  /// A step entered its execution lifecycle.
  ///
  /// Emitted at the beginning of every step (including retries).
  stepStarted,

  /// A step's grace phase expired and the engine is advancing to the next
  /// step (or ending the chain if no next step).
  stepAdvancing,

  /// A step's grace phase expired before the user responded.
  ///
  /// Always emitted on grace expiry — for retried disguised-reminder steps,
  /// [repeatMissed] follows. For all other step types, [stepAdvancing] (or
  /// the chain-ending [sessionEnded]) follows.
  graceExpired,

  /// A disguised-reminder retry fired with no response.
  ///
  /// Metadata: `{'missCount': int, 'stepIndex': int}`.
  repeatMissed,

  /// A disguised-reminder step entered its duration phase — the overlay is
  /// now visible to the user.
  reminderFired,

  /// A pause exceeded [SessionEngine.maxPauseDuration]; the engine
  /// auto-resumed.
  pauseExpired,

  /// A strategy's `executeReal()` threw an exception; the chain keeps
  /// running.
  ///
  /// Emitted by the orchestrator (future `SessionController`) via
  /// [SessionEngine.notifyStepExecutionFailed]. Metadata:
  /// `{'stepIndex': int, 'error': String}`.
  stepExecutionFailed,

  /// A distress trigger fired; the engine replaced the main chain with the
  /// distress chain.
  ///
  /// Metadata: `{'triggerReason': String}` (name of the [EndReason] that
  /// caused the replacement).
  distressTriggered,

  /// The distress chain finished.
  ///
  /// Emitted exactly once, immediately before the [sessionEnded] event
  /// when the chain that ended was a distress chain (i.e., the session
  /// ends with [EndReason.hardwarePanic] / [EndReason.duressPin] /
  /// [EndReason.wrongPinExhausted]).
  distressCompleted,

  /// The session was paused.
  ///
  /// Metadata: `{'reason': String}` (name of the [PauseReason]).
  sessionPaused,

  /// The session was resumed after a pause.
  sessionResumed,

  /// The user disarmed (or checked-in): the chain reset to step 0 without
  /// ending the session.
  ///
  /// Metadata: `{'fromStepIndex': int}` — where the user was when they
  /// disarmed.
  userDisarmed,

  /// Wrong PIN entered while the deceptive PIN dialog is enabled.
  ///
  /// Emitted by [SessionEngine.notifyWrongPin] so the session-log recorder
  /// can capture it in the unified timeline. Metadata:
  /// `{'attemptCount': int}`.
  deceptiveOldPinShown,

  /// The session ended for any reason.
  ///
  /// Metadata: `{'reason': String}` (name of the [EndReason]).
  sessionEnded,
}

/// Carries a [ChainEvent] plus contextual metadata emitted on the engine
/// event stream.
///
/// The stream is broadcast and synchronous — listeners see events in
/// emission order. Closed when [SessionEngine.endSession] completes.
final class ChainEventData {
  /// Creates an event data record.
  const ChainEventData(
    this.event, {
    this.timestamp,
    this.stepIndex,
    this.stepType,
    Map<String, Object?>? metadata,
  }) : metadata = metadata ?? const {};

  /// The event type.
  final ChainEvent event;

  /// Wall-clock time at emission. Null only in legacy test code that omits
  /// the timestamp.
  final DateTime? timestamp;

  /// Index of the currently active step, or null for chain-level events.
  final int? stepIndex;

  /// Type of the currently active step, or null for chain-level events.
  final ChainStepType? stepType;

  /// Arbitrary key-value pairs carrying event-specific context.
  final Map<String, Object?> metadata;

  @override
  String toString() =>
      'ChainEventData($event, step=$stepIndex, '
      'type=$stepType, meta=$metadata)';
}
