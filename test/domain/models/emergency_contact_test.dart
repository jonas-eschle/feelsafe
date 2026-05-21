// Unit tests for [EmergencyContact].
//
// Verifies constructor invariants, JSON round-trip, copyWith behaviour,
// equality / hashCode contract, and edge cases per
// docs/spec/03-data-models.md §EmergencyContact.

// Tests legitimately exercise default values for explicit defaults-
// match assertions.
// ignore_for_file: avoid_redundant_argument_values

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('EmergencyContact', () {
    group('constructor + defaults', () {
      test('default channels list is [MessageChannel.sms]', () {
        // Arrange + Act
        final c = EmergencyContact(
          id: 'c-1',
          name: 'Alice',
          phoneNumber: '+15551234567',
          sortOrder: 0,
        );

        // Assert — spec 03: channels default [MessageChannel.sms]
        check(c.channels.length).equals(1);
        check(c.channels.first).equals(MessageChannel.sms);
      });

      test('relationship defaults to null', () {
        // Arrange + Act
        final c = makeContact();

        // Assert
        check(c.relationship).isNull();
      });

      test('languageCode defaults to null (use app language)', () {
        // Arrange + Act
        final c = makeContact();

        // Assert
        check(c.languageCode).isNull();
      });

      test('all required fields stored unchanged', () {
        // Arrange + Act
        final c = EmergencyContact(
          id: 'contact-x',
          name: 'Bob',
          phoneNumber: '+447911123456',
          relationship: 'Mom',
          sortOrder: 3,
          channels: const [MessageChannel.sms, MessageChannel.whatsapp],
          languageCode: 'de',
        );

        // Assert
        check(c.id).equals('contact-x');
        check(c.name).equals('Bob');
        check(c.phoneNumber).equals('+447911123456');
        check(c.relationship).equals('Mom');
        check(c.sortOrder).equals(3);
        check(c.channels.length).equals(2);
        check(c.languageCode).equals('de');
      });

      test('accepts name up to 255 chars (boundary)', () {
        // Arrange
        final longName = 'x' * 255;

        // Act
        final c = EmergencyContact(
          id: 'id',
          name: longName,
          phoneNumber: '+15551234567',
          sortOrder: 0,
        );

        // Assert
        check(c.name).equals(longName);
      });

      test('accepts sortOrder = 0 (boundary)', () {
        // Arrange + Act
        final c = makeContact(sortOrder: 0);

        // Assert
        check(c.sortOrder).equals(0);
      });
    });

    group('JSON round-trip', () {
      test('toJson contains all required keys', () {
        // Arrange
        final c = makeContact();

        // Act
        final json = c.toJson();

        // Assert
        check(json).containsKey('id');
        check(json).containsKey('name');
        check(json).containsKey('phoneNumber');
        check(json).containsKey('sortOrder');
        check(json).containsKey('channels');
      });

      test('toJson omits null relationship', () {
        // Arrange
        final c = makeContact();

        // Act
        final json = c.toJson();

        // Assert
        check(json.containsKey('relationship')).isFalse();
      });

      test('toJson omits null languageCode', () {
        // Arrange
        final c = makeContact();

        // Act
        final json = c.toJson();

        // Assert
        check(json.containsKey('languageCode')).isFalse();
      });

      test('toJson includes non-null relationship', () {
        // Arrange
        final c = EmergencyContact(
          id: 'id',
          name: 'X',
          phoneNumber: '+15551234567',
          relationship: 'Sister',
          sortOrder: 0,
        );

        // Act
        final json = c.toJson();

        // Assert
        check(json['relationship']).equals('Sister');
      });

      test('toJson encodes channels by enum name string (not index)', () {
        // Arrange
        final c = makeContact(
          channels: const [MessageChannel.whatsapp, MessageChannel.sms],
        );

        // Act
        final json = c.toJson();

        // Assert
        final encoded = json['channels'] as List<dynamic>;
        check(encoded[0]).equals('whatsapp');
        check(encoded[1]).equals('sms');
      });

      test('fromJson(toJson) preserves equality for minimal contact', () {
        // Arrange
        final original = makeContact();

        // Act
        final restored = EmergencyContact.fromJson(original.toJson());

        // Assert
        check(restored).equals(original);
      });

      test('fromJson(toJson) preserves all non-null fields', () {
        // Arrange
        final original = EmergencyContact(
          id: 'full-id',
          name: 'Full',
          phoneNumber: '+15559999999',
          relationship: 'Friend',
          sortOrder: 5,
          channels: const [
            MessageChannel.sms,
            MessageChannel.whatsapp,
            MessageChannel.telegram,
            MessageChannel.phoneCall,
          ],
          languageCode: 'es',
        );

        // Act
        final restored = EmergencyContact.fromJson(original.toJson());

        // Assert
        check(restored).equals(original);
        check(restored.languageCode).equals('es');
        check(restored.channels.length).equals(4);
      });

      test('fromJson preserves channels list order', () {
        // Arrange
        final original = makeContact(
          channels: const [
            MessageChannel.telegram,
            MessageChannel.sms,
            MessageChannel.phoneCall,
          ],
        );

        // Act
        final restored = EmergencyContact.fromJson(original.toJson());

        // Assert
        check(restored.channels[0]).equals(MessageChannel.telegram);
        check(restored.channels[1]).equals(MessageChannel.sms);
        check(restored.channels[2]).equals(MessageChannel.phoneCall);
      });

      test('fromJson preserves nullable relationship as null', () {
        // Arrange
        final original = makeContact();

        // Act
        final restored = EmergencyContact.fromJson(original.toJson());

        // Assert
        check(restored.relationship).isNull();
      });
    });

    group('copyWith', () {
      test('with no arguments returns equal object', () {
        // Arrange
        final base = makeContact();

        // Act
        final copy = base.copyWith();

        // Assert
        check(copy).equals(base);
      });

      test('replaces id only', () {
        // Arrange
        final base = makeContact(id: 'a');

        // Act
        final next = base.copyWith(id: 'b');

        // Assert
        check(next.id).equals('b');
        check(next.name).equals(base.name);
      });

      test('replaces name', () {
        // Arrange
        final base = makeContact(name: 'Old');

        // Act
        final next = base.copyWith(name: 'New');

        // Assert
        check(next.name).equals('New');
      });

      test('replaces phoneNumber', () {
        // Arrange
        final base = makeContact();

        // Act
        final next = base.copyWith(phoneNumber: '+440000000000');

        // Assert
        check(next.phoneNumber).equals('+440000000000');
      });

      test('replaces relationship', () {
        // Arrange
        final base = makeContact();

        // Act
        final next = base.copyWith(relationship: 'Sister');

        // Assert
        check(next.relationship).equals('Sister');
      });

      test('replaces sortOrder', () {
        // Arrange
        final base = makeContact(sortOrder: 0);

        // Act
        final next = base.copyWith(sortOrder: 9);

        // Assert
        check(next.sortOrder).equals(9);
      });

      test('replaces channels list', () {
        // Arrange
        final base = makeContact();

        // Act
        final next = base.copyWith(
          channels: const [MessageChannel.whatsapp, MessageChannel.phoneCall],
        );

        // Assert
        check(next.channels.length).equals(2);
        check(next.channels.first).equals(MessageChannel.whatsapp);
      });

      test('replaces languageCode', () {
        // Arrange
        final base = makeContact();

        // Act
        final next = base.copyWith(languageCode: 'fr');

        // Assert
        check(next.languageCode).equals('fr');
      });

      test('omitting a field preserves the original value', () {
        // Arrange
        final base = makeContact(name: 'Keep');

        // Act — only change unrelated field
        final next = base.copyWith(sortOrder: 7);

        // Assert
        check(next.name).equals('Keep');
        check(next.sortOrder).equals(7);
      });
    });

    group('equality + hashCode', () {
      test('two identical contacts are equal', () {
        // Arrange + Act
        final a = makeContact();
        final b = makeContact();

        // Assert
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('equality is reflexive', () {
        // Arrange
        final c = makeContact();

        // Act + Assert
        check(c).equals(c);
      });

      test('equality is symmetric and transitive', () {
        // Arrange
        final a = makeContact(id: 'eq');
        final b = makeContact(id: 'eq');
        final c = makeContact(id: 'eq');

        // Assert
        check(a == b).isTrue();
        check(b == a).isTrue();
        check(b == c).isTrue();
        check(a == c).isTrue();
      });

      test('different id breaks equality', () {
        // Arrange + Act
        final a = makeContact(id: 'a');
        final b = makeContact(id: 'b');

        // Assert
        check(a == b).isFalse();
      });

      test('different name breaks equality', () {
        // Arrange + Act
        final a = makeContact(name: 'A');
        final b = makeContact(name: 'B');

        // Assert
        check(a == b).isFalse();
      });

      test('different phoneNumber breaks equality', () {
        // Arrange + Act
        final a = makeContact(phoneNumber: '+11111111111');
        final b = makeContact(phoneNumber: '+22222222222');

        // Assert
        check(a == b).isFalse();
      });

      test('different sortOrder breaks equality', () {
        // Arrange + Act
        final a = makeContact(sortOrder: 0);
        final b = makeContact(sortOrder: 1);

        // Assert
        check(a == b).isFalse();
      });

      test('different channels list breaks equality', () {
        // Arrange + Act
        final a = makeContact(channels: const [MessageChannel.sms]);
        final b = makeContact(channels: const [MessageChannel.whatsapp]);

        // Assert
        check(a == b).isFalse();
      });

      test('different channels length breaks equality', () {
        // Arrange + Act
        final a = makeContact(channels: const [MessageChannel.sms]);
        final b = makeContact(
          channels: const [MessageChannel.sms, MessageChannel.whatsapp],
        );

        // Assert
        check(a == b).isFalse();
      });

      test('different relationship breaks equality', () {
        // Arrange
        final a = EmergencyContact(
          id: 'id',
          name: 'X',
          phoneNumber: '+15551234567',
          relationship: 'Mom',
          sortOrder: 0,
        );
        final b = EmergencyContact(
          id: 'id',
          name: 'X',
          phoneNumber: '+15551234567',
          relationship: 'Dad',
          sortOrder: 0,
        );

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different languageCode breaks equality', () {
        // Arrange + Act
        final a = makeContact(languageCode: 'en');
        final b = makeContact(languageCode: 'de');

        // Assert
        check(a == b).isFalse();
      });

      test('hashCode equals when contacts are equal', () {
        // Arrange + Act
        final a = makeContact();
        final b = makeContact();

        // Assert
        check(a.hashCode).equals(b.hashCode);
      });
    });

    group('validation', () {
      test('rejects empty id', () {
        // Act + Assert
        check(
          () => EmergencyContact(
            id: '',
            name: 'Alice',
            phoneNumber: '+15551234567',
            sortOrder: 0,
          ),
        ).throws<AssertionError>();
      });

      test('rejects empty name', () {
        // Act + Assert
        check(
          () => EmergencyContact(
            id: 'id',
            name: '',
            phoneNumber: '+15551234567',
            sortOrder: 0,
          ),
        ).throws<AssertionError>();
      });

      test('rejects name longer than 255 chars', () {
        // Act + Assert — spec 03 line 203 "Name: non-empty, max 255"
        check(
          () => EmergencyContact(
            id: 'id',
            name: 'x' * 256,
            phoneNumber: '+15551234567',
            sortOrder: 0,
          ),
        ).throws<AssertionError>();
      });

      test('rejects sortOrder < 0', () {
        // Act + Assert
        check(
          () => EmergencyContact(
            id: 'id',
            name: 'X',
            phoneNumber: '+15551234567',
            sortOrder: -1,
          ),
        ).throws<AssertionError>();
      });

      test('accepts empty phoneNumber (no model-level E.164 check)', () {
        // Arrange + Act — spec 03 line 200: E.164 is "preferred", not
        // enforced at the model level; UI/form layer warns.
        final c = EmergencyContact(
          id: 'id',
          name: 'X',
          phoneNumber: '',
          sortOrder: 0,
        );

        // Assert
        check(c.phoneNumber).equals('');
      });

      test('accepts all four message channels simultaneously', () {
        // Arrange + Act
        final c = makeContact(
          channels: const [
            MessageChannel.sms,
            MessageChannel.whatsapp,
            MessageChannel.telegram,
            MessageChannel.phoneCall,
          ],
        );

        // Assert
        check(c.channels.length).equals(4);
      });
    });
  });
}
