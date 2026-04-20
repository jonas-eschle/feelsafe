/// History-feature controller stub.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/domain/models/models.dart';

/// Stub AsyncNotifier exposing the list of persisted `SessionLog`s.
class HistoryController extends AsyncNotifier<List<SessionLog>> {
  @override
  Future<List<SessionLog>> build() async => const <SessionLog>[];
}

/// Provider for `HistoryController`.
final AsyncNotifierProvider<HistoryController, List<SessionLog>>
    historyControllerProvider =
    AsyncNotifierProvider<HistoryController, List<SessionLog>>(
  HistoryController.new,
);
