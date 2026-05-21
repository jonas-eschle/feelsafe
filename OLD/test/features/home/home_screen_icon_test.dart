/// Issues-v4 #12 — HomeScreen now resolves mode icons via
/// `iconForName(m.iconName) ?? _iconForModeName(m.name)`. These
/// tests verify both branches: explicit iconName wins, name
/// heuristic is the fallback.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/home/home_screen.dart';
import 'package:guardianangela/features/session/session_controller.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

class _FakeSessionController extends SessionController {
  _FakeSessionController(this._seed);
  final WalkSession? _seed;
  @override
  Future<WalkSession?> build() async => _seed;
}

SessionMode _modeWithIcon(String id, String name, String? iconName) =>
    SessionMode(id: id, name: name, iconName: iconName, chainSteps: const []);

void main() {
  testWidgets('HomeScreen renders the mode iconName when set (#12)', (
    tester,
  ) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        child: const HomeScreen(),
        overrides: [
          modesRepositoryProvider.overrideWithValue(
            FakeModesRepository([
              // 'directions_walk' is one of the curated icons in
              // mode_icon_library.dart.
              _modeWithIcon('m1', 'Anything', 'directions_walk'),
            ]),
          ),
          contactsRepositoryProvider.overrideWithValue(
            FakeContactsRepository(),
          ),
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
          sessionControllerProvider.overrideWith(
            () => _FakeSessionController(null),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    // The mode tile renders Icons.directions_walk because the mode
    // has iconName='directions_walk'. The legacy heuristic would
    // have returned Icons.tune for name='Anything'.
    check(
      find.byIcon(Icons.directions_walk).evaluate().length,
    ).isGreaterOrEqual(1);
  });

  testWidgets(
    'HomeScreen falls back to the name heuristic when iconName is null (#12)',
    (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          child: const HomeScreen(),
          overrides: [
            modesRepositoryProvider.overrideWithValue(
              FakeModesRepository([_modeWithIcon('m1', 'Run Mode', null)]),
            ),
            contactsRepositoryProvider.overrideWithValue(
              FakeContactsRepository(),
            ),
            settingsRepositoryProvider.overrideWithValue(
              FakeSettingsRepository(),
            ),
            sessionControllerProvider.overrideWith(
              () => _FakeSessionController(null),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      // No iconName -> heuristic kicks in: name contains "run" so it
      // resolves to Icons.directions_run.
      check(
        find.byIcon(Icons.directions_run).evaluate().length,
      ).isGreaterOrEqual(1);
    },
  );

  testWidgets('unknown iconName falls through to the name heuristic (#12)', (
    tester,
  ) async {
    // 'not_a_real_icon' is not in kModeIconLibrary; iconForName
    // returns null and the heuristic uses the name.
    await tester.pumpWidget(
      hostScreenWithRouter(
        child: const HomeScreen(),
        overrides: [
          modesRepositoryProvider.overrideWithValue(
            FakeModesRepository([
              _modeWithIcon('m1', 'Bike Day', 'not_a_real_icon'),
            ]),
          ),
          contactsRepositoryProvider.overrideWithValue(
            FakeContactsRepository(),
          ),
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
          sessionControllerProvider.overrideWith(
            () => _FakeSessionController(null),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    // Heuristic for "bike" returns Icons.directions_bike.
    check(
      find.byIcon(Icons.directions_bike).evaluate().length,
    ).isGreaterOrEqual(1);
  });
}
