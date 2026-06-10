/// Unit tests for [GpsLoggingController] against a recording fake
/// [AppSettingsRepository].
///
/// Plain `test()` + bare [ProviderContainer] (no widget pump) so
/// `ref.invalidateSelf()` re-runs `build()` without leaking timers. The
/// recording fake pins exactly what is persisted: each setter must save
/// a copy of the CURRENT settings with only its own [GpsLoggingConfig]
/// field changed — clobbering a sibling config value (or another
/// settings field such as the selected mode) would silently rewrite the
/// user's configuration.
///
/// Spec ref: `docs/spec/06-settings.md §GPS Logging Screen`.
library;

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/enums/gps_accuracy.dart';
import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';
import 'package:guardianangela/features/gps_logging/gps_logging_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository(this._current)
    : super(
        keyProvider: () async => '00' * 32,
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('gps_logging_ctl_'),
      );

  AppSettings _current;

  /// Every value passed to [save], in order.
  final List<AppSettings> saved = <AppSettings>[];

  @override
  Future<AppSettings> load() async => _current;

  @override
  Future<void> save(AppSettings value) async {
    _current = value;
    saved.add(value);
  }
}

void main() {
  late _FakeAppSettingsRepository settingsRepo;
  late ProviderContainer container;

  setUp(() {
    // Non-default interval + accuracy so the preservation asserts below
    // would fail if a setter clobbered a sibling back to its default.
    settingsRepo = _FakeAppSettingsRepository(
      const AppSettings(
        selectedModeId: 'walk',
        defaults: AppDefaults(
          gpsLogging: GpsLoggingConfig(
            intervalSeconds: 45,
            accuracy: GpsAccuracy.medium,
          ),
        ),
      ),
    );
    container = ProviderContainer(
      overrides: <Override>[
        appSettingsRepositoryProvider.overrideWithValue(settingsRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<GpsLoggingState> state() =>
      container.read(gpsLoggingControllerProvider.future);

  GpsLoggingController controller() =>
      container.read(gpsLoggingControllerProvider.notifier);

  group('GpsLoggingController.build', () {
    test('exposes the global gpsLogging config from settings', () async {
      final GpsLoggingState s = await state();

      check(s.config.enabled).isTrue();
      check(s.config.intervalSeconds).equals(45);
      check(s.config.accuracy).equals(GpsAccuracy.medium);
    });
  });

  group('GpsLoggingController.setEnabled', () {
    test('persists only the enabled flag and refreshes state', () async {
      await state();

      await controller().setEnabled(false);

      check(settingsRepo.saved.length).equals(1);
      final GpsLoggingConfig saved =
          settingsRepo.saved.single.defaults.gpsLogging;
      check(saved.enabled).isFalse();
      // Sibling config values and unrelated settings are NOT clobbered.
      check(saved.intervalSeconds).equals(45);
      check(saved.accuracy).equals(GpsAccuracy.medium);
      check(settingsRepo.saved.single.selectedModeId).equals('walk');
      check((await state()).config.enabled).isFalse();
    });
  });

  group('GpsLoggingController.setInterval', () {
    test('persists the new interval and refreshes state', () async {
      await state();

      await controller().setInterval(120);

      check(settingsRepo.saved.length).equals(1);
      final GpsLoggingConfig saved =
          settingsRepo.saved.single.defaults.gpsLogging;
      check(saved.intervalSeconds).equals(120);
      check(saved.enabled).isTrue();
      check((await state()).config.intervalSeconds).equals(120);
    });
  });

  group('GpsLoggingController.setAccuracy', () {
    test('persists the new accuracy and refreshes state', () async {
      await state();

      await controller().setAccuracy(GpsAccuracy.low);

      check(
        settingsRepo.saved.single.defaults.gpsLogging.accuracy,
      ).equals(GpsAccuracy.low);
      check((await state()).config.accuracy).equals(GpsAccuracy.low);
    });
  });

  group('GpsLoggingController setter sequencing', () {
    test('successive setters accumulate onto the latest settings', () async {
      await state();

      await controller().setEnabled(false);
      // Settle the invalidateSelf rebuild — mirrors the screen's `watch`,
      // which re-resolves state before the user can touch the next control.
      await state();
      await controller().setInterval(60);

      check(settingsRepo.saved.length).equals(2);
      final GpsLoggingConfig last = settingsRepo.saved.last.defaults.gpsLogging;
      // The second save must build on the first (enabled stays false).
      check(last.enabled).isFalse();
      check(last.intervalSeconds).equals(60);
    });
  });
}
