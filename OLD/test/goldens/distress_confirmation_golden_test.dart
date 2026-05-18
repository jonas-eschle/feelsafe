/// Goldens for the distress-confirmation overlay (normal + stealth).
///
/// Exercises the real [DistressConfirmation] widget — it has no
/// provider dependencies and reads only [AppLocalizations]. A fresh
/// pump leaves the countdown at its initial value so the golden is
/// deterministic.
library;

import 'package:flutter/material.dart';
import 'package:alchemist/alchemist.dart';

import 'package:guardianangela/core/widgets/distress_confirmation.dart';

import 'goldens_setup.dart';

void main() {
  for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
    final themeName = themeMode == ThemeMode.light ? 'light' : 'dark';

    goldenTest(
      'distress_confirmation_normal_$themeName',
      fileName: 'distress_confirmation_normal_$themeName',
      builder: () => goldenWrapper(
        child: Scaffold(
          body: DistressConfirmation(onConfirmed: () {}, onCancelled: () {}),
        ),
        themeMode: themeMode,
      ),
    );

    goldenTest(
      'distress_confirmation_stealth_$themeName',
      fileName: 'distress_confirmation_stealth_$themeName',
      builder: () => goldenWrapper(
        child: Scaffold(
          body: DistressConfirmation(
            onConfirmed: () {},
            onCancelled: () {},
            stealth: true,
          ),
        ),
        themeMode: themeMode,
      ),
    );
  }
}
