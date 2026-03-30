import 'package:flutter/material.dart';
import 'package:safewayhome/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/settings/settings_controller.dart';

class SafeWayHomeApp extends ConsumerWidget {
  final GoRouter router;

  const SafeWayHomeApp({
    super.key,
    required this.router,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    // Defaults while loading
    final isDark = settingsAsync.valueOrNull?.isDarkTheme ?? true;
    final langCode = settingsAsync.valueOrNull?.languageCode ?? 'en';

    return MaterialApp.router(
      title: 'SafeWayHome',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(langCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
