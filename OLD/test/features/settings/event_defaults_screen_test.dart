/// Smoke tests for [EventDefaultsScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/features/settings/event_defaults_screen.dart';

import '../widget_test_helpers.dart';

void main() {
  testWidgets('EventDefaultsScreen renders without throwing', (tester) async {
    await tester.pumpWidget(hostScreen(child: const EventDefaultsScreen()));
    await tester.pumpAndSettle();
    check(find.byType(EventDefaultsScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('EventDefaultsScreen shows placeholder text', (tester) async {
    await tester.pumpWidget(hostScreen(child: const EventDefaultsScreen()));
    await tester.pumpAndSettle();
    check(find.byType(Text).evaluate().length).isGreaterThan(1);
  });
}
