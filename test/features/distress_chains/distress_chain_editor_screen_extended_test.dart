/// Extended tests for [DistressChainEditorScreen]:
///   * Add-step bottom sheet appends a step.
///   * Delete-step tile removes the step.
///   * Save persists a brand-new chain (not just edits to existing).
///   * Empty name falls back to "Chain".
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/distress_chains/distress_chain_editor_screen.dart';
import 'package:guardianangela/features/modes/widgets/chain_step_tile.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets(
    'DistressChainEditorScreen add-step bottom sheet appends a step',
    (tester) async {
      final repo = FakeDistressChainsRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          distressChainsRepositoryProvider.overrideWithValue(repo),
        ],
        child: const DistressChainEditorScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      final tiles = find.byType(ListTile);
      check(tiles.evaluate().length).isGreaterOrEqual(1);
      await tester.tap(tiles.first);
      await tester.pumpAndSettle();
      check(find.byType(ChainStepTile).evaluate().length).equals(1);
    },
  );

  testWidgets(
    'DistressChainEditorScreen delete tile removes the step',
    (tester) async {
      final chain = makeDistressChain(
        id: 'dc-1',
        name: 'ToEdit',
        steps: [smsStep(id: 's1'), smsStep(id: 's2', order: 1)],
      );
      final repo = FakeDistressChainsRepository([chain]);
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          distressChainsRepositoryProvider.overrideWithValue(repo),
        ],
        initialQuery: 'id=dc-1',
        child: const DistressChainEditorScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.byType(ChainStepTile).evaluate().length).equals(2);
      final deletes = find.descendant(
        of: find.byType(ChainStepTile),
        matching: find.byIcon(Icons.delete_outline),
      );
      await tester.tap(deletes.first);
      await tester.pumpAndSettle();
      check(find.byType(ChainStepTile).evaluate().length).equals(1);
    },
  );

  testWidgets(
    'DistressChainEditorScreen saves a brand-new chain',
    (tester) async {
      final repo = FakeDistressChainsRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          distressChainsRepositoryProvider.overrideWithValue(repo),
        ],
        child: const DistressChainEditorScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'BrandNew');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      final stored = await repo.getAll();
      check(stored.length).equals(1);
      check(stored.single.name).equals('BrandNew');
    },
  );

  testWidgets(
    'DistressChainEditorScreen empty name falls back to "Chain"',
    (tester) async {
      final repo = FakeDistressChainsRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          distressChainsRepositoryProvider.overrideWithValue(repo),
        ],
        child: const DistressChainEditorScreen(),
      ));
      await tester.pumpAndSettle();
      // Leave the name blank. Add a step so save is not a no-op.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      final stored = await repo.getAll();
      check(stored.single.name).equals('Chain');
    },
  );
}
