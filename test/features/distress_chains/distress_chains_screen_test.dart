/// Smoke tests for [DistressChainsScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/distress_chains/distress_chains_screen.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('DistressChainsScreen renders empty state', (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: [
        distressChainsRepositoryProvider
            .overrideWithValue(FakeDistressChainsRepository()),
      ],
      child: const DistressChainsScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(DistressChainsScreen).evaluate().length).equals(1);
  });

  testWidgets('DistressChainsScreen lists each chain', (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: [
        distressChainsRepositoryProvider.overrideWithValue(
          FakeDistressChainsRepository([
            makeDistressChain(id: 'd1', name: 'Primary'),
            makeDistressChain(id: 'd2', name: 'Secondary'),
          ]),
        ),
      ],
      child: const DistressChainsScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.text('Primary').evaluate().length).equals(1);
    check(find.text('Secondary').evaluate().length).equals(1);
  });

  testWidgets(
    'DistressChainsScreen delete icon removes one of multiple chains',
    (tester) async {
      final repo = FakeDistressChainsRepository([
        makeDistressChain(id: 'd1', name: 'Primary'),
        makeDistressChain(id: 'd2', name: 'Secondary'),
      ]);
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          distressChainsRepositoryProvider.overrideWithValue(repo),
        ],
        child: const DistressChainsScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      check((await repo.getAll()).length).equals(1);
    },
  );
}
