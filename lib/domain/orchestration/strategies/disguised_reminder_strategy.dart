import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Strategy for [ChainStepType.disguisedReminder] steps.
///
/// Real mode: no service action — the reminder overlay is rendered entirely
/// by [SessionScreen]; the background service notification is posted by
/// [BackgroundSessionService] (Phase 5 wiring). This strategy fires when the
/// engine emits a `stepFired` event, but the actual reminder UI is driven by
/// the engine state rather than a service call.
///
/// Simulation: the real reminder overlay fires identically, so no `[SIM]`
/// toast substitution is needed. Background notifications carry a `[SIM]`
/// suffix — that is applied by the notification layer (Phase 5).
///
/// See spec 02 §2 disguisedReminder.
final class DisguisedReminderStrategy implements EventStrategy {
  /// Creates a [DisguisedReminderStrategy].
  const DisguisedReminderStrategy();

  /// No-op — disguised reminder is UI-only.
  ///
  /// The simulation guard is omitted because there are no real actions
  /// to block; the overlay fires identically in both modes.
  @override
  Future<void> executeReal(ChainStep step, EventServices services) =>
      Future<void>.value();

  /// Returns `null` — the actual reminder overlay fires identically in
  /// simulation; no `[SIM]` card substitution is needed. The background
  /// notification carries a `[SIM]` suffix, applied by the notification
  /// layer (Phase 5), not by this strategy.
  @override
  String? simulationDescription(ChainStep step, EventServices services) => null;
}
