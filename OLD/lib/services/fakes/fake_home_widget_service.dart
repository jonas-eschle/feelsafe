/// Deterministic fake implementation of
/// [HomeWidgetServiceProtocol] for tests. Every call is recorded to
/// [calls]; widget-click events are broadcast via a controller.
library;

import 'dart:async';

import 'package:guardianangela/services/protocols/home_widget_service_protocol.dart';

/// Test double for [HomeWidgetServiceProtocol].
final class FakeHomeWidgetService implements HomeWidgetServiceProtocol {
  /// Creates a fake home-widget service.
  FakeHomeWidgetService();

  /// Invocation log: one entry per method call.
  final List<String> calls = [];

  final StreamController<Uri?> _clickController =
      StreamController<Uri?>.broadcast();

  String? _pendingMarker;

  /// Scripted initial-launch URI returned by [initiallyLaunchedUri].
  Uri? initialLaunchUri;

  @override
  Future<void> registerInteractivity(Function callback) async {
    calls.add('registerInteractivity');
  }

  @override
  Stream<Uri?> get widgetClicked => _clickController.stream;

  @override
  Future<Uri?> initiallyLaunchedUri() async {
    calls.add('initiallyLaunchedUri');
    return initialLaunchUri;
  }

  @override
  Future<void> updateStatus({
    required String status,
    required String modeName,
    required bool isRunning,
  }) async {
    calls.add('updateStatus:$status/$modeName/$isRunning');
  }

  @override
  Future<void> writeLastMarker(String marker) async {
    calls.add('writeLastMarker:$marker');
    _pendingMarker = marker;
  }

  @override
  Future<String?> consumePendingMarker() async {
    calls.add('consumePendingMarker');
    final current = _pendingMarker;
    _pendingMarker = null;
    return current;
  }

  /// Test helper: synthesize a widget click on the stream.
  void injectClick(Uri? uri) {
    _clickController.add(uri);
  }

  /// Closes the widget-click stream controller.
  void dispose() {
    _clickController.close();
  }
}
