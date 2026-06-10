import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/features/home/home_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Immutable state for the modes list.
@immutable
class ModesState {
  /// Creates a [ModesState].
  const ModesState({required this.modes});

  /// Visible modes (regular only — distress modes live elsewhere).
  final List<SessionMode> modes;
}

/// Controller for the modes list (non-distress).
class ModesController extends AsyncNotifier<ModesState> {
  @override
  Future<ModesState> build() async {
    final db = await ref.watch(databaseProvider.future);
    final modes = await db.sessionModesDao.getRegularModes();
    return ModesState(modes: modes);
  }

  /// Creates a blank mode and returns its id.
  ///
  /// Invalidates the home controller for the same reason [delete] does:
  /// home is keep-alive and stays mounted beneath the modes screen, so
  /// without a rebuild its cached chip list would not show the new mode
  /// until app restart (spec 04:422-426).
  Future<String> createBlank() async {
    final db = await ref.read(databaseProvider.future);
    final id = const Uuid().v4();
    final blank = SessionMode(
      id: id,
      name: 'New mode',
      chainSteps: <ChainStep>[
        ChainStep(
          id: const Uuid().v4(),
          type: ChainStepType.holdButton,
          order: 0,
          waitSeconds: 0,
          durationSeconds: 10,
          gracePeriodSeconds: 5,
          retryCount: 0,
          randomize: false,
          config: const HoldButtonConfig(),
        ),
      ],
    );
    await db.sessionModesDao.upsert(blank);
    ref.invalidate(homeControllerProvider);
    ref.invalidateSelf();
    return id;
  }

  /// Duplicates [sourceId] and returns the new mode's id.
  ///
  /// Invalidates the home controller — see [createBlank] for why.
  Future<String> duplicate(String sourceId) async {
    final db = await ref.read(databaseProvider.future);
    final src = await db.sessionModesDao.getById(sourceId);
    if (src == null) {
      throw StateError('mode not found: $sourceId');
    }
    final newId = const Uuid().v4();
    final copy = src.copyWith(id: newId, name: 'Copy of ${src.name}');
    await db.sessionModesDao.upsert(copy);
    ref.invalidate(homeControllerProvider);
    ref.invalidateSelf();
    return newId;
  }

  /// Deletes [id] and refreshes the list.
  ///
  /// Also invalidates the home controller: home is keep-alive and stays
  /// mounted beneath the modes screen, so without this its cached state
  /// keeps the deleted mode — a stale chip list and, when [id] was the
  /// selected mode, a silently dead Start button. Rebuilding lets home's
  /// `build()` re-anchor the selection to an existing mode (spec 04
  /// §Mode Selector: "If selected mode deleted: Auto-select another
  /// mode").
  Future<void> delete(String id) async {
    final db = await ref.read(databaseProvider.future);
    await db.sessionModesDao.deleteById(id);
    ref.invalidate(homeControllerProvider);
    ref.invalidateSelf();
  }
}

/// Provides [ModesController].
final modesControllerProvider =
    AsyncNotifierProvider<ModesController, ModesState>(ModesController.new);
