import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/domain/triggers/distress_trigger.dart';

/// Bundle of trigger lists passed to [SessionEngine] at construction.
///
/// Holds the per-mode distress and disarm trigger configurations as
/// immutable lists. The engine wires both lists through its internal
/// [TriggerManager]. See spec 01 §Constructor.
final class Triggers {
  /// Creates a Triggers bundle. Both lists default to empty.
  const Triggers({
    this.distressTriggers = const [],
    this.disarmTriggers = const [],
  });

  /// Triggers that replace the main chain with the distress chain when they
  /// fire (e.g., [HardwareButtonDistressTrigger]).
  final List<DistressTrigger> distressTriggers;

  /// Triggers that fire [SessionEngine.disarm] when their condition is met
  /// (e.g., [GpsArrivalDisarmTrigger], [TimerDisarmTrigger]). Gated by the
  /// engine's `allowDisarmAsDistress` constructor flag while in the
  /// distress chain (spec 01 Invariant 13).
  final List<DisarmTrigger> disarmTriggers;
}
