/// Shared golden-test scaffolding: device matrix, theme helpers, and a
/// provider-scope wrapper used by all goldens under `test/goldens/`.
///
/// The pragmatic matrix is 3 device profiles × 2 themes. The full
/// 5-device × 14-locale matrix specified in D-TEST-12 is an ongoing
/// task: the infrastructure here is a proper subset of that matrix and
/// can be extended by adding entries to [goldenDevices] and [allLocales].
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:guardianangela/core/theme/app_theme.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Pragmatic 3-profile device matrix used by goldens.
///
/// Full 5-device matrix (D-TEST-12) also includes a small-tablet and
/// foldable; these three cover the common breakpoints.
const List<Device> goldenDevices = <Device>[
  Device(
    name: 'phone-small',
    size: Size(360, 640),
    devicePixelRatio: 2,
    textScale: 1,
  ),
  Device(
    name: 'phone-large',
    size: Size(411, 891),
    devicePixelRatio: 2.75,
    textScale: 1,
  ),
  Device(
    name: 'tablet',
    size: Size(810, 1080),
    devicePixelRatio: 2,
    textScale: 1,
  ),
];

/// Single locale used for pragmatic goldens. The full matrix covers all
/// 14 supported locales; that expansion is an ongoing task (see file
/// doc-comment).
const Locale goldenLocale = Locale('en');

/// Wraps [child] in a `MaterialApp` with localization delegates + the
/// supplied theme, and hosts it under a `ProviderScope` with [overrides].
///
/// [themeMode] selects which Guardian-Angela theme is applied (light or
/// dark). `system` is not used for goldens because the goldens always
/// pin a deterministic brightness.
Widget goldenWrapper({
  required Widget child,
  List<Override> overrides = const [],
  ThemeMode themeMode = ThemeMode.light,
}) => ProviderScope(
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
);

/// Returns a `DeviceBuilder` that renders [child] once per entry in
/// [goldenDevices] under the [themeMode] theme.
DeviceBuilder buildDevices({
  required Widget child,
  required ThemeMode themeMode,
  String scenarioName = 'default',
}) => DeviceBuilder()
  ..overrideDevicesForAllScenarios(devices: goldenDevices)
  ..addScenario(name: scenarioName, widget: child);
