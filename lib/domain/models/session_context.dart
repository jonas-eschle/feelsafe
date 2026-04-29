/// `SessionContext` — the bundle of "what this session needs to
/// know" passed to engine strategies.
///
/// Holds the active mode, emergency contacts, user profile,
/// resolved templates, event defaults, and the simulation flag.
/// `configFor` resolves per-step config with fallback to
/// `eventDefaults`; `resolvePlaceholders` substitutes standard
/// `{name}`, `{location}`, `{time}`, `{description}` tokens in
/// message templates.
library;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/models/user_profile.dart';

/// The session-scoped bundle used by engine / orchestration code.
final class SessionContext {
  /// Creates a session context.
  ///
  /// [mode] — the active mode, if any.
  /// [contacts] — emergency contacts available to the session;
  /// defaults to empty.
  /// [userProfile] — user profile, if any.
  /// [isSimulation] — whether this is a simulation run; defaults to
  /// false.
  /// [reminderTemplates] — effective template list (global +
  /// mode-local); defaults to empty.
  /// [hadMedicalInfo] — stamped `true` iff medical info was
  /// delivered this session; defaults to false.
  /// [eventDefaults] — the effective event defaults; defaults to
  /// null (engine falls back to step-level config where needed).
  /// [emergencyNumber] — resolved emergency-call number from
  /// [AppSettings.emergencyCallNumber]; used by [CallEmergencyStrategy]
  /// when a step's `CallEmergencyConfig.emergencyNumber` is null.
  /// Defaults to '112'. Fix for bugs.json Bug #7.
  /// [gpsLoggingEnabled] — global GPS logging flag (DE-2). Sourced
  /// from `mode.overrides.gpsLogging.enabled` when set, else
  /// `AppDefaults.gpsLogging.enabled`. Defaults to `true` —
  /// matches `GpsLoggingConfig`'s default.
  const SessionContext({
    this.mode,
    this.contacts = const [],
    this.userProfile,
    this.isSimulation = false,
    this.reminderTemplates = const [],
    this.hadMedicalInfo = false,
    this.eventDefaults,
    this.emergencyNumber = '112',
    this.gpsLoggingEnabled = true,
  });

  /// The active mode, if any.
  final SessionMode? mode;

  /// Emergency contacts available this session.
  final List<EmergencyContact> contacts;

  /// User profile, if any.
  final UserProfile? userProfile;

  /// Whether this is a simulation run.
  final bool isSimulation;

  /// Effective reminder templates for this session.
  final List<ReminderTemplate> reminderTemplates;

  /// True iff medical info was included in a message this session.
  final bool hadMedicalInfo;

  /// Effective event defaults for this session.
  final EventDefaults? eventDefaults;

  /// Resolved emergency-call number from
  /// [AppSettings.emergencyCallNumber]. Consumed by
  /// [CallEmergencyStrategy] when the step's config has no
  /// per-step override. Defaults to '112'. Fix for bugs.json Bug #7.
  final String emergencyNumber;

  /// Global GPS-logging master toggle for this session (DE-2).
  /// Sourced from `mode.overrides.gpsLogging.enabled` when set, else
  /// `AppDefaults.gpsLogging.enabled`. Defaults to `true`.
  final bool gpsLoggingEnabled;

  /// Returns the config for [step]. If [step.config] is non-null,
  /// returns it. Otherwise, returns the matching default from
  /// [eventDefaults]. Throws [StateError] if neither is available.
  StepConfig configFor(ChainStep step) {
    final stepConfig = step.config;
    if (stepConfig != null) return stepConfig;
    final defaults = eventDefaults;
    if (defaults == null) {
      throw StateError(
        'SessionContext.configFor(${step.type}): step has no config '
        'and the context has no eventDefaults to fall back to.',
      );
    }
    return defaults.forType(step.type);
  }

  /// Resolves the standard placeholder tokens in [template]:
  /// `{name}`, `{location}`, `{time}`, `{description}`.
  ///
  /// [name] defaults to `UserProfile.name` or empty if missing.
  /// [location] / [time] / [description] default to empty strings if
  /// omitted.
  String resolvePlaceholders(
    String template, {
    String? name,
    String? location,
    String? time,
    String? description,
  }) {
    final resolvedName = name ?? userProfile?.name ?? '';
    final resolvedLocation = location ?? '';
    final resolvedTime = time ?? '';
    final resolvedDescription = description ?? '';
    return template
        .replaceAll('{name}', resolvedName)
        .replaceAll('{location}', resolvedLocation)
        .replaceAll('{time}', resolvedTime)
        .replaceAll('{description}', resolvedDescription);
  }

  /// Returns a new context with the given fields replaced.
  SessionContext copyWith({
    SessionMode? mode,
    List<EmergencyContact>? contacts,
    UserProfile? userProfile,
    bool? isSimulation,
    List<ReminderTemplate>? reminderTemplates,
    bool? hadMedicalInfo,
    EventDefaults? eventDefaults,
    String? emergencyNumber,
    bool? gpsLoggingEnabled,
  }) => SessionContext(
    mode: mode ?? this.mode,
    contacts: contacts ?? this.contacts,
    userProfile: userProfile ?? this.userProfile,
    isSimulation: isSimulation ?? this.isSimulation,
    reminderTemplates: reminderTemplates ?? this.reminderTemplates,
    hadMedicalInfo: hadMedicalInfo ?? this.hadMedicalInfo,
    eventDefaults: eventDefaults ?? this.eventDefaults,
    emergencyNumber: emergencyNumber ?? this.emergencyNumber,
    gpsLoggingEnabled: gpsLoggingEnabled ?? this.gpsLoggingEnabled,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SessionContext) return false;
    if (other.mode != mode) return false;
    if (other.userProfile != userProfile) return false;
    if (other.isSimulation != isSimulation) return false;
    if (other.hadMedicalInfo != hadMedicalInfo) return false;
    if (other.eventDefaults != eventDefaults) return false;
    if (other.emergencyNumber != emergencyNumber) return false;
    if (other.gpsLoggingEnabled != gpsLoggingEnabled) return false;
    if (other.contacts.length != contacts.length) return false;
    for (var i = 0; i < contacts.length; i++) {
      if (other.contacts[i] != contacts[i]) return false;
    }
    if (other.reminderTemplates.length != reminderTemplates.length) {
      return false;
    }
    for (var i = 0; i < reminderTemplates.length; i++) {
      if (other.reminderTemplates[i] != reminderTemplates[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    mode,
    Object.hashAll(contacts),
    userProfile,
    isSimulation,
    Object.hashAll(reminderTemplates),
    hadMedicalInfo,
    eventDefaults,
    emergencyNumber,
    gpsLoggingEnabled,
  );

  @override
  String toString() =>
      'SessionContext(mode: ${mode?.name}, '
      'contacts: ${contacts.length}, isSimulation: $isSimulation)';
}
