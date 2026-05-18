/// Tests for the "new mode" picker on [ModesScreen].
///
/// The picker offers a "Blank mode" entry plus one "From [name]"
/// entry per existing non-distress mode. Selecting a template clones
/// its `chainSteps` + triggers into a freshly-id'd `SessionMode`.
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
  testWidgets(
    'picker offers Blank plus one entry per existing mode',
    (tester) async {
      final walk = makeMode(id: 'walk', name: 'Walk Mode');
      final date = makeMode(id: 'date', name: 'Date Mode');
      final repo = FakeModesRepository([walk, date]);
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [modesRepositoryProvider.overrideWithValue(repo)],
        child: const ModesScreen(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      check(find.textContaining('Blank').evaluate()).isNotEmpty();
      check(find.textContaining('Walk Mode').evaluate()).isNotEmpty();
      check(find.textContaining('Date Mode').evaluate()).isNotEmpty();
    },
  );

  testWidgets(
    'picker omits distress modes from the template list',
    (tester) async {
      final walk = makeMode(id: 'walk', name: 'Walk Mode');
      final distress = makeDistressMode(id: 'distress', name: 'Default');
      final repo = FakeModesRepository([walk, distress]);
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [modesRepositoryProvider.overrideWithValue(repo)],
        child: const ModesScreen(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      check(find.textContaining('Walk Mode').evaluate()).isNotEmpty();
      // The distress mode (name 'Default') is NOT offered as a clone
      // source.
      check(find.textContaining('From Default').evaluate()).isEmpty();
    },
  );

  testWidgets(
    'picker still shows built-in templates when the modes list is empty',
    (tester) async {
      // Even with no user-saved modes, Walk Mode + Date Mode appear
      // as permanent built-in templates carrying the "Built-in" badge.
      final repo = FakeModesRepository();
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [modesRepositoryProvider.overrideWithValue(repo)],
        child: const ModesScreen(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      check(find.text('From Walk Mode').evaluate()).isNotEmpty();
      check(find.text('From Date Mode').evaluate()).isNotEmpty();
      // Built-in badge should be present (one or more, depending on
      // theme rendering).
      check(find.text('Built-in').evaluate()).isNotEmpty();
    },
  );

  testWidgets(
    'picker clones the chosen mode and saves it before routing',
    (tester) async {
      // Use a custom name so the test taps a single entry — the
      // built-in 'Walk Mode' is always also present in the picker.
      final walk = makeMode(
        id: 'user-mode-1',
        name: 'My Custom Mode',
        steps: [holdStep(), smsStep()],
      );
      final repo = FakeModesRepository([walk]);
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [modesRepositoryProvider.overrideWithValue(repo)],
        child: const ModesScreen(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      // The picker sheet now also lists Walk + Date built-ins above
      // the user mode; scroll the user mode into view before tapping.
      final myMode = find.text('From My Custom Mode');
      await tester.ensureVisible(myMode);
      await tester.pumpAndSettle();
      await tester.tap(myMode);
      await tester.pumpAndSettle();

      final stored = await repo.getAll();
      // Original 'My Custom Mode' is still there, plus the new clone.
      check(stored.length).equals(2);
      final clone = stored.firstWhere((m) => m.id != 'user-mode-1');
      check(clone.name).contains('My Custom Mode');
      check(clone.chainSteps.length).equals(walk.chainSteps.length);
    },
  );
}
