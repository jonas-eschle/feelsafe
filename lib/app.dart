/// Root widget for Guardian Angela.
///
/// Wires the router, the l10n delegate, and reads settings-driven
/// configuration (theme, locale) from the `SettingsController`.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/router/app_router.dart';

/// Top-level app widget.
class GuardianAngelaApp extends ConsumerWidget {
  /// Creates the app root.
  const GuardianAngelaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'Guardian Angela',
        routerConfig: appRouter,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
      );
}
