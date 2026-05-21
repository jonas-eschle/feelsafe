/// Supplemental tests for [SessionContext] covering the
/// `resolvePreSmsTemplateForContact` method branches:
///  - resolver present + returns localized value → localized string used
///  - resolver present + returns null → falls back to defaultPreSmsTemplate
///  - resolver present + returns empty string → falls back to default
///  - resolver absent (null) → falls back to defaultPreSmsTemplate
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';

EmergencyContact _contact({String? languageCode}) => EmergencyContact(
  id: 'c1',
  name: 'Alice',
  phoneNumber: '+15551234567',
  sortOrder: 0,
  channels: const [MessageChannel.sms],
  languageCode: languageCode,
);

void main() {
  group('SessionContext.resolvePreSmsTemplateForContact', () {
    test('returns localized value when resolver returns non-empty string',
        () {
      const context = SessionContext(
        defaultPreSmsTemplate: 'DEFAULT',
        preSmsTemplateForLanguage: _resolveDE,
      );
      final result = context.resolvePreSmsTemplateForContact(
        _contact(languageCode: 'de'),
      );
      check(result).equals('Ich komme zu spät.');
    });

    test('falls back to default when resolver returns null', () {
      const context = SessionContext(
        defaultPreSmsTemplate: 'DEFAULT',
        preSmsTemplateForLanguage: _resolveNull,
      );
      final result = context.resolvePreSmsTemplateForContact(
        _contact(languageCode: 'en'),
      );
      check(result).equals('DEFAULT');
    });

    test('falls back to default when resolver returns empty string', () {
      const context = SessionContext(
        defaultPreSmsTemplate: 'DEFAULT',
        preSmsTemplateForLanguage: _resolveEmpty,
      );
      final result = context.resolvePreSmsTemplateForContact(
        _contact(languageCode: 'fr'),
      );
      check(result).equals('DEFAULT');
    });

    test('falls back to default when preSmsTemplateForLanguage is null',
        () {
      const context = SessionContext(
        defaultPreSmsTemplate: 'FALLBACK',
      );
      final result = context.resolvePreSmsTemplateForContact(
        _contact(languageCode: 'de'),
      );
      check(result).equals('FALLBACK');
    });
  });

  group('SessionContext.resolveSmsTemplateForContact (existing)', () {
    test('returns localized value when resolver returns non-empty string',
        () {
      const context = SessionContext(
        defaultSmsTemplate: 'DEFAULT',
        smsTemplateForLanguage: _resolveDE,
      );
      final result = context.resolveSmsTemplateForContact(
        _contact(languageCode: 'de'),
      );
      check(result).equals('Ich komme zu spät.');
    });

    test('falls back when resolver returns null for unknown language', () {
      const context = SessionContext(
        defaultSmsTemplate: 'MY_DEFAULT',
        smsTemplateForLanguage: _resolveNull,
      );
      final result = context.resolveSmsTemplateForContact(
        _contact(languageCode: 'xx'),
      );
      check(result).equals('MY_DEFAULT');
    });
  });
}

// Top-level functions so they can be used as const SmsTemplateResolver values.

String? _resolveDE(String? lang) => lang == 'de' ? 'Ich komme zu spät.' : null;

String? _resolveNull(String? lang) => null;

String? _resolveEmpty(String? lang) => '';
