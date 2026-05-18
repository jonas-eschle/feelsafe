/// Real implementation of [BackgroundSessionServiceProtocol].
///
/// Wraps [NotificationServiceProtocol] for the persistent session
/// notification and translates the underlying string action-id
/// stream into the typed [BackgroundAction] enum the session
/// controller consumes. Audit Q3.
///
/// Action-id mapping (matches the strings the notification layer
/// already uses for disarm-trigger and the foreground service):
/// * `imSafe`, `disarmTriggerEnd`, `endSession` → [BackgroundAction.imSafe]
/// * `pause` → [BackgroundAction.pause]
/// * `resume`, `disarmTriggerContinue` → [BackgroundAction.resume]
library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:guardianangela/services/protocols/background_session_service_protocol.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';

/// Default action-id → [BackgroundAction] mapping. Exposed as a
/// constant so call sites and tests can refer to the same source of
/// truth.
const Map<String, BackgroundAction> kBackgroundActionMap =
    <String, BackgroundAction>{
      'imSafe': BackgroundAction.imSafe,
      'endSession': BackgroundAction.imSafe,
      'disarmTriggerEnd': BackgroundAction.imSafe,
      'pause': BackgroundAction.pause,
      'resume': BackgroundAction.resume,
      'disarmTriggerContinue': BackgroundAction.resume,
    };

/// Real implementation of [BackgroundSessionServiceProtocol].
final class BackgroundSessionService
    implements BackgroundSessionServiceProtocol {
  /// Creates the service.
  ///
  /// [notification] supplies the persistent-notification surface.
  /// [actionMap] overrides the default string→action mapping (used
  /// by tests).
  BackgroundSessionService({
    required NotificationServiceProtocol notification,
    Map<String, BackgroundAction>? actionMap,
  }) : _notification = notification,
       _actionMap = actionMap ?? kBackgroundActionMap;

  final NotificationServiceProtocol _notification;
  final Map<String, BackgroundAction> _actionMap;

  final StreamController<BackgroundAction> _actionsController =
      StreamController<BackgroundAction>.broadcast();
  StreamSubscription<String>? _tapSub;
  bool _running = false;

  @override
  Stream<BackgroundAction> get actions => _actionsController.stream;

  @override
  bool get isRunning => _running;

  @override
  Future<void> start({
    required String title,
    required String body,
    bool isSimulation = false,
  }) async {
    await _notification.showSessionNotification(
      title: title,
      body: body,
      isSimulation: isSimulation,
    );
    _tapSub ??= _notification.actionTaps.listen(_onActionTap);
    _running = true;
  }

  @override
  Future<void> updateStatus({
    required String title,
    required String body,
    bool isSimulation = false,
  }) async {
    if (!_running) return;
    await _notification.showSessionNotification(
      title: title,
      body: body,
      isSimulation: isSimulation,
    );
  }

  @override
  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    await _tapSub?.cancel();
    _tapSub = null;
    // Cancel the persistent session notification (id 1 — same as
    // `_sessionNotificationId` in NotificationService). Use cancelAll
    // here would be too aggressive — disguised reminders may still be
    // valid.
    await _notification.cancelNotification(1);
  }

  void _onActionTap(String actionId) {
    final action = _actionMap[actionId];
    if (action == null) {
      developer.log('[BackgroundSessionService] unknown action id: $actionId');
      return;
    }
    _actionsController.add(action);
  }

  /// Closes the broadcast controller. Wire from
  /// `ref.onDispose(...)` in `service_providers.dart`.
  Future<void> dispose() async {
    await stop();
    if (!_actionsController.isClosed) {
      await _actionsController.close();
    }
  }
}
