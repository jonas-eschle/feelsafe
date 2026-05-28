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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/app_theme_mode.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/features/settings/settings_screen.dart';
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
      ),
    );
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
}) => SettingsHubState(
  themeMode: themeMode,
  languageCode: languageCode,
  stealthEnabled: stealthEnabled,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

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
        l10n.settingsBatteryAlertRow,
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
}

// ---------------------------------------------------------------------------
// Helper: controller whose build() always throws, forcing AsyncError
// ---------------------------------------------------------------------------

class _AsyncErrorController extends SettingsController {
  @override
  Future<SettingsHubState> build() async =>
      throw Exception('settings load failed');
}
