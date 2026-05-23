/// A single validation issue discovered by [SessionStartValidator].
///
/// See spec 05 §SessionStartValidator. Issues have optional action
/// callbacks so the UI can offer quick-fix buttons ("Add Contact",
/// "Grant Permission", etc.).
final class ValidationIssue {
  /// Creates a validation issue.
  const ValidationIssue({
    required this.title,
    required this.description,
    this.actionLabel,
    this.action,
  });

  /// Short title displayed in the validation UI (e.g., "No contacts
  /// configured").
  final String title;

  /// Longer description of the issue and how to resolve it.
  final String description;

  /// Optional label for the action button (e.g., "Add Contact").
  ///
  /// Null if no quick-fix action is available.
  final String? actionLabel;

  /// Optional callback invoked when the user taps the action button.
  ///
  /// Uses a plain `Future<void> Function()` (not `VoidCallback`) so
  /// the domain model stays Flutter-free; UI layers wrap it in a
  /// button `onPressed` handler.
  final Future<void> Function()? action;
}

/// The result of a pre-session validation run.
///
/// [isValid] is `true` only when [errors] is empty. The UI shows all
/// [errors] and blocks session start; it shows [warnings] but permits
/// the user to proceed. See spec 05 §SessionStartValidator
/// §Result Handling.
final class ValidationResult {
  /// Creates a validation result.
  const ValidationResult({required this.errors, required this.warnings});

  /// Convenience constructor for a fully-valid result.
  const ValidationResult.valid() : errors = const [], warnings = const [];

  /// Critical issues that prevent the session from starting.
  final List<ValidationIssue> errors;

  /// Non-critical issues that the user may acknowledge and proceed.
  final List<ValidationIssue> warnings;

  /// `true` iff [errors] is empty.
  bool get isValid => errors.isEmpty;
}
