import 'dart:async';

import 'package:guardianangela/services/protocols/background_session_service_protocol.dart';

/// A recorded invocation for [SimulationBackgroundSessionService].
final class BackgroundSessionCall {
  /// Creates a [BackgroundSessionCall].
  const BackgroundSessionCall({
    required this.method,
    this.title,
    this.body,
    this.stealth,
    this.fakeName,
  });

  /// Method name: `configure`, `startService`, `updateNotification`,
  /// `stopService`.
  final String method;

  /// Notification title (for `startService` / `updateNotification`).
  final String? title;

  /// Notification body (for `startService` / `updateNotification`).
  final String? body;

  /// Stealth flag (for `startService` / `updateNotification`).
  final bool? stealth;

  /// Disguise app name (for `startService` / `updateNotification`).
  final String? fakeName;

  @override
  String toString() => 'BackgroundSessionCall(method: $method)';
}

/// Simulation [BackgroundSessionServiceProtocol] for tests.
///
/// Records every method call. Action-button taps can be injected via
/// [injectImSafe], [injectPause], and [injectResume] for stream testing.
/// Never starts a real foreground service or platform notification.
class SimulationBackgroundSessionService
    implements BackgroundSessionServiceProtocol {
  /// Creates a [SimulationBackgroundSessionService].
  SimulationBackgroundSessionService();

  /// All method invocations since construction or last [reset].
  final List<BackgroundSessionCall> calls = [];

  final StreamController<void> _imSafeController =
      StreamController<void>.broadcast();
  final StreamController<void> _pauseController =
      StreamController<void>.broadcast();
  final StreamController<void> _resumeController =
      StreamController<void>.broadcast();

  // -------------------------------------------------------------------------
  // BackgroundSessionServiceProtocol implementation
  // -------------------------------------------------------------------------

  @override
  Future<void> configure() async {
    calls.add(const BackgroundSessionCall(method: 'configure'));
  }

  @override
  Future<void> startService({
    required String title,
    required String body,
    bool stealth = false,
    String? fakeName,
  }) async {
    calls.add(
      BackgroundSessionCall(
        method: 'startService',
        title: title,
        body: body,
        stealth: stealth,
        fakeName: fakeName,
      ),
    );
  }

  @override
  Future<void> updateNotification({
    required String title,
    required String body,
    bool stealth = false,
    String? fakeName,
  }) async {
    calls.add(
      BackgroundSessionCall(
        method: 'updateNotification',
        title: title,
        body: body,
        stealth: stealth,
        fakeName: fakeName,
      ),
    );
  }

  @override
  Future<void> stopService() async {
    calls.add(const BackgroundSessionCall(method: 'stopService'));
  }

  @override
  Stream<void> get onImSafe => _imSafeController.stream;

  @override
  Stream<void> get onPause => _pauseController.stream;

  @override
  Stream<void> get onResume => _resumeController.stream;

  // -------------------------------------------------------------------------
  // Test helpers
  // -------------------------------------------------------------------------

  /// Emits an [onImSafe] event.
  void injectImSafe() => _imSafeController.add(null);

  /// Emits an [onPause] event.
  void injectPause() => _pauseController.add(null);

  /// Emits an [onResume] event.
  void injectResume() => _resumeController.add(null);

  /// Clears [calls].
  void reset() => calls.clear();

  /// Disposes all stream controllers.
  Future<void> dispose() async {
    await _imSafeController.close();
    await _pauseController.close();
    await _resumeController.close();
  }
}
