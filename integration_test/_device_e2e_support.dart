// Shared host↔device coordination helpers for the C4 device-e2e proofs
// (#11 incoming-call pause/resume, #12 background-throttle survival).
//
// These integration tests run IN THE APP PROCESS on the emulator, but the
// stimulus (an emulator GSM call, a HOME keyevent) must be fired from the HOST
// via `adb` WHILE the test is observing. The coordination contract is a
// marker handshake over the HOST TEST STDOUT:
//
//   1. The on-device test logs a distinctive [emitMarker] line. Under
//      `flutter test integration_test/<file>` the marker reaches the HOST via
//      `debugPrint` → the runner's captured stdout log (NOT Android logcat —
//      `dart:developer log` does NOT route to logcat in this embedder mode;
//      verified). It is ALSO sent to `developer.log` as a secondary sink.
//   2. The host runner (see `tool/device_e2e/`) greps its captured stdout log
//      for that marker, fires the matching `adb` command, and the on-device
//      test — already polling REAL state in wall-clock time via [pollUntil] —
//      observes the effect and logs the next marker.
//
// The ASSERTIONS live here, on-device, against the REAL `SessionController` /
// `SessionEngine` state. The host only fires `adb` at the marker boundaries; it
// makes no assertion of its own (it just checks the test's own pass/fail exit).
// This keeps the proof honest: a host that fired the wrong command would leave
// the on-device `pollUntil` to time out and the test to FAIL red.
//
// NOTE the manual platform channels (`call_state`, `system_ui`, …) registered
// in `MainActivity.configureFlutterEngine` are only reachable AFTER the full
// app has launched — so #11 calls `app.main()` first (channels are
// process-global on the default binary messenger). Without it, an
// `invokeMethod` on a manual channel surfaces `MissingPluginException`.

import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/background_session_service_sim.dart';
import 'package:guardianangela/services/sim/contact_service_sim.dart';
import 'package:guardianangela/services/sim/location_service_sim.dart';
import 'package:guardianangela/services/sim/messaging_service_sim.dart';
import 'package:guardianangela/services/sim/notification_service_sim.dart';
import 'package:guardianangela/services/sim/phone_service_sim.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The logcat tag prefix every device-e2e marker shares, so the host runner can
/// grep for `GA-E2E` and the per-test marker name.
const String kE2eMarkerPrefix = 'GA-E2E';

/// Logs a host-observable coordination [marker].
///
/// The host runner greps its CAPTURED STDOUT LOG (the redirected output of
/// `flutter test`) for `$kE2eMarkerPrefix $marker` (e.g. `GA-E2E
/// READY-FOR-CALL`) and fires the matching `adb` command. An optional [detail]
/// is appended for human-readable host logs.
void emitMarker(String marker, [String? detail]) {
  final line = detail == null
      ? '$kE2eMarkerPrefix $marker'
      : '$kE2eMarkerPrefix $marker $detail';
  // `debugPrint` is the host-observable sink: under `flutter test` it routes to
  // the host test stdout (captured to the runner's log file). `developer.log`
  // is a secondary sink (does NOT reach logcat in this embedder — verified).
  developer.log(line, name: 'GaDeviceE2E');
  debugPrint(line);
}

/// Polls [predicate] every [interval] until it returns true or [timeout]
/// elapses, in REAL wall-clock time (NOT `fakeAsync` — this is a real device
/// with real telephony / lifecycle events arriving asynchronously).
///
/// Returns true if [predicate] became true within [timeout]. The caller asserts
/// on the result so a timeout surfaces as a red test (never a silent pass).
Future<bool> pollUntil(
  bool Function() predicate, {
  Duration timeout = const Duration(seconds: 40),
  Duration interval = const Duration(milliseconds: 200),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (predicate()) return true;
    await Future<void>.delayed(interval);
  }
  return predicate();
}

/// Blocks until `READ_PHONE_STATE` (`Permission.phone`) is granted, or
/// [timeout] elapses.
///
/// `flutter test`'s reinstall WIPES any pre-granted permission (verified), so
/// the grant must land AFTER install but BEFORE the native CallStateChannel
/// listener starts (inside `startSession`) — otherwise it emits
/// `permissionDenied` and never reports the incoming call. This gate makes the
/// race deterministic: the test emits `GA-E2E AWAITING-PHONE-GRANT` and polls
/// the permission; the host runner, on that marker, runs `pm grant` in a tight
/// loop. Returns the final grant state (the caller asserts it, so a missing
/// grant surfaces as a red test, never a silent skip).
Future<bool> waitForPhonePermission({
  Duration timeout = const Duration(seconds: 60),
}) async {
  emitMarker('AWAITING-PHONE-GRANT');
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if ((await Permission.phone.status).isGranted) return true;
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
  return (await Permission.phone.status).isGranted;
}

/// A single-step `holdButton` [SessionMode] used by the pause/resume and
/// background-survival proofs.
///
/// A `holdButton` step that is never held starts NO engine timer — the engine
/// waits for the first `holdStart()` and otherwise parks at step 0 forever
/// (spec 02:46; INT-002 finding). That makes it the safe minimal real chain for
/// these proofs: NO SMS / phone-call step can fire during the test, so the only
/// observable transitions are the ones the stimulus drives (pause→resume on a
/// call; survival across a background round-trip).
SessionMode holdOnlyMode() => SessionMode(
  id: 'e2e-hold-only',
  name: 'E2E Hold Only',
  iconName: 'directions_walk',
  chainSteps: [
    ChainStep(
      id: 'e2e-hold-0',
      type: ChainStepType.holdButton,
      order: 0,
      waitSeconds: 0,
      durationSeconds: 600,
      gracePeriodSeconds: 5,
      retryCount: 0,
      randomize: false,
      config: const HoldButtonConfig(),
    ),
  ],
);

/// Builds a [ProviderContainer] for a device-e2e session.
///
/// In-memory Drift DB (self-contained; no onboarding / encrypted on-disk store).
/// The service-override strategy is surgical: keep REAL exactly what the proof
/// exercises, and SIM out the rest.
///
///   * **`callStateServiceProvider` stays REAL** — the [RealCallStateService]
///     native telephony channel (`CallStateChannel.kt`) IS the #11 subject.
///   * The **engine / controller are always REAL** (never overridable) — the
///     pause/resume + background-clamp wiring under test.
///   * **`backgroundSessionServiceProvider` + `notificationServiceProvider` are
///     SIM** — the real `flutter_background_service` / `flutter_local_notifications`
///     plugins HANG / NPE on a headless `integration_test` embedder (no real
///     foreground-service binding, `setSmallIcon` null on the bare engine), and
///     they are orthogonal to the call-state and clamp wiring. Stubbing them is
///     the only way the real session can start at all here; they are covered by
///     their own host tests (FG-service start wiring) — NOT a vacuous stub of
///     the subject under test.
///   * **location / contacts / phone / messaging are SIM** — real
///     hardware/IO irrelevant to pause/clamp, and they would request further
///     runtime permissions / block on a headless device.
///
/// The caller MUST `dispose()` the returned container in `tearDown`.
ProviderContainer buildDeviceE2eContainer() => ProviderContainer(
  overrides: [
    databaseProvider.overrideWith((_) async => GuardianAngelaDatabase.memory()),
    // Headless-hostile infra — SIM (see doc above). NOT the subject under test.
    notificationServiceProvider.overrideWithValue(
      SimulationNotificationService(),
    ),
    backgroundSessionServiceProvider.overrideWithValue(
      SimulationBackgroundSessionService(),
    ),
    // Real hardware/IO orthogonal to pause/clamp — SIM.
    locationServiceProvider.overrideWithValue(SimulationLocationService()),
    contactServiceProvider.overrideWith(
      (_) async => SimulationContactService(),
    ),
    phoneServiceProvider.overrideWithValue(SimulationPhoneService()),
    messagingServiceProvider.overrideWithValue(SimulationMessagingService()),
    // callStateServiceProvider is intentionally NOT overridden — REAL native
    // telephony is the #11 subject.
  ],
);
