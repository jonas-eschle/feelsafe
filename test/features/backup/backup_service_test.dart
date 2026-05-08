/// Tests for [BackupService].
///
/// Covers plain round-trip, PIN-encrypted round-trip, version
/// mismatch rejection, wrong-PIN rejection, tampered-payload
/// rejection, empty-PIN equivalence, format errors, and each
/// repository section.
library;

import 'dart:convert';
import 'dart:math';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/battery_alert_repository.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/data/repositories/modes_repository.dart';
import 'package:guardianangela/data/repositories/session_logs_repository.dart';
import 'package:guardianangela/data/repositories/settings_repository.dart';
import 'package:guardianangela/data/repositories/templates_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/battery_alert_config.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/features/backup/backup_service.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('BackupService', () {
    late _FakeModesRepo modes;
    late _FakeContactsRepo contacts;
    late _FakeTemplatesRepo templates;
    late _FakeSettingsRepo settings;
    late _FakeUserProfileRepo userProfile;
    late _FakeBatteryAlertRepo batteryAlert;
    late _FakeSessionLogsRepo sessionLogs;
    late BackupService service;

    setUp(() {
      modes = _FakeModesRepo();
      contacts = _FakeContactsRepo();
      templates = _FakeTemplatesRepo();
      settings = _FakeSettingsRepo();
      userProfile = _FakeUserProfileRepo();
      batteryAlert = _FakeBatteryAlertRepo();
      sessionLogs = _FakeSessionLogsRepo();
      service = BackupService(
        modesRepository: modes,
        contactsRepository: contacts,
        templatesRepository: templates,
        settingsRepository: settings,
        userProfileRepository: userProfile,
        batteryAlertRepository: batteryAlert,
        sessionLogsRepository: sessionLogs,
        random: Random(42),
      );
    });

    test('exports version and exportedAt', () async {
      final payload = await service.exportAll();
      check(payload['version']).equals(kBackupVersion);
      check(payload['encrypted']).equals(false);
      check(payload['exportedAt']).isA<String>();
    });

    test('exports every section key when unencrypted', () async {
      final payload = await service.exportAll();
      for (final key in const [
        'modes',
        'contacts',
        'templates',
        'sessionLogs',
      ]) {
        check(payload.containsKey(key)).isTrue();
      }
    });

    test('round-trips modes / contacts / templates', () async {
      modes.items[_modeA.id] = _modeA;
      contacts.items[_contactA.id] = _contactA;
      templates.items[_templateA.id] = _templateA;
      settings.value = _settingsA;
      userProfile.value = _profileA;
      batteryAlert.value = _batteryA;
      sessionLogs.items[_logA.id] = _logA;

      final payload = await service.exportAll();

      modes.items.clear();
      contacts.items.clear();
      templates.items.clear();
      sessionLogs.items.clear();
      settings.value = null;
      userProfile.value = null;
      batteryAlert.value = null;

      await service.importAll(payload);

      check(modes.items[_modeA.id]).equals(_modeA);
      check(contacts.items[_contactA.id]).equals(_contactA);
      check(templates.items[_templateA.id]).equals(_templateA);
      check(settings.value).equals(_settingsA);
      check(userProfile.value).equals(_profileA);
      check(batteryAlert.value).equals(_batteryA);
      check(sessionLogs.items[_logA.id]).equals(_logA);
    });

    test('PIN-encrypted export hides section keys', () async {
      modes.items[_modeA.id] = _modeA;
      final payload = await service.exportAll(pin: 'secret-pin');
      check(payload['encrypted']).equals(true);
      check(payload.containsKey('modes')).isFalse();
      check(payload.containsKey('ciphertext')).isTrue();
      check(payload.containsKey('salt')).isTrue();
      check(payload.containsKey('nonce')).isTrue();
      check(payload.containsKey('tag')).isTrue();
    });

    test('PIN round-trip restores modes', () async {
      modes.items[_modeA.id] = _modeA;
      final payload = await service.exportAll(pin: 'correct-pin');
      modes.items.clear();
      await service.importAll(payload, pin: 'correct-pin');
      check(modes.items[_modeA.id]).equals(_modeA);
    });

    test('wrong PIN throws BackupAuthenticationError', () async {
      final payload = await service.exportAll(pin: 'pin-one');
      await check(
        service.importAll(payload, pin: 'pin-two'),
      ).throws<BackupAuthenticationError>();
    });

    test('missing PIN on encrypted bundle throws BackupFormatError', () async {
      final payload = await service.exportAll(pin: 'pin-one');
      await check(service.importAll(payload)).throws<BackupFormatError>();
    });

    test('tampered ciphertext throws BackupAuthenticationError', () async {
      modes.items[_modeA.id] = _modeA;
      final payload = await service.exportAll(pin: 'pin-one');
      // Flip one byte in-place, keep base64 size the same.
      final raw = base64Decode(payload['ciphertext']! as String);
      raw[0] ^= 0x01;
      final mutated = Map<String, Object?>.from(payload)
        ..['ciphertext'] = base64Encode(raw);
      await check(
        service.importAll(mutated, pin: 'pin-one'),
      ).throws<BackupAuthenticationError>();
    });

    test('version-0 payload is rejected', () async {
      await check(
        service.importAll(const {'version': 0, 'encrypted': false}),
      ).throws<BackupVersionError>();
    });

    test('version-2 payload is rejected', () async {
      await check(
        service.importAll(const {'version': 2, 'encrypted': false}),
      ).throws<BackupVersionError>();
    });

    test('missing version is rejected', () async {
      await check(
        service.importAll(const {'encrypted': false}),
      ).throws<BackupVersionError>();
    });

    test('empty PIN behaves as no PIN (unencrypted)', () async {
      final payload = await service.exportAll(pin: '');
      check(payload['encrypted']).equals(false);
    });

    test('import wipes existing data (nuke-and-reseed)', () async {
      final payload = await service.exportAll();
      // Now add stale data that is NOT in the payload; import must
      // drop it.
      modes.items['stale'] = makeMode(id: 'stale');
      await service.importAll(payload);
      check(modes.items.containsKey('stale')).isFalse();
    });

    test('empty bundle imports without errors', () async {
      final payload = await service.exportAll();
      await service.importAll(payload);
      check(modes.items).isEmpty();
    });

    test('malformed base64 field throws BackupFormatError', () async {
      final payload = await service.exportAll(pin: 'pin');
      final mutated = Map<String, Object?>.from(payload)
        ..['salt'] = 'not-base-64!!';
      await check(
        service.importAll(mutated, pin: 'pin'),
      ).throws<BackupFormatError>();
    });

    test('plain-text export preserves exported sessionLog count', () async {
      sessionLogs.items[_logA.id] = _logA;
      final payload = await service.exportAll();
      final logs = payload['sessionLogs'] as List<Object?>;
      check(logs.length).equals(1);
    });

    test('PIN shorter than 8 chars still round-trips', () async {
      modes.items[_modeA.id] = _modeA;
      final payload = await service.exportAll(pin: '1234');
      modes.items.clear();
      await service.importAll(payload, pin: '1234');
      check(modes.items[_modeA.id]).equals(_modeA);
    });

    test('unicode-heavy PIN round-trips', () async {
      modes.items[_modeA.id] = _modeA;
      final payload = await service.exportAll(pin: 'P\u00e4sswörd1\u{1F510}');
      modes.items.clear();
      await service.importAll(payload, pin: 'P\u00e4sswörd1\u{1F510}');
      check(modes.items[_modeA.id]).equals(_modeA);
    });
  });
}

// ---------- Fixtures ----------

final _modeA = makeMode(id: 'mode-a', name: 'Walk Mode');
final _contactA = makeContact(id: 'contact-a', name: 'Alice');
final _templateA = ReminderTemplate(
  id: 'tpl-a',
  name: 'Calendar',
  title: 'Event',
  body: 'Reminder',
  confirmationType: ConfirmationType.tapButton,
  displayStyle: ReminderDisplayStyle.fullScreen,
  isGlobal: true,
);
final _settingsA = AppSettings(
  defaults: const AppDefaults(),
  emergencyCallNumber: '911',
  telemetryOptOut: true,
  sessionLogRetentionDays: 14,
);
const _profileA = UserProfile(
  name: 'Test User',
  bloodType: 'O+',
  allergies: 'Peanuts',
);
const _batteryA = BatteryAlertConfig(enabled: true, thresholdPercent: 15);
final _logA = SessionLog(
  id: 'log-a',
  modeId: 'mode-a',
  modeName: 'Walk Mode',
  startedAt: DateTime.utc(2026, 4, 20, 12),
  endedAt: DateTime.utc(2026, 4, 20, 13),
  endReason: EndReason.chainExhausted,
  isSimulation: false,
  events: const [],
);

// ---------- Fake repositories ----------

class _FakeModesRepo extends ModesRepository {
  _FakeModesRepo() : super.forTesting();
  final Map<String, SessionMode> items = {};
  @override
  Future<List<SessionMode>> getAll() async => items.values.toList();
  @override
  Future<SessionMode?> getById(String id) async => items[id];
  @override
  Future<void> save(SessionMode value) async => items[value.id] = value;
  @override
  Future<void> saveAll(List<SessionMode> values) async {
    for (final v in values) {
      items[v.id] = v;
    }
  }

  @override
  Future<void> delete(String id) async => items.remove(id);
  @override
  Future<void> deleteAll() async => items.clear();
}

class _FakeContactsRepo extends ContactsRepository {
  _FakeContactsRepo() : super.forTesting();
  final Map<String, EmergencyContact> items = {};
  @override
  Future<List<EmergencyContact>> getAll() async => items.values.toList();
  @override
  Future<EmergencyContact?> getById(String id) async => items[id];
  @override
  Future<void> save(EmergencyContact value) async => items[value.id] = value;
  @override
  Future<void> delete(String id) async => items.remove(id);
  @override
  Future<void> deleteAll() async => items.clear();
}

class _FakeTemplatesRepo extends TemplatesRepository {
  _FakeTemplatesRepo() : super.forTesting();
  final Map<String, ReminderTemplate> items = {};
  @override
  Future<List<ReminderTemplate>> getAll() async => items.values.toList();
  @override
  Future<List<ReminderTemplate>> getAllGlobal() async =>
      items.values.where((t) => t.isGlobal).toList();
  @override
  Future<ReminderTemplate?> getById(String id) async => items[id];
  @override
  Future<void> save(ReminderTemplate value) async => items[value.id] = value;
  @override
  Future<void> delete(String id) async => items.remove(id);
  @override
  Future<void> deleteAll() async => items.clear();
}

class _FakeSettingsRepo extends SettingsRepository {
  _FakeSettingsRepo() : super.forTesting();
  AppSettings? value;
  @override
  Future<AppSettings?> get() async => value;
  @override
  Future<void> save(AppSettings v) async => value = v;
}

class _FakeUserProfileRepo extends UserProfileRepository {
  _FakeUserProfileRepo() : super.forTesting();
  UserProfile? value;
  @override
  Future<UserProfile?> get() async => value;
  @override
  Future<void> save(UserProfile v) async => value = v;
}

class _FakeBatteryAlertRepo extends BatteryAlertRepository {
  _FakeBatteryAlertRepo() : super.forTesting();
  BatteryAlertConfig? value;
  @override
  Future<BatteryAlertConfig?> get() async => value;
  @override
  Future<void> save(BatteryAlertConfig v) async => value = v;
}

class _FakeSessionLogsRepo extends SessionLogsRepository {
  _FakeSessionLogsRepo() : super.forTesting();
  final Map<String, SessionLog> items = {};
  @override
  Future<List<SessionLog>> getAll() async => items.values.toList();
  @override
  Future<SessionLog?> getById(String id) async => items[id];
  @override
  Future<void> save(SessionLog value) async => items[value.id] = value;
  @override
  Future<void> delete(String id) async => items.remove(id);
  @override
  Future<void> deleteAll() async => items.clear();
}
