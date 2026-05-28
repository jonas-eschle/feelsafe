import 'package:guardianangela/services/protocols/device_info_service_protocol.dart';

/// Simulation [DeviceInfoServiceProtocol] used by tests and
/// simulation-mode sessions.
///
/// Defaults to returning [SimNumberUnsupported] so onboarding behaves
/// like a desktop / iOS test environment. Tests can override
/// [nextResult] to drive any outcome path.
class SimulationDeviceInfoService implements DeviceInfoServiceProtocol {
  /// Creates a simulation device-info service. Pass [initial] to seed
  /// the result returned by the first [getSimPhoneNumber] call.
  SimulationDeviceInfoService({SimNumberResult? initial})
    : nextResult = initial ?? const SimNumberUnsupported();

  /// The result the next [getSimPhoneNumber] call returns. Tests can
  /// mutate this between assertions to exercise every branch.
  SimNumberResult nextResult;

  /// Call counter for assertions.
  int callCount = 0;

  @override
  Future<SimNumberResult> getSimPhoneNumber() async {
    callCount++;
    return nextResult;
  }
}
