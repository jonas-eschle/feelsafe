/// Thrown when a destructive mutation is blocked because a user
/// safety session is currently active. Spec 06 §Session Locks.
library;

/// Error raised by controllers when a mutation is blocked by the
/// active-session lock (contact delete, backup import, language
/// change, schema migration).
class SessionLockedError extends StateError {
  /// Creates a session-locked error describing the blocked action.
  SessionLockedError(String action)
    : super(
        'Cannot $action while a safety session is active. '
        'End or disarm the session first.',
      );
}
