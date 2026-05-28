import 'package:drift/drift.dart';

/// Drift table backing the local feedback history (spec 04 §Feedback
/// Form). One row per submission; the screen writes locally first and
/// then opens the mailto link, so the user can browse their own past
/// reports even when the email round-trip fails.
@DataClassName('FeedbackEntryRow')
class FeedbackHistory extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// Category type — `name` of the `FeedbackType` enum.
  TextColumn get category => text()();

  /// Optional reply-to address typed by the user.
  TextColumn get email => text().nullable()();

  /// Free-form feedback body.
  TextColumn get message => text()();

  /// Whether the user opted to attach the latest log file.
  BoolColumn get includeLog => boolean().withDefault(const Constant(false))();

  /// Wall-clock UTC time the row was inserted.
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
