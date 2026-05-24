import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/validation_result.dart';
import 'package:guardianangela/services/protocols/session_start_validator_protocol.dart';

/// Simulation [SessionStartValidatorProtocol] for tests and simulation
/// sessions.
///
/// Returns a constructor-injected [ValidationResult] without performing any
/// permission or state checks.
class SimulationSessionStartValidator implements SessionStartValidatorProtocol {
  /// Creates a [SimulationSessionStartValidator].
  ///
  /// [fixedResult] defaults to [ValidationResult.valid] if not provided.
  SimulationSessionStartValidator({ValidationResult? fixedResult})
    : _fixedResult = fixedResult ?? const ValidationResult.valid();

  final ValidationResult _fixedResult;

  /// Every [SessionMode] passed to [validate] since construction or [reset].
  final List<SessionMode> validatedModes = [];

  // ---------------------------------------------------------------------------
  // SessionStartValidatorProtocol implementation
  // ---------------------------------------------------------------------------

  @override
  ValidationResult validate(SessionMode mode) {
    validatedModes.add(mode);
    return _fixedResult;
  }

  // ---------------------------------------------------------------------------
  // Test helpers
  // ---------------------------------------------------------------------------

  /// Clears [validatedModes].
  void reset() => validatedModes.clear();
}
