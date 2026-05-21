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

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:guardianangela/core/platform/platform_info.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';

/// Factory that builds a fresh [FlutterLocalNotificationsPlugin].
/// Injected by tests to substitute a mock.
typedef NotificationPluginFactory = FlutterLocalNotificationsPlugin Function();

/// Real platform-backed implementation of
/// [NotificationServiceProtocol].
final class NotificationService implements NotificationServiceProtocol {
  /// Creates the real notification service.
  ///
  /// [platform] defaults to the const production [PlatformInfo()];
  /// tests inject a [FakePlatformInfo] to exercise the Android-channel
  /// registration path.
  /// [pluginFactory] defaults to building a real
  /// [FlutterLocalNotificationsPlugin]; tests inject a mock so the
  /// plugin-boundary branches can be exercised on the Linux host.
  NotificationService({
    PlatformInfo platform = const PlatformInfo(),
    NotificationPluginFactory? pluginFactory,
  }) : _platform = platform,
       _plugin = (pluginFactory ?? FlutterLocalNotificationsPlugin.new)();

  final PlatformInfo _platform;

  /// Persistent-session notification id.
  static const int _sessionNotificationId = 1;

  /// Disarm-trigger notification id (single-slot — overrides the
  /// previous one if a new disarm trigger fires).
  static const int _disarmTriggerNotificationId = 2;

  /// Disarm-trigger end-session action id (forwarded on actionTaps).
  static const String _disarmTriggerEndActionId = 'disarmTriggerEnd';

  /// Disarm-trigger continue action id (forwarded on actionTaps).
  static const String _disarmTriggerContinueActionId = 'disarmTriggerContinue';

  /// Reminder-channel id.
  static const String _reminderChannelId = 'ga_reminders';

  /// Session-channel id.
  static const String _sessionChannelId = 'ga_session';

  /// Toast-channel id.
  static const String _toastChannelId = 'ga_toasts';

  final FlutterLocalNotificationsPlugin _plugin;

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
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    // Linux desktop is non-shipping but we want `flutter run -d linux`
    // to boot for development. The default-icon name is required by
    // flutter_local_notifications even when it is never invoked.
    const linuxInit = LinuxInitializationSettings(defaultActionName: 'Open');
    const settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
      macOS: iosInit,
      linux: linuxInit,
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onResponse,
    );

    // Register Android channels explicitly.
    if (_platform.isAndroid) {
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
      developer.log('[SIM-BLOCK] showDisguisedReminder name=${template.name}');
      await showToast('${template.title} — ${template.body}');
      return;
    }
    await _ensureInit();
    // Fix for specs.json Block #3 clarification (StealthConfig
    // consumers): this path always renders the template's `title` and
    // `body` — there is no "branded Guardian Angela" alternative
    // surface. `StealthConfig.notificationDisguise` therefore does
    // not gate WHETHER this method is called; it is a preference
    // toggle the reminder-template UI uses when composing the
    // template itself (so a user who opts out of disguise can still
    // pick a plainly-named reminder template).
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
    // bugs.json Warn 2: track the timer in _scheduledTimers so
    // dispose() cancels it. Otherwise toasts fired in the 3s before
    // teardown would still call _plugin.cancel after the plugin is
    // closed.
    _scheduledTimers[id] = Timer(const Duration(seconds: 3), () {
      _scheduledTimers.remove(id);
      _plugin.cancel(id: id);
    });
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

  @override
  Future<void> showDisarmTriggerNotification({
    required String title,
    required String body,
    required String endSessionLabel,
    required String continueLabel,
  }) async {
    await _ensureInit();
    await _plugin.show(
      id: _disarmTriggerNotificationId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _sessionChannelId,
          'Guardian Angela session',
          importance: Importance.high,
          priority: Priority.high,
          ongoing: false,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              _disarmTriggerEndActionId,
              endSessionLabel,
            ),
            AndroidNotificationAction(
              _disarmTriggerContinueActionId,
              continueLabel,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// Releases the action-tap controller and cancels every pending
  /// timer (including toast auto-dismiss and scheduled notifications).
  ///
  /// Fix for bugs.json Warn (leak — _actionController never closed,
  /// toast Timer fire-and-forget). Idempotent.
  Future<void> dispose() async {
    for (final timer in _scheduledTimers.values) {
      timer.cancel();
    }
    _scheduledTimers.clear();
    if (!_actionController.isClosed) {
      await _actionController.close();
    }
  }
}
