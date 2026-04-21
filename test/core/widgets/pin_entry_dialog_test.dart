/// Tests for [showPinEntryDialog] — the modal PIN prompt.
///
/// Covers the five outcome paths the dialog can resolve to:
/// correct PIN → [PinResult.correct]; wrong PIN (8 digits) →
/// [PinResult.wrong]; cancel button → [PinResult.cancelled];
/// duress PIN → [PinResult.duress] (checked BEFORE the session-end
/// PIN so a duress==sessionEnd collision never reveals "correct");
/// and a smoke test that the dialog renders a PIN keypad.
///
/// Uses real [PinHasher.hash] to produce stored hashes so the dialog
/// exercises the same async Argon2 path as production. Argon2id
/// derivation happens on a worker isolate; `tester.runAsync` is used
/// for every PinHasher call AND for post-tap settles so the fake
/// clock does not block real isolate work.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/utils/pin_hasher.dart';
import 'package:guardianangela/core/utils/pin_result.dart';
import 'package:guardianangela/core/widgets/pin_entry_dialog.dart';
import 'package:guardianangela/core/widgets/pin_keypad.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

Widget _appHost({
  required String? sessionEndHash,
  required String? duressHash,
  required void Function(PinResult) onResolved,
}) => MaterialApp(
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
        onPressed: () async {
          final r = await showPinEntryDialog(
            context: context,
            sessionEndHash: sessionEndHash,
            duressHash: duressHash,
            timeout: 0,
          );
          onResolved(r);
        },
        child: const Text('open'),
      ),
    ),
  ),
);

/// Lets ~[seconds] of real wall-clock time pass so Argon2id worker
/// isolates can deliver their results onto the main port, then pumps
/// a frame for every 200ms tick.
Future<void> _settleRealAsync(WidgetTester tester, {int seconds = 3}) async {
  final iterations = seconds * 5;
  for (var i = 0; i < iterations; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
  }
}

void main() {
  testWidgets('PinEntryDialog renders with a PinKeypad + Cancel button',
      (tester) async {
    final stored =
        (await tester.runAsync(() => PinHasher.hash('1234')))!;
    PinResult? resolved;
    await tester.pumpWidget(_appHost(
      sessionEndHash: stored,
      duressHash: null,
      onResolved: (r) => resolved = r,
    ));
    await tester.pump();
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    check(find.byType(AlertDialog).evaluate().length).equals(1);
    check(find.byType(PinKeypad).evaluate().length).equals(1);
    await tester.tap(find.byType(TextButton).last);
    await _settleRealAsync(tester, seconds: 1);
    check(resolved).equals(PinResult.cancelled);
  });

  testWidgets('Correct PIN resolves with PinResult.correct', (tester) async {
    final stored =
        (await tester.runAsync(() => PinHasher.hash('1234')))!;
    PinResult? resolved;
    await tester.pumpWidget(_appHost(
      sessionEndHash: stored,
      duressHash: null,
      onResolved: (r) => resolved = r,
    ));
    await tester.pump();
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    for (final d in ['1', '2', '3', '4']) {
      await tester.tap(find.text(d));
      await tester.pump();
    }
    await _settleRealAsync(tester, seconds: 5);
    check(resolved).equals(PinResult.correct);
  });

  testWidgets('Wrong PIN at 8 digits resolves with PinResult.wrong',
      (tester) async {
    final stored =
        (await tester.runAsync(() => PinHasher.hash('99999999')))!;
    PinResult? resolved;
    await tester.pumpWidget(_appHost(
      sessionEndHash: stored,
      duressHash: null,
      onResolved: (r) => resolved = r,
    ));
    await tester.pump();
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    for (final d in ['1', '1', '1', '1', '1', '1', '1', '1']) {
      await tester.tap(find.text(d));
      await tester.pump();
    }
    // Verify runs for each 200ms tap under real time. With the
    // _inFlight guard, multiple verifies can still pile up as digits
    // are absorbed — give plenty of headroom.
    await _settleRealAsync(tester, seconds: 15);
    check(resolved).equals(PinResult.wrong);
  });

  testWidgets('Cancel button resolves with PinResult.cancelled',
      (tester) async {
    final stored =
        (await tester.runAsync(() => PinHasher.hash('5555')))!;
    PinResult? resolved;
    await tester.pumpWidget(_appHost(
      sessionEndHash: stored,
      duressHash: null,
      onResolved: (r) => resolved = r,
    ));
    await tester.pump();
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byType(TextButton).last);
    await _settleRealAsync(tester, seconds: 1);
    check(resolved).equals(PinResult.cancelled);
  });

  testWidgets('Duress PIN resolves with PinResult.duress (checked first)',
      (tester) async {
    final sessionEnd =
        (await tester.runAsync(() => PinHasher.hash('1234')))!;
    final duress =
        (await tester.runAsync(() => PinHasher.hash('9999')))!;
    PinResult? resolved;
    await tester.pumpWidget(_appHost(
      sessionEndHash: sessionEnd,
      duressHash: duress,
      onResolved: (r) => resolved = r,
    ));
    await tester.pump();
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    for (final d in ['9', '9', '9', '9']) {
      await tester.tap(find.text(d));
      await tester.pump();
    }
    await _settleRealAsync(tester, seconds: 5);
    check(resolved).equals(PinResult.duress);
  });
}
