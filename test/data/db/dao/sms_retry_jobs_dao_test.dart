import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/db/dao/sms_retry_jobs_dao.dart';
import 'package:guardianangela/data/db/database.dart';

void main() {
  late GuardianAngelaDatabase db;
  final t0 = DateTime.utc(2026, 5, 23, 14);

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
  });

  tearDown(() async {
    await db.close();
  });

  group('SmsRetryJobsDao', () {
    test('getAll returns empty on a fresh database', () async {
      check(await db.smsRetryJobsDao.getAll()).isEmpty();
    });

    test('round-trips a job with all optional fields populated', () async {
      // Arrange
      final job = SmsRetryJob(
        workId: 'work-1',
        contactId: 'alice-1',
        phoneNumber: '+15551112222',
        message: 'Help — last seen at 37.7,-122.4',
        attemptCount: 2,
        enqueuedAt: t0,
        lastError: 'No service',
      );
      // Act
      await db.smsRetryJobsDao.upsert(job);
      final fetched = await db.smsRetryJobsDao.getByWorkId('work-1');
      // Assert
      check(fetched).isNotNull().equals(job);
    });

    test('round-trips a job with null contactId and lastError', () async {
      // Arrange — ad-hoc message (no contact, first attempt).
      final job = SmsRetryJob(
        workId: 'work-adhoc',
        phoneNumber: '+15559999999',
        message: 'hi',
        attemptCount: 0,
        enqueuedAt: t0,
      );
      // Act
      await db.smsRetryJobsDao.upsert(job);
      final fetched = await db.smsRetryJobsDao.getByWorkId('work-adhoc');
      // Assert
      check(fetched).isNotNull().equals(job);
    });

    test('getAllWorkIds returns ids oldest first', () async {
      // Arrange — insert in reverse order.
      await db.smsRetryJobsDao.upsert(
        SmsRetryJob(
          workId: 'work-c',
          phoneNumber: '+1',
          message: 'c',
          attemptCount: 0,
          enqueuedAt: t0.add(const Duration(seconds: 30)),
        ),
      );
      await db.smsRetryJobsDao.upsert(
        SmsRetryJob(
          workId: 'work-a',
          phoneNumber: '+1',
          message: 'a',
          attemptCount: 0,
          enqueuedAt: t0,
        ),
      );
      await db.smsRetryJobsDao.upsert(
        SmsRetryJob(
          workId: 'work-b',
          phoneNumber: '+1',
          message: 'b',
          attemptCount: 0,
          enqueuedAt: t0.add(const Duration(seconds: 15)),
        ),
      );
      // Act
      final ids = await db.smsRetryJobsDao.getAllWorkIds();
      // Assert
      check(ids).deepEquals(['work-a', 'work-b', 'work-c']);
    });

    test('deleteByWorkId removes a single job', () async {
      // Arrange
      await db.smsRetryJobsDao.upsert(
        SmsRetryJob(
          workId: 'work-1',
          phoneNumber: '+1',
          message: '1',
          attemptCount: 0,
          enqueuedAt: t0,
        ),
      );
      await db.smsRetryJobsDao.upsert(
        SmsRetryJob(
          workId: 'work-2',
          phoneNumber: '+1',
          message: '2',
          attemptCount: 0,
          enqueuedAt: t0,
        ),
      );
      // Act
      await db.smsRetryJobsDao.deleteByWorkId('work-1');
      // Assert
      check(await db.smsRetryJobsDao.getByWorkId('work-1')).isNull();
      check(await db.smsRetryJobsDao.getByWorkId('work-2')).isNotNull();
    });

    test('deleteByWorkId is a no-op on an unknown id', () async {
      // Act + Assert (no throw).
      await db.smsRetryJobsDao.deleteByWorkId('missing');
    });

    test('upsert replaces an existing job with the same workId', () async {
      // Arrange
      await db.smsRetryJobsDao.upsert(
        SmsRetryJob(
          workId: 'work-1',
          phoneNumber: '+1',
          message: '1',
          attemptCount: 0,
          enqueuedAt: t0,
        ),
      );
      // Act
      await db.smsRetryJobsDao.upsert(
        SmsRetryJob(
          workId: 'work-1',
          phoneNumber: '+1',
          message: '1',
          attemptCount: 3,
          enqueuedAt: t0,
          lastError: 'No service',
        ),
      );
      // Assert
      final fetched = await db.smsRetryJobsDao.getByWorkId('work-1');
      check(fetched).isNotNull();
      check(fetched!.attemptCount).equals(3);
      check(fetched.lastError).equals('No service');
    });

    test('watchAll emits the current list oldest first', () async {
      // Arrange
      await db.smsRetryJobsDao.upsert(
        SmsRetryJob(
          workId: 'work-1',
          phoneNumber: '+1',
          message: '1',
          attemptCount: 0,
          enqueuedAt: t0,
        ),
      );
      // Act
      final first = await db.smsRetryJobsDao.watchAll().first;
      // Assert
      check(first.length).equals(1);
      check(first.single.workId).equals('work-1');
    });
  });
}
