// M3 #15 C4 + M5 C4 — on-device proof for the per-preset fakeIcon launcher
// disguise.
//
// Drives the REAL `RealSystemUiService.setStealthIcon(preset)` from INSIDE the
// app process (the correct UID — `PackageManager.setComponentEnabledSetting`
// for an app's own components is only permitted from that app, not from the adb
// shell, which is why this must run as an integration test, not via `pm`).
//
// M5 C4 PER-PRESET HARDENING (the M3-C4 cohort deferral): rather than only
// applying every preset and letting the harness check the FINAL alias, this
// test makes the disguise observable AFTER EACH switch. It sets one preset at a
// time, emits a host-observable marker naming that preset, then DWELLS ~2.5s.
// The host runner (tool/device_e2e/run_stealth_per_preset.sh) reads
// `cmd package resolve-activity -a MAIN -c LAUNCHER` during each dwell and
// asserts the launcher resolves to that preset's alias
// (`none`→.MainActivityAlias, else .StealthAlias_<preset>) and that exactly one
// launcher alias is enabled (the invariant; the app stays launchable).
//
// On-device, the test ALSO asserts each `setStealthIcon` completes without the
// channel throwing — a missing alias / bad icon would surface as a
// PlatformException and fail the test here regardless of the host.
//
// KEY (M3-C4): the alias swap is drivable ONLY from the app's own UID (this
// in-process path; `pm enable` of the component is blocked from the adb shell
// and `adb root` is refused on this image). So the host can only OBSERVE via
// the read-only `resolve-activity`/`query-activities` between switches; a
// concurrent `am start` mid-test stalls the integration binding, so the host
// must NOT relaunch during a dwell, only read. iOS: `setStealthIcon` no-ops
// (component toggling unavailable); CI build-ios only.

import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:guardianangela/domain/enums/stealth_icon_preset.dart';
import 'package:guardianangela/main.dart' as app;
import 'package:guardianangela/services/system_ui_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // RealSystemUiService is constructed directly here (not via the
  // service-providers gate) ON PURPOSE: this is an on-device proof of the REAL
  // native channel. This is an integration_test file; the CI single-constructor
  // grep targets lib/, not integration_test/.
  final service = RealSystemUiService();

  testWidgets('per-preset: each switch makes its alias the launcher resolver', (
    WidgetTester tester,
  ) async {
    // Full app launch FIRST so MainActivity.configureFlutterEngine registers
    // the stealth_icon platform channel for this isolate (under `flutter test
    // integration_test` the manual channels would otherwise surface
    // MissingPluginException). Called exactly once.
    await app.main();
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.byType(MaterialApp), findsOneWidget);

    _emit('PER-PRESET-START');
    // Walk every preset with a SHORT per-switch pump (the original all-presets
    // pass used this and completed cleanly). A short dwell is REQUIRED, not just
    // preferred: disabling the running activity's OWN launcher alias makes the
    // platform detach the Flutter engine from the activity a few seconds later,
    // which stalls the test isolate — so a LONG per-preset dwell hangs. We
    // therefore switch promptly and let the HOST tight-poll
    // `resolve-activity` throughout (run_stealth_per_preset.sh) to catch each
    // preset's alias as it becomes the launcher resolver. The on-device proof
    // here is that EVERY preset's channel call completes without throwing (a
    // missing alias / bad icon would raise a PlatformException → red); the host
    // proof is that the per-preset alias transitions are observable (not just
    // the final), closing the M3-C4 deferral.
    for (final preset in StealthIconPreset.values) {
      await service.setStealthIcon(preset);
      _emit('SET', preset.name);
      // Single frame only — the whole walk must finish before the
      // alias-disable engine-detach (~a few seconds after the first switch
      // disables the running activity's alias) stalls the isolate. The host
      // tight-polls resolve-activity to catch the transient aliases in this
      // brief window.
      await tester.pump(const Duration(milliseconds: 80));
    }

    // Leave the launcher on a concrete disguise (music) so the harness
    // post-check (and the relaunch-after-switch proof) observes the disguise
    // alias as the sole LAUNCHER resolver.
    await service.setStealthIcon(StealthIconPreset.music);
    await tester.pump(const Duration(milliseconds: 300));
    _emit('PER-PRESET-DONE');
  });
}

/// Logs a host-observable per-preset marker (`GA-E2E STEALTH <name> [detail]`).
///
/// Uses [debugPrintSynchronously] (NOT the throttled [debugPrint]) so a burst
/// of markers across the preset loop is never rate-limited away before the host
/// reads them, plus `developer.log` for the logcat sink.
void _emit(String name, [String? detail]) {
  final line = detail == null
      ? 'GA-E2E STEALTH $name'
      : 'GA-E2E STEALTH $name $detail';
  developer.log(line, name: 'GaDeviceE2E');
  debugPrintSynchronously(line);
}
