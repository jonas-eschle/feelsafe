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

/// Universal English fallback for the SMS body. Used when neither a
/// per-language ARB template nor a per-step config template is set.
///
/// Why a constant: keeps the pure-Dart strategy code locale-agnostic
/// while still guaranteeing a non-empty body if the controller forgot
/// to seed [SessionContext.defaultSmsTemplate]. Tests rely on this so
/// the harness can build a `SessionContext` without booting Flutter.
const String kFallbackSmsTemplate =
    '{name} may need help. Location: {location}. Time: {time}.';

/// Universal English fallback for the pre-call SMS body sent ahead of
/// a phone-call-contact step. See [kFallbackSmsTemplate] for context.
const String kFallbackPreSmsTemplate =
    '{name} is trying to reach you. Please expect a call.';

/// Universal English fallback for the TTS "running late" phrase used
/// when the bundled voice asset is missing. Resolved from
/// `AppLocalizations.audioRunningLatePhrase` at session bootstrap.
const String kFallbackTtsLatePhrase =
    'Hi, I am running late. I will call you back soon.';

/// Resolves an SMS template for a given language code.
///
/// [languageCode] — ISO 639-1 code (e.g. `'en'`, `'de'`). May be null
/// or unknown — implementations return null to signal "use default".
typedef SmsTemplateResolver = String? Function(String? languageCode);

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
  /// [ttsLatePhrase] — localized "I'm running late..." phrase used as
  /// the TTS fallback when no voice asset is bundled. Resolved from
  /// `AppLocalizations.audioRunningLatePhrase` at session bootstrap.
  /// Fix for bugs.json Warn 3.
  /// [defaultSmsTemplate] — localized default SMS body template
  /// (e.g. `"{name} may need help. Location: {location}. Time:
  /// {time}."`). Strategies fall back to this when no per-step config
  /// template is set AND no per-contact language template resolves.
  /// Fix for bugs.json Warn 4.
  /// [defaultPreSmsTemplate] — localized default pre-call-SMS body.
  /// Mirrors [defaultSmsTemplate] for the phone-call-contact strategy.
  /// [smsTemplateForLanguage] — optional resolver that returns the
  /// localized default SMS template for a given ISO language code
  /// (`contact.languageCode`). Returns null when no template is
  /// available for that language; strategies then fall back to
  /// [defaultSmsTemplate]. Fix for bugs.json Warn 4.
  /// [preSmsTemplateForLanguage] — analogous resolver for the pre-call
  /// SMS template; falls back to [defaultPreSmsTemplate] when null.
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
    this.ttsLatePhrase = kFallbackTtsLatePhrase,
    this.defaultSmsTemplate = kFallbackSmsTemplate,
    this.defaultPreSmsTemplate = kFallbackPreSmsTemplate,
    this.smsTemplateForLanguage,
    this.preSmsTemplateForLanguage,
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

  /// Localized "I'm running late..." phrase used as the TTS fallback
  /// when no voice asset is bundled. Resolved from
  /// `AppLocalizations.audioRunningLatePhrase` at session bootstrap.
  /// Fix for bugs.json Warn 3.
  final String ttsLatePhrase;

  /// Localized default SMS body template
  /// (e.g. `"{name} may need help. Location: {location}. Time:
  /// {time}."`). Strategies fall back to this when no per-step
  /// config template is set. Fix for bugs.json Warn 4.
  final String defaultSmsTemplate;

  /// Localized default pre-call-SMS body. Mirrors
  /// [defaultSmsTemplate] for phone-call-contact steps.
  final String defaultPreSmsTemplate;

  /// Optional resolver that returns the localized default SMS
  /// template for a given ISO language code ([EmergencyContact.languageCode]).
  /// Returns null when no template is available for that language;
  /// strategies then fall back to [defaultSmsTemplate].
  final SmsTemplateResolver? smsTemplateForLanguage;

  /// Analogous resolver for the pre-call SMS template; falls back to
  /// [defaultPreSmsTemplate] when null.
  final SmsTemplateResolver? preSmsTemplateForLanguage;

  /// Returns the SMS template that should apply to [contact].
  ///
  /// Resolution order: per-language ARB template (if
  /// [smsTemplateForLanguage] resolves) → [defaultSmsTemplate]. Used
  /// by [SmsContactStrategy] when the step config has no template.
  /// Fix for bugs.json Warn 4.
  String resolveSmsTemplateForContact(EmergencyContact contact) {
    final resolver = smsTemplateForLanguage;
    if (resolver != null) {
      final localized = resolver(contact.languageCode);
      if (localized != null && localized.isNotEmpty) return localized;
    }
    return defaultSmsTemplate;
  }

  /// Returns the pre-call-SMS template that should apply to
  /// [contact]. Mirrors [resolveSmsTemplateForContact] for
  /// phone-call-contact steps.
  String resolvePreSmsTemplateForContact(EmergencyContact contact) {
    final resolver = preSmsTemplateForLanguage;
    if (resolver != null) {
      final localized = resolver(contact.languageCode);
      if (localized != null && localized.isNotEmpty) return localized;
    }
    return defaultPreSmsTemplate;
  }

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
    String? ttsLatePhrase,
    String? defaultSmsTemplate,
    String? defaultPreSmsTemplate,
    SmsTemplateResolver? smsTemplateForLanguage,
    SmsTemplateResolver? preSmsTemplateForLanguage,
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
    ttsLatePhrase: ttsLatePhrase ?? this.ttsLatePhrase,
    defaultSmsTemplate: defaultSmsTemplate ?? this.defaultSmsTemplate,
    defaultPreSmsTemplate:
        defaultPreSmsTemplate ?? this.defaultPreSmsTemplate,
    smsTemplateForLanguage:
        smsTemplateForLanguage ?? this.smsTemplateForLanguage,
    preSmsTemplateForLanguage:
        preSmsTemplateForLanguage ?? this.preSmsTemplateForLanguage,
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
    if (other.ttsLatePhrase != ttsLatePhrase) return false;
    if (other.defaultSmsTemplate != defaultSmsTemplate) return false;
    if (other.defaultPreSmsTemplate != defaultPreSmsTemplate) return false;
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
    ttsLatePhrase,
    defaultSmsTemplate,
    defaultPreSmsTemplate,
  );

  @override
  String toString() =>
      'SessionContext(mode: ${mode?.name}, '
      'contacts: ${contacts.length}, isSimulation: $isSimulation)';
}
