/// Deterministic fake implementation of [PhoneServiceProtocol] for
/// tests. Every call is recorded to [calls].
library;

import 'package:guardianangela/services/protocols/phone_service_protocol.dart';

/// Test double for [PhoneServiceProtocol].
final class FakePhoneService implements PhoneServiceProtocol {
  /// Creates a fake phone service.
  FakePhoneService();

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

  @override
  Future<void> call(String number, {bool isSimulation = false}) async {
    calls.add('call:$number');
  }

  @override
  Future<void> callEmergency(
    String number, {
    bool isSimulation = false,
  }) async {
    calls.add('callEmergency:$number');
  }

  /// Tears down any held state (no-op here; provided for symmetry).
  void dispose() {}
}
