/// Smoke tests for [GpsLoggingScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';
import 'package:guardianangela/features/settings/gps_logging_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('GpsLoggingScreen renders without throwing', (tester) async {
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
        ],
        child: const GpsLoggingScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(GpsLoggingScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('GpsLoggingScreen shows enable toggle', (tester) async {
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
        ],
        child: const GpsLoggingScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(SwitchListTile).evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('GpsLoggingScreen enable toggle persists value', (tester) async {
    final repo = FakeSettingsRepository();
    await tester.pumpWidget(
      hostScreen(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const GpsLoggingScreen(),
      ),
    );
    await tester.pumpAndSettle();
    // Default is enabled=true; tapping flips to false.
    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();
    check(repo.stored!.defaults.gpsLogging.enabled).isFalse();
  });

  testWidgets('GpsLoggingScreen interval slider updates config', (
    tester,
  ) async {
    final repo = FakeSettingsRepository();
    await tester.pumpWidget(
      hostScreen(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const GpsLoggingScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Slider).first, const Offset(200, 0));
    await tester.pumpAndSettle();
    check(repo.stored).isNotNull();
  });

  testWidgets('GpsLoggingScreen accuracy dropdown switches to high', (
    tester,
  ) async {
    final repo = FakeSettingsRepository();
    await tester.pumpWidget(
      hostScreen(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const GpsLoggingScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<GpsAccuracy>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High').last);
    await tester.pumpAndSettle();
    check(repo.stored!.defaults.gpsLogging.accuracy).equals(GpsAccuracy.high);
  });

  testWidgets('GpsLoggingScreen includeInSms switch persists', (tester) async {
    final repo = FakeSettingsRepository();
    await tester.pumpWidget(
      hostScreen(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const GpsLoggingScreen(),
      ),
    );
    await tester.pumpAndSettle();
    // Default includeInSms is true; tapping flips to false.
    await tester.tap(find.byType(SwitchListTile).at(1));
    await tester.pumpAndSettle();
    check(repo.stored!.defaults.gpsLogging.includeInSms).isFalse();
  });

  testWidgets('GpsLoggingScreen retention slider updates days', (tester) async {
    final repo = FakeSettingsRepository();
    await tester.pumpWidget(
      hostScreen(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const GpsLoggingScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Slider).at(1), const Offset(200, 0));
    await tester.pumpAndSettle();
    check(repo.stored).isNotNull();
  });
}
