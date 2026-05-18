/// In-memory fake of [BiometricServiceProtocol] for tests and
/// simulations. Defaults to `unavailable` so tests that do not opt
/// in keep the existing PIN-only behavior.
library;

import 'package:guardianangela/services/protocols/biometric_service_protocol.dart';

/// In-memory biometric service used by tests and simulations.
final class FakeBiometricService implements BiometricServiceProtocol {
  /// Creates a fake biometric service. Defaults: unavailable hw +
  /// next-call returns `unavailable` so tests stay deterministic.
  FakeBiometricService({
    this.available = false,
    this.nextResult = BiometricResult.unavailable,
  });

  /// Return value of [isAvailable].
  bool available;

  /// Return value of [authenticate].
  BiometricResult nextResult;

  /// Authentication reasons recorded for test assertions.
  final List<String> prompts = <String>[];

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<BiometricResult> authenticate({required String reason}) async {
    prompts.add(reason);
    return nextResult;
  }
}
