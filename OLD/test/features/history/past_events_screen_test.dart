/// Smoke tests for [PastEventsScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/history/past_events_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

SessionLog _log(String id, String mode) => SessionLog(
  id: id,
  modeId: 'mode-1',
  modeName: mode,
  startedAt: DateTime(2025, 1, 1, 12),
  isSimulation: false,
);

void main() {
  testWidgets('PastEventsScreen renders empty when no logs', (tester) async {
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          sessionLogsRepositoryProvider.overrideWithValue(
            FakeSessionLogsRepository(),
          ),
        ],
        child: const PastEventsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(PastEventsScreen).evaluate().length).equals(1);
  });

  testWidgets('PastEventsScreen lists each log', (tester) async {
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          sessionLogsRepositoryProvider.overrideWithValue(
            FakeSessionLogsRepository([_log('a', 'Walk'), _log('b', 'Date')]),
          ),
        ],
        child: const PastEventsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.text('Walk').evaluate().length).equals(1);
    check(find.text('Date').evaluate().length).equals(1);
  });

  testWidgets('PastEventsScreen delete icon removes log', (tester) async {
    final repo = FakeSessionLogsRepository([_log('a', 'Walk')]);
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [sessionLogsRepositoryProvider.overrideWithValue(repo)],
        child: const PastEventsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    check(await repo.getAll()).isEmpty();
  });
}
