import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/services/protocols/contact_service_protocol.dart';
import 'package:guardianangela/services/sim/contact_service_sim.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

EmergencyContact _contact({
  required String id,
  String name = 'TestContact',
  int sortOrder = 0,
  String phoneNumber = '+15550001111',
}) => EmergencyContact(
  id: id,
  name: name,
  phoneNumber: phoneNumber,
  sortOrder: sortOrder,
);

SimulationContactService _sim([List<EmergencyContact>? contacts]) =>
    SimulationContactService(contacts: contacts);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SimulationContactService', () {
    group('constructor', () {
      test('implements ContactServiceProtocol', () {
        check(_sim()).isA<ContactServiceProtocol>();
      });

      test('default constructor yields empty all list', () {
        check(_sim().all).isEmpty();
      });

      test('injected contacts are accessible via all', () {
        final c = _contact(id: 'c0');
        check(_sim([c]).all).length.equals(1);
      });
    });

    group('all getter', () {
      test('returns unmodifiable view', () {
        final s = _sim([_contact(id: 'c0')]);
        final list = s.all;
        check(
          () => (list as dynamic).add(_contact(id: 'x')),
        ).throws<Error>();
      });

      test('sorted by sortOrder ascending', () {
        final contacts = [
          _contact(id: 'c3', sortOrder: 2),
          _contact(id: 'c1'),
          _contact(id: 'c2', sortOrder: 1),
        ];
        final s = _sim(contacts);
        final sorted = s.all;
        check(sorted[0].id).equals('c1');
        check(sorted[1].id).equals('c2');
        check(sorted[2].id).equals('c3');
      });

      test('all with single contact returns one element', () {
        final c = _contact(id: 'x', sortOrder: 5);
        final s = _sim([c]);
        check(s.all).length.equals(1);
        check(s.all.first.id).equals('x');
      });

      test('all with multiple contacts returns all of them', () {
        final contacts = List.generate(
          5,
          (i) => _contact(id: 'c$i', sortOrder: i),
        );
        final s = _sim(contacts);
        check(s.all).length.equals(5);
      });
    });

    group('byId', () {
      test('returns null for unknown id', () {
        check(_sim().byId('unknown')).isNull();
      });

      test('returns null when list is empty', () {
        check(_sim().byId('c1')).isNull();
      });

      test('returns correct contact for known id', () {
        final c = _contact(id: 'c1', name: 'Alice');
        final s = _sim([c]);
        check(s.byId('c1')).isNotNull();
        check(s.byId('c1')!.name).equals('Alice');
      });

      test('returns null for non-existent id among multiple contacts', () {
        final contacts = [
          _contact(id: 'c1'),
          _contact(id: 'c2', sortOrder: 1),
        ];
        check(_sim(contacts).byId('c99')).isNull();
      });

      test('can look up every contact by id', () {
        final contacts = List.generate(
          3,
          (i) => _contact(id: 'c$i', name: 'Contact$i', sortOrder: i),
        );
        final s = _sim(contacts);
        for (final c in contacts) {
          final found = s.byId(c.id);
          check(found).isNotNull();
          check(found!.id).equals(c.id);
        }
      });

      test('byId preserves all contact fields', () {
        final c = EmergencyContact(
          id: 'x1',
          name: 'Bob',
          phoneNumber: '+49123456789',
          relationship: 'Brother',
          sortOrder: 3,
          channels: [MessageChannel.sms, MessageChannel.whatsapp],
          languageCode: 'de',
        );
        final s = _sim([c]);
        final found = s.byId('x1')!;
        check(found.name).equals('Bob');
        check(found.phoneNumber).equals('+49123456789');
        check(found.relationship).equals('Brother');
        check(found.sortOrder).equals(3);
        check(found.channels).deepEquals([
          MessageChannel.sms,
          MessageChannel.whatsapp,
        ]);
        check(found.languageCode).equals('de');
      });
    });

    group('empty service', () {
      test('all returns empty list', () {
        check(_sim().all).isEmpty();
      });

      test('byId returns null for any id', () {
        final s = _sim();
        check(s.byId('anything')).isNull();
        check(s.byId('')).isNull();
      });
    });

    group('contacts with identical sortOrder', () {
      test('all returns both contacts', () {
        final contacts = [
          _contact(id: 'c1'),
          _contact(id: 'c2'),
        ];
        check(_sim(contacts).all).length.equals(2);
      });
    });
  });
}
