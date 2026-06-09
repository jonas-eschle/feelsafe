/// Unit tests for [ModesController] against the REAL in-memory Drift DB.
///
/// Each test builds a fresh [ProviderContainer] whose `databaseProvider`
/// resolves to an isolated [GuardianAngelaDatabase.memory] (no seed), then
/// drives the real controller methods and asserts both the returned state
/// and the persisted rows. Plain `test()` (no widget pump) so
/// `ref.invalidateSelf()` re-runs `build()` without leaking timers.
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Modes Screen` (list,
/// create blank, duplicate, delete).
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/features/modes/modes_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

ChainStep _step(String id, {ChainStepType type = ChainStepType.holdButton}) =>
    ChainStep(
      id: id,
      type: type,
      order: 0,
      waitSeconds: 0,
      durationSeconds: 10,
      gracePeriodSeconds: 5,
      retryCount: 0,
      randomize: false,
    );

SessionMode _mode(String id, String name, {bool isDistress = false}) =>
    SessionMode(
      id: id,
      name: name,
      isDistressMode: isDistress,
      chainSteps: <ChainStep>[_step('$id-s0')],
    );

void main() {
  late GuardianAngelaDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
    container = ProviderContainer(
      overrides: <Override>[databaseProvider.overrideWith((_) async => db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<ModesState> state() => container.read(modesControllerProvider.future);

  group('ModesController.build', () {
    test('returns only regular (non-distress) modes', () async {
      await db.sessionModesDao.upsert(_mode('m1', 'Walk'));
      await db.sessionModesDao.upsert(_mode('d1', 'Panic', isDistress: true));

      final ModesState s = await state();

      check(s.modes.map((m) => m.id)).deepEquals(<String>['m1']);
    });

    test('returns an empty list on an empty database', () async {
      final ModesState s = await state();
      check(s.modes).isEmpty();
    });
  });

  group('ModesController.createBlank', () {
    test(
      'persists a single-holdButton blank mode and returns its id',
      () async {
        final controller = container.read(modesControllerProvider.notifier);
        await state();

        final String id = await controller.createBlank();

        final SessionMode? saved = await db.sessionModesDao.getById(id);
        check(saved).isNotNull();
        check(saved!.name).equals('New mode');
        check(saved.chainSteps.length).equals(1);
        final ChainStep step = saved.chainSteps.single;
        check(step.type).equals(ChainStepType.holdButton);
        check(step.durationSeconds).equals(10);
        check(step.gracePeriodSeconds).equals(5);
        check(step.config).isA<HoldButtonConfig>();
      },
    );

    test('invalidates the list so the new mode appears in state', () async {
      final controller = container.read(modesControllerProvider.notifier);
      check((await state()).modes).isEmpty();

      final String id = await controller.createBlank();

      check((await state()).modes.map((m) => m.id)).deepEquals(<String>[id]);
    });
  });

  group('ModesController.duplicate', () {
    test(
      'copies the source mode under a fresh id and "Copy of" name',
      () async {
        await db.sessionModesDao.upsert(_mode('m1', 'Walk'));
        final controller = container.read(modesControllerProvider.notifier);
        await state();

        final String newId = await controller.duplicate('m1');

        check(newId).not((it) => it.equals('m1'));
        final SessionMode? copy = await db.sessionModesDao.getById(newId);
        check(copy).isNotNull();
        check(copy!.name).equals('Copy of Walk');
        check(copy.chainSteps.length).equals(1);
        // The source mode is untouched.
        final SessionMode? src = await db.sessionModesDao.getById('m1');
        check(src!.name).equals('Walk');
        check((await state()).modes.length).equals(2);
      },
    );

    test('throws StateError for an unknown source id', () async {
      final controller = container.read(modesControllerProvider.notifier);
      await state();

      await expectLater(
        controller.duplicate('nope'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('ModesController.delete', () {
    test('removes the mode from the database and the state', () async {
      await db.sessionModesDao.upsert(_mode('m1', 'Walk'));
      await db.sessionModesDao.upsert(_mode('m2', 'Date'));
      final controller = container.read(modesControllerProvider.notifier);
      check((await state()).modes.length).equals(2);

      await controller.delete('m1');

      check(await db.sessionModesDao.getById('m1')).isNull();
      check((await state()).modes.map((m) => m.id)).deepEquals(<String>['m2']);
    });
  });
}
