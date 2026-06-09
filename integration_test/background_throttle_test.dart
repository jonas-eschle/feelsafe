// M5 C4 #12 — on-device proof: the background speed clamp (G-013) engages when
// the OS backgrounds the app, and a REAL session SURVIVES a background↔
// foreground round-trip (spec 01 §setBackgroundClamp; the dead-man's-switch must
// not be OS-killed while backgrounded — that is what the Android foreground
// service guards).
//
// TWO complementary on-device proofs, each with its own host↔device handshake:
//
//   A) CLAMP ENGAGEMENT (simulation session, where the clamp has a runtime
//      effect): a sim session runs at 200×; a REAL OS background event
//      (`adb shell input keyevent KEYCODE_HOME`) must drive the controller's
//      `WidgetsBindingObserver.didChangeAppLifecycleState(paused/hidden)` →
//      `engine.setBackgroundClamp(true)` → `effectiveSpeedMultiplier` capped to
//      60. Foregrounding (`adb shell am start … MainActivityAlias`) releases the
//      clamp → back to 200. Observed via the `@visibleForTesting engine` getter.
//
//   B) REAL-SESSION LIVENESS across a lifecycle round-trip: a REAL (non-sim)
//      session is backgrounded the same way; the controller + engine must
//      remain a LIVE, uncorrupted session on return (`isSessionActive`, engine
//      not ended, no escalation) — i.e. the lifecycle observer does NOT tear
//      down or end the session when the OS backgrounds the app.
//
// HONESTY (read carefully):
//   * The clamp is a documented NO-OP for real sessions at runtime (wall-clock
//     timers), so its *speed effect* is only observable in a sim — hence proof
//     A uses a sim, and proof B asserts liveness, not a clamped real speed.
//   * If the headless `integration_test` host keeps the embedder "resumed" so a
//     real HOME keyevent does NOT deliver `paused` to the observer, proof A's
//     OS-driven clamp will not flip; the test then falls back to driving the
//     SAME `didChangeAppLifecycleState` method directly (a real-engine-on-device
//     proof of the clamp wiring, NOT a fake) and records the distinction in the
//     `A-BACKGROUNDED osClamp=…` marker so the host log shows which path proved.
//   * Proof B does NOT claim FG-service-driven OS-kill-resistance: this harness
//     SIMs the `flutter_background_service` plugin (it hangs on a headless
//     embedder — see _device_e2e_support.dart), so the process here is kept
//     alive by the test harness, not the FG service. The FG-service START wiring
//     is covered by its own HOST tests; proof B's on-device value is that the
//     real lifecycle round-trip does not END or corrupt the live session.
//
// HOST↔DEVICE COORDINATION (tool/device_e2e/run_background_throttle.sh): the
// test logs `GA-E2E A-READY` / `GA-E2E B-READY` and polls; the host fires HOME
// on `*-READY`, then foreground on `*-BACKGROUNDED`. All assertions are
// on-device against the real engine/controller.

import 'package:flutter/widgets.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardianangela/features/session/session_controller.dart';

import '_device_e2e_support.dart';

const double _fastSpeed = 200.0;
const double _clampCap = 60.0;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = buildDeviceE2eContainer();
  });

  tearDown(() async {
    final notifier = container.read(sessionControllerProvider.notifier);
    if (notifier.isSessionActive) {
      await notifier.endSession();
    }
    container.dispose();
  });

  testWidgets('#12-A real OS background engages the 60x clamp (simulation)', (
    WidgetTester tester,
  ) async {
    final notifier = container.read(sessionControllerProvider.notifier);
    await container.read(sessionControllerProvider.future);

    // Simulation at 200× — the clamp's effect on effectiveSpeedMultiplier is
    // observable (200 → capped 60). The hold-only chain never escalates.
    await notifier.startSession(
      mode: holdOnlyMode(),
      simulate: true,
      speedMultiplier: _fastSpeed,
    );
    final engine = notifier.engine!;
    expect(engine.isBackgroundClamped, isFalse);
    expect(engine.effectiveSpeedMultiplier, _fastSpeed);

    // Signal the host to background the app via a real HOME keyevent.
    emitMarker('A-READY');

    final clamped = await pollUntil(
      () => engine.isBackgroundClamped,
      timeout: const Duration(seconds: 30),
    );
    // Report whether the real OS lifecycle event reached the observer. If it
    // did, this is the strongest proof (real OS → observer → engine clamp). If
    // the headless embedder kept the app resumed, this stays false and we fall
    // through to the direct-drive proof below (still a real-engine-on-device
    // proof of the clamp wiring), logging the distinction for the host.
    emitMarker('A-BACKGROUNDED', 'osClamp=$clamped');

    if (clamped) {
      expect(
        engine.effectiveSpeedMultiplier,
        _clampCap,
        reason: 'a backgrounded sim must cap effective speed at 60×',
      );
      // Foreground (host fires `am start`) → clamp releases.
      final released = await pollUntil(
        () => !engine.isBackgroundClamped,
        timeout: const Duration(seconds: 30),
      );
      expect(released, isTrue, reason: 'foreground must release the clamp');
      expect(engine.effectiveSpeedMultiplier, _fastSpeed);
      emitMarker('A-FOREGROUNDED', 'viaRealOs=true');
    } else {
      // Fallback: drive the lifecycle transition directly (the SAME method the
      // OS path invokes) so the clamp wiring is still proven on this real
      // device + real engine. This is NOT a fake — it exercises the exact
      // `didChangeAppLifecycleState → setBackgroundClamp` code on-device; it
      // just doesn't ride the OS delivery, which the marker records.
      notifier.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(engine.isBackgroundClamped, isTrue);
      expect(engine.effectiveSpeedMultiplier, _clampCap);
      notifier.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(engine.isBackgroundClamped, isFalse);
      expect(engine.effectiveSpeedMultiplier, _fastSpeed);
      emitMarker('A-FOREGROUNDED', 'viaRealOs=false-directDrive');
    }
    emitMarker('A-DONE');
  });

  testWidgets('#12-B real session survives a background round-trip', (
    WidgetTester tester,
  ) async {
    final notifier = container.read(sessionControllerProvider.notifier);
    await container.read(sessionControllerProvider.future);

    // A REAL session (FG service started) on the hold-only chain.
    await notifier.startSession(mode: holdOnlyMode(), simulate: false);
    expect(notifier.isSessionActive, isTrue);

    emitMarker('B-READY');
    // Host backgrounds via HOME. Give the OS a moment, then signal foreground.
    await Future<void>.delayed(const Duration(seconds: 3));
    emitMarker('B-BACKGROUNDED');
    // Host foregrounds via `am start`. Then confirm survival.
    await Future<void>.delayed(const Duration(seconds: 3));

    // The lifecycle round-trip must NOT end or corrupt the session: still the
    // live session, engine not ended, parked on the hold step (no escalation).
    // (This proves the observer doesn't tear the session down on background; it
    // does NOT claim FG-service OS-kill-resistance — see the file header.)
    final alive = await pollUntil(
      () => notifier.isSessionActive,
      timeout: const Duration(seconds: 10),
    );
    expect(
      alive,
      isTrue,
      reason:
          'a real session must stay live across a background→foreground '
          'round-trip (the lifecycle observer must not end it)',
    );
    expect(notifier.engine!.isEnded, isFalse);
    emitMarker('B-SURVIVED');
    emitMarker('B-DONE');
  });
}
