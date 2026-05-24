// Smoke test for the placeholder app shell. Phase 6 replaces
// this when the real routing + screens land.

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/main.dart';

void main() {
  testWidgets('App shell renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const GuardianAngelaApp());
    await tester.pumpAndSettle();

    expect(find.text('Guardian Angela'), findsOneWidget);
    expect(find.text("Your angel's got your back."), findsOneWidget);
    expect(find.text('Pre-alpha v3 — Phase 5 bootstrap.'), findsOneWidget);
  });

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
}
