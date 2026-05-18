/// `SessionValidator` — pre-flight validation of a session's
/// configuration (mode, contacts, user profile, app settings).
///
/// Pure Dart. Returns a [ValidationResult] the UI uses to surface
/// warnings and block session start on hard errors.
library;

import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/user_profile.dart';

/// Outcome of a [SessionValidator.validate] call.
final class ValidationResult {
  /// Creates a validation result.
  ///
  /// [valid] — true iff [errors] is empty.
  /// [warnings] — non-blocking advisories shown to the user.
  /// [errors] — blocking problems preventing session start.
  const ValidationResult({
    required this.valid,
    required this.warnings,
    required this.errors,
  });

  /// True iff the session configuration is usable.
  final bool valid;

  /// Non-blocking advisory messages.
  final List<String> warnings;

  /// Blocking error messages.
  final List<String> errors;
}

/// Pre-flight validator for a session-start configuration.
final class SessionValidator {
  const SessionValidator._();

  /// Validates [mode] against the supplied contacts, distress modes,
  /// user profile, and app settings. Returns a [ValidationResult].
  ///
  /// [mode] — the mode about to start.
  /// [contacts] — the user's emergency contacts.
  /// [distressModes] — the available distress-flagged modes (first
  /// entry is treated as the default).
  /// [userProfile] — optional user profile; absence may yield a
  /// warning but not an error.
  /// [settings] — optional app settings; used to cross-check
  /// emergency number and PIN configuration.
  static ValidationResult validate({
    required SessionMode mode,
    required List<EmergencyContact> contacts,
    required List<SessionMode> distressModes,
    UserProfile? userProfile,
    AppSettings? settings,
  }) {
    throw UnimplementedError();
  }
}
