import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:guardianangela/services/service_providers.dart';

/// Immutable state for the history retention screen.
@immutable
class HistoryRetentionState {
  /// Creates a [HistoryRetentionState].
  const HistoryRetentionState({
    required this.sessionLogRetentionDays,
    required this.trashRetentionDays,
  });

  /// Days after which a non-critical log moves to trash (1–365).
  final int sessionLogRetentionDays;

  /// Days after which a trashed log is permanently deleted (1–90).
  final int trashRetentionDays;
}

/// Controller for the history retention screen.
class HistoryRetentionController extends AsyncNotifier<HistoryRetentionState> {
  @override
  Future<HistoryRetentionState> build() async {
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    return HistoryRetentionState(
      sessionLogRetentionDays: settings.sessionLogRetentionDays,
      trashRetentionDays: settings.trashRetentionDays,
    );
  }

  /// Persists [days] as the session log retention.
  Future<void> setSessionLogRetention(int days) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(settings.copyWith(sessionLogRetentionDays: days));
    ref.invalidateSelf();
  }

  /// Persists [days] as the trash retention.
  Future<void> setTrashRetention(int days) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    await repo.save(settings.copyWith(trashRetentionDays: days));
    ref.invalidateSelf();
  }
}

/// Provides [HistoryRetentionController].
final historyRetentionControllerProvider =
    AsyncNotifierProvider<HistoryRetentionController, HistoryRetentionState>(
      HistoryRetentionController.new,
    );
