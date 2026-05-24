import 'package:guardianangela/services/protocols/vibration_service_protocol.dart';

/// Simulation [VibrationServiceProtocol] for tests and simulation isolates.
///
/// Records every method invocation into [calls] as a string tag so tests
/// can assert which patterns were requested and in what order.
///
/// Never calls the native vibration plugin.
class SimulationVibrationService implements VibrationServiceProtocol {
  /// Creates a [SimulationVibrationService].
  SimulationVibrationService();

  /// Ordered record of every method invocation.
  ///
  /// Values: `'warningPattern'`, `'confirmPulse'`, `'alarmPattern'`,
  /// `'fakeCallPattern'`, `'reminderPattern'`, `'cancel'`.
  final List<String> calls = [];

  /// Whether [cancel] has been called at least once since construction (or
  /// since the last [reset]).
  bool get wasCancelled => calls.contains('cancel');

  /// Clears [calls] and [cancelled] state.
  void reset() => calls.clear();

  @override
  Future<void> warningPattern({bool isSimulation = false}) async {
    calls.add('warningPattern');
  }

  @override
  Future<void> confirmPulse() async {
    calls.add('confirmPulse');
  }

  @override
  Future<void> alarmPattern({bool isSimulation = false}) async {
    calls.add('alarmPattern');
  }

  @override
  Future<void> fakeCallPattern() async {
    calls.add('fakeCallPattern');
  }

  @override
  Future<void> reminderPattern() async {
    calls.add('reminderPattern');
  }

  @override
  Future<void> cancel() async {
    calls.add('cancel');
  }
}
