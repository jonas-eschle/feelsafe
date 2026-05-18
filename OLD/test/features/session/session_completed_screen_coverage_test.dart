/// Coverage test for [SessionCompletedScreen] — targets line 14
/// (the const constructor), which is not instrumented when called as
/// `const` because const constructors are resolved at compile time.
/// A non-const instantiation forces the constructor line into the
/// coverage data.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/features/session/session_completed_screen.dart';

import '../widget_test_helpers.dart';

void main() {
  group('SessionCompletedScreen constructor coverage (line 14)', () {
    testWidgets(
      'non-const instantiation instruments the constructor line',
      (tester) async {
        // ignore: prefer_const_constructors
        final widget = SessionCompletedScreen(key: UniqueKey());
        await tester.pumpWidget(hostScreenWithRouter(child: widget));
        await tester.pumpAndSettle();
        check(find.byType(SessionCompletedScreen).evaluate()).isNotEmpty();
      },
    );
  });
}
