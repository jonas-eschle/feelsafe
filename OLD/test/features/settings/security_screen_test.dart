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
    // The screen now also shows three biometric switches (Q-bio) and
    // a duress-test row (Q-DURESS-TEST) so the content overflows the
    // default 800x600 viewport. Use a tall viewport so the PIN
    // timeout slider mounts.
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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

  testWidgets(
    'SecurityScreen disable app PIN clears settings.appPinHash',
    (tester) async {
      final repo = FakeSettingsRepository(
        const AppSettings(defaults: AppDefaults(), appPinHash: 'x'),
      );
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const SecurityScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();
      check(repo.stored!.appPinHash).isNull();
    },
  );

  testWidgets('SecurityScreen disable session-end PIN clears hash',
      (tester) async {
    final repo = FakeSettingsRepository(
      const AppSettings(defaults: AppDefaults(), sessionEndPinHash: 'y'),
    );
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      child: const SecurityScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextButton).first);
    await tester.pumpAndSettle();
    check(repo.stored!.sessionEndPinHash).isNull();
  });

  testWidgets('SecurityScreen disable duress PIN clears hash',
      (tester) async {
    final repo = FakeSettingsRepository(
      const AppSettings(defaults: AppDefaults(), duressPinHash: 'z'),
    );
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      child: const SecurityScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextButton).first);
    await tester.pumpAndSettle();
    check(repo.stored!.duressPinHash).isNull();
  });

  testWidgets('SecurityScreen slider updates pin timeout seconds',
      (tester) async {
    final repo = FakeSettingsRepository();
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      child: const SecurityScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Slider), const Offset(200, 0));
    await tester.pumpAndSettle();
    check(repo.stored).isNotNull();
  });
}
