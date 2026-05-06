/// Shared golden-test scaffolding for the alchemist-based goldens.
///
/// alchemist replaces the discontinued `golden_toolkit` package. Each
/// individual screen golden file calls [goldenTest] with a [builder]
/// that returns the widget under test wrapped via [goldenWrapper].
/// Multi-scenario and multi-device matrices are expressed via
/// alchemist's `GoldenTestGroup` + `GoldenTestScenario`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'package:guardianangela/core/theme/app_theme.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Single locale used for pragmatic goldens. Full 14-locale matrix is
/// an ongoing task (D-TEST-12).
const Locale goldenLocale = Locale('en');

/// Default golden viewport — phone-medium proxy.
const Size goldenViewport = Size(360, 640);

/// Wraps [child] in a sized box + `MaterialApp` with localization
/// delegates + the supplied theme, and hosts it under a `ProviderScope`
/// with [overrides].
///
/// The outer `SizedBox` is required because alchemist's `goldenTest`
/// composes the builder result inside an unbounded constraint frame —
/// without an explicit size, `MaterialApp` (which expands) blows up
/// during layout.
Widget goldenWrapper({
  required Widget child,
  List<Override> overrides = const [],
  ThemeMode themeMode = ThemeMode.light,
  Size size = goldenViewport,
}) => SizedBox(
  width: size.width,
  height: size.height,
  child: ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: goldenLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: child,
    ),
  ),
);
