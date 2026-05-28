import 'package:guardianangela/domain/enums/feedback_type.dart';

/// One row of locally-persisted user feedback (spec 04 §Feedback Form).
///
/// The feedback form writes a row before opening the system mailto so
/// the user retains a copy even when the email round-trip fails.
class FeedbackEntry {
  /// Creates a feedback entry.
  FeedbackEntry({
    required this.id,
    required this.category,
    this.email,
    required this.message,
    required this.includeLog,
    required this.createdAt,
  }) : assert(id.isNotEmpty, 'FeedbackEntry.id must be non-empty'),
       assert(message.isNotEmpty, 'FeedbackEntry.message must be non-empty');

  /// UUID primary key.
  final String id;

  /// Category bucket selected by the user.
  final FeedbackType category;

  /// Optional reply-to address.
  final String? email;

  /// Free-form message body.
  final String message;

  /// Whether the user asked to attach the latest log file.
  final bool includeLog;

  /// Wall-clock UTC time of submission.
  final DateTime createdAt;
}
