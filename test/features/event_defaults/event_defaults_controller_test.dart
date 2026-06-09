/// Unit tests for [EventDefaultsController] against a recording fake
/// [AppSettingsRepository].
///
/// Plain `test()` with a bare [ProviderContainer] (no widget pump) so
/// `ref.invalidateSelf()` re-runs `build()` without leaking timers.
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Event Defaults Screen`.
library;

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/features/event_defaults/event_defaults_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository(this._current)
    : super(
        keyProvider: () async => '00' * 32,
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('event_defaults_ctl_test_'),
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
  late _FakeAppSettingsRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = _FakeAppSettingsRepository(const AppSettings());
    container = ProviderContainer(
      overrides: <Override>[
        appSettingsRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<EventDefaultsState> state() =>
      container.read(eventDefaultsControllerProvider.future);

  group('EventDefaultsController.build', () {
    test('publishes the stored event defaults', () async {
      repo._current = const AppSettings(
        defaults: AppDefaults(
          eventDefaults: EventDefaults(
            fakeCall: FakeCallConfig(callerName: 'Alex'),
          ),
        ),
      );

      final EventDefaultsState s = await state();

      check(s.defaults.fakeCall.callerName).equals('Alex');
    });
  });

  group('EventDefaultsController.save', () {
    test('persists the updated defaults, preserving other settings', () async {
      repo._current = const AppSettings(
        defaults: AppDefaults(defaultDistressModeId: 'd1'),
      );
      await state();
      const updated = EventDefaults(
        fakeCall: FakeCallConfig(callerName: 'Mom'),
      );

      await container
          .read(eventDefaultsControllerProvider.notifier)
          .save(updated);

      check(repo.saved.length).equals(1);
      final AppSettings persisted = repo.saved.single;
      check(persisted.defaults.eventDefaults.fakeCall.callerName).equals('Mom');
      // Sibling defaults survive the copyWith round-trip.
      check(persisted.defaults.defaultDistressModeId).equals('d1');
      // invalidateSelf republishes the new defaults.
      check((await state()).defaults.fakeCall.callerName).equals('Mom');
    });
  });
}
