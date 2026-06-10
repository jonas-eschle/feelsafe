/// Widget tests for [SettingsScreen].
///
/// Mirrors the pattern established in `test/features/home/home_screen_test.dart`:
/// a `_FakeSettingsController` subclasses the real controller, overrides
/// `build()` to return a canned [SettingsHubState], and exposes call
/// counters for interaction assertions.
///
/// Spec refs: 04 §Settings Screen (lines 1869–1974), 06-settings.md.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/domain/enums/app_theme_mode.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/features/settings/settings_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Fake controller
// ---------------------------------------------------------------------------

class _FakeSettingsController extends SettingsController {
  _FakeSettingsController(this._initial);

  final SettingsHubState _initial;

  int setThemeModeCalls = 0;
  AppThemeMode? lastThemeMode;

  int setLanguageCalls = 0;
  String? lastLanguageCode;

  int resetOnboardingCalls = 0;

  @override
  Future<SettingsHubState> build() async => _initial;

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    setThemeModeCalls++;
    lastThemeMode = mode;
    state = AsyncData(
      SettingsHubState(
        themeMode: mode,
        languageCode: _initial.languageCode,
        stealthEnabled: _initial.stealthEnabled,
        emergencyCallNumber: _initial.emergencyCallNumber,
        alarmDndOverride: _initial.alarmDndOverride,
        alarmGradualVolume: _initial.alarmGradualVolume,
        alarmGradualVolumeDurationSeconds:
            _initial.alarmGradualVolumeDurationSeconds,
      ),
    );
  }

  @override
  Future<void> setLanguage(String code) async {
    setLanguageCalls++;
    lastLanguageCode = code;
    state = AsyncData(
      SettingsHubState(
        themeMode: _initial.themeMode,
        languageCode: code,
        stealthEnabled: _initial.stealthEnabled,
        emergencyCallNumber: _initial.emergencyCallNumber,
        alarmDndOverride: _initial.alarmDndOverride,
        alarmGradualVolume: _initial.alarmGradualVolume,
        alarmGradualVolumeDurationSeconds:
            _initial.alarmGradualVolumeDurationSeconds,
      ),
    );
  }

  int setEmergencyCallNumberCalls = 0;
  String? lastEmergencyCallNumber;

  @override
  Future<void> setEmergencyCallNumber(String number) async {
    setEmergencyCallNumberCalls++;
    lastEmergencyCallNumber = number;
  }

  @override
  Future<void> resetOnboarding() async {
    resetOnboardingCalls++;
  }
}

// ---------------------------------------------------------------------------
// Factory helpers
// ---------------------------------------------------------------------------

SettingsHubState _defaultState({
  AppThemeMode themeMode = AppThemeMode.system,
  String languageCode = 'en',
  bool stealthEnabled = false,
  String emergencyCallNumber = '112',
  bool alarmDndOverride = false,
  bool alarmGradualVolume = false,
  int alarmGradualVolumeDurationSeconds = 5,
}) => SettingsHubState(
  themeMode: themeMode,
  languageCode: languageCode,
  stealthEnabled: stealthEnabled,
  emergencyCallNumber: emergencyCallNumber,
  alarmDndOverride: alarmDndOverride,
  alarmGradualVolume: alarmGradualVolume,
  alarmGradualVolumeDurationSeconds: alarmGradualVolumeDurationSeconds,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

/// Gives the test a viewport tall enough for the whole settings list to render
/// without scrolling, so rows near the bottom (e.g. "Redo onboarding") are
/// fully on-screen and hit-testable by `tap()`. The default 800×600 surface
/// leaves the last rows clipped at the scroll edge, where `scrollUntilVisible`
/// stops as soon as a row attaches (often only partly visible). Reset on
/// teardown.
void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Mounts [SettingsScreen] inside a minimal [GoRouter] whose destinations
/// are stub screens echoing `dest:<route name>`, so every `pushNamed` /
/// `goNamed` in the screen resolves and can be asserted on.
Future<GoRouter> _pumpWithRouter(
  WidgetTester tester, {
  required _FakeSettingsController fake,
}) async {
  const destinations = <(String, String)>[
    ('profile', RouteNames.profile),
    ('security', RouteNames.settingsSecurity),
    ('stealth', RouteNames.settingsStealth),
    ('modes', RouteNames.modes),
    ('distress-modes', RouteNames.distressModes),
    ('event-defaults', RouteNames.settingsEventDefaults),
    ('gps-logging', RouteNames.settingsGpsLogging),
    ('reminders', RouteNames.settingsReminderTemplates),
    ('notifications', RouteNames.settingsNotifications),
    ('history', RouteNames.settingsHistoryRetention),
    ('backup', RouteNames.settingsBackup),
    ('feedback', RouteNames.settingsFeedback),
    ('about', RouteNames.settingsAbout),
  ];
  final router = GoRouter(
    initialLocation: '/settings',
    routes: <RouteBase>[
      GoRoute(
        path: '/settings',
        name: RouteNames.settings,
        builder: (BuildContext _, GoRouterState _) => const SettingsScreen(),
        routes: <RouteBase>[
          for (final (path, name) in destinations)
            GoRoute(
              path: path,
              name: name,
              builder: (BuildContext _, GoRouterState state) =>
                  Scaffold(body: Text('dest:${state.name}')),
            ),
        ],
      ),
      GoRoute(
        path: '/onboarding',
        name: RouteNames.onboarding,
        builder: (BuildContext _, GoRouterState state) =>
            Scaffold(body: Text('dest:${state.name}')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        settingsControllerProvider.overrideWith(() => fake),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
          useMaterial3: true,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  // ── AppBar ────────────────────────────────────────────────────────────────

  group('SettingsScreen — AppBar', () {
    testWidgets('renders Settings title in AppBar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      expect(find.text(l10n.homeMenuSettings), findsWidgets);
    });
  });

  // ── Async states ──────────────────────────────────────────────────────────

  group('SettingsScreen — async states', () {
    testWidgets('shows CircularProgressIndicator while loading', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
        settle: false,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders body once AsyncValue resolves', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error message on AsyncError', (
      WidgetTester tester,
    ) async {
      // Override build() to throw so the provider surfaces an AsyncError.
      final controller = _AsyncErrorController();
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(() => controller),
        ],
      );
      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });

  // ── General section: Theme ─────────────────────────────────────────────

  group('SettingsScreen — Theme tile', () {
    testWidgets('renders General section header', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      // _SectionHeader renders text.toUpperCase(); the header is at the top
      // so it is visible without scrolling.
      expect(
        find.text(l10n.settingsGeneralHeader.toUpperCase()),
        findsOneWidget,
      );
    });

    testWidgets('renders three theme chips (Light / Dark / System)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      expect(find.text(l10n.settingsThemeLight), findsOneWidget);
      expect(find.text(l10n.settingsThemeDark), findsOneWidget);
      expect(find.text(l10n.settingsThemeSystem), findsOneWidget);
    });

    testWidgets('System chip is selected when themeMode is system', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      final systemChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text(l10n.settingsThemeSystem),
          matching: find.byType(ChoiceChip),
        ),
      );
      check(systemChip.selected).isTrue();
      final lightChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text(l10n.settingsThemeLight),
          matching: find.byType(ChoiceChip),
        ),
      );
      check(lightChip.selected).isFalse();
    });

    testWidgets('tapping Light chip calls setThemeMode(light)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSettingsController(_defaultState());
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(() => fake),
        ],
      );
      await tester.tap(find.text(l10n.settingsThemeLight));
      await tester.pumpAndSettle();
      check(fake.setThemeModeCalls).equals(1);
      check(fake.lastThemeMode).equals(AppThemeMode.light);
    });

    testWidgets('tapping Dark chip calls setThemeMode(dark)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSettingsController(
        _defaultState(themeMode: AppThemeMode.light),
      );
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(() => fake),
        ],
      );
      await tester.tap(find.text(l10n.settingsThemeDark));
      await tester.pumpAndSettle();
      check(fake.setThemeModeCalls).equals(1);
      check(fake.lastThemeMode).equals(AppThemeMode.dark);
    });
  });

  // ── General section: Language ─────────────────────────────────────────

  group('SettingsScreen — Language tile', () {
    testWidgets('renders language tile with current code', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState(languageCode: 'de')),
          ),
        ],
      );
      expect(find.text(l10n.settingsLanguageLabel), findsOneWidget);
      expect(find.text('de'), findsOneWidget);
    });

    testWidgets('tapping language tile opens bottom sheet with language list', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      // Tap the Language ListTile — not inside a ChoiceChip.
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.text(l10n.settingsLanguageLabel));
      await tester.pumpAndSettle();
      // Bottom sheet should show at least 'en' and 'de' language codes.
      expect(find.text('en'), findsWidgets);
      expect(find.text('de'), findsOneWidget);
    });

    testWidgets('selecting a language from bottom sheet calls setLanguage', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSettingsController(_defaultState());
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(() => fake),
        ],
      );
      await tester.tap(find.text(l10n.settingsLanguageLabel));
      await tester.pumpAndSettle();
      // Tap 'fr' in the bottom sheet list.
      await tester.tap(find.text('fr'));
      await tester.pumpAndSettle();
      check(fake.setLanguageCalls).equals(1);
      check(fake.lastLanguageCode).equals('fr');
    });
  });

  // ── Configuration rows ────────────────────────────────────────────────

  group('SettingsScreen — Configuration section rows', () {
    testWidgets('renders Configuration section header', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      expect(
        find.text(
          l10n.settingsConfigurationHeader.toUpperCase(),
          skipOffstage: false,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Security row with subtitle', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      expect(find.text(l10n.settingsSecurityRow), findsOneWidget);
      expect(find.text(l10n.settingsSecuritySubtitle), findsOneWidget);
    });

    testWidgets('renders Stealth row with OFF summary', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      expect(find.text(l10n.settingsStealthRow), findsOneWidget);
      expect(find.text(l10n.settingsStealthSummaryOff), findsOneWidget);
    });

    testWidgets('renders Stealth row with ON summary when stealth enabled', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState(stealthEnabled: true)),
          ),
        ],
      );
      expect(find.text(l10n.settingsStealthSummaryOn), findsOneWidget);
    });

    testWidgets('renders all core configuration rows', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      // Use skipOffstage: false because the ListView may not render all rows
      // within the test viewport — rows below the fold are built lazily but
      // still exist in the widget tree.
      final rowLabels = <String>[
        l10n.settingsProfileRow,
        l10n.settingsModesRow,
        l10n.settingsDistressModesRow,
        l10n.settingsEventDefaultsRow,
        l10n.settingsGpsLoggingRow,
        l10n.settingsRemindersRow,
        l10n.settingsNotificationsRow,
      ];
      for (final label in rowLabels) {
        expect(
          find.text(label, skipOffstage: false),
          findsOneWidget,
          reason: 'Expected row "$label" in configuration section',
        );
      }
    });
  });

  // ── Configuration row navigation ──────────────────────────────────────
  //
  // The test harness uses a bare MaterialApp (no GoRouter). Tapping a row
  // that calls context.pushNamed would throw "No GoRouter found in context".
  // Instead, we assert that:
  //   (a) the SettingsTile is present in the widget tree (skipOffstage: false),
  //   (b) its onTap is non-null (the tile is interactive).
  //
  // This proves the screen wires each row correctly without requiring a
  // full router scaffold in unit widget tests.

  group('SettingsScreen — Configuration row navigation', () {
    testWidgets('Security row has non-null onTap wired', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      final tile = tester.widget<ListTile>(
        find
            .ancestor(
              of: find.text(l10n.settingsSecurityRow, skipOffstage: false),
              matching: find.byType(ListTile),
            )
            .first,
      );
      check(tile.onTap).isNotNull();
    });

    testWidgets('Modes row has non-null onTap wired', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      final tile = tester.widget<ListTile>(
        find
            .ancestor(
              of: find.text(l10n.settingsModesRow, skipOffstage: false),
              matching: find.byType(ListTile),
            )
            .first,
      );
      check(tile.onTap).isNotNull();
    });

    testWidgets('Distress Modes row has non-null onTap wired', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      final tile = tester.widget<ListTile>(
        find
            .ancestor(
              of: find.text(l10n.settingsDistressModesRow, skipOffstage: false),
              matching: find.byType(ListTile),
            )
            .first,
      );
      check(tile.onTap).isNotNull();
    });
  });

  // ── App section ───────────────────────────────────────────────────────

  group('SettingsScreen — App section', () {
    testWidgets('renders App section header', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      // _SectionHeader renders text.toUpperCase(). The App section is below
      // the fold — scroll until the header becomes visible.
      await tester.scrollUntilVisible(
        find.text(l10n.settingsAppHeader.toUpperCase()),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(l10n.settingsAppHeader.toUpperCase()), findsOneWidget);
    });

    testWidgets('renders About, Feedback, Backup, History, OSS rows', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      // ListView(children:) uses a SliverList that lazily builds items.
      // Scroll the list to make each row visible before asserting.
      final scrollable = find.byType(Scrollable).first;
      final appRows = <String>[
        l10n.settingsAboutRow,
        l10n.settingsFeedbackRow,
        l10n.settingsBackupRow,
        l10n.settingsHistoryRetentionRow,
        l10n.settingsOssLicenses,
      ];
      for (final label in appRows) {
        await tester.scrollUntilVisible(
          find.text(label),
          200,
          scrollable: scrollable,
        );
        expect(
          find.text(label),
          findsOneWidget,
          reason: 'Expected App row "$label"',
        );
      }
    });

    testWidgets('renders Redo Onboarding tile', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      await tester.scrollUntilVisible(
        find.text(l10n.settingsRedoOnboarding),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(l10n.settingsRedoOnboarding), findsOneWidget);
    });
  });

  // ── Redo Onboarding flow ──────────────────────────────────────────────

  group('SettingsScreen — Redo Onboarding', () {
    testWidgets('tapping Redo Onboarding shows confirmation dialog', (
      WidgetTester tester,
    ) async {
      _useTallViewport(tester);
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      await tester.scrollUntilVisible(
        find.text(l10n.settingsRedoOnboarding),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(l10n.settingsRedoOnboarding));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('confirmation dialog shows Confirm and Cancel buttons', (
      WidgetTester tester,
    ) async {
      _useTallViewport(tester);
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      await tester.scrollUntilVisible(
        find.text(l10n.settingsRedoOnboarding),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(l10n.settingsRedoOnboarding));
      await tester.pumpAndSettle();
      // Verify the AlertDialog contains both action buttons.
      expect(find.text(l10n.commonConfirm), findsOneWidget);
      expect(find.text(l10n.commonCancel), findsOneWidget);
      expect(find.text(l10n.settingsRedoOnboardingConfirm), findsOneWidget);
    });

    testWidgets('resetOnboarding controller method increments call counter', (
      WidgetTester tester,
    ) async {
      // This test exercises the controller directly via the provider to
      // confirm the fake wiring is correct, without triggering the
      // post-navigation context.goNamed that requires GoRouter.
      final fake = _FakeSettingsController(_defaultState());
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(() => fake),
        ],
      );
      await fake.resetOnboarding();
      check(fake.resetOnboardingCalls).equals(1);
    });

    testWidgets(
      'cancelling Redo Onboarding dialog does not call resetOnboarding',
      (WidgetTester tester) async {
        _useTallViewport(tester);
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSettingsController(_defaultState());
        await pumpScreen(
          tester,
          const SettingsScreen(),
          overrides: <Override>[
            settingsControllerProvider.overrideWith(() => fake),
          ],
        );
        await tester.scrollUntilVisible(
          find.text(l10n.settingsRedoOnboarding),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text(l10n.settingsRedoOnboarding));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.commonCancel));
        await tester.pumpAndSettle();
        check(fake.resetOnboardingCalls).equals(0);
      },
    );
  });

  // ── RTL smoke ─────────────────────────────────────────────────────────

  group('SettingsScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
        locale: const Locale('ar'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Dark mode smoke ───────────────────────────────────────────────────

  group('SettingsScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // ── Accessibility ─────────────────────────────────────────────────────

  group('SettingsScreen — Accessibility', () {
    testWidgets('SettingsTile rows include chevron trailing icon', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      // Each SettingsTile renders a chevron_right; at least one must be found.
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    testWidgets('Theme label tile uses leading icon', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      expect(find.byIcon(Icons.brightness_6), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
    });
  });

  // ── Emergency-number dialog (spec 06 §Emergency Number) ───────────────────

  group('SettingsScreen — emergency-number dialog', () {
    Future<_FakeSettingsController> openDialog(
      WidgetTester tester, {
      String current = '112',
    }) async {
      _useTallViewport(tester);
      final controller = _FakeSettingsController(
        _defaultState(emergencyCallNumber: current),
      );
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(() => controller),
        ],
      );
      await tester.tap(find.text(l10n.settingsEmergencyNumberLabel));
      await tester.pumpAndSettle();
      return controller;
    }

    testWidgets('opens an editable dialog pre-filled with the current value', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await openDialog(tester, current: '911');
      // The dialog is open (its field-label is unique to the dialog).
      expect(find.text(l10n.settingsEmergencyNumberFieldLabel), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      // The text field shows the current value.
      expect(find.widgetWithText(TextField, '911'), findsOneWidget);
    });

    testWidgets('Save persists the trimmed typed value', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final controller = await openDialog(tester);
      await tester.enterText(find.byType(TextField), '999');
      await tester.pump();
      await tester.tap(find.text(l10n.commonSave));
      await tester.pumpAndSettle();
      check(controller.setEmergencyCallNumberCalls).equals(1);
      check(controller.lastEmergencyCallNumber).equals('999');
    });

    testWidgets('an empty field disables Save (empty blocks)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final controller = await openDialog(tester);
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      // The Save FilledButton is disabled (onPressed == null).
      final FilledButton save = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text(l10n.commonSave),
          matching: find.byType(FilledButton),
        ),
      );
      check(save.onPressed).isNull();
      // Tapping it is a no-op — the setter is never called.
      await tester.tap(find.text(l10n.commonSave));
      await tester.pumpAndSettle();
      check(controller.setEmergencyCallNumberCalls).equals(0);
    });

    testWidgets('a too-long number shows the regular-number warning but '
        'still allows Save', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final controller = await openDialog(tester);
      await tester.enterText(find.byType(TextField), '5551234567');
      await tester.pump();
      expect(find.text(l10n.phoneWarnLooksLikeRegular), findsOneWidget);
      // Non-empty → Save still enabled (the length warning is non-blocking).
      await tester.tap(find.text(l10n.commonSave));
      await tester.pumpAndSettle();
      check(controller.setEmergencyCallNumberCalls).equals(1);
      check(controller.lastEmergencyCallNumber).equals('5551234567');
    });

    testWidgets('tapping a preset fills the field', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final controller = await openDialog(tester);
      // Tap the "Australia" preset row → field becomes 000.
      await tester.tap(find.text('Australia'));
      await tester.pump();
      expect(find.widgetWithText(TextField, '000'), findsOneWidget);
      await tester.tap(find.text(l10n.commonSave));
      await tester.pumpAndSettle();
      check(controller.lastEmergencyCallNumber).equals('000');
    });

    testWidgets('Cancel dismisses the dialog without persisting anything', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final controller = await openDialog(tester, current: '911');
      // Even a typed value is discarded on Cancel.
      await tester.enterText(find.byType(TextField), '999');
      await tester.pump();
      await tester.tap(find.text(l10n.commonCancel));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      check(controller.setEmergencyCallNumberCalls).equals(0);
    });
  });

  // ── Row navigation through a real GoRouter ─────────────────────────────────

  group('SettingsScreen — row navigation (GoRouter)', () {
    testWidgets('every configuration and app row pushes its named route', (
      WidgetTester tester,
    ) async {
      _useTallViewport(tester);
      final l10n = await loadL10n(const Locale('en'));
      final router = await _pumpWithRouter(
        tester,
        fake: _FakeSettingsController(_defaultState()),
      );
      final cases = <(String, String)>[
        (l10n.settingsProfileRow, RouteNames.profile),
        (l10n.settingsSecurityRow, RouteNames.settingsSecurity),
        (l10n.settingsStealthRow, RouteNames.settingsStealth),
        (l10n.settingsModesRow, RouteNames.modes),
        (l10n.settingsDistressModesRow, RouteNames.distressModes),
        (l10n.settingsEventDefaultsRow, RouteNames.settingsEventDefaults),
        (l10n.settingsGpsLoggingRow, RouteNames.settingsGpsLogging),
        (l10n.settingsRemindersRow, RouteNames.settingsReminderTemplates),
        (l10n.settingsNotificationsRow, RouteNames.settingsNotifications),
        (l10n.settingsHistoryRetentionRow, RouteNames.settingsHistoryRetention),
        (l10n.settingsBackupRow, RouteNames.settingsBackup),
        (l10n.settingsFeedbackRow, RouteNames.settingsFeedback),
        (l10n.settingsAboutRow, RouteNames.settingsAbout),
      ];
      for (final (label, routeName) in cases) {
        await tester.scrollUntilVisible(
          find.text(label),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(
          find.text('dest:$routeName'),
          findsOneWidget,
          reason: 'tapping "$label" must push $routeName',
        );
        router.pop();
        await tester.pumpAndSettle();
      }
    });

    testWidgets(
      'confirming Redo Onboarding resets the flag and lands on onboarding',
      (WidgetTester tester) async {
        _useTallViewport(tester);
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSettingsController(_defaultState());
        await _pumpWithRouter(tester, fake: fake);
        await tester.scrollUntilVisible(
          find.text(l10n.settingsRedoOnboarding),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text(l10n.settingsRedoOnboarding));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.commonConfirm));
        await tester.pumpAndSettle();
        check(fake.resetOnboardingCalls).equals(1);
        expect(find.text('dest:${RouteNames.onboarding}'), findsOneWidget);
      },
    );
  });

  // ── OSS licenses ───────────────────────────────────────────────────────────

  group('SettingsScreen — OSS licenses', () {
    testWidgets('tapping the licenses row opens the LicensePage', (
      WidgetTester tester,
    ) async {
      _useTallViewport(tester);
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(_defaultState()),
          ),
        ],
      );
      await tester.scrollUntilVisible(
        find.text(l10n.settingsOssLicenses),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(l10n.settingsOssLicenses));
      // LicensePage streams licenses; pump fixed frames instead of settling.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(LicensePage), findsOneWidget);
      expect(find.text('Guardian Angela'), findsWidgets);
    });
  });
}

// ---------------------------------------------------------------------------
// Helper: controller whose build() always throws, forcing AsyncError
// ---------------------------------------------------------------------------

class _AsyncErrorController extends SettingsController {
  @override
  Future<SettingsHubState> build() async =>
      throw Exception('settings load failed');
}
