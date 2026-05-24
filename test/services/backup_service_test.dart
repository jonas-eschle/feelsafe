// Tests for RealBackupService and SimulationBackupService (Stage 5C.3).
//
// Uses an in-memory GuardianAngelaDatabase (no seed) so every test starts
// with a clean slate. AppSettingsRepository and UserProfileRepository are
// backed by a temporary temp-dir resolver so there is no disk I/O to the
// real app-documents path.

import 'dart:convert';
import 'dart:io';

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/repositories/battery_alert_config_repository.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/domain/models/validation_result.dart';
import 'package:guardianangela/services/backup_service.dart';
import 'package:guardianangela/services/sim/backup_service_sim.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Synchronous in-memory key provider for test repositories.
///
/// 64 hex chars = 32 bytes, accepted by JsonSingletonRepository._decodeKey.
Future<String> _fakeKey() async =>
    '0000000000000000000000000000000000000000000000000000000000000000';

/// Opens a no-seed in-memory database.
GuardianAngelaDatabase _openDb() =>
    GuardianAngelaDatabase.memory(seedCallback: (_) async {});

/// Resolves to [dir] instead of the real app-documents path.
Future<Directory> Function() _tempResolver(Directory dir) => () async => dir;

/// Builds a [RealBackupService] wired to an in-memory DB and temp-dir repos.
Future<
  ({
    RealBackupService service,
    GuardianAngelaDatabase db,
    AppSettingsRepository appSettings,
    UserProfileRepository userProfile,
    SessionLogRepository sessionLogs,
    Directory tmpDir,
  })
> _make() async {
  final db = _openDb();
  final tmp = Directory.systemTemp.createTempSync('backup_test_');
  final appSettings = AppSettingsRepository(
    keyProvider: _fakeKey,
    resolveDir: _tempResolver(tmp),
  );
  final userProfile = UserProfileRepository(
    keyProvider: _fakeKey,
    resolveDir: _tempResolver(tmp),
  );
  final batteryAlertConfig = BatteryAlertConfigRepository(
    keyProvider: _fakeKey,
    resolveDir: _tempResolver(tmp),
  );
  final sessionLogs = SessionLogRepository(db.sessionLogsDao);

  final service = RealBackupService(
    db: db,
    contacts: ContactsRepository(db.contactsDao),
    appSettings: appSettings,
    userProfile: userProfile,
    batteryAlertConfig: batteryAlertConfig,
    sessionLogs: sessionLogs,
  );

  return (
    service: service,
    db: db,
    appSettings: appSettings,
    userProfile: userProfile,
    sessionLogs: sessionLogs,
    tmpDir: tmp,
  );
}

void _cleanup(({
  RealBackupService service,
  GuardianAngelaDatabase db,
  AppSettingsRepository appSettings,
  UserProfileRepository userProfile,
  SessionLogRepository sessionLogs,
  Directory tmpDir,
}) env) {
  env.db.close();
  env.tmpDir.deleteSync(recursive: true);
}

/// A minimal valid [SessionLog] for tests.
SessionLog _log({String id = 'log1'}) => SessionLog(
  id: id,
  modeId: 'mode1',
  modeName: 'Test Mode',
  startedAt: DateTime.utc(2026, 1, 1, 10),
  endedAt: DateTime.utc(2026, 1, 1, 10, 5),
  isSimulation: false,
  events: const [],
);

/// A minimal valid [EmergencyContact] for tests.
EmergencyContact _contact({String id = 'c1', String name = 'Alice'}) =>
    EmergencyContact(
      id: id,
      name: name,
      phoneNumber: '+15551234567',
      sortOrder: 0,
    );

/// A minimal valid [SessionMode] for tests (single holdButton step).
SessionMode _mode({String id = 'mode1', String name = 'Walk'}) =>
    SessionMode(
      id: id,
      name: name,
      chainSteps: [
        ChainStep(
          id: 'step1',
          type: ChainStepType.holdButton,
          order: 0,
          waitSeconds: 60,
          durationSeconds: 30,
          gracePeriodSeconds: 10,
          retryCount: 0,
          randomize: false,
        ),
      ],
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // --------------------------------------------------------------------------
  group('RealBackupService — exportToJson()', () {
    test('returns valid JSON with expected top-level keys', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      final json = await env.service.exportToJson();
      final Map<String, dynamic> payload = jsonDecode(json) as Map<String, dynamic>;

      check(payload).containsKey('version');
      check(payload).containsKey('_schemaVersion');
      check(payload).containsKey('timestamp');
      check(payload).containsKey('contacts');
      check(payload).containsKey('modes');
      check(payload).containsKey('settings');
      check(payload).containsKey('templates');
      check(payload).containsKey('eventDefaults');
      check(payload).containsKey('profile');
    });

    test('_schemaVersion is 1', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      final payload = jsonDecode(await env.service.exportToJson()) as Map<String, dynamic>;
      check(payload['_schemaVersion']).equals(1);
    });

    test('timestamp is a valid ISO 8601 UTC string', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      final payload = jsonDecode(await env.service.exportToJson()) as Map<String, dynamic>;
      final ts = payload['timestamp'] as String;
      check(ts).isNotEmpty();
      check(() => DateTime.parse(ts)).returnsNormally();
    });

    test('includes contacts that were inserted before export', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      await env.db.contactsDao.upsert(_contact());
      final payload = jsonDecode(await env.service.exportToJson()) as Map<String, dynamic>;
      final contacts = payload['contacts'] as List<dynamic>;
      check(contacts.length).equals(1);
      check((contacts.first as Map<String, dynamic>)['id']).equals('c1');
    });

    test('includeSessionLogs=true includes sessionLogs key', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      await env.sessionLogs.upsert(_log());
      final payload = jsonDecode(
        await env.service.exportToJson(),
      ) as Map<String, dynamic>;
      check(payload).containsKey('sessionLogs');
      final logs = payload['sessionLogs'] as List<dynamic>;
      check(logs.length).equals(1);
    });

    test('includeSessionLogs=false omits sessionLogs key entirely', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      await env.sessionLogs.upsert(_log());
      final payload = jsonDecode(
        await env.service.exportToJson(includeSessionLogs: false),
      ) as Map<String, dynamic>;
      check(payload.containsKey('sessionLogs')).isFalse();
    });

    test('includeMedia=false strips photoPath from profile', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      await env.userProfile.save(
        const UserProfile(name: 'Angela', photoPath: '/some/photo.jpg'),
      );
      final payload = jsonDecode(
        await env.service.exportToJson(includeMedia: false),
      ) as Map<String, dynamic>;
      final profile = payload['profile'] as Map<String, dynamic>;
      check(profile.containsKey('photoPath')).isFalse();
      check(profile['name']).equals('Angela');
    });

    test('includeMedia=true keeps photoPath in profile', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      await env.userProfile.save(
        const UserProfile(photoPath: '/some/photo.jpg'),
      );
      final payload = jsonDecode(
        await env.service.exportToJson(),
      ) as Map<String, dynamic>;
      final profile = payload['profile'] as Map<String, dynamic>;
      check(profile.containsKey('photoPath')).isTrue();
      check(profile['photoPath']).equals('/some/photo.jpg');
    });
  });

  // --------------------------------------------------------------------------
  group('RealBackupService — importFromJson() happy path', () {
    test('restores contacts from export', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      await env.db.contactsDao.upsert(_contact());
      await env.db.contactsDao.upsert(_contact(id: 'c2', name: 'Bob'));
      final exported = await env.service.exportToJson(includeSessionLogs: false);

      // Wipe the contacts and import the backup.
      await env.db.delete(env.db.contacts).go();
      await env.service.importFromJson(exported);

      final restored = await env.db.contactsDao.getAll();
      check(restored.length).equals(2);
      final names = restored.map((c) => c.name).toSet();
      check(names).contains('Alice');
      check(names).contains('Bob');
    });

    test('restores session modes from export', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      await env.db.sessionModesDao.upsert(_mode());
      final exported = await env.service.exportToJson(includeSessionLogs: false);

      await env.db.delete(env.db.sessionModes).go();
      await env.service.importFromJson(exported);

      final restored = await env.db.sessionModesDao.getAll();
      check(restored).isNotEmpty();
      check(restored.any((m) => m.id == 'mode1')).isTrue();
    });

    test('clears existing contacts before restoring', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      // Export with c1 only.
      await env.db.contactsDao.upsert(_contact());
      final exported = await env.service.exportToJson(includeSessionLogs: false);

      // Add a second contact AFTER the export.
      await env.db.contactsDao.upsert(_contact(id: 'c2', name: 'Carol'));
      check(await env.db.contactsDao.getAll()).has((l) => l.length, 'length').equals(2);

      // Import should replace with only c1.
      await env.service.importFromJson(exported);
      final after = await env.db.contactsDao.getAll();
      check(after.length).equals(1);
      check(after.first.id).equals('c1');
    });

    test('restores session logs when present in backup', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      await env.sessionLogs.upsert(_log());
      final exported = await env.service.exportToJson();

      await env.db.delete(env.db.sessionLogs).go();
      await env.service.importFromJson(exported);

      final restored = await env.db.sessionLogsDao.getAllOrderedByStartDesc();
      check(restored.length).equals(1);
      check(restored.first.id).equals('log1');
    });

    test('missing sessionLogs key in JSON does not throw', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      final exported = await env.service.exportToJson(includeSessionLogs: false);
      // Should not throw even though key is absent.
      await check(env.service.importFromJson(exported)).completes();
    });

    test('restores AppSettings after import', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      const customSettings = AppSettings(
        languageCode: 'de',
        emergencyCallNumber: '110',
      );
      await env.appSettings.save(customSettings);
      final exported = await env.service.exportToJson(includeSessionLogs: false);

      // Override settings before import.
      await env.appSettings.save(const AppSettings());
      await env.service.importFromJson(exported);

      final restored = await env.appSettings.load();
      check(restored.languageCode).equals('de');
      check(restored.emergencyCallNumber).equals('110');
    });

    test('restores UserProfile after import', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      await env.userProfile.save(const UserProfile(name: 'Angela', age: 30));
      final exported = await env.service.exportToJson(includeSessionLogs: false);

      await env.userProfile.save(const UserProfile(name: 'Unknown'));
      await env.service.importFromJson(exported);

      final restored = await env.userProfile.load();
      check(restored.name).equals('Angela');
      check(restored.age).equals(30);
    });
  });

  // --------------------------------------------------------------------------
  group('RealBackupService — importFromJson() error handling', () {
    test('malformed JSON throws FormatException', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      await check(
        env.service.importFromJson('{not valid json'),
      ).throws<FormatException>();
    });

    test('top-level JSON array (not object) throws FormatException', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      await check(
        env.service.importFromJson('[1, 2, 3]'),
      ).throws<FormatException>();
    });

    test('missing _schemaVersion field throws FormatException', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      final json = jsonEncode(<String, dynamic>{'version': '1.0', 'contacts': <dynamic>[]});
      await check(
        env.service.importFromJson(json),
      ).throws<FormatException>();
    });

    test('_schemaVersion with wrong type (string) throws FormatException',
        () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      final json = jsonEncode(<String, dynamic>{'_schemaVersion': '1', 'contacts': <dynamic>[]});
      await check(
        env.service.importFromJson(json),
      ).throws<FormatException>();
    });

    test('_schemaVersion newer than app schema throws StateError', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      final json = jsonEncode(<String, dynamic>{
        '_schemaVersion': 999,
        'contacts': <dynamic>[],
        'modes': <dynamic>[],
        'templates': <dynamic>[],
        'settings': <String, dynamic>{},
        'profile': <String, dynamic>{},
      });
      await check(
        env.service.importFromJson(json),
      ).throws<StateError>();
    });

    test('older schema version is accepted (no throw)', () async {
      final env = await _make();
      addTearDown(() => _cleanup(env));

      // Export a v1 backup and manually set _schemaVersion to 0
      // (pretend we wrote it with an older schema).
      final base = jsonDecode(
        await env.service.exportToJson(includeSessionLogs: false),
      ) as Map<String, dynamic>;
      base['_schemaVersion'] = 0;
      await check(
        env.service.importFromJson(jsonEncode(base)),
      ).completes();
    });

    test('invalid contact JSON inside list does not crash (skipped)', () async {
      // Items that are not Map<String, dynamic> are silently skipped.
      final env = await _make();
      addTearDown(() => _cleanup(env));

      final json = jsonEncode(<String, dynamic>{
        '_schemaVersion': 1,
        'contacts': <dynamic>['not_a_map', 42],
        'modes': <dynamic>[],
        'templates': <dynamic>[],
        'settings': const AppSettings().toJson(),
        'profile': const UserProfile().toJson(),
      });
      await check(env.service.importFromJson(json)).completes();
    });

    test(
      'existing data is preserved when import fails (atomicity)',
      () async {
        final env = await _make();
        addTearDown(() => _cleanup(env));

        // Seed a contact.
        await env.db.contactsDao.upsert(_contact(id: 'original'));

        // Attempt to import JSON that is completely invalid.
        try {
          await env.service.importFromJson('invalid json');
        } catch (_) {
          // Expected.
        }

        // Original data must still be intact.
        final contacts = await env.db.contactsDao.getAll();
        check(contacts.any((c) => c.id == 'original')).isTrue();
      },
    );
  });

  // --------------------------------------------------------------------------
  group('SimulationBackupService', () {
    test('exportToJson returns the default envelope', () async {
      final v = SimulationBackupService();
      final json = await v.exportToJson();
      final payload = jsonDecode(json) as Map<String, dynamic>;
      check(payload).containsKey('_schemaVersion');
    });

    test('exportToJson returns constructor-injected fixedExport', () async {
      final custom = jsonEncode({'_schemaVersion': 1, 'custom': true});
      final v = SimulationBackupService(fixedExport: custom);
      final json = await v.exportToJson();
      check(json).equals(custom);
    });

    test('exportToJson records call parameters', () async {
      final v = SimulationBackupService();
      await v.exportToJson(includeSessionLogs: false, includeMedia: false);
      await v.exportToJson();
      check(v.exportCalls.length).equals(2);
      check(v.exportCalls.first.includeSessionLogs).isFalse();
      check(v.exportCalls.first.includeMedia).isFalse();
      check(v.exportCalls.last.includeSessionLogs).isTrue();
    });

    test('importFromJson records JSON strings passed', () async {
      final v = SimulationBackupService();
      const json1 = '{"_schemaVersion":1}';
      const json2 = '{"_schemaVersion":1,"extra":true}';
      await v.importFromJson(json1);
      await v.importFromJson(json2);
      check(v.importCalls.length).equals(2);
      check(v.importCalls.first).equals(json1);
      check(v.importCalls.last).equals(json2);
    });

    test('importFromJson does not throw on any input', () async {
      final v = SimulationBackupService();
      await check(v.importFromJson('not_real_json')).completes();
    });

    test('reset clears exportCalls and importCalls', () async {
      final v = SimulationBackupService();
      await v.exportToJson();
      await v.importFromJson('{}');
      v.reset();
      check(v.exportCalls).isEmpty();
      check(v.importCalls).isEmpty();
    });

    test('exportToJson default returns parseable JSON', () async {
      final v = SimulationBackupService();
      final json = await v.exportToJson();
      check(() => jsonDecode(json)).returnsNormally();
    });
  });

  // --------------------------------------------------------------------------
  group('ValidationResult (used by BackupService consumer layer)', () {
    test('ValidationResult.valid has no errors or warnings', () {
      const r = ValidationResult.valid();
      check(r.isValid).isTrue();
      check(r.errors).isEmpty();
      check(r.warnings).isEmpty();
    });

    test('ValidationResult with errors is not valid', () {
      const r = ValidationResult(
        errors: [
          ValidationIssue(
            title: 'Missing data',
            description: 'The backup is incomplete.',
          ),
        ],
        warnings: [],
      );
      check(r.isValid).isFalse();
    });

    test('ValidationResult with warnings only is still valid', () {
      const r = ValidationResult(
        errors: [],
        warnings: [
          ValidationIssue(
            title: 'Note',
            description: 'Media files excluded.',
          ),
        ],
      );
      check(r.isValid).isTrue();
    });
  });
}
