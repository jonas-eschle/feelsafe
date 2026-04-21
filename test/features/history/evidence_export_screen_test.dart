/// Smoke tests for [EvidenceExportScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/history/evidence_export_screen.dart';

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
  testWidgets('EvidenceExportScreen renders without throwing',
      (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        sessionLogsRepositoryProvider
            .overrideWithValue(FakeSessionLogsRepository()),
      ],
      child: const EvidenceExportScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(EvidenceExportScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('EvidenceExportScreen disables buttons when no id',
      (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        sessionLogsRepositoryProvider
            .overrideWithValue(FakeSessionLogsRepository()),
      ],
      child: const EvidenceExportScreen(),
    ));
    await tester.pumpAndSettle();
    final filled = tester.widget<FilledButton>(find.byType(FilledButton));
    check(filled.onPressed).isNull();
  });

  testWidgets('EvidenceExportScreen enables buttons for existing log',
      (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        sessionLogsRepositoryProvider.overrideWithValue(
          FakeSessionLogsRepository([_log('log-7')]),
        ),
      ],
      initialLocation: '/?id=log-7',
      child: const EvidenceExportScreen(),
    ));
    await tester.pumpAndSettle();
    final filled = tester.widget<FilledButton>(find.byType(FilledButton));
    check(filled.onPressed).isNotNull();
  });
}
