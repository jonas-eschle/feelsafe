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

/// Hosts [child] on top of a throwaway root so `context.pop()` has
/// somewhere to return to. Use this for tests that invoke a screen's
/// save-and-pop flow.
///
/// [overrides] are forwarded to the outer `ProviderScope`.
/// [initialQuery] appends `?<query>` to the push target so the
/// hosted screen can read `GoRouterState` query parameters.
Widget hostScreenPushed({
  required Widget child,
  List<Override> overrides = const [],
  String initialQuery = '',
}) {
  final route = '/screen${initialQuery.isEmpty ? '' : '?$initialQuery'}';
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => _PushRoot(target: route),
      ),
      GoRoute(
        path: '/screen',
        builder: (context, state) => child,
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

class _PushRoot extends StatefulWidget {
  const _PushRoot({required this.target});
  final String target;

  @override
  State<_PushRoot> createState() => _PushRootState();
}

class _PushRootState extends State<_PushRoot> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) GoRouter.of(context).push(widget.target);
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox());
}
