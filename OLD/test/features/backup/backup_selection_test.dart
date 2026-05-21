/// Tests for [BackupSelection] value-object methods (copyWith,
/// equality, hashCode, toString) and the [BackupService._base64Field]
/// non-string-value error path.
library;

import 'dart:math';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/battery_alert_repository.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/data/repositories/modes_repository.dart';
import 'package:guardianangela/data/repositories/session_logs_repository.dart';
import 'package:guardianangela/data/repositories/settings_repository.dart';
import 'package:guardianangela/data/repositories/templates_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/battery_alert_config.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/features/backup/backup_service.dart';

void main() {
  group('BackupSelection', () {
    test('all preset has all flags true', () {
      const sel = BackupSelection.all;
      check(sel.contacts).isTrue();
      check(sel.modes).isTrue();
      check(sel.distressModes).isTrue();
      check(sel.templates).isTrue();
      check(sel.sessionLogs).isTrue();
      check(sel.recordings).isTrue();
    });

    test('copyWith replaces contacts', () {
      const sel = BackupSelection();
      final sel2 = sel.copyWith(contacts: false);
      check(sel2.contacts).isFalse();
      check(sel2.modes).isTrue();
    });

    test('copyWith replaces modes', () {
      final sel = const BackupSelection().copyWith(modes: false);
      check(sel.modes).isFalse();
      check(sel.contacts).isTrue();
    });

    test('copyWith replaces distressModes', () {
      final sel = const BackupSelection().copyWith(distressModes: false);
      check(sel.distressModes).isFalse();
    });

    test('copyWith replaces templates', () {
      final sel = const BackupSelection().copyWith(templates: false);
      check(sel.templates).isFalse();
    });

    test('copyWith replaces sessionLogs', () {
      final sel = const BackupSelection().copyWith(sessionLogs: false);
      check(sel.sessionLogs).isFalse();
    });

    test('copyWith replaces recordings', () {
      final sel = const BackupSelection().copyWith(recordings: false);
      check(sel.recordings).isFalse();
    });

    test('copyWith with no args returns equivalent object', () {
      const sel = BackupSelection(contacts: false, modes: false);
      final sel2 = sel.copyWith();
      check(sel2).equals(sel);
    });

    test('equality: identical instances are equal', () {
      const sel = BackupSelection();
      check(sel == sel).isTrue();
    });

    test('equality: two identical-flag instances are equal', () {
      const a = BackupSelection(contacts: false);
      const b = BackupSelection(contacts: false);
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });

    test('equality: differs by contacts', () {
      check(
        const BackupSelection() == const BackupSelection(contacts: false),
      ).isFalse();
    });

    test('equality: differs by modes', () {
      check(
        const BackupSelection() == const BackupSelection(modes: false),
      ).isFalse();
    });

    test('equality: differs by distressModes', () {
      check(
        const BackupSelection() == const BackupSelection(distressModes: false),
      ).isFalse();
    });

    test('equality: differs by templates', () {
      check(
        const BackupSelection() == const BackupSelection(templates: false),
      ).isFalse();
    });

    test('equality: differs by sessionLogs', () {
      check(
        const BackupSelection() == const BackupSelection(sessionLogs: false),
      ).isFalse();
    });

    test('equality: differs by recordings', () {
      check(
        const BackupSelection() == const BackupSelection(recordings: false),
      ).isFalse();
    });

    test('equality: cross-type returns false', () {
      // ignore: unrelated_type_equality_checks
      check(const BackupSelection() == 'x').isFalse();
    });

    test('toString contains flag names', () {
      final s = const BackupSelection(contacts: false).toString();
      check(s).contains('contacts');
      check(s).contains('false');
    });
  });

  group('BackupService._base64Field non-string value', () {
    // The _base64Field helper throws BackupFormatError when the field
    // value exists but is not a String. We reach this by building an
    // encrypted payload and replacing a base64 field with a non-string.
    late BackupService service;

    setUp(() {
      service = BackupService(
        modesRepository: _NullModesRepo(),
        contactsRepository: _NullContactsRepo(),
        templatesRepository: _NullTemplatesRepo(),
        settingsRepository: _NullSettingsRepo(),
        userProfileRepository: _NullUserProfileRepo(),
        batteryAlertRepository: _NullBatteryAlertRepo(),
        sessionLogsRepository: _NullSessionLogsRepo(),
        random: Random(0),
      );
    });

    test('non-string salt field throws BackupFormatError', () async {
      final payload = await service.exportAll(pin: 'secret');
      final mutated = Map<String, Object?>.from(payload)..['salt'] = 42;
      await check(
        service.importAll(mutated, pin: 'secret'),
      ).throws<BackupFormatError>();
    });

    test('non-string nonce field throws BackupFormatError', () async {
      final payload = await service.exportAll(pin: 'secret');
      final mutated = Map<String, Object?>.from(payload)..['nonce'] = true;
      await check(
        service.importAll(mutated, pin: 'secret'),
      ).throws<BackupFormatError>();
    });
  });
}

// ---------------------------------------------------------------------------
// Minimal stub repositories that return empty/null data.
// ---------------------------------------------------------------------------

class _NullModesRepo extends ModesRepository {
  _NullModesRepo() : super.forTesting();
  @override
  Future<List<SessionMode>> getAll() async => const [];
}

class _NullContactsRepo extends ContactsRepository {
  _NullContactsRepo() : super.forTesting();
  @override
  Future<List<EmergencyContact>> getAll() async => const [];
}

class _NullTemplatesRepo extends TemplatesRepository {
  _NullTemplatesRepo() : super.forTesting();
  @override
  Future<List<ReminderTemplate>> getAll() async => const [];
  @override
  Future<List<ReminderTemplate>> getAllGlobal() async => const [];
}

class _NullSettingsRepo extends SettingsRepository {
  _NullSettingsRepo() : super.forTesting();
  @override
  Future<AppSettings?> get() async => null;
}

class _NullUserProfileRepo extends UserProfileRepository {
  _NullUserProfileRepo() : super.forTesting();
  @override
  Future<UserProfile?> get() async => null;
}

class _NullBatteryAlertRepo extends BatteryAlertRepository {
  _NullBatteryAlertRepo() : super.forTesting();
  @override
  Future<BatteryAlertConfig?> get() async => null;
}

class _NullSessionLogsRepo extends SessionLogsRepository {
  _NullSessionLogsRepo() : super.forTesting();
  @override
  Future<List<SessionLog>> getAll() async => const [];
}
