import 'package:guardianangela/services/protocols/quick_exit_service_protocol.dart';

/// Simulation [QuickExitServiceProtocol] for tests and simulation isolates.
///
/// Records every [quickExit] invocation in [calls] so tests can assert
/// the controller actually called the service. Never terminates the
/// process — both Real- and Sim- paths share the same protocol so the
/// controller code is identical in both modes.
class SimulationQuickExitService implements QuickExitServiceProtocol {
  /// Creates a [SimulationQuickExitService].
  SimulationQuickExitService();

  /// Ordered record of every [quickExit] invocation.
  ///
  /// Value is the wall-clock time the call was received. Tests inspect
  /// `calls.length` to verify the controller fired the service exactly
  /// the expected number of times.
  final List<DateTime> calls = [];

  @override
  Future<void> quickExit() async {
    calls.add(DateTime.now());
  }

  /// Clears [calls].
  void reset() => calls.clear();
}
