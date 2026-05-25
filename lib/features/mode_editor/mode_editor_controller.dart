import 'package:uuid/uuid.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';

/// Stateless service-style helper used by [ModeEditorScreen].
///
/// Riverpod 3's `AsyncNotifierProvider.family` requires the notifier to
/// be constructed with the argument up front; rather than thread that
/// through every refresh, the editor screen owns the in-memory draft
/// and uses this helper to load/save from the database.
class ModeEditorService {
  /// Creates a [ModeEditorService] bound to [db].
  const ModeEditorService(this._db);

  final GuardianAngelaDatabase _db;

  /// Returns a freshly seeded blank mode (used when [modeId] is null).
  SessionMode blankMode({bool isDistress = false}) => SessionMode(
    id: const Uuid().v4(),
    name: isDistress ? 'New distress mode' : 'New mode',
    isDistressMode: isDistress,
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

  /// Loads the mode with [id], or throws if missing.
  Future<SessionMode> load(String id) async {
    final mode = await _db.sessionModesDao.getById(id);
    if (mode == null) throw StateError('mode not found: $id');
    return mode;
  }

  /// Saves [mode].
  Future<void> save(SessionMode mode) => _db.sessionModesDao.upsert(mode);
}
