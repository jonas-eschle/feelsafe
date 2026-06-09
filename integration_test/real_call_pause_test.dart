// M5 C4 #11 — on-device proof: a REAL incoming call pauses the session, and
// the call ending resumes it (spec 01 §Real Phone Call Detection, A2;
// spec 05/10 §Real Incoming Call Detection).
//
// This drives the ENTIRE real Android telephony path end-to-end:
//
//   adb emu gsm call <n>  →  TelephonyManager CALL_STATE_RINGING
//     →  CallStateChannel.kt emits "ringing" on the EventChannel
//     →  RealCallStateService parses → CallState.ringing
//     →  SessionController._onCallStateChanged → engine.pause(incomingCall)
//     →  SessionState.isPaused == true, pauseReason == incomingCall   (ASSERTED)
//   adb emu gsm cancel <n> →  CALL_STATE_IDLE
//     →  "idle" → CallState.idle → _onRealCallEnded → engine.resume()
//     →  SessionState.isPaused == false                                (ASSERTED)
//
// HOST↔DEVICE COORDINATION (see _device_e2e_support.dart + tool/device_e2e/):
// the test logs `GA-E2E READY-FOR-CALL`, then polls the REAL SessionState for
// the pause; the host runner — grepping the captured `flutter test` STDOUT log
// (markers reach it via `debugPrint`; `dart:developer log` does NOT route to
// logcat in this embedder, see _device_e2e_support.dart) — fires `adb emu gsm
// call` on that marker. The test then logs `GA-E2E PAUSE-OBSERVED`; the host
// fires `adb emu gsm cancel`, and the test polls for the resume. All assertions
// are on-device against the real controller — a host that fired the wrong
// command would simply let `pollUntil` time out and the test fail RED (no
// vacuous pass).
//
// DEVICE-ONLY: tagged `device-e2e` (declared in dart_test.yaml) so the host
// `flutter test integration_test/ --exclude-tags device-e2e` CI job SKIPS it —
// the real-OS telephony stimulus is only drivable on the emulator via the local
// tool/device_e2e/run_real_call_pause.sh runner (which invokes this file by
// explicit path, so the tag does not gate it there).
//
// REQUIRES `READ_PHONE_STATE` granted before the run (the host runner grants
// it). Without it CallStateChannel emits a `permissionDenied` error instead of
// "ringing" and the pause never happens → the test fails red (honest).
//
// iOS: the equivalent path is CXCallObserver (CallStatePlugin.swift), reliable
// only while audio is active; NOT drivable on this Linux box — CI build-ios
// only.
@Tags(['device-e2e'])
library;

import 'package:flutter/widgets.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardianangela/domain/enums/pause_reason.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/main.dart' as app;

import '_device_e2e_support.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = buildDeviceE2eContainer();
  });

  tearDown(() async {
    // Stop any live session (cancels the call-state subscription + the native
    // listener) and dispose the container so the next run starts clean.
    final notifier = container.read(sessionControllerProvider.notifier);
    if (notifier.isSessionActive) {
      await notifier.endSession();
    }
    container.dispose();
  });

  testWidgets('#11 real incoming call pauses then resumes the live session', (
    WidgetTester tester,
  ) async {
    // Launch the full app FIRST so MainActivity.configureFlutterEngine
    // registers the call_state platform channels for this isolate. Platform
    // channels are process-global (default binary messenger), so the
    // RealCallStateService in our own container below reaches the same native
    // handler. Under `flutter test integration_test` WITHOUT this, the manual
    // channels surface MissingPluginException and no telephony event arrives.
    await app.main();
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    final notifier = container.read(sessionControllerProvider.notifier);

    // Resolve the AsyncNotifier's initial build (orphan-marker detection) so
    // startSession runs against a settled controller.
    await container.read(sessionControllerProvider.future);

    // `flutter test`'s reinstall wipes any pre-granted permission, so gate the
    // session start on READ_PHONE_STATE landing (the host grants on the
    // AWAITING-PHONE-GRANT marker). Without it the native telephony channel
    // would emit permissionDenied and never report the call.
    final phoneGranted = await waitForPhonePermission();
    expect(
      phoneGranted,
      isTrue,
      reason:
          'READ_PHONE_STATE must be granted before the call-state listener '
          'starts (host runner grants on the AWAITING-PHONE-GRANT marker)',
    );

    // Start a REAL (non-simulation) session on a single hold-only chain. It
    // subscribes the real RealCallStateService native telephony channel and
    // parks at step 0 (never held → no escalation), so the only transitions
    // observable are the pause/resume the real call drives.
    await notifier.startSession(mode: holdOnlyMode(), simulate: false);
    expect(notifier.isSessionActive, isTrue);

    SessionState read() =>
        container.read(sessionControllerProvider).requireValue;
    expect(read().isPaused, isFalse, reason: 'session starts unpaused');

    // Signal the host to fire `adb emu gsm call`. The host tails logcat for
    // this exact marker.
    emitMarker('READY-FOR-CALL');

    // Observe the REAL pause driven by the native telephony → controller path.
    final paused = await pollUntil(
      () => read().isPaused,
      timeout: const Duration(seconds: 45),
    );
    expect(
      paused,
      isTrue,
      reason:
          'a real incoming call must pause the engine within 45s — if this '
          'times out, the native CallState channel did not deliver "ringing" '
          '(check READ_PHONE_STATE was granted and the host fired the call)',
    );
    // The pause must be attributed to the incoming call, not a user pause.
    expect(read().pauseReason, PauseReason.incomingCall);
    emitMarker('PAUSE-OBSERVED', 'reason=${read().pauseReason}');

    // Tell the host to cancel the call, then observe the REAL resume.
    final resumed = await pollUntil(
      () => !read().isPaused,
      timeout: const Duration(seconds: 45),
    );
    expect(
      resumed,
      isTrue,
      reason: 'the call ending must resume the engine within 45s',
    );
    expect(
      read().pauseReason,
      isNull,
      reason: 'resume clears the pause reason',
    );
    // The session is still alive after the call round-trip (the hold step never
    // escalated): pause/resume did not end or corrupt the session.
    expect(notifier.isSessionActive, isTrue);
    emitMarker('RESUME-OBSERVED');
    emitMarker('DONE');
  });
}
