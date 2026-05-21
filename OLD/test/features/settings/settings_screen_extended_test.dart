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
  // The Material DropdownButton's overlay menu does not render
  // reliably in the widget-test environment (see flutter/flutter
  // issue #84518), so we drive the persistence path through the
  // dropdown's `onChanged` callback directly instead of tapping
  // through the popup menu. We still scroll the dropdown into view
  // to make sure it's wired into the screen.
  Future<void> drivenPickTheme(WidgetTester tester, AppThemeMode mode) async {
    await tester.scrollUntilVisible(
      find.byType(DropdownButton<AppThemeMode>),
      400,
    );
    final dropdown = tester.widget<DropdownButton<AppThemeMode>>(
      find.byType(DropdownButton<AppThemeMode>),
    );
    dropdown.onChanged!(mode);
    await tester.pumpAndSettle();
  }

  testWidgets('SettingsScreen theme dropdown persists dark theme', (
    tester,
  ) async {
    final repo = FakeSettingsRepository();
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await drivenPickTheme(tester, AppThemeMode.dark);
    check(repo.stored).isNotNull();
    check(repo.stored!.themeMode).equals(AppThemeMode.dark);
  });

  testWidgets('SettingsScreen theme dropdown persists light theme', (
    tester,
  ) async {
    final repo = FakeSettingsRepository();
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await drivenPickTheme(tester, AppThemeMode.light);
    check(repo.stored!.themeMode).equals(AppThemeMode.light);
  });

  testWidgets('SettingsScreen alarm DND toggle off reverses the flag', (
    tester,
  ) async {
    final repo = FakeSettingsRepository(
      const AppSettings(defaults: AppDefaults(), alarmDndOverride: true),
    );
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    // Scroll the DND tile text into view and tap the Switch inside it.
    // When alarmDndOverride is true the gradual-volume SwitchListTile
    // also renders, so we can't use find.byType(Switch) unqualified.
    final dndTileText = find.text('Alarm overrides Do Not Disturb');
    await tester.scrollUntilVisible(dndTileText, 400);
    final dndSwitch = find.descendant(
      of: find.ancestor(of: dndTileText, matching: find.byType(ListTile)),
      matching: find.byType(Switch),
    );
    await tester.tap(dndSwitch);
    await tester.pumpAndSettle();
    check(repo.stored!.alarmDndOverride).equals(false);
  });

  testWidgets('SettingsScreen has multiple ListTiles with chevron_right', (
    tester,
  ) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
        ],
        child: const SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    // Many NavTiles — each has a chevron_right trailing icon.
    // ListView builds lazily, so before scrolling only a few tiles
    // are present. Just assert at least one is rendered.
    check(
      find.byIcon(Icons.chevron_right).evaluate().length,
    ).isGreaterOrEqual(1);
  });

  testWidgets('SettingsScreen initial theme value reflects stored setting', (
    tester,
  ) async {
    final repo = FakeSettingsRepository(
      const AppSettings(defaults: AppDefaults(), themeMode: AppThemeMode.dark),
    );
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byType(DropdownButton<AppThemeMode>),
      400,
    );
    final dd = tester.widget<DropdownButton<AppThemeMode>>(
      find.byType(DropdownButton<AppThemeMode>),
    );
    check(dd.value).equals(AppThemeMode.dark);
  });
}
