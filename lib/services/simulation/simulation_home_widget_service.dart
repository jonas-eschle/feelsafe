/// Simulation implementation of [HomeWidgetServiceProtocol]. All
/// methods log via `dart:developer` and return a no-op.
library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:guardianangela/services/protocols/home_widget_service_protocol.dart';

/// Simulation double for [HomeWidgetServiceProtocol].
final class SimulationHomeWidgetService implements HomeWidgetServiceProtocol {
  /// Creates the simulation home-widget service.
  SimulationHomeWidgetService();

  final StreamController<Uri?> _clickController =
      StreamController<Uri?>.broadcast();

  @override
  Future<void> registerInteractivity(Function callback) async {
    developer.log('[SIM] homeWidget.registerInteractivity');
  }

  @override
  Stream<Uri?> get widgetClicked => _clickController.stream;

  @override
  Future<Uri?> initiallyLaunchedUri() async {
    developer.log('[SIM] homeWidget.initiallyLaunchedUri');
    return null;
  }

  @override
  Future<void> updateStatus({
    required String status,
    required String modeName,
    required bool isRunning,
  }) async {
    developer.log(
      '[SIM] homeWidget.updateStatus $status/$modeName/$isRunning',
    );
  }

  @override
  Future<void> writeLastMarker(String marker) async {
    developer.log('[SIM] homeWidget.writeLastMarker $marker');
  }

  @override
  Future<String?> consumePendingMarker() async {
    developer.log('[SIM] homeWidget.consumePendingMarker');
    return null;
  }

  /// Closes the widget-click stream controller.
  void dispose() {
    _clickController.close();
  }
}
