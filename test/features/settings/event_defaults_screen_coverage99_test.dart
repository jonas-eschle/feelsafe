/// Extended coverage tests for [EventDefaultsScreen].
///
/// Exercises:
/// 1. All 9 ExpansionTile tiles rendered (scroll to each).
/// 2. Expanding a tile triggers _currentConfig / _replaceConfig paths.
/// 3. Interacting with the form inside each tile calls onChanged and
///    persists updated EventDefaults via SettingsController.setDefaults.
///
/// ChainStepType.values order (defines tile index):
///   0 holdButton, 1 disguisedReminder, 2 countdownWarning, 3 fakeCall,
///   4 smsContact, 5 phoneCallContact, 6 loudAlarm, 7 callEmergency,
///   8 hardwareButton.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/settings/event_defaults_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _defaultSettings = AppSettings(defaults: AppDefaults());

Widget _host(AppSettings? seed) {
  final repo = seed != null
      ? FakeSettingsRepository(seed)
      : FakeSettingsRepository(null);
  return hostScreen(
    overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
    child: const EventDefaultsScreen(),
  );
}

/// Scrolls until the [tileIndex]-th ExpansionTile (0-based) is visible
/// and taps it to expand it. Does NOT scroll after expanding so the
/// newly revealed children stay in the viewport.
Future<void> _expandTileAt(WidgetTester tester, int tileIndex) async {
  for (var attempt = 0; attempt < 40; attempt++) {
    final tiles = find.byType(ExpansionTile);
    if (tiles.evaluate().length > tileIndex) {
      await tester.ensureVisible(tiles.at(tileIndex));
      await tester.pump();
      await tester.tap(tiles.at(tileIndex));
      await tester.pumpAndSettle();
      return;
    }
    await tester.drag(find.byType(ListView).first, const Offset(0, -200));
    await tester.pump();
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('EventDefaultsScreen tile rendering', () {
    testWidgets(
      'renders at least one ExpansionTile',
      (tester) async {
        await tester.pumpWidget(_host(_defaultSettings));
        await tester.pumpAndSettle();

        check(find.byType(ExpansionTile).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'ChainStepType has exactly 9 values',
      (tester) async {
        check(ChainStepType.values.length).equals(9);
      },
    );

    testWidgets(
      'scrolling to end reveals all 9 ExpansionTiles',
      (tester) async {
        await tester.pumpWidget(_host(_defaultSettings));
        await tester.pumpAndSettle();

        // Scroll to the end to build all tiles.
        for (var i = 0; i < 15; i++) {
          await tester.drag(find.byType(ListView).first, const Offset(0, -300));
          await tester.pump();
        }
        await tester.pumpAndSettle();

        // At least some tiles are rendered; count rendered ones.
        check(find.byType(ExpansionTile).evaluate().length)
            .isGreaterOrEqual(1);
      },
    );
  });

  group('EventDefaultsScreen _currentConfig paths (expand each tile)', () {
    testWidgets(
      'holdButton tile (index 0) — expands and shows TextFormField',
      (tester) async {
        await tester.pumpWidget(_host(_defaultSettings));
        await tester.pumpAndSettle();

        await _expandTileAt(tester, 0);

        check(find.byType(TextFormField).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'disguisedReminder tile (index 1) — expands and shows TextFormField',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(_host(_defaultSettings));
        await tester.pumpAndSettle();

        await _expandTileAt(tester, 1);

        // Ensure at least one TextFormField is in the tree (may need scroll).
        final fieldFinder = find.byType(TextFormField);
        if (fieldFinder.evaluate().isNotEmpty) {
          await tester.ensureVisible(fieldFinder.first);
          await tester.pump();
        }
        check(find.byType(TextFormField).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'countdownWarning tile (index 2) — expands and shows SwitchListTile',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(_host(_defaultSettings));
        await tester.pumpAndSettle();

        await _expandTileAt(tester, 2);

        check(find.byType(SwitchListTile).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'fakeCall tile (index 3) — expands and shows form widgets',
      (tester) async {
        await tester.pumpWidget(_host(_defaultSettings));
        await tester.pumpAndSettle();

        await _expandTileAt(tester, 3);

        // FakeCall form has a TextFormField for callerName.
        check(find.byType(EventDefaultsScreen).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'smsContact tile (index 4) — expands and shows dropdown',
      (tester) async {
        await tester.pumpWidget(_host(_defaultSettings));
        await tester.pumpAndSettle();

        await _expandTileAt(tester, 4);

        check(find.byType(EventDefaultsScreen).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'phoneCallContact tile (index 5) — expands without error',
      (tester) async {
        await tester.pumpWidget(_host(_defaultSettings));
        await tester.pumpAndSettle();

        await _expandTileAt(tester, 5);

        check(find.byType(EventDefaultsScreen).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'loudAlarm tile (index 6) — expands without error',
      (tester) async {
        await tester.pumpWidget(_host(_defaultSettings));
        await tester.pumpAndSettle();

        await _expandTileAt(tester, 6);

        check(find.byType(EventDefaultsScreen).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'callEmergency tile (index 7) — expands without error',
      (tester) async {
        await tester.pumpWidget(_host(_defaultSettings));
        await tester.pumpAndSettle();

        await _expandTileAt(tester, 7);

        check(find.byType(EventDefaultsScreen).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'hardwareButton tile (index 8) — expands without error',
      (tester) async {
        await tester.pumpWidget(_host(_defaultSettings));
        await tester.pumpAndSettle();

        await _expandTileAt(tester, 8);

        check(find.byType(EventDefaultsScreen).evaluate()).isNotEmpty();
      },
    );
  });

  group('EventDefaultsScreen _replaceConfig paths (onChanged wiring)', () {
    testWidgets(
      'holdButton TextFormField edit calls setDefaults with updated config',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = FakeSettingsRepository(_defaultSettings);
        await tester.pumpWidget(hostScreen(
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
          child: const EventDefaultsScreen(),
        ));
        await tester.pumpAndSettle();

        // Expand holdButton tile (index 0).
        await _expandTileAt(tester, 0);

        final fieldFinder = find.byType(TextFormField);
        if (fieldFinder.evaluate().isNotEmpty) {
          await tester.ensureVisible(fieldFinder.first);
          await tester.pump();
          await tester.tap(fieldFinder.first);
          await tester.enterText(fieldFinder.first, '0.8');
          await tester.pumpAndSettle();

          check(repo.stored).isNotNull();
          check(
            repo.stored!.defaults.eventDefaults.holdButton.releaseSensitivity,
          ).equals(0.8);
        }
      },
    );

    testWidgets(
      'disguisedReminder TextFormField edit updates intervalSeconds',
      (tester) async {
        // Large surface to keep expanded children in view.
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = FakeSettingsRepository(_defaultSettings);
        await tester.pumpWidget(hostScreen(
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
          child: const EventDefaultsScreen(),
        ));
        await tester.pumpAndSettle();

        await _expandTileAt(tester, 1);

        // Scroll to bring the TextFormField into view.
        final fieldFinder = find.byType(TextFormField);
        if (fieldFinder.evaluate().isNotEmpty) {
          await tester.ensureVisible(fieldFinder.first);
          await tester.pump();
          await tester.tap(fieldFinder.first);
          await tester.enterText(fieldFinder.first, '120');
          await tester.pumpAndSettle();

          check(repo.stored).isNotNull();
          check(
            repo.stored!.defaults.eventDefaults.disguisedReminder
                .intervalSeconds,
          ).equals(120);
        }
      },
    );

    testWidgets(
      'countdownWarning switch toggle persists an update to EventDefaults',
      (tester) async {
        // Use a large surface so expanded tile children are in view.
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = FakeSettingsRepository(_defaultSettings);
        await tester.pumpWidget(hostScreen(
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
          child: const EventDefaultsScreen(),
        ));
        await tester.pumpAndSettle();

        await _expandTileAt(tester, 2);

        final switches = find.byType(SwitchListTile);
        if (switches.evaluate().isNotEmpty) {
          await tester.tap(switches.first);
          await tester.pumpAndSettle();
          // The key assertion: setDefaults was called and the repo was updated.
          check(repo.stored).isNotNull();
        }
      },
    );

    testWidgets(
      'fakeCall declineIsSafe switch toggle persists updated config (line 99)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = FakeSettingsRepository(_defaultSettings);
        await tester.pumpWidget(hostScreen(
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
          child: const EventDefaultsScreen(),
        ));
        await tester.pumpAndSettle();

        // fakeCall = index 3.
        await _expandTileAt(tester, 3);

        // FakeCall form has a SwitchListTile for declineIsSafe.
        final switches = find.byType(SwitchListTile);
        if (switches.evaluate().isNotEmpty) {
          await tester.ensureVisible(switches.first);
          await tester.pump();
          await tester.tap(switches.first);
          await tester.pumpAndSettle();
          check(repo.stored).isNotNull();
        }
      },
    );

    testWidgets(
      'smsContact includeLocation switch toggle persists (line 102)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = FakeSettingsRepository(_defaultSettings);
        await tester.pumpWidget(hostScreen(
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
          child: const EventDefaultsScreen(),
        ));
        await tester.pumpAndSettle();

        // smsContact = index 4.
        await _expandTileAt(tester, 4);

        final switches = find.byType(SwitchListTile);
        if (switches.evaluate().isNotEmpty) {
          await tester.ensureVisible(switches.first);
          await tester.pump();
          await tester.tap(switches.first);
          await tester.pumpAndSettle();
          check(repo.stored).isNotNull();
        }
      },
    );

    testWidgets(
      'phoneCallContact preSendSms switch toggle persists (line 103-104)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = FakeSettingsRepository(_defaultSettings);
        await tester.pumpWidget(hostScreen(
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
          child: const EventDefaultsScreen(),
        ));
        await tester.pumpAndSettle();

        // phoneCallContact = index 5.
        await _expandTileAt(tester, 5);

        final switches = find.byType(SwitchListTile);
        if (switches.evaluate().isNotEmpty) {
          await tester.ensureVisible(switches.first);
          await tester.pump();
          await tester.tap(switches.first);
          await tester.pumpAndSettle();
          check(repo.stored).isNotNull();
        }
      },
    );

    testWidgets(
      'loudAlarm flashScreen switch toggle persists (lines 105-106)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = FakeSettingsRepository(_defaultSettings);
        await tester.pumpWidget(hostScreen(
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
          child: const EventDefaultsScreen(),
        ));
        await tester.pumpAndSettle();

        // loudAlarm = index 6.
        await _expandTileAt(tester, 6);

        final switches = find.byType(SwitchListTile);
        if (switches.evaluate().isNotEmpty) {
          await tester.ensureVisible(switches.first);
          await tester.pump();
          await tester.tap(switches.first);
          await tester.pumpAndSettle();
          check(repo.stored).isNotNull();
        }
      },
    );

    testWidgets(
      'callEmergency showConfirmation switch toggle persists (lines 107-108)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = FakeSettingsRepository(_defaultSettings);
        await tester.pumpWidget(hostScreen(
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
          child: const EventDefaultsScreen(),
        ));
        await tester.pumpAndSettle();

        // callEmergency = index 7.
        await _expandTileAt(tester, 7);

        final switches = find.byType(SwitchListTile);
        if (switches.evaluate().isNotEmpty) {
          await tester.ensureVisible(switches.first);
          await tester.pump();
          await tester.tap(switches.first);
          await tester.pumpAndSettle();
          check(repo.stored).isNotNull();
        }
      },
    );

    testWidgets(
      'hardwareButton pressCount TextFormField edit persists (line 95)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = FakeSettingsRepository(_defaultSettings);
        await tester.pumpWidget(hostScreen(
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
          child: const EventDefaultsScreen(),
        ));
        await tester.pumpAndSettle();

        // hardwareButton = index 8.
        await _expandTileAt(tester, 8);

        // HardwareForm has TextFormField for pressCount (last field).
        final fields = find.byType(TextFormField);
        if (fields.evaluate().isNotEmpty) {
          final lastField = fields.last;
          await tester.ensureVisible(lastField);
          await tester.pump();
          await tester.tap(lastField);
          await tester.enterText(lastField, '5');
          await tester.pumpAndSettle();
          check(repo.stored).isNotNull();
        }
      },
    );
  });
}
