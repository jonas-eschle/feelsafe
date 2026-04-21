/// Widget-test helpers: wrap a screen in a `MaterialApp` with the
/// app's localization delegates + provider overrides, so smoke tests
/// can pump screens that call `AppLocalizations.of(context)`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:go_router/go_router.dart';

import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Wraps [child] in a MaterialApp configured for localization and
/// a ProviderScope with the given [overrides].
Widget hostScreen({
  required Widget child,
  List<Override> overrides = const [],
}) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  ),
);

/// Hosts [child] inside a minimal `GoRouter` so screens that call
/// `GoRouterState.of(context)` or `context.go/push` can render.
///
/// [initialLocation] seeds the router at the given path (query
/// parameters are supported); defaults to `/` if omitted.
/// The router includes a `/other` catch-all route so navigation
/// callbacks don't crash the widget tree under test.
Widget hostScreenWithRouter({
  required Widget child,
  List<Override> overrides = const [],
  String initialLocation = '/',
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => child,
      ),
      GoRoute(
        path: '/other',
        builder: (context, state) => const Scaffold(body: SizedBox()),
      ),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}
