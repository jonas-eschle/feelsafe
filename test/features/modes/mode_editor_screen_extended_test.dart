/// Extended tests for [ModeEditorScreen]:
///   * Add-step bottom sheet flow adds a new [ChainStep] to the chain.
///   * Delete-step trashes the selected step.
///   * Check-in type dropdown persists chosen [ChainStepType].
///   * Distress-chain dropdown binds `distressModeId` on save.
///   * Editing an existing mode with a populated chain renders the
///     [ReorderableListView].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/modes/mode_editor_screen.dart';
import 'package:guardianangela/features/modes/widgets/chain_step_tile.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets(
    'ModeEditorScreen add-step bottom sheet appends a step',
    (tester) async {
      final repo = FakeModesRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          modesRepositoryProvider.overrideWithValue(repo),        ],
        child: const ModeEditorScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(ModeEditorScreen),
          matching: find.byIcon(Icons.add),
        ),
      );
      await tester.pumpAndSettle();
      // The bottom sheet lists nine step types — tap the first.
      final tiles = find.byType(ListTile);
      check(tiles.evaluate().length).isGreaterOrEqual(1);
      await tester.tap(tiles.first);
      await tester.pumpAndSettle();
      // Save to persist the new step.
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      final saved = await repo.getAll();
      check(saved.length).equals(1);
      check(saved.single.chainSteps.length).equals(1);
    },
  );

  testWidgets(
    'ModeEditorScreen check-in dropdown persists disguisedReminder',
    (tester) async {
      final repo = FakeModesRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          modesRepositoryProvider.overrideWithValue(repo),        ],
        child: const ModeEditorScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(ModeEditorScreen),
          matching: find.byType(DropdownButtonFormField<ChainStepType>),
        ),
      );
      await tester.pumpAndSettle();
      await tester
          .tap(find.text('Disguised reminder').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      final saved = await repo.getAll();
      check(saved.single.checkInType)
          .equals(ChainStepType.disguisedReminder);
    },
  );

  testWidgets(
    'ModeEditorScreen distress-chain dropdown binds selected chain id',
    (tester) async {
      final distressMode = makeDistressMode(id: 'dc-1', name: 'MyChain');
      final repo = FakeModesRepository([distressMode]);
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          modesRepositoryProvider.overrideWithValue(repo),
        ],
        child: const ModeEditorScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(ModeEditorScreen),
          matching: find.byType(DropdownButtonFormField<String?>),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('MyChain').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      final saved = (await repo.getAll())
          .where((m) => !m.isDistressMode)
          .toList();
      check(saved.single.distressModeId).equals('dc-1');
    },
  );

  testWidgets(
    'ModeEditorScreen existing mode renders ReorderableListView',
    (tester) async {
      final mode = makeMode(
        id: 'm7',
        steps: [holdStep(id: 's1'), holdStep(id: 's2', order: 1)],
      );
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          modesRepositoryProvider
              .overrideWithValue(FakeModesRepository([mode])),        ],
        initialQuery: 'id=m7',
        child: const ModeEditorScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.byType(ReorderableListView).evaluate().length).equals(1);
      check(find.byType(ChainStepTile).evaluate().length).equals(2);
    },
  );

  testWidgets(
    'ModeEditorScreen delete tile removes a chain step on save',
    (tester) async {
      final mode = makeMode(
        id: 'm8',
        steps: [holdStep(id: 's1'), holdStep(id: 's2', order: 1)],
      );
      final repo = FakeModesRepository([mode]);
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          modesRepositoryProvider.overrideWithValue(repo),        ],
        initialQuery: 'id=m8',
        child: const ModeEditorScreen(),
      ));
      await tester.pumpAndSettle();
      // ChainStepTile exposes a delete icon; each tile has one.
      final deletes = find.descendant(
        of: find.byType(ChainStepTile),
        matching: find.byIcon(Icons.delete_outline),
      );
      check(deletes.evaluate().length).equals(2);
      await tester.tap(deletes.first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      final saved = await repo.getAll();
      check(saved.single.chainSteps.length).equals(1);
    },
  );
}
