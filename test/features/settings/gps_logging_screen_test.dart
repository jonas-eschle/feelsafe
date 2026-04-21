/// Smoke tests for [GpsLoggingScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/settings/gps_logging_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('GpsLoggingScreen renders without throwing', (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: [
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
      ],
      child: const GpsLoggingScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(GpsLoggingScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('GpsLoggingScreen shows enable toggle', (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: [
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
      ],
      child: const GpsLoggingScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(SwitchListTile).evaluate().length).isGreaterOrEqual(1);
  });
}
