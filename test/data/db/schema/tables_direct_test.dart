// Schema regression test: hard-codes the expected column list for every
// Drift table so any accidental addition / rename / type-change breaks
// the test. Updates to the schema MUST update this file in the same
// commit.

import 'package:checks/checks.dart';
import 'package:drift/drift.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/db/database.dart';

void main() {
  late GuardianAngelaDatabase db;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
  });

  tearDown(() async {
    await db.close();
  });

  group('schema regression', () {
    test('schema version is 3 (Phase 6 gap-5)', () {
      // Phase 4 shipped v1; Phase 6c bumps to v2 (added
      // session_logs.deleted_at_ms); Phase 6 gap-5 bumps to v3
      // (added session_modes.is_built_in). Bumping triggers
      // nuke-and-reseed (pre-alpha policy).
      check(db.schemaVersion).equals(3);
    });

    test('contacts table columns match spec 03 §EmergencyContact', () {
      // Arrange + Act
      final cols = _columnSpec(db.contacts);
      // Assert
      check(cols).deepEquals({
        'id': (type: DriftSqlType.string, nullable: false, isPk: true),
        'name': (type: DriftSqlType.string, nullable: false, isPk: false),
        'phone_number': (
          type: DriftSqlType.string,
          nullable: false,
          isPk: false,
        ),
        'relationship': (
          type: DriftSqlType.string,
          nullable: true,
          isPk: false,
        ),
        'sort_order': (type: DriftSqlType.int, nullable: false, isPk: false),
        'channels_json': (
          type: DriftSqlType.string,
          nullable: false,
          isPk: false,
        ),
        'language_code': (
          type: DriftSqlType.string,
          nullable: true,
          isPk: false,
        ),
      });
    });

    test('reminder_templates columns match spec 03 §ReminderTemplate', () {
      final cols = _columnSpec(db.reminderTemplates);
      check(cols).deepEquals({
        'id': (type: DriftSqlType.string, nullable: false, isPk: true),
        'name': (type: DriftSqlType.string, nullable: false, isPk: false),
        'title': (type: DriftSqlType.string, nullable: false, isPk: false),
        'body': (type: DriftSqlType.string, nullable: false, isPk: false),
        'icon_asset': (type: DriftSqlType.string, nullable: true, isPk: false),
        'confirmation_type': (
          type: DriftSqlType.string,
          nullable: false,
          isPk: false,
        ),
        'keyword': (type: DriftSqlType.string, nullable: true, isPk: false),
        'button_label': (
          type: DriftSqlType.string,
          nullable: true,
          isPk: false,
        ),
        'is_custom': (type: DriftSqlType.bool, nullable: false, isPk: false),
        'image_path': (type: DriftSqlType.string, nullable: true, isPk: false),
        'subtitle': (type: DriftSqlType.string, nullable: true, isPk: false),
        'display_style': (
          type: DriftSqlType.string,
          nullable: false,
          isPk: false,
        ),
        'is_global': (type: DriftSqlType.bool, nullable: false, isPk: false),
      });
    });

    test('session_modes columns match spec 03 §SessionMode', () {
      final cols = _columnSpec(db.sessionModes);
      check(cols).deepEquals({
        'id': (type: DriftSqlType.string, nullable: false, isPk: true),
        'name': (type: DriftSqlType.string, nullable: false, isPk: false),
        'icon_name': (type: DriftSqlType.string, nullable: true, isPk: false),
        'chain_steps_json': (
          type: DriftSqlType.string,
          nullable: false,
          isPk: false,
        ),
        'distress_mode_id': (
          type: DriftSqlType.string,
          nullable: true,
          isPk: false,
        ),
        'distress_triggers_json': (
          type: DriftSqlType.string,
          nullable: false,
          isPk: false,
        ),
        'disarm_triggers_json': (
          type: DriftSqlType.string,
          nullable: false,
          isPk: false,
        ),
        'overrides_json': (
          type: DriftSqlType.string,
          nullable: true,
          isPk: false,
        ),
        'tracking_enabled': (
          type: DriftSqlType.bool,
          nullable: false,
          isPk: false,
        ),
        'tracking_interval_seconds': (
          type: DriftSqlType.int,
          nullable: false,
          isPk: false,
        ),
        'tracking_buffer_size': (
          type: DriftSqlType.int,
          nullable: false,
          isPk: false,
        ),
        'pause_allowed': (
          type: DriftSqlType.bool,
          nullable: false,
          isPk: false,
        ),
        'max_pause_minutes': (
          type: DriftSqlType.int,
          nullable: true,
          isPk: false,
        ),
        'is_distress_mode': (
          type: DriftSqlType.bool,
          nullable: false,
          isPk: false,
        ),
        'allow_disarm_as_distress': (
          type: DriftSqlType.bool,
          nullable: false,
          isPk: false,
        ),
        'is_built_in': (
          type: DriftSqlType.bool,
          nullable: false,
          isPk: false,
        ),
      });
    });

    test('session_logs columns match spec 03 §SessionLog', () {
      final cols = _columnSpec(db.sessionLogs);
      check(cols).deepEquals({
        'id': (type: DriftSqlType.string, nullable: false, isPk: true),
        'mode_id': (type: DriftSqlType.string, nullable: false, isPk: false),
        'mode_name': (type: DriftSqlType.string, nullable: false, isPk: false),
        'started_at_ms': (type: DriftSqlType.int, nullable: false, isPk: false),
        'ended_at_ms': (type: DriftSqlType.int, nullable: true, isPk: false),
        'end_reason': (type: DriftSqlType.string, nullable: true, isPk: false),
        'is_simulation': (
          type: DriftSqlType.bool,
          nullable: false,
          isPk: false,
        ),
        'had_medical_info': (
          type: DriftSqlType.bool,
          nullable: false,
          isPk: false,
        ),
        'events_json': (
          type: DriftSqlType.string,
          nullable: false,
          isPk: false,
        ),
        // Phase 6c: soft-delete column for the trash flow
        // (spec 04:2455–2459 / spec 03:970).
        'deleted_at_ms': (type: DriftSqlType.int, nullable: true, isPk: false),
      });
    });

    test('sms_retry_jobs columns match spec 05 §SMS Retry Queue', () {
      final cols = _columnSpec(db.smsRetryJobs);
      check(cols).deepEquals({
        'work_id': (type: DriftSqlType.string, nullable: false, isPk: true),
        'contact_id': (type: DriftSqlType.string, nullable: true, isPk: false),
        'phone_number': (
          type: DriftSqlType.string,
          nullable: false,
          isPk: false,
        ),
        'message': (type: DriftSqlType.string, nullable: false, isPk: false),
        'attempt_count': (type: DriftSqlType.int, nullable: false, isPk: false),
        'enqueued_at_ms': (
          type: DriftSqlType.int,
          nullable: false,
          isPk: false,
        ),
        'last_error': (type: DriftSqlType.string, nullable: true, isPk: false),
      });
    });

    test('all five DAOs are exposed on the database class', () {
      // Smoke test: every promised DAO must resolve to a non-null
      // instance bound to the same database connection.
      check(db.contactsDao).isNotNull();
      check(db.reminderTemplatesDao).isNotNull();
      check(db.sessionModesDao).isNotNull();
      check(db.sessionLogsDao).isNotNull();
      check(db.smsRetryJobsDao).isNotNull();
    });
  });
}

typedef _ColumnSpec = ({DriftSqlType<Object> type, bool nullable, bool isPk});

Map<String, _ColumnSpec> _columnSpec(TableInfo<Table, dynamic> table) {
  final pkNames = {for (final c in table.$primaryKey) c.name};
  return {
    for (final col in table.$columns)
      col.name: (
        type: col.type as DriftSqlType<Object>,
        nullable: col.$nullable,
        isPk: pkNames.contains(col.name),
      ),
  };
}
