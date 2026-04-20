/// `EventStrategy` — abstract Strategy-pattern base for the nine
/// escalation step types.
///
/// Pure Dart. Each concrete strategy implements:
/// * [executeReal] — the real side-effect (send SMS, play alarm…);
/// * [simulationDescription] — the toast text shown in simulation
///   mode instead of running the side-effect.
///
/// Strategies never hold mutable state; they receive everything via
/// [EventServices].
library;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';

/// Strategy contract for a single step type.
abstract class EventStrategy {
  /// Const default constructor so subclasses can be `const`.
  const EventStrategy();

  /// Performs the real side-effect for [step] using [services].
  Future<void> executeReal(ChainStep step, EventServices services);

  /// Returns the one-line simulation description shown to the user
  /// instead of performing the side-effect. Localized at the call
  /// site; implementations should return a short, self-contained
  /// phrase.
  String simulationDescription(ChainStep step, EventServices services);
}
