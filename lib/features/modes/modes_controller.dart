/// Modes-feature controller stub.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/domain/models/models.dart';

/// Stub AsyncNotifier exposing the list of session modes.
class ModesController extends AsyncNotifier<List<SessionMode>> {
  @override
  Future<List<SessionMode>> build() async => const <SessionMode>[];
}

/// Provider for `ModesController`.
final AsyncNotifierProvider<ModesController, List<SessionMode>>
    modesControllerProvider =
    AsyncNotifierProvider<ModesController, List<SessionMode>>(
  ModesController.new,
);
