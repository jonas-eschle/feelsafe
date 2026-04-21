/// Goldens for the distress-confirmation overlay (normal + stealth).
///
/// Exercises the real [DistressConfirmation] widget — it has no
/// provider dependencies and reads only [AppLocalizations]. A fresh
/// pump leaves the countdown at its initial value so the golden is
/// deterministic.
library;

import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:guardianangela/core/widgets/distress_confirmation.dart';

import 'goldens_setup.dart';

void main() {
  for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
    final themeName = themeMode == ThemeMode.light ? 'light' : 'dark';

    testGoldens('distress_confirmation_normal_$themeName', (tester) async {
      final builder = buildDevices(
        child: Scaffold(
          body: DistressConfirmation(onConfirmed: () {}, onCancelled: () {}),
        ),
        themeMode: themeMode,
        scenarioName: 'normal',
      );
      await tester.pumpDeviceBuilder(
        builder,
        wrapper: (child) => goldenWrapper(child: child, themeMode: themeMode),
      );
      await screenMatchesGolden(
        tester,
        'distress_confirmation_normal_$themeName',
      );
    });

    testGoldens('distress_confirmation_stealth_$themeName', (tester) async {
      final builder = buildDevices(
        child: Scaffold(
          body: DistressConfirmation(
            onConfirmed: () {},
            onCancelled: () {},
            stealth: true,
          ),
        ),
        themeMode: themeMode,
        scenarioName: 'stealth',
      );
      await tester.pumpDeviceBuilder(
        builder,
        wrapper: (child) => goldenWrapper(child: child, themeMode: themeMode),
      );
      await screenMatchesGolden(
        tester,
        'distress_confirmation_stealth_$themeName',
      );
    });
  }
}
