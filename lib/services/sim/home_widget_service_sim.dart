import 'dart:developer';

import 'package:guardianangela/domain/enums/home_widget_status.dart';
import 'package:guardianangela/services/protocols/home_widget_service_protocol.dart';

/// Simulation [HomeWidgetServiceProtocol] that logs calls and records them for
/// tests; never touches the `home_widget` plugin or any platform channel.
///
/// Exposed as [SimulationHomeWidgetService] so tests can override
/// [homeWidgetServiceProvider] and inspect [calls].
final class SimulationHomeWidgetService implements HomeWidgetServiceProtocol {
  /// All [publishStatus] invocations since construction, in call order.
  final List<Map<String, Object?>> calls = [];

  /// Whether [registerCallback] has been called.
  bool callbackRegistered = false;

  @override
  Future<void> publishStatus({
    required HomeWidgetStatus status,
    Duration? elapsed,
    required String statusText,
    required String quickExitLabel,
    required String fakeCallLabel,
  }) async {
    calls.add(<String, Object?>{
      'status': status,
      'elapsed': elapsed,
      'statusText': statusText,
      'quickExitLabel': quickExitLabel,
      'fakeCallLabel': fakeCallLabel,
    });
    log(
      'sim home_widget publishStatus: status=${status.name} elapsed=$elapsed',
      name: 'HomeWidgetServiceSim',
    );
  }

  @override
  Future<void> registerCallback() async {
    callbackRegistered = true;
    log('sim home_widget registerCallback', name: 'HomeWidgetServiceSim');
  }
}
