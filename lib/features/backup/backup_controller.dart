/// Backup-feature controller stub.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stub AsyncNotifier for the import / export backup tool.
class BackupController extends AsyncNotifier<Object?> {
  @override
  Future<Object?> build() async => null;
}

/// Provider for `BackupController`.
final AsyncNotifierProvider<BackupController, Object?>
    backupControllerProvider =
    AsyncNotifierProvider<BackupController, Object?>(BackupController.new);
