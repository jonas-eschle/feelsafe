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
  /// defaults to 30 (D-SAFETY-6).
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
    this.sessionLogRetentionDays = 30,
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
        (json['sessionLogRetentionDays'] as num?)?.toInt() ?? 30,
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

  /// Days to retain session logs. Defaults to 30. Per D-SAFETY-6,
  /// old logs are pruned on a schedule by `StructuredLogger`.
  final int sessionLogRetentionDays;

  /// Returns a new settings instance with the given fields replaced.
  AppSettings copyWith({
    String? appPinHash,
    String? sessionEndPinHash,
    String? duressPinHash,
    int? pinTimeoutSeconds,
    AppThemeMode? themeMode,
    String? languageCode,
    String? emergencyCallNumber,
    bool? alarmDndOverride,
    AppDefaults? defaults,
    String? selectedModeId,
    bool? isFirstLaunch,
    bool? telemetryOptOut,
    int? sessionLogRetentionDays,
  }) => AppSettings(
    appPinHash: appPinHash ?? this.appPinHash,
    sessionEndPinHash: sessionEndPinHash ?? this.sessionEndPinHash,
    duressPinHash: duressPinHash ?? this.duressPinHash,
    pinTimeoutSeconds: pinTimeoutSeconds ?? this.pinTimeoutSeconds,
    themeMode: themeMode ?? this.themeMode,
    languageCode: languageCode ?? this.languageCode,
    emergencyCallNumber: emergencyCallNumber ?? this.emergencyCallNumber,
    alarmDndOverride: alarmDndOverride ?? this.alarmDndOverride,
    defaults: defaults ?? this.defaults,
    selectedModeId: selectedModeId ?? this.selectedModeId,
    isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    telemetryOptOut: telemetryOptOut ?? this.telemetryOptOut,
    sessionLogRetentionDays:
        sessionLogRetentionDays ?? this.sessionLogRetentionDays,
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
          other.sessionLogRetentionDays == sessionLogRetentionDays;

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
