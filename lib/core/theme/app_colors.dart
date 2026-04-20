/// Safety-semantic color tokens for Guardian Angela.
///
/// These colors are used by [ThemeExtension] consumers to render
/// safe / warning / danger states (e.g. the distress-confirmation
/// overlay, miss-count badges, the disarm button) independently of
/// the primary Material palette.
library;

import 'package:flutter/material.dart';

/// Immutable bag of safety-semantic colors.
@immutable
class AppColors {
  /// Creates a color palette.
  const AppColors({
    required this.safe,
    required this.warning,
    required this.danger,
    required this.safeOn,
    required this.warningOn,
    required this.dangerOn,
  });

  /// Light palette.
  static const AppColors light = AppColors(
    safe: Color(0xFF1B873A),
    warning: Color(0xFFE58A00),
    danger: Color(0xFFD1202F),
    safeOn: Colors.white,
    warningOn: Colors.black,
    dangerOn: Colors.white,
  );

  /// Dark palette.
  static const AppColors dark = AppColors(
    safe: Color(0xFF4ED080),
    warning: Color(0xFFFFC267),
    danger: Color(0xFFFF6B75),
    safeOn: Colors.black,
    warningOn: Colors.black,
    dangerOn: Colors.black,
  );

  /// "You are safe" color; used for the disarm affordance.
  final Color safe;

  /// Mid-severity indicator; used for miss-count badges, countdowns.
  final Color warning;

  /// High-severity indicator; used for distress / escalation UI.
  final Color danger;

  /// Foreground over [safe].
  final Color safeOn;

  /// Foreground over [warning].
  final Color warningOn;

  /// Foreground over [danger].
  final Color dangerOn;
}
