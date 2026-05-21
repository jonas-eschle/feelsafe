import 'package:guardianangela/domain/enums/stealth_icon_preset.dart';
import 'package:guardianangela/domain/enums/stealth_timer_display.dart';

/// Configures stealth-mode appearance for a session.
///
/// The global config lives in [AppDefaults.stealth]; modes can override via
/// [ModeOverrides.stealth]. See spec 03 §StealthConfig and Q20.
///
/// All sub-options are always visible in the UI even when [enabled] is
/// false, so users can pre-configure stealth before enabling it (D5).
final class StealthConfig {
  /// Creates a stealth config with the given values.
  ///
  /// Defaults: [enabled] = false, [fakeName] = 'Music',
  /// [fakeIcon] = [StealthIconPreset.music],
  /// [notificationDisguise] = true,
  /// [timerDisplay] = [StealthTimerDisplay.normal],
  /// [sessionScreenStealth] = true.
  const StealthConfig({
    this.enabled = false,
    this.fakeName = 'Music',
    this.fakeIcon = StealthIconPreset.music,
    this.notificationDisguise = true,
    this.timerDisplay = StealthTimerDisplay.normal,
    this.sessionScreenStealth = true,
  });

  /// Deserialises a [StealthConfig] from [json].
  factory StealthConfig.fromJson(Map<String, dynamic> json) => StealthConfig(
    enabled: (json['enabled'] as bool?) ?? false,
    fakeName: (json['fakeName'] as String?) ?? 'Music',
    fakeIcon: StealthIconPreset.values.byName(
      (json['fakeIcon'] as String?) ?? StealthIconPreset.music.name,
    ),
    notificationDisguise: (json['notificationDisguise'] as bool?) ?? true,
    timerDisplay: StealthTimerDisplay.values.byName(
      (json['timerDisplay'] as String?) ?? StealthTimerDisplay.normal.name,
    ),
    sessionScreenStealth: (json['sessionScreenStealth'] as bool?) ?? true,
  );

  /// Whether stealth mode is active.
  final bool enabled;

  /// Fake app name shown in notifications and the app switcher.
  final String fakeName;

  /// Generic icon shown when stealth is enabled.
  final StealthIconPreset fakeIcon;

  /// Whether to use a disguised notification channel name and icon.
  final bool notificationDisguise;

  /// How the session timer is displayed in stealth mode.
  final StealthTimerDisplay timerDisplay;

  /// Whether to remove Guardian Angela branding from the session screen.
  final bool sessionScreenStealth;

  /// Returns a copy with the specified fields replaced.
  StealthConfig copyWith({
    bool? enabled,
    String? fakeName,
    StealthIconPreset? fakeIcon,
    bool? notificationDisguise,
    StealthTimerDisplay? timerDisplay,
    bool? sessionScreenStealth,
  }) => StealthConfig(
    enabled: enabled ?? this.enabled,
    fakeName: fakeName ?? this.fakeName,
    fakeIcon: fakeIcon ?? this.fakeIcon,
    notificationDisguise: notificationDisguise ?? this.notificationDisguise,
    timerDisplay: timerDisplay ?? this.timerDisplay,
    sessionScreenStealth: sessionScreenStealth ?? this.sessionScreenStealth,
  );

  /// Serialises this config to a JSON map.
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'fakeName': fakeName,
    'fakeIcon': fakeIcon.name,
    'notificationDisguise': notificationDisguise,
    'timerDisplay': timerDisplay.name,
    'sessionScreenStealth': sessionScreenStealth,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StealthConfig &&
          enabled == other.enabled &&
          fakeName == other.fakeName &&
          fakeIcon == other.fakeIcon &&
          notificationDisguise == other.notificationDisguise &&
          timerDisplay == other.timerDisplay &&
          sessionScreenStealth == other.sessionScreenStealth);

  @override
  int get hashCode => Object.hash(
    enabled,
    fakeName,
    fakeIcon,
    notificationDisguise,
    timerDisplay,
    sessionScreenStealth,
  );
}
