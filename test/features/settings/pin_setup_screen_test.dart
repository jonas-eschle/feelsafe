/// Smoke tests for [PinSetupScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/pin_keypad.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/settings/pin_setup_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('PinSetupScreen renders without throwing', (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
      ],
      child: const PinSetupScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(PinSetupScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('PinSetupScreen shows the shared PinKeypad', (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
      ],
      child: const PinSetupScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(PinKeypad).evaluate().length).equals(1);
  });
}
