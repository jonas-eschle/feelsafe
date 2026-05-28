/// Alchemist golden tests for [HomeScreen].
///
/// Six scenarios across light, dark, and RTL variants capture the
/// full visual surface of the home dashboard: empty state, populated
/// (3 modes + 3 contacts), and overflow (7 contacts → "+2" chip).
///
/// Run with `--update-goldens` on first execution to generate the
/// PNG baselines under `test/features/home/goldens/`.
library;

import 'package:flutter/material.dart';

import 'package:alchemist/alchemist.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/features/home/home_controller.dart';
import 'package:guardianangela/features/home/home_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Fake controller
// ---------------------------------------------------------------------------

class _FakeHomeController extends HomeController {
  _FakeHomeController(this._initial);

  final HomeState _initial;

  @override
  Future<HomeState> build() async => _initial;

  @override
  Future<void> selectMode(String modeId) async {}

  @override
  Future<bool> startSession({required bool simulate}) async => false;

  @override
  void clearValidationErrors() {}
}

// ---------------------------------------------------------------------------
// Test data helpers
// ---------------------------------------------------------------------------

SessionMode _mode(String id, String name) => SessionMode(
  id: id,
  name: name,
  chainSteps: <ChainStep>[
    ChainStep(
      id: '$id-step-0',
      type: ChainStepType.holdButton,
      order: 0,
      waitSeconds: 0,
      durationSeconds: 30,
      gracePeriodSeconds: 5,
      retryCount: 0,
      randomize: false,
    ),
  ],
);

EmergencyContact _contact(String id, String name) => EmergencyContact(
  id: id,
  name: name,
  phoneNumber: '+15550100',
  sortOrder: 0,
);

HomeState _state({
  List<SessionMode>? modes,
  List<EmergencyContact>? contacts,
  String? selectedModeId,
}) => HomeState(
  modes: modes ?? <SessionMode>[],
  contacts: contacts ?? <EmergencyContact>[],
  selectedModeId: selectedModeId,
);

// ---------------------------------------------------------------------------
// Scenario data sets
// ---------------------------------------------------------------------------

/// Three modes with the first selected.
final _threeModes = <SessionMode>[
  _mode('m1', 'Walk'),
  _mode('m2', 'Date'),
  _mode('m3', 'Custom'),
];

/// Three emergency contacts.
final _threeContacts = <EmergencyContact>[
  _contact('c1', 'Alice'),
  _contact('c2', 'Bob'),
  _contact('c3', 'Carol'),
];

/// Seven contacts to trigger the "+2" overflow chip (5 shown + chip).
final _sevenContacts = <EmergencyContact>[
  for (int i = 0; i < 7; i++) _contact('c$i', 'Person $i'),
];

// ---------------------------------------------------------------------------
// Widget harness
// ---------------------------------------------------------------------------

/// Mirrors [pumpScreen] from `widget_test_helpers.dart` but returns a
/// [Widget] (for use with [goldenTest]'s builder) rather than pumping.
///
/// [locale] defaults to `Locale('en')` when null; pass `Locale('ar')`
/// for RTL.
/// [themeMode] defaults to [ThemeMode.light] when null.
Widget _wrap(HomeState state, {Locale? locale, ThemeMode? themeMode}) {
  final effectiveLocale = locale ?? const Locale('en');
  final effectiveThemeMode = themeMode ?? ThemeMode.light;
  return ProviderScope(
    overrides: <Override>[
      homeControllerProvider.overrideWith(() => _FakeHomeController(state)),
    ],
    child: MaterialApp(
      locale: effectiveLocale,
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: effectiveThemeMode,
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
      home: const HomeScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Golden tests
// ---------------------------------------------------------------------------

void main() {
  goldenTest(
    'HomeScreen — variants',
    fileName: 'home_screen',
    constraints: const BoxConstraints(maxWidth: 390),
    builder: () => GoldenTestGroup(
      columns: 2,
      scenarioConstraints: const BoxConstraints(maxWidth: 390, maxHeight: 820),
      children: <Widget>[
        // Scenario 1: Light theme, empty state.
        GoldenTestScenario(name: 'light - empty state', child: _wrap(_state())),

        // Scenario 2: Light theme, 3 modes + 3 contacts, mode selected.
        GoldenTestScenario(
          name: 'light - populated',
          child: _wrap(
            _state(
              modes: _threeModes,
              contacts: _threeContacts,
              selectedModeId: 'm1',
            ),
          ),
        ),

        // Scenario 3: Dark theme, 3 modes + 3 contacts, mode selected.
        GoldenTestScenario(
          name: 'dark - populated',
          child: _wrap(
            _state(
              modes: _threeModes,
              contacts: _threeContacts,
              selectedModeId: 'm1',
            ),
            themeMode: ThemeMode.dark,
          ),
        ),

        // Scenario 4: Dark theme, 7 contacts → "+2" overflow chip.
        GoldenTestScenario(
          name: 'dark - overflow contacts',
          child: _wrap(
            _state(
              modes: _threeModes,
              contacts: _sevenContacts,
              selectedModeId: 'm2',
            ),
            themeMode: ThemeMode.dark,
          ),
        ),

        // Scenario 5: RTL (Arabic) locale, populated.
        GoldenTestScenario(
          name: 'rtl - populated',
          child: _wrap(
            _state(
              modes: _threeModes,
              contacts: _threeContacts,
              selectedModeId: 'm1',
            ),
            locale: const Locale('ar'),
          ),
        ),

        // Scenario 6: RTL (Arabic) locale, empty state.
        GoldenTestScenario(
          name: 'rtl - empty state',
          child: _wrap(_state(), locale: const Locale('ar')),
        ),
      ],
    ),
  );
}
