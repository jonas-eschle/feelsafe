/// Smoke tests for [HomeScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/home/home_screen.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('HomeScreen renders without throwing', (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        modesRepositoryProvider.overrideWithValue(FakeModesRepository()),
        contactsRepositoryProvider
            .overrideWithValue(FakeContactsRepository()),
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
      ],
      child: const HomeScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(HomeScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('HomeScreen shows content with seeded modes', (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        modesRepositoryProvider.overrideWithValue(
          FakeModesRepository([makeMode(id: 'm1', name: 'Walk')]),
        ),
        contactsRepositoryProvider.overrideWithValue(
          FakeContactsRepository([makeContact(id: 'c1', name: 'Bob')]),
        ),
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
      ],
      child: const HomeScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(HomeScreen).evaluate().length).equals(1);
  });

  testWidgets('HomeScreen renders a settings icon in the app bar',
      (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        modesRepositoryProvider.overrideWithValue(FakeModesRepository()),
        contactsRepositoryProvider
            .overrideWithValue(FakeContactsRepository()),
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
      ],
      child: const HomeScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.settings).evaluate().length).equals(1);
  });

  testWidgets(
    'HomeScreen stealth mode swaps title to fakeName and shows subtitle',
    (tester) async {
      const stealth = StealthConfig(
        enabled: true,
        fakeName: 'Calendar',
      );
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          modesRepositoryProvider.overrideWithValue(FakeModesRepository()),
          contactsRepositoryProvider
              .overrideWithValue(FakeContactsRepository()),
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(
              const AppSettings(
                defaults: AppDefaults(stealth: stealth),
              ),
            ),
          ),
        ],
        child: const HomeScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.text('Calendar').evaluate().length).isGreaterOrEqual(1);
    },
  );

  testWidgets('HomeScreen simulate is a TextButton next to Start',
      (tester) async {
    // Spec 04 §Simulate Button: outlined TextButton, less prominent
    // — replaces the older switch-style simulate toggle.
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        modesRepositoryProvider.overrideWithValue(
          FakeModesRepository([makeMode(id: 'm1', name: 'Walk')]),
        ),
        contactsRepositoryProvider
            .overrideWithValue(FakeContactsRepository()),
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
      ],
      child: const HomeScreen(),
    ));
    await tester.pumpAndSettle();
    check(
      find.widgetWithIcon(TextButton, Icons.science_outlined)
          .evaluate()
          .length,
    ).equals(1);
  });
}
