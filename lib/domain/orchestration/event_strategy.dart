import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';

/// Abstract interface for step-type execution strategies.
///
/// Each of the 9 [ChainStepType] values has exactly one [EventStrategy]
/// registered in [EventStrategyRegistry]. The strategy encapsulates
/// **all** side effects for a step type — service calls, logging, etc.
///
/// The [SessionController] (Phase 5) obtains the strategy for a given step
/// via [EventStrategyRegistry.forStep] and calls [executeReal] when the
/// engine emits a `stepFired` event.
///
/// **Simulation contract (spec 02 §Simulation behavior summary):**
/// Every [executeReal] MUST check `services.isSimulation` first. When
/// `true`, log a `sim_blocked` message via `dart:developer.log` and
/// return `Future<void>.value()` without performing any real action.
/// [simulationDescription] returns a short human-readable description
/// for the `[SIM]` card shown in simulation, or `null` when the real
/// UI fires identically and no card is needed.
///
/// **Error handling:** Strategies intentionally do NOT catch errors. The
/// engine's `notifyStepExecutionFailed` (called by the controller in
/// Phase 5) is the centralised non-blocking error handler. Fail loud —
/// propagate all exceptions.
abstract interface class EventStrategy {
  /// Constant constructor so concrete strategies can be `const`.
  const EventStrategy();

  /// Executes the real (non-simulation) action for [step].
  ///
  /// MUST short-circuit when `services.isSimulation == true` by logging
  /// a `sim_blocked` line and returning immediately. Concrete
  /// implementations document any additional simulation-safe notes in
  /// their own doc comments.
  ///
  /// Called by the [SessionController] on a `stepFired` engine event.
  Future<void> executeReal(ChainStep step, EventServices services);

  /// Returns a short description for the simulation `[SIM]` card.
  ///
  /// Returns `null` when no card is needed — either because the real
  /// UI fires identically in simulation (e.g. fake call, countdown
  /// warning) or because there is no user-visible side effect.
  String? simulationDescription(ChainStep step, EventServices services);
}
