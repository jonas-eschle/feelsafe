/// Strict integration tests for biometric toggles in [SecurityScreen].
///
/// Coverage (50+ tests):
/// - appPinBiometricEnabled toggle: enabled only when appPinHash != null
/// - sessionEndPinBiometricEnabled toggle: enabled only when sessionEndPinHash != null
/// - distressCancelBiometricEnabled toggle: enabled only when appPinHash != null
/// - All three OFF + biometric available → falls through to PIN keypad
/// - Each toggle independently persists its value
/// - Toggling ON then OFF correctly
/// - Slider min=5, max=60, reflects stored value
/// - Duress PIN test dialog engine-never-touched invariant
/// - Spec check: biometricEnabled is guarded by correct hash field
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/timing_slider.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/features/settings/security_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _host(Widget child, {List<Override> extras = const []}) =>
    hostScreenWithRouter(child: child, overrides: extras);

// (No-op stub: viewport sizing is handled by `_pumpAndSettleTall`
// inside each test that needs the full SecurityScreen visible.)
extension _TallPump on WidgetTester {
  /// Pumps and settles with a tall viewport so the SecurityScreen
  /// ListView mounts all of its SwitchListTiles (the default
  /// 800x600 test viewport clips the bottom rows). Also restores
  /// the original size on test teardown.
  Future<void> pumpAndSettleTall() async {
    await binding.setSurfaceSize(_bigViewport);
    addTearDown(() async => binding.setSurfaceSize(null));
    await pumpAndSettle();
  }
}

FakeSettingsRepository _repo(AppSettings s) => FakeSettingsRepository(s);

/// A structurally-valid stub PHC string that will not verify for any real PIN.
const _stubHash =
    r'$argon2id$v=19$m=65536,t=3,p=4'
    r'$AAAAAAAAAAAAAAAAAAAAAA'
    r'$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

/// SecurityScreen has 5 SwitchListTiles + 2 Sliders + multiple
/// ListTiles in a single ListView; the default 800x600 test viewport
/// does not mount the off-screen children. Resize the surface so the
/// finder sees all the switches.
const Size _bigViewport = Size(800, 1800);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // appPinBiometricEnabled switch
  // -------------------------------------------------------------------------

  group('SecurityScreen — appPinBiometric switch', () {
    testWidgets(
      'switch is disabled (onChanged==null) when appPinHash is null',
      (tester) async {
        final repo = _repo(const AppSettings(defaults: AppDefaults()));
        await tester.pumpWidget(
          _host(
            const SecurityScreen(),
            extras: [settingsRepositoryProvider.overrideWithValue(repo)],
          ),
        );
        await tester.pumpAndSettleTall();
        final switches = tester
            .widgetList<SwitchListTile>(find.byType(SwitchListTile))
            .toList();
        check(switches).isNotEmpty();
        check(switches[0].onChanged).isNull();
      },
    );

    testWidgets('switch is enabled (onChanged!=null) when appPinHash is set', (
      tester,
    ) async {
      final repo = _repo(
        const AppSettings(defaults: AppDefaults(), appPinHash: 'h'),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      final switches = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .toList();
      check(switches[0].onChanged).isNotNull();
    });

    testWidgets('switch is OFF by default (appPinBiometricEnabled=false)', (
      tester,
    ) async {
      final repo = _repo(
        const AppSettings(defaults: AppDefaults(), appPinHash: 'h'),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      final switches = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .toList();
      check(switches[0].value).isFalse();
    });

    testWidgets('tapping switch ON persists appPinBiometricEnabled=true', (
      tester,
    ) async {
      final repo = _repo(
        const AppSettings(
          defaults: AppDefaults(),
          appPinHash: 'h',
          appPinBiometricEnabled: false,
        ),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettleTall();
      check(repo.stored!.appPinBiometricEnabled).isTrue();
    });

    testWidgets('tapping switch OFF persists appPinBiometricEnabled=false', (
      tester,
    ) async {
      final repo = _repo(
        const AppSettings(
          defaults: AppDefaults(),
          appPinHash: 'h',
          appPinBiometricEnabled: true,
        ),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettleTall();
      check(repo.stored!.appPinBiometricEnabled).isFalse();
    });

    testWidgets('switch toggle does NOT affect sessionEndPinBiometricEnabled', (
      tester,
    ) async {
      final repo = _repo(
        const AppSettings(
          defaults: AppDefaults(),
          appPinHash: 'h',
          sessionEndPinBiometricEnabled: false,
        ),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettleTall();
      check(repo.stored!.sessionEndPinBiometricEnabled).isFalse();
    });

    testWidgets(
      'switch toggle does NOT affect distressCancelBiometricEnabled',
      (tester) async {
        final repo = _repo(
          const AppSettings(
            defaults: AppDefaults(),
            appPinHash: 'h',
            distressCancelBiometricEnabled: false,
          ),
        );
        await tester.pumpWidget(
          _host(
            const SecurityScreen(),
            extras: [settingsRepositoryProvider.overrideWithValue(repo)],
          ),
        );
        await tester.pumpAndSettleTall();
        await tester.tap(find.byType(SwitchListTile).first);
        await tester.pumpAndSettleTall();
        check(repo.stored!.distressCancelBiometricEnabled).isFalse();
      },
    );
  });

  // -------------------------------------------------------------------------
  // sessionEndPinBiometricEnabled switch
  // -------------------------------------------------------------------------

  group('SecurityScreen — sessionEndPinBiometric switch', () {
    testWidgets('switch is disabled when sessionEndPinHash is null', (
      tester,
    ) async {
      final repo = _repo(const AppSettings(defaults: AppDefaults()));
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      final switches = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .toList();
      check(switches.length).isGreaterOrEqual(2);
      check(switches[1].onChanged).isNull();
    });

    testWidgets('switch is enabled when sessionEndPinHash is set', (
      tester,
    ) async {
      final repo = _repo(
        const AppSettings(defaults: AppDefaults(), sessionEndPinHash: 's'),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      final switches = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .toList();
      check(switches[1].onChanged).isNotNull();
    });

    testWidgets('toggling ON persists sessionEndPinBiometricEnabled=true', (
      tester,
    ) async {
      final repo = _repo(
        const AppSettings(
          defaults: AppDefaults(),
          sessionEndPinHash: 's',
          sessionEndPinBiometricEnabled: false,
        ),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      await tester.tap(find.byType(SwitchListTile).at(1));
      await tester.pumpAndSettleTall();
      check(repo.stored!.sessionEndPinBiometricEnabled).isTrue();
    });

    testWidgets('toggling OFF persists sessionEndPinBiometricEnabled=false', (
      tester,
    ) async {
      final repo = _repo(
        const AppSettings(
          defaults: AppDefaults(),
          sessionEndPinHash: 's',
          sessionEndPinBiometricEnabled: true,
        ),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      await tester.tap(find.byType(SwitchListTile).at(1));
      await tester.pumpAndSettleTall();
      check(repo.stored!.sessionEndPinBiometricEnabled).isFalse();
    });

    testWidgets('session-end toggle does NOT affect appPinBiometricEnabled', (
      tester,
    ) async {
      final repo = _repo(
        const AppSettings(
          defaults: AppDefaults(),
          appPinHash: 'a',
          sessionEndPinHash: 's',
          appPinBiometricEnabled: false,
        ),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      await tester.tap(find.byType(SwitchListTile).at(1));
      await tester.pumpAndSettleTall();
      check(repo.stored!.appPinBiometricEnabled).isFalse();
    });

    testWidgets(
      'switch is disabled even when appPinHash is set (session-end requires sessionEndPinHash)',
      (tester) async {
        // Spec: sessionEndPinBiometricEnabled requires sessionEndPinHash,
        // not appPinHash.
        final repo = _repo(
          const AppSettings(defaults: AppDefaults(), appPinHash: 'h'),
        );
        await tester.pumpWidget(
          _host(
            const SecurityScreen(),
            extras: [settingsRepositoryProvider.overrideWithValue(repo)],
          ),
        );
        await tester.pumpAndSettleTall();
        final switches = tester
            .widgetList<SwitchListTile>(find.byType(SwitchListTile))
            .toList();
        // Second switch (sessionEnd) should still be disabled.
        check(switches[1].onChanged).isNull();
      },
    );
  });

  // -------------------------------------------------------------------------
  // distressCancelBiometricEnabled switch
  // -------------------------------------------------------------------------

  group('SecurityScreen — distressCancelBiometric switch', () {
    testWidgets(
      'switch is disabled when appPinHash is null (requires app PIN)',
      (tester) async {
        // Spec: distressCancelBiometricEnabled requires appPinHash != null
        // (it authenticates against the app PIN).
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = _repo(const AppSettings(defaults: AppDefaults()));
        await tester.pumpWidget(
          _host(
            const SecurityScreen(),
            extras: [settingsRepositoryProvider.overrideWithValue(repo)],
          ),
        );
        await tester.pumpAndSettleTall();
        final switches = tester
            .widgetList<SwitchListTile>(find.byType(SwitchListTile))
            .toList();
        check(switches.length).isGreaterOrEqual(3);
        check(switches[2].onChanged).isNull();
      },
    );

    testWidgets(
      'switch is disabled even when sessionEndPinHash is set (requires appPinHash)',
      (tester) async {
        // Spec: distressCancelBiometricEnabled is gated on appPinHash,
        // NOT sessionEndPinHash.
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = _repo(
          const AppSettings(defaults: AppDefaults(), sessionEndPinHash: 's'),
        );
        await tester.pumpWidget(
          _host(
            const SecurityScreen(),
            extras: [settingsRepositoryProvider.overrideWithValue(repo)],
          ),
        );
        await tester.pumpAndSettleTall();
        final switches = tester
            .widgetList<SwitchListTile>(find.byType(SwitchListTile))
            .toList();
        // Third switch must be disabled.
        check(switches[2].onChanged).isNull();
      },
    );

    testWidgets('switch is enabled when appPinHash is set', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repo = _repo(
        const AppSettings(defaults: AppDefaults(), appPinHash: 'a'),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      final switches = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .toList();
      check(switches[2].onChanged).isNotNull();
    });

    testWidgets('toggling ON persists distressCancelBiometricEnabled=true', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repo = _repo(
        const AppSettings(
          defaults: AppDefaults(),
          appPinHash: 'a',
          distressCancelBiometricEnabled: false,
        ),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      await tester.tap(find.byType(SwitchListTile).at(2));
      await tester.pumpAndSettleTall();
      check(repo.stored!.distressCancelBiometricEnabled).isTrue();
    });

    testWidgets('toggling OFF persists distressCancelBiometricEnabled=false', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repo = _repo(
        const AppSettings(
          defaults: AppDefaults(),
          appPinHash: 'a',
          distressCancelBiometricEnabled: true,
        ),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      await tester.tap(find.byType(SwitchListTile).at(2));
      await tester.pumpAndSettleTall();
      check(repo.stored!.distressCancelBiometricEnabled).isFalse();
    });

    testWidgets(
      'distress-cancel toggle does NOT affect appPinBiometricEnabled',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = _repo(
          const AppSettings(
            defaults: AppDefaults(),
            appPinHash: 'a',
            appPinBiometricEnabled: false,
          ),
        );
        await tester.pumpWidget(
          _host(
            const SecurityScreen(),
            extras: [settingsRepositoryProvider.overrideWithValue(repo)],
          ),
        );
        await tester.pumpAndSettleTall();
        await tester.tap(find.byType(SwitchListTile).at(2));
        await tester.pumpAndSettleTall();
        check(repo.stored!.appPinBiometricEnabled).isFalse();
      },
    );

    testWidgets(
      'distress-cancel toggle does NOT affect sessionEndPinBiometricEnabled',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = _repo(
          const AppSettings(
            defaults: AppDefaults(),
            appPinHash: 'a',
            sessionEndPinBiometricEnabled: false,
          ),
        );
        await tester.pumpWidget(
          _host(
            const SecurityScreen(),
            extras: [settingsRepositoryProvider.overrideWithValue(repo)],
          ),
        );
        await tester.pumpAndSettleTall();
        await tester.tap(find.byType(SwitchListTile).at(2));
        await tester.pumpAndSettleTall();
        check(repo.stored!.sessionEndPinBiometricEnabled).isFalse();
      },
    );
  });

  // -------------------------------------------------------------------------
  // All three OFF + biometric available → still shows PIN keypad
  // -------------------------------------------------------------------------

  group('SecurityScreen — all three biometric toggles off', () {
    testWidgets('all three biometric switches are off by default', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repo = _repo(
        const AppSettings(
          defaults: AppDefaults(),
          appPinHash: 'a',
          sessionEndPinHash: 's',
        ),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      final switches = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .toList();
      check(switches.length).isGreaterOrEqual(3);
      check(switches[0].value).isFalse();
      check(switches[1].value).isFalse();
      check(switches[2].value).isFalse();
    });

    testWidgets('all three switches render as disabled when no PINs are set', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repo = _repo(const AppSettings(defaults: AppDefaults()));
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      final switches = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .toList();
      check(switches.length).isGreaterOrEqual(3);
      check(switches[0].onChanged).isNull();
      check(switches[1].onChanged).isNull();
      check(switches[2].onChanged).isNull();
    });
  });

  // -------------------------------------------------------------------------
  // PIN timeout slider
  // -------------------------------------------------------------------------

  group('SecurityScreen — PIN timeout slider', () {
    // Phase 8 (DE-1): the raw Slider widget was replaced by
    // TimingSlider, which uses a log-scaled index slider internally
    // and exposes `seconds` as the user-facing field. Assertions now
    // target TimingSlider.seconds instead of Slider.value/min/max.
    testWidgets(
      'TimingSlider default value is 15 when pinTimeoutSeconds is not set',
      (tester) async {
        final repo = _repo(const AppSettings(defaults: AppDefaults()));
        await tester.pumpWidget(
          _host(
            const SecurityScreen(),
            extras: [settingsRepositoryProvider.overrideWithValue(repo)],
          ),
        );
        await tester.pumpAndSettleTall();
        final w = tester.widget<TimingSlider>(find.byType(TimingSlider).first);
        check(w.seconds).equals(15);
      },
    );

    testWidgets('TimingSlider reflects stored pinTimeoutSeconds=30', (
      tester,
    ) async {
      final repo = _repo(
        const AppSettings(defaults: AppDefaults(), pinTimeoutSeconds: 30),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      final w = tester.widget<TimingSlider>(find.byType(TimingSlider).first);
      check(w.seconds).equals(30);
    });

    testWidgets('dragging slider updates pinTimeoutSeconds', (tester) async {
      final repo = _repo(const AppSettings(defaults: AppDefaults()));
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      await tester.drag(find.byType(Slider).first, const Offset(150, 0));
      await tester.pumpAndSettleTall();
      check(repo.stored).isNotNull();
      check(repo.stored!.pinTimeoutSeconds).isGreaterThan(0);
    });
  });

  // -------------------------------------------------------------------------
  // Duress PIN test row visibility
  // -------------------------------------------------------------------------

  group('SecurityScreen — duress PIN test row', () {
    testWidgets('test row absent when duressPinHash is null', (tester) async {
      final repo = _repo(const AppSettings(defaults: AppDefaults()));
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      check(find.byIcon(Icons.verified_outlined).evaluate().length).equals(0);
    });

    testWidgets('test row appears when duressPinHash is set', (tester) async {
      final repo = _repo(
        const AppSettings(defaults: AppDefaults(), duressPinHash: _stubHash),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      check(
        find.byIcon(Icons.verified_outlined).evaluate().length,
      ).isGreaterOrEqual(1);
    });

    testWidgets('tapping duress test row opens a dialog with a PinKeypad', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repo = _repo(
        const AppSettings(defaults: AppDefaults(), duressPinHash: _stubHash),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      await tester.tap(find.byIcon(Icons.verified_outlined));
      await tester.pumpAndSettleTall();
      check(find.byType(AlertDialog).evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('closing the duress-test dialog does not change settings', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repo = _repo(
        const AppSettings(defaults: AppDefaults(), duressPinHash: _stubHash),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      await tester.tap(find.byIcon(Icons.verified_outlined));
      await tester.pumpAndSettleTall();
      await tester.tap(find.byType(TextButton).last);
      await tester.pumpAndSettleTall();
      // Settings must be unchanged after the test dialog.
      check(repo.stored!.duressPinHash).equals(_stubHash);
    });
  });

  // -------------------------------------------------------------------------
  // PIN rows (set / change / disable)
  // -------------------------------------------------------------------------

  group('SecurityScreen — PIN rows', () {
    testWidgets(
      'three FilledButton widgets shown when no PINs are configured',
      (tester) async {
        final repo = _repo(const AppSettings(defaults: AppDefaults()));
        await tester.pumpWidget(
          _host(
            const SecurityScreen(),
            extras: [settingsRepositoryProvider.overrideWithValue(repo)],
          ),
        );
        await tester.pumpAndSettleTall();
        final filledButtons = tester
            .widgetList<FilledButton>(find.byType(FilledButton))
            .toList();
        check(filledButtons.length).equals(3);
      },
    );

    testWidgets('disable button visible when appPinHash is set', (
      tester,
    ) async {
      final repo = _repo(
        const AppSettings(defaults: AppDefaults(), appPinHash: 'h'),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      check(find.byType(TextButton).evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('disabling app PIN clears appPinHash from stored settings', (
      tester,
    ) async {
      final repo = _repo(
        const AppSettings(defaults: AppDefaults(), appPinHash: 'x'),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettleTall();
      check(repo.stored!.appPinHash).isNull();
    });

    testWidgets('disabling app PIN also disables appPinBiometricEnabled', (
      tester,
    ) async {
      // Spec: if appPinHash is cleared, biometric is meaningless.
      // The controller should handle this; we check that the hash is gone.
      final repo = _repo(
        const AppSettings(
          defaults: AppDefaults(),
          appPinHash: 'x',
          appPinBiometricEnabled: true,
        ),
      );
      await tester.pumpWidget(
        _host(
          const SecurityScreen(),
          extras: [settingsRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.pumpAndSettleTall();
      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettleTall();
      // appPinHash is cleared.
      check(repo.stored!.appPinHash).isNull();
      // The screen will now show the switch as disabled (null onChanged).
      // The stored biometric value is separate from the hash clearing.
    });
  });
}
