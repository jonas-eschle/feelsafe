import 'package:guardianangela/domain/enums/app_theme_mode.dart';
import 'package:guardianangela/domain/models/app_defaults.dart';

/// Application-level settings persisted in `app_settings.json`.
///
/// JSON-backed singleton. See spec 03 §AppSettings.
///
/// Three independent PIN hashes (each nullable = disabled):
/// - [appPinHash]: locks the app on open.
/// - [sessionEndPinHash]: required to disarm or end a session.
/// - [duressPinHash]: silently fires the distress chain when entered.
final class AppSettings {
  /// Creates an [AppSettings] instance.
  ///
  /// Defaults represent a freshly installed, first-launch state.
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.languageCode = 'en',
    this.isFirstLaunch = true,
    this.selectedModeId,
    this.appPinHash,
    this.sessionEndPinHash,
    this.duressPinHash,
    this.pinTimeoutSeconds = 15,
    this.wrongPinThreshold = 5,
    this.deceptivePinDialogEnabled = true,
    this.appPinBiometricEnabled = false,
    this.sessionEndPinBiometricEnabled = false,
    this.distressCancelBiometricEnabled = false,
    this.requireLaunchAuth = false,
    this.launchAuthBiometric = true,
    this.emergencyCallNumber = '112',
    this.alarmDndOverride = false,
    this.alarmGradualVolume = false,
    this.alarmGradualVolumeDurationSeconds = 5,
    this.sessionLogRetentionDays = 180,
    this.trashRetentionDays = 7,
    this.telemetryOptOut = false,
    this.sentryEnabled = false,
    this.defaults = const AppDefaults(),
  });

  /// Deserialises an [AppSettings] from [json].
  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    themeMode: AppThemeMode.values.byName(
      (json['themeMode'] as String?) ?? AppThemeMode.system.name,
    ),
    languageCode: (json['languageCode'] as String?) ?? 'en',
    isFirstLaunch: (json['isFirstLaunch'] as bool?) ?? true,
    selectedModeId: json['selectedModeId'] as String?,
    appPinHash: json['appPinHash'] as String?,
    sessionEndPinHash: json['sessionEndPinHash'] as String?,
    duressPinHash: json['duressPinHash'] as String?,
    pinTimeoutSeconds: (json['pinTimeoutSeconds'] as num?)?.toInt() ?? 15,
    wrongPinThreshold: (json['wrongPinThreshold'] as num?)?.toInt() ?? 5,
    deceptivePinDialogEnabled:
        (json['deceptivePinDialogEnabled'] as bool?) ?? true,
    appPinBiometricEnabled: (json['appPinBiometricEnabled'] as bool?) ?? false,
    sessionEndPinBiometricEnabled:
        (json['sessionEndPinBiometricEnabled'] as bool?) ?? false,
    distressCancelBiometricEnabled:
        (json['distressCancelBiometricEnabled'] as bool?) ?? false,
    requireLaunchAuth: (json['requireLaunchAuth'] as bool?) ?? false,
    launchAuthBiometric: (json['launchAuthBiometric'] as bool?) ?? true,
    emergencyCallNumber: (json['emergencyCallNumber'] as String?) ?? '112',
    alarmDndOverride: (json['alarmDndOverride'] as bool?) ?? false,
    alarmGradualVolume: (json['alarmGradualVolume'] as bool?) ?? false,
    alarmGradualVolumeDurationSeconds:
        (json['alarmGradualVolumeDurationSeconds'] as num?)?.toInt() ?? 5,
    sessionLogRetentionDays:
        (json['sessionLogRetentionDays'] as num?)?.toInt() ?? 180,
    trashRetentionDays: (json['trashRetentionDays'] as num?)?.toInt() ?? 7,
    telemetryOptOut: (json['telemetryOptOut'] as bool?) ?? false,
    sentryEnabled: (json['sentryEnabled'] as bool?) ?? false,
    defaults: json['defaults'] != null
        ? AppDefaults.fromJson(json['defaults'] as Map<String, dynamic>)
        : const AppDefaults(),
  );

  // ── Display ────────────────────────────────────────────────────────

  /// App theme preference. Default: [AppThemeMode.system].
  final AppThemeMode themeMode;

  /// Active language code (BCP 47). Default: `'en'`.
  ///
  /// Supported: en, de, es, fr, ru, zh, zh_TW, hi, fa, uk, pl, el, ar, he.
  final String languageCode;

  /// Whether this is the first app launch (routes to onboarding). Default
  /// true.
  final bool isFirstLaunch;

  /// UUID of the currently selected session mode (for quick resume).
  final String? selectedModeId;

  // ── Security — three independent PIN hashes ────────────────────────

  /// Hash of the app lock PIN. Null = no app lock.
  final String? appPinHash;

  /// Hash of the session-end PIN. Null = no session-end lock.
  final String? sessionEndPinHash;

  /// Hash of the duress PIN. Null = duress PIN disabled.
  ///
  /// Entering this at any PIN prompt silently fires the distress chain
  /// and shows a fake "Session ended" screen to the attacker.
  final String? duressPinHash;

  /// Seconds before the PIN prompt auto-dismisses on timeout. Default 15;
  /// max 120.
  final int pinTimeoutSeconds;

  /// Wrong PIN entries before silently firing distress (A3). Default 5.
  final int wrongPinThreshold;

  /// Whether to show a deceptive "Old PIN entered" dialog on wrong-PIN
  /// entry to mask the failure counter from a casual attacker (R-42).
  /// Default true.
  final bool deceptivePinDialogEnabled;

  // ── Biometric / launch-auth (Q14) ─────────────────────────────────

  /// Try biometric before the app lock PIN prompt. Default false.
  final bool appPinBiometricEnabled;

  /// Try biometric before the session-end PIN prompt. Default false.
  final bool sessionEndPinBiometricEnabled;

  /// Try biometric before the distress-cancel PIN prompt. Default false.
  final bool distressCancelBiometricEnabled;

  /// Gate the home screen behind PIN or biometric on cold start. Default
  /// false.
  final bool requireLaunchAuth;

  /// Prefer biometric at the launch auth gate. Default true.
  final bool launchAuthBiometric;

  // ── Global behavior ────────────────────────────────────────────────

  /// Emergency services number. Default `'112'` (GSM international).
  final String emergencyCallNumber;

  /// Whether loud-alarm steps may override Do Not Disturb. Default false
  /// (Q19 — opt-in).
  final bool alarmDndOverride;

  /// Whether the alarm volume ramps from 0 to the configured level.
  /// Default false.
  final bool alarmGradualVolume;

  /// Ramp duration in seconds when [alarmGradualVolume] is true. Default 5.
  final int alarmGradualVolumeDurationSeconds;

  /// Days after which a non-critical session log is soft-deleted into the
  /// trash. Default 180.
  final int sessionLogRetentionDays;

  /// Days that a soft-deleted log remains in the trash before permanent
  /// deletion (Extra 11). Default 7.
  final int trashRetentionDays;

  // ── Telemetry ──────────────────────────────────────────────────────

  /// Legacy telemetry opt-out flag.
  final bool telemetryOptOut;

  /// Master Sentry toggle. Default false (opt-in, Q42).
  final bool sentryEnabled;

  // ── AppDefaults ────────────────────────────────────────────────────

  /// GPS logging, stealth, templates, event defaults, and distress-mode
  /// pointer.
  final AppDefaults defaults;

  /// Returns a copy with the specified fields replaced.
  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? languageCode,
    bool? isFirstLaunch,
    String? selectedModeId,
    String? appPinHash,
    String? sessionEndPinHash,
    String? duressPinHash,
    int? pinTimeoutSeconds,
    int? wrongPinThreshold,
    bool? deceptivePinDialogEnabled,
    bool? appPinBiometricEnabled,
    bool? sessionEndPinBiometricEnabled,
    bool? distressCancelBiometricEnabled,
    bool? requireLaunchAuth,
    bool? launchAuthBiometric,
    String? emergencyCallNumber,
    bool? alarmDndOverride,
    bool? alarmGradualVolume,
    int? alarmGradualVolumeDurationSeconds,
    int? sessionLogRetentionDays,
    int? trashRetentionDays,
    bool? telemetryOptOut,
    bool? sentryEnabled,
    AppDefaults? defaults,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    languageCode: languageCode ?? this.languageCode,
    isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    selectedModeId: selectedModeId ?? this.selectedModeId,
    appPinHash: appPinHash ?? this.appPinHash,
    sessionEndPinHash: sessionEndPinHash ?? this.sessionEndPinHash,
    duressPinHash: duressPinHash ?? this.duressPinHash,
    pinTimeoutSeconds: pinTimeoutSeconds ?? this.pinTimeoutSeconds,
    wrongPinThreshold: wrongPinThreshold ?? this.wrongPinThreshold,
    deceptivePinDialogEnabled:
        deceptivePinDialogEnabled ?? this.deceptivePinDialogEnabled,
    appPinBiometricEnabled:
        appPinBiometricEnabled ?? this.appPinBiometricEnabled,
    sessionEndPinBiometricEnabled:
        sessionEndPinBiometricEnabled ?? this.sessionEndPinBiometricEnabled,
    distressCancelBiometricEnabled:
        distressCancelBiometricEnabled ?? this.distressCancelBiometricEnabled,
    requireLaunchAuth: requireLaunchAuth ?? this.requireLaunchAuth,
    launchAuthBiometric: launchAuthBiometric ?? this.launchAuthBiometric,
    emergencyCallNumber: emergencyCallNumber ?? this.emergencyCallNumber,
    alarmDndOverride: alarmDndOverride ?? this.alarmDndOverride,
    alarmGradualVolume: alarmGradualVolume ?? this.alarmGradualVolume,
    alarmGradualVolumeDurationSeconds:
        alarmGradualVolumeDurationSeconds ??
        this.alarmGradualVolumeDurationSeconds,
    sessionLogRetentionDays:
        sessionLogRetentionDays ?? this.sessionLogRetentionDays,
    trashRetentionDays: trashRetentionDays ?? this.trashRetentionDays,
    telemetryOptOut: telemetryOptOut ?? this.telemetryOptOut,
    sentryEnabled: sentryEnabled ?? this.sentryEnabled,
    defaults: defaults ?? this.defaults,
  );

  /// Serialises this instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'languageCode': languageCode,
    'isFirstLaunch': isFirstLaunch,
    if (selectedModeId != null) 'selectedModeId': selectedModeId,
    if (appPinHash != null) 'appPinHash': appPinHash,
    if (sessionEndPinHash != null) 'sessionEndPinHash': sessionEndPinHash,
    if (duressPinHash != null) 'duressPinHash': duressPinHash,
    'pinTimeoutSeconds': pinTimeoutSeconds,
    'wrongPinThreshold': wrongPinThreshold,
    'deceptivePinDialogEnabled': deceptivePinDialogEnabled,
    'appPinBiometricEnabled': appPinBiometricEnabled,
    'sessionEndPinBiometricEnabled': sessionEndPinBiometricEnabled,
    'distressCancelBiometricEnabled': distressCancelBiometricEnabled,
    'requireLaunchAuth': requireLaunchAuth,
    'launchAuthBiometric': launchAuthBiometric,
    'emergencyCallNumber': emergencyCallNumber,
    'alarmDndOverride': alarmDndOverride,
    'alarmGradualVolume': alarmGradualVolume,
    'alarmGradualVolumeDurationSeconds': alarmGradualVolumeDurationSeconds,
    'sessionLogRetentionDays': sessionLogRetentionDays,
    'trashRetentionDays': trashRetentionDays,
    'telemetryOptOut': telemetryOptOut,
    'sentryEnabled': sentryEnabled,
    'defaults': defaults.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettings &&
          themeMode == other.themeMode &&
          languageCode == other.languageCode &&
          isFirstLaunch == other.isFirstLaunch &&
          selectedModeId == other.selectedModeId &&
          appPinHash == other.appPinHash &&
          sessionEndPinHash == other.sessionEndPinHash &&
          duressPinHash == other.duressPinHash &&
          pinTimeoutSeconds == other.pinTimeoutSeconds &&
          wrongPinThreshold == other.wrongPinThreshold &&
          deceptivePinDialogEnabled == other.deceptivePinDialogEnabled &&
          appPinBiometricEnabled == other.appPinBiometricEnabled &&
          sessionEndPinBiometricEnabled ==
              other.sessionEndPinBiometricEnabled &&
          distressCancelBiometricEnabled ==
              other.distressCancelBiometricEnabled &&
          requireLaunchAuth == other.requireLaunchAuth &&
          launchAuthBiometric == other.launchAuthBiometric &&
          emergencyCallNumber == other.emergencyCallNumber &&
          alarmDndOverride == other.alarmDndOverride &&
          alarmGradualVolume == other.alarmGradualVolume &&
          alarmGradualVolumeDurationSeconds ==
              other.alarmGradualVolumeDurationSeconds &&
          sessionLogRetentionDays == other.sessionLogRetentionDays &&
          trashRetentionDays == other.trashRetentionDays &&
          telemetryOptOut == other.telemetryOptOut &&
          sentryEnabled == other.sentryEnabled &&
          defaults == other.defaults);

  @override
  int get hashCode => Object.hashAll([
    themeMode,
    languageCode,
    isFirstLaunch,
    selectedModeId,
    appPinHash,
    sessionEndPinHash,
    duressPinHash,
    pinTimeoutSeconds,
    wrongPinThreshold,
    deceptivePinDialogEnabled,
    appPinBiometricEnabled,
    sessionEndPinBiometricEnabled,
    distressCancelBiometricEnabled,
    requireLaunchAuth,
    launchAuthBiometric,
    emergencyCallNumber,
    alarmDndOverride,
    alarmGradualVolume,
    alarmGradualVolumeDurationSeconds,
    sessionLogRetentionDays,
    trashRetentionDays,
    telemetryOptOut,
    sentryEnabled,
    defaults,
  ]);
}
