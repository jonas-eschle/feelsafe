import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';

/// A disguised notification template used in [ChainStepType.disguisedReminder]
/// steps.
///
/// Persisted as one row in the Drift `reminder_templates` table.
/// See spec 03 §ReminderTemplate.
///
/// 8 built-in templates are seeded on first launch.
/// Built-in templates have [isCustom] = false and cannot be deleted,
/// only disabled. Custom templates have [isCustom] = true.
final class ReminderTemplate {
  /// Creates a reminder template.
  ///
  /// [id] must be non-empty. [name], [title], [body] must each be
  /// non-empty and at most 255 characters.
  ReminderTemplate({
    required this.id,
    required this.name,
    required this.title,
    required this.body,
    this.iconAsset,
    required this.confirmationType,
    this.keyword,
    this.buttonLabel,
    required this.isCustom,
    this.imagePath,
    this.subtitle,
    required this.displayStyle,
    required this.isGlobal,
  }) : assert(id.isNotEmpty, 'ReminderTemplate.id must be non-empty'),
       assert(
         name.isNotEmpty && name.length <= 255,
         'ReminderTemplate.name must be 1–255 characters',
       ),
       assert(
         title.isNotEmpty && title.length <= 255,
         'ReminderTemplate.title must be 1–255 characters',
       ),
       assert(
         body.isNotEmpty && body.length <= 255,
         'ReminderTemplate.body must be 1–255 characters',
       ),
       assert(
         keyword == null || (keyword.isNotEmpty && keyword.length <= 50),
         'ReminderTemplate.keyword must be 1–50 characters when set',
       );

  /// Deserialises a [ReminderTemplate] from [json].
  factory ReminderTemplate.fromJson(Map<String, dynamic> json) =>
      ReminderTemplate(
        id: json['id'] as String,
        name: json['name'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        iconAsset: json['iconAsset'] as String?,
        confirmationType: ConfirmationType.values.byName(
          json['confirmationType'] as String,
        ),
        keyword: json['keyword'] as String?,
        buttonLabel: json['buttonLabel'] as String?,
        isCustom: json['isCustom'] as bool,
        imagePath: json['imagePath'] as String?,
        subtitle: json['subtitle'] as String?,
        displayStyle: ReminderDisplayStyle.values.byName(
          json['displayStyle'] as String,
        ),
        isGlobal: json['isGlobal'] as bool,
      );

  /// UUID — primary key.
  final String id;

  /// Human-readable name (e.g., "Calendar Event").
  final String name;

  /// Notification title text.
  final String title;

  /// Notification body text.
  final String body;

  /// Optional asset path for the notification icon.
  final String? iconAsset;

  /// How the user confirms safety when this template is shown.
  final ConfirmationType confirmationType;

  /// The correct word for [ConfirmationType.tapWord] templates.
  ///
  /// Case-insensitive matching in the UI. Must be 1–50 characters when set.
  final String? keyword;

  /// Label text for [ConfirmationType.tapButton] templates.
  final String? buttonLabel;

  /// Whether this is a user-created template.
  ///
  /// false = built-in (cannot be deleted, only disabled).
  /// true = user-created (can be deleted freely).
  final bool isCustom;

  /// Optional custom image path for full-screen display.
  final String? imagePath;

  /// Optional subtitle shown between [title] and [body].
  final String? subtitle;

  /// How the reminder is displayed to the user.
  final ReminderDisplayStyle displayStyle;

  /// Whether this template comes from [AppDefaults.templates] (global)
  /// or [ModeOverrides.localTemplates] (mode-local).
  final bool isGlobal;

  /// Returns a copy with the specified fields replaced.
  ReminderTemplate copyWith({
    String? id,
    String? name,
    String? title,
    String? body,
    String? iconAsset,
    ConfirmationType? confirmationType,
    String? keyword,
    String? buttonLabel,
    bool? isCustom,
    String? imagePath,
    String? subtitle,
    ReminderDisplayStyle? displayStyle,
    bool? isGlobal,
  }) => ReminderTemplate(
    id: id ?? this.id,
    name: name ?? this.name,
    title: title ?? this.title,
    body: body ?? this.body,
    iconAsset: iconAsset ?? this.iconAsset,
    confirmationType: confirmationType ?? this.confirmationType,
    keyword: keyword ?? this.keyword,
    buttonLabel: buttonLabel ?? this.buttonLabel,
    isCustom: isCustom ?? this.isCustom,
    imagePath: imagePath ?? this.imagePath,
    subtitle: subtitle ?? this.subtitle,
    displayStyle: displayStyle ?? this.displayStyle,
    isGlobal: isGlobal ?? this.isGlobal,
  );

  /// Serialises this template to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'title': title,
    'body': body,
    if (iconAsset != null) 'iconAsset': iconAsset,
    'confirmationType': confirmationType.name,
    if (keyword != null) 'keyword': keyword,
    if (buttonLabel != null) 'buttonLabel': buttonLabel,
    'isCustom': isCustom,
    if (imagePath != null) 'imagePath': imagePath,
    if (subtitle != null) 'subtitle': subtitle,
    'displayStyle': displayStyle.name,
    'isGlobal': isGlobal,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderTemplate &&
          id == other.id &&
          name == other.name &&
          title == other.title &&
          body == other.body &&
          iconAsset == other.iconAsset &&
          confirmationType == other.confirmationType &&
          keyword == other.keyword &&
          buttonLabel == other.buttonLabel &&
          isCustom == other.isCustom &&
          imagePath == other.imagePath &&
          subtitle == other.subtitle &&
          displayStyle == other.displayStyle &&
          isGlobal == other.isGlobal);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    title,
    body,
    iconAsset,
    confirmationType,
    keyword,
    buttonLabel,
    isCustom,
    imagePath,
    subtitle,
    displayStyle,
    isGlobal,
  );
}
