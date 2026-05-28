import 'package:drift/drift.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/db/tables/feedback_history_table.dart';
import 'package:guardianangela/domain/enums/feedback_type.dart';
import 'package:guardianangela/domain/models/feedback_entry.dart';

part 'feedback_history_dao.g.dart';

/// DAO for the [FeedbackHistory] table.
///
/// Stores submitted feedback so the user retains a record locally even
/// when the mailto round-trip fails. Spec 04 §Feedback Form.
@DriftAccessor(tables: [FeedbackHistory])
class FeedbackHistoryDao extends DatabaseAccessor<GuardianAngelaDatabase>
    with _$FeedbackHistoryDaoMixin {
  /// Creates a DAO bound to [db].
  FeedbackHistoryDao(super.db);

  /// All entries, newest first.
  Future<List<FeedbackEntry>> getAll() async {
    final rows = await (select(
      feedbackHistory,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
    return rows.map(_rowToModel).toList();
  }

  /// Insert a new entry.
  Future<void> insert(FeedbackEntry entry) async {
    await into(feedbackHistory).insert(_modelToCompanion(entry));
  }

  /// Delete every row.
  Future<void> deleteAll() => delete(feedbackHistory).go();

  static FeedbackEntry _rowToModel(FeedbackEntryRow row) => FeedbackEntry(
    id: row.id,
    category: FeedbackType.values.byName(row.category),
    email: row.email,
    message: row.message,
    includeLog: row.includeLog,
    createdAt: row.createdAt,
  );

  static FeedbackHistoryCompanion _modelToCompanion(FeedbackEntry e) =>
      FeedbackHistoryCompanion(
        id: Value(e.id),
        category: Value(e.category.name),
        email: Value(e.email),
        message: Value(e.message),
        includeLog: Value(e.includeLog),
        createdAt: Value(e.createdAt),
      );
}
