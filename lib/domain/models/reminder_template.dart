/// `ReminderTemplate` — a disguised reminder shown during a
/// `disguisedReminder` step.
///
/// Templates can be global (stored in `AppDefaults.templates`) or
/// mode-local (stored in `ModeOverrides.localTemplates`, appended to
/// the effective list).
library;

import 'package:guardianangela/data/models/enums.dart';

/// A single disguised-reminder template.
final class ReminderTemplate {
  /// Creates a reminder template.
  ///
  /// [id] — stable UUID.
  /// [name] — editor-side name (e.g., "Calendar Event").
  /// [title] — reminder title shown to the user.
  /// [body] — reminder body.
  /// [confirmationType] — how the user confirms.
  /// [displayStyle] — full-screen or subtle overlay.
  /// [isGlobal] — true if stored in `AppDefaults.templates`; false
  /// if mode-local.
  /// [isCustom] — true if user-created; false if seeded built-in.
  /// [iconAsset] — optional asset path for an icon.
  /// [keyword] — correct word for `tapWord` confirmation.
  /// [buttonLabel] — label for `tapButton` confirmation.
  /// [imagePath] — optional custom image path.
  /// [subtitle] — optional subtitle between title and body.
  const ReminderTemplate({
    required this.id,
    required this.name,
    required this.title,
    required this.body,
    required this.confirmationType,
    required this.displayStyle,
    required this.isGlobal,
    this.isCustom = false,
    this.iconAsset,
    this.keyword,
    this.buttonLabel,
    this.imagePath,
    this.subtitle,
  });

  /// Deserializes a `ReminderTemplate` from JSON.
  factory ReminderTemplate.fromJson(Map<String, Object?> json) =>
      ReminderTemplate(
        id: json['id']! as String,
        name: json['name']! as String,
        title: json['title']! as String,
        body: json['body']! as String,
        confirmationType: _confirmationTypeFromJson(json['confirmationType']),
        displayStyle: _displayStyleFromJson(json['displayStyle']),
        isGlobal: json['isGlobal'] as bool? ?? true,
        isCustom: json['isCustom'] as bool? ?? false,
        iconAsset: json['iconAsset'] as String?,
        keyword: json['keyword'] as String?,
        buttonLabel: json['buttonLabel'] as String?,
        imagePath: json['imagePath'] as String?,
        subtitle: json['subtitle'] as String?,
      );

  /// Stable identifier (UUID).
  final String id;

  /// Editor-side name.
  final String name;

  /// Reminder title shown to the user.
  final String title;

  /// Reminder body shown to the user.
  final String body;

  /// How the user confirms safety.
  final ConfirmationType confirmationType;

  /// Visual style of the reminder.
  final ReminderDisplayStyle displayStyle;

  /// True if the template is global (`AppDefaults.templates`),
  /// false if mode-local (`ModeOverrides.localTemplates`).
  final bool isGlobal;

  /// True if user-created. Built-in templates have `isCustom=false`.
  final bool isCustom;

  /// Optional asset path for the template icon.
  final String? iconAsset;

  /// Correct word for `tapWord` confirmation. Defaults to null.
  final String? keyword;

  /// Button label for `tapButton` confirmation. Defaults to null.
  final String? buttonLabel;

  /// Optional custom image path. Defaults to null.
  final String? imagePath;

  /// Optional subtitle. Defaults to null.
  final String? subtitle;

  /// Returns a new template with the given fields replaced.
  ReminderTemplate copyWith({
    String? id,
    String? name,
    String? title,
    String? body,
    ConfirmationType? confirmationType,
    ReminderDisplayStyle? displayStyle,
    bool? isGlobal,
    bool? isCustom,
    String? iconAsset,
    String? keyword,
    String? buttonLabel,
    String? imagePath,
    String? subtitle,
  }) => ReminderTemplate(
    id: id ?? this.id,
    name: name ?? this.name,
    title: title ?? this.title,
    body: body ?? this.body,
    confirmationType: confirmationType ?? this.confirmationType,
    displayStyle: displayStyle ?? this.displayStyle,
    isGlobal: isGlobal ?? this.isGlobal,
    isCustom: isCustom ?? this.isCustom,
    iconAsset: iconAsset ?? this.iconAsset,
    keyword: keyword ?? this.keyword,
    buttonLabel: buttonLabel ?? this.buttonLabel,
    imagePath: imagePath ?? this.imagePath,
    subtitle: subtitle ?? this.subtitle,
  );

  /// Serializes to JSON.
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'title': title,
    'body': body,
    'confirmationType': confirmationType.name,
    'displayStyle': displayStyle.name,
    'isGlobal': isGlobal,
    'isCustom': isCustom,
    'iconAsset': iconAsset,
    'keyword': keyword,
    'buttonLabel': buttonLabel,
    'imagePath': imagePath,
    'subtitle': subtitle,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderTemplate &&
          other.id == id &&
          other.name == name &&
          other.title == title &&
          other.body == body &&
          other.confirmationType == confirmationType &&
          other.displayStyle == displayStyle &&
          other.isGlobal == isGlobal &&
          other.isCustom == isCustom &&
          other.iconAsset == iconAsset &&
          other.keyword == keyword &&
          other.buttonLabel == buttonLabel &&
          other.imagePath == imagePath &&
          other.subtitle == subtitle;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    title,
    body,
    confirmationType,
    displayStyle,
    isGlobal,
    isCustom,
    iconAsset,
    keyword,
    buttonLabel,
    imagePath,
    subtitle,
  );

  @override
  String toString() =>
      'ReminderTemplate(id: $id, name: $name, '
      'title: $title, isGlobal: $isGlobal)';
}

ConfirmationType _confirmationTypeFromJson(Object? raw) => switch (raw) {
  'tapButton' => ConfirmationType.tapButton,
  'tapWord' => ConfirmationType.tapWord,
  'swipe' => ConfirmationType.swipe,
  'dismiss' => ConfirmationType.dismiss,
  _ => throw ArgumentError.value(
    raw,
    'confirmationType',
    'unknown ConfirmationType',
  ),
};

ReminderDisplayStyle _displayStyleFromJson(Object? raw) => switch (raw) {
  'fullScreen' => ReminderDisplayStyle.fullScreen,
  'subtle' => ReminderDisplayStyle.subtle,
  _ => throw ArgumentError.value(
    raw,
    'displayStyle',
    'unknown ReminderDisplayStyle',
  ),
};
