import 'package:guardianangela/domain/enums/hardware_button_type.dart';
import 'package:guardianangela/domain/enums/hardware_trigger_pattern.dart';

/// An event emitted by [HardwareButtonServiceProtocol.panicEvents] when
/// the configured button panic pattern is detected.
///
/// See spec 05 §HardwareButtonService §Stream-Based API.
final class HardwarePanicEvent {
  /// Creates a panic event.
  const HardwarePanicEvent({
    required this.buttonType,
    required this.pattern,
    required this.timestamp,
  });

  /// Which hardware button triggered the event.
  final HardwareButtonType buttonType;

  /// The detection pattern that matched.
  final HardwareTriggerPattern pattern;

  /// Wall-clock time of the event in UTC.
  final DateTime timestamp;

  @override
  String toString() =>
      'HardwarePanicEvent(button=$buttonType, pattern=$pattern, '
      'timestamp=$timestamp)';
}
