/// Smoke tests for [BatteryAlertScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
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
}
