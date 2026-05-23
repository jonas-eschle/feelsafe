import 'package:drift/drift.dart';

/// Drift table backing the [ReminderTemplate] domain model.
///
/// See spec 03 §ReminderTemplate. The [confirmationType] and
/// [displayStyle] columns store enum `name` strings.
@DataClassName('ReminderTemplateRow')
class ReminderTemplates extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// User-visible template name (e.g., "Calendar Event").
  TextColumn get name => text()();

  /// Notification title text.
  TextColumn get title => text()();

  /// Notification body text.
  TextColumn get body => text()();

  /// Optional asset path for the notification icon.
  TextColumn get iconAsset => text().nullable()();

  /// `ConfirmationType.name`.
  TextColumn get confirmationType => text()();

  /// Correct word for tap-word templates.
  TextColumn get keyword => text().nullable()();

  /// Button label for tap-button templates.
  TextColumn get buttonLabel => text().nullable()();

  /// True iff the template is user-created (vs. seeded built-in).
  BoolColumn get isCustom => boolean()();

  /// Optional custom image path for full-screen display.
  TextColumn get imagePath => text().nullable()();

  /// Optional subtitle between [title] and [body].
  TextColumn get subtitle => text().nullable()();

  /// `ReminderDisplayStyle.name`.
  TextColumn get displayStyle => text()();

  /// True iff template comes from `AppDefaults.templates` (global) vs.
  /// `ModeOverrides.localTemplates` (mode-local).
  BoolColumn get isGlobal => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
