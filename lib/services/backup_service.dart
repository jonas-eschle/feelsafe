import 'dart:convert';
import 'dart:developer';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/services/protocols/backup_service_protocol.dart';

/// Current schema version emitted in [exportToJson].
///
/// [importFromJson] rejects payloads whose `_schemaVersion` is strictly
/// greater than this value (forward-incompatible — spec 05 §BackupService
/// §Import Validation).
const int _kSchemaVersion = 1;

/// Production [BackupServiceProtocol].
///
/// Reads from all Drift-backed and JSON-singleton repositories and assembles
/// a single JSON string per spec 05 §BackupService §Export Format.
///
/// Import writes Drift-backed entities inside a single transaction (rolled
/// back atomically on failure) and then writes JSON singletons individually
/// (each file is an independent unit).
///
/// **`share_plus` is NOT called here.** The UI layer passes the exported
/// string to `Share.shareXFiles(...)`.
///
/// **Single constructor location rule:** no `RealBackupService()` call may
/// appear outside `lib/services/service_providers.dart` (CI grep enforces).
class RealBackupService implements BackupServiceProtocol {
  /// Creates a [RealBackupService].
  const RealBackupService({
    required GuardianAngelaDatabase db,
    required ContactsRepository contacts,
    required AppSettingsRepository appSettings,
    required UserProfileRepository userProfile,
    required SessionLogRepository sessionLogs,
  }) : _db = db,
       _contacts = contacts,
       _appSettings = appSettings,
       _userProfile = userProfile,
       _sessionLogs = sessionLogs;

  final GuardianAngelaDatabase _db;
  final ContactsRepository _contacts;
  final AppSettingsRepository _appSettings;
  final UserProfileRepository _userProfile;
  final SessionLogRepository _sessionLogs;

  // ---------------------------------------------------------------------------
  // BackupServiceProtocol implementation
  // ---------------------------------------------------------------------------

  @override
  Future<String> exportToJson({
    bool includeSessionLogs = true,
    bool includeMedia = true,
  }) async {
    log(
      'exportToJson includeSessionLogs=$includeSessionLogs '
      'includeMedia=$includeMedia',
      name: 'BackupService',
    );

    final contacts = await _contacts.getAll();
    final modes = await _db.sessionModesDao.getAll();
    final templates = await _db.reminderTemplatesDao.getAll();
    final settings = await _appSettings.load();
    final profile = await _userProfile.load();

    final profileJson = profile.toJson();
    if (!includeMedia) {
      profileJson.remove('photoPath');
    }

    final Map<String, dynamic> payload = {
      'version': '1.0',
      '_schemaVersion': _kSchemaVersion,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'contacts': contacts.map((c) => c.toJson()).toList(),
      'modes': modes.map((m) => m.toJson()).toList(),
      'settings': settings.toJson(),
      'templates': templates.map((t) => t.toJson()).toList(),
      'eventDefaults': settings.defaults.eventDefaults.toJson(),
      'profile': profileJson,
    };

    if (includeSessionLogs) {
      // Include trashed rows so backup → restore round-trips with full
      // fidelity (deletedAt is preserved across the boundary).
      final logs = await _db.sessionLogsDao.getAllOrderedByStartDesc(
        includeTrashed: true,
      );
      payload['sessionLogs'] = logs.map((l) => l.toJson()).toList();
    }

    final result = jsonEncode(payload);
    log('exportToJson: ${result.length} chars', name: 'BackupService');
    return result;
  }

  @override
  Future<void> importFromJson(String json) async {
    log('importFromJson: parsing', name: 'BackupService');

    final Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Top-level JSON value must be a JSON object.',
        );
      }
      payload = decoded;
    } on FormatException {
      rethrow;
    } catch (e) {
      throw FormatException('Backup JSON could not be parsed: $e');
    }

    // Schema version guard.
    final rawVersion = payload['_schemaVersion'];
    if (rawVersion is! int) {
      throw const FormatException(
        'Backup is missing a valid _schemaVersion field.',
      );
    }
    if (rawVersion > _kSchemaVersion) {
      throw StateError(
        'Backup was created with schema v$rawVersion; this app only supports '
        'up to v$_kSchemaVersion. Upgrade the app to restore this backup.',
      );
    }

    log(
      'importFromJson: schema v$rawVersion — writing Drift data',
      name: 'BackupService',
    );

    // Drift entities — inside a single transaction so any failure leaves the
    // existing database completely untouched (spec 05 §Import Validation).
    await _db.transaction(() async {
      // Clear existing rows.
      await _db.delete(_db.contacts).go();
      await _db.delete(_db.sessionModes).go();
      await _db.delete(_db.reminderTemplates).go();
      await _db.delete(_db.sessionLogs).go();

      // Restore contacts.
      final contactsRaw = payload['contacts'];
      if (contactsRaw is List) {
        for (final item in contactsRaw) {
          if (item is Map<String, dynamic>) {
            await _db.contactsDao.upsert(EmergencyContact.fromJson(item));
          }
        }
      }

      // Restore modes.
      final modesRaw = payload['modes'];
      if (modesRaw is List) {
        for (final item in modesRaw) {
          if (item is Map<String, dynamic>) {
            await _db.sessionModesDao.upsert(SessionMode.fromJson(item));
          }
        }
      }

      // Restore reminder templates.
      final templatesRaw = payload['templates'];
      if (templatesRaw is List) {
        for (final item in templatesRaw) {
          if (item is Map<String, dynamic>) {
            await _db.reminderTemplatesDao.upsert(
              ReminderTemplate.fromJson(item),
            );
          }
        }
      }

      // Restore session logs (optional — key may be absent).
      final logsRaw = payload['sessionLogs'];
      if (logsRaw is List) {
        for (final item in logsRaw) {
          if (item is Map<String, dynamic>) {
            await _sessionLogs.upsert(SessionLog.fromJson(item));
          }
        }
      }
    });

    // JSON singletons — individual writes after the Drift transaction
    // succeeds. On failure the singletons remain unchanged.
    final settingsRaw = payload['settings'];
    if (settingsRaw is Map<String, dynamic>) {
      await _appSettings.save(AppSettings.fromJson(settingsRaw));
    }

    final profileRaw = payload['profile'];
    if (profileRaw is Map<String, dynamic>) {
      await _userProfile.save(UserProfile.fromJson(profileRaw));
    }

    log('importFromJson: complete', name: 'BackupService');
  }
}
