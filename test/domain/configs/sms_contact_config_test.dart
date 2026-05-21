// Unit tests for [SmsContactConfig].
//
// Verifies constructor defaults, JSON round-trip, copyWith behaviour,
// equality / hashCode contract, and edge cases per
// docs/spec/03-data-models.md §SmsContactConfig (spec 03:373-394 and
// the contact-button UI section). Asserts the field set matches the
// post-REJ-3 / post-commit 936515d shape: no `autoRecordVideo` field.
//
// ignore_for_file: avoid_redundant_argument_values
// Tests intentionally pass default values to verify round-trip and
// equality semantics.

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';

void main() {
  group('SmsContactConfig', () {
    group('constructor defaults', () {
      test('contactIds defaults to null', () {
        // Arrange + Act
        const cfg = SmsContactConfig();

        // Assert
        check(cfg.contactIds).isNull();
      });

      test('contactSelection defaults to allContacts (ITEM 6)', () {
        // Arrange + Act
        const cfg = SmsContactConfig();

        // Assert
        check(cfg.contactSelection).equals(SmsContactSelection.allContacts);
      });

      test('channel defaults to sms (decision 15/15b)', () {
        // Arrange + Act
        const cfg = SmsContactConfig();

        // Assert
        check(cfg.channel).equals(MessageChannel.sms);
      });

      test('includeLocation defaults to true', () {
        // Arrange + Act
        const cfg = SmsContactConfig();

        // Assert
        check(cfg.includeLocation).isTrue();
      });

      test('includeMedicalInfo defaults to false (per-step C3 toggle)', () {
        // Arrange + Act
        const cfg = SmsContactConfig();

        // Assert
        check(cfg.includeMedicalInfo).isFalse();
      });

      test('autoRecordAudio defaults to false', () {
        // Arrange + Act
        const cfg = SmsContactConfig();

        // Assert
        check(cfg.autoRecordAudio).isFalse();
      });

      test('recordDurationSeconds defaults to 30', () {
        // Arrange + Act
        const cfg = SmsContactConfig();

        // Assert
        check(cfg.recordDurationSeconds).equals(30);
      });

      test('messageTemplate defaults to null (inherits seed default per spec '
          '03:382-391)', () {
        // Arrange + Act
        const cfg = SmsContactConfig();

        // Assert
        check(cfg.messageTemplate).isNull();
      });

      test('blackScreenMode defaults to false', () {
        // Arrange + Act
        const cfg = SmsContactConfig();

        // Assert
        check(cfg.blackScreenMode).isFalse();
      });
    });

    group('field schema (REJ-3 / commit 936515d parity)', () {
      test('toJson omits autoRecordVideo key (REJ-3 removed it)', () {
        // Arrange
        const cfg = SmsContactConfig();

        // Act
        final json = cfg.toJson();

        // Assert
        check(json.containsKey('autoRecordVideo')).isFalse();
      });

      test('toJson exposes all expected keys when fully populated', () {
        // Arrange
        const cfg = SmsContactConfig(
          contactIds: ['c1', 'c2'],
          contactSelection: SmsContactSelection.specificIds,
          channel: MessageChannel.whatsapp,
          includeLocation: false,
          includeMedicalInfo: true,
          autoRecordAudio: true,
          recordDurationSeconds: 45,
          messageTemplate: 'Help me at {location}',
          blackScreenMode: true,
        );

        // Act
        final json = cfg.toJson();

        // Assert
        check(json.containsKey('contactIds')).isTrue();
        check(json.containsKey('contactSelection')).isTrue();
        check(json.containsKey('channel')).isTrue();
        check(json.containsKey('includeLocation')).isTrue();
        check(json.containsKey('includeMedicalInfo')).isTrue();
        check(json.containsKey('autoRecordAudio')).isTrue();
        check(json.containsKey('recordDurationSeconds')).isTrue();
        check(json.containsKey('messageTemplate')).isTrue();
        check(json.containsKey('blackScreenMode')).isTrue();
      });

      test('toJson omits contactIds when null', () {
        // Arrange
        const cfg = SmsContactConfig();

        // Act
        final json = cfg.toJson();

        // Assert
        check(json.containsKey('contactIds')).isFalse();
      });

      test('toJson omits messageTemplate when null', () {
        // Arrange
        const cfg = SmsContactConfig();

        // Act
        final json = cfg.toJson();

        // Assert
        check(json.containsKey('messageTemplate')).isFalse();
      });
    });

    group('JSON round-trip', () {
      test('default config round-trips equal', () {
        // Arrange
        const cfg = SmsContactConfig();

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.smsContact,
          cfg.toJson(),
        );

        // Assert
        check(decoded).isA<SmsContactConfig>();
        check(decoded as SmsContactConfig).equals(cfg);
      });

      test('fully-populated config round-trips equal', () {
        // Arrange
        const cfg = SmsContactConfig(
          contactIds: ['contact-1', 'contact-2'],
          contactSelection: SmsContactSelection.specificIds,
          channel: MessageChannel.telegram,
          includeLocation: false,
          includeMedicalInfo: true,
          autoRecordAudio: true,
          recordDurationSeconds: 60,
          messageTemplate: 'Custom template',
          blackScreenMode: true,
        );

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.smsContact,
          cfg.toJson(),
        );

        // Assert
        check(decoded as SmsContactConfig).equals(cfg);
      });

      test('round-trip preserves messageTemplate null', () {
        // Arrange
        const cfg = SmsContactConfig();

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.smsContact,
          cfg.toJson(),
        );

        // Assert
        check((decoded as SmsContactConfig).messageTemplate).isNull();
      });

      test('round-trip preserves non-null messageTemplate', () {
        // Arrange
        const cfg = SmsContactConfig(
          messageTemplate: 'Please call back, {name}.',
        );

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.smsContact,
          cfg.toJson(),
        );

        // Assert
        check(
          (decoded as SmsContactConfig).messageTemplate,
        ).equals('Please call back, {name}.');
      });

      test('round-trip preserves SmsContactSelection.allContacts by name', () {
        // Arrange
        const cfg = SmsContactConfig(
          contactSelection: SmsContactSelection.allContacts,
        );

        // Act
        final json = cfg.toJson();
        final decoded = StepConfig.fromJson(ChainStepType.smsContact, json);

        // Assert
        check(json['contactSelection']).equals('allContacts');
        check(
          (decoded as SmsContactConfig).contactSelection,
        ).equals(SmsContactSelection.allContacts);
      });

      test('round-trip preserves SmsContactSelection.firstContact by name '
          '(legacy)', () {
        // Arrange
        const cfg = SmsContactConfig(
          contactSelection: SmsContactSelection.firstContact,
        );

        // Act
        final json = cfg.toJson();
        final decoded = StepConfig.fromJson(ChainStepType.smsContact, json);

        // Assert
        check(json['contactSelection']).equals('firstContact');
        check(
          (decoded as SmsContactConfig).contactSelection,
        ).equals(SmsContactSelection.firstContact);
      });

      test('round-trip preserves SmsContactSelection.specificIds by name', () {
        // Arrange
        const cfg = SmsContactConfig(
          contactSelection: SmsContactSelection.specificIds,
          contactIds: ['x'],
        );

        // Act
        final json = cfg.toJson();
        final decoded = StepConfig.fromJson(ChainStepType.smsContact, json);

        // Assert
        check(json['contactSelection']).equals('specificIds');
        check(
          (decoded as SmsContactConfig).contactSelection,
        ).equals(SmsContactSelection.specificIds);
      });

      test('round-trip preserves channel through every MessageChannel', () {
        for (final ch in MessageChannel.values) {
          // Arrange
          final cfg = SmsContactConfig(channel: ch);

          // Act
          final decoded = StepConfig.fromJson(
            ChainStepType.smsContact,
            cfg.toJson(),
          );

          // Assert
          check((decoded as SmsContactConfig).channel).equals(ch);
        }
      });

      test('round-trip preserves contactIds list ordering', () {
        // Arrange
        const cfg = SmsContactConfig(
          contactSelection: SmsContactSelection.specificIds,
          contactIds: ['c3', 'c1', 'c2'],
        );

        // Act
        final decoded = StepConfig.fromJson(
          ChainStepType.smsContact,
          cfg.toJson(),
        );

        // Assert
        check(
          (decoded as SmsContactConfig).contactIds!,
        ).deepEquals(['c3', 'c1', 'c2']);
      });

      test('fromJson with empty map produces all defaults', () {
        // Arrange + Act
        final decoded = StepConfig.fromJson(
          ChainStepType.smsContact,
          <String, dynamic>{},
        );

        // Assert
        check(decoded).isA<SmsContactConfig>();
        check(decoded as SmsContactConfig).equals(const SmsContactConfig());
      });
    });

    group('copyWith + equality + hashCode', () {
      test('copyWith with no args returns equal instance', () {
        // Arrange
        const cfg = SmsContactConfig(
          contactIds: ['a'],
          recordDurationSeconds: 7,
        );

        // Act
        final copy = cfg.copyWith();

        // Assert
        check(copy).equals(cfg);
        check(copy.hashCode).equals(cfg.hashCode);
      });

      test('copyWith replaces only the specified field', () {
        // Arrange
        const cfg = SmsContactConfig(channel: MessageChannel.sms);

        // Act
        final copy = cfg.copyWith(channel: MessageChannel.whatsapp);

        // Assert
        check(copy.channel).equals(MessageChannel.whatsapp);
        check(copy.includeLocation).equals(cfg.includeLocation);
        check(copy.includeMedicalInfo).equals(cfg.includeMedicalInfo);
      });

      test('two configs with identical fields are equal', () {
        // Arrange
        const a = SmsContactConfig(
          contactIds: ['x', 'y'],
          contactSelection: SmsContactSelection.specificIds,
          channel: MessageChannel.whatsapp,
          messageTemplate: 'tpl',
        );
        const b = SmsContactConfig(
          contactIds: ['x', 'y'],
          contactSelection: SmsContactSelection.specificIds,
          channel: MessageChannel.whatsapp,
          messageTemplate: 'tpl',
        );

        // Assert
        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('two configs with differing channel are not equal', () {
        // Arrange
        const a = SmsContactConfig(channel: MessageChannel.sms);
        const b = SmsContactConfig(channel: MessageChannel.telegram);

        // Assert
        check(a == b).isFalse();
      });

      test('configs with different contactIds length are not equal', () {
        // Arrange
        const a = SmsContactConfig(contactIds: ['x']);
        const b = SmsContactConfig(contactIds: ['x', 'y']);

        // Assert
        check(a == b).isFalse();
      });

      test('configs with different contactIds elements are not equal', () {
        // Arrange
        const a = SmsContactConfig(contactIds: ['x', 'y']);
        const b = SmsContactConfig(contactIds: ['x', 'z']);

        // Assert
        check(a == b).isFalse();
      });

      test('identical reference equals itself (short-circuit)', () {
        // Arrange
        const cfg = SmsContactConfig();

        // Assert
        check(cfg == cfg).isTrue();
      });

      test('config never equals an unrelated type', () {
        // Arrange
        const cfg = SmsContactConfig();

        // Assert
        check(cfg == const Object()).isFalse();
      });
    });
  });
}
