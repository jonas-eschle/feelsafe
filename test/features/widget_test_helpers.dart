/// Widget-test helpers: wrap a screen in a `MaterialApp` with the
/// app's localization delegates + provider overrides, so smoke tests
/// can pump screens that call `AppLocalizations.of(context)`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

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
