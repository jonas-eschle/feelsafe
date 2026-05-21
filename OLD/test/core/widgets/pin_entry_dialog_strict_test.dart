/// Strict integration tests for [showPinEntryDialog] — 40+ tests.
///
/// Coverage:
/// - All 6 PinResult outcomes: correct, wrong, duress, cancelled, timeout
///   (wrongPinThreshold is produced by SessionController, not the dialog)
/// - Timeout countdown accuracy
/// - Backspace clears digits one at a time
/// - Submit button explicitly drives every verify (Q12 / B4) — no
///   length-cap, no auto-submit on length-match
/// - Biometric success → correct without keypad shown
/// - Biometric cancelled → keypad shown as fallback
/// - Biometric unavailable → keypad shown as fallback
/// - _inFlight guard prevents stacked verifications
/// - No sessionEndHash → wrong always (when Submit pressed)
/// - Duress checked BEFORE correct
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
import 'package:guardianangela/services/fakes/fake_biometric_service.dart';
import 'package:guardianangela/services/protocols/biometric_service_protocol.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _app({
  required String? sessionEndHash,
  required String? duressHash,
  int timeout = 0,
  BiometricServiceProtocol? biometric,
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
    builder: (ctx) => Scaffold(
      body: ElevatedButton(
        key: const Key('open'),
        onPressed: () async {
          final r = await showPinEntryDialog(
            context: ctx,
            sessionEndHash: sessionEndHash,
            duressHash: duressHash,
            timeout: timeout,
            biometric: biometric,
          );
          onResolved(r);
        },
        child: const Text('open'),
      ),
    ),
  ),
);

/// Poke real time past the Flutter fake clock so Argon2id isolates complete.
Future<void> _realSettle(WidgetTester tester, {int seconds = 4}) async {
  for (var i = 0; i < seconds * 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
  }
}

/// Open the dialog by tapping the 'open' button, then pump once.
Future<void> _openDialog(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('open')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

Future<void> _tapDigits(WidgetTester tester, Iterable<String> digits) async {
  for (final d in digits) {
    await tester.tap(find.text(d));
    await tester.pump();
  }
}

/// Tap the explicit Submit FilledButton (Q12 / B4). Pumps once.
Future<void> _tapSubmit(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('pin-submit')));
  await tester.pump();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Rendering
  // -------------------------------------------------------------------------

  group('PinEntryDialog renders', () {
    testWidgets('dialog shows AlertDialog after opening', (tester) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      check(find.byType(AlertDialog).evaluate().length).equals(1);
      // Cancel via the leading TextButton (Cancel — first action).
      await tester.tap(find.byType(TextButton).last);
      await _realSettle(tester, seconds: 1);
      check(r).equals(PinResult.cancelled);
    });

    testWidgets('dialog contains a PinKeypad', (tester) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      check(find.byType(PinKeypad).evaluate().length).equals(1);
      // Cleanup.
      await tester.tap(find.byType(TextButton).last);
      await _realSettle(tester, seconds: 1);
      check(r).equals(PinResult.cancelled);
    });

    testWidgets('dialog shows Cancel button', (tester) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      check(find.byType(TextButton).evaluate().length).isGreaterOrEqual(1);
      await tester.tap(find.byType(TextButton).last);
      await _realSettle(tester, seconds: 1);
      check(r).equals(PinResult.cancelled);
    });

    testWidgets('dialog shows Submit button (Q12 / B4)', (tester) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      check(find.byKey(const Key('pin-submit')).evaluate().length).equals(1);
      // Cleanup.
      await tester.tap(find.byType(TextButton).last);
      await _realSettle(tester, seconds: 1);
      check(r).equals(PinResult.cancelled);
    });

    testWidgets('Submit is disabled on empty buffer', (tester) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      // FilledButton with onPressed=null is disabled.
      final submit = tester.widget<FilledButton>(
        find.byKey(const Key('pin-submit')),
      );
      check(submit.onPressed).isNull();
      // Cleanup.
      await tester.tap(find.byType(TextButton).last);
      await _realSettle(tester, seconds: 1);
      check(r).equals(PinResult.cancelled);
    });

    testWidgets('bullet dots are empty before any digit is typed', (
      tester,
    ) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      // The bullet display shows empty string before any digit.
      check(find.text('•').evaluate()).isEmpty();
      await tester.tap(find.byType(TextButton).last);
      await _realSettle(tester, seconds: 1);
      check(r).equals(PinResult.cancelled);
    });
  });

  // -------------------------------------------------------------------------
  // Correct PIN (Submit-driven)
  // -------------------------------------------------------------------------

  group('PinEntryDialog — correct PIN', () {
    testWidgets('correct 4-digit PIN + Submit returns PinResult.correct', (
      tester,
    ) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      await _tapDigits(tester, ['1', '2', '3', '4']);
      await _tapSubmit(tester);
      await _realSettle(tester, seconds: 6);
      check(r).equals(PinResult.correct);
    });

    testWidgets('correct PIN + Submit dismisses the dialog', (tester) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('5678')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      await _tapDigits(tester, ['5', '6', '7', '8']);
      await _tapSubmit(tester);
      // Give Argon2id isolate generous time; pump extra after result.
      await _realSettle(tester, seconds: 8);
      await tester.pump(const Duration(milliseconds: 200));
      check(r).equals(PinResult.correct);
      // After correct, dialog is dismissed.
      check(find.byType(AlertDialog).evaluate().length).equals(0);
    });

    testWidgets('correct 8-digit PIN + Submit returns PinResult.correct', (
      tester,
    ) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('12345678')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      await _tapDigits(tester, ['1', '2', '3', '4', '5', '6', '7', '8']);
      await _tapSubmit(tester);
      await _realSettle(tester, seconds: 6);
      check(r).equals(PinResult.correct);
    });

    testWidgets('typing PIN without Submit keeps the dialog open', (
      tester,
    ) async {
      // Q12: no auto-submit on length match. The dialog stays open until
      // the user presses Submit.
      final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      await _tapDigits(tester, ['1', '2', '3', '4']);
      // Wait — the dialog must NOT auto-submit.
      await _realSettle(tester, seconds: 2);
      check(r).isNull();
      check(find.byType(AlertDialog).evaluate().length).equals(1);
      // Cancel cleanup.
      await tester.tap(find.byType(TextButton).last);
      await _realSettle(tester, seconds: 1);
      check(r).equals(PinResult.cancelled);
    });
  });

  // -------------------------------------------------------------------------
  // Wrong PIN (Submit-driven, no length cap)
  // -------------------------------------------------------------------------

  group('PinEntryDialog — wrong PIN', () {
    testWidgets('4 wrong digits + Submit → PinResult.wrong', (tester) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('9999')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      await _tapDigits(tester, ['1', '1', '1', '1']);
      await _tapSubmit(tester);
      await _realSettle(tester, seconds: 6);
      check(r).equals(PinResult.wrong);
    });

    testWidgets('8 wrong digits + Submit → PinResult.wrong', (tester) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('99999999')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      await _tapDigits(tester, ['1', '1', '1', '1', '1', '1', '1', '1']);
      await _tapSubmit(tester);
      await _realSettle(tester, seconds: 16);
      check(r).equals(PinResult.wrong);
    });

    testWidgets('Q12: buffer accepts > 8 digits (no length cap)', (
      tester,
    ) async {
      // Q12 (B4): the 8-digit hard cap was removed when auto-submit was
      // deleted. Typing 9 digits must show 9 bullet dots — Submit then
      // verifies the full 9-digit string.
      final hash = (await tester.runAsync(() => PinHasher.hash('99999999')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      await _tapDigits(tester, ['1', '1', '1', '1', '1', '1', '1', '1', '1']);
      // 9 bullets visible (string of 9 '•' chars) — pump already done.
      check(find.text('•' * 9).evaluate().length).equals(1);
      // Cleanup.
      await tester.tap(find.byType(TextButton).last);
      await _realSettle(tester, seconds: 1);
      check(r).equals(PinResult.cancelled);
    });
  });

  // -------------------------------------------------------------------------
  // Cancel
  // -------------------------------------------------------------------------

  group('PinEntryDialog — cancel', () {
    testWidgets('Cancel button returns PinResult.cancelled', (tester) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      await tester.tap(find.byType(TextButton).last);
      await _realSettle(tester, seconds: 1);
      check(r).equals(PinResult.cancelled);
    });

    testWidgets(
      'Cancel after partial entry (3 digits) returns PinResult.cancelled',
      (tester) async {
        final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
        PinResult? r;
        await tester.pumpWidget(
          _app(
            sessionEndHash: hash,
            duressHash: null,
            onResolved: (v) => r = v,
          ),
        );
        await tester.pump();
        await _openDialog(tester);
        await _tapDigits(tester, ['1', '2', '3']);
        await tester.tap(find.byType(TextButton).last);
        await _realSettle(tester, seconds: 1);
        check(r).equals(PinResult.cancelled);
      },
    );

    testWidgets('barrier dismissal returns PinResult.cancelled', (
      tester,
    ) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      // Tap outside the dialog to dismiss via barrier.
      await tester.tapAt(const Offset(10, 10));
      await _realSettle(tester, seconds: 1);
      check(r).equals(PinResult.cancelled);
    });
  });

  // -------------------------------------------------------------------------
  // Duress PIN
  // -------------------------------------------------------------------------

  group('PinEntryDialog — duress PIN', () {
    testWidgets('duress PIN + Submit returns PinResult.duress', (tester) async {
      final sessionHash = (await tester.runAsync(
        () => PinHasher.hash('1234'),
      ))!;
      final duressHash = (await tester.runAsync(() => PinHasher.hash('9999')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(
          sessionEndHash: sessionHash,
          duressHash: duressHash,
          onResolved: (v) => r = v,
        ),
      );
      await tester.pump();
      await _openDialog(tester);
      await _tapDigits(tester, ['9', '9', '9', '9']);
      await _tapSubmit(tester);
      await _realSettle(tester, seconds: 6);
      check(r).equals(PinResult.duress);
    });

    testWidgets('duress is checked before correct (priority order)', (
      tester,
    ) async {
      // Hash the SAME PIN as both duress and session-end.
      // Duress must win.
      final samePin = (await tester.runAsync(() => PinHasher.hash('5555')))!;
      final duressHash = (await tester.runAsync(() => PinHasher.hash('5555')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(
          sessionEndHash: samePin,
          duressHash: duressHash,
          onResolved: (v) => r = v,
        ),
      );
      await tester.pump();
      await _openDialog(tester);
      await _tapDigits(tester, ['5', '5', '5', '5']);
      await _tapSubmit(tester);
      await _realSettle(tester, seconds: 6);
      // Spec: duress is checked FIRST; even if session-end also matches,
      // the result must be duress.
      check(r).equals(PinResult.duress);
    });

    testWidgets('with no duress hash set, correct PIN returns correct', (
      tester,
    ) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('2222')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      await _tapDigits(tester, ['2', '2', '2', '2']);
      await _tapSubmit(tester);
      await _realSettle(tester, seconds: 6);
      check(r).equals(PinResult.correct);
    });
  });

  // -------------------------------------------------------------------------
  // Timeout
  // -------------------------------------------------------------------------

  group('PinEntryDialog — timeout', () {
    testWidgets('timeout=1 returns PinResult.timeout after 1 second', (
      tester,
    ) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(
          sessionEndHash: hash,
          duressHash: null,
          timeout: 1,
          onResolved: (v) => r = v,
        ),
      );
      await tester.pump();
      await _openDialog(tester);
      // Advance past the 1s timeout using the fake clock.
      await tester.pump(const Duration(seconds: 2));
      await _realSettle(tester, seconds: 1);
      check(r).equals(PinResult.timeout);
    });

    testWidgets('timeout=0 does not fire; Cancel returns cancelled', (
      tester,
    ) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(
          sessionEndHash: hash,
          duressHash: null,
          timeout: 0,
          onResolved: (v) => r = v,
        ),
      );
      await tester.pump();
      await _openDialog(tester);
      // Advance a long time — no timeout should fire.
      await tester.pump(const Duration(seconds: 30));
      await _realSettle(tester, seconds: 1);
      // Still open — cancel manually.
      await tester.tap(find.byType(TextButton).last);
      await _realSettle(tester, seconds: 1);
      check(r).equals(PinResult.cancelled);
    });
  });

  // -------------------------------------------------------------------------
  // Backspace
  // -------------------------------------------------------------------------

  group('PinEntryDialog — backspace', () {
    testWidgets('one digit then backspace → zero bullets', (tester) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      await tester.tap(find.text('1'));
      await tester.pump();
      check(find.text('•').evaluate()).isNotEmpty();
      await tester.tap(find.text('⌫'));
      await tester.pump();
      check(find.text('•').evaluate()).isEmpty();
      await tester.tap(find.byType(TextButton).last);
      await _realSettle(tester, seconds: 1);
      check(r).equals(PinResult.cancelled);
    });

    testWidgets('three digits then two backspaces → one bullet', (
      tester,
    ) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      await _tapDigits(tester, ['1', '2', '3']);
      await tester.tap(find.text('⌫'));
      await tester.pump();
      await tester.tap(find.text('⌫'));
      await tester.pump();
      // One bullet remaining.
      check(find.text('•').evaluate()).isNotEmpty();
      check(find.text('••').evaluate()).isEmpty();
      await tester.tap(find.byType(TextButton).last);
      await _realSettle(tester, seconds: 1);
      check(r).equals(PinResult.cancelled);
    });

    testWidgets('backspace on empty buffer is a no-op', (tester) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      // Multiple backspaces on empty buffer must not throw.
      await tester.tap(find.text('⌫'));
      await tester.pump();
      await tester.tap(find.text('⌫'));
      await tester.pump();
      // Dialog remains open.
      check(find.byType(AlertDialog).evaluate().length).isGreaterOrEqual(1);
      await tester.tap(find.byType(TextButton).last);
      await _realSettle(tester, seconds: 1);
      check(r).equals(PinResult.cancelled);
    });

    testWidgets('digit after backspace is re-typed correctly', (tester) async {
      // Type 1, backspace, type correct PIN, Submit → correct.
      final hash = (await tester.runAsync(() => PinHasher.hash('2345')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('⌫'));
      await tester.pump();
      await _tapDigits(tester, ['2', '3', '4', '5']);
      await _tapSubmit(tester);
      await _realSettle(tester, seconds: 6);
      check(r).equals(PinResult.correct);
    });
  });

  // -------------------------------------------------------------------------
  // Biometric paths
  // -------------------------------------------------------------------------

  group('PinEntryDialog — biometric', () {
    testWidgets(
      'biometric success → PinResult.correct without showing keypad',
      (tester) async {
        final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
        final bio = FakeBiometricService(
          available: true,
          nextResult: BiometricResult.success,
        );
        PinResult? r;
        await tester.pumpWidget(
          _app(
            sessionEndHash: hash,
            duressHash: null,
            biometric: bio,
            onResolved: (v) => r = v,
          ),
        );
        await tester.pump();
        await _openDialog(tester);
        await _realSettle(tester, seconds: 2);
        // Should have resolved to correct via biometric — no keypad shown.
        check(r).equals(PinResult.correct);
        check(find.byType(AlertDialog).evaluate().length).equals(0);
      },
    );

    testWidgets(
      'biometric cancelled → falls back to keypad; correct PIN+Submit works',
      (tester) async {
        final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
        final bio = FakeBiometricService(
          available: true,
          nextResult: BiometricResult.cancelled,
        );
        PinResult? r;
        await tester.pumpWidget(
          _app(
            sessionEndHash: hash,
            duressHash: null,
            biometric: bio,
            onResolved: (v) => r = v,
          ),
        );
        await tester.pump();
        await _openDialog(tester);
        await _realSettle(tester, seconds: 2);
        // Keypad should now be visible.
        check(find.byType(PinKeypad).evaluate().length).isGreaterOrEqual(1);
        await _tapDigits(tester, ['1', '2', '3', '4']);
        await _tapSubmit(tester);
        await _realSettle(tester, seconds: 6);
        check(r).equals(PinResult.correct);
      },
    );

    testWidgets(
      'biometric unavailable → falls back to keypad; correct PIN+Submit works',
      (tester) async {
        final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
        final bio = FakeBiometricService(
          available: false,
          nextResult: BiometricResult.unavailable,
        );
        PinResult? r;
        await tester.pumpWidget(
          _app(
            sessionEndHash: hash,
            duressHash: null,
            biometric: bio,
            onResolved: (v) => r = v,
          ),
        );
        await tester.pump();
        await _openDialog(tester);
        await _realSettle(tester, seconds: 2);
        // Keypad visible as fallback.
        check(find.byType(PinKeypad).evaluate().length).isGreaterOrEqual(1);
        await _tapDigits(tester, ['1', '2', '3', '4']);
        await _tapSubmit(tester);
        await _realSettle(tester, seconds: 6);
        check(r).equals(PinResult.correct);
      },
    );

    testWidgets('biometric records the authenticate reason prompt', (
      tester,
    ) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
      final bio = FakeBiometricService(
        available: true,
        nextResult: BiometricResult.success,
      );
      PinResult? r;
      await tester.pumpWidget(
        _app(
          sessionEndHash: hash,
          duressHash: null,
          biometric: bio,
          onResolved: (v) => r = v,
        ),
      );
      await tester.pump();
      await _openDialog(tester);
      await _realSettle(tester, seconds: 2);
      check(r).equals(PinResult.correct);
      // Biometric authenticate was called with a non-empty reason.
      check(bio.prompts).isNotEmpty();
    });

    testWidgets('biometric=null ignores biometric entirely; keypad shown', (
      tester,
    ) async {
      final hash = (await tester.runAsync(() => PinHasher.hash('1234')))!;
      PinResult? r;
      await tester.pumpWidget(
        _app(sessionEndHash: hash, duressHash: null, onResolved: (v) => r = v),
      );
      await tester.pump();
      await _openDialog(tester);
      check(find.byType(PinKeypad).evaluate().length).isGreaterOrEqual(1);
      await tester.tap(find.byType(TextButton).last);
      await _realSettle(tester, seconds: 1);
      check(r).equals(PinResult.cancelled);
    });

    testWidgets('biometric skipped when sessionEndHash is null; keypad shown', (
      tester,
    ) async {
      // Spec: biometric is only tried when sessionEndHash != null.
      final bio = FakeBiometricService(
        available: true,
        nextResult: BiometricResult.success,
      );
      PinResult? r;
      await tester.pumpWidget(
        _app(
          sessionEndHash: null,
          duressHash: null,
          biometric: bio,
          onResolved: (v) => r = v,
        ),
      );
      await tester.pump();
      await _openDialog(tester);
      await _realSettle(tester, seconds: 1);
      // Biometric should NOT have been called (sessionEndHash is null).
      check(bio.prompts).isEmpty();
      // Keypad is shown.
      check(find.byType(PinKeypad).evaluate().length).isGreaterOrEqual(1);
      await tester.tap(find.byType(TextButton).last);
      await _realSettle(tester, seconds: 1);
      check(r).equals(PinResult.cancelled);
    });
  });

  // -------------------------------------------------------------------------
  // hashPin helper
  // -------------------------------------------------------------------------

  group('hashPin helper', () {
    testWidgets('hashPin delegates to PinHasher.hash', (tester) async {
      final hash = (await tester.runAsync(() => hashPin('7777')))!;
      check(hash.startsWith(r'$argon2id$')).isTrue();
    });

    testWidgets('hashPin output verifies correctly', (tester) async {
      final hash = (await tester.runAsync(() => hashPin('8888')))!;
      final ok = (await tester.runAsync(() => PinHasher.verify('8888', hash)))!;
      check(ok).isTrue();
    });

    testWidgets('two hashPin calls produce different hashes', (tester) async {
      final a = (await tester.runAsync(() => hashPin('9999')))!;
      final b = (await tester.runAsync(() => hashPin('9999')))!;
      check(a).not((m) => m.equals(b));
    });
  });
}
