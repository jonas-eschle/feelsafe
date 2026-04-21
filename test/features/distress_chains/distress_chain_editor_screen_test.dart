/// Smoke tests for [DistressChainEditorScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/distress_chains/distress_chain_editor_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('DistressChainEditorScreen renders a blank form for creation',
      (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        distressChainsRepositoryProvider
            .overrideWithValue(FakeDistressChainsRepository()),
      ],
      child: const DistressChainEditorScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(DistressChainEditorScreen).evaluate().length)
        .equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('DistressChainEditorScreen shows a name TextField',
      (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        distressChainsRepositoryProvider
            .overrideWithValue(FakeDistressChainsRepository()),
      ],
      child: const DistressChainEditorScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(TextField).evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('DistressChainEditorScreen shows an add-step button',
      (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        distressChainsRepositoryProvider
            .overrideWithValue(FakeDistressChainsRepository()),
      ],
      child: const DistressChainEditorScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.add).evaluate().length).isGreaterOrEqual(1);
  });
}
