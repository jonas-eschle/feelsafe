/// `TriggerManager` — wires external triggers (hardware panic, GPS
/// arrival, low battery) into the `SessionEngine`.
///
/// Pure Dart (service protocols are themselves pure-Dart abstracts).
/// Each trigger has a cooldown to suppress double-fires.
library;

import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/services/protocols/battery_monitor_service_protocol.dart';
import 'package:guardianangela/services/protocols/geofence_service_protocol.dart';
import 'package:guardianangela/services/protocols/hardware_button_service_protocol.dart';

/// Wires platform triggers into the engine.
final class TriggerManager {
  /// Creates a trigger manager.
  ///
  /// [engine] — the session engine to signal.
  /// [mode] — active mode providing the trigger configuration.
  /// [hardwareButtonService] — detection of hardware panic patterns.
  /// [geofenceService] — arrival-geofence detection.
  /// [batteryMonitorService] — one-shot low-battery detection.
  /// [onDisarmRequested] — optional callback for GPS-arrival or
  /// timer disarm. Null = call `engine.disarm()` directly.
  /// [onDistressConfirmation] — optional async hook returning true
  /// if the user confirmed the distress trigger (e.g., via a
  /// countdown-to-cancel dialog). Null = fire immediately.
  /// [distressStepsResolver] — optional closure that produces the
  /// distress chain steps at trigger time; used to avoid capturing
  /// stale chain data.
  TriggerManager({
    required this.engine,
    required this.mode,
    required this.hardwareButtonService,
    required this.geofenceService,
    required this.batteryMonitorService,
    this.onDisarmRequested,
    this.onDistressConfirmation,
    this.distressStepsResolver,
  });

  /// Minimum time between successive trigger fires.
  static const Duration cooldown = Duration(milliseconds: 500);

  /// The session engine being driven.
  final SessionEngine engine;

  /// The active mode.
  final SessionMode mode;

  /// Hardware-panic-button service.
  final HardwareButtonServiceProtocol hardwareButtonService;

  /// Arrival-geofence service.
  final GeofenceServiceProtocol geofenceService;

  /// Battery-monitor service.
  final BatteryMonitorServiceProtocol batteryMonitorService;

  /// Optional disarm callback.
  final void Function()? onDisarmRequested;

  /// Optional distress-confirmation hook.
  final Future<bool> Function()? onDistressConfirmation;

  /// Optional distress-steps resolver.
  final List<ChainStep> Function()? distressStepsResolver;

  /// Subscribes to all trigger streams.
  Future<void> start() async => throw UnimplementedError();

  /// Unsubscribes and releases resources.
  Future<void> dispose() async => throw UnimplementedError();
}
