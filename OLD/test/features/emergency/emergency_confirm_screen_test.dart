/// Widget tests for [EmergencyConfirmScreen].
///
/// Spec 04 §EmergencyCallConfirmationScreen. Verifies:
/// - The countdown starts at the configured value.
/// - The emergency number appears in the title text.
/// - The "Cancel call" button is present.
/// - The countdown decrements each second (via Flutter's timer pump).
/// - Cancel with no session-end PIN calls [SessionController.disarm].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/utils/pin_result.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/emergency/emergency_confirm_screen.dart';
import 'package:guardianangela/features/session/session_controller.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Minimal [SessionController] subclass that records calls.
class _FakeSessionController extends SessionController {
  @override
  Future<WalkSession?> build() async => null;

  final List<String> calls = [];

  @override
  Future<void> disarm() async => calls.add('disarm');

  @override
  bool handlePinResult(PinResult result) {
    calls.add('pin:${result.name}');
    return result == PinResult.correct;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('EmergencyConfirmScreen renders', () {
    testWidgets('shows countdown value equal to durationSeconds', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        hostScreen(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(
              FakeSettingsRepository(),
            ),
            sessionControllerProvider.overrideWith(
              () => _FakeSessionController(),
            ),
          ],
          child: const EmergencyConfirmScreen(
            number: '112',
            durationSeconds: 8,
          ),
        ),
      );
      await tester.pump();

      // Assert — countdown shows initial value.
      check(find.text('8').evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('displays the emergency number', (tester) async {
      // Arrange
      await tester.pumpWidget(
        hostScreen(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(
              FakeSettingsRepository(),
            ),
            sessionControllerProvider.overrideWith(
              () => _FakeSessionController(),
            ),
          ],
          child: const EmergencyConfirmScreen(
            number: '999',
            durationSeconds: 5,
          ),
        ),
      );
      await tester.pump();

      // Assert — number appears in the widget tree.
      check(find.textContaining('999').evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('Cancel (call_end) button is present', (tester) async {
      // Arrange
      await tester.pumpWidget(
        hostScreen(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(
              FakeSettingsRepository(),
            ),
            sessionControllerProvider.overrideWith(
              () => _FakeSessionController(),
            ),
          ],
          child: const EmergencyConfirmScreen(
            number: '112',
            durationSeconds: 5,
          ),
        ),
      );
      await tester.pump();

      // Assert — a cancel / call-end button is visible.
      check(find.byIcon(Icons.call_end).evaluate().length).isGreaterOrEqual(1);
    });
  });

  group('EmergencyConfirmScreen countdown', () {
    testWidgets('countdown decrements by 1 after one second', (tester) async {
      // Arrange
      await tester.pumpWidget(
        hostScreen(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(
              FakeSettingsRepository(),
            ),
            sessionControllerProvider.overrideWith(
              () => _FakeSessionController(),
            ),
          ],
          child: const EmergencyConfirmScreen(
            number: '112',
            durationSeconds: 5,
          ),
        ),
      );
      await tester.pump();
      // Verify initial value.
      check(find.text('5').evaluate().length).isGreaterOrEqual(1);

      // Act — advance one second.
      await tester.pump(const Duration(seconds: 1));

      // Assert — countdown decremented.
      check(find.text('4').evaluate().length).isGreaterOrEqual(1);
    });
  });

  group('EmergencyConfirmScreen Cancel action', () {
    testWidgets('Cancel calls disarm when no session-end PIN is configured', (
      tester,
    ) async {
      // Arrange — settings with no session-end PIN hash (null).
      const settings = AppSettings(defaults: AppDefaults());
      final ctrl = _FakeSessionController();

      await tester.pumpWidget(
        hostScreen(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(
              FakeSettingsRepository(settings),
            ),
            sessionControllerProvider.overrideWith(() => ctrl),
          ],
          child: const EmergencyConfirmScreen(
            number: '112',
            durationSeconds: 5,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act — tap the Cancel button (call_end icon).
      await tester.tap(find.byIcon(Icons.call_end));
      await tester.pumpAndSettle();

      // Assert — disarm was called.
      check(ctrl.calls).contains('disarm');
    });
  });
}
