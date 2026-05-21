/// Smoke tests for [NotificationSettingsScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/settings/notification_settings_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('NotificationSettingsScreen renders without throwing', (
    tester,
  ) async {
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
        ],
        child: const NotificationSettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(NotificationSettingsScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('NotificationSettingsScreen shows DND toggle', (tester) async {
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
        ],
        child: const NotificationSettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(SwitchListTile).evaluate().length).equals(1);
  });

  testWidgets('NotificationSettingsScreen toggle persists alarm DND', (
    tester,
  ) async {
    final repo = FakeSettingsRepository();
    await tester.pumpWidget(
      hostScreen(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const NotificationSettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    check(repo.stored!.alarmDndOverride).isTrue();
  });
}
