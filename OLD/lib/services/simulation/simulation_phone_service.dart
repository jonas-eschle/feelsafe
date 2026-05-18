/// Simulation implementation of [PhoneServiceProtocol].
///
/// CRITICAL: this file MUST NOT import `url_launcher` or declare any
/// [MethodChannel] — simulation layer 2 guarantees no real call can
/// ever be placed during a simulated session. Every method logs and
/// returns a no-op.
library;

import 'dart:developer' as developer;

import 'package:guardianangela/services/protocols/phone_service_protocol.dart';

/// Simulation double for [PhoneServiceProtocol]. All methods are
/// structural no-ops logged via `dart:developer`.
final class SimulationPhoneService implements PhoneServiceProtocol {
  /// Creates the simulation phone service.
  SimulationPhoneService();

  @override
  Future<void> call(String number, {bool isSimulation = false}) async {
    developer.log('[SIM] phone.call $number');
  }

  @override
  Future<void> callEmergency(String number, {bool isSimulation = false}) async {
    developer.log('[SIM] phone.callEmergency $number');
  }
}
