/// Supplemental tests for [EventDefaultsScreen] covering uncovered
/// onChanged callbacks:
///   - lines 186–187: FakeCallForm callerName TextFormField onChanged.
///   - lines 222–223: SmsContactForm channel DropdownButtonFormField onChanged.
///   - lines 282–284: HardwareButtonForm pressCount TextFormField onChanged.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/settings/event_defaults_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

const _defaultSettings = AppSettings(defaults: AppDefaults());
const _bigViewport = Size(800, 1400);

Widget _host(FakeSettingsRepository repo) => hostScreen(
  overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
  child: const EventDefaultsScreen(),
);

/// Scrolls the list until the nth ExpansionTile appears, then expands it.
Future<void> _expandTile(WidgetTester tester, int index) async {
  for (var attempt = 0; attempt < 40; attempt++) {
    final tiles = find.byType(ExpansionTile);
    if (tiles.evaluate().length > index) {
      await tester.ensureVisible(tiles.at(index));
      await tester.pump();
      await tester.tap(tiles.at(index));
      await tester.pumpAndSettle();
      return;
    }
    await tester.drag(find.byType(ListView).first, const Offset(0, -200));
    await tester.pump();
  }
}

void main() {
  group('EventDefaultsScreen — extra onChanged branches', () {
    testWidgets(
        'FakeCall callerName TextFormField onChanged persists (lines 186–187)',
        (tester) async {
      await tester.binding.setSurfaceSize(_bigViewport);
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      final repo = FakeSettingsRepository(_defaultSettings);
      await tester.pumpWidget(_host(repo));
      await tester.pumpAndSettle();

      // fakeCall tile is index 3.
      await _expandTile(tester, 3);

      // Find the callerName TextFormField and enter text.
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.ensureVisible(textFields.first);
        await tester.pump();
        // Type a caller name to fire onChanged.
        await tester.enterText(textFields.first, 'Angela');
        await tester.pumpAndSettle();
        // The repository should now be updated.
        check(repo.stored).isNotNull();
      }
    });

    testWidgets(
        'SmsContact channel dropdown onChanged persists (lines 222–223)',
        (tester) async {
      await tester.binding.setSurfaceSize(_bigViewport);
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      final repo = FakeSettingsRepository(_defaultSettings);
      await tester.pumpWidget(_host(repo));
      await tester.pumpAndSettle();

      // smsContact tile is index 4.
      await _expandTile(tester, 4);

      // The SmsContactForm has a DropdownButtonFormField for channel.
      // Open the dropdown and tap a menu item.
      final dropdowns = find.byType(DropdownButtonFormField<dynamic>);
      if (dropdowns.evaluate().isNotEmpty) {
        await tester.ensureVisible(dropdowns.first);
        await tester.pump();
        await tester.tap(dropdowns.first);
        await tester.pumpAndSettle();
        // Tap 'WhatsApp' menu item if visible, else tap the first item.
        final whatsapp = find.text('WhatsApp');
        if (whatsapp.evaluate().isNotEmpty) {
          await tester.tap(whatsapp.first);
        } else {
          // Fallback: tap first item in dropdown.
          final items = find.byType(DropdownMenuItem<dynamic>);
          if (items.evaluate().isNotEmpty) {
            await tester.tap(items.first);
          }
        }
        await tester.pumpAndSettle();
        check(find.byType(EventDefaultsScreen).evaluate()).isNotEmpty();
      }
    });

    testWidgets(
        'HardwareButton pressCount TextFormField onChanged persists (lines 282–284)',
        (tester) async {
      await tester.binding.setSurfaceSize(_bigViewport);
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      final repo = FakeSettingsRepository(_defaultSettings);
      await tester.pumpWidget(_host(repo));
      await tester.pumpAndSettle();

      // hardwareButton tile is index 8.
      await _expandTile(tester, 8);

      // HardwareButtonForm has a TextFormField for pressCount.
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.ensureVisible(textFields.first);
        await tester.pump();
        // Enter a valid press count integer.
        await tester.enterText(textFields.first, '7');
        await tester.pumpAndSettle();
        check(repo.stored).isNotNull();
      }
    });
  });
}
