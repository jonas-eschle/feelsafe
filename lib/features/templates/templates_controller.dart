/// Templates-feature controller.
///
/// Exposes every [ReminderTemplate] in the repository (global +
/// mode-local) and mediates CRUD on the backing store.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';

/// Async controller exposing reminder templates.
class TemplatesController extends AsyncNotifier<List<ReminderTemplate>> {
  @override
  Future<List<ReminderTemplate>> build() async {
    final repo = ref.read(templatesRepositoryProvider);
    return repo.getAll();
  }

  /// Upserts [template] and refreshes [state].
  Future<void> save(ReminderTemplate template) async {
    final repo = ref.read(templatesRepositoryProvider);
    await repo.save(template);
    state = AsyncValue.data(await repo.getAll());
  }

  /// Deletes the template with [id] and refreshes [state].
  Future<void> delete(String id) async {
    final repo = ref.read(templatesRepositoryProvider);
    await repo.delete(id);
    state = AsyncValue.data(await repo.getAll());
  }

  /// Forces a reload from the repository.
  Future<void> reload() async {
    state = const AsyncValue.loading();
    final repo = ref.read(templatesRepositoryProvider);
    state = AsyncValue.data(await repo.getAll());
  }
}

/// Provider for `TemplatesController`.
final AsyncNotifierProvider<TemplatesController, List<ReminderTemplate>>
    templatesControllerProvider =
    AsyncNotifierProvider<TemplatesController, List<ReminderTemplate>>(
  TemplatesController.new,
);
