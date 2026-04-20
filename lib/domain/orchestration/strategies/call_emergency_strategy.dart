/// `CallEmergencyStrategy` — strategy for
/// `ChainStepType.callEmergency`.
///
/// Dials the configured emergency number via
/// [PhoneServiceProtocol.callEmergency]. The resolution order is:
///
///   1. per-step `CallEmergencyConfig.emergencyNumber` when set and
///      non-empty;
///   2. a universal fallback of `'112'`.
///
/// The app-level `AppSettings.emergencyCallNumber` override is
/// resolved by the controller at session start (before this strategy
/// runs) and written into the step config, so this strategy does
/// not reach out to settings.
library;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Fallback emergency number used when no config is present.
const String _defaultEmergencyNumber = '112';

/// Strategy for emergency-call steps.
final class CallEmergencyStrategy extends EventStrategy {
  /// Const constructor.
  const CallEmergencyStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) async {
    final number = _resolveNumber(step);
    await services.phone.callEmergency(
      number,
      isSimulation: services.context.isSimulation,
    );
  }

  @override
  String simulationDescription(ChainStep step, EventServices services) =>
      '[SIM] Would dial ${_resolveNumber(step)}';

  /// Resolves the number to dial from the step config with fallback.
  String _resolveNumber(ChainStep step) {
    final raw = step.config;
    if (raw is CallEmergencyConfig) {
      final n = raw.emergencyNumber;
      if (n != null && n.isNotEmpty) return n;
    }
    return _defaultEmergencyNumber;
  }
}
