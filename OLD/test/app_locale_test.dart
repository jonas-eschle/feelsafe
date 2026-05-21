/// Coverage for `lib/app.dart` — specifically the
/// `locale: locale == null ? null : Locale(locale)` branch that only
/// fires when the persisted `AppSettings.languageCode` is non-null.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/app.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';

import 'features/fake_repositories.dart';

void main() {
  testWidgets(
    'MaterialApp.router receives non-null Locale when languageCode is set',
    (tester) async {
      final seeded = FakeSettingsRepository(
        const AppSettings(
          languageCode: 'de',
          themeMode: AppThemeMode.dark,
          defaults: AppDefaults(),
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [settingsRepositoryProvider.overrideWithValue(seeded)],
          child: const GuardianAngelaApp(),
        ),
      );
      await tester.pump();
      await tester.pump();

      // Locate the MaterialApp built by GuardianAngelaApp and confirm
      // the locale plumbing on line 33 executed.
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      check(app.locale).equals(const Locale('de'));
      check(app.themeMode).equals(ThemeMode.dark);
    },
  );

  testWidgets(
    'MaterialApp.router defaults Locale to en when AppSettings default',
    (tester) async {
      // AppSettings defaults `languageCode` to 'en', exercising the
      // non-null branch via the default path.
      final seeded = FakeSettingsRepository(
        const AppSettings(defaults: AppDefaults()),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [settingsRepositoryProvider.overrideWithValue(seeded)],
          child: const GuardianAngelaApp(),
        ),
      );
      await tester.pump();
      await tester.pump();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      check(app.locale).equals(const Locale('en'));
      check(app.themeMode).equals(ThemeMode.system);
    },
  );

  testWidgets('Resolves AppThemeMode.light correctly', (tester) async {
    final seeded = FakeSettingsRepository(
      const AppSettings(themeMode: AppThemeMode.light, defaults: AppDefaults()),
    );
    // Exercise the `key:` parameter branch of the const ctor.
    const appKey = Key('ga-app-under-test');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsRepositoryProvider.overrideWithValue(seeded)],
        child: const GuardianAngelaApp(key: appKey),
      ),
    );
    await tester.pump();
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    check(app.themeMode).equals(ThemeMode.light);
    check(find.byKey(appKey).evaluate().isNotEmpty).isTrue();
  });
}
