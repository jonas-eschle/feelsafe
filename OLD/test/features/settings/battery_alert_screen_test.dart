/// Smoke tests for [BatteryAlertScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/settings/battery_alert_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('BatteryAlertScreen renders without throwing', (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: [
        batteryAlertRepositoryProvider
            .overrideWithValue(FakeBatteryAlertRepository()),
      ],
      child: const BatteryAlertScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(BatteryAlertScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('BatteryAlertScreen shows enable toggle', (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: [
        batteryAlertRepositoryProvider
            .overrideWithValue(FakeBatteryAlertRepository()),
      ],
      child: const BatteryAlertScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(SwitchListTile).evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('BatteryAlertScreen enabling the toggle persists the flag',
      (tester) async {
    final repo = FakeBatteryAlertRepository();
    await tester.pumpWidget(hostScreen(
      overrides: [
        batteryAlertRepositoryProvider.overrideWithValue(repo),
      ],
      child: const BatteryAlertScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    // The controller calls enable() which persists a default config.
    check(repo.stored).isNotNull();
  });

  testWidgets('BatteryAlertScreen disabling the toggle persists the flag',
      (tester) async {
    final repo = FakeBatteryAlertRepository(
      const BatteryAlertConfig(enabled: true),
    );
    await tester.pumpWidget(hostScreen(
      overrides: [
        batteryAlertRepositoryProvider.overrideWithValue(repo),
      ],
      child: const BatteryAlertScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    check(repo.stored!.enabled).isFalse();
  });

  testWidgets('BatteryAlertScreen threshold slider updates config',
      (tester) async {
    final repo = FakeBatteryAlertRepository(
      const BatteryAlertConfig(enabled: true, thresholdPercent: 20),
    );
    await tester.pumpWidget(hostScreen(
      overrides: [
        batteryAlertRepositoryProvider.overrideWithValue(repo),
      ],
      child: const BatteryAlertScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Slider), const Offset(200, 0));
    await tester.pumpAndSettle();
    check(repo.stored!.thresholdPercent).isGreaterThan(20);
  });
}
