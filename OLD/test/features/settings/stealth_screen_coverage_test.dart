/// Coverage filler for [StealthScreen]:
///   * Tap an icon-preset tile → exercises `pickPreset` inner
///     function (lines 34-39) and the `onTap: () => onSelect(preset)`
///     callback (line 121).
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/settings/stealth_screen.dart';
import 'package:guardianangela/services/fakes/fake_stealth_icon_service.dart';
import 'package:guardianangela/services/service_providers.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('StealthScreen tapping an icon preset persists the choice', (
    tester,
  ) async {
    final repo = FakeSettingsRepository();
    final fake = FakeStealthIconService();
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
          stealthIconServiceProvider.overrideWithValue(fake),
        ],
        child: const StealthScreen(),
      ),
    );
    await tester.pumpAndSettle();
    // The preset picker is a horizontal carousel with icons;
    // tapping Icons.music_note fires onSelect(music).
    final music = find.byIcon(Icons.music_note);
    if (music.evaluate().isEmpty) {
      // If layout hides it, scroll the screen first.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byIcon(Icons.music_note).first);
    await tester.pumpAndSettle();
    check(fake.calls.any((c) => c.startsWith('setPreset:music'))).isTrue();
    check(repo.stored).isNotNull();
  });
}
