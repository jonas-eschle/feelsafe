// Phase 7 native dependency: flutter_background_service plugin manages its
// own native Android foreground service (START_STICKY) and iOS background
// execution modes. The Dart side manages lifecycle and notification-action
// routing via NotificationService.
//
// NOTE: flutter_background_service iOS support is limited. If the plugin
// cannot deliver persistent background on iOS, the Phase 6 UI should
// surface a `BackgroundSessionServiceProtocol.isSupported` getter (to be
// added at that point) to grey out the option for unsupported configurations.
//
// Action IDs for foreground-service notification buttons (spec 05:805-820).
// These are read by BackgroundSessionService and BackgroundSessionService
// consumers; kept here as the single definition.

import 'dart:async';
import 'dart:developer';

import 'package:guardianangela/services/notification_service.dart'
    show kForegroundNotificationId;
import 'package:guardianangela/services/protocols/background_session_service_protocol.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';

/// Notification action identifier for the "I'm Safe" button.
const String kActionImSafe = 'background:im_safe';

/// Notification action identifier for the "Pause" button.
const String kActionPause = 'background:pause';

/// Notification action identifier for the "Play/Resume" button.
const String kActionResume = 'background:resume';

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
  RealBackgroundSessionService({required NotificationServiceProtocol notification})
    : _notification = notification {
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

  // -------------------------------------------------------------------------
  // BackgroundSessionServiceProtocol implementation
  // -------------------------------------------------------------------------

  @override
  Future<void> configure() async {
    // Phase 7: flutter_background_service.initialize() would be called here
    // to register the background isolate entry point and notification
    // channels. Until Phase 7 lands, channel setup is delegated to
    // NotificationService.init() which is already called at app startup.
    log('BackgroundSessionService configured', name: 'BackgroundSessionService');
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
        _pauseController.add(null);
      case kActionResume:
        log('onResume action tap', name: 'BackgroundSessionService');
        _resumeController.add(null);
    }
  }
}
