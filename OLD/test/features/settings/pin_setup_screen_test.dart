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

/// Lets ~[seconds] of real wall-clock time pass so the Argon2id
/// isolate can deliver results, pumping a frame every 200ms.
Future<void> _settleRealAsync(WidgetTester tester, {int seconds = 4}) async {
  final iterations = seconds * 5;
  for (var i = 0; i < iterations; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
  }
}

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

  testWidgets('PinSetupScreen collects digits and shows bullets',
      (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
      ],
      child: const PinSetupScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('3'));
    await tester.pump();
    // Three bullets => three digits entered.
    check(find.text('\u2022\u2022\u2022').evaluate().length).equals(1);
  });

  testWidgets('PinSetupScreen backspace removes a digit', (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
      ],
      child: const PinSetupScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1'));
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('\u232b'));
    await tester.pump();
    check(find.text('\u2022').evaluate().length).equals(1);
  });

  testWidgets(
    'PinSetupScreen mismatch resets both buffers and shows error',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          settingsRepositoryProvider
              .overrideWithValue(FakeSettingsRepository()),
        ],
        child: const PinSetupScreen(),
      ));
      await tester.pumpAndSettle();
      // First PIN: 1234
      for (final d in ['1', '2', '3', '4']) {
        await tester.tap(find.text(d));
      }
      await tester.pumpAndSettle();
      // Second PIN: 9999 (mismatch)
      for (final d in ['9', '9', '9', '9']) {
        await tester.tap(find.text(d));
      }
      await tester.pumpAndSettle();
      // Error text is visible; buffers cleared (no bullets).
      check(find.text('\u2022').evaluate()).isEmpty();
    },
  );

  testWidgets(
    'PinSetupScreen match saves hash to session-end when no which',
    (tester) async {
      final repo = FakeSettingsRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
        ],
        child: const PinSetupScreen(),
      ));
      await tester.pumpAndSettle();
      final keypad = find.byType(PinKeypad);
      for (final d in ['1', '2', '3', '4']) {
        await tester.tap(find.descendant(of: keypad, matching: find.text(d)));
        await tester.pump();
      }
      for (final d in ['1', '2', '3', '4']) {
        await tester.tap(find.descendant(of: keypad, matching: find.text(d)));
        await tester.pump();
      }
      await _settleRealAsync(tester);
      check(repo.stored).isNotNull();
      check(repo.stored!.sessionEndPinHash).isNotNull();
    },
  );

  testWidgets(
    'PinSetupScreen saves to app PIN hash when which=app',
    (tester) async {
      final repo = FakeSettingsRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
        ],
        initialQuery: 'which=app',
        child: const PinSetupScreen(),
      ));
      await tester.pumpAndSettle();
      final keypad = find.byType(PinKeypad);
      for (final d in ['1', '2', '3', '4']) {
        await tester.tap(find.descendant(of: keypad, matching: find.text(d)));
        await tester.pump();
      }
      for (final d in ['1', '2', '3', '4']) {
        await tester.tap(find.descendant(of: keypad, matching: find.text(d)));
        await tester.pump();
      }
      await _settleRealAsync(tester);
      check(repo.stored).isNotNull();
      check(repo.stored!.appPinHash).isNotNull();
    },
  );

  testWidgets(
    'PinSetupScreen saves to duress hash when which=duress',
    (tester) async {
      final repo = FakeSettingsRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
        ],
        initialQuery: 'which=duress',
        child: const PinSetupScreen(),
      ));
      await tester.pumpAndSettle();
      final keypad = find.byType(PinKeypad);
      for (final d in ['1', '2', '3', '4']) {
        await tester.tap(find.descendant(of: keypad, matching: find.text(d)));
        await tester.pump();
      }
      for (final d in ['1', '2', '3', '4']) {
        await tester.tap(find.descendant(of: keypad, matching: find.text(d)));
        await tester.pump();
      }
      await _settleRealAsync(tester);
      check(repo.stored).isNotNull();
      check(repo.stored!.duressPinHash).isNotNull();
    },
  );

  testWidgets(
    'PinSetupScreen saves to sessionEnd when which=sessionEnd',
    (tester) async {
      final repo = FakeSettingsRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
        ],
        initialQuery: 'which=sessionEnd',
        child: const PinSetupScreen(),
      ));
      await tester.pumpAndSettle();
      final keypad = find.byType(PinKeypad);
      for (final d in ['1', '2', '3', '4']) {
        await tester.tap(find.descendant(of: keypad, matching: find.text(d)));
        await tester.pump();
      }
      for (final d in ['1', '2', '3', '4']) {
        await tester.tap(find.descendant(of: keypad, matching: find.text(d)));
        await tester.pump();
      }
      await _settleRealAsync(tester);
      check(repo.stored).isNotNull();
      check(repo.stored!.sessionEndPinHash).isNotNull();
    },
  );

  testWidgets('PinSetupScreen backspace on empty buffer is a no-op',
      (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
      ],
      child: const PinSetupScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('\u232b'));
    await tester.pump();
    check(find.text('\u2022').evaluate()).isEmpty();
  });
}
