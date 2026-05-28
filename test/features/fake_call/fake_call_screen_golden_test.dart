/// Alchemist golden tests for [FakeCallScreen].
///
/// Seven scenarios (≥ 6 required) cover all 5 [CallStyle] variants plus
/// a dark-theme variant and an RTL locale variant, each in the incoming
/// phase.  Golden images land in
/// `test/features/fake_call/goldens/ci/<name>.png`.
///
/// Run:
///   flutter test test/features/fake_call/fake_call_screen_golden_test.dart \
///     --update-goldens   # regenerate baselines
///   flutter test test/features/fake_call/fake_call_screen_golden_test.dart
///
/// Spec reference: docs/spec/04-screens-navigation.md §Fake Call Screen
/// (lines 1044–1159).
library;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/call_style.dart';
import 'package:guardianangela/features/fake_call/fake_call_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Harness helpers
// ---------------------------------------------------------------------------

/// Canonical light [ThemeData] matching the app shell.
ThemeData _lightTheme() => ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
  useMaterial3: true,
);

/// Canonical dark [ThemeData] matching the app shell.
ThemeData _darkTheme() => ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF131118),
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
);

/// Wraps [screen] in a [ProviderScope] + [MaterialApp] and returns the
/// result as a [Widget].
///
/// Used inside [FutureBuilder.builder] in each [GoldenTestScenario] child
/// following the pattern established in [OnboardingScreen] golden tests.
///
/// [locale] defaults to `Locale('en')`.
/// [themeMode] defaults to [ThemeMode.light].
Widget _buildHarness(
  Widget screen, {
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) => ProviderScope(
  child: MaterialApp(
    locale: locale,
    localizationsDelegates: const <LocalizationsDelegate<Object>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    themeMode: themeMode,
    theme: _lightTheme(),
    darkTheme: _darkTheme(),
    home: screen,
  ),
);

/// Phone-sized tight constraint applied to every scenario child so that
/// [Scaffold] children using [Spacer] lay out correctly inside alchemist's
/// unconstrained [Table].
const BoxConstraints _kPhone = BoxConstraints(
  minWidth: 390,
  maxWidth: 390,
  minHeight: 844,
  maxHeight: 844,
);

/// Builds a [GoldenTestScenario] whose child is [screen] wrapped in the
/// canonical harness.
///
/// [name] is the scenario label rendered by alchemist.
/// [locale] and [themeMode] are forwarded to [_buildHarness].
GoldenTestScenario _scenario(
  String name,
  Widget screen, {
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) => GoldenTestScenario(
  name: name,
  child: _buildHarness(screen, locale: locale, themeMode: themeMode),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Scenario 1 — androidNative, light, incoming.
  goldenTest(
    'FakeCallScreen — androidNative light incoming',
    fileName: 'fake_call_s1_android_native_light',
    builder: () => GoldenTestGroup(
      scenarioConstraints: _kPhone,
      children: <Widget>[
        _scenario(
          'androidNative — light — incoming',
          const FakeCallScreen(
            config: FakeCallConfig(callStyle: CallStyle.androidNative),
          ),
        ),
      ],
    ),
    pumpWidget: (WidgetTester tester, Widget widget) async {
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
    },
  );

  // Scenario 2 — iosNative, light, incoming.
  goldenTest(
    'FakeCallScreen — iosNative light incoming',
    fileName: 'fake_call_s2_ios_native_light',
    builder: () => GoldenTestGroup(
      scenarioConstraints: _kPhone,
      children: <Widget>[
        _scenario(
          'iosNative — light — incoming',
          const FakeCallScreen(
            config: FakeCallConfig(callStyle: CallStyle.iosNative),
          ),
        ),
      ],
    ),
    pumpWidget: (WidgetTester tester, Widget widget) async {
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
    },
  );

  // Scenario 3 — whatsapp, light, incoming.
  goldenTest(
    'FakeCallScreen — whatsapp light incoming',
    fileName: 'fake_call_s3_whatsapp_light',
    builder: () => GoldenTestGroup(
      scenarioConstraints: _kPhone,
      children: <Widget>[
        _scenario(
          'whatsapp — light — incoming',
          const FakeCallScreen(
            config: FakeCallConfig(callStyle: CallStyle.whatsapp),
          ),
        ),
      ],
    ),
    pumpWidget: (WidgetTester tester, Widget widget) async {
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
    },
  );

  // Scenario 4 — telegram, dark, incoming.
  goldenTest(
    'FakeCallScreen — telegram dark incoming',
    fileName: 'fake_call_s4_telegram_dark',
    builder: () => GoldenTestGroup(
      scenarioConstraints: _kPhone,
      children: <Widget>[
        _scenario(
          'telegram — dark — incoming',
          const FakeCallScreen(
            config: FakeCallConfig(callStyle: CallStyle.telegram),
          ),
          themeMode: ThemeMode.dark,
        ),
      ],
    ),
    pumpWidget: (WidgetTester tester, Widget widget) async {
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
    },
  );

  // Scenario 5 — signal, dark, incoming.
  goldenTest(
    'FakeCallScreen — signal dark incoming',
    fileName: 'fake_call_s5_signal_dark',
    builder: () => GoldenTestGroup(
      scenarioConstraints: _kPhone,
      children: <Widget>[
        _scenario(
          'signal — dark — incoming',
          const FakeCallScreen(
            config: FakeCallConfig(callStyle: CallStyle.signal),
          ),
          themeMode: ThemeMode.dark,
        ),
      ],
    ),
    pumpWidget: (WidgetTester tester, Widget widget) async {
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
    },
  );

  // Scenario 6 — androidNative, RTL (Arabic locale), incoming.
  goldenTest(
    'FakeCallScreen — androidNative RTL incoming',
    fileName: 'fake_call_s6_android_native_rtl',
    builder: () => GoldenTestGroup(
      scenarioConstraints: _kPhone,
      children: <Widget>[
        _scenario(
          'androidNative — RTL (ar) — incoming',
          const FakeCallScreen(
            config: FakeCallConfig(callStyle: CallStyle.androidNative),
          ),
          locale: const Locale('ar'),
        ),
      ],
    ),
    pumpWidget: (WidgetTester tester, Widget widget) async {
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
    },
  );

  // Scenario 7 — androidNative, declineIsSafe = false, light, incoming.
  // Exercises the "Stay on alert" decline-label variant (spec 04:1074–1076).
  goldenTest(
    'FakeCallScreen — androidNative declineUnsafe light incoming',
    fileName: 'fake_call_s7_android_native_decline_unsafe_light',
    builder: () => GoldenTestGroup(
      scenarioConstraints: _kPhone,
      children: <Widget>[
        _scenario(
          'androidNative — declineUnsafe — light — incoming',
          const FakeCallScreen(
            config: FakeCallConfig(
              callStyle: CallStyle.androidNative,
              declineIsSafe: false,
            ),
          ),
        ),
      ],
    ),
    pumpWidget: (WidgetTester tester, Widget widget) async {
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
    },
  );
}
