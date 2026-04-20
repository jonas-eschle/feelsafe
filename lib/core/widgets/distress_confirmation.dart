/// Countdown overlay used to confirm a distress trigger.
///
/// Shows a circular countdown with a "Cancel" button. If the user
/// does not cancel before the timer expires, [onConfirmed] fires;
/// cancel fires [onCancelled]. Stealth-aware via [stealth].
library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:guardianangela/core/theme/theme_extensions.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Countdown overlay widget.
class DistressConfirmation extends StatefulWidget {
  /// Creates a confirmation.
  const DistressConfirmation({
    super.key,
    this.countdownSeconds = 5,
    required this.onConfirmed,
    required this.onCancelled,
    this.stealth = false,
  });

  /// Number of seconds to wait before auto-confirming.
  final int countdownSeconds;

  /// Called when countdown completes.
  final VoidCallback onConfirmed;

  /// Called when the user taps cancel.
  final VoidCallback onCancelled;

  /// If true, hides distress-specific labels.
  final bool stealth;

  @override
  State<DistressConfirmation> createState() => _DistressConfirmationState();
}

class _DistressConfirmationState extends State<DistressConfirmation> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.countdownSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) {
        t.cancel();
        widget.onConfirmed();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l = AppLocalizations.of(context);
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.stealth ? l.distressCountdownStealth : l.distressCountdown,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Container(
              width: 140,
              height: 140,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.danger,
              ),
              child: Text(
                '$_remaining',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(color: colors.dangerOn),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                _timer?.cancel();
                widget.onCancelled();
              },
              child: Text(l.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
