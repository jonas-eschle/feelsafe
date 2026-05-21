// Unit tests for [BatteryAlertConfig].
//
// Verifies constructor defaults, threshold validation, chain validation
// (forbidden interactive step types), JSON round-trip, copyWith, and
// equality / hashCode contract per docs/spec/03-data-models.md
// §BatteryAlertConfig, spec 06 §Battery Alert Section, and Q22.

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/battery_alert_config.dart';
import 'package:guardianangela/domain/models/chain_step.dart';

/// Builds a [ChainStep] of the given type with sensible test defaults.
ChainStep _step({
  required ChainStepType type,
  String? id,
  int order = 0,
  int durationSeconds = 10,
  int gracePeriodSeconds = 0,
  int waitSeconds = 0,
  int retryCount = 0,
  bool randomize = false,
  StepConfig? config,
}) => ChainStep(
  id: id ?? 'step-$order-${type.name}',
  type: type,
  order: order,
  waitSeconds: waitSeconds,
  durationSeconds: durationSeconds,
  gracePeriodSeconds: gracePeriodSeconds,
  retryCount: retryCount,
  randomize: randomize,
  config: config,
);

void main() {
  group('BatteryAlertConfig', () {
    group('defaults', () {
      test('enabled defaults to false (Q22 — opt-in)', () {
        // Arrange + Act
        final cfg = BatteryAlertConfig();

        // Assert
        check(cfg.enabled).isFalse();
      });

      test('thresholdPercent defaults to 10', () {
        // Arrange + Act
        final cfg = BatteryAlertConfig();

        // Assert
        check(cfg.thresholdPercent).equals(10);
      });

      test('chain defaults to empty list', () {
        // Arrange + Act
        final cfg = BatteryAlertConfig();

        // Assert
        check(cfg.chain).isEmpty();
      });

      test('non-default values stored unchanged', () {
        // Arrange
        final step = _step(type: ChainStepType.smsContact);

        // Act
        final cfg = BatteryAlertConfig(
          enabled: true,
          thresholdPercent: 25,
          chain: [step],
        );

        // Assert
        check(cfg.enabled).isTrue();
        check(cfg.thresholdPercent).equals(25);
        check(cfg.chain).length.equals(1);
        check(cfg.chain.first).equals(step);
      });
    });

    group('validation', () {
      test('rejects thresholdPercent = 0', () {
        // Act + Assert
        check(
          () => BatteryAlertConfig(thresholdPercent: 0),
        ).throws<AssertionError>();
      });

      test('rejects negative thresholdPercent', () {
        // Act + Assert
        check(
          () => BatteryAlertConfig(thresholdPercent: -1),
        ).throws<AssertionError>();
      });

      test('rejects thresholdPercent = 100', () {
        // Lib enforces upper bound of 99 (assert 1-99).
        // Act + Assert
        check(
          () => BatteryAlertConfig(thresholdPercent: 100),
        ).throws<AssertionError>();
      });

      test('accepts thresholdPercent = 1 (lower boundary)', () {
        // Arrange + Act
        final cfg = BatteryAlertConfig(thresholdPercent: 1);

        // Assert
        check(cfg.thresholdPercent).equals(1);
      });

      test('accepts thresholdPercent = 99 (upper boundary)', () {
        // Arrange + Act
        final cfg = BatteryAlertConfig(thresholdPercent: 99);

        // Assert
        check(cfg.thresholdPercent).equals(99);
      });

      test('accepts thresholdPercent within typical UI range (5-50)', () {
        // Spec 06 advertises a 5–50 UI slider range; lib accepts 1–99.
        // Arrange + Act
        final cfg = BatteryAlertConfig(thresholdPercent: 30);

        // Assert
        check(cfg.thresholdPercent).equals(30);
      });

      test('rejects forbidden holdButton step in chain', () {
        // Arrange
        final step = _step(type: ChainStepType.holdButton);

        // Act + Assert
        check(() => BatteryAlertConfig(chain: [step])).throws<ArgumentError>();
      });

      test('rejects forbidden disguisedReminder step in chain', () {
        // Arrange
        final step = _step(type: ChainStepType.disguisedReminder);

        // Act + Assert
        check(() => BatteryAlertConfig(chain: [step])).throws<ArgumentError>();
      });

      test('rejects forbidden hardwareButton step in chain', () {
        // Arrange
        final step = _step(type: ChainStepType.hardwareButton);

        // Act + Assert
        check(() => BatteryAlertConfig(chain: [step])).throws<ArgumentError>();
      });

      test(
        'forbiddenStepTypes contains exactly the three interactive types',
        () {
          // Arrange + Act + Assert
          check(
            BatteryAlertConfig.forbiddenStepTypes,
          ).deepEquals(<ChainStepType>{
            ChainStepType.holdButton,
            ChainStepType.disguisedReminder,
            ChainStepType.hardwareButton,
          });
        },
      );

      test('accepts smsContact step in chain', () {
        // Arrange + Act
        final cfg = BatteryAlertConfig(
          chain: [_step(type: ChainStepType.smsContact)],
        );

        // Assert
        check(cfg.chain).length.equals(1);
      });

      test('accepts phoneCallContact, callEmergency, loudAlarm steps', () {
        // Arrange + Act
        final cfg = BatteryAlertConfig(
          chain: [
            _step(type: ChainStepType.phoneCallContact),
            _step(type: ChainStepType.callEmergency, order: 1),
            _step(type: ChainStepType.loudAlarm, order: 2),
          ],
        );

        // Assert
        check(cfg.chain).length.equals(3);
      });

      test('accepts countdownWarning and fakeCall steps', () {
        // Per spec 03 §BatteryAlertConfig ITEM 8 — countdown and fakeCall
        // are explicitly allowed.
        // Arrange + Act
        final cfg = BatteryAlertConfig(
          chain: [
            _step(type: ChainStepType.countdownWarning),
            _step(type: ChainStepType.fakeCall, order: 1),
          ],
        );

        // Assert
        check(cfg.chain).length.equals(2);
      });

      test('validateChain throws ArgumentError for forbidden step', () {
        // Arrange
        final steps = [_step(type: ChainStepType.holdButton)];

        // Act + Assert
        check(
          () => BatteryAlertConfig.validateChain(steps),
        ).throws<ArgumentError>();
      });

      test('validateChain is a no-op for an empty list', () {
        // Act + Assert — does not throw.
        BatteryAlertConfig.validateChain(const []);
      });

      test('validateChain accepts a mixed valid chain', () {
        // Act + Assert — does not throw.
        BatteryAlertConfig.validateChain([
          _step(type: ChainStepType.smsContact),
          _step(type: ChainStepType.loudAlarm, order: 1),
        ]);
      });
    });

    group('JSON round-trip', () {
      test('toJson contains the three expected keys', () {
        // Arrange
        final cfg = BatteryAlertConfig();

        // Act
        final json = cfg.toJson();

        // Assert
        check(json).containsKey('enabled');
        check(json).containsKey('thresholdPercent');
        check(json).containsKey('chain');
      });

      test('toJson encodes chain as a list of step JSON maps', () {
        // Arrange
        final cfg = BatteryAlertConfig(
          chain: [_step(type: ChainStepType.smsContact)],
        );

        // Act
        final json = cfg.toJson();

        // Assert
        check(json['chain']).isA<List<dynamic>>();
        check((json['chain']! as List).length).equals(1);
      });

      test('fromJson(toJson) round-trips empty default config', () {
        // Arrange
        final original = BatteryAlertConfig();

        // Act
        final restored = BatteryAlertConfig.fromJson(original.toJson());

        // Assert
        check(restored).equals(original);
      });

      test('fromJson(toJson) round-trips fully customised config', () {
        // Arrange
        final original = BatteryAlertConfig(
          enabled: true,
          thresholdPercent: 20,
          chain: [
            _step(type: ChainStepType.smsContact),
            _step(type: ChainStepType.loudAlarm, order: 1),
          ],
        );

        // Act
        final restored = BatteryAlertConfig.fromJson(original.toJson());

        // Assert
        check(restored).equals(original);
      });

      test('fromJson applies defaults to empty map', () {
        // Arrange + Act
        final cfg = BatteryAlertConfig.fromJson(const <String, dynamic>{});

        // Assert
        check(cfg.enabled).isFalse();
        check(cfg.thresholdPercent).equals(10);
        check(cfg.chain).isEmpty();
      });

      test('fromJson preserves chain order', () {
        // Arrange
        final original = BatteryAlertConfig(
          chain: [
            _step(id: 'first', type: ChainStepType.smsContact),
            _step(id: 'second', type: ChainStepType.loudAlarm, order: 1),
            _step(id: 'third', type: ChainStepType.callEmergency, order: 2),
          ],
        );

        // Act
        final restored = BatteryAlertConfig.fromJson(original.toJson());

        // Assert
        check(restored.chain.length).equals(3);
        check(restored.chain[0].id).equals('first');
        check(restored.chain[1].id).equals('second');
        check(restored.chain[2].id).equals('third');
      });

      test('fromJson preserves step content (type, timing)', () {
        // Arrange
        final original = BatteryAlertConfig(
          chain: [
            _step(
              type: ChainStepType.loudAlarm,
              durationSeconds: 7,
              gracePeriodSeconds: 3,
              waitSeconds: 2,
              retryCount: 1,
            ),
          ],
        );

        // Act
        final restored = BatteryAlertConfig.fromJson(original.toJson());

        // Assert
        final step = restored.chain.single;
        check(step.type).equals(ChainStepType.loudAlarm);
        check(step.durationSeconds).equals(7);
        check(step.gracePeriodSeconds).equals(3);
        check(step.waitSeconds).equals(2);
        check(step.retryCount).equals(1);
      });

      test('fromJson tolerates thresholdPercent encoded as double', () {
        // Arrange
        final json = <String, dynamic>{
          'enabled': true,
          'thresholdPercent': 20.0,
          'chain': <dynamic>[],
        };

        // Act
        final cfg = BatteryAlertConfig.fromJson(json);

        // Assert
        check(cfg.thresholdPercent).equals(20);
      });

      test('fromJson treats absent chain as empty list', () {
        // Arrange + Act
        final cfg = BatteryAlertConfig.fromJson(const <String, dynamic>{
          'enabled': true,
          'thresholdPercent': 30,
        });

        // Assert
        check(cfg.chain).isEmpty();
      });
    });

    group('copyWith', () {
      test('with no arguments returns equal object', () {
        // Arrange
        final base = BatteryAlertConfig();

        // Act
        final copy = base.copyWith();

        // Assert
        check(copy).equals(base);
      });

      test('replaces enabled only', () {
        // Arrange
        final base = BatteryAlertConfig();

        // Act
        final next = base.copyWith(enabled: true);

        // Assert
        check(next.enabled).isTrue();
        check(next.thresholdPercent).equals(base.thresholdPercent);
        check(next.chain).deepEquals(base.chain);
      });

      test('replaces thresholdPercent only', () {
        // Arrange
        final base = BatteryAlertConfig();

        // Act
        final next = base.copyWith(thresholdPercent: 25);

        // Assert
        check(next.thresholdPercent).equals(25);
        check(next.enabled).equals(base.enabled);
        check(next.chain).deepEquals(base.chain);
      });

      test('replaces chain only', () {
        // Arrange
        final base = BatteryAlertConfig();
        final newChain = [_step(type: ChainStepType.smsContact)];

        // Act
        final next = base.copyWith(chain: newChain);

        // Assert
        check(next.chain).length.equals(1);
        check(next.enabled).equals(base.enabled);
        check(next.thresholdPercent).equals(base.thresholdPercent);
      });

      test('replaces all fields together', () {
        // Arrange
        final base = BatteryAlertConfig();

        // Act
        final next = base.copyWith(
          enabled: true,
          thresholdPercent: 5,
          chain: [_step(type: ChainStepType.callEmergency)],
        );

        // Assert
        check(next.enabled).isTrue();
        check(next.thresholdPercent).equals(5);
        check(next.chain).length.equals(1);
      });

      test('copyWith with invalid thresholdPercent fires assert', () {
        // The copy is built via the constructor, so the same assert
        // applies to copyWith.
        // Arrange
        final base = BatteryAlertConfig();

        // Act + Assert
        check(
          () => base.copyWith(thresholdPercent: 0),
        ).throws<AssertionError>();
      });

      test('copyWith with forbidden chain step rejects', () {
        // Arrange
        final base = BatteryAlertConfig();

        // Act + Assert
        check(
          () => base.copyWith(chain: [_step(type: ChainStepType.holdButton)]),
        ).throws<ArgumentError>();
      });
    });

    group('equality + hashCode', () {
      test('two default configs are equal', () {
        // Arrange
        final a = BatteryAlertConfig();
        final b = BatteryAlertConfig();

        // Act + Assert
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('equality is reflexive', () {
        // Arrange
        final cfg = BatteryAlertConfig();

        // Act + Assert
        check(cfg).equals(cfg);
      });

      test('equality is symmetric and transitive', () {
        // Arrange
        final a = BatteryAlertConfig(enabled: true, thresholdPercent: 20);
        final b = BatteryAlertConfig(enabled: true, thresholdPercent: 20);
        final c = BatteryAlertConfig(enabled: true, thresholdPercent: 20);

        // Assert
        check(a == b).isTrue();
        check(b == a).isTrue();
        check(b == c).isTrue();
        check(a == c).isTrue();
      });

      test('different enabled breaks equality', () {
        // Arrange
        final a = BatteryAlertConfig();
        final b = BatteryAlertConfig(enabled: true);

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different thresholdPercent breaks equality', () {
        // Arrange
        final a = BatteryAlertConfig();
        final b = BatteryAlertConfig(thresholdPercent: 20);

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different chain length breaks equality', () {
        // Arrange
        final a = BatteryAlertConfig();
        final b = BatteryAlertConfig(
          chain: [_step(type: ChainStepType.smsContact)],
        );

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different chain step content breaks equality', () {
        // Arrange
        final a = BatteryAlertConfig(
          chain: [_step(id: 'a', type: ChainStepType.smsContact)],
        );
        final b = BatteryAlertConfig(
          chain: [_step(id: 'b', type: ChainStepType.smsContact)],
        );

        // Act + Assert
        check(a == b).isFalse();
      });

      test('chain order matters for equality', () {
        // Arrange
        final a = BatteryAlertConfig(
          chain: [
            _step(id: 'one', type: ChainStepType.smsContact),
            _step(id: 'two', type: ChainStepType.loudAlarm, order: 1),
          ],
        );
        final b = BatteryAlertConfig(
          chain: [
            _step(id: 'two', type: ChainStepType.loudAlarm, order: 1),
            _step(id: 'one', type: ChainStepType.smsContact),
          ],
        );

        // Act + Assert
        check(a == b).isFalse();
      });

      test('hashCode equals when configs are equal', () {
        // Arrange
        final a = BatteryAlertConfig(
          enabled: true,
          thresholdPercent: 30,
          chain: [_step(type: ChainStepType.smsContact)],
        );
        final b = BatteryAlertConfig(
          enabled: true,
          thresholdPercent: 30,
          chain: [_step(type: ChainStepType.smsContact)],
        );

        // Act + Assert
        check(a.hashCode).equals(b.hashCode);
      });

      test('not equal to object of different type', () {
        // Arrange
        final cfg = BatteryAlertConfig();

        // Act + Assert
        check(cfg == const Object()).isFalse();
      });
    });
  });
}
