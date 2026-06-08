import 'package:guardianangela/domain/enums/stealth_icon_preset.dart';
import 'package:guardianangela/services/protocols/system_ui_service_protocol.dart';

/// Simulation [SystemUiServiceProtocol] for tests.
///
/// Tracks all calls to [setStealthIcon] and [toggleLockTaskMode]
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
  Future<void> setStealthIcon(StealthIconPreset preset) async {
    _calls.add(SystemUiCall.stealthIcon(preset: preset));
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
  const SystemUiCall();

  /// Constructs a [StealthIconCall].
  const factory SystemUiCall.stealthIcon({required StealthIconPreset preset}) =
      StealthIconCall;

  /// Constructs a [LockTaskCall].
  const factory SystemUiCall.lockTask({required bool enabled}) = LockTaskCall;
}

/// Represents a call to [SimulationSystemUiService.setStealthIcon].
final class StealthIconCall extends SystemUiCall {
  /// Creates a [StealthIconCall].
  const StealthIconCall({required this.preset});

  /// The launcher disguise preset that was requested.
  final StealthIconPreset preset;
}

/// Represents a call to [SimulationSystemUiService.toggleLockTaskMode].
final class LockTaskCall extends SystemUiCall {
  /// Creates a [LockTaskCall].
  const LockTaskCall({required this.enabled});

  /// Whether lock-task mode was requested on or off.
  final bool enabled;
}
