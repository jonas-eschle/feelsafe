import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/reminder_template.dart';
import '../../data/repositories/templates_repository.dart';

final templatesRepositoryProvider = Provider((_) => TemplatesRepository());

final templatesControllerProvider =
    AsyncNotifierProvider<TemplatesController, List<ReminderTemplate>>(
  TemplatesController.new,
);

class TemplatesController extends AsyncNotifier<List<ReminderTemplate>> {
  TemplatesRepository get _repo => ref.read(templatesRepositoryProvider);

  @override
  Future<List<ReminderTemplate>> build() => _repo.getAll();

  Future<void> saveTemplate(ReminderTemplate template) async {
    await _repo.save(template);
    state = AsyncData(await _repo.getAll());
  }

  Future<void> deleteTemplate(String id) async {
    await _repo.delete(id);
    state = AsyncData(await _repo.getAll());
  }
}
