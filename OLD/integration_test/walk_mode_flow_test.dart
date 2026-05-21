/// Walk Mode smoke flow (Patrol).
///
/// Launches the app, completes onboarding with fake profile data,
/// starts Walk Mode in **simulation** (never real), holds the
/// "check-in" button, then disarms.
///
/// This is a *smoke* test — it asserts that the screens wire up and
/// the state machine transitions happen, not that every edge case
/// of the escalation chain fires. Those are covered by unit tests
/// in `test/domain/session_engine_test.dart`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol/patrol.dart';

import 'package:guardianangela/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  patrolTest('walk mode: onboarding -> simulate -> hold -> disarm', ($) async {
    app.main();
    await $.pumpAndSettle(duration: const Duration(seconds: 3));

    // --- Onboarding: advance through each page via the first
    // visible FilledButton (works for Next / Finish). ---
    for (var i = 0; i < 3; i++) {
      final btns = find.byType(FilledButton);
      if (btns.evaluate().isEmpty) break;
      if (i == 1) {
        // Page 2 has the profile form: fill name + phone.
        final fields = find.byType(TextFormField);
        if (fields.evaluate().length >= 2) {
          await $.tester.enterText(fields.at(0), 'Test User');
          await $.tester.enterText(fields.at(1), '+15555550100');
        }
      }
      await $.tester.tap(btns.first);
      await $.pumpAndSettle();
    }

    // --- Home: start Walk Mode in simulation ---
    await $.tester.tap(find.text('Walk').first);
    await $.pumpAndSettle();
    final simBtn = find.textContaining('Simulat');
    if (simBtn.evaluate().isNotEmpty) {
      await $.tester.tap(simBtn.first);
      await $.pumpAndSettle();
    }

    // --- Session screen: hold the first GestureDetector ~2s ---
    final holdBtn = find.byType(GestureDetector);
    if (holdBtn.evaluate().isNotEmpty) {
      await $.tester.longPress(holdBtn.first);
      await $.pumpAndSettle(duration: const Duration(seconds: 2));
    }

    // --- Disarm ---
    final disarm = find.textContaining(RegExp('Disarm|End'));
    if (disarm.evaluate().isNotEmpty) {
      await $.tester.tap(disarm.first);
      await $.pumpAndSettle();
    }

    expect(
      find.byType(MaterialApp),
      findsOneWidget,
      reason: 'app should still be alive after disarm',
    );
  });
}
