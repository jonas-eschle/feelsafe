/// Smoke tests for [DistressChainEditorScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/distress_chains/distress_chain_editor_screen.dart';

import '../../helpers/test_helpers.dart';
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

  testWidgets(
    'DistressChainEditorScreen hydrates fields when editing existing chain',
    (tester) async {
      final chain = makeDistressChain(id: 'dc-1', name: 'MyChain');
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          distressChainsRepositoryProvider
              .overrideWithValue(FakeDistressChainsRepository([chain])),
        ],
        initialLocation: '/?id=dc-1',
        child: const DistressChainEditorScreen(),
      ));
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(
        find.descendant(
          of: find.byType(DistressChainEditorScreen),
          matching: find.byType(TextField),
        ).first,
      );
      check(field.controller!.text).equals('MyChain');
    },
  );

  testWidgets(
    'DistressChainEditorScreen save with empty steps is a no-op',
    (tester) async {
      final repo = FakeDistressChainsRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          distressChainsRepositoryProvider.overrideWithValue(repo),
        ],
        child: const DistressChainEditorScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      check(await repo.getAll()).isEmpty();
    },
  );

  testWidgets(
    'DistressChainEditorScreen save persists edited chain with new name',
    (tester) async {
      final chain = makeDistressChain(id: 'dc-1', name: 'Old');
      final repo = FakeDistressChainsRepository([chain]);
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          distressChainsRepositoryProvider.overrideWithValue(repo),
        ],
        initialQuery: 'id=dc-1',
        child: const DistressChainEditorScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'New');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      final stored = await repo.getAll();
      check(stored.single.name).equals('New');
    },
  );
}
