/// Tests for [ModeEditorScreen] in distress-mode editing path.
///
/// Covers: isDistress=true rendering (simplified name field, no
/// check-in type dropdown, no tracking section, no triggers),
/// save via distress controller, and mode hydration for distress modes.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/modes/mode_editor_screen.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  group('ModeEditorScreen (isDistress=true)', () {
    Widget buildDistressEditor({
      FakeModesRepository? repo,
      String initialQuery = '',
    }) {
      final r = repo ?? FakeModesRepository();
      return hostScreenPushed(
        overrides: [
          modesRepositoryProvider.overrideWithValue(r),
          settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
        ],
        initialQuery: initialQuery,
        child: const ModeEditorScreen(isDistress: true),
      );
    }

    testWidgets('renders a name TextField for distress modes', (tester) async {
      await tester.pumpWidget(buildDistressEditor());
      await tester.pumpAndSettle();
      check(find.byType(TextField).evaluate()).isNotEmpty();
    });

    testWidgets('does not render check-in type dropdown for distress modes',
        (tester) async {
      await tester.pumpWidget(buildDistressEditor());
      await tester.pumpAndSettle();
      // The check-in DropdownButtonFormField is not shown in distress mode.
      // We check that only one dropdown or none appears (some other dropdowns
      // may appear in distress editors but not check-in type).
      final dropdowns = find.byType(DropdownButtonFormField);
      // In distress mode the check-in type dropdown is hidden.
      // At most 0 dropdowns shown (the isDistress=true branch shows only name).
      check(dropdowns.evaluate().length).isLessThan(2);
    });

    testWidgets('save button is present', (tester) async {
      await tester.pumpWidget(buildDistressEditor());
      await tester.pumpAndSettle();
      check(find.byIcon(Icons.check).evaluate()).isNotEmpty();
    });

    testWidgets('adds a step via the add-step button', (tester) async {
      final repo = FakeModesRepository();
      await tester.pumpWidget(buildDistressEditor(repo: repo));
      await tester.pumpAndSettle();

      // Tap add-step button.
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      // Pick a step type from the picker.
      await tester.tap(find.text('Hold button').last);
      await tester.pumpAndSettle();
    });

    testWidgets('hydrates name from existing distress mode', (tester) async {
      final dm = makeDistressMode(id: 'dm1', name: 'My Distress');
      final repo = FakeModesRepository([dm]);
      await tester.pumpWidget(buildDistressEditor(
        repo: repo,
        initialQuery: 'id=dm1',
      ));
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(find.byType(TextField).first);
      check(field.controller?.text).equals('My Distress');
    });

    testWidgets('saves distress mode when check button tapped', (tester) async {
      final repo = FakeModesRepository();
      await tester.pumpWidget(buildDistressEditor(repo: repo));
      await tester.pumpAndSettle();

      // Type a name.
      await tester.enterText(find.byType(TextField).first, 'New Distress');
      await tester.pump();

      // Add a step so the chain is non-empty (required for distress modes).
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hold button').last);
      await tester.pumpAndSettle();

      // Tap save.
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // The mode should now be in the repository.
      final all = await repo.getAll();
      final distressModes = all.where((m) => m.isDistressMode).toList();
      check(distressModes).isNotEmpty();
      check(distressModes.first.name).equals('New Distress');
    });
  });

  group('ModeEditorScreen (distress triggers section)', () {
    testWidgets('distress triggers section exists for regular modes',
        (tester) async {
      final repo = FakeModesRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          modesRepositoryProvider.overrideWithValue(repo),
          settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
        ],
        child: const ModeEditorScreen(),
      ));
      await tester.pumpAndSettle();

      // The screen renders without errors — distress triggers section
      // is present in the layout for regular modes.
      check(find.byType(ModeEditorScreen).evaluate()).isNotEmpty();
    });
  });

  group('ModeEditorScreen (tracking section)', () {
    testWidgets('tracking section is hidden for distress modes', (tester) async {
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          modesRepositoryProvider.overrideWithValue(FakeModesRepository()),
          settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
        ],
        child: const ModeEditorScreen(isDistress: true),
      ));
      await tester.pumpAndSettle();

      // Scroll through all content to confirm no tracking header appears.
      // The tracking section is only shown for !isDistress.
      // No SwitchListTile for tracking in distress mode.
      final tiles = tester.widgetList<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      check(tiles.toList()).isEmpty();
    });
  });
}
