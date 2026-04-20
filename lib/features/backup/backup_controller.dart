/// Backup-feature controller.
///
/// The actual import/export implementation is deferred to Phase 15;
/// today this controller carries only the public entry points used
/// by the backup screen and returns `null` to signal "no pending
/// operation".
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Async controller for the import / export backup tool.
///
/// State is `Object?` today — Phase 15 will replace it with a sealed
/// `BackupState` hierarchy (progress, error, last-export-time).
class BackupController extends AsyncNotifier<Object?> {
  @override
  Future<Object?> build() async => null;

  /// Exports every persisted entity (modes, contacts, templates,
  /// settings) as a JSON bundle. Phase 15 will define the schema.
  Future<Object?> exportAll() async {
    throw UnimplementedError(
      'BackupController.exportAll is scheduled for Phase 15.',
    );
  }

  /// Imports a previously-exported JSON bundle, replacing every
  /// persisted entity. Phase 15 will define the merge rules.
  Future<void> importAll(Object bundle) async {
    throw UnimplementedError(
      'BackupController.importAll is scheduled for Phase 15.',
    );
  }
}

/// Provider for `BackupController`.
final AsyncNotifierProvider<BackupController, Object?>
    backupControllerProvider =
    AsyncNotifierProvider<BackupController, Object?>(BackupController.new);
