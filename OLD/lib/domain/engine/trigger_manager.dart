/// `TriggerManager` — wires external triggers (hardware panic, GPS
/// arrival, low battery) into the `SessionEngine`.
///
/// Pure Dart (service protocols are themselves pure-Dart abstracts).
/// Each trigger has a cooldown to suppress double-fires.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/trigger.dart';
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
  /// [clock] — optional wall-clock source for cooldown tracking;
  /// defaults to `DateTime.now`.
  TriggerManager({
    required this.engine,
    required this.mode,
    required this.hardwareButtonService,
    required this.geofenceService,
    this.batteryMonitorService,
    this.onDisarmRequested,
    this.onDistressConfirmation,
    this.distressStepsResolver,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

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
  final BatteryMonitorServiceProtocol? batteryMonitorService;

  /// Optional disarm callback.
  final void Function()? onDisarmRequested;

  /// Optional distress-confirmation hook.
  final Future<bool> Function()? onDistressConfirmation;

  /// Optional distress-steps resolver.
  final List<ChainStep> Function()? distressStepsResolver;

  final DateTime Function() _clock;

  StreamSubscription<HardwarePanicEvent>? _panicSub;
  StreamSubscription<LocationPoint>? _arrivalSub;
  final List<Timer> _disarmTimers = [];

  DateTime? _lastPanicFiredAt;
  DateTime? _lastArrivalFiredAt;
  DateTime? _lastTimerFiredAt;

  /// True iff this manager has subscribed to its streams.
  bool get isStarted =>
      _panicSub != null || _arrivalSub != null || _disarmTimers.isNotEmpty;

  /// Subscribes to all trigger streams.
  ///
  /// Idempotent within the lifetime of a single manager — calling
  /// twice is a no-op if already started.
  Future<void> start() async {
    if (isStarted) return;
    if (mode.distressTriggers.isNotEmpty) {
      _panicSub = hardwareButtonService.panicEvents.listen(_onPanic);
    }
    // GPS arrival disarm trigger?
    final hasGpsTrigger = mode.disarmTriggers.any(
      (t) => t is GpsArrivalDisarmTrigger,
    );
    if (hasGpsTrigger) {
      _arrivalSub = geofenceService.arrivals.listen(_onArrival);
    }
    // Timer disarm triggers — schedule one Timer per configured trigger.
    for (final trigger in mode.disarmTriggers.whereType<TimerDisarmTrigger>()) {
      final duration = Duration(seconds: trigger.durationSeconds);
      _disarmTimers.add(Timer(duration, _onTimerDisarm));
    }
  }

  /// Unsubscribes and releases resources.
  Future<void> dispose() async {
    final panic = _panicSub;
    final arrival = _arrivalSub;
    _panicSub = null;
    _arrivalSub = null;
    for (final t in _disarmTimers) {
      t.cancel();
    }
    _disarmTimers.clear();
    await panic?.cancel();
    await arrival?.cancel();
  }

  void _onTimerDisarm() {
    final now = _clock();
    final last = _lastTimerFiredAt;
    if (last != null && now.difference(last) < cooldown) {
      return;
    }
    _lastTimerFiredAt = now;
    final cb = onDisarmRequested;
    if (cb != null) {
      cb();
    } else {
      engine.endSession(reason: EndReason.disarm);
    }
  }

  Future<void> _onPanic(HardwarePanicEvent event) async {
    final now = _clock();
    final last = _lastPanicFiredAt;
    if (last != null && now.difference(last) < cooldown) {
      return;
    }
    _lastPanicFiredAt = now;
    final confirm = onDistressConfirmation;
    if (confirm != null) {
      final confirmed = await confirm();
      if (!confirmed) return;
    }
    final steps =
        distressStepsResolver?.call() ?? List<ChainStep>.from(engine.steps);
    if (steps.isEmpty) return;
    engine.replaceWithDistressChain(steps);
  }

  void _onArrival(LocationPoint arrival) {
    // Only fire if the arrival sits inside one of the configured
    // GPS geofences. `GeofenceService` typically already filters —
    // we re-check defensively.
    final triggers = mode.disarmTriggers.whereType<GpsArrivalDisarmTrigger>();
    final matched = triggers.any((t) => _withinRadius(arrival, t));
    if (!matched) return;
    final now = _clock();
    final last = _lastArrivalFiredAt;
    if (last != null && now.difference(last) < cooldown) {
      return;
    }
    _lastArrivalFiredAt = now;
    final cb = onDisarmRequested;
    if (cb != null) {
      cb();
    } else {
      engine.endSession(reason: EndReason.disarm);
    }
  }

  static bool _withinRadius(LocationPoint p, GpsArrivalDisarmTrigger trigger) {
    // Haversine distance in meters between (p.latitude, p.longitude)
    // and the trigger's center.
    const earthRadiusMeters = 6371000.0;
    final latP = p.latitude * (math.pi / 180.0);
    final latT = trigger.latitude * (math.pi / 180.0);
    final deltaLat = (trigger.latitude - p.latitude) * (math.pi / 180.0);
    final deltaLon = (trigger.longitude - p.longitude) * (math.pi / 180.0);
    final a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(latP) *
            math.cos(latT) *
            math.sin(deltaLon / 2) *
            math.sin(deltaLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distance = earthRadiusMeters * c;
    return distance <= trigger.radiusMeters;
  }
}
