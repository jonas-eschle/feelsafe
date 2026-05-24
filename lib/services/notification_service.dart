// Native platform integration: flutter_local_notifications (cross-platform).
// No custom channel needed — flutter_local_notifications handles Android + iOS.

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:guardianangela/services/protocols/notification_service_protocol.dart';

// ---------------------------------------------------------------------------
// Channel identifiers (spec 05 §Notification Channel Architecture)
// ---------------------------------------------------------------------------

const String _kSessionServiceChannelId = 'session_service';
const String _kSessionServiceChannelName = 'System Service';

const String _kRemindersChannelId = 'reminders';
const String _kRemindersChannelName = 'Reminders';

const String _kAlarmChannelId = 'alarm';
const String _kAlarmChannelName = 'Alerts';

const String _kUpdatesChannelId = 'updates';
const String _kUpdatesChannelName = 'Updates';

/// ID used for the foreground-service persistent notification.
const int kForegroundNotificationId = 1;

/// Production [NotificationServiceProtocol] backed by
/// `package:flutter_local_notifications`.
///
/// Four notification channels are registered at construction time:
/// - `session_service` (Low) — persistent foreground-service notification.
/// - `reminders` (High) — disguised check-in reminders with max urgency so
///   they surface on the lock screen (spec 05 §Extra 35).
/// - `alarm` (Max) — urgent escalation and emergency notifications.
/// - `updates` (Default) — app updates and general info.
///
/// The `requestPermission()` method requests Android 13+
/// POST_NOTIFICATIONS and iOS alert/sound/badge permissions.
///
/// Action-button taps are forwarded to [actionTaps] via the
/// [FlutterLocalNotificationsPlugin.initialize] callback.
///
/// **Single constructor location rule:** no `RealNotificationService()`
/// call may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces).
class RealNotificationService implements NotificationServiceProtocol {
  /// Creates a [RealNotificationService].
  ///
  /// [plugin] — optional [FlutterLocalNotificationsPlugin] for injection;
  /// defaults to the singleton.
  RealNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<String> _actionTapsController =
      StreamController<String>.broadcast();
  bool _initialised = false;

  /// Initialises the plugin and registers all four notification channels.
  ///
  /// Must be called once at app startup before any `show*` method.
  Future<void> init() async {
    if (_initialised) return;
    _initialised = true;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onResponse,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundResponse,
    );

    if (Platform.isAndroid) {
      await _createAndroidChannels();
    }

    log('NotificationService initialised', name: 'NotificationService');
  }

  // ---------------------------------------------------------------------------
  // NotificationServiceProtocol implementation
  // ---------------------------------------------------------------------------

  @override
  Future<bool> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
        log(
          'Android notification permission: $granted',
          name: 'NotificationService',
        );
        return granted ?? false;
      }
      if (Platform.isIOS) {
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        log(
          'iOS notification permission: $granted',
          name: 'NotificationService',
        );
        return granted ?? false;
      }
      // Desktop / macOS — assume granted.
      return true;
    } catch (e) {
      log('requestPermission error: $e', name: 'NotificationService');
      return false;
    }
  }

  @override
  Future<void> showDisguisedReminder({
    required int id,
    required String title,
    required String body,
  }) async {
    log(
      'showDisguisedReminder id=$id title="$title"',
      name: 'NotificationService',
    );
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _kRemindersChannelId,
        _kRemindersChannelName,
        importance: Importance.max,
        priority: Priority.max,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
      ),
      iOS: DarwinNotificationDetails(
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
    await _plugin.show(id: id, title: title, body: body, notificationDetails: details);
  }

  @override
  Future<void> showSmsRetryExhaustedNotification({
    required String contactName,
    required String actionPayload,
  }) async {
    log(
      'showSmsRetryExhaustedNotification contact=$contactName',
      name: 'NotificationService',
    );
    const channelId = 'ga_sms_retry';
    const channelName = 'SMS Retry';

    final actionId = kActionRetrySmsPrefix + actionPayload;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
        actions: [
          AndroidNotificationAction(actionId, 'Retry'),
        ],
      ),
    );
    await _plugin.show(
      id: actionPayload.hashCode,
      title: 'SMS to $contactName never sent',
      body: 'Tap to retry manually.',
      notificationDetails: details,
    );
  }

  @override
  Future<void> showForegroundServiceNotification({
    required String title,
    required String body,
    bool stealth = false,
  }) async {
    log(
      'showForegroundServiceNotification stealth=$stealth',
      name: 'NotificationService',
    );
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _kSessionServiceChannelId,
        _kSessionServiceChannelName,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
      ),
    );
    await _plugin.show(
      id: kForegroundNotificationId,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  @override
  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
    log('cancel id=$id', name: 'NotificationService');
  }

  @override
  Stream<String> get actionTaps => _actionTapsController.stream;

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _onResponse(NotificationResponse response) {
    final payload = response.actionId ?? response.payload;
    if (payload != null) {
      _actionTapsController.add(payload);
      log('onResponse payload=$payload', name: 'NotificationService');
    }
  }

  Future<void> _createAndroidChannels() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _kSessionServiceChannelId,
        _kSessionServiceChannelName,
        importance: Importance.low,
      ),
    );
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _kRemindersChannelId,
        _kRemindersChannelName,
        importance: Importance.high,
      ),
    );
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _kAlarmChannelId,
        _kAlarmChannelName,
        importance: Importance.max,
      ),
    );
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _kUpdatesChannelId,
        _kUpdatesChannelName,
      ),
    );
    log('Android channels created', name: 'NotificationService');
  }
}

// ---------------------------------------------------------------------------
// Background handler — must be a top-level function.
// ---------------------------------------------------------------------------

/// Background notification response handler (top-level, required by
/// `flutter_local_notifications`).
@pragma('vm:entry-point')
void _onBackgroundResponse(NotificationResponse response) {
  // Background handling is managed at the app layer (Phase 6). Log only.
}
