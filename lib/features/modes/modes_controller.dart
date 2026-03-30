import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/session_mode.dart';
import '../../data/repositories/modes_repository.dart';

final modesRepositoryProvider = Provider((_) => ModesRepository());

final modesControllerProvider =
    AsyncNotifierProvider<ModesController, List<SessionMode>>(
  ModesController.new,
);

class ModesController extends AsyncNotifier<List<SessionMode>> {
  ModesRepository get _repo => ref.read(modesRepositoryProvider);

  @override
  Future<List<SessionMode>> build() => _repo.getAll();

  Future<void> loadModes() async {
    state = const AsyncLoading();
    state = AsyncData(await _repo.getAll());
  }

  Future<void> saveMode(SessionMode mode) async {
    await _repo.save(mode);
    state = AsyncData(await _repo.getAll());
  }

  Future<void> deleteMode(String id) async {
    await _repo.delete(id);
    state = AsyncData(await _repo.getAll());
  }
}
