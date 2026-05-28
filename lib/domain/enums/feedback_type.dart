/// The kind of feedback the user is sending (spec 04 §Feedback Form).
enum FeedbackType {
  /// Bug report.
  bug,

  /// Feature request.
  feature,

  /// Anything that doesn't fit the other two buckets.
  other,
}
