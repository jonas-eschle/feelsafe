// Phase 9 — device smoke test.
//
// Boots the real app (`main()` → full bootstrap pipeline: encrypted Drift
// open, settings load, notification channels) on a device/emulator and
// asserts the root `MaterialApp.router` shell renders without throwing.
// This is the minimal proof that the Android build runs on the emulator
// and that `flutter test integration_test --coverage` collects line
// coverage from on-device execution.

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:guardianangela/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots to a MaterialApp shell', (WidgetTester tester) async {
    await app.main();

    // The app shell may run continuous animations (e.g. the logo), so a
    // bounded pump loop is used instead of pumpAndSettle to avoid hangs.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
