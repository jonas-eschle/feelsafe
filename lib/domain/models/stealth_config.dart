/// `StealthConfig` and its `StealthIconPreset` enum.
///
/// Configures how the app presents itself when stealth is active
/// (fake app name, fake icon, disguised notifications, minimal
/// session UI). Global defaults live in `AppDefaults.stealth`; modes
/// may override via `ModeOverrides.stealth`.
library;

/// Built-in icon preset identifiers for the stealth / fake-app
/// appearance.
enum StealthIconPreset {
  /// Music app icon preset.
  music,

  /// Calendar app icon preset. Default.
  calendar,

  /// Fitness app icon preset.
  fitness,

  /// Weather app icon preset.
  weather,

  /// News app icon preset.
  news,

  /// Photos app icon preset.
  photos,

  /// Notes app icon preset.
  notes,

  /// Clock app icon preset.
  clock,

  /// Podcast app icon preset.
  podcast,

  /// No icon preset (default app face).
  none,
}

/// How the session timer is rendered while stealth is active (Q26).
enum StealthTimerDisplay {
  /// Show the full localized "remaining" countdown text. Default
  /// when stealth is disabled.
  normal,

  /// Integer-only display (e.g., "37"). Useful when the disguise UI
  /// already has its own visible clock.
  small,

  /// Hide the timer text entirely.
  none,
}

/// Configuration for the app's stealth appearance.
final class StealthConfig {
  /// Creates a stealth config.
  ///
  /// [enabled] — master stealth toggle; defaults to false.
  /// [fakeName] — fake app / mode name shown to observers; defaults
  /// to "Calendar".
  /// [fakeIcon] — which built-in icon preset to use; defaults to
  /// calendar.
  /// [notificationDisguise] — disguise notification channel / icon;
  /// defaults to true.
  /// [timerDisplay] — show session timer even in stealth; defaults
  /// to false.
  /// [sessionScreenStealth] — strip Guardian-Angela branding from
  /// the session screen; defaults to true.
  const StealthConfig({
    this.enabled = false,
    this.fakeName = 'Calendar',
    this.fakeIcon = StealthIconPreset.calendar,
    this.notificationDisguise = true,
    this.timerDisplay = false,
    this.sessionScreenStealth = true,
  });

  /// Deserializes a `StealthConfig` from JSON.
  factory StealthConfig.fromJson(Map<String, Object?> json) => StealthConfig(
    enabled: json['enabled'] as bool? ?? false,
    fakeName: json['fakeName'] as String? ?? 'Calendar',
    fakeIcon: _iconFromJson(json['fakeIcon']),
    notificationDisguise: json['notificationDisguise'] as bool? ?? true,
    timerDisplay: json['timerDisplay'] as bool? ?? false,
    sessionScreenStealth: json['sessionScreenStealth'] as bool? ?? true,
  );

  /// Master toggle for stealth mode. Defaults to false.
  final bool enabled;

  /// Fake app/mode name. Defaults to "Calendar".
  final String fakeName;

  /// Which icon preset to show. Defaults to
  /// `StealthIconPreset.calendar`.
  final StealthIconPreset fakeIcon;

  /// Whether notifications use disguised channel / icon. Defaults to
  /// true.
  final bool notificationDisguise;

  /// Whether the session timer is still displayed in stealth.
  /// Defaults to false.
  final bool timerDisplay;

  /// Whether the session screen hides Guardian-Angela branding.
  /// Defaults to true.
  final bool sessionScreenStealth;

  /// Returns a new config with the given fields replaced.
  StealthConfig copyWith({
    bool? enabled,
    String? fakeName,
    StealthIconPreset? fakeIcon,
    bool? notificationDisguise,
    bool? timerDisplay,
    bool? sessionScreenStealth,
  }) => StealthConfig(
    enabled: enabled ?? this.enabled,
    fakeName: fakeName ?? this.fakeName,
    fakeIcon: fakeIcon ?? this.fakeIcon,
    notificationDisguise: notificationDisguise ?? this.notificationDisguise,
    timerDisplay: timerDisplay ?? this.timerDisplay,
    sessionScreenStealth: sessionScreenStealth ?? this.sessionScreenStealth,
  );

  /// Serializes to JSON.
  Map<String, Object?> toJson() => {
    'enabled': enabled,
    'fakeName': fakeName,
    'fakeIcon': fakeIcon.name,
    'notificationDisguise': notificationDisguise,
    'timerDisplay': timerDisplay,
    'sessionScreenStealth': sessionScreenStealth,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StealthConfig &&
          other.enabled == enabled &&
          other.fakeName == fakeName &&
          other.fakeIcon == fakeIcon &&
          other.notificationDisguise == notificationDisguise &&
          other.timerDisplay == timerDisplay &&
          other.sessionScreenStealth == sessionScreenStealth;

  @override
  int get hashCode => Object.hash(
    enabled,
    fakeName,
    fakeIcon,
    notificationDisguise,
    timerDisplay,
    sessionScreenStealth,
  );

  @override
  String toString() =>
      'StealthConfig(enabled: $enabled, '
      'fakeName: $fakeName, fakeIcon: $fakeIcon)';
}

StealthIconPreset _iconFromJson(Object? raw) => switch (raw) {
  'music' => StealthIconPreset.music,
  'calendar' => StealthIconPreset.calendar,
  'fitness' => StealthIconPreset.fitness,
  'weather' => StealthIconPreset.weather,
  'news' => StealthIconPreset.news,
  'photos' => StealthIconPreset.photos,
  'notes' => StealthIconPreset.notes,
  'clock' => StealthIconPreset.clock,
  null => StealthIconPreset.calendar,
  _ => throw ArgumentError.value(raw, 'fakeIcon', 'unknown StealthIconPreset'),
};
