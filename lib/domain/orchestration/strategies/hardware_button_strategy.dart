import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Strategy for [ChainStepType.hardwareButton] steps.
///
/// Real mode: no service calls — hardware button detection is handled
/// independently by the platform channel ([HardwareButtonChannel.kt] on
/// Android). When the configured press pattern is detected, the platform
/// calls `engine.disarm()` directly. This strategy fires on `stepFired`
/// but the actual detection is a background platform concern.
///
/// Simulation: the spec specifies a toast `'Button press detected!'` to
/// indicate that the simulated button press was registered (spec 02
/// §3 hardwareButton "Simulation: Toast: 'Button press detected!'"). The
/// text is raw English; localisation happens at UI render time (Phase 6).
/// Test/Preview in settings uses the same text.
///
/// See spec 02 §3 hardwareButton.
final class HardwareButtonStrategy implements EventStrategy {
  /// Creates a [HardwareButtonStrategy].
  const HardwareButtonStrategy();

  /// No-op — hardware button detection runs via the platform channel
  /// independently of the strategy; no service calls are needed here.
  ///
  /// The simulation guard is omitted because there are no real actions
  /// to block; the step is UI/platform-driven.
  @override
  Future<void> executeReal(ChainStep step, EventServices services) =>
      Future<void>.value();

  /// Returns the raw English simulation feedback text.
  ///
  /// The UI layer (Phase 6) is responsible for localising this string.
  /// Spec 02 §3 hardwareButton specifies the exact text.
  @override
  String? simulationDescription(ChainStep step, EventServices services) =>
      'Button press detected!';
}
