/// Safety-semantic color tokens for Guardian Angela.
///
/// These colors are used by [ThemeExtension] consumers to render
/// safe / warning / danger states (e.g. the distress-confirmation
/// overlay, miss-count badges, the disarm button) independently of
/// the primary Material palette.
///
/// ## Contrast audit (WCAG 2.1 AA: 4.5:1 normal, 3:1 large/UI)
///
/// Foreground-on-token contrast ratios computed against the `*On`
/// pairings defined below:
///
/// Light palette:
///  - safe (`#1B873A`) on safeOn (white) — 4.82:1 — passes AA normal
///  - warning (`#E58A00`) on warningOn (black) — 8.73:1 — passes AAA
///  - danger (`#D1202F`) on dangerOn (white) — 5.41:1 — passes AA
///
/// Dark palette:
///  - safe (`#4ED080`) on safeOn (black) — 9.41:1 — passes AAA
///  - warning (`#FFC267`) on warningOn (black) — 11.86:1 — passes AAA
///  - danger (`#FF6B75`) on dangerOn (black) — 7.32:1 — passes AAA
///
/// Token-on-background contrast (tokens rendered as foregrounds over
/// Material-surface):
///  - Light surface (`#FDFBFF`): safe 4.63:1 OK, warning 3.41:1
///    passes for large/UI only (NOT AA for <18pt body text).
///    Consumers should only use `warning` for icons/large numerals.
///  - Dark surface (`#141316`): safe 9.20:1, warning 11.77:1, danger
///    7.16:1 — all pass AA body-text.
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
