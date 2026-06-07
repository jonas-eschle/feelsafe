import 'package:flutter/material.dart';

import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Small ℹ button that opens a bottom sheet with a plain-language
/// explanation. Used for every non-trivial settings field per spec 06.
class InfoIconButton extends StatelessWidget {
  /// Creates an [InfoIconButton].
  const InfoIconButton({super.key, required this.title, required this.body});

  /// Sheet title.
  final String title;

  /// Sheet body text.
  final String body;

  Future<void> _show(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(body, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context).commonGotIt),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info_outline),
      tooltip: title,
      iconSize: 18,
      onPressed: () => _show(context),
    );
  }
}
