/// Smoke tests for [StealthScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/features/settings/stealth_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('StealthScreen renders without throwing', (tester) async {
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
        ],
        child: const StealthScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(StealthScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('StealthScreen shows toggles', (tester) async {
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
        ],
        child: const StealthScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(SwitchListTile).evaluate().length).isGreaterThan(0);
  });

  testWidgets('StealthScreen enable toggle persists defaults', (tester) async {
    final repo = FakeSettingsRepository();
    await tester.pumpWidget(
      hostScreen(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const StealthScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();
    check(repo.stored!.defaults.stealth.enabled).isTrue();
  });

  testWidgets('StealthScreen notificationDisguise toggle persists', (
    tester,
  ) async {
    final repo = FakeSettingsRepository();
    await tester.pumpWidget(
      hostScreen(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const StealthScreen(),
      ),
    );
    await tester.pumpAndSettle();
    // Second switch = notificationDisguise.
    await tester.tap(find.byType(SwitchListTile).at(1));
    await tester.pumpAndSettle();
    check(repo.stored!.defaults.stealth.notificationDisguise).isFalse();
  });

  testWidgets('StealthScreen timerDisplay selector persists', (tester) async {
    // Spec Q26: timerDisplay is an enum (normal / small / none),
    // surfaced via a PopupMenuButton in the settings screen.
    final repo = FakeSettingsRepository();
    await tester.pumpWidget(
      hostScreen(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const StealthScreen(),
      ),
    );
    await tester.pumpAndSettle();
    final list = find.descendant(
      of: find.byType(StealthScreen),
      matching: find.byType(Scrollable),
    );
    final tile = find.widgetWithText(ListTile, 'Timer display');
    await tester.dragUntilVisible(tile, list.first, const Offset(0, -100));
    await tester.tap(find.byType(PopupMenuButton<StealthTimerDisplay>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hide timer').last);
    await tester.pumpAndSettle();
    check(
      repo.stored!.defaults.stealth.timerDisplay,
    ).equals(StealthTimerDisplay.none);
  });

  testWidgets('StealthScreen sessionScreenStealth toggle persists', (
    tester,
  ) async {
    final repo = FakeSettingsRepository();
    await tester.pumpWidget(
      hostScreen(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const StealthScreen(),
      ),
    );
    await tester.pumpAndSettle();
    final tile = find.widgetWithText(
      SwitchListTile,
      'Strip branding on session screen',
    );
    final list = find.descendant(
      of: find.byType(StealthScreen),
      matching: find.byType(Scrollable),
    );
    await tester.dragUntilVisible(tile, list.first, const Offset(0, -100));
    // Default sessionScreenStealth is true; tapping flips it to false.
    await tester.tap(tile);
    await tester.pumpAndSettle();
    check(repo.stored!.defaults.stealth.sessionScreenStealth).isFalse();
  });
}
