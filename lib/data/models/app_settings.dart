import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 9)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool isDarkTheme;

  @HiveField(1)
  String languageCode;

  @HiveField(2)
  bool isFirstLaunch;

  @HiveField(3)
  String? selectedModeId;

  /// Emergency number (e.g. "112", "911").
  @HiveField(4)
  String emergencyNumber;

  AppSettings({
    this.isDarkTheme = true,
    this.languageCode = 'en',
    this.isFirstLaunch = true,
    this.selectedModeId,
    this.emergencyNumber = '112',
  });

  AppSettings copyWith({
    bool? isDarkTheme,
    String? languageCode,
    bool? isFirstLaunch,
    String? selectedModeId,
    String? emergencyNumber,
  }) {
    return AppSettings(
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      languageCode: languageCode ?? this.languageCode,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      selectedModeId: selectedModeId ?? this.selectedModeId,
      emergencyNumber: emergencyNumber ?? this.emergencyNumber,
    );
  }
}
