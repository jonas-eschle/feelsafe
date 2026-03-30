import 'package:flutter/material.dart';

abstract final class AppColors {
  // Dark theme — warmer tones
  static const darkBackground = Color(0xFF131118);
  static const darkSurface = Color(0xFF1C1924);
  static const darkSurfaceVariant = Color(0xFF262230);
  static const darkText = Color(0xFFF0ECF4);
  static const darkTextSecondary = Color(0xFF9B93A8);

  // Light theme — warm whites
  static const lightBackground = Color(0xFFFAF8FC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF0ECF4);
  static const lightText = Color(0xFF1C1924);
  static const lightTextSecondary = Color(0xFF6B6279);

  // Semantic colors — warmer variants
  static const safe = Color(0xFF4ECDC4);
  static const warning = Color(0xFFFFB74D);
  static const danger = Color(0xFFEF5350);
  static const safeLight = Color(0xFF2DD4BF);
  static const warningLight = Color(0xFFFFD54F);
  static const dangerLight = Color(0xFFE57373);

  // Pride flag colors (used as subtle accents)
  static const prideRed = Color(0xFFE40303);
  static const prideOrange = Color(0xFFFF8C00);
  static const prideYellow = Color(0xFFFFED00);
  static const prideGreen = Color(0xFF008026);
  static const prideBlue = Color(0xFF004DFF);
  static const pridePurple = Color(0xFF750787);

  static const prideColors = [
    prideRed,
    prideOrange,
    prideYellow,
    prideGreen,
    prideBlue,
    pridePurple,
  ];

  /// A thin pride gradient for dividers, progress bars, and accents.
  static const prideGradient = LinearGradient(
    colors: prideColors,
  );

  /// Subtle version (lower opacity) for backgrounds.
  static LinearGradient get prideGradientSubtle => LinearGradient(
        colors: prideColors.map((c) => c.withValues(alpha: 0.35)).toList(),
      );
}
