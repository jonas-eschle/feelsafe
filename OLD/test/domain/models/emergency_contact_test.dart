/// Unit tests for `EmergencyContact` — fields, channel lists, JSON
/// round-trip, equality.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('EmergencyContact', () {
    test('defaults', () {
      final c = makeContact();
      check(c.name).equals('Alice');
      check(c.phoneNumber).equals('+15551234567');
      check(c.sortOrder).equals(0);
      check(c.channels).deepEquals([MessageChannel.sms]);
      check(c.relationship).isNull();
      check(c.languageCode).isNull();
    });

    test('copyWith replaces targeted field', () {
      final c = makeContact();
      final c2 = c.copyWith(phoneNumber: '+44123');
      check(c2.phoneNumber).equals('+44123');
      check(c2.name).equals(c.name);
    });

    test('copyWith replaces channels', () {
      final c = makeContact();
      final c2 = c.copyWith(
        channels: const [MessageChannel.whatsapp, MessageChannel.telegram],
      );
      check(
        c2.channels,
      ).deepEquals([MessageChannel.whatsapp, MessageChannel.telegram]);
    });

    test('JSON round-trip (minimal)', () {
      final c = makeContact();
      check(EmergencyContact.fromJson(c.toJson())).equals(c);
    });

    test('JSON round-trip (all fields)', () {
      final c = makeContact(
        channels: const [
          MessageChannel.sms,
          MessageChannel.whatsapp,
          MessageChannel.telegram,
          MessageChannel.phoneCall,
        ],
      ).copyWith(relationship: 'Mom', languageCode: 'de', sortOrder: 3);
      check(EmergencyContact.fromJson(c.toJson())).equals(c);
    });

    test('JSON round-trip with null optional fields', () {
      const c = EmergencyContact(
        id: 'c1',
        name: 'X',
        phoneNumber: '+1',
        sortOrder: 0,
      );
      check(EmergencyContact.fromJson(c.toJson())).equals(c);
    });

    test('equality', () {
      final a = makeContact();
      final b = makeContact();
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });

    test('inequality when name differs', () {
      check(
        makeContact(name: 'A'),
      ).not((it) => it.equals(makeContact(name: 'B')));
    });

    test('inequality when channels differ', () {
      check(makeContact(channels: const [MessageChannel.sms])).not(
        (it) =>
            it.equals(makeContact(channels: const [MessageChannel.whatsapp])),
      );
    });

    test('channels order matters', () {
      final a = makeContact(
        channels: const [MessageChannel.sms, MessageChannel.whatsapp],
      );
      final b = makeContact(
        channels: const [MessageChannel.whatsapp, MessageChannel.sms],
      );
      check(a).not((it) => it.equals(b));
    });

    test('fromJson unknown channel throws', () {
      check(
        () => EmergencyContact.fromJson(const {
          'id': 'c',
          'name': 'X',
          'phoneNumber': '+1',
          'sortOrder': 0,
          'channels': ['bogus'],
        }),
      ).throws<ArgumentError>();
    });

    test('sortOrder preserved in round-trip', () {
      final c = makeContact(sortOrder: 42);
      check(EmergencyContact.fromJson(c.toJson()).sortOrder).equals(42);
    });

    test('relationship preserved', () {
      final c = makeContact().copyWith(relationship: 'Dad');
      check(EmergencyContact.fromJson(c.toJson()).relationship).equals('Dad');
    });

    test('languageCode preserved', () {
      final c = makeContact().copyWith(languageCode: 'ar');
      check(EmergencyContact.fromJson(c.toJson()).languageCode).equals('ar');
    });

    test('toString is informative', () {
      final c = makeContact();
      check(c.toString()).contains(c.name);
      check(c.toString()).contains(c.phoneNumber);
    });

    test('multiple channels round-trip preserves order', () {
      final c = makeContact(
        channels: const [
          MessageChannel.phoneCall,
          MessageChannel.sms,
          MessageChannel.whatsapp,
        ],
      );
      check(EmergencyContact.fromJson(c.toJson()).channels).deepEquals([
        MessageChannel.phoneCall,
        MessageChannel.sms,
        MessageChannel.whatsapp,
      ]);
    });

    test('empty channels round-trip', () {
      const c = EmergencyContact(
        id: 'c1',
        name: 'X',
        phoneNumber: '+1',
        sortOrder: 0,
        channels: [],
      );
      check(EmergencyContact.fromJson(c.toJson())).equals(c);
    });
  });
}
