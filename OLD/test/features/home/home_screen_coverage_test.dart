/// Home-screen coverage filler: targets the onPressed / onTap
/// closures that the extended tests don't click through:
///   * Settings IconButton push (line 64).
///   * AsyncError state rendering (line 70).
///   * Active-session Card onTap + FilledButton Resume tap.
///   * Start-session button onPressed when mode is present.
///   * Shortcut (OutlinedButton) onPressed navigating to routes.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/data/repositories/modes_repository.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/home/home_screen.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';

class _ThrowingModes extends ModesRepository {
  _ThrowingModes() : super.forTesting();
  @override
  Future<List<SessionMode>> getAll() async {
    throw StateError('modes-boom');
  }
}

class _FakeSessionController extends SessionController {
  _FakeSessionController(this._seed);
  final WalkSession? _seed;
  final List<String> startCalls = <String>[];
  @override
  Future<WalkSession?> build() async => _seed;
  @override
  Future<void> startSession({
    required String modeId,
    bool isSimulation = false,
  }) async {
    startCalls.add('$modeId:$isSimulation');
  }
}

WalkSession _activeSession() => WalkSession(
  id: 'session-1',
  modeId: 'mode-x',
  isSimulation: false,
  startedAt: DateTime.utc(2025),
  phase: const SessionPhaseActive(),
  currentStepType: ChainStepType.holdButton,
);

Widget _host(Widget child, {List<Override> overrides = const []}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (c, s) => child),
      GoRoute(path: '/settings', builder: (c, s) =>
          const Scaffold(key: Key('/settings'), body: SizedBox())),
      GoRoute(path: '/session', builder: (c, s) =>
          const Scaffold(key: Key('/session'), body: SizedBox())),
      GoRoute(path: '/contacts', builder: (c, s) =>
          const Scaffold(key: Key('/contacts'), body: SizedBox())),
      GoRoute(path: '/modes', builder: (c, s) =>
          const Scaffold(key: Key('/modes'), body: SizedBox())),
      GoRoute(path: '/past-events', builder: (c, s) =>
          const Scaffold(key: Key('/past-events'), body: SizedBox())),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets('HomeScreen settings IconButton pushes /settings',
      (tester) async {
    await tester.pumpWidget(_host(
      const HomeScreen(),
      overrides: [
        modesRepositoryProvider.overrideWithValue(FakeModesRepository()),
        contactsRepositoryProvider
            .overrideWithValue(FakeContactsRepository()),
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      ],
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    check(find.byKey(const Key('/settings')).evaluate().length).equals(1);
  });

  testWidgets('HomeScreen error state renders the error text',
      (tester) async {
    await tester.pumpWidget(_host(
      const HomeScreen(),
      overrides: [
        modesRepositoryProvider.overrideWithValue(_ThrowingModes()),
        contactsRepositoryProvider
            .overrideWithValue(FakeContactsRepository()),
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      ],
    ));
    await tester.pumpAndSettle();
    check(find.textContaining('modes-boom').evaluate().length)
        .isGreaterOrEqual(1);
  });

  testWidgets('HomeScreen active-session card onTap navigates to /session',
      (tester) async {
    await tester.pumpWidget(_host(
      const HomeScreen(),
      overrides: [
        modesRepositoryProvider.overrideWithValue(
          FakeModesRepository([makeMode(id: 'm')]),
        ),
        contactsRepositoryProvider
            .overrideWithValue(FakeContactsRepository()),
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
        sessionControllerProvider.overrideWith(
          () => _FakeSessionController(_activeSession()),
        ),
      ],
    ));
    await tester.pumpAndSettle();
    // Tap the Card's ListTile (active session). The mode-icon
    // fallback also uses `Icons.shield`, so tap the FIRST shield
    // (the active-session card renders before the mode tiles).
    await tester.tap(find.byIcon(Icons.shield).first);
    await tester.pumpAndSettle();
    check(find.byKey(const Key('/session')).evaluate().length).equals(1);
  });

  testWidgets(
    'HomeScreen Resume button navigates to /session',
    (tester) async {
      await tester.pumpWidget(_host(
        const HomeScreen(),
        overrides: [
          modesRepositoryProvider.overrideWithValue(
            FakeModesRepository([makeMode(id: 'm')]),
          ),
          contactsRepositoryProvider
              .overrideWithValue(FakeContactsRepository()),
          settingsRepositoryProvider
              .overrideWithValue(FakeSettingsRepository()),
          sessionControllerProvider.overrideWith(
            () => _FakeSessionController(_activeSession()),
          ),
        ],
      ));
      await tester.pumpAndSettle();
      // The Resume button is the FilledButton inside the Card's
      // trailing slot; tapping it pushes /session.
      await tester.tap(find.widgetWithText(FilledButton, 'Resume'));
      await tester.pumpAndSettle();
      check(find.byKey(const Key('/session')).evaluate().length).equals(1);
    },
  );

  testWidgets(
    'HomeScreen Start button shows confirmation; confirm fires startSession',
    (tester) async {
      // Spec 04 §Selected Mode Card: tapping the primary Start
      // button on the selected-mode card opens an AlertDialog. Only
      // confirming the dialog fires startSession + navigates.
      final ctrl = _FakeSessionController(null);
      await tester.pumpWidget(_host(
        const HomeScreen(),
        overrides: [
          modesRepositoryProvider.overrideWithValue(
            FakeModesRepository([makeMode(id: 'alpha')]),
          ),
          contactsRepositoryProvider
              .overrideWithValue(FakeContactsRepository()),
          settingsRepositoryProvider
              .overrideWithValue(FakeSettingsRepository()),
          sessionControllerProvider.overrideWith(() => ctrl),
        ],
      ));
      await tester.pumpAndSettle();
      // Tap the primary Start button on the selected-mode card.
      await tester.tap(
        find.widgetWithIcon(FilledButton, Icons.play_arrow),
      );
      await tester.pumpAndSettle();
      // Confirmation dialog must be visible.
      final l = AppLocalizations.of(
        tester.element(find.byType(Scaffold).first),
      );
      check(find.text(l.homeStartConfirmTitle).evaluate()).isNotEmpty();
      // Tap "Start session" in the dialog. Two FilledButtons match
      // the homeStartSession text — the original Start button on the
      // home card AND the confirm button in the dialog. The dialog
      // appears last in the widget tree, so `.last` targets it.
      await tester.tap(
        find.widgetWithText(FilledButton, l.homeStartSession).last,
      );
      await tester.pumpAndSettle();
      check(ctrl.startCalls).deepEquals(['alpha:false']);
      check(find.byKey(const Key('/session')).evaluate().length).equals(1);
    },
  );

  testWidgets(
    'HomeScreen tapping a mode tile only selects it (no startSession)',
    (tester) async {
      // Spec 04 §Mode Tiles: tap-to-select replaces the previous
      // tap-to-start. The tile sets selectedModeId; Start/Simulate
      // buttons below the chain preview start the session.
      final ctrl = _FakeSessionController(null);
      final settings = FakeSettingsRepository();
      await tester.pumpWidget(_host(
        const HomeScreen(),
        overrides: [
          modesRepositoryProvider.overrideWithValue(
            FakeModesRepository([
              makeMode(id: 'one', name: 'Walk'),
              makeMode(id: 'two', name: 'Date'),
            ]),
          ),
          contactsRepositoryProvider
              .overrideWithValue(FakeContactsRepository()),
          settingsRepositoryProvider.overrideWithValue(settings),
          sessionControllerProvider.overrideWith(() => ctrl),
        ],
      ));
      await tester.pumpAndSettle();
      // Tap the Date tile (Icons.favorite per _iconForModeName).
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();
      // Selection persisted, but no session was started.
      check(settings.stored?.selectedModeId).equals('two');
      check(ctrl.startCalls).isEmpty();
    },
  );

  testWidgets(
    'HomeScreen OutlinedButton shortcut navigates',
    (tester) async {
      await tester.pumpWidget(_host(
        const HomeScreen(),
        overrides: [
          modesRepositoryProvider.overrideWithValue(FakeModesRepository()),
          contactsRepositoryProvider
              .overrideWithValue(FakeContactsRepository()),
          settingsRepositoryProvider
              .overrideWithValue(FakeSettingsRepository()),
        ],
      ));
      await tester.pumpAndSettle();
      // Tap the first OutlinedButton shortcut (Contacts).
      final contactsBtn = find.descendant(
        of: find.byType(HomeScreen),
        matching: find.byIcon(Icons.contacts),
      );
      await tester.tap(contactsBtn);
      await tester.pumpAndSettle();
      check(find.byKey(const Key('/contacts')).evaluate().length).equals(1);
    },
  );

  // Touch the RouteNames import so the analyzer doesn't flag it.
  test('RouteNames constants exist', () {
    check(RouteNames.settings).equals('/settings');
  });
}
