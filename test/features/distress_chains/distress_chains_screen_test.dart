/// Smoke tests for [DistressChainsScreen].
library;

import 'package:checks/checks.dart';
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
}
