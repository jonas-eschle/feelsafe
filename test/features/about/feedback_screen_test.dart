/// Smoke tests for [FeedbackScreen] — verify renders and accepts
/// text input.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/features/about/feedback_screen.dart';

import '../widget_test_helpers.dart';

void main() {
  testWidgets('FeedbackScreen renders without throwing', (tester) async {
    await tester.pumpWidget(hostScreen(child: const FeedbackScreen()));
    await tester.pumpAndSettle();
    check(find.byType(FeedbackScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('FeedbackScreen accepts text input', (tester) async {
    await tester.pumpWidget(hostScreen(child: const FeedbackScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Love it');
    await tester.pump();
    check(find.text('Love it').evaluate().length).equals(1);
  });

  testWidgets('FeedbackScreen shows a FilledButton for sending',
      (tester) async {
    await tester.pumpWidget(hostScreen(child: const FeedbackScreen()));
    await tester.pumpAndSettle();
    check(find.byType(FilledButton).evaluate().length).isGreaterOrEqual(1);
  });
}
