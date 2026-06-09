/// Unit tests for [HomeController] against the REAL in-memory Drift DB.
///
/// Each test builds a fresh [ProviderContainer] whose `databaseProvider`
/// resolves to an isolated [GuardianAngelaDatabase.memory] (no seed), a
/// recording fake [AppSettingsRepository], and a recording
/// [SessionController] subclass, then drives the real controller methods
/// and asserts the returned state, the persisted rows, AND exactly what
/// reaches `SessionController.startSession` (mode / simulate /
/// resolved distress mode). Plain `test()` (no widget pump) so the
/// AsyncNotifier resolves without leaking timers.
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Home Screen` (mode
/// selection, Start Session pre-flight, distress-mode resolution) and
/// §Safety Setup Checklist item 4 (simulation-done flag).
library;

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/validation_result.dart';
import 'package:guardianangela/features/home/home_checklist_repository.dart';
import 'package:guardianangela/features/home/home_controller.dart';
import 'package:guardianangela/features/modes/modes_controller.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/services/protocols/session_start_validator_protocol.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/session_start_validator.dart';
import 'package:guardianangela/services/sim/session_start_validator_sim.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository(this._current)
    : super(
        keyProvider: () async => '00' * 32,
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('home_ctl_'),
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

/// Records every `startSession` call without spinning up a real engine,
/// so the test pins exactly what the home controller hands over.
class _RecordingSessionController extends SessionController {
  final List<({SessionMode mode, bool simulate, SessionMode? distressMode})>
  starts = [];

  @override
  Future<SessionState> build() async => const SessionState.initial();

  @override
  Future<void> startSession({
    required SessionMode mode,
    required bool simulate,
    SessionMode? distressMode,
    double speedMultiplier = 1.0,
    bool writeInterruptMarker = true,
  }) async {
    starts.add((mode: mode, simulate: simulate, distressMode: distressMode));
  }
}

/// In-memory checklist repository recording `markSimulationDone` calls.
class _RecordingChecklistRepo extends HomeChecklistRepository {
  _RecordingChecklistRepo({this.throwOnMark = false});

  /// When true, [markSimulationDone] throws — drives the home
  /// controller's best-effort catch (the flag must never abort a start).
  final bool throwOnMark;

  int markSimulationDoneCalls = 0;

  @override
  Future<void> markSimulationDone() async {
    markSimulationDoneCalls++;
    if (throwOnMark) {
      throw StateError('prefs unavailable');
    }
  }
}

// ---------------------------------------------------------------------------
// Data factories
// ---------------------------------------------------------------------------

ChainStep _step(String id) => ChainStep(
  id: id,
  type: ChainStepType.holdButton,
  order: 0,
  waitSeconds: 0,
  durationSeconds: 10,
  gracePeriodSeconds: 5,
  retryCount: 0,
  randomize: false,
);

SessionMode _mode(
  String id,
  String name, {
  bool isDistress = false,
  String? distressModeId,
}) => SessionMode(
  id: id,
  name: name,
  isDistressMode: isDistress,
  distressModeId: distressModeId,
  chainSteps: <ChainStep>[_step('$id-s0')],
);

EmergencyContact _contact(String id, String name) => EmergencyContact(
  id: id,
  name: name,
  phoneNumber: '+15550100',
  sortOrder: 0,
);

const ValidationIssue _issue = ValidationIssue(
  title: 'No contacts',
  description: 'Add at least one emergency contact.',
);

void main() {
  late GuardianAngelaDatabase db;
  late _FakeAppSettingsRepository settingsRepo;
  late _RecordingSessionController session;
  late _RecordingChecklistRepo checklist;
  late ProviderContainer container;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
    session = _RecordingSessionController();
    checklist = _RecordingChecklistRepo();
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// Builds the container; call after seeding [db] / configuring fakes.
  ///
  /// [validator] defaults to an always-valid [SimulationSessionStartValidator]
  /// so start-path tests are not blocked by the conservative default cache
  /// of the real validator.
  void buildContainer({
    AppSettings settings = const AppSettings(),
    SessionStartValidatorProtocol? validator,
    _RecordingChecklistRepo? checklistRepo,
  }) {
    settingsRepo = _FakeAppSettingsRepository(settings);
    container = ProviderContainer(
      overrides: <Override>[
        databaseProvider.overrideWith((_) async => db),
        appSettingsRepositoryProvider.overrideWithValue(settingsRepo),
        sessionControllerProvider.overrideWith(() => session),
        homeChecklistRepositoryProvider.overrideWithValue(
          checklistRepo ?? checklist,
        ),
        sessionStartValidatorProvider.overrideWithValue(
          validator ?? SimulationSessionStartValidator(),
        ),
      ],
    );
  }

  Future<HomeState> state() => container.read(homeControllerProvider.future);

  HomeController controller() =>
      container.read(homeControllerProvider.notifier);

  group('HomeController.build', () {
    test('loads regular modes + contacts and selects the first mode', () async {
      await db.sessionModesDao.upsert(_mode('m1', 'Walk'));
      await db.sessionModesDao.upsert(_mode('m2', 'Date'));
      await db.sessionModesDao.upsert(_mode('d1', 'Panic', isDistress: true));
      await db.contactsDao.upsert(_contact('c1', 'Bob'));
      buildContainer();

      final HomeState s = await state();

      check(s.modes.map((m) => m.id)).deepEquals(<String>['m1', 'm2']);
      check(s.contacts.map((c) => c.name)).deepEquals(<String>['Bob']);
      check(s.selectedModeId).equals('m1');
      check(s.lastValidationErrors).isEmpty();
    });

    test('respects the persisted selectedModeId from settings', () async {
      await db.sessionModesDao.upsert(_mode('m1', 'Walk'));
      await db.sessionModesDao.upsert(_mode('m2', 'Date'));
      buildContainer(settings: const AppSettings(selectedModeId: 'm2'));

      check((await state()).selectedModeId).equals('m2');
    });

    test('selects nothing on an empty database', () async {
      buildContainer();

      final HomeState s = await state();

      check(s.modes).isEmpty();
      check(s.selectedModeId).isNull();
    });

    test('a stale persisted selection falls back to the first mode', () async {
      // The previously selected mode was deleted on the Modes screen
      // (delete does not rewrite appSettings.selectedModeId). Home must
      // re-anchor to an existing mode or Start silently dead-ends.
      await db.sessionModesDao.upsert(_mode('m1', 'Walk'));
      buildContainer(settings: const AppSettings(selectedModeId: 'deleted'));

      final HomeState s = await state();

      check(s.selectedModeId).equals('m1');
      check(await controller().startSession(simulate: false)).isTrue();
      check(session.starts.single.mode.id).equals('m1');
    });

    test(
      'deleting the selected mode via ModesController re-anchors home',
      () async {
        // The real in-app delete flow for spec 04 §Mode Selector ("If
        // selected mode deleted: Auto-select another mode"): Home stays
        // mounted beneath /modes and homeControllerProvider is keep-alive,
        // so the build-time heal above is unreachable on pop-back unless
        // ModesController.delete invalidates home. Without that, the
        // cached state keeps the dead selection and Start silently
        // dead-ends.
        await db.sessionModesDao.upsert(_mode('m1', 'Walk'));
        await db.sessionModesDao.upsert(_mode('m2', 'Date'));
        buildContainer();
        await state();
        await controller().selectMode('m2');
        check((await state()).selectedModeId).equals('m2');

        await container.read(modesControllerProvider.notifier).delete('m2');

        final HomeState s = await state();
        check(s.selectedModeId).equals('m1');
        check(s.modes.map((m) => m.id)).deepEquals(<String>['m1']);
        check(await controller().startSession(simulate: false)).isTrue();
        check(session.starts.single.mode.id).equals('m1');
      },
    );
  });

  group('HomeController.selectMode', () {
    test('updates state and persists the next-start default', () async {
      await db.sessionModesDao.upsert(_mode('m1', 'Walk'));
      await db.sessionModesDao.upsert(_mode('m2', 'Date'));
      buildContainer(settings: const AppSettings(emergencyCallNumber: '999'));
      await state();

      await controller().selectMode('m2');

      check((await state()).selectedModeId).equals('m2');
      check(settingsRepo.saved.length).equals(1);
      check(settingsRepo.saved.single.selectedModeId).equals('m2');
      // Unrelated settings are not clobbered.
      check(settingsRepo.saved.single.emergencyCallNumber).equals('999');
    });
  });

  group('HomeController.startSession — guards', () {
    test('returns false before the first build resolves', () async {
      buildContainer();

      // No await of the provider future: state.value is still null.
      final bool ok = await controller().startSession(simulate: false);

      check(ok).isFalse();
      check(session.starts).isEmpty();
    });

    test('returns false when no mode is selected', () async {
      buildContainer();
      await state();

      check(await controller().startSession(simulate: false)).isFalse();
      check(session.starts).isEmpty();
    });

    test('returns false when the mode row vanished out-of-band', () async {
      await db.sessionModesDao.upsert(_mode('m1', 'Walk'));
      buildContainer();
      await state();
      // Raw DAO delete behind every controller's back AFTER build
      // resolved — no invalidation can fire, so home's cached selection
      // is unrecoverably stale until the next rebuild. The guard must
      // fail the start silently rather than crash. In-app deletes go
      // through ModesController.delete, which invalidates home and
      // re-anchors the selection (see 'deleting the selected mode via
      // ModesController re-anchors home').
      await db.sessionModesDao.deleteById('m1');

      check(await controller().startSession(simulate: false)).isFalse();
      check(session.starts).isEmpty();
    });
  });

  group('HomeController.startSession — validation gating', () {
    test('real start is blocked and surfaces the errors', () async {
      await db.sessionModesDao.upsert(_mode('m1', 'Walk'));
      buildContainer(
        validator: SimulationSessionStartValidator(
          fixedResult: const ValidationResult(
            errors: <ValidationIssue>[_issue],
            warnings: <ValidationIssue>[],
          ),
        ),
      );
      await state();

      final bool ok = await controller().startSession(simulate: false);

      check(ok).isFalse();
      check(session.starts).isEmpty();
      final HomeState s = await state();
      check(
        s.lastValidationErrors.map((i) => i.title),
      ).deepEquals(<String>['No contacts']);
    });

    test('clearValidationErrors empties the list, keeps selection', () async {
      await db.sessionModesDao.upsert(_mode('m1', 'Walk'));
      buildContainer(
        validator: SimulationSessionStartValidator(
          fixedResult: const ValidationResult(
            errors: <ValidationIssue>[_issue],
            warnings: <ValidationIssue>[],
          ),
        ),
      );
      await state();
      await controller().startSession(simulate: false);
      check((await state()).lastValidationErrors).isNotEmpty();

      controller().clearValidationErrors();

      final HomeState s = await state();
      check(s.lastValidationErrors).isEmpty();
      check(s.selectedModeId).equals('m1');
    });

    test('simulation start ignores validation errors and runs', () async {
      await db.sessionModesDao.upsert(_mode('m1', 'Walk'));
      buildContainer(
        validator: SimulationSessionStartValidator(
          fixedResult: const ValidationResult(
            errors: <ValidationIssue>[_issue],
            warnings: <ValidationIssue>[],
          ),
        ),
      );
      await state();

      final bool ok = await controller().startSession(simulate: true);

      check(ok).isTrue();
      check(session.starts.length).equals(1);
      check(session.starts.single.simulate).isTrue();
      check(session.starts.single.mode.id).equals('m1');
      // Spec 04 §Safety Setup Checklist item 4: first simulation flips
      // the checklist flag.
      check(checklist.markSimulationDoneCalls).equals(1);
    });

    test('a real start never touches the simulation-done flag', () async {
      await db.sessionModesDao.upsert(_mode('m1', 'Walk'));
      buildContainer();
      await state();

      check(await controller().startSession(simulate: false)).isTrue();
      check(checklist.markSimulationDoneCalls).equals(0);
    });

    test('a markSimulationDone failure does not abort the start', () async {
      await db.sessionModesDao.upsert(_mode('m1', 'Walk'));
      final throwing = _RecordingChecklistRepo(throwOnMark: true);
      buildContainer(checklistRepo: throwing);
      await state();

      final bool ok = await controller().startSession(simulate: true);

      check(ok).isTrue();
      check(throwing.markSimulationDoneCalls).equals(1);
      check(session.starts.length).equals(1);
    });
  });

  group('HomeController.startSession — distress resolution', () {
    test('mode-local distressModeId wins and is fetched from db', () async {
      await db.sessionModesDao.upsert(_mode('d1', 'Panic', isDistress: true));
      await db.sessionModesDao.upsert(
        _mode('m1', 'Walk', distressModeId: 'd1'),
      );
      buildContainer(
        settings: const AppSettings(
          selectedModeId: 'm1',
          defaults: AppDefaults(defaultDistressModeId: 'd-global'),
        ),
      );
      await state();

      check(await controller().startSession(simulate: false)).isTrue();
      check(session.starts.single.distressMode?.id).equals('d1');
    });

    test('falls back to the global default distress mode', () async {
      await db.sessionModesDao.upsert(_mode('d2', 'Global', isDistress: true));
      await db.sessionModesDao.upsert(_mode('m1', 'Walk'));
      buildContainer(
        settings: const AppSettings(
          defaults: AppDefaults(defaultDistressModeId: 'd2'),
        ),
      );
      await state();

      check(await controller().startSession(simulate: false)).isTrue();
      check(session.starts.single.distressMode?.id).equals('d2');
    });

    test('passes null when no distress mode is configured', () async {
      await db.sessionModesDao.upsert(_mode('m1', 'Walk'));
      buildContainer();
      await state();

      check(await controller().startSession(simulate: false)).isTrue();
      check(session.starts.single.distressMode).isNull();
    });
  });

  group('HomeController.startSession — real validator pre-warm', () {
    test('refreshes cache + prewarms installed apps before validate', () async {
      await db.sessionModesDao.upsert(_mode('m1', 'Walk'));
      await db.contactsDao.upsert(_contact('c1', 'Bob'));
      final prewarmed = <Uri>[];
      final validator = RealSessionStartValidator(
        permissionChecker: (_) async => PermissionStatus.granted,
        batteryOptChecker: () async => true,
        canLaunchUrl: (Uri uri) async {
          prewarmed.add(uri);
          return true;
        },
      );
      buildContainer(validator: validator);
      await state();

      final bool ok = await controller().startSession(simulate: false);

      check(ok).isTrue();
      // prewarm() probed both third-party messengers.
      check(
        prewarmed.map((u) => u.scheme).toList(),
      ).deepEquals(<String>['whatsapp', 'tg']);
      check(session.starts.length).equals(1);
    });

    test('a pre-warm failure is non-fatal for a simulation start', () async {
      await db.sessionModesDao.upsert(_mode('m1', 'Walk'));
      final validator = RealSessionStartValidator(
        permissionChecker: (_) async =>
            throw StateError('platform channel unavailable'),
        batteryOptChecker: () async => true,
        canLaunchUrl: (_) async => true,
      );
      buildContainer(validator: validator);
      await state();

      final bool ok = await controller().startSession(simulate: true);

      check(ok).isTrue();
      check(session.starts.length).equals(1);
    });
  });
}
