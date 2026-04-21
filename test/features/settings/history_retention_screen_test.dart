/// Smoke tests for [HistoryRetentionScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/settings/history_retention_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('HistoryRetentionScreen renders without throwing',
      (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: [
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
      ],
      child: const HistoryRetentionScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(HistoryRetentionScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('HistoryRetentionScreen shows a retention slider',
      (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: [
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
      ],
      child: const HistoryRetentionScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(Slider).evaluate().length).equals(1);
  });
}
