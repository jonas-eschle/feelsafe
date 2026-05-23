import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/user_profile.dart';

/// Runtime context assembled by the session controller before starting a
/// session.
///
/// Passed to [SessionLogRecorder] at construction and to event strategies
/// during execution. All data is resolved from repositories at session
/// start — strategies and the recorder do not query the database during
/// execution.
///
/// See spec 05 §SessionLogRecorder and spec 02 §disguisedReminder
/// (template pool) for field semantics.
final class SessionContext {
  /// Creates a [SessionContext].
  ///
  /// [mode] is the session mode being executed. [profile] is the
  /// user's current profile (may be null for anonymous users).
  /// [reminderTemplates] is the merged pool of global + mode-local
  /// templates available for disguised-reminder steps.
  const SessionContext({
    required this.mode,
    required this.profile,
    this.reminderTemplates = const [],
  });

  /// The session mode whose chain is being executed.
  final SessionMode mode;

  /// The user's profile at session start.
  ///
  /// Used by [SessionLogRecorder] to stamp [SessionLog.hadMedicalInfo]:
  /// `true` iff the profile has any medical field set AND at least one
  /// `smsContact` step in the chain has `includeMedicalInfo = true`.
  final UserProfile? profile;

  /// The resolved pool of reminder templates available to
  /// [DisguisedReminderStrategy].
  ///
  /// Merged from `AppDefaults` templates and any mode-local templates
  /// by the session controller before start (spec 02 §disguisedReminder
  /// template selection, C4).
  final List<ReminderTemplate> reminderTemplates;

  /// Returns `true` iff the user profile contains any medical
  /// information.
  ///
  /// Convenience helper used by [SessionLogRecorder.hadMedicalInfo].
  bool get profileHasMedicalInfo {
    final p = profile;
    if (p == null) return false;
    return p.bloodType != null ||
        p.allergies != null ||
        p.medications != null ||
        p.medicalConditions != null ||
        p.emergencyInstructions != null;
  }
}
