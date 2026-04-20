/// `NotificationServiceProtocol` — abstract contract for session
/// notifications, disguised reminders, simulation toasts, and
/// scheduled notifications used by event strategies.
///
/// Pure Dart. The concrete implementation wraps
/// `flutter_local_notifications` in Phase 4b.
library;

import 'package:guardianangela/domain/models/reminder_template.dart';

/// Abstract contract for the notification service.
abstract class NotificationServiceProtocol {
  /// Initializes the native notification channels / permissions.
  Future<void> init();

  /// Posts the persistent session notification.
  Future<void> showSessionNotification({
    required String title,
    required String body,
    bool isSimulation = false,
  });

  /// Posts a disguised reminder rendered from [template].
  Future<void> showDisguisedReminder({
    required ReminderTemplate template,
    bool isSimulation = false,
  });

  /// Schedules a notification to fire after [delay]. Returns the
  /// notification id the caller can later pass to
  /// [cancelNotification].
  Future<int> scheduleNotification({
    required String title,
    required String body,
    required Duration delay,
    bool isSimulation = false,
  });

  /// Cancels a scheduled / posted notification by its id.
  Future<void> cancelNotification(int id);

  /// Cancels all notifications owned by the app.
  Future<void> cancelAll();

  /// Broadcast stream of notification action tap events; each
  /// payload is the tapped action id (opaque string, defined by
  /// the caller when posting).
  Stream<String> get actionTaps;

  /// Shows a short transient toast (simulation descriptions).
  Future<void> showToast(String message);
}
