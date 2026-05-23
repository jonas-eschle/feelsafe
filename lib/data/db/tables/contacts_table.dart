import 'package:drift/drift.dart';

/// Drift table backing the [EmergencyContact] domain model.
///
/// See spec 03 §EmergencyContact. The [channelsJson] column stores the
/// contact's channel list as a JSON array of `MessageChannel.name` strings.
@DataClassName('ContactRow')
class Contacts extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// Human-readable display name.
  TextColumn get name => text()();

  /// Phone number (E.164 preferred).
  TextColumn get phoneNumber => text()();

  /// Optional human relationship label.
  TextColumn get relationship => text().nullable()();

  /// 0-based position used for manual ordering.
  IntColumn get sortOrder => integer()();

  /// JSON-encoded list of `MessageChannel.name` strings.
  TextColumn get channelsJson => text()();

  /// Per-contact SMS language override; null = inherit app language.
  TextColumn get languageCode => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
