// Native platform integration: flutter_local_notifications (cross-platform).
// No custom channel needed — flutter_local_notifications handles Android + iOS.

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Android notification channel ID for SMS retry exhaustion alerts.
///
/// High importance so the user sees delivery failures even in DND mode.
/// Defined as a public constant for test assertions and channel registration
/// verification (spec 05 §Extra-35 / F9).
const String kSmsRetryChannelId = 'ga_sms_retry';

/// SharedPreferences key for notification actions received while the app was
/// killed (Android background isolate). Populated by [_onBackgroundResponse]
/// and drained on next foreground startup by [RealNotificationService.init].
const String _kPendingActionsKey = 'pending_notification_actions';

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
  ///
  /// [prefsFactory] — optional factory for [SharedPreferences] used in
  /// [_replayPendingActions]. Defaults to [SharedPreferences.getInstance].
  /// Tests inject a factory that returns a pre-seeded instance.
  ///
  /// [forceAndroidChannels] — when `true`, [_createAndroidChannels] is called
  /// unconditionally regardless of [Platform.isAndroid]. Use only in tests
  /// that inject a mock [AndroidFlutterLocalNotificationsPlugin] via
  /// [resolvePlatformSpecificImplementation].
  RealNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    Future<SharedPreferences> Function()? prefsFactory,
    bool forceAndroidChannels = false,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _prefsFactory = prefsFactory ?? SharedPreferences.getInstance,
       _forceAndroidChannels = forceAndroidChannels {
    _actionTapsController = StreamController<String>.broadcast(
      onListen: _flushPending,
    );
  }

  final FlutterLocalNotificationsPlugin _plugin;
  final Future<SharedPreferences> Function() _prefsFactory;
  final bool _forceAndroidChannels;
  late final StreamController<String> _actionTapsController;
  bool _initialised = false;

  /// Action IDs received while the app was killed, waiting to be flushed once
  /// a subscriber connects to [actionTaps].
  final List<String> _pendingReplay = [];

  /// Initialises the plugin and registers all four notification channels.
  ///
  /// Reads and clears any [_kPendingActionsKey] entries persisted by
  /// [_onBackgroundResponse] while the app was killed. These are stored in
  /// [_pendingReplay] and flushed to the [actionTaps] stream the first time
  /// a subscriber connects (via the [StreamController.broadcast] `onListen`
  /// callback).
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

    if (Platform.isAndroid || _forceAndroidChannels) {
      await _createAndroidChannels();
    }

    // Drain any actions that arrived while the app was killed. Must happen
    // AFTER plugin init so the pending list is populated before any listener
    // calls actionTaps.listen(). The actual emit to the stream happens in
    // _flushPending() when the first subscriber connects.
    await _replayPendingActions();

    log('NotificationService initialised', name: 'NotificationService');
  }

  // ---------------------------------------------------------------------------
  // Background-action replay
  // ---------------------------------------------------------------------------

  /// Reads the persisted pending-action list from [SharedPreferences] and
  /// copies it into [_pendingReplay], then clears the persisted key.
  ///
  /// The list is emitted to [actionTaps] on first subscriber connect via
  /// [_flushPending].
  Future<void> _replayPendingActions() async {
    try {
      final prefs = await _prefsFactory();
      final stored = prefs.getStringList(_kPendingActionsKey);
      if (stored != null && stored.isNotEmpty) {
        _pendingReplay.addAll(stored);
        await prefs.remove(_kPendingActionsKey);
        log(
          'Queued ${stored.length} pending background action(s) for replay',
          name: 'NotificationService',
        );
      }
    } catch (e) {
      log(
        'Failed to read pending background actions: $e',
        name: 'NotificationService',
      );
    }
  }

  /// Called by [_actionTapsController]'s `onListen` when the first subscriber
  /// attaches to [actionTaps].
  ///
  /// Emits all [_pendingReplay] items in order and then clears the buffer.
  void _flushPending() {
    if (_pendingReplay.isEmpty) return;
    final items = List<String>.from(_pendingReplay);
    _pendingReplay.clear();
    for (final actionId in items) {
      log(
        'Replaying background action: $actionId',
        name: 'NotificationService',
      );
      _actionTapsController.add(actionId);
    }
  }

  // ---------------------------------------------------------------------------
  // NotificationServiceProtocol implementation
  // ---------------------------------------------------------------------------

  /// Maps a high-level [NotificationChannelKey] to the underlying
  /// Android channel id used in [_createAndroidChannels].
  ///
  /// `fakeCall` reuses the `alarm` channel because spec 05 does not
  /// allocate a separate channel for fake-call screens — the alarm
  /// channel's max-importance + full-screen-intent flags are exactly
  /// what the fake-call UI requires.
  static String _channelIdFor(NotificationChannelKey c) => switch (c) {
    NotificationChannelKey.alarm => _kAlarmChannelId,
    NotificationChannelKey.reminder => _kRemindersChannelId,
    NotificationChannelKey.fakeCall => _kAlarmChannelId,
  };

  @override
  Future<bool> isChannelEnabled(NotificationChannelKey channel) async {
    if (!Platform.isAndroid) {
      // iOS / desktop expose only the overall app-level toggle. Fall
      // back to the permission status returned by the OS.
      try {
        final iOSImpl = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        final granted = await iOSImpl?.checkPermissions();
        return granted?.isEnabled ?? true;
      } catch (e) {
        log('isChannelEnabled iOS error: $e', name: 'NotificationService');
        return true;
      }
    }
    try {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final channels = await androidImpl?.getNotificationChannels();
      if (channels == null) return true;
      final id = _channelIdFor(channel);
      for (final ch in channels) {
        if (ch.id == id) {
          return ch.importance != Importance.none;
        }
      }
      return true;
    } catch (e) {
      log(
        'isChannelEnabled Android error: $e',
        name: 'NotificationService',
      );
      return true;
    }
  }

  @override
  Future<void> openChannelSettings(NotificationChannelKey channel) async {
    if (!Platform.isAndroid) {
      // iOS / desktop only expose the app-level settings panel.
      // Caller falls back to permission_handler.openAppSettings().
      return;
    }
    try {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidImpl?.requestNotificationsPermission();
    } catch (e) {
      log(
        'openChannelSettings error: $e',
        name: 'NotificationService',
      );
    }
  }

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
            ?.requestPermissions(alert: true, badge: true, sound: true);
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
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
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
    const channelId = kSmsRetryChannelId;
    const channelName = 'SMS Retry';

    final actionId = kActionRetrySmsPrefix + actionPayload;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
        actions: [AndroidNotificationAction(actionId, 'Retry')],
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
  Future<void> showAlarmEscalation({
    required int id,
    required String title,
    required String body,
    String sound = 'critical_alert.wav',
  }) async {
    log(
      'showAlarmEscalation id=$id title="$title"',
      name: 'NotificationService',
    );
    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        _kAlarmChannelId,
        _kAlarmChannelName,
        importance: Importance.max,
        priority: Priority.max,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
      ),
      iOS: DarwinNotificationDetails(
        // InterruptionLevel.critical bypasses Focus/DND and requires the
        // com.apple.developer.usernotifications.critical-alerts entitlement
        // provisioned in ios/Runner/Runner.entitlements (spec 05:880-886).
        interruptionLevel: InterruptionLevel.critical,
        sound: sound,
      ),
    );
    await _plugin.show(
      id: id,
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
    // ga_sms_retry: High importance so the user sees SMS delivery failures
    // without it being confused with session reminders (spec 05:296).
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        kSmsRetryChannelId,
        'SMS Retry',
        description:
            'Notifications when an SMS message failed to deliver after retries.',
        importance: Importance.high,
      ),
    );
    log('Android channels created (5 channels)', name: 'NotificationService');
  }
}

// ---------------------------------------------------------------------------
// Background handler — must be a top-level function.
// ---------------------------------------------------------------------------

/// Background notification response handler (top-level, required by
/// `flutter_local_notifications`).
///
/// Called by the OS in a brand-new isolate when the user taps a notification
/// action while the app is killed (Android). The action ID is persisted via
/// [SharedPreferences] under [_kPendingActionsKey] so the main isolate can
/// replay it on the next foreground startup (see [RealNotificationService.init]).
///
/// Ordering is preserved: the list is appended to, not replaced.
@pragma('vm:entry-point')
Future<void> _onBackgroundResponse(NotificationResponse response) async {
  final actionId = response.actionId ?? response.payload;
  if (actionId == null || actionId.isEmpty) return;

  try {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_kPendingActionsKey) ?? [];
    existing.add(actionId);
    await prefs.setStringList(_kPendingActionsKey, existing);
    log(
      'Background response persisted: $actionId',
      name: 'NotificationService',
    );
  } catch (e) {
    log(
      'Failed to persist background notification action: $e',
      name: 'NotificationService',
    );
  }
}
