/// Real battery-monitor-service implementation.
///
/// Wraps `battery_plus` to observe battery level and emit a one-shot
/// low-battery event when the level crosses below a configured
/// threshold from above. Subsequent crossings require a reset via
/// [stopMonitoring] / [startMonitoring].
library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:guardianangela/services/protocols/battery_monitor_service_protocol.dart';

/// Real platform-backed implementation of
/// [BatteryMonitorServiceProtocol].
final class BatteryMonitorService implements BatteryMonitorServiceProtocol {
  /// Creates the real battery-monitor service.
  BatteryMonitorService();

  final Battery _battery = Battery();
  final StreamController<int> _lowBatteryController =
      StreamController<int>.broadcast();

  StreamSubscription<BatteryState>? _stateSubscription;
  Timer? _pollTimer;
  int? _threshold;
  int? _lastLevel;
  bool _fired = false;
  bool _isActive = false;

  @override
  Stream<int> get onLowBattery => _lowBatteryController.stream;

  @override
  Future<void> startMonitoring({required int thresholdPercent}) async {
    if (thresholdPercent < 0 || thresholdPercent > 100) {
      throw ArgumentError.value(
        thresholdPercent,
        'thresholdPercent',
        'must be in 0..100',
      );
    }
    await stopMonitoring();
    _threshold = thresholdPercent;
    _fired = false;
    _isActive = true;

    // Seed last level so a stale reading below threshold does not
    // immediately fire (only real crossings fire).
    _lastLevel = await _safeBatteryLevel();

    // React to state changes (charging/discharging) — re-check level.
    _stateSubscription = _battery.onBatteryStateChanged.listen(
      (_) async => _sample(),
      onError: (Object e, StackTrace s) {
        developer.log('battery state error', error: e, stackTrace: s);
      },
    );

    // Also poll every 60s as a safety net.
    _pollTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _sample(),
    );
  }

  @override
  Future<void> stopMonitoring() async {
    await _stateSubscription?.cancel();
    _stateSubscription = null;
    _pollTimer?.cancel();
    _pollTimer = null;
    _threshold = null;
    _lastLevel = null;
    _fired = false;
    _isActive = false;
  }

  @override
  bool get isActive => _isActive;

  Future<void> _sample() async {
    final threshold = _threshold;
    if (threshold == null || _fired) return;
    final level = await _safeBatteryLevel();
    if (level == null) return;
    final previous = _lastLevel ?? level;
    if (previous > threshold && level <= threshold) {
      _fired = true;
      _lowBatteryController.add(level);
    }
    _lastLevel = level;
  }

  Future<int?> _safeBatteryLevel() async {
    try {
      return await _battery.batteryLevel;
    } on PlatformException catch (e, s) {
      developer.log(
        'battery level platform error',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }
}
