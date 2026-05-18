/// Tests covering the [EmergencyContact] default-channels invariant.
/// A fresh contact must enable all 4 messaging channels (sms,
/// whatsapp, telegram, phoneCall) — the user opts out, not in.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';

void main() {
  test(
    'default channels enable all four messaging channels',
    () {
      const c = EmergencyContact(
        id: 'c1',
        name: 'A',
        phoneNumber: '+15551112222',
        sortOrder: 0,
      );
      check(c.channels.toSet()).deepEquals({
        MessageChannel.sms,
        MessageChannel.whatsapp,
        MessageChannel.telegram,
        MessageChannel.phoneCall,
      });
    },
  );

  test('default channels list survives JSON round-trip', () {
    const c = EmergencyContact(
      id: 'c1',
      name: 'A',
      phoneNumber: '+15551112222',
      sortOrder: 0,
    );
    final rt = EmergencyContact.fromJson(c.toJson());
    check(rt.channels.toSet()).deepEquals(c.channels.toSet());
  });
}
