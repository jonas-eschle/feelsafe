import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:guardianangela/features/past_events/past_events_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Immutable state for the past-events trash screen.
@immutable
class PastEventsTrashState {
  /// Creates a [PastEventsTrashState].
  const PastEventsTrashState({required this.logs, required this.retentionDays});

  /// All trashed logs (real + simulated), most-recently trashed first.
  final List<PastEventsTrashLog> logs;

  /// Number of days a trashed log survives before being permanently
  /// purged. Sourced from `AppSettings.trashRetentionDays`.
  final int retentionDays;
}

/// A trashed log, augmented with its deletion timestamp so the screen
/// can display the remaining-restore window.
@immutable
class PastEventsTrashLog {
  /// Creates a [PastEventsTrashLog].
  const PastEventsTrashLog({
    required this.id,
    required this.modeName,
    required this.startedAt,
    required this.durationSeconds,
    required this.isSimulation,
    required this.deletedAt,
  });

  /// Session log id.
  final String id;

  /// Resolved mode display name.
  final String modeName;

  /// Session start wall-clock time.
  final DateTime startedAt;

  /// Total duration in seconds.
  final int durationSeconds;

  /// Whether this was a simulation.
  final bool isSimulation;

  /// UTC timestamp when the log was moved to the trash.
  final DateTime deletedAt;
}

/// Controller for the past-events trash screen.
///
/// On every [build] the controller calls
/// [SessionLogRepository.purgeExpiredLogs] so trashed rows older than
/// `AppSettings.trashRetentionDays` are hard-deleted before the user
/// sees the list (spec 04:2458 "On screen open and again on
/// HistoryController.build, any tombstone older than 7 days is
/// hard-deleted"). Then it reads the remaining trashed rows from
/// Drift.
class PastEventsTrashController extends AsyncNotifier<PastEventsTrashState> {
  @override
  Future<PastEventsTrashState> build() async {
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    final repo = await ref.watch(sessionLogRepositoryProvider.future);
    // Step 1 — purge expired trash (and age-based non-critical logs).
    // The repository purges both in a single call; we only care about
    // the trash portion here, but the age-based purge is cheap and
    // always-correct.
    try {
      final purged = await repo.purgeExpiredLogs(
        retentionDays: settings.sessionLogRetentionDays,
        now: DateTime.now().toUtc(),
        trashRetentionDays: settings.trashRetentionDays,
      );
      if (purged > 0) {
        log(
          'trash-screen open purged $purged expired rows',
          name: 'PastEventsTrashController',
        );
      }
    } catch (e, st) {
      log(
        'trash-screen purge failed (non-fatal)',
        name: 'PastEventsTrashController',
        error: e,
        stackTrace: st,
      );
    }
    // Step 2 — load surviving trashed rows.
    final raw = await repo.getTrashed();
    final logs = <PastEventsTrashLog>[];
    for (final l in raw) {
      final ended = l.endedAt;
      final durationSeconds = ended == null
          ? 0
          : ended.difference(l.startedAt).inSeconds;
      // deletedAt is required by getTrashed (the DAO filters on it),
      // so a null here is a bug.
      assert(
        l.deletedAt != null,
        'getTrashed returned a row without deletedAt',
      );
      logs.add(
        PastEventsTrashLog(
          id: l.id,
          modeName: l.modeName,
          startedAt: l.startedAt,
          durationSeconds: durationSeconds,
          isSimulation: l.isSimulation,
          deletedAt: l.deletedAt!,
        ),
      );
    }
    return PastEventsTrashState(
      logs: logs,
      retentionDays: settings.trashRetentionDays,
    );
  }

  /// Restores the trashed log with [id] back into the live list.
  ///
  /// Invalidates both this controller and the past-events list
  /// controller so both screens re-read from Drift.
  Future<void> restore(String id) async {
    final repo = await ref.read(sessionLogRepositoryProvider.future);
    await repo.restore(id);
    ref.invalidate(pastEventsControllerProvider);
    ref.invalidateSelf();
  }

  /// Hard-deletes the trashed log with [id], bypassing the
  /// retention timer.
  Future<void> deletePermanently(String id) async {
    final repo = await ref.read(sessionLogRepositoryProvider.future);
    await repo.deleteById(id);
    ref.invalidateSelf();
  }

  /// Hard-deletes every trashed row at once (spec 04 §Past Events
  /// Trash — Empty trash action). Returns the count of rows purged.
  Future<int> emptyTrash() async {
    final repo = await ref.read(sessionLogRepositoryProvider.future);
    final count = await repo.hardDeleteAllTrashed();
    ref.invalidateSelf();
    return count;
  }
}

/// Provides [PastEventsTrashController].
final pastEventsTrashControllerProvider =
    AsyncNotifierProvider<PastEventsTrashController, PastEventsTrashState>(
      PastEventsTrashController.new,
    );
