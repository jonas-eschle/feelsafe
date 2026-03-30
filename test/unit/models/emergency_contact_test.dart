import 'package:flutter_test/flutter_test.dart';
import 'package:safewayhome/data/models/emergency_contact.dart';

void main() {
  group('EmergencyContact', () {
    test('creates with all fields', () {
      final contact = EmergencyContact(
        id: 'c1',
        name: 'Alice',
        phoneNumber: '+49123456',
        relationship: 'Sister',
        sortOrder: 2,
        preferredChannel: MessageChannel.whatsapp,
      );

      expect(contact.id, 'c1');
      expect(contact.name, 'Alice');
      expect(contact.phoneNumber, '+49123456');
      expect(contact.relationship, 'Sister');
      expect(contact.sortOrder, 2);
      expect(contact.preferredChannel, MessageChannel.whatsapp);
    });

    test('defaults sortOrder to 0', () {
      final contact = EmergencyContact(
        id: 'c1',
        name: 'Alice',
        phoneNumber: '+49123456',
      );
      expect(contact.sortOrder, 0);
    });

    test('defaults preferredChannel to sms', () {
      final contact = EmergencyContact(
        id: 'c1',
        name: 'Alice',
        phoneNumber: '+49123456',
      );
      expect(contact.preferredChannel, MessageChannel.sms);
    });

    test('defaults relationship to null', () {
      final contact = EmergencyContact(
        id: 'c1',
        name: 'Alice',
        phoneNumber: '+49123456',
      );
      expect(contact.relationship, isNull);
    });

    test('copyWith preserves unchanged fields', () {
      final contact = EmergencyContact(
        id: 'c1',
        name: 'Alice',
        phoneNumber: '+49123456',
        relationship: 'Friend',
        sortOrder: 3,
        preferredChannel: MessageChannel.whatsapp,
      );

      final copy = contact.copyWith(name: 'Bob');

      expect(copy.id, 'c1');
      expect(copy.name, 'Bob');
      expect(copy.phoneNumber, '+49123456');
      expect(copy.relationship, 'Friend');
      expect(copy.sortOrder, 3);
      expect(copy.preferredChannel, MessageChannel.whatsapp);
    });

    test('copyWith overrides multiple fields', () {
      final contact = EmergencyContact(
        id: 'c1',
        name: 'Alice',
        phoneNumber: '+49123456',
      );

      final copy = contact.copyWith(
        name: 'Bob',
        phoneNumber: '+49999999',
        preferredChannel: MessageChannel.whatsapp,
        sortOrder: 5,
      );

      expect(copy.id, 'c1'); // immutable
      expect(copy.name, 'Bob');
      expect(copy.phoneNumber, '+49999999');
      expect(copy.preferredChannel, MessageChannel.whatsapp);
      expect(copy.sortOrder, 5);
    });

    test('copyWith preserves id (immutable)', () {
      final contact = EmergencyContact(
        id: 'original_id',
        name: 'Alice',
        phoneNumber: '+49123456',
      );

      final copy = contact.copyWith(name: 'Changed');
      expect(copy.id, 'original_id');
    });
  });

  group('MessageChannel', () {
    test('has exactly 4 values', () {
      expect(MessageChannel.values.length, 4);
    });

    test('contains all channel types', () {
      expect(MessageChannel.values, contains(MessageChannel.sms));
      expect(MessageChannel.values, contains(MessageChannel.whatsapp));
      expect(MessageChannel.values, contains(MessageChannel.telegram));
      expect(MessageChannel.values, contains(MessageChannel.phoneCall));
    });
  });
}
