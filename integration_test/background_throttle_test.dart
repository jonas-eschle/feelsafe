// M5 C4 #12 — on-device proof: the background speed clamp (G-013) engages when
// the OS REALLY backgrounds the app, and a REAL session survives — and OBSERVES
// — a real background↔foreground round-trip (spec 01 §setBackgroundClamp;
// remediation #12 "🟡 sim-only clamp").
//
// EMPIRICALLY ESTABLISHED (M5 C4-fix, emulator-5554 / Pixel_9_Pro / API36, 3/3
// runs): a real OS `adb shell input keyevent KEYCODE_HOME` RELIABLY delivers
// `AppLifecycleState.paused` to the running integration_test engine, and a
// `monkey … LAUNCHER` foreground delivers `resumed`. So there is NO silent
// direct-drive fallback here: both proofs assert the REAL OS-delivered
// transition as a HARD requirement. If the OS path ever stops delivering, the
// test goes RED — it can never green on a host run or a no-stimulus run in a
// way that implies a device proof. (The pure-Dart clamp ARITHMETIC — 200×→60×,
// release→200×, the lifecycle→`setBackgroundClamp` wiring, and a real
// `flutter/lifecycle` platform message — is also covered host-side by
// test/domain/engine/background_clamp_test.dart +
// test/features/session/session_controller_clamp_test.dart; this file adds the
// genuine real-device value on top.)
//
// TWO complementary on-device proofs, each with its own host↔device handshake:
//
//   A) CLAMP ENGAGEMENT (simulation session — the only place the clamp has a
//      RUNTIME effect): a sim session runs at 200×; a REAL OS background event
//      MUST drive the controller's
//      `WidgetsBindingObserver.didChangeAppLifecycleState(paused)` →
//      `engine.setBackgroundClamp(true)` → `effectiveSpeedMultiplier` capped to
//      60. The `monkey … LAUNCHER` foreground MUST release it → back to 200.
//      Observed via the `@visibleForTesting engine` getter. HARD-asserted (no
//      fallback): the OS clamp not landing within the timeout fails the test.
//
//   B) REAL-SESSION SURVIVES + OBSERVES the round-trip: a REAL (non-sim) session
//      is backgrounded the same way. A test-local `WidgetsBindingObserver`
//      records the OS-delivered lifecycle states; the proof HARD-asserts the
//      real `paused → resumed` transition was actually observed AND that the
//      session stayed live + uncorrupted across it (engine not ended, no
//      escalation). Bare `isSessionActive` is NOT sufficient on its own — a
//      no-stimulus run never sees `paused→resumed` and fails.
//
// HONESTY (read carefully):
//   * The clamp is a documented NO-OP for real sessions at runtime (wall-clock
//     timers), so its *speed effect* is only observable in a sim — hence proof
//     A uses a sim. Proof B therefore asserts the lifecycle round-trip + session
//     survival, NOT a clamped real speed. This is the honest "sim-only clamp"
//     scope (remediation #12) made device-true: a real OS background engages the
//     clamp wiring on a real engine (A) and does not corrupt a real session (B).
//   * Proof B does NOT claim FG-service-driven OS-kill-resistance: this harness
//     SIMs the `flutter_background_service` plugin (it hangs on a headless
//     embedder — see _device_e2e_support.dart), so the process here is kept
//     alive by the test harness, not the FG service. The FG-service START wiring
//     is covered by its own HOST tests; proof B's on-device value is that the
//     real lifecycle round-trip does not END or corrupt the live session, and
//     that the OS transitions are genuinely delivered.
//
// HOST↔DEVICE COORDINATION (tool/device_e2e/run_background_throttle.sh): the
// test logs `GA-E2E A-READY` / `GA-E2E B-READY` and polls; the host fires HOME
// (`input keyevent KEYCODE_HOME`) on `*-READY`, then foregrounds the app with
// `monkey -p <pkg> -c android.intent.category.LAUNCHER 1` on `*-BACKGROUNDED`.
// Markers reach the host via `debugPrint` → the captured `flutter test` STDOUT
// log (NOT logcat — see _device_e2e_support.dart). All assertions are on-device
// against the real engine/controller.
//
// DEVICE-ONLY: tagged `device-e2e` (declared in dart_test.yaml) so the host
// `flutter test integration_test/ --exclude-tags device-e2e` CI job SKIPS it.
// The local runner invokes this file by explicit path (the tag does not gate an
// explicit-path invocation).
@Tags(['device-e2e'])
library;

import 'package:flutter/widgets.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardianangela/features/session/session_controller.dart';

import '_device_e2e_support.dart';

const double _fastSpeed = 200.0;
const double _clampCap = 60.0;

/// Records the real OS-delivered [AppLifecycleState] transitions so proof B can
/// HARD-assert that the OS actually backgrounded (`paused`) and re-foregrounded
/// (`resumed`) the app — not merely that the session is still alive.
class _LifecycleRecorder with WidgetsBindingObserver {
  final List<AppLifecycleState> states = <AppLifecycleState>[];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => states.add(state);

  bool get sawBackgrounded =>
      states.contains(AppLifecycleState.paused) ||
      states.contains(AppLifecycleState.hidden);

  /// True once a `resumed` arrives AFTER the first backgrounding state — a real
  /// round-trip, not just an initial `resumed` at launch.
  bool get sawRoundTrip {
    final firstBg = states.indexWhere(
      (s) => s == AppLifecycleState.paused || s == AppLifecycleState.hidden,
    );
    if (firstBg < 0) return false;
    return states.indexOf(AppLifecycleState.resumed, firstBg) >= 0;
  }
}

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

    // HARD requirement: the REAL OS lifecycle event must reach the observer and
    // engage the clamp. No direct-drive fallback — if this times out, the test
    // fails RED (it can never silently green as a device proof).
    final clamped = await pollUntil(
      () => engine.isBackgroundClamped,
      timeout: const Duration(seconds: 30),
    );
    emitMarker('A-BACKGROUNDED', 'osClamp=$clamped');
    expect(
      clamped,
      isTrue,
      reason:
          'a REAL OS HOME keyevent must drive didChangeAppLifecycleState(paused) '
          '→ setBackgroundClamp(true). If this times out the OS did not deliver '
          'the lifecycle transition to the integration_test engine — that is a '
          'real regression of the device proof, not a host-skippable case.',
    );
    expect(
      engine.effectiveSpeedMultiplier,
      _clampCap,
      reason: 'a backgrounded sim must cap effective speed at 60×',
    );

    // Foreground (host fires `monkey … LAUNCHER`) → clamp releases.
    final released = await pollUntil(
      () => !engine.isBackgroundClamped,
      timeout: const Duration(seconds: 30),
    );
    expect(released, isTrue, reason: 'foreground must release the clamp');
    expect(engine.effectiveSpeedMultiplier, _fastSpeed);
    emitMarker('A-FOREGROUNDED', 'viaRealOs=true');
    emitMarker('A-DONE');
  });

  testWidgets('#12-B real session observes + survives a background round-trip', (
    WidgetTester tester,
  ) async {
    final notifier = container.read(sessionControllerProvider.notifier);
    await container.read(sessionControllerProvider.future);

    // Record the OS-delivered lifecycle transitions so the proof can HARD-assert
    // a real background→foreground round-trip actually occurred (not just bare
    // liveness, which a no-stimulus run would also satisfy).
    final recorder = _LifecycleRecorder();
    WidgetsBinding.instance.addObserver(recorder);
    addTearDown(() => WidgetsBinding.instance.removeObserver(recorder));

    // A REAL session (FG service SIM'd, see header) on the hold-only chain.
    await notifier.startSession(mode: holdOnlyMode(), simulate: false);
    expect(notifier.isSessionActive, isTrue);

    emitMarker('B-READY');
    // Host backgrounds via HOME → wait for the OS-delivered `paused`.
    final backgrounded = await pollUntil(
      () => recorder.sawBackgrounded,
      timeout: const Duration(seconds: 30),
    );
    emitMarker('B-BACKGROUNDED', 'osPaused=$backgrounded');
    expect(
      backgrounded,
      isTrue,
      reason:
          'the real OS HOME keyevent must deliver paused/hidden to the lifecycle '
          'observer — a no-stimulus or host run never sees it and fails here',
    );

    // Host foregrounds via `monkey … LAUNCHER` → wait for the OS-delivered
    // `resumed` AFTER the backgrounding (a genuine round-trip).
    final roundTripped = await pollUntil(
      () => recorder.sawRoundTrip,
      timeout: const Duration(seconds: 30),
    );
    expect(
      roundTripped,
      isTrue,
      reason:
          'a real paused→resumed round-trip must be observed (foreground after '
          'background), not just an initial resumed at launch',
    );

    // The lifecycle round-trip must NOT end or corrupt the session: still the
    // live session, engine not ended, parked on the hold step (no escalation).
    // (This proves the observer does not tear the session down on background; it
    // does NOT claim FG-service OS-kill-resistance — see the file header.)
    expect(
      notifier.isSessionActive,
      isTrue,
      reason:
          'a real session must stay live across a real background→foreground '
          'round-trip (the lifecycle observer must not end it)',
    );
    expect(notifier.engine!.isEnded, isFalse);
    emitMarker('B-SURVIVED', 'roundTrip=$roundTripped');
    emitMarker('B-DONE');
  });
}
