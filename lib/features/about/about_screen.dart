/// About / credits screen.
library;

import 'package:flutter/material.dart';

import 'package:guardianangela/core/theme/guardian_angela_logo.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// About screen.
class AboutScreen extends StatelessWidget {
  /// Creates the about screen.
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.aboutTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            const GuardianAngelaLogo(size: 120),
            const SizedBox(height: 16),
            Text(
              l.appTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('${l.aboutVersion}: 1.0.0'),
            const SizedBox(height: 24),
            Text(l.aboutCredits, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
