/// Tests for [TemplatesController] — CRUD + reload against a fake
/// templates repository.
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/templates/templates_controller.dart';

import '../fake_repositories.dart';

ReminderTemplate _template({
  String id = 't1',
  String name = 'Calendar',
  bool isGlobal = true,
}) => ReminderTemplate(
  id: id,
  name: name,
  title: 'title',
  body: 'body',
  confirmationType: ConfirmationType.dismiss,
  displayStyle: ReminderDisplayStyle.fullScreen,
  isGlobal: isGlobal,
);

ProviderContainer _makeContainer({List<ReminderTemplate> seed = const []}) {
  final repo = FakeTemplatesRepository(seed);
  return ProviderContainer(
    overrides: [templatesRepositoryProvider.overrideWithValue(repo)],
  );
}

void main() {
  group('TemplatesController.build', () {
    test('empty repo yields empty list', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final list = await container.read(templatesControllerProvider.future);
      check(list).isEmpty();
    });

    test('hydrates persisted templates', () async {
      final container = _makeContainer(
        seed: [
          _template(),
          _template(id: 't2', name: 'Other'),
        ],
      );
      addTearDown(container.dispose);
      final list = await container.read(templatesControllerProvider.future);
      check(list.length).equals(2);
    });
  });

  group('TemplatesController.save', () {
    test('inserts a new template', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(templatesControllerProvider.notifier);
      await container.read(templatesControllerProvider.future);
      await notifier.save(_template(id: 'new'));
      final list = container.read(templatesControllerProvider).value!;
      check(list.single.id).equals('new');
    });

    test('upserts existing template by id', () async {
      final container = _makeContainer(
        seed: [_template(id: 't1', name: 'old')],
      );
      addTearDown(container.dispose);
      final notifier = container.read(templatesControllerProvider.notifier);
      await container.read(templatesControllerProvider.future);
      await notifier.save(_template(id: 't1', name: 'new'));
      final list = container.read(templatesControllerProvider).value!;
      check(list.length).equals(1);
      check(list.single.name).equals('new');
    });
  });

  group('TemplatesController.delete', () {
    test('removes matching template', () async {
      final container = _makeContainer(
        seed: [
          _template(id: 'a'),
          _template(id: 'b', name: 'Other'),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(templatesControllerProvider.notifier);
      await container.read(templatesControllerProvider.future);
      await notifier.delete('a');
      final list = container.read(templatesControllerProvider).value!;
      check(list.single.id).equals('b');
    });
  });

  group('TemplatesController.reload', () {
    test('reads fresh data from repo', () async {
      final repo = FakeTemplatesRepository([_template()]);
      final container = ProviderContainer(
        overrides: [templatesRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(templatesControllerProvider.notifier);
      await container.read(templatesControllerProvider.future);
      await repo.save(_template(id: 'added'));
      await notifier.reload();
      final list = container.read(templatesControllerProvider).value!;
      check(list.length).equals(2);
    });
  });
}
