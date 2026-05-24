import 'package:guardianangela/services/_phone_number_utils.dart';
import 'package:guardianangela/services/protocols/phone_service_protocol.dart';

/// A single recorded phone call for [SimulationPhoneService].
final class PhoneCall {
  /// Creates a [PhoneCall] record.
  const PhoneCall({
    required this.phoneNumber,
    required this.isEmergency,
    required this.timestamp,
  });

  /// The sanitized phone number that was dialed.
  final String phoneNumber;

  /// Whether this was an emergency call ([callEmergency]) or regular ([call]).
  final bool isEmergency;

  /// Wall-clock time when the call was recorded.
  final DateTime timestamp;

  @override
  String toString() =>
      'PhoneCall(number=$phoneNumber, emergency=$isEmergency, '
      'time=$timestamp)';
}

/// Simulation [PhoneServiceProtocol] for tests and simulation sessions.
///
/// Never triggers a real dial. Applies phone number sanitization (so invalid
/// numbers throw [ArgumentError] identically to the production path). Records
/// every call in [calls] for test assertions.
///
/// Layer 3 guard: [call] and [callEmergency] with [isSimulation] = true log
/// a `sim_blocked` event and return `false` without recording a [PhoneCall].
class SimulationPhoneService implements PhoneServiceProtocol {
  /// Creates a [SimulationPhoneService].
  SimulationPhoneService();

  /// All calls recorded since construction or last [reset].
  final List<PhoneCall> calls = [];

  // -------------------------------------------------------------------------
  // PhoneServiceProtocol implementation
  // -------------------------------------------------------------------------

  @override
  Future<bool> call(String phoneNumber, {bool isSimulation = false}) async {
    final number = sanitizePhoneNumber(phoneNumber);
    if (isSimulation) {
      return false;
    }
    calls.add(
      PhoneCall(phoneNumber: number, isEmergency: false, timestamp: DateTime.now()),
    );
    return true;
  }

  @override
  Future<bool> callEmergency(
    String emergencyNumber, {
    bool isSimulation = false,
  }) async {
    final number = sanitizePhoneNumber(emergencyNumber);
    if (isSimulation) {
      return false;
    }
    calls.add(
      PhoneCall(phoneNumber: number, isEmergency: true, timestamp: DateTime.now()),
    );
    return true;
  }

  // -------------------------------------------------------------------------
  // Test helpers
  // -------------------------------------------------------------------------

  /// Clears [calls].
  void reset() => calls.clear();

  /// All calls to [callEmergency] regardless of [isSimulation].
  List<PhoneCall> get emergencyCalls =>
      calls.where((c) => c.isEmergency).toList();

  /// All calls to [call] regardless of [isSimulation].
  List<PhoneCall> get regularCalls =>
      calls.where((c) => !c.isEmergency).toList();
}
