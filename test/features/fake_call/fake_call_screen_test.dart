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
}
