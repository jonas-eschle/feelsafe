import 'package:hive/hive.dart';

part 'reminder_template.g.dart';

@HiveType(typeId: 4)
enum ConfirmationType {
  @HiveField(0)
  tapButton,

  @HiveField(1)
  tapWord,

  @HiveField(2)
  swipe,

  @HiveField(3)
  dismiss,
}

@HiveType(typeId: 5)
class ReminderTemplate extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String title;

  @HiveField(3)
  String body;

  @HiveField(4)
  String? iconAsset;

  @HiveField(5)
  ConfirmationType confirmationType;

  /// For tapWord: the correct keyword to tap.
  @HiveField(6)
  String? keyword;

  /// For tapButton: label of the confirmation button.
  @HiveField(7)
  String? buttonLabel;

  @HiveField(8)
  bool isCustom;

  /// Optional custom image path for the notification icon.
  @HiveField(9)
  String? imagePath;

  /// Optional subtitle text shown between title and body.
  @HiveField(10)
  String? subtitle;

  ReminderTemplate({
    required this.id,
    required this.name,
    required this.title,
    required this.body,
    this.iconAsset,
    required this.confirmationType,
    this.keyword,
    this.buttonLabel,
    this.isCustom = false,
    this.imagePath,
    this.subtitle,
  });

  ReminderTemplate copyWith({
    String? name,
    String? title,
    String? body,
    String? iconAsset,
    ConfirmationType? confirmationType,
    String? keyword,
    String? buttonLabel,
    String? imagePath,
    String? subtitle,
  }) {
    return ReminderTemplate(
      id: id,
      name: name ?? this.name,
      title: title ?? this.title,
      body: body ?? this.body,
      iconAsset: iconAsset ?? this.iconAsset,
      confirmationType: confirmationType ?? this.confirmationType,
      keyword: keyword ?? this.keyword,
      buttonLabel: buttonLabel ?? this.buttonLabel,
      isCustom: isCustom,
      imagePath: imagePath ?? this.imagePath,
      subtitle: subtitle ?? this.subtitle,
    );
  }
}
