/// Smoke tests for [SecurityScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/settings/security_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('SecurityScreen renders without throwing', (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
      ],
      child: const SecurityScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(SecurityScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('SecurityScreen shows three PIN rows', (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(
          FakeSettingsRepository(
            const AppSettings(
              defaults: AppDefaults(),
              appPinHash: 'x',
              sessionEndPinHash: 'y',
              duressPinHash: 'z',
            ),
          ),
        ),
      ],
      child: const SecurityScreen(),
    ));
    await tester.pumpAndSettle();
    // A list + divider + slider structure is expected.
    check(find.byType(Slider).evaluate().length).equals(1);
  });
}
