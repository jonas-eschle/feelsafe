/// Unit tests for [validateModeDraft] (spec 04:1595-1599, 1656-1659).
///
/// Pure-Dart coverage of the five save-validation rules: name length, chain
/// non-emptiness, the distress no-action-step warning (non-blocking), the
/// GPS-arrival fixed-coordinate requirement, and hardware-button trigger
/// consistency. The mode editor's `_save()` consumes the same function; see
/// `test/features/mode_editor/mode_editor_screen_test.dart` for the wired path.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/gps_destination_source.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/domain/triggers/distress_trigger.dart';
import 'package:guardianangela/domain/validation/mode_draft_validator.dart';

ChainStep _step(ChainStepType type, {String id = 's', int order = 0}) =>
    ChainStep(
      id: id,
      type: type,
      order: order,
      waitSeconds: 0,
      durationSeconds: 10,
      gracePeriodSeconds: 5,
      retryCount: 0,
      randomize: false,
    );

SessionMode _mode({
  String name = 'Walk',
  bool isDistress = false,
  List<ChainStep>? steps,
  List<DisarmTrigger> disarm = const <DisarmTrigger>[],
  List<DistressTrigger> distress = const <DistressTrigger>[],
}) => SessionMode(
  id: 'm1',
  name: name,
  isDistressMode: isDistress,
  chainSteps: steps ?? <ChainStep>[_step(ChainStepType.holdButton)],
  disarmTriggers: disarm,
  distressTriggers: distress,
);

/// Returns the codes of all blocking issues in declaration order.
List<ModeValidationCode> _blocking(List<ModeValidationIssue> issues) =>
    <ModeValidationCode>[
      for (final ModeValidationIssue i in issues)
        if (i.blocking) i.code,
    ];

/// Returns the codes of all non-blocking (warning) issues.
List<ModeValidationCode> _warnings(List<ModeValidationIssue> issues) =>
    <ModeValidationCode>[
      for (final ModeValidationIssue i in issues)
        if (!i.blocking) i.code,
    ];

void main() {
  group('validateModeDraft — name (rule 1, blocking)', () {
    test('a 1-char name is blocked', () {
      final issues = validateModeDraft(_mode(), name: 'A');
      check(_blocking(issues)).contains(ModeValidationCode.nameTooShort);
    });

    test('an all-whitespace name is blocked (trimmed to empty)', () {
      final issues = validateModeDraft(_mode(), name: '   ');
      check(_blocking(issues)).contains(ModeValidationCode.nameTooShort);
    });

    test('a 2-char name passes the name rule', () {
      final issues = validateModeDraft(_mode(), name: 'Hi');
      check(_blocking(issues)).not(
        (Subject<List<ModeValidationCode>> s) =>
            s.contains(ModeValidationCode.nameTooShort),
      );
    });

    test('a valid mode produces no issues at all', () {
      final issues = validateModeDraft(_mode(), name: 'Walk home');
      check(issues).isEmpty();
    });
  });

  group('validateModeDraft — chain (rule 2, blocking)', () {
    test('a non-empty chain does not trigger chainEmpty', () {
      // Note: an empty-chain SessionMode is unconstructable (the constructor
      // asserts chainSteps.isNotEmpty), so the chainEmpty rule is a
      // release-mode defense; here we prove the predicate is wired and stays
      // silent for the only inputs that can exist.
      final issues = validateModeDraft(_mode(), name: 'Walk');
      check(_blocking(issues)).not(
        (Subject<List<ModeValidationCode>> s) =>
            s.contains(ModeValidationCode.chainEmpty),
      );
    });
  });

  group('validateModeDraft — distress no-action (rule 3, NON-blocking)', () {
    test('distress mode without SMS/call step warns but does not block', () {
      final issues = validateModeDraft(
        _mode(
          isDistress: true,
          steps: <ChainStep>[_step(ChainStepType.countdownWarning)],
        ),
        name: 'Panic',
      );
      check(
        _warnings(issues),
      ).contains(ModeValidationCode.distressNoActionStep);
      check(_blocking(issues)).isEmpty();
    });

    test('distress mode WITH an smsContact step does not warn', () {
      final issues = validateModeDraft(
        _mode(
          isDistress: true,
          steps: <ChainStep>[_step(ChainStepType.smsContact)],
        ),
        name: 'Panic',
      );
      check(issues).isEmpty();
    });

    test('distress mode with phoneCallContact does not warn', () {
      final issues = validateModeDraft(
        _mode(
          isDistress: true,
          steps: <ChainStep>[_step(ChainStepType.phoneCallContact)],
        ),
        name: 'Panic',
      );
      check(issues).isEmpty();
    });

    test('distress mode with callEmergency does not warn', () {
      final issues = validateModeDraft(
        _mode(
          isDistress: true,
          steps: <ChainStep>[_step(ChainStepType.callEmergency)],
        ),
        name: 'Panic',
      );
      check(issues).isEmpty();
    });

    test('a NON-distress mode without an action step does not warn', () {
      final issues = validateModeDraft(
        _mode(steps: <ChainStep>[_step(ChainStepType.countdownWarning)]),
        name: 'Walk',
      );
      check(issues).isEmpty();
    });
  });

  group('validateModeDraft — GPS fixed coords (rule 4, blocking)', () {
    test('fixed source with no lat/lng is blocked', () {
      final issues = validateModeDraft(
        _mode(
          disarm: const <DisarmTrigger>[
            GpsArrivalDisarmTrigger(
              destinationSource: GpsDestinationSource.fixed,
            ),
          ],
        ),
        name: 'Walk',
      );
      check(
        _blocking(issues),
      ).contains(ModeValidationCode.gpsFixedMissingCoords);
    });

    test('fixed source with only lat (lng null) is blocked', () {
      final issues = validateModeDraft(
        _mode(
          disarm: const <DisarmTrigger>[
            GpsArrivalDisarmTrigger(
              destinationSource: GpsDestinationSource.fixed,
              lat: 47.3769,
            ),
          ],
        ),
        name: 'Walk',
      );
      check(
        _blocking(issues),
      ).contains(ModeValidationCode.gpsFixedMissingCoords);
    });

    test('fixed source with both lat and lng passes', () {
      final issues = validateModeDraft(
        _mode(
          disarm: const <DisarmTrigger>[
            GpsArrivalDisarmTrigger(
              destinationSource: GpsDestinationSource.fixed,
              lat: 47.3769,
              lng: 8.5417,
            ),
          ],
        ),
        name: 'Walk',
      );
      check(issues).isEmpty();
    });

    test('promptAtStart source with no coords passes (coords come later)', () {
      final issues = validateModeDraft(
        _mode(disarm: const <DisarmTrigger>[GpsArrivalDisarmTrigger()]),
        name: 'Walk',
      );
      check(issues).isEmpty();
    });
  });

  group('validateModeDraft — hardware trigger (rule 5, blocking)', () {
    test('a default repeat-press trigger is consistent', () {
      final issues = validateModeDraft(
        _mode(
          distress: const <DistressTrigger>[HardwareButtonDistressTrigger()],
        ),
        name: 'Walk',
      );
      check(issues).isEmpty();
    });

    test('repeat-press carrying a stray duration is blocked', () {
      final issues = validateModeDraft(
        _mode(
          distress: const <DistressTrigger>[
            HardwareButtonDistressTrigger(durationSeconds: 2),
          ],
        ),
        name: 'Walk',
      );
      check(
        _blocking(issues),
      ).contains(ModeValidationCode.hardwareTriggerInconsistent);
    });

    test('repeat-press with sub-minimum press count is blocked', () {
      final issues = validateModeDraft(
        _mode(
          distress: const <DistressTrigger>[
            HardwareButtonDistressTrigger(pressCount: 1),
          ],
        ),
        name: 'Walk',
      );
      check(
        _blocking(issues),
      ).contains(ModeValidationCode.hardwareTriggerInconsistent);
    });

    test('a valid long-press trigger is consistent', () {
      final issues = validateModeDraft(
        _mode(
          distress: const <DistressTrigger>[
            HardwareButtonDistressTrigger(
              buttonType: ButtonType.volumeDown,
              pattern: PressPattern.longPress,
              durationSeconds: 2,
            ),
          ],
        ),
        name: 'Walk',
      );
      check(issues).isEmpty();
    });

    test('long-press with null duration is blocked', () {
      final issues = validateModeDraft(
        _mode(
          distress: const <DistressTrigger>[
            HardwareButtonDistressTrigger(pattern: PressPattern.longPress),
          ],
        ),
        name: 'Walk',
      );
      check(
        _blocking(issues),
      ).contains(ModeValidationCode.hardwareTriggerInconsistent);
    });

    test('long-press with non-positive duration is blocked', () {
      final issues = validateModeDraft(
        _mode(
          distress: const <DistressTrigger>[
            HardwareButtonDistressTrigger(
              pattern: PressPattern.longPress,
              durationSeconds: 0,
            ),
          ],
        ),
        name: 'Walk',
      );
      check(
        _blocking(issues),
      ).contains(ModeValidationCode.hardwareTriggerInconsistent);
    });
  });

  group('validateModeDraft — combined', () {
    test('multiple blocking issues are all reported', () {
      final issues = validateModeDraft(
        _mode(
          disarm: const <DisarmTrigger>[
            GpsArrivalDisarmTrigger(
              destinationSource: GpsDestinationSource.fixed,
            ),
          ],
          distress: const <DistressTrigger>[
            HardwareButtonDistressTrigger(pattern: PressPattern.longPress),
          ],
        ),
        name: 'A',
      );
      check(_blocking(issues))
        ..contains(ModeValidationCode.nameTooShort)
        ..contains(ModeValidationCode.gpsFixedMissingCoords)
        ..contains(ModeValidationCode.hardwareTriggerInconsistent);
    });
  });
}
