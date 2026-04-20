/// Tests for [StructuredLogger.enforceRetention].
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/logging/structured_logger.dart';
import 'package:guardianangela/data/repositories/session_logs_repository.dart';
import 'package:guardianangela/domain/models/session_log.dart';

void main() {
  group('StructuredLogger.enforceRetention', () {
    late _FakeLogsRepo repo;
    final now = DateTime.utc(2026, 4, 20, 12);

    setUp(() {
      repo = _FakeLogsRepo();
    });

    test('noop when retentionDays <= 0', () async {
      repo.items['log-1'] = _log(
        'log-1',
        now.subtract(const Duration(days: 100)),
      );
      final pruned = await StructuredLogger.enforceRetention(
        repo: repo,
        retentionDays: 0,
        now: now,
      );
      check(pruned).equals(0);
      check(repo.items.containsKey('log-1')).isTrue();
    });

    test('prunes logs older than retentionDays', () async {
      repo.items['old'] = _log('old', now.subtract(const Duration(days: 40)));
      repo.items['fresh'] = _log(
        'fresh',
        now.subtract(const Duration(days: 5)),
      );
      final pruned = await StructuredLogger.enforceRetention(
        repo: repo,
        retentionDays: 30,
        now: now,
      );
      check(pruned).equals(1);
      check(repo.items.containsKey('old')).isFalse();
      check(repo.items.containsKey('fresh')).isTrue();
    });

    test('keeps logs exactly at the cutoff', () async {
      repo.items['edge'] = _log('edge', now.subtract(const Duration(days: 30)));
      final pruned = await StructuredLogger.enforceRetention(
        repo: repo,
        retentionDays: 30,
        now: now,
      );
      check(pruned).equals(0);
      check(repo.items.containsKey('edge')).isTrue();
    });
  });
}

SessionLog _log(String id, DateTime startedAt) => SessionLog(
  id: id,
  modeId: 'mode-a',
  modeName: 'Walk Mode',
  startedAt: startedAt,
  isSimulation: false,
);

class _FakeLogsRepo extends SessionLogsRepository {
  _FakeLogsRepo() : super.forTesting();
  final Map<String, SessionLog> items = {};
  @override
  Future<List<SessionLog>> getAll() async => items.values.toList();
  @override
  Future<SessionLog?> getById(String id) async => items[id];
  @override
  Future<void> save(SessionLog value) async => items[value.id] = value;
  @override
  Future<void> delete(String id) async => items.remove(id);
  @override
  Future<void> deleteAll() async => items.clear();
}
