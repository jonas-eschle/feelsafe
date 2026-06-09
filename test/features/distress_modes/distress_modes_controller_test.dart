/// Unit tests for [DistressModesController] against the REAL in-memory
/// Drift DB and a recording fake [AppSettingsRepository].
///
/// Each test builds a fresh [ProviderContainer] whose `databaseProvider`
/// resolves to an isolated [GuardianAngelaDatabase.memory] (no seed), then
/// drives the real controller methods and asserts both the returned state
/// and the persisted rows. Plain `test()` (no widget pump) so
/// `ref.invalidateSelf()` re-runs `build()` without leaking timers.
///
/// SAFETY-CRITICAL: distress modes are what a distress trigger swaps in.
/// Every delete guard is pinned in BOTH directions (refuses default /
/// last / referenced; allows an unreferenced extra) so a regression can
/// never silently delete the mode an active trigger depends on.
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Distress Modes Screen`.
library;

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/features/distress_modes/distress_modes_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository(this._current)
    : super(
        keyProvider: () async => '00' * 32,
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('distress_modes_ctl_test_'),
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

ChainStep _step(String id, {ChainStepType type = ChainStepType.smsContact}) =>
    ChainStep(
      id: id,
      type: type,
      order: 0,
      waitSeconds: 0,
      durationSeconds: 15,
      gracePeriodSeconds: 0,
      retryCount: 0,
      randomize: false,
    );

SessionMode _distress(String id, String name) => SessionMode(
  id: id,
  name: name,
  isDistressMode: true,
  chainSteps: <ChainStep>[_step('$id-s0')],
);

SessionMode _regular(String id, String name, {String? distressModeId}) =>
    SessionMode(
      id: id,
      name: name,
      distressModeId: distressModeId,
      chainSteps: <ChainStep>[_step('$id-s0')],
    );

void main() {
  late GuardianAngelaDatabase db;
  late _FakeAppSettingsRepository settingsRepo;
  late ProviderContainer container;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
    settingsRepo = _FakeAppSettingsRepository(const AppSettings());
    container = ProviderContainer(
      overrides: <Override>[
        databaseProvider.overrideWith((_) async => db),
        appSettingsRepositoryProvider.overrideWithValue(settingsRepo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<DistressModesState> state() =>
      container.read(distressModesControllerProvider.future);

  DistressModesController notifier() =>
      container.read(distressModesControllerProvider.notifier);

  group('DistressModesController.build', () {
    test('lists only distress modes, with default + referenced ids', () async {
      await db.sessionModesDao.upsert(_distress('d1', 'Panic'));
      await db.sessionModesDao.upsert(_distress('d2', 'Silent'));
      await db.sessionModesDao.upsert(
        _regular('m1', 'Walk', distressModeId: 'd2'),
      );
      settingsRepo._current = const AppSettings(
        defaults: AppDefaults(defaultDistressModeId: 'd1'),
      );

      final DistressModesState s = await state();

      check(s.modes.map((m) => m.id).toSet()).deepEquals(<String>{'d1', 'd2'});
      check(s.defaultId).equals('d1');
      check(s.referencedIds).deepEquals(<String>{'d2'});
    });

    test('a regular mode without a distress link references nothing', () async {
      await db.sessionModesDao.upsert(_distress('d1', 'Panic'));
      await db.sessionModesDao.upsert(_regular('m1', 'Walk'));

      final DistressModesState s = await state();

      check(s.referencedIds).isEmpty();
      check(s.defaultId).isNull();
    });
  });

  group('DistressModesController.createBlank', () {
    test('persists a blank smsContact distress mode and lists it', () async {
      await state();

      final String id = await notifier().createBlank();

      final SessionMode? saved = await db.sessionModesDao.getById(id);
      check(saved).isNotNull();
      check(saved!.name).equals('New distress mode');
      check(saved.isDistressMode).isTrue();
      final ChainStep step = saved.chainSteps.single;
      check(step.type).equals(ChainStepType.smsContact);
      check(step.config).isA<SmsContactConfig>();
      check((await state()).modes.map((m) => m.id)).deepEquals(<String>[id]);
    });
  });

  group('DistressModesController.duplicate', () {
    test('copies under a fresh id, forcing isDistressMode', () async {
      // Duplicating a REGULAR mode into the distress list must coerce the
      // copy to a distress mode (spec: list only ever holds distress modes).
      await db.sessionModesDao.upsert(_regular('m1', 'Walk'));
      await state();

      final String newId = await notifier().duplicate('m1');

      check(newId).not((it) => it.equals('m1'));
      final SessionMode? copy = await db.sessionModesDao.getById(newId);
      check(copy).isNotNull();
      check(copy!.name).equals('Copy of Walk');
      check(copy.isDistressMode).isTrue();
      // Source untouched.
      check((await db.sessionModesDao.getById('m1'))!.isDistressMode).isFalse();
    });

    test('throws StateError for an unknown source id', () async {
      await state();

      await expectLater(
        notifier().duplicate('nope'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('DistressModesController.setDefault', () {
    test('persists the new default id and republishes it', () async {
      await db.sessionModesDao.upsert(_distress('d1', 'Panic'));
      await db.sessionModesDao.upsert(_distress('d2', 'Silent'));
      check((await state()).defaultId).isNull();

      await notifier().setDefault('d2');

      check(settingsRepo.saved.length).equals(1);
      check(
        settingsRepo.saved.single.defaults.defaultDistressModeId,
      ).equals('d2');
      check((await state()).defaultId).equals('d2');
    });
  });

  group('DistressModesController.delete — guards (safety-critical)', () {
    test('REFUSES to delete the default distress mode', () async {
      await db.sessionModesDao.upsert(_distress('d1', 'Panic'));
      await db.sessionModesDao.upsert(_distress('d2', 'Silent'));
      settingsRepo._current = const AppSettings(
        defaults: AppDefaults(defaultDistressModeId: 'd1'),
      );
      await state();

      await notifier().delete('d1');

      check(await db.sessionModesDao.getById('d1')).isNotNull();
      check((await state()).modes.length).equals(2);
    });

    test('REFUSES to delete the last remaining distress mode', () async {
      await db.sessionModesDao.upsert(_distress('d1', 'Panic'));
      await state();

      await notifier().delete('d1');

      check(await db.sessionModesDao.getById('d1')).isNotNull();
    });

    test('REFUSES to delete a mode referenced by a regular mode', () async {
      await db.sessionModesDao.upsert(_distress('d1', 'Panic'));
      await db.sessionModesDao.upsert(_distress('d2', 'Silent'));
      await db.sessionModesDao.upsert(
        _regular('m1', 'Walk', distressModeId: 'd2'),
      );
      await state();

      await notifier().delete('d2');

      check(await db.sessionModesDao.getById('d2')).isNotNull();
    });

    test('no-ops when called before the list state has resolved', () async {
      await db.sessionModesDao.upsert(_distress('d1', 'Panic'));
      await db.sessionModesDao.upsert(_distress('d2', 'Silent'));

      // Do NOT await the provider future: state.value is still null.
      await notifier().delete('d2');

      check(await db.sessionModesDao.getById('d2')).isNotNull();
    });

    test('DOES delete an unreferenced, non-default extra mode', () async {
      await db.sessionModesDao.upsert(_distress('d1', 'Panic'));
      await db.sessionModesDao.upsert(_distress('d2', 'Silent'));
      settingsRepo._current = const AppSettings(
        defaults: AppDefaults(defaultDistressModeId: 'd1'),
      );
      await state();

      await notifier().delete('d2');

      check(await db.sessionModesDao.getById('d2')).isNull();
      check((await state()).modes.map((m) => m.id)).deepEquals(<String>['d1']);
    });
  });
}
