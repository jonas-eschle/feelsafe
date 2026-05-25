import 'package:flutter/material.dart';

/// Shared tappable settings row.
///
/// Renders as a `ListTile` with a leading icon, primary title, optional
/// subtitle, and a chevron trailing. Used by every settings subcategory
/// row per spec 06.
class SettingsTile extends StatelessWidget {
  /// Creates a [SettingsTile].
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
  });

  /// Leading icon.
  final IconData icon;

  /// Row title.
  final String title;

  /// Optional row subtitle (sub-label).
  final String? subtitle;

  /// Tap handler.
  final VoidCallback onTap;

  /// Optional trailing widget (defaults to chevron).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
