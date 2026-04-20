/// Session-feature controller stub.
///
/// Drives the active safety session — wraps `SessionEngine` and
/// translates engine events into the `WalkSession` view-model.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardianangela/domain/models/models.dart';

/// Stub AsyncNotifier for the active safety session.
///
/// State is nullable: `null` = no active session, non-null =
/// session in progress or recently-ended.
class SessionController extends AsyncNotifier<WalkSession?> {
  /// Callback fired when the engine wants to confirm a distress
  /// trigger (e.g. hardware panic button). Returning `true` lets
  /// the distress chain run; `false` cancels.
  Future<bool> Function()? onDistressConfirmation;

  /// Callback fired when a disarm trigger (GPS arrival, timer)
  /// fires and asks the UI to request PIN entry.
  void Function()? onDisarmRequested;

  @override
  Future<WalkSession?> build() async => null;

  /// Starts a new session for `modeId`. `isSimulation` routes
  /// strategies through the simulation services.
  Future<void> startSession({
    required String modeId,
    bool isSimulation = false,
  }) async {
    throw UnimplementedError();
  }

  /// Starts a one-shot battery-alert session driven by `config`.
  Future<void> startBatteryAlertSession(BatteryAlertConfig config) async {
    throw UnimplementedError();
  }

  /// Disarms the active session. Requires a valid session-end PIN
  /// if one is configured.
  Future<void> disarm() async {
    throw UnimplementedError();
  }

  /// Pauses the active session (stops timers without ending it).
  Future<void> pause() async {
    throw UnimplementedError();
  }

  /// Resumes a paused session.
  Future<void> resume() async {
    throw UnimplementedError();
  }

  /// Accepts a simulated fake-call pretext.
  Future<void> answerFakeCall() async {
    throw UnimplementedError();
  }

  /// Ends a simulated fake call that is currently "in progress".
  Future<void> hangUp() async {
    throw UnimplementedError();
  }

  /// Declines a simulated fake-call pretext.
  Future<void> declineFakeCall() async {
    throw UnimplementedError();
  }

  /// Force-fires the distress chain (e.g. hardware panic).
  Future<void> triggerDistressChain() async {
    throw UnimplementedError();
  }

  /// Handles the outcome of a PIN prompt. `result` is a discriminated
  /// outcome object from the PIN subsystem (Phase 8+).
  bool handlePinResult(Object result) {
    throw UnimplementedError();
  }
}

/// Provider for `SessionController`.
final AsyncNotifierProvider<SessionController, WalkSession?>
    sessionControllerProvider =
    AsyncNotifierProvider<SessionController, WalkSession?>(
  SessionController.new,
);
