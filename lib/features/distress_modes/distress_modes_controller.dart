import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Immutable state for the distress modes list.
@immutable
class DistressModesState {
  /// Creates a [DistressModesState].
  const DistressModesState({
    required this.modes,
    required this.defaultId,
    required this.referencedIds,
  });

  /// Visible distress modes.
  final List<SessionMode> modes;

  /// Id of the currently default distress mode, or null.
  final String? defaultId;

  /// Ids of distress modes that are currently referenced by at least
  /// one regular mode's `distressModeId`. Such rows cannot be deleted
  /// until the referencing modes drop the link.
  final Set<String> referencedIds;
}

/// Controller for the distress modes list.
class DistressModesController extends AsyncNotifier<DistressModesState> {
  @override
  Future<DistressModesState> build() async {
    final db = await ref.watch(databaseProvider.future);
    final modes = await db.sessionModesDao.getDistressModes();
    final all = await db.sessionModesDao.getAll();
    final referenced = <String>{
      for (final SessionMode m in all)
        if (!m.isDistressMode && m.distressModeId != null) m.distressModeId!,
    };
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    return DistressModesState(
      modes: modes,
      defaultId: settings.defaults.defaultDistressModeId,
      referencedIds: referenced,
    );
  }

  /// Creates a blank distress mode and returns its id.
  Future<String> createBlank() async {
    final db = await ref.read(databaseProvider.future);
    final id = const Uuid().v4();
    final blank = SessionMode(
      id: id,
      name: 'New distress mode',
      isDistressMode: true,
      chainSteps: <ChainStep>[
        ChainStep(
          id: const Uuid().v4(),
          type: ChainStepType.smsContact,
          order: 0,
          waitSeconds: 0,
          durationSeconds: 15,
          gracePeriodSeconds: 0,
          retryCount: 0,
          randomize: false,
          config: const SmsContactConfig(),
        ),
      ],
    );
    await db.sessionModesDao.upsert(blank);
    ref.invalidateSelf();
    return id;
  }

  /// Duplicates [sourceId]; returns the new distress mode's id.
  Future<String> duplicate(String sourceId) async {
    final db = await ref.read(databaseProvider.future);
    final src = await db.sessionModesDao.getById(sourceId);
    if (src == null) throw StateError('mode not found');
    final newId = const Uuid().v4();
    final copy = src.copyWith(
      id: newId,
      name: 'Copy of ${src.name}',
      isDistressMode: true,
    );
    await db.sessionModesDao.upsert(copy);
    ref.invalidateSelf();
    return newId;
  }

  /// Promotes [id] to be the default distress mode.
  Future<void> setDefault(String id) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final settings = await repo.load();
    final updated = settings.copyWith(
      defaults: settings.defaults.copyWith(defaultDistressModeId: id),
    );
    await repo.save(updated);
    ref.invalidateSelf();
  }

  /// Deletes [id]; refuses to delete the default, the last remaining
  /// mode, or any mode currently referenced by another regular mode.
  Future<void> delete(String id) async {
    final db = await ref.read(databaseProvider.future);
    final current = state.value;
    if (current == null) return;
    if (current.defaultId == id) return;
    if (current.modes.length <= 1) return;
    if (current.referencedIds.contains(id)) return;
    await db.sessionModesDao.deleteById(id);
    ref.invalidateSelf();
  }
}

/// Provides [DistressModesController].
final distressModesControllerProvider =
    AsyncNotifierProvider<DistressModesController, DistressModesState>(
      DistressModesController.new,
    );
