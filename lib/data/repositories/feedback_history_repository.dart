import 'package:guardianangela/data/db/dao/feedback_history_dao.dart';
import 'package:guardianangela/domain/models/feedback_entry.dart';

/// Repository wrapping [FeedbackHistoryDao] in the project's
/// repository convention. Thin DAO facade for now — no caching.
class FeedbackHistoryRepository {
  /// Creates a repository bound to [dao].
  FeedbackHistoryRepository(this._dao);

  final FeedbackHistoryDao _dao;

  /// All entries, newest first.
  Future<List<FeedbackEntry>> getAll() => _dao.getAll();

  /// Persist [entry].
  Future<void> insert(FeedbackEntry entry) => _dao.insert(entry);

  /// Drop every row.
  Future<void> deleteAll() => _dao.deleteAll();
}
