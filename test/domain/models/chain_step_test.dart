// Unit tests for [ChainStep].
//
// Verifies the constructor invariants, JSON round-trip, copyWith
// behaviour, equality / hashCode contract, and edge cases per
// docs/spec/03-data-models.md §ChainStep.

// Tests legitimately exercise default values for explicit defaults-
// match assertions.
// ignore_for_file: avoid_redundant_argument_values

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/hold_style.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('ChainStep', () {
    group('constructor + defaults', () {
      test('all required fields are stored unchanged', () {
        // Arrange + Act
        final stepInstance = ChainStep(
          id: 'step-1',
          type: ChainStepType.fakeCall,
          order: 2,
          waitSeconds: 1,
          durationSeconds: 30,
          gracePeriodSeconds: 5,
          retryCount: 1,
          randomize: true,
        );

        // Assert
        check(stepInstance.id).equals('step-1');
        check(stepInstance.type).equals(ChainStepType.fakeCall);
        check(stepInstance.order).equals(2);
        check(stepInstance.waitSeconds).equals(1);
        check(stepInstance.durationSeconds).equals(30);
        check(stepInstance.gracePeriodSeconds).equals(5);
        check(stepInstance.retryCount).equals(1);
        check(stepInstance.randomize).isTrue();
        check(stepInstance.config).isNull();
      });

      test('config defaults to null (inherit EventDefaults)', () {
        // Arrange + Act
        final s = step();

        // Assert
        check(s.config).isNull();
      });

      test('helper step() defaults match spec-style minimal step', () {
        // Arrange + Act
        final s = step();

        // Assert
        check(s.type).equals(ChainStepType.holdButton);
        check(s.order).equals(0);
        check(s.waitSeconds).equals(0);
        check(s.durationSeconds).equals(30);
        check(s.gracePeriodSeconds).equals(5);
        check(s.retryCount).equals(0);
        check(s.randomize).isFalse();
      });

      test('config is preserved when provided', () {
        // Arrange + Act
        final s = step(
          type: ChainStepType.holdButton,
          config: const HoldButtonConfig(holdStyle: HoldStyle.fullScreen),
        );

        // Assert
        check(s.config).isNotNull();
        check(s.config!).isA<HoldButtonConfig>();
      });
    });

    group('duration getters', () {
      test('waitDuration wraps waitSeconds', () {
        // Arrange
        final s = step(waitSeconds: 1800);

        // Act + Assert
        check(s.waitDuration).equals(const Duration(seconds: 1800));
      });

      test('activeDuration wraps durationSeconds', () {
        // Arrange
        final s = step(durationSeconds: 60);

        // Act + Assert
        check(s.activeDuration).equals(const Duration(seconds: 60));
      });

      test('gracePeriod wraps gracePeriodSeconds', () {
        // Arrange
        final s = step(gracePeriodSeconds: 12);

        // Act + Assert
        check(s.gracePeriod).equals(const Duration(seconds: 12));
      });

      test('totalCycleSeconds sums all three phases', () {
        // Arrange
        final s = step(
          waitSeconds: 10,
          durationSeconds: 20,
          gracePeriodSeconds: 5,
        );

        // Act + Assert
        check(s.totalCycleSeconds).equals(35);
      });

      test('totalCycleSeconds with all-zero step is zero', () {
        // Arrange
        final s = step(durationSeconds: 0, gracePeriodSeconds: 0);

        // Act + Assert
        check(s.totalCycleSeconds).equals(0);
      });
    });

    group('JSON round-trip', () {
      test('toJson contains all required keys', () {
        // Arrange
        final s = step(
          id: 'step-x',
          waitSeconds: 0,
          durationSeconds: 10,
          gracePeriodSeconds: 5,
          retryCount: 0,
        );

        // Act
        final json = s.toJson();

        // Assert
        check(json).containsKey('id');
        check(json).containsKey('type');
        check(json).containsKey('order');
        check(json).containsKey('waitSeconds');
        check(json).containsKey('durationSeconds');
        check(json).containsKey('gracePeriodSeconds');
        check(json).containsKey('retryCount');
        check(json).containsKey('randomize');
      });

      test('toJson omits config when null', () {
        // Arrange
        final s = step();

        // Act
        final json = s.toJson();

        // Assert
        check(json.containsKey('config')).isFalse();
      });

      test('toJson includes config when non-null', () {
        // Arrange
        final s = step(config: const HoldButtonConfig());

        // Act
        final json = s.toJson();

        // Assert
        check(json).containsKey('config');
        check(json['config']).isA<Map<String, dynamic>>();
      });

      test('toJson encodes type by enum name string (not index)', () {
        // Arrange
        final s = step(type: ChainStepType.smsContact);

        // Act
        final json = s.toJson();

        // Assert
        check(json['type']).equals('smsContact');
      });

      test('fromJson(toJson) preserves equality for minimal step', () {
        // Arrange
        final original = step(
          id: 'rt-1',
          type: ChainStepType.fakeCall,
          order: 1,
          durationSeconds: 30,
          gracePeriodSeconds: 5,
        );

        // Act
        final restored = ChainStep.fromJson(original.toJson());

        // Assert
        check(restored).equals(original);
      });

      test('fromJson(toJson) preserves config payload', () {
        // Arrange
        final original = step(
          type: ChainStepType.holdButton,
          config: const HoldButtonConfig(
            holdStyle: HoldStyle.fullScreen,
            releaseSensitivity: 0.7,
            vibrateOnRelease: false,
          ),
        );

        // Act
        final restored = ChainStep.fromJson(original.toJson());

        // Assert
        check(restored.config).isNotNull();
        check(restored.config!).isA<HoldButtonConfig>();
        final cfg = restored.config! as HoldButtonConfig;
        check(cfg.holdStyle).equals(HoldStyle.fullScreen);
        check(cfg.releaseSensitivity).equals(0.7);
        check(cfg.vibrateOnRelease).isFalse();
      });

      test('fromJson restores SmsContactConfig via discriminator', () {
        // Arrange
        final original = step(
          type: ChainStepType.smsContact,
          config: const SmsContactConfig(
            contactSelection: SmsContactSelection.firstContact,
            includeLocation: false,
          ),
        );

        // Act
        final restored = ChainStep.fromJson(original.toJson());

        // Assert
        check(restored.config).isNotNull();
        check(restored.config!).isA<SmsContactConfig>();
        check(
          (restored.config! as SmsContactConfig).contactSelection,
        ).equals(SmsContactSelection.firstContact);
      });

      test('fromJson preserves nullable config (null round-trips)', () {
        // Arrange
        final original = step();

        // Act
        final restored = ChainStep.fromJson(original.toJson());

        // Assert
        check(restored.config).isNull();
      });

      test('fromJson restores randomize=true', () {
        // Arrange
        final original = step(randomize: true);

        // Act
        final restored = ChainStep.fromJson(original.toJson());

        // Assert
        check(restored.randomize).isTrue();
      });
    });

    group('copyWith', () {
      test('with no arguments returns equal object', () {
        // Arrange
        final base = step(id: 'a', durationSeconds: 30, gracePeriodSeconds: 5);

        // Act
        final copy = base.copyWith();

        // Assert
        check(copy).equals(base);
      });

      test('replaces id only', () {
        // Arrange
        final base = step(id: 'old-id');

        // Act
        final next = base.copyWith(id: 'new-id');

        // Assert
        check(next.id).equals('new-id');
        check(next.type).equals(base.type);
        check(next.order).equals(base.order);
      });

      test('replaces order only', () {
        // Arrange
        final base = step(order: 0);

        // Act
        final next = base.copyWith(order: 7);

        // Assert
        check(next.order).equals(7);
        check(next.id).equals(base.id);
      });

      test('replaces type only', () {
        // Arrange
        final base = step(type: ChainStepType.holdButton);

        // Act
        final next = base.copyWith(type: ChainStepType.fakeCall);

        // Assert
        check(next.type).equals(ChainStepType.fakeCall);
      });

      test('replaces all three timing fields', () {
        // Arrange
        final base = step();

        // Act
        final next = base.copyWith(
          waitSeconds: 30,
          durationSeconds: 60,
          gracePeriodSeconds: 10,
        );

        // Assert
        check(next.waitSeconds).equals(30);
        check(next.durationSeconds).equals(60);
        check(next.gracePeriodSeconds).equals(10);
      });

      test('replaces retryCount and randomize', () {
        // Arrange
        final base = step(retryCount: 0, randomize: false);

        // Act
        final next = base.copyWith(retryCount: 3, randomize: true);

        // Assert
        check(next.retryCount).equals(3);
        check(next.randomize).isTrue();
      });

      test('omitting a field preserves the original value', () {
        // Arrange
        final base = step(durationSeconds: 99);

        // Act — only change unrelated field
        final next = base.copyWith(order: 5);

        // Assert
        check(next.durationSeconds).equals(99);
        check(next.order).equals(5);
      });

      test('replaces config', () {
        // Arrange
        final base = step(config: const HoldButtonConfig());

        // Act
        final next = base.copyWith(
          config: const HoldButtonConfig(holdStyle: HoldStyle.fakeLockScreen),
        );

        // Assert
        check(next.config).isNotNull();
        final cfg = next.config! as HoldButtonConfig;
        check(cfg.holdStyle).equals(HoldStyle.fakeLockScreen);
      });
    });

    group('equality + hashCode', () {
      test('two identically-constructed steps are equal', () {
        // Arrange + Act
        final a = step(id: 'eq-1');
        final b = step(id: 'eq-1');

        // Assert
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('equality is reflexive', () {
        // Arrange + Act
        final s = step();

        // Assert
        check(s).equals(s);
      });

      test('equality is symmetric and transitive over three instances', () {
        // Arrange
        final a = step(id: 't-1');
        final b = step(id: 't-1');
        final c = step(id: 't-1');

        // Assert — symmetric
        check(a == b).isTrue();
        check(b == a).isTrue();
        // Transitive
        check(b == c).isTrue();
        check(a == c).isTrue();
      });

      test('different id breaks equality', () {
        // Arrange
        final a = step(id: 'x');
        final b = step(id: 'y');

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different order breaks equality', () {
        // Arrange
        final a = step(order: 0);
        final b = step(order: 1);

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different type breaks equality', () {
        // Arrange
        final a = step(type: ChainStepType.holdButton);
        final b = step(type: ChainStepType.fakeCall);

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different durationSeconds breaks equality', () {
        // Arrange
        final a = step(durationSeconds: 10);
        final b = step(durationSeconds: 20);

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different randomize breaks equality', () {
        // Arrange
        final a = step(randomize: false);
        final b = step(randomize: true);

        // Act + Assert
        check(a == b).isFalse();
      });

      test('different config breaks equality', () {
        // Arrange
        final a = step(config: const HoldButtonConfig());
        final b = step(
          config: const HoldButtonConfig(holdStyle: HoldStyle.fullScreen),
        );

        // Act + Assert
        check(a == b).isFalse();
      });

      test('hashCode equals when objects are equal', () {
        // Arrange
        final a = step(
          id: 'h-1',
          waitSeconds: 0,
          durationSeconds: 30,
          gracePeriodSeconds: 5,
        );
        final b = step(
          id: 'h-1',
          waitSeconds: 0,
          durationSeconds: 30,
          gracePeriodSeconds: 5,
        );

        // Act + Assert
        check(a.hashCode).equals(b.hashCode);
      });
    });

    group('validation', () {
      test('rejects empty id', () {
        // Act + Assert
        check(
          () => ChainStep(
            id: '',
            type: ChainStepType.holdButton,
            order: 0,
            waitSeconds: 0,
            durationSeconds: 30,
            gracePeriodSeconds: 5,
            retryCount: 0,
            randomize: false,
          ),
        ).throws<AssertionError>();
      });

      test('rejects order < 0', () {
        // Act + Assert
        check(
          () => ChainStep(
            id: 'x',
            type: ChainStepType.holdButton,
            order: -1,
            waitSeconds: 0,
            durationSeconds: 30,
            gracePeriodSeconds: 5,
            retryCount: 0,
            randomize: false,
          ),
        ).throws<AssertionError>();
      });

      test('rejects waitSeconds < 0', () {
        // Act + Assert
        check(
          () => ChainStep(
            id: 'x',
            type: ChainStepType.holdButton,
            order: 0,
            waitSeconds: -1,
            durationSeconds: 30,
            gracePeriodSeconds: 5,
            retryCount: 0,
            randomize: false,
          ),
        ).throws<AssertionError>();
      });

      test('rejects durationSeconds < 0', () {
        // Act + Assert
        check(
          () => ChainStep(
            id: 'x',
            type: ChainStepType.holdButton,
            order: 0,
            waitSeconds: 0,
            durationSeconds: -5,
            gracePeriodSeconds: 5,
            retryCount: 0,
            randomize: false,
          ),
        ).throws<AssertionError>();
      });

      test('rejects gracePeriodSeconds < 0', () {
        // Act + Assert
        check(
          () => ChainStep(
            id: 'x',
            type: ChainStepType.holdButton,
            order: 0,
            waitSeconds: 0,
            durationSeconds: 30,
            gracePeriodSeconds: -1,
            retryCount: 0,
            randomize: false,
          ),
        ).throws<AssertionError>();
      });

      test('rejects retryCount < 0', () {
        // Act + Assert
        check(
          () => ChainStep(
            id: 'x',
            type: ChainStepType.holdButton,
            order: 0,
            waitSeconds: 0,
            durationSeconds: 30,
            gracePeriodSeconds: 5,
            retryCount: -1,
            randomize: false,
          ),
        ).throws<AssertionError>();
      });

      test('accepts order=0 and all-zero timing (boundary)', () {
        // Arrange + Act
        final s = ChainStep(
          id: 'zero',
          type: ChainStepType.hardwareButton,
          order: 0,
          waitSeconds: 0,
          durationSeconds: 0,
          gracePeriodSeconds: 0,
          retryCount: 0,
          randomize: false,
        );

        // Assert
        check(s.totalCycleSeconds).equals(0);
      });
    });
  });
}
