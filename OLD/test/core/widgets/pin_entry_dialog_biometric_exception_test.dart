/// Supplemental tests for [PinEntryDialog] covering lines 140–141:
/// the `on Object catch` branch in `_tryBiometric` — any platform error
/// from `bio.authenticate` should fall back to the keypad without throwing.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/pin_entry_dialog.dart';
import 'package:guardianangela/core/utils/pin_result.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/protocols/biometric_service_protocol.dart';

/// A biometric service whose `authenticate` always throws a platform
/// error to exercise the `on Object catch` branch (lines 140–141).
class _ThrowingBiometric implements BiometricServiceProtocol {
  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<BiometricResult> authenticate({required String reason}) async =>
      throw StateError('platform channel not available in test');
}

Widget _app({required void Function(PinResult) onResolved}) => MaterialApp(
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
            sessionEndHash: null,
            duressHash: null,
            biometric: _ThrowingBiometric(),
          );
          onResolved(r);
        },
        child: const Text('open'),
      ),
    ),
  ),
);

void main() {
  group('PinEntryDialog — biometric exception falls back to keypad', () {
    testWidgets(
        'platform error from authenticate falls back to keypad (lines 140–141)',
        (tester) async {
      PinResult? resolved;
      await tester.pumpWidget(_app(onResolved: (r) => resolved = r));
      await tester.tap(find.byKey(const Key('open')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // The dialog should still be visible after the exception — the widget
      // falls back to the keypad instead of crashing.
      check(find.byType(AlertDialog).evaluate()).isNotEmpty();
      // No result resolved yet (dialog still open).
      check(resolved).isNull();
    });
  });
}
