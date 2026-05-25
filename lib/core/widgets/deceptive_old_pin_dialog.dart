import 'package:flutter/material.dart';

import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Deceptive "Old PIN entered" dialog (R-42, D3).
///
/// Shown on every wrong PIN entry when
/// `AppSettings.deceptivePinDialogEnabled` is true. Both buttons close
/// the dialog without distinguishing intent — the wrong-PIN counter has
/// already been incremented by the calling site (spec 04 §DeceptiveOldPinDialog).
///
/// Spec 04 mandates `showDialog<void>(barrierDismissible: false, ...)`.
class DeceptiveOldPinDialog extends StatelessWidget {
  /// Creates a [DeceptiveOldPinDialog].
  const DeceptiveOldPinDialog({super.key});

  /// Convenience launcher used by every PIN-entry site.
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DeceptiveOldPinDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.angelaDialogTitle),
      content: Text(l10n.angelaDialogBody),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.angelaDialogCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.angelaDialogConfirm),
        ),
      ],
    );
  }
}
