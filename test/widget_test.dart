// Smoke test for the Phase 6 app shell.
//
// Phase 6 replaces the Phase 5 placeholder with a GoRouter-driven
// `MaterialApp.router`. Rendering the full shell requires a Drift
// database; this smoke test only checks that the JSON recovery widget
// still renders without errors. Full router smoke tests live in
// `test/router/app_router_test.dart`.

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/main.dart';

void main() {
  testWidgets('JsonRecoveryApp renders with reason text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const JsonRecoveryApp(reason: 'FormatException: test'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Data Recovery'), findsWidgets);
    expect(find.text('Start fresh'), findsOneWidget);
    expect(find.text('Restore from backup'), findsOneWidget);
  });

  testWidgets('GuardianAngelaApp is constructable', (
    WidgetTester tester,
  ) async {
    // Just verify the symbol exists and is const-constructable.
    // Rendering requires a Drift database; the widget test cohort
    // covers the full router shell.
    const widget = GuardianAngelaApp();
    expect(widget, isA<Widget>());
  });
}
