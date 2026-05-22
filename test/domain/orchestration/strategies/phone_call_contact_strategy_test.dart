import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/log_gps_override.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/orchestration/strategies/phone_call_contact_strategy.dart';
import '../_test_fakes.dart';

// ─── Local step factory ────────────────────────────────────────────────────

/// Builds a [ChainStep] of type [ChainStepType.phoneCallContact].
///
/// [config] defaults to null — exercises the null-config path where the
/// strategy falls back to [PhoneCallContactConfig] defaults.
ChainStep _step({PhoneCallContactConfig? config}) => ChainStep(
  id: 'step-phone-call-contact',
  type: ChainStepType.phoneCallContact,
  order: 0,
  waitSeconds: 0,
  durationSeconds: 30,
  gracePeriodSeconds: 5,
  retryCount: 0,
  randomize: false,
  config: config,
);

// ─── Contact fixtures ──────────────────────────────────────────────────────

EmergencyContact _contact({
  required String id,
  required String name,
  required String phoneNumber,
  int sortOrder = 0,
}) => EmergencyContact(
  id: id,
  name: name,
  phoneNumber: phoneNumber,
  sortOrder: sortOrder,
);

// ─── Tests ─────────────────────────────────────────────────────────────────

void main() {
  // ── Group 1: executeReal — simulation guard ─────────────────────────────

  group('executeReal — isSimulation=true — sim_blocked guard', () {
    test(
      'phone receives no calls with default config when isSimulation=true',
      () async {
        // Arrange
        final phone = FakePhoneService();
        final services = buildServices(
          isSimulation: true,
          phone: phone,
          contacts: [
            _contact(id: 'c1', name: 'Alice', phoneNumber: '+10000000001'),
          ],
        );
        // Act
        await const PhoneCallContactStrategy().executeReal(
          _step(config: const PhoneCallContactConfig()),
          services,
        );
        // Assert
        check(phone.calls).isEmpty();
      },
    );

    test(
      'phone receives no calls with explicit contactId when isSimulation=true',
      () async {
        // Arrange
        final phone = FakePhoneService();
        final services = buildServices(
          isSimulation: true,
          phone: phone,
          contacts: [
            _contact(id: 'c1', name: 'Alice', phoneNumber: '+10000000001'),
          ],
        );
        // Act
        await const PhoneCallContactStrategy().executeReal(
          _step(config: const PhoneCallContactConfig(contactId: 'c1')),
          services,
        );
        // Assert
        check(phone.calls).isEmpty();
      },
    );
  });

  // ── Group 2: executeReal — primary contact resolution by contactId ──────

  group('executeReal — primary contact resolved by contactId', () {
    test(
      'exactly one phone.call dispatched when contactId matches a contact',
      () async {
        // Arrange
        final phone = FakePhoneService();
        final services = buildServices(
          phone: phone,
          contacts: [
            _contact(id: 'id-1', name: 'Alice', phoneNumber: '+10000000001'),
          ],
        );
        // Act
        await const PhoneCallContactStrategy().executeReal(
          _step(config: const PhoneCallContactConfig(contactId: 'id-1')),
          services,
        );
        // Assert
        check(phone.calls).length.equals(1);
      },
    );

    test(
      'call is placed to the correct phone number for matched contactId',
      () async {
        // Arrange
        final phone = FakePhoneService();
        final services = buildServices(
          phone: phone,
          contacts: [
            _contact(id: 'id-1', name: 'Alice', phoneNumber: '+10000000001'),
            _contact(id: 'id-2', name: 'Bob', phoneNumber: '+10000000002'),
          ],
        );
        // Act
        await const PhoneCallContactStrategy().executeReal(
          _step(config: const PhoneCallContactConfig(contactId: 'id-1')),
          services,
        );
        // Assert
        check(phone.calls.first['phoneNumber']).equals('+10000000001');
      },
    );

    test('call method name is "call" (not callEmergency)', () async {
      // Arrange
      final phone = FakePhoneService();
      final services = buildServices(
        phone: phone,
        contacts: [
          _contact(id: 'id-1', name: 'Alice', phoneNumber: '+10000000001'),
        ],
      );
      // Act
      await const PhoneCallContactStrategy().executeReal(
        _step(config: const PhoneCallContactConfig(contactId: 'id-1')),
        services,
      );
      // Assert
      check(phone.calls.first['method']).equals('call');
    });
  });

  // ── Group 3: executeReal — primary contact resolved as first-sorted ──────

  group('executeReal — contactId=null falls back to first-sorted contact', () {
    test(
      'call goes to sortOrder=0 contact when three contacts exist',
      () async {
        // Arrange — contacts in unsorted insertion order
        final phone = FakePhoneService();
        final services = buildServices(
          phone: phone,
          contacts: [
            _contact(
              id: 'c-sort2',
              name: 'Charlie',
              phoneNumber: '+10000000003',
              sortOrder: 2,
            ),
            _contact(id: 'c-sort0', name: 'Alice', phoneNumber: '+10000000001'),
            _contact(
              id: 'c-sort1',
              name: 'Bob',
              phoneNumber: '+10000000002',
              sortOrder: 1,
            ),
          ],
        );
        // Act
        await const PhoneCallContactStrategy().executeReal(
          _step(config: const PhoneCallContactConfig()),
          services,
        );
        // Assert — sortOrder=0 contact is Alice at +10000000001
        check(phone.calls).length.equals(1);
        check(phone.calls.first['phoneNumber']).equals('+10000000001');
      },
    );

    test(
      'no phone.call when contactId=null and contacts list is empty',
      () async {
        // Arrange
        final phone = FakePhoneService();
        final services = buildServices(phone: phone, contacts: []);
        // Act
        await const PhoneCallContactStrategy().executeReal(
          _step(config: const PhoneCallContactConfig()),
          services,
        );
        // Assert
        check(phone.calls).isEmpty();
      },
    );
  });

  // ── Group 4: executeReal — alternative fallback ──────────────────────────

  group('executeReal — alternative contact fallback', () {
    test('calls alt-1 when primary id not found and alt-1 resolves', () async {
      // Arrange
      final phone = FakePhoneService();
      final services = buildServices(
        phone: phone,
        contacts: [
          _contact(id: 'alt-1', name: 'AltOne', phoneNumber: '+10000000010'),
        ],
      );
      // Act
      await const PhoneCallContactStrategy().executeReal(
        _step(
          config: const PhoneCallContactConfig(
            contactId: 'unknown-id',
            alternativeContactIds: ['alt-1'],
          ),
        ),
        services,
      );
      // Assert
      check(phone.calls).length.equals(1);
      check(phone.calls.first['phoneNumber']).equals('+10000000010');
    });

    test(
      'calls the first resolving alt when multiple alternatives are listed',
      () async {
        // Arrange — only alt-2 is present in contacts
        final phone = FakePhoneService();
        final services = buildServices(
          phone: phone,
          contacts: [
            _contact(id: 'alt-2', name: 'AltTwo', phoneNumber: '+10000000020'),
          ],
        );
        // Act
        await const PhoneCallContactStrategy().executeReal(
          _step(
            config: const PhoneCallContactConfig(
              contactId: 'unknown-id',
              alternativeContactIds: ['unknown-1', 'alt-2'],
            ),
          ),
          services,
        );
        // Assert — calls alt-2, not unknown-1
        check(phone.calls).length.equals(1);
        check(phone.calls.first['phoneNumber']).equals('+10000000020');
      },
    );

    test(
      'no phone.call when primary and all alternatives are unresolvable',
      () async {
        // Arrange
        final phone = FakePhoneService();
        final services = buildServices(
          phone: phone,
          contacts: [
            _contact(
              id: 'c-exists',
              name: 'Existing',
              phoneNumber: '+10000000099',
            ),
          ],
        );
        // Act
        await const PhoneCallContactStrategy().executeReal(
          _step(
            config: const PhoneCallContactConfig(
              contactId: 'unknown-id',
              alternativeContactIds: ['unknown-1', 'unknown-2'],
            ),
          ),
          services,
        );
        // Assert — none of the specified IDs matched
        check(phone.calls).isEmpty();
      },
    );

    test(
      'no phone.call when contactId=null, contacts empty, alternatives empty',
      () async {
        // Arrange
        final phone = FakePhoneService();
        final services = buildServices(phone: phone, contacts: []);
        // Act
        // alternativeContactIds defaults to [] — no alternatives at all
        await const PhoneCallContactStrategy().executeReal(
          _step(config: const PhoneCallContactConfig()),
          services,
        );
        // Assert
        check(phone.calls).isEmpty();
      },
    );
  });

  // ── Group 5: executeReal — no other services called ──────────────────────

  group('executeReal — no other services called after successful call', () {
    test('messaging service receives no calls', () async {
      // Arrange
      final messaging = FakeMessagingService();
      final services = buildServices(
        messaging: messaging,
        contacts: [
          _contact(id: 'c1', name: 'Alice', phoneNumber: '+10000000001'),
        ],
      );
      // Act
      await const PhoneCallContactStrategy().executeReal(
        _step(config: const PhoneCallContactConfig(contactId: 'c1')),
        services,
      );
      // Assert — no pre-call SMS
      check(messaging.calls).isEmpty();
    });

    test('audio service receives no calls', () async {
      // Arrange
      final audio = FakeAudioService();
      final services = buildServices(
        audio: audio,
        contacts: [
          _contact(id: 'c1', name: 'Alice', phoneNumber: '+10000000001'),
        ],
      );
      // Act
      await const PhoneCallContactStrategy().executeReal(
        _step(config: const PhoneCallContactConfig(contactId: 'c1')),
        services,
      );
      // Assert
      check(audio.calls).isEmpty();
    });

    test('vibration service receives no calls', () async {
      // Arrange
      final vibration = FakeVibrationService();
      final services = buildServices(
        vibration: vibration,
        contacts: [
          _contact(id: 'c1', name: 'Alice', phoneNumber: '+10000000001'),
        ],
      );
      // Act
      await const PhoneCallContactStrategy().executeReal(
        _step(config: const PhoneCallContactConfig(contactId: 'c1')),
        services,
      );
      // Assert
      check(vibration.calls).isEmpty();
    });

    test('flash service receives no calls', () async {
      // Arrange
      final flash = FakeFlashService();
      final services = buildServices(
        flash: flash,
        contacts: [
          _contact(id: 'c1', name: 'Alice', phoneNumber: '+10000000001'),
        ],
      );
      // Act
      await const PhoneCallContactStrategy().executeReal(
        _step(config: const PhoneCallContactConfig(contactId: 'c1')),
        services,
      );
      // Assert
      check(flash.calls).isEmpty();
    });

    test('screenFlash service receives no calls', () async {
      // Arrange
      final screenFlash = FakeScreenFlashService();
      final services = buildServices(
        screenFlash: screenFlash,
        contacts: [
          _contact(id: 'c1', name: 'Alice', phoneNumber: '+10000000001'),
        ],
      );
      // Act
      await const PhoneCallContactStrategy().executeReal(
        _step(config: const PhoneCallContactConfig(contactId: 'c1')),
        services,
      );
      // Assert
      check(screenFlash.calls).isEmpty();
    });

    test('recording service receives no calls', () async {
      // Arrange
      final recording = FakeRecordingService();
      final services = buildServices(
        recording: recording,
        contacts: [
          _contact(id: 'c1', name: 'Alice', phoneNumber: '+10000000001'),
        ],
      );
      // Act
      await const PhoneCallContactStrategy().executeReal(
        _step(config: const PhoneCallContactConfig(contactId: 'c1')),
        services,
      );
      // Assert
      check(recording.calls).isEmpty();
    });

    test(
      'all non-phone services are empty together after successful call',
      () async {
        // Arrange
        final messaging = FakeMessagingService();
        final audio = FakeAudioService();
        final vibration = FakeVibrationService();
        final flash = FakeFlashService();
        final screenFlash = FakeScreenFlashService();
        final recording = FakeRecordingService();
        final services = buildServices(
          messaging: messaging,
          audio: audio,
          vibration: vibration,
          flash: flash,
          screenFlash: screenFlash,
          recording: recording,
          contacts: [
            _contact(id: 'c1', name: 'Alice', phoneNumber: '+10000000001'),
          ],
        );
        // Act
        await const PhoneCallContactStrategy().executeReal(
          _step(config: const PhoneCallContactConfig(contactId: 'c1')),
          services,
        );
        // Assert — only phone.call, nothing else
        check(messaging.calls).isEmpty();
        check(audio.calls).isEmpty();
        check(vibration.calls).isEmpty();
        check(flash.calls).isEmpty();
        check(screenFlash.calls).isEmpty();
        check(recording.calls).isEmpty();
      },
    );
  });

  // ── Group 6: simulationDescription ──────────────────────────────────────

  group('simulationDescription', () {
    test('returns "Would call Alice" when primary contact resolves', () {
      // Arrange
      final services = buildServices(
        contacts: [
          _contact(id: 'c1', name: 'Alice', phoneNumber: '+10000000001'),
        ],
      );
      // Act
      final result = const PhoneCallContactStrategy().simulationDescription(
        _step(config: const PhoneCallContactConfig(contactId: 'c1')),
        services,
      );
      // Assert
      check(result).equals('Would call Alice');
    });

    test(
      'returns fallback string when contactId unknown and no alternatives',
      () {
        // Arrange
        final services = buildServices(contacts: []);
        // Act
        final result = const PhoneCallContactStrategy().simulationDescription(
          _step(config: const PhoneCallContactConfig(contactId: 'unknown')),
          services,
        );
        // Assert
        check(result).equals('Would call (no contact resolved)');
      },
    );

    test(
      'returns alt contact name when primary unresolved but alt resolves',
      () {
        // Arrange
        final services = buildServices(
          contacts: [
            _contact(id: 'alt-9', name: 'Backup', phoneNumber: '+10000000009'),
          ],
        );
        // Act
        final result = const PhoneCallContactStrategy().simulationDescription(
          _step(
            config: const PhoneCallContactConfig(
              contactId: 'unknown',
              alternativeContactIds: ['alt-9'],
            ),
          ),
          services,
        );
        // Assert — description uses whoever would actually be called
        check(result).equals('Would call Backup');
      },
    );

    test(
      'returns fallback string when contacts list is empty and contactId=null',
      () {
        // Arrange
        final services = buildServices(contacts: []);
        // Act
        final result = const PhoneCallContactStrategy().simulationDescription(
          _step(config: const PhoneCallContactConfig()),
          services,
        );
        // Assert
        check(result).equals('Would call (no contact resolved)');
      },
    );

    test('description is the same regardless of isSimulation=false', () {
      // Arrange
      final services = buildServices(
        contacts: [
          _contact(id: 'c1', name: 'Alice', phoneNumber: '+10000000001'),
        ],
      );
      // Act
      final result = const PhoneCallContactStrategy().simulationDescription(
        _step(config: const PhoneCallContactConfig(contactId: 'c1')),
        services,
      );
      // Assert
      check(result).equals('Would call Alice');
    });

    test('description is the same regardless of isSimulation=true', () {
      // Arrange
      final services = buildServices(
        isSimulation: true,
        contacts: [
          _contact(id: 'c1', name: 'Alice', phoneNumber: '+10000000001'),
        ],
      );
      // Act
      final result = const PhoneCallContactStrategy().simulationDescription(
        _step(config: const PhoneCallContactConfig(contactId: 'c1')),
        services,
      );
      // Assert — simulationDescription ignores isSimulation flag
      check(result).equals('Would call Alice');
    });

    test('returns first-sorted contact name when step.config is null', () {
      // Arrange — null config falls back to default PhoneCallContactConfig
      // which means contactId=null → first-sorted contact
      final services = buildServices(
        contacts: [
          _contact(
            id: 'c-sort1',
            name: 'Bob',
            phoneNumber: '+10000000002',
            sortOrder: 1,
          ),
          _contact(id: 'c-sort0', name: 'Alice', phoneNumber: '+10000000001'),
        ],
      );
      // Act
      final result = const PhoneCallContactStrategy().simulationDescription(
        _step(),
        services,
      );
      // Assert — Alice has sortOrder=0 (default) so is first
      check(result).equals('Would call Alice');
    });

    test(
      'returns fallback string when step.config is null and contacts empty',
      () {
        // Arrange
        final services = buildServices(contacts: []);
        // Act
        final result = const PhoneCallContactStrategy().simulationDescription(
          _step(),
          services,
        );
        // Assert
        check(result).equals('Would call (no contact resolved)');
      },
    );
  });

  // ── Group 7: LogGpsOverride values do not affect executeReal ────────────

  group('executeReal — LogGpsOverride values do not affect call behavior', () {
    for (final logGps in LogGpsOverride.values) {
      test(
        'logGps=${logGps.name}: exactly one phone.call, no other service calls',
        () async {
          // Arrange
          final phone = FakePhoneService();
          final messaging = FakeMessagingService();
          final audio = FakeAudioService();
          final vibration = FakeVibrationService();
          final services = buildServices(
            phone: phone,
            messaging: messaging,
            audio: audio,
            vibration: vibration,
            contacts: [
              _contact(id: 'c1', name: 'Alice', phoneNumber: '+10000000001'),
            ],
          );
          // Act
          await const PhoneCallContactStrategy().executeReal(
            _step(
              config: PhoneCallContactConfig(contactId: 'c1', logGps: logGps),
            ),
            services,
          );
          // Assert — call goes through; logGps has no side-effects here
          check(phone.calls).length.equals(1);
          check(phone.calls.first['phoneNumber']).equals('+10000000001');
          check(messaging.calls).isEmpty();
          check(audio.calls).isEmpty();
          check(vibration.calls).isEmpty();
        },
      );
    }
  });

  // ── Group 8: null config path ────────────────────────────────────────────

  group('null step.config — fallback to default PhoneCallContactConfig', () {
    test(
      'executeReal calls first-sorted contact when config is null',
      () async {
        // Arrange — config=null triggers default: contactId=null
        final phone = FakePhoneService();
        final services = buildServices(
          phone: phone,
          contacts: [
            _contact(id: 'c-first', name: 'First', phoneNumber: '+10000000001'),
            _contact(
              id: 'c-second',
              name: 'Second',
              phoneNumber: '+10000000002',
              sortOrder: 1,
            ),
          ],
        );
        // Act
        await const PhoneCallContactStrategy().executeReal(
          _step(), // config=null
          services,
        );
        // Assert
        check(phone.calls).length.equals(1);
        check(phone.calls.first['phoneNumber']).equals('+10000000001');
      },
    );

    test(
      'executeReal is a no-op when config is null and contacts list is empty',
      () async {
        // Arrange
        final phone = FakePhoneService();
        final services = buildServices(phone: phone, contacts: []);
        // Act
        await const PhoneCallContactStrategy().executeReal(
          _step(), // config=null
          services,
        );
        // Assert
        check(phone.calls).isEmpty();
      },
    );
  });

  // ── Group 9: const constructor identity ─────────────────────────────────

  group('const constructor — identity', () {
    test(
      'identical(PhoneCallContactStrategy(), PhoneCallContactStrategy())',
      () {
        // Assert — const guarantees a single canonical instance
        check(
          identical(
            const PhoneCallContactStrategy(),
            const PhoneCallContactStrategy(),
          ),
        ).isTrue();
      },
    );
  });
}
