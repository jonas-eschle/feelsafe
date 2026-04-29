/// Widget tests for [SimulationAdvancedControls].
///
/// Spec 04 §SessionScreen — Simulation Advanced controls. Verifies:
/// - The ExpansionTile with "Advanced" label renders.
/// - Expanding reveals the speed slider preset chips and trigger buttons.
/// - Background-cap hint is absent when speed <= 60.
/// - The four preset chips show the correct labels.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/models/walk_session.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/session/widgets/simulation_advanced_controls.dart';
import '../widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Fake controller
// ---------------------------------------------------------------------------

/// Minimal [SessionController] subclass that exposes a recording surface
/// for simulation helper invocations.
class _FakeSessionController extends SessionController {
  @override
  Future<WalkSession?> build() async => null;

  final List<String> calls = [];

  @override
  void setSimulationSpeedMultiplier(double value) =>
      calls.add('speed:${value.round()}');

  @override
  Future<void> simulateGpsArrival() async => calls.add('gpsArrival');

  @override
  Future<void> simulateLowBattery() async => calls.add('battery');

  @override
  Future<void> triggerDistressChain({
    TriggerReason triggerReason = TriggerReason.hardwarePanic,
  }) async => calls.add('panic');
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SimulationAdvancedControls renders', () {
    testWidgets('ExpansionTile with "Advanced" title is present',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        hostScreen(
          overrides: [
            sessionControllerProvider.overrideWith(
              () => _FakeSessionController(),
            ),
          ],
          child: const SimulationAdvancedControls(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert — "Advanced" label renders.
      check(find.text('Advanced').evaluate().length).isGreaterOrEqual(1);
      check(find.byType(ExpansionTile).evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('trigger buttons are visible after expansion', (tester) async {
      // Arrange — use a large enough surface to fit all expanded children.
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        hostScreen(
          overrides: [
            sessionControllerProvider.overrideWith(
              () => _FakeSessionController(),
            ),
          ],
          child: const SingleChildScrollView(
            child: SimulationAdvancedControls(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act — expand the tile.
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Assert — trigger buttons visible.
      check(find.text('Trigger arrival').evaluate().length).isGreaterOrEqual(1);
      check(
        find.text('Trigger low battery').evaluate().length,
      ).isGreaterOrEqual(1);
      check(find.text('Trigger panic').evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('preset chips visible after expansion', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        hostScreen(
          overrides: [
            sessionControllerProvider.overrideWith(
              () => _FakeSessionController(),
            ),
          ],
          child: const SingleChildScrollView(
            child: SimulationAdvancedControls(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      // Assert — preset chip labels.
      for (final preset in kSimulationSpeedPresets) {
        final label = '${preset.round()}×';
        check(find.text(label).evaluate().length).isGreaterOrEqual(1);
      }
    });

    testWidgets('background-cap hint absent when speed is 1×', (tester) async {
      // Default state is speed = 1.0 → no background cap hint.
      await tester.pumpWidget(
        hostScreen(
          overrides: [
            sessionControllerProvider.overrideWith(
              () => _FakeSessionController(),
            ),
          ],
          child: const SimulationAdvancedControls(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      check(
        find.text('Capped at 60× in background').evaluate().length,
      ).equals(0);
    });
  });

  group('SimulationAdvancedControls trigger buttons invoke controller', () {
    Future<void> setupExpanded(
      WidgetTester tester,
      _FakeSessionController ctrl,
    ) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        hostScreen(
          overrides: [
            sessionControllerProvider.overrideWith(() => ctrl),
          ],
          child: const SingleChildScrollView(
            child: SimulationAdvancedControls(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();
    }

    testWidgets('"Trigger arrival" button calls simulateGpsArrival',
        (tester) async {
      // Arrange
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final ctrl = _FakeSessionController();
      await setupExpanded(tester, ctrl);

      // Act
      await tester.tap(find.text('Trigger arrival'));
      await tester.pumpAndSettle();

      // Assert
      check(ctrl.calls).contains('gpsArrival');
    });

    testWidgets('"Trigger low battery" button calls simulateLowBattery',
        (tester) async {
      // Arrange
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final ctrl = _FakeSessionController();
      await setupExpanded(tester, ctrl);

      // Act
      await tester.tap(find.text('Trigger low battery'));
      await tester.pumpAndSettle();

      // Assert
      check(ctrl.calls).contains('battery');
    });

    testWidgets('"Trigger panic" button calls triggerDistressChain',
        (tester) async {
      // Arrange
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final ctrl = _FakeSessionController();
      await setupExpanded(tester, ctrl);

      // Act
      await tester.tap(find.text('Trigger panic'));
      await tester.pumpAndSettle();

      // Assert
      check(ctrl.calls).contains('panic');
    });
  });
}
