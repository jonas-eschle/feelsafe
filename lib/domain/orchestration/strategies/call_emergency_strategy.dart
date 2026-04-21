/// `CallEmergencyStrategy` — strategy for
/// `ChainStepType.callEmergency`.
///
/// Dials the configured emergency number via
/// [PhoneServiceProtocol.callEmergency]. The resolution order is:
///
///   1. per-step `CallEmergencyConfig.emergencyNumber` when set and
///      non-empty;
///   2. `SessionContext.emergencyNumber` (seeded from
///      `AppSettings.emergencyCallNumber` by the controller at
///      session start — fix for bugs.json Bug #7);
///   3. a universal fallback of `'112'` if the context is missing.
///
/// Chosen the "SessionContext.emergencyNumber" approach over mutating
/// ChainStep.config at session-bootstrap (simpler: no model surgery).
library;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Strategy for emergency-call steps.
final class CallEmergencyStrategy extends EventStrategy {
  /// Const constructor.
  const CallEmergencyStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) async {
    final number = _resolveNumber(step, services);
    await services.phone.callEmergency(
      number,
      isSimulation: services.context.isSimulation,
    );
  }

  @override
  String simulationDescription(ChainStep step, EventServices services) =>
      '[SIM] Would dial ${_resolveNumber(step, services)}';

  /// Resolves the number to dial.
  ///
  /// Fix for bugs.json Bug #7: fall back through 3 tiers —
  /// step-config → session eventDefaults → `context.emergencyNumber`
  /// (seeded from `AppSettings.emergencyCallNumber` by the
  /// controller at session start).
  String _resolveNumber(ChainStep step, EventServices services) {
    final raw = step.config;
    if (raw is CallEmergencyConfig) {
      final n = raw.emergencyNumber;
      if (n != null && n.isNotEmpty) return n;
    }
    try {
      final fromDefaults = services.context.configFor(step);
      if (fromDefaults is CallEmergencyConfig) {
        final n = fromDefaults.emergencyNumber;
        if (n != null && n.isNotEmpty) return n;
      }
    } on StateError {
      // No eventDefaults — fall through.
    }
    return services.context.emergencyNumber;
  }
}
