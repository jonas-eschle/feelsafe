/// Backup-feature controller.
///
/// Thin wrapper around [BackupService] — deferred to Phase 15. The
/// controller itself holds no state today; the state published to
/// consumers is the last completed-export payload, or `null` if
/// nothing has been exported in this session.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/core/utils/session_locked_error.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/backup/backup_service.dart';
import 'package:guardianangela/features/session/session_controller.dart';

/// Provider for a singleton [BackupService].
final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(
    modesRepository: ref.watch(modesRepositoryProvider),
    contactsRepository: ref.watch(contactsRepositoryProvider),
    templatesRepository: ref.watch(templatesRepositoryProvider),
    distressChainsRepository: ref.watch(distressChainsRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
    userProfileRepository: ref.watch(userProfileRepositoryProvider),
    batteryAlertRepository: ref.watch(batteryAlertRepositoryProvider),
    sessionLogsRepository: ref.watch(sessionLogsRepositoryProvider),
  ),
);

/// Async controller for the import / export backup tool.
class BackupController extends AsyncNotifier<Map<String, Object?>?> {
  @override
  Future<Map<String, Object?>?> build() async => null;

  /// Exports every persisted entity as a JSON-compatible map. When
  /// [pin] is non-empty the body is encrypted; see [BackupService].
  ///
  /// [selection] — per-element opt-out toggles (D5). Defaults to
  /// [BackupSelection.all].
  Future<Map<String, Object?>> exportAll({
    String? pin,
    BackupSelection selection = BackupSelection.all,
  }) async {
    state = const AsyncLoading<Map<String, Object?>?>();
    try {
      final service = ref.read(backupServiceProvider);
      final payload = await service.exportAll(pin: pin, selection: selection);
      state = AsyncData<Map<String, Object?>?>(payload);
      return payload;
    } catch (error, stack) {
      state = AsyncError<Map<String, Object?>?>(error, stack);
      rethrow;
    }
  }

  /// Imports a previously-exported bundle. Throws
  /// [BackupVersionError] / [BackupAuthenticationError] /
  /// [BackupFormatError] on structural problems. Also throws
  /// [SessionLockedError] when a safety session is active — import
  /// would mutate persisted state mid-session.
  Future<void> importAll(Map<String, Object?> payload, {String? pin}) async {
    final session = ref.read(sessionControllerProvider.notifier);
    if (session.isSessionActive) {
      throw SessionLockedError('import backup');
    }
    state = const AsyncLoading<Map<String, Object?>?>();
    try {
      final service = ref.read(backupServiceProvider);
      await service.importAll(payload, pin: pin);
      state = const AsyncData<Map<String, Object?>?>(null);
    } catch (error, stack) {
      state = AsyncError<Map<String, Object?>?>(error, stack);
      rethrow;
    }
  }
}

/// Provider for `BackupController`.
final AsyncNotifierProvider<BackupController, Map<String, Object?>?>
backupControllerProvider =
    AsyncNotifierProvider<BackupController, Map<String, Object?>?>(
      BackupController.new,
    );
