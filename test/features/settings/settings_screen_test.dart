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
}
