/// `EventStrategy` — abstract Strategy-pattern base for the nine
/// escalation step types.
///
/// Pure Dart. Each concrete strategy implements:
/// * [executeReal] — the real side-effect (send SMS, play alarm…);
/// * [simulationDescription] — a symbolic description (template key
///   + args) shown in simulation mode instead of running the
///   side-effect. The UI layer resolves the key against
///   `AppLocalizations` to produce the user-visible string.
///
/// Strategies never hold mutable state; they receive everything via
/// [EventServices].
library;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';

/// Symbolic simulation-mode description returned by every
/// [EventStrategy.simulationDescription].
///
/// Carries an opaque l10n template key and a typed argument map. The
/// UI layer (e.g. `SimulationSummaryScreen`) switches on
/// [templateKey] to call the matching [AppLocalizations] getter and
/// substitutes [args] into the resulting string.
///
/// Why: keeps strategies pure-Dart and locale-agnostic. They never
/// import Flutter / AppLocalizations directly. Fix for
/// `docs/verification/bugs.json` Warn 5.
final class SimulationDescription {
  /// Creates a symbolic simulation description.
  const SimulationDescription(this.templateKey, [this.args = const {}]);

  /// Stable key identifying which localized template to render.
  ///
  /// Conventions:
  /// * `simLoudAlarm`, `simSmsContact`, `simFakeCallRing`,
  ///   `simCountdownWarning`, `simPhoneCall`, `simCallEmergency`,
  ///   `simHardwareButton`, `simHoldButton`, `simDisguisedReminder`,
  ///   `simDisguisedReminderEmpty`, `simNoContactToCall`,
  ///   `simGpsArrivalTrigger`, `simLowBatteryAlert`.
  final String templateKey;

  /// Typed arguments substituted into the rendered template.
  ///
  /// Allowed value types: `String`, `num`, `bool`. Strategies must not
  /// pass mutable state — args are surfaced verbatim into ARB
  /// placeholders.
  final Map<String, Object?> args;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SimulationDescription) return false;
    if (other.templateKey != templateKey) return false;
    if (other.args.length != args.length) return false;
    for (final entry in args.entries) {
      if (!other.args.containsKey(entry.key)) return false;
      if (other.args[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    templateKey,
    Object.hashAllUnordered(
      args.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );

  @override
  String toString() => 'SimulationDescription($templateKey, $args)';
}

/// Strategy contract for a single step type.
abstract class EventStrategy {
  /// Const default constructor so subclasses can be `const`.
  const EventStrategy();

  /// Performs the real side-effect for [step] using [services].
  Future<void> executeReal(ChainStep step, EventServices services);

  /// Returns a symbolic description shown to the user in simulation
  /// mode instead of performing the side-effect.
  ///
  /// Implementations return a [SimulationDescription] containing a
  /// stable l10n template key and any typed args; the UI layer
  /// resolves the key against `AppLocalizations`.
  SimulationDescription simulationDescription(
    ChainStep step,
    EventServices services,
  );
}
