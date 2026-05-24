// Native platform integration: battery_plus (cross-platform).
// No custom channel needed — battery_plus handles both Android and iOS.

import 'dart:async';
import 'dart:developer';

import 'package:battery_plus/battery_plus.dart';

import 'package:guardianangela/services/protocols/battery_monitor_service_protocol.dart';

/// Poll interval for battery level when the device state does not change.
const Duration _kPollInterval = Duration(seconds: 60);

/// Production [BatteryMonitorServiceProtocol] backed by `package:battery_plus`.
///
/// Monitoring starts a periodic 60-second poll plus a subscription to
/// [Battery.onBatteryStateChanged] for quicker detection on real state
/// transitions. When the level first drops at or below [threshold], the
/// alert fires ONCE per [startMonitoring] invocation; subsequent drops are
/// ignored until the next [startMonitoring] call.
///
/// The service only emits battery-level readings via [batteryLevel]; it does
/// NOT spawn a [SessionEngine] or interact with [BatteryAlertConfig] — that
/// responsibility belongs to the [BatteryAlertController] in Phase 6
/// (spec 05:1103).
///
/// **Single constructor location rule:** no `RealBatteryMonitorService()`
/// call may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces).
class RealBatteryMonitorService implements BatteryMonitorServiceProtocol {
  /// Creates a [RealBatteryMonitorService].
  ///
  /// [battery] — optional [Battery] instance for test injection; defaults to
  /// a new [Battery()].
  RealBatteryMonitorService({Battery? battery})
    : _battery = battery ?? Battery();

  final Battery _battery;
  final StreamController<int> _levelController =
      StreamController<int>.broadcast();

  Timer? _pollTimer;
  StreamSubscription<BatteryState>? _stateSub;

  bool _alertFired = false;
  int _threshold = 10;

  // ---------------------------------------------------------------------------
  // BatteryMonitorServiceProtocol implementation
  // ---------------------------------------------------------------------------

  @override
  Future<void> startMonitoring({int threshold = 10}) async {
    _threshold = threshold;
    _alertFired = false;

    log(
      'startMonitoring — threshold=$threshold%',
      name: 'BatteryMonitorService',
    );

    // Immediate level check.
    await _pollLevel();

    // Periodic 60-second poll.
    _pollTimer = Timer.periodic(_kPollInterval, (_) => _pollLevel());

    // Subscribe to battery state changes for faster detection.
    _stateSub = _battery.onBatteryStateChanged.listen(
      (_) => _pollLevel(),
      onError: (Object e) {
        log('onBatteryStateChanged error: $e', name: 'BatteryMonitorService');
      },
    );
  }

  @override
  Future<void> stopMonitoring() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    await _stateSub?.cancel();
    _stateSub = null;
    _alertFired = false;
    log('stopMonitoring', name: 'BatteryMonitorService');
  }

  @override
  Stream<int> get batteryLevel => _levelController.stream;

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _pollLevel() async {
    try {
      final level = await _battery.batteryLevel;
      log('battery level: $level%', name: 'BatteryMonitorService');
      _levelController.add(level);
      _checkThreshold(level);
    } catch (e) {
      log('batteryLevel error: $e', name: 'BatteryMonitorService');
    }
  }

  void _checkThreshold(int level) {
    if (!_alertFired && level <= _threshold) {
      _alertFired = true;
      log(
        'Low battery alert fired at $level% (threshold=$_threshold%)',
        name: 'BatteryMonitorService',
      );
      // Consumers subscribe to batteryLevel and watch for sub-threshold
      // values. The BatteryAlertController (Phase 6) detects the crossing
      // and spawns a separate SessionEngine per spec 05:1103.
    }
  }
}
