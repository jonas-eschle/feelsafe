/// Unit tests for the R-8 emergency-number map and locale resolver
/// (`lib/domain/models/emergency_numbers.dart`).
///
/// This is safety-critical data — the app dials the resolved number — so the
/// suite asserts: (1) the map is well-formed (valid ISO keys, dialable
/// numbers, no accidental duplicate-key shadowing); (2) the owner-mandated
/// adjustments landed (PK=15, DE=112) and the re-confirmed entries are present
/// (CO=123, ZA=112, ET=911, CI=111); (3) the locale resolver maps a device
/// region to its number and falls back to '112' for unmapped / region-less
/// input.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/models/emergency_numbers.dart';

void main() {
  group('emergencyNumbers map — well-formed', () {
    test('keys are 2-letter upper-case ISO 3166 alpha-2 codes', () {
      final RegExp isoKey = RegExp(r'^[A-Z]{2}$');
      for (final String key in emergencyNumbers.keys) {
        check(isoKey.hasMatch(key)).isTrue();
      }
    });

    test('every number contains only dialable chars (0-9 + * #)', () {
      final RegExp dialable = RegExp(r'^[0-9+*#]+$');
      emergencyNumbers.forEach((String region, String number) {
        check(number).isNotEmpty();
        check(dialable.hasMatch(number)).isTrue();
      });
    });

    test('contains exactly the 109 reviewed countries', () {
      // Exact count (not a floor) so silent map truncation OR an accidental
      // duplicate-key collapse is caught — the reviewed draft is 109 entries.
      check(emergencyNumbers.length).equals(109);
    });
  });

  group('owner-mandated adjustments (R-8 review, 2026-06-09)', () {
    test('Pakistan is the police line 15 (not Rescue 1122)', () {
      check(emergencyNumbers['PK']).equals('15');
    });

    test('Germany is the EU unified line 112', () {
      check(emergencyNumbers['DE']).equals('112');
    });

    test('South Africa keeps 112 (mobile all-services route)', () {
      check(emergencyNumbers['ZA']).equals('112');
    });

    test('re-confirmed corrected entries hold', () {
      check(emergencyNumbers['CO']).equals('123'); // NUSE unified line.
      check(emergencyNumbers['DZ']).equals('17'); // police line.
      check(emergencyNumbers['IQ']).equals('104'); // police line.
      check(emergencyNumbers['MM']).equals('199'); // police line.
    });

    test('flagged-but-shipped entries are present', () {
      // ET/CI ship the best pick + an inline // VERIFY comment.
      check(emergencyNumbers['ET']).equals('911');
      check(emergencyNumbers['CI']).equals('111');
    });

    test('split-country police lines are the police number', () {
      check(emergencyNumbers['CN']).equals('110');
      check(emergencyNumbers['JP']).equals('110');
      check(emergencyNumbers['BR']).equals('190');
      check(emergencyNumbers['VN']).equals('113');
      check(emergencyNumbers['KR']).equals('112');
    });

    test('the EU / GSM-112 block resolves to 112', () {
      for (final String eu in <String>[
        'FR',
        'IT',
        'ES',
        'PL',
        'NL',
        'BE',
        'SE',
        'PT',
        'GR',
        'AT',
        'IE',
        'FI',
        'DK',
        'NO',
      ]) {
        check(emergencyNumbers[eu]).equals('112');
      }
    });
  });

  group('kEmergencyFallback', () {
    test('is the GSM international standard 112', () {
      check(kEmergencyFallback).equals('112');
    });
  });

  group('emergencyNumberForLocale — region resolution', () {
    test('lang_REGION maps to the region number', () {
      check(emergencyNumberForLocale('en_US')).equals('911');
      check(emergencyNumberForLocale('de_DE')).equals('112');
      check(emergencyNumberForLocale('en_GB')).equals('999');
      check(emergencyNumberForLocale('en_PK')).equals('15');
    });

    test('lang-REGION (hyphen form) is handled', () {
      check(emergencyNumberForLocale('de-DE')).equals('112');
      check(emergencyNumberForLocale('pt-BR')).equals('190');
    });

    test('a POSIX codeset/modifier suffix is stripped', () {
      check(emergencyNumberForLocale('pt_BR.UTF-8')).equals('190');
      check(emergencyNumberForLocale('fr_FR@euro')).equals('112');
      check(emergencyNumberForLocale('en_US.UTF-8')).equals('911');
    });

    test('a region-less language tag falls back to 112', () {
      check(emergencyNumberForLocale('en')).equals('112');
      check(emergencyNumberForLocale('de')).equals('112');
      check(emergencyNumberForLocale('und')).equals('112');
    });

    test('an empty locale falls back to 112', () {
      check(emergencyNumberForLocale('')).equals('112');
    });

    test('an unmapped region falls back to 112', () {
      // A real-looking but unmapped region (e.g. Greenland) → fallback.
      check(emergencyNumberForLocale('da_GL')).equals('112');
      check(emergencyNumberForLocale('xx_ZZ')).equals('112');
    });

    test('region matching is case-insensitive', () {
      check(emergencyNumberForLocale('en_us')).equals('911');
      check(emergencyNumberForLocale('de_de')).equals('112');
    });

    test('always returns a non-empty dialable number', () {
      final RegExp dialable = RegExp(r'^[0-9+*#]+$');
      for (final String loc in <String>[
        'en_US',
        'zz_ZZ',
        '',
        'fr',
        'ja_JP',
        'en_ZA',
      ]) {
        final String n = emergencyNumberForLocale(loc);
        check(n).isNotEmpty();
        check(dialable.hasMatch(n)).isTrue();
      }
    });
  });
}
