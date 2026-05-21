/// `AppSettings` — the top-level app configuration singleton.
///
/// Stores theme, language, the three PIN hashes, the emergency-call
/// number, the DND override, the active `AppDefaults`, the currently
/// selected mode id, and the first-launch flag.
library;

import 'package:guardianangela/domain/models/app_defaults.dart';

/// Application theme mode.
enum AppThemeMode {
  /// Force light theme.
  light,

  /// Force dark theme.
  dark,

  /// Follow the operating-system theme. The default.
  system,
}

/// Top-level app configuration.
final class AppSettings {
  /// Creates an `AppSettings`.
  ///
  /// [defaults] — master `AppDefaults` (GPS logging, stealth,
  /// templates, event defaults).
  /// [appPinHash] — hash of the app-unlock PIN; null = disabled.
  /// [sessionEndPinHash] — hash of the session-end PIN; null =
  /// disabled.
  /// [duressPinHash] — hash of the duress PIN; null = disabled.
  /// [pinTimeoutSeconds] — lockout timeout after wrong PINs in
  /// seconds; defaults to 15.
  /// [themeMode] — app theme mode; defaults to system.
  /// [languageCode] — app language code; defaults to 'en'.
  /// [emergencyCallNumber] — emergency dial number; defaults to
  /// '112'.
  /// [alarmDndOverride] — allow the alarm step to override Do Not
  /// Disturb; defaults to false.
  /// [selectedModeId] — currently active mode; null = none chosen.
  /// [isFirstLaunch] — true until onboarding completes; defaults to
  /// true.
  /// [telemetryOptOut] — user opted out of Sentry telemetry; defaults
  /// to false (telemetry on per D-TELEMETRY-1).
  /// [sessionLogRetentionDays] — how many days session logs are kept;
  /// defaults to 180 per spec/B8 (D-SAFETY-6).
  /// [wrongPinThreshold] — consecutive wrong-PIN entries that fire
  /// the distress chain; defaults to 5 per D-SEC-5 / spec A3.
  /// [alarmGradualVolume] — when true the loud-alarm step ramps
  /// volume from a low starting level to maximum over
  /// [alarmGradualVolumeDurationSeconds]; defaults to false.
  /// [alarmGradualVolumeDurationSeconds] — ramp duration in seconds;
  /// must be >= 0; defaults to 5. Ignored when
  /// [alarmGradualVolume] is false.
  const AppSettings({
    required this.defaults,
    this.appPinHash,
    this.sessionEndPinHash,
    this.duressPinHash,
    this.pinTimeoutSeconds = 15,
    this.themeMode = AppThemeMode.system,
    this.languageCode = 'en',
    this.emergencyCallNumber = '112',
    this.alarmDndOverride = false,
    this.selectedModeId,
    this.isFirstLaunch = true,
    this.telemetryOptOut = false,
    this.sessionLogRetentionDays = 180,
    this.wrongPinThreshold = 5,
    this.appPinBiometricEnabled = false,
    this.sessionEndPinBiometricEnabled = false,
    this.distressCancelBiometricEnabled = false,
    this.requireLaunchAuth = false,
    this.launchAuthBiometric = true,
    this.sentryEnabled = false,
    this.alarmGradualVolume = false,
    this.alarmGradualVolumeDurationSeconds = 5,
  });

  /// Deserializes `AppSettings` from JSON.
  factory AppSettings.fromJson(Map<String, Object?> json) => AppSettings(
    appPinHash: json['appPinHash'] as String?,
    sessionEndPinHash: json['sessionEndPinHash'] as String?,
    duressPinHash: json['duressPinHash'] as String?,
    pinTimeoutSeconds: (json['pinTimeoutSeconds'] as num?)?.toInt() ?? 15,
    themeMode: _themeFromJson(json['themeMode']),
    languageCode: json['languageCode'] as String? ?? 'en',
    emergencyCallNumber: json['emergencyCallNumber'] as String? ?? '112',
    alarmDndOverride: json['alarmDndOverride'] as bool? ?? false,
    defaults: json['defaults'] is Map<String, Object?>
        ? AppDefaults.fromJson(json['defaults']! as Map<String, Object?>)
        : const AppDefaults(),
    selectedModeId: json['selectedModeId'] as String?,
    isFirstLaunch: json['isFirstLaunch'] as bool? ?? true,
    telemetryOptOut: json['telemetryOptOut'] as bool? ?? false,
    sessionLogRetentionDays:
        (json['sessionLogRetentionDays'] as num?)?.toInt() ?? 180,
    wrongPinThreshold: (json['wrongPinThreshold'] as num?)?.toInt() ?? 5,
    appPinBiometricEnabled: json['appPinBiometricEnabled'] as bool? ?? false,
    sessionEndPinBiometricEnabled:
        json['sessionEndPinBiometricEnabled'] as bool? ?? false,
    distressCancelBiometricEnabled:
        json['distressCancelBiometricEnabled'] as bool? ?? false,
    requireLaunchAuth: json['requireLaunchAuth'] as bool? ?? false,
    launchAuthBiometric: json['launchAuthBiometric'] as bool? ?? true,
    sentryEnabled: json['sentryEnabled'] as bool? ?? false,
    alarmGradualVolume: json['alarmGradualVolume'] as bool? ?? false,
    alarmGradualVolumeDurationSeconds:
        (json['alarmGradualVolumeDurationSeconds'] as num?)?.toInt() ?? 5,
  );

  /// Hash of the app-unlock PIN; null = no lock.
  final String? appPinHash;

  /// Hash of the session-end PIN; null = no lock.
  final String? sessionEndPinHash;

  /// Hash of the duress PIN; null = disabled.
  final String? duressPinHash;

  /// Lockout timeout after wrong PIN entries, in seconds. Defaults
  /// to 15.
  final int pinTimeoutSeconds;

  /// App theme. Defaults to `AppThemeMode.system`.
  final AppThemeMode themeMode;

  /// Language code (e.g., 'en', 'de'). Defaults to 'en'.
  final String languageCode;

  /// Emergency dial number. Defaults to '112'.
  final String emergencyCallNumber;

  /// Whether the alarm step may override Do Not Disturb. Defaults
  /// to false.
  final bool alarmDndOverride;

  /// The active `AppDefaults`.
  final AppDefaults defaults;

  /// Id of the currently selected mode; null = none.
  final String? selectedModeId;

  /// True until onboarding is complete. Defaults to true.
  final bool isFirstLaunch;

  /// User opted out of Sentry telemetry. Defaults to false (telemetry
  /// on). Per D-TELEMETRY-1, telemetry is opt-out — flipping this to
  /// true suppresses all Sentry initialization at app start.
  final bool telemetryOptOut;

  /// Days to retain session logs. Defaults to 180 per spec/B8. Per
  /// D-SAFETY-6, old logs are pruned on a schedule by
  /// `StructuredLogger`.
  final int sessionLogRetentionDays;

  /// Consecutive wrong-PIN entries that silently fire the distress
  /// chain. Defaults to 5 per D-SEC-5 / spec A3.
  final int wrongPinThreshold;

  /// When true, the app-unlock PIN prompt tries biometric first.
  /// Requires [appPinHash] non-null.
  final bool appPinBiometricEnabled;

  /// When true, the session-end PIN prompt tries biometric first.
  /// Requires [sessionEndPinHash] non-null.
  final bool sessionEndPinBiometricEnabled;

  /// When true, the distress-cancel PIN prompt tries biometric
  /// first. Authenticates against the APP PIN. Requires
  /// [appPinHash] non-null.
  final bool distressCancelBiometricEnabled;

  /// Q14 launch gate. When true AND [appPinHash] is non-null, the
  /// app gates the home screen behind a PIN-or-biometric prompt on
  /// every cold start. Default false (opt-in).
  final bool requireLaunchAuth;

  /// Q14 sub-toggle. When true AND [requireLaunchAuth] is true,
  /// the launch gate tries biometric first; PIN is always available
  /// as a fallback. Default true.
  final bool launchAuthBiometric;

  /// Master Sentry telemetry toggle (Q42 amended). Defaults to
  /// **false** — telemetry is opt-in. When false, no Sentry SDK
  /// initialization happens at app start.
  final bool sentryEnabled;

  /// When true, the loud-alarm step ramps volume from a low starting
  /// level to maximum over [alarmGradualVolumeDurationSeconds],
  /// giving the user time to reach their phone. Defaults to false.
  final bool alarmGradualVolume;

  /// Duration of the volume ramp in seconds. Must be >= 0. Defaults
  /// to 5. Ignored when [alarmGradualVolume] is false.
  final int alarmGradualVolumeDurationSeconds;

  /// Returns a new settings instance with the given fields replaced.
  ///
  /// Nullable PIN-hash fields and `selectedModeId` support explicit
  /// clearing via the `clearXxx` flags — the `?? this.field` pattern
  /// alone cannot distinguish "keep existing" from "set to null". The
  /// `clearAppPinHash` etc. flags let the controllers (and users)
  /// actually disable a PIN.
  AppSettings copyWith({
    String? appPinHash,
    bool clearAppPinHash = false,
    String? sessionEndPinHash,
    bool clearSessionEndPinHash = false,
    String? duressPinHash,
    bool clearDuressPinHash = false,
    int? pinTimeoutSeconds,
    AppThemeMode? themeMode,
    String? languageCode,
    String? emergencyCallNumber,
    bool? alarmDndOverride,
    AppDefaults? defaults,
    String? selectedModeId,
    bool clearSelectedModeId = false,
    bool? isFirstLaunch,
    bool? telemetryOptOut,
    int? sessionLogRetentionDays,
    int? wrongPinThreshold,
    bool? appPinBiometricEnabled,
    bool? sessionEndPinBiometricEnabled,
    bool? distressCancelBiometricEnabled,
    bool? requireLaunchAuth,
    bool? launchAuthBiometric,
    bool? sentryEnabled,
    bool? alarmGradualVolume,
    int? alarmGradualVolumeDurationSeconds,
  }) => AppSettings(
    appPinHash: clearAppPinHash ? null : (appPinHash ?? this.appPinHash),
    sessionEndPinHash: clearSessionEndPinHash
        ? null
        : (sessionEndPinHash ?? this.sessionEndPinHash),
    duressPinHash: clearDuressPinHash
        ? null
        : (duressPinHash ?? this.duressPinHash),
    pinTimeoutSeconds: pinTimeoutSeconds ?? this.pinTimeoutSeconds,
    themeMode: themeMode ?? this.themeMode,
    languageCode: languageCode ?? this.languageCode,
    emergencyCallNumber: emergencyCallNumber ?? this.emergencyCallNumber,
    alarmDndOverride: alarmDndOverride ?? this.alarmDndOverride,
    defaults: defaults ?? this.defaults,
    selectedModeId: clearSelectedModeId
        ? null
        : (selectedModeId ?? this.selectedModeId),
    isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    telemetryOptOut: telemetryOptOut ?? this.telemetryOptOut,
    sessionLogRetentionDays:
        sessionLogRetentionDays ?? this.sessionLogRetentionDays,
    wrongPinThreshold: wrongPinThreshold ?? this.wrongPinThreshold,
    appPinBiometricEnabled:
        appPinBiometricEnabled ?? this.appPinBiometricEnabled,
    sessionEndPinBiometricEnabled:
        sessionEndPinBiometricEnabled ?? this.sessionEndPinBiometricEnabled,
    distressCancelBiometricEnabled:
        distressCancelBiometricEnabled ?? this.distressCancelBiometricEnabled,
    requireLaunchAuth: requireLaunchAuth ?? this.requireLaunchAuth,
    launchAuthBiometric: launchAuthBiometric ?? this.launchAuthBiometric,
    sentryEnabled: sentryEnabled ?? this.sentryEnabled,
    alarmGradualVolume: alarmGradualVolume ?? this.alarmGradualVolume,
    alarmGradualVolumeDurationSeconds:
        alarmGradualVolumeDurationSeconds ??
        this.alarmGradualVolumeDurationSeconds,
  );

  /// Serializes to JSON.
  Map<String, Object?> toJson() => {
    'appPinHash': appPinHash,
    'sessionEndPinHash': sessionEndPinHash,
    'duressPinHash': duressPinHash,
    'pinTimeoutSeconds': pinTimeoutSeconds,
    'themeMode': themeMode.name,
    'languageCode': languageCode,
    'emergencyCallNumber': emergencyCallNumber,
    'alarmDndOverride': alarmDndOverride,
    'defaults': defaults.toJson(),
    'selectedModeId': selectedModeId,
    'isFirstLaunch': isFirstLaunch,
    'telemetryOptOut': telemetryOptOut,
    'sessionLogRetentionDays': sessionLogRetentionDays,
    'wrongPinThreshold': wrongPinThreshold,
    'appPinBiometricEnabled': appPinBiometricEnabled,
    'sessionEndPinBiometricEnabled': sessionEndPinBiometricEnabled,
    'distressCancelBiometricEnabled': distressCancelBiometricEnabled,
    'requireLaunchAuth': requireLaunchAuth,
    'launchAuthBiometric': launchAuthBiometric,
    'sentryEnabled': sentryEnabled,
    'alarmGradualVolume': alarmGradualVolume,
    'alarmGradualVolumeDurationSeconds': alarmGradualVolumeDurationSeconds,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          other.appPinHash == appPinHash &&
          other.sessionEndPinHash == sessionEndPinHash &&
          other.duressPinHash == duressPinHash &&
          other.pinTimeoutSeconds == pinTimeoutSeconds &&
          other.themeMode == themeMode &&
          other.languageCode == languageCode &&
          other.emergencyCallNumber == emergencyCallNumber &&
          other.alarmDndOverride == alarmDndOverride &&
          other.defaults == defaults &&
          other.selectedModeId == selectedModeId &&
          other.isFirstLaunch == isFirstLaunch &&
          other.telemetryOptOut == telemetryOptOut &&
          other.sessionLogRetentionDays == sessionLogRetentionDays &&
          other.wrongPinThreshold == wrongPinThreshold &&
          other.appPinBiometricEnabled == appPinBiometricEnabled &&
          other.sessionEndPinBiometricEnabled ==
              sessionEndPinBiometricEnabled &&
          other.distressCancelBiometricEnabled ==
              distressCancelBiometricEnabled &&
          other.alarmGradualVolume == alarmGradualVolume &&
          other.alarmGradualVolumeDurationSeconds ==
              alarmGradualVolumeDurationSeconds;

  @override
  int get hashCode => Object.hash(
    appPinHash,
    sessionEndPinHash,
    duressPinHash,
    pinTimeoutSeconds,
    themeMode,
    languageCode,
    emergencyCallNumber,
    alarmDndOverride,
    defaults,
    selectedModeId,
    isFirstLaunch,
    telemetryOptOut,
    sessionLogRetentionDays,
    wrongPinThreshold,
    Object.hash(
      appPinBiometricEnabled,
      sessionEndPinBiometricEnabled,
      distressCancelBiometricEnabled,
      alarmGradualVolume,
      alarmGradualVolumeDurationSeconds,
    ),
  );

  @override
  String toString() =>
      'AppSettings(language: $languageCode, '
      'theme: $themeMode, emergencyCallNumber: $emergencyCallNumber)';
}

AppThemeMode _themeFromJson(Object? raw) => switch (raw) {
  'light' => AppThemeMode.light,
  'dark' => AppThemeMode.dark,
  'system' => AppThemeMode.system,
  null => AppThemeMode.system,
  _ => throw ArgumentError.value(raw, 'themeMode', 'unknown AppThemeMode'),
};
