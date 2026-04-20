/// Real notification-service implementation.
///
/// Wraps `flutter_local_notifications`. Channels:
/// * `ga_session` — persistent foreground session notification (id 1)
/// * `ga_reminders` — disguised reminders
/// * `ga_toasts` — transient simulation toasts (auto-dismiss)
///
/// `scheduleNotification` is Timer-backed (per AUDIT_RISK_8 fix) so
/// cancellation is deterministic without relying on native exact-
/// alarm plumbing. `isSimulation` short-circuits to toast delivery
/// only (4-layer defense layer 2).
library;

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';

/// Real platform-backed implementation of
/// [NotificationServiceProtocol].
final class NotificationService implements NotificationServiceProtocol {
  /// Creates the real notification service.
  NotificationService();

  /// Persistent-session notification id.
  static const int _sessionNotificationId = 1;

  /// Reminder-channel id.
  static const String _reminderChannelId = 'ga_reminders';

  /// Session-channel id.
  static const String _sessionChannelId = 'ga_session';

  /// Toast-channel id.
  static const String _toastChannelId = 'ga_toasts';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<String> _actionController =
      StreamController<String>.broadcast();

  /// In-flight timers for Dart-scheduled notifications. Keyed by id.
  final Map<int, Timer> _scheduledTimers = <int, Timer>{};

  int _nextId = 1000;
  bool _initialized = false;

  @override
  Stream<String> get actionTaps => _actionController.stream;

  @override
  Future<void> init() async {
    if (_initialized) return;
    const androidInit = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onResponse,
    );

    // Register Android channels explicitly.
    if (Platform.isAndroid) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidImpl?.createNotificationChannel(
        const AndroidNotificationChannel(
          _sessionChannelId,
          'Guardian Angela session',
          description: 'Shown while a safety session is running.',
          importance: Importance.high,
        ),
      );
      await androidImpl?.createNotificationChannel(
        const AndroidNotificationChannel(
          _reminderChannelId,
          'Reminders',
          description: 'Disguised reminders.',
          importance: Importance.high,
        ),
      );
      await androidImpl?.createNotificationChannel(
        const AndroidNotificationChannel(
          _toastChannelId,
          'Toasts',
          description: 'Short transient notifications.',
          importance: Importance.low,
        ),
      );
    }
    _initialized = true;
  }

  @override
  Future<void> showSessionNotification({
    required String title,
    required String body,
    bool isSimulation = false,
  }) async {
    if (isSimulation) {
      developer.log('[SIM-BLOCK] showSessionNotification title=$title');
      await showToast('$title — $body');
      return;
    }
    await _ensureInit();
    await _plugin.show(
      id: _sessionNotificationId,
      title: title,
      body: body,
      notificationDetails: _notificationDetails(
        channelId: _sessionChannelId,
        ongoing: true,
        importance: Importance.high,
      ),
    );
  }

  @override
  Future<void> showDisguisedReminder({
    required ReminderTemplate template,
    bool isSimulation = false,
  }) async {
    if (isSimulation) {
      developer.log(
        '[SIM-BLOCK] showDisguisedReminder name=${template.name}',
      );
      await showToast('${template.title} — ${template.body}');
      return;
    }
    await _ensureInit();
    await _plugin.show(
      id: _allocId(),
      title: template.title,
      body: template.body,
      notificationDetails: _notificationDetails(
        channelId: _reminderChannelId,
        ongoing: false,
        importance: Importance.high,
      ),
    );
  }

  @override
  Future<int> scheduleNotification({
    required String title,
    required String body,
    required Duration delay,
    bool isSimulation = false,
  }) async {
    if (isSimulation) {
      developer.log(
        '[SIM-BLOCK] scheduleNotification title=$title '
        'delay=${delay.inSeconds}s',
      );
      // Return a deterministic no-op id so callers can still track it.
      return _allocId();
    }
    await _ensureInit();
    final id = _allocId();
    _scheduledTimers[id] = Timer(delay, () async {
      _scheduledTimers.remove(id);
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: _notificationDetails(
          channelId: _reminderChannelId,
          ongoing: false,
          importance: Importance.high,
        ),
      );
    });
    return id;
  }

  @override
  Future<void> cancelNotification(int id) async {
    _scheduledTimers.remove(id)?.cancel();
    await _ensureInit();
    await _plugin.cancel(id: id);
  }

  @override
  Future<void> cancelAll() async {
    for (final timer in _scheduledTimers.values) {
      timer.cancel();
    }
    _scheduledTimers.clear();
    await _ensureInit();
    await _plugin.cancelAll();
  }

  @override
  Future<void> showToast(String message) async {
    await _ensureInit();
    final id = _allocId();
    await _plugin.show(
      id: id,
      title: message,
      body: null,
      notificationDetails: _notificationDetails(
        channelId: _toastChannelId,
        ongoing: false,
        importance: Importance.low,
      ),
    );
    // Auto-dismiss after 3 seconds so the toast stays transient.
    Timer(
      const Duration(seconds: 3),
      () => _plugin.cancel(id: id),
    );
  }

  /// Builds [NotificationDetails] for a given channel.
  NotificationDetails _notificationDetails({
    required String channelId,
    required bool ongoing,
    required Importance importance,
  }) => NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      channelId,
      importance: importance,
      priority: _priorityFor(importance),
      ongoing: ongoing,
      autoCancel: !ongoing,
    ),
    iOS: const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  Priority _priorityFor(Importance importance) => switch (importance) {
    Importance.max => Priority.max,
    Importance.high => Priority.high,
    Importance.defaultImportance => Priority.defaultPriority,
    Importance.low => Priority.low,
    Importance.min => Priority.min,
    _ => Priority.defaultPriority,
  };

  int _allocId() => _nextId++;

  Future<void> _ensureInit() async {
    if (!_initialized) await init();
  }

  void _onResponse(NotificationResponse response) {
    final payload = response.payload ?? response.actionId;
    if (payload != null && payload.isNotEmpty) {
      _actionController.add(payload);
    }
  }
}
