/// Wiring map coverage test.
///
/// Parses `docs/wiring-map.md` and verifies every provider cited in
/// the "Provider" column exists in either `service_providers.dart`
/// or `repository_providers.dart`. Keeps the wiring map honest as
/// Phase 11 fills controllers out.
///
/// Closes L8 (wiring-map drift) per `docs/rebuild-strategy.md` §2.
library;

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:test/test.dart';

void main() {
  group('docs/wiring-map.md', () {
    late String wiringMap;
    late Set<String> knownProviderNames;

    setUpAll(() {
      wiringMap = File('docs/wiring-map.md').readAsStringSync();
      knownProviderNames = <String>{};
      for (final path in <String>[
        'lib/services/service_providers.dart',
        'lib/data/repositories/repository_providers.dart',
      ]) {
        final text = File(path).readAsStringSync();
        final regex = RegExp(r'final\s+([A-Za-z0-9_]+Provider)\s*=');
        for (final match in regex.allMatches(text)) {
          knownProviderNames.add(match.group(1)!);
        }
        // Also pick up typed declarations like:
        // final AsyncNotifierProvider<...> fooProvider =
        final typedRegex = RegExp(
          r'\s+([A-Za-z0-9_]+Provider)\s*=\s*(?:AsyncNotifierProvider|Provider)',
        );
        for (final match in typedRegex.allMatches(text)) {
          knownProviderNames.add(match.group(1)!);
        }
      }
      // Also include the feature-level controller providers cited in
      // the map — each lives beside its controller.
      for (final file in <String>[
        'lib/features/session/session_controller.dart',
        'lib/features/settings/settings_controller.dart',
        'lib/features/battery_alert/battery_alert_controller.dart',
      ]) {
        final text = File(file).readAsStringSync();
        final regex = RegExp(r'([A-Za-z0-9_]+Provider)\s*=');
        for (final match in regex.allMatches(text)) {
          knownProviderNames.add(match.group(1)!);
        }
      }
    });

    test('every row cites a known provider', () {
      final rowProvidersRegex = RegExp(
        r'^\|\s*`[^`]+`\s*\|\s*`([A-Za-z0-9_]+Provider)`',
        multiLine: true,
      );
      final cited = <String>{};
      for (final match in rowProvidersRegex.allMatches(wiringMap)) {
        cited.add(match.group(1)!);
      }
      check(cited).isNotEmpty();
      for (final name in cited) {
        check(
          because:
              'Wiring map cites "$name" but no such provider exists in '
              'service_providers.dart / repository_providers.dart / '
              'feature controllers',
          knownProviderNames.contains(name),
        ).isTrue();
      }
    });

    test('table has at least 15 rows of safety-critical wiring', () {
      final rowsRegex = RegExp(
        r'^\|\s*`[^`]+`\s*\|\s*`[A-Za-z0-9_]+Provider`',
        multiLine: true,
      );
      final rowCount = rowsRegex.allMatches(wiringMap).length;
      check(
        because:
            'The wiring map must document at least 15 '
            'safety-critical field→provider→service rows (L8).',
        rowCount,
      ).isGreaterOrEqual(15);
    });

    test('each cited provider is referenced by at least one row', () {
      // Sanity: we expect several core providers to appear.
      final expected = <String>[
        'settingsControllerProvider',
        'modesRepositoryProvider',
        'batteryAlertControllerProvider',
        'contactsRepositoryProvider',
      ];
      for (final name in expected) {
        check(
          because:
              'Core provider "$name" must have at least one wiring-map '
              'row documenting its side-effects (L8).',
          wiringMap.contains(name),
        ).isTrue();
      }
    });
  });
}
