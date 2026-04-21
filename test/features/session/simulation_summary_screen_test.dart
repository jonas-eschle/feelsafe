/// Smoke tests for [SimulationSummaryScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/features/session/simulation_summary_screen.dart';

import '../widget_test_helpers.dart';

void main() {
  testWidgets('SimulationSummaryScreen renders empty state', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(child: const SimulationSummaryScreen()),
    );
    await tester.pumpAndSettle();
    check(find.byType(SimulationSummaryScreen).evaluate().length).equals(1);
  });

  testWidgets('SimulationSummaryScreen has an AppBar', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(child: const SimulationSummaryScreen()),
    );
    await tester.pumpAndSettle();
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('SimulationSummaryScreen shows return CTA', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(child: const SimulationSummaryScreen()),
    );
    await tester.pumpAndSettle();
    check(find.byType(FilledButton).evaluate().length).equals(1);
  });
}
