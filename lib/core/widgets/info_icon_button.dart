/// A small "?" icon that opens a bottom sheet explaining a field.
library;

import 'package:flutter/material.dart';

/// Info icon that shows a help bottom sheet.
class InfoIconButton extends StatelessWidget {
  /// Creates an info button.
  const InfoIconButton({super.key, required this.title, required this.body});

  /// Title of the help sheet.
  final String title;

  /// Body text of the help sheet.
  final String body;

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.help_outline),
    tooltip: title,
    onPressed: () => showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(body),
          ],
        ),
      ),
    ),
  );
}
