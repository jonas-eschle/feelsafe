import 'package:guardianangela/services/protocols/biometric_service_protocol.dart';

/// Simulation [BiometricServiceProtocol] for tests and simulation isolates.
///
/// Never calls the native biometric plugin. [available] drives [isAvailable]
/// and [authenticateResult] drives [authenticate]; both invocations are
/// recorded in [calls] so tests can assert that the gate consulted the
/// service in the expected order.
class SimulationBiometricService implements BiometricServiceProtocol {
  /// Creates a [SimulationBiometricService].
  ///
  /// [available] is returned by [isAvailable] (default false — no biometric).
  /// [authenticateResult] is returned by [authenticate] (default false — the
  /// prompt is declined/cancelled so the caller falls back to PIN).
  SimulationBiometricService({
    this.available = false,
    this.authenticateResult = false,
  });

  /// Value returned by [isAvailable]. Mutable so tests can flip it mid-run.
  bool available;

  /// Value returned by [authenticate]. Mutable so tests can flip it mid-run.
  bool authenticateResult;

  /// Ordered record of invocations: `'isAvailable'`, `'authenticate'`.
  final List<String> calls = <String>[];

  @override
  Future<bool> isAvailable() async {
    calls.add('isAvailable');
    return available;
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    calls.add('authenticate');
    return authenticateResult;
  }
}
