/// Root widget for Guardian Angela.
///
/// Wires the router, the l10n delegate, and reads settings-driven
/// configuration (theme, locale) from the `SettingsController`.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/core/theme/app_theme.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/router/app_router.dart';

/// Top-level app widget.
class GuardianAngelaApp extends ConsumerWidget {
  /// Creates the app root.
  const GuardianAngelaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final themeMode = _resolveThemeMode(settings.value?.themeMode);
    final locale = settings.value?.languageCode;
    return MaterialApp.router(
      title: 'Guardian Angela',
      routerConfig: appRouter,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale == null ? null : Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeMode _resolveThemeMode(AppThemeMode? mode) => switch (mode) {
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.system => ThemeMode.system,
    null => ThemeMode.system,
  };
}
