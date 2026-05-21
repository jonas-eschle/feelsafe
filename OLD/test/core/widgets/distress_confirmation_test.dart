/// Widget tests for [DistressConfirmation] and
/// [showDistressConfirmation].
///
/// Covers the countdown tick loop, cancel button path (both default
/// and hook-override via [showDistressConfirmation]'s `onCancel`),
/// stealth copy switch, and auto-confirm on timeout.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/theme/app_theme.dart';
import 'package:guardianangela/core/widgets/distress_confirmation.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

Widget _appHost({required void Function(BuildContext) onOpen}) => MaterialApp(
  theme: AppTheme.light(),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Builder(
    builder: (context) => Scaffold(
      body: ElevatedButton(
        onPressed: () => onOpen(context),
        child: const Text('open'),
      ),
    ),
  ),
);

Widget _directHost({required DistressConfirmation child}) => MaterialApp(
  theme: AppTheme.light(),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('DistressConfirmation renders initial countdown', (tester) async {
    await tester.pumpWidget(
      _directHost(
        child: DistressConfirmation(
          countdownSeconds: 5,
          onConfirmed: () {},
          onCancelled: () {},
        ),
      ),
    );
    check(find.text('5').evaluate().length).equals(1);
  });

  testWidgets('DistressConfirmation ticks down each second', (tester) async {
    await tester.pumpWidget(
      _directHost(
        child: DistressConfirmation(
          countdownSeconds: 3,
          onConfirmed: () {},
          onCancelled: () {},
        ),
      ),
    );
    check(find.text('3').evaluate().length).equals(1);
    await tester.pump(const Duration(seconds: 1));
    check(find.text('2').evaluate().length).equals(1);
    await tester.pump(const Duration(seconds: 1));
    check(find.text('1').evaluate().length).equals(1);
  });

  testWidgets('DistressConfirmation fires onConfirmed when countdown expires', (
    tester,
  ) async {
    var confirmed = 0;
    await tester.pumpWidget(
      _directHost(
        child: DistressConfirmation(
          countdownSeconds: 2,
          onConfirmed: () => confirmed++,
          onCancelled: () {},
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    check(confirmed).equals(1);
    // Pump again to ensure Timer.cancel() inside the tick body runs.
    await tester.pump(const Duration(seconds: 1));
    check(confirmed).equals(1);
  });

  testWidgets('DistressConfirmation cancel button fires onCancelled', (
    tester,
  ) async {
    var cancelled = 0;
    await tester.pumpWidget(
      _directHost(
        child: DistressConfirmation(
          countdownSeconds: 5,
          onConfirmed: () {},
          onCancelled: () => cancelled++,
        ),
      ),
    );
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    check(cancelled).equals(1);
  });

  testWidgets('DistressConfirmation stealth=true renders without error', (
    tester,
  ) async {
    await tester.pumpWidget(
      _directHost(
        child: DistressConfirmation(
          countdownSeconds: 5,
          stealth: true,
          onConfirmed: () {},
          onCancelled: () {},
        ),
      ),
    );
    // In stealth mode the header uses the stealth localization key;
    // the countdown number is the same (shows "5").
    check(find.text('5').evaluate().length).equals(1);
  });

  testWidgets('showDistressConfirmation returns true on countdown expiry', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      _appHost(
        onOpen: (ctx) async {
          result = await showDistressConfirmation(ctx, duration: 2);
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    // Let the countdown fully expire.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    check(result).equals(true);
  });

  testWidgets('showDistressConfirmation returns false on cancel (default)', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      _appHost(
        onOpen: (ctx) async {
          result = await showDistressConfirmation(ctx, duration: 60);
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    check(result).equals(false);
  });

  testWidgets('showDistressConfirmation hook returning true honors cancel', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      _appHost(
        onOpen: (ctx) async {
          result = await showDistressConfirmation(
            ctx,
            duration: 60,
            onCancel: () async => true,
          );
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    check(result).equals(false);
  });

  testWidgets('showDistressConfirmation hook returning false rejects cancel', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      _appHost(
        onOpen: (ctx) async {
          result = await showDistressConfirmation(
            ctx,
            duration: 60,
            onCancel: () async => false,
          );
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    // Hook rejected the cancel -> dialog popped with true (confirmed).
    check(result).equals(true);
  });

  testWidgets('showDistressConfirmation stealth flag propagates', (
    tester,
  ) async {
    await tester.pumpWidget(
      _appHost(
        onOpen: (ctx) async {
          await showDistressConfirmation(ctx, duration: 60, isStealth: true);
        },
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    // The widget renders; we only need to hit the non-stealth default
    // path in _host and the stealth copy branch in build().
    check(find.byType(DistressConfirmation).evaluate().length).equals(1);
    // Clean up by cancelling.
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
  });
}
