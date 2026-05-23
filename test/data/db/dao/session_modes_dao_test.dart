import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/gps_destination_source.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';
import 'package:guardianangela/domain/models/mode_overrides.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/domain/triggers/distress_trigger.dart';

void main() {
  late GuardianAngelaDatabase db;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
  });

  tearDown(() async {
    await db.close();
  });

  group('SessionModesDao', () {
    test('getAll returns empty on a fresh database', () async {
      check(await db.sessionModesDao.getAll()).isEmpty();
    });

    test('round-trips a 5-step mode with overrides + triggers', () async {
      // Arrange
      final mode = SessionMode(
        id: 'mode-walk',
        name: 'Walk',
        iconName: 'directions_walk',
        chainSteps: [
          ChainStep(
            id: 's0',
            type: ChainStepType.holdButton,
            order: 0,
            waitSeconds: 0,
            durationSeconds: 10,
            gracePeriodSeconds: 1,
            retryCount: 0,
            randomize: false,
            config: const HoldButtonConfig(),
          ),
          ChainStep(
            id: 's1',
            type: ChainStepType.fakeCall,
            order: 1,
            waitSeconds: 0,
            durationSeconds: 30,
            gracePeriodSeconds: 5,
            retryCount: 0,
            randomize: false,
          ),
          ChainStep(
            id: 's2',
            type: ChainStepType.smsContact,
            order: 2,
            waitSeconds: 0,
            durationSeconds: 15,
            gracePeriodSeconds: 5,
            retryCount: 0,
            randomize: false,
            config: const SmsContactConfig(
              contactSelection: SmsContactSelection.firstContact,
            ),
          ),
          ChainStep(
            id: 's3',
            type: ChainStepType.phoneCallContact,
            order: 3,
            waitSeconds: 0,
            durationSeconds: 60,
            gracePeriodSeconds: 5,
            retryCount: 0,
            randomize: false,
          ),
          ChainStep(
            id: 's4',
            type: ChainStepType.callEmergency,
            order: 4,
            waitSeconds: 0,
            durationSeconds: 5,
            gracePeriodSeconds: 0,
            retryCount: 0,
            randomize: false,
          ),
        ],
        distressModeId: 'distress-default',
        distressTriggers: [const HardwareButtonDistressTrigger()],
        disarmTriggers: [
          const GpsArrivalDisarmTrigger(
            destinationSource: GpsDestinationSource.fixed,
            lat: 52.5,
            lng: 13.4,
          ),
          const TimerDisarmTrigger(durationSeconds: 1800),
        ],
        overrides: const ModeOverrides(
          gpsLogging: GpsLoggingConfig(intervalSeconds: 10),
          eventDefaults: EventDefaults(),
        ),
        trackingEnabled: true,
        trackingIntervalSeconds: 60,
        trackingBufferSize: 100,
        pauseAllowed: false,
        maxPauseMinutes: 5,
      );
      // Act
      await db.sessionModesDao.upsert(mode);
      final fetched = await db.sessionModesDao.getById('mode-walk');
      // Assert
      check(fetched).isNotNull().equals(mode);
    });

    test(
      'getDistressModes / getRegularModes filter on isDistressMode',
      () async {
        // Arrange
        await db.sessionModesDao.upsert(_simpleMode('walk'));
        await db.sessionModesDao.upsert(_simpleMode('date'));
        await db.sessionModesDao.upsert(
          _simpleMode('distress', isDistress: true),
        );
        // Act
        final regular = await db.sessionModesDao.getRegularModes();
        final distress = await db.sessionModesDao.getDistressModes();
        // Assert
        check(regular.map((m) => m.id).toSet()).deepEquals({'walk', 'date'});
        check(distress.map((m) => m.id).toSet()).deepEquals({'distress'});
      },
    );

    test('deleteById removes the mode', () async {
      // Arrange
      await db.sessionModesDao.upsert(_simpleMode('walk'));
      // Act
      await db.sessionModesDao.deleteById('walk');
      // Assert
      check(await db.sessionModesDao.getById('walk')).isNull();
    });

    test('round-trips a mode with null overrides', () async {
      // Arrange
      final mode = _simpleMode('plain');
      check(mode.overrides).isNull();
      // Act
      await db.sessionModesDao.upsert(mode);
      // Assert
      final fetched = await db.sessionModesDao.getById('plain');
      check(fetched).isNotNull();
      check(fetched!.overrides).isNull();
    });

    test('watchAll emits the current list on subscription', () async {
      // Arrange
      await db.sessionModesDao.upsert(_simpleMode('walk'));
      // Act
      final first = await db.sessionModesDao.watchAll().first;
      // Assert
      check(first.length).equals(1);
      check(first.single.id).equals('walk');
    });
  });
}

SessionMode _simpleMode(String id, {bool isDistress = false}) => SessionMode(
  id: id,
  name: 'Mode-$id',
  chainSteps: [
    ChainStep(
      id: 'step-0',
      type: ChainStepType.holdButton,
      order: 0,
      waitSeconds: 0,
      durationSeconds: 10,
      gracePeriodSeconds: 1,
      retryCount: 0,
      randomize: false,
    ),
  ],
  isDistressMode: isDistress,
);
