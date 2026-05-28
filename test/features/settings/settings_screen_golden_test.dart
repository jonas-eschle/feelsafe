/// Alchemist golden tests for [SettingsScreen].
///
/// Six scenarios covering light/dark/RTL × default/stealth-on/active-session:
///
/// 1. Light — default settings (System theme, en locale, Stealth off).
/// 2. Light — Stealth on (subtitle shows "Stealth: ON").
/// 3. Dark — default settings (dark theme).
/// 4. Dark — active session (Redo Onboarding row disabled with tooltip).
/// 5. RTL — default settings (Arabic locale).
/// 6. RTL — Stealth on.
///
/// Golden files live at `test/goldens/goldens/ci/` via a custom
/// [filePathResolver].
///
/// Spec refs: 04 §Settings Screen (lines 1869–1974).
library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:alchemist/alchemist.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'package:guardianangela/domain/enums/app_theme_mode.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/features/settings/settings_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Fake controllers
// ---------------------------------------------------------------------------

/// Injects a canned [SettingsHubState] without touching the real repository.
class _FakeSettingsController extends SettingsController {
  _FakeSettingsController(this._initial);

  final SettingsHubState _initial;

  @override
  Future<SettingsHubState> build() async => _initial;

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {}

  @override
  Future<void> setLanguage(String code) async {}

  @override
  Future<void> resetOnboarding() async {}
}

/// Injects a canned [SessionState] representing an active session.
///
/// The [SessionController.build] normally reads the database; this fake
/// returns a pre-built [SessionState] with [SessionPhase.wait] and a
/// non-empty [activeChain], which satisfies the `sessionRunning` guard in
/// [SettingsScreen].
class _FakeActiveSessionController extends SessionController {
  @override
  Future<SessionState> build() async => SessionState(
    isSimulation: false,
    elapsedSeconds: 42,
    phase: SessionPhase.wait,
    activeChain: <ChainStep>[
      ChainStep(
        id: 'golden-step-1',
        type: ChainStepType.holdButton,
        order: 0,
        waitSeconds: 30,
        durationSeconds: 10,
        gracePeriodSeconds: 5,
        retryCount: 0,
        randomize: false,
      ),
    ],
    currentStepIndex: 0,
    missCount: 0,
    isHolding: false,
    isPaused: false,
    isDistressChain: false,
  );
}

/// Injects an idle [SessionState] (no active session).
class _FakeIdleSessionController extends SessionController {
  @override
  Future<SessionState> build() async => const SessionState.initial();
}

// ---------------------------------------------------------------------------
// State factories
// ---------------------------------------------------------------------------

SettingsHubState _state({
  AppThemeMode themeMode = AppThemeMode.system,
  String languageCode = 'en',
  bool stealthEnabled = false,
  String emergencyCallNumber = '112',
}) => SettingsHubState(
  themeMode: themeMode,
  languageCode: languageCode,
  stealthEnabled: stealthEnabled,
  emergencyCallNumber: emergencyCallNumber,
);

// ---------------------------------------------------------------------------
// Scaffold builder
// ---------------------------------------------------------------------------

/// Builds the [SettingsScreen] inside a [ProviderScope] + [MaterialApp]
/// harness compatible with the alchemist [pumpWidget] contract.
///
/// [themeMode] switches between light and dark themes. [locale] sets the
/// locale and text direction. [overrides] is forwarded to [ProviderScope].
Widget _buildHarness({
  required List<Override> overrides,
  ThemeMode themeMode = ThemeMode.light,
  Locale locale = const Locale('en'),
}) => ProviderScope(
  overrides: overrides,
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
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
      useMaterial3: true,
    ),
    darkTheme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF131118),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    ),
    home: const SettingsScreen(),
  ),
);

// ---------------------------------------------------------------------------
// Custom file-path resolver
// ---------------------------------------------------------------------------

/// Redirects CI golden files to `test/goldens/goldens/ci/` — the
/// canonical location used by the existing project golden corpus.
///
/// The test file lives at `test/features/settings/`; the corpus root is
/// two directories above at `test/goldens/goldens/ci/`.
FutureOr<String> _pathResolver(String fileName, String environmentName) =>
    '../../goldens/goldens/ci/$fileName.png';

// ---------------------------------------------------------------------------
// Golden tests
// ---------------------------------------------------------------------------

void main() {
  // Disable platform (non-CI) goldens: pixel-identical results are only
  // guaranteed in the CI (Ahem-font) configuration.
  AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(enabled: false),
      ciGoldensConfig: CiGoldensConfig(filePathResolver: _pathResolver),
    ),
    run: _declareTests,
  );
}

void _declareTests() {
  // Scenario 1 — Light, default settings ---------------------------------
  goldenTest(
    'settings screen · light · default',
    fileName: 'settings_screen_light_default',
    constraints: const BoxConstraints(maxWidth: 390, maxHeight: 844),
    builder: () => _buildHarness(
      overrides: <Override>[
        settingsControllerProvider.overrideWith(
          () => _FakeSettingsController(_state()),
        ),
        sessionControllerProvider.overrideWith(_FakeIdleSessionController.new),
      ],
    ),
  );

  // Scenario 2 — Light, Stealth on ---------------------------------------
  goldenTest(
    'settings screen · light · stealth on',
    fileName: 'settings_screen_light_stealth',
    constraints: const BoxConstraints(maxWidth: 390, maxHeight: 844),
    builder: () => _buildHarness(
      overrides: <Override>[
        settingsControllerProvider.overrideWith(
          () => _FakeSettingsController(_state(stealthEnabled: true)),
        ),
        sessionControllerProvider.overrideWith(_FakeIdleSessionController.new),
      ],
    ),
  );

  // Scenario 3 — Dark, default settings ----------------------------------
  goldenTest(
    'settings screen · dark · default',
    fileName: 'settings_screen_dark_default',
    constraints: const BoxConstraints(maxWidth: 390, maxHeight: 844),
    builder: () => _buildHarness(
      themeMode: ThemeMode.dark,
      overrides: <Override>[
        settingsControllerProvider.overrideWith(
          () => _FakeSettingsController(_state()),
        ),
        sessionControllerProvider.overrideWith(_FakeIdleSessionController.new),
      ],
    ),
  );

  // Scenario 4 — Dark, active session (Redo Onboarding disabled) ---------
  goldenTest(
    'settings screen · dark · active session',
    fileName: 'settings_screen_dark_active_session',
    constraints: const BoxConstraints(maxWidth: 390, maxHeight: 844),
    builder: () => _buildHarness(
      themeMode: ThemeMode.dark,
      overrides: <Override>[
        settingsControllerProvider.overrideWith(
          () => _FakeSettingsController(_state()),
        ),
        sessionControllerProvider.overrideWith(
          _FakeActiveSessionController.new,
        ),
      ],
    ),
  );

  // Scenario 5 — RTL (Arabic), default settings --------------------------
  goldenTest(
    'settings screen · rtl · default',
    fileName: 'settings_screen_rtl_default',
    constraints: const BoxConstraints(maxWidth: 390, maxHeight: 844),
    builder: () => _buildHarness(
      locale: const Locale('ar'),
      overrides: <Override>[
        settingsControllerProvider.overrideWith(
          () => _FakeSettingsController(_state(languageCode: 'ar')),
        ),
        sessionControllerProvider.overrideWith(_FakeIdleSessionController.new),
      ],
    ),
  );

  // Scenario 6 — RTL (Arabic), Stealth on --------------------------------
  goldenTest(
    'settings screen · rtl · stealth on',
    fileName: 'settings_screen_rtl_stealth',
    constraints: const BoxConstraints(maxWidth: 390, maxHeight: 844),
    builder: () => _buildHarness(
      locale: const Locale('ar'),
      overrides: <Override>[
        settingsControllerProvider.overrideWith(
          () => _FakeSettingsController(
            _state(languageCode: 'ar', stealthEnabled: true),
          ),
        ),
        sessionControllerProvider.overrideWith(_FakeIdleSessionController.new),
      ],
    ),
  );
}
