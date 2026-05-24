import 'package:guardianangela/services/protocols/wakelock_service_protocol.dart';

/// Simulation [WakelockServiceProtocol] for tests and simulation isolates.
///
/// Tracks wakelock state via a pure-Dart bool; never calls the native
/// `wakelock_plus` plugin. Records every method call in [calls] so tests
/// can assert order.
class SimulationWakelockService implements WakelockServiceProtocol {
  /// Creates a [SimulationWakelockService].
  ///
  /// [initialEnabled] sets the initial [isEnabled] state (default `false`).
  SimulationWakelockService({bool initialEnabled = false})
    : _isEnabled = initialEnabled;

  bool _isEnabled;

  /// Ordered record of every method invocation.
  ///
  /// Values: `'enable'`, `'disable'`.
  final List<String> calls = [];

  @override
  bool get isEnabled => _isEnabled;

  @override
  Future<void> enable() async {
    calls.add('enable');
    _isEnabled = true;
  }

  @override
  Future<void> disable() async {
    calls.add('disable');
    _isEnabled = false;
  }

  /// Resets [calls] and restores [isEnabled] to [initialEnabled].
  void reset({bool initialEnabled = false}) {
    calls.clear();
    _isEnabled = initialEnabled;
  }
}
