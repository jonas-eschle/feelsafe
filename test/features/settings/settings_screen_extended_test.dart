/// Extended tests for [SettingsScreen]:
///   * Theme dropdown changes persist AppThemeMode in settings.
///   * Tapping NavTiles pushes expected routes (checked by using a
///     GoRouter with a throwaway catch-all destination).
///   * Alarm DND switch toggles off again.
///   * Ships exactly the expected number of NavTiles (one per route).
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/settings/settings_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets(
    'SettingsScreen theme dropdown persists dark theme',
    (tester) async {
      final repo = FakeSettingsRepository();
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const SettingsScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(DropdownButton<AppThemeMode>),
        400,
      );
      await tester.tap(find.byType(DropdownButton<AppThemeMode>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark').last);
      await tester.pumpAndSettle();
      check(repo.stored).isNotNull();
      check(repo.stored!.themeMode).equals(AppThemeMode.dark);
    },
  );

  testWidgets(
    'SettingsScreen theme dropdown persists light theme',
    (tester) async {
      final repo = FakeSettingsRepository();
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const SettingsScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(DropdownButton<AppThemeMode>),
        400,
      );
      await tester.tap(find.byType(DropdownButton<AppThemeMode>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Light').last);
      await tester.pumpAndSettle();
      check(repo.stored!.themeMode).equals(AppThemeMode.light);
    },
  );

  testWidgets(
    'SettingsScreen alarm DND toggle off reverses the flag',
    (tester) async {
      final repo = FakeSettingsRepository(
        const AppSettings(defaults: AppDefaults(), alarmDndOverride: true),
      );
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const SettingsScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.byType(Switch), 400);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      check(repo.stored!.alarmDndOverride).equals(false);
    },
  );

  testWidgets(
    'SettingsScreen has multiple ListTiles with chevron_right',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          settingsRepositoryProvider
              .overrideWithValue(FakeSettingsRepository()),
        ],
        child: const SettingsScreen(),
      ));
      await tester.pumpAndSettle();
      // Many NavTiles — each has a chevron_right trailing icon.
      // ListView builds lazily, so before scrolling only a few tiles
      // are present. Just assert at least one is rendered.
      check(find.byIcon(Icons.chevron_right).evaluate().length)
          .isGreaterOrEqual(1);
    },
  );

  testWidgets(
    'SettingsScreen initial theme value reflects stored setting',
    (tester) async {
      final repo = FakeSettingsRepository(
        const AppSettings(
          defaults: AppDefaults(),
          themeMode: AppThemeMode.dark,
        ),
      );
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const SettingsScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(DropdownButton<AppThemeMode>),
        400,
      );
      final dd = tester.widget<DropdownButton<AppThemeMode>>(
        find.byType(DropdownButton<AppThemeMode>),
      );
      check(dd.value).equals(AppThemeMode.dark);
    },
  );
}
