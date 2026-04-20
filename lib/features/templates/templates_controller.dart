/// Templates-feature controller stub.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/domain/models/models.dart';

/// Stub AsyncNotifier exposing the list of reminder templates.
class TemplatesController extends AsyncNotifier<List<ReminderTemplate>> {
  @override
  Future<List<ReminderTemplate>> build() async =>
      const <ReminderTemplate>[];
}

/// Provider for `TemplatesController`.
final AsyncNotifierProvider<TemplatesController, List<ReminderTemplate>>
    templatesControllerProvider =
    AsyncNotifierProvider<TemplatesController, List<ReminderTemplate>>(
  TemplatesController.new,
);
