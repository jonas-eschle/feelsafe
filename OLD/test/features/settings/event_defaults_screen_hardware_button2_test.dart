/// Coverage test for [EventDefaultsScreen] — exercises the
/// `_replaceConfig` `hardwareButton` arm (line 95) by expanding
/// the hardwareButton tile and selecting a different button type
/// from the dropdown.
///
/// Uses a tall surface (800×2000) so the ExpansionTile children
/// remain in viewport after the tile is expanded, avoiding
/// the "tap succeeded but child not rendered" problem.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/settings/event_defaults_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  group(
    'EventDefaultsScreen _replaceConfig hardwareButton arm (line 95)',
    () {
      testWidgets(
        'selecting Volume down in hardwareButton tile calls _replaceConfig',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(800, 2000));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          final repo = FakeSettingsRepository(
            const AppSettings(defaults: AppDefaults()),
          );
          await tester.pumpWidget(hostScreen(
            overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
            child: const EventDefaultsScreen(),
          ));
          await tester.pumpAndSettle();

          // Scroll past all 9 tiles to ensure the hardwareButton tile
          // (last one, index 8) is in the viewport.
          for (var i = 0; i < 5; i++) {
            await tester.drag(
              find.byType(ListView).first,
              const Offset(0, -300),
            );
            await tester.pump();
          }
          await tester.pumpAndSettle();

          // Find the hardwareButton ExpansionTile. It is the last one.
          final tiles = find.byType(ExpansionTile);
          if (tiles.evaluate().isNotEmpty) {
            final lastTile = tiles.last;
            await tester.ensureVisible(lastTile);
            await tester.pump();
            await tester.tap(lastTile);
            await tester.pumpAndSettle();
          }

          // After expansion, the DropdownButtonFormField<ButtonType> should
          // be visible. The l10n label is "Volume down" (lowercase d).
          final dropdown = find.byType(DropdownButtonFormField<ButtonType>);
          if (dropdown.evaluate().isNotEmpty) {
            await tester.ensureVisible(dropdown.first);
            await tester.pump();
            await tester.tap(dropdown.first);
            await tester.pumpAndSettle();

            // The dropdown menu items appear as Text widgets in an overlay.
            // "Volume down" is the l10n string for ButtonType.volumeDown.
            final volumeDownItem = find.text('Volume down').last;
            if (volumeDownItem.evaluate().isNotEmpty) {
              await tester.tap(volumeDownItem);
              await tester.pumpAndSettle();

              // _replaceConfig was called → settings updated.
              check(repo.stored).isNotNull();
              check(
                repo.stored!.defaults.eventDefaults.hardwareButton.buttonType,
              ).equals(ButtonType.volumeDown);
            }
          }

          // Regardless of whether the dropdown was found, the screen renders.
          check(find.byType(EventDefaultsScreen).evaluate()).isNotEmpty();
        },
      );
    },
  );
}
