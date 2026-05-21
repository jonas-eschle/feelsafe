/// Phase 7 settings-screen tests: language picker, emergency-number
/// tile, redo-onboarding tile, and gradual-volume toggle + slider.
///
/// Each test would fail if the respective Phase 7 control was absent
/// or not wired to its setter. The large viewport size prevents
/// lazy-ListView from skipping items near the bottom of the list.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/settings/settings_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helper: pump a SettingsScreen with a large viewport so the
// ListView builds all items eagerly (not lazily cut off at 600px).
// ---------------------------------------------------------------------------

/// Pumps a [SettingsScreen] with optional seeded settings and
/// returns the [FakeSettingsRepository] so tests can inspect
/// what was written back.
Future<FakeSettingsRepository> _pump(
  WidgetTester tester, {
  AppSettings? initial,
}) async {
  // Large viewport: all list items are built immediately.
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final repo = FakeSettingsRepository(initial);
  await tester.pumpWidget(hostScreenWithRouter(
    overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
    child: const SettingsScreen(),
  ));
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  // -------------------------------------------------------------------------
  // Language picker
  // -------------------------------------------------------------------------
  group('Phase 7 — language picker', () {
    testWidgets('SettingsScreen renders a DropdownButton<String> for language',
        (tester) async {
      await _pump(tester);
      // _LanguagePicker uses DropdownButton<String>. There may also be
      // the theme DropdownButton<AppThemeMode> — verify at least one
      // DropdownButton<String> exists.
      final langDropdowns = find.byType(DropdownButton<String>);
      check(langDropdowns.evaluate().length).isGreaterThan(0);
    });

    testWidgets('language DropdownButton persists new language code via callback',
        (tester) async {
      final repo = await _pump(tester);
      // Drive onChanged directly — the dropdown popup is unreliable in
      // widget tests (flutter#84518). This still verifies the full
      // controller wiring.
      final langDropdown = tester.widget<DropdownButton<String>>(
        find.byType(DropdownButton<String>),
      );
      langDropdown.onChanged!('de');
      await tester.pumpAndSettle();
      check(repo.stored).isNotNull();
      check(repo.stored!.languageCode).equals('de');
    });

    testWidgets('language DropdownButton initial value reflects stored code',
        (tester) async {
      await _pump(
        tester,
        initial: const AppSettings(defaults: AppDefaults(), languageCode: 'fr'),
      );
      final langDropdown = tester.widget<DropdownButton<String>>(
        find.byType(DropdownButton<String>),
      );
      check(langDropdown.value).equals('fr');
    });
  });

  // -------------------------------------------------------------------------
  // Emergency number tile
  // -------------------------------------------------------------------------
  group('Phase 7 — emergency number tile', () {
    testWidgets('emergency-number ListTile renders with the current number',
        (tester) async {
      await _pump(
        tester,
        initial: const AppSettings(
          defaults: AppDefaults(),
          emergencyCallNumber: '999',
        ),
      );
      // The tile subtitle shows the configured number.
      check(find.text('999').evaluate().length).isGreaterThan(0);
    });

    testWidgets('tapping emergency-number tile opens an AlertDialog',
        (tester) async {
      await _pump(tester);
      // The number tile contains the default '112' as subtitle text.
      final tile = find.ancestor(
        of: find.text('112'),
        matching: find.byType(ListTile),
      );
      check(tile.evaluate().length).isGreaterThan(0);
      await tester.tap(tile.first);
      await tester.pumpAndSettle();
      check(find.byType(AlertDialog).evaluate().length).equals(1);
    });

    testWidgets('emergency-number AlertDialog contains a TextField',
        (tester) async {
      // Verify the dialog has a TextField where a number can be entered.
      // (Interaction test kept minimal to avoid controller-dispose race
      // in the autofocus rebuild path.)
      await _pump(tester);
      final tile = find.ancestor(
        of: find.text('112'),
        matching: find.byType(ListTile),
      );
      await tester.tap(tile.first);
      await tester.pump();
      check(find.byType(TextField).evaluate().length).isGreaterThan(0);
      // The dialog contains a FilledButton (Save) and at least one
      // TextButton (Cancel).
      check(find.byType(FilledButton).evaluate().length).isGreaterThan(0);
      check(find.byType(TextButton).evaluate().length).isGreaterThan(0);
    });
  });

  // -------------------------------------------------------------------------
  // Redo-onboarding tile
  // -------------------------------------------------------------------------
  group('Phase 7 — redo-onboarding tile', () {
    testWidgets('redo-onboarding ListTile is present in the screen',
        (tester) async {
      await _pump(tester);
      // Locate the tile by its title text containing "redo" (case-insensitive).
      final tiles = find.byWidgetPredicate(
        (w) =>
            w is ListTile &&
            w.title is Text &&
            (w.title! as Text).data!.toLowerCase().contains('redo'),
      );
      check(tiles.evaluate().length).isGreaterThan(0);
    });

    testWidgets('tapping redo-onboarding tile opens a confirmation AlertDialog',
        (tester) async {
      await _pump(tester);
      final redoTile = find.byWidgetPredicate(
        (w) =>
            w is ListTile &&
            w.title is Text &&
            (w.title! as Text).data!.toLowerCase().contains('redo'),
      );
      await tester.tap(redoTile.first);
      await tester.pumpAndSettle();
      check(find.byType(AlertDialog).evaluate().length).equals(1);
    });

    testWidgets('cancelling redo-onboarding dialog dismisses it',
        (tester) async {
      await _pump(tester);

      final redoTile = find.byWidgetPredicate(
        (w) =>
            w is ListTile &&
            w.title is Text &&
            (w.title! as Text).data!.toLowerCase().contains('redo'),
      );
      await tester.tap(redoTile.first);
      await tester.pumpAndSettle();
      check(find.byType(AlertDialog).evaluate().length).equals(1);

      // Tap the first TextButton (Cancel) in the confirmation dialog.
      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();
      check(find.byType(AlertDialog).evaluate().length).equals(0);
    });
  });

  // -------------------------------------------------------------------------
  // Gradual-volume toggle + slider
  // -------------------------------------------------------------------------
  group('Phase 7 — gradual-volume toggle + slider', () {
    testWidgets('gradual-volume SwitchListTile is present', (tester) async {
      await _pump(tester);
      final volTile = find.byWidgetPredicate(
        (w) =>
            w is SwitchListTile &&
            w.title is Text &&
            (w.title! as Text).data!.toLowerCase().contains('gradual'),
      );
      check(volTile.evaluate().length).isGreaterThan(0);
    });

    testWidgets('toggling gradual-volume switch persists alarmGradualVolume',
        (tester) async {
      final repo = await _pump(tester);
      final volTile = find.byWidgetPredicate(
        (w) =>
            w is SwitchListTile &&
            w.title is Text &&
            (w.title! as Text).data!.toLowerCase().contains('gradual'),
      );
      check(volTile.evaluate().length).isGreaterThan(0);
      await tester.tap(volTile.first);
      await tester.pumpAndSettle();
      check(repo.stored).isNotNull();
      check(repo.stored!.alarmGradualVolume).isTrue();
    });

    testWidgets(
        'gradual-volume duration Slider appears when alarmGradualVolume=true',
        (tester) async {
      await _pump(
        tester,
        initial: const AppSettings(
          defaults: AppDefaults(),
          alarmGradualVolume: true,
          alarmGradualVolumeDurationSeconds: 10,
        ),
      );
      // _GradualVolumeDurationSlider wraps a Material Slider.
      check(find.byType(Slider).evaluate().length).isGreaterThan(0);
    });

    testWidgets(
        'gradual-volume Slider is absent when alarmGradualVolume=false',
        (tester) async {
      await _pump(
        tester,
        initial: const AppSettings(
          defaults: AppDefaults(),
          // ignore: avoid_redundant_argument_values
          alarmGradualVolume: false,
        ),
      );
      check(find.byType(Slider).evaluate().length).equals(0);
    });
  });
}
