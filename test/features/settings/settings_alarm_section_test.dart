/// Tests for the Settings-level Alarm section (GA-blocker #23, spec 06
/// §Alarm Section, lines 240–265).
///
/// Two layers of proof:
///
/// 1. **Widget tests** mount the real [SettingsScreen] with a fake
///    [SettingsController] (call-counter) and assert the alarm controls
///    render the current state, the silent-mode warning appears only when
///    DND-override is OFF, the ramp slider is revealed only when gradual
///    volume is ON, and each control invokes the matching controller
///    setter with the right value. These fail red if the screen is not
///    wired to the controller.
///
/// 2. **Controller integration tests** drive the REAL [SettingsController]
///    through a round-tripping in-memory [AppSettingsRepository] (overrides
///    both `load` and `save` over a mutable field) and assert the three
///    setters persist into [AppSettings] and that `build()` reads them
///    back. These fail red if a setter does not `copyWith` + `save`.
library;

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/timing_slider.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/enums/app_theme_mode.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/features/settings/settings_screen.dart';
import 'package:guardianangela/services/service_providers.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Fake controller (widget-layer proof)
// ---------------------------------------------------------------------------

class _FakeSettingsController extends SettingsController {
  _FakeSettingsController(this._initial);

  final SettingsHubState _initial;

  int dndCalls = 0;
  bool? lastDnd;
  int gradualCalls = 0;
  bool? lastGradual;
  int rampCalls = 0;
  int? lastRamp;

  @override
  Future<SettingsHubState> build() async => _initial;

  SettingsHubState get _current => state.value ?? _initial;

  @override
  Future<void> setAlarmDndOverride(bool enabled) async {
    dndCalls++;
    lastDnd = enabled;
    state = AsyncData(_copyWith(alarmDndOverride: enabled));
  }

  @override
  Future<void> setAlarmGradualVolume(bool enabled) async {
    gradualCalls++;
    lastGradual = enabled;
    state = AsyncData(_copyWith(alarmGradualVolume: enabled));
  }

  @override
  Future<void> setAlarmGradualVolumeDurationSeconds(int seconds) async {
    rampCalls++;
    lastRamp = seconds;
    state = AsyncData(_copyWith(alarmGradualVolumeDurationSeconds: seconds));
  }

  SettingsHubState _copyWith({
    bool? alarmDndOverride,
    bool? alarmGradualVolume,
    int? alarmGradualVolumeDurationSeconds,
  }) {
    final c = _current;
    return SettingsHubState(
      themeMode: c.themeMode,
      languageCode: c.languageCode,
      stealthEnabled: c.stealthEnabled,
      emergencyCallNumber: c.emergencyCallNumber,
      alarmDndOverride: alarmDndOverride ?? c.alarmDndOverride,
      alarmGradualVolume: alarmGradualVolume ?? c.alarmGradualVolume,
      alarmGradualVolumeDurationSeconds:
          alarmGradualVolumeDurationSeconds ??
          c.alarmGradualVolumeDurationSeconds,
    );
  }
}

SettingsHubState _state({
  bool alarmDndOverride = false,
  bool alarmGradualVolume = false,
  int alarmGradualVolumeDurationSeconds = 5,
}) => SettingsHubState(
  themeMode: AppThemeMode.system,
  languageCode: 'en',
  stealthEnabled: false,
  emergencyCallNumber: '112',
  alarmDndOverride: alarmDndOverride,
  alarmGradualVolume: alarmGradualVolume,
  alarmGradualVolumeDurationSeconds: alarmGradualVolumeDurationSeconds,
);

Future<void> _pump(
  WidgetTester tester,
  _FakeSettingsController fake, {
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) {
  // A tall viewport keeps the Alarm section (mid-list) on-screen and
  // hit-testable without scroll fiddling.
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  return pumpScreen(
    tester,
    const SettingsScreen(),
    overrides: <Override>[settingsControllerProvider.overrideWith(() => fake)],
    locale: locale,
    themeMode: themeMode,
  );
}

// ---------------------------------------------------------------------------
// Round-tripping fake repository (controller-layer proof)
// ---------------------------------------------------------------------------

/// In-memory [AppSettingsRepository] that genuinely persists: `save`
/// mutates a field and `load` returns it. Lets a test drive the REAL
/// [SettingsController] and read back what it wrote.
class _RoundTripSettingsRepository extends AppSettingsRepository {
  _RoundTripSettingsRepository([AppSettings? initial])
    : _current = initial ?? const AppSettings(),
      super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('alarm_settings_test_'),
      );

  AppSettings _current;
  int saveCount = 0;

  @override
  Future<AppSettings> load() async => _current;

  @override
  Future<void> save(AppSettings value) async {
    saveCount++;
    _current = value;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SettingsScreen — Alarm section (widget)', () {
    testWidgets('renders the Alarm section header', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, _FakeSettingsController(_state()));
      expect(
        find.text(l10n.settingsAlarmHeader.toUpperCase(), skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('DND-override switch reflects state (off)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, _FakeSettingsController(_state()));
      final tile = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text(l10n.settingsAlarmDndOverrideLabel),
          matching: find.byType(SwitchListTile),
        ),
      );
      check(tile.value).isFalse();
    });

    testWidgets('DND-override switch reflects state (on)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        _FakeSettingsController(_state(alarmDndOverride: true)),
      );
      final tile = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text(l10n.settingsAlarmDndOverrideLabel),
          matching: find.byType(SwitchListTile),
        ),
      );
      check(tile.value).isTrue();
    });

    testWidgets('silent-mode warning shows when DND-override is OFF', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, _FakeSettingsController(_state()));
      expect(find.text(l10n.settingsAlarmDndOverrideWarning), findsOneWidget);
    });

    testWidgets('silent-mode warning hidden when DND-override is ON', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        _FakeSettingsController(_state(alarmDndOverride: true)),
      );
      expect(find.text(l10n.settingsAlarmDndOverrideWarning), findsNothing);
    });

    testWidgets('toggling DND-override calls setAlarmDndOverride(true)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSettingsController(_state());
      await _pump(tester, fake);
      await tester.tap(
        find.ancestor(
          of: find.text(l10n.settingsAlarmDndOverrideLabel),
          matching: find.byType(SwitchListTile),
        ),
      );
      await tester.pumpAndSettle();
      check(fake.dndCalls).equals(1);
      check(fake.lastDnd).equals(true);
    });

    testWidgets('gradual-volume switch reflects state', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        _FakeSettingsController(_state(alarmGradualVolume: true)),
      );
      final tile = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text(l10n.settingsAlarmGradualLabel),
          matching: find.byType(SwitchListTile),
        ),
      );
      check(tile.value).isTrue();
    });

    testWidgets('toggling gradual-volume calls setAlarmGradualVolume(true)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSettingsController(_state());
      await _pump(tester, fake);
      await tester.tap(
        find.ancestor(
          of: find.text(l10n.settingsAlarmGradualLabel),
          matching: find.byType(SwitchListTile),
        ),
      );
      await tester.pumpAndSettle();
      check(fake.gradualCalls).equals(1);
      check(fake.lastGradual).equals(true);
    });

    testWidgets('ramp slider hidden when gradual-volume is OFF', (
      WidgetTester tester,
    ) async {
      await _pump(tester, _FakeSettingsController(_state()));
      expect(find.byType(TimingSlider), findsNothing);
    });

    testWidgets('ramp slider shown when gradual-volume is ON', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        _FakeSettingsController(_state(alarmGradualVolume: true)),
      );
      expect(find.byType(TimingSlider), findsOneWidget);
      expect(find.text(l10n.settingsAlarmRampLabel), findsOneWidget);
    });

    testWidgets('ramp slider receives the current duration + 1–60s bounds', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _FakeSettingsController(
          _state(
            alarmGradualVolume: true,
            alarmGradualVolumeDurationSeconds: 30,
          ),
        ),
      );
      final slider = tester.widget<TimingSlider>(find.byType(TimingSlider));
      check(slider.valueSeconds).equals(30);
      check(slider.minSeconds).equals(1);
      check(slider.maxSeconds).equals(60);
    });

    testWidgets('renders in Arabic (RTL) without exception', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _FakeSettingsController(_state(alarmGradualVolume: true)),
        locale: const Locale('ar'),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in dark mode without exception', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _FakeSettingsController(_state(alarmGradualVolume: true)),
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('SettingsController — alarm setters (real controller → repo)', () {
    late ProviderContainer container;
    late _RoundTripSettingsRepository repo;

    Future<SettingsController> notifier() async {
      // Resolve the AsyncNotifier (await its build()).
      await container.read(settingsControllerProvider.future);
      return container.read(settingsControllerProvider.notifier);
    }

    void makeContainer([AppSettings? initial]) {
      repo = _RoundTripSettingsRepository(initial);
      container = ProviderContainer(
        overrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
    }

    test('build() reads the three alarm fields from AppSettings', () async {
      makeContainer(
        const AppSettings(
          alarmDndOverride: true,
          alarmGradualVolume: true,
          alarmGradualVolumeDurationSeconds: 42,
        ),
      );
      final state = await container.read(settingsControllerProvider.future);
      check(state.alarmDndOverride).isTrue();
      check(state.alarmGradualVolume).isTrue();
      check(state.alarmGradualVolumeDurationSeconds).equals(42);
    });

    test('setAlarmDndOverride persists into AppSettings', () async {
      makeContainer();
      final n = await notifier();
      check(repo.saveCount).equals(0);
      await n.setAlarmDndOverride(true);
      // Persisted to the repo.
      check((await repo.load()).alarmDndOverride).isTrue();
      check(repo.saveCount).equals(1);
      // Re-read state reflects it.
      final state = await container.read(settingsControllerProvider.future);
      check(state.alarmDndOverride).isTrue();
    });

    test('setAlarmGradualVolume persists into AppSettings', () async {
      makeContainer();
      final n = await notifier();
      await n.setAlarmGradualVolume(true);
      check((await repo.load()).alarmGradualVolume).isTrue();
      final state = await container.read(settingsControllerProvider.future);
      check(state.alarmGradualVolume).isTrue();
    });

    test(
      'setAlarmGradualVolumeDurationSeconds persists into AppSettings',
      () async {
        makeContainer();
        final n = await notifier();
        await n.setAlarmGradualVolumeDurationSeconds(30);
        check((await repo.load()).alarmGradualVolumeDurationSeconds).equals(30);
        final state = await container.read(settingsControllerProvider.future);
        check(state.alarmGradualVolumeDurationSeconds).equals(30);
      },
    );

    test(
      'duration setter clamps below-range values to 1 before saving',
      () async {
        makeContainer();
        final n = await notifier();
        await n.setAlarmGradualVolumeDurationSeconds(0);
        // 0 is out of the asserted [1,60] range; the setter clamps to 1 so the
        // AppSettings constructor assertion never trips.
        check((await repo.load()).alarmGradualVolumeDurationSeconds).equals(1);
      },
    );

    test(
      'duration setter clamps above-range values to 60 before saving',
      () async {
        makeContainer();
        final n = await notifier();
        await n.setAlarmGradualVolumeDurationSeconds(120);
        check((await repo.load()).alarmGradualVolumeDurationSeconds).equals(60);
      },
    );

    test('alarm setters preserve unrelated AppSettings fields', () async {
      makeContainer(
        const AppSettings(emergencyCallNumber: '999', wrongPinThreshold: 3),
      );
      final n = await notifier();
      await n.setAlarmDndOverride(true);
      final saved = await repo.load();
      // copyWith must not disturb sibling fields.
      check(saved.emergencyCallNumber).equals('999');
      check(saved.wrongPinThreshold).equals(3);
      check(saved.alarmDndOverride).isTrue();
    });
  });
}
