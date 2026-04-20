/// `SessionOrchestrator` — glue between the pure-Dart `SessionEngine`
/// event stream and the side-effecting [EventStrategy] registry.
///
/// Consumes `ChainEventData` from the engine, looks up the matching
/// strategy via [EventStrategyRegistry], builds an [EventServices]
/// bundle on demand, and calls `executeReal` (real mode) or
/// `simulationDescription` (simulation mode). Also handles
/// per-step cancellation of pending messaging work.
library;

import 'package:guardianangela/domain/models/chain_event.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';

/// Orchestrates side-effects in response to engine events.
final class SessionOrchestrator {
  /// Creates a session orchestrator.
  ///
  /// [isSimulation] — if true, strategies' `simulationDescription`
  /// is surfaced via [onSimulationDescription] instead of running
  /// the real side-effect.
  /// [servicesBuilder] — builds a fresh [EventServices] for the
  /// current step. Takes two callbacks: (a) the `isCancelled`
  /// predicate the strategy polls, (b) the `registerSmsWorkId`
  /// hook the orchestrator uses to track cancelable SMS work.
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
    this.messagingService,
    this.onSimulationDescription,
    this.onStepExecutionFailed,
  }) : _servicesBuilder = servicesBuilder;

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
  ///
  /// Phase 4b consumes this via `handleEvent`.
  final EventServices Function(
    bool Function(),
    void Function(MessageWorkId)?,
  )
  // ignore: unused_field
  _servicesBuilder;

  /// Handles a single engine event. Dispatches to the strategy
  /// registered for the current step.
  Future<void> handleEvent(ChainEventData event) {
    throw UnimplementedError();
  }

  /// Cancels all messaging work queued so far.
  Future<void> cancelPendingWork() {
    throw UnimplementedError();
  }
}
