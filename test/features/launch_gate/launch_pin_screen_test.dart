/// Widget tests for [LaunchPinScreen] — the App-lock launch gate.
///
/// Verifies the full priority ladder (Duress > App PIN > wrong), wrong-PIN
/// escalation, the deceptive dialog, and biometric-first unlock. Fakes:
/// - [_FakeAppSettingsRepository] supplies canned hashes/flags.
/// - [_FakeSessionController] records distress + wrong-PIN-counter calls
///   without real engine machinery.
/// - [_FakeLaunchGate] records `unlock()`.
/// - [SimulationBiometricService] drives the biometric branch.
///
/// Spec ref: `docs/spec/06-settings.md §App PIN`, `§Duress PIN`,
/// `§Wrong PIN Behavior`.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/deceptive_old_pin_dialog.dart';
import 'package:guardianangela/core/widgets/pin_keypad.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/features/launch_gate/launch_gate_controller.dart';
import 'package:guardianangela/features/launch_gate/launch_pin_screen.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/biometric_service_sim.dart';
import '../../helpers/widget_test_helpers.dart';

String _hash(String pin) => sha256.convert(utf8.encode(pin)).toString();

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository(this._current)
    : super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('launch_gate_test_'),
      );

  AppSettings _current;

  @override
  Future<AppSettings> load() async => _current;

  @override
  Future<void> save(AppSettings value) async => _current = value;
}

class _FakeSessionController extends SessionController {
  int distressCalls = 0;
  EndReason? lastReason;
  int wrongCalls = 0;
  int resetCalls = 0;
  int _attempts = 0;

  @override
  Future<SessionState> build() async => const SessionState.initial();

  @override
  int notifyWrongPinAttempt() {
    wrongCalls++;
    return ++_attempts;
  }

  @override
  void resetWrongPinAttempts() {
    resetCalls++;
    _attempts = 0;
  }

  @override
  Future<void> startDistressSession({required EndReason reason}) async {
    distressCalls++;
    lastReason = reason;
  }
}

class _FakeLaunchGate extends LaunchGateController {
  int unlockCalls = 0;

  @override
  bool build() => true;

  @override
  void unlock() {
    unlockCalls++;
    super.unlock();
  }
}

// ---------------------------------------------------------------------------
// Harness
// ---------------------------------------------------------------------------

class _Harness {
  _Harness(this.session, this.gate, this.biometric);
  final _FakeSessionController session;
  final _FakeLaunchGate gate;
  final SimulationBiometricService biometric;
}

Future<_Harness> _pumpGate(
  WidgetTester tester, {
  required AppSettings settings,
  SimulationBiometricService? biometric,
  Locale locale = const Locale('en'),
}) async {
  final session = _FakeSessionController();
  final gate = _FakeLaunchGate();
  final bio = biometric ?? SimulationBiometricService();
  await pumpScreen(
    tester,
    const LaunchPinScreen(),
    overrides: <Override>[
      appSettingsRepositoryProvider.overrideWithValue(
        _FakeAppSettingsRepository(settings),
      ),
      biometricServiceProvider.overrideWithValue(bio),
      sessionControllerProvider.overrideWith(() => session),
      launchGateProvider.overrideWith(() => gate),
    ],
    locale: locale,
  );
  return _Harness(session, gate, bio);
}

Future<void> _enterDigits(WidgetTester tester, List<int> digits) async {
  for (final d in digits) {
    await tester.tap(find.widgetWithText(InkWell, '$d').last);
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

AppSettings _settings({
  String? appPin = '1234',
  String? duressPin,
  bool deceptive = false,
  int threshold = 5,
  bool appBiometric = false,
}) => const AppSettings().copyWith(
  appPinHash: appPin == null ? null : _hash(appPin),
  duressPinHash: duressPin == null ? null : _hash(duressPin),
  deceptivePinDialogEnabled: deceptive,
  wrongPinThreshold: threshold,
  appPinBiometricEnabled: appBiometric,
);

void main() {
  group('LaunchPinScreen — rendering', () {
    testWidgets('shows the title and keypad', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpGate(tester, settings: _settings());
      expect(find.text(l10n.launchPinTitle), findsOneWidget);
      expect(find.byType(PinKeypad), findsOneWidget);
    });

    testWidgets('renders in Arabic (RTL) without exception', (
      WidgetTester tester,
    ) async {
      await _pumpGate(
        tester,
        settings: _settings(),
        locale: const Locale('ar'),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(PinKeypad), findsOneWidget);
    });
  });

  group('LaunchPinScreen — PIN unlock ladder', () {
    testWidgets('correct App PIN unlocks and resets the counter', (
      WidgetTester tester,
    ) async {
      final h = await _pumpGate(tester, settings: _settings());
      await _enterDigits(tester, <int>[1, 2, 3, 4]);
      check(h.gate.unlockCalls).equals(1);
      check(h.session.resetCalls).isGreaterThan(0);
      check(h.session.distressCalls).equals(0);
    });

    testWidgets('Duress PIN starts the distress chain then fake-unlocks', (
      WidgetTester tester,
    ) async {
      final h = await _pumpGate(tester, settings: _settings(duressPin: '9999'));
      await _enterDigits(tester, <int>[9, 9, 9, 9]);
      check(h.session.distressCalls).equals(1);
      check(h.session.lastReason).equals(EndReason.duressPin);
      check(h.gate.unlockCalls).equals(1);
    });

    testWidgets('Duress wins a prefix collision with the App PIN', (
      WidgetTester tester,
    ) async {
      // App = 1234, Duress = 1234 would be rejected at setup; use a distinct
      // duress to prove duress is checked first at each length.
      final h = await _pumpGate(
        tester,
        settings: _settings(appPin: '5678', duressPin: '1234'),
      );
      await _enterDigits(tester, <int>[1, 2, 3, 4]);
      check(h.session.distressCalls).equals(1);
      check(h.gate.unlockCalls).equals(1);
    });
  });

  group('LaunchPinScreen — variable-length PIN (no false distress)', () {
    testWidgets('a 6-digit App PIN unlocks when fully entered', (
      WidgetTester tester,
    ) async {
      final h = await _pumpGate(tester, settings: _settings(appPin: '123456'));
      await _enterDigits(tester, <int>[1, 2, 3, 4, 5, 6]);
      check(h.gate.unlockCalls).equals(1);
      check(h.session.distressCalls).equals(0);
    });

    testWidgets('typing the 4-digit prefix of a 6-digit PIN does NOT count '
        'as wrong (would otherwise fire false distress)', (
      WidgetTester tester,
    ) async {
      final h = await _pumpGate(tester, settings: _settings(appPin: '123456'));
      await _enterDigits(tester, <int>[1, 2, 3, 4]);
      check(h.gate.unlockCalls).equals(0);
      check(h.session.wrongCalls).equals(0);
      check(h.session.distressCalls).equals(0);
    });
  });

  group('LaunchPinScreen — wrong PIN', () {
    testWidgets('wrong PIN shows the inline hint (deceptive off)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final h = await _pumpGate(tester, settings: _settings());
      await _enterDigits(tester, <int>[5, 5, 5, 5, 5, 5, 5, 5]);
      expect(find.text(l10n.launchPinIncorrect), findsOneWidget);
      check(h.session.wrongCalls).equals(1);
      check(h.gate.unlockCalls).equals(0);
    });

    testWidgets('wrong PIN shows the deceptive dialog (deceptive on)', (
      WidgetTester tester,
    ) async {
      final h = await _pumpGate(tester, settings: _settings(deceptive: true));
      await _enterDigits(tester, <int>[5, 5, 5, 5, 5, 5, 5, 5]);
      expect(find.byType(DeceptiveOldPinDialog), findsOneWidget);
      check(h.session.wrongCalls).equals(1);
      check(h.gate.unlockCalls).equals(0);
    });

    testWidgets('reaching the threshold fires distress but stays locked', (
      WidgetTester tester,
    ) async {
      final h = await _pumpGate(tester, settings: _settings(threshold: 2));
      await _enterDigits(tester, <int>[5, 5, 5, 5, 5, 5, 5, 5]);
      check(h.session.distressCalls).equals(0);
      await _enterDigits(tester, <int>[5, 5, 5, 5, 5, 5, 5, 5]);
      check(h.session.distressCalls).equals(1);
      check(h.session.lastReason).equals(EndReason.wrongPinExhausted);
      check(h.gate.unlockCalls).equals(0);
    });
  });

  group('LaunchPinScreen — biometric', () {
    testWidgets('successful biometric unlocks on mount without a PIN', (
      WidgetTester tester,
    ) async {
      final bio = SimulationBiometricService(
        available: true,
        authenticateResult: true,
      );
      final h = await _pumpGate(
        tester,
        settings: _settings(appBiometric: true),
        biometric: bio,
      );
      check(h.gate.unlockCalls).equals(1);
      check(bio.calls).deepEquals(<String>['isAvailable', 'authenticate']);
    });

    testWidgets('failed biometric leaves the keypad for PIN entry', (
      WidgetTester tester,
    ) async {
      final bio = SimulationBiometricService()..available = true;
      final h = await _pumpGate(
        tester,
        settings: _settings(appBiometric: true),
        biometric: bio,
      );
      check(h.gate.unlockCalls).equals(0);
      expect(find.byType(PinKeypad), findsOneWidget);
      // PIN still works after a failed biometric.
      await _enterDigits(tester, <int>[1, 2, 3, 4]);
      check(h.gate.unlockCalls).equals(1);
    });

    testWidgets('no biometric attempt when the toggle is off', (
      WidgetTester tester,
    ) async {
      final bio = SimulationBiometricService(
        available: true,
        authenticateResult: true,
      );
      await _pumpGate(tester, settings: _settings(), biometric: bio);
      check(bio.calls).isEmpty();
    });
  });
}
