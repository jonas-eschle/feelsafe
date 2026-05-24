import 'dart:async';

import 'package:guardianangela/services/protocols/notification_service_protocol.dart';

/// Recorded invocation for [SimulationNotificationService].
final class NotificationCall {
  /// Creates a [NotificationCall].
  const NotificationCall({
    required this.method,
    this.id,
    this.title,
    this.body,
    this.contactName,
    this.actionPayload,
    this.stealth,
  });

  /// Method name.
  final String method;

  /// Notification ID (for [showDisguisedReminder] / [cancel]).
  final int? id;

  /// Notification title.
  final String? title;

  /// Notification body.
  final String? body;

  /// Contact name (for [showSmsRetryExhaustedNotification]).
  final String? contactName;

  /// Action payload (for [showSmsRetryExhaustedNotification]).
  final String? actionPayload;

  /// Stealth flag (for [showForegroundServiceNotification]).
  final bool? stealth;

  @override
  String toString() => 'NotificationCall(method: $method, id: $id)';
}

/// Simulation [NotificationServiceProtocol] for tests.
///
/// Records every method invocation. The [actionTaps] stream is a broadcast
/// [StreamController] that tests pump action IDs into via [injectActionTap].
/// Never calls `flutter_local_notifications` or any platform code.
class SimulationNotificationService implements NotificationServiceProtocol {
  /// Creates a [SimulationNotificationService].
  SimulationNotificationService();

  /// All method invocations since construction or last [reset].
  final List<NotificationCall> calls = [];

  final StreamController<String> _actionTapsController =
      StreamController<String>.broadcast();

  /// Simulated permission result returned by [requestPermission].
  ///
  /// Defaults to `true`. Tests can set this to `false` to simulate denial.
  bool simulatedPermissionGranted = true;

  // ---------------------------------------------------------------------------
  // NotificationServiceProtocol implementation
  // ---------------------------------------------------------------------------

  @override
  Future<bool> requestPermission() async {
    calls.add(const NotificationCall(method: 'requestPermission'));
    return simulatedPermissionGranted;
  }

  @override
  Future<void> showDisguisedReminder({
    required int id,
    required String title,
    required String body,
  }) async {
    calls.add(
      NotificationCall(
        method: 'showDisguisedReminder',
        id: id,
        title: title,
        body: body,
      ),
    );
  }

  @override
  Future<void> showSmsRetryExhaustedNotification({
    required String contactName,
    required String actionPayload,
  }) async {
    calls.add(
      NotificationCall(
        method: 'showSmsRetryExhaustedNotification',
        contactName: contactName,
        actionPayload: actionPayload,
      ),
    );
  }

  @override
  Future<void> showForegroundServiceNotification({
    required String title,
    required String body,
    bool stealth = false,
  }) async {
    calls.add(
      NotificationCall(
        method: 'showForegroundServiceNotification',
        title: title,
        body: body,
        stealth: stealth,
      ),
    );
  }

  @override
  Future<void> cancel(int id) async {
    calls.add(NotificationCall(method: 'cancel', id: id));
  }

  @override
  Stream<String> get actionTaps => _actionTapsController.stream;

  // ---------------------------------------------------------------------------
  // Test helpers
  // ---------------------------------------------------------------------------

  /// Injects an action tap ID into the [actionTaps] stream.
  void injectActionTap(String actionId) => _actionTapsController.add(actionId);

  /// Clears [calls].
  void reset() => calls.clear();

  /// Disposes the [actionTaps] stream controller.
  Future<void> dispose() => _actionTapsController.close();
}
