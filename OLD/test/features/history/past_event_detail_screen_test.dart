/// Smoke tests for [PastEventDetailScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/history/past_event_detail_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

SessionLog _log(String id) => SessionLog(
  id: id,
  modeId: 'mode',
  modeName: 'Walk',
  startedAt: DateTime(2024, 1, 1, 12),
  endedAt: DateTime(2024, 1, 1, 12, 30),
  isSimulation: false,
);

void main() {
  testWidgets('PastEventDetailScreen shows empty when id missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [
          sessionLogsRepositoryProvider.overrideWithValue(
            FakeSessionLogsRepository(),
          ),
        ],
        child: const PastEventDetailScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(PastEventDetailScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('PastEventDetailScreen renders details for existing log', (
    tester,
  ) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [
          sessionLogsRepositoryProvider.overrideWithValue(
            FakeSessionLogsRepository([_log('log-1')]),
          ),
        ],
        initialLocation: '/?id=log-1',
        child: const PastEventDetailScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(PastEventDetailScreen).evaluate().length).equals(1);
    check(find.text('Walk').evaluate().length).equals(1);
  });

  testWidgets('PastEventDetailScreen shows a share FAB for existing log', (
    tester,
  ) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [
          sessionLogsRepositoryProvider.overrideWithValue(
            FakeSessionLogsRepository([_log('log-2')]),
          ),
        ],
        initialLocation: '/?id=log-2',
        child: const PastEventDetailScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(FloatingActionButton).evaluate().length).equals(1);
  });
}
