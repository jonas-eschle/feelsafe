/// Unit tests for [SmsContactStrategy].
///
/// Spec ref: docs/spec/02-event-types.md §6 smsContact.
///
/// Coverage:
/// - sim guard (Layer 2)
/// - contactSelection variants (allContacts, firstContact, specificIds, legacy)
/// - single-channel dispatch filtering
/// - placeholder substitution ({name}, {location}, {time}, {description})
/// - medical-info appendix
/// - autoRecordAudio (fire-and-forget)
/// - simulationDescription return values
/// - const constructor identity
/// - null step.config defaults
library;

import 'package:checks/checks.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/orchestration/strategies/sms_contact_strategy.dart';
import '../_test_fakes.dart';

// ─── Helper factories ─────────────────────────────────────────────────────────

/// Builds a [ChainStep] of type [ChainStepType.smsContact].
///
/// [config] defaults to `null` to exercise the null-config path.
ChainStep _step({SmsContactConfig? config}) => ChainStep(
  id: 'sms-step-id',
  type: ChainStepType.smsContact,
  order: 0,
  waitSeconds: 0,
  durationSeconds: 10,
  gracePeriodSeconds: 5,
  retryCount: 0,
  randomize: false,
  config: config,
);

/// Builds an [EmergencyContact] with defaults suitable for SMS tests.
///
/// [id] defaults to `'c1'`, [name] to `'Contact 1'`,
/// [sortOrder] to `0`, [channels] to `[MessageChannel.sms]`.
EmergencyContact _contact({
  String id = 'c1',
  String name = 'Contact 1',
  int sortOrder = 0,
  List<MessageChannel> channels = const [MessageChannel.sms],
}) => EmergencyContact(
  id: id,
  name: name,
  phoneNumber: '+10000000001',
  sortOrder: sortOrder,
  channels: channels,
);

void main() {
  // ─── Group 1: sim guard ──────────────────────────────────────────────────

  group('executeReal — sim guard (isSimulation=true)', () {
    test(
      'messaging.calls empty with default config when isSimulation=true',
      () async {
        final messaging = FakeMessagingService();
        final services = buildServices(
          isSimulation: true,
          messaging: messaging,
          contacts: [_contact()],
        );
        await const SmsContactStrategy().executeReal(
          _step(config: const SmsContactConfig()),
          services,
        );
        check(messaging.calls).isEmpty();
      },
    );

    test('messaging.calls empty with custom config (autoRecordAudio) when '
        'isSimulation=true', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(
        isSimulation: true,
        messaging: messaging,
        contacts: [
          _contact(),
          _contact(id: 'c2', name: 'C2', sortOrder: 1),
        ],
      );
      await const SmsContactStrategy().executeReal(
        _step(config: const SmsContactConfig(autoRecordAudio: true)),
        services,
      );
      check(messaging.calls).isEmpty();
    });

    test('recording.calls empty when isSimulation=true', () async {
      final recording = FakeRecordingService();
      final services = buildServices(
        isSimulation: true,
        recording: recording,
        contacts: [_contact()],
      );
      await const SmsContactStrategy().executeReal(
        _step(config: const SmsContactConfig(autoRecordAudio: true)),
        services,
      );
      check(recording.calls).isEmpty();
    });
  });

  // ─── Group 2: contactSelection — allContacts ─────────────────────────────

  group('executeReal — contactSelection: allContacts', () {
    test('3 sms-channel contacts → 3 sendMessage calls', () async {
      final messaging = FakeMessagingService();
      final contacts = [
        _contact(),
        _contact(id: 'c2', name: 'C2', sortOrder: 1),
        _contact(id: 'c3', name: 'C3', sortOrder: 2),
      ];
      final services = buildServices(messaging: messaging, contacts: contacts);
      await const SmsContactStrategy().executeReal(
        _step(config: const SmsContactConfig()),
        services,
      );
      check(messaging.calls).length.equals(3);
    });

    test('0 contacts → 0 sendMessage calls', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(messaging: messaging, contacts: []);
      await const SmsContactStrategy().executeReal(
        _step(config: const SmsContactConfig()),
        services,
      );
      check(messaging.calls).isEmpty();
    });
  });

  // ─── Group 3: contactSelection — firstContact ────────────────────────────

  group('executeReal — contactSelection: firstContact', () {
    test(
      '3 contacts with sortOrder 2,0,1 → only the one with sortOrder 0 targeted',
      () async {
        final messaging = FakeMessagingService();
        final contacts = [
          _contact(name: 'C1', sortOrder: 2),
          _contact(id: 'c2', name: 'C2'),
          _contact(id: 'c3', name: 'C3', sortOrder: 1),
        ];
        final services = buildServices(
          messaging: messaging,
          contacts: contacts,
        );
        await const SmsContactStrategy().executeReal(
          _step(
            config: const SmsContactConfig(
              contactSelection: SmsContactSelection.firstContact,
            ),
          ),
          services,
        );
        check(messaging.calls).length.equals(1);
        final sent = messaging.calls.first['contact'] as EmergencyContact;
        check(sent.id).equals('c2');
      },
    );

    test('ties in sortOrder: list order (first in list) wins', () async {
      final messaging = FakeMessagingService();
      // Both have sortOrder 1 — the one inserted first in the list wins.
      final contacts = [
        _contact(id: 'first', name: 'First', sortOrder: 1),
        _contact(id: 'second', name: 'Second', sortOrder: 1),
      ];
      final services = buildServices(messaging: messaging, contacts: contacts);
      await const SmsContactStrategy().executeReal(
        _step(
          config: const SmsContactConfig(
            contactSelection: SmsContactSelection.firstContact,
          ),
        ),
        services,
      );
      check(messaging.calls).length.equals(1);
      final sent = messaging.calls.first['contact'] as EmergencyContact;
      // List.sort is stable in Dart — first element in the list wins on ties.
      check(sent.id).equals('first');
    });

    test('empty contacts list → 0 sendMessage calls', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(messaging: messaging, contacts: []);
      await const SmsContactStrategy().executeReal(
        _step(
          config: const SmsContactConfig(
            contactSelection: SmsContactSelection.firstContact,
          ),
        ),
        services,
      );
      check(messaging.calls).isEmpty();
    });
  });

  // ─── Group 4: contactSelection — specificIds ─────────────────────────────

  group('executeReal — contactSelection: specificIds', () {
    test('ids matching 2 of 3 contacts → 2 sendMessage calls', () async {
      final messaging = FakeMessagingService();
      final contacts = [
        _contact(name: 'C1'),
        _contact(id: 'c2', name: 'C2', sortOrder: 1),
        _contact(id: 'c3', name: 'C3', sortOrder: 2),
      ];
      final services = buildServices(messaging: messaging, contacts: contacts);
      await const SmsContactStrategy().executeReal(
        _step(
          config: const SmsContactConfig(
            contactSelection: SmsContactSelection.specificIds,
            contactIds: ['c1', 'c3'],
          ),
        ),
        services,
      );
      check(messaging.calls).length.equals(2);
    });

    test('empty contactIds list → 0 sendMessage calls', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(
        messaging: messaging,
        contacts: [_contact()],
      );
      await const SmsContactStrategy().executeReal(
        _step(
          config: const SmsContactConfig(
            contactSelection: SmsContactSelection.specificIds,
            contactIds: [],
          ),
        ),
        services,
      );
      check(messaging.calls).isEmpty();
    });

    test('null contactIds → 0 sendMessage calls', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(
        messaging: messaging,
        contacts: [_contact()],
      );
      await const SmsContactStrategy().executeReal(
        _step(
          config: const SmsContactConfig(
            contactSelection: SmsContactSelection.specificIds,
          ),
        ),
        services,
      );
      check(messaging.calls).isEmpty();
    });

    test('non-matching ids → 0 sendMessage calls', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(
        messaging: messaging,
        contacts: [_contact(id: 'real-id')],
      );
      await const SmsContactStrategy().executeReal(
        _step(
          config: const SmsContactConfig(
            contactSelection: SmsContactSelection.specificIds,
            contactIds: ['nonexistent-id'],
          ),
        ),
        services,
      );
      check(messaging.calls).isEmpty();
    });
  });

  // ─── Group 5: legacy fallback ─────────────────────────────────────────────

  group('executeReal — legacy fallback: allContacts + non-empty contactIds → '
      'specificIds behaviour', () {
    test('allContacts + contactIds: only listed contacts targeted', () async {
      final messaging = FakeMessagingService();
      final contacts = [
        _contact(),
        _contact(id: 'c2', name: 'C2', sortOrder: 1),
        _contact(id: 'c3', name: 'C3', sortOrder: 2),
      ];
      final services = buildServices(messaging: messaging, contacts: contacts);
      await const SmsContactStrategy().executeReal(
        _step(config: const SmsContactConfig(contactIds: ['c2'])),
        services,
      );
      // Legacy: treated as specificIds — only c2 targeted, not all 3.
      check(messaging.calls).length.equals(1);
      final sent = messaging.calls.first['contact'] as EmergencyContact;
      check(sent.id).equals('c2');
    });

    test(
      'allContacts + empty contactIds → normal allContacts (not legacy path)',
      () async {
        final messaging = FakeMessagingService();
        final contacts = [
          _contact(),
          _contact(id: 'c2', name: 'C2', sortOrder: 1),
        ];
        final services = buildServices(
          messaging: messaging,
          contacts: contacts,
        );
        await const SmsContactStrategy().executeReal(
          _step(config: const SmsContactConfig(contactIds: [])),
          services,
        );
        // Empty list: legacy path not triggered → all contacts used.
        check(messaging.calls).length.equals(2);
      },
    );
  });

  // ─── Group 6: channel filtering (single-channel dispatch) ────────────────

  group('executeReal — channel filtering (single-channel dispatch)', () {
    test('2 sms contacts + 1 whatsapp-only; channel=sms → 2 calls, '
        'none to whatsapp-only', () async {
      final messaging = FakeMessagingService();
      final contacts = [
        _contact(id: 'sms1', name: 'Sms1'),
        _contact(id: 'sms2', name: 'Sms2', sortOrder: 1),
        _contact(
          id: 'wp1',
          name: 'Wp1',
          sortOrder: 2,
          channels: [MessageChannel.whatsapp],
        ),
      ];
      final services = buildServices(messaging: messaging, contacts: contacts);
      await const SmsContactStrategy().executeReal(
        _step(config: const SmsContactConfig()),
        services,
      );
      check(messaging.calls).length.equals(2);
      final ids = messaging.calls
          .map((c) => (c['contact'] as EmergencyContact).id)
          .toList();
      check(ids).contains('sms1');
      check(ids).contains('sms2');
      check(ids).not((s) => s.contains('wp1'));
    });

    test(
      'all contacts have sms; channel=whatsapp → 0 sendMessage calls',
      () async {
        final messaging = FakeMessagingService();
        final contacts = [
          _contact(),
          _contact(id: 'c2', name: 'C2', sortOrder: 1),
        ];
        final services = buildServices(
          messaging: messaging,
          contacts: contacts,
        );
        await const SmsContactStrategy().executeReal(
          _step(
            config: const SmsContactConfig(channel: MessageChannel.whatsapp),
          ),
          services,
        );
        check(messaging.calls).isEmpty();
      },
    );

    test(
      'each sendMessage call passes contact with channels: [config.channel] only',
      () async {
        final messaging = FakeMessagingService();
        // Contact has both sms and whatsapp; default channel=sms → copyWith
        // strips to [sms] only.
        final contacts = [
          _contact(
            id: 'multi',
            channels: [MessageChannel.sms, MessageChannel.whatsapp],
          ),
        ];
        final services = buildServices(
          messaging: messaging,
          contacts: contacts,
        );
        await const SmsContactStrategy().executeReal(
          _step(config: const SmsContactConfig()),
          services,
        );
        check(messaging.calls).length.equals(1);
        final sent = messaging.calls.first['contact'] as EmergencyContact;
        check(sent.channels).deepEquals([MessageChannel.sms]);
      },
    );
  });

  // ─── Group 7: placeholder substitution ───────────────────────────────────

  group('executeReal — placeholder substitution', () {
    test(
      'default template with userName, userDescription, location URL',
      () async {
        final messaging = FakeMessagingService();
        final services = buildServices(
          messaging: messaging,
          contacts: [_contact()],
          userName: 'Alice',
          userDescription: 'red jacket',
          lastLocationUrl: 'https://maps.google.com/?q=1.0,2.0',
        );
        await withClock(
          Clock.fixed(DateTime.utc(2026, 5, 22, 10)),
          () => const SmsContactStrategy().executeReal(
            _step(config: const SmsContactConfig()),
            services,
          ),
        );
        final msg = messaging.calls.first['message'] as String;
        check(msg).contains('Alice may need help');
        check(msg).contains('red jacket');
        check(msg).contains('https://maps.google.com/?q=1.0,2.0');
      },
    );

    test(
      'userName=null → {name} resolved to "the owner of this phone"',
      () async {
        final messaging = FakeMessagingService();
        final services = buildServices(
          messaging: messaging,
          contacts: [_contact()],
        );
        await const SmsContactStrategy().executeReal(
          _step(config: const SmsContactConfig()),
          services,
        );
        final msg = messaging.calls.first['message'] as String;
        check(msg).contains('the owner of this phone');
      },
    );

    test(
      'userDescription=null → {description} resolves to empty string',
      () async {
        final messaging = FakeMessagingService();
        final services = buildServices(
          messaging: messaging,
          contacts: [_contact()],
          userName: 'Alice',
        );
        await const SmsContactStrategy().executeReal(
          _step(config: const SmsContactConfig()),
          services,
        );
        final msg = messaging.calls.first['message'] as String;
        // Placeholder must be substituted with empty, not the literal token.
        check(msg).not((s) => s.contains('{description}'));
        check(msg).contains('Physical description: ');
      },
    );

    test(
      'locationUrl=null, description set → {location} uses description',
      () async {
        final messaging = FakeMessagingService();
        final services = buildServices(
          messaging: messaging,
          contacts: [_contact()],
          lastLocationUrl: null,
          lastLocationDescription: 'Near 5th Ave',
        );
        await const SmsContactStrategy().executeReal(
          _step(config: const SmsContactConfig()),
          services,
        );
        final msg = messaging.calls.first['message'] as String;
        check(msg).contains('Near 5th Ave');
      },
    );

    test('locationUrl=null AND description=null → {location} = '
        '"Location unavailable"', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(
        messaging: messaging,
        contacts: [_contact()],
        lastLocationUrl: null,
      );
      await const SmsContactStrategy().executeReal(
        _step(config: const SmsContactConfig()),
        services,
      );
      final msg = messaging.calls.first['message'] as String;
      check(msg).contains('Location unavailable');
    });

    test('custom template renders exactly', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(
        messaging: messaging,
        contacts: [_contact()],
        userName: 'Bob',
      );
      await const SmsContactStrategy().executeReal(
        _step(
          config: const SmsContactConfig(messageTemplate: 'Help me {name}'),
        ),
        services,
      );
      final msg = messaging.calls.first['message'] as String;
      check(msg).equals('Help me Bob');
    });

    test('{time} resolves to frozen ISO-8601 UTC string', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(
        messaging: messaging,
        contacts: [_contact()],
        userName: 'Test',
      );
      await withClock(
        Clock.fixed(DateTime.utc(2026, 5, 22, 10)),
        () => const SmsContactStrategy().executeReal(
          _step(config: const SmsContactConfig()),
          services,
        ),
      );
      final msg = messaging.calls.first['message'] as String;
      check(msg).contains('2026-05-22T10:00:00.000Z');
    });

    test('locationUrl available; includeLocation=false → '
        '"Location unavailable" inserted', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(
        messaging: messaging,
        contacts: [_contact()],
        lastLocationUrl: 'https://maps.google.com/?q=1.0,2.0',
      );
      await const SmsContactStrategy().executeReal(
        _step(config: const SmsContactConfig(includeLocation: false)),
        services,
      );
      final msg = messaging.calls.first['message'] as String;
      check(msg).contains('Location unavailable');
      check(msg).not((s) => s.contains('maps.google.com'));
    });
  });

  // ─── Group 8: medical info appendix ──────────────────────────────────────

  group('executeReal — medical info appendix', () {
    test(
      'includeMedicalInfo=true + userMedicalInfo set → appended to message',
      () async {
        final messaging = FakeMessagingService();
        final services = buildServices(
          messaging: messaging,
          contacts: [_contact()],
          userMedicalInfo: 'Type 1 diabetes',
        );
        await const SmsContactStrategy().executeReal(
          _step(config: const SmsContactConfig(includeMedicalInfo: true)),
          services,
        );
        final msg = messaging.calls.first['message'] as String;
        check(msg).endsWith('\n\nMedical info: Type 1 diabetes');
      },
    );

    test(
      'includeMedicalInfo=true + userMedicalInfo=null → no appendix',
      () async {
        final messaging = FakeMessagingService();
        final services = buildServices(
          messaging: messaging,
          contacts: [_contact()],
        );
        await const SmsContactStrategy().executeReal(
          _step(config: const SmsContactConfig(includeMedicalInfo: true)),
          services,
        );
        final msg = messaging.calls.first['message'] as String;
        check(msg).not((s) => s.contains('Medical info:'));
      },
    );

    test(
      'includeMedicalInfo=false (default) + userMedicalInfo set → no appendix',
      () async {
        final messaging = FakeMessagingService();
        final services = buildServices(
          messaging: messaging,
          contacts: [_contact()],
          userMedicalInfo: 'Allergic to penicillin',
        );
        await const SmsContactStrategy().executeReal(
          _step(config: const SmsContactConfig()),
          services,
        );
        final msg = messaging.calls.first['message'] as String;
        check(msg).not((s) => s.contains('Medical info:'));
      },
    );
  });

  // ─── Group 9: autoRecordAudio ─────────────────────────────────────────────

  group('executeReal — autoRecordAudio', () {
    test(
      'autoRecordAudio=true → recording.calls has one recordForDuration entry',
      () async {
        final recording = FakeRecordingService();
        final services = buildServices(
          recording: recording,
          contacts: [_contact()],
        );
        await const SmsContactStrategy().executeReal(
          _step(
            config: const SmsContactConfig(
              autoRecordAudio: true,
              recordDurationSeconds: 45,
            ),
          ),
          services,
        );
        check(recording.calls).length.equals(1);
        check(recording.calls.first['method']).equals('recordForDuration');
        check(
          recording.calls.first['duration'],
        ).equals(const Duration(seconds: 45));
      },
    );

    test(
      'autoRecordAudio default (false) → recording.calls is empty',
      () async {
        final recording = FakeRecordingService();
        final services = buildServices(
          recording: recording,
          contacts: [_contact()],
        );
        await const SmsContactStrategy().executeReal(
          _step(config: const SmsContactConfig()),
          services,
        );
        check(recording.calls).isEmpty();
      },
    );

    test(
      'recordDurationSeconds matches config value passed to recordForDuration',
      () async {
        final recording = FakeRecordingService();
        final services = buildServices(
          recording: recording,
          contacts: [_contact()],
        );
        await const SmsContactStrategy().executeReal(
          _step(
            config: const SmsContactConfig(
              autoRecordAudio: true,
              recordDurationSeconds: 60,
            ),
          ),
          services,
        );
        final duration = recording.calls.first['duration'] as Duration;
        check(duration.inSeconds).equals(60);
      },
    );

    test('autoRecordAudio=true and no contacts → recording NOT kicked off '
        '(filtered list empty means early return before recording)', () async {
      // The strategy returns early when filtered list is empty (no contacts
      // with the matching channel). Recording should NOT fire.
      final recording = FakeRecordingService();
      final services = buildServices(recording: recording, contacts: []);
      await const SmsContactStrategy().executeReal(
        _step(config: const SmsContactConfig(autoRecordAudio: true)),
        services,
      );
      check(recording.calls).isEmpty();
    });
  });

  // ─── Group 10: simulationDescription ─────────────────────────────────────

  group('simulationDescription', () {
    test('default config + 3 sms-channel contacts → '
        '"Would send to 3 contacts via sms"', () {
      final services = buildServices(
        contacts: [
          _contact(),
          _contact(id: 'c2', name: 'C2', sortOrder: 1),
          _contact(id: 'c3', name: 'C3', sortOrder: 2),
        ],
      );
      final result = const SmsContactStrategy().simulationDescription(
        _step(config: const SmsContactConfig()),
        services,
      );
      check(result).equals('Would send to 3 contacts via sms');
    });

    test('0 contacts → "No contacts targeted for sms"', () {
      final services = buildServices(contacts: []);
      final result = const SmsContactStrategy().simulationDescription(
        _step(config: const SmsContactConfig()),
        services,
      );
      check(result).equals('No contacts targeted for sms');
    });

    test('channel=whatsapp; 3 contacts, only 1 has whatsapp → '
        '"Would send to 1 contact via whatsapp"', () {
      final services = buildServices(
        contacts: [
          _contact(),
          _contact(
            id: 'c2',
            name: 'C2',
            sortOrder: 1,
            channels: [MessageChannel.whatsapp],
          ),
          _contact(id: 'c3', name: 'C3', sortOrder: 2),
        ],
      );
      final result = const SmsContactStrategy().simulationDescription(
        _step(config: const SmsContactConfig(channel: MessageChannel.whatsapp)),
        services,
      );
      check(result).equals('Would send to 1 contact via whatsapp');
    });

    test('step.config=null → uses defaults (channel=sms); '
        '"No contacts targeted for sms" with 0 contacts', () {
      final services = buildServices(contacts: []);
      final result = const SmsContactStrategy().simulationDescription(
        _step(),
        services,
      );
      check(result).equals('No contacts targeted for sms');
    });

    test(
      'step.config=null + 1 sms contact → "Would send to 1 contact via sms"',
      () {
        final services = buildServices(contacts: [_contact()]);
        final result = const SmsContactStrategy().simulationDescription(
          _step(),
          services,
        );
        check(result).equals('Would send to 1 contact via sms');
      },
    );

    test(
      'N=2 contacts → "Would send to 2 contacts via sms" (plural branch)',
      () {
        // N=2 is the smallest plural value; explicitly covers the plural
        // branch adjacent to the N=1 singular branch per spec 02 line 354.
        final services = buildServices(
          contacts: [
            _contact(),
            _contact(id: 'c2', name: 'C2', sortOrder: 1),
          ],
        );
        final result = const SmsContactStrategy().simulationDescription(
          _step(config: const SmsContactConfig()),
          services,
        );
        check(result).equals('Would send to 2 contacts via sms');
      },
    );
  });

  // ─── Group 11: const + null safety ───────────────────────────────────────

  group('const constructor and null step.config', () {
    test('two SmsContactStrategy() instances are identical (const)', () {
      check(
        identical(const SmsContactStrategy(), const SmsContactStrategy()),
      ).isTrue();
    });

    test('step.config=null → defaults used, no throw', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(
        messaging: messaging,
        contacts: [_contact()],
      );
      await check(
        const SmsContactStrategy().executeReal(_step(), services),
      ).completes();
      // Behaves as allContacts + channel=sms default.
      check(messaging.calls).length.equals(1);
    });

    test(
      'step.config=null + 3 contacts → all 3 sent (allContacts default)',
      () async {
        final messaging = FakeMessagingService();
        final services = buildServices(
          messaging: messaging,
          contacts: [
            _contact(),
            _contact(id: 'c2', name: 'C2', sortOrder: 1),
            _contact(id: 'c3', name: 'C3', sortOrder: 2),
          ],
        );
        await const SmsContactStrategy().executeReal(_step(), services);
        check(messaging.calls).length.equals(3);
      },
    );
  });

  // ─── Group 12: sendMessage payload validation ─────────────────────────────

  group('executeReal — sendMessage payload', () {
    test('sendMessage method name is "sendMessage"', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(
        messaging: messaging,
        contacts: [_contact()],
      );
      await const SmsContactStrategy().executeReal(
        _step(config: const SmsContactConfig()),
        services,
      );
      check(messaging.calls.first['method']).equals('sendMessage');
    });

    test('isSimulation=false in the sendMessage call', () async {
      final messaging = FakeMessagingService();
      final services = buildServices(
        messaging: messaging,
        contacts: [_contact()],
      );
      await const SmsContactStrategy().executeReal(
        _step(config: const SmsContactConfig()),
        services,
      );
      // FakeMessagingService records isSimulation; default is false.
      check(messaging.calls.first['isSimulation']).equals(false);
    });

    test(
      'each contact gets its own message (Future.wait dispatches all)',
      () async {
        final messaging = FakeMessagingService();
        final contacts = [
          _contact(),
          _contact(id: 'c2', name: 'C2', sortOrder: 1),
        ];
        final services = buildServices(
          messaging: messaging,
          contacts: contacts,
        );
        await const SmsContactStrategy().executeReal(
          _step(config: const SmsContactConfig()),
          services,
        );
        final sentIds = messaging.calls
            .map((c) => (c['contact'] as EmergencyContact).id)
            .toSet();
        check(sentIds).contains('c1');
        check(sentIds).contains('c2');
      },
    );
  });
}
