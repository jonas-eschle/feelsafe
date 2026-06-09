/// Unit tests for [PhoneValidators] (spec 06 §Emergency Number, Extra 25/26).
///
/// Pure-Dart: drives the real validators with no Flutter/widget dependency.
/// Covers the allowed character class, the length-guidance boundaries, the
/// empty (Save-blocking) case for the emergency number, and the more lenient
/// contact-number character class.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/core/utils/phone_validators.dart';

void main() {
  group('warnEmergencyNumber — character class (spec 06:231)', () {
    test('digits only is accepted', () {
      check(PhoneValidators.warnEmergencyNumber('911')).isNull();
    });

    test('+ * # are allowed', () {
      check(PhoneValidators.warnEmergencyNumber('+112')).isNull();
      check(PhoneValidators.warnEmergencyNumber('*123')).isNull();
      check(PhoneValidators.warnEmergencyNumber('#123')).isNull();
      check(PhoneValidators.warnEmergencyNumber('*123#')).isNull();
    });

    test('letters warn invalidCharacters', () {
      check(
        PhoneValidators.warnEmergencyNumber('abc'),
      ).equals(PhoneNumberWarning.invalidCharacters);
      check(
        PhoneValidators.warnEmergencyNumber('1a2'),
      ).equals(PhoneNumberWarning.invalidCharacters);
    });

    test('spaces, hyphens and parentheses warn invalidCharacters', () {
      check(
        PhoneValidators.warnEmergencyNumber('11 2'),
      ).equals(PhoneNumberWarning.invalidCharacters);
      check(
        PhoneValidators.warnEmergencyNumber('11-2'),
      ).equals(PhoneNumberWarning.invalidCharacters);
      check(
        PhoneValidators.warnEmergencyNumber('(11)2'),
      ).equals(PhoneNumberWarning.invalidCharacters);
    });

    test('invalid-character check precedes the length checks', () {
      // "1a" is both too short (1 digit) and contains a letter; the character
      // class is reported first.
      check(
        PhoneValidators.warnEmergencyNumber('1a'),
      ).equals(PhoneNumberWarning.invalidCharacters);
    });
  });

  group('warnEmergencyNumber — length guidance (spec 06:234-238)', () {
    test('empty is the empty (Save-blocking) warning', () {
      check(
        PhoneValidators.warnEmergencyNumber(''),
      ).equals(PhoneNumberWarning.empty);
    });

    test('fewer than 3 digits warns tooShort', () {
      check(
        PhoneValidators.warnEmergencyNumber('1'),
      ).equals(PhoneNumberWarning.tooShort);
      check(
        PhoneValidators.warnEmergencyNumber('11'),
      ).equals(PhoneNumberWarning.tooShort);
    });

    test('exactly 3 digits is accepted (lower boundary)', () {
      check(PhoneValidators.warnEmergencyNumber('112')).isNull();
      check(PhoneValidators.warnEmergencyNumber('000')).isNull();
    });

    test('4 to 6 digits are accepted', () {
      check(PhoneValidators.warnEmergencyNumber('1515')).isNull();
      check(PhoneValidators.warnEmergencyNumber('10111')).isNull();
      check(PhoneValidators.warnEmergencyNumber('999999')).isNull();
    });

    test(
      'more than 6 digits warns looksLikeRegularNumber (upper boundary)',
      () {
        check(
          PhoneValidators.warnEmergencyNumber('9999999'),
        ).equals(PhoneNumberWarning.looksLikeRegularNumber);
        check(
          PhoneValidators.warnEmergencyNumber('5551234567'),
        ).equals(PhoneNumberWarning.looksLikeRegularNumber);
      },
    );

    test('non-digit allowed chars do not count toward the digit length', () {
      // "+12" has only 2 digits → too short despite 3 characters.
      check(
        PhoneValidators.warnEmergencyNumber('+12'),
      ).equals(PhoneNumberWarning.tooShort);
      // "+112" has 3 digits → accepted.
      check(PhoneValidators.warnEmergencyNumber('+112')).isNull();
    });
  });

  group('warnContactNumber (Extra 26)', () {
    test('empty warns empty (advisory; the form blocks separately)', () {
      check(
        PhoneValidators.warnContactNumber(''),
      ).equals(PhoneNumberWarning.empty);
    });

    test('a formatted regular number with spaces and hyphens is accepted', () {
      check(PhoneValidators.warnContactNumber('+1 555-123-4567')).isNull();
      check(PhoneValidators.warnContactNumber('555 1234')).isNull();
      check(PhoneValidators.warnContactNumber('5551234567')).isNull();
    });

    test('a long number does NOT warn (contacts are regular numbers)', () {
      // Unlike the emergency number, length is never flagged for a contact.
      check(PhoneValidators.warnContactNumber('00441234567890')).isNull();
    });

    test('letters, dots and parentheses warn invalidCharacters', () {
      check(
        PhoneValidators.warnContactNumber('555.123'),
      ).equals(PhoneNumberWarning.invalidCharacters);
      check(
        PhoneValidators.warnContactNumber('(555)1234'),
      ).equals(PhoneNumberWarning.invalidCharacters);
      check(
        PhoneValidators.warnContactNumber('call-me'),
      ).equals(PhoneNumberWarning.invalidCharacters);
    });
  });
}
