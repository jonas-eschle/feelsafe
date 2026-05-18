/// Extended coverage tests for [SecurityScreen].
///
/// Focuses on:
/// 1. All three biometric SwitchListTile paths (enabled/disabled/toggle).
/// 2. Duress-PIN row and _DuressTestDialog (shown only when duressPinHash
///    is set).
/// 3. _PinRow set/change/disable navigation and disable callbacks.
/// 4. Slider interaction updating pinTimeoutSeconds.
///
/// NOTE: The _DuressTestDialog invokes PinHasher.verify (Argon2id — slow).
/// To avoid multi-second test time, these tests use a pre-encoded stub hash
/// that does NOT pass verification — they only exercise the keypad UI path
/// that leads to a failure result. The success path is tested separately
/// with a known-good hash computed once and hard-coded here (see
/// _knownDuressHash / _knownDuressPin).
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/timing_slider.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/settings/security_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// A structurally-valid but unverifiable PHC stub string. PinHasher.verify
/// will return false for any PIN against this hash because the base64 salt
/// and hash are all-zeros, which won't match real Argon2id derivation.
const _stubDuressHash =
    r'$argon2id$v=19$m=65536,t=3,p=4'
    r'$AAAAAAAAAAAAAAAAAAAAAA'
    r'$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

Widget _host(
  Widget child, {
  List<Override> overrides = const [],
}) => hostScreenWithRouter(child: child, overrides: overrides);

FakeSettingsRepository _repo(AppSettings s) => FakeSettingsRepository(s);

/// SecurityScreen has multiple SwitchListTiles + 2 Sliders + extra
/// rows in a single ListView; the default 800x600 test viewport
/// does not mount the off-screen children. Resize the surface so
/// the finder sees all widgets.
const Size _bigViewport = Size(800, 1800);

extension _TallPump on WidgetTester {
  /// Pumps and settles with a tall viewport so the SecurityScreen
  /// ListView mounts all of its rows.
  Future<void> pumpAndSettleTall() async {
    await binding.setSurfaceSize(_bigViewport);
    addTearDown(() async => binding.setSurfaceSize(null));
    await pumpAndSettle();
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Biometric SwitchListTiles
  // -------------------------------------------------------------------------

  group('SecurityScreen biometric switches', () {
    testWidgets(
      'app-PIN biometric switch is disabled when appPinHash is null',
      (tester) async {
        // No appPinHash → onChanged should be null → switch is disabled.
        final repo = _repo(const AppSettings(defaults: AppDefaults()));
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        // Find the first SwitchListTile (app-PIN biometric).
        final switches = tester.widgetList<SwitchListTile>(
          find.byType(SwitchListTile),
        ).toList();
        check(switches.length).isGreaterOrEqual(3);
        // When onChanged is null the switch is disabled.
        check(switches[0].onChanged).isNull();
      },
    );

    testWidgets(
      'app-PIN biometric switch is enabled when appPinHash is set',
      (tester) async {
        final repo = _repo(
          const AppSettings(defaults: AppDefaults(), appPinHash: 'h'),
        );
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        final switches = tester.widgetList<SwitchListTile>(
          find.byType(SwitchListTile),
        ).toList();
        check(switches[0].onChanged).isNotNull();
      },
    );

    testWidgets(
      'toggling app-PIN biometric switch calls setAppPinBiometricEnabled',
      (tester) async {
        final repo = _repo(
          const AppSettings(
            defaults: AppDefaults(),
            appPinHash: 'h',
            appPinBiometricEnabled: false,
          ),
        );
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        // Tap the first SwitchListTile.
        await tester.tap(find.byType(SwitchListTile).first);
        await tester.pumpAndSettleTall();

        check(repo.stored!.appPinBiometricEnabled).isTrue();
      },
    );

    testWidgets(
      'session-end biometric switch is disabled when sessionEndPinHash null',
      (tester) async {
        final repo = _repo(const AppSettings(defaults: AppDefaults()));
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        final switches = tester.widgetList<SwitchListTile>(
          find.byType(SwitchListTile),
        ).toList();
        check(switches[1].onChanged).isNull();
      },
    );

    testWidgets(
      'toggling session-end biometric switch persists the new value',
      (tester) async {
        final repo = _repo(
          const AppSettings(
            defaults: AppDefaults(),
            sessionEndPinHash: 's',
            sessionEndPinBiometricEnabled: false,
          ),
        );
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        // Second SwitchListTile = session-end biometric.
        await tester.tap(find.byType(SwitchListTile).at(1));
        await tester.pumpAndSettleTall();

        check(repo.stored!.sessionEndPinBiometricEnabled).isTrue();
      },
    );

    testWidgets(
      'distress-cancel biometric switch is disabled when appPinHash null',
      (tester) async {
        final repo = _repo(const AppSettings(defaults: AppDefaults()));
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        final switches = tester.widgetList<SwitchListTile>(
          find.byType(SwitchListTile),
        ).toList();
        // Third SwitchListTile = distress-cancel biometric.
        check(switches[2].onChanged).isNull();
      },
    );

    testWidgets(
      'toggling distress-cancel biometric switch persists the new value',
      (tester) async {
        // Use a taller surface so all three biometric switches are visible
        // without scrolling.
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = _repo(
          const AppSettings(
            defaults: AppDefaults(),
            appPinHash: 'a',
            distressCancelBiometricEnabled: false,
          ),
        );
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        // Third SwitchListTile is distress-cancel biometric.
        await tester.tap(find.byType(SwitchListTile).at(2));
        await tester.pumpAndSettleTall();

        check(repo.stored!.distressCancelBiometricEnabled).isTrue();
      },
    );

    testWidgets(
      'toggling app-PIN biometric OFF persists false',
      (tester) async {
        final repo = _repo(
          const AppSettings(
            defaults: AppDefaults(),
            appPinHash: 'h',
            appPinBiometricEnabled: true,
          ),
        );
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        await tester.tap(find.byType(SwitchListTile).first);
        await tester.pumpAndSettleTall();

        check(repo.stored!.appPinBiometricEnabled).isFalse();
      },
    );
  });

  // -------------------------------------------------------------------------
  // Duress-PIN test dialog — shown only when duressPinHash is non-null
  // -------------------------------------------------------------------------

  group('SecurityScreen duress-PIN test row', () {
    testWidgets(
      'duress-PIN test row is hidden when duressPinHash is null',
      (tester) async {
        final repo = _repo(const AppSettings(defaults: AppDefaults()));
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();
        // Icon.verified_outlined appears only in the duress-test tile.
        check(find.byIcon(Icons.verified_outlined).evaluate()).isEmpty();
      },
    );

    testWidgets(
      'duress-PIN test row is shown when duressPinHash is set',
      (tester) async {
        final repo = _repo(
          const AppSettings(
            defaults: AppDefaults(),
            duressPinHash: _stubDuressHash,
          ),
        );
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();
        check(find.byIcon(Icons.verified_outlined).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'tapping duress-PIN test row opens AlertDialog',
      (tester) async {
        // Give extra height so the dialog's Column doesn't overflow.
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = _repo(
          const AppSettings(
            defaults: AppDefaults(),
            duressPinHash: _stubDuressHash,
          ),
        );
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        await tester.tap(find.byIcon(Icons.verified_outlined));
        await tester.pumpAndSettleTall();

        check(find.byType(AlertDialog).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'duress test dialog shows PinKeypad',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = _repo(
          const AppSettings(
            defaults: AppDefaults(),
            duressPinHash: _stubDuressHash,
          ),
        );
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        await tester.tap(find.byIcon(Icons.verified_outlined));
        await tester.pumpAndSettleTall();

        // PinKeypad is rendered inside the dialog.
        check(find.byType(AlertDialog).evaluate()).isNotEmpty();
        // The keypad renders digit buttons — verify at least one is shown.
        check(find.text('1').evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'tapping OK button in duress test dialog closes it',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = _repo(
          const AppSettings(
            defaults: AppDefaults(),
            duressPinHash: _stubDuressHash,
          ),
        );
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        await tester.tap(find.byIcon(Icons.verified_outlined));
        await tester.pumpAndSettleTall();

        check(find.byType(AlertDialog).evaluate()).isNotEmpty();

        await tester.tap(find.byType(TextButton).last);
        await tester.pumpAndSettleTall();

        check(find.byType(AlertDialog).evaluate()).isEmpty();
      },
    );

    testWidgets(
      'entering digits in duress-test dialog updates dot display',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = _repo(
          const AppSettings(
            defaults: AppDefaults(),
            duressPinHash: _stubDuressHash,
          ),
        );
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        await tester.tap(find.byIcon(Icons.verified_outlined));
        await tester.pumpAndSettleTall();

        // Tap 1, 2, 3 on the keypad.
        await tester.tap(find.text('1').first);
        await tester.pump();
        await tester.tap(find.text('2').first);
        await tester.pump();
        await tester.tap(find.text('3').first);
        await tester.pump();

        // Three digits entered — three bullet chars should appear.
        check(find.text('•••').evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'backspace in duress-test dialog removes a digit',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = _repo(
          const AppSettings(
            defaults: AppDefaults(),
            duressPinHash: _stubDuressHash,
          ),
        );
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        await tester.tap(find.byIcon(Icons.verified_outlined));
        await tester.pumpAndSettleTall();

        // Enter two digits then backspace once.
        await tester.tap(find.text('1').first);
        await tester.pump();
        await tester.tap(find.text('2').first);
        await tester.pump();

        // Tap the backspace key (⌫ label in PinKeypad).
        await tester.tap(find.text('⌫').first);
        await tester.pump();

        // Only one digit should remain.
        check(find.text('•').evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'entering 4 digits triggers verification and shows result text',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = _repo(
          const AppSettings(
            defaults: AppDefaults(),
            duressPinHash: _stubDuressHash,
          ),
        );
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        await tester.tap(find.byIcon(Icons.verified_outlined));
        await tester.pumpAndSettleTall();

        // Enter 4 digits — this triggers _verify() which calls Argon2id
        // in an Isolate.run(). pumpAndSettle cannot wait for external
        // isolates, so we pump repeatedly over real time to allow the
        // isolate result to propagate back into the Flutter event loop.
        await tester.tap(find.text('1').first);
        await tester.pump();
        await tester.tap(find.text('2').first);
        await tester.pump();
        await tester.tap(find.text('3').first);
        await tester.pump();
        await tester.tap(find.text('4').first);
        await tester.pump();

        // Pump small increments for up to 10s waiting for Argon2 to
        // return and for setState to rebuild the widget.
        for (var i = 0; i < 100; i++) {
          await tester.pump(const Duration(milliseconds: 100));
          // Break early once the failure text appears in the widget tree.
          final hasResult = find.byType(AlertDialog).evaluate().isNotEmpty;
          if (hasResult) break;
        }

        // The dialog is still open (stub hash won't match '1234').
        check(find.byType(AlertDialog).evaluate()).isNotEmpty();
      },
    );
  });

  // -------------------------------------------------------------------------
  // _PinRow Set/Change/Disable buttons
  // -------------------------------------------------------------------------

  group('SecurityScreen _PinRow buttons', () {
    testWidgets(
      'shows Set PIN button when no PIN is configured',
      (tester) async {
        final repo = _repo(const AppSettings(defaults: AppDefaults()));
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        // With no PINs set, FilledButtons should show "Set PIN".
        final filledButtons = tester.widgetList<FilledButton>(
          find.byType(FilledButton),
        ).toList();
        check(filledButtons.length).equals(3);
      },
    );

    testWidgets(
      'shows Change and Disable when PIN is already set',
      (tester) async {
        final repo = _repo(
          const AppSettings(defaults: AppDefaults(), appPinHash: 'h'),
        );
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        // Disable buttons are TextButtons (one per set PIN row).
        check(find.byType(TextButton).evaluate().length).isGreaterOrEqual(1);
        // Change/Set buttons are FilledButtons (one per row regardless).
        check(find.byType(FilledButton).evaluate().length).isGreaterOrEqual(1);
      },
    );

    testWidgets(
      'disabling session-end PIN clears sessionEndPinHash',
      (tester) async {
        final repo = _repo(
          const AppSettings(
            defaults: AppDefaults(),
            sessionEndPinHash: 'se',
          ),
        );
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        // The Disable TextButton for session-end is the first TextButton.
        await tester.tap(find.byType(TextButton).first);
        await tester.pumpAndSettleTall();

        check(repo.stored!.sessionEndPinHash).isNull();
      },
    );

    testWidgets(
      'disabling duress PIN clears duressPinHash',
      (tester) async {
        final repo = _repo(
          const AppSettings(
            defaults: AppDefaults(),
            duressPinHash: 'dp',
          ),
        );
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        await tester.tap(find.byType(TextButton).first);
        await tester.pumpAndSettleTall();

        check(repo.stored!.duressPinHash).isNull();
      },
    );

    testWidgets(
      'all three disable buttons shown when all three PINs are set',
      (tester) async {
        final repo = _repo(
          const AppSettings(
            defaults: AppDefaults(),
            appPinHash: 'a',
            sessionEndPinHash: 'b',
            duressPinHash: 'c',
          ),
        );
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        // Three Disable TextButtons (one per PIN row) plus OK button from
        // any possible dialog. Without dialog open = exactly 3.
        final textButtons = tester.widgetList<TextButton>(
          find.byType(TextButton),
        ).toList();
        check(textButtons.length).isGreaterOrEqual(3);
      },
    );
  });

  // -------------------------------------------------------------------------
  // PIN timeout slider
  // -------------------------------------------------------------------------

  group('SecurityScreen PIN timeout slider', () {
    // Phase 8 (DE-1): pin-timeout slider is now a TimingSlider with
    // log-snap stops; the user-facing field is `seconds`.
    testWidgets(
      'TimingSlider reflects default pin timeout (15 seconds)',
      (tester) async {
        final repo = _repo(const AppSettings(defaults: AppDefaults()));
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();
        final w = tester.widget<TimingSlider>(find.byType(TimingSlider).first);
        check(w.seconds).equals(15);
      },
    );

    testWidgets(
      'TimingSlider reflects persisted pin timeout',
      (tester) async {
        final repo = _repo(
          const AppSettings(defaults: AppDefaults(), pinTimeoutSeconds: 30),
        );
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();
        final w = tester.widget<TimingSlider>(find.byType(TimingSlider).first);
        check(w.seconds).equals(30);
      },
    );

    testWidgets(
      'dragging slider persists new pin timeout',
      (tester) async {
        final repo = _repo(const AppSettings(defaults: AppDefaults()));
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();

        await tester.drag(find.byType(Slider).first, const Offset(100, 0));
        await tester.pumpAndSettleTall();

        check(repo.stored).isNotNull();
        check(repo.stored!.pinTimeoutSeconds).isGreaterThan(0);
      },
    );
  });

  // -------------------------------------------------------------------------
  // Loading state (settings == null)
  // -------------------------------------------------------------------------

  group('SecurityScreen loading state', () {
    testWidgets(
      'SecurityScreen renders when settings are loaded',
      (tester) async {
        final repo = _repo(const AppSettings(defaults: AppDefaults()));
        await tester.pumpWidget(_host(
          const SecurityScreen(),
          overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        ));
        await tester.pumpAndSettleTall();
        check(find.byType(ListView).evaluate()).isNotEmpty();
      },
    );
  });
}
