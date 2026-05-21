/// Smoke tests for [ModesScreen] — renders, shows an entry per mode.
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
  testWidgets('ModesScreen renders empty state with no modes', (tester) async {
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          modesRepositoryProvider.overrideWithValue(FakeModesRepository()),
        ],
        child: const ModesScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(ModesScreen).evaluate().length).equals(1);
  });

  testWidgets('ModesScreen renders one tile per mode', (tester) async {
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          modesRepositoryProvider.overrideWithValue(
            FakeModesRepository([
              makeMode(id: 'm1', name: 'Walk'),
              makeMode(id: 'm2', name: 'Date'),
            ]),
          ),
        ],
        child: const ModesScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.text('Walk').evaluate().length).equals(1);
    check(find.text('Date').evaluate().length).equals(1);
  });

  testWidgets('ModesScreen shows an AppBar', (tester) async {
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          modesRepositoryProvider.overrideWithValue(FakeModesRepository()),
        ],
        child: const ModesScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('ModesScreen delete icon removes mode', (tester) async {
    final repo = FakeModesRepository([
      makeMode(id: 'm1', name: 'Walk'),
      makeMode(id: 'm2', name: 'Date'),
    ]);
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [modesRepositoryProvider.overrideWithValue(repo)],
        child: const ModesScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    check((await repo.getAll()).length).equals(1);
  });
}
