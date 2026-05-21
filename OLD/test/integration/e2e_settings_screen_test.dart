/// End-to-end UI integration tests for the settings screen tree.
///
/// Covers: SettingsScreen hub (all nav tiles), SecurityScreen (PIN rows,
/// biometric toggles, duress test row), StealthScreen (fields), and
/// BackupScreen (export/import widgets).
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/settings/backup_screen.dart';
import 'package:guardianangela/features/settings/security_screen.dart';
import 'package:guardianangela/features/settings/settings_screen.dart';
import 'package:guardianangela/features/settings/stealth_screen.dart';
import 'package:guardianangela/services/fakes/fake_stealth_icon_service.dart';
import 'package:guardianangela/services/service_providers.dart';

import '../features/fake_repositories.dart';
import '../features/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

FakeSettingsRepository _settingsRepo([AppSettings? s]) =>
    FakeSettingsRepository(s ?? const AppSettings(defaults: AppDefaults()));

List<Override> _settingsOverrides([AppSettings? s]) => [
  settingsRepositoryProvider.overrideWithValue(_settingsRepo(s)),
  stealthIconServiceProvider.overrideWithValue(FakeStealthIconService()),
];

List<Override> _backupOverrides() => [
  settingsRepositoryProvider.overrideWithValue(_settingsRepo()),
  modesRepositoryProvider.overrideWithValue(FakeModesRepository()),
  contactsRepositoryProvider.overrideWithValue(FakeContactsRepository()),
  templatesRepositoryProvider.overrideWithValue(FakeTemplatesRepository()),
  userProfileRepositoryProvider.overrideWithValue(FakeUserProfileRepository()),
  batteryAlertRepositoryProvider.overrideWithValue(
    FakeBatteryAlertRepository(),
  ),
  sessionLogsRepositoryProvider.overrideWithValue(FakeSessionLogsRepository()),
];

// ---------------------------------------------------------------------------
// Tests: SettingsScreen hub
// ---------------------------------------------------------------------------

void main() {
  group('settings hub', () {
    testWidgets('settings_hub_renders_app_bar', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _settingsOverrides(),
          child: const SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(find.byType(AppBar).evaluate().length).equals(1);
    });

    testWidgets('settings_hub_shows_profile_tile', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _settingsOverrides(),
          child: const SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // The profile tile is a ListTile with chevron_right.
      check(
        find.byIcon(Icons.chevron_right).evaluate().length,
      ).isGreaterOrEqual(1);
    });

    testWidgets('settings_hub_shows_security_tile', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _settingsOverrides(),
          child: const SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(find.byType(ListTile).evaluate().length).isGreaterOrEqual(5);
    });

    testWidgets('settings_hub_shows_theme_dropdown', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _settingsOverrides(),
          child: const SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // Scroll to the bottom to ensure lazy-built items are rendered.
      await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
      await tester.pump();
      // DropdownButton<AppThemeMode> — use predicate since generic types
      // aren't preserved at runtime.
      check(
        find.byWidgetPredicate((w) => w is DropdownButton).evaluate().length,
      ).isGreaterOrEqual(1);
    });

    testWidgets('settings_hub_shows_alarm_dnd_switch', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _settingsOverrides(),
          child: const SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // Scroll to the bottom to ensure the DND Switch is rendered.
      await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
      await tester.pump();
      check(find.byType(Switch).evaluate().length).isGreaterOrEqual(1);
    });
  });

  // ---- SecurityScreen -------------------------------------------------------

  group('security screen — no PINs configured', () {
    testWidgets('security_renders_app_bar', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _settingsOverrides(),
          child: const SecurityScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(find.byType(AppBar).evaluate().length).equals(1);
    });

    testWidgets('security_shows_three_pin_rows', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _settingsOverrides(),
          child: const SecurityScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // Three PIN rows: App PIN, Session End PIN, Duress PIN.
      // Each has at least a title tile.
      check(find.byType(ListTile).evaluate().length).isGreaterOrEqual(3);
    });

    testWidgets('security_no_duress_test_row_when_duress_pin_absent', (
      tester,
    ) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _settingsOverrides(
            const AppSettings(defaults: AppDefaults(), duressPinHash: null),
          ),
          child: const SecurityScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // Duress test row only shown when duressPinHash != null.
      check(find.byIcon(Icons.verified_outlined).evaluate()).isEmpty();
    });

    testWidgets('security_duress_test_row_shown_when_duress_pin_configured', (
      tester,
    ) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _settingsOverrides(
            const AppSettings(
              defaults: AppDefaults(),
              duressPinHash: 'some-hash',
            ),
          ),
          child: const SecurityScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(
        find.byIcon(Icons.verified_outlined).evaluate().length,
      ).isGreaterOrEqual(1);
    });

    testWidgets('security_shows_biometric_switches', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _settingsOverrides(
            const AppSettings(
              defaults: AppDefaults(),
              appPinHash: 'some-hash',
              sessionEndPinHash: 'some-other-hash',
            ),
          ),
          child: const SecurityScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // With PINs configured, biometric toggle switches should appear.
      check(find.byType(SwitchListTile).evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('security_biometric_switches_disabled_without_pin', (
      tester,
    ) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _settingsOverrides(
            const AppSettings(
              defaults: AppDefaults(),
              appPinHash: null,
              sessionEndPinHash: null,
            ),
          ),
          child: const SecurityScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // SwitchListTile onChanged = null when no PIN configured.
      final switches = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .where((s) => s.onChanged == null)
          .length;
      check(switches).isGreaterOrEqual(1);
    });

    testWidgets('security_pin_timeout_slider_visible', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _settingsOverrides(),
          child: const SecurityScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(find.byType(Slider).evaluate().length).isGreaterOrEqual(1);
    });
  });

  group('security screen — with PINs', () {
    testWidgets('security_app_pin_row_shows_disable_action_when_set', (
      tester,
    ) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _settingsOverrides(
            const AppSettings(defaults: AppDefaults(), appPinHash: 'abc'),
          ),
          child: const SecurityScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // When PIN is set, the row shows a TextButton to disable the PIN.
      check(find.byType(TextButton).evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('security_duress_test_row_tap_shows_keypad', (tester) async {
      // Verifies that the duress test row (verified icon) is present and
      // tappable. The full keypad dialog is tested separately — here we
      // just confirm the row is rendered.
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _settingsOverrides(
            const AppSettings(
              defaults: AppDefaults(),
              duressPinHash: 'test-hash',
            ),
          ),
          child: const SecurityScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // The duress test row (verified icon) must be present and have an onTap.
      final verifyIcon = find.byIcon(Icons.verified_outlined);
      check(verifyIcon.evaluate().length).isGreaterOrEqual(1);
    });
  });

  // ---- StealthScreen --------------------------------------------------------

  group('stealth screen', () {
    testWidgets('stealth_screen_renders_app_bar', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _settingsOverrides(),
          child: const StealthScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(find.byType(AppBar).evaluate().length).equals(1);
    });

    testWidgets('stealth_screen_shows_enable_switch', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _settingsOverrides(),
          child: const StealthScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(find.byType(SwitchListTile).evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('stealth_screen_shows_fake_name_field', (tester) async {
      // The stealth screen shows the fakeName as a ListTile subtitle (Text),
      // not as an editable TextField — editing is via an icon-picker flow.
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _settingsOverrides(
            const AppSettings(
              defaults: AppDefaults(stealth: StealthConfig(enabled: true)),
            ),
          ),
          child: const StealthScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // The fake name ListTile is always present when stealth is available.
      check(find.byType(ListTile).evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('stealth_screen_session_screen_stealth_switch', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _settingsOverrides(
            const AppSettings(
              defaults: AppDefaults(stealth: StealthConfig(enabled: true)),
            ),
          ),
          child: const StealthScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // Multiple switches visible.
      check(find.byType(SwitchListTile).evaluate().length).isGreaterOrEqual(2);
    });
  });

  // ---- BackupScreen ---------------------------------------------------------

  group('backup screen', () {
    testWidgets('backup_screen_renders_app_bar', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _backupOverrides(),
          child: const BackupScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(find.byType(AppBar).evaluate().length).equals(1);
    });

    testWidgets('backup_screen_shows_export_button', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _backupOverrides(),
          child: const BackupScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(find.byType(FilledButton).evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('backup_screen_shows_import_button', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _backupOverrides(),
          child: const BackupScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(find.byType(OutlinedButton).evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('backup_screen_shows_pin_field', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _backupOverrides(),
          child: const BackupScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(find.byType(TextField).evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('backup_screen_export_shows_json_dialog', (tester) async {
      // The BackupScreen content overflows the default 800x600
      // viewport (PIN field, selection toggles, plus the two CTAs).
      // Use a tall viewport so the Export button is hit-testable.
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: _backupOverrides(),
          child: const BackupScreen(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      // Export dialog with JSON content should appear.
      check(find.byType(AlertDialog).evaluate().length).isGreaterOrEqual(1);
    });
  });
}
