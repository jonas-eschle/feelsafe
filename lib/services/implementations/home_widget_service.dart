/// Real home-widget-service implementation.
///
/// Wraps the `home_widget` package to back the home-screen widget
/// that can arm / trigger the app and surface current session status.
library;

import 'dart:async';

import 'package:home_widget/home_widget.dart';

import 'package:guardianangela/services/protocols/home_widget_service_protocol.dart';

/// Real platform-backed implementation of
/// [HomeWidgetServiceProtocol].
final class HomeWidgetService implements HomeWidgetServiceProtocol {
  /// Creates the real home-widget service.
  HomeWidgetService();

  /// Key used to persist the most recent marker. The invariant is
  /// "return-and-clear atomic" — see [consumePendingMarker].
  static const String _markerKey = 'ga_last_marker';

  /// Key used to persist the current session status label.
  static const String _statusKey = 'ga_status';

  /// Key used to persist the current mode name.
  static const String _modeNameKey = 'ga_mode_name';

  /// Key used to persist the running flag.
  static const String _runningKey = 'ga_running';

  /// Android widget provider class name. Phase 10 registers the
  /// matching Kotlin side.
  static const String _androidWidgetProvider = 'GuardianAngelaWidget';

  /// iOS widget name. Phase 10 registers the matching Swift side.
  static const String _iosWidgetName = 'GuardianAngelaWidget';

  @override
  Future<void> registerInteractivity(Function callback) async {
    await HomeWidget.registerInteractivityCallback(
      callback as FutureOr<void> Function(Uri?),
    );
  }

  @override
  Stream<Uri?> get widgetClicked => HomeWidget.widgetClicked;

  @override
  Future<Uri?> initiallyLaunchedUri() =>
      HomeWidget.initiallyLaunchedFromHomeWidget();

  @override
  Future<void> updateStatus({
    required String status,
    required String modeName,
    required bool isRunning,
  }) async {
    await HomeWidget.saveWidgetData<String>(_statusKey, status);
    await HomeWidget.saveWidgetData<String>(_modeNameKey, modeName);
    await HomeWidget.saveWidgetData<bool>(_runningKey, isRunning);
    await HomeWidget.updateWidget(
      androidName: _androidWidgetProvider,
      iOSName: _iosWidgetName,
    );
  }

  @override
  Future<void> writeLastMarker(String marker) =>
      HomeWidget.saveWidgetData<String>(_markerKey, marker);

  @override
  Future<String?> consumePendingMarker() async {
    final marker = await HomeWidget.getWidgetData<String>(_markerKey);
    if (marker == null) return null;
    // Clear atomically so the same marker is never delivered twice.
    await HomeWidget.saveWidgetData<String?>(_markerKey, null);
    return marker;
  }
}
