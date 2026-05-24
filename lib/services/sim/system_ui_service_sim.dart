import 'package:guardianangela/services/protocols/system_ui_service_protocol.dart';

/// Simulation [SystemUiServiceProtocol] for tests.
///
/// Tracks all calls to [setStealthIconEnabled] and [toggleLockTaskMode]
/// without invoking any platform channels.  Tests inspect [calls] to
/// verify the controller drove the service correctly.
class SimulationSystemUiService implements SystemUiServiceProtocol {
  /// Creates a [SimulationSystemUiService].
  SimulationSystemUiService();

  final List<SystemUiCall> _calls = [];

  // ---------------------------------------------------------------------------
  // SystemUiServiceProtocol implementation
  // ---------------------------------------------------------------------------

  @override
  Future<void> setStealthIconEnabled(bool enabled) async {
    _calls.add(SystemUiCall.stealthIcon(enabled: enabled));
  }

  @override
  Future<void> toggleLockTaskMode(bool enabled) async {
    _calls.add(SystemUiCall.lockTask(enabled: enabled));
  }

  // ---------------------------------------------------------------------------
  // Test helpers
  // ---------------------------------------------------------------------------

  /// All calls recorded in invocation order.
  List<SystemUiCall> get calls => List.unmodifiable(_calls);

  /// Clears the call log.
  void reset() => _calls.clear();
}

// ---------------------------------------------------------------------------
// Call record
// ---------------------------------------------------------------------------

/// Discriminated record of a [SimulationSystemUiService] call.
sealed class SystemUiCall {
  const SystemUiCall({required this.enabled});

  /// Whether the operation was requested to be enabled or disabled.
  final bool enabled;

  /// Constructs a [StealthIconCall].
  const factory SystemUiCall.stealthIcon({required bool enabled}) =
      StealthIconCall;

  /// Constructs a [LockTaskCall].
  const factory SystemUiCall.lockTask({required bool enabled}) = LockTaskCall;
}

/// Represents a call to [SimulationSystemUiService.setStealthIconEnabled].
final class StealthIconCall extends SystemUiCall {
  /// Creates a [StealthIconCall].
  const StealthIconCall({required super.enabled});
}

/// Represents a call to [SimulationSystemUiService.toggleLockTaskMode].
final class LockTaskCall extends SystemUiCall {
  /// Creates a [LockTaskCall].
  const LockTaskCall({required super.enabled});
}
