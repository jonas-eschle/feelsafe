/// `ThemeExtension` carrying Guardian-Angela safety colors.
///
/// Read from any widget via `Theme.of(context).extension<AppColorsExt>()!`.
library;

import 'package:flutter/material.dart';

import 'package:guardianangela/core/theme/app_colors.dart';

/// Theme extension wrapping [AppColors].
class AppColorsExt extends ThemeExtension<AppColorsExt> {
  /// Creates an extension.
  const AppColorsExt({required this.colors});

  /// The wrapped palette.
  final AppColors colors;

  @override
  AppColorsExt copyWith({AppColors? colors}) =>
      AppColorsExt(colors: colors ?? this.colors);

  @override
  AppColorsExt lerp(covariant ThemeExtension<AppColorsExt>? other, double t) {
    if (other is! AppColorsExt) return this;
    return t < 0.5 ? this : other;
  }
}

/// Convenience accessor for [AppColors] from a build context.
extension AppColorsOn on BuildContext {
  /// Returns the current [AppColors]; falls back to [AppColors.light].
  AppColors get appColors =>
      Theme.of(this).extension<AppColorsExt>()?.colors ?? AppColors.light;
}
