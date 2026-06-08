// M3 #15 C4 — on-device proof for the per-preset fakeIcon launcher disguise.
//
// Drives the REAL `RealSystemUiService.setStealthIcon(preset)` from INSIDE the
// app process (the correct UID — `PackageManager.setComponentEnabledSetting`
// for an app's own components is only permitted from that app, not from the adb
// shell, which is why this must run as an integration test, not via `pm`).
//
// Asserts the native `StealthIconChannel.kt` alias swap completes without
// throwing for every preset. Component-enabled state is persistent in
// PackageManager (it outlives the app process), so the harness wrapper queries
// `cmd package resolve-activity` from the shell AFTER this run to confirm the
// disguise alias (left as `music` at the end) became the LAUNCHER resolver and
// the app is still launchable (relaunch-after-switch proof).
//
// Failure mode guarded: a malformed alias / dangling icon would crash the
// channel here; a switch that left zero enabled launcher aliases would make the
// app unlaunchable (resolve-activity would return nothing).

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

  testWidgets('setStealthIcon drives the native alias swap for every preset', (
    WidgetTester tester,
  ) async {
    await app.main();
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.byType(MaterialApp), findsOneWidget);

    // Every preset must apply without the channel throwing (proves each alias
    // exists and its icon resolves). The MethodChannel completes a Future; a
    // missing alias / bad icon would surface as a PlatformException and fail
    // the test. `none` restores the real Guardian Angela launcher.
    for (final preset in StealthIconPreset.values) {
      await service.setStealthIcon(preset);
      await tester.pump(const Duration(milliseconds: 150));
    }

    // Leave the launcher on a concrete disguise (music) so the shell-side
    // launcher-resolution check after this run observes the disguise alias as
    // the sole LAUNCHER resolver — the relaunch-after-switch proof.
    await service.setStealthIcon(StealthIconPreset.music);
    await tester.pump(const Duration(milliseconds: 400));
  });
}
