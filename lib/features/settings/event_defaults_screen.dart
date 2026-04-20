/// Per-step-type event defaults configuration screen.
///
/// Today this screen shows a placeholder; the full editor would
/// reuse [StepConfigForm] for each of the 9 step types — deferred
/// to Phase 12.2.
library;

import 'package:flutter/material.dart';

import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Event-defaults screen.
class EventDefaultsScreen extends StatelessWidget {
  /// Creates the event-defaults screen.
  const EventDefaultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.eventDefaultsTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.eventDefaultsBody),
            const SizedBox(height: 16),
            Text('— ${l.commonNone} —'),
          ],
        ),
      ),
    );
  }
}
