/// Smoke tests for [SettingsScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/settings/settings_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('SettingsScreen renders without throwing', (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
      ],
      child: const SettingsScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(SettingsScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('SettingsScreen renders navigable list tiles', (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
      ],
      child: const SettingsScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(ListTile).evaluate().length).isGreaterThan(0);
  });

  testWidgets('SettingsScreen alarm DND switch toggles setting',
      (tester) async {
    final repo = FakeSettingsRepository();
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repo),
      ],
      child: const SettingsScreen(),
    ));
    await tester.pumpAndSettle();
    // Scroll until the DND switch ListTile text is visible, then tap
    // the Switch inside the DND tile directly via a descendant search.
    // `alarmDndOverride` defaults to false so the first Switch in the
    // list is the DND one (gradual-volume switch is hidden until DND is
    // toggled on, but let's be precise with a text-parent finder).
    final dndTileText = find.text('Alarm overrides Do Not Disturb');
    await tester.scrollUntilVisible(dndTileText, 400);
    // The DND ListTile contains a raw Switch (not SwitchListTile).
    final dndSwitch = find.descendant(
      of: find.ancestor(
        of: dndTileText,
        matching: find.byType(ListTile),
      ),
      matching: find.byType(Switch),
    );
    await tester.tap(dndSwitch);
    await tester.pumpAndSettle();
    check(repo.stored!.alarmDndOverride).isTrue();
  });
}
