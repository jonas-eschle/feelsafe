/// Smoke tests for [SessionCompletedScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/features/session/session_completed_screen.dart';

import '../widget_test_helpers.dart';

void main() {
  testWidgets('SessionCompletedScreen renders without throwing', (
    tester,
  ) async {
    await tester.pumpWidget(
      hostScreenWithRouter(child: const SessionCompletedScreen()),
    );
    await tester.pumpAndSettle();
    check(find.byType(SessionCompletedScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('SessionCompletedScreen shows a return-home CTA', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(child: const SessionCompletedScreen()),
    );
    await tester.pumpAndSettle();
    check(find.byType(FilledButton).evaluate().length).equals(1);
  });

  testWidgets('SessionCompletedScreen shows a check icon', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(child: const SessionCompletedScreen()),
    );
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.check_circle).evaluate().length).equals(1);
  });
}
