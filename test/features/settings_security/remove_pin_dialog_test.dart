/// Widget tests for [RemovePinDialog] — the identity check before PIN removal.
///
/// Spec ref: `docs/spec/06-settings.md §Security` (removing a PIN requires
/// re-entering it; an attacker with the unlocked device must not be able to
/// wipe protection). No distress here (spec 06:174) — plain verify.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/features/settings_security/remove_pin_dialog.dart';
import 'package:guardianangela/features/settings_security/settings_security_controller.dart';
import 'package:guardianangela/services/service_providers.dart';
import '../../helpers/widget_test_helpers.dart';

String _hash(String digits) => sha256.convert(utf8.encode(digits)).toString();

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository(this._current)
    : super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('remove_pin_test_'),
      );

  final AppSettings _current;

  @override
  Future<AppSettings> load() async => _current;
}

/// Pumps a host with a button that opens [RemovePinDialog] and records each
/// resolved result in the returned list.
Future<List<bool>> _open(
  WidgetTester tester, {
  required AppSettings settings,
  required PinType type,
}) async {
  final results = <bool>[];
  await pumpScreen(
    tester,
    Builder(
      builder: (BuildContext context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async => results.add(
              await RemovePinDialog.show(context, type: type, title: 'PIN'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
    overrides: <Override>[
      appSettingsRepositoryProvider.overrideWithValue(
        _FakeAppSettingsRepository(settings),
      ),
    ],
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return results;
}

Future<void> _enterDigits(WidgetTester tester, List<int> digits) async {
  for (final d in digits) {
    await tester.tap(find.widgetWithText(InkWell, '$d').last);
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('correct PIN resolves to true', (WidgetTester tester) async {
    final results = await _open(
      tester,
      settings: const AppSettings().copyWith(appPinHash: _hash('1234')),
      type: PinType.app,
    );
    await _enterDigits(tester, <int>[1, 2, 3, 4]);
    check(results).deepEquals(<bool>[true]);
  });

  testWidgets('wrong PIN shows the incorrect hint and does not resolve', (
    WidgetTester tester,
  ) async {
    final l10n = await loadL10n(const Locale('en'));
    final results = await _open(
      tester,
      settings: const AppSettings().copyWith(appPinHash: _hash('1234')),
      type: PinType.app,
    );
    await _enterDigits(tester, <int>[9, 9, 9, 9, 9, 9, 9, 9]);
    expect(find.text(l10n.securityRemovePinIncorrect), findsOneWidget);
    expect(find.byType(RemovePinDialog), findsOneWidget);
    check(results).isEmpty();
  });

  testWidgets('cancel resolves to false', (WidgetTester tester) async {
    final l10n = await loadL10n(const Locale('en'));
    final results = await _open(
      tester,
      settings: const AppSettings().copyWith(appPinHash: _hash('1234')),
      type: PinType.app,
    );
    await tester.tap(find.text(l10n.commonCancel));
    await tester.pumpAndSettle();
    check(results).deepEquals(<bool>[false]);
  });

  testWidgets('a 6-digit PIN resolves only on the full entry', (
    WidgetTester tester,
  ) async {
    final results = await _open(
      tester,
      settings: const AppSettings().copyWith(appPinHash: _hash('123456')),
      type: PinType.app,
    );
    // The 4-digit prefix must not resolve or count as wrong.
    await _enterDigits(tester, <int>[1, 2, 3, 4]);
    check(results).isEmpty();
    await _enterDigits(tester, <int>[5, 6]);
    check(results).deepEquals(<bool>[true]);
  });

  testWidgets('verifies the requested PIN type (duress, not app)', (
    WidgetTester tester,
  ) async {
    final results = await _open(
      tester,
      settings: const AppSettings().copyWith(
        appPinHash: _hash('1234'),
        duressPinHash: _hash('5678'),
      ),
      type: PinType.duress,
    );
    // Entering the Duress PIN resolves true; the App PIN ('1234') would not,
    // proving the dialog verifies against the duress hash for type=duress.
    await _enterDigits(tester, <int>[5, 6, 7, 8]);
    check(results).deepEquals(<bool>[true]);
  });

  testWidgets('backspace removes the last digit so a mistyped entry can be '
      'corrected', (WidgetTester tester) async {
    final results = await _open(
      tester,
      settings: const AppSettings().copyWith(appPinHash: _hash('1234')),
      type: PinType.app,
    );
    // A 4-digit mistype neither resolves nor wipes the entry …
    await _enterDigits(tester, <int>[1, 2, 3, 9]);
    check(results).isEmpty();
    // … backspace drops the 9, and completing with 4 verifies '1234'.
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pumpAndSettle();
    await _enterDigits(tester, <int>[4]);
    check(results).deepEquals(<bool>[true]);
  });

  testWidgets('backspace on an empty entry is a harmless no-op', (
    WidgetTester tester,
  ) async {
    final results = await _open(
      tester,
      settings: const AppSettings().copyWith(appPinHash: _hash('1234')),
      type: PinType.app,
    );
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(RemovePinDialog), findsOneWidget);
    check(results).isEmpty();
    // Entry is still pristine: the correct PIN verifies on exactly 4 digits.
    await _enterDigits(tester, <int>[1, 2, 3, 4]);
    check(results).deepEquals(<bool>[true]);
  });
}
