/// Shared widget-test scaffolding for the Phase 6 screen cohort.
///
/// Provides a single [pumpScreen] helper that every widget test under
/// `test/features/<feature>/` uses to mount a screen inside a
/// `ProviderScope` + `MaterialApp` + the canonical localization +
/// theme stack. Tests pass per-screen Riverpod overrides to inject
/// fake controllers or fake repositories — see `home_screen_test.dart`
/// for the reference pattern.
library;

import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Pumps [screen] inside the canonical widget-test harness.
///
/// The harness mirrors `GuardianAngelaApp`'s shell minus GoRouter: a
/// `MaterialApp` with `AppLocalizations.delegate` + locale-aware text
/// direction, a Material 3 theme, and a `ProviderScope` that accepts
/// per-test [overrides] for controller / service / repository
/// providers.
///
/// [locale] defaults to `Locale('en')`; pass `Locale('ar')` (RTL) to
/// exercise RTL-specific layouts.
///
/// [themeMode] defaults to [ThemeMode.light]; pass [ThemeMode.dark]
/// for dark-mode tests.
///
/// [platform] overrides `ThemeData.platform` for both the light and dark
/// themes. Defaults to null (Flutter's default for the host, normally
/// Android in the test VM). Pass [TargetPlatform.iOS] to exercise
/// platform-gated UI such as `ensureNotificationPermission`'s iOS no-op
/// branch (which reads `Theme.of(context).platform`).
///
/// [navigatorObservers] are forwarded to the inner `MaterialApp` so
/// tests can assert on push / pop transitions.
///
/// After the pump the helper calls `tester.pumpAndSettle()` once so
/// initial async providers resolve before assertions run. Pass
/// `settle: false` to skip the settle call (useful when asserting
/// on the loading state of an AsyncValue).
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  List<Override> overrides = const <Override>[],
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  TargetPlatform? platform,
  List<NavigatorObserver> navigatorObservers = const <NavigatorObserver>[],
  bool settle = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        themeMode: themeMode,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
          useMaterial3: true,
          platform: platform,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF131118),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          platform: platform,
        ),
        navigatorObservers: navigatorObservers,
        home: screen,
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  }
}

/// Convenience: returns the resolved [AppLocalizations] for [locale].
///
/// Useful when a widget test needs to assert on the exact translated
/// string for the locale under test without re-deriving from the
/// `BuildContext`.
Future<AppLocalizations> loadL10n(Locale locale) async {
  return AppLocalizations.delegate.load(locale);
}
