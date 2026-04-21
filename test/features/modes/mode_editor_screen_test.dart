/// Smoke tests for [ModeEditorScreen].
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
  testWidgets('ModeEditorScreen renders a blank form for creation',
      (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        modesRepositoryProvider.overrideWithValue(FakeModesRepository()),
        distressChainsRepositoryProvider
            .overrideWithValue(FakeDistressChainsRepository()),
      ],
      child: const ModeEditorScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(ModeEditorScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('ModeEditorScreen shows a name TextField', (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        modesRepositoryProvider.overrideWithValue(FakeModesRepository()),
        distressChainsRepositoryProvider
            .overrideWithValue(FakeDistressChainsRepository()),
      ],
      child: const ModeEditorScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(TextField).evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('ModeEditorScreen shows an add-step button', (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        modesRepositoryProvider.overrideWithValue(FakeModesRepository()),
        distressChainsRepositoryProvider
            .overrideWithValue(FakeDistressChainsRepository()),
      ],
      child: const ModeEditorScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.add).evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('ModeEditorScreen hydrates fields when editing existing mode',
      (tester) async {
    final mode = makeMode(id: 'mode-7', name: 'CustomMode');
    await tester.pumpWidget(hostScreenPushed(
      overrides: [
        modesRepositoryProvider
            .overrideWithValue(FakeModesRepository([mode])),
        distressChainsRepositoryProvider
            .overrideWithValue(FakeDistressChainsRepository()),
      ],
      initialQuery: 'id=mode-7',
      child: const ModeEditorScreen(),
    ));
    await tester.pumpAndSettle();
    // The hydrated name appears in the TextField's controller value.
    final field = tester.widget<TextField>(find.byType(TextField).first);
    check(field.controller!.text).equals('CustomMode');
  });

  testWidgets(
    'ModeEditorScreen save tap persists a new mode',
    (tester) async {
      final repo = FakeModesRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          modesRepositoryProvider.overrideWithValue(repo),
          distressChainsRepositoryProvider
              .overrideWithValue(FakeDistressChainsRepository()),
        ],
        child: const ModeEditorScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'FancyMode');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      final saved = await repo.getAll();
      check(saved.length).equals(1);
      check(saved.single.name).equals('FancyMode');
    },
  );

  testWidgets('ModeEditorScreen empty name falls back to "Mode"',
      (tester) async {
    final repo = FakeModesRepository();
    await tester.pumpWidget(hostScreenPushed(
      overrides: [
        modesRepositoryProvider.overrideWithValue(repo),
        distressChainsRepositoryProvider
            .overrideWithValue(FakeDistressChainsRepository()),
      ],
      child: const ModeEditorScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();
    final saved = await repo.getAll();
    check(saved.single.name).equals('Mode');
  });
}
