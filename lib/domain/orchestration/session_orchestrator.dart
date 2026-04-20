/// `SessionOrchestrator` — glue between the pure-Dart `SessionEngine`
/// event stream and the side-effecting [EventStrategy] registry.
///
/// The orchestrator consumes `ChainEventData` from the engine,
/// resolves the corresponding [ChainStep] via an injected
/// [chainStepsResolver], looks up the matching [EventStrategy] via
/// [EventStrategyRegistry], builds an [EventServices] bundle on
/// demand, and calls `executeReal` (real mode) or
/// `simulationDescription` (simulation mode). It is also the bearer
/// of per-strategy error isolation (L4 mitigation) and of pending
/// messaging-work cancellation (D-SAFETY-11).
///
/// ### Layer 1 of the 4-layer simulation defense
/// In simulation mode, `executeReal` is **never** invoked by the
/// orchestrator; only the pure-Dart `simulationDescription` text is
/// surfaced via [onSimulationDescription]. Layers 2–4 are enforced
/// downstream (services / platform channels / native guards) per
/// spec §overview and `docs/rebuild-strategy.md` §2 L6.
///
/// ### Error isolation (D-STRATEGY-2 — "continue")
/// A strategy's `executeReal` may throw. The orchestrator wraps
/// every invocation in a `try/catch` and forwards the failure to
/// [onStepExecutionFailed]. The engine's event stream is NOT
/// interrupted — subsequent steps still run. This is the
/// **continue** policy: a single failing strategy must not silence
/// the rest of the chain, because later steps (alarm, emergency
/// call) are the user's last line of defense. Full rationale in
/// `docs/decisions-log.md#D-STRATEGY-2`.
library;

import 'dart:async';

import 'package:guardianangela/domain/models/chain_event.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy_registry.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';

/// Orchestrates side-effects in response to engine events.
final class SessionOrchestrator {
  /// Creates a session orchestrator.
  ///
  /// [isSimulation] — if true, the orchestrator never calls a
  /// strategy's `executeReal`; only `simulationDescription` is
  /// surfaced via [onSimulationDescription].
  /// [servicesBuilder] — builds a fresh [EventServices] for the
  /// current step. Takes two callbacks: (a) the `isCancelled`
  /// predicate the strategy polls, (b) the `registerSmsWorkId`
  /// hook the orchestrator uses to track cancelable SMS work.
  /// [chainStepsResolver] — returns the active chain's steps at the
  /// moment of resolution. The orchestrator indexes into the
  /// returned list using `event.stepIndex`.
  /// [messagingService] — optional messaging service used for bulk
  /// cancellation via [cancelPendingWork].
  /// [onSimulationDescription] — optional sink for simulation-mode
  /// descriptions; typically the simulation summary screen.
  /// [onStepExecutionFailed] — optional error hook called when a
  /// strategy's `executeReal` throws.
  SessionOrchestrator({
    required this.isSimulation,
    required EventServices Function(
      bool Function(),
      void Function(MessageWorkId)?,
    )
    servicesBuilder,
    required List<ChainStep> Function() chainStepsResolver,
    this.messagingService,
    this.onSimulationDescription,
    this.onStepExecutionFailed,
  }) : _servicesBuilder = servicesBuilder,
       _chainStepsResolver = chainStepsResolver;

  /// True if the session is running in simulation mode.
  final bool isSimulation;

  /// Optional messaging service used to cancel pending SMS work.
  final MessagingServiceProtocol? messagingService;

  /// Optional simulation-description sink.
  final void Function(String)? onSimulationDescription;

  /// Optional error hook for strategy-execution failures.
  final void Function({
    required ChainStep step,
    required Object error,
    required StackTrace stack,
  })?
  onStepExecutionFailed;

  /// Builds the per-step [EventServices] bundle.
  final EventServices Function(
    bool Function(),
    void Function(MessageWorkId)?,
  )
  _servicesBuilder;

  /// Returns the active chain's steps at the moment of resolution.
  final List<ChainStep> Function() _chainStepsResolver;

  /// Set of enqueued SMS work ids the orchestrator can cancel.
  final Set<MessageWorkId> _pendingWorkIds = <MessageWorkId>{};

  /// True once [dispose] has been called; subsequent events are
  /// ignored.
  bool _disposed = false;

  /// Read-only view of currently-tracked pending SMS work ids.
  ///
  /// Visible for tests and controller-side diagnostics. The set is a
  /// snapshot — mutations to it do not reach the orchestrator.
  Set<MessageWorkId> get pendingWorkIds =>
      Set<MessageWorkId>.unmodifiable(_pendingWorkIds);

  /// Handles a single engine event. Dispatches to the strategy
  /// registered for the current step for [ChainEvent.stepStarted];
  /// ignores every other event (those are state/lifecycle signals
  /// the controller handles directly).
  Future<void> handleEvent(ChainEventData event) async {
    if (_disposed) return;
    if (event.event != ChainEvent.stepStarted) return;
    final step = _resolveStep(event);
    if (step == null) return;
    final strategy = EventStrategyRegistry.forStep(step);
    final services = _servicesBuilder(_isCancelled, _registerWorkId);
    if (isSimulation) {
      // Layer 1 of the 4-layer simulation defense: never invoke the
      // real strategy path from the orchestrator in simulation mode.
      final desc = strategy.simulationDescription(step, services);
      onSimulationDescription?.call(desc);
      return;
    }
    try {
      await strategy.executeReal(step, services);
    } catch (error, stack) {
      final hook = onStepExecutionFailed;
      if (hook != null) {
        hook(step: step, error: error, stack: stack);
      }
      // Swallow the error: per D-STRATEGY-2, the chain keeps going
      // so later escalation steps still run.
    }
  }

  /// Cancels all SMS work queued so far, if a messaging service is
  /// bound. Called by the session controller on disarm / end.
  Future<void> cancelPendingWork() async {
    final messaging = messagingService;
    if (messaging == null || _pendingWorkIds.isEmpty) {
      _pendingWorkIds.clear();
      return;
    }
    final snapshot = List<MessageWorkId>.unmodifiable(_pendingWorkIds);
    _pendingWorkIds.clear();
    await messaging.cancelPending(snapshot);
  }

  /// Marks the orchestrator as disposed; subsequent [handleEvent]
  /// calls are ignored. Any still-tracked SMS work IDs remain the
  /// caller's responsibility to cancel via [cancelPendingWork] first.
  void dispose() {
    _disposed = true;
    _pendingWorkIds.clear();
  }

  /// Predicate passed to the current strategy as `isCancelled`.
  /// A strategy polls this to bail out of long-running work. The
  /// orchestrator considers itself cancelled once [dispose] fires.
  bool _isCancelled() => _disposed;

  /// Records [id] so it can later be cancelled by
  /// [cancelPendingWork].
  void _registerWorkId(MessageWorkId id) {
    _pendingWorkIds.add(id);
  }

  /// Resolves the [ChainStep] referenced by [event]. Returns null
  /// when the event carries no index or when the index is
  /// out-of-range for the current chain snapshot.
  ChainStep? _resolveStep(ChainEventData event) {
    final idx = event.stepIndex;
    if (idx == null) return null;
    final steps = _chainStepsResolver();
    if (idx < 0 || idx >= steps.length) return null;
    return steps[idx];
  }
}
