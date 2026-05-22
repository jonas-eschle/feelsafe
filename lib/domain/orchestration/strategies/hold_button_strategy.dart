import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Strategy for [ChainStepType.holdButton] steps.
///
/// Real mode: no service action — the hold-button step is entirely UI-driven.
/// The [SessionScreen] renders the hold target; the engine timer tracks
/// whether the user is holding (via `holdStart()` / `holdStop()` calls).
/// No platform service needs to be invoked when this step fires.
///
/// Simulation: no toast needed — the UI shows the hold button identically
/// in simulation.
///
/// See spec 02 §1 holdButton.
final class HoldButtonStrategy implements EventStrategy {
  /// Creates a [HoldButtonStrategy].
  const HoldButtonStrategy();

  /// No-op — holdButton is purely UI-driven.
  ///
  /// The simulation guard is omitted here because there are no real actions
  /// to block; calling this method in simulation is already harmless.
  @override
  Future<void> executeReal(ChainStep step, EventServices services) =>
      Future<void>.value();

  /// Returns `null` — the UI shows the hold button identically in both
  /// real and simulation modes; no `[SIM]` card is needed.
  @override
  String? simulationDescription(ChainStep step, EventServices services) => null;
}
