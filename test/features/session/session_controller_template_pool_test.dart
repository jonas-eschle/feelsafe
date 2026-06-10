/// Bug #14 — the runtime reminder-template pool reads the Drift DAO.
///
/// Global reminder templates used to live in TWO unsynced stores: the Drift
/// `reminder_templates` table (where the Templates screen writes) and the
/// `AppDefaults.templates` JSON list (where `startSession` read). A user's
/// template edits were silently inert in every session. These tests pin the
/// fix: the Drift DAO is the single source of truth for GLOBAL templates;
/// mode-local templates stay in `ModeOverrides.localTemplates`.
///
/// Red-proof (pre-fix): the pool came from `settings.defaults.templates`, so
/// a DAO edit through the Templates-editor write path never reached a
/// session.
library;

import 'dart:convert';
import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/data/seed_data.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/mode_overrides.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/services/backup_service.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/session_log_recorder.dart';
import 'package:guardianangela/services/sim/audio_service_sim.dart';
import 'package:guardianangela/services/sim/background_session_service_sim.dart';
import 'package:guardianangela/services/sim/call_state_service_sim.dart';
import 'package:guardianangela/services/sim/contact_service_sim.dart';
import 'package:guardianangela/services/sim/flash_service_sim.dart';
import 'package:guardianangela/services/sim/home_widget_service_sim.dart';
import 'package:guardianangela/services/sim/location_service_sim.dart';
import 'package:guardianangela/services/sim/messaging_service_sim.dart';
import 'package:guardianangela/services/sim/notification_service_sim.dart';
import 'package:guardianangela/services/sim/phone_service_sim.dart';
import 'package:guardianangela/services/sim/recording_service_sim.dart';
import 'package:guardianangela/services/sim/screen_flash_service_sim.dart';
import 'package:guardianangela/services/sim/system_ui_service_sim.dart';
import 'package:guardianangela/services/sim/vibration_service_sim.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Stable id of the seeded "Calendar Event" template (see SeedData).
const String _calendarSeedId =
    '${SeedData.reminderTemplatePrefix}calendar_event';

class _FakeAppSettingsRepository extends AppSettingsRepository {
  /// [settings] defaults to `SeedData.defaultAppSettings()` — the exact
  /// object the real repository returns on a fresh install.
  _FakeAppSettingsRepository({AppSettings? settings})
    : _settings = settings ?? SeedData.defaultAppSettings(),
      super(
        keyProvider: () async => '00' * 32,
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('tpl_pool_test_'),
      );

  final AppSettings _settings;

  @override
  Future<AppSettings> load() async => _settings;
}

class _FakeUserProfileRepository extends UserProfileRepository {
  _FakeUserProfileRepository() : super(keyProvider: _k);

  static Future<String> _k() async => '00' * 32;

  @override
  Future<UserProfile> load() async => const UserProfile();
}

/// A mode-local template staged in the mode's overrides (NOT in the DAO).
ReminderTemplate _localTemplate() => ReminderTemplate(
  id: 'tmpl-local',
  name: 'Local Tpl',
  title: 'Local title',
  body: 'Local body',
  confirmationType: ConfirmationType.dismiss,
  isCustom: true,
  displayStyle: ReminderDisplayStyle.subtle,
  isGlobal: false,
);

/// disguisedReminder mode whose step is pinned to [templateIds] and fires
/// immediately (waitSeconds = 0) with deterministic selection.
SessionMode _reminderMode({
  List<String> templateIds = const <String>[],
  ModeOverrides? overrides,
}) => SessionMode(
  id: 'mode-pool',
  name: 'Pool Test',
  chainSteps: <ChainStep>[
    ChainStep(
      id: 'step-pool-0',
      type: ChainStepType.disguisedReminder,
      order: 0,
      waitSeconds: 0,
      durationSeconds: 60,
      gracePeriodSeconds: 5,
      retryCount: 3,
      randomize: false,
      config: DisguisedReminderConfig(
        templateIds: templateIds,
        randomizeTemplateOrder: false,
      ),
    ),
  ],
  overrides: overrides,
);

/// Builds a container around [db] with all hardware services simulated.
///
/// [contexts], when given, captures every [SessionContext] handed to the
/// session-log recorder factory — the exact pool `startSession` built.
ProviderContainer _container(
  GuardianAngelaDatabase db, {
  AppSettings? settings,
  AppSettingsRepository? settingsRepository,
  List<SessionContext>? contexts,
}) {
  final container = ProviderContainer(
    overrides: [
      appSettingsRepositoryProvider.overrideWithValue(
        settingsRepository ?? _FakeAppSettingsRepository(settings: settings),
      ),
      userProfileRepositoryProvider.overrideWithValue(
        _FakeUserProfileRepository(),
      ),
      databaseProvider.overrideWith((ref) async => db),
      systemUiServiceProvider.overrideWithValue(SimulationSystemUiService()),
      homeWidgetServiceProvider.overrideWithValue(
        SimulationHomeWidgetService(),
      ),
      sessionLogRecorderProvider.overrideWith((ref) async {
        final repo = await ref.watch(sessionLogRepositoryProvider.future);
        return (SessionContext ctx) {
          contexts?.add(ctx);
          return SimulationSessionLogRecorder(context: ctx, repo: repo);
        };
      }),
      vibrationServiceProvider.overrideWithValue(SimulationVibrationService()),
      flashServiceProvider.overrideWithValue(SimulationFlashService()),
      screenFlashServiceProvider.overrideWithValue(
        SimulationScreenFlashService(),
      ),
      recordingServiceProvider.overrideWithValue(SimulationRecordingService()),
      locationServiceProvider.overrideWithValue(SimulationLocationService()),
      phoneServiceProvider.overrideWithValue(SimulationPhoneService()),
      messagingServiceProvider.overrideWithValue(SimulationMessagingService()),
      contactServiceProvider.overrideWith(
        (_) async => SimulationContactService(),
      ),
      audioServiceProvider.overrideWithValue(SimulationAudioService()),
      notificationServiceProvider.overrideWithValue(
        SimulationNotificationService(),
      ),
      callStateServiceProvider.overrideWithValue(SimulationCallStateService()),
      backgroundSessionServiceProvider.overrideWithValue(
        SimulationBackgroundSessionService(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Performs exactly the write the Templates editor's Save performs
/// (template_editor_screen.dart `_save`): a DAO upsert with `isGlobal: true`.
Future<ReminderTemplate> _editTemplateBody(
  GuardianAngelaDatabase db,
  String id,
  String newBody,
) async {
  final existing = await db.reminderTemplatesDao.getById(id);
  final edited = existing!.copyWith(body: newBody, isGlobal: true);
  await db.reminderTemplatesDao.upsert(edited);
  return edited;
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GuardianAngelaDatabase db;

  setUp(() {
    // Full real seed — 8 built-in templates in the DAO, like a fresh install.
    db = GuardianAngelaDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  group('bug #14 — DAO is the single source of truth for global templates', () {
    test('CORE: a body edited through the Templates-editor write path (DAO '
        'upsert) reaches the session pool — the session shows the EDITED '
        'text, not the stale seed', () async {
      // The user edits the seeded Calendar template's body. This is the
      // exact write template_editor_screen._save performs.
      await _editTemplateBody(db, _calendarSeedId, 'Dentist at 9 AM');

      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      await container
          .read(sessionControllerProvider.notifier)
          .startSession(
            mode: _reminderMode(templateIds: const <String>[_calendarSeedId]),
            simulate: false,
          );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(sessionControllerProvider).value;
      final active = state!.activeReminderTemplate;
      check(active).isNotNull();
      check(active!.id).equals(_calendarSeedId);
      // Pre-fix this read 'Meeting with Alex at 3 PM' from the JSON store.
      check(active.body).equals('Dentist at 9 AM');

      await container.read(sessionControllerProvider.notifier).endSession();
    });

    test('pool = DAO globals (with edits) then mode-local templates, in '
        'order', () async {
      await _editTemplateBody(db, _calendarSeedId, 'Edited body');
      final contexts = <SessionContext>[];
      final container = _container(db, contexts: contexts);
      await container.read(sessionControllerProvider.future);

      await container
          .read(sessionControllerProvider.notifier)
          .startSession(
            mode: _reminderMode(
              overrides: ModeOverrides(
                localTemplates: <ReminderTemplate>[_localTemplate()],
              ),
            ),
            simulate: false,
          );
      await Future<void>.delayed(Duration.zero);

      check(contexts).length.equals(1);
      final pool = contexts.single.reminderTemplates;
      final daoGlobals = await db.reminderTemplatesDao.getAll();
      check(pool.length).equals(daoGlobals.length + 1);
      // Global half: the DAO rows, in DAO order, including the edit.
      check(
        pool.take(daoGlobals.length).map((t) => t.id).toList(),
      ).deepEquals(daoGlobals.map((t) => t.id).toList());
      check(
        pool.firstWhere((t) => t.id == _calendarSeedId).body,
      ).equals('Edited body');
      // Local half appended last.
      check(pool.last.id).equals('tmpl-local');
      check(pool.last.isGlobal).isFalse();

      await container.read(sessionControllerProvider.notifier).endSession();
    });

    test('a custom template deleted on the Templates screen (DAO delete) is '
        'gone from the next session pool', () async {
      final custom = ReminderTemplate(
        id: 'tmpl-custom',
        name: 'Custom',
        title: 'Custom title',
        body: 'Custom body',
        confirmationType: ConfirmationType.dismiss,
        isCustom: true,
        displayStyle: ReminderDisplayStyle.subtle,
        isGlobal: true,
      );
      await db.reminderTemplatesDao.upsert(custom);
      await db.reminderTemplatesDao.deleteById(custom.id);

      final contexts = <SessionContext>[];
      final container = _container(db, contexts: contexts);
      await container.read(sessionControllerProvider.future);
      await container
          .read(sessionControllerProvider.notifier)
          .startSession(mode: _reminderMode(), simulate: false);
      await Future<void>.delayed(Duration.zero);

      check(
        contexts.single.reminderTemplates.map((t) => t.id),
      ).not((it) => it.contains('tmpl-custom'));

      await container.read(sessionControllerProvider.notifier).endSession();
    });

    test('isGlobal pin: every row in the DAO is global — seed, the '
        'Templates-screen write paths, AND the backup-import path only ever '
        'store isGlobal=true, so the pool read needs no filter (mode-locals '
        'live in the mode JSON only)', () async {
      // Seed rows.
      final seeded = await db.reminderTemplatesDao.getAll();
      check(seeded.length).equals(8);
      for (final t in seeded) {
        check(t.isGlobal, because: '${t.id} must be global').isTrue();
      }
      // The editor's save path writes isGlobal: true explicitly.
      final edited = await _editTemplateBody(db, _calendarSeedId, 'x');
      check(edited.isGlobal).isTrue();
      // The list screen's duplicate copies a DAO row, preserving isGlobal.
      final copy = seeded.first.copyWith(id: 'tmpl-copy', isCustom: true);
      await db.reminderTemplatesDao.upsert(copy);
      check(
        (await db.reminderTemplatesDao.getAll()).every((t) => t.isGlobal),
      ).isTrue();

      // The LAST write path into the table: backup restore. Export the
      // current DB, tamper ONE top-level template row to isGlobal:false
      // (hand-edited backup), and re-import — the import coerces the row
      // back to global, so the invariant is total by construction.
      final tmp = Directory.systemTemp.createTempSync('tpl_pin_import_');
      addTearDown(() => tmp.deleteSync(recursive: true));
      final backup = RealBackupService(
        db: db,
        contacts: ContactsRepository(db.contactsDao),
        appSettings: AppSettingsRepository(
          keyProvider: () async => '00' * 32,
          resolveDir: () async => tmp,
        ),
        userProfile: UserProfileRepository(
          keyProvider: () async => '00' * 32,
          resolveDir: () async => tmp,
        ),
        sessionLogs: SessionLogRepository(db.sessionLogsDao),
      );
      final payload =
          jsonDecode(await backup.exportToJson()) as Map<String, dynamic>;
      final templates = payload['templates'] as List<dynamic>;
      (templates.first as Map<String, dynamic>)['isGlobal'] = false;
      await backup.importFromJson(jsonEncode(payload));

      final restored = await db.reminderTemplatesDao.getAll();
      check(restored.length).equals(seeded.length + 1);
      for (final t in restored) {
        check(
          t.isGlobal,
          because: '${t.id} must stay global after import',
        ).isTrue();
      }
    });
  });

  group('bug #14 — backup carries templates through the DAO only', () {
    test('round-trip: custom global template → export → wipe → import → '
        'template is in the DAO AND selected by a real session', () async {
      // Source device: seeded DB + a custom global template written the way
      // the Templates editor writes it.
      final srcTmp = Directory.systemTemp.createTempSync('tpl_backup_src_');
      addTearDown(() => srcTmp.deleteSync(recursive: true));
      final srcSettings = AppSettingsRepository(
        keyProvider: () async => '00' * 32,
        resolveDir: () async => srcTmp,
      );
      final srcProfile = UserProfileRepository(
        keyProvider: () async => '00' * 32,
        resolveDir: () async => srcTmp,
      );
      final custom = ReminderTemplate(
        id: 'tmpl-mine',
        name: 'My Disguise',
        title: 'Yoga class',
        body: 'Mat session at 7',
        confirmationType: ConfirmationType.dismiss,
        isCustom: true,
        displayStyle: ReminderDisplayStyle.subtle,
        isGlobal: true,
      );
      await db.reminderTemplatesDao.upsert(custom);
      final exporter = RealBackupService(
        db: db,
        contacts: ContactsRepository(db.contactsDao),
        appSettings: srcSettings,
        userProfile: srcProfile,
        sessionLogs: SessionLogRepository(db.sessionLogsDao),
      );
      final json = await exporter.exportToJson();

      // Wipe: a brand-new empty DB and fresh settings store.
      final freshDb = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
      addTearDown(freshDb.close);
      final dstTmp = Directory.systemTemp.createTempSync('tpl_backup_dst_');
      addTearDown(() => dstTmp.deleteSync(recursive: true));
      final dstSettings = AppSettingsRepository(
        keyProvider: () async => '00' * 32,
        resolveDir: () async => dstTmp,
      );
      final importer = RealBackupService(
        db: freshDb,
        contacts: ContactsRepository(freshDb.contactsDao),
        appSettings: dstSettings,
        userProfile: UserProfileRepository(
          keyProvider: () async => '00' * 32,
          resolveDir: () async => dstTmp,
        ),
        sessionLogs: SessionLogRepository(freshDb.sessionLogsDao),
      );
      await importer.importFromJson(json);

      // The DAO carries the custom template (payload['templates']).
      final restored = await freshDb.reminderTemplatesDao.getById('tmpl-mine');
      check(restored).isNotNull();
      check(restored!.body).equals('Mat session at 7');

      // And a real session on the restored device selects it.
      final container = _container(freshDb, settingsRepository: dstSettings);
      await container.read(sessionControllerProvider.future);
      await container
          .read(sessionControllerProvider.notifier)
          .startSession(
            mode: _reminderMode(templateIds: const <String>['tmpl-mine']),
            simulate: false,
          );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(sessionControllerProvider).value;
      check(state!.activeReminderTemplate).isNotNull();
      check(state.activeReminderTemplate!.id).equals('tmpl-mine');

      await container.read(sessionControllerProvider.notifier).endSession();
    });
  });
}
