// Phase 0 smoke test for the placeholder splash. Phase 6 replaces
// this when the real routing + screens land.

import 'package:flutter_test/flutter_test.dart';
import 'package:guardianangela/main.dart';

void main() {
  testWidgets('Phase 0 splash renders without errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GuardianAngelaApp());
    await tester.pumpAndSettle();

    expect(find.text('Guardian Angela'), findsOneWidget);
    expect(find.text("Your angel's got your back."), findsOneWidget);
    expect(find.text('Pre-alpha v3 — Phase 0 skeleton.'), findsOneWidget);
  });
}
