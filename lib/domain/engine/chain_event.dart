import 'package:guardianangela/domain/enums/chain_step_type.dart';

/// Every observable event the [SessionEngine] emits on its event stream.
///
/// Consumers subscribe via [SessionEngine.events] and respond to events
/// (e.g., [SessionController] logs events and drives UI updates). The stream
/// is broadcast and synchronous — listeners see events in emission order
/// without microtask latency.
enum ChainEvent {
  /// A new session was started via [SessionEngine.start].
  sessionStarted,

  /// A step entered its wait or duration phase.
  ///
  /// Emitted at the beginning of each step execution (including retries).
  stepStarted,

  /// A step's action phase fired (duration started).
  ///
  /// Signals that a strategy's executeReal() / simulationDescription()
  /// should be invoked by the controller.
  stepFired,

  /// A step was missed: grace expired without user disarming.
  ///
  /// Metadata: `{'missCount': int, 'stepIndex': int}`.
  stepMissed,

  /// The user successfully disarmed a specific step (not via the global
  /// disarm path). Used for step-level acknowledgements.
  stepDisarmed,

  /// The user successfully disarmed: the chain reset to step 0.
  ///
  /// Metadata: `{'fromStepIndex': int}` — where the user was when they
  /// disarmed.
  userDisarmed,

  /// All steps exhausted without the user disarming; session will end.
  chainExhausted,

  /// The main chain was replaced by the distress chain.
  ///
  /// Metadata: `{'triggerReason': String}` (name of the [EndReason] that
  /// caused the replacement).
  replaceWithDistress,

  /// The session was paused.
  ///
  /// Metadata: `{'reason': String}` (name of the [PauseReason]).
  pausedRequested,

  /// The session was resumed after a pause.
  resumed,

  /// A pause exceeded [SessionEngine.maxPauseDuration]; the engine
  /// auto-resumed.
  pauseExpired,

  /// A strategy's executeReal() threw an exception; the chain keeps running.
  ///
  /// Metadata: `{'stepIndex': int, 'error': String}`.
  stepExecutionFailed,

  /// Wrong PIN entered while deceptive PIN dialog is enabled.
  ///
  /// Emitted by [SessionEngine.notifyWrongPin] so [SessionLogRecorder]
  /// can capture it in the unified timeline.
  /// Metadata: `{'attemptCount': int}`.
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
