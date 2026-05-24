// flutter_background_service plugin manages its own native Android foreground
// service (START_STICKY) and iOS background execution modes. The Dart side
// calls configure() to register the entry-point callbacks with the plugin;
// the native side (plugin-generated code) handles the rest.
//
// NOTE: flutter_background_service iOS support is limited to foreground
// keep-alive via BGTaskScheduler. Persistent background on iOS is not
// guaranteed by this plugin (per plugin README). The app degrades gracefully:
// the session engine still runs in the main isolate; only the background
// keep-alive is absent when iOS suspends the app.
//
// Action IDs for foreground-service notification buttons (spec 05:805-820).
// These are read by BackgroundSessionService and BackgroundSessionService
// consumers; kept here as the single definition.

import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';

import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:guardianangela/services/protocols/background_session_service_protocol.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';

import 'package:guardianangela/services/notification_service.dart'
    show kForegroundNotificationId;

/// Notification action identifier for the "I'm Safe" button.
const String kActionImSafe = 'background:im_safe';

/// Notification action identifier for the "Pause" button.
const String kActionPause = 'background:pause';

/// Notification action identifier for the "Play/Resume" button.
const String kActionResume = 'background:resume';

// ---------------------------------------------------------------------------
// Background isolate entry point (top-level — required by the plugin).
// ---------------------------------------------------------------------------

/// Entry point invoked by [FlutterBackgroundService] when the background
/// isolate starts (Android foreground service / iOS background fetch).
///
/// This function MUST be top-level and annotated with
/// `@pragma('vm:entry-point')` so the Dart AOT compiler retains it.
/// The plugin calls it via reflection; if it is not retained the background
/// isolate will fail to start silently.
///
/// The function sets the service as a foreground service (Android) and then
/// listens for the `'stop'` method emitted by the main isolate when a
/// session ends.  All session logic still runs in the main isolate; this
/// handler only keeps the process alive and responds to the stop signal.
@pragma('vm:entry-point')
void _onBackgroundStart(ServiceInstance service) {
  log('Background service started', name: 'BackgroundSessionService');

  // Promote to foreground on Android so the OS does not kill the process.
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  // Listen for a stop request from the main isolate.
  service.on('stop').listen((_) {
    log(
      'Background service stopping on request',
      name: 'BackgroundSessionService',
    );
    service.stopSelf();
  });
}

/// Production [BackgroundSessionServiceProtocol].
///
/// On Android, the foreground service is managed via
/// [NotificationServiceProtocol.showForegroundServiceNotification]. The
/// plugin-level foreground-service promotion (via
/// `flutter_background_service` with `SERVICE_TYPE_FOREGROUND`) is set up
/// in Phase 7 Kotlin code; the Dart side calls [startService] to post/update
/// the notification and [stopService] to cancel it.
///
/// On iOS, [startService] posts a persistent notification and initiates
/// a background-task keep-alive request. The plugin's iOS background
/// behaviour is limited — see the Phase 7 native dependency note above.
///
/// Action-button taps are routed via [NotificationServiceProtocol.actionTaps].
/// [onImSafe], [onPause], and [onResume] streams are backed by
/// [StreamController]s that emit when the matching action ID is received.
///
/// **Single constructor location rule:** no `RealBackgroundSessionService()`
/// call may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces).
class RealBackgroundSessionService implements BackgroundSessionServiceProtocol {
  /// Creates a [RealBackgroundSessionService].
  ///
  /// [notification] is used both to manage the foreground-service
  /// notification and to receive action taps.
  RealBackgroundSessionService({
    required NotificationServiceProtocol notification,
  }) : _notification = notification {
    _subscribeActionTaps();
  }

  final NotificationServiceProtocol _notification;

  final StreamController<void> _imSafeController =
      StreamController<void>.broadcast();
  final StreamController<void> _pauseController =
      StreamController<void>.broadcast();
  final StreamController<void> _resumeController =
      StreamController<void>.broadcast();

  StreamSubscription<String>? _actionTapsSub;

  // Cached state for pause/resume notification text (G2, G3).
  String _lastTitle = 'Guardian Angela active';
  String _lastBody = 'Your session is running.';
  bool _stealthMode = false;

  // -------------------------------------------------------------------------
  // BackgroundSessionServiceProtocol implementation
  // -------------------------------------------------------------------------

  @override
  Future<void> configure() async {
    // Register the background isolate entry point with the plugin.
    //
    // autoStart: false — the session controller starts the service explicitly
    //   via startService() when a session begins. We never want the service
    //   running in the background without an active session.
    //
    // isForegroundMode: true — Android START_STICKY foreground service.
    //   The OS will restart the process if it is killed. The persistent
    //   notification is managed separately via NotificationService.
    //
    // iOS degradation: IosConfiguration is supplied so configure() succeeds
    //   on iOS. Persistent background delivery is not guaranteed by this
    //   plugin on iOS (BGTaskScheduler window is short); the session engine
    //   runs in the main isolate and degrades gracefully when iOS suspends.
    try {
      await FlutterBackgroundService().configure(
        iosConfiguration: IosConfiguration(
          autoStart: false,
          onForeground: _onBackgroundStart,
          onBackground: (_) async {
            // iOS background fetch: keep-alive only; no long work permitted.
            log('iOS background fetch tick', name: 'BackgroundSessionService');
            return true;
          },
        ),
        androidConfiguration: AndroidConfiguration(
          onStart: _onBackgroundStart,
          isForegroundMode: true,
          autoStart: false,
          foregroundServiceNotificationId: kForegroundNotificationId,
          notificationChannelId: 'session_service',
          initialNotificationTitle: 'Guardian Angela',
          initialNotificationContent: 'Session starting…',
        ),
      );
      log(
        'BackgroundSessionService configured',
        name: 'BackgroundSessionService',
      );
    } on MissingPluginException catch (e) {
      // Plugin channel not registered (unit tests / unsupported platform).
      // Log and continue — the notification-based foreground path via
      // NotificationService is always available as a fallback.
      log(
        'BackgroundSessionService configure skipped (MissingPlugin): $e',
        name: 'BackgroundSessionService',
      );
    } catch (e) {
      // flutter_background_service throws a plain string (not an Exception)
      // when the platform is unsupported. Catch all remaining errors so the
      // app can still run in environments where the plugin is unavailable
      // (e.g. unit tests on Linux).
      log(
        'BackgroundSessionService configure skipped: $e',
        name: 'BackgroundSessionService',
      );
    }
  }

  @override
  Future<void> startService({
    required String title,
    required String body,
    bool stealth = false,
  }) async {
    log(
      'startService title="$title" stealth=$stealth',
      name: 'BackgroundSessionService',
    );
    _lastTitle = title;
    _lastBody = body;
    _stealthMode = stealth;
    await _notification.showForegroundServiceNotification(
      title: title,
      body: body,
      stealth: stealth,
    );
  }

  @override
  Future<void> updateNotification({
    required String title,
    required String body,
    bool stealth = false,
  }) async {
    log(
      'updateNotification title="$title" stealth=$stealth',
      name: 'BackgroundSessionService',
    );
    _lastTitle = title;
    _lastBody = body;
    _stealthMode = stealth;
    await _notification.showForegroundServiceNotification(
      title: title,
      body: body,
      stealth: stealth,
    );
  }

  @override
  Future<void> stopService() async {
    log('stopService', name: 'BackgroundSessionService');
    await _notification.cancel(kForegroundNotificationId);
  }

  @override
  Stream<void> get onImSafe => _imSafeController.stream;

  @override
  Stream<void> get onPause => _pauseController.stream;

  @override
  Stream<void> get onResume => _resumeController.stream;

  // -------------------------------------------------------------------------
  // Cleanup
  // -------------------------------------------------------------------------

  /// Disposes all stream controllers and cancels the action-tap subscription.
  Future<void> dispose() async {
    await _actionTapsSub?.cancel();
    await _imSafeController.close();
    await _pauseController.close();
    await _resumeController.close();
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  void _subscribeActionTaps() {
    _actionTapsSub = _notification.actionTaps.listen(_onActionTap);
  }

  void _onActionTap(String actionId) {
    switch (actionId) {
      case kActionImSafe:
        log('onImSafe action tap', name: 'BackgroundSessionService');
        _imSafeController.add(null);
      case kActionPause:
        log('onPause action tap', name: 'BackgroundSessionService');
        // Update notification text to reflect the paused state immediately
        // (spec 05:823-832). The engine-timer pause is owned by SessionController
        // (Phase 6); we only own the notification here.
        // G2: stealth mode shows "Music paused"; normal mode shows "Session
        // paused" (spec 05:825).
        _notification.showForegroundServiceNotification(
          title: _stealthMode ? 'Music paused' : 'Session paused',
          body: 'Tap Resume to continue.',
          stealth: _stealthMode,
        );
        _pauseController.add(null);
      case kActionResume:
        log('onResume action tap', name: 'BackgroundSessionService');
        // G3: restore the prior notification text, not a generic fallback.
        // Phase 6 SessionController will call updateNotification once it
        // handles the resume (spec 05:830-832).
        _notification.showForegroundServiceNotification(
          title: _lastTitle,
          body: _lastBody,
          stealth: _stealthMode,
        );
        _resumeController.add(null);
    }
  }
}
