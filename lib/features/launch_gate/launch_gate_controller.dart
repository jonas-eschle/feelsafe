import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the App-lock launch gate is currently covering the app.
///
/// `true` = locked (the launch PIN screen is shown over everything). Seeded
/// once at bootstrap from `AppSettings.appPinHash != null` ([lockForLaunch])
/// and cleared on a correct PIN / biometric / Duress unlock ([unlock]).
///
/// **In-memory only, cold-start scoped** (spec 06 §App PIN — the gate appears
/// only on a fresh launch when an App PIN is set). The state is never
/// persisted and nothing re-locks it on resume, matching the cold-start-only
/// decision: a running app, once unlocked, stays unlocked until the process
/// dies. A plain [Notifier] with no `ref.watch` dependencies never rebuilds,
/// so the unlocked state cannot be silently reset mid-session.
class LaunchGateController extends Notifier<bool> {
  @override
  bool build() => false;

  /// Seeds the gate at app start. [appPinSet] is `appPinHash != null`; when
  /// false the gate stays open (no App PIN configured → no lock).
  void lockForLaunch({required bool appPinSet}) {
    state = appPinSet;
  }

  /// Clears the gate after a successful unlock (correct App PIN, biometric, or
  /// a Duress PIN's fake-normal unlock).
  void unlock() {
    state = false;
  }
}

/// Exposes whether the launch gate is currently locked. Watched by the router
/// redirect (to gate every route) and its refresh listenable (so [unlock]
/// re-routes away from the launch screen).
final launchGateProvider = NotifierProvider<LaunchGateController, bool>(
  LaunchGateController.new,
);
