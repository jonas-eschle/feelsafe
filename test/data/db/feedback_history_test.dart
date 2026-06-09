// Coverage for the feedback-history persistence trio (spec 04 §Feedback Form):
// FeedbackHistoryDao + FeedbackHistoryRepository + the FeedbackHistory Drift
// table DSL. Driven against a real in-memory GuardianAngelaDatabase so the
// genuine SQL round-trip, the desc(createdAt) ordering, and the
// row<->model mappers all run.

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/feedback_history_repository.dart';
import 'package:guardianangela/domain/enums/feedback_type.dart';
import 'package:guardianangela/domain/models/feedback_entry.dart';

FeedbackEntry _entry({
  required String id,
  FeedbackType category = FeedbackType.bug,
  String? email,
  String message = 'Something went wrong',
  bool includeLog = false,
  required DateTime createdAt,
}) => FeedbackEntry(
  id: id,
  category: category,
  email: email,
  message: message,
  includeLog: includeLog,
  createdAt: createdAt,
);

void main() {
  late GuardianAngelaDatabase db;
  late FeedbackHistoryRepository repo;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
    repo = FeedbackHistoryRepository(db.feedbackHistoryDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('FeedbackHistoryDao', () {
    test('getAll is empty on a fresh database', () async {
      check(await db.feedbackHistoryDao.getAll()).isEmpty();
    });

    test(
      'insert + getAll round-trips every field through the mappers',
      () async {
        final created = DateTime.utc(2026, 6, 9, 12, 30);
        await db.feedbackHistoryDao.insert(
          _entry(
            id: 'fb-1',
            category: FeedbackType.feature,
            email: 'me@example.com',
            message: 'Please add dark mode',
            includeLog: true,
            createdAt: created,
          ),
        );
        final all = await db.feedbackHistoryDao.getAll();
        check(all).length.equals(1);
        final e = all.single;
        check(e.id).equals('fb-1');
        check(e.category).equals(FeedbackType.feature);
        check(e.email).equals('me@example.com');
        check(e.message).equals('Please add dark mode');
        check(e.includeLog).isTrue();
        // Drift stores DateTime as unix seconds (local on read); compare the
        // instant, not the zone/representation.
        check(e.createdAt.isAtSameMomentAs(created)).isTrue();
      },
    );

    test('a null email round-trips as null', () async {
      await db.feedbackHistoryDao.insert(
        _entry(id: 'fb-anon', createdAt: DateTime.utc(2026)),
      );
      check((await db.feedbackHistoryDao.getAll()).single.email).isNull();
    });

    test('getAll orders newest-first by createdAt', () async {
      await db.feedbackHistoryDao.insert(
        _entry(id: 'old', createdAt: DateTime.utc(2026)),
      );
      await db.feedbackHistoryDao.insert(
        _entry(id: 'new', createdAt: DateTime.utc(2026, 6)),
      );
      await db.feedbackHistoryDao.insert(
        _entry(id: 'mid', createdAt: DateTime.utc(2026, 3)),
      );
      final ids = (await db.feedbackHistoryDao.getAll())
          .map((e) => e.id)
          .toList();
      check(ids).deepEquals(['new', 'mid', 'old']);
    });

    test('deleteAll drops every row', () async {
      await db.feedbackHistoryDao.insert(
        _entry(id: 'a', createdAt: DateTime.utc(2026)),
      );
      await db.feedbackHistoryDao.insert(
        _entry(id: 'b', createdAt: DateTime.utc(2026, 2)),
      );
      await db.feedbackHistoryDao.deleteAll();
      check(await db.feedbackHistoryDao.getAll()).isEmpty();
    });

    test('each FeedbackType persists and parses back by name', () async {
      for (final t in FeedbackType.values) {
        await db.feedbackHistoryDao.insert(
          _entry(
            id: 'fb-${t.name}',
            category: t,
            createdAt: DateTime.utc(2026).add(Duration(days: t.index)),
          ),
        );
      }
      final byId = {
        for (final e in await db.feedbackHistoryDao.getAll()) e.id: e.category,
      };
      for (final t in FeedbackType.values) {
        check(byId['fb-${t.name}']).equals(t);
      }
    });
  });

  group('FeedbackHistoryRepository (thin DAO facade)', () {
    test('insert + getAll delegate to the DAO', () async {
      await repo.insert(_entry(id: 'r-1', createdAt: DateTime.utc(2026, 5, 5)));
      final all = await repo.getAll();
      check(all.single.id).equals('r-1');
    });

    test('deleteAll delegates to the DAO', () async {
      await repo.insert(_entry(id: 'r-2', createdAt: DateTime.utc(2026, 5, 5)));
      await repo.deleteAll();
      check(await repo.getAll()).isEmpty();
    });
  });

  group('FeedbackHistory table DSL', () {
    test('columns and primary key match spec 04 §Feedback Form', () {
      final table = db.feedbackHistory;
      final names = {for (final c in table.$columns) c.name};
      check(names).deepEquals({
        'id',
        'category',
        'email',
        'message',
        'include_log',
        'created_at',
      });
      // id is the sole primary key.
      check(table.$primaryKey.map((c) => c.name).toSet()).deepEquals({'id'});
      // includeLog is non-null with a default; email is nullable.
      final byName = {for (final c in table.$columns) c.name: c};
      check(byName['email']!.$nullable).isTrue();
      check(byName['include_log']!.$nullable).isFalse();
    });
  });
}
