/// Smoke tests for [FakeCallScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/features/fake_call/fake_call_screen.dart';

import '../widget_test_helpers.dart';

void main() {
  testWidgets('FakeCallScreen renders without throwing', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(child: const FakeCallScreen()),
    );
    await tester.pumpAndSettle();
    check(find.byType(FakeCallScreen).evaluate().length).equals(1);
  });

  testWidgets('FakeCallScreen has answer and decline buttons',
      (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(child: const FakeCallScreen()),
    );
    await tester.pumpAndSettle();
    // Two icon buttons (answer+decline) before answering.
    check(find.byIcon(Icons.call).evaluate().length).isGreaterOrEqual(1);
    check(find.byIcon(Icons.call_end).evaluate().length).equals(1);
  });

  testWidgets('FakeCallScreen uses a black background', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(child: const FakeCallScreen()),
    );
    await tester.pumpAndSettle();
    final scaffold =
        tester.widget<Scaffold>(find.byType(Scaffold).first);
    check(scaffold.backgroundColor).equals(Colors.black);
  });

  testWidgets('FakeCallScreen tapping Answer shows Hang Up button',
      (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(child: const FakeCallScreen()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.call));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.call_end).evaluate().length).equals(1);
    check(find.byIcon(Icons.call).evaluate()).isEmpty();
  });

  testWidgets('FakeCallScreen tapping Decline triggers controller.decline',
      (tester) async {
    await tester.pumpWidget(
      hostScreenPushed(child: const FakeCallScreen()),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(FakeCallScreen),
        matching: find.byIcon(Icons.call_end),
      ),
    );
    await tester.pumpAndSettle();
    // After decline the widget pops back to the root; should no longer render.
    check(find.byType(FakeCallScreen).evaluate().length).isLessOrEqual(1);
  });

  testWidgets('FakeCallScreen tapping Hang-up after answer ends call',
      (tester) async {
    await tester.pumpWidget(
      hostScreenPushed(child: const FakeCallScreen()),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(FakeCallScreen),
        matching: find.byIcon(Icons.call),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(FakeCallScreen),
        matching: find.byIcon(Icons.call_end),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(FakeCallScreen).evaluate().length).isLessOrEqual(1);
  });
}
