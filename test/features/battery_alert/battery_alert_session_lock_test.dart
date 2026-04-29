/// Coverage test for [BatteryAlertController] — exercises the
/// `SessionLockedError` guard in [save] (line 26 in the source).
///
/// The guard fires when `isSessionActive` returns true; all mutator
/// methods delegate to [save] so a single test covering it covers
/// the missing line.
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/core/utils/session_locked_error.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/battery_alert/battery_alert_controller.dart';
import 'package:guardianangela/features/session/session_controller.dart';

import '../../features/fake_repositories.dart';

// ---------------------------------------------------------------------------
// Fake active session controller
// ---------------------------------------------------------------------------

class _ActiveSessionController extends SessionController {
  @override
  Future<WalkSession?> build() async => WalkSession(
    id: 'active',
    modeId: 'mode',
    isSimulation: false,
    startedAt: DateTime.utc(2025),
    phase: const SessionPhaseActive(),
    currentStepIndex: 0,
  );

  @override
  bool get isSessionActive => true;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('BatteryAlertController.save session-lock guard', () {
    test('save throws SessionLockedError when session is active', () async {
      final repo = FakeBatteryAlertRepository();
      final container = ProviderContainer(
        overrides: [
          batteryAlertRepositoryProvider.overrideWithValue(repo),
          sessionControllerProvider.overrideWith(
            () => _ActiveSessionController(),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Hydrate the controller first.
      await container.read(batteryAlertControllerProvider.future);
      final notifier = container.read(batteryAlertControllerProvider.notifier);

      // Act: save while session is active must throw SessionLockedError.
      await check(
        notifier.save(const BatteryAlertConfig(thresholdPercent: 50)),
      ).throws<SessionLockedError>();
    });
  });
}
