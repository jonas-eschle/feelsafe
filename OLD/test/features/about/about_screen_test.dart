/// Smoke tests for [AboutScreen] and [FeedbackScreen] — verify
/// render without throwing and core UI elements present.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/features/about/about_screen.dart';
import 'package:guardianangela/features/about/feedback_screen.dart';

import '../widget_test_helpers.dart';

void main() {
  testWidgets('AboutScreen renders without throwing', (tester) async {
    await tester.pumpWidget(hostScreen(child: const AboutScreen()));
    await tester.pump();
    check(find.byType(AboutScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('FeedbackScreen renders with a TextField', (tester) async {
    await tester.pumpWidget(hostScreen(child: const FeedbackScreen()));
    await tester.pump();
    check(find.byType(FeedbackScreen).evaluate().length).equals(1);
    // FeedbackScreen contains a text input controlled by _ctrl.
    check(find.byType(TextField).evaluate().length).isGreaterThan(0);
  });
}
