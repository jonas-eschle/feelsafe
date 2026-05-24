import 'dart:developer';

import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:guardianangela/services/protocols/wakelock_service_protocol.dart';

/// Production [WakelockServiceProtocol] backed by `package:wakelock_plus`.
///
/// Wraps [WakelockPlus.enable] / [WakelockPlus.disable] and tracks
/// the local state via [isEnabled].
///
/// **Single constructor location rule:** no `RealWakelockService()`
/// call may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces).
class RealWakelockService implements WakelockServiceProtocol {
  /// Creates a [RealWakelockService].
  RealWakelockService();

  bool _isEnabled = false;

  @override
  bool get isEnabled => _isEnabled;

  @override
  Future<void> enable() async {
    if (_isEnabled) return;
    log('enable — requesting wakelock', name: 'WakelockService');
    await WakelockPlus.enable();
    _isEnabled = true;
  }

  @override
  Future<void> disable() async {
    if (!_isEnabled) return;
    log('disable — releasing wakelock', name: 'WakelockService');
    await WakelockPlus.disable();
    _isEnabled = false;
  }
}
