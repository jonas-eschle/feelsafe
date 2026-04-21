/// Smoke tests for [StealthScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/settings/stealth_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('StealthScreen renders without throwing', (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: [
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
      ],
      child: const StealthScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(StealthScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('StealthScreen shows toggles', (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: [
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
      ],
      child: const StealthScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(SwitchListTile).evaluate().length).isGreaterThan(0);
  });
}
