/// Material 3 [ThemeData] factories for the light + dark themes.
///
/// Both themes seed the [ColorScheme] from Material-indigo and attach
/// an [AppColorsExt] carrying the safety-semantic color tokens.
library;

import 'package:flutter/material.dart';

import 'package:guardianangela/core/theme/app_colors.dart';
import 'package:guardianangela/core/theme/theme_extensions.dart';

/// Theme factories.
abstract class AppTheme {
  /// The light theme.
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
    return _buildTheme(scheme, AppColors.light);
  }

  /// The dark theme.
  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    );
    return _buildTheme(scheme, AppColors.dark);
  }

  static ThemeData _buildTheme(ColorScheme scheme, AppColors colors) =>
      ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        extensions: <ThemeExtension<dynamic>>[AppColorsExt(colors: colors)],
      );
}
