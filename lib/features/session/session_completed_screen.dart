/// Post-session success screen.
library;

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Shown after a session ends normally.
class SessionCompletedScreen extends StatelessWidget {
  /// Creates the session-completed screen.
  const SessionCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.sessionCompletedTitle)),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 96, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              l.sessionCompletedTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(l.sessionCompletedBody, textAlign: TextAlign.center),
            const Spacer(),
            FilledButton(
              onPressed: () => context.go(RouteNames.home),
              child: Text(l.sessionCompletedReturnHome),
            ),
          ],
        ),
      ),
    );
  }
}
