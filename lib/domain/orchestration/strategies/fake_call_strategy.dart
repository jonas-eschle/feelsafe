import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Strategy for [ChainStepType.fakeCall] steps.
///
/// **Pivot 2 / R-1 — fakeCall is an event, not a pause.** The engine timer
/// continues running while the fake call UI is shown. [FakeCallScreen] is a
/// route push, not a pause-and-overlay. `engine.answerFakeCall()` is a no-op
/// at the engine level. `engine.hangUp()` fires disarm. The rationale:
/// pausing on every fake call would create gaps that an attacker could
/// exploit by repeatedly declining/answering to delay the chain.
///
/// Real mode: no service action from this strategy — the [SessionScreen]
/// pushes [FakeCallScreen] in response to the engine's `stepFired` event
/// (Phase 6 wiring). The ringtone is played by [AudioService] from the
/// [FakeCallScreen] widget. This strategy's job is to be present in the
/// registry; actual UI work is done by the session controller (Phase 5).
///
/// Simulation: the call screen and ringtone fire normally (local-only action
/// per spec 02 §Simulation behavior summary). No `[SIM]` card substitution;
/// this strategy returns `null` from [simulationDescription].
///
/// See spec 02 §5 fakeCall and §Answer / Hang-up Semantics (Pivot 2).
final class FakeCallStrategy implements EventStrategy {
  /// Creates a [FakeCallStrategy].
  const FakeCallStrategy();

  /// No-op — fake call is entirely UI-driven (Pivot 2 / R-1).
  ///
  /// The simulation guard is omitted because there are no real actions
  /// to block; the fake-call UI fires identically in both modes.
  @override
  Future<void> executeReal(ChainStep step, EventServices services) =>
      Future<void>.value();

  /// Returns `null` — the call screen and ringtone fire normally in
  /// simulation; no `[SIM]` card is needed.
  ///
  /// See spec 02 §5 fakeCall "Simulation: Call screen + ringtone fire
  /// normally."
  @override
  String? simulationDescription(ChainStep step, EventServices services) => null;
}
