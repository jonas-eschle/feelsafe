/// Coverage test for [BackupController] — exercises the session-locked
/// guard in [importAll] (line 55).
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/core/utils/session_locked_error.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/backup/backup_controller.dart';
import 'package:guardianangela/features/session/session_controller.dart';

import '../../features/fake_repositories.dart';

// ---------------------------------------------------------------------------
// Fake active session controller (same pattern as other coverage tests)
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
  group('BackupController.importAll session-lock guard', () {
    test(
      'importAll throws SessionLockedError when session is active',
      () async {
        final container = ProviderContainer(
          overrides: [
            modesRepositoryProvider.overrideWithValue(FakeModesRepository()),
            contactsRepositoryProvider.overrideWithValue(
              FakeContactsRepository(),
            ),
            templatesRepositoryProvider.overrideWithValue(
              FakeTemplatesRepository(),
            ),
            settingsRepositoryProvider.overrideWithValue(
              FakeSettingsRepository(),
            ),
            userProfileRepositoryProvider.overrideWithValue(
              FakeUserProfileRepository(),
            ),
            batteryAlertRepositoryProvider.overrideWithValue(
              FakeBatteryAlertRepository(),
            ),
            sessionLogsRepositoryProvider.overrideWithValue(
              FakeSessionLogsRepository(),
            ),
            sessionControllerProvider.overrideWith(
              () => _ActiveSessionController(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container.read(backupControllerProvider.future);
        final notifier = container.read(backupControllerProvider.notifier);

        await check(
          notifier.importAll({'version': 1, 'data': {}}),
        ).throws<SessionLockedError>();
      },
    );
  });
}
