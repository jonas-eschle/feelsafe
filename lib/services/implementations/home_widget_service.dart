/// Real home-widget-service implementation stub. Phase 9 fills bodies.
library;

import 'package:guardianangela/services/protocols/home_widget_service_protocol.dart';

/// Real platform-backed implementation of
/// [HomeWidgetServiceProtocol].
final class HomeWidgetService implements HomeWidgetServiceProtocol {
  /// Creates the real home-widget service.
  HomeWidgetService();

  @override
  Future<void> registerInteractivity(Function callback) async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Stream<Uri?> get widgetClicked =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<Uri?> initiallyLaunchedUri() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> updateStatus({
    required String status,
    required String modeName,
    required bool isRunning,
  }) async => throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<void> writeLastMarker(String marker) async =>
      throw UnimplementedError('TODO: Phase 9 real impl');

  @override
  Future<String?> consumePendingMarker() async =>
      throw UnimplementedError('TODO: Phase 9 real impl');
}
