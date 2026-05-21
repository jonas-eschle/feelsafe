/// `MoreSettingsPanel` — collapsible "More settings" tile per spec
/// 11 §DE-4.
///
/// Wraps the rare-toggle subset of a step's config in an
/// `ExpansionTile` so the common settings (timing, retry count,
/// type-specific primary fields) stay above the fold. When any of
/// the wrapped fields differs from its default, the collapsed
/// header shows a `(N customized)` badge so users can tell at a
/// glance that overrides are in play.
///
/// *Why a dedicated widget:* the badge counter logic is identical
/// for every step type and every host screen (mode editor, event
/// defaults). Centralising it keeps the editor forms slim and the
/// counting rule consistent.
library;

import 'package:flutter/material.dart';

import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Collapsible host for a step's "More settings" subsection (DE-4).
class MoreSettingsPanel extends StatelessWidget {
  /// Creates the panel.
  ///
  /// [customizedCount] — number of "more" fields whose values differ
  /// from their resolved defaults. Drives the badge on the
  /// collapsed header. Pass `0` to hide the badge.
  /// [children] — the collapsible body (the rare-toggle widgets).
  /// [initiallyExpanded] — start expanded; defaults to `false` per
  /// spec ("hidden by default").
  const MoreSettingsPanel({
    super.key,
    required this.customizedCount,
    required this.children,
    this.initiallyExpanded = false,
  });

  /// Number of customized "more" fields. `0` = no badge.
  final int customizedCount;

  /// Collapsible body widgets.
  final List<Widget> children;

  /// Whether the tile starts expanded. Defaults to `false`.
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final title = customizedCount == 0
        ? l.moreSettingsHeader
        : l.moreSettingsHeaderCustomized(customizedCount);
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: customizedCount == 0
                ? null
                : theme.colorScheme.primary,
          ),
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: children,
      ),
    );
  }
}
