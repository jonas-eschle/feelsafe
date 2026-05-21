// Unit tests for [SessionMode].
//
// Verifies constructor invariants, JSON round-trip, copyWith behaviour,
// equality / hashCode contract, and edge cases per
// docs/spec/03-data-models.md §SessionMode.

// Tests legitimately exercise default values for explicit defaults-
// match assertions.
// ignore_for_file: avoid_redundant_argument_values

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/gps_destination_source.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/models/mode_overrides.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/domain/triggers/distress_trigger.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('SessionMode', () {
    group('constructor + defaults', () {
      test('default values match spec 03', () {
        // Arrange + Act
        final m = makeMode();

        // Assert — spec defaults
        check(m.trackingEnabled).isFalse();
        check(m.trackingIntervalSeconds).equals(300);
        check(m.trackingBufferSize).equals(50);
        check(m.pauseAllowed).isTrue();
        check(m.maxPauseMinutes).isNull();
        check(m.isDistressMode).isFalse();
        check(m.allowDisarmAsDistress).isTrue();
        check(m.distressTriggers).isEmpty();
        check(m.disarmTriggers).isEmpty();
        check(m.overrides).isNull();
        check(m.distressModeId).isNull();
        check(m.iconName).isNull();
      });

      test('all required fields stored unchanged', () {
        // Arrange + Act
        final m = makeMode(
          id: 'mode-abc',
          name: 'My Walk',
          steps: [holdStep()],
        );

        // Assert
        check(m.id).equals('mode-abc');
        check(m.name).equals('My Walk');
        check(m.chainSteps.length).equals(1);
      });

      test('iconName stored when provided', () {
        // Arrange + Act
        final m = SessionMode(
          id: 'm',
          name: 'Walk',
          iconName: 'directions_walk',
          chainSteps: [holdStep()],
        );

        // Assert
        check(m.iconName).equals('directions_walk');
      });

      test('isDistressMode=true is stored', () {
        // Arrange + Act
        final m = makeDistressMode();

        // Assert
        check(m.isDistressMode).isTrue();
      });

      test('allowDisarmAsDistress can be set to false (paranoid mode)', () {
        // Arrange + Act
        final m = SessionMode(
          id: 'paranoid',
          name: 'Paranoid',
          chainSteps: [holdStep()],
          allowDisarmAsDistress: false,
        );

        // Assert — G-014
        check(m.allowDisarmAsDistress).isFalse();
      });
    });

    group('JSON round-trip', () {
      test('toJson contains all baseline keys', () {
        // Arrange
        final m = makeMode();

        // Act
        final json = m.toJson();

        // Assert
        check(json).containsKey('id');
        check(json).containsKey('name');
        check(json).containsKey('chainSteps');
        check(json).containsKey('distressTriggers');
        check(json).containsKey('disarmTriggers');
        check(json).containsKey('trackingEnabled');
        check(json).containsKey('trackingIntervalSeconds');
        check(json).containsKey('trackingBufferSize');
        check(json).containsKey('pauseAllowed');
        check(json).containsKey('isDistressMode');
        check(json).containsKey('allowDisarmAsDistress');
      });

      test('toJson omits null distressModeId / iconName / overrides', () {
        // Arrange
        final m = makeMode();

        // Act
        final json = m.toJson();

        // Assert
        check(json.containsKey('distressModeId')).isFalse();
        check(json.containsKey('iconName')).isFalse();
        check(json.containsKey('overrides')).isFalse();
        check(json.containsKey('maxPauseMinutes')).isFalse();
      });

      test('toJson includes distressModeId when set', () {
        // Arrange
        final m = makeMode(distressModeId: 'distress-1');

        // Act
        final json = m.toJson();

        // Assert
        check(json['distressModeId']).equals('distress-1');
      });

      test('fromJson(toJson) preserves equality for minimal mode', () {
        // Arrange
        final original = makeMode();

        // Act
        final restored = SessionMode.fromJson(original.toJson());

        // Assert
        check(restored).equals(original);
      });

      test('fromJson preserves chainSteps order', () {
        // Arrange
        final original = makeMode(
          steps: [
            holdStep(order: 0),
            smsStep(order: 1),
            fakeCallStep(order: 2),
          ],
        );

        // Act
        final restored = SessionMode.fromJson(original.toJson());

        // Assert
        check(restored.chainSteps.length).equals(3);
        check(restored.chainSteps[0].type).equals(ChainStepType.holdButton);
        check(restored.chainSteps[1].type).equals(ChainStepType.smsContact);
        check(restored.chainSteps[2].type).equals(ChainStepType.fakeCall);
      });

      test('fromJson restores distressTriggers list', () {
        // Arrange
        final original = SessionMode(
          id: 'm',
          name: 'M',
          chainSteps: [holdStep()],
          distressTriggers: const [HardwareButtonDistressTrigger()],
        );

        // Act
        final restored = SessionMode.fromJson(original.toJson());

        // Assert
        check(restored.distressTriggers.length).equals(1);
        check(
          restored.distressTriggers.first,
        ).isA<HardwareButtonDistressTrigger>();
      });

      test('fromJson restores disarmTriggers list', () {
        // Arrange
        final original = SessionMode(
          id: 'm',
          name: 'M',
          chainSteps: [holdStep()],
          disarmTriggers: const [
            TimerDisarmTrigger(durationSeconds: 600),
            GpsArrivalDisarmTrigger(
              radiusMeters: 100,
              destinationSource: GpsDestinationSource.fixed,
              lat: 1.0,
              lng: 2.0,
            ),
          ],
        );

        // Act
        final restored = SessionMode.fromJson(original.toJson());

        // Assert
        check(restored.disarmTriggers.length).equals(2);
        check(restored.disarmTriggers[0]).isA<TimerDisarmTrigger>();
        check(restored.disarmTriggers[1]).isA<GpsArrivalDisarmTrigger>();
      });

      test('fromJson restores allowDisarmAsDistress=false', () {
        // Arrange
        final original = SessionMode(
          id: 'm',
          name: 'M',
          chainSteps: [holdStep()],
          allowDisarmAsDistress: false,
        );

        // Act
        final restored = SessionMode.fromJson(original.toJson());

        // Assert
        check(restored.allowDisarmAsDistress).isFalse();
      });

      test('fromJson with missing optional fields applies spec defaults', () {
        // Arrange — JSON without trackingEnabled / triggers / isDistressMode
        final json = <String, dynamic>{
          'id': 'minimal',
          'name': 'Minimal',
          'chainSteps': [holdStep().toJson()],
        };

        // Act
        final restored = SessionMode.fromJson(json);

        // Assert — defaults apply
        check(restored.trackingEnabled).isFalse();
        check(restored.trackingIntervalSeconds).equals(300);
        check(restored.trackingBufferSize).equals(50);
        check(restored.pauseAllowed).isTrue();
        check(restored.isDistressMode).isFalse();
        check(restored.allowDisarmAsDistress).isTrue();
        check(restored.distressTriggers).isEmpty();
        check(restored.disarmTriggers).isEmpty();
      });

      test('fromJson preserves nullable maxPauseMinutes (non-null)', () {
        // Arrange
        final original = SessionMode(
          id: 'm',
          name: 'M',
          chainSteps: [holdStep()],
          maxPauseMinutes: 30,
        );

        // Act
        final restored = SessionMode.fromJson(original.toJson());

        // Assert
        check(restored.maxPauseMinutes).equals(30);
      });
    });

    group('copyWith', () {
      test('with no arguments returns equal object', () {
        // Arrange
        final base = makeMode();

        // Act
        final copy = base.copyWith();

        // Assert
        check(copy).equals(base);
      });

      test('replaces id only', () {
        // Arrange
        final base = makeMode(id: 'old');

        // Act
        final next = base.copyWith(id: 'new');

        // Assert
        check(next.id).equals('new');
        check(next.name).equals(base.name);
      });

      test('replaces name only', () {
        // Arrange
        final base = makeMode(name: 'Walk');

        // Act
        final next = base.copyWith(name: 'Date');

        // Assert
        check(next.name).equals('Date');
      });

      test('replaces chainSteps', () {
        // Arrange
        final base = makeMode(steps: [holdStep()]);
        final newSteps = [holdStep(), smsStep(order: 1)];

        // Act
        final next = base.copyWith(chainSteps: newSteps);

        // Assert
        check(next.chainSteps.length).equals(2);
      });

      test('replaces trackingEnabled', () {
        // Arrange
        final base = makeMode();

        // Act
        final next = base.copyWith(trackingEnabled: true);

        // Assert
        check(next.trackingEnabled).isTrue();
      });

      test('replaces trackingIntervalSeconds + trackingBufferSize', () {
        // Arrange
        final base = makeMode();

        // Act
        final next = base.copyWith(
          trackingIntervalSeconds: 60,
          trackingBufferSize: 200,
        );

        // Assert
        check(next.trackingIntervalSeconds).equals(60);
        check(next.trackingBufferSize).equals(200);
      });

      test('replaces isDistressMode and allowDisarmAsDistress', () {
        // Arrange
        final base = makeMode();

        // Act
        final next = base.copyWith(
          isDistressMode: true,
          allowDisarmAsDistress: false,
        );

        // Assert
        check(next.isDistressMode).isTrue();
        check(next.allowDisarmAsDistress).isFalse();
      });

      test('replaces overrides', () {
        // Arrange
        final base = makeMode();
        const ov = ModeOverrides();

        // Act
        final next = base.copyWith(overrides: ov);

        // Assert
        check(next.overrides).equals(ov);
      });

      test('omitting a field preserves the original value', () {
        // Arrange
        final base = makeMode(name: 'Original');

        // Act — change only id
        final next = base.copyWith(id: 'changed');

        // Assert
        check(next.name).equals('Original');
      });
    });

    group('equality + hashCode', () {
      test('two identically-constructed modes are equal', () {
        // Arrange + Act
        final a = makeMode();
        final b = makeMode();

        // Assert
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('equality is reflexive', () {
        // Arrange
        final m = makeMode();

        // Act + Assert
        check(m).equals(m);
      });

      test('equality is symmetric and transitive', () {
        // Arrange
        final a = makeMode(id: 'eq');
        final b = makeMode(id: 'eq');
        final c = makeMode(id: 'eq');

        // Assert
        check(a == b).isTrue();
        check(b == a).isTrue();
        check(b == c).isTrue();
        check(a == c).isTrue();
      });

      test('different id breaks equality', () {
        // Arrange + Act
        final a = makeMode(id: 'a');
        final b = makeMode(id: 'b');

        // Assert
        check(a == b).isFalse();
      });

      test('different name breaks equality', () {
        // Arrange + Act
        final a = makeMode(name: 'A');
        final b = makeMode(name: 'B');

        // Assert
        check(a == b).isFalse();
      });

      test('different chain length breaks equality', () {
        // Arrange + Act
        final a = makeMode(steps: [holdStep()]);
        final b = makeMode(steps: [holdStep(), smsStep(order: 1)]);

        // Assert
        check(a == b).isFalse();
      });

      test('different distressModeId breaks equality', () {
        // Arrange + Act
        final a = makeMode(distressModeId: 'd1');
        final b = makeMode(distressModeId: 'd2');

        // Assert
        check(a == b).isFalse();
      });

      test('different isDistressMode breaks equality', () {
        // Arrange
        final a = SessionMode(id: 'm', name: 'M', chainSteps: [holdStep()]);
        final b = SessionMode(
          id: 'm',
          name: 'M',
          chainSteps: [holdStep()],
          isDistressMode: true,
        );

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different allowDisarmAsDistress breaks equality', () {
        // Arrange
        final a = SessionMode(id: 'm', name: 'M', chainSteps: [holdStep()]);
        final b = SessionMode(
          id: 'm',
          name: 'M',
          chainSteps: [holdStep()],
          allowDisarmAsDistress: false,
        );

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different distressTriggers list breaks equality', () {
        // Arrange
        final a = makeMode();
        final b = SessionMode(
          id: 'mode-Test',
          name: 'Test',
          chainSteps: [holdStep()],
          distressTriggers: const [HardwareButtonDistressTrigger()],
        );

        // Act + Assert
        check(a == b).isFalse();
      });

      test('hashCode equals when modes are equal', () {
        // Arrange + Act
        final a = makeMode();
        final b = makeMode();

        // Assert
        check(a.hashCode).equals(b.hashCode);
      });
    });

    group('validation', () {
      test('rejects empty id', () {
        // Act + Assert
        check(
          () => SessionMode(id: '', name: 'Mode', chainSteps: [holdStep()]),
        ).throws<AssertionError>();
      });

      test('rejects empty name', () {
        // Act + Assert
        check(
          () => SessionMode(id: 'm', name: '', chainSteps: [holdStep()]),
        ).throws<AssertionError>();
      });

      test('rejects empty chainSteps (must have at least 1 step)', () {
        // Act + Assert — spec 03 line 731: "Cannot save empty: Must
        // have at least 1 chain step"
        check(
          () => SessionMode(id: 'm', name: 'M', chainSteps: const []),
        ).throws<AssertionError>();
      });

      test('rejects trackingIntervalSeconds = 0', () {
        // Act + Assert
        check(
          () => SessionMode(
            id: 'm',
            name: 'M',
            chainSteps: [holdStep()],
            trackingIntervalSeconds: 0,
          ),
        ).throws<AssertionError>();
      });

      test('rejects trackingIntervalSeconds < 0', () {
        // Act + Assert
        check(
          () => SessionMode(
            id: 'm',
            name: 'M',
            chainSteps: [holdStep()],
            trackingIntervalSeconds: -10,
          ),
        ).throws<AssertionError>();
      });

      test('rejects trackingBufferSize = 0', () {
        // Act + Assert
        check(
          () => SessionMode(
            id: 'm',
            name: 'M',
            chainSteps: [holdStep()],
            trackingBufferSize: 0,
          ),
        ).throws<AssertionError>();
      });

      test('accepts single-step chain (boundary)', () {
        // Arrange + Act
        final m = SessionMode(
          id: 'm',
          name: 'Single',
          chainSteps: [holdStep()],
        );

        // Assert
        check(m.chainSteps.length).equals(1);
      });

      test('preserves long chain of multiple step types', () {
        // Arrange + Act
        final m = makeMode(
          steps: [
            holdStep(order: 0),
            fakeCallStep(order: 1),
            smsStep(order: 2),
          ],
        );

        // Assert
        check(m.chainSteps.length).equals(3);
        check(m.chainSteps.last.order).equals(2);
      });

      test('round-trips HardwareButtonDistressTrigger with longPress', () {
        // Arrange
        final original = SessionMode(
          id: 'm',
          name: 'M',
          chainSteps: [holdStep()],
          distressTriggers: const [
            HardwareButtonDistressTrigger(
              buttonType: ButtonType.volumeDown,
              pattern: PressPattern.longPress,
              pressCount: 5,
              durationSeconds: 2.5,
            ),
          ],
        );

        // Act
        final restored = SessionMode.fromJson(original.toJson());

        // Assert
        check(restored.distressTriggers.length).equals(1);
        final t =
            restored.distressTriggers.first as HardwareButtonDistressTrigger;
        check(t.buttonType).equals(ButtonType.volumeDown);
        check(t.pattern).equals(PressPattern.longPress);
        check(t.durationSeconds).equals(2.5);
      });
    });
  });
}
