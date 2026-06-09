/// Unit tests for [ModeEditorService] against the REAL in-memory Drift DB.
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Mode Editor`.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/features/mode_editor/mode_editor_controller.dart';

void main() {
  late GuardianAngelaDatabase db;
  late ModeEditorService service;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
    service = ModeEditorService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ModeEditorService.load', () {
    test('round-trips a mode persisted via save', () async {
      final SessionMode blank = service.blankMode();
      await service.save(blank);

      final SessionMode loaded = await service.load(blank.id);

      check(loaded.id).equals(blank.id);
      check(loaded.name).equals('New mode');
      check(loaded.chainSteps.length).equals(1);
    });

    test('throws StateError for an unknown id (fail loud)', () async {
      await expectLater(
        service.load('does-not-exist'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
