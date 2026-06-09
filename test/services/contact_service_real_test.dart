// Host tests for the production [RealContactService] (C6 coverage push).
//
// The simulation counterpart is covered by contact_service_test.dart; this
// file drives the REAL repo-backed cache against an in-memory Drift database
// (no native channel — RealContactService is 100% host-testable). It exercises
// start() pre-warming, byId()/all() lookups, the unmodifiable-view guard, and
// stop() cache clearing.

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/services/contact_service.dart';
import 'package:guardianangela/services/protocols/contact_service_protocol.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

EmergencyContact _contact({
  required String id,
  String name = 'TestContact',
  int sortOrder = 0,
  String phoneNumber = '+15550001111',
  List<MessageChannel>? channels,
}) => EmergencyContact(
  id: id,
  name: name,
  phoneNumber: phoneNumber,
  sortOrder: sortOrder,
  channels: channels ?? const [MessageChannel.sms],
);

void main() {
  group('RealContactService', () {
    late GuardianAngelaDatabase db;
    late ContactsRepository repo;
    late RealContactService svc;

    setUp(() {
      db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
      repo = ContactsRepository(db.contactsDao);
      svc = RealContactService(repository: repo);
    });

    tearDown(() async {
      await db.close();
    });

    test('implements ContactServiceProtocol', () {
      check(svc).isA<ContactServiceProtocol>();
    });

    test('all is empty before start (no DB hit)', () {
      check(svc.all).isEmpty();
    });

    test('byId returns null before start', () {
      check(svc.byId('anything')).isNull();
    });

    test('start pre-warms the cache from the repository', () async {
      await repo.upsert(_contact(id: 'c1', name: 'Alice'));
      await repo.upsert(_contact(id: 'c2', name: 'Bob', sortOrder: 1));

      await svc.start();

      check(svc.all).length.equals(2);
    });

    test('all returns contacts ordered by sortOrder ascending', () async {
      await repo.upsert(_contact(id: 'c3', sortOrder: 2));
      await repo.upsert(_contact(id: 'c1'));
      await repo.upsert(_contact(id: 'c2', sortOrder: 1));

      await svc.start();

      check(svc.all.map((c) => c.id).toList()).deepEquals(['c1', 'c2', 'c3']);
    });

    test('all returns an unmodifiable view', () async {
      await repo.upsert(_contact(id: 'c1'));
      await svc.start();

      final list = svc.all;
      check(() => list.add(_contact(id: 'x'))).throws<Error>();
    });

    test('byId resolves a cached contact after start', () async {
      await repo.upsert(_contact(id: 'c1', name: 'Alice'));
      await svc.start();

      final found = svc.byId('c1');
      check(found).isNotNull();
      check(found!.name).equals('Alice');
    });

    test('byId preserves every contact field via the cache', () async {
      await repo.upsert(
        _contact(
          id: 'x1',
          name: 'Bob',
          phoneNumber: '+49123456789',
          channels: const [MessageChannel.sms, MessageChannel.whatsapp],
        ),
      );
      await svc.start();

      final found = svc.byId('x1')!;
      check(found.name).equals('Bob');
      check(found.phoneNumber).equals('+49123456789');
      check(
        found.channels,
      ).deepEquals([MessageChannel.sms, MessageChannel.whatsapp]);
    });

    test('byId returns null for an unknown id after start', () async {
      await repo.upsert(_contact(id: 'c1'));
      await svc.start();

      check(svc.byId('nope')).isNull();
    });

    test('start is idempotent — re-running reloads the latest data', () async {
      await repo.upsert(_contact(id: 'c1'));
      await svc.start();
      check(svc.all).length.equals(1);

      // Add a second contact and re-warm.
      await repo.upsert(_contact(id: 'c2', sortOrder: 1));
      await svc.start();
      check(svc.all).length.equals(2);
      check(svc.byId('c2')).isNotNull();
    });

    test('stop clears the cache so stale data is not retained', () async {
      await repo.upsert(_contact(id: 'c1'));
      await svc.start();
      check(svc.all).isNotEmpty();

      svc.stop();

      check(svc.all).isEmpty();
      check(svc.byId('c1')).isNull();
    });

    test('start after stop re-warms the cache', () async {
      await repo.upsert(_contact(id: 'c1'));
      await svc.start();
      svc.stop();
      check(svc.all).isEmpty();

      await svc.start();
      check(svc.all).length.equals(1);
    });

    test('start with an empty repository yields an empty cache', () async {
      await svc.start();
      check(svc.all).isEmpty();
      check(svc.byId('x')).isNull();
    });
  });
}
