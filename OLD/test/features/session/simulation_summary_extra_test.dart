/// Supplemental tests for [SimulationSummaryScreen] covering branches
/// not exercised by the smoke tests:
///   - non-empty fired list renders a ListView (lines 29–33)
///   - Return button can be tapped (line 39)
///   - The session `?.firedStepDescriptions ?? []` null-branch (line 24)
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/session/simulation_summary_screen.dart';

import '../widget_test_helpers.dart';

// A controller that returns a session with firedStepDescriptions.
class _FiredController extends SessionController {
  _FiredController(this._session);
  final WalkSession _session;
  @override
  Future<WalkSession?> build() async => _session;
}

// A controller that returns null (no active session).
class _NullController extends SessionController {
  @override
  Future<WalkSession?> build() async => null;
}

WalkSession _sessionWith(List<SimulationDescription> fired) => WalkSession(
  id: 's1',
  modeId: 'm1',
  isSimulation: true,
  startedAt: DateTime.utc(2025),
  phase: const SessionPhaseEnded(),
  firedStepDescriptions: fired,
);

void main() {
  group('SimulationSummaryScreen — extra branches', () {
    testWidgets('non-empty fired list renders ListView items', (tester) async {
      final session = _sessionWith(const [
        SimulationDescription('simHoldButton'),
        SimulationDescription('simLoudAlarm', {'flash': false}),
      ]);
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: [
            sessionControllerProvider.overrideWith(
              () => _FiredController(session),
            ),
          ],
          child: const SimulationSummaryScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(find.byType(ListTile).evaluate().length).equals(2);
      // The CircleAvatar should show numbering.
      check(find.text('1').evaluate()).isNotEmpty();
      check(find.text('2').evaluate()).isNotEmpty();
    });

    testWidgets('return button can be tapped without exception', (
      tester,
    ) async {
      final session = _sessionWith(const [
        SimulationDescription('simHoldButton'),
      ]);
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: [
            sessionControllerProvider.overrideWith(
              () => _FiredController(session),
            ),
          ],
          child: const SimulationSummaryScreen(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
    });

    testWidgets('null session shows empty state (fallback ?? [])', (
      tester,
    ) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: [
            sessionControllerProvider.overrideWith(_NullController.new),
          ],
          child: const SimulationSummaryScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // Empty list → Center(child: Text(l.simulationSummaryEmpty)).
      check(find.byType(ListTile).evaluate()).isEmpty();
    });
  });
}
