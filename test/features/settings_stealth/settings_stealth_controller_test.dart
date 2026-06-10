/// Tests for [SettingsStealthController]'s launcher-icon wiring (M3 #15 C4).
///
/// These drive the REAL controller through its real `_saveStealth` path and
/// assert that the per-preset `fakeIcon` disguise is pushed to the native
/// (here: simulation) `SystemUiService`, and that the apply is SUPPRESSED while
/// a session is active (stealth settings are immutable during a session — the
/// launcher alias swap can kill the process, so it never runs mid-session).
///
/// Spec: `docs/spec/06-settings.md §Stealth Mode Section` (immutability +
/// fakeIcon-when-it-applies), `docs/spec/11-deferred-enhancements.md` REJ-6.
library;

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/enums/stealth_icon_preset.dart';
import 'package:guardianangela/domain/enums/stealth_timer_display.dart';
import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/features/settings_stealth/settings_stealth_controller.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/system_ui_service_sim.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

/// Round-tripping in-memory [AppSettingsRepository]: `save` then `load`
/// returns the saved value, so the controller's persist + read-back is real.
class _InMemorySettingsRepo extends AppSettingsRepository {
  _InMemorySettingsRepo([AppSettings? initial])
    : _settings = initial ?? const AppSettings(),
      super(
        keyProvider: () async => '00' * 32,
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('stealth_icon_test_'),
      );

  AppSettings _settings;

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<AppSettings?> loadOrNull() async => _settings;

  @override
  Future<void> save(AppSettings value) async => _settings = value;
}

/// Session controller stub whose [isSessionActive] is fixed, so the
/// session-lock branch can be exercised without standing up an engine.
class _FakeSessionController extends SessionController {
  _FakeSessionController({required this.active});

  final bool active;

  @override
  bool get isSessionActive => active;

  @override
  Future<SessionState> build() async => const SessionState.initial();
}

// ---------------------------------------------------------------------------
// Harness
// ---------------------------------------------------------------------------

ProviderContainer _container({
  required _InMemorySettingsRepo repo,
  required SimulationSystemUiService sysUi,
  bool sessionActive = false,
}) {
  final container = ProviderContainer(
    overrides: <Override>[
      appSettingsRepositoryProvider.overrideWithValue(repo),
      systemUiServiceProvider.overrideWithValue(sysUi),
      sessionControllerProvider.overrideWith(
        () => _FakeSessionController(active: sessionActive),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

AppSettings _settingsWithStealth(StealthConfig stealth) => const AppSettings()
    .copyWith(defaults: const AppDefaults().copyWith(stealth: stealth));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SettingsStealthController — launcher-icon apply', () {
    test('enabling stealth applies the configured fakeIcon preset', () async {
      final repo = _InMemorySettingsRepo(
        _settingsWithStealth(
          // enabled defaults to false; the configured preset is calendar.
          const StealthConfig(fakeIcon: StealthIconPreset.calendar),
        ),
      );
      final sysUi = SimulationSystemUiService();
      final container = _container(repo: repo, sysUi: sysUi);

      await container.read(settingsStealthControllerProvider.future);
      final notifier = container.read(
        settingsStealthControllerProvider.notifier,
      );
      await notifier.setEnabled(true);

      // Exactly one alias swap, carrying the configured preset (calendar).
      final calls = sysUi.calls.whereType<StealthIconCall>().toList();
      check(calls).length.equals(1);
      check(calls.single.preset).equals(StealthIconPreset.calendar);
    });

    test('changing the preset while enabled applies that preset', () async {
      final repo = _InMemorySettingsRepo(
        _settingsWithStealth(
          const StealthConfig(
            enabled: true,
            fakeIcon: StealthIconPreset.calendar,
          ),
        ),
      );
      final sysUi = SimulationSystemUiService();
      final container = _container(repo: repo, sysUi: sysUi);

      await container.read(settingsStealthControllerProvider.future);
      final notifier = container.read(
        settingsStealthControllerProvider.notifier,
      );
      await notifier.setFakeIcon(StealthIconPreset.podcast);

      final calls = sysUi.calls.whereType<StealthIconCall>().toList();
      check(calls).length.equals(1);
      check(calls.single.preset).equals(StealthIconPreset.podcast);
    });

    test('disabling stealth restores the real icon (none)', () async {
      final repo = _InMemorySettingsRepo(
        _settingsWithStealth(
          const StealthConfig(
            enabled: true,
            fakeIcon: StealthIconPreset.fitness,
          ),
        ),
      );
      final sysUi = SimulationSystemUiService();
      final container = _container(repo: repo, sysUi: sysUi);

      await container.read(settingsStealthControllerProvider.future);
      final notifier = container.read(
        settingsStealthControllerProvider.notifier,
      );
      await notifier.setEnabled(false);

      final calls = sysUi.calls.whereType<StealthIconCall>().toList();
      check(calls).length.equals(1);
      check(calls.single.preset).equals(StealthIconPreset.none);
    });

    test('a non-icon save (fakeName) still reconciles the launcher', () async {
      // Any save reconciles the launcher to the latest resolved preset; an
      // enabled config keeps applying its fakeIcon, never the real icon.
      final repo = _InMemorySettingsRepo(
        _settingsWithStealth(
          const StealthConfig(enabled: true, fakeIcon: StealthIconPreset.notes),
        ),
      );
      final sysUi = SimulationSystemUiService();
      final container = _container(repo: repo, sysUi: sysUi);

      await container.read(settingsStealthControllerProvider.future);
      final notifier = container.read(
        settingsStealthControllerProvider.notifier,
      );
      await notifier.setFakeName('Reading');

      final calls = sysUi.calls.whereType<StealthIconCall>().toList();
      check(calls).length.equals(1);
      check(calls.single.preset).equals(StealthIconPreset.notes);
    });

    test('persists the saved config (round-trips through the repo)', () async {
      final repo = _InMemorySettingsRepo();
      final sysUi = SimulationSystemUiService();
      final container = _container(repo: repo, sysUi: sysUi);

      await container.read(settingsStealthControllerProvider.future);
      final notifier = container.read(
        settingsStealthControllerProvider.notifier,
      );
      await notifier.setEnabled(true);
      // Each setter loads from the freshly-rebuilt state; re-await the
      // provider between edits (the UI re-reads it between interactions) so
      // the second setter sees enabled=true rather than stale state.
      await container.read(settingsStealthControllerProvider.future);
      await notifier.setFakeIcon(StealthIconPreset.weather);

      final saved = await repo.load();
      check(saved.defaults.stealth.enabled).isTrue();
      check(saved.defaults.stealth.fakeIcon).equals(StealthIconPreset.weather);
    });
  });

  group('SettingsStealthController — lockTaskMode persistence', () {
    test('setLockTaskMode(true) round-trips through the repo', () async {
      // lockTaskMode is the session-scoped pinning preference. The controller
      // only persists it (the OS pinning is engaged by the session controller
      // at session start); assert the saved value survives a reload.
      final repo = _InMemorySettingsRepo(
        _settingsWithStealth(const StealthConfig(enabled: true)),
      );
      final sysUi = SimulationSystemUiService();
      final container = _container(repo: repo, sysUi: sysUi);

      await container.read(settingsStealthControllerProvider.future);
      final notifier = container.read(
        settingsStealthControllerProvider.notifier,
      );
      await notifier.setLockTaskMode(true);

      final saved = await repo.load();
      check(saved.defaults.stealth.lockTaskMode).isTrue();
      // Persisting the pinning preference does not push a lock-task call here;
      // it is engaged by the session controller at session start.
      check(sysUi.calls.whereType<LockTaskCall>()).isEmpty();
    });

    test('setLockTaskMode(false) clears the persisted preference', () async {
      final repo = _InMemorySettingsRepo(
        _settingsWithStealth(
          const StealthConfig(enabled: true, lockTaskMode: true),
        ),
      );
      final sysUi = SimulationSystemUiService();
      final container = _container(repo: repo, sysUi: sysUi);

      await container.read(settingsStealthControllerProvider.future);
      final notifier = container.read(
        settingsStealthControllerProvider.notifier,
      );
      await notifier.setLockTaskMode(false);

      final saved = await repo.load();
      check(saved.defaults.stealth.lockTaskMode).isFalse();
    });
  });

  group('SettingsStealthController — session-active lock', () {
    test('does NOT apply the icon while a session is active', () async {
      final repo = _InMemorySettingsRepo(
        _settingsWithStealth(
          const StealthConfig(enabled: true, fakeIcon: StealthIconPreset.clock),
        ),
      );
      final sysUi = SimulationSystemUiService();
      final container = _container(
        repo: repo,
        sysUi: sysUi,
        sessionActive: true,
      );

      await container.read(settingsStealthControllerProvider.future);
      final notifier = container.read(
        settingsStealthControllerProvider.notifier,
      );
      await notifier.setFakeIcon(StealthIconPreset.podcast);

      // Locked: the native alias swap is suppressed mid-session …
      check(sysUi.calls.whereType<StealthIconCall>()).isEmpty();
    });

    test('still PERSISTS the config while a session is active', () async {
      // Immutability applies to the running session, not to the stored value:
      // the new config is saved and takes effect for the NEXT session.
      final repo = _InMemorySettingsRepo(
        _settingsWithStealth(
          const StealthConfig(enabled: true, fakeIcon: StealthIconPreset.clock),
        ),
      );
      final sysUi = SimulationSystemUiService();
      final container = _container(
        repo: repo,
        sysUi: sysUi,
        sessionActive: true,
      );

      await container.read(settingsStealthControllerProvider.future);
      final notifier = container.read(
        settingsStealthControllerProvider.notifier,
      );
      await notifier.setFakeIcon(StealthIconPreset.podcast);

      final saved = await repo.load();
      check(saved.defaults.stealth.fakeIcon).equals(StealthIconPreset.podcast);
    });
  });

  group('SettingsStealthController — sub-option setters', () {
    test(
      'setNotificationDisguise(false) persists and keeps siblings',
      () async {
        final repo = _InMemorySettingsRepo(
          _settingsWithStealth(
            const StealthConfig(enabled: true, fakeName: 'Notes'),
          ),
        );
        final container = _container(
          repo: repo,
          sysUi: SimulationSystemUiService(),
        );

        await container.read(settingsStealthControllerProvider.future);
        await container
            .read(settingsStealthControllerProvider.notifier)
            .setNotificationDisguise(false);

        final saved = (await repo.load()).defaults.stealth;
        check(saved.notificationDisguise).isFalse();
        check(saved.enabled).isTrue();
        check(saved.fakeName).equals('Notes');
        final state = await container.read(
          settingsStealthControllerProvider.future,
        );
        check(state.config.notificationDisguise).isFalse();
      },
    );

    test('setSessionScreenStealth(false) persists and surfaces', () async {
      final repo = _InMemorySettingsRepo(
        _settingsWithStealth(const StealthConfig(enabled: true)),
      );
      final container = _container(
        repo: repo,
        sysUi: SimulationSystemUiService(),
      );

      await container.read(settingsStealthControllerProvider.future);
      await container
          .read(settingsStealthControllerProvider.notifier)
          .setSessionScreenStealth(false);

      check(
        (await repo.load()).defaults.stealth.sessionScreenStealth,
      ).isFalse();
      final state = await container.read(
        settingsStealthControllerProvider.future,
      );
      check(state.config.sessionScreenStealth).isFalse();
    });

    test('setTimerDisplay(none) persists and surfaces', () async {
      final repo = _InMemorySettingsRepo(
        _settingsWithStealth(const StealthConfig(enabled: true)),
      );
      final container = _container(
        repo: repo,
        sysUi: SimulationSystemUiService(),
      );

      await container.read(settingsStealthControllerProvider.future);
      await container
          .read(settingsStealthControllerProvider.notifier)
          .setTimerDisplay(StealthTimerDisplay.none);

      check(
        (await repo.load()).defaults.stealth.timerDisplay,
      ).equals(StealthTimerDisplay.none);
      final state = await container.read(
        settingsStealthControllerProvider.future,
      );
      check(state.config.timerDisplay).equals(StealthTimerDisplay.none);
    });
  });

  group('SettingsStealthController — settings-hub refresh', () {
    test(
      'setEnabled(true) refreshes the keep-alive settings hub state',
      () async {
        final repo = _InMemorySettingsRepo(
          _settingsWithStealth(const StealthConfig()),
        );
        final sysUi = SimulationSystemUiService();
        final container = _container(repo: repo, sysUi: sysUi);

        // Materialise the hub FIRST — the Settings screen renders its
        // stealth ON/OFF subtitle from this keep-alive provider before the
        // user drills into the stealth submenu.
        final hubBefore = await container.read(
          settingsControllerProvider.future,
        );
        check(hubBefore.stealthEnabled).isFalse();

        await container.read(settingsStealthControllerProvider.future);
        await container
            .read(settingsStealthControllerProvider.notifier)
            .setEnabled(true);

        // Returning to the hub must show "Stealth: On" — not the cached
        // pre-toggle summary.
        final hubAfter = await container.read(
          settingsControllerProvider.future,
        );
        check(hubAfter.stealthEnabled).isTrue();
      },
    );
  });
}
