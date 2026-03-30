import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/models/reminder_template.dart';

/// Fires disguised reminder notifications that look like real app notifications.
///
/// Uses [flutter_local_notifications] to push system notifications styled per
/// template. The notification tap is handled via a stream that the session
/// controller listens to.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final _tapController = StreamController<String>.broadcast();

  /// Stream of notification payload strings. Emitted when the user taps
  /// a notification. The payload is the template ID.
  Stream<String> get onNotificationTap => _tapController.stream;

  bool _initialized = false;

  /// Initialize the notification plugin. Must be called once at app startup.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onTap,
    );
  }

  void _onTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      _tapController.add(payload);
    }
  }

  /// Show a disguised reminder notification for the given [template].
  ///
  /// The notification title and body come from the template. The notification
  /// channel is deliberately generic ("Reminders") so it doesn't reveal the
  /// app's safety purpose.
  Future<void> showDisguisedReminder(ReminderTemplate template) async {
    const androidDetails = AndroidNotificationDetails(
      'disguised_reminders',
      'Reminders',
      channelDescription: 'Periodic reminders',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'reminder',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use a hash of the template id as the notification id
    final notificationId = template.id.hashCode.abs() % 0x7FFFFFFF;

    await _plugin.show(
      id: notificationId,
      title: template.title,
      body: template.body,
      notificationDetails: details,
      payload: template.id,
    );
  }

  /// Cancel a specific notification by template.
  Future<void> cancelForTemplate(ReminderTemplate template) async {
    final notificationId = template.id.hashCode.abs() % 0x7FFFFFFF;
    await _plugin.cancel(id: notificationId);
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Dispose the service. Call when the app is shutting down.
  void dispose() {
    _tapController.close();
  }
}
