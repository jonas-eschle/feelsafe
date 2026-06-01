import 'package:guardianangela/domain/enums/home_widget_status.dart';

/// Contract for the home-screen widget bridge.
///
/// Implementations write localised status text and button labels to the
/// shared widget data store so the native widget can render without any
/// l10n logic of its own. Deep-link taps from the widget are routed by
/// the app via [HomeWidget.widgetClicked] / [HomeWidget.initiallyLaunchedFromHomeWidget].
/// Spec 04 §Home Screen Widget.
abstract interface class HomeWidgetServiceProtocol {
  /// Publishes the current session status and optional elapsed time to the
  /// home-screen widget storage and triggers a widget refresh.
  ///
  /// [status] determines which status string is written. [elapsed] is
  /// written as an `mm:ss` string when non-null (active session timer);
  /// omit or pass null to clear the timer display (idle state).
  /// [statusText] is the pre-localised label for the status line; callers
  /// resolve localisation at the controller level so the service stays
  /// locale-agnostic.
  Future<void> publishStatus({
    required HomeWidgetStatus status,
    Duration? elapsed,
    required String statusText,
    required String quickExitLabel,
    required String fakeCallLabel,
  });

  /// Registers the Dart interactivity callback so taps on widget buttons
  /// can invoke Dart code on Android (no-op on iOS where Link/AppIntent
  /// handles taps). Must be called once at app startup.
  Future<void> registerCallback();
}
