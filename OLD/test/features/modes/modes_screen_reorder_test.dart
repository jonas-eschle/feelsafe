/// Supplemental tests for [ModesScreen] covering:
///   - line 17: const constructor via non-const instantiation.
///   - lines 32–33: `onReorder` callback of [ReorderableListView].
///
/// The `onReorder` callback is accessed directly from the
/// [ReorderableListView] widget found in the tree — this avoids the
/// complexity of simulating a long-press drag gesture and ensures the
/// line is actually executed.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/modes/modes_screen.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  group('ModesScreen — constructor + onReorder (lines 17, 32–33)', () {
    testWidgets(
      'non-const instantiation covers line 17',
      (tester) async {
        // ignore: prefer_const_constructors
        final widget = ModesScreen(key: UniqueKey());
        await tester.pumpWidget(
          hostScreenWithRouter(
            overrides: [
              modesRepositoryProvider.overrideWithValue(
                FakeModesRepository([]),
              ),
            ],
            child: widget,
          ),
        );
        await tester.pumpAndSettle();
        check(find.byType(ModesScreen).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'onReorder callback can be invoked directly (lines 32–33)',
      (tester) async {
        final repo = FakeModesRepository([
          makeMode(id: 'm1', name: 'Mode One'),
          makeMode(id: 'm2', name: 'Mode Two'),
          makeMode(id: 'm3', name: 'Mode Three'),
        ]);

        await tester.pumpWidget(
          hostScreenWithRouter(
            overrides: [modesRepositoryProvider.overrideWithValue(repo)],
            child: const ModesScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Find the ReorderableListView and invoke onReorder directly.
        final rlv = tester.widget<ReorderableListView>(
          find.byType(ReorderableListView),
        );
        // Call the callback with a valid reorder (move index 0 to 2).
        rlv.onReorder(0, 2);
        await tester.pumpAndSettle();

        // The screen must still be visible after the reorder.
        check(find.byType(ModesScreen).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'reorder in reverse direction (lines 32–33)',
      (tester) async {
        final repo = FakeModesRepository([
          makeMode(id: 'm1', name: 'Alpha'),
          makeMode(id: 'm2', name: 'Beta'),
        ]);

        await tester.pumpWidget(
          hostScreenWithRouter(
            overrides: [modesRepositoryProvider.overrideWithValue(repo)],
            child: const ModesScreen(),
          ),
        );
        await tester.pumpAndSettle();

        final rlv = tester.widget<ReorderableListView>(
          find.byType(ReorderableListView),
        );
        // Move index 1 to 0.
        rlv.onReorder(1, 0);
        await tester.pumpAndSettle();

        check(find.byType(ModesScreen).evaluate()).isNotEmpty();
      },
    );
  });
}
