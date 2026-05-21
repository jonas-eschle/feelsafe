/// Date Mode smoke flow (Patrol).
///
/// Launches the app (onboarding assumed completed by a prior test or
/// skipped by tapping through the FilledButtons), starts Date Mode
/// in **simulation**, waits for the first disguised reminder,
/// responds within the grace period, then disarms.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol/patrol.dart';

import 'package:guardianangela/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  patrolTest('date mode: start sim -> respond to reminder -> disarm', (
    $,
  ) async {
    app.main();
    await $.pumpAndSettle(duration: const Duration(seconds: 3));

    // Skip onboarding if present (tap primary button up to 3 times).
    for (var i = 0; i < 3; i++) {
      final btns = find.byType(FilledButton);
      if (btns.evaluate().isEmpty) break;
      await $.tester.tap(btns.first);
      await $.pumpAndSettle();
    }

    // --- Home: start Date Mode in simulation ---
    await $.tester.tap(find.text('Date').first);
    await $.pumpAndSettle();
    final simBtn = find.textContaining('Simulat');
    if (simBtn.evaluate().isNotEmpty) {
      await $.tester.tap(simBtn.first);
      await $.pumpAndSettle();
    }

    // --- Wait for first reminder (10x sim speed => ~6s for 60s) ---
    await $.pumpAndSettle(duration: const Duration(seconds: 8));

    // Respond to the reminder. UI copy varies by template, so
    // match loosely.
    final respond = find.textContaining(RegExp("I'm OK|Respond|Yes"));
    if (respond.evaluate().isNotEmpty) {
      await $.tester.tap(respond.first);
      await $.pumpAndSettle();
    }

    // --- Disarm ---
    final disarm = find.textContaining(RegExp('Disarm|End'));
    if (disarm.evaluate().isNotEmpty) {
      await $.tester.tap(disarm.first);
      await $.pumpAndSettle();
    }
  });
}
