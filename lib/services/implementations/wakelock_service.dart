/// Real wakelock-service implementation.
///
/// Wraps `wakelock_plus` to keep the screen awake while a session is
/// active.
library;

import 'package:guardianangela/services/protocols/wakelock_service_protocol.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Real platform-backed implementation of [WakelockServiceProtocol].
final class WakelockService implements WakelockServiceProtocol {
  /// Creates the real wakelock service.
  WakelockService();

  @override
  Future<void> enable() async => WakelockPlus.enable();

  @override
  Future<void> disable() async => WakelockPlus.disable();

  @override
  Future<bool> get isEnabled async => WakelockPlus.enabled;
}
