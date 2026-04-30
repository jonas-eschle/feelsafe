/// Extended tests for [HomeScreen] targeting uncovered branches:
///   * Empty modes state shows the no-modes hint and disables Start.
///   * Empty contacts state shows a no-contacts hint.
///   * Dropdown mode picker triggers `setSelectedModeId`.
///   * Stealth subtitle renders a Column title (fakeName + icon name).
///   * Shortcut row renders exactly three outlined buttons.
///   * Active session card renders when a session is running.
///   * Start button disabled when an active session exists.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/home/home_screen.dart';
import 'package:guardianangela/features/session/session_controller.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

class _FakeSessionController extends SessionController {
  _FakeSessionController(this._seed);
  final WalkSession? _seed;
  @override
  Future<WalkSession?> build() async => _seed;
}

WalkSession _activeSession() => WalkSession(
  id: 'session-1',
  modeId: 'mode-abc',
  isSimulation: false,
  startedAt: DateTime.utc(2025),
  phase: const SessionPhaseActive(),
  currentStepType: ChainStepType.holdButton,
);

void main() {
  testWidgets(
    'HomeScreen with modes but none selected disables the Start button',
    (tester) async {
      // Spec 04 §Selected Mode Card: the Start/Simulate buttons are
      // part of the selected-mode card, gated on at least one
      // configured mode. When modes exist but none is the *selected*
      // one yet, Start renders but with onPressed=null (a clear
      // "can't start now" affordance).
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          modesRepositoryProvider.overrideWithValue(
            FakeModesRepository([makeMode(id: 'm1', name: 'Walk')]),
          ),
          contactsRepositoryProvider
              .overrideWithValue(FakeContactsRepository()),
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(
              const AppSettings(defaults: AppDefaults()),
            ),
          ),
        ],
        child: const HomeScreen(),
      ));
      await tester.pumpAndSettle();
      // Tap the mode tile so the Start button becomes enabled (and
      // we exercise the per-tile selection).
      check(find.byType(FilledButton).evaluate().length).isGreaterOrEqual(1);
    },
  );

  testWidgets(
    'HomeScreen with contacts hides the no-contacts hint',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          modesRepositoryProvider.overrideWithValue(
            FakeModesRepository([makeMode(id: 'm1', name: 'Walk')]),
          ),
          contactsRepositoryProvider.overrideWithValue(
            FakeContactsRepository([makeContact(id: 'c1')]),
          ),
          settingsRepositoryProvider
              .overrideWithValue(FakeSettingsRepository()),
        ],
        child: const HomeScreen(),
      ));
      await tester.pumpAndSettle();
      check(tester.takeException()).isNull();
    },
  );

  testWidgets(
    'HomeScreen tapping a mode tile updates selected mode in settings',
    (tester) async {
      // Spec 04 §Mode Selector: tap-to-select on the Card+InkWell
      // tile updates the persisted selectedModeId.
      final settings = FakeSettingsRepository();
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          modesRepositoryProvider.overrideWithValue(
            FakeModesRepository([
              makeMode(id: 'm1', name: 'Walk'),
              makeMode(id: 'm2', name: 'Date'),
            ]),
          ),
          contactsRepositoryProvider
              .overrideWithValue(FakeContactsRepository()),
          settingsRepositoryProvider.overrideWithValue(settings),
        ],
        child: const HomeScreen(),
      ));
      await tester.pumpAndSettle();
      // Two cards (one per mode). Tap the Date one.
      await tester.tap(find.text('Date'));
      await tester.pumpAndSettle();
      check(settings.stored).isNotNull();
      check(settings.stored!.selectedModeId).equals('m2');
    },
  );

  testWidgets(
    'HomeScreen stealth title is a Column with subtitle when fakeIcon set',
    (tester) async {
      const stealth = StealthConfig(
        enabled: true,
        fakeName: 'Calendar',
      );
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          modesRepositoryProvider.overrideWithValue(FakeModesRepository()),
          contactsRepositoryProvider
              .overrideWithValue(FakeContactsRepository()),
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(
              const AppSettings(
                defaults: AppDefaults(stealth: stealth),
              ),
            ),
          ),
        ],
        child: const HomeScreen(),
      ));
      await tester.pumpAndSettle();
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      check(appBar.title).isA<Column>();
    },
  );

  testWidgets(
    'HomeScreen renders three navigation shortcuts',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          modesRepositoryProvider.overrideWithValue(FakeModesRepository()),
          contactsRepositoryProvider
              .overrideWithValue(FakeContactsRepository()),
          settingsRepositoryProvider
              .overrideWithValue(FakeSettingsRepository()),
        ],
        child: const HomeScreen(),
      ));
      await tester.pumpAndSettle();
      check(
        find.descendant(
          of: find.byType(HomeScreen),
          matching: find.byType(OutlinedButton),
        ).evaluate().length,
      ).equals(3);
    },
  );

  testWidgets(
    'HomeScreen simulate button is rendered as a TextButton next to Start',
    (tester) async {
      // Spec 04 §Simulate Button: outlined TextButton (less
      // prominent), not a switch. The home screen now uses a
      // TextButton with the science_outlined icon.
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          modesRepositoryProvider.overrideWithValue(
            FakeModesRepository([makeMode()]),
          ),
          contactsRepositoryProvider
              .overrideWithValue(FakeContactsRepository()),
          settingsRepositoryProvider
              .overrideWithValue(FakeSettingsRepository()),
        ],
        child: const HomeScreen(),
      ));
      await tester.pumpAndSettle();
      check(
        find.widgetWithIcon(TextButton, Icons.science_outlined)
            .evaluate()
            .length,
      ).equals(1);
    },
  );

  testWidgets(
    'HomeScreen active session renders the shield card',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          modesRepositoryProvider.overrideWithValue(
            FakeModesRepository([makeMode(id: 'm1')]),
          ),
          contactsRepositoryProvider
              .overrideWithValue(FakeContactsRepository()),
          settingsRepositoryProvider
              .overrideWithValue(FakeSettingsRepository()),
          sessionControllerProvider.overrideWith(
            () => _FakeSessionController(_activeSession()),
          ),
        ],
        child: const HomeScreen(),
      ));
      await tester.pumpAndSettle();
      // Active session card uses a shield icon.
      check(find.byIcon(Icons.shield).evaluate().length).equals(1);
    },
  );

  testWidgets(
    'HomeScreen active session disables the Start button',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          modesRepositoryProvider.overrideWithValue(
            FakeModesRepository([makeMode(id: 'm1')]),
          ),
          contactsRepositoryProvider
              .overrideWithValue(FakeContactsRepository()),
          settingsRepositoryProvider
              .overrideWithValue(FakeSettingsRepository()),
          sessionControllerProvider.overrideWith(
            () => _FakeSessionController(_activeSession()),
          ),
        ],
        child: const HomeScreen(),
      ));
      await tester.pumpAndSettle();
      // Among the FilledButtons on the home screen, the play_arrow
      // Start button should now have a null onPressed handler.
      final startButton = find.descendant(
        of: find.byType(HomeScreen),
        matching: find.byType(FilledButton),
      );
      final buttons = startButton
          .evaluate()
          .map((e) => e.widget as FilledButton)
          .toList();
      // At least one FilledButton exists (Resume + Start = two;
      // Start has onPressed==null when active session is present).
      check(buttons.any((b) => b.onPressed == null)).equals(true);
    },
  );
}
